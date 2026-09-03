import 'package:flutter/material.dart';

enum AppLanguage { english, hindi, tamil, telugu }

extension AppLanguageInfo on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english: return 'en';
      case AppLanguage.hindi: return 'hi';
      case AppLanguage.tamil: return 'ta';
      case AppLanguage.telugu: return 'te';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLanguage.english: return 'English';
      case AppLanguage.hindi: return 'हिन्दी';
      case AppLanguage.tamil: return 'தமிழ்';
      case AppLanguage.telugu: return 'తెలుగు';
    }
  }
}

class AppStrings {
  AppStrings._();

  static const Map<String, Map<AppLanguage, String>> _values = {
    'dashboard': {
      AppLanguage.english: 'Dashboard', AppLanguage.hindi: 'डैशबोर्ड',
      AppLanguage.tamil: 'டாஷ்போர்டு', AppLanguage.telugu: 'డ్యాష్‌బోర్డ్',
    },
    'dashboardTitle': {
      AppLanguage.english: 'Your Financial Identity', AppLanguage.hindi: 'आपकी वित्तीय पहचान',
      AppLanguage.tamil: 'உங்கள் நிதி அடையாளம்', AppLanguage.telugu: 'మీ ఆర్థిక గుర్తింపు',
    },
    'multiSourceIncome': {
      AppLanguage.english: 'Multi-source income', AppLanguage.hindi: 'कई स्रोतों की आय',
      AppLanguage.tamil: 'பல மூல வருமானம்', AppLanguage.telugu: 'బహుళ మూలాల ఆదాయం',
    },
    'unifiedLedger': {
      AppLanguage.english: 'Unified ledger', AppLanguage.hindi: 'एकीकृत लेजर',
      AppLanguage.tamil: 'ஒருங்கிணைந்த பதிவேடு', AppLanguage.telugu: 'ఏకీకృత లెడ్జర్',
    },
    'financialReliability': {
      AppLanguage.english: 'Financial reliability profile', AppLanguage.hindi: 'वित्तीय विश्वसनीयता प्रोफ़ाइल',
      AppLanguage.tamil: 'நிதி நம்பகத்தன்மை சுயவிவரம்', AppLanguage.telugu: 'ఆర్థిక విశ్వసనీయత ప్రొఫైల్',
    },
    'trustScore': {
      AppLanguage.english: 'Trust Score', AppLanguage.hindi: 'ट्रस्ट स्कोर',
      AppLanguage.tamil: 'நம்பிக்கை மதிப்பெண்', AppLanguage.telugu: 'ట్రస్ట్ స్కోర్',
    },
    'credentials': {
      AppLanguage.english: 'Credentials', AppLanguage.hindi: 'प्रमाण-पत्र',
      AppLanguage.tamil: 'சான்றுகள்', AppLanguage.telugu: 'ధృవపత్రాలు',
    },
    'verifiedCredentials': {
      AppLanguage.english: 'Verified credentials', AppLanguage.hindi: 'सत्यापित प्रमाण-पत्र',
      AppLanguage.tamil: 'சரிபார்க்கப்பட்ட சான்றுகள்', AppLanguage.telugu: 'ధృవీకరించిన ఆధారాలు',
    },
    'generateCredential': {
      AppLanguage.english: 'Generate earnings proof', AppLanguage.hindi: 'आय प्रमाण बनाएं',
      AppLanguage.tamil: 'வருமானச் சான்றை உருவாக்கு', AppLanguage.telugu: 'ఆదాయ రుజువు సృష్టించండి',
    },
    'verified': {
      AppLanguage.english: 'Verified', AppLanguage.hindi: 'सत्यापित',
      AppLanguage.tamil: 'சரிபார்க்கப்பட்டது', AppLanguage.telugu: 'ధృవీకరించబడింది',
    },
    'integrityVerified': {
      AppLanguage.english: 'Integrity Verified', AppLanguage.hindi: 'अखंडता सत्यापित',
      AppLanguage.tamil: 'ஒருமைப்பாடு சரிபார்க்கப்பட்டது', AppLanguage.telugu: 'సమగ్రత ధృవీకరించబడింది',
    },
    'share': {
      AppLanguage.english: 'Share', AppLanguage.hindi: 'साझा करें',
      AppLanguage.tamil: 'பகிர்', AppLanguage.telugu: 'షేర్',
    },
    'sharing': {
      AppLanguage.english: 'Sharing', AppLanguage.hindi: 'डेटा साझाकरण',
      AppLanguage.tamil: 'தரவு பகிர்வு', AppLanguage.telugu: 'డేటా షేరింగ్',
    },
    'dataAccess': {
      AppLanguage.english: 'Data access & consent', AppLanguage.hindi: 'डेटा एक्सेस और सहमति',
      AppLanguage.tamil: 'தரவு அணுகல் & ஒப்புதல்', AppLanguage.telugu: 'డేటా యాక్సెస్ & సమ్మతి',
    },
    'exportProfile': {
      AppLanguage.english: 'Export Profile', AppLanguage.hindi: 'प्रोफ़ाइल एक्सपोर्ट करें',
      AppLanguage.tamil: 'சுயவிவரத்தை ஏற்றுமதி செய்', AppLanguage.telugu: 'ప్రొఫైల్ ఎగుమతి',
    },
    'revokeAccess': {
      AppLanguage.english: 'Revoke Access', AppLanguage.hindi: 'पहुंच रद्द करें',
      AppLanguage.tamil: 'அணுகலை ரத்து செய்', AppLanguage.telugu: 'యాక్సెస్ రద్దు',
    },
    'why': {
      AppLanguage.english: 'Why', AppLanguage.hindi: 'क्यों',
      AppLanguage.tamil: 'ஏன்', AppLanguage.telugu: 'ఎందుకు',
    },
    'decisionHistory': {
      AppLanguage.english: 'Decision history', AppLanguage.hindi: 'निर्णय इतिहास',
      AppLanguage.tamil: 'முடிவு வரலாறு', AppLanguage.telugu: 'నిర్ణయ చరిత్ర',
    },
    'whatAffectedDecision': {
      AppLanguage.english: 'What affected this decision', AppLanguage.hindi: 'इस निर्णय को किसने प्रभावित किया',
      AppLanguage.tamil: 'இந்த முடிவை பாதித்த காரணங்கள்', AppLanguage.telugu: 'ఈ నిర్ణయాన్ని ప్రభావితం చేసినవి',
    },
    'nextStep': {
      AppLanguage.english: 'Next step', AppLanguage.hindi: 'अगला कदम',
      AppLanguage.tamil: 'அடுத்த படி', AppLanguage.telugu: 'తదుపరి దశ',
    },
    'settings': {
      AppLanguage.english: 'Settings', AppLanguage.hindi: 'सेटिंग्स',
      AppLanguage.tamil: 'அமைப்புகள்', AppLanguage.telugu: 'సెట్టింగ్స్',
    },
  };

  static String of(AppLanguage language, String key) =>
      _values[key]?[language] ?? _values[key]?[AppLanguage.english] ?? key;
}

extension LocalizedBuildContext on BuildContext {
  String tr(String key) {
    final provider = dependOnInheritedWidgetOfExactType<_LanguageScope>();
    return AppStrings.of(provider?.language ?? AppLanguage.english, key);
  }
}

class LanguageScope extends StatelessWidget {
  const LanguageScope({super.key, required this.language, required this.child});
  final AppLanguage language;
  final Widget child;

  @override
  Widget build(BuildContext context) => _LanguageScope(language: language, child: child);
}

class _LanguageScope extends InheritedWidget {
  const _LanguageScope({required this.language, required super.child});
  final AppLanguage language;

  @override
  bool updateShouldNotify(_LanguageScope oldWidget) => language != oldWidget.language;
}
