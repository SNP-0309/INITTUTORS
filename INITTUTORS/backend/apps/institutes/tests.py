from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from apps.authentication.models import User
from apps.common.constants import Role
from .models import Institute

PASSWORD = "Passw0rd123"


class InstituteTests(APITestCase):
    def setUp(self):
        self.admin = User.objects.create_user(
            phone="9876500001",
            full_name="Raj Admin",
            email="raj.admin@example.com",
            password=PASSWORD,
            role=Role.ADMIN,
        )
        self.teacher = User.objects.create_user(
            phone="9876500002",
            full_name="Raj Teacher",
            email="raj.teacher@example.com",
            password=PASSWORD,
            role=Role.TEACHER,
        )
        # Create a test institute
        self.institute = Institute.objects.create(
            name="Init Tutors",
            phone="9999999999",
            email="contact@inittutors.com",
        )

    def get_token_header(self, user):
        response = self.client.post(
            reverse("v1:authentication:login"),
            {"email": user.email, "password": PASSWORD},
            format="json",
        )
        token = response.data["data"]["access_token"]
        return f"Bearer {token}"

    def test_list_institutes_authenticated(self):
        auth_header = self.get_token_header(self.teacher)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.get(reverse("v1:institute-list-create"))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(len(res.data["data"]), 1)
        self.assertEqual(res.data["data"][0]["name"], "Init Tutors")

    def test_create_institute_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.post(
            reverse("v1:institute-list-create"),
            {
                "name": "New Coaching Center",
                "phone": "8888888888",
                "email": "new@example.com",
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data["data"]["name"], "New Coaching Center")

    def test_create_institute_teacher_forbidden(self):
        auth_header = self.get_token_header(self.teacher)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.post(
            reverse("v1:institute-list-create"),
            {
                "name": "New Coaching Center",
                "phone": "8888888888",
                "email": "new@example.com",
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_get_institute_detail_authenticated(self):
        auth_header = self.get_token_header(self.teacher)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.get(
            reverse("v1:institute-detail", kwargs={"pk": self.institute.id})
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data["data"]["name"], "Init Tutors")

    def test_update_institute_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.put(
            reverse("v1:institute-detail", kwargs={"pk": self.institute.id}),
            {"name": "Init Tutors Updated"},
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data["data"]["name"], "Init Tutors Updated")

    def test_update_institute_teacher_forbidden(self):
        auth_header = self.get_token_header(self.teacher)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.put(
            reverse("v1:institute-detail", kwargs={"pk": self.institute.id}),
            {"name": "Init Tutors Updated"},
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_delete_institute_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.delete(
            reverse("v1:institute-detail", kwargs={"pk": self.institute.id})
        )
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        # Verify it's soft deleted
        self.assertFalse(Institute.objects.filter(id=self.institute.id).exists())
        self.assertTrue(Institute.all_objects.filter(id=self.institute.id).exists())
