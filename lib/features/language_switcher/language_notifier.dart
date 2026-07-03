import 'package:flutter/foundation.dart';

enum AppLanguage { ru, kz }

class LanguageNotifier extends ChangeNotifier {
  AppLanguage _language = AppLanguage.ru;

  AppLanguage get language => _language;
  bool get isKz => _language == AppLanguage.kz;

  void toggle() {
    _language = _language == AppLanguage.ru ? AppLanguage.kz : AppLanguage.ru;
    debugPrint('Language switched to: ${_language.name.toUpperCase()}');
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    debugPrint('Language switched to: ${_language.name.toUpperCase()}');
    notifyListeners();
  }
}
