"""Django admin registration for the User model."""

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    ordering = ("full_name",)
    list_display = ("full_name", "email", "phone", "role", "status", "is_active")
    list_filter = ("role", "status", "is_active")
    search_fields = ("full_name", "email", "phone")

    fieldsets = (
        (None, {"fields": ("phone", "password")}),
        ("Profile", {"fields": ("full_name", "email", "photo_url", "role", "status")}),
        ("Permissions", {"fields": ("is_active", "is_staff", "is_superuser", "groups", "user_permissions")}),
        ("Important dates", {"fields": ("last_login", "created_at", "updated_at", "deleted_at")}),
    )
    readonly_fields = ("last_login", "created_at", "updated_at")
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": ("phone", "full_name", "email", "role", "password1", "password2"),
            },
        ),
    )
