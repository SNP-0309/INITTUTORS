from django.urls import path
from .views import HomeworkListCreateView, HomeworkDetailView

urlpatterns = [
    path("", HomeworkListCreateView.as_view()),
    path("<uuid:pk>/", HomeworkDetailView.as_view()),
]
