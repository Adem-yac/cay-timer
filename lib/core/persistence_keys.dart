/// Keys for [SharedPreferences] (Flutter adds the `flutter.` prefix on Android).
abstract final class PersistenceKeys {
  static const userGoals = 'user_goals_json';
  static const userBlockingApps = 'user_blocking_apps_json';
  static const blockedPackageNames = 'blocked_package_names';
}
