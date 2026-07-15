import uuid
from django.db import models
from django.conf import settings
from apps.common.models import SoftDeleteModel, SoftDeleteQuerySet
from apps.common.constants import StudentStatus
from django.core.validators import RegexValidator

phone_validator = RegexValidator(
    regex=r"^\d{10,15}$",
    message="Phone must be a 10–15 digit number.",
)


class SoftDeleteStudentManager(models.Manager):
    def get_queryset(self):
        return SoftDeleteQuerySet(self.model, using=self._db).filter(deleted_at__isnull=True)


class Student(SoftDeleteModel):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="student_profile"
    )
    roll_number = models.CharField(max_length=30)
    admission_date = models.DateField()
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100, null=True, blank=True)
    phone = models.CharField(max_length=15, validators=[phone_validator], null=True, blank=True)
    parent_phone = models.CharField(max_length=15, validators=[phone_validator])
    email = models.EmailField(max_length=255, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    school = models.CharField(max_length=150, null=True, blank=True)
    standard = models.CharField(max_length=20)
    photo_url = models.TextField(null=True, blank=True)
    status = models.CharField(
        max_length=15,
        choices=StudentStatus.choices,
        default=StudentStatus.ACTIVE
    )
    status_reason = models.TextField(null=True, blank=True)

    objects = SoftDeleteStudentManager()
    all_objects = models.Manager()

    class Meta:
        db_table = "students"

    def __str__(self) -> str:
        return f"{self.first_name} {self.last_name or ''} ({self.roll_number})"


class ParentRelation(models.TextChoices):
    FATHER = "father", "Father"
    MOTHER = "mother", "Mother"
    GUARDIAN = "guardian", "Guardian"
    OTHER = "other", "Other"


class SoftDeleteParentManager(models.Manager):
    def get_queryset(self):
        return SoftDeleteQuerySet(self.model, using=self._db).filter(deleted_at__isnull=True)


class Parent(SoftDeleteModel):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.RESTRICT,
        related_name="parent_profile"
    )
    relation = models.CharField(
        max_length=15,
        choices=ParentRelation.choices,
        default=ParentRelation.GUARDIAN
    )

    objects = SoftDeleteParentManager()
    all_objects = models.Manager()

    class Meta:
        db_table = "parents"

    def __str__(self) -> str:
        return f"{self.user.full_name} ({self.relation})"


class StudentParent(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name="student_parent_links")
    parent = models.ForeignKey(Parent, on_delete=models.CASCADE, related_name="parent_student_links")
    is_primary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "student_parents"
        unique_together = ("student", "parent")

    def __str__(self) -> str:
        return f"{self.student} - {self.parent} (Primary: {self.is_primary})"
