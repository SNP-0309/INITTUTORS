from django.db import transaction
from django.shortcuts import get_object_or_404
from apps.authentication.models import User
from apps.common.constants import Role, UserStatus
from .models import Teacher


def create_teacher(*, user_data: dict, teacher_data: dict) -> Teacher:
    """Create a new User and a linked Teacher record transactionally."""
    with transaction.atomic():
        phone = user_data.get("phone")
        full_name = user_data.get("full_name")
        email = user_data.get("email")
        password = user_data.get("password")
        status = user_data.get("status", UserStatus.ACTIVE)

        user = User.objects.create_user(
            phone=phone,
            full_name=full_name,
            password=password,
            email=email,
            role=Role.TEACHER,
            status=status
        )

        teacher = Teacher(user=user, **teacher_data)
        teacher.full_clean()
        teacher.save()
        return teacher


def update_teacher(*, teacher_id: str, user_data: dict, teacher_data: dict) -> Teacher:
    """Update User and linked Teacher details transactionally."""
    teacher = get_object_or_404(Teacher, id=teacher_id)
    user = teacher.user
    
    with transaction.atomic():
        # Update user fields
        for field in ["phone", "full_name", "email", "status"]:
            if field in user_data:
                setattr(user, field, user_data[field])
        if "password" in user_data and user_data["password"]:
            user.set_password(user_data["password"])
        user.full_clean()
        user.save()

        # Update teacher fields
        for field, value in teacher_data.items():
            setattr(teacher, field, value)
        teacher.full_clean()
        teacher.save()
        return teacher


def delete_teacher(*, teacher_id: str) -> None:
    """Soft delete Teacher and linked User."""
    teacher = get_object_or_404(Teacher, id=teacher_id)
    with transaction.atomic():
        teacher.soft_delete()
        teacher.user.soft_delete()


def get_teacher(*, teacher_id: str) -> Teacher:
    """Get teacher details by ID."""
    return get_object_or_404(Teacher, id=teacher_id)
