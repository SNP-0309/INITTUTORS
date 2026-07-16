"""Standard success-envelope helper (api.md §4.1).

Every successful response follows `{ "success": true, "data": ..., "meta": ... }`.
Errors are shaped by the custom exception handler in `exceptions.py`.
"""

from typing import Any

from rest_framework.response import Response


def success(data: Any = None, *, status: int = 200, meta: dict | None = None) -> Response:
    body: dict[str, Any] = {"success": True, "data": data}
    if meta is not None:
        body["meta"] = meta
    return Response(body, status=status)
