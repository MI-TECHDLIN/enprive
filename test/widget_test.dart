// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.enprive/hybrid_ai'), null);
  });

  testWidgets('EnpriveApp renders title, tagline, and Deni greeting', (WidgetTester tester) async {
    await tester.pumpWidget(const EnpriveApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Enprive'), findsOneWidget);
    expect(find.text('NANO 4'), findsOneWidget);
    expect(find.textContaining('Deni'), findsWidgets);
  });
}


