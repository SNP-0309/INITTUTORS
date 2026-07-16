from django.urls import path
from .views import AnnouncementListCreateView, AnnouncementDetailView

urlpatterns = [
    path("", AnnouncementListCreateView.as_view()),
    path("<uuid:pk>/", AnnouncementDetailView.as_view()),
]
