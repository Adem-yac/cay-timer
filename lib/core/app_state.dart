import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'persistence_keys.dart';

/// Snapshot for the timer “Blocked apps” strip (no icons until list is refreshed on device).
class BlockedAppTileData {
  final String name;
  final Uint8List? iconBytes;
  final String blockedForLabel;
  final String? unlockHint;

  const BlockedAppTileData({
    required this.name,
    this.iconBytes,
    required this.blockedForLabel,
    this.unlockHint,
  });
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Language
  String _language = 'en';
  String get language => _language;

  // Timer preset (in minutes)
  int _timerPreset = 25;
  int get timerPreset => _timerPreset;

  // Onboarding
  bool _onboardingComplete = false;
  bool get onboardingComplete => _onboardingComplete;

  // Notifications enabled
  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  // App blocking permission
  bool _blockingPermissionGranted = false;
  bool get blockingPermissionGranted => _blockingPermissionGranted;

  // Notification settings
  bool _goalReminderNotif = true;
  bool get goalReminderNotif => _goalReminderNotif;

  bool _timerEndNotif = true;
  bool get timerEndNotif => _timerEndNotif;

  bool _blockingAlertNotif = true;
  bool get blockingAlertNotif => _blockingAlertNotif;

  // Goals
  int _dailyFocusGoal = 120; // minutes
  int get dailyFocusGoal => _dailyFocusGoal;

  int _currentFocusMinutes = 0;
  int get currentFocusMinutes => _currentFocusMinutes;

  List<BlockedAppTileData> _blockedAppsPreview = [];
  List<BlockedAppTileData> get blockedAppsPreview =>
      List<BlockedAppTileData>.unmodifiable(_blockedAppsPreview);

  void setBlockedAppsPreview(List<BlockedAppTileData> items) {
    _blockedAppsPreview = List<BlockedAppTileData>.from(items);
    notifyListeners();
  }

  /// Resets in-memory fields to defaults. For tests only; use with mocked
  /// [SharedPreferences] or call [loadPrefs] afterwards.
  @visibleForTesting
  void resetForTests() {
    _language = 'en';
    _timerPreset = 25;
    _onboardingComplete = false;
    _notificationsEnabled = false;
    _blockingPermissionGranted = false;
    _goalReminderNotif = true;
    _timerEndNotif = true;
    _blockingAlertNotif = true;
    _dailyFocusGoal = 120;
    _currentFocusMinutes = 0;
    _blockedAppsPreview = [];
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('language') ?? 'en';
    _timerPreset = prefs.getInt('timerPreset') ?? 25;
    _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    _blockingPermissionGranted =
        prefs.getBool('blockingPermissionGranted') ?? false;
    _goalReminderNotif = prefs.getBool('goalReminderNotif') ?? true;
    _timerEndNotif = prefs.getBool('timerEndNotif') ?? true;
    _blockingAlertNotif = prefs.getBool('blockingAlertNotif') ?? true;
    _dailyFocusGoal = prefs.getInt('dailyFocusGoal') ?? 120;
    _currentFocusMinutes = prefs.getInt('currentFocusMinutes') ?? 0;
    await _reloadBlockedAppsPreviewFromPrefs();
    notifyListeners();
  }

  Future<void> _reloadBlockedAppsPreviewFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PersistenceKeys.userBlockingApps);
    if (raw == null || raw.isEmpty) {
      _blockedAppsPreview = [];
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final next = <BlockedAppTileData>[];
      for (final e in list) {
        final m = Map<String, dynamic>.from(e as Map);
        final enabled = m['isEnabled'] == true;
        final status = m['blockStatus'] as String? ?? 'inactive';
        if (!enabled || status != 'active') continue;
        final name = m['name'] as String? ?? '';
        if (name.isEmpty) continue;
        final minutes = m['remainingMinutes'] as int? ??
            m['blockDurationMinutes'] as int? ??
            0;
        final blockedFor = minutes > 0 ? '${minutes}m' : '—';
        next.add(
          BlockedAppTileData(
            name: name,
            iconBytes: null,
            blockedForLabel: blockedFor,
            unlockHint: m['unblockTime'] as String?,
          ),
        );
      }
      _blockedAppsPreview = next;
    } catch (_) {
      _blockedAppsPreview = [];
    }
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setTimerPreset(int minutes) async {
    _timerPreset = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timerPreset', minutes);
    notifyListeners();
  }

  Future<void> setOnboardingComplete(bool value) async {
    _onboardingComplete = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setBlockingPermissionGranted(bool value) async {
    _blockingPermissionGranted = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('blockingPermissionGranted', value);
    notifyListeners();
  }

  Future<void> setGoalReminderNotif(bool value) async {
    _goalReminderNotif = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('goalReminderNotif', value);
    notifyListeners();
  }

  Future<void> setTimerEndNotif(bool value) async {
    _timerEndNotif = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('timerEndNotif', value);
    notifyListeners();
  }

  Future<void> setBlockingAlertNotif(bool value) async {
    _blockingAlertNotif = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('blockingAlertNotif', value);
    notifyListeners();
  }

  Future<void> setDailyFocusGoal(int minutes) async {
    _dailyFocusGoal = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyFocusGoal', minutes);
    notifyListeners();
  }

  Future<void> addFocusMinutes(int minutes) async {
    _currentFocusMinutes += minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentFocusMinutes', _currentFocusMinutes);
    notifyListeners();
  }

  Future<void> resetDailyProgress() async {
    _currentFocusMinutes = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentFocusMinutes', 0);
    notifyListeners();
  }

  // Translations
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'Caytimer',
      'timer': 'Timer',
      'goals': 'Goals',
      'blocking': 'Blocking',
      'settings': 'Settings',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'timer_settings': 'Timer Settings',
      'notifications': 'Notifications',
      'account': 'Account',
      'select_language': 'Select Language',
      'choose_language': 'Choose your language',
      'permissions': 'Permissions',
      'notif_permission': 'Notification Permission',
      'notif_permission_desc':
          'Allow Caytimer to send you reminders and alerts',
      'blocking_permission': 'App Blocking Permission',
      'blocking_permission_desc':
          'Allow Caytimer to block distracting apps during focus sessions',
      'grant': 'Grant',
      'granted': 'Granted',
      'continue_btn': 'Continue',
      'get_started': 'Get Started',
      'welcome': 'Welcome to Caytimer',
      'welcome_sub': 'Your productivity companion',
      'timer_preset': 'Timer Preset',
      'custom': 'Custom',
      'goal_reminders': 'Goal Reminders',
      'timer_end_alert': 'Timer End Alert',
      'blocking_alerts': 'Blocking Alerts',
      'notif_settings': 'Notification Settings',
      'schedule_blocking': 'Schedule Blocking',
      'add_schedule': 'Add Schedule',
      'blocking_rules': 'Blocking Rules',
      'start_time': 'Start Time',
      'end_time': 'End Time',
      'days': 'Days',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'french': 'French',
      'arabic': 'Arabic',
      'english': 'English',
      'theme': 'Theme',
      'appearance': 'Appearance',
      'daily_focus_goal': 'Daily Focus Goal',
      'complete': 'complete',
      'keep_it_up': 'Keep it up!',
      'add_time': 'Add Time',
      'minutes_left': 'minutes left',
      'session_paused': 'Session paused',
      'focus_session_active': 'Focus session active',
      'blocked_apps': 'Blocked Apps',
      'manage_list': 'Manage List',
      'access_resumes_25': 'Access resumes in 25 minutes',
      'session_paused_accessible': 'Session paused - apps accessible',
      'all_apps': 'All Apps',
      'apps': 'apps',
      'no_apps_found': 'No Apps Found',
      'try_different_search': 'Try a different search term.',
      'no_active_blocks': 'No Active Blocks',
      'enable_blocking_focus': 'Enable blocking for apps to protect your focus time.',
      'block_all': 'Block All',
      'unblock_all': 'Unblock All',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'add_goal': 'Add Goal',
      'blocking_android_only_title': 'Android only',
      'blocking_android_only_sub':
          'Install the app on Android to load your installed apps and block them.',
      'blocking_pull_refresh': 'Pull down to refresh the app list.',
      'no_blocked_apps_preview':
          'No apps blocked yet. Open Blocking and enable apps to block.',
    },
    'fr': {
      'app_name': 'Caytimer',
      'timer': 'Minuteur',
      'goals': 'Objectifs',
      'blocking': 'Blocage',
      'settings': 'Paramètres',
      'language': 'Langue',
      'dark_mode': 'Mode Sombre',
      'light_mode': 'Mode Clair',
      'timer_settings': 'Réglages Minuteur',
      'notifications': 'Notifications',
      'account': 'Compte',
      'select_language': 'Choisir la Langue',
      'choose_language': 'Choisissez votre langue',
      'permissions': 'Autorisations',
      'notif_permission': 'Permission Notifications',
      'notif_permission_desc':
          'Autoriser Caytimer à envoyer des rappels et alertes',
      'blocking_permission': 'Permission Blocage',
      'blocking_permission_desc':
          'Autoriser Caytimer à bloquer les apps distrayantes',
      'grant': 'Autoriser',
      'granted': 'Autorisé',
      'continue_btn': 'Continuer',
      'get_started': 'Commencer',
      'welcome': 'Bienvenue sur Caytimer',
      'welcome_sub': 'Votre compagnon de productivité',
      'timer_preset': 'Préréglage Minuteur',
      'custom': 'Personnalisé',
      'goal_reminders': 'Rappels Objectifs',
      'timer_end_alert': 'Alerte Fin Minuteur',
      'blocking_alerts': 'Alertes Blocage',
      'notif_settings': 'Paramètres Notifications',
      'schedule_blocking': 'Planifier Blocage',
      'add_schedule': 'Ajouter Horaire',
      'blocking_rules': 'Règles de Blocage',
      'start_time': 'Heure Début',
      'end_time': 'Heure Fin',
      'days': 'Jours',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'enabled': 'Activé',
      'disabled': 'Désactivé',
      'french': 'Français',
      'arabic': 'Arabe',
      'english': 'Anglais',
      'theme': 'Thème',
      'appearance': 'Apparence',
      'daily_focus_goal': 'Objectif Focus Quotidien',
      'complete': 'terminé',
      'keep_it_up': 'Continuez comme ça !',
      'add_time': 'Ajouter du temps',
      'minutes_left': 'minutes restantes',
      'session_paused': 'Session en pause',
      'focus_session_active': 'Session de focus active',
      'blocked_apps': 'Applications bloquées',
      'manage_list': 'Gérer la liste',
      'access_resumes_25': 'Accès rétabli dans 25 minutes',
      'session_paused_accessible': 'Session en pause - apps accessibles',
      'all_apps': 'Toutes les apps',
      'apps': 'apps',
      'no_apps_found': 'Aucune app trouvée',
      'try_different_search': 'Essayez un autre mot-clé.',
      'no_active_blocks': 'Aucun blocage actif',
      'enable_blocking_focus': 'Activez le blocage pour protéger votre concentration.',
      'block_all': 'Tout bloquer',
      'unblock_all': 'Tout débloquer',
      'daily': 'Quotidien',
      'weekly': 'Hebdomadaire',
      'monthly': 'Mensuel',
      'add_goal': 'Ajouter un objectif',
      'blocking_android_only_title': 'Android uniquement',
      'blocking_android_only_sub':
          'Installez l’app sur Android pour charger vos applications installées et les bloquer.',
      'blocking_pull_refresh': 'Tirez vers le bas pour actualiser la liste.',
      'no_blocked_apps_preview':
          'Aucune app bloquée. Ouvrez Blocage et activez les applications.',
    },
    'ar': {
      'app_name': 'كاي تايمر',
      'timer': 'المؤقت',
      'goals': 'الأهداف',
      'blocking': 'الحجب',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'timer_settings': 'إعدادات المؤقت',
      'notifications': 'الإشعارات',
      'account': 'الحساب',
      'select_language': 'اختر اللغة',
      'choose_language': 'اختر لغتك',
      'permissions': 'الأذونات',
      'notif_permission': 'إذن الإشعارات',
      'notif_permission_desc': 'السماح لـ Caytimer بإرسال التذكيرات والتنبيهات',
      'blocking_permission': 'إذن حجب التطبيقات',
      'blocking_permission_desc': 'السماح لـ Caytimer بحجب التطبيقات المشتتة',
      'grant': 'منح',
      'granted': 'ممنوح',
      'continue_btn': 'متابعة',
      'get_started': 'ابدأ الآن',
      'welcome': 'مرحباً بك في Caytimer',
      'welcome_sub': 'رفيقك للإنتاجية',
      'timer_preset': 'إعداد المؤقت',
      'custom': 'مخصص',
      'goal_reminders': 'تذكيرات الأهداف',
      'timer_end_alert': 'تنبيه انتهاء المؤقت',
      'blocking_alerts': 'تنبيهات الحجب',
      'notif_settings': 'إعدادات الإشعارات',
      'schedule_blocking': 'جدولة الحجب',
      'add_schedule': 'إضافة جدول',
      'blocking_rules': 'قواعد الحجب',
      'start_time': 'وقت البداية',
      'end_time': 'وقت النهاية',
      'days': 'الأيام',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'enabled': 'مفعّل',
      'disabled': 'معطّل',
      'french': 'الفرنسية',
      'arabic': 'العربية',
      'english': 'الإنجليزية',
      'theme': 'المظهر',
      'appearance': 'المظهر',
      'daily_focus_goal': 'هدف التركيز اليومي',
      'complete': 'مكتمل',
      'keep_it_up': 'استمر على هذا النحو!',
      'add_time': 'إضافة وقت',
      'minutes_left': 'دقائق متبقية',
      'session_paused': 'الجلسة متوقفة',
      'focus_session_active': 'جلسة تركيز نشطة',
      'blocked_apps': 'التطبيقات المحجوبة',
      'manage_list': 'إدارة القائمة',
      'access_resumes_25': 'سيعود الوصول خلال 25 دقيقة',
      'session_paused_accessible': 'الجلسة متوقفة - التطبيقات متاحة',
      'all_apps': 'كل التطبيقات',
      'apps': 'تطبيق',
      'no_apps_found': 'لم يتم العثور على تطبيقات',
      'try_different_search': 'جرّب كلمة بحث مختلفة.',
      'no_active_blocks': 'لا يوجد حظر نشط',
      'enable_blocking_focus': 'فعّل الحظر لحماية وقت التركيز.',
      'block_all': 'حظر الكل',
      'unblock_all': 'إلغاء حظر الكل',
      'daily': 'يومي',
      'weekly': 'أسبوعي',
      'monthly': 'شهري',
      'add_goal': 'إضافة هدف',
      'blocking_android_only_title': 'Android فقط',
      'blocking_android_only_sub':
          'ثبّت التطبيق على أندرويد لعرض التطبيقات المثبتة وحظرها.',
      'blocking_pull_refresh': 'اسحب للأسفل لتحديث القائمة.',
      'no_blocked_apps_preview':
          'لا توجد تطبيقات محظورة. افتح الحجب وفعّل التطبيقات.',
    },
  };

  String t(String key) {
    return _translations[_language]?[key] ?? _translations['en']?[key] ?? key;
  }
}