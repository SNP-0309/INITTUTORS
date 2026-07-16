"""Shared abstract base models.

These define reusable column sets (UUID PK, timestamps, soft-delete) per
database.md §2/§6/§7. They are abstract — they create no tables of their own
and are inherited by concrete domain models (e.g. the auth `User`).
"""

import uuid

from django.db import models
from django.utils import timezone


class TimeStampedModel(models.Model):
    """UUID primary key + created/updated timestamps (database.md §2)."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class SoftDeleteQuerySet(models.QuerySet):
    """QuerySet exposing soft-delete helpers."""

    def alive(self):
        return self.filter(deleted_at__isnull=True)

    def dead(self):
        return self.filter(deleted_at__isnull=False)

    def soft_delete(self):
        return self.update(deleted_at=timezone.now())


class SoftDeleteModel(TimeStampedModel):
    """Adds `deleted_at` soft-delete semantics (database.md §6).

    Application queries should filter `deleted_at IS NULL` by default. Concrete
    models decide which manager to expose; this base only provides the column
    and an instance-level `soft_delete()` helper.
    """

    deleted_at = models.DateTimeField(null=True, blank=True, default=None)

    class Meta:
        abstract = True

    def soft_delete(self):
        self.deleted_at = timezone.now()
        self.save(update_fields=["deleted_at", "updated_at"])

    @property
    def is_deleted(self) -> bool:
        return self.deleted_at is not None
