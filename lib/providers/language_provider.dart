import 'package:flutter/foundation.dart';
import '../core/localization/app_localizations.dart';

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;

  void setLanguage(AppLanguage value) {
    if (_language == value) return;
    _language = value;
    notifyListeners();
  }
}
