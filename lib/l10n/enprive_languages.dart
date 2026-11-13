import 'package:flutter/material.dart';

/// Metadata for a user-selectable Enprive display and analysis language.
class EnpriveLanguageOption {
  final String code;
  final String nativeName;
  final String englishName;
  final String shortBadge;
  final String bcp47Tag;

  const EnpriveLanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.shortBadge,
    required this.bcp47Tag,
  });

  Locale get locale => Locale(code);
  bool get isRtl => code == 'ar';
}

/// All 12 languages supported locally via `.arb` bundles and by Cloud Gemini.
const List<EnpriveLanguageOption> kEnpriveLanguages = [
  EnpriveLanguageOption(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    shortBadge: 'EN',
    bcp47Tag: 'en-US',
  ),
  EnpriveLanguageOption(
    code: 'ko',
    nativeName: '한국어',
    englishName: 'Korean',
    shortBadge: '한국어',
    bcp47Tag: 'ko-KR',
  ),
  EnpriveLanguageOption(
    code: 'es',
    nativeName: 'Español',
    englishName: 'Spanish',
    shortBadge: 'ES',
    bcp47Tag: 'es-ES',
  ),
  EnpriveLanguageOption(
    code: 'fr',
    nativeName: 'Français',
    englishName: 'French',
    shortBadge: 'FR',
    bcp47Tag: 'fr-FR',
  ),
  EnpriveLanguageOption(
    code: 'de',
    nativeName: 'Deutsch',
    englishName: 'German',
    shortBadge: 'DE',
    bcp47Tag: 'de-DE',
  ),
  EnpriveLanguageOption(
    code: 'ar',
    nativeName: 'العربية',
    englishName: 'Arabic',
    shortBadge: 'AR',
    bcp47Tag: 'ar-SA',
  ),
  EnpriveLanguageOption(
    code: 'ja',
    nativeName: '日本語',
    englishName: 'Japanese',
    shortBadge: '日本語',
    bcp47Tag: 'ja-JP',
  ),
  EnpriveLanguageOption(
    code: 'zh',
    nativeName: '简体中文',
    englishName: 'Chinese',
    shortBadge: '中文',
    bcp47Tag: 'zh-CN',
  ),
  EnpriveLanguageOption(
    code: 'hi',
    nativeName: 'हिन्दी',
    englishName: 'Hindi',
    shortBadge: 'HI',
    bcp47Tag: 'hi-IN',
  ),
  EnpriveLanguageOption(
    code: 'pt',
    nativeName: 'Português',
    englishName: 'Portuguese',
    shortBadge: 'PT',
    bcp47Tag: 'pt-BR',
  ),
  EnpriveLanguageOption(
    code: 'it',
    nativeName: 'Italiano',
    englishName: 'Italian',
    shortBadge: 'IT',
    bcp47Tag: 'it-IT',
  ),
  EnpriveLanguageOption(
    code: 'ru',
    nativeName: 'Русский',
    englishName: 'Russian',
    shortBadge: 'RU',
    bcp47Tag: 'ru-RU',
  ),
];

/// Resolves [languageCode] to its configured [EnpriveLanguageOption], falling back to English.
EnpriveLanguageOption enpriveLanguageByCode(String languageCode) {
  final normalized = languageCode.toLowerCase().split(RegExp(r'[-_]')).first;
  for (final option in kEnpriveLanguages) {
    if (option.code == normalized) {
      return option;
    }
  }
  return kEnpriveLanguages.first;
}
