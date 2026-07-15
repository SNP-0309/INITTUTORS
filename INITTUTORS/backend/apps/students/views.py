from django.db.models import Q
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination
from django.shortcuts import get_object_or_404

from apps.common.responses import success
from apps.common.permissions import IsAdmin
from .models import Student
from .serializers import StudentSerializer
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


class StudentListCreateView(APIView):
    """GET /api/v1/students/ — List, search, and paginate students
    POST /api/v1/students/ — Create a new student with optional parent profile (Admin only)
    """
    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request):
        queryset = Student.objects.all().order_by("first_name", "last_name")

        search_query = request.query_params.get("search")
        if search_query:
            queryset = queryset.filter(
                Q(first_name__icontains=search_query) |
                Q(last_name__icontains=search_query) |
                Q(phone__icontains=search_query) |
                Q(parent_phone__icontains=search_query) |
                Q(roll_number__icontains=search_query) |
                Q(standard__icontains=search_query) |
                Q(student_parent_links__parent__user__full_name__icontains=search_query)
            ).distinct()

        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request, view=self)
        if page is not None:
            serializer = StudentSerializer(page, many=True)
            return paginator.get_paginated_response(serializer.data)

        serializer = StudentSerializer(queryset, many=True)
        return success(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = StudentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        student = serializer.save()
        return success(StudentSerializer(student).data, status=status.HTTP_201_CREATED)


class StudentDetailView(APIView):
    """GET /api/v1/students/:id — Retrieve student details
    PUT /api/v1/students/:id — Update student details (Admin only)
    DELETE /api/v1/students/:id — Soft-delete student (Admin only)
    """
    def get_permissions(self):
        if self.request.method in ["PUT", "PATCH", "DELETE"]:
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request, pk):
        student = get_object_or_404(Student, id=pk)
        serializer = StudentSerializer(student)
        return success(serializer.data, status=status.HTTP_200_OK)

    def put(self, request, pk):
        student = get_object_or_404(Student, id=pk)
        serializer = StudentSerializer(student, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        updated_student = serializer.save()
        return success(StudentSerializer(updated_student).data, status=status.HTTP_200_OK)

    def delete(self, request, pk):
        services.delete_student(student_id=pk)
        return success(None, status=status.HTTP_204_NO_CONTENT)
