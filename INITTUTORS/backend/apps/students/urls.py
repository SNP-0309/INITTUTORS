from django.urls import path
from .views import StudentListCreateView, StudentDetailView

app_name = "students"

urlpatterns = [
    path("", StudentListCreateView.as_view(), name="student-list-create"),
    path("<uuid:pk>/", StudentDetailView.as_view(), name="student-detail"),
]
