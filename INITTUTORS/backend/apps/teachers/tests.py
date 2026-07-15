from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from apps.authentication.models import User
from apps.common.constants import Role, UserStatus
from .models import Teacher, TeacherStatus

PASSWORD = "Passw0rd123"


class TeacherTests(APITestCase):
    def setUp(self):
        self.admin = User.objects.create_user(
            phone="9876500001",
            full_name="Raj Admin",
            email="raj.admin@example.com",
            password=PASSWORD,
            role=Role.ADMIN,
        )
        self.teacher_user = User.objects.create_user(
            phone="9876500002",
            full_name="Raj Teacher",
            email="raj.teacher@example.com",
            password=PASSWORD,
            role=Role.TEACHER,
        )
        self.teacher = Teacher.objects.create(
            user=self.teacher_user,
            employee_code="T001",
            specialization="Mathematics",
        )

    def get_token_header(self, user):
        response = self.client.post(
            reverse("v1:authentication:login"),
            {"email": user.email, "password": PASSWORD},
            format="json",
        )
        token = response.data["data"]["access_token"]
        return f"Bearer {token}"

    def test_list_teachers_authenticated(self):
        auth_header = self.get_token_header(self.teacher_user)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.get(reverse("v1:teacher-list-create"))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        # Verify pagination envelopes
        self.assertIn("results", res.data["data"])
        self.assertEqual(res.data["data"]["count"], 1)
        self.assertEqual(res.data["data"]["results"][0]["employee_code"], "T001")

    def test_search_teachers(self):
        auth_header = self.get_token_header(self.teacher_user)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        
        # Match search
        res = self.client.get(reverse("v1:teacher-list-create"), {"search": "Math"})
        self.assertEqual(res.data["data"]["count"], 1)

        # No match search
        res = self.client.get(reverse("v1:teacher-list-create"), {"search": "Science"})
        self.assertEqual(res.data["data"]["count"], 0)

    def test_create_teacher_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.post(
            reverse("v1:teacher-list-create"),
            {
                "user": {
                    "full_name": "New Teacher",
                    "phone": "9876500003",
                    "email": "new.teacher@example.com",
                    "password": PASSWORD,
                },
                "employee_code": "T002",
                "specialization": "Physics",
                "status": "active"
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data["data"]["employee_code"], "T002")
        self.assertEqual(res.data["data"]["user"]["full_name"], "New Teacher")

    def test_create_teacher_duplicate_phone_fails(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.post(
            reverse("v1:teacher-list-create"),
            {
                "user": {
                    "full_name": "New Teacher",
                    "phone": "9876500002", # Taken by self.teacher_user
                    "email": "another@example.com",
                    "password": PASSWORD,
                },
                "employee_code": "T003",
                "specialization": "Chemistry",
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        fields = [d["field"] for d in res.data["error"]["details"]]
        self.assertIn("user", fields)

    def test_create_teacher_non_admin_forbidden(self):
        auth_header = self.get_token_header(self.teacher_user)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.post(
            reverse("v1:teacher-list-create"),
            {
                "user": {
                    "full_name": "New Teacher",
                    "phone": "9876500003",
                    "password": PASSWORD,
                },
                "employee_code": "T002",
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_update_teacher_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.put(
            reverse("v1:teacher-detail", kwargs={"pk": self.teacher.id}),
            {
                "user": {
                    "full_name": "Raj Teacher Updated",
                    "phone": "9876500002"
                },
                "specialization": "Pure Mathematics",
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data["data"]["user"]["full_name"], "Raj Teacher Updated")
        self.assertEqual(res.data["data"]["specialization"], "Pure Mathematics")

    def test_delete_teacher_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.delete(
            reverse("v1:teacher-detail", kwargs={"pk": self.teacher.id})
        )
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        # Verify both Teacher and linked User are soft deleted
        self.assertFalse(Teacher.objects.filter(id=self.teacher.id).exists())
        self.teacher_user.refresh_from_db()
        self.assertTrue(self.teacher_user.is_deleted)
