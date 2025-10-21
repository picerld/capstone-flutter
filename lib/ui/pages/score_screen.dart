import 'package:capstone/provider/nav_provider.dart';
import 'package:capstone/provider/sleep_provider.dart';
import 'package:capstone/ui/widgets/bottom_nav.dart';
import 'package:capstone/ui/widgets/quality_label.dart';
import 'package:capstone/ui/widgets/score/score_circular_progress.dart';
import 'package:capstone/utils/time_utils.dart';
import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with m.TickerProviderStateMixin {
  late m.AnimationController _progressController;
  late m.AnimationController _contentController;
  late m.Animation<double> _progressAnimation;
  late m.Animation<double> _slideAnimation;
  late m.Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = m.AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _contentController = m.AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = m.Tween<double>(begin: 50, end: 0).animate(
      m.CurvedAnimation(
        parent: _contentController,
        curve: m.Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = m.Tween<double>(begin: 0, end: 1).animate(
      m.CurvedAnimation(parent: _contentController, curve: m.Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<SleepProvider>();

      // Load data first
      await provider.loadData();

      await _updateProgress(provider);

      // Start content animation
      _contentController.forward();
    });
  }

  Future<void> _updateProgress(SleepProvider provider) async {
    if (!mounted) return;

    final qualityPercent = await provider.calculateQuality();

    setState(() {
      _progressAnimation = Tween<double>(begin: 0, end: qualityPercent).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
      );
    });

    _progressController.forward(from: 0);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    final navProvider = Provider.of<NavProvider>(context);

    return Consumer<SleepProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            child: m.Container(
              decoration: const m.BoxDecoration(
                gradient: m.LinearGradient(
                  begin: m.Alignment.topCenter,
                  end: m.Alignment.bottomCenter,
                  colors: [
                    m.Color(0xFF0A0118),
                    m.Color(0xFF1A0B2E),
                    m.Color(0xFF0A0118),
                  ],
                ),
              ),
              child: m.Center(
                child: m.Column(
                  mainAxisAlignment: m.MainAxisAlignment.center,
                  children: [
                    m.Container(
                      padding: const m.EdgeInsets.all(20),
                      decoration: m.BoxDecoration(
                        shape: m.BoxShape.circle,
                        boxShadow: [
                          m.BoxShadow(
                            color: const m.Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const m.CircularProgressIndicator(
                        color: m.Color(0xFF8B5CF6),
                        strokeWidth: 3,
                      ),
                    ),
                    const m.SizedBox(height: 24),
                    const m.Text(
                      'Menganalisis tidurmu...',
                      style: m.TextStyle(
                        color: m.Colors.white70,
                        fontSize: 16,
                        fontWeight: m.FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          floatingHeader: true,
          floatingFooter: true,
          footers: [
            ShadcnBottomNav(
              currentIndex: navProvider.index,
              onTap: (i) => navProvider.setIndex(context, i),
            ),
          ],
          child: m.Container(
            decoration: const m.BoxDecoration(
              gradient: m.LinearGradient(
                begin: m.Alignment.topCenter,
                end: m.Alignment.bottomCenter,
                colors: [
                  m.Color(0xFF0A0118),
                  m.Color(0xFF1A0B2E),
                  m.Color(0xFF0A0118),
                ],
              ),
            ),
            child: m.SafeArea(
              child: m.SingleChildScrollView(
                physics: const m.BouncingScrollPhysics(),
                child: m.Padding(
                  padding: const m.EdgeInsets.all(24),
                  child: m.AnimatedBuilder(
                    animation: _contentController,
                    builder: (context, child) {
                      return m.Transform.translate(
                        offset: m.Offset(0, _slideAnimation.value),
                        child: m.Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: m.Column(
                      children: [
                        _buildHeader(),
                        const m.SizedBox(height: 32),

                        ScoreCircularProgress(
                          progressAnimation: _progressAnimation,
                        ),
                        const m.SizedBox(height: 30),

                        // _buildLegendRow(),
                        // const m.SizedBox(height: 40),
                        const QualityLabel(),
                        const m.SizedBox(height: 40),

                        _buildStatsCards(provider),
                        const m.SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  m.Widget _buildHeader() {
    return m.Column(
      children: [
        m.Container(
          padding: const m.EdgeInsets.all(16),
          decoration: m.BoxDecoration(
            shape: m.BoxShape.circle,
            gradient: m.LinearGradient(
              colors: [
                const m.Color(0xFF8B5CF6).withOpacity(0.2),
                const m.Color(0xFF06B6D4).withOpacity(0.2),
              ],
            ),
          ),
          child: const m.Icon(
            m.Icons.nightlight_round,
            color: m.Color(0xFF8B5CF6),
            size: 32,
          ),
        ),
        const m.SizedBox(height: 16),
        const m.Text(
          'Hasil Analisis Tidur',
          style: m.TextStyle(
            color: m.Colors.white,
            fontSize: 24,
            fontWeight: m.FontWeight.bold,
          ),
        ),
        const m.SizedBox(height: 8),
        m.Text(
          'Laporan kualitas tidur malam ini',
          style: m.TextStyle(
            color: m.Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  m.Widget _buildLegendRow() {
    return m.Container(
      padding: const m.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: m.BoxDecoration(
        color: m.Colors.white.withOpacity(0.05),
        borderRadius: m.BorderRadius.circular(16),
        border: m.Border.all(color: m.Colors.white.withOpacity(0.1)),
      ),
      child: m.Row(
        mainAxisAlignment: m.MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem("Deep Sleep", const m.Color(0xFF8B5CF6)),
          m.Container(
            width: 1,
            height: 30,
            color: m.Colors.white.withOpacity(0.2),
          ),
          _buildLegendItem("Light Sleep", const m.Color(0xFF06B6D4)),
        ],
      ),
    );
  }

  m.Widget _buildLegendItem(String label, m.Color color) {
    return m.Row(
      children: [
        m.Container(
          width: 12,
          height: 12,
          decoration: m.BoxDecoration(
            color: color,
            shape: m.BoxShape.circle,
            boxShadow: [
              m.BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const m.SizedBox(width: 12),
        m.Text(
          label,
          style: const m.TextStyle(
            color: m.Colors.white,
            fontSize: 16,
            fontWeight: m.FontWeight.w500,
          ),
        ),
      ],
    );
  }

  m.Widget _buildStatsCards(SleepProvider provider) {
    return m.Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: m.Icons.access_time,
            label: 'Durasi',
            value: formatDurationFromMinutes(provider.weeklyAverageDuration),
            color: const m.Color(0xFF06B6D4),
          ),
        ),
        const m.SizedBox(width: 16),
        Expanded(
          child: m.AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return _buildStatCard(
                icon: m.Icons.hotel,
                label: 'Kualitas',
                value: "${_progressAnimation.value.toStringAsFixed(0)}",
                color: const m.Color(0xFF8B5CF6),
              );
            },
          ),
        ),
      ],
    );
  }

  m.Widget _buildStatCard({
    required m.IconData icon,
    required String label,
    required String value,
    required m.Color color,
  }) {
    return m.Container(
      padding: const m.EdgeInsets.all(20),
      decoration: m.BoxDecoration(
        gradient: m.LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: m.Alignment.topLeft,
          end: m.Alignment.bottomRight,
        ),
        borderRadius: m.BorderRadius.circular(20),
        border: m.Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.start,
        children: [
          m.Container(
            padding: const m.EdgeInsets.all(10),
            decoration: m.BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: m.BorderRadius.circular(12),
            ),
            child: m.Icon(icon, color: color, size: 20),
          ),
          const m.SizedBox(height: 12),
          m.Text(
            label,
            style: m.TextStyle(
              color: m.Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: m.FontWeight.w500,
            ),
          ),
          const m.SizedBox(height: 4),
          m.Text(
            value,
            style: const m.TextStyle(
              color: m.Colors.white,
              fontSize: 24,
              fontWeight: m.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
