import 'package:capstone/ui/widgets/home/circular_progress_painter.dart';
import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ScoreCircularProgress extends StatefulWidget {
  const ScoreCircularProgress({super.key, required this.progressAnimation});
  final m.Animation<double> progressAnimation;

  @override
  State<ScoreCircularProgress> createState() => _ScoreCircularProgressState();
}

class _ScoreCircularProgressState extends State<ScoreCircularProgress> {
  @override
  Widget build(BuildContext context) {
    return m.Container(
      padding: const m.EdgeInsets.all(16),
      decoration: m.BoxDecoration(
        shape: m.BoxShape.circle,
        gradient: m.RadialGradient(
          colors: [
            const m.Color(0xFF8B5CF6).withOpacity(0.1),
            m.Colors.transparent,
          ],
        ),
      ),
      child: m.SizedBox(
        width: 280,
        height: 280,
        child: m.AnimatedBuilder(
          animation: widget.progressAnimation,
          builder: (context, child) {
            return m.CustomPaint(
              painter: CircularProgressPainter(
                progress: widget.progressAnimation.value,
                strokeWidth: 14,
              ),
              child: m.Center(
                child: m.Column(
                  mainAxisAlignment: m.MainAxisAlignment.center,
                  children: [
                    const m.Text(
                      "Skor Produktivitas",
                      style: m.TextStyle(
                        color: m.Colors.white70,
                        fontSize: 16,
                        fontWeight: m.FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                    const m.SizedBox(height: 12),
                    m.Text(
                      "${widget.progressAnimation.value.toStringAsFixed(0)}",
                      style: const m.TextStyle(
                        color: m.Colors.white,
                        fontSize: 72,
                        fontWeight: m.FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const m.Text(
                      "/ 100",
                      style: m.TextStyle(
                        color: m.Colors.white60,
                        fontSize: 20,
                        fontWeight: m.FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
