"""Serializers for the authentication module.

Serializers validate/shape input and output at the boundary only. Auth
business logic (credential checks, token issuance, blacklisting) lives in
`services.py`.
"""

from rest_framework import serializers

from .models import User


class UserSerializer(serializers.ModelSerializer):
    """Public user representation (api.md §3.4 / §3 `/me`).

    Explicit allow-list — never exposes `password`/internal flags
    (backend.md §6.3). `institute_id` is null: multi-tenancy is out of scope
    (database.md §2).
    """

    name = serializers.CharField(source="full_name", read_only=True)
    institute_id = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ["id", "name", "email", "phone", "role", "status", "institute_id"]
        read_only_fields = fields

    def get_institute_id(self, obj) -> None:
        return None


class LoginSerializer(serializers.Serializer):
    """Login input (api.md §3.4): email + password."""

    email = serializers.EmailField()
    password = serializers.CharField(
        write_only=True, min_length=1, trim_whitespace=False
    )


class LogoutSerializer(serializers.Serializer):
    """Logout input: the refresh token to invalidate (api.md §3.4)."""

    refresh_token = serializers.CharField()


class RefreshSerializer(serializers.Serializer):
    """Refresh input (api.md §3.4): a valid refresh token."""

    refresh_token = serializers.CharField()
