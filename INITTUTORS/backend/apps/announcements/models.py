import uuid
from django.db import models
from django.conf import settings
from apps.common.constants import AnnouncementType, Role


class AnnouncementPriority(models.TextChoices):
    LOW = "low", "Low"
    NORMAL = "normal", "Normal"
    HIGH = "high", "High"
    URGENT = "urgent", "Urgent"


class Announcement(models.Model):
    """A broadcast message sent to one or more roles in the institute."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=255)
    body = models.TextField()
    category = models.CharField(
        max_length=20,
        choices=AnnouncementType.choices,
        default=AnnouncementType.GENERAL,
    )
    target_role = models.CharField(
        max_length=15,
        choices=[("all", "All"), *Role.choices],
        default="all",
    )
    priority = models.CharField(
        max_length=10,
        choices=AnnouncementPriority.choices,
        default=AnnouncementPriority.NORMAL,
    )
    is_pinned = models.BooleanField(default=False)
    attachment_url = models.TextField(null=True, blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="announcements",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "announcements"
        ordering = ["-is_pinned", "-created_at"]

    def __str__(self) -> str:
        return f"[{self.category}] {self.title}"
