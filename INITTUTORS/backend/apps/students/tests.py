import io
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.core.files.uploadedfile import SimpleUploadedFile
from apps.authentication.models import User
from apps.common.constants import Role, UserStatus
from .models import Student, Parent, StudentParent, ParentRelation

PASSWORD = "Passw0rd123"


class StudentTests(APITestCase):
    def setUp(self):
        # Create users
        self.admin = User.objects.create_user(
            phone="9876500011",
            full_name="Raj Admin",
            email="admin@example.com",
            password=PASSWORD,
            role=Role.ADMIN,
        )
        self.teacher = User.objects.create_user(
            phone="9876500012",
            full_name="Raj Teacher",
            email="teacher@example.com",
            password=PASSWORD,
            role=Role.TEACHER,
        )
        
        # Setup initial student and parent
        self.parent_user = User.objects.create_user(
            phone="9876500013",
            full_name="Parent One",
            password=PASSWORD,
            role=Role.PARENT,
        )
        self.parent = Parent.objects.create(
            user=self.parent_user,
            relation=ParentRelation.FATHER,
        )
        self.student = Student.objects.create(
            roll_number="S001",
            admission_date="2026-07-01",
            first_name="Ramesh",
            last_name="Kumar",
            phone="9876500014",
            parent_phone="9876500013",
            standard="10th",
        )
        self.student_parent = StudentParent.objects.create(
            student=self.student,
            parent=self.parent,
            is_primary=True,
        )

    def get_token_header(self, user):
        from rest_framework_simplejwt.tokens import RefreshToken
        refresh = RefreshToken.for_user(user)
        refresh["role"] = user.role
        access = refresh.access_token
        access["role"] = user.role
        return f"Bearer {str(access)}"

    def test_list_students_authenticated(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.get(reverse("v1:students:student-list-create"))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn("results", res.data["data"])
        self.assertEqual(res.data["data"]["count"], 1)

    def test_search_students(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        
        # Match student name
        res = self.client.get(reverse("v1:students:student-list-create"), {"search": "Ramesh"})
        self.assertEqual(res.data["data"]["count"], 1)

        # Match parent name
        res = self.client.get(reverse("v1:students:student-list-create"), {"search": "Parent"})
        self.assertEqual(res.data["data"]["count"], 1)

        # No match search
        res = self.client.get(reverse("v1:students:student-list-create"), {"search": "Physics"})
        self.assertEqual(res.data["data"]["count"], 0)

    def test_create_student_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.post(
            reverse("v1:students:student-list-create"),
            {
                "roll_number": "S002",
                "admission_date": "2026-07-05",
                "first_name": "Suresh",
                "last_name": "Kumar",
                "phone": "9876500015",
                "standard": "12th",
                "parent": {
                    "full_name": "Parent Two",
                    "phone": "9876500016",
                    "relation": "mother",
                    "is_primary": True
                }
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.data["data"]["first_name"], "Suresh")
        self.assertEqual(res.data["data"]["primary_parent"]["full_name"], "Parent Two")

        # Verify parent user was created
        self.assertTrue(User.objects.filter(phone="9876500016").exists())

    def test_create_student_sibling_match(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        # Create sibling using the same parent phone number
        res = self.client.post(
            reverse("v1:students:student-list-create"),
            {
                "roll_number": "S003",
                "admission_date": "2026-07-05",
                "first_name": "Ganesh",
                "standard": "10th",
                "parent": {
                    "full_name": "Parent One",
                    "phone": "9876500013", # Taken by self.parent_user
                    "relation": "father",
                }
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        # Verify Ganesh is linked to Parent One
        student = Student.objects.get(roll_number="S003")
        self.assertEqual(student.student_parent_links.first().parent, self.parent)

    def test_create_student_future_admission_date_fails(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.post(
            reverse("v1:students:student-list-create"),
            {
                "roll_number": "S004",
                "admission_date": "2100-01-01",
                "first_name": "Invalid",
                "standard": "10th",
                "parent": {
                    "full_name": "Parent",
                    "phone": "9876500017",
                }
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        fields = [d["field"] for d in res.data["error"]["details"]]
        self.assertIn("admission_date", fields)

    def test_update_student_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.put(
            reverse("v1:students:student-detail", kwargs={"pk": self.student.id}),
            {
                "first_name": "Ramesh Updated",
                "parent": {
                    "full_name": "Parent One Updated",
                    "phone": "9876500013"
                }
            },
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data["data"]["first_name"], "Ramesh Updated")
        self.assertEqual(res.data["data"]["primary_parent"]["full_name"], "Parent One Updated")

    def test_delete_student_admin_success(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        res = self.client.delete(
            reverse("v1:students:student-detail", kwargs={"pk": self.student.id})
        )
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Student.objects.filter(id=self.student.id).exists())

    def test_media_upload_endpoint(self):
        auth_header = self.get_token_header(self.admin)
        self.client.credentials(HTTP_AUTHORIZATION=auth_header)
        
        # Create a mock file
        file = SimpleUploadedFile("avatar.jpg", b"file_content", content_type="image/jpeg")
        res = self.client.post(
            reverse("v1:media:media-upload"),
            {"file": file},
            format="multipart"
        )
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertIn("url", res.data["data"])
