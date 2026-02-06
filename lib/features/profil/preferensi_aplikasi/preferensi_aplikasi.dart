import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../../../core/utils/theme_manager.dart';
import '../../../core/utils/language_manager.dart';

class PreferensiAplikasiPage extends StatefulWidget {
  const PreferensiAplikasiPage({super.key});

  @override
  State<PreferensiAplikasiPage> createState() => _PreferensiAplikasiPageState();
}

class _PreferensiAplikasiPageState extends State<PreferensiAplikasiPage> {
  ThemeManager? _themeManager;
  LanguageManager? _languageManager;

  // Language settings
  String _selectedLanguage = 'id'; // 'id' or 'en'

  // Unit settings
  String _distanceUnit = 'km'; // 'km' or 'mi'
  String _fuelUnit = 'L'; // 'L' or 'gal'

  // GPS & Battery
  bool _autoGPS = true;
  bool _batteryOptimization = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeManager = ThemeProvider.of(context)?.themeManager;
    _languageManager = LanguageProvider.of(context);
    _selectedLanguage = _languageManager?.locale.languageCode ?? 'id';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = _themeManager?.isDarkMode ?? true;
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Column(
          children: [
            // Header
            _buildHeader(context),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  children: [
                    // Display Section
                    _buildDisplaySection(context, isDarkMode),
                    const SizedBox(height: 16),
                    // Language Section
                    _buildLanguageSection(context),
                    const SizedBox(height: 16),
                    // Units Section
                    _buildUnitsSection(context),
                    const SizedBox(height: 16),
                    // GPS & Battery Section
                    _buildGPSBatterySection(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 12),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appPreferences,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.displayLanguageUnits,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.43,
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

  Widget _buildDisplaySection(BuildContext context, bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.brightness_6_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.display,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Dark Mode Toggle
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDarkMode ? l10n.darkTheme : l10n.lightTheme,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDarkMode
                                ? 'Tema gelap untuk kenyamanan mata'
                                : 'Tema terang untuk visibilitas lebih baik',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.33,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) async {
                        await _themeManager?.toggleTheme(value);
                      },
                      activeColor: colorScheme.onPrimary,
                      activeTrackColor: colorScheme.primary,
                      inactiveThumbColor: colorScheme.onSurfaceVariant,
                      inactiveTrackColor: colorScheme.outline,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Info Card
                Container(
                  padding: const EdgeInsets.fromLTRB(12.65, 12.65, 12.65, 0.65),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 0.65,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isDarkMode
                            ? 'ℹ️ Mode gelap menghemat baterai dan mengurangi ketegangan mata'
                            : 'ℹ️ Mode terang memberikan visibilitas lebih baik di siang hari',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.33,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.language_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.language,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Indonesian
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'id';
                    });
                    _languageManager?.setLocale(const Locale('id'));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedLanguage == 'id'
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : colorScheme.surfaceContainerLow,
                      border: Border.all(
                        color: _selectedLanguage == 'id'
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: 1.96,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🇮🇩', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bahasa Indonesia',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                                Text(
                                  'Default',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.33,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_selectedLanguage == 'id')
                          Icon(
                            Icons.check,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // English
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'en';
                    });
                    _languageManager?.setLocale(const Locale('en'));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedLanguage == 'en'
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : colorScheme.surfaceContainerLow,
                      border: Border.all(
                        color: _selectedLanguage == 'en'
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: 1.96,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'English',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                                Text(
                                  'International',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.33,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_selectedLanguage == 'en')
                          Icon(
                            Icons.check,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.straighten_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.units,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance Unit
                Text(
                  l10n.distanceUnit,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _distanceUnit = 'km';
                          });
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _distanceUnit == 'km'
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '${l10n.kilometers} (km)',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: _distanceUnit == 'km'
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _distanceUnit = 'mi';
                          });
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _distanceUnit == 'mi'
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '${l10n.miles} (mi)',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: _distanceUnit == 'mi'
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Fuel Unit
                Text(
                  l10n.fuelUnit,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _fuelUnit = 'L';
                          });
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _fuelUnit == 'L'
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '${l10n.liters} (L)',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: _fuelUnit == 'L'
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _fuelUnit = 'gal';
                          });
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _fuelUnit == 'gal'
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '${l10n.gallons} (gal)',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: _fuelUnit == 'gal'
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSBatterySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.gpsAndBattery,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Items
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.autoStartGPS,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.autoStartGPSDesc,
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoGPS,
                    onChanged: (value) => setState(() => _autoGPS = value),
                    activeColor: colorScheme.onPrimary,
                    activeTrackColor: colorScheme.primary,
                    inactiveThumbColor: colorScheme.onSurfaceVariant,
                    inactiveTrackColor: colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.battery_charging_full_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.batteryOptimization,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.batteryOptimizationDesc,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _batteryOptimization,
                  onChanged: (value) =>
                      setState(() => _batteryOptimization = value),
                  activeColor: colorScheme.onPrimary,
                  activeTrackColor: colorScheme.primary,
                  inactiveThumbColor: colorScheme.onSurfaceVariant,
                  inactiveTrackColor: colorScheme.outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
