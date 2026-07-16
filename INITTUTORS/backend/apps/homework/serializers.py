from rest_framework import serializers
from .models import Homework


class HomeworkSerializer(serializers.ModelSerializer):
    batch_name = serializers.SerializerMethodField(read_only=True)
    uploaded_by_name = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Homework
        fields = [
            "id",
            "batch",
            "batch_name",
            "title",
            "description",
            "due_date",
            "file_url",
            "file_name",
            "uploaded_by",
            "uploaded_by_name",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "uploaded_by", "created_at", "updated_at"]

    def get_batch_name(self, obj):
        return obj.batch.name

    def get_uploaded_by_name(self, obj):
        return obj.uploaded_by.full_name if obj.uploaded_by else None

    def create(self, validated_data):
        validated_data["uploaded_by"] = self.context["request"].user
        return super().create(validated_data)
