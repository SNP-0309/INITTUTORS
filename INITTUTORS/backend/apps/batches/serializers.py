from rest_framework import serializers
from .models import Batch, BatchSchedule, BatchStudent, Classroom, Subject
from apps.teachers.serializers import TeacherSerializer
from apps.students.serializers import StudentSerializer
from . import services

class SubjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subject
        fields = ["id", "name"]

class ClassroomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Classroom
        fields = ["id", "name", "capacity"]

class BatchScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = BatchSchedule
        fields = ["id", "day_of_week", "start_time", "end_time"]

class BatchStudentSerializer(serializers.ModelSerializer):
    student = StudentSerializer(read_only=True)

    class Meta:
        model = BatchStudent
        fields = ["id", "student", "enrolled_on", "left_on", "status"]

class BatchSerializer(serializers.ModelSerializer):
    subject = SubjectSerializer(read_only=True)
    subject_id = serializers.UUIDField(write_only=True)
    teacher = TeacherSerializer(read_only=True)
    teacher_id = serializers.UUIDField(write_only=True)
    classroom = ClassroomSerializer(read_only=True)
    classroom_id = serializers.UUIDField(write_only=True, required=False, allow_null=True)
    schedules = BatchScheduleSerializer(many=True, read_only=True)
    schedule_data = serializers.ListField(child=serializers.DictField(), write_only=True, required=False)

    class Meta:
        model = Batch
        fields = [
            "id",
            "name",
            "subject",
            "subject_id",
            "teacher",
            "teacher_id",
            "classroom",
            "classroom_id",
            "standard",
            "capacity",
            "status",
            "schedules",
            "schedule_data",
        ]
        read_only_fields = ["id"]

    def create(self, validated_data):
        schedules = validated_data.pop("schedule_data", None)
        return services.create_batch(
            name=validated_data["name"],
            subject_id=str(validated_data["subject_id"]),
            teacher_id=str(validated_data["teacher_id"]),
            classroom_id=str(validated_data["classroom_id"]) if validated_data.get("classroom_id") else None,
            standard=validated_data.get("standard"),
            capacity=validated_data.get("capacity", 30),
            status=validated_data.get("status", "active"),
            schedules=schedules,
        )

    def update(self, instance, validated_data):
        schedules = validated_data.pop("schedule_data", None)
        return services.update_batch(
            batch_id=instance.id,
            name=validated_data.get("name"),
            subject_id=str(validated_data["subject_id"]) if validated_data.get("subject_id") else None,
            teacher_id=str(validated_data["teacher_id"]) if validated_data.get("teacher_id") else None,
            classroom_id=str(validated_data["classroom_id"]) if "classroom_id" in validated_data else None,
            standard=validated_data.get("standard"),
            capacity=validated_data.get("capacity"),
            status=validated_data.get("status"),
            schedules=schedules,
        )
