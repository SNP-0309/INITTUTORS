from django.db import transaction
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from apps.common.constants import Role, UserStatus
from .models import Student, Parent, StudentParent, ParentRelation
from rest_framework import serializers

User = get_user_model()

def create_student(*, student_data: dict, parent_data: dict) -> Student:
    """Create a student and associate it with a parent.
    
    If the parent phone already exists, links the student to the existing parent profile.
    Otherwise, provisions a new parent user and profile.
    """
    roll_number = student_data.get("roll_number")
    if not roll_number:
        raise serializers.ValidationError({"roll_number": "Roll number is required."})
        
    # Check roll number uniqueness among active records
    if Student.objects.filter(roll_number=roll_number).exists():
        raise serializers.ValidationError({"roll_number": "A student with this roll number already exists."})

    parent_phone = parent_data.get("phone")
    parent_name = parent_data.get("full_name")
    parent_relation = parent_data.get("relation", ParentRelation.GUARDIAN)
    is_primary = parent_data.get("is_primary", True)
    
    if not parent_phone:
        raise serializers.ValidationError({"parent": {"phone": "Parent phone is required."}})
    if not parent_name:
        raise serializers.ValidationError({"parent": {"full_name": "Parent name is required."}})

    with transaction.atomic():
        # Find or create Parent User
        parent_user, created_user = User.objects.get_or_create(
            phone=parent_phone,
            defaults={
                "full_name": parent_name,
                "role": Role.PARENT,
                "status": UserStatus.ACTIVE
            }
        )
        if created_user:
            parent_user.set_unusable_password()
            parent_user.save()

        # Find or create Parent profile
        parent_profile, created_profile = Parent.objects.get_or_create(
            user=parent_user,
            defaults={"relation": parent_relation}
        )

        # Create Student
        student = Student.objects.create(
            roll_number=roll_number,
            admission_date=student_data["admission_date"],
            first_name=student_data["first_name"],
            last_name=student_data.get("last_name"),
            phone=student_data.get("phone"),
            parent_phone=parent_phone,
            email=student_data.get("email"),
            address=student_data.get("address"),
            school=student_data.get("school"),
            standard=student_data["standard"],
            photo_url=student_data.get("photo_url"),
            status=student_data.get("status", "active"),
            status_reason=student_data.get("status_reason")
        )

        # Link Student to Parent
        StudentParent.objects.create(
            student=student,
            parent=parent_profile,
            is_primary=is_primary
        )

        return student

def update_student(*, student_id: str, student_data: dict, parent_data: dict = None) -> Student:
    """Update a student and optional parent linkage details."""
    student = get_object_or_404(Student, id=student_id)
    
    roll_number = student_data.get("roll_number")
    if roll_number and roll_number != student.roll_number:
        if Student.objects.filter(roll_number=roll_number).exists():
            raise serializers.ValidationError({"roll_number": "A student with this roll number already exists."})

    with transaction.atomic():
        # Update Student fields
        for field, value in student_data.items():
            setattr(student, field, value)
        
        # If parent phone is updated, update the denormalized parent_phone in Student as well
        if parent_data and "phone" in parent_data:
            student.parent_phone = parent_data["phone"]

        student.save()

        if parent_data:
            parent_phone = parent_data.get("phone")
            parent_name = parent_data.get("full_name")
            parent_relation = parent_data.get("relation")
            is_primary = parent_data.get("is_primary")

            # Check if there is already a primary link
            primary_link = StudentParent.objects.filter(student=student, is_primary=True).first()
            if primary_link:
                parent_profile = primary_link.parent
                # Update Parent User
                parent_user = parent_profile.user
                if parent_phone:
                    # Check if phone changed
                    if parent_phone != parent_user.phone:
                        # Verify we don't conflict with another user
                        if User.objects.filter(phone=parent_phone).exclude(id=parent_user.id).exists():
                            raise serializers.ValidationError({"parent": {"phone": "A user with this phone already exists."}})
                        parent_user.phone = parent_phone
                if parent_name:
                    parent_user.full_name = parent_name
                parent_user.save()
                
                if parent_relation:
                    parent_profile.relation = parent_relation
                    parent_profile.save()
                    
                if is_primary is not None:
                    primary_link.is_primary = is_primary
                    primary_link.save()
            else:
                # If no link exists, create one
                if parent_phone and parent_name:
                    parent_user, _ = User.objects.get_or_create(
                        phone=parent_phone,
                        defaults={
                            "full_name": parent_name,
                            "role": Role.PARENT,
                            "status": UserStatus.ACTIVE
                        }
                    )
                    parent_profile, _ = Parent.objects.get_or_create(
                        user=parent_user,
                        defaults={"relation": parent_relation or ParentRelation.GUARDIAN}
                    )
                    StudentParent.objects.create(
                        student=student,
                        parent=parent_profile,
                        is_primary=is_primary if is_primary is not None else True
                    )

    return student

def delete_student(*, student_id: str) -> None:
    """Soft delete student."""
    student = get_object_or_404(Student, id=student_id)
    with transaction.atomic():
        student.soft_delete()
