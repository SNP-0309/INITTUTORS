from datetime import date, time
from django.db import transaction
from django.shortcuts import get_object_or_404
from rest_framework import serializers

from .models import Batch, BatchSchedule, BatchStudent, Classroom, Subject, BatchStudentStatus
from apps.teachers.models import Teacher
from apps.students.models import Student

def parse_time(val):
    if isinstance(val, str):
        # Slice to ignore milliseconds if present, then split
        val_clean = val.split('.')[0]
        parts = list(map(int, val_clean.split(':')))
        return time(*parts)
    return val

def validate_schedule_overlap(classroom_id, day_of_week, start_time, end_time, exclude_batch_id=None):
    """Check if another active batch schedule overlaps in the same classroom."""
    if not classroom_id:
        return False
        
    start_t = parse_time(start_time)
    end_t = parse_time(end_time)
        
    qs = BatchSchedule.objects.filter(
        batch__classroom_id=classroom_id,
        batch__deleted_at__isnull=True,
        day_of_week=day_of_week
    )
    if exclude_batch_id:
        qs = qs.exclude(batch_id=exclude_batch_id)
        
    for sched in qs:
        # Overlap check: start1 < end2 and end1 > start2
        if start_t < sched.end_time and end_t > sched.start_time:
            return True
    return False

def create_batch(*, name: str, subject_id: str, teacher_id: str, classroom_id: str = None,
                 standard: str = None, capacity: int = 30, status: str = "active", schedules: list = None) -> Batch:
    """Create a batch and nested schedules transactionally."""
    if capacity <= 0:
        raise serializers.ValidationError({"capacity": "Capacity must be greater than 0."})

    subject = get_object_or_404(Subject, id=subject_id)
    teacher = get_object_or_404(Teacher, id=teacher_id)
    classroom = get_object_or_404(Classroom, id=classroom_id) if classroom_id else None

    # Validate schedules overlap
    if schedules:
        for sched in schedules:
            day = sched["day_of_week"]
            start = sched["start_time"]
            end = sched["end_time"]
            if start >= end:
                raise serializers.ValidationError({"schedules": f"End time must be after start time on {day}."})
            if classroom and validate_schedule_overlap(classroom.id, day, start, end):
                raise serializers.ValidationError({"schedules": f"Classroom double-booking detected on {day}."})

    with transaction.atomic():
        batch = Batch.objects.create(
            name=name,
            subject=subject,
            teacher=teacher,
            classroom=classroom,
            standard=standard,
            capacity=capacity,
            status=status
        )

        if schedules:
            for sched in schedules:
                BatchSchedule.objects.create(
                    batch=batch,
                    day_of_week=sched["day_of_week"],
                    start_time=sched["start_time"],
                    end_time=sched["end_time"]
                )

        return batch

def update_batch(*, batch_id: str, name: str = None, subject_id: str = None, teacher_id: str = None,
                 classroom_id: str = None, standard: str = None, capacity: int = None, status: str = None,
                 schedules: list = None) -> Batch:
    """Update batch details and schedules transactionally."""
    batch = get_object_or_404(Batch, id=batch_id)

    if capacity is not None and capacity <= 0:
        raise serializers.ValidationError({"capacity": "Capacity must be greater than 0."})

    with transaction.atomic():
        if name is not None:
            batch.name = name
        if subject_id is not None:
            batch.subject = get_object_or_404(Subject, id=subject_id)
        if teacher_id is not None:
            batch.teacher = get_object_or_404(Teacher, id=teacher_id)
        if classroom_id is not None:
            batch.classroom = get_object_or_404(Classroom, id=classroom_id)
        elif classroom_id == "":
            batch.classroom = None
            
        if standard is not None:
            batch.standard = standard
        if capacity is not None:
            batch.capacity = capacity
        if status is not None:
            batch.status = status

        batch.save()

        if schedules is not None:
            # Validate schedules overlap
            for sched in schedules:
                day = sched["day_of_week"]
                start = sched["start_time"]
                end = sched["end_time"]
                if start >= end:
                    raise serializers.ValidationError({"schedules": f"End time must be after start time on {day}."})
                if batch.classroom and validate_schedule_overlap(batch.classroom.id, day, start, end, exclude_batch_id=batch.id):
                    raise serializers.ValidationError({"schedules": f"Classroom double-booking detected on {day}."})

            # Recreate schedules
            batch.schedules.all().delete()
            for sched in schedules:
                BatchSchedule.objects.create(
                    batch=batch,
                    day_of_week=sched["day_of_week"],
                    start_time=sched["start_time"],
                    end_time=sched["end_time"]
                )

        return batch

def assign_student_to_batch(*, batch_id: str, student_id: str) -> BatchStudent:
    """Assign student to a batch. Validates capacity constraint."""
    batch = get_object_or_404(Batch, id=batch_id)
    student = get_object_or_404(Student, id=student_id)

    # Check if student is already active in batch
    existing = BatchStudent.objects.filter(batch=batch, student=student).first()
    if existing and existing.status == BatchStudentStatus.ACTIVE:
        return existing

    # Validate capacity limit
    active_count = BatchStudent.objects.filter(batch=batch, status=BatchStudentStatus.ACTIVE).count()
    if active_count >= batch.capacity:
        raise serializers.ValidationError({"student": "Batch capacity limit reached."})

    with transaction.atomic():
        if existing:
            # Reactivate
            existing.status = BatchStudentStatus.ACTIVE
            existing.enrolled_on = date.today()
            existing.left_on = None
            existing.save()
            return existing
        else:
            return BatchStudent.objects.create(
                batch=batch,
                student=student,
                status=BatchStudentStatus.ACTIVE
            )

def remove_student_from_batch(*, batch_id: str, student_id: str) -> None:
    """Remove student from a batch (soft remove)."""
    enrollment = get_object_or_404(BatchStudent, batch_id=batch_id, student_id=student_id, status=BatchStudentStatus.ACTIVE)
    with transaction.atomic():
        enrollment.status = BatchStudentStatus.REMOVED
        enrollment.left_on = date.today()
        enrollment.save()
