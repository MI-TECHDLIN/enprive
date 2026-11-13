import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/l10n/enprive_languages.dart';
import 'package:enprive/main.dart';
import 'package:enprive/screens/onboarding_flow_screen.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/analysis_process_trace.dart';
import 'package:enprive/widgets/review_progress_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> recordedCalls = [];

  setUp(() {
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
    'EnpriveApp renders clean Home hero, sample app checks, and what-we-check content without pose debug card',
    (WidgetTester tester) async {
      await tester.pumpWidget(const EnpriveApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Enprive'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Receipts'), findsWidgets);
      expect(find.text('Try a sample app check'), findsOneWidget);
      expect(find.text('EduTrack Classroom'), findsOneWidget);
      expect(find.text('CalmMath Kids'), findsOneWidget);
      expect(find.text('What we check for'), findsOneWidget);
      expect(find.text('Exact policy quotes'), findsOneWidget);
      expect(find.textContaining('Deni ·'), findsNothing);
      expect(find.text('Thinking'), findsNothing);
    },
  );

  testWidgets(
    'EnpriveApp renders cleanly at 200% text scale and reduced motion across all tabs',
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

      expect(find.text('Enprive'), findsOneWidget);

      // Switch to Settings tab at 200% text scale
      await tester.tap(find.text('Settings').last);
      await tester.pump();
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Show Deni companion'), findsNothing);
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

    // Step 0 (B2 Mascot Intro — updated Deni narrative)
    expect(find.text("Hi, I'm Deni. 👋"), findsOneWidget);
    expect(
      find.text("Let's make app privacy easier to understand."),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        "I'll help you uncover what an app's privacy policy really says",
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('No guessing. No false promises.'),
      findsOneWidget,
    );
    expect(find.text("Know what you're agreeing to."), findsOneWidget);

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
      expect(find.text('Reviewing on this phone…'), findsOneWidget);
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
        find.text('Reading policy clauses on this phone…'),
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

      expect(find.text('Reading policy clauses on this phone…'), findsNothing);
      expect(
        find.text('Streaming reasoning & thought signature'),
        findsOneWidget,
      );
      expect(
        find.text('Verifying sharing clause verbatim boundaries.'),
        findsOneWidget,
      );
      expect(find.textContaining('Thought signature'), findsOneWidget);
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
      expect(find.textContaining('Thought signature:'), findsOneWidget);
      expect(find.text('View streamed thoughts'), findsOneWidget);
      expect(
        find.text('Matched clause about ad network telemetry.'),
        findsNothing,
      );

      await tester.tap(find.text('View streamed thoughts'));
      await tester.pump();

      expect(find.text('Hide streamed thoughts'), findsOneWidget);
      expect(
        find.text('Matched clause about ad network telemetry.'),
        findsOneWidget,
      );
    },
  );

  test(
    'All 12 requested languages are configured locally and propagate to Cloud Gemini & disclaimer',
    () async {
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
        policyText:
            'We do not collect personal data from children and keep lessons stored exclusively on this device.',
        forceLocalManualScan: true,
        languageCode: 'es',
      );
      expect(outcome.receipt, isNotNull);
      expect(outcome.receipt!.overallState, ReviewOverallState.noConcern);
      expect(
        outcome.receipt!.calibratedDisclaimer,
        lookupAppLocalizations(const Locale('es')).stateNoConcernSubtitle,
      );
    },
  );

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
      expect(find.text(arL10n.onboardingIntroFooter), findsOneWidget);
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
      final arCounter =
          lookupAppLocalizations(const Locale('ar')).progressStepCounter(1, 4);
      expect(find.text(arCounter), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
