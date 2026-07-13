# `media` app

Media upload flow: signed upload URLs and orphaned-upload cleanup. Corresponds to api.md §17.1.

## Structure

Follows the standard module anatomy (development.md 2, backend.md 3):

- `models.py` - data models (none yet)
- `serializers.py` - request/response serializers (none yet)
- `services.py` - business logic lives here, never in views (development.md 3.4)
- `views.py` - HTTP concerns only
- `urls.py` - route-to-view mapping
- `tests.py` - unit/integration tests

> Initialization scaffold only: no models, endpoints, or business logic yet.

