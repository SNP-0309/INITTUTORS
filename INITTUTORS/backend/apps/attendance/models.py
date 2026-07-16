import uuid
from django.db import models
from django.conf import settings
from apps.common.constants import AttendanceStatus
from apps.batches.models import Batch
from apps.students.models import Student


class AttendanceRecord(models.Model):
    """A single student's attendance status for one batch session on one date."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    batch = models.ForeignKey(
        Batch,
        on_delete=models.CASCADE,
        related_name="attendance_records",
    )
    student = models.ForeignKey(
        Student,
        on_delete=models.CASCADE,
        related_name="attendance_records",
    )
    date = models.DateField()
    status = models.CharField(
        max_length=10,
        choices=AttendanceStatus.choices,
        default=AttendanceStatus.ABSENT,
    )
    marked_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="marked_attendance",
    )
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "attendance_records"
        unique_together = ("batch", "student", "date")
        ordering = ["-date", "student__first_name"]

    def __str__(self) -> str:
        return f"{self.student} — {self.batch.name} — {self.date} — {self.status}"
