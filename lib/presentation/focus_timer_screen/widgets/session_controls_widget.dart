import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_state.dart';
import '../../theme/app_theme.dart';

class SessionControlsWidget extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onAddTime;

  const SessionControlsWidget({
    super.key,
    required this.isRunning,
    required this.onToggle,
    required this.onAddTime,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppState().t;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pause/Play button
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(31),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  key: ValueKey(isRunning),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Add Time button
          GestureDetector(
            onTap: onAddTime,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 36),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryPink, AppTheme.secondaryViolet],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withAlpha(102),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t('add_time'),
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}