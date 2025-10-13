import 'package:capstone/provider/nav_provider.dart';
import 'package:capstone/provider/sleep_provider.dart';
import 'package:capstone/theme.dart';
import 'package:capstone/ui/widgets/bottom_nav.dart';
import 'package:capstone/ui/widgets/header_with_greeting.dart';
import 'package:capstone/ui/widgets/home/circular_progress_painter.dart';
import 'package:capstone/ui/widgets/home/time_card.dart';
import 'package:capstone/utils/time_utils.dart';
import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with m.TickerProviderStateMixin {
  late m.AnimationController _progressController;
  late m.Animation<double> _progressAnimation;

  late m.AnimationController _contentController;
  late m.Animation<double> _slideAnimation;
  late m.Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = m.AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepProvider>().loadData().then((_) {
        _updateProgress();
        _contentController.forward();
      });
    });
  }

  void _updateProgress() {
    final provider = context.read<SleepProvider>();
    final quality = provider.calculateQuality();
    _progressAnimation = m.Tween<double>(begin: 0, end: quality).animate(
      m.CurvedAnimation(parent: _progressController, curve: m.Curves.easeInOut),
    );
    _progressController.forward(from: 0);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> pickTime({required bool isSleepTime}) async {
    final provider = context.read<SleepProvider>();

    final m.TimeOfDay? picked = await m.showTimePicker(
      context: context,
      initialTime: m.TimeOfDay.now(),
      builder: (context, child) {
        return m.Theme(
          data: m.Theme.of(context).copyWith(
            colorScheme: const m.ColorScheme.dark(
              primary: m.Color(0xFF8B5CF6),
              onPrimary: m.Colors.white,
              surface: m.Color(0xFF1A0B2E),
              onSurface: m.Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isSleepTime) {
        provider.setJamTidur(picked);
      } else {
        provider.setJamBangun(picked);
      }

      if (provider.jamTidur != null && provider.jamBangun != null) {
        if (mounted) {
          m.ScaffoldMessenger.of(context).showSnackBar(
            const m.SnackBar(
              content: m.Text('Sleep record saved successfully!'),
              backgroundColor: m.Color(0xFF8B5CF6),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      _updateProgress();
    }
  }

  @override
  m.Widget build(m.BuildContext context) {
    final navProvider = Provider.of<NavProvider>(context);

    return Consumer<SleepProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return m.Scaffold(
            body: m.Container(
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
                  mainAxisSize: m.MainAxisSize.min,
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
                      'Memuat data...',
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

        final duration = provider.calculateDuration();

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
                      crossAxisAlignment: m.CrossAxisAlignment.start,
                      children: [
                        const m.SizedBox(height: 32),

                        HeaderWithGreeting(),

                        const SizedBox(height: 32),

                        m.Row(
                          children: [
                            m.Expanded(
                              child: TimeCard(
                                title: "Going to bed",
                                subtitle: "Jam Tidur",
                                time: provider.jamTidur,
                                icon: m.Icons.bedtime,
                                gradientColors: const [
                                  AppTheme.primaryColor,
                                  AppTheme.deepPrimary,
                                ],
                                onTap: () => pickTime(isSleepTime: true),
                              ),
                            ),
                            const m.SizedBox(width: 16),
                            m.Expanded(
                              child: TimeCard(
                                title: "Waking up",
                                subtitle: "Waktu Bangun",
                                time: provider.jamBangun,
                                icon: m.Icons.wb_sunny_outlined,
                                gradientColors: const [
                                  AppTheme.secondaryColor,
                                  AppTheme.deepSecondary,
                                ],
                                onTap: () => pickTime(isSleepTime: false),
                              ),
                            ),
                          ],
                        ),

                        const m.SizedBox(height: 40),

                        Button(
                          onPressed: () {
                            provider.loadData().then((_) => _updateProgress());
                          },
                          style: const ButtonStyle.outline().withBorder(
                            border: m.Border.all(
                              color: m.Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.loader,
                                size: 23,
                                color: Colors.white,
                              ),
                              const Text(
                                "Hitung Skor",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        const m.SizedBox(height: 40),

                        m.Center(
                          child: m.Column(
                            children: [
                              m.SizedBox(
                                width: 200,
                                height: 200,
                                child: m.AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, child) {
                                    return m.CustomPaint(
                                      painter: CircularProgressPainter(
                                        progress: _progressAnimation.value,
                                        strokeWidth: 12,
                                      ),
                                      child: m.Center(
                                        child: m.Column(
                                          mainAxisAlignment:
                                          m.MainAxisAlignment.center,
                                          children: [
                                            const m.Text(
                                              "Skor Tidur",
                                              style: m.TextStyle(
                                                color: m.Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const m.SizedBox(height: 8),
                                            m.Text(
                                              "${(_progressAnimation.value * 100).toInt()}%",
                                              style: const m.TextStyle(
                                                color: m.Colors.white,
                                                fontSize: 48,
                                                fontWeight: m.FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const m.SizedBox(height: 24),
                              m.Row(
                                mainAxisAlignment: m.MainAxisAlignment.center,
                                children: [
                                  _buildLegend(
                                    "Deep Sleep",
                                    const m.Color(0xFF8B5CF6),
                                  ),
                                  const m.SizedBox(width: 32),
                                  _buildLegend(
                                    "Light Sleep",
                                    const m.Color(0xFF06B6D4),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const m.SizedBox(height: 32),

                        m.Container(
                          padding: const m.EdgeInsets.all(20),
                          decoration: m.BoxDecoration(
                            color: m.Colors.white.withValues(alpha: 0.05),
                            borderRadius: m.BorderRadius.circular(20),
                            border: m.Border.all(
                              color: m.Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: m.Row(
                            children: [
                              m.Container(
                                padding: const m.EdgeInsets.all(12),
                                decoration: m.BoxDecoration(
                                  gradient: const m.LinearGradient(
                                    colors: [
                                      m.Color(0xFF8B5CF6),
                                      m.Color(0xFF6366F1),
                                    ],
                                  ),
                                  borderRadius: m.BorderRadius.circular(12),
                                ),
                                child: const m.Icon(
                                  m.Icons.alarm,
                                  color: m.Colors.white,
                                  size: 28,
                                ),
                              ),
                              const m.SizedBox(width: 16),
                              m.Expanded(
                                child: m.Column(
                                  crossAxisAlignment: m.CrossAxisAlignment.start,
                                  children: [
                                    const m.Text(
                                      "Asleep",
                                      style: m.TextStyle(
                                        color: m.Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const m.SizedBox(height: 4),
                                    m.Text(
                                      formatTime(provider.jamTidur),
                                      style: const m.TextStyle(
                                        color: m.Colors.white,
                                        fontSize: 20,
                                        fontWeight: m.FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              m.Column(
                                crossAxisAlignment: m.CrossAxisAlignment.end,
                                children: [
                                  const m.Text(
                                    "Time to Sleep",
                                    style: m.TextStyle(
                                      color: m.Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const m.SizedBox(height: 4),
                                  m.Text(
                                    formatDuration(duration),
                                    style: const m.TextStyle(
                                      color: m.Colors.white,
                                      fontSize: 20,
                                      fontWeight: m.FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const m.SizedBox(height: 32),

                        m.Row(
                          mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
                          children: [
                            const m.Text(
                              "Weekly Status",
                              style: m.TextStyle(
                                color: m.Colors.white,
                                fontSize: 20,
                                fontWeight: m.FontWeight.bold,
                              ),
                            ),
                            m.Text(
                              "${provider.weeklyRecords.length} records",
                              style: const m.TextStyle(
                                color: m.Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const m.SizedBox(height: 16),

                        m.Container(
                          padding: const m.EdgeInsets.all(20),
                          decoration: m.BoxDecoration(
                            color: m.Colors.white,
                            borderRadius: m.BorderRadius.circular(20),
                          ),
                          child: m.Column(
                            children: [
                              m.Row(
                                mainAxisAlignment:
                                m.MainAxisAlignment.spaceBetween,
                                children: [
                                  const m.Text(
                                    "Time in bed",
                                    style: m.TextStyle(
                                      color: m.Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  m.Row(
                                    children: [
                                      m.Text(
                                        formatDurationFromMinutes(
                                          provider.weeklyAverageDuration,
                                        ),
                                        style: const m.TextStyle(
                                          color: m.Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const m.SizedBox(width: 16),
                                      m.Text(
                                        formatDuration(duration),
                                        style: const m.TextStyle(
                                          color: m.Colors.black87,
                                          fontSize: 14,
                                          fontWeight: m.FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const m.SizedBox(height: 12),
                              m.Container(
                                height: 8,
                                decoration: m.BoxDecoration(
                                  borderRadius: m.BorderRadius.circular(4),
                                  color: m.Colors.grey.shade200,
                                ),
                                child: m.FractionallySizedBox(
                                  alignment: m.Alignment.centerLeft,
                                  widthFactor: duration != null
                                      ? math.min(duration.inMinutes / 540, 1.0)
                                      : 0.0,
                                  child: m.Container(
                                    decoration: m.BoxDecoration(
                                      borderRadius: m.BorderRadius.circular(4),
                                      gradient: const m.LinearGradient(
                                        colors: [
                                          m.Color(0xFF06B6D4),
                                          m.Color(0xFF8B5CF6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const m.SizedBox(height: 24),
                              m.SizedBox(
                                width: double.infinity,
                                child: m.ElevatedButton(
                                  onPressed: () {
                                    m.Navigator.pushReplacementNamed(
                                      context,
                                      '/dashboard',
                                    );
                                  },
                                  style: m.ElevatedButton.styleFrom(
                                    backgroundColor: const m.Color(0xFF8B5CF6),
                                    foregroundColor: m.Colors.white,
                                    padding: const m.EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: m.RoundedRectangleBorder(
                                      borderRadius: m.BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: m.Row(
                                    mainAxisAlignment: m.MainAxisAlignment.center,
                                    children: [
                                      const m.Icon(
                                        m.Icons.home_outlined,
                                        size: 20,
                                      ),
                                      const m.SizedBox(width: 8),
                                      const m.Text(
                                        "Back to Home",
                                        style: m.TextStyle(
                                          fontSize: 16,
                                          fontWeight: m.FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  m.Widget _buildLegend(String label, m.Color color) {
    return m.Row(
      children: [
        m.Container(
          width: 8,
          height: 8,
          decoration: m.BoxDecoration(color: color, shape: m.BoxShape.circle),
        ),
        const m.SizedBox(width: 8),
        m.Text(
          label,
          style: const m.TextStyle(color: m.Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
