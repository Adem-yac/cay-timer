import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_state.dart';
import '../../theme/app_theme.dart';

class FocusGoalProgressWidget extends StatefulWidget {
  const FocusGoalProgressWidget({super.key});

  @override
  State<FocusGoalProgressWidget> createState() => _FocusGoalProgressWidgetState();
}

class _FocusGoalProgressWidgetState extends State<FocusGoalProgressWidget> {
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = (_appState.currentFocusMinutes / _appState.dailyFocusGoal).clamp(0.0, 1.0);

    return Semantics(
      label: '${_appState.t('daily_focus_goal')}: ${(progressValue * 100).toInt()}% complete',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(31)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPink.withAlpha(77),
                          AppTheme.secondaryViolet.withAlpha(77),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: AppTheme.primaryPink,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _appState.t('daily_focus_goal'),
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(progressValue * 100).toInt()}%',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryPink,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progressValue * 100).toInt()}% ${_appState.t('complete')} — ${_appState.t('keep_it_up')}',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.white38,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 6,
                            backgroundColor: Colors.white.withAlpha(26),
                            valueColor: const AlwaysStoppedAnimation(
                              AppTheme.primaryPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}