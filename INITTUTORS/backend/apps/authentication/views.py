"""HTTP views for the authentication module.

Thin controllers (backend.md §2.2): parse/validate input, call the service,
shape the response envelope. No business logic here.
"""

from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView

from apps.common.responses import success

from . import services
from .serializers import (
    LoginSerializer,
    LogoutSerializer,
    RefreshSerializer,
    UserSerializer,
)
from .throttling import LoginRateThrottle


def _auth_payload(result: dict) -> dict:
    """Shape the login/refresh service result into the api.md §3.4 envelope."""
    return {
        "access_token": result["access_token"],
        "refresh_token": result["refresh_token"],
        "expires_in": result["expires_in"],
        "user": UserSerializer(result["user"]).data,
    }


class LoginView(APIView):
    """POST /api/v1/auth/login — email + password (api.md §3.4)."""

    permission_classes = [AllowAny]
    throttle_classes = [LoginRateThrottle]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        result = services.login(**serializer.validated_data)
        return success(_auth_payload(result), status=status.HTTP_200_OK)


class RefreshView(APIView):
    """POST /api/v1/auth/refresh — rotate tokens (api.md §3.4)."""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RefreshSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        result = services.refresh(**serializer.validated_data)
        return success(_auth_payload(result), status=status.HTTP_200_OK)


class LogoutView(APIView):
    """POST /api/v1/auth/logout — blacklist the refresh token (api.md §3.4)."""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = LogoutSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        services.logout(**serializer.validated_data)
        return success(None, status=status.HTTP_204_NO_CONTENT)


class MeView(APIView):
    """GET /api/v1/auth/me — the authenticated user's profile (api.md §3.4)."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        return success(UserSerializer(request.user).data)
