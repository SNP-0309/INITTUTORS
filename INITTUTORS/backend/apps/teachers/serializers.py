from rest_framework import serializers
from apps.authentication.models import User
from .models import Teacher, TeacherStatus
from apps.common.constants import UserStatus


class TeacherUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False)
    phone = serializers.CharField()
    email = serializers.EmailField(required=False, allow_null=True, allow_blank=True)

    class Meta:
        model = User
        fields = ["id", "full_name", "phone", "email", "status", "password"]
        read_only_fields = ["id"]


class TeacherSerializer(serializers.ModelSerializer):
    user = TeacherUserSerializer()

    class Meta:
        model = Teacher
        fields = [
            "id",
            "user",
            "employee_code",
            "specialization",
            "joining_date",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]

    def validate(self, attrs):
        user_data = attrs.get("user", {})
        phone = user_data.get("phone")
        email = user_data.get("email")
        employee_code = attrs.get("employee_code")

        teacher_instance = self.instance
        user_instance = teacher_instance.user if teacher_instance else None

        # Check phone uniqueness
        if phone:
            qs = User.objects.filter(phone=phone, deleted_at__isnull=True)
            if user_instance:
                qs = qs.exclude(id=user_instance.id)
            if qs.exists():
                raise serializers.ValidationError({"user": {"phone": "Phone number is already registered."}})

        # Check email uniqueness
        if email:
            qs = User.objects.filter(email=email, deleted_at__isnull=True)
            if user_instance:
                qs = qs.exclude(id=user_instance.id)
            if qs.exists():
                raise serializers.ValidationError({"user": {"email": "Email address is already registered."}})

        # Check employee_code uniqueness
        if employee_code:
            qs = Teacher.objects.filter(employee_code=employee_code, deleted_at__isnull=True)
            if teacher_instance:
                qs = qs.exclude(id=teacher_instance.id)
            if qs.exists():
                raise serializers.ValidationError({"employee_code": "Employee code is already in use."})

        return attrs

    def create(self, validated_data):
        user_data = validated_data.pop("user")
        # Keep status synchronized
        user_data["status"] = validated_data.get("status", TeacherStatus.ACTIVE)
        from .services import create_teacher
        return create_teacher(user_data=user_data, teacher_data=validated_data)

    def update(self, instance, validated_data):
        user_data = validated_data.pop("user", {})
        if "status" in validated_data:
            user_data["status"] = validated_data["status"]
        from .services import update_teacher
        return update_teacher(
            teacher_id=instance.id,
            user_data=user_data,
            teacher_data=validated_data
        )
