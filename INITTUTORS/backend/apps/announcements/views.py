from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404

from apps.common.responses import success
from apps.common.permissions import IsAdmin
from .models import Announcement
from .serializers import AnnouncementSerializer


class AnnouncementListCreateView(APIView):
    """GET  /api/v1/announcements/  — list all announcements (filterable by category/role)
       POST /api/v1/announcements/  — create a new announcement (admin only)
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qs = Announcement.objects.select_related("created_by")
        category = request.query_params.get("category")
        target_role = request.query_params.get("role")
        if category:
            qs = qs.filter(category=category)
        if target_role:
            qs = qs.filter(target_role__in=[target_role, "all"])
        serializer = AnnouncementSerializer(qs, many=True)
        return success(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = AnnouncementSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        ann = serializer.save()
        return success(
            AnnouncementSerializer(ann, context={"request": request}).data,
            status=status.HTTP_201_CREATED,
        )


class AnnouncementDetailView(APIView):
    """GET    /api/v1/announcements/{id}/
       PUT    /api/v1/announcements/{id}/
       DELETE /api/v1/announcements/{id}/
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        ann = get_object_or_404(Announcement, id=pk)
        return success(AnnouncementSerializer(ann).data, status=status.HTTP_200_OK)

    def put(self, request, pk):
        ann = get_object_or_404(Announcement, id=pk)
        serializer = AnnouncementSerializer(
            ann, data=request.data, partial=True, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        updated = serializer.save()
        return success(AnnouncementSerializer(updated).data, status=status.HTTP_200_OK)

    def delete(self, request, pk):
        ann = get_object_or_404(Announcement, id=pk)
        ann.delete()
        return success(None, status=status.HTTP_204_NO_CONTENT)
