from django.contrib import admin
from .models import Teacher


@admin.register(Teacher)
class TeacherAdmin(admin.ModelAdmin):
    list_display = ("get_name", "employee_code", "specialization", "joining_date", "status", "created_at")
    list_filter = ("status", "specialization")
    search_fields = ("user__full_name", "user__phone", "user__email", "employee_code")
    readonly_fields = ("created_at", "updated_at", "deleted_at")
    fieldsets = (
        (None, {"fields": ("user", "status")}),
        ("Professional Details", {"fields": ("employee_code", "specialization", "joining_date")}),
        ("System/Audit Details", {"fields": ("created_at", "updated_at", "deleted_at")}),
    )

    def get_name(self, obj):
        return obj.user.full_name
    get_name.short_description = "Teacher Name"
