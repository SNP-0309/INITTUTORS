import uuid
from django.db import models
from apps.common.models import SoftDeleteModel, SoftDeleteQuerySet
from apps.common.constants import DayOfWeek
from apps.teachers.models import Teacher
from apps.students.models import Student

class SoftDeleteManager(models.Manager):
    def get_queryset(self):
        return SoftDeleteQuerySet(self.model, using=self._db).filter(deleted_at__isnull=True)

class Subject(SoftDeleteModel):
    name = models.CharField(max_length=100, unique=True)
    objects = SoftDeleteManager()
    all_objects = models.Manager()

    class Meta:
        db_table = "subjects"

    def __str__(self):
        return self.name

class Classroom(SoftDeleteModel):
    name = models.CharField(max_length=100, unique=True)
    capacity = models.IntegerField(null=True, blank=True)
    objects = SoftDeleteManager()
    all_objects = models.Manager()

    class Meta:
        db_table = "classrooms"

    def __str__(self):
        return self.name

class BatchStatus(models.TextChoices):
    ACTIVE = "active", "Active"
    ARCHIVED = "archived", "Archived"

class Batch(SoftDeleteModel):
    name = models.CharField(max_length=150)
    subject = models.ForeignKey(Subject, on_delete=models.RESTRICT, related_name="batches")
    teacher = models.ForeignKey(Teacher, on_delete=models.RESTRICT, related_name="batches")
    classroom = models.ForeignKey(Classroom, on_delete=models.SET_NULL, null=True, blank=True, related_name="batches")
    standard = models.CharField(max_length=20, null=True, blank=True)
    capacity = models.IntegerField(default=30)
    status = models.CharField(max_length=15, choices=BatchStatus.choices, default=BatchStatus.ACTIVE)

    objects = SoftDeleteManager()
    all_objects = models.Manager()

    class Meta:
        db_table = "batches"

    def __str__(self):
        return self.name

class BatchSchedule(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    batch = models.ForeignKey(Batch, on_delete=models.CASCADE, related_name="schedules")
    day_of_week = models.CharField(max_length=3, choices=DayOfWeek.choices)
    start_time = models.TimeField()
    end_time = models.TimeField()

    class Meta:
        db_table = "batch_schedules"
        unique_together = ("batch", "day_of_week", "start_time")

class BatchStudentStatus(models.TextChoices):
    ACTIVE = "active", "Active"
    REMOVED = "removed", "Removed"

class BatchStudent(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    batch = models.ForeignKey(Batch, on_delete=models.CASCADE, related_name="batch_students")
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name="batch_enrollments")
    enrolled_on = models.DateField(auto_now_add=True)
    left_on = models.DateField(null=True, blank=True)
    status = models.CharField(max_length=10, choices=BatchStudentStatus.choices, default=BatchStudentStatus.ACTIVE)

    class Meta:
        db_table = "batch_students"
        unique_together = ("batch", "student")
