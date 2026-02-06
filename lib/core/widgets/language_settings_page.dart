import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../utils/language_manager.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageManager = LanguageProvider.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.language)),
      body: ListView(
        children: [
          RadioListTile<Locale>(
            title: Text(localizations.indonesian),
            subtitle: const Text('Bahasa Indonesia'),
            value: const Locale('id'),
            groupValue: languageManager.locale,
            onChanged: (Locale? value) {
              if (value != null) {
                languageManager.setLocale(value);
              }
            },
          ),
          RadioListTile<Locale>(
            title: Text(localizations.english),
            subtitle: const Text('English'),
            value: const Locale('en'),
            groupValue: languageManager.locale,
            onChanged: (Locale? value) {
              if (value != null) {
                languageManager.setLocale(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
