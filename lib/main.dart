import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/splashscreen/splashcreen.dart';
import 'core/utils/app_theme.dart';
import 'core/utils/theme_manager.dart';
import 'core/utils/language_manager.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ThemeManager _themeManager = ThemeManager();
  final LanguageManager _languageManager = LanguageManager();

  @override
  void initState() {
    super.initState();
    _themeManager.addListener(() {
      setState(() {});
    });
    _languageManager.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeManager.dispose();
    _languageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeManager: _themeManager,
      child: LanguageProvider(
        languageManager: _languageManager,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeManager.themeMode,
          locale: _languageManager.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('id'), // Indonesia
            Locale('en'), // English
          ],
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

// InheritedWidget untuk mengakses ThemeManager dari mana saja
class ThemeProvider extends InheritedWidget {
  final ThemeManager themeManager;

  const ThemeProvider({
    super.key,
    required this.themeManager,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeManager != oldWidget.themeManager;
  }
}
