import 'dart:async';
import 'package:capstone/provider/user_provider.dart';
import 'package:capstone/ui/pages/on_boarding_screen.dart';
import 'package:capstone/ui/pages/name_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final userProvider = context.read<UserProvider>();
      
      await userProvider.loadUserName();

      if (mounted) {
        if (userProvider.userName != null &&
            userProvider.userName!.isNotEmpty) {
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnBoardingScreen()),
          );
        } else {
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NameEntryScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191825),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_logo.png', width: 150, height: 150),
            const SizedBox(height: 20),
            Text(
              'Project Owl',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
            Text(
              'Unlock Your Productivity',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
