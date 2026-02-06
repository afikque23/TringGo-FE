import 'package:flutter/material.dart';

class AppTheme {
  // ============== LIGHT THEME COLORS ==============
  static const Color _lightPrimary = Color(0xFF6B7C4F); // Hijau utama
  static const Color _lightBackground = Color(
    0xFFF4F3F0,
  ); // Warm greige background
  static const Color _lightSurface = Color(0xFFFDFCFA); // Soft cream surface
  static const Color _lightSurfaceVariant = Color(
    0xFFE9E7E3,
  ); // Warm light gray
  static const Color _lightOnBackground = Color(0xFF0A0A0A); // Hitam untuk text
  static const Color _lightOnSurface = Color(0xFF1A1A1A); // Hampir hitam
  static const Color _lightOnSurfaceVariant = Color(
    0xFF6A7282,
  ); // Abu gelap untuk text sekunder
  static const Color _lightSecondary = Color(0xFF8B9181); // Warm gray-green
  static const Color _lightTertiary = Color(0xFF51A2FF); // Biru
  static const Color _lightError = Color(0xFFFF6467); // Merah
  static const Color _lightWarning = Color(0xFFFDC700); // Kuning
  static const Color _lightBorder = Color(0xFF364153); // Border gelap
  static const Color _lightDivider = Color(0xFFCDCBC5); // Warm divider
  static const Color _lightCard = Color(0xFFFDFCFA); // Soft cream card
  static const Color _lightShadow = Color(0x1A000000); // Shadow

  // ============== DARK THEME COLORS ==============
  static const Color _darkPrimary = Color(0xFF6B7C4F); // Hijau utama (sama)
  static const Color _darkBackground = Color(0xFF0A0A0A); // Hitam gelap
  static const Color _darkSurface = Color(0xFF1A1A1A); // Hitam medium
  static const Color _darkSurfaceVariant = Color(
    0xFF252525,
  ); // Hitam agak terang
  static const Color _darkOnBackground = Color(0xFFFFFFFF); // Putih untuk text
  static const Color _darkOnSurface = Color(0xFFFFFFFF); // Putih
  static const Color _darkOnSurfaceVariant = Color(
    0xFF99A1AF,
  ); // Abu medium untuk text sekunder
  static const Color _darkSecondary = Color(0xFF99A1AF); // Abu medium
  static const Color _darkTertiary = Color(0xFF51A2FF); // Biru (sama)
  static const Color _darkError = Color(0xFFFF6467); // Merah (sama)
  static const Color _darkWarning = Color(0xFFFDC700); // Kuning (sama)
  static const Color _darkBorder = Color(0xFF364153); // Border
  static const Color _darkDivider = Color(0xFF1E2939); // Divider gelap
  static const Color _darkCard = Color(0xFF1A1A1A); // Card background
  static const Color _darkShadow = Color(0x1AFFFFFF); // Shadow

  // ============== LIGHT THEME ==============
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      tertiary: _lightTertiary,
      error: _lightError,
      surface: _lightSurface,
      surfaceContainerHighest: _lightSurfaceVariant, // untuk card, container
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _lightOnSurface,
      onSurfaceVariant: _lightOnSurfaceVariant,
      outline: _lightBorder,
      outlineVariant: _lightDivider,
      shadow: _lightShadow,
    ),

    scaffoldBackgroundColor: _lightBackground,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightSurface,
      foregroundColor: _lightOnSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: _lightOnSurface),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: _lightCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(color: _lightDivider, thickness: 0.65),

    // Text Theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _lightOnSurface),
      bodyMedium: TextStyle(color: _lightOnSurface),
      bodySmall: TextStyle(color: _lightOnSurfaceVariant),
      titleLarge: TextStyle(color: _lightOnSurface),
      titleMedium: TextStyle(color: _lightOnSurface),
      titleSmall: TextStyle(color: _lightOnSurfaceVariant),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: _lightOnSurface),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightPrimary, width: 2),
      ),
      hintStyle: const TextStyle(color: _lightOnSurfaceVariant),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // SnackBar Theme
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: _lightOnSurface,
      contentTextStyle: TextStyle(color: Colors.white),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: _lightPrimary,
      unselectedItemColor: _lightSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // ============== DARK THEME ==============
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      tertiary: _darkTertiary,
      error: _darkError,
      surface: _darkSurface,
      surfaceContainerHighest: _darkSurfaceVariant, // untuk card, container
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _darkOnSurface,
      onSurfaceVariant: _darkOnSurfaceVariant,
      outline: _darkBorder,
      outlineVariant: _darkDivider,
      shadow: _darkShadow,
    ),

    scaffoldBackgroundColor: _darkBackground,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkOnSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: _darkOnSurface),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: _darkCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(color: _darkDivider, thickness: 0.65),

    // Text Theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _darkOnSurface),
      bodyMedium: TextStyle(color: _darkOnSurface),
      bodySmall: TextStyle(color: _darkOnSurfaceVariant),
      titleLarge: TextStyle(color: _darkOnSurface),
      titleMedium: TextStyle(color: _darkOnSurface),
      titleSmall: TextStyle(color: _darkOnSurfaceVariant),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: _darkOnSurface),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
      hintStyle: const TextStyle(color: _darkOnSurfaceVariant),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // SnackBar Theme
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: _darkSurface,
      contentTextStyle: TextStyle(color: Colors.white),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _darkPrimary,
      unselectedItemColor: _darkSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // ============== HELPER EXTENSION ==============
  // Extension untuk memudahkan akses warna khusus yang tidak ada di ColorScheme
}

// Extension untuk mendapatkan warna custom
extension CustomColors on ColorScheme {
  Color get warning => brightness == Brightness.light
      ? const Color(0xFFFDC700)
      : const Color(0xFFFDC700);

  Color get warningAlt => brightness == Brightness.light
      ? const Color(0xFFF0B100)
      : const Color(0xFFF0B100);

  Color get cardBackground => brightness == Brightness.light
      ? const Color(0xFFFDFCFA)
      : const Color(0xFF1A1A1A);

  Color get inputFillColor => brightness == Brightness.light
      ? const Color(0xFFE9E7E3)
      : const Color(0xFF1A1A1A);

  Color get textSecondary => brightness == Brightness.light
      ? const Color(0xFF6A7282)
      : const Color(0xFF99A1AF);

  Color get surfaceContainerLow => brightness == Brightness.light
      ? const Color(0xFFF4F3F0)
      : const Color(0xFF0A0A0A);

  Color get surfaceContainerLowest => brightness == Brightness.light
      ? const Color(0xFFFDFCFA)
      : const Color(0xFF0A0A0A);

  Color get dividerLight => brightness == Brightness.light
      ? const Color(0xFFCDCBC5)
      : const Color(0xFF1E2939);

  Color get borderDark => brightness == Brightness.light
      ? const Color(0xFF364153)
      : const Color(0xFF364153);
}
