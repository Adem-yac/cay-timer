import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only structured logging. For production crash analytics, wire
/// [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics/get-started?platform=flutter)
/// or [Sentry](https://docs.sentry.io/platforms/flutter/).
void appLog(
  String message, {
  String name = 'caytimer',
  Object? error,
  StackTrace? stackTrace,
}) {
  if (kDebugMode) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 800,
    );
  }
}
