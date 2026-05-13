import 'package:flutter/material.dart';

import '../blocking_screen/blocking_screen.dart';
import '../focus_timer_screen/widgets/focus_timer_screen.dart';
import '../goals_screen/widgets/goals_stats_header_widget.dart';
import '../onboarding/language_selection_screen.dart';
import '../onboarding/permissions_onboarding_screen.dart';
import '../settings/account_settings_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String languageSelection = '/language-selection';
  static const String permissionsOnboarding = '/permissions-onboarding';
  static const String goalsScreen = '/goals-screen';
  static const String focusTimerScreen = '/focus-timer-screen';
  static const String blockingScreen = '/blocking-screen';
  static const String accountSettings = '/account-settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LanguageSelectionScreen(),
    languageSelection: (context) => const LanguageSelectionScreen(),
    permissionsOnboarding: (context) => const PermissionsOnboardingScreen(),
    goalsScreen: (context) => const GoalsScreen(),
    focusTimerScreen: (context) => const FocusTimerScreen(),
    blockingScreen: (context) => const BlockingScreen(),
    accountSettings: (context) => const AccountSettingsScreen(),
  };
}
