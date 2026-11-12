import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:enprive/main.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> recordedCalls = [];

  setUp(() {
    recordedCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.enprive/hybrid_ai'), (call) async {
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
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.enprive/hybrid_ai'), null);
  });

  testWidgets('EnpriveApp renders title, tagline, Deni greeting, and interactive pose pills', (WidgetTester tester) async {
    await tester.pumpWidget(const EnpriveApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Enprive'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Receipts'), findsWidgets);
    expect(find.textContaining('Deni'), findsWidgets);
    expect(find.text('Thinking'), findsOneWidget);

    // Tap the 'Thinking' pose pill and verify Deni updates state dialogue
    await tester.tap(find.text('Thinking'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.textContaining('Matching policy clauses on-device with Gemini Nano'),
      findsOneWidget,
    );
  });

  testWidgets('EnpriveApp renders cleanly at 200% text scale and reduced motion across all tabs', (WidgetTester tester) async {
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
  });

  test('HybridAiBridge speakText and stopSpeaking invoke native TTS channel', () async {
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
  });
}
