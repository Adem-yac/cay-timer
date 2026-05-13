import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_icon_display.dart';
import '../../widgets/status_badge_widget.dart';
import '../blocking_screen.dart';

class AppBlockListWidget extends StatelessWidget {
  final List<AppBlockModel> apps;
  final void Function(String id) onToggle;
  final void Function(AppBlockModel app) onDurationTap;

  const AppBlockListWidget({
    super.key,
    required this.apps,
    required this.onToggle,
    required this.onDurationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, i) {
        final app = apps[i];
        return _AppBlockItem(
          app: app,
          index: i,
          onToggle: () => onToggle(app.id),
          onDurationTap: () => onDurationTap(app),
        );
      }, childCount: apps.length),
    );
  }
}

class _AppBlockItem extends StatefulWidget {
  final AppBlockModel app;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDurationTap;

  const _AppBlockItem({
    required this.app,
    required this.index,
    required this.onToggle,
    required this.onDurationTap,
  });

  @override
  State<_AppBlockItem> createState() => _AppBlockItemState();
}

class _AppBlockItemState extends State<_AppBlockItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.index * 50),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final isActive = app.blockStatus == BlockStatus.active;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dismissible(
          key: Key(app.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.block_rounded,
                  color: AppTheme.error,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  'Block',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (_) async {
            widget.onToggle();
            return false;
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.error.withAlpha(15)
                  : Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? AppTheme.error.withAlpha(51)
                    : Colors.white.withAlpha(20),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: app.iconColor.withAlpha(20),
                onTap: widget.onDurationTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // App icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: app.iconColor.withAlpha(38),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: AppIconDisplay(
                                size: 40,
                                icon: app.icon,
                                iconColor: app.iconColor,
                                iconBytes: app.iconBytes,
                              ),
                            ),
                            if (isActive)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppTheme.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.darkBackground,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  app.name,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadgeWidget.blockStatus(app.blockStatus),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  app.category,
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    color: Colors.white38,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '·',
                                  style: TextStyle(color: Colors.white24),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: widget.onDurationTap,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 11,
                                        color: isActive
                                            ? AppTheme.primaryPink
                                            : Colors.white38,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        _formatDuration(
                                          app.blockDurationMinutes,
                                        ),
                                        style: GoogleFonts.manrope(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isActive
                                              ? AppTheme.primaryPink
                                              : Colors.white38,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (app.unblockTime != null) ...[
                                  const SizedBox(width: 8),
                                  const Text(
                                    '·',
                                    style: TextStyle(color: Colors.white24),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Until ${app.unblockTime}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      color: AppTheme.error.withAlpha(179),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: app.isEnabled,
                        onChanged: (_) => widget.onToggle(),
                        activeThumbColor: AppTheme.primaryPink,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}