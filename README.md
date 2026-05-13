# Caytimer

[![CI](https://github.com/Adem-yac/cay-timer/actions/workflows/ci.yml/badge.svg)](https://github.com/Adem-yac/cay-timer/actions/workflows/ci.yml)

Cross-platform **Flutter** app for focused work: Pomodoro-style timer, daily goals, and **Android** app blocking (via accessibility service). iOS builds run; blocking features target Android where `installed_apps` applies.

## Requirements

- Flutter SDK (stable), Dart `^3.9`
- For Android: SDK 21+, Gradle as shipped with Flutter

## Quick start

```bash
git clone https://github.com/Adem-yac/cay-timer.git
cd cay-timer
flutter pub get   # refreshes pubspec.lock if dependencies changed
flutter run
```

Optional local config (not read by the app yet—template for future API / Supabase):

```bash
cp env.example.json env.json
```

Never commit real API keys; `env.json` is gitignored.

## Scripts

| Command | Purpose |
|--------|---------|
| `flutter analyze` | Static analysis |
| `flutter test` | Unit + widget tests |
| `flutter build apk` | Release APK |
| `flutter build ios` | iOS (on macOS) |

## Architecture

| Path | Role |
|------|------|
| `lib/main.dart` | Entry, orientation lock, global error surface |
| `lib/core/app_state.dart` | Singleton `ChangeNotifier`, prefs, i18n strings |
| `lib/core/persistence_keys.dart` | `SharedPreferences` keys for JSON blobs |
| `lib/core/app_log.dart` | Debug logging (`dart:developer`); swap for Crashlytics/Sentry in prod |
| `lib/presentation/` | Screens & widgets by feature |
| `lib/presentation/routes/app_routes.dart` | Named routes |
| `android/.../AppBlockingAccessibilityService.kt` | Android blocking integration |

**Persistence:** no SQL database—[`shared_preferences`](https://pub.dev/packages/shared_preferences) plus JSON strings for goals and blocked-app metadata.

**Tests:** `test/flutter_test_config.dart` disables runtime Google Fonts fetching so CI stays offline-stable.

## CI

GitHub Actions runs `flutter pub get`, `flutter analyze`, and `flutter test` on every push and pull request to `main`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
