# Web Migration Checklist for sbpos_mobile_v2

This document lists native plugins found in the repository and recommended replacements or additions to make the app run on Flutter Web while keeping mobile functionality unchanged.

## Summary of native-only packages found
- sqflite (sqflite_android, sqflite_darwin)
- flutter_bcrypt (native build)
- path_provider + platform implementations
- connectivity_plus + platform implementations

## Recommended package additions (already added to root `pubspec.yaml`)
- `connectivity_plus_web` — web implementation for `connectivity_plus`.
- `path_provider_web` — web implementation for `path_provider`.
- `sembast` + `sembast_web` — file-based NoSQL DB with web (IndexedDB) support to use as a replacement/adapter for web.
- `bcrypt` (pure-Dart) — replace `flutter_bcrypt` usage on web via conditional import.

> Note: these were added to the root `pubspec.yaml` so mobile/native packages remain available. Adding these does not remove `sqflite` or other native plugins.

## Suggested migration approach (preserve current behavior)
1. Keep existing mobile/native packages (e.g., `sqflite`, `flutter_bcrypt`) in code for Android/iOS/desktop.
2. Create platform-specific implementations via conditional imports or factory constructors:
   - Database abstraction: define an interface `LocalDatabase` with methods used by the app. Implement `SqfliteLocalDatabase` for mobile and `SembastLocalDatabase` for web. Use conditional imports:
     ```dart
     // local_db.dart
     export 'local_db_mobile.dart'
         if (dart.library.html) 'local_db_web.dart';
     ```
   - Crypto hashing: export a `password_hash.dart` that conditionally imports the native `flutter_bcrypt` implementation for mobile, and the pure-Dart `bcrypt` for web.
3. Replace direct references to native-only APIs (file system, native channels) with adapter calls behind the interfaces.
4. Add `*_web` packages where applicable (already added) to `pubspec.yaml`.
5. Test web locally:
   ```bash
   flutter pub get
   flutter run -d chrome
   # or build
   flutter build web
   ```

## Files/places to inspect next
- `features/*/pubspec.yaml` — currently include `sqflite_common_ffi` in several packages. You may keep these but ensure package imports for DB are behind abstraction.
- DAO / repository implementations under `features/transaction/lib/data` and other features referencing sqflite.
- Any direct `flutter_bcrypt` imports in the repo — replace with conditional wrapper.

## Next actions I can take (choose one)
- A: Create the `LocalDatabase` abstraction and implement web/mobile adapters (moderate effort).
- B: Replace `flutter_bcrypt` usages with a small conditional wrapper that picks `bcrypt` on web and `flutter_bcrypt` on native (small effort).
- C: Create a PR that updates `pubspec.yaml` across packages to include the web packages (small effort; compatibility-only).

If you want, I can start with B (quick) then move to A.
