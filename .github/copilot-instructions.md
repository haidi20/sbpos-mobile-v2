<!--
Compact Copilot instructions for working on the `sbpos_mobile_v2` monorepo.
Keep edits focused: update only discoverable, repo-specific guidance.
-->

# AI Guidance for sbpos_mobile_v2

Purpose: rapidly onboard an AI agent by highlighting architecture, common workflows, and repo-specific conventions.

## Big picture (what to know first)

- Monorepo layout: `core/` holds shared utilities and re-exports; `features/<name>/` are local Flutter modules.
- Entrypoints: `lib/main.dart` (normal app; loads `.env.local` then `.env`) and `lib/main_local.dart` (initializes logging and overrides providers for local testing).
- Routing: single GoRouter configured in `core/lib/utils/app_router.dart` using constants from `core/lib/utils/app_routes.dart`. Use `AppRouter.instance.router` as the router singleton.
- State: Riverpod (hooks_riverpod + flutter_riverpod); app root is wrapped by `ProviderScope`.
- Feature convention: MVVM-like layout under each feature: `lib/domain`, `lib/data`, `lib/presentation` (providers/viewmodels under `presentation/providers` or `presentation/viewmodels`).

## Key files to reference (examples)

- Router: [core/lib/utils/app_router.dart](core/lib/utils/app_router.dart#L1-L200) — register `GoRoute` entries here.
- Route constants: [core/lib/utils/app_routes.dart](core/lib/utils/app_routes.dart#L1-L120) — add route strings here (example: `AppRoutes.transactionPos`).
- Shared exports: [core/lib/core.dart](core/lib/core.dart#L1-L120) — add new shared helpers/widgets here so features import `package:core/core.dart`.
- Entrypoints: [lib/main.dart](lib/main.dart#L1-L120) and [lib/main_local.dart](lib/main_local.dart#L1-L200).
- Feature scaffolding: `create_feature.py` (root) — shows required file layout and a sample `lib/<feature>.dart` export.
- Path deps script: `update_path_module.py` (root) — updates feature and core `pubspec.yaml` entries and sets `publish_to: none` for feature packages.

## Developer workflows & commands (repo-specific)

- Install/update deps (root):
  - `flutter pub get`
- After adding/removing features: run
  - `python update_path_module.py`
  - then `flutter pub get`
- Scaffold a feature (example):
  - Edit `project_name` in `create_feature.py` then run `python create_feature.py`.
- Run app (Windows):
  - `flutter run -d windows` (or `flutter run -d emulator-5554` for emulator)
- Run local app with concrete provider overrides (useful for development):
  - Run `lib/main_local.dart` target (this file wires local repos/providers for demo data).
- Analyze / Tests:
  - `flutter analyze` or `flutter analyze <package>`
  - `flutter test` (root or per-package tests)

## Project-specific conventions (do not improvise)

- Centralize shared logic and 3rd-party re-exports in `core/lib/core.dart`; avoid direct cross-feature imports that bypass `core`.
- Use route constants from `AppRoutes` instead of hardcoded strings. Example navigation: `context.go(AppRoutes.transactionPos)`.
- Feature pubspecs are managed by `update_path_module.py` — run it after structural changes to keep path deps consistent.
- Feature modules should expose a `lib/<feature>.dart` that re-exports their public API so `core` and other features can depend on the feature package.

## Integration points & notable dependencies

- Navigation: `go_router` (registered in `core`).
- State: `hooks_riverpod` + `flutter_riverpod`.
- Local DB: `sqflite` (DAOs under each feature `data` folder).
- Env: `flutter_dotenv` loaded in `lib/main.dart` (prefers `.env.local`).
- Logging: configured in `lib/main_local.dart` via `package:logging` for dev-local runs.

## Quick code patterns & examples

- Router singleton: `final router = AppRouter.instance.router;`
- Add a route:
  1. Add constant to [core/lib/utils/app_routes.dart](core/lib/utils/app_routes.dart#L1-L120).
  2. Register `GoRoute` in [core/lib/utils/app_router.dart](core/lib/utils/app_router.dart#L1-L200) using `pageBuilder` that returns the screen widget.
- Add shared export:
  1. Create helper under `core/lib/utils`.
  2. Export it from [core/lib/core.dart](core/lib/core.dart#L1-L120) so features can `import 'package:core/core.dart'`.

## When to run scripts

- Run `update_path_module.py` after adding/removing features or changing path deps.
- Run `create_feature.py` only when scaffolding new modules.

---
If you'd like, I can (pick one):
1) run `python update_path_module.py` and `flutter pub get`,
2) add an example route and screen registration in `core/lib/utils/app_router.dart`, or
3) expand testing and CI notes. Which should I do next?
