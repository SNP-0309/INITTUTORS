from rest_framework import serializers
from django.utils import timezone
from apps.authentication.models import User
from .models import Student, Parent, StudentParent, ParentRelation
from .services import create_student, update_student

class ParentSerializer(serializers.Serializer):
    full_name = serializers.CharField(max_length=255)
    phone = serializers.CharField(max_length=15)
    relation = serializers.ChoiceField(choices=ParentRelation.choices, default=ParentRelation.GUARDIAN)
    is_primary = serializers.BooleanField(default=True)

class StudentSerializer(serializers.ModelSerializer):
    parent = ParentSerializer(write_only=True, required=False)
    primary_parent = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Student
        fields = [
            "id",
            "roll_number",
            "admission_date",
            "first_name",
            "last_name",
            "phone",
            "parent_phone",
            "email",
            "address",
            "school",
            "standard",
            "photo_url",
            "status",
            "status_reason",
            "parent",
            "primary_parent",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "parent_phone", "created_at", "updated_at"]

    def get_primary_parent(self, obj):
        # Fetch primary parent from StudentParent
        link = StudentParent.objects.filter(student=obj, is_primary=True).first()
        if link:
            return {
                "full_name": link.parent.user.full_name,
                "phone": link.parent.user.phone,
                "relation": link.parent.relation,
                "is_primary": link.is_primary,
            }
        return None

    def validate_admission_date(self, value):
        if value > timezone.now().date():
            raise serializers.ValidationError("Admission date cannot be in the future.")
        return value

    def create(self, validated_data):
        parent_data = validated_data.pop("parent", None)
        if not parent_data:
            raise serializers.ValidationError({"parent": "Parent details are required."})
        return create_student(student_data=validated_data, parent_data=parent_data)

    def update(self, instance, validated_data):
        parent_data = validated_data.pop("parent", None)
        return update_student(student_id=instance.id, student_data=validated_data, parent_data=parent_data)
