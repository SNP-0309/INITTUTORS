"""URL routes for the media app.

Intentionally empty during initialization — endpoints are added in later
phases. Routes are mounted under /api/v1/ from config/urls.py.
"""

from django.urls import path

from .views import MediaUploadView

app_name = "media"

urlpatterns = [
    path("upload/", MediaUploadView.as_view(), name="media-upload"),
]
