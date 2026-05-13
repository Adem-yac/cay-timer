import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum GoalStatus { pending, inProgress, completed, failed, skipped }

enum BlockStatus { active, scheduled, inactive }

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadgeWidget.goalStatus(
    GoalStatus status, {
    String? customLabel,
  }) {
    switch (status) {
      case GoalStatus.completed:
        return StatusBadgeWidget(
          label: customLabel ?? 'Completed',
          backgroundColor: const Color(0x2210B981),
          textColor: const Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        );
      case GoalStatus.inProgress:
        return StatusBadgeWidget(
          label: customLabel ?? 'In Progress',
          backgroundColor: const Color(0x223B82F6),
          textColor: const Color(0xFF3B82F6),
          icon: Icons.play_circle_rounded,
        );
      case GoalStatus.failed:
        return StatusBadgeWidget(
          label: customLabel ?? 'Failed',
          backgroundColor: const Color(0x22EF4444),
          textColor: const Color(0xFFEF4444),
          icon: Icons.cancel_rounded,
        );
      case GoalStatus.skipped:
        return StatusBadgeWidget(
          label: customLabel ?? 'Skipped',
          backgroundColor: const Color(0x22F59E0B),
          textColor: const Color(0xFFF59E0B),
          icon: Icons.skip_next_rounded,
        );
      case GoalStatus.pending:
      return StatusBadgeWidget(
          label: customLabel ?? 'Pending',
          backgroundColor: const Color(0x22FFFFFF),
          textColor: const Color(0x99FFFFFF),
          icon: Icons.radio_button_unchecked_rounded,
        );
    }
  }

  factory StatusBadgeWidget.blockStatus(BlockStatus status) {
    switch (status) {
      case BlockStatus.active:
        return StatusBadgeWidget(
          label: 'Blocked',
          backgroundColor: const Color(0x22EF4444),
          textColor: const Color(0xFFEF4444),
          icon: Icons.block_rounded,
        );
      case BlockStatus.scheduled:
        return StatusBadgeWidget(
          label: 'Scheduled',
          backgroundColor: const Color(0x22F59E0B),
          textColor: const Color(0xFFF59E0B),
          icon: Icons.schedule_rounded,
        );
      case BlockStatus.inactive:
      return StatusBadgeWidget(
          label: 'Allowed',
          backgroundColor: const Color(0x2210B981),
          textColor: const Color(0xFF10B981),
          icon: Icons.check_circle_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
