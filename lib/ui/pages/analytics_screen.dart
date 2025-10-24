import 'package:capstone/provider/nav_provider.dart';
import 'package:capstone/provider/sleep_provider.dart';
import 'package:capstone/ui/widgets/bottom_nav.dart';
import 'package:capstone/data/models/sleep_record.dart';
import 'package:capstone/ui/widgets/header_with_greeting.dart';
import 'package:flutter/material.dart' as m;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with m.TickerProviderStateMixin {
  late m.AnimationController _contentController;
  late m.Animation<double> _slideAnimation;
  late m.Animation<double> _fadeAnimation;

  DateTime _selectedMonth = DateTime.now();
  DateTime _weekStart = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday - 1),
  );

  @override
  void initState() {
    super.initState();

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
        _contentController.forward();
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _changeWeek(int days) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: days));
    });
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + months,
      );
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  String _getDayName(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[(date.weekday - 1) % 7];
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    return '${_getDayName(start)}, ${start.day} ${_getMonthName(start.month)} - ${_getDayName(end)}, ${end.day} ${_getMonthName(end.month)}';
  }

  String _formatMonthYear(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  String _formatMinutesToHuman(double minutes) {
    if (minutes <= 0) return '--';
    final dur = Duration(minutes: minutes.round());
    final h = dur.inHours;
    final mnt = dur.inMinutes.remainder(60);
    return '${h}h ${mnt}m';
  }

  Color _colorFromQuality(double quality) {
    final pct = (quality).round();
    if (pct <= 0) return m.Colors.white.withValues(alpha: 0.06);
    if (pct < 40) return const m.Color(0xFFEF4444);
    if (pct < 70) return const m.Color(0xFFF59E0B);
    return const m.Color(0xFF10B981);
  }

  Future<void> _showRecordDetails(SleepRecord record) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const m.Text('Detail Tidur'),
        content: m.Column(
          mainAxisSize: m.MainAxisSize.min,
          crossAxisAlignment: m.CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal: ${record.date.toLocal().toIso8601String().split("T")[0]}',
            ),
            Text('Jam Tidur: ${record.sleepTime}'),
            Text('Jam Bangun: ${record.wakeTime}'),
            Text('Durasi: ${record.durationMinutes} menit'),
            Text('Quality: ${(record.quality).toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const m.Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddRecordDialog(DateTime date) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tidak ada data'),
        content: Text(
          'Tidak ada record untuk ${date.toLocal().toIso8601String().split("T")[0]}.',
        ),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const m.Text('Tutup'),
          ),
        ],
      ),
    );
  }

  SleepRecord? _findRecordByDate(List<SleepRecord> list, DateTime target) {
    try {
      return list.firstWhere(
        (r) =>
            r.date.year == target.year &&
            r.date.month == target.month &&
            r.date.day == target.day,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  m.Widget build(m.BuildContext context) {
    final navProvider = Provider.of<NavProvider>(context, listen: false);

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

        // Prepare frequently-used data
        final weeklyRecords = provider.weeklyRecords; // possibly empty
        final avgQuality = weeklyRecords.isNotEmpty
            ? weeklyRecords.fold<double>(0, (s, r) => s + r.quality) /
                  weeklyRecords.length
            : 0.0;

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
                  padding: const m.EdgeInsets.all(20),
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
                        const m.SizedBox(height: 24),
                        HeaderWithGreeting(),
                        const m.SizedBox(height: 24),
                        _buildWeeklyOverview(avgQuality),
                        const m.SizedBox(height: 20),
                        _buildDualAxisChart(provider),
                        const m.SizedBox(height: 20),
                        _buildCalendarHeatmap(provider),
                        const m.SizedBox(height: 20),
                        _buildLatestAnalysis(provider),
                        const m.SizedBox(height: 20),
                        // _buildRecommendations(provider),
                        const m.SizedBox(height: 100),
                        // _buildMonthlyTrends(provider),
                        // const m.SizedBox(height: 20),
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

  m.Widget _buildWeeklyOverview(double avgQuality) {
    final weekEnd = _weekStart.add(const Duration(days: 6));

    return m.Container(
      padding: const m.EdgeInsets.all(20),
      decoration: m.BoxDecoration(
        color: m.Colors.white.withOpacity(0.05),
        borderRadius: m.BorderRadius.circular(16),
        border: m.Border.all(color: m.Colors.white.withOpacity(0.1)),
      ),
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.start,
        children: [
          const m.Text(
            'Wawasan Minggu Ini',
            style: m.TextStyle(
              color: m.Colors.white,
              fontSize: 18,
              fontWeight: m.FontWeight.bold,
            ),
          ),
          const m.SizedBox(height: 16),
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
            children: [
              m.IconButton(
                onPressed: () => _changeWeek(-7),
                icon: const m.Icon(
                  m.Icons.chevron_left,
                  color: m.Colors.white70,
                ),
              ),
              m.Expanded(
                child: m.Text(
                  _formatWeekRange(_weekStart, weekEnd),
                  style: const m.TextStyle(
                    color: m.Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: m.TextAlign.center,
                ),
              ),
              m.IconButton(
                onPressed: () => _changeWeek(7),
                icon: const m.Icon(
                  m.Icons.chevron_right,
                  color: m.Colors.white70,
                ),
              ),
            ],
          ),
          const m.SizedBox(height: 12),
          m.Row(
            children: [
              const m.Text(
                'Avg quality: ',
                style: m.TextStyle(color: m.Colors.white70),
              ),
              m.Text(
                '${(avgQuality).toStringAsFixed(0)}',
                style: const m.TextStyle(color: m.Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  m.Widget _buildDualAxisChart(SleepProvider provider) {
    // 7-day window from _weekStart
    final days = List.generate(
      7,
      (i) => DateTime(_weekStart.year, _weekStart.month, _weekStart.day + i),
    );
    final all = provider.weeklyRecords;

    final dayQualities = days.map((d) {
      final rec = _findRecordByDate(all, d);
      return (rec?.quality ?? 0.0) * 100.0; // 0..100
    }).toList();

    final sleepScores = dayQualities;
    final productivityScores = dayQualities.map((s) => s * 0.8).toList();

    return m.Container(
      padding: const m.EdgeInsets.all(20),
      decoration: m.BoxDecoration(
        color: m.Colors.white.withOpacity(0.05),
        borderRadius: m.BorderRadius.circular(16),
        border: m.Border.all(color: m.Colors.white.withOpacity(0.1)),
      ),
      child: m.Column(
        children: [
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
            children: [
              m.IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const m.Icon(
                  m.Icons.chevron_left,
                  color: m.Colors.white70,
                  size: 20,
                ),
              ),
              m.Text(
                _formatMonthYear(_selectedMonth),
                style: const m.TextStyle(
                  color: m.Colors.white,
                  fontSize: 16,
                  fontWeight: m.FontWeight.w600,
                ),
              ),
              m.IconButton(
                onPressed: () => _changeMonth(1),
                icon: const m.Icon(
                  m.Icons.chevron_right,
                  color: m.Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const m.SizedBox(height: 20),
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: m.CrossAxisAlignment.start,
            children: const [
              m.Text(
                'Skor Tidur',
                style: m.TextStyle(color: m.Colors.white70, fontSize: 12),
              ),
              m.Text(
                'Skor Produktivitas',
                style: m.TextStyle(color: m.Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const m.SizedBox(height: 10),
          m.SizedBox(
            height: 200,
            child: m.CustomPaint(
              painter: _DualAxisChartPainter(sleepScores, productivityScores),
              size: const m.Size(double.infinity, 200),
            ),
          ),
          const m.SizedBox(height: 10),
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceAround,
            children: const [
              m.Text(
                'Sen',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 11),
              ),
              m.Text(
                'Sel',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 11),
              ),
              m.Text(
                'Rab',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 11),
              ),
              m.Text(
                'Kam',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 11),
              ),
              m.Text(
                'Jum',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 11),
              ),
              m.Text(
                'Sab',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 11),
              ),
              m.Text(
                'Min',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  m.Widget _buildCalendarHeatmap(SleepProvider provider) {
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return m.Container(
      padding: const m.EdgeInsets.all(20),
      decoration: m.BoxDecoration(
        color: m.Colors.white.withOpacity(0.05),
        borderRadius: m.BorderRadius.circular(16),
        border: m.Border.all(color: m.Colors.white.withOpacity(0.1)),
      ),
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.start,
        children: [
          m.Row(
            mainAxisAlignment: m.MainAxisAlignment.spaceAround,
            children: const [
              m.Text(
                'Min',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 12),
              ),
              m.Text(
                'Sen',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 12),
              ),
              m.Text(
                'Sel',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 12),
              ),
              m.Text(
                'Rab',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 12),
              ),
              m.Text(
                'Kam',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 12),
              ),
              m.Text(
                'Jum',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 12),
              ),
              m.Text(
                'Sab',
                style: m.TextStyle(color: m.Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const m.SizedBox(height: 12),
          m.GridView.builder(
            shrinkWrap: true,
            physics: const m.NeverScrollableScrollPhysics(),
            gridDelegate: const m.SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: startingWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const m.SizedBox();
              }

              final day = index - startingWeekday + 1;
              final date = DateTime(
                _selectedMonth.year,
                _selectedMonth.month,
                day,
              );
              final record = _findRecordByDate(provider.weeklyRecords, date);
              final quality = record?.quality ?? 0.0;

              return m.GestureDetector(
                onTap: () {
                  if (record != null) {
                    _showRecordDetails(record);
                  } else {
                    _showAddRecordDialog(date);
                  }
                },
                child: m.Container(
                  decoration: m.BoxDecoration(
                    color: _colorFromQuality(quality),
                    borderRadius: m.BorderRadius.circular(8),
                  ),
                  child: m.Center(
                    child: m.Text(
                      '$day',
                      style: const m.TextStyle(
                        color: m.Colors.white,
                        fontSize: 14,
                        fontWeight: m.FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  m.Widget _buildLatestAnalysis(SleepProvider provider) {
    final latestRecord = provider.todayRecord;

    final avgThisWeek = provider.weeklyRecords.isNotEmpty
        ? provider.weeklyRecords.fold<double>(0, (s, r) => s + r.quality) /
              provider.weeklyRecords.length
        : 0.0;

    return m.Container(
      padding: const m.EdgeInsets.all(20),
      decoration: m.BoxDecoration(
        color: m.Colors.white.withOpacity(0.05),
        borderRadius: m.BorderRadius.circular(16),
        border: m.Border.all(color: m.Colors.white.withOpacity(0.1)),
      ),
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.start,
        children: [
          const m.Text(
            'Analisis Terkini',
            style: m.TextStyle(
              color: m.Colors.white,
              fontSize: 18,
              fontWeight: m.FontWeight.bold,
            ),
          ),
          const m.SizedBox(height: 12),
          _buildAnalysisItem(
            '• Rata-rata tidur minggu ini: ${(avgThisWeek).toStringAsFixed(0)}.',
            const m.Color(0xFF06B6D4),
          ),
          if (latestRecord != null) ...[
            const m.SizedBox(height: 12),
            _buildAnalysisItem(
              '• Terakhir: ${latestRecord.sleepTime} - ${latestRecord.wakeTime} (${(latestRecord.quality).toStringAsFixed(0)}).',
              m.Colors.orange.shade300,
            ),
          ],
        ],
      ),
    );
  }

  m.Widget _buildAnalysisItem(String text, m.Color color) {
    return m.Row(
      crossAxisAlignment: m.CrossAxisAlignment.start,
      children: [
        m.Container(
          margin: const m.EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: m.BoxDecoration(color: color, shape: m.BoxShape.circle),
        ),
        const m.SizedBox(width: 12),
        m.Expanded(
          child: m.Text(
            text,
            style: m.TextStyle(
              color: m.Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  m.Widget _buildRecommendations(SleepProvider provider) {
    final duration = provider.calculateDuration();
    final hours = duration != null ? duration.inMinutes / 60.0 : 0;

    String recommendationText;
    if (hours < 7) {
      recommendationText =
          'Hari ini kamu tidur kurang dari 7 jam. Coba tidur 90 menit lebih malam ini untuk meningkatkan energimu besok!';
    } else if (hours >= 7 && hours <= 9) {
      recommendationText =
          'Tidurmu cukup hari ini. Pertahankan pola tidur yang sehat!';
    } else {
      recommendationText =
          'Tidurmu lebih dari 9 jam. Pastikan tidak terlalu berlebihan!';
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
              const m.Text(
                'Rekomendasi Besok',
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
            recommendationText,
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

  m.Widget _buildMonthlyTrends(SleepProvider provider) {
    // Example month summary using provider data
    final avgQuality = provider.weeklyRecords.isNotEmpty
        ? provider.weeklyRecords.fold<double>(0, (s, r) => s + r.quality) /
              provider.weeklyRecords.length
        : 0.0;

    final avgDurationMinutes = provider.weeklyAverageDuration;

    return m.Container(
      padding: const m.EdgeInsets.all(20),
      decoration: m.BoxDecoration(
        color: m.Colors.white,
        borderRadius: m.BorderRadius.circular(16),
      ),
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.start,
        children: [
          const m.Text(
            'Tren Produktivitas Bulanan',
            style: m.TextStyle(
              color: m.Colors.black87,
              fontSize: 18,
              fontWeight: m.FontWeight.bold,
            ),
          ),
          const m.SizedBox(height: 16),
          m.Container(
            padding: const m.EdgeInsets.all(16),
            decoration: m.BoxDecoration(
              color: const m.Color(0xFFF3F4F6),
              borderRadius: m.BorderRadius.circular(12),
            ),
            child: m.Column(
              crossAxisAlignment: m.CrossAxisAlignment.start,
              children: [
                m.Text(
                  'Skor Tidur Rata-rata: ${(avgQuality * 100).toStringAsFixed(0)}',
                  style: const m.TextStyle(
                    color: m.Colors.black87,
                    fontSize: 16,
                    fontWeight: m.FontWeight.w600,
                  ),
                ),
                const m.SizedBox(height: 4),
                m.Text(
                  'Durasi Tidur: ${_formatMinutesToHuman(avgDurationMinutes)}',
                  style: m.TextStyle(
                    color: m.Colors.black.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const m.SizedBox(height: 16),
          m.SizedBox(
            height: 150,
            child: m.Row(
              crossAxisAlignment: m.CrossAxisAlignment.end,
              mainAxisAlignment: m.MainAxisAlignment.spaceAround,
              children: [
                _buildBarChart('Min', 65, const m.Color(0xFF06B6D4)),
                _buildBarChart('Sep', 72, const m.Color(0xFFF59E0B)),
                _buildBarChart('Omt', 85, const m.Color(0xFF10B981)),
                _buildBarChart('Okt', 78, const m.Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  m.Widget _buildBarChart(String label, int value, m.Color color) {
    return m.Column(
      mainAxisAlignment: m.MainAxisAlignment.end,
      children: [
        m.Container(
          width: 50,
          height: value * 1.5,
          decoration: m.BoxDecoration(
            color: color,
            borderRadius: const m.BorderRadius.vertical(
              top: m.Radius.circular(8),
            ),
          ),
        ),
        const m.SizedBox(height: 8),
        m.Text(
          label,
          style: m.TextStyle(
            color: m.Colors.black.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DualAxisChartPainter extends m.CustomPainter {
  final List<double> sleepScores;
  final List<double> productivityScores;

  _DualAxisChartPainter(this.sleepScores, this.productivityScores);

  @override
  void paint(m.Canvas canvas, m.Size size) {
    final sleepPaint = m.Paint()
      ..color = const m.Color(0xFF8B5CF6)
      ..strokeWidth = 3
      ..style = m.PaintingStyle.stroke;

    final productivityPaint = m.Paint()
      ..color = const m.Color(0xFF06B6D4)
      ..strokeWidth = 3
      ..style = m.PaintingStyle.stroke;

    final pointPaint = m.Paint()..style = m.PaintingStyle.fill;

    final n = sleepScores.length;
    if (n == 0 || productivityScores.length != n) return;

    final sleepPath = m.Path();
    final productivityPath = m.Path();

    for (var i = 0; i < n; i++) {
      final x = n == 1 ? size.width / 2 : (size.width / (n - 1)) * i;
      final sleepY =
          size.height - (sleepScores[i].clamp(0, 100) / 100 * size.height);
      final prodY =
          size.height -
          (productivityScores[i].clamp(0, 100) / 100 * size.height);

      if (i == 0) {
        sleepPath.moveTo(x, sleepY);
        productivityPath.moveTo(x, prodY);
      } else {
        sleepPath.lineTo(x, sleepY);
        productivityPath.lineTo(x, prodY);
      }

      // Draw sleep points
      pointPaint.color = const m.Color(0xFF8B5CF6);
      canvas.drawCircle(m.Offset(x, sleepY), 5, pointPaint);
      canvas.drawCircle(
        m.Offset(x, sleepY),
        7,
        pointPaint..color = m.Colors.white.withOpacity(0.3),
      );

      // Draw productivity points
      pointPaint.color = const m.Color(0xFF06B6D4);
      canvas.drawCircle(m.Offset(x, prodY), 5, pointPaint);
      canvas.drawCircle(
        m.Offset(x, prodY),
        7,
        pointPaint..color = m.Colors.white.withOpacity(0.3),
      );
    }

    canvas.drawPath(sleepPath, sleepPaint);
    canvas.drawPath(productivityPath, productivityPaint);
  }

  @override
  bool shouldRepaint(covariant m.CustomPainter oldDelegate) => true;
}
