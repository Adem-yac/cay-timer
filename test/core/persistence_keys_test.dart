import 'package:flutter_test/flutter_test.dart';

import 'package:caytimer/core/persistence_keys.dart';

void main() {
  test('PersistenceKeys are stable contract strings', () {
    expect(PersistenceKeys.userGoals, 'user_goals_json');
    expect(PersistenceKeys.userBlockingApps, 'user_blocking_apps_json');
    expect(PersistenceKeys.blockedPackageNames, 'blocked_package_names');
  });
}
