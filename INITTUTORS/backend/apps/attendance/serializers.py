from rest_framework import serializers
from apps.students.serializers import StudentSerializer
from .models import AttendanceRecord


class AttendanceRecordSerializer(serializers.ModelSerializer):
    student_name = serializers.SerializerMethodField(read_only=True)
    student_roll = serializers.SerializerMethodField(read_only=True)
    student_photo = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = AttendanceRecord
        fields = [
            "id",
            "batch",
            "student",
            "student_name",
            "student_roll",
            "student_photo",
            "date",
            "status",
            "notes",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]

    def get_student_name(self, obj):
        return f"{obj.student.first_name} {obj.student.last_name or ''}".strip()

    def get_student_roll(self, obj):
        return obj.student.roll_number

    def get_student_photo(self, obj):
        return obj.student.photo_url


class BulkAttendanceItemSerializer(serializers.Serializer):
    """A single item in a bulk mark-attendance payload."""
    student_id = serializers.UUIDField()
    status = serializers.ChoiceField(choices=["present", "absent", "late", "leave"])
    notes = serializers.CharField(required=False, allow_blank=True, default="")


class BulkAttendanceSerializer(serializers.Serializer):
    """POST /api/v1/attendance/ — mark/update attendance for an entire batch session."""
    batch_id = serializers.UUIDField()
    date = serializers.DateField()
    records = BulkAttendanceItemSerializer(many=True)
