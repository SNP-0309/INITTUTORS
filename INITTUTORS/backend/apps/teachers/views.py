from django.db.models import Q
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination

from apps.common.responses import success
from apps.common.permissions import IsAdmin
from .models import Teacher
from .serializers import TeacherSerializer
from . import services


class StandardResultsSetPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = "page_size"
    max_page_size = 100

    def get_paginated_response(self, data):
        return success({
            "count": self.page.paginator.count,
            "next": self.get_next_link(),
            "previous": self.get_previous_link(),
            "results": data
        })


class TeacherListCreateView(APIView):
    """GET /api/v1/teachers/ — List, search, and paginate teachers
    POST /api/v1/teachers/ — Create a new teacher with linked User profile (Admin only)
    """
    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request):
        queryset = Teacher.objects.all().select_related("user").order_by("user__full_name")

        search_query = request.query_params.get("search")
        if search_query:
            queryset = queryset.filter(
                Q(user__full_name__icontains=search_query) |
                Q(user__phone__icontains=search_query) |
                Q(user__email__icontains=search_query) |
                Q(employee_code__icontains=search_query) |
                Q(specialization__icontains=search_query)
            )

        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request, view=self)
        if page is not None:
            serializer = TeacherSerializer(page, many=True)
            return paginator.get_paginated_response(serializer.data)

        serializer = TeacherSerializer(queryset, many=True)
        return success(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = TeacherSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        teacher = serializer.save()
        return success(TeacherSerializer(teacher).data, status=status.HTTP_201_CREATED)


class TeacherDetailView(APIView):
    """GET /api/v1/teachers/:id — Retrieve teacher details
    PUT /api/v1/teachers/:id — Update teacher details (Admin only)
    DELETE /api/v1/teachers/:id — Soft-delete teacher and user profile (Admin only)
    """
    def get_permissions(self):
        if self.request.method in ["PUT", "PATCH", "DELETE"]:
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request, pk):
        teacher = services.get_teacher(teacher_id=pk)
        serializer = TeacherSerializer(teacher)
        return success(serializer.data, status=status.HTTP_200_OK)

    def put(self, request, pk):
        teacher = services.get_teacher(teacher_id=pk)
        serializer = TeacherSerializer(teacher, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        updated_teacher = serializer.save()
        return success(TeacherSerializer(updated_teacher).data, status=status.HTTP_200_OK)

    def delete(self, request, pk):
        services.delete_teacher(teacher_id=pk)
        return success(None, status=status.HTTP_204_NO_CONTENT)
