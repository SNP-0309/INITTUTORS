"""Custom DRF exception handling → standard error envelope (api.md §4.1/§4.3).

All errors are returned as:
    { "success": false, "error": { "code", "message", "details"? } }

Domain code raises `AppError` subclasses (or DRF's built-in exceptions); this
handler maps them to the envelope. Unexpected exceptions become a generic
500 INTERNAL_ERROR with no internal detail leaked (backend.md §7.2).
"""

from rest_framework import status as http_status
from rest_framework.exceptions import APIException
from rest_framework.response import Response
from rest_framework.views import exception_handler as drf_exception_handler


class AppError(APIException):
    """Base class for typed domain errors carrying an api.md error `code`."""

    status_code = http_status.HTTP_400_BAD_REQUEST
    default_code = "VALIDATION_ERROR"
    default_detail = "Request could not be processed."


class InvalidCredentialsError(AppError):
    status_code = http_status.HTTP_401_UNAUTHORIZED
    default_code = "INVALID_CREDENTIALS"
    default_detail = "Invalid email or password."


class AccountSuspendedError(AppError):
    status_code = http_status.HTTP_403_FORBIDDEN
    default_code = "ACCOUNT_SUSPENDED"
    default_detail = "This account is not active. Contact your institute."


class InvalidRefreshTokenError(AppError):
    status_code = http_status.HTTP_401_UNAUTHORIZED
    default_code = "INVALID_REFRESH_TOKEN"
    default_detail = "Refresh token is invalid or expired."


# Maps DRF's default_code strings to the api.md §4.3 registry codes where they
# differ, so responses use the documented codes.
_DRF_CODE_MAP = {
    "not_authenticated": "TOKEN_EXPIRED",
    "authentication_failed": "TOKEN_EXPIRED",
    "permission_denied": "FORBIDDEN_ROLE",
    "not_found": "RESOURCE_NOT_FOUND",
    "throttled": "RATE_LIMIT_EXCEEDED",
    "invalid": "VALIDATION_ERROR",
    "parse_error": "BAD_REQUEST",
}


def _extract_details(detail):
    """Turn DRF's nested validation detail into a flat details list."""
    if isinstance(detail, dict):
        return [
            {"field": field, "issue": str(msgs[0]) if isinstance(msgs, list) else str(msgs)}
            for field, msgs in detail.items()
        ]
    return None


def custom_exception_handler(exc, context):
    response = drf_exception_handler(exc, context)

    if response is None:
        # Unhandled/unexpected exception — never leak internals (backend.md §7.2).
        return Response(
            {
                "success": False,
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "Something went wrong on our end. Please try again.",
                },
            },
            status=http_status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    code = getattr(exc, "default_code", None) or "ERROR"
    code = _DRF_CODE_MAP.get(code, code)
    # Normalize to UPPER_SNAKE_CASE for anything not already mapped.
    if code == code.lower():
        code = code.upper()

    detail = getattr(exc, "detail", response.data)
    if isinstance(detail, dict):
        message = "Validation failed."
    elif isinstance(detail, list):
        message = str(detail[0]) if detail else "Error."
    else:
        message = str(detail)

    error_body = {"code": code, "message": message}
    details = _extract_details(detail)
    if details:
        error_body["details"] = details

    response.data = {"success": False, "error": error_body}
    return response
