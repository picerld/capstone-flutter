import 'package:capstone/provider/nav_provider.dart';
import 'package:capstone/provider/sleep_provider.dart';
import 'package:capstone/provider/theme_provider.dart';
import 'package:capstone/provider/user_provider.dart';
import 'package:capstone/routes.dart';
import 'package:capstone/theme.dart';
import 'package:capstone/ui/pages/on_boarding_screen.dart';
import 'package:capstone/ui/pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() async {
  runApp(const CapstoneApp());
}

class CapstoneApp extends StatelessWidget {
  const CapstoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);

          return ShadcnApp(
            title: "Restaurant",
            debugShowCheckedModeBanner: false,
            theme: AppTheme.owlLightTheme,
            darkTheme: AppTheme.owlDarkTheme,
            themeMode: themeProvider.themeMode,
            home: SplashScreen(),
            initialRoute: '/',
            onGenerateRoute: Routes.generateRoute,
            onUnknownRoute: (settings) {
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            },
          );
        },
      ),
    );
  }
}
