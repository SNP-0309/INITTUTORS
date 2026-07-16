"""Integration tests for the authentication module (backend.md §14.2).

Covers happy path + auth/validation failure paths for every endpoint, plus a
role-permission check.
"""

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from apps.common.constants import Role, UserStatus

from .models import User

PASSWORD = "Passw0rd123"


class AuthTestBase(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            phone="9876500001",
            full_name="Raj Admin",
            email="raj.admin@example.com",
            password=PASSWORD,
            role=Role.ADMIN,
        )

    def login(self, email="raj.admin@example.com", password=PASSWORD):
        return self.client.post(
            reverse("v1:authentication:login"),
            {"email": email, "password": password},
            format="json",
        )


class LoginTests(AuthTestBase):
    def test_login_success_returns_tokens_and_user(self):
        res = self.login()
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data["success"])
        data = res.data["data"]
        self.assertIn("access_token", data)
        self.assertIn("refresh_token", data)
        self.assertEqual(data["expires_in"], 15 * 60)
        self.assertEqual(data["user"]["role"], Role.ADMIN)
        self.assertEqual(data["user"]["email"], "raj.admin@example.com")
        self.assertNotIn("password", data["user"])

    def test_login_wrong_password_is_invalid_credentials(self):
        res = self.login(password="wrong-password")
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(res.data["error"]["code"], "INVALID_CREDENTIALS")

    def test_login_unknown_email_is_invalid_credentials(self):
        res = self.login(email="nobody@example.com")
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(res.data["error"]["code"], "INVALID_CREDENTIALS")

    def test_login_suspended_account_is_forbidden(self):
        self.user.status = UserStatus.SUSPENDED
        self.user.save()
        res = self.login()
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(res.data["error"]["code"], "ACCOUNT_SUSPENDED")

    def test_login_missing_field_is_validation_error(self):
        res = self.client.post(
            reverse("v1:authentication:login"),
            {"email": "raj.admin@example.com"},
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data["error"]["code"], "VALIDATION_ERROR")


class RefreshTests(AuthTestBase):
    def test_refresh_rotates_tokens(self):
        refresh = self.login().data["data"]["refresh_token"]
        res = self.client.post(
            reverse("v1:authentication:refresh"),
            {"refresh_token": refresh},
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertNotEqual(res.data["data"]["refresh_token"], refresh)

    def test_reused_refresh_token_is_rejected(self):
        refresh = self.login().data["data"]["refresh_token"]
        self.client.post(
            reverse("v1:authentication:refresh"),
            {"refresh_token": refresh},
            format="json",
        )
        # Second use of the now-blacklisted token must fail.
        res = self.client.post(
            reverse("v1:authentication:refresh"),
            {"refresh_token": refresh},
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(res.data["error"]["code"], "INVALID_REFRESH_TOKEN")


class LogoutTests(AuthTestBase):
    def test_logout_blacklists_refresh_token(self):
        tokens = self.login().data["data"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {tokens['access_token']}")
        res = self.client.post(
            reverse("v1:authentication:logout"),
            {"refresh_token": tokens["refresh_token"]},
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        # The refresh token can no longer be used.
        self.client.credentials()
        res2 = self.client.post(
            reverse("v1:authentication:refresh"),
            {"refresh_token": tokens["refresh_token"]},
            format="json",
        )
        self.assertEqual(res2.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_logout_requires_authentication(self):
        res = self.client.post(
            reverse("v1:authentication:logout"),
            {"refresh_token": "x"},
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)


class MeTests(AuthTestBase):
    def test_me_returns_current_user(self):
        access = self.login().data["data"]["access_token"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")
        res = self.client.get(reverse("v1:authentication:me"))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data["data"]["email"], "raj.admin@example.com")

    def test_me_without_token_is_unauthorized(self):
        res = self.client.get(reverse("v1:authentication:me"))
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)


class PermissionTests(AuthTestBase):
    def test_is_admin_allows_matching_role(self):
        from apps.common.permissions import IsAdmin

        request = type("Req", (), {"user": self.user})()
        self.assertTrue(IsAdmin().has_permission(request, None))

    def test_is_teacher_blocks_other_role(self):
        from apps.common.permissions import IsTeacher

        request = type("Req", (), {"user": self.user})()
        self.assertFalse(IsTeacher().has_permission(request, None))
