from django.shortcuts import get_object_or_404
from .models import Institute


def create_institute(*, data: dict) -> Institute:
    """Create a new institute."""
    institute = Institute(**data)
    institute.full_clean()
    institute.save()
    return institute


def update_institute(*, institute_id: str, data: dict) -> Institute:
    """Update an existing institute."""
    institute = get_object_or_404(Institute, id=institute_id)
    for field, value in data.items():
        setattr(institute, field, value)
    institute.full_clean()
    institute.save()
    return institute


def get_institute(*, institute_id: str) -> Institute:
    """Get institute by ID."""
    return get_object_or_404(Institute, id=institute_id)


def get_institutes_list() -> list:
    """Get list of institutes."""
    return Institute.objects.all()
