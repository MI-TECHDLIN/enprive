import 'dart:convert';
import 'dart:io';

import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/l10n/enprive_languages.dart';
import 'package:enprive/screens/settings_screen.dart';
import 'package:enprive/services/platform/companion_bridge.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locales fully translated in this stage (expanded across D5.3-F PRs 1-3).
const List<String> _completedSecondaryLocales = [
  'ar',
  'de',
  'es',
  'fr',
  'hi',
  'it',
  'ja',
  'ko',
  'pt',
  'ru',
  'zh',
];

const List<String> _allSecondaryLocales = [
  'ar',
  'de',
  'es',
  'fr',
  'hi',
  'it',
  'ja',
  'ko',
  'pt',
  'ru',
  'zh',
];

final RegExp _placeholderRe = RegExp(r'\{([A-Za-z_][A-Za-z0-9_]*)\}');
final RegExp _icuHeaderRe = RegExp(
  r'^\{\s*([A-Za-z_][A-Za-z0-9_]*)\s*,\s*(plural|select)\s*,',
);

Set<String> _extractPlaceholders(String value) {
  final found = <String>{};
  final header = _icuHeaderRe.firstMatch(value);
  if (header != null) {
    found.add(header.group(1)!);
    var depth = 0;
    var i = header.end;
    while (i < value.length) {
      if (value[i] == '{') {
        depth++;
        if (depth == 1) {
          final start = i + 1;
          var j = start;
          var sub = 1;
          while (j < value.length && sub > 0) {
            if (value[j] == '{') sub++;
            if (value[j] == '}') sub--;
            j++;
          }
          final body = value.substring(start, j - 1);
          for (final m in _placeholderRe.allMatches(body)) {
            found.add(m.group(1)!);
          }
          i = j - 1;
          depth = 0;
        }
      }
      i++;
    }
    return found;
  }
  for (final m in _placeholderRe.allMatches(value)) {
    found.add(m.group(1)!);
  }
  return found;
}

Map<String, dynamic> _loadArb(String localeCode) {
  final file = File('lib/l10n/app_$localeCode.arb');
  if (!file.existsSync()) {
    throw StateError('Missing ARB file ${file.path}');
  }
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('D5.3-F ARB integrity and completeness', () {
    final enArb = _loadArb('en');
    final enKeys = enArb.keys.where((k) => !k.startsWith('@')).toList();

    test(
      'No ARB file (English or any secondary locale) contains em dashes',
      () {
        for (final code in ['en', ..._allSecondaryLocales]) {
          final arb = _loadArb(code);
          final offending = <String>[];
          for (final entry in arb.entries) {
            if (entry.key.startsWith('@')) continue;
            final val = entry.value.toString();
            if (val.contains('\u2014')) {
              offending.add(entry.key);
            }
          }
          expect(
            offending,
            isEmpty,
            reason: 'Em dash found in app_$code.arb: $offending',
          );
        }
      },
    );

    test('Every translated key in every locale matches English placeholder sets and has no extra keys', () {
      final enKeySet = enKeys.toSet();
      for (final code in _allSecondaryLocales) {
        final arb = _loadArb(code);
        final extraKeys = arb.keys
            .where((k) => !k.startsWith('@') && !enKeySet.contains(k))
            .toList();
        expect(
          extraKeys,
          isEmpty,
          reason: 'Unexpected extra keys in app_$code.arb: $extraKeys',
        );

        final mismatches = <String>[];
        for (final entry in arb.entries) {
          if (entry.key.startsWith('@')) continue;
          final val = entry.value.toString();
          expect(
            val.trim(),
            isNotEmpty,
            reason: 'Empty value for ${entry.key} in app_$code.arb',
          );
          final enPh = _extractPlaceholders(enArb[entry.key].toString());
          final locPh = _extractPlaceholders(val);
          if (enPh.length != locPh.length || !enPh.containsAll(locPh)) {
            mismatches.add('${entry.key}: EN=$enPh vs $code=$locPh');
          }
        }
        expect(
          mismatches,
          isEmpty,
          reason: 'Placeholder mismatches in app_$code.arb: $mismatches',
        );
      }
    });

    test('Every completed locale has every English key and valid localized lookups', () {
      for (final code in _completedSecondaryLocales) {
        final arb = _loadArb(code);
        final missing = enKeys.where((k) => !arb.containsKey(k)).toList();
        expect(
          missing,
          isEmpty,
          reason:
              'app_$code.arb is missing ${missing.length} keys: '
              '${missing.take(10).toList()}',
        );

        final l10n = lookupAppLocalizations(Locale(code));
        expect(l10n.translationDraftNotice.trim(), isNotEmpty);
        expect(
          l10n.translationDraftNotice,
          isNot(enArb['translationDraftNotice']),
        );
        expect(l10n.cloudConsentDisclosure.trim(), isNotEmpty);
        expect(l10n.statusSourceMatched.trim(), isNotEmpty);
        expect(l10n.statusDeviceObserved.trim(), isNotEmpty);
        expect(l10n.statusInterpretation.trim(), isNotEmpty);
        expect(l10n.statusUnverified.trim(), isNotEmpty);
        expect(l10n.verifiedClausesCount(1), isNotEmpty);
        expect(l10n.verifiedClausesCount(5), isNotEmpty);
        expect(l10n.consentMaskedCount(0), isNotEmpty);
        expect(l10n.consentMaskedCount(1), isNotEmpty);
        expect(l10n.consentMaskedCount(3), isNotEmpty);
        expect(l10n.permissionComparisonMismatchNote(1), isNotEmpty);
        expect(l10n.permissionComparisonMismatchNote(4), isNotEmpty);
        expect(l10n.learnLessonStepCount(1), isNotEmpty);
        expect(l10n.learnLessonStepCount(5), isNotEmpty);
      }
    });

    test('All 12 supported locales are registered in kEnpriveLanguages', () {
      expect(kEnpriveLanguages.length, 12);
      for (final lang in kEnpriveLanguages) {
        expect(AppLocalizations.delegate.isSupported(lang.locale), isTrue);
      }
    });
  });

  group('Settings AI-translation draft notice', () {
    testWidgets(
      'renders calm translation draft note in English and Arabic RTL at 200% text without overflow',
      (WidgetTester tester) async {
        for (final locale in const [Locale('en'), Locale('ar')]) {
          final expected = lookupAppLocalizations(locale)
              .translationDraftNotice;
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MediaQuery(
                data: const MediaQueryData(
                  size: Size(360, 800),
                  textScaler: TextScaler.linear(2.0),
                  disableAnimations: true,
                ),
                child: Scaffold(
                  body: SettingsScreen(
                    bridge: HybridAiBridge(),
                    companionBridge: CompanionBridge(),
                    capability: null,
                    explanationDepth: ExplanationDepth.balanced,
                    currentLocale: locale,
                    savedReceiptsCount: 0,
                    onExplanationDepthChanged: (_) {},
                    onLocaleChanged: (_) {},
                    onRefreshCapability: () {},
                    onClearAllReceipts: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          final noteFinder = find.byKey(
            const Key('settings_translation_draft_note'),
          );
          expect(noteFinder, findsOneWidget);
          expect(find.text(expected), findsOneWidget);
          expect(
            find.text(lookupAppLocalizations(locale).appearanceSectionTitle),
            findsOneWidget,
          );
          expect(
            find.text(lookupAppLocalizations(locale).quickSettingsSectionTitle),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'CloudConsentSheet localizes known deviceReason strings in Arabic',
      (WidgetTester tester) async {
        final arL10n = lookupAppLocalizations(const Locale('ar'));
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: CloudConsentSheet(
                subjectTitle: 'Demo App',
                policyText: 'We collect your device identifier for analytics.',
                deviceReason:
                    'This policy is too detailed for on-device AI processing.',
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text(arL10n.consentReasonPolicyTooDetailed),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
