import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_state.dart';
import '../../theme/app_theme.dart';

class TimerRingWidget extends StatelessWidget {
  final String timeDisplay;
  final double progress;
  final bool isRunning;
  final Animation<double> pulseAnimation;
  final double size;

  const TimerRingWidget({
    super.key,
    required this.timeDisplay,
    required this.progress,
    required this.isRunning,
    required this.pulseAnimation,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppState().t;
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            CustomPaint(
              size: Size(size, size),
              painter: _GlowRingPainter(
                progress: progress,
                isRunning: isRunning,
              ),
            ),
            // Inner content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isRunning ? pulseAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: Text(
                    timeDisplay,
                    style: GoogleFonts.manrope(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t('minutes_left').toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white38,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowRingPainter extends CustomPainter {
  final double progress;
  final bool isRunning;

  _GlowRingPainter({required this.progress, required this.isRunning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const strokeWidth = 10.0;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Inner dark circle background
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1A2E).withAlpha(204)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (progress <= 0) return;

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * progress,
        colors: isRunning
            ? [
                AppTheme.primaryPink,
                AppTheme.secondaryViolet,
                AppTheme.primaryPink,
              ]
            : [Colors.white38, Colors.white60],
        stops: isRunning ? const [0.0, 0.5, 1.0] : const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Glow effect at progress end
    if (isRunning && progress > 0) {
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      final glowPaint = Paint()
        ..color = AppTheme.primaryPink.withAlpha(153)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(dotX, dotY), 8, glowPaint);

      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_GlowRingPainter old) =>
      old.progress != progress || old.isRunning != isRunning;
}