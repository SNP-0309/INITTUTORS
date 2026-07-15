from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView

from apps.common.responses import success
from apps.common.permissions import IsAdmin
from .serializers import InstituteSerializer
from . import services


class InstituteListCreateView(APIView):
    """GET /api/v1/institutes/ — List institutes
    POST /api/v1/institutes/ — Create institute (Admin only)
    """
    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request):
        institutes = services.get_institutes_list()
        serializer = InstituteSerializer(institutes, many=True)
        return success(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        serializer = InstituteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        institute = services.create_institute(data=serializer.validated_data)
        return success(InstituteSerializer(institute).data, status=status.HTTP_201_CREATED)


class InstituteDetailView(APIView):
    """GET /api/v1/institutes/:id — Get details of a specific institute
    PUT /api/v1/institutes/:id — Update institute (Admin only)
    DELETE /api/v1/institutes/:id — Delete institute (Admin only)
    """
    def get_permissions(self):
        if self.request.method in ["PUT", "PATCH", "DELETE"]:
            return [IsAdmin()]
        return [IsAuthenticated()]

    def get(self, request, pk):
        institute = services.get_institute(institute_id=pk)
        serializer = InstituteSerializer(institute)
        return success(serializer.data, status=status.HTTP_200_OK)

    def put(self, request, pk):
        serializer = InstituteSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        institute = services.update_institute(institute_id=pk, data=serializer.validated_data)
        return success(InstituteSerializer(institute).data, status=status.HTTP_200_OK)

    def delete(self, request, pk):
        institute = services.get_institute(institute_id=pk)
        institute.soft_delete()
        return success(None, status=status.HTTP_204_NO_CONTENT)
