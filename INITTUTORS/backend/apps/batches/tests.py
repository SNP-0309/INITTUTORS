from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from apps.authentication.models import User
from apps.common.constants import Role
from apps.teachers.models import Teacher
from apps.students.models import Student
from .models import Batch, Subject, Classroom, BatchSchedule, BatchStudent, BatchStudentStatus

PASSWORD = "Passw0rd123"


class BatchTests(APITestCase):
    def setUp(self):
        # Create users
        self.admin = User.objects.create_user(
            phone="9876500021",
            full_name="Raj Admin",
            email="admin@example.com",
            password=PASSWORD,
            role=Role.ADMIN,
        )
        self.teacher_user = User.objects.create_user(
            phone="9876500022",
            full_name="Raj Teacher",
            email="teacher@example.com",
            password=PASSWORD,
            role=Role.TEACHER,
        )
        self.teacher = Teacher.objects.create(
            user=self.teacher_user,
            employee_code="T101",
        )
        
        # Create subjects and classrooms
        self.subject = Subject.objects.create(name="Mathematics")
        self.classroom = Classroom.objects.create(name="Room A", capacity=30)
        
        # Create student for assignment
        self.student = Student.objects.create(
            roll_number="S101",
            admission_date="2026-07-01",
            first_name="Ravi",
            parent_phone="9876500023",
            standard="10th",
        )

    def get_token_header(self, user):
        from rest_framework_simplejwt.tokens import RefreshToken
        refresh = RefreshToken.for_user(user)
        refresh["role"] = user.role
        access = refresh.access_token
        access["role"] = user.role
        return f"Bearer {str(access)}"

    def test_list_batches_authenticated(self):
        auth_header = self.get_token_header(self.teacher_user)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.get(reverse("v1:batches:batch-list-create"))
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_batch_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.post(
            reverse("v1:batches:batch-list-create"),
            {
                "name": "Maths Tenth Batch A",
                "subject_id": str(self.subject.id),
                "teacher_id": str(self.teacher.id),
                "classroom_id": str(self.classroom.id),
                "standard": "10th",
                "capacity": 20,
                "schedule_data": [
                    {
                        "day_of_week": "mon",
                        "start_time": "18:00:00",
                        "end_time": "19:00:00"
                    }
                ]
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data["data"]["name"], "Maths Tenth Batch A")
        self.assertEqual(len(res.data["data"]["schedules"]), 1)

    def test_create_batch_classroom_double_booking_fails(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        
        # Create first batch
        self.client.post(
            reverse("v1:batches:batch-list-create"),
            {
                "name": "Batch 1",
                "subject_id": str(self.subject.id),
                "teacher_id": str(self.teacher.id),
                "classroom_id": str(self.classroom.id),
                "standard": "10th",
                "schedule_data": [
                    {
                        "day_of_week": "mon",
                        "start_time": "18:00:00",
                        "end_time": "19:00:00"
                    }
                ]
            },
            format="json",
        )
        
        # Try to double book second batch
        res = self.client.post(
            reverse("v1:batches:batch-list-create"),
            {
                "name": "Batch 2",
                "subject_id": str(self.subject.id),
                "teacher_id": str(self.teacher.id),
                "classroom_id": str(self.classroom.id),
                "standard": "10th",
                "schedule_data": [
                    {
                        "day_of_week": "mon",
                        "start_time": "18:30:00",
                        "end_time": "19:30:00"
                    }
                ]
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        fields = [d["field"] for d in res.data["error"]["details"]]
        self.assertIn("schedules", fields)

    def test_student_assignment_and_removal(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        
        batch = Batch.objects.create(
            name="Batch A",
            subject=self.subject,
            teacher=self.teacher,
            capacity=1
        )
        
        # Assign student
        res = self.client.post(
            reverse("v1:batches:batch-assign", kwargs={"pk": batch.id}),
            {"student_id": str(self.student.id)},
            format="json"
        )
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        self.assertTrue(BatchStudent.objects.filter(batch=batch, student=self.student, status=BatchStudentStatus.ACTIVE).exists())
        
        # Assign second student fails due to capacity=1 limit
        other_student = Student.objects.create(
            roll_number="S102",
            admission_date="2026-07-01",
            first_name="Amar",
            parent_phone="9876500024",
            standard="10th",
        )
        res_fail = self.client.post(
            reverse("v1:batches:batch-assign", kwargs={"pk": batch.id}),
            {"student_id": str(other_student.id)},
            format="json"
        )
        self.assertEqual(res_fail.status_code, status.HTTP_400_BAD_REQUEST)
        
        # Remove student
        res_remove = self.client.post(
            reverse("v1:batches:batch-remove", kwargs={"pk": batch.id}),
            {"student_id": str(self.student.id)},
            format="json"
        )
        self.assertEqual(res_remove.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(BatchStudent.objects.filter(batch=batch, student=self.student, status=BatchStudentStatus.ACTIVE).exists())
