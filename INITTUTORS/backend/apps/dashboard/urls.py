"""URL routes for the dashboard app.
"""

from django.urls import path
from .views import OwnerDashboardView

app_name = "dashboard"

urlpatterns = [
    path("owner/", OwnerDashboardView.as_view(), name="owner-dashboard"),
]
