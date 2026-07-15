from django.db import models
from apps.common.models import SoftDeleteModel, SoftDeleteQuerySet
from apps.common.constants import TeacherStatus
from django.conf import settings


class SoftDeleteTeacherManager(models.Manager):
    def get_queryset(self):
        return SoftDeleteQuerySet(self.model, using=self._db).filter(deleted_at__isnull=True)


class Teacher(SoftDeleteModel):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.RESTRICT,
        related_name="teacher_profile"
    )
    employee_code = models.CharField(max_length=30, unique=True, null=True, blank=True)
    specialization = models.CharField(max_length=150, null=True, blank=True)
    joining_date = models.DateField(null=True, blank=True)
    status = models.CharField(
        max_length=15,
        choices=TeacherStatus.choices,
        default=TeacherStatus.ACTIVE
    )

    objects = SoftDeleteTeacherManager()
    all_objects = models.Manager()

    class Meta:
        db_table = "teachers"

    def __str__(self) -> str:
        return f"{self.user.full_name} ({self.employee_code or 'No Code'})"
