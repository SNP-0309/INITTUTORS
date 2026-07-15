"""Root URL configuration.

Only wiring lives here — no business endpoints are defined yet. Each feature
app owns its own `urls.py` and is mounted under the versioned `/api/v1/` base
path (api.md §2) as endpoints are implemented in later phases.
"""

from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path

# Versioned API routes. App route modules are added here as they are built,
# e.g. path("students/", include("apps.students.urls")).
api_v1_patterns = [
    path("auth/", include("apps.authentication.urls")),
    path("institutes/", include("apps.institutes.urls")),
    path("teachers/", include("apps.teachers.urls")),
    path("students/", include("apps.students.urls")),
    path("media/", include("apps.media.urls")),
    path("batches/", include("apps.batches.urls")),
]

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/", include((api_v1_patterns, "v1"), namespace="v1")),
]

# Serve uploaded media via Django's dev server only (production uses object
# storage / a real web server).
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
