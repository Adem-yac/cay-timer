import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:caytimer/core/app_state.dart';
import 'package:caytimer/core/persistence_keys.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppState().resetForTests();
  });

  tearDown(() async {
    AppState().resetForTests();
  });

  group('AppState persistence', () {
    test('loadPrefs applies defaults when store is empty', () async {
      await AppState().loadPrefs();
      final s = AppState();
      expect(s.language, 'en');
      expect(s.timerPreset, 25);
      expect(s.onboardingComplete, isFalse);
      expect(s.dailyFocusGoal, 120);
      expect(s.blockedAppsPreview, isEmpty);
    });

    test('setLanguage writes SharedPreferences', () async {
      await AppState().loadPrefs();
      await AppState().setLanguage('fr');
      expect(AppState().language, 'fr');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language'), 'fr');
    });

    test('setTimerPreset persists minutes', () async {
      await AppState().loadPrefs();
      await AppState().setTimerPreset(45);
      expect(AppState().timerPreset, 45);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('timerPreset'), 45);
    });

    test('addFocusMinutes accumulates and persists', () async {
      await AppState().loadPrefs();
      await AppState().addFocusMinutes(10);
      await AppState().addFocusMinutes(5);
      expect(AppState().currentFocusMinutes, 15);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('currentFocusMinutes'), 15);
    });

    test('blocked apps preview parses active JSON entries', () async {
      final jsonList = [
        {
          'name': 'ExampleApp',
          'isEnabled': true,
          'blockStatus': 'active',
          'remainingMinutes': 12,
          'unblockTime': '18:00',
        },
        {
          'name': 'Skipped',
          'isEnabled': false,
          'blockStatus': 'active',
        },
      ];
      SharedPreferences.setMockInitialValues({
        PersistenceKeys.userBlockingApps: jsonEncode(jsonList),
      });
      AppState().resetForTests();
      await AppState().loadPrefs();

      final preview = AppState().blockedAppsPreview;
      expect(preview, hasLength(1));
      expect(preview.single.name, 'ExampleApp');
      expect(preview.single.blockedForLabel, '12m');
      expect(preview.single.unlockHint, '18:00');
    });
  });

  group('AppState i18n', () {
    test('t falls back to English for unknown key', () async {
      SharedPreferences.setMockInitialValues({'language': 'en'});
      AppState().resetForTests();
      await AppState().loadPrefs();
      expect(AppState().t('app_name'), 'Caytimer');
    });

    test('French strings for timer label', () async {
      SharedPreferences.setMockInitialValues({'language': 'fr'});
      AppState().resetForTests();
      await AppState().loadPrefs();
      expect(AppState().t('timer'), 'Minuteur');
    });
  });
}
