import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:caytimer/core/app_state.dart';
import 'package:caytimer/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MyApp shows main shell when onboarding is complete', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'onboardingComplete': true,
      'language': 'en',
    });
    AppState().resetForTests();
    await AppState().loadPrefs();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    // Avoid pumpAndSettle: focus screen uses a repeating animation.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Goals'), findsOneWidget);
  });

  testWidgets('MyApp starts at language selection when onboarding incomplete', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'onboardingComplete': false,
      'language': 'en',
    });
    AppState().resetForTests();
    await AppState().loadPrefs();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Choose your language'), findsOneWidget);
  });
}
