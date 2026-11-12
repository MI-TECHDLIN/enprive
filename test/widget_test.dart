import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:enprive/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.enprive/hybrid_ai'), (call) async {
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
}
