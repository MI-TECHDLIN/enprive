import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/l10n/enprive_languages.dart';
import 'package:enprive/main.dart';
import 'package:enprive/screens/onboarding_flow_screen.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/screens/splash_screen.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/analysis_process_trace.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/installed_app_icon.dart';
import 'package:enprive/widgets/installed_app_picker_sheet.dart';
import 'package:enprive/widgets/review_progress_sheet.dart';
import 'package:enprive/widgets/why_this_finding_sheet.dart';

import 'fixtures/synthetic_test_fixtures.dart';

Future<void> _flushBridgeAndPump(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> recordedCalls = [];

  setUp(() {
    rootBundle.clear();
    recordedCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.enprive/hybrid_ai'),
          (call) async {
            recordedCalls.add(call);
            if (call.method == 'getDeviceCapability') {
              return {
                'isSupported': true,
                'modelStatus': 'AVAILABLE',
                'modelCategory': 'PREVIEW',
                'apiLevel': 34,
                'userMessage': 'Gemini Nano 4 is ready on this device.',
              };
            }
            if (call.method == 'getInitialSelectedText') {
              return null;
            }
            if (call.method == 'speakText' || call.method == 'stopSpeaking') {
              return true;
            }
            return null;
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.enprive/hybrid_ai'),
          null,
        );
  });

  testWidgets(
    'EnpriveApp renders brand splash first then clean Home hero and what-we-check content without built-in sample apps',
    (WidgetTester tester) async {
      await tester.pumpWidget(const EnpriveApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('enprive'), findsOneWidget);
      expect(find.text("Know what you're agreeing to"), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1450));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Enprive'), findsOneWidget);
      final appBarLogo = tester.widget<Image>(
        find.descendant(of: find.byType(AppBar), matching: find.byType(Image)),
      );
      expect(
        (appBarLogo.image as AssetImage).assetName,
        'assets/images/enprive_logo.png',
      );
      expect(find.text('Check'), findsOneWidget);
      expect(find.text('Receipts'), findsWidgets);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.byKey(const Key('nav_settings_btn')), findsOneWidget);
      expect(find.byKey(const Key('check_quick_settings_card')), findsOneWidget);
      expect(find.text('Try a sample app check'), findsNothing);
      expect(find.text('EduTrack Classroom'), findsNothing);
      expect(find.text('CalmMath Kids'), findsNothing);
      expect(find.text('Sample app'), findsNothing);
      expect(find.text('What we check for'), findsOneWidget);
      expect(find.text('Exact policy quotes'), findsOneWidget);
      expect(find.textContaining('Deni ·'), findsNothing);
      expect(find.text('Thinking'), findsNothing);
    },
  );

  testWidgets(
    'EnpriveApp renders cleanly at 200% text scale and reduced motion across splash and tabs',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(2.0),
            disableAnimations: true,
          ),
          child: EnpriveApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('enprive'), findsOneWidget);
      expect(find.text("Know what you're agreeing to"), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Enprive'), findsOneWidget);

      // Open Settings secondary route at 200% text scale
      await tester.tap(find.byKey(const Key('nav_settings_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Show Deni companion'), findsNothing);
    },
  );

  testWidgets(
    'EnpriveSplashScreen localizes quote across languages and dismisses on tap',
    (WidgetTester tester) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EnpriveSplashScreen(onCompleted: () => completed = true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final arQuote = lookupAppLocalizations(const Locale('ar')).splashQuote;
      expect(find.text('enprive'), findsOneWidget);
      expect(find.text(arQuote), findsOneWidget);

      await tester.tap(find.text('enprive'));
      await tester.pump();
      expect(completed, isTrue);
    },
  );

  test(
    'HybridAiBridge speakText and stopSpeaking invoke native TTS channel',
    () async {
      final bridge = HybridAiBridge();
      final spoke = await bridge.speakText(
        'No concern identified in the reviewed evidence.',
        languageCode: 'en',
      );
      expect(spoke, isTrue);
      expect(recordedCalls.any((c) => c.method == 'speakText'), isTrue);

      final stopped = await bridge.stopSpeaking();
      expect(stopped, isTrue);
      expect(recordedCalls.any((c) => c.method == 'stopSpeaking'), isTrue);
    },
  );

  testWidgets('OnboardingFlowScreen navigates across all 3 B2-B3-B19 steps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingFlowScreen(
          initialDepth: ExplanationDepth.balanced,
          initialLocale: Locale('en'),
        ),
      ),
    );
    await tester.pump();

    // Step 0 (B2 Mascot Intro — clean Deni greeting without body card)
    expect(find.text("Hi, I'm Deni. 👋"), findsOneWidget);
    expect(
      find.text("Let's make app privacy easier to understand."),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        "I'll help you uncover what an app's privacy policy really says",
      ),
      findsNothing,
    );
    expect(find.text("Know what you're agreeing to."), findsNothing);

    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 300));

    // Step 1 (B3 Question Cards)
    expect(find.textContaining('How should I explain'), findsOneWidget);
    await tester.tap(find.textContaining('Quick &'));
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 300));

    // Step 2 (B19 Private Readiness)
    expect(find.textContaining('Private by default'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets(
    'ReviewProgressCard renders calm single-button reviewing status and subject title',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReviewProgressCard(
              subjectTitle: 'EduTrack Classroom Companion',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('EduTrack Classroom Companion'), findsOneWidget);
      expect(find.text('Reviewing on this phone.'), findsOneWidget);

      // Cloud mode renders accurate cloud progress messaging + real Cancel action
      var cancelTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReviewProgressCard(
              subjectTitle: 'Cloud Target App',
              isCloudCheck: true,
              onCancel: () => cancelTapped = true,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Checking policy with cloud AI.'), findsOneWidget);
      expect(find.text('Reviewing on this phone.'), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey<String>('review_progress_cancel_btn')),
      );
      expect(cancelTapped, isTrue);
    },
  );

  testWidgets(
    'ReviewProgressCard renders streamed process steps, thoughts, and thought signature',
    (WidgetTester tester) async {
      final controller = StreamController<AnalysisStreamEvent>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewProgressCard(
              subjectTitle: 'EduTrack',
              processStream: controller.stream,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.text('Reading policy text on this phone…'),
        findsOneWidget,
      );

      controller.add(
        AnalysisStreamEvent(
          requestId: 'req_1',
          stage: 'streaming_thoughts',
          label: 'Streaming reasoning & thought signature',
          thoughtSummary: 'Verifying sharing clause verbatim boundaries.',
          thoughtSignature: 'sig_1234567890abcdef',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Reading policy text on this phone…'), findsNothing);
      expect(
        find.text('Streaming reasoning & thought signature'),
        findsOneWidget,
      );
      expect(
        find.text('Verifying sharing clause verbatim boundaries.'),
        findsOneWidget,
      );
      expect(find.textContaining('Check ID'), findsNothing);
    },
  );

  testWidgets(
    'AnalysisSavedTraceCard displays completed steps, signature, and toggles thoughts',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnalysisSavedTraceCard(
              processSteps: [
                'Masked 2 personal details with placeholders',
                'Streaming reasoning via Firebase App Check',
              ],
              thoughtSummary: 'Matched clause about ad network telemetry.',
              thoughtSignature: 'sig_abcdef1234567890',
            ),
          ),
        ),
      );

      expect(find.text('2 steps'), findsOneWidget);
      expect(
        find.text('Streaming reasoning via Firebase App Check'),
        findsOneWidget,
      );
      expect(
        find.text('Masked 2 personal details with placeholders'),
        findsNothing,
      );
      expect(find.textContaining('Check ID:'), findsNothing);
      expect(find.text('How Enprive checked this'), findsOneWidget);
      expect(
        find.text('Matched clause about ad network telemetry.'),
        findsNothing,
      );

      await tester.tap(find.text('How Enprive checked this'));
      await tester.pump();

      expect(find.text('Hide how Enprive checked this'), findsOneWidget);
      expect(
        find.text('Matched clause about ad network telemetry.'),
        findsOneWidget,
      );
      expect(find.textContaining('Check ID:'), findsOneWidget);
    },
  );

  test('All 12 requested languages are configured locally and propagate to Cloud Gemini & disclaimer', () async {
    const expectedCodes = [
      'en',
      'ko',
      'es',
      'fr',
      'de',
      'ar',
      'ja',
      'zh',
      'hi',
      'pt',
      'it',
      'ru',
    ];
    expect(kEnpriveLanguages.length, expectedCodes.length);
    expect(
      kEnpriveLanguages.map((e) => e.code).toList(),
      equals(expectedCodes),
    );

    for (final lang in kEnpriveLanguages) {
      expect(AppLocalizations.delegate.isSupported(lang.locale), isTrue);
      expect(
        AppLocalizations.supportedLocales.any(
          (supported) => supported.languageCode == lang.code,
        ),
        isTrue,
      );
      final l10n = lookupAppLocalizations(lang.locale);
      expect(l10n.onboardingIntroHeadline.trim(), isNotEmpty);
      expect(l10n.onboardingIntroLead.trim(), isNotEmpty);
      expect(l10n.onboardingIntroBody.trim(), isNotEmpty);
      expect(l10n.onboardingIntroFooter.trim(), isNotEmpty);
      expect(l10n.stateNoConcernSubtitle.trim(), isNotEmpty);
      expect(l10n.progressStepCounter(1, 4).trim(), isNotEmpty);
      expect(l10n.chooseLanguage.trim(), isNotEmpty);
      expect(l10n.btnCheckApp.trim(), isNotEmpty);
      expect(l10n.btnPasteTerms.trim(), isNotEmpty);
      if (lang.code != 'en') {
        expect(
          l10n.onboardingIntroLead,
          isNot("Let's make app privacy easier to understand."),
        );
      }
    }

    // Verify HybridAiBridge.analyseText forwards languageCode to native Kotlin/Cloud prompt
    final bridge = HybridAiBridge();
    await bridge.analyseText(
      requestId: 'req_lang_test',
      task: 'summarise_concerns',
      text: 'Sample child app privacy policy clause.',
      cloudConsent: false,
      languageCode: 'fr',
    );
    final analyseCall = recordedCalls.lastWhere(
      (c) => c.method == 'analyseText',
    );
    expect(analyseCall.arguments['languageCode'], 'fr');

    // Verify ReviewCoordinator applies localized calibrated disclaimer while preserving evidence
    final coordinator = ReviewCoordinator(bridge: bridge);
    final outcome = await coordinator.runPolicyReview(
      subjectTitle: 'CalmMath',
      sourceLabel: 'Test Snapshot',
      policyText: 'We do not collect personal data from children and keep lessons stored exclusively on this device.',
      forceLocalManualScan: true,
      languageCode: 'es',
    );
    expect(outcome.receipt, isNotNull);
    expect(outcome.receipt!.overallState, ReviewOverallState.noConcern);
    expect(
      outcome.receipt!.calibratedDisclaimer,
      lookupAppLocalizations(const Locale('es')).stateNoConcernSubtitle,
    );
  });

  testWidgets(
    'OnboardingFlowScreen opens 12-language picker and applies Arabic RTL cleanly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OnboardingFlowScreen(
            initialDepth: ExplanationDepth.balanced,
            initialLocale: Locale('en'),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('EN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Ensure all 12 language options render cleanly and switch to Arabic
      expect(find.text('Español'), findsOneWidget);
      final arabicFinder = find.text('العربية');
      await tester.dragUntilVisible(
        arabicFinder,
        find.byType(ListView),
        const Offset(0, -150),
      );
      await tester.pump();
      await tester.tap(arabicFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final arL10n = lookupAppLocalizations(const Locale('ar'));
      expect(find.text(arL10n.onboardingIntroHeadline), findsOneWidget);
      expect(find.text(arL10n.onboardingIntroLead), findsOneWidget);
      expect(find.text(arL10n.onboardingIntroBody), findsNothing);
      expect(
        Directionality.of(
          tester.element(find.text(arL10n.onboardingIntroHeadline)),
        ),
        TextDirection.rtl,
      );
    },
  );

  testWidgets(
    'ReviewProgressCard advances 4-step milestone counter and handles 200% text scaling + Arabic RTL',
    (WidgetTester tester) async {
      final controller = StreamController<AnalysisStreamEvent>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReviewProgressCard(
              subjectTitle: 'EduTrack Classroom Companion',
              processStream: controller.stream,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('1 of 4'), findsOneWidget);

      controller.add(
        AnalysisStreamEvent(
          requestId: 'rev_1',
          stage: 'redacting_pii',
          label: 'Masked 1 personal detail with placeholders',
        ),
      );
      await tester.pump();
      expect(find.text('2 of 4'), findsOneWidget);

      controller.add(
        AnalysisStreamEvent(
          requestId: 'rev_1',
          stage: 'streaming_thoughts',
          label: 'Streaming reasoning with App Check protection',
          inferenceSource: 'IN_CLOUD',
        ),
      );
      await tester.pump();
      expect(find.text('3 of 4'), findsOneWidget);

      controller.add(
        AnalysisStreamEvent(
          requestId: 'rev_1',
          stage: 'verifying_evidence',
          label: 'Matching verbatim quotes in policy',
          isCompleted: true,
        ),
      );
      await tester.pump();
      expect(find.text('4 of 4'), findsOneWidget);

      // Verify Arabic RTL + 200% font scale fits cleanly without overflow exceptions
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 720),
              textScaler: TextScaler.linear(2.0),
            ),
            child: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: ReviewProgressCard(
                  subjectTitle: 'EduTrack Classroom Companion',
                  isCloudCheck: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final arCounter = lookupAppLocalizations(const Locale('ar'))
          .progressStepCounter(1, 4);
      expect(find.text(arCounter), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'EnpriveProvenanceChip renders all five provenance variants accurately',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Column(
              children: [
                EnpriveProvenanceChip(source: InferenceSource.onDevice),
                EnpriveProvenanceChip(source: InferenceSource.inCloud),
                EnpriveProvenanceChip(
                  source: InferenceSource.offlineDeterministic,
                ),
                EnpriveProvenanceChip(source: InferenceSource.unknown),
                EnpriveProvenanceChip(
                  source: InferenceSource.locationUnavailable,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('On this device'), findsOneWidget);
      expect(find.text('In the cloud'), findsOneWidget);
      expect(find.text('Checked offline on this phone'), findsOneWidget);
      expect(find.text('Source unknown'), findsOneWidget);
      expect(find.text('Source not available'), findsOneWidget);
    },
  );

  testWidgets(
    'CloudConsentSheet displays complete untruncated scrubbed PII preview and deviceReason',
    (WidgetTester tester) async {
      final longTail =
          '${'Detailed classroom diagnostics clause. ' * 6}'
          'FINAL_VERIFIED_CLAUSE_END_MARKER';
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CloudConsentSheet(
              subjectTitle: 'EduTrack Classroom',
              policyText:
                  'Parent: Maya Lin (maya@school.edu, +1 415-555-0199). $longTail',
              deviceReason: 'On-device AI unavailable right now.',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('On-device AI unavailable right now.'), findsOneWidget);
      final previewWidget = tester.widget<SelectableText>(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.byType(SelectableText),
        ),
      );
      expect(
        previewWidget.data ?? previewWidget.textSpan?.toPlainText(),
        equals('Parent: [PERSON] ([EMAIL], [PHONE]). $longTail'),
      );
      expect(find.textContaining('[PERSON]'), findsAtLeastNWidgets(1));
      expect(find.textContaining('[EMAIL]'), findsAtLeastNWidgets(1));
      expect(find.textContaining('[PHONE]'), findsAtLeastNWidgets(1));
      expect(
        find.textContaining('FINAL_VERIFIED_CLAUSE_END_MARKER'),
        findsOneWidget,
      );
      expect(find.textContaining('Maya Lin'), findsNothing);
      expect(find.textContaining('maya@school.edu'), findsNothing);
      expect(find.textContaining('415-555-0199'), findsNothing);
    },
  );

  testWidgets(
    'Home review opens CloudConsentSheet when on-device AI is unavailable, blocks unconsented cloud, and supports local scan & explicit cloud choice',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'enprive_pref_completed_onboarding': true,
      });

      final analyseCalls = <Map<String, dynamic>>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.enprive/hybrid_ai'),
            (call) async {
              recordedCalls.add(call);
              if (call.method == 'getDeviceCapability') {
                return {
                  'isSupported': false,
                  'modelStatus': 'UNAVAILABLE',
                  'modelCategory': 'NONE',
                  'apiLevel': 34,
                  'userMessage': 'Gemini Nano unavailable on emulator.',
                };
              }
              if (call.method == 'getInitialSelectedText') {
                return null;
              }
              if (call.method == 'listLaunchableApps') {
                return const [];
              }
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                analyseCalls.add(args);
                if (args['cloudConsent'] != true) {
                  return {
                    'schemaVersion': 1,
                    'requestId': args['requestId'],
                    'status': 'unavailable',
                    'inferenceSource': 'UNKNOWN',
                    'message': 'On-device model unavailable on emulator.',
                  };
                }
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'IN_CLOUD',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary': 'Reviewed via consented cloud check.',
                    'concerns': const [],
                    'calibratedDisclaimer':
                        ReviewCoordinator.calibratedDefaultDisclaimer,
                  },
                };
              }
              return null;
            },
          );

      await tester.pumpWidget(
        const EnpriveApp(
          showSplashOnLaunch: false,
          splashDuration: Duration.zero,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      // Dismiss splash or onboarding cleanly if visible
      if (find.text('enprive').evaluate().isNotEmpty) {
        await tester.tap(find.text('enprive'), warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }
      if (find.text('Continue').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      Future<void> submitPastedPolicy(String policyText) async {
        final pasteBtn = find.text('Paste terms or URL');
        await Scrollable.ensureVisible(
          tester.element(pasteBtn),
          alignment: 0.5,
        );
        await tester.pump();
        await tester.tap(pasteBtn);
        await _flushBridgeAndPump(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          policyText,
        );
        final submitBtn = find.byKey(const Key('intake_primary_submit_btn'));
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _flushBridgeAndPump(tester);
      }

      // 1. Trigger concise policy via Paste -> tries ONLY_ON_DEVICE once,
      // fails on unavailable Nano, and opens CloudConsentSheet without any cloud call
      await submitPastedPolicy(syntheticCalmMathPolicy);

      expect(analyseCalls.length, 1);
      expect(analyseCalls.single['cloudConsent'], isFalse);
      expect(analyseCalls.single['requestedMode'], 'ONLY_ON_DEVICE');
      expect(find.byType(CloudConsentSheet), findsOneWidget);
      expect(
        find.text('On-device model unavailable on emulator.'),
        findsOneWidget,
      );

      // 2. Cancel -> zero cloud calls occur
      await tester.tap(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.byTooltip('Close'),
        ),
      );
      await _flushBridgeAndPump(tester);
      expect(analyseCalls.length, 1);

      // 3. Re-trigger and pick "Review on this phone" -> Offline local scan (still 0 cloud calls)
      await submitPastedPolicy(syntheticCalmMathPolicy);
      expect(analyseCalls.length, 2);
      expect(analyseCalls[1]['cloudConsent'], isFalse);

      final reviewOnPhoneBtn = find.text('Review on this phone');
      await Scrollable.ensureVisible(
        tester.element(reviewOnPhoneBtn),
        alignment: 0.5,
      );
      await tester.pump();
      await tester.tap(reviewOnPhoneBtn);
      await _flushBridgeAndPump(tester);

      expect(find.text('Checked offline on this phone'), findsOneWidget);
      expect(analyseCalls.where((c) => c['cloudConsent'] == true), isEmpty);

      // Navigate back to Home
      await tester.tap(find.byTooltip('Close').last);
      await _flushBridgeAndPump(tester);
      await tester.tap(find.text('Discard without saving'));
      await _flushBridgeAndPump(tester);

      // 4. Trigger again and explicitly choose "Use cloud for this check"
      await submitPastedPolicy(syntheticCalmMathPolicy);

      final homePreviewWidget = tester.widget<SelectableText>(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.byType(SelectableText),
        ),
      );
      final displayedHomePayload =
          homePreviewWidget.data ?? homePreviewWidget.textSpan?.toPlainText();

      final useCloudBtn = find.text('Use cloud for this check');
      await Scrollable.ensureVisible(
        tester.element(useCloudBtn),
        alignment: 0.5,
      );
      await tester.pump();
      await tester.tap(useCloudBtn);
      await _flushBridgeAndPump(tester);

      expect(find.text('In the cloud'), findsOneWidget);
      final cloudCalls = analyseCalls
          .where((c) => c['cloudConsent'] == true)
          .toList();
      expect(cloudCalls.length, 1);
      expect(cloudCalls.single['requestedMode'], 'ONLY_IN_CLOUD');
      expect(cloudCalls.single['text'], equals(displayedHomePayload));

      // Navigate back to Home and verify comprehensive policy pauses BEFORE
      // even calling native analyseText (0 calls without consent)
      await tester.tap(find.byTooltip('Close').last);
      await _flushBridgeAndPump(tester);
      await tester.tap(find.text('Discard without saving'));
      await _flushBridgeAndPump(tester);
      await submitPastedPolicy(syntheticEduTrackPolicy);
      expect(find.byType(CloudConsentSheet), findsOneWidget);
      expect(analyseCalls.length, 4);
    },
  );

  testWidgets(
    'WhyThisFindingSheet requires explicit CloudConsentSheet before cloud Deni call and enforces per-check consent',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final analyseCalls = <Map<String, dynamic>>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.enprive/hybrid_ai'),
            (call) async {
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                analyseCalls.add(args);
                if (args['cloudConsent'] != true) {
                  return {
                    'schemaVersion': 1,
                    'requestId': args['requestId'],
                    'status': 'unavailable',
                    'inferenceSource': 'UNKNOWN',
                    'message': 'Nano cannot explain offline.',
                  };
                }
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'IN_CLOUD',
                  'structuredOutput': {
                    'answer': 'Consented cloud explanation.',
                    'whatPolicySays': 'Shares ad IDs.',
                    'unknownBoundary': 'Opt-out scope not detailed.',
                  },
                };
              }
              return null;
            },
          );

      final coordinator = ReviewCoordinator();
      const finding = VerifiedFinding(
        id: 'f1',
        title: 'Ad Tracking',
        category: FindingCategory.tracking,
        severity: FindingSeverity.medium,
        exactExcerpt: 'Shares ad IDs.',
        explanation: 'Default local explanation.',
        whatPolicySays: 'Shares ad IDs.',
        whatAndroidReports: 'Text-only review.',
        unknowns: ['Opt-out scope not detailed.'],
        status: EvidenceStatus.sourceMatched,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WhyThisFindingSheet(
              finding: finding,
              snapshotText:
                  'Parent: Sara Bell (sara@school.edu). Shares ad IDs.',
              snapshotDigest: 'digest_1',
              coordinator: coordinator,
            ),
          ),
        ),
      );
      await tester.pump();

      // 1. Tap preset question -> tries ONLY_ON_DEVICE -> pauses with CloudConsentSheet
      final q1Finder = find.text('What does this mean for my child?');
      await Scrollable.ensureVisible(tester.element(q1Finder), alignment: 0.5);
      await tester.pump();
      await tester.tap(q1Finder);
      await _flushBridgeAndPump(tester);

      expect(analyseCalls.length, 1);
      expect(analyseCalls.single['cloudConsent'], isFalse);
      expect(find.byType(CloudConsentSheet), findsOneWidget);
      expect(find.text('Nano cannot explain offline.'), findsOneWidget);

      // 2. Choose "Review on this phone" -> deterministic offline answer, 0 cloud calls
      final reviewOnPhoneBtn = find.text('Review on this phone');
      await Scrollable.ensureVisible(
        tester.element(reviewOnPhoneBtn),
        alignment: 0.5,
      );
      await tester.pump();
      await tester.tap(reviewOnPhoneBtn);
      await _flushBridgeAndPump(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('Deni’s Answer'), findsOneWidget);
      expect(find.text('Checked offline on this phone'), findsOneWidget);
      expect(analyseCalls.where((c) => c['cloudConsent'] == true), isEmpty);

      // 3. Ask another question and approve "Use cloud for this check"
      final q2Finder = find.text('What is still unknown here?');
      await Scrollable.ensureVisible(tester.element(q2Finder), alignment: 0.5);
      await tester.pump();
      await tester.tap(q2Finder);
      await _flushBridgeAndPump(tester);
      expect(find.byType(CloudConsentSheet), findsOneWidget);

      final deniPreviewWidget = tester.widget<SelectableText>(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.byType(SelectableText),
        ),
      );
      final displayedDeniPayload =
          deniPreviewWidget.data ?? deniPreviewWidget.textSpan?.toPlainText();

      final useCloudBtn = find.text('Use cloud for this check');
      await Scrollable.ensureVisible(
        tester.element(useCloudBtn),
        alignment: 0.5,
      );
      await tester.pump();
      await tester.tap(useCloudBtn);
      await _flushBridgeAndPump(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('Consented cloud explanation.'), findsOneWidget);
      expect(find.text('In the cloud'), findsOneWidget);
      final cloudCalls = analyseCalls
          .where((c) => c['cloudConsent'] == true)
          .toList();
      expect(cloudCalls.length, 1);
      expect(cloudCalls.single['requestedMode'], 'ONLY_IN_CLOUD');
      expect(cloudCalls.single['text'], equals(displayedDeniPayload));
      expect(cloudCalls.single['text'], isNot(contains('Sara Bell')));
      expect(cloudCalls.single['text'], isNot(contains('sara@school.edu')));

      // 4. Subsequent question still requires explicit consent (per-check gate)
      final q3Finder = find.text('Can we turn this off or opt out?');
      await Scrollable.ensureVisible(tester.element(q3Finder), alignment: 0.5);
      await tester.pump();
      await tester.tap(q3Finder);
      await _flushBridgeAndPump(tester);
      expect(find.byType(CloudConsentSheet), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.byTooltip('Close'),
        ),
      );
      await _flushBridgeAndPump(tester);
      expect(analyseCalls.where((c) => c['cloudConsent'] == true).length, 1);
    },
  );

  testWidgets(
    'P0-B: real installed app defaults to Device Permission Inspection without synthetic policy and compares only after user supplies genuine policy',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'enprive_pref_completed_onboarding': true,
      });

      final nativeCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.enprive/hybrid_ai'),
            (call) async {
              nativeCalls.add(call);
              if (call.method == 'getDeviceCapability') {
                return {
                  'isSupported': true,
                  'deviceTier': 'SUPPORTED',
                  'modelStatus': 'AVAILABLE',
                };
              }
              if (call.method == 'listLaunchableApps') {
                return [
                  {
                    'packageName': 'com.example.reader',
                    'appName': 'Focus Reader',
                    'isSystemApp': false,
                  },
                ];
              }
              if (call.method == 'inspectSelectedApp') {
                return {
                  'packageName': 'com.example.reader',
                  'appName': 'Focus Reader',
                  'versionName': '2.1.0',
                  'requestedPermissions': [
                    'android.permission.CAMERA',
                    'android.permission.INTERNET',
                  ],
                  'grantedPermissions': ['android.permission.CAMERA'],
                };
              }
              if (call.method == 'analyseText') {
                return {
                  'schemaVersion': 1,
                  'requestId': (call.arguments as Map)['requestId'],
                  'status': 'success',
                  'inferenceSource': 'ON_DEVICE',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary': 'No collection claims in policy.',
                    'concerns': [],
                  },
                };
              }
              return null;
            },
          );

      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const EnpriveApp(showSplashOnLaunch: false));
      await _flushBridgeAndPump(tester);

      // No built-in sample apps shown on Home
      expect(find.text('Sample app'), findsNothing);

      final checkAppBtn = find.text('Check an app');
      await tester.ensureVisible(checkAppBtn);
      await tester.pump();
      await tester.tap(checkAppBtn);
      await _flushBridgeAndPump(tester);
      await _flushBridgeAndPump(tester);
      expect(find.byType(InstalledAppPickerSheet), findsOneWidget);

      // Installed app list renders Focus Reader
      final readerTile = find.text('Focus Reader');
      await tester.ensureVisible(readerTile);
      await tester.pump();
      await tester.tap(readerTile);
      await _flushBridgeAndPump(tester);
      await _flushBridgeAndPump(tester);

      // Opens Phone permissions checked directly with 0 analyseText AI calls
      expect(find.byType(ReviewResultScreen), findsOneWidget);
      expect(find.text('Phone permissions checked'), findsWidgets);
      expect(find.text('Allowed on this phone'), findsWidgets);
      expect(find.text('Not allowed'), findsWidgets);
      expect(find.text('View reviewed policy text'), findsNothing);
      expect(nativeCalls.where((c) => c.method == 'analyseText'), isEmpty);

      // Tap optional CTA "Add this app's privacy policy"
      final addPolicyBtn = find.text("Add this app's privacy policy").last;
      await tester.ensureVisible(addPolicyBtn);
      await tester.pump();
      await tester.tap(addPolicyBtn);
      await _flushBridgeAndPump(tester);

      // Placeholder stub is rejected inline
      final policyField = find.byKey(const Key('intake_paste_field'));
      final submitBtn = find.byKey(const Key('intake_primary_submit_btn'));
      await tester.enterText(policyField, 'Privacy notice unavailable.');
      await tester.tap(submitBtn);
      await tester.pump();
      expect(find.textContaining('placeholder'), findsAtLeastNWidgets(1));
      expect(nativeCalls.where((c) => c.method == 'analyseText'), isEmpty);

      // Genuine supplied policy runs policy-to-permission comparison
      await tester.enterText(
        policyField,
        'Focus Reader stores books locally and does not use your camera or upload analytics.',
      );
      await tester.tap(submitBtn);
      await _flushBridgeAndPump(tester);
      await _flushBridgeAndPump(tester);

      expect(nativeCalls.where((c) => c.method == 'analyseText').length, 1);
    },
  );

  testWidgets(
    'P0-C, P0-E & Section 7: CloudConsentSheet copy/safe layout, FNV-1a digest sheet & copy, and calibrated noConcern subtitles',
    (WidgetTester tester) async {
      String? copiedDigest;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copiedDigest =
                  (call.arguments as Map<dynamic, dynamic>)['text'] as String?;
            }
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      // Section 7 calibrated strings in English & French
      final enL10n = lookupAppLocalizations(const Locale('en'));
      final frL10n = lookupAppLocalizations(const Locale('fr'));
      expect(
        enL10n.stateNoConcernSubtitle,
        equals(
          'No concern identified in the reviewed evidence. This is not a safety certification.',
        ),
      );
      expect(
        frL10n.stateNoConcernSubtitle.toLowerCase(),
        contains('certification'),
      );

      // P0-C CloudConsentSheet.show copy and layout
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: ThemeMode.dark,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
            child: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    CloudConsentSheet.show(
                      ctx,
                      subjectTitle: 'CalmMath',
                      policyText:
                          'Contact: alex@example.com or Device ID: 998877.',
                      deviceReason: 'On-device AI is downloading.',
                    );
                  },
                  child: const Text('Open Consent'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Consent'));
      await _flushBridgeAndPump(tester);

      expect(find.byType(CloudConsentSheet), findsOneWidget);
      expect(find.textContaining('shown above'), findsOneWidget);
      expect(find.textContaining('shown below'), findsNothing);
      expect(find.textContaining('never be sent'), findsOneWidget);
      expect(find.textContaining('never sent'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.byTooltip('Close'),
        ),
      );
      await _flushBridgeAndPump(tester);

      // P0-E Snapshot receipt modal shows FNV-1a 64-bit digest + copy action, zero SHA-256
      final cleanReceipt = PolicyReviewReceipt(
        id: 'r_digest_test',
        subjectTitle: 'CalmMath Kids',
        sourceLabel: 'Synthetic example',
        createdAt: DateTime(2026, 11, 15, 10, 0),
        overallState: ReviewOverallState.noConcern,
        summary: 'No data collection found.',
        calibratedDisclaimer: 'No concern identified in the reviewed evidence. This is not a safety certification.',
        findings: const [],
        snapshotText: 'We never sell student data.',
        snapshotDigest: '9a8b7c6d5e4f3210',
        inferenceSource: InferenceSource.onDevice,
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReviewResultScreen(
            receipt: cleanReceipt,
            coordinator: ReviewCoordinator(),
          ),
        ),
      );
      await _flushBridgeAndPump(tester);

      final viewSnapshotBtn = find.text('View reviewed policy text').last;
      await tester.ensureVisible(viewSnapshotBtn);
      await tester.pump();
      await tester.tap(viewSnapshotBtn);
      await _flushBridgeAndPump(tester);

      expect(find.textContaining('SHA-256 ·'), findsNothing);
      expect(
        find.text('Document fingerprint · #9a8b7c6d5e4f3210'),
        findsNothing,
      );
      await tester.tap(
        find.byKey(const Key('snapshot_advanced_details_toggle')),
      );
      await tester.pump();
      expect(
        find.textContaining('helps verify this is the exact text Enprive checked'),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.text('Document fingerprint · #9a8b7c6d5e4f3210'),
        findsOneWidget,
      );

      final copyDigestBtn = find.text('Copy fingerprint').first;
      await tester.ensureVisible(copyDigestBtn);
      await tester.pump();
      await tester.tap(copyDigestBtn);
      await tester.pump();
      expect(copiedDigest, equals('9a8b7c6d5e4f3210'));
    },
  );

  testWidgets(
    'HybridAiBridge caches getAppIcon calls and InstalledAppPickerSheet renders original launcher icons with graceful fallback',
    (WidgetTester tester) async {
      final samplePngBytes = Uint8List.fromList(const [
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        31,
        21,
        196,
        137,
        0,
        0,
        0,
        13,
        73,
        68,
        65,
        84,
        120,
        218,
        99,
        252,
        207,
        192,
        80,
        15,
        0,
        4,
        133,
        1,
        128,
        132,
        169,
        140,
        33,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130,
      ]);

      final iconRequests = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.enprive/hybrid_ai'),
            (call) async {
              if (call.method == 'listLaunchableApps') {
                return [
                  {
                    'packageName': 'com.example.focus',
                    'appName': 'Focus Reader',
                    'isSystemApp': false,
                  },
                  {
                    'packageName': 'com.example.noicon',
                    'appName': 'Plain Utility',
                    'isSystemApp': false,
                  },
                ];
              }
              if (call.method == 'getAppIcon') {
                final args = call.arguments as Map<dynamic, dynamic>;
                final pkg = args['packageName'] as String;
                iconRequests.add(pkg);
                if (pkg == 'com.example.focus') {
                  return samplePngBytes;
                }
                if (pkg == 'com.example.broken') {
                  throw PlatformException(code: 'NOT_FOUND');
                }
                return null;
              }
              return null;
            },
          );

      // 1. Bridge deduplication & instance caching
      final bridge = HybridAiBridge();
      final concurrent = await Future.wait([
        bridge.getAppIcon('com.example.focus'),
        bridge.getAppIcon('com.example.focus'),
      ]);
      expect(concurrent[0], equals(samplePngBytes));
      expect(concurrent[1], equals(samplePngBytes));
      expect(bridge.cachedAppIcon('com.example.focus'), equals(samplePngBytes));
      expect(
        iconRequests.where((p) => p == 'com.example.focus').length,
        equals(1),
      );
      expect(await bridge.getAppIcon('com.example.broken'), isNull);
      expect(await bridge.getAppIcon(''), isNull);

      // 2. InstalledAppPickerSheet renders original icon + fallback cleanly in Dark Mode 200% text scale
      iconRequests.clear();
      final sheetBridge = HybridAiBridge();
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final darkData = EnpriveM3ETheme.darkThemeData;
      await tester.pumpWidget(
        M3EMaterialApp(
          data: darkData,
          typeface: EnpriveM3ETheme.typefaceConfig,
          autoTheming: false,
          dynamicColoring: false,
          initialTheme: darkData.brightness,
          theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
          darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
          localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          appBuilder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.0)),
            child: EnpriveM3EBridgeScope(
              themeMode: ThemeMode.dark,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          home: Scaffold(
            body: InstalledAppPickerSheet(
              bridge: sheetBridge,
            ),
          ),
        ),
      );
      await _flushBridgeAndPump(tester);
      await tester.scrollUntilVisible(
        find.text('Plain Utility'),
        220,
        scrollable: find
            .descendant(
              of: find.byType(InstalledAppPickerSheet),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await _flushBridgeAndPump(tester);

      final focusTile = find.byKey(const ValueKey('com.example.focus'));
      final noIconTile = find.byKey(const ValueKey('com.example.noicon'));
      expect(focusTile, findsOneWidget);
      expect(noIconTile, findsOneWidget);
      expect(find.byType(InstalledAppIcon), findsNWidgets(2));

      final focusImageFinder = find.descendant(
        of: focusTile,
        matching: find.byType(Image),
      );
      expect(focusImageFinder, findsOneWidget);
      final focusImage = tester.widget<Image>(focusImageFinder);
      expect(focusImage.image, isA<MemoryImage>());
      expect((focusImage.image as MemoryImage).bytes, equals(samplePngBytes));

      final noIconFallbackFinder = find.descendant(
        of: noIconTile,
        matching: find.byIcon(LucideIcons.layoutGrid),
      );
      expect(noIconFallbackFinder, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
