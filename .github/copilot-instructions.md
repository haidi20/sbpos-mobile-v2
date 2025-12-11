<!--
This file provides concise, actionable guidance for AI coding agents working
on the `sbpos_mobile_v2` monorepo. Keep the instructions short and focused —
examples reference files discovered in the workspace.
-->

# AI Guidance for sbpos_mobile_v2

Purpose: help an AI coding agent get productive quickly by surfacing
architecture, developer workflows, and project-specific conventions.

- **Project type:** Flutter mono-repo (app + local feature packages).
- **Root packages:** `core/` and multiple feature folders under `features/`.

## Big picture / architecture

- The app entry points are `lib/main.dart` and `lib/main_local.dart`. Both
  import shared APIs from `package:core/core.dart`.
- `core/` is the shared package: open `core/lib/core.dart` to see common
  exports (widgets, utils, helpers, and most third-party packages).
- Features live in `features/<name>/` and are referenced as path
  dependencies from the root `pubspec.yaml` (e.g. `dashboard`,
  `landing_page_menu`, `mode`, `outlet`, ...). Keep features decoupled and
  rely on `core` for shared code.

## Important files & patterns (quick refs)

- Routing: `core/lib/utils/app_router.dart` + `core/lib/utils/app_routes.dart`.
  - Uses a singleton `AppRouter.instance.router` and `go_router`.
  - Routes are defined centrally in `AppRoutes` (named constants).
- Environment loading: `lib/main.dart` prefers `.env.local` then `.env`.
  - Use `.env.local` for local overrides; the app tolerates missing env files.
- Logging: `lib/main_local.dart` configures `package:logging` once at startup.
- Shared exports: `core/lib/core.dart` gathers and re-exports public APIs —
  add new cross-package utilities there so features can import `package:core/core.dart`.

## Adding a new feature / module

1. Use the provided helper to scaffold a module (optional):

   - `python create_feature.py` (edit `project_name` in the script or modify to accept args).

2. Update internal path dependencies so packages reference each other correctly:

   - From repo root run: `python update_path_module.py` — this writes/normalizes `pubspec.yaml` entries for `core` and `features/*`.

3. Then run `flutter pub get` at the repo root.

Notes: the helper scripts create recommended MVVM folders (`domain`, `data`, `presentation`). Keep feature exports under `lib/<feature>.dart` so the root package can reference the module.

## Build / test / run (Windows PowerShell examples)

- Install deps: `flutter pub get`
- Run on local desktop: `flutter run -d windows`
- Run on Android emulator: `flutter run -d emulator-5554` (or use `flutter devices` to list)
- Build Android APK (from repo root):
  - `cd android; .\gradlew.bat assembleRelease`
- Run unit/widget tests (run in repo root or package dir):
  - `flutter test` (runs tests discovered in packages)
  - To run only core tests: `flutter test core/test`

## Conventions & patterns an agent should follow

- Follow the mono-repo pattern: features import shared APIs from `package:core/core.dart`.
- Use named routes from `AppRoutes` when adding navigation; do not hardcode paths.
- Prefer adding reusable UI or helpers into `core/` and export them from `core/lib/core.dart`.
- Use Riverpod providers and wrap changes with `ProviderScope` (already used in `main.dart`).
- Error handling and API helpers live under `core/lib/utils/helpers` —
  consult `api_helper.dart`, `handle_response.dart`, `failure.dart` for existing patterns.

## Integration points / external deps

- go_router for navigation (`core` manages the router singleton).
- Riverpod / hooks_riverpod for state management (ProviderScope is the app wrapper).
- sqflite, connectivity_plus, cached_network_image, fl_chart; check `core/lib/core.dart` for the authoritative list.

## What to look for when changing code

- If you add a new feature, update path dependencies (either modify root `pubspec.yaml` or run `update_path_module.py`).
- When changing routing, update both `AppRoutes` constants and `app_router.dart`.
- Adding shared APIs -> add to `core` and export via `core/lib/core.dart` to avoid import churn across features.

## Example snippets (copy/paste safe)

- Use router singleton: `final router = AppRouter.instance.router;`
- Named route navigation: `context.go(AppRoutes.productPos);`
- Load local env file in startup: main uses `dotenv.load(fileName: '.env.local')` with a fallback to `.env`.

---

If anything above is unclear or you'd like the guidance to emphasize other files (for example specific helper files under `core/lib/utils/helpers`), tell me which area to expand and I'll iterate.
