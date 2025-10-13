import 'package:capstone/ui/pages/analytics_screen.dart';
import 'package:capstone/ui/pages/home_screen.dart';
import 'package:capstone/ui/pages/landing_screen.dart';
import 'package:capstone/ui/pages/score_screen.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name!);
    final segments = uri.pathSegments;

    if (segments.isEmpty) {
      return _createRoute(const LandingScreen());
    }

    switch (segments[0]) {
      case '':
        return _createRoute(const LandingScreen());
      case 'dashboard':
        return _createRoute(const HomeScreen());
      case 'score':
        return _createRoute(const ScoreScreen());
      case 'analytics':
        return _createRoute(const AnalyticsScreen());
      default:
        return _createRoute(const LandingScreen());
    }
  }

  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var opacityAnimation = animation.drive(tween);

        return FadeTransition(opacity: opacityAnimation, child: child);
      },
    );
  }
}
