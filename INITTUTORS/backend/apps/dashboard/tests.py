from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from apps.authentication.models import User
from apps.common.constants import Role

PASSWORD = "Passw0rd123"

class DashboardTests(APITestCase):
    def setUp(self):
        # Create Admin
        self.admin = User.objects.create_user(
            phone="9876500001",
            full_name="Raj Admin",
            email="raj.admin@example.com",
            password=PASSWORD,
            role=Role.ADMIN,
        )
        
        # Create Teacher
        self.teacher = User.objects.create_user(
            phone="9876500002",
            full_name="Raj Teacher",
            email="raj.teacher@example.com",
            password=PASSWORD,
            role=Role.TEACHER,
        )

    def get_token_header(self, user):
        response = self.client.post(
            reverse("v1:authentication:login"),
            {"email": user.email, "password": PASSWORD},
            format="json",
        )
        token = response.data["data"]["access_token"]
        return f"Bearer {token}"

    def test_owner_dashboard_requires_authentication(self):
        url = reverse("v1:dashboard:owner-dashboard")
        res = self.client.get(url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_owner_dashboard_forbidden_for_teacher(self):
        url = reverse("v1:dashboard:owner-dashboard")
        auth_header = self.get_token_header(self.teacher)
        res = self.client.get(url, HTTP_AUTHORIZATION=auth_header)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_owner_dashboard_success_for_admin(self):
        url = reverse("v1:dashboard:owner-dashboard")
        auth_header = self.get_token_header(self.admin)
        res = self.client.get(url, HTTP_AUTHORIZATION=auth_header)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data["success"])
        
        data = res.data["data"]
        self.assertIn("date", data)
        self.assertIn("todays_attendance_marked_batches", data)
        self.assertIn("todays_attendance_pending_batches", data)
        self.assertIn("students_present_today", data)
        self.assertIn("students_absent_today", data)
        self.assertIn("attendance_percentage_today", data)
        self.assertIn("new_admissions_this_month", data)
        self.assertIn("todays_batches", data)
        self.assertIn("pending_fees_amount", data)
        self.assertIn("pending_fees_students_count", data)
