# Contributing

Thanks for improving Caytimer.

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) stable channel
- Xcode (macOS) for iOS builds; Android Studio / SDK for Android

## Local setup

```bash
flutter pub get
cp env.example.json env.json   # optional; fill keys only if you add cloud features
flutter analyze
flutter test
```

## Pull requests

1. Branch from `main`.
2. Run `flutter analyze` and `flutter test` before opening a PR.
3. Describe the change and any user-visible behavior in the PR text.

## Code style

- Follow existing layout and naming in `lib/`.
- Prefer small, focused commits over large mixed changes.
