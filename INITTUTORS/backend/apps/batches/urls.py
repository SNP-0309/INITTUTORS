from django.urls import path
from .views import (
    BatchListCreateView,
    BatchDetailView,
    BatchStudentAssignView,
    BatchStudentRemoveView,
    SubjectListCreateView,
    ClassroomListCreateView,
)

app_name = "batches"

urlpatterns = [
    path("", BatchListCreateView.as_view(), name="batch-list-create"),
    path("<uuid:pk>/", BatchDetailView.as_view(), name="batch-detail"),
    path("<uuid:pk>/assign/", BatchStudentAssignView.as_view(), name="batch-assign"),
    path("<uuid:pk>/remove/", BatchStudentRemoveView.as_view(), name="batch-remove"),
    path("subjects/", SubjectListCreateView.as_view(), name="subject-list-create"),
    path("classrooms/", ClassroomListCreateView.as_view(), name="classroom-list-create"),
]
