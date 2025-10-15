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

class _HomeScreenState extends m.State<HomeScreen>
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

    _progressAnimation = m.Tween<double>(begin: 0, end: 0).animate(
      m.CurvedAnimation(parent: _progressController, curve: m.Curves.easeInOut),
    );

    m.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepProvider>().loadData().then((_) {
        if (mounted) {
          _updateProgress();
          _contentController.forward();
        }
      });
    });
  }

  void _updateProgress() {
    final provider = context.read<SleepProvider>();
    final quality = provider.calculateQuality();
    setState(() {
      _progressAnimation = m.Tween<double>(begin: 0, end: quality).animate(
        m.CurvedAnimation(
            parent: _progressController, curve: m.Curves.easeInOut),
      );
      _progressController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
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
      if (mounted) {
        await provider.saveSleepRecord();
        _updateProgress();
      }
    }
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

                        const m.SizedBox(height: 35),
                        // ## KODE FITUR STRES ADA DI SINI ##
                        StressInputCard(
                          stressLevel: provider.stressLevel,
                          onChanged: (value) {
                            provider.setStressLevel(value);
                            _updateProgress();
                          },
                        ),
                        const m.SizedBox(height: 50),
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
                                            const m.Text("Quality",
                                                style: m.TextStyle(
                                                    color: m.Colors.white70,
                                                    fontSize: 14)),
                                            const m.SizedBox(height: 8),
                                            m.Text(
                                              "${(_progressAnimation.value * 100).toInt()}%",
                                              style: const m.TextStyle(
                                                  color: m.Colors.white,
                                                  fontSize: 48,
                                                  fontWeight: m.FontWeight.bold),
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
                                      "Deep Sleep", const m.Color(0xFF8B5CF6)),
                                  const m.SizedBox(width: 32),
                                  _buildLegend(
                                      "Light Sleep", const m.Color(0xFF06B6D4)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const m.SizedBox(height: 45),

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

                        const m.SizedBox(height: 32)
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
}

class StressInputCard extends m.StatelessWidget {
  const StressInputCard({
    super.key,
    required this.stressLevel,
    required this.onChanged,
  });

  final int stressLevel;
  final m.ValueChanged<int> onChanged;

  m.Widget _buildStressIcon(int level, m.Color color) {
    m.IconData iconData;
    switch (level) {
      case 1:
        iconData = m.Icons.sentiment_very_satisfied;
        break;
      case 2:
        iconData = m.Icons.sentiment_satisfied;
        break;
      case 3:
        iconData = m.Icons.sentiment_neutral;
        break;
      case 4:
        iconData = m.Icons.sentiment_dissatisfied;
        break;
      default:
        iconData = m.Icons.sentiment_very_dissatisfied;
    }
    return m.Icon(iconData, color: color, size: 30);
  }

  @override
  m.Widget build(m.BuildContext context) {
    const stressColors = [
      m.Colors.green,
      m.Colors.lightGreen,
      m.Colors.yellow,
      m.Colors.orange,
      m.Colors.red,
    ];

    return m.Container(
      padding: const m.EdgeInsets.all(20),
      decoration: m.BoxDecoration(
        color: m.Colors.white.withOpacity(0.05),
        borderRadius: m.BorderRadius.circular(20),
        border: m.Border.all(color: m.Colors.white.withOpacity(0.1)),
      ),
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.start,
        children: [
          const m.Text(
            "Tingkat Stres Hari Ini",
            style: m.TextStyle(color: m.Colors.white70, fontSize: 14),
          ),
          const m.SizedBox(height: 16),
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
            children: [
              _buildStressIcon(stressLevel, stressColors[stressLevel - 1]),
              m.Expanded(
                child: m.Slider(
                  value: stressLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: stressColors[stressLevel - 1],
                  inactiveColor: m.Colors.white.withOpacity(0.2),
                  label: stressLevel.toString(),
                  onChanged: (value) => onChanged(value.round()),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}