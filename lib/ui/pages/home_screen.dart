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
      await provider.loadData();
      await _updateProgress(provider);
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
        await provider.setJamTidur(picked);
      } else {
        await provider.setJamBangun(picked);
      }

      if (provider.jamTidur != null && provider.jamBangun != null && mounted) {
        m.ScaffoldMessenger.of(context).showSnackBar(
          const m.SnackBar(
            content: m.Text('Sleep time updated!'),
            backgroundColor: m.Color(0xFF8B5CF6),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> showSubmitDialog(
    BuildContext context,
    SleepProvider provider,
  ) async {
    final result = await m.showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => m.AlertDialog(
        backgroundColor: const m.Color(0xFF1A0B2E),
        shape: m.RoundedRectangleBorder(
          borderRadius: m.BorderRadius.circular(20),
          side: m.BorderSide(color: m.Colors.white.withOpacity(0.1)),
        ),
        title: const m.Text(
          'Kalkulasi!',
          style: m.TextStyle(color: m.Colors.white),
        ),
        content: const m.Text(
          'Apakah Anda yakin ingin menyimpan data tidur hari ini?',
          style: m.TextStyle(color: m.Colors.white70),
        ),
        actions: [
          m.TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const m.Text(
              'Batal',
              style: m.TextStyle(color: m.Colors.white70),
            ),
          ),
          m.ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: m.ElevatedButton.styleFrom(
              backgroundColor: const m.Color(0xFF8B5CF6),
              shape: m.RoundedRectangleBorder(
                borderRadius: m.BorderRadius.circular(12),
              ),
            ),
            child: const m.Text(
              'Simpan',
              style: m.TextStyle(color: m.Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      // Show loading
      m.showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const m.Center(
          child: m.CircularProgressIndicator(color: m.Color(0xFF8B5CF6)),
        ),
      );

      // Submit data and get the score
      final scoreResult = await provider.submitSleepData();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        if (scoreResult != null) {
          // Success - update progress with the returned score
          setState(() {
            _progressAnimation = Tween<double>(begin: 0, end: scoreResult)
                .animate(
                  CurvedAnimation(
                    parent: _progressController,
                    curve: Curves.easeInOut,
                  ),
                );
          });
          _progressController.forward(from: 0);

          m.ScaffoldMessenger.of(context).showSnackBar(
            const m.SnackBar(
              content: m.Text('Data tidur berhasil disimpan!'),
              backgroundColor: m.Color(0xFF8B5CF6),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Failed
          m.ScaffoldMessenger.of(context).showSnackBar(
            const m.SnackBar(
              content: m.Text('Gagal menyimpan data. Silakan coba lagi.'),
              backgroundColor: m.Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
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
          return m.Scaffold(
            body: m.Container(
              decoration: const m.BoxDecoration(color: Color(0xFF3B0764)),
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
                    builder: (context, child) => m.Transform.translate(
                      offset: m.Offset(0, _slideAnimation.value),
                      child: m.Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    ),
                    child: m.Column(
                      crossAxisAlignment: m.CrossAxisAlignment.start,
                      children: [
                        const m.SizedBox(height: 40),
                        const HeaderWithGreeting(),
                        const m.SizedBox(height: 40),

                        // Time Cards
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

                        // Stress Card (1-10 scale)
                        StressInputCard(
                          stressLevel: provider.stressLevel,
                          onChanged: (level) {
                            provider.setStressLevel(level);
                            // NO progress update here
                          },
                        ),

                        const m.SizedBox(height: 20),

                        // Quality Sleep Card (1-10 scale)
                        QualitySleepCard(
                          qualitySleep: provider.qualitySleep,
                          onChanged: (level) {
                            provider.setQualitySleep(level);
                            // NO progress update here
                          },
                        ),

                        const m.SizedBox(height: 30),

                        // Submit Button
                        m.SizedBox(
                          width: double.infinity,
                          child: m.ElevatedButton(
                            onPressed:
                                provider.jamTidur == null ||
                                    provider.jamBangun == null
                                ? null
                                : () => showSubmitDialog(context, provider),
                            style: m.ElevatedButton.styleFrom(
                              backgroundColor: const m.Color(0xFF8B5CF6),
                              disabledBackgroundColor: m.Colors.grey
                                  .withOpacity(0.3),
                              padding: const m.EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: m.RoundedRectangleBorder(
                                borderRadius: m.BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: provider.isSaving
                                ? const m.SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: m.CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          m.AlwaysStoppedAnimation<m.Color>(
                                            m.Colors.white,
                                          ),
                                    ),
                                  )
                                : const m.Text(
                                    'Hitung Skor',
                                    style: m.TextStyle(
                                      color: m.Colors.white,
                                      fontSize: 16,
                                      fontWeight: m.FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const m.SizedBox(height: 40),

                        // Sleep Score Circle
                        m.Center(
                          child: m.Column(
                            children: [
                              m.SizedBox(
                                width: 200,
                                height: 200,
                                child: m.AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, child) => m.CustomPaint(
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
                                            "Skor Produktivitas",
                                            style: m.TextStyle(
                                              color: m.Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const m.SizedBox(height: 8),
                                          m.Text(
                                            "${_progressAnimation.value.toStringAsFixed(0)}",
                                            style: const m.TextStyle(
                                              color: m.Colors.white,
                                              fontSize: 48,
                                              fontWeight: m.FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // const m.SizedBox(height: 24),
                              // m.Row(
                              //   mainAxisAlignment: m.MainAxisAlignment.center,
                              //   children: [
                              //     _buildLegend(
                              //       "Deep Sleep",
                              //       const m.Color(0xFF8B5CF6),
                              //     ),
                              //     const m.SizedBox(width: 32),
                              //     _buildLegend(
                              //       "Light Sleep",
                              //       const m.Color(0xFF06B6D4),
                              //     ),
                              //   ],
                              // ),
                              const m.SizedBox(height: 45),

                              // Sleep Summary Card
                              m.Container(
                                padding: const m.EdgeInsets.all(20),
                                decoration: m.BoxDecoration(
                                  color: m.Colors.white.withValues(alpha: 0.05),
                                  borderRadius: m.BorderRadius.circular(20),
                                  border: m.Border.all(
                                    color: m.Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
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
                                        borderRadius: m.BorderRadius.circular(
                                          12,
                                        ),
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
                                        crossAxisAlignment:
                                            m.CrossAxisAlignment.start,
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
                                      crossAxisAlignment:
                                          m.CrossAxisAlignment.end,
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

                              const m.SizedBox(height: 20),

                              _buildRecommendations(provider),

                              const m.SizedBox(height: 100),
                            ],
                          ),
                        ),
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

  m.Widget _buildRecommendations(SleepProvider sleep) {
    final score = sleep.todayRecord?.prediction ?? 0;
    print("Skor Kamu: ${score}");
    String categoryText;
    String titleText;

    if (score <= 51) {
      titleText = "Produktivitas Rendah";
      categoryText =
          'Tidur pendek, kualitas tidur rendah, atau tingkat stres tinggi. Perlu memperbaiki pola tidur dan mengurangi stres';
    } else if (score <= 68) {
      titleText = "Perlu Ditingkatkan";
      categoryText =
          'Kondisi sudah sedang, tapi masih bisa ditingkatkan dengan tidur yang lebih lama atau kualitas yang lebih baik!';
    } else if (score <= 86) {
      titleText = "Cukup Baik";
      categoryText =
          'Produktivitas sudah baik, tetapi masih dapat ditingkatkan dengan menjaga rutinitas yang konsisten!';
    } else {
      titleText = "Optimal";
      categoryText =
          'Kombinasi tidur cukup, kualitas tinggi, dan stres rendah -- pertahankan gaya hidup ini!';
    }

    return m.Container(
      padding: const m.EdgeInsets.all(20),
      decoration: m.BoxDecoration(
        gradient: m.LinearGradient(
          colors: [
            const m.Color(0xFF8B5CF6).withOpacity(0.2),
            const m.Color(0xFF06B6D4).withOpacity(0.1),
          ],
        ),
        borderRadius: m.BorderRadius.circular(16),
        border: m.Border.all(color: const m.Color(0xFF8B5CF6).withOpacity(0.3)),
      ),
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.start,
        children: [
          m.Row(
            children: [
              m.Container(
                padding: const m.EdgeInsets.all(10),
                decoration: m.BoxDecoration(
                  color: const m.Color(0xFF8B5CF6).withOpacity(0.3),
                  borderRadius: m.BorderRadius.circular(10),
                ),
                child: const m.Icon(
                  m.Icons.lightbulb_outline,
                  color: m.Color(0xFFFBBF24),
                  size: 20,
                ),
              ),
              const m.SizedBox(width: 12),
              m.Text(
                titleText,
                style: m.TextStyle(
                  color: m.Colors.white,
                  fontSize: 18,
                  fontWeight: m.FontWeight.bold,
                ),
              ),
            ],
          ),
          const m.SizedBox(height: 16),
          m.Text(
            categoryText,
            style: m.TextStyle(
              color: m.Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
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

class StressInputCard extends m.StatefulWidget {
  const StressInputCard({
    super.key,
    required this.stressLevel,
    required this.onChanged,
  });

  final int stressLevel;
  final void Function(int) onChanged;

  @override
  State<StressInputCard> createState() => _StressInputCardState();
}

class _StressInputCardState extends m.State<StressInputCard> {
  late double _currentLevel;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.stressLevel.toDouble();
  }

  @override
  void didUpdateWidget(covariant StressInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stressLevel != oldWidget.stressLevel) {
      _currentLevel = widget.stressLevel.toDouble();
    }
  }

  m.Widget _buildStressIcon(int level, m.Color color) {
    m.IconData iconData;
    if (level <= 2) {
      iconData = m.Icons.sentiment_very_satisfied;
    } else if (level <= 4) {
      iconData = m.Icons.sentiment_satisfied;
    } else if (level <= 6) {
      iconData = m.Icons.sentiment_neutral;
    } else if (level <= 8) {
      iconData = m.Icons.sentiment_dissatisfied;
    } else {
      iconData = m.Icons.sentiment_very_dissatisfied;
    }
    return m.Icon(iconData, color: color, size: 30);
  }

  m.Color _getStressColor(int level) {
    if (level <= 2) return m.Colors.green;
    if (level <= 4) return m.Colors.lightGreen;
    if (level <= 6) return m.Colors.yellow;
    if (level <= 8) return m.Colors.orange;
    return m.Colors.red;
  }

  @override
  m.Widget build(m.BuildContext context) {
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
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
            children: [
              const m.Text(
                "Tingkat Stres Hari Ini",
                style: m.TextStyle(color: m.Colors.white70, fontSize: 14),
              ),
              m.Text(
                "${_currentLevel.toInt()}/10",
                style: m.TextStyle(
                  color: _getStressColor(_currentLevel.toInt()),
                  fontSize: 14,
                  fontWeight: m.FontWeight.bold,
                ),
              ),
            ],
          ),
          const m.SizedBox(height: 16),
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
            children: [
              _buildStressIcon(
                _currentLevel.toInt(),
                _getStressColor(_currentLevel.toInt()),
              ),
              m.Expanded(
                child: m.Slider(
                  value: _currentLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: _getStressColor(_currentLevel.toInt()),
                  inactiveColor: m.Colors.white.withOpacity(0.2),
                  label: _currentLevel.toInt().toString(),
                  onChanged: (value) {
                    setState(() => _currentLevel = value);
                    widget.onChanged(_currentLevel.toInt());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QualitySleepCard extends m.StatefulWidget {
  const QualitySleepCard({
    super.key,
    required this.qualitySleep,
    required this.onChanged,
  });

  final int qualitySleep;
  final void Function(int) onChanged;

  @override
  State<QualitySleepCard> createState() => _QualitySleepCardState();
}

class _QualitySleepCardState extends m.State<QualitySleepCard> {
  late double _currentLevel;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.qualitySleep.toDouble();
  }

  @override
  void didUpdateWidget(covariant QualitySleepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.qualitySleep != oldWidget.qualitySleep) {
      _currentLevel = widget.qualitySleep.toDouble();
    }
  }

  m.Widget _buildQualityIcon(int level, m.Color color) {
    m.IconData iconData;
    if (level <= 2) {
      iconData = m.Icons.hotel_outlined;
    } else if (level <= 4) {
      iconData = m.Icons.hotel;
    } else if (level <= 6) {
      iconData = m.Icons.king_bed_outlined;
    } else if (level <= 8) {
      iconData = m.Icons.king_bed;
    } else {
      iconData = m.Icons.airline_seat_flat;
    }
    return m.Icon(iconData, color: color, size: 30);
  }

  m.Color _getQualityColor(int level) {
    if (level <= 2) return m.Colors.red;
    if (level <= 4) return m.Colors.orange;
    if (level <= 6) return m.Colors.yellow;
    if (level <= 8) return m.Colors.lightGreen;
    return m.Colors.green;
  }

  @override
  m.Widget build(m.BuildContext context) {
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
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
            children: [
              const m.Text(
                "Kualitas Tidur Hari Ini",
                style: m.TextStyle(color: m.Colors.white70, fontSize: 14),
              ),
              m.Text(
                "${_currentLevel.toInt()}/10",
                style: m.TextStyle(
                  color: _getQualityColor(_currentLevel.toInt()),
                  fontSize: 14,
                  fontWeight: m.FontWeight.bold,
                ),
              ),
            ],
          ),
          const m.SizedBox(height: 16),
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
            children: [
              _buildQualityIcon(
                _currentLevel.toInt(),
                _getQualityColor(_currentLevel.toInt()),
              ),
              m.Expanded(
                child: m.Slider(
                  value: _currentLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: _getQualityColor(_currentLevel.toInt()),
                  inactiveColor: m.Colors.white.withOpacity(0.2),
                  label: _currentLevel.toInt().toString(),
                  onChanged: (value) {
                    setState(() => _currentLevel = value);
                    widget.onChanged(_currentLevel.toInt());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
