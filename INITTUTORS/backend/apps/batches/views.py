from django.db.models import Q
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination
from django.shortcuts import get_object_or_404

from apps.common.responses import success
from apps.common.permissions import IsAdmin
from .models import Batch, Subject, Classroom, BatchStudent
from .serializers import BatchSerializer, SubjectSerializer, ClassroomSerializer, BatchStudentSerializer
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


class SubjectListCreateView(APIView):
    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request):
        subjects = Subject.objects.all().order_by("name")
        serializer = SubjectSerializer(subjects, many=True)
        return success(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = SubjectSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        subject = serializer.save()
        return success(SubjectSerializer(subject).data, status=status.HTTP_201_CREATED)


class ClassroomListCreateView(APIView):
    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request):
        classrooms = Classroom.objects.all().order_by("name")
        serializer = ClassroomSerializer(classrooms, many=True)
        return success(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = ClassroomSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        classroom = serializer.save()
        return success(ClassroomSerializer(classroom).data, status=status.HTTP_201_CREATED)


class BatchListCreateView(APIView):
    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request):
        queryset = Batch.objects.all().select_related("subject", "teacher__user", "classroom").order_by("name")

        search_query = request.query_params.get("search")
        if search_query:
            queryset = queryset.filter(
                Q(name__icontains=search_query) |
                Q(subject__name__icontains=search_query) |
                Q(teacher__user__full_name__icontains=search_query) |
                Q(standard__icontains=search_query)
            )

        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request, view=self)
        if page is not None:
            serializer = BatchSerializer(page, many=True)
            return paginator.get_paginated_response(serializer.data)

        serializer = BatchSerializer(queryset, many=True)
        return success(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = BatchSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        batch = serializer.save()
        return success(BatchSerializer(batch).data, status=status.HTTP_201_CREATED)


class BatchDetailView(APIView):
    def get_permissions(self):
        if self.request.method in ["PUT", "PATCH", "DELETE"]:
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request, pk):
        batch = get_object_or_404(Batch, id=pk)
        serializer = BatchSerializer(batch)
        # Roster list of active enrolled students
        enrollments = batch.batch_students.filter(status="active").select_related("student")
        roster_serializer = BatchStudentSerializer(enrollments, many=True)
        return success({
            "batch": serializer.data,
            "roster": roster_serializer.data
        }, status=status.HTTP_200_OK)

    def put(self, request, pk):
        batch = get_object_or_404(Batch, id=pk)
        serializer = BatchSerializer(batch, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        updated_batch = serializer.save()
        return success(BatchSerializer(updated_batch).data, status=status.HTTP_200_OK)

    def delete(self, request, pk):
        batch = get_object_or_404(Batch, id=pk)
        batch.soft_delete()
        return success(None, status=status.HTTP_204_NO_CONTENT)


class BatchStudentAssignView(APIView):
    permission_classes = [IsAdmin]

    def post(self, request, pk):
        student_id = request.data.get("student_id")
        if not student_id:
            return success(None, status=status.HTTP_400_BAD_REQUEST)
            
        services.assign_student_to_batch(batch_id=pk, student_id=student_id)
        return success(None, status=status.HTTP_204_NO_CONTENT)


class BatchStudentRemoveView(APIView):
    permission_classes = [IsAdmin]

    def post(self, request, pk):
        student_id = request.data.get("student_id")
        if not student_id:
            return success(None, status=status.HTTP_400_BAD_REQUEST)
            
        services.remove_student_from_batch(batch_id=pk, student_id=student_id)
        return success(None, status=status.HTTP_204_NO_CONTENT)
