<!-- AI companion guide for working on the sbpos_mobile_v2 monorepo.
Keep this file concise and focused on discoverable, repo-specific patterns. -->

# Quick AI Onboarding — sbpos_mobile_v2

Purpose: give an AI coding agent the minimum, high-value knowledge to be productive in this monorepo.

## Big picture
- Monorepo layout: `core/` contains shared utilities and re-exports; `features/<name>/` are Flutter packages implementing domain slices.
- Entrypoints: `lib/main.dart` (production-like run; loads `.env.local` then `.env`) and `lib/main_local.dart` (dev logging and provider overrides).
- Routing: single router in `core/lib/utils/app_router.dart`; route strings live in `core/lib/utils/app_routes.dart`. Use `AppRouter.instance.router`.
- State: Riverpod (hooks_riverpod + flutter_riverpod). App root is wrapped by `ProviderScope`.
- Feature layout: each feature typically follows MVVM-like folders: `lib/domain`, `lib/data`, `lib/presentation` (providers/viewmodels live under `presentation`).

## Key files to inspect (start here)
- Router: core/lib/utils/app_router.dart — register `GoRoute` entries and pages.
- Route constants: core/lib/utils/app_routes.dart — canonical strings for navigation.
- Shared exports: core/lib/core.dart — where common widgets/helpers are re-exported.
- Entrypoints: lib/main.dart and lib/main_local.dart — environment loading and logging setup.
- Feature scaffolding: create_feature.py — shows required package layout and sample exports.
- Path deps manager: update_path_module.py — updates all feature `pubspec.yaml` path deps and `publish_to` settings.

## Developer workflows & common commands
- Install/update deps (root):
  ```bash
  flutter pub get
  ```
- After adding/removing features (mandatory):
  ```bash
  python update_path_module.py
  flutter pub get
  ```
- Scaffold a feature: edit `project_name` inside `create_feature.py` then run:
  ```bash
  python create_feature.py
  ```
- Run app (Windows):
  ```bash
  flutter run -d windows
  ```
- Run dev-local with provider overrides: run `lib/main_local.dart` as the entrypoint (IDE run configuration or `flutter run -t lib/main_local.dart`).
- Analyze / tests:
  ```bash
  <!-- Compact Copilot instructions for working on the `sbpos_mobile_v2` monorepo.
  Keep edits focused: update only discoverable, repo-specific guidance. -->

  # AI Guidance for sbpos_mobile_v2

  Purpose: give an AI agent the minimal, repo-specific knowledge to be productive quickly.

  ## Big picture
  - Monorepo: `core/` contains shared utilities and re-exports; `features/<name>/` are Dart/Flutter packages each with `lib/domain`, `lib/data`, `lib/presentation`.
  - Entrypoints: [lib/main.dart](lib/main.dart#L1-L120) (loads `.env.local` then `.env`) and [lib/main_local.dart](lib/main_local.dart#L1-L200) (dev overrides, logging).
  - Routing: single router in [core/lib/utils/app_router.dart](core/lib/utils/app_router.dart#L1-L200) using constants in [core/lib/utils/app_routes.dart](core/lib/utils/app_routes.dart#L1-L120). Use `AppRouter.instance.router`.
  - State: Riverpod (`hooks_riverpod` + `flutter_riverpod`). App root uses `ProviderScope`.

  ## Key patterns & where to change things
  - Add a route: add constant to [core/lib/utils/app_routes.dart](core/lib/utils/app_routes.dart#L1-L120) then register a `GoRoute` in [core/lib/utils/app_router.dart](core/lib/utils/app_router.dart#L1-L200) with a `pageBuilder` returning the screen widget.
  - Shared exports: add utilities/widgets to [core/lib/core.dart](core/lib/core.dart#L1-L120) so features import `package:core/core.dart` instead of reaching across feature boundaries.
  - Feature API: each feature should expose a `lib/<feature>.dart` that re-exports its public API for path-based package deps.
  - Data layer: DAOs and local DB code live under each feature's `lib/data` and use `sqflite` for persistence.

  ## Scripts & developer workflows (Windows notes)
  - Install/update deps (root):
    ```bash
    flutter pub get
    ```
  - After adding/removing features or changing path deps:
    ```bash
    python update_path_module.py
    flutter pub get
    ```
  - Scaffold a feature: edit `project_name` in `create_feature.py` and run:
    ```bash
    python create_feature.py
    ```
  - Run app (Windows):
    ```bash
    flutter run -d windows
    ```
  - Run dev-local target (provider overrides, demo data): run the `main_local.dart` target in your IDE or via `flutter run -t lib/main_local.dart`.
  - Analyze and test:
    ```bash
    flutter analyze
    flutter test
    ```

  ## Conventions to follow (do not improvise)
  - Centralize 3rd-party and shared exports in `core/lib/core.dart`; do not import between features directly.
  - Use route constants from `AppRoutes` for navigation (example: `context.go(AppRoutes.transactionPos)`).
  - Keep presentation/viewmodel/provider code under `presentation/providers` or `presentation/viewmodels` inside a feature.
  - Feature pubspecs and `publish_to` are managed by `update_path_module.py` — always run it after structural changes.

  ## Integration points & notable deps
  - Navigation: `go_router` configured in `core`.
  - State: `hooks_riverpod` + `flutter_riverpod`.
  - Local DB: `sqflite`; DAOs live under features' `lib/data`.
  - Env: `flutter_dotenv` (loaded in `lib/main.dart`, `.env.local` preferred).
  - Logging: `lib/main_local.dart` configures `package:logging` for local runs.

  ## Quick examples
  - Router singleton: `final router = AppRouter.instance.router;`
  - Add shared util: create under `core/lib/utils/` and export from [core/lib/core.dart](core/lib/core.dart#L1-L120).

  ---
  If you'd like, I can:
  1) run `python update_path_module.py` and `flutter pub get`,
  2) add an example route and screen in [core/lib/utils/app_router.dart](core/lib/utils/app_router.dart#L1-L200), or
  3) expand CI/testing steps. Which should I do next?
