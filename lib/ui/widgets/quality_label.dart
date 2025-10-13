import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:capstone/provider/sleep_provider.dart';

class QualityLabel extends StatelessWidget {
  const QualityLabel({super.key});

  String getQualityMessage(double score) {
    final percent = score * 100;

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
    final qualityScore = provider.calculateQuality();

    return Text(
      "${getQualityMessage(qualityScore)} 🦉",
      style: const TextStyle(color: Colors.white, fontSize: 23),
    ).h4;
  }
}
