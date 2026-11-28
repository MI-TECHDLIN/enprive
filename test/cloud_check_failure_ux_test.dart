
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';

const _policy =
    'We collect device identifiers to share telemetry with partners. '
    'We also share your location with advertising partners and keep it '
    'for as long as your account exists.';

const _channel = MethodChannel('com.enprive/hybrid_ai');

Widget _wrap(Widget home) {
  final light = EnpriveM3ETheme.resolve(
    mode: ThemeMode.light,
    platformBrightness: Brightness.light,
  );
  return M3EMaterialApp(
    title: 'Enprive Test',
    debugShowCheckedModeBanner: false,
    data: light,
    typeface: EnpriveM3ETheme.typefaceConfig,
    autoTheming: false,
    dynamicColoring: false,
    initialTheme: Brightness.light,
    theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
    darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
    locale: const Locale('en'),
    localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    appBuilder: (context, child) => EnpriveM3EBridgeScope(
      themeMode: ThemeMode.light,
      child: child ?? const SizedBox.shrink(),
    ),
    home: home,
  );
}

Future<void> _settle(WidgetTester tester, {int steps = 8}) async {
  await tester.pump();
  for (var i = 0; i < steps; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 120));
  }
}

typedef _Reply = Map<String, Object?> Function(String requestId);

Map<String, Object?> _timedOut(String id) => {
  'schemaVersion': 1,
  'requestId': id,
  'status': 'cancelled',
  'inferenceSource': 'UNKNOWN',
  'errorCode': 'TIMED_OUT',
  'message': 'Cloud AI timed out before completing.',
};

Map<String, Object?> _serverException(String id) => {
  'schemaVersion': 1,
  'requestId': id,
  'status': 'failed',
  'inferenceSource': 'UNKNOWN',
  'errorCode': 'ServerException',
  'message': 'The model is overloaded due to high demand.',
};

Map<String, Object?> _userCancelled(String id) => {
  'schemaVersion': 1,
  'requestId': id,
  'status': 'cancelled',
  'inferenceSource': 'UNKNOWN',
  'errorCode': 'CANCELLED',
  'message': 'Analysis cancelled.',
};

Map<String, Object?> _cloudSuccess(String id) => {
  'schemaVersion': 1,
  'requestId': id,
  'status': 'success',
  'inferenceSource': 'IN_CLOUD',
  'structuredOutput': {
    'overall_state': 'REVIEW_RECOMMENDED',
    'summary': 'Cloud summary.',
    'concerns': [
      {
        'title': 'Third-party tracking',
        'category': 'TRACKING',
        'severity': 'MEDIUM',
        'exact_quote':
            'We collect device identifiers to share telemetry with partners.',
        'explanation': 'Shares device identifiers with partners.',
        'unknowns': ['Partner retention period'],
      },
    ],
  },
};

/// Only consented cloud policy checks; the on-device voice summary also uses
/// the same channel.
List<Map<String, dynamic>> _cloudChecks(List<Map<String, dynamic>> calls) =>
    calls
        .where(
          (c) => c['cloudConsent'] == true && c['task'] == 'summarise_concerns',
        )
        .toList();

List<Map<String, dynamic>> _mockBridge(_Reply reply) {
  final calls = <Map<String, dynamic>>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, (call) async {
        if (call.method == 'analyseText') {
          final args = Map<String, dynamic>.from(call.arguments as Map);
          calls.add(args);
          return reply(args['requestId'] as String);
        }
        return null;
      });
  return calls;
}

Future<ReviewExecutionResult> _cloudReview(ReviewCoordinator c) =>
    c.runPolicyReview(
      subjectTitle: 'EduTrack',
      sourceLabel: 'Paste',
      policyText: _policy,
      cloudConsent: true,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  group('cloud check failure outcome (coordinator)', () {
    test(
      'timeout returns the on-device result and sends exactly one request',
      () async {
        final calls = _mockBridge(_timedOut);
        final outcome = await _cloudReview(ReviewCoordinator());

        expect(calls, hasLength(1), reason: 'no silent cloud retry');
        final receipt = outcome.receipt!;
        expect(receipt.snapshotText, contains('device identifiers'));
        expect(
          receipt.diagnosticKind,
          ReviewDiagnosticKind.cloudUnavailableLocalFallback,
        );
        expect(receipt.inferenceSource, InferenceSource.offlineDeterministic);
        expect(receipt.summary, isNot(contains('—')));
      },
    );

    test(
      'ServerException returns the on-device result and sends one request',
      () async {
        final calls = _mockBridge(_serverException);
        final outcome = await _cloudReview(ReviewCoordinator());

        expect(calls, hasLength(1));
        expect(
          outcome.receipt!.diagnosticKind,
          ReviewDiagnosticKind.cloudUnavailableLocalFallback,
        );
        expect(
          outcome.receipt!.inferenceSource,
          InferenceSource.offlineDeterministic,
        );
      },
    );

    test('user cancel still throws and produces no receipt', () async {
      _mockBridge(_userCancelled);
      await expectLater(
        _cloudReview(ReviewCoordinator()),
        throwsA(
          isA<HybridOperationCancelledException>().having(
            (e) => e.isTimeout,
            'isTimeout',
            isFalse,
          ),
        ),
      );
    });

    test('success keeps the cloud result and diagnostic', () async {
      _mockBridge(_cloudSuccess);
      final outcome = await _cloudReview(ReviewCoordinator());

      expect(outcome.receipt!.inferenceSource, InferenceSource.inCloud);
      expect(
        outcome.receipt!.diagnosticKind,
        isNot(ReviewDiagnosticKind.cloudUnavailableLocalFallback),
      );
    });
  });

  group('fallback notice and retry (ReviewResultScreen)', () {
    Future<(ReviewCoordinator, PolicyReviewReceipt)> failedReceipt(
      WidgetTester tester,
      _Reply failure,
    ) async {
      _mockBridge(failure);
      final coordinator = ReviewCoordinator();
      final outcome = await tester.runAsync(() => _cloudReview(coordinator));
      return (coordinator, outcome!.receipt!);
    }

    Future<void> pumpScreen(
      WidgetTester tester,
      ReviewCoordinator coordinator,
      PolicyReviewReceipt receipt,
      List<PolicyReviewReceipt> saved,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _wrap(
          ReviewResultScreen(
            receipt: receipt,
            coordinator: coordinator,
            onSaveReceipt: (r) async => saved.add(r),
          ),
        ),
      );
      await _settle(tester);
    }

    for (final scenario in <(String, _Reply)>[
      ('timeout', _timedOut),
      ('server exception', _serverException),
    ]) {
      testWidgets(
        '${scenario.$1}: plain message, on-device result, retry, nothing saved',
        (tester) async {
          final (coordinator, receipt) = await failedReceipt(
            tester,
            scenario.$2,
          );
          final saved = <PolicyReviewReceipt>[];
          await pumpScreen(tester, coordinator, receipt, saved);

          final notice = find.byKey(
            const ValueKey<String>('cloud_fallback_notice_card'),
          );
          await tester.ensureVisible(notice);
          await tester.pump();
          expect(find.text('The cloud check could not finish'), findsOneWidget);
          expect(find.textContaining('on-device result'), findsWidgets);
          expect(
            find.byKey(const Key('cloud_fallback_retry_btn')),
            findsOneWidget,
          );
          expect(saved, isEmpty);
        },
      );
    }

    testWidgets('retry asks for consent again; declining sends nothing', (
      tester,
    ) async {
      final (coordinator, receipt) = await failedReceipt(tester, _timedOut);
      final calls = _mockBridge(_cloudSuccess);
      final saved = <PolicyReviewReceipt>[];
      await pumpScreen(tester, coordinator, receipt, saved);

      final retry = find.byKey(const Key('cloud_fallback_retry_btn'));
      await tester.ensureVisible(retry);
      await tester.pump();
      await tester.tap(retry);
      await _settle(tester);
      expect(find.byType(CloudConsentSheet), findsOneWidget);
      expect(
        _cloudChecks(calls),
        isEmpty,
        reason: 'nothing is sent before consent',
      );

      await tester.tap(
        find
            .descendant(
              of: find.byType(CloudConsentSheet),
              matching: find.byTooltip('Close'),
            )
            .first,
      );
      await _settle(tester);
      expect(_cloudChecks(calls), isEmpty);
      expect(saved, isEmpty);
      expect(find.text('The cloud check could not finish'), findsOneWidget);
    });

    testWidgets(
      'retry with consent shows the cloud result as an unsaved draft',
      (tester) async {
        final (coordinator, receipt) = await failedReceipt(
          tester,
          _serverException,
        );
        final calls = _mockBridge(_cloudSuccess);
        final saved = <PolicyReviewReceipt>[];
        await pumpScreen(tester, coordinator, receipt, saved);

        final retry = find.byKey(const Key('cloud_fallback_retry_btn'));
        await tester.ensureVisible(retry);
        await tester.pump();
        await tester.tap(retry);
        await _settle(tester);
        await tester.tap(find.text('Use cloud for this check'));
        await _settle(tester, steps: 12);

        expect(_cloudChecks(calls), hasLength(1));
        expect(find.text('The cloud check could not finish'), findsNothing);
        expect(saved, isEmpty, reason: 'save stays an explicit user action');
      },
    );
  });
}
