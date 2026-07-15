from django.urls import path
from .views import InstituteListCreateView, InstituteDetailView

urlpatterns = [
    path("", InstituteListCreateView.as_view(), name="institute-list-create"),
    path("<uuid:pk>/", InstituteDetailView.as_view(), name="institute-detail"),
]
