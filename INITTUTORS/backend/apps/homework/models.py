import uuid
from django.db import models
from django.conf import settings
from apps.batches.models import Batch


class Homework(models.Model):
    """An assignment uploaded by a teacher for a batch."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    batch = models.ForeignKey(
        Batch,
        on_delete=models.CASCADE,
        related_name="homework_assignments",
    )
    title = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    due_date = models.DateField(null=True, blank=True)
    file_url = models.TextField(null=True, blank=True)
    file_name = models.CharField(max_length=255, null=True, blank=True)
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="uploaded_homework",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "homework"
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"{self.title} — {self.batch.name}"
