from django.urls import path
from .views import (
    AttendanceByBatchDateView,
    AttendanceByBatchView,
    AttendanceByStudentView,
    BatchRosterForAttendanceView,
)

urlpatterns = [
    path("", AttendanceByBatchDateView.as_view()),
    path("batch/<uuid:batch_id>/", AttendanceByBatchView.as_view()),
    path("batch/<uuid:batch_id>/roster/", BatchRosterForAttendanceView.as_view()),
    path("student/<uuid:student_id>/", AttendanceByStudentView.as_view()),
]
