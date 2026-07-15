from django.contrib import admin
from .models import Institute


@admin.register(Institute)
class InstituteAdmin(admin.ModelAdmin):
    list_display = ("name", "phone", "email", "status", "timezone", "created_at")
    list_filter = ("status", "timezone")
    search_fields = ("name", "phone", "email", "city", "state")
    readonly_fields = ("created_at", "updated_at", "deleted_at")
    fieldsets = (
        (None, {"fields": ("name", "status")}),
        ("Contact Details", {"fields": ("phone", "email", "website", "logo_url")}),
        ("Address", {"fields": ("address", "city", "state", "pincode")}),
        ("System/Audit Details", {"fields": ("timezone", "created_at", "updated_at", "deleted_at")}),
    )
