<!--
Concise guidance for AI coding agents working on the `sbpos_mobile_v2` monorepo.
Keep edits focused and use the examples below when changing code.
-->

# AI Guidance for sbpos_mobile_v2

Purpose: Help an AI agent get productive quickly by surfacing architecture, workflows, and project-specific conventions.

- Project type: Flutter monorepo (app + local feature packages).
- Top-level packages: `core/` (shared) and `features/<name>/` (module packages).

## Big picture

- App entry points: `lib/main.dart` and `lib/main_local.dart` (both import `package:core/core.dart`).
- `core/` re-exports shared widgets, helpers, and third-party packages from `core/lib/core.dart`. Add cross-package utilities there.
- Navigation: central `go_router` instance in `core/lib/utils/app_router.dart` using string constants in `core/lib/utils/app_routes.dart`.
- State management: Riverpod (hooks_riverpod + flutter_riverpod). App root wraps with `ProviderScope`.
- Feature structure: follow MVVM-like layout inside each feature: `domain`, `data`, `presentation`.

## Key files & where to change things

- Routing: update `core/lib/utils/app_routes.dart` (add constant) and register the route in `core/lib/utils/app_router.dart`.
- Shared exports: add new shared helpers/widgets to `core/lib/core.dart` so features can `import 'package:core/core.dart'`.
- App setup: `lib/main.dart` (.env handling + `ProviderScope`), `lib/main_local.dart` (logging initialization).
- Feature entry: each feature should expose a `lib/<feature>.dart` that re-exports its public API (scaffolded by `create_feature.py`).

## Developer workflows & common commands

- Install/update deps (root):
  - flutter pub get
- Normalize internal path deps after adding/removing features:
  - python update_path_module.py
  - then `flutter pub get`
- Scaffold a feature (optional):
  - python create_feature.py (edit `project_name` in the script) — it creates the MVVM skeleton.
- Run app (Windows):
  - flutter run -d windows
  - or target an emulator: flutter run -d emulator-5554
- Run tests:
  - flutter test (root or package folder)
  - flutter test core/test for core package tests
- Build Android release (root):
  - cd android && .\gradlew.bat assembleRelease

## Project-specific conventions (do not improvise)

- Centralize shared code in `core/` and export via `core/lib/core.dart`. Avoid cross-feature imports that bypass `core`.
- Route names: use constants in `AppRoutes` (no hardcoded strings). Example: `context.go(AppRoutes.transactionPos)`.
- Feature layout: prefer `lib/domain`, `lib/data`, `lib/presentation` with providers/viewmodels under `presentation/providers` or `presentation/viewmodels`.
- Module publishing: features are local path packages; `update_path_module.py` ensures `publish_to: none` for features and correct `path` entries.

## Integration points & notable dependencies

- Navigation: `go_router` (router singleton in `core`).
- State: `hooks_riverpod` + `flutter_riverpod`.
- Local DB: `sqflite` (DAOs live under feature `data` folders).
- Dotenv: `flutter_dotenv` for environment - `lib/main.dart` prefers `.env.local` then `.env`.
- Logging: configured in `lib/main_local.dart` using `package:logging`.

## Examples & quick patterns

- Router singleton: `final router = AppRouter.instance.router;`
- Add route:
  1. Add constant in `core/lib/utils/app_routes.dart`.
  2. Register `GoRoute` in `core/lib/utils/app_router.dart` with `pageBuilder` returning the screen widget.
- Add shared helper:
  1. Add file under `core/lib/utils` (or `presentation/widgets`).
  2. Export it from `core/lib/core.dart`.
- Scaffold a feature and wire to the app:
  - python create_feature.py (creates structure)
  - run python update_path_module.py && flutter pub get

## When to run the scripts

- Run `update_path_module.py` after adding/removing features or changing path deps.
- Run `create_feature.py` only when scaffolding new feature skeletons.

## If you get stuck

- Check `pubspec.yaml` at the root for active path deps.
- Look at `core/lib/core.dart` to see available exported helpers and packages.
- Run `flutter analyze <package>` or `flutter test <package>/test` for package-scoped diagnostics.

---
If you'd like, I can: (1) run `python update_path_module.py` and `flutter pub get`, (2) add an example route change to `app_router.dart`, or (3) expand testing guidelines. Which should I do next?
