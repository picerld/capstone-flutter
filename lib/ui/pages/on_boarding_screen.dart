import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:capstone/ui/pages/home_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color darkPurple = Color(0xFF191825);
  static const Color primaryPurple = Color(0xFF865DFF);

  final List<Widget> _onboardingPages = [];

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    _onboardingPages.addAll([
      buildAnimatedPage(
        const OnboardingPageContent(
          icon: Icons.monitor_heart_outlined,
          title: "Lacak Tidur Harianmu",
          description:
              "Catat durasi tidurmu setiap hari dengan mudah untuk melihat polanya.",
        ),
      ),
      buildAnimatedPage(
        const OnboardingPageContent(
          icon: Icons.auto_graph_outlined,
          title: "Dapatkan Prediksi Produktivitas",
          description:
              "Model cerdas kami akan menganalisis data tidurmu dan memberikan prediksi produktivitas.",
        ),
      ),
      buildAnimatedPage(
        const OnboardingPageContent(
          icon: Icons.lightbulb_outline,
          title: "Rekomendasi Cerdas",
          description:
              "Terima rekomendasi yang dipersonalisasi untuk meningkatkan kualitas tidur dan kinerjamu.",
        ),
      ),
    ]);

    _contentController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildAnimatedPage(Widget child) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: _onboardingPages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingPages.length,
                      (index) => buildDot(index),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingPages.length - 1) {
                          // Smooth transition to HomeScreen
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const HomeScreen(),
                              transitionDuration: const Duration(
                                milliseconds: 700,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 700,
                              ),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    final curvedAnimation = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOutCubic,
                                    );

                                    final fade = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).animate(curvedAnimation);
                                    final slide = Tween<Offset>(
                                      begin: const Offset(0, 0.2),
                                      end: Offset.zero,
                                    ).animate(curvedAnimation);
                                    final scale = Tween<double>(
                                      begin: 0.95,
                                      end: 1.0,
                                    ).animate(curvedAnimation);

                                    return FadeTransition(
                                      opacity: fade,
                                      child: SlideTransition(
                                        position: slide,
                                        child: ScaleTransition(
                                          scale: scale,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingPages.length - 1
                            ? "Mulai"
                            : "Lanjut",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? primaryPurple
            : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  static const Color primaryPurple = Color(0xFF865DFF);

  const OnboardingPageContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryPurple.withOpacity(0.15),
            ),
            child: Icon(icon, size: 80, color: primaryPurple),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
