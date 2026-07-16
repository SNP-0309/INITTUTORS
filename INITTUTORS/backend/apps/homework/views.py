from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404

from apps.common.responses import success
from apps.common.permissions import IsAdmin
from .models import Homework
from .serializers import HomeworkSerializer


class HomeworkListCreateView(APIView):
    """GET  /api/v1/homework/  — list assignments (filter by batch_id)
       POST /api/v1/homework/  — create a new homework assignment (admin/teacher)
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qs = Homework.objects.select_related("batch", "uploaded_by")
        batch_id = request.query_params.get("batch_id")
        if batch_id:
            qs = qs.filter(batch_id=batch_id)
        serializer = HomeworkSerializer(qs, many=True)
        return success(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = HomeworkSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        hw = serializer.save()
        return success(HomeworkSerializer(hw, context={"request": request}).data, status=status.HTTP_201_CREATED)


class HomeworkDetailView(APIView):
    """GET    /api/v1/homework/{id}/
       PUT    /api/v1/homework/{id}/
       DELETE /api/v1/homework/{id}/
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        hw = get_object_or_404(Homework, id=pk)
        serializer = HomeworkSerializer(hw)
        return success(serializer.data, status=status.HTTP_200_OK)

    def put(self, request, pk):
        hw = get_object_or_404(Homework, id=pk)
        serializer = HomeworkSerializer(hw, data=request.data, partial=True, context={"request": request})
        serializer.is_valid(raise_exception=True)
        updated = serializer.save()
        return success(HomeworkSerializer(updated).data, status=status.HTTP_200_OK)

    def delete(self, request, pk):
        hw = get_object_or_404(Homework, id=pk)
        hw.delete()
        return success(None, status=status.HTTP_204_NO_CONTENT)
