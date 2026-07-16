"""Custom User model — the base identity table (database.md §5.1).

Every login-capable person (Admin/Teacher/Parent/Student) has one row here.
Built on Django's auth framework (`AbstractBaseUser` + `PermissionsMixin`) so
password hashing, sessions, and the admin site work out of the box.

Deviations from database.md, flagged deliberately:
- Django's auth framework adds `is_staff`, `is_superuser`, `groups`,
  `user_permissions` (required to "use Django authentication").
- Column names mapped to the schema: `password` → `password_hash`,
  `last_login` → `last_login_at`.
- `is_active` (used internally by Django's auth backends) is kept in sync with
  the domain `status` field, which is the authoritative account state.
"""

from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.core.validators import RegexValidator
from django.db import models

from apps.common.constants import Role, UserStatus
from apps.common.models import SoftDeleteModel

from .managers import UserManager

phone_validator = RegexValidator(
    regex=r"^\d{10,15}$",
    message="Phone must be a 10–15 digit number.",
)


class User(AbstractBaseUser, PermissionsMixin, SoftDeleteModel):
    role = models.CharField(max_length=10, choices=Role.choices)
    full_name = models.CharField(max_length=150)
    email = models.EmailField(max_length=255, unique=True, null=True, blank=True)
    phone = models.CharField(
        max_length=15, unique=True, validators=[phone_validator]
    )
    # AbstractBaseUser defines `password`; override only to map the column name
    # to the schema's `password_hash`. Still stores a hash via set_password().
    password = models.CharField(
        max_length=128, db_column="password_hash"
    )
    photo_url = models.TextField(null=True, blank=True)
    status = models.CharField(
        max_length=10, choices=UserStatus.choices, default=UserStatus.ACTIVE
    )
    last_login = models.DateTimeField(
        db_column="last_login_at", null=True, blank=True
    )

    # Required by the Django admin / auth framework.
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    objects = UserManager()

    USERNAME_FIELD = "phone"
    REQUIRED_FIELDS = ["full_name", "email"]

    class Meta:
        db_table = "users"
        indexes = [
            models.Index(fields=["role"]),
            models.Index(fields=["status"]),
        ]

    def __str__(self) -> str:
        return f"{self.full_name} ({self.role})"

    def save(self, *args, **kwargs):
        # Keep Django's is_active in sync with the domain status field.
        self.is_active = self.status == UserStatus.ACTIVE
        super().save(*args, **kwargs)

    @property
    def is_suspended(self) -> bool:
        return self.status == UserStatus.SUSPENDED
