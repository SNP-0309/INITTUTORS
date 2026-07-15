from django.db import models
from django.core.validators import RegexValidator
from apps.common.models import SoftDeleteModel, SoftDeleteQuerySet
from apps.common.constants import InstituteStatus

phone_validator = RegexValidator(
    regex=r"^\d{10,15}$",
    message="Phone must be a 10–15 digit number.",
)


class SoftDeleteManager(models.Manager):
    def get_queryset(self):
        return SoftDeleteQuerySet(self.model, using=self._db).filter(deleted_at__isnull=True)


class Institute(SoftDeleteModel):
    name = models.CharField(max_length=200, unique=True)
    address = models.TextField(blank=True, default="")
    city = models.CharField(max_length=100, blank=True, default="")
    state = models.CharField(max_length=100, blank=True, default="")
    pincode = models.CharField(max_length=10, blank=True, default="")
    phone = models.CharField(max_length=15, validators=[phone_validator])
    email = models.EmailField(max_length=255, blank=True, null=True)
    website = models.URLField(max_length=255, blank=True, null=True)
    logo_url = models.TextField(blank=True, null=True)
    timezone = models.CharField(max_length=50, default="Asia/Kolkata")
    status = models.CharField(
        max_length=15,
        choices=InstituteStatus.choices,
        default=InstituteStatus.ACTIVE,
    )

    objects = SoftDeleteManager()
    all_objects = models.Manager()

    class Meta:
        db_table = "institutes"

    def __str__(self) -> str:
        return self.name
