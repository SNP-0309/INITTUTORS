"""Development environment settings.

Notifications must never fire to real parent phone numbers/emails from
development (development.md §11) — provider clients default to sandbox/mock
when their API keys are absent, which is the case in local `.env` files.
"""

from .base import *  # noqa: F401,F403
from .base import env

DEBUG = True

ALLOWED_HOSTS = env.list(
    "ALLOWED_HOSTS", default=["localhost", "127.0.0.1", "0.0.0.0"]
)

# Convenience for local Flutter/web clients hitting the dev server.
CORS_ALLOWED_ORIGINS = env.list(
    "CORS_ALLOWED_ORIGINS",
    default=["http://localhost:3000", "http://127.0.0.1:3000"],
)
