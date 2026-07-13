# Attendance Management System (AMS)

Mobile-first attendance management for coaching institutes. Monorepo containing
the backend API and the mobile client.

> **Status:** project *initialization* only — no models, endpoints, business
> logic, or UI are implemented yet. This scaffold establishes structure,
> configuration, and conventions for subsequent feature work.

## Stack

| Layer | Technology |
|---|---|
| Backend | Django 5 + Django REST Framework |
| Auth | JWT (djangorestframework-simplejwt) |
| Database | Supabase PostgreSQL |
| Frontend | Flutter (Dart) |
| Routing (FE) | go_router |
| State (FE) | Riverpod |
| HTTP (FE) | Dio |
| Env (FE) | flutter_dotenv + `--dart-define` |

> **Stack note / deviation from docs.** The docs in `docs/` describe an assumed
> Node.js + Express + React stack, but every doc explicitly labels that stack a
> *recommendation, not a mandate* (`backend.md §1.1`, `development.md`). This
> project deliberately uses **Django + Flutter + Supabase** per the project
> owner's instruction. The docs remain the source of truth for **architecture,
> module boundaries, naming, business rules, and API/DB contracts**, which are
> translated into Django/Flutter idioms.

## Repository layout

```
INITTUTORS/
├── docs/         # Source-of-truth documentation
├── backend/      # Django + DRF API
├── frontend/     # Flutter app
├── .gitignore
└── README.md
```

## Backend — getting started

```bash
cd backend
python -m venv .venv
# Windows:  .venv\Scripts\activate      macOS/Linux:  source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # then fill in DATABASE_URL, secrets, etc.
python manage.py check
python manage.py runserver
```

- Settings are split per environment under `config/settings/`
  (`development` / `staging` / `production`), selected via
  `DJANGO_SETTINGS_MODULE`. Config is validated at boot (fail-fast).
- Feature apps live under `apps/` (one per bounded domain).
- No migrations exist yet — models are added in a later phase.

## Frontend — getting started

```bash
cd frontend
flutter pub get
cp .env.example .env          # then set API_BASE_URL if needed
flutter analyze
flutter run
```

- App code is under `lib/` (`app/`, `core/`, `features/`, `shared/`).
- Routing (`core/router`), theme (`core/theme`), API client (`core/network`),
  and env (`core/config`) are configured; screens are placeholder stubs.

## Manual setup required

See the "What you'll need to do manually" section provided with this scaffold:
create the Supabase project, populate `backend/.env` and `frontend/.env`, and
(optionally) `git init` at the repo root. Do **not** run migrations until models
exist.
