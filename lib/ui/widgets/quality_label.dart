import 'package:flutter/material.dart' as m;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:capstone/provider/sleep_provider.dart';

class QualityLabel extends StatelessWidget {
  const QualityLabel({super.key});

  String getQualityMessage(double score) {
    final percent = score; // Already 0-100%

    if (percent > 80) {
      return "Tidurmu tadi malam nyenyak";
    } else if (percent > 60) {
      return "Tidurmu cukup baik";
    } else {
      return "Tidurmu kurang nyenyak";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();

    return FutureBuilder<double>(
      future: provider.calculateQuality(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "Memuat skor tidur...",
            style: TextStyle(color: Colors.white, fontSize: 23),
          ).h4;
        } else if (snapshot.hasError) {
          return Text(
            "Gagal memuat skor tidur",
            style: TextStyle(color: Colors.white, fontSize: 23),
          ).h4;
        } else {
          final score = snapshot.data ?? 0;
          return Text(
            "${getQualityMessage(score)} 🦉",
            style: TextStyle(color: Colors.white, fontSize: 23),
          ).h4;
        }
      },
    );
  }
}
