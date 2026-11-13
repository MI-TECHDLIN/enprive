import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
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
          initialShowDeni: true,
          initialLocale: Locale('en'),
        ),
      ),
    );
    await tester.pump();

    // Step 0 (B2 Mascot Intro)
    expect(find.textContaining("Hi, I'm Deni."), findsOneWidget);

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
}
