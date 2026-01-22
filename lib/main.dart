import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'services/theme_storage_service.dart';
import 'ui/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const ExpenseTrackerApp());
}

/// Main application widget with Material 3 setup
class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _themeLoaded = false;

  void _toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    ThemeStorageService.saveThemeMode(mode);
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final storedMode = await ThemeStorageService.loadThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = storedMode;
        _themeLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final Color seed = AppTheme.primaryColor;
        final ColorScheme lightScheme =
            lightDynamic ??
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
        final ColorScheme darkScheme =
            darkDynamic ??
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

        return MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(colorScheme: lightScheme),
          darkTheme: AppTheme.darkTheme(colorScheme: darkScheme),
          themeMode: _themeLoaded ? _themeMode : ThemeMode.dark,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => SplashScreen(
              onThemeChanged: _toggleTheme,
              currentThemeMode: _themeMode,
            ),
            '/home': (context) => HomeScreen(
              onThemeChanged: _toggleTheme,
              currentThemeMode: _themeMode,
            ),
          },
          // Custom page transitions
          builder: (context, child) {
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
