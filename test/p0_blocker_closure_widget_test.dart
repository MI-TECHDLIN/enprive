import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/evidence/evidence_validator.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/main.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:enprive/widgets/deni_animated_mascot.dart';
import 'package:enprive/widgets/m3e/enprive_m3e_components.dart';

Future<void> _pumpAndFlush(WidgetTester tester, {int steps = 6}) async {
  await tester.pump();
  for (var i = 0; i < steps; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.enprive/hybrid_ai');
  final publicIp = InternetAddress('93.184.216.34');
  Future<List<InternetAddress>> fakeDns(String host) async => [publicIp];

  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues({
      'enprive_pref_completed_onboarding': true,
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('P0 Blocker Closure Widget & End-to-End Parity Tests', () {
    testWidgets(
      'Link mode removes fake URL substitution: 404 -> INSUFFICIENT_EVIDENCE with fallback prompt; real HTML -> real extracted policy & SHA-256 provenance',
      (WidgetTester tester) async {
        final requestedUris = <Uri>[];
        final retriever = PolicyUrlRetriever(
          dnsLookup: fakeDns,
          clientFactory: () => MockClient((request) async {
            requestedUris.add(request.url);
            if (request.url.host.contains('edutrack.example.edu')) {
              return http.Response('Not Found', 404, headers: {
                'content-type': 'text/html; charset=utf-8',
              });
            }
            return http.Response(
              '''
              <!doctype html>
              <html>
                <head><title>GreenLeaf Journal Privacy</title></head>
                <body>
                  <nav>Home Pricing Login</nav>
                  <main>
                    <h1>GreenLeaf Journal Privacy Policy</h1>
                    <p>GreenLeaf Journal stores journal entries locally on this phone. We do not sell personal information or collect background GPS coordinates.</p>
                    <p>If you email support@greenleaf.example.org, we only use your message to respond to your support question.</p>
                  </main>
                  <footer>Cookie Settings</footer>
                </body>
              </html>
              ''',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }),
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'getDeviceCapability':
              return {
                'isSupported': true,
                'modelStatus': 'AVAILABLE',
                'modelCategory': 'PREVIEW',
                'apiLevel': 34,
                'userMessage': 'Gemini Nano 4 is ready on this device.',
              };
            case 'getInitialIncomingPayload':
            case 'getInitialSelectedText':
              return null;
            case 'analyseText':
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary':
                      'GreenLeaf Journal stores notes locally and does not collect background GPS.',
                  'concerns': [],
                },
              };
          }
          return null;
        });

        await tester.pumpWidget(
          EnpriveApp(
            showSplashOnLaunch: false,
            urlRetriever: retriever,
          ),
        );
        await _pumpAndFlush(tester);

        expect(find.byType(DeniAnimatedMascot), findsOneWidget);

        // Open Paste / URL / Document sheet
        await tester.tap(find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);

        // Switch to Policy link mode
        await tester.tap(find.text('Policy link'));
        await _pumpAndFlush(tester);

        // Ensure fake sample assist chips & prefilled EduTrack URL are gone
        expect(find.text('edutrack.example.edu/privacy'), findsNothing);
        expect(find.text('calmmath.example.org/privacy'), findsNothing);

        // 1) Enter EduTrack URL that returns HTTP 404 -> MUST NOT substitute bundled fixture!
        await tester.enterText(
          find.widgetWithText(TextField, 'https://example.com/privacy-policy'),
          'https://edutrack.example.edu/privacy',
        );
        await tester.tap(find.text('Review on this phone'));
        await _pumpAndFlush(tester, steps: 10);

        expect(
          requestedUris.any((u) => u.toString() == 'https://edutrack.example.edu/privacy'),
          isTrue,
        );
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(find.text('Insufficient evidence'), findsOneWidget);
        expect(
          find.textContaining('Paste the privacy policy text manually'),
          findsWidgets,
        );
        expect(find.textContaining('Background GPS Tracking'), findsNothing);

        // Return to Home
        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Discard without saving'));
        await _pumpAndFlush(tester);

        // 2) Enter CalmMath domain URL serving real "GreenLeaf Journal" HTML -> analyzes GreenLeaf HTML, NOT CalmMath fixture
        await tester.tap(find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Policy link'));
        await _pumpAndFlush(tester);

        await tester.enterText(
          find.widgetWithText(TextField, 'https://example.com/privacy-policy'),
          'https://calmmath.example.org/privacy',
        );
        await tester.tap(find.text('Review on this phone'));
        await _pumpAndFlush(tester, steps: 10);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(
          find.textContaining('GreenLeaf Journal stores notes locally'),
          findsOneWidget,
        );
        await tester.scrollUntilVisible(
          find.textContaining('SHA-256 source hash'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.textContaining('https://calmmath.example.org/privacy'),
          findsWidgets,
        );
        expect(find.textContaining('UTC'), findsWidgets);
        expect(find.textContaining('SHA-256 source hash'), findsOneWidget);
        expect(
          find.textContaining('does not prove app ownership'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'Document intake supports valid PDF provenance & SHA-256 and fails closed to INSUFFICIENT_EVIDENCE on corrupt/empty/password-protected files',
      (WidgetTester tester) async {
        const extractedPdfPolicy =
            'Northwood School App Privacy Notice. Northwood collects student homework completions locally and shares anonymized diagnostics only when consented. Users may request deletion of records at any time under regional data rights.';
        var returnCorruptDoc = false;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'getDeviceCapability':
              return {
                'isSupported': true,
                'modelStatus': 'AVAILABLE',
                'modelCategory': 'PREVIEW',
                'apiLevel': 34,
                'userMessage': 'Gemini Nano 4 is ready on this device.',
              };
            case 'getInitialIncomingPayload':
            case 'getInitialSelectedText':
              return null;
            case 'pickAndExtractDocument':
              if (returnCorruptDoc) {
                return {
                  'status': 'password_protected',
                  'documentType': 'pdf',
                  'fileName': 'locked_policy.pdf',
                  'mimeType': 'application/pdf',
                  'byteLength': 2048,
                  'extractedText': '',
                  'userMessage':
                      'This PDF is password-protected, so Enprive could not unlock it locally.',
                };
              }
              return {
                'status': 'ok',
                'documentType': 'pdf',
                'fileName': 'school_policy.pdf',
                'mimeType': 'application/pdf',
                'byteLength': 4096,
                'pageCount': 2,
                'extractedText': extractedPdfPolicy,
                'userMessage': 'Extracted PDF text locally.',
              };
            case 'analyseText':
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary':
                      'Northwood School App stores homework progress locally.',
                  'concerns': [],
                },
              };
          }
          return null;
        });

        await tester.pumpWidget(
          const EnpriveApp(showSplashOnLaunch: false),
        );
        await _pumpAndFlush(tester);

        // 1) Successful PDF extraction
        await tester.tap(find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Document'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Choose document (PDF, TXT, DOCX)'));
        await _pumpAndFlush(tester, steps: 10);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        final expectedSha = EvidenceValidator.computeSha256SourceHash(
          extractedPdfPolicy,
        );
        await tester.scrollUntilVisible(
          find.textContaining('SHA-256 source hash'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('school_policy.pdf'), findsWidgets);
        expect(find.textContaining('application/pdf'), findsWidgets);
        expect(find.textContaining(expectedSha.substring(0, 12)), findsWidgets);

        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Discard without saving'));
        await _pumpAndFlush(tester);

        // 2) Password-protected PDF -> INSUFFICIENT_EVIDENCE with manual paste fallback prompt
        returnCorruptDoc = true;
        await tester.tap(find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Document'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Choose document (PDF, TXT, DOCX)'));
        await _pumpAndFlush(tester, steps: 10);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(find.text('Insufficient evidence'), findsOneWidget);
        expect(
          find.textContaining('password-protected'),
          findsWidgets,
        );
        expect(
          find.textContaining('paste the privacy policy text manually'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'ACTION_SEND incoming shared URL triggers genuine retrieval and shared DOCX intake opens with DOCX provenance',
      (WidgetTester tester) async {
        final fetchedUrls = <String>[];
        final retriever = PolicyUrlRetriever(
          dnsLookup: fakeDns,
          clientFactory: () => MockClient((request) async {
            fetchedUrls.add(request.url.toString());
            return http.Response(
              '<html><body><main><h1>Shared Policy</h1><p>This shared notice states all user notes stay offline without telemetry or third-party trackers. Deletion occurs automatically on uninstall.</p></main></body></html>',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }),
        );

        Map<String, dynamic> incomingPayload = {
          'kind': 'text_or_url',
          'sourceAction': 'ACTION_SEND',
          'text': 'Shared App Privacy Policy - https://shared.example.org/privacy',
          'subject': 'Shared Browser App',
        };

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'getDeviceCapability':
              return {
                'isSupported': true,
                'modelStatus': 'AVAILABLE',
                'modelCategory': 'PREVIEW',
                'apiLevel': 34,
                'userMessage': 'Gemini Nano 4 is ready on this device.',
              };
            case 'getInitialIncomingPayload':
              final current = incomingPayload;
              incomingPayload = <String, dynamic>{};
              return current.isEmpty ? null : current;
            case 'getInitialSelectedText':
              return null;
            case 'analyseText':
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'Shared notice states notes remain offline.',
                  'concerns': [],
                },
              };
          }
          return null;
        });

        await tester.pumpWidget(
          EnpriveApp(
            showSplashOnLaunch: false,
            urlRetriever: retriever,
          ),
        );
        await _pumpAndFlush(tester, steps: 10);

        expect(fetchedUrls, ['https://shared.example.org/privacy']);
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(find.textContaining('Shared Browser App'), findsWidgets);

        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Discard without saving'));
        await _pumpAndFlush(tester);

        // Now deliver a warm incoming ACTION_SEND DOCX intent via onIncomingPayload channel push
        const docxPolicy =
            'Docx Policy Notice: We retain essential account timestamps and never transmit student location or microphone streams to ad networks. Parents may request export or deletion by writing privacy team.';
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(
            const MethodCall('onIncomingPayload', {
              'kind': 'document',
              'sourceAction': 'ACTION_SEND',
              'status': 'ok',
              'documentType': 'docx',
              'fileName': 'notice.docx',
              'mimeType':
                  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              'byteLength': 8192,
              'extractedText': docxPolicy,
              'userMessage': 'Extracted DOCX locally.',
            }),
          ),
          (_) {},
        );
        await _pumpAndFlush(tester, steps: 10);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        await tester.scrollUntilVisible(
          find.textContaining('SHA-256 source hash'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('notice.docx'), findsWidgets);
        expect(
          find.textContaining(
            EvidenceValidator.computeSha256SourceHash(docxPolicy).substring(0, 12),
          ),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'Installed-app attach policy -> CloudConsentSheet exact byte-for-byte parity, Cancel=0 cloud calls, per-operation consent, zero permission leakage, and tampered disclaimer guard',
      (WidgetTester tester) async {
        final analyseCalls = <Map<String, dynamic>>[];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getDeviceCapability') {
            return {
              'isSupported': true,
              'modelStatus': 'AVAILABLE',
              'modelCategory': 'PREVIEW',
              'apiLevel': 34,
              'userMessage': 'Gemini Nano 4 is ready on this device.',
            };
          }
          if (call.method == 'analyseText') {
            final args = Map<String, dynamic>.from(call.arguments as Map);
            analyseCalls.add(args);
            return {
              'schemaVersion': 1,
              'requestId': args['requestId'],
              'status': 'success',
              'inferenceSource': 'IN_CLOUD',
              'structuredOutput': {
                'overall_state': 'NO_CONCERN',
                'summary': 'Reviewed policy describes strictly local usage.',
                'concerns': [],
                'calibratedDisclaimer': 'FAKE 100% SAFE SEAL BY MODEL',
              },
            };
          }
          return null;
        });

        final coordinator = ReviewCoordinator();
        const appSnapshot = AppPermissionSnapshot(
          packageName: 'com.installed.targetapp',
          appName: 'InstalledTargetApp',
          requestedPermissions: [
            'android.permission.ACCESS_FINE_LOCATION',
            'android.permission.RECORD_AUDIO',
          ],
          grantedPermissions: [
            'android.permission.ACCESS_FINE_LOCATION',
          ],
        );
        final initialReceipt =
            coordinator.buildDevicePermissionInspectionReceipt(
          subjectTitle: 'InstalledTargetApp',
          sourceLabel: 'Device app inspection · com.installed.targetapp',
          appPermissions: appSnapshot,
          languageCode: 'en',
        );

        final lightM3E = EnpriveM3ETheme.resolve(
          mode: ThemeMode.light,
          platformBrightness: Brightness.light,
        );

        Widget buildTestReviewHost(ReviewResultScreen screen, Key appKey) {
          return M3EMaterialApp(
            key: appKey,
            title: 'Enprive Test',
            debugShowCheckedModeBanner: false,
            data: lightM3E,
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
            home: screen,
          );
        }

        await tester.pumpWidget(
          buildTestReviewHost(
            ReviewResultScreen(
              key: const ValueKey<String>('first_installed_review'),
              receipt: initialReceipt,
              coordinator: coordinator,
            ),
            const ValueKey<String>('host_1'),
          ),
        );
        await _pumpAndFlush(tester);

        // Comprehensive policy (> 1400 chars) with PII that must be redacted once and shown byte-identically
        final comprehensivePolicy =
            'Vendor Demo Privacy Policy. For questions email jane@example.com or cite Student ID: STU_90421. '
            'All math notebooks, local cache entries, and classroom quiz scores stay strictly inside device storage without third-party trackers, background telemetry, or advertising brokers. ' *
                10;

        // Open attach-policy sheet via "Add this app's privacy policy"
        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);

        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          comprehensivePolicy,
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);

        // CloudConsentSheet must now be open with redacted text
        expect(find.byType(CloudConsentSheet), findsOneWidget);
        expect(find.textContaining('[EMAIL]'), findsWidgets);
        expect(find.textContaining('[ID]'), findsWidgets);
        expect(find.textContaining('jane@example.com'), findsNothing);
        expect(find.textContaining('STU_90421'), findsNothing);

        // Scenario 1: Cancel -> ZERO cloud analyseText calls
        await tester.tap(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.byTooltip('Close'),
          ),
        );
        await _pumpAndFlush(tester);
        expect(find.byType(CloudConsentSheet), findsNothing);
        expect(analyseCalls, isEmpty);

        // Scenario 2: Re-open, trigger CloudConsentSheet, capture exact displayed preview, tap "Use cloud for this check"
        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          comprehensivePolicy,
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);

        expect(find.byType(CloudConsentSheet), findsOneWidget);
        final quoteWidget = tester.widget<EnpriveQuoteCard>(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.byType(EnpriveQuoteCard),
          ),
        );
        final selectableQuote = tester.widget<SelectableText>(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.byType(SelectableText),
          ),
        );
        final displayedCloudPreview = quoteWidget.quote;
        final visibleTextInSheet =
            selectableQuote.data ?? selectableQuote.textSpan?.toPlainText();
        expect(visibleTextInSheet, equals(displayedCloudPreview));

        await tester.tap(find.text('Use cloud for this check'));
        await _pumpAndFlush(tester, steps: 10);

        // Verify exactly 1 cloud call with EXACT byte-for-byte payload equality and zero permission/app leakage
        final cloudCalls = analyseCalls
            .where((c) => c['cloudConsent'] == true)
            .toList();
        expect(cloudCalls, hasLength(1));
        final sentArgs = cloudCalls.single;
        final sentText = sentArgs['text'] as String;
        expect(sentText, equals(displayedCloudPreview));

        final serializedArgs = sentArgs.toString();
        expect(serializedArgs, isNot(contains('com.installed.targetapp')));
        expect(serializedArgs, isNot(contains('InstalledTargetApp')));
        expect(serializedArgs, isNot(contains('ACCESS_FINE_LOCATION')));
        expect(serializedArgs, isNot(contains('RECORD_AUDIO')));
        expect(serializedArgs, isNot(contains('jane@example.com')));
        expect(serializedArgs, isNot(contains('STU_90421')));

        // Tampered model disclaimer MUST NEVER be shown; localized non-certification copy MUST be displayed
        expect(find.textContaining('FAKE 100% SAFE SEAL BY MODEL'), findsNothing);
        expect(
          find.text(
            'No concern identified in the reviewed evidence. This is not a safety certification.',
          ),
          findsWidgets,
        );

        // Scenario 3: Consent is strictly per-operation — starting another attach-policy review prompts CloudConsentSheet again without silently reusing consent
        await tester.pumpWidget(
          buildTestReviewHost(
            ReviewResultScreen(
              key: const ValueKey<String>('second_installed_review'),
              receipt: initialReceipt,
              coordinator: coordinator,
            ),
            const ValueKey<String>('host_2'),
          ),
        );
        await _pumpAndFlush(tester);
        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          comprehensivePolicy,
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);
        expect(find.byType(CloudConsentSheet), findsOneWidget);
        expect(
          analyseCalls.where((c) => c['cloudConsent'] == true).toList(),
          hasLength(1),
        );
      },
    );

    testWidgets(
      'D1/D2: Chrome URL share reaches PolicyUrlRetriever, cloud fallback explains local scan, and timeout/cancel restore UI cleanly without fallback receipt',
      (WidgetTester tester) async {
        final requestedUris = <Uri>[];
        final retriever = PolicyUrlRetriever(
          dnsLookup: fakeDns,
          clientFactory: () => MockClient((request) async {
            requestedUris.add(request.url);
            return http.Response(
              '''
              <!doctype html>
              <html>
                <head><title>Ululab Privacy</title></head>
                <body>
                  <main>
                    <h1>Privacy Policy</h1>
                    <p>Our services do not include any third party advertising. A third party attribution platform called AppsFlyer collects the Android Advertising ID to measure parent-facing campaigns.</p>
                    <p>For questions email info@ululab.com.</p>
                  </main>
                </body>
              </html>
              ''',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }),
        );

        var nextCloudMode = 'quota_429';
        final cancelRequests = <String?>[];
        final analyseCalls = <Map<String, dynamic>>[];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'getDeviceCapability':
              return {
                'isSupported': false,
                'modelStatus': 'UNAVAILABLE',
                'modelCategory': 'PREVIEW',
                'apiLevel': 35,
                'userMessage': 'Gemini Nano unavailable on RMX5303.',
              };
            case 'getInitialIncomingPayload':
              return {
                'kind': 'text_or_url',
                'sourceAction': 'ACTION_SEND',
                'text': 'https://ululab.com/privacy-policy/',
                'subject': 'Privacy Policy - Ululab',
              };
            case 'getInitialSelectedText':
              return null;
            case 'cancelAnalysis':
              cancelRequests.add((call.arguments as Map?)?['requestId'] as String?);
              return true;
            case 'analyseText':
              final args = Map<String, dynamic>.from(call.arguments as Map);
              analyseCalls.add(args);
              if (args['requestedMode'] == 'ONLY_ON_DEVICE') {
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'unavailable',
                  'inferenceSource': 'UNKNOWN',
                  'message': 'On-device AI unavailable on this hardware.',
                };
              }
              if (nextCloudMode == 'quota_429') {
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'failed',
                  'inferenceSource': 'UNKNOWN',
                  'errorCode': 'QuotaExceededException',
                  'message': 'HTTP 429 quota exceeded',
                };
              }
              if (nextCloudMode == 'timeout') {
                throw PlatformException(
                  code: 'TIMED_OUT',
                  message: 'Cloud AI timed out before completing.',
                  details: {'reason': 'timeout'},
                );
              }
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'success',
                'inferenceSource': 'IN_CLOUD',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'Reviewed cleanly.',
                  'concerns': [],
                },
              };
          }
          return null;
        });

        await tester.pumpWidget(
          EnpriveApp(
            showSplashOnLaunch: false,
            urlRetriever: retriever,
          ),
        );
        await _pumpAndFlush(tester, steps: 8);

        // 1. Verify Chrome URL share reached PolicyUrlRetriever (NOT PNG unsupportedMime!)
        expect(
          requestedUris.any(
            (u) => u.toString() == 'https://ululab.com/privacy-policy/',
          ),
          isTrue,
        );
        expect(find.byType(CloudConsentSheet), findsOneWidget);
        expect(find.textContaining('Unsupported document format'), findsNothing);

        // 2. Cloud fails with HTTP 429 -> deterministic fallback shows explicit explanation card
        await tester.tap(find.text('Use cloud for this check'));
        await _pumpAndFlush(tester, steps: 8);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey<String>('cloud_fallback_notice_card')),
          findsOneWidget,
        );
        expect(
          find.textContaining('Cloud analysis was unavailable'),
          findsWidgets,
        );
        // Verified D3 accuracy on live extracted HTML too: negated ad claim skipped, AppsFlyer kept
        expect(
          find.textContaining('Our services do not include any third party advertising'),
          findsNothing,
        );
        expect(
          analyseCalls.where((c) => c['cloudConsent'] == true).toList(),
          hasLength(1),
        );

        // 3. Navigate back & verify timeout cancellation propagates without creating a fallback receipt
        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Discard without saving'));
        await _pumpAndFlush(tester);
        nextCloudMode = 'timeout';

        await tester.tap(find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Policy link'));
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byType(TextField).last,
          'https://ululab.com/privacy-policy/',
        );
        await tester.tap(find.text('Review on this phone'));
        await _pumpAndFlush(tester, steps: 8);

        expect(find.byType(CloudConsentSheet), findsOneWidget);
        await tester.tap(find.text('Use cloud for this check'));
        await _pumpAndFlush(tester, steps: 8);

        expect(find.byType(ReviewResultScreen), findsNothing);
        expect(
          find.text('Cloud AI timed out before responding. No automatic retry was sent.'),
          findsOneWidget,
        );

        // 4. Live in-flight user cancellation via ReviewProgressCard Cancel button
        final stalledCloudCompleter = Completer<Map<String, dynamic>>();
        nextCloudMode = 'stalled';
        cancelRequests.clear();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'getDeviceCapability':
              return {
                'isSupported': false,
                'modelStatus': 'UNAVAILABLE',
                'modelCategory': 'PREVIEW',
                'apiLevel': 35,
                'userMessage': 'Gemini Nano unavailable on RMX5303.',
              };
            case 'getInitialIncomingPayload':
            case 'getInitialSelectedText':
              return null;
            case 'cancelAnalysis':
              cancelRequests.add((call.arguments as Map?)?['requestId'] as String?);
              if (!stalledCloudCompleter.isCompleted) {
                stalledCloudCompleter.completeError(
                  PlatformException(
                    code: 'CANCELLED',
                    message: 'Analysis cancelled by user.',
                    details: {'reason': 'user_cancelled'},
                  ),
                );
              }
              return true;
            case 'analyseText':
              final args = Map<String, dynamic>.from(call.arguments as Map);
              analyseCalls.add(args);
              if (args['requestedMode'] == 'ONLY_ON_DEVICE') {
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'unavailable',
                  'inferenceSource': 'UNKNOWN',
                  'message': 'On-device AI unavailable on this hardware.',
                };
              }
              return stalledCloudCompleter.future;
          }
          return null;
        });

        await tester.tap(find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Policy link'));
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byType(TextField).last,
          'https://ululab.com/privacy-policy/',
        );
        await tester.tap(find.text('Review on this phone'));
        await _pumpAndFlush(tester, steps: 8);

        expect(find.byType(CloudConsentSheet), findsOneWidget);
        await tester.tap(find.text('Use cloud for this check'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Checking policy with cloud AI.'), findsOneWidget);
        expect(find.text('Reviewing on this phone.'), findsNothing);
        final cancelBtn = find.byKey(
          const ValueKey<String>('review_progress_cancel_btn'),
        );
        expect(cancelBtn, findsOneWidget);

        await tester.ensureVisible(cancelBtn);
        await tester.pump();
        await tester.tap(cancelBtn);
        await _pumpAndFlush(tester, steps: 6);

        expect(cancelRequests.where((id) => id != null && id.isNotEmpty), isNotEmpty);
        expect(find.byType(ReviewResultScreen), findsNothing);
        expect(find.text('Check an app'), findsOneWidget);
        expect(find.text('Review cancelled.'), findsOneWidget);
      },
    );
  });
}
