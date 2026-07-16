"""Authentication business logic (backend.md §5, §11).

Kept out of views/serializers so it is independently testable. Responsible for:
credential verification, account-status gating, JWT issuance, refresh rotation,
and logout (refresh-token blacklisting).
"""

from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken

from apps.common.constants import UserStatus
from apps.common.exceptions import (
    AccountSuspendedError,
    InvalidCredentialsError,
    InvalidRefreshTokenError,
)

User = get_user_model()

# api.md §3.1: access token lifetime is 15 minutes (900s). Sourced from the
# configured SIMPLE_JWT lifetime so the two never drift.
from django.conf import settings  # noqa: E402

ACCESS_TOKEN_TTL_SECONDS = int(
    settings.SIMPLE_JWT["ACCESS_TOKEN_LIFETIME"].total_seconds()
)


def _issue_tokens_for(user) -> dict:
    """Build the standard token payload (api.md §3.4).

    Adds `role` as a custom claim; `sub` (user id) is added by simplejwt.
    """
    refresh = RefreshToken.for_user(user)
    refresh["role"] = user.role
    access = refresh.access_token
    access["role"] = user.role
    return {
        "access_token": str(access),
        "refresh_token": str(refresh),
        "expires_in": ACCESS_TOKEN_TTL_SECONDS,
    }


def authenticate(*, email: str, password: str):
    """Verify email+password and return the active user.

    Uses a generic INVALID_CREDENTIALS error for both unknown-email and
    wrong-password to avoid user enumeration (FR-1.4). A suspended account that
    supplies correct credentials gets the distinct ACCOUNT_SUSPENDED signal
    (backend.md §5.3).
    """
    user = (
        User.objects.filter(email__iexact=email, deleted_at__isnull=True).first()
    )
    if user is None or not user.check_password(password):
        raise InvalidCredentialsError()

    if user.status == UserStatus.SUSPENDED or not user.is_active:
        raise AccountSuspendedError()

    return user


def login(*, email: str, password: str) -> dict:
    user = authenticate(email=email, password=password)
    user.last_login = timezone.now()
    user.save(update_fields=["last_login"])
    tokens = _issue_tokens_for(user)
    return {"user": user, **tokens}


def refresh(*, refresh_token: str) -> dict:
    """Rotate a refresh token: blacklist the old one, issue a fresh pair.

    Reuse of an already-blacklisted token raises INVALID_REFRESH_TOKEN.
    """
    try:
        old = RefreshToken(refresh_token)
    except TokenError as exc:
        raise InvalidRefreshTokenError() from exc

    user_id = old.get(settings.SIMPLE_JWT["USER_ID_CLAIM"])
    user = User.objects.filter(
        id=user_id, deleted_at__isnull=True
    ).first()
    if user is None:
        raise InvalidRefreshTokenError()
    if user.status == UserStatus.SUSPENDED or not user.is_active:
        raise AccountSuspendedError()

    # BLACKLIST_AFTER_ROTATION handles blacklisting the old token on rotation;
    # blacklist explicitly here as well to be robust against reuse.
    try:
        old.blacklist()
    except AttributeError:
        pass

    tokens = _issue_tokens_for(user)
    return {"user": user, **tokens}


def logout(*, refresh_token: str) -> None:
    """Invalidate a refresh token by blacklisting it (api.md §3.4)."""
    try:
        token = RefreshToken(refresh_token)
        token.blacklist()
    except TokenError as exc:
        raise InvalidRefreshTokenError() from exc
