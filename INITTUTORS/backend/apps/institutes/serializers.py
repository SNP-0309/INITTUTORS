from rest_framework import serializers
from .models import Institute


class InstituteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Institute
        fields = [
            "id",
            "name",
            "address",
            "city",
            "state",
            "pincode",
            "phone",
            "email",
            "website",
            "logo_url",
            "timezone",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]
