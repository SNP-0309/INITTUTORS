"""
Base Django settings for the Attendance Management System (AMS).

Shared across all environments. Environment-specific overrides live in
`development.py`, `staging.py`, and `production.py`.

Configuration is sourced exclusively from environment variables and validated
at startup so the process fails fast if a required variable is missing
(per development.md §11). Nothing here defines models, endpoints, or business
logic — this is initialization/wiring only.
"""

from datetime import timedelta
from pathlib import Path

import dj_database_url
import environ

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
# BASE_DIR points at the `backend/` directory (two levels up from this file:
# config/settings/base.py -> config/settings -> config -> backend).
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# ---------------------------------------------------------------------------
# Environment loading (fail-fast)
# ---------------------------------------------------------------------------
env = environ.Env(
    DEBUG=(bool, False),
)

# Load a .env file if present (local/dev). In staging/production, variables are
# injected by the platform's secrets manager and this file is absent.
environ.Env.read_env(BASE_DIR / ".env")

# SECURITY: required in every environment — no insecure default is provided.
SECRET_KEY = env("DJANGO_SECRET_KEY")

DEBUG = env("DEBUG")

ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=[])

# ---------------------------------------------------------------------------
# Applications
# ---------------------------------------------------------------------------
DJANGO_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

THIRD_PARTY_APPS = [
    "rest_framework",
    "rest_framework_simplejwt",
    "rest_framework_simplejwt.token_blacklist",
    "corsheaders",
]

# Modular feature apps — one folder per bounded domain area (backend.md §3).
# These are scaffolding only: no models / endpoints / logic yet.
LOCAL_APPS = [
    "apps.common",
    "apps.authentication",
    "apps.institutes",
    "apps.teachers",
    "apps.students",
    "apps.batches",
    "apps.attendance",
    "apps.reports",
    "apps.notifications",
    "apps.dashboard",
    "apps.timetable",
    "apps.announcements",
    "apps.homework",
    "apps.notes",
    "apps.media",
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

# ---------------------------------------------------------------------------
# Middleware
# ---------------------------------------------------------------------------
# CorsMiddleware must be placed as high as possible, before CommonMiddleware.
MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"
ASGI_APPLICATION = "config.asgi.application"

# ---------------------------------------------------------------------------
# Database — Supabase PostgreSQL
# ---------------------------------------------------------------------------
# DATABASE_URL comes from the Supabase project (Settings -> Database).
# `conn_max_age` keeps connections warm; SSL is required by Supabase.
DATABASES = {
    "default": dj_database_url.config(
        default=env("DATABASE_URL"),
        conn_max_age=env.int("DB_CONN_MAX_AGE", default=600),
        ssl_require=env.bool("DB_SSL_REQUIRE", default=True),
    )
}

# ---------------------------------------------------------------------------
# Authentication
# ---------------------------------------------------------------------------
AUTH_USER_MODEL = "authentication.User"

# bcrypt (cost factor 12) as the primary password hasher, per backend.md §5.1.
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.BCryptSHA256PasswordHasher",
    "django.contrib.auth.hashers.PBKDF2PasswordHasher",
]

# Password policy: min 8 chars, at least 1 letter + 1 number (features.md §1.2).
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
        "OPTIONS": {"min_length": 8},
    },
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# ---------------------------------------------------------------------------
# Internationalization
# ---------------------------------------------------------------------------
# Default to IST per development.md §12 (institute's configured timezone).
LANGUAGE_CODE = "en-us"
TIME_ZONE = env("TIME_ZONE", default="Asia/Kolkata")
USE_I18N = True
USE_TZ = True

# ---------------------------------------------------------------------------
# Static & media files
# ---------------------------------------------------------------------------
STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
STATICFILES_DIRS = [BASE_DIR / "static"]

MEDIA_URL = "media/"
MEDIA_ROOT = BASE_DIR / "media"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# ---------------------------------------------------------------------------
# Django REST Framework
# ---------------------------------------------------------------------------
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
    # Offset-based pagination is the documented default for most list
    # endpoints (api.md §4.4): ?page=1&limit=25, max 100.
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 25,
    "DEFAULT_RENDERER_CLASSES": (
        "rest_framework.renderers.JSONRenderer",
    ),
    # Standard error envelope (api.md §4.1/§4.3).
    "EXCEPTION_HANDLER": "apps.common.exceptions.custom_exception_handler",
    # Rate limiting (api.md §4.6). The `auth` scope is applied per-endpoint by
    # the login throttle (5 requests / 15 min).
    "DEFAULT_THROTTLE_RATES": {
        "auth": "5/15m",
    },
}

# ---------------------------------------------------------------------------
# JWT authentication (djangorestframework-simplejwt)
# ---------------------------------------------------------------------------
# Access token 15 min / refresh 30 days with rotation, per api.md §3.1.
SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(
        minutes=env.int("JWT_ACCESS_TOKEN_LIFETIME_MINUTES", default=15)
    ),
    "REFRESH_TOKEN_LIFETIME": timedelta(
        days=env.int("JWT_REFRESH_TOKEN_LIFETIME_DAYS", default=30)
    ),
    "ROTATE_REFRESH_TOKENS": True,
    # Blacklist the old refresh token on rotation and on logout — the
    # Django-idiomatic equivalent of the reuse-detection/invalidation intent in
    # backend.md §5.2 / api.md §3.1 (token_version + institute_id are omitted:
    # multi-tenancy is out of scope per database.md §2).
    "BLACKLIST_AFTER_ROTATION": True,
    "SIGNING_KEY": env("JWT_SECRET", default=SECRET_KEY),
    "AUTH_HEADER_TYPES": ("Bearer",),
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "sub",
}

# ---------------------------------------------------------------------------
# CORS
# ---------------------------------------------------------------------------
# Allowlist driven by config; never a blanket allow-all in shared environments.
CORS_ALLOWED_ORIGINS = env.list("CORS_ALLOWED_ORIGINS", default=[])
CORS_ALLOW_CREDENTIALS = env.bool("CORS_ALLOW_CREDENTIALS", default=True)
