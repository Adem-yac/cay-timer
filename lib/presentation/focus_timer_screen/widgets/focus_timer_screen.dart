import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_state.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/caytimer_brand_header.dart';
import './blocked_apps_grid_widget.dart';
import './focus_goal_progress_widget.dart';
import './session_controls_widget.dart';
import './timer_ring_widget.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen>
    with TickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  final _appState = AppState();
  bool _isRunning = false;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChanged);
    _totalSeconds = _appState.timerPreset * 60;
    _remainingSeconds = _totalSeconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onStateChanged() => setState(() {});
  String _t(String key) => _appState.t(key);

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remainingSeconds <= 0) {
          t.cancel();
          setState(() => _isRunning = false);
        } else {
          setState(() => _remainingSeconds--);
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  void _addTime() {
    setState(() {
      _remainingSeconds += 5 * 60;
      _totalSeconds += 5 * 60;
    });
  }

  void _applyPresetMinutes(int minutes) {
    _timer?.cancel();
    _appState.setTimerPreset(minutes);
    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  String get _timeDisplay {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress =>
      _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 0.9,
                  colors: [
                    Color(0x33E91E8C),
                    Color(0x007C3AED),
                    AppTheme.darkBackground,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
          ),
        ],
      ),
      bottomNavigationBar: AppNavigation(currentIndex: 0),
    );
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: [
          _buildAppBar(),
          const SizedBox(height: 8),
          _buildSessionBadge(),
          const SizedBox(height: 24),
          TimerRingWidget(
            timeDisplay: _timeDisplay,
            progress: _progress,
            isRunning: _isRunning,
            pulseAnimation: _pulseAnimation,
            size: 260,
          ),
          const SizedBox(height: 28),
          SessionControlsWidget(
            isRunning: _isRunning,
            onToggle: _toggleTimer,
            onAddTime: _addTime,
          ),
          const SizedBox(height: 16),
          _buildPresetChips(),
          const SizedBox(height: 28),
          BlockedAppsGridWidget(isRunning: _isRunning),
          const SizedBox(height: 20),
          FocusGoalProgressWidget(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 55,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32, left: 24, right: 12),
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 12),
                _buildSessionBadge(),
                const SizedBox(height: 28),
                TimerRingWidget(
                  timeDisplay: _timeDisplay,
                  progress: _progress,
                  isRunning: _isRunning,
                  pulseAnimation: _pulseAnimation,
                  size: 320,
                ),
                const SizedBox(height: 32),
                SessionControlsWidget(
                  isRunning: _isRunning,
                  onToggle: _toggleTimer,
                  onAddTime: _addTime,
                ),
                const SizedBox(height: 16),
                _buildPresetChips(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 45,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 32,
              left: 12,
              right: 24,
              top: 80,
            ),
            child: Column(
              children: [
                BlockedAppsGridWidget(isRunning: _isRunning, columns: 3),
                const SizedBox(height: 20),
                FocusGoalProgressWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CaytimerBrandHeader(title: _t('app_name')),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.accountSettings);
            },
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white70,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChips() {
    const presets = <(String, int)>[
      ('25m', 25),
      ('30m', 30),
      ('45m', 45),
      ('1h', 60),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final p in presets)
            _PresetChip(
              label: p.$1,
              selected: _appState.timerPreset == p.$2,
              onTap: () => _applyPresetMinutes(p.$2),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionBadge() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRunning ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: _isRunning
                ? AppTheme.primaryPink.withAlpha(38)
                : Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _isRunning
                  ? AppTheme.primaryPink.withAlpha(128)
                  : Colors.white24,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _isRunning ? AppTheme.primaryPink : Colors.white38,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isRunning
                    ? _t('focus_session_active').toUpperCase()
                    : _t('session_paused').toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _isRunning ? AppTheme.primaryPink : Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppTheme.primaryPink, AppTheme.secondaryViolet],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: selected ? null : Colors.white.withAlpha(14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
