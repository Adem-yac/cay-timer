import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge_widget.dart';
import './goals_stats_header_widget.dart';

class GoalCardWidget extends StatefulWidget {
  final GoalModel goal;
  final int index;
  final void Function(String id) onToggleNotification;
  final void Function(String id, GoalStatus status) onStatusChange;

  const GoalCardWidget({
    super.key,
    required this.goal,
    required this.index,
    required this.onToggleNotification,
    required this.onStatusChange,
  });

  @override
  State<GoalCardWidget> createState() => _GoalCardWidgetState();
}

class _GoalCardWidgetState extends State<GoalCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 60),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
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

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final isCompleted = goal.status == GoalStatus.completed;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.success.withAlpha(20)
                    : Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.success.withAlpha(64)
                      : goal.status == GoalStatus.failed
                      ? AppTheme.error.withAlpha(51)
                      : Colors.white.withAlpha(26),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  splashColor: goal.color.withAlpha(26),
                  onTap: () => _showGoalOptions(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: goal.color.withAlpha(38),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                goal.icon,
                                color: goal.color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.title,
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: Colors.white38,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    goal.category,
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadgeWidget.goalStatus(goal.status),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          goal.description,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        // Progress
                        Row(
                          children: [
                            Text(
                              _formatMinutes(goal.completedMinutes),
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: goal.color,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            Text(
                              ' / ${_formatMinutes(goal.targetMinutes)}',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(goal.progress * 100).toInt()}%',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            minHeight: 6,
                            backgroundColor: Colors.white.withAlpha(20),
                            valueColor: AlwaysStoppedAnimation(goal.color),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => widget.onToggleNotification(goal.id),
                              child: Row(
                                children: [
                                  Icon(
                                    goal.notificationEnabled
                                        ? Icons.notifications_active_rounded
                                        : Icons.notifications_off_outlined,
                                    size: 16,
                                    color: goal.notificationEnabled
                                        ? AppTheme.primaryPink
                                        : Colors.white38,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    goal.notificationEnabled
                                        ? 'Alerts On'
                                        : 'Alerts Off',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      color: goal.notificationEnabled
                                          ? AppTheme.primaryPink
                                          : Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (goal.status != GoalStatus.completed)
                              GestureDetector(
                                onTap: () => widget.onStatusChange(
                                  goal.id,
                                  GoalStatus.completed,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withAlpha(31),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.success.withAlpha(77),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 13,
                                        color: AppTheme.success,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Mark Done',
                                        style: GoogleFonts.manrope(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withAlpha(242),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.goal.title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionTile(
                  Icons.check_circle_rounded,
                  'Mark as Completed',
                  AppTheme.success,
                  () => _handleOption(context, GoalStatus.completed),
                ),
                _buildOptionTile(
                  Icons.play_circle_rounded,
                  'Mark as In Progress',
                  AppTheme.accentBlueBright,
                  () => _handleOption(context, GoalStatus.inProgress),
                ),
                _buildOptionTile(
                  Icons.skip_next_rounded,
                  'Skip for Today',
                  AppTheme.warning,
                  () => _handleOption(context, GoalStatus.skipped),
                ),
                _buildOptionTile(
                  Icons.cancel_rounded,
                  'Mark as Failed',
                  AppTheme.error,
                  () => _handleOption(context, GoalStatus.failed),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withAlpha(31),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }

  void _handleOption(BuildContext context, GoalStatus status) {
    Navigator.pop(context);
    widget.onStatusChange(widget.goal.id, status);
  }
}
