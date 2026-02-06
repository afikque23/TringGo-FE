import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  Locale _locale = const Locale('id'); // Default Bahasa Indonesia

  Locale get locale => _locale;

  LanguageManager() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'id';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  void clearListener() {
    // Untuk membersihkan listener saat dispose
  }
}

// InheritedWidget untuk mengakses LanguageManager dari mana saja
class LanguageProvider extends InheritedWidget {
  final LanguageManager languageManager;

  const LanguageProvider({
    super.key,
    required this.languageManager,
    required super.child,
  });

  static LanguageManager of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<LanguageProvider>();
    assert(provider != null, 'LanguageProvider not found in widget tree');
    return provider!.languageManager;
  }

  @override
  bool updateShouldNotify(LanguageProvider oldWidget) {
    return languageManager != oldWidget.languageManager;
  }
}
