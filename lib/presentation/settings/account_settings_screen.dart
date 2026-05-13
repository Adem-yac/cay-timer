import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_state.dart';
import '../theme/app_theme.dart';
import '../blocking_screen/widgets/blocking_schedule_widget.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _appState = AppState();
  late String _language;
  late int _timerPreset;
  late bool _notifEnabled;
  late bool _goalReminderNotif;
  late bool _timerEndNotif;
  late bool _blockingAlertNotif;
  int? _customMinutes;
  final _customController = TextEditingController();

  final _presets = [15, 25, 45, 60];

  @override
  void initState() {
    super.initState();
    _language = _appState.language;
    _timerPreset = _appState.timerPreset;
    _notifEnabled = _appState.notificationsEnabled;
    _goalReminderNotif = _appState.goalReminderNotif;
    _timerEndNotif = _appState.timerEndNotif;
    _blockingAlertNotif = _appState.blockingAlertNotif;
    if (!_presets.contains(_timerPreset)) {
      _customMinutes = _timerPreset;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  String _t(String key) => _appState.t(key);

  void _setLanguage(String lang) async {
    await _appState.setLanguage(lang);
    setState(() => _language = lang);
  }

  void _setTimerPreset(int minutes) async {
    await _appState.setTimerPreset(minutes);
    setState(() {
      _timerPreset = minutes;
      _customMinutes = null;
    });
  }

  void _showCustomTimerDialog() {
    _customController.text = _customMinutes?.toString() ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _t('custom'),
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: _customController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Minutes (1-180)',
            hintStyle: GoogleFonts.manrope(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withAlpha(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryPink),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _t('cancel'),
              style: GoogleFonts.manrope(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(_customController.text);
              if (val != null && val >= 1 && val <= 180) {
                _appState.setTimerPreset(val);
                setState(() {
                  _timerPreset = val;
                  _customMinutes = val;
                });
                Navigator.pop(ctx);
              }
            },
            child: Text(
              _t('save'),
              style: GoogleFonts.manrope(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final bg = theme.scaffoldBackgroundColor;
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.colorScheme.surface.withAlpha(isDarkTheme ? 40 : 235);
    final borderColor = theme.colorScheme.outline.withAlpha(isDarkTheme ? 120 : 180);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.5),
                  radius: 0.8,
                  colors: [
                    AppTheme.primaryPink.withAlpha(isDarkTheme ? 40 : 26),
                    bg,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(onSurface, cardColor, borderColor),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildSectionHeader(_t('notif_settings')),
                        _buildNotifSection(),
                        const SizedBox(height: 24),
                        _buildSectionHeader(_t('schedule_blocking')),
                        const BlockingScheduleWidget(),
                        const SizedBox(height: 24),
                        _buildSectionHeader(_t('language')),
                        _buildLanguageSection(),
                        const SizedBox(height: 24),
                        _buildSectionHeader(_t('timer_settings')),
                        _buildTimerSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Color onSurface, Color cardColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: onSurface,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _t('settings'),
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryPink,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.colorScheme.surface.withAlpha(isDarkTheme ? 40 : 235);
    final borderColor = theme.colorScheme.outline.withAlpha(isDarkTheme ? 120 : 180);

    final langs = [
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: langs.asMap().entries.map((entry) {
              final i = entry.key;
              final lang = entry.value;
              final isSelected = _language == lang['code'];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () => _setLanguage(lang['code']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Text(
                            lang['flag']!,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            lang['name']!,
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.primaryPink
                                  : onSurface,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.primaryPink,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (i < langs.length - 1)
                    Divider(height: 1, color: Colors.white12),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final cardColor = theme.colorScheme.surface.withAlpha(isDarkTheme ? 40 : 235);
    final borderColor = theme.colorScheme.outline.withAlpha(isDarkTheme ? 120 : 180);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('timer_preset'),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ..._presets.map(
                      (min) => _buildPresetChip(min, _formatPreset(min)),
                    ),
                    _buildCustomChip(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPreset(int min) {
    if (min == 60) return '1h';
    return '${min}min';
  }

  Widget _buildPresetChip(int minutes, String label) {
    final isSelected = _timerPreset == minutes && _customMinutes == null;
    return GestureDetector(
      onTap: () => _setTimerPreset(minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPink : Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPink : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip() {
    final isSelected = _customMinutes != null;
    return GestureDetector(
      onTap: _showCustomTimerDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.secondaryViolet
              : Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.secondaryViolet : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSelected ? '${_customMinutes}min' : _t('custom'),
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.edit_rounded,
              size: 14,
              color: isSelected ? Colors.white : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifSection() {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final cardColor = theme.colorScheme.surface.withAlpha(isDarkTheme ? 40 : 235);
    final borderColor = theme.colorScheme.outline.withAlpha(isDarkTheme ? 120 : 180);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildNotifToggle(
                icon: Icons.notifications_active_rounded,
                iconColor: AppTheme.primaryPink,
                title: _t('notifications'),
                subtitle: 'Master notifications toggle',
                value: _notifEnabled,
                onChanged: (val) async {
                  await _appState.setNotificationsEnabled(val);
                  setState(() => _notifEnabled = val);
                },
              ),
              Divider(height: 1, color: Colors.white12),
              _buildNotifToggle(
                icon: Icons.flag_rounded,
                iconColor: AppTheme.accentBlueBright,
                title: _t('goal_reminders'),
                subtitle: 'Reminders for your daily goals',
                value: _goalReminderNotif && _notifEnabled,
                onChanged: _notifEnabled
                    ? (val) async {
                        await _appState.setGoalReminderNotif(val);
                        setState(() => _goalReminderNotif = val);
                      }
                    : null,
              ),
              Divider(height: 1, color: Colors.white12),
              _buildNotifToggle(
                icon: Icons.timer_rounded,
                iconColor: AppTheme.secondaryViolet,
                title: _t('timer_end_alert'),
                subtitle: 'Alert when focus session ends',
                value: _timerEndNotif && _notifEnabled,
                onChanged: _notifEnabled
                    ? (val) async {
                        await _appState.setTimerEndNotif(val);
                        setState(() => _timerEndNotif = val);
                      }
                    : null,
              ),
              Divider(height: 1, color: Colors.white12),
              _buildNotifToggle(
                icon: Icons.block_rounded,
                iconColor: AppTheme.warning,
                title: _t('blocking_alerts'),
                subtitle: 'Alerts for app blocking events',
                value: _blockingAlertNotif && _notifEnabled,
                onChanged: _notifEnabled
                    ? (val) async {
                        await _appState.setBlockingAlertNotif(val);
                        setState(() => _blockingAlertNotif = val);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifToggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final isDisabled = onChanged == null;
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.primaryPink,
              activeTrackColor: AppTheme.primaryPink.withAlpha(80),
              inactiveThumbColor: Colors.white38,
              inactiveTrackColor: Colors.white12,
            ),
          ],
        ),
      ),
    );
  }
}
