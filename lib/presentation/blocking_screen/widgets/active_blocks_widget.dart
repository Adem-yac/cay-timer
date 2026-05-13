import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_icon_display.dart';
import '../blocking_screen.dart';

class ActiveBlocksWidget extends StatelessWidget {
  final List<AppBlockModel> activeApps;
  final VoidCallback onUnblockAll;

  const ActiveBlocksWidget({
    super.key,
    required this.activeApps,
    required this.onUnblockAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.error.withAlpha(26),
                  AppTheme.secondaryViolet.withAlpha(15),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.error.withAlpha(51), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Currently Blocked',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onUnblockAll,
                      child: Text(
                        'Unblock All',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryPink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Access resumes when session ends',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 14),
                ...activeApps.map((app) => _ActiveBlockRow(app: app)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveBlockRow extends StatelessWidget {
  final AppBlockModel app;

  const _ActiveBlockRow({required this.app});

  String _formatMinutes(int? minutes) {
    if (minutes == null) return '--';
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m left' : '${h}h left';
    }
    return '${minutes}m left';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AppIconDisplay(
            size: 38,
            icon: app.icon,
            iconColor: app.iconColor,
            iconBytes: app.iconBytes,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatMinutes(app.remainingMinutes),
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppTheme.error.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
          // Countdown badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(31),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.error.withAlpha(64)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: AppTheme.error, size: 11),
                const SizedBox(width: 4),
                Text(
                  app.unblockTime ?? '--:--',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.error,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}