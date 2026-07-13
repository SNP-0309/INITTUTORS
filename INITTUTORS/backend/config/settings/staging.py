"""Staging environment settings.

Uses an isolated database and sandbox/mock notification providers — staging
must never send real notifications to parents (development.md §11).
"""

from .base import *  # noqa: F401,F403
from .base import env

DEBUG = False

ALLOWED_HOSTS = env.list("ALLOWED_HOSTS")

# Standard production-grade security headers (relaxed vs production as needed).
SECURE_SSL_REDIRECT = env.bool("SECURE_SSL_REDIRECT", default=True)
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
