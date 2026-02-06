import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/language_manager.dart';
import '../../main.dart';

class SettingsExamplePage extends StatelessWidget {
  const SettingsExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageManager = LanguageProvider.of(context);
    final themeProvider = ThemeProvider.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: ListView(
        children: [
          // Dark Mode Toggle
          SwitchListTile(
            title: Text(localizations.darkMode),
            value: themeProvider?.themeManager.themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              themeProvider?.themeManager.toggleTheme(value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),

          // Language Setting
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizations.language),
            subtitle: Text(
              languageManager.locale.languageCode == 'id'
                  ? localizations.indonesian
                  : localizations.english,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog(context, localizations, languageManager);
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    AppLocalizations localizations,
    LanguageManager languageManager,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: Text(localizations.indonesian),
                value: const Locale('id'),
                groupValue: languageManager.locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    languageManager.setLocale(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<Locale>(
                title: Text(localizations.english),
                value: const Locale('en'),
                groupValue: languageManager.locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    languageManager.setLocale(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }
}
