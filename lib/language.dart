part of 'main.dart';

enum AppLanguage { english, gujarati }

class _LanguageSettings {
  static const _prefKey = 'appLanguage';

  static Future<AppLanguage> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefKey);
    if (value == AppLanguage.gujarati.name) {
      return AppLanguage.gujarati;
    }
    return AppLanguage.english;
  }

  static Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, language.name);
  }
}

Future<void> showLanguageSelectorDialog(BuildContext context) async {
  final initialLanguage = languageNotifier.value;
  await showDialog<void>(
    context: context,
    builder: (context) {
      var selectedLanguage = initialLanguage;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.text(initialLanguage, 'selectLanguage')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguage.values
                .map(
                  (lang) => RadioListTile<AppLanguage>(
                    value: lang,
                    // ignore: deprecated_member_use
                    groupValue: selectedLanguage,
                    title: Text(lang.displayName),
                    // ignore: deprecated_member_use
                    onChanged: (selected) async {
                      if (selected == null) return;
                      setState(() => selectedLanguage = selected);
                      languageNotifier.value = selected;
                      await _LanguageSettings.saveLanguage(selected);
                    },
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.text(initialLanguage, 'save')),
            ),
          ],
        ),
      );
    },
  );
}
