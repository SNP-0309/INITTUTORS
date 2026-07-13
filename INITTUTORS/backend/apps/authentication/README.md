# `authentication` app

Identity & access: JWT auth wiring, login/refresh/logout, RBAC enforcement, and account lifecycle. Corresponds to Module 1 (Auth & Roles).

## Structure

Follows the standard module anatomy (development.md 2, backend.md 3):

- `models.py` - data models (none yet)
- `serializers.py` - request/response serializers (none yet)
- `services.py` - business logic lives here, never in views (development.md 3.4)
- `views.py` - HTTP concerns only
- `urls.py` - route-to-view mapping
- `tests.py` - unit/integration tests

> Initialization scaffold only: no models, endpoints, or business logic yet.

