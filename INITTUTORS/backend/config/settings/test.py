"""Test settings — isolated, fast, and independent of Supabase.

Uses an in-memory SQLite database and a fast password hasher so the suite runs
quickly and never touches the real (Supabase) database.
"""

from .base import *  # noqa: F401,F403
from .base import REST_FRAMEWORK

DEBUG = False
ALLOWED_HOSTS = ["*"]

# Disable rate limiting in tests — the shared throttle counter would otherwise
# bleed across test methods (same IP+email). The throttle is exercised
# separately, not in these behavioural tests.
REST_FRAMEWORK = {**REST_FRAMEWORK, "DEFAULT_THROTTLE_RATES": {"auth": None}}

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}

# Fast hashing for tests only (production uses bcrypt per base.py).
PASSWORD_HASHERS = ["django.contrib.auth.hashers.MD5PasswordHasher"]
