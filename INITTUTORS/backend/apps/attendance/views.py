from datetime import date as date_type
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404

from apps.common.responses import success
from apps.common.permissions import IsAdmin
from apps.batches.models import Batch, BatchStudent, BatchStudentStatus
from apps.students.models import Student
from .models import AttendanceRecord
from .serializers import AttendanceRecordSerializer, BulkAttendanceSerializer


class AttendanceByBatchDateView(APIView):
    """GET  /api/v1/attendance/?batch_id=X&date=YYYY-MM-DD
       POST /api/v1/attendance/  — bulk mark/update attendance for a batch session.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        batch_id = request.query_params.get("batch_id")
        date_str = request.query_params.get("date")

        if not batch_id or not date_str:
            return success(
                {"error": "batch_id and date query params are required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        batch = get_object_or_404(Batch, id=batch_id)
        records = AttendanceRecord.objects.filter(
            batch=batch, date=date_str
        ).select_related("student")
        serializer = AttendanceRecordSerializer(records, many=True)
        return success(
            {
                "batch_id": str(batch.id),
                "batch_name": batch.name,
                "date": date_str,
                "records": serializer.data,
            },
            status=status.HTTP_200_OK,
        )

    def post(self, request):
        serializer = BulkAttendanceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        batch = get_object_or_404(Batch, id=data["batch_id"])
        session_date = data["date"]
        user = request.user

        created, updated = 0, 0
        for item in data["records"]:
            student = get_object_or_404(Student, id=item["student_id"])
            record, was_created = AttendanceRecord.objects.update_or_create(
                batch=batch,
                student=student,
                date=session_date,
                defaults={
                    "status": item["status"],
                    "notes": item.get("notes", ""),
                    "marked_by": user,
                },
            )
            if was_created:
                created += 1
            else:
                updated += 1

        return success(
            {"created": created, "updated": updated},
            status=status.HTTP_200_OK,
        )


class AttendanceByBatchView(APIView):
    """GET /api/v1/attendance/batch/{batch_id}/ — full attendance history for a batch."""
    permission_classes = [IsAuthenticated]

    def get(self, request, batch_id):
        batch = get_object_or_404(Batch, id=batch_id)
        records = AttendanceRecord.objects.filter(batch=batch).select_related("student")
        serializer = AttendanceRecordSerializer(records, many=True)
        return success(serializer.data, status=status.HTTP_200_OK)


class AttendanceByStudentView(APIView):
    """GET /api/v1/attendance/student/{student_id}/ — attendance history for a student."""
    permission_classes = [IsAuthenticated]

    def get(self, request, student_id):
        student = get_object_or_404(Student, id=student_id)
        records = AttendanceRecord.objects.filter(student=student).select_related("batch")

        month = request.query_params.get("month")
        year = request.query_params.get("year")
        if month and year:
            records = records.filter(date__month=month, date__year=year)

        total = records.count()
        present = records.filter(status="present").count()
        late = records.filter(status="late").count()
        absent = records.filter(status="absent").count()
        leave = records.filter(status="leave").count()
        percentage = round(((present + late) / total * 100), 1) if total > 0 else 0.0

        serializer = AttendanceRecordSerializer(records, many=True)
        return success(
            {
                "student_id": str(student.id),
                "stats": {
                    "total": total,
                    "present": present,
                    "late": late,
                    "absent": absent,
                    "leave": leave,
                    "percentage": percentage,
                },
                "records": serializer.data,
            },
            status=status.HTTP_200_OK,
        )


class BatchRosterForAttendanceView(APIView):
    """GET /api/v1/attendance/batch/{batch_id}/roster/ — active students for marking."""
    permission_classes = [IsAuthenticated]

    def get(self, request, batch_id):
        batch = get_object_or_404(Batch, id=batch_id)
        enrollments = BatchStudent.objects.filter(
            batch=batch, status=BatchStudentStatus.ACTIVE
        ).select_related("student")

        roster = [
            {
                "student_id": str(e.student.id),
                "name": f"{e.student.first_name} {e.student.last_name or ''}".strip(),
                "roll_number": e.student.roll_number,
                "photo_url": e.student.photo_url,
            }
            for e in enrollments
        ]
        return success(
            {"batch_id": str(batch.id), "batch_name": batch.name, "roster": roster},
            status=status.HTTP_200_OK,
        )
