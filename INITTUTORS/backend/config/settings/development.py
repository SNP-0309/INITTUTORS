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

# Disable/relax rate limiting in development/testing to prevent unit test failures
REST_FRAMEWORK = {
    **REST_FRAMEWORK,
    "DEFAULT_THROTTLE_RATES": {
        "auth": "10000/h",  # Extremely relaxed rate for testing/development
    }
}

