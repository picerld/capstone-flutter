import 'package:flutter/material.dart' as m;
import 'dart:math' as math;

class CircularProgressPainter extends m.CustomPainter {
  final double progress; // Expects 0-100 (percentage)
  final double strokeWidth;

  CircularProgressPainter({required this.progress, this.strokeWidth = 12});

  @override
  void paint(m.Canvas canvas, m.Size size) {
    final center = m.Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = m.Paint()
      ..color = m.Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = strokeWidth
      ..style = m.PaintingStyle.stroke
      ..strokeCap = m.StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Convert percentage (0-100) to fraction (0-1)
    final normalizedProgress = (progress / 100.0).clamp(0.0, 1.0);

    // Only draw progress arc if there's actual progress
    if (normalizedProgress > 0) {
      // Gradient progress
      final rect = m.Rect.fromCircle(center: center, radius: radius);
      final gradient = m.SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 2 * math.pi - math.pi / 2,
        colors: [
          const m.Color(0xFF8B5CF6), // Purple
          const m.Color(0xFF06B6D4), // Cyan
          const m.Color(0xFF8B5CF6), // Purple
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final progressPaint = m.Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = m.PaintingStyle.stroke
        ..strokeCap = m.StrokeCap.round;

      // Draw arc based on normalized progress (0-1)
      canvas.drawArc(
        rect,
        -math.pi / 2, // Start at top
        2 * math.pi * normalizedProgress, // Sweep angle based on progress
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
