"""Shared enums and constants for the AMS backend.

Single source of truth for closed value sets used across apps (roles,
statuses, attendance status, days of week). Per development.md §3.1 these must
be imported everywhere rather than hardcoded as raw strings, and mirror the
enums in api.md §5 and database.md §5.

These are constants only — no models, serializers, or business logic. Django
`TextChoices` are used so they can later back model fields and serializer
choices without redefinition.
"""

from django.db import models


class Role(models.TextChoices):
    ADMIN = "admin", "Admin"
    TEACHER = "teacher", "Teacher"
    STUDENT = "student", "Student"
    PARENT = "parent", "Parent"


class UserStatus(models.TextChoices):
    ACTIVE = "active", "Active"
    INACTIVE = "inactive", "Inactive"
    SUSPENDED = "suspended", "Suspended"


class StudentStatus(models.TextChoices):
    ACTIVE = "active", "Active"
    LEFT = "left", "Left Coaching"
    SUSPENDED = "suspended", "Suspended"


class AttendanceStatus(models.TextChoices):
    PRESENT = "present", "Present"
    ABSENT = "absent", "Absent"
    LATE = "late", "Late"
    LEAVE = "leave", "Leave"


class DayOfWeek(models.TextChoices):
    MON = "mon", "Monday"
    TUE = "tue", "Tuesday"
    WED = "wed", "Wednesday"
    THU = "thu", "Thursday"
    FRI = "fri", "Friday"
    SAT = "sat", "Saturday"
    SUN = "sun", "Sunday"


class NotificationChannel(models.TextChoices):
    WHATSAPP = "whatsapp", "WhatsApp"
    SMS = "sms", "SMS"
    EMAIL = "email", "Email"
    APP = "app", "In-App"


class AnnouncementType(models.TextChoices):
    HOLIDAY = "holiday", "Holiday"
    EXAM = "exam", "Exam"
    FEE_REMINDER = "fee_reminder", "Fees Reminder"
    GENERAL = "general", "General"


class InstituteStatus(models.TextChoices):
    ACTIVE = "active", "Active"
    INACTIVE = "inactive", "Inactive"


class TeacherStatus(models.TextChoices):
    ACTIVE = "active", "Active"
    INACTIVE = "inactive", "Inactive"


# Notification channel fallback priority (BR-7.2 / api.md §12.5).
DEFAULT_NOTIFICATION_CHANNEL_PRIORITY = [
    NotificationChannel.WHATSAPP,
    NotificationChannel.SMS,
    NotificationChannel.EMAIL,
]
