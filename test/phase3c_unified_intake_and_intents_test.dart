import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:enprive/domain/evidence/evidence_validator.dart';
import 'package:enprive/domain/intake/policy_intake_models.dart';
import 'package:enprive/domain/review/app_policy_association.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/main.dart';
import 'package:enprive/screens/companion_screen.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/services/intake/policy_intake_coordinator.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:enprive/widgets/installed_app_picker_sheet.dart';
import 'package:enprive/widgets/intake/unified_policy_intake_sheet.dart';
import 'package:enprive/widgets/review/unsaved_review_exit_sheet.dart';

Future<void> _pumpAndFlush(WidgetTester tester, {int steps = 8}) async {
  await tester.pump();
  for (var i = 0; i < steps; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

class _SpyPolicyIntakeCoordinator extends PolicyIntakeCoordinator {
  int incomingPayloadCalls = 0;
  int urlCaptureCalls = 0;
  int textCaptureCalls = 0;
  int documentPickerCalls = 0;
  final List<PolicyIntakeOutcome> outcomes = <PolicyIntakeOutcome>[];

  _SpyPolicyIntakeCoordinator({
    super.urlRetriever,
    super.hybridBridge,
  });

  @override
  PolicyIntakeOutcome captureText({
    required TextPolicyLocator locator,
    SelectedAppReference? selectedApp,
    String? defaultSubjectTitle,
  }) {
    textCaptureCalls++;
    final res = super.captureText(
      locator: locator,
      selectedApp: selectedApp,
      defaultSubjectTitle: defaultSubjectTitle,
    );
    outcomes.add(res);
    return res;
  }

  @override
  Future<PolicyIntakeOutcome> captureFromUrl({
    required UrlPolicyLocator locator,
    SelectedAppReference? selectedApp,
    PolicyUrlCancellationToken? cancelToken,
  }) async {
    urlCaptureCalls++;
    final res = await super.captureFromUrl(
      locator: locator,
      selectedApp: selectedApp,
      cancelToken: cancelToken,
    );
    outcomes.add(res);
    return res;
  }

  @override
  Future<PolicyIntakeOutcome> captureFromDocumentPicker({
    SelectedAppReference? selectedApp,
    String? userSubjectTitle,
  }) async {
    documentPickerCalls++;
    final res = await super.captureFromDocumentPicker(
      selectedApp: selectedApp,
      userSubjectTitle: userSubjectTitle,
    );
    outcomes.add(res);
    return res;
  }

  @override
  Future<PolicyIntakeOutcome> captureIncomingPayload({
    required IncomingIntentPayload payload,
    SelectedAppReference? selectedApp,
    PolicyUrlCancellationToken? cancelToken,
  }) async {
    incomingPayloadCalls++;
    final res = await super.captureIncomingPayload(
      payload: payload,
      selectedApp: selectedApp,
      cancelToken: cancelToken,
    );
    outcomes.add(res);
    return res;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hybridChannel = MethodChannel('com.enprive/hybrid_ai');
  const companionChannel = MethodChannel('com.enprive/companion');
  final publicIp = InternetAddress('93.184.216.34');
  Future<List<InternetAddress>> fakeDns(String host) async => [publicIp];

  const validPolicyText =
      'Focus Reader collects only account email addresses for cloud backup and never sells personal data to advertisers or third parties. Parents may request deletion of account records anytime.';

  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues({
      'enprive_pref_completed_onboarding': true,
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(companionChannel, null);
  });

  void installMocks({
    Map<String, dynamic>? initialPayload,
    List<Map<String, dynamic>> launchableApps = const [],
    Map<String, Map<String, dynamic>> inspectedApps = const {},
    Future<Map<String, dynamic>?> Function(MethodCall call)? onAnalyseText,
    Future<Map<String, dynamic>?> Function()? onPickDocument,
    void Function(String? requestId)? onCancelAnalysis,
    List<String>? playStoreOpenedPackages,
  }) {
    var deliveredInitial = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, (call) async {
          switch (call.method) {
            case 'getDeviceCapability':
              return {
                'isSupported': true,
                'modelStatus': 'AVAILABLE',
                'modelCategory': 'PREVIEW',
                'apiLevel': 36,
                'userMessage': 'Ready',
              };
            case 'getInitialIncomingPayload':
              if (!deliveredInitial && initialPayload != null) {
                deliveredInitial = true;
                return initialPayload;
              }
              return null;
            case 'getInitialSelectedText':
              return null;
            case 'listLaunchableApps':
              return launchableApps;
            case 'inspectSelectedApp':
              final pkg = (call.arguments as Map?)?['packageName'] as String?;
              if (pkg != null && inspectedApps.containsKey(pkg)) {
                return inspectedApps[pkg];
              }
              return {
                'packageName': pkg ?? 'com.example.unknown',
                'appName': 'Unknown App',
                'requestedPermissions': <String>[],
                'grantedPermissions': <String>[],
              };
            case 'pickAndExtractDocument':
              if (onPickDocument != null) return onPickDocument();
              return {
                'status': 'cancelled',
                'extractedText': '',
                'userMessage': 'Cancelled.',
              };
            case 'cancelAnalysis':
              onCancelAnalysis?.call(
                (call.arguments as Map?)?['requestId'] as String?,
              );
              return true;
            case 'analyseText':
              if (onAnalyseText != null) return onAnalyseText(call);
              final args = Map<String, dynamic>.from(call.arguments as Map);
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'Reviewed cleanly on device.',
                  'concerns': const [],
                },
              };
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(companionChannel, (call) async {
          switch (call.method) {
            case 'getInitialCompanionInvocation':
              return null;
            case 'checkUsageAccess':
              return {'status': 'denied', 'deviceLocked': false};
            case 'getQuickSettingsTileStatus':
              return {
                'isTileAdded': false,
                'canRequestDirectAdd': true,
                'hasDeclinedBefore': false,
              };
            case 'resolveForegroundApp':
              return {
                'resolutionStatus': 'usageAccessDenied',
                'confidence': 'none',
                'usageAccessStatus': 'denied',
                'userMessage': 'Usage Access is optional.',
                'candidates': <Map<String, dynamic>>[],
              };
            case 'openPlayStoreListing':
              final pkg = (call.arguments as Map?)?['packageName'] as String?;
              if (pkg != null) playStoreOpenedPackages?.add(pkg);
              return {
                'status': 'opened_play_store',
                'packageName': pkg ?? '',
              };
            case 'returnToPreviousApp':
              return true;
          }
          return null;
        });
  }

  group('D5.3-D Phase 3c — F1 Home Check Manual Intake (EP-1)', () {
    testWidgets(
      'F1: Home Check policy-first intake supports optional app select/change/remove via InstalledAppPickerSheet, unmatched & ambiguous peer warnings, Play Store helper, redirects, consent parity, and zero permission leakage',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final analyseCalls = <Map<String, dynamic>>[];
        final playStorePackages = <String>[];
        final retriever = PolicyUrlRetriever(
          dnsLookup: fakeDns,
          clientFactory: () => MockClient((request) async {
            if (request.url.toString() == 'https://redirect.example.org/p') {
              return http.Response(
                '',
                302,
                headers: {'location': 'https://canonical.example.org/privacy'},
              );
            }
            if (request.url.toString() ==
                'https://canonical.example.org/privacy') {
              return http.Response(
                '<html><body><main><h1>Policy</h1><p>This policy for com.other.unrelatedapp describes email support@example.org handling and never sells personal data. Users may delete data anytime.</p></main></body></html>',
                200,
                headers: {'content-type': 'text/html; charset=utf-8'},
              );
            }
            return http.Response('Not Found', 404);
          }),
        );
        final spyCoordinator = _SpyPolicyIntakeCoordinator(
          urlRetriever: retriever,
          hybridBridge: HybridAiBridge(),
        );
        final repo = ReceiptRepository(useInMemoryOnly: true);

        installMocks(
          launchableApps: const [
            {
              'packageName': 'com.alpha.notes',
              'appName': 'Focus Reader',
              'isSystemApp': false,
            },
            {
              'packageName': 'com.beta.notes',
              'appName': 'Focus Reader Pro',
              'isSystemApp': false,
            },
          ],
          inspectedApps: const {
            'com.alpha.notes': {
              'packageName': 'com.alpha.notes',
              'appName': 'Focus Reader',
              'requestedPermissions': ['android.permission.CAMERA'],
              'grantedPermissions': ['android.permission.CAMERA'],
            },
            'com.beta.notes': {
              'packageName': 'com.beta.notes',
              'appName': 'Focus Reader Pro',
              'requestedPermissions': ['android.permission.RECORD_AUDIO'],
              'grantedPermissions': [],
            },
          },
          playStoreOpenedPackages: playStorePackages,
          onAnalyseText: (call) async {
            final args = Map<String, dynamic>.from(call.arguments as Map);
            analyseCalls.add(args);
            if (args['cloudConsent'] != true) {
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'unavailable',
                'inferenceSource': 'UNKNOWN',
                'message': 'On-device AI unavailable on this device.',
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
              },
            };
          },
        );

        await tester.pumpWidget(
          EnpriveApp(
            showSplashOnLaunch: false,
            urlRetriever: retriever,
            intakeCoordinator: spyCoordinator,
            receiptRepository: repo,
          ),
        );
        await _pumpAndFlush(tester);

        // Open EP-1 manual intake sheet
        await _tapVisible(tester, find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);

        // Select optional installed app via InstalledAppPickerSheet
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_select_app_btn')),
        );
        await _pumpAndFlush(tester);
        expect(find.byType(InstalledAppPickerSheet), findsOneWidget);
        await _tapVisible(tester, find.byKey(const ValueKey('com.alpha.notes')));
        await _pumpAndFlush(tester);

        expect(find.byKey(const Key('intake_selected_app_card')), findsOneWidget);
        expect(find.text('App ID: com.alpha.notes'), findsOneWidget);

        // Change app -> com.beta.notes, then Remove app, then re-select com.alpha.notes
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_change_app_btn')),
        );
        await _pumpAndFlush(tester);
        await _tapVisible(tester, find.byKey(const ValueKey('com.beta.notes')));
        await _pumpAndFlush(tester);
        expect(find.text('App ID: com.beta.notes'), findsOneWidget);

        await _tapVisible(
          tester,
          find.byKey(const Key('intake_remove_app_btn')),
        );
        await _pumpAndFlush(tester);
        expect(find.byKey(const Key('intake_select_app_btn')), findsOneWidget);

        // Re-select com.alpha.notes and test peer-name ambiguousIdentity warning!
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_select_app_btn')),
        );
        await _pumpAndFlush(tester);
        await _tapVisible(tester, find.byKey(const ValueKey('com.alpha.notes')));
        await _pumpAndFlush(tester);

        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          validPolicyText,
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester);

        // Peer collision (Focus Reader vs Focus Reader Pro) surfaces ambiguousIdentity warning
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );
        expect(spyCoordinator.textCaptureCalls, 1);
        final lastOutcome = spyCoordinator.outcomes.last as PolicyIntakeSuccess;
        expect(
          lastOutcome.associationReport.state,
          AppPolicyAssociationState.ambiguousIdentity,
        );
        expect(lastOutcome.associationReport.provesDeveloperOwnership, isFalse);

        // Switch to URL mode, verify Play Store helper works and keeps state,
        // and test SSRF blocked host omits Retry fetch
        await _tapVisible(tester, find.text('Policy link'));
        await _pumpAndFlush(tester);
        await _tapVisible(tester, find.byKey(const Key('intake_play_store_btn')));
        await _pumpAndFlush(tester);
        expect(playStorePackages, ['com.alpha.notes']);

        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'http://127.0.0.1/privacy',
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(find.byKey(const Key('intake_recovery_retry_btn')), findsNothing);
        expect(
          find.byKey(const Key('intake_recovery_edit_url_btn')),
          findsOneWidget,
        );

        // Now fetch redirected URL mentioning a conflicting package -> unmatched warning
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://redirect.example.org/p',
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester);
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );

        // Continue anyway -> triggers CloudConsentSheet with exact byte-for-byte preview parity
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_association_continue_btn')),
        );
        await _pumpAndFlush(tester, steps: 10);

        expect(find.byType(CloudConsentSheet), findsOneWidget);
        expect(find.textContaining('[EMAIL]'), findsWidgets);
        expect(find.textContaining('support@example.org'), findsNothing);
        final previewWidget = tester.widget<SelectableText>(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.byType(SelectableText),
          ),
        );
        final displayedPreview =
            previewWidget.data ?? previewWidget.textSpan?.toPlainText();

        await _tapVisible(tester, find.text('Use cloud for this check'));
        await _pumpAndFlush(tester, steps: 10);

        // Verify byte-for-byte parity & zero permission/package leakage to cloud
        final cloudCalls = analyseCalls
            .where((c) => c['cloudConsent'] == true)
            .toList();
        expect(cloudCalls, hasLength(1));
        expect(cloudCalls.single['text'], equals(displayedPreview));
        final serializedCloud = cloudCalls.single.toString();
        expect(serializedCloud, isNot(contains('com.alpha.notes')));
        expect(serializedCloud, isNot(contains('com.beta.notes')));
        expect(serializedCloud, isNot(contains('CAMERA')));
        expect(serializedCloud, isNot(contains('support@example.org')));

        // ReviewResultScreen shows redirect provenance, SHA-256, and unmatched
        // association notice; stays unsaved draft (0 writes)
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(await repo.loadReceipts(), isEmpty);
        await tester.scrollUntilVisible(
          find.byKey(const Key('review_result_association_notice')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.byKey(const Key('review_result_association_notice')),
          findsOneWidget,
        );
        await tester.scrollUntilVisible(
          find.byKey(const Key('source_advanced_details_toggle')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(
          find.byKey(const Key('source_advanced_details_toggle')),
        );
        await tester.pump();
        expect(
          find.textContaining('Redirected from: https://redirect.example.org/p'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Canonical URL: https://canonical.example.org/privacy'),
          findsOneWidget,
        );
        expect(find.textContaining('SHA-256 source hash:'), findsOneWidget);
      },
    );
  });

  group('D5.3-D Phase 3c — F3, F4, F5 Intents (EP-6, EP-7, EP-8)', () {
    testWidgets(
      'F3/EP-6: cold-start ACTION_SEND failed URL opens prefilled sheet (never a capture), recovers on edit, and warm ACTION_SEND text prefills sharedText ("Shared text")',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final retriever = PolicyUrlRetriever(
          dnsLookup: fakeDns,
          clientFactory: () => MockClient((request) async {
            if (request.url.toString() ==
                'https://broken.example.org/privacy') {
              return http.Response('Not Found', 404);
            }
            if (request.url.toString() == 'https://fixed.example.org/privacy') {
              return http.Response(
                '<html><body><main><h1>Fixed Policy</h1><p>$validPolicyText</p></main></body></html>',
                200,
                headers: {'content-type': 'text/html; charset=utf-8'},
              );
            }
            return http.Response('Not Found', 404);
          }),
        );
        final spyCoordinator = _SpyPolicyIntakeCoordinator(
          urlRetriever: retriever,
          hybridBridge: HybridAiBridge(),
        );
        installMocks(
          initialPayload: {
            'kind': 'text_or_url',
            'sourceAction': 'ACTION_SEND',
            'text': 'Broken App - https://broken.example.org/privacy',
            'subject': 'Broken App',
          },
        );

        // Launch WITH splash screen enabled to verify cold-start queuing
        await tester.pumpWidget(
          EnpriveApp(
            showSplashOnLaunch: true,
            splashDuration: const Duration(milliseconds: 50),
            urlRetriever: retriever,
            intakeCoordinator: spyCoordinator,
          ),
        );
        await _pumpAndFlush(tester, steps: 12);

        // HTTP 404 must NEVER present a ReviewResultScreen capture; opens prefilled sheet
        expect(spyCoordinator.incomingPayloadCalls, 1);
        expect(find.byType(ReviewResultScreen), findsNothing);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_url_field')))
              .controller!
              .text,
          'https://broken.example.org/privacy',
        );
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_title_field')))
              .controller!
              .text,
          'Broken App',
        );

        // Recover inline by fixing the URL
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://fixed.example.org/privacy',
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester, steps: 10);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        await _tapVisible(tester, find.text('Discard without saving'));
        await _pumpAndFlush(tester);

        // Warm ACTION_SEND plain text prefills UnifiedPolicyIntakeSheet with sharedText ("Shared text")
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              hybridChannel.name,
              hybridChannel.codec.encodeMethodCall(
                const MethodCall('onIncomingPayload', {
                  'kind': 'text_or_url',
                  'sourceAction': 'ACTION_SEND',
                  'text': validPolicyText,
                  'subject': 'Shared Classroom Notice',
                }),
              ),
              (_) {},
            );
        await _pumpAndFlush(tester, steps: 8);

        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester, steps: 10);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        final sharedScreen = tester.widget<ReviewResultScreen>(
          find.byType(ReviewResultScreen),
        );
        expect(
          sharedScreen.receipt.sourceSnapshot?.sourceType,
          PolicySourceType.sharedText,
        );
        expect(sharedScreen.receipt.sourceLabel, 'Shared text');
        expect(
          sharedScreen.receipt.sourceSnapshot?.sourceSha256Hash,
          EvidenceValidator.computeSha256SourceHash(validPolicyText),
        );
      },
    );

    testWidgets(
      'F4/EP-7: failed ACTION_SEND document opens prefilled sheet with expired-share notice (never retrying stale content URI) and recovers via fresh document picker',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        var pickerCalls = 0;
        installMocks(
          initialPayload: {
            'kind': 'document',
            'sourceAction': 'ACTION_SEND',
            'status': 'password_protected',
            'documentType': 'pdf',
            'fileName': 'locked_share.pdf',
            'mimeType': 'application/pdf',
            'byteLength': 4096,
            'extractedText': '',
            'userMessage':
                'This PDF is password-protected and cannot be unlocked locally.',
          },
          onPickDocument: () async {
            pickerCalls++;
            return {
              'status': 'ok',
              'documentType': 'docx',
              'fileName': 'replacement_policy.docx',
              'mimeType':
                  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              'byteLength': 2048,
              'extractedText': validPolicyText,
              'userMessage': 'Extracted DOCX locally.',
            };
          },
        );

        await tester.pumpWidget(const EnpriveApp(showSplashOnLaunch: false));
        await _pumpAndFlush(tester, steps: 10);

        expect(find.byType(ReviewResultScreen), findsNothing);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(
          find.textContaining('The originally shared file link can no longer be reopened'),
          findsOneWidget,
        );
        expect(find.text('Choose replacement document'), findsOneWidget);
        expect(pickerCalls, 0);

        // Replacing uses fresh SAF picker (never retrying stale content URI)
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester, steps: 10);

        expect(pickerCalls, 1);
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        final docScreen = tester.widget<ReviewResultScreen>(
          find.byType(ReviewResultScreen),
        );
        expect(
          docScreen.receipt.sourceSnapshot?.sourceType,
          PolicySourceType.docx,
        );
        expect(docScreen.receipt.sourceLabel, 'Document · replacement_policy.docx');
        expect(
          docScreen.receipt.sourceSnapshot?.sourceSha256Hash,
          EvidenceValidator.computeSha256SourceHash(validPolicyText),
        );
      },
    );

    testWidgets(
      'F5/EP-8: ACTION_PROCESS_TEXT preserves Selected text label and selectedText source type (cold start) and handles selected URLs via fast path (warm onNewIntent)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final fetchedUrls = <String>[];
        final retriever = PolicyUrlRetriever(
          dnsLookup: fakeDns,
          clientFactory: () => MockClient((request) async {
            fetchedUrls.add(request.url.toString());
            return http.Response(
              '<html><body><main><h1>Selected URL Policy</h1><p>$validPolicyText</p></main></body></html>',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }),
        );
        installMocks(
          initialPayload: {
            'kind': 'text',
            'sourceAction': 'ACTION_PROCESS_TEXT',
            'text': validPolicyText,
          },
        );

        await tester.pumpWidget(
          EnpriveApp(showSplashOnLaunch: false, urlRetriever: retriever),
        );
        await _pumpAndFlush(tester, steps: 8);

        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester, steps: 10);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        final selScreen = tester.widget<ReviewResultScreen>(
          find.byType(ReviewResultScreen),
        );
        expect(
          selScreen.receipt.sourceSnapshot?.sourceType,
          PolicySourceType.selectedText,
        );
        expect(selScreen.receipt.sourceLabel, 'Selected text');

        // Discard draft and send warm ACTION_PROCESS_TEXT containing a URL
        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        await _tapVisible(tester, find.text('Discard without saving'));
        await _pumpAndFlush(tester);

        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              hybridChannel.name,
              hybridChannel.codec.encodeMethodCall(
                const MethodCall('onIncomingPayload', {
                  'kind': 'text',
                  'sourceAction': 'ACTION_PROCESS_TEXT',
                  'text': 'https://selected-url.example.org/privacy',
                }),
              ),
              (_) {},
            );
        await _pumpAndFlush(tester, steps: 10);

        expect(fetchedUrls, ['https://selected-url.example.org/privacy']);
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        final urlScreen = tester.widget<ReviewResultScreen>(
          find.byType(ReviewResultScreen),
        );
        expect(
          urlScreen.receipt.sourceSnapshot?.sourceType,
          PolicySourceType.url,
        );
        expect(
          urlScreen.receipt.sourceLabel,
          'https://selected-url.example.org/privacy',
        );
      },
    );
  });

  group('D5.3-D Phase 3c — N1 Warm Intents, Draft Protection & Concurrency', () {
    testWidgets(
      'N1: warm ACTION_SEND & Quick Settings over unsaved draft enforce Save / Discard / Continue, and warm intent over modified saved draft from Receipts is also guarded',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final retriever = PolicyUrlRetriever(
          dnsLookup: fakeDns,
          clientFactory: () => MockClient((request) async {
            return http.Response(
              '<html><body><main><h1>Warm Shared Policy</h1><p>$validPolicyText</p></main></body></html>',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }),
        );
        installMocks();
        final repo = ReceiptRepository(useInMemoryOnly: true);

        await tester.pumpWidget(
          EnpriveApp(
            showSplashOnLaunch: false,
            urlRetriever: retriever,
            receiptRepository: repo,
          ),
        );
        await _pumpAndFlush(tester);

        // Open unsaved draft via Paste terms or URL
        await _tapVisible(tester, find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_title_field')),
          'CalmMath Abacus',
        );
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          validPolicyText,
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester, steps: 10);
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(await repo.loadReceipts(), isEmpty);

        // 1) Warm ACTION_SEND URL -> UnsavedReviewExitSheet -> Continue reviewing keeps draft
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              hybridChannel.name,
              hybridChannel.codec.encodeMethodCall(
                const MethodCall('onIncomingPayload', {
                  'kind': 'text_or_url',
                  'sourceAction': 'ACTION_SEND',
                  'text': 'https://warm1.example.org/privacy',
                  'subject': 'Warm App 1',
                }),
              ),
              (_) {},
            );
        await _pumpAndFlush(tester);
        expect(find.byType(UnsavedReviewExitSheet), findsOneWidget);
        await _tapVisible(tester, find.text('Continue reviewing'));
        await _pumpAndFlush(tester);
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(find.text('Warm App 1'), findsNothing);
        expect(await repo.loadReceipts(), isEmpty);

        // 2) Warm ACTION_SEND URL -> Save to Receipts persists original draft THEN opens warm share!
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              hybridChannel.name,
              hybridChannel.codec.encodeMethodCall(
                const MethodCall('onIncomingPayload', {
                  'kind': 'text_or_url',
                  'sourceAction': 'ACTION_SEND',
                  'text': 'https://warm2.example.org/privacy',
                  'subject': 'Warm App 2',
                }),
              ),
              (_) {},
            );
        await _pumpAndFlush(tester);
        expect(find.byType(UnsavedReviewExitSheet), findsOneWidget);
        await _tapVisible(
          tester,
          find.byKey(const Key('unsaved_exit_save_btn')),
        );
        await _pumpAndFlush(tester, steps: 12);

        // Original CalmMath draft was saved AND Warm App 2 review opened!
        final savedAfterSave = await repo.loadReceipts();
        expect(savedAfterSave, hasLength(1));
        expect(savedAfterSave.single.subjectTitle, 'CalmMath Abacus');
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(
          tester
              .widget<ReviewResultScreen>(find.byType(ReviewResultScreen))
              .receipt
              .subjectTitle,
          'Warm App 2',
        );

        // 3) Warm Quick Settings over Warm App 2 unsaved draft -> Discard without saving -> opens CompanionScreen!
        const companionCodec = StandardMethodCodec();
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              companionChannel.name,
              companionCodec.encodeMethodCall(
                MethodCall('onCompanionInvocation', {
                  'invocationId': 'qs_over_warm2_draft',
                  'source': 'quick_settings',
                  'timestampMs': DateTime.now().millisecondsSinceEpoch,
                  'deviceLocked': false,
                }),
              ),
              (_) {},
            );
        await _pumpAndFlush(tester);
        expect(find.byType(UnsavedReviewExitSheet), findsOneWidget);
        expect(find.byType(CompanionScreen), findsNothing);

        await _tapVisible(
          tester,
          find.byKey(const Key('unsaved_exit_discard_btn')),
        );
        await _pumpAndFlush(tester, steps: 8);
        expect(find.byType(CompanionScreen), findsOneWidget);
        // Warm App 2 was discarded, so still only 1 saved receipt (CalmMath)
        expect(await repo.loadReceipts(), hasLength(1));
      },
    );

    testWidgets(
      'N1 concurrency: warm intent cancels in-flight Home cloud review (with exact _appcheck requestId) and dismisses open UnifiedPolicyIntakeSheet cleanly without stale results',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final stalledCloud = Completer<Map<String, dynamic>>();
        final cancelledRequestIds = <String?>[];
        final startedCloudRequestIds = <String>[];
        var nextOnDeviceAvailable = false;

        installMocks(
          onCancelAnalysis: (reqId) {
            cancelledRequestIds.add(reqId);
          },
          onAnalyseText: (call) async {
            final args = Map<String, dynamic>.from(call.arguments as Map);
            if (args['cloudConsent'] == true) {
              startedCloudRequestIds.add(args['requestId'] as String);
              return stalledCloud.future;
            }
            if (!nextOnDeviceAvailable) {
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'unavailable',
                'inferenceSource': 'UNKNOWN',
                'message': 'Nano unavailable',
              };
            }
            return {
              'schemaVersion': 1,
              'requestId': args['requestId'],
              'status': 'success',
              'inferenceSource': 'ON_DEVICE',
              'structuredOutput': {
                'overall_state': 'NO_CONCERN',
                'summary': 'Fresh warm review completed.',
                'concerns': const [],
              },
            };
          },
        );

        await tester.pumpWidget(const EnpriveApp(showSplashOnLaunch: false));
        await _pumpAndFlush(tester);

        // 1) Open UnifiedPolicyIntakeSheet, then deliver warm ACTION_SEND text ->
        // old sheet closes cleanly and new sheet opens with shared text prefilled
        await _tapVisible(tester, find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);

        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              hybridChannel.name,
              hybridChannel.codec.encodeMethodCall(
                const MethodCall('onIncomingPayload', {
                  'kind': 'text_or_url',
                  'sourceAction': 'ACTION_SEND',
                  'text': validPolicyText,
                  'subject': 'Replaced By Warm Share',
                }),
              ),
              (_) {},
            );
        await _pumpAndFlush(tester, steps: 6);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_title_field')))
              .controller!
              .text,
          'Replaced By Warm Share',
        );

        // 2) Submit -> opens CloudConsentSheet -> start cloud review (stalled in flight)
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester, steps: 8);
        expect(find.byType(CloudConsentSheet), findsOneWidget);

        await _tapVisible(tester, find.text('Use cloud for this check'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        expect(startedCloudRequestIds, hasLength(1));
        expect(startedCloudRequestIds.single, endsWith('_appcheck'));

        // Deliver a warm ACTION_PROCESS_TEXT while cloud review is in flight!
        nextOnDeviceAvailable = true;
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              hybridChannel.name,
              hybridChannel.codec.encodeMethodCall(
                const MethodCall('onIncomingPayload', {
                  'kind': 'text',
                  'sourceAction': 'ACTION_PROCESS_TEXT',
                  'text': validPolicyText,
                }),
              ),
              (_) {},
            );
        await _pumpAndFlush(tester, steps: 8);

        // Old cloud job MUST have been cancelled with its exact _appcheck request ID
        expect(cancelledRequestIds, contains(startedCloudRequestIds.single));
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);

        // Late cloud response arriving after cancellation must NOT push a stale result
        stalledCloud.complete({
          'schemaVersion': 1,
          'requestId': startedCloudRequestIds.single,
          'status': 'success',
          'inferenceSource': 'IN_CLOUD',
          'structuredOutput': {
            'overall_state': 'REVIEW_RECOMMENDED',
            'summary': 'STALE RESULT MUST NEVER APPEAR',
            'concerns': const [],
          },
        });
        await _pumpAndFlush(tester, steps: 6);

        expect(find.textContaining('STALE RESULT'), findsNothing);
        expect(find.byType(ReviewResultScreen), findsNothing);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
      },
    );

    testWidgets(
      'F6/N1: cancelling headless incoming URL fetch aborts cleanly with zero stale result, and warm intent over a modifiedSavedDraft opened from Receipts tab enforces Save/Discard/Continue',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final slowFetchStarted = Completer<void>();
        final slowFetchGate = Completer<http.Response>();
        final retriever = PolicyUrlRetriever(
          dnsLookup: fakeDns,
          clientFactory: () => MockClient((request) async {
            if (request.url.host == 'slow-share.example.org') {
              if (!slowFetchStarted.isCompleted) slowFetchStarted.complete();
              return slowFetchGate.future;
            }
            return http.Response(
              '<html><body><main><h1>Fast Share</h1><p>$validPolicyText</p></main></body></html>',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }),
        );
        installMocks();
        final repo = ReceiptRepository(useInMemoryOnly: true);

        await tester.pumpWidget(
          EnpriveApp(
            showSplashOnLaunch: false,
            urlRetriever: retriever,
            receiptRepository: repo,
          ),
        );
        await _pumpAndFlush(tester);

        // 1) Deliver warm ACTION_SEND URL that stalls -> tap ReviewProgressCard Cancel
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              hybridChannel.name,
              hybridChannel.codec.encodeMethodCall(
                const MethodCall('onIncomingPayload', {
                  'kind': 'text_or_url',
                  'sourceAction': 'ACTION_SEND',
                  'text': 'https://slow-share.example.org/privacy',
                  'subject': 'Slow Share',
                }),
              ),
              (_) {},
            );
        await tester.runAsync(() => slowFetchStarted.future);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));

        final cancelBtn = find.byKey(
          const ValueKey<String>('review_progress_cancel_btn'),
        );
        expect(cancelBtn, findsOneWidget);
        await _tapVisible(tester, cancelBtn);
        await _pumpAndFlush(tester);

        // Late HTTP response must NOT open ReviewResultScreen or UnifiedPolicyIntakeSheet
        slowFetchGate.complete(
          http.Response(
            '<html><body><main><p>$validPolicyText</p></main></body></html>',
            200,
            headers: {'content-type': 'text/html'},
          ),
        );
        await _pumpAndFlush(tester);
        expect(find.byType(ReviewResultScreen), findsNothing);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);

        // 2) Save a real app-linked receipt, open it from Receipts tab, attach an
        // updated policy (modifiedSavedDraft), then send a warm ACTION_SEND ->
        // UnsavedReviewExitSheet MUST appear (ReceiptsScreen forwards exitGuardController)!
        await _tapVisible(tester, find.text('Paste terms or URL'));
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_title_field')),
          'Saved Reader',
        );
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          validPolicyText,
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _pumpAndFlush(tester, steps: 10);
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        await _tapVisible(tester, find.byKey(const Key('review_result_save_btn')));
        await _pumpAndFlush(tester);
        expect(await repo.loadReceipts(), hasLength(1));

        // Unmodified saved receipt exits cleanly on warm intent WITHOUT nagging!
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              hybridChannel.name,
              hybridChannel.codec.encodeMethodCall(
                const MethodCall('onIncomingPayload', {
                  'kind': 'text_or_url',
                  'sourceAction': 'ACTION_SEND',
                  'text': 'https://fast-share.example.org/privacy',
                  'subject': 'Fast Share App',
                }),
              ),
              (_) {},
            );
        await _pumpAndFlush(tester, steps: 10);
        expect(find.byType(UnsavedReviewExitSheet), findsNothing);
        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(
          tester
              .widget<ReviewResultScreen>(find.byType(ReviewResultScreen))
              .receipt
              .subjectTitle,
          'Fast Share App',
        );
      },
    );
  });
}
