import 'package:capstone/provider/user_provider.dart';
import 'package:flutter/material.dart' as m;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class HeaderWithGreeting extends m.StatelessWidget {
  const HeaderWithGreeting({super.key});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Selamat Pagi";
    } else if (hour < 15) {
      return "Selamat Siang";
    } else if (hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  @override
  m.Widget build(m.BuildContext context) {
    final userName = context.watch<UserProvider>().userName;

    return Text(
      '${getGreeting()}, ${userName ?? 'Sobat'}',
      style: m.TextStyle(fontWeight: m.FontWeight.bold, color: m.Colors.white),
    ).h4;
  }
}
