import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:enprive/domain/companion/companion_policy_resolver.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/main.dart';
import 'package:enprive/screens/companion_screen.dart';
import 'package:enprive/screens/settings_screen.dart';
import 'package:enprive/services/intake/policy_intake_coordinator.dart';
import 'package:enprive/services/intake/policy_intake_helper.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';
import 'package:enprive/services/platform/companion_bridge.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/intake/unified_policy_intake_sheet.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'support/keyboard_focus.dart';

class _FakeCompanionDocBridge implements PolicyDocumentPlatformBridge {
  int pickCalls = 0;
  Future<DocumentExtractionOutcome> Function()? onPick;
  Future<AppPermissionSnapshot?> Function(String packageName)? onInspect;

  @override
  Future<DocumentExtractionOutcome> pickAndExtractDocument() async {
    pickCalls++;
    if (onPick != null) return onPick!();
    return const DocumentExtractionOutcome(
      status: 'cancelled',
      extractedText: '',
      userMessage: 'No document was selected.',
    );
  }

  @override
  Future<AppPermissionSnapshot?> inspectAppSnapshot(String packageName) async {
    if (onInspect != null) return onInspect!(packageName);
    return null;
  }
}

Widget _wrapCompanionApp({required Widget child}) {
  return M3EMaterialApp(
    data: EnpriveM3ETheme.lightThemeData,
    typeface: EnpriveM3ETheme.typefaceConfig,
    autoTheming: false,
    dynamicColoring: false,
    initialTheme: Brightness.light,
    theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
    darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
    locale: const Locale('en'),
    localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    appBuilder: (context, appChild) => EnpriveM3EBridgeScope(
      themeMode: ThemeMode.light,
      child: appChild ?? const SizedBox.shrink(),
    ),
    home: child,
  );
}

Future<void> _pumpFrames(WidgetTester tester, {int count = 6}) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 25)),
  );
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 90));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hybridChannel = MethodChannel('com.enprive/hybrid_ai');
  const companionChannel = MethodChannel('com.enprive/companion');

  setUp(() {
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

  group('Quick Settings Companion Domain & Evidence Tests', () {
    test('CompanionPolicyResolver strictly verifies exact package match and builds verified vs unverified explanations', () {
      final verifiedPolicy =
          'When a student uses Math Makers, precise location coordinates are collected to unlock local classroom challenges. Analytics telemetry may share device metrics with partners. All other personal records stay on device unless parents request export.';
      final verifiedReceipt = PolicyReviewReceipt(
        id: 'r_math_1',
        subjectTitle: 'Math Makers',
        sourceLabel: 'https://ululab.com/privacy-policy/',
        snapshotText: verifiedPolicy,
        snapshotDigest: 'fnv_1',
        createdAt: DateTime(2026, 11, 16),
        overallState: ReviewOverallState.reviewRecommended,
        inferenceSource: InferenceSource.offlineDeterministic,
        summary: 'Verified summary',
        calibratedDisclaimer: 'No concern identified in the reviewed evidence.',
        findings: const [],
        permissionReport: const AppPermissionComparisonReport(
          snapshot: AppPermissionSnapshot(
            packageName: 'com.ululab.numbers',
            appName: 'Math Makers',
            requestedPermissions: ['android.permission.ACCESS_FINE_LOCATION'],
            grantedPermissions: [],
          ),
          items: [],
          limitationNotice: 'Local only',
        ),
        sourceSnapshot: PolicySourceSnapshot(
          snapshotId: 'snap_1',
          sourceType: PolicySourceType.url,
          canonicalUrl: 'https://ululab.com/privacy-policy/',
          retrievedAt: DateTime(2026, 11, 16),
          retrievalStatus: PolicyRetrievalStatus.retrieved,
          sourceSha256Hash: 'aabbccddeeff00112233445566778899',
        ),
      );

      // Must never match by app name alone when package differs
      expect(
        CompanionPolicyResolver.findVerifiedReceiptForPackage(
          'com.other.mathmakers',
          [verifiedReceipt],
        ),
        isNull,
      );
      expect(
        CompanionPolicyResolver.findVerifiedReceiptForPackage(
          'com.ululab.numbers',
          [verifiedReceipt],
        ),
        verifiedReceipt,
      );

      const locationPerm = DeclaredSensitivePermission(
        permission: 'android.permission.ACCESS_FINE_LOCATION',
        categoryId: 'location',
        title: 'Precise location',
        whatPermissionMeans:
            'Allows the app to read exact GPS coordinates while you use it.',
        grantStatus: DeclaredPermissionGrantStatus.denied,
        statusNote: 'Declared · Currently denied',
      );

      final unverified = CompanionPolicyResolver.buildExplanation(
        permission: locationPerm,
        confirmedAppLabel: 'Math Makers',
        confirmedPackageName: 'com.ululab.numbers',
        verifiedReceipt: null,
      );
      expect(unverified.hasVerifiedPolicy, isFalse);
      expect(
        unverified.policyStatusHeadline,
        CompanionPolicyResolver.unverifiedPolicyHeadline,
      );
      expect(unverified.verbatimExcerpts, isEmpty);

      final verified = CompanionPolicyResolver.buildExplanation(
        permission: locationPerm,
        confirmedAppLabel: 'Math Makers',
        confirmedPackageName: 'com.ululab.numbers',
        verifiedReceipt: verifiedReceipt,
      );
      expect(verified.hasVerifiedPolicy, isTrue);
      expect(verified.verbatimExcerpts, isNotEmpty);
      expect(
        verified.verbatimExcerpts.first,
        contains('precise location coordinates'),
      );
    });

    test('ReviewCoordinator.askDeniAboutPermission answers locally with 0 cloud calls when policy is missing, and strips packageName from cloud payloads when verified policy exists', () async {
      final analyseCalls = <Map<String, dynamic>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(hybridChannel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              analyseCalls.add(args);
              if (args['requestedMode'] == 'ONLY_ON_DEVICE') {
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'unavailable',
                  'inferenceSource': 'UNKNOWN',
                  'errorCode': 'Unavailable',
                  'message': 'Nano unavailable',
                };
              }
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'success',
                'inferenceSource': 'IN_CLOUD',
                'structuredOutput': {
                  'answer':
                      'Quoted policy states contacts sync classroom rosters.',
                  'whatPolicySays': 'Syncs classroom rosters.',
                  'unknownBoundary': 'Does not state server retention period.',
                },
              };
            }
            return null;
          });

      final coordinator = ReviewCoordinator();
      const contactsPerm = DeclaredSensitivePermission(
        permission: 'android.permission.READ_CONTACTS',
        categoryId: 'contacts',
        title: 'Contacts',
        whatPermissionMeans: 'Reads names and phone numbers in contacts.',
        grantStatus: DeclaredPermissionGrantStatus.denied,
        statusNote: 'Declared · Currently denied',
      );

      // 1. No verified policy -> deterministic local response, ZERO bridge calls
      final unverifiedExplanation = CompanionPolicyResolver.buildExplanation(
        permission: contactsPerm,
        confirmedAppLabel: 'Sample App',
        confirmedPackageName: 'com.secret.pkg',
        verifiedReceipt: null,
      );
      final unverifiedAnswer = await coordinator.askDeniAboutPermission(
        explanation: unverifiedExplanation,
        question: 'What happens if I deny it?',
        confirmedPackageName: 'com.secret.pkg',
        cloudConsent: true,
      );
      expect(analyseCalls, isEmpty);
      expect(
        unverifiedAnswer.inferenceSource,
        InferenceSource.offlineDeterministic,
      );
      expect(unverifiedAnswer.answer, contains('keep'));

      // 2. Verified policy -> cloud payload MUST NOT contain packageName or full permission inventory
      final verifiedReceipt = PolicyReviewReceipt(
        id: 'r_contacts',
        subjectTitle: 'Roster App',
        sourceLabel: 'https://roster.example/privacy',
        snapshotText: 'With parental permission, we read your address book contacts to suggest classroom peers. No advertising SDKs are included in student accounts and records stay encrypted.',
        snapshotDigest: 'd1',
        createdAt: DateTime(2026, 11, 16),
        overallState: ReviewOverallState.reviewRecommended,
        inferenceSource: InferenceSource.onDevice,
        summary: 'Summary',
        calibratedDisclaimer: 'Calibrated.',
        findings: const [],
        sourceSnapshot: PolicyIntakeHelper.snapshotForManualOrSharedText(
          sourceType: PolicySourceType.url,
          text: 'With parental permission, we read your address book contacts to suggest classroom peers. No advertising SDKs are included in student accounts and records stay encrypted.',
        ),
      );
      final verifiedExp = CompanionPolicyResolver.buildExplanation(
        permission: contactsPerm,
        confirmedAppLabel: 'Roster App',
        confirmedPackageName: 'com.secret.pkg',
        verifiedReceipt: verifiedReceipt,
      );

      // 3. DEVICE_OBSERVED findings ("Android Manifest Observation: ...") MUST
      // never leak into policy quotes or trigger "Mentioned in verified policy text".
      final receiptWithUndisclosedCamera = PolicyReviewReceipt(
        id: 'r_camera_undisclosed',
        subjectTitle: 'Math App',
        sourceLabel: 'https://math.example/privacy',
        snapshotText: verifiedReceipt.snapshotText,
        snapshotDigest: 'd_cam',
        createdAt: DateTime(2026, 11, 16),
        overallState: ReviewOverallState.reviewRecommended,
        inferenceSource: InferenceSource.offlineDeterministic,
        summary: 'Summary',
        calibratedDisclaimer: 'Calibrated.',
        findings: const [
          VerifiedFinding(
            id: 'perm_camera',
            title: 'Undisclosed Android Permission: Camera',
            category: FindingCategory.dataCollection,
            severity: FindingSeverity.medium,
            exactExcerpt: 'Android Manifest Observation: android.permission.CAMERA (REQUESTED) — no matching disclosure found in policy snapshot.',
            explanation: 'Camera disclosure missing.',
            whatPolicySays: 'Not mentioned.',
            whatAndroidReports: 'Denied',
            unknowns: ['Unknown'],
            status: EvidenceStatus.deviceObserved,
          ),
        ],
        sourceSnapshot: verifiedReceipt.sourceSnapshot,
      );
      const cameraPerm = DeclaredSensitivePermission(
        permission: 'android.permission.CAMERA',
        categoryId: 'camera',
        title: 'Camera',
        whatPermissionMeans: 'Allows capturing photos or video.',
        grantStatus: DeclaredPermissionGrantStatus.denied,
        statusNote: 'Declared · Currently denied',
      );
      final undisclosedExp = CompanionPolicyResolver.buildExplanation(
        permission: cameraPerm,
        confirmedAppLabel: 'Math App',
        confirmedPackageName: 'com.math.app',
        verifiedReceipt: receiptWithUndisclosedCamera,
      );
      expect(
        undisclosedExp.policyStatusHeadline,
        'Not clearly explained in verified policy text',
      );
      expect(undisclosedExp.verbatimExcerpts, isEmpty);

      final consentPrompt = await coordinator.askDeniAboutPermission(
        explanation: verifiedExp,
        question: 'Why does com.secret.pkg need my contacts?',
        userFeatureContext: 'Inviting classmates from com.secret.pkg',
        confirmedPackageName: 'com.secret.pkg',
        cloudConsent: false,
      );
      expect(consentPrompt.requiresCloudConsent, isTrue);
      expect(consentPrompt.redactedPreview, isNot(contains('com.secret.pkg')));

      final cloudAnswer = await coordinator.askDeniAboutPermission(
        explanation: verifiedExp,
        question: 'Why does com.secret.pkg need my contacts?',
        userFeatureContext: 'Inviting classmates from com.secret.pkg',
        confirmedPackageName: 'com.secret.pkg',
        cloudConsent: true,
      );
      expect(cloudAnswer.inferenceSource, InferenceSource.inCloud);
      final cloudText = analyseCalls.last['text'] as String;
      expect(cloudText, isNot(contains('com.secret.pkg')));
      expect(cloudText, isNot(contains('android.permission.READ_CONTACTS')));
    });

    test('askDeniAboutPermission never substitutes opening snapshot sentence when no matching excerpt exists and distinguishes missing, ambiguous, and verified disclosures', () async {
      final analyseCalls = <Map<String, dynamic>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(hybridChannel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              analyseCalls.add(args);
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'unavailable',
                'inferenceSource': 'UNKNOWN',
                'errorCode': 'Unavailable',
                'message': 'Nano unavailable',
              };
            }
            return null;
          });

      const openingSentence =
          'Welcome to Classroom Studio — trusted by schools since 2020.';
      const cameraFreePolicy =
          '$openingSentence All homework notes and attendance sheets are stored for parent visibility.';

      final missingReceipt = PolicyReviewReceipt(
        id: 'r_missing_cam',
        subjectTitle: 'Classroom Studio',
        sourceLabel: 'https://studio.example/privacy',
        snapshotText: cameraFreePolicy,
        snapshotDigest: 'd_missing_cam',
        createdAt: DateTime(2026, 11, 18),
        overallState: ReviewOverallState.noConcern,
        inferenceSource: InferenceSource.offlineDeterministic,
        summary: 'No concerns identified.',
        calibratedDisclaimer: 'Not a safety certification.',
        findings: const [],
        sourceSnapshot: PolicyIntakeHelper.snapshotForManualOrSharedText(
          sourceType: PolicySourceType.url,
          text: cameraFreePolicy,
        ),
        permissionReport: const AppPermissionComparisonReport(
          snapshot: AppPermissionSnapshot(
            packageName: 'org.studio.app',
            appName: 'Classroom Studio',
            requestedPermissions: ['android.permission.CAMERA'],
            grantedPermissions: [],
          ),
          items: [],
          limitationNotice: 'Permission list comes from APK manifest.',
        ),
      );

      const cameraPerm = DeclaredSensitivePermission(
        permission: 'android.permission.CAMERA',
        categoryId: 'camera',
        title: 'Camera',
        whatPermissionMeans: 'Allows the app to take photos or record video.',
        grantStatus: DeclaredPermissionGrantStatus.denied,
        statusNote: 'Declared · Currently denied',
      );

      // 1. Missing disclosure on verified policy -> empty verbatimExcerpts & missingDisclosure status
      final missingExp = CompanionPolicyResolver.buildExplanation(
        permission: cameraPerm,
        confirmedAppLabel: 'Classroom Studio',
        confirmedPackageName: 'org.studio.app',
        verifiedReceipt: missingReceipt,
      );
      expect(missingExp.hasVerifiedPolicy, isTrue);
      expect(
        missingExp.disclosureStatus,
        CompanionDisclosureStatus.missingDisclosure,
      );
      expect(missingExp.verbatimExcerpts, isEmpty);

      final coordinator = ReviewCoordinator();

      // 2. Prompt construction + CloudConsentSheet preview MUST NOT treat opening sentence as Quoted Clause
      final consentCheck = await coordinator.askDeniAboutPermission(
        explanation: missingExp,
        question: 'Why does Classroom Studio request Camera?',
        confirmedPackageName: 'org.studio.app',
        cloudConsent: false,
      );
      expect(consentCheck.requiresCloudConsent, isTrue);
      expect(
        consentCheck.redactedPreview,
        contains('Matched Policy Excerpt: None'),
      );
      expect(consentCheck.redactedPreview, isNot(contains('Quoted Clause:')));
      expect(
        consentCheck.redactedPreview,
        contains('Disclosure status: Missing in reviewed policy'),
      );
      expect(analyseCalls, hasLength(1));
      expect(
        analyseCalls.single['text'],
        contains('Matched Policy Excerpt: None'),
      );
      expect(analyseCalls.single['text'], isNot(contains('Quoted Clause:')));

      // 3. Deterministic fallback MUST NOT manufacture a policy quote or cite opening sentence
      final deterministicDefault = await coordinator.askDeniAboutPermission(
        explanation: missingExp,
        question: 'Why does Classroom Studio request Camera?',
        confirmedPackageName: 'org.studio.app',
        forceLocalManualFallback: true,
      );
      expect(
        deterministicDefault.whatPolicySays,
        isNot(contains('Policy quote:')),
      );
      expect(
        deterministicDefault.whatPolicySays,
        isNot(contains(openingSentence)),
      );
      expect(
        deterministicDefault.answer,
        contains('does not explicitly mention Camera'),
      );

      final deterministicOptOut = await coordinator.askDeniAboutPermission(
        explanation: missingExp,
        question: 'Can I use the app without granting this access?',
        confirmedPackageName: 'org.studio.app',
        forceLocalManualFallback: true,
      );
      expect(
        deterministicOptOut.whatPolicySays,
        isNot(contains('Policy quote:')),
      );
      expect(
        deterministicOptOut.whatPolicySays,
        isNot(contains(openingSentence)),
      );
      expect(
        deterministicOptOut.answer,
        contains('No matching disclosure was found'),
      );

      // 4. Ambiguous conditional disclosure vs Verified affirmative disclosure
      const conditionalPolicy =
          '$openingSentence Our camera access may be used from time to time if needed for optional scanning.';
      final ambiguousReceipt = PolicyReviewReceipt(
        id: 'r_ambig_cam',
        subjectTitle: 'Classroom Studio',
        sourceLabel: 'https://studio.example/privacy',
        snapshotText: conditionalPolicy,
        snapshotDigest: 'd_ambig_cam',
        createdAt: DateTime(2026, 11, 18),
        overallState: ReviewOverallState.reviewRecommended,
        inferenceSource: InferenceSource.offlineDeterministic,
        summary: 'Summary.',
        calibratedDisclaimer: 'Calibrated.',
        findings: const [],
        sourceSnapshot: PolicyIntakeHelper.snapshotForManualOrSharedText(
          sourceType: PolicySourceType.url,
          text: conditionalPolicy,
        ),
        permissionReport: missingReceipt.permissionReport,
      );
      final ambiguousExp = CompanionPolicyResolver.buildExplanation(
        permission: cameraPerm,
        confirmedAppLabel: 'Classroom Studio',
        confirmedPackageName: 'org.studio.app',
        verifiedReceipt: ambiguousReceipt,
      );
      expect(
        ambiguousExp.disclosureStatus,
        CompanionDisclosureStatus.ambiguousDisclosure,
      );
      expect(
        ambiguousExp.verbatimExcerpts,
        equals([
          'Our camera access may be used from time to time if needed for optional scanning.',
        ]),
      );

      // 5. Verified affirmative disclosure returns matched quote verbatim and cites Quote in prompt + fallback
      const matchedCameraSentence =
          'Camera input is used to scan printed math worksheets locally on the tablet.';
      const verifiedCameraPolicy = '$openingSentence $matchedCameraSentence';
      final verifiedCameraReceipt = PolicyReviewReceipt(
        id: 'r_ver_cam',
        subjectTitle: 'Classroom Studio',
        sourceLabel: 'https://studio.example/privacy',
        snapshotText: verifiedCameraPolicy,
        snapshotDigest: 'd_ver_cam',
        createdAt: DateTime(2026, 11, 18),
        overallState: ReviewOverallState.reviewRecommended,
        inferenceSource: InferenceSource.offlineDeterministic,
        summary: 'Summary.',
        calibratedDisclaimer: 'Calibrated.',
        findings: const [],
        sourceSnapshot: PolicyIntakeHelper.snapshotForManualOrSharedText(
          sourceType: PolicySourceType.url,
          text: verifiedCameraPolicy,
        ),
        permissionReport: missingReceipt.permissionReport,
      );
      final verifiedCamExp = CompanionPolicyResolver.buildExplanation(
        permission: cameraPerm,
        confirmedAppLabel: 'Classroom Studio',
        confirmedPackageName: 'org.studio.app',
        verifiedReceipt: verifiedCameraReceipt,
      );
      expect(
        verifiedCamExp.disclosureStatus,
        CompanionDisclosureStatus.verifiedDisclosure,
      );
      expect(verifiedCamExp.verbatimExcerpts, equals([matchedCameraSentence]));

      final verifiedConsent = await coordinator.askDeniAboutPermission(
        explanation: verifiedCamExp,
        question: 'Why does Classroom Studio request Camera?',
        confirmedPackageName: 'org.studio.app',
        cloudConsent: false,
      );
      expect(
        verifiedConsent.redactedPreview,
        contains('Quoted Clause: "$matchedCameraSentence"'),
      );

      final verifiedDeterministic = await coordinator.askDeniAboutPermission(
        explanation: verifiedCamExp,
        question: 'What does this mean?',
        confirmedPackageName: 'org.studio.app',
        forceLocalManualFallback: true,
      );
      expect(
        verifiedDeterministic.whatPolicySays,
        equals('Policy quote: “$matchedCameraSentence”'),
      );
    });
  });

  group('Quick Settings Companion Widget & E2E Flow Tests', () {
    testWidgets(
      'Cold start + duplicate invocation protection + app confirmation + permission selection/status + policy not found + return to previous app',
      (WidgetTester tester) async {
        final returnedCalls = <String>[];
        var initialFetched = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'getDeviceCapability') {
                return {
                  'isSupported': false,
                  'modelStatus': 'UNAVAILABLE',
                  'apiLevel': 35,
                  'userMessage': 'Local scanner active',
                };
              }
              if (call.method == 'listLaunchableApps') {
                return [
                  {
                    'packageName': 'com.ululab.numbers',
                    'appName': 'Math Makers',
                    'isSystemApp': false,
                  },
                ];
              }
              return null;
            });

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(companionChannel, (call) async {
              switch (call.method) {
                case 'getInitialCompanionInvocation':
                  if (initialFetched) return null;
                  initialFetched = true;
                  return {
                    'schemaVersion': 1,
                    'invocationId': 'qs-cold-1',
                    'source': 'quick_settings',
                    'timestampMs': 1760000005000,
                    'deviceLocked': false,
                  };
                case 'checkUsageAccess':
                  return {'status': 'granted', 'deviceLocked': false};
                case 'getQuickSettingsTileStatus':
                  return {
                    'canRequestDirectAdd': true,
                    'isTileAdded': true,
                    'hasDeclinedBefore': false,
                    'apiLevel': 35,
                  };
                case 'resolveForegroundApp':
                  return {
                    'schemaVersion': 1,
                    'resolutionStatus': 'identified',
                    'packageName': 'com.ululab.numbers',
                    'applicationLabel': 'Math Makers',
                    'eventTimestamp': 1760000001000,
                    'eventAgeMillis': 4000,
                    'confidence': 'high',
                    'candidates': [
                      {
                        'packageName': 'com.ululab.numbers',
                        'applicationLabel': 'Math Makers',
                        'eventTimestamp': 1760000001000,
                        'eventAgeMillis': 4000,
                        'permissionMetadataAvailable': true,
                      },
                    ],
                    'permissionMetadataAvailable': true,
                  };
                case 'getDeclaredSensitivePermissions':
                  return {
                    'status': 'ok',
                    'packageName': 'com.ululab.numbers',
                    'applicationLabel': 'Math Makers',
                    'versionName': '01.30.00',
                    'versionCode': 130,
                    'permissions': [
                      {
                        'permission': 'android.permission.CAMERA',
                        'categoryId': 'camera',
                        'title': 'Camera',
                        'whatPermissionMeans': 'Takes photos and video.',
                        'grantStatus': 'denied',
                        'isRuntimePermission': true,
                        'statusNote': 'Declared · Currently denied',
                      },
                      {
                        'permission': 'android.permission.POST_NOTIFICATIONS',
                        'categoryId': 'notifications',
                        'title': 'Notifications',
                        'whatPermissionMeans': 'Shows alerts and reminders.',
                        'grantStatus': 'granted',
                        'isRuntimePermission': true,
                        'statusNote': 'Declared · Currently granted',
                      },
                    ],
                  };
                case 'returnToPreviousApp':
                  returnedCalls.add('returned');
                  return true;
              }
              return null;
            });

        await tester.pumpWidget(
          const EnpriveApp(
            showSplashOnLaunch: true,
            splashDuration: Duration(milliseconds: 1400),
          ),
        );
        await _pumpFrames(tester, count: 8);

        // Duplicate warm delivery with same invocationId MUST NOT push second CompanionScreen
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              'com.enprive/companion',
              const StandardMethodCodec().encodeMethodCall(
                const MethodCall('onCompanionInvocation', {
                  'schemaVersion': 1,
                  'invocationId': 'qs-cold-1',
                  'source': 'quick_settings',
                  'timestampMs': 1760000005000,
                  'deviceLocked': false,
                }),
              ),
              (_) {},
            );
        await _pumpFrames(tester);

        expect(find.byType(CompanionScreen), findsOneWidget);
        expect(find.text('Deni — Enprive Companion'), findsWidgets);
        expect(
          find.text("We think you're using Math Makers. Is this correct?"),
          findsOneWidget,
        );

        // Confirm identified app
        await tester.tap(find.byKey(const Key('companion_confirm_app_btn')));
        await _pumpFrames(tester);

        expect(find.text("You're looking at Math Makers."), findsOneWidget);
        expect(
          find.text('Which permission would you like to understand?'),
          findsOneWidget,
        );
        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('Listed by app · Not allowed'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Listed by app · Allowed'), findsOneWidget);

        // Select Camera permission
        final cameraTile = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(cameraTile);
        await tester.pump();
        await tester.tap(cameraTile);
        await _pumpFrames(tester);

        expect(find.text('1. What this permission means'), findsOneWidget);
        expect(
          find.text(CompanionPolicyResolver.unverifiedPolicyHeadline),
          findsWidgets,
        );

        // Ask Deni local question when no verified policy is present
        final denyChip = find.text('What happens if I deny it?');
        await tester.ensureVisible(denyChip);
        await tester.pump();
        await tester.tap(denyChip);
        await _pumpFrames(tester);
        expect(
          find.byKey(const Key('companion_deni_answer_card')),
          findsOneWidget,
        );

        // Return to previous app
        final returnBtn = find.byKey(const Key('companion_return_btn'));
        await tester.ensureVisible(returnBtn);
        await tester.pump();
        await tester.tap(returnBtn);
        await _pumpFrames(tester);

        expect(returnedCalls, ['returned']);
        expect(find.byType(CompanionScreen), findsNothing);
      },
    );

    testWidgets(
      'Warm invocation, usageAccessDenied fallback, empty permissions, cloud consent, timeout & user cancellation in CompanionScreen',
      (WidgetTester tester) async {
        final cancelCalls = <String?>[];
        var modeForNextCloud = 'slow_hang';
        var cloudRequestCount = 0;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'getDeviceCapability') {
                return {
                  'isSupported': false,
                  'modelStatus': 'UNAVAILABLE',
                  'apiLevel': 35,
                  'userMessage': 'Unavailable',
                };
              }
              if (call.method == 'listLaunchableApps') {
                return [
                  {
                    'packageName': 'com.example.noperm',
                    'appName': 'Quiet Notes',
                    'isSystemApp': false,
                  },
                  {
                    'packageName': 'de.knowunity.app',
                    'appName': 'Knowunity',
                    'isSystemApp': false,
                  },
                ];
              }
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                if (args['requestedMode'] == 'ONLY_IN_CLOUD') {
                  cloudRequestCount += 1;
                  if (modeForNextCloud == 'timeout') {
                    return {
                      'schemaVersion': 1,
                      'requestId': args['requestId'],
                      'status': 'cancelled',
                      'inferenceSource': 'UNKNOWN',
                      'errorCode': 'TIMED_OUT',
                      'message': 'Timed out',
                    };
                  }
                  return {
                    'schemaVersion': 1,
                    'requestId': args['requestId'],
                    'status': 'cancelled',
                    'inferenceSource': 'UNKNOWN',
                    'errorCode': 'CANCELLED',
                    'message': 'Cancelled',
                  };
                }
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'unavailable',
                  'inferenceSource': 'UNKNOWN',
                  'errorCode': 'Unavailable',
                  'message': 'Nano unavailable',
                };
              }
              if (call.method == 'cancelAnalysis') {
                final args = call.arguments as Map?;
                cancelCalls.add(args?['requestId'] as String?);
                return true;
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
                    'canRequestDirectAdd': true,
                    'isTileAdded': false,
                    'hasDeclinedBefore': false,
                    'apiLevel': 35,
                  };
                case 'resolveForegroundApp':
                  return {
                    'schemaVersion': 1,
                    'resolutionStatus': 'usageAccessDenied',
                    'confidence': 'none',
                    'fallbackReason': 'Usage Access denied.',
                  };
                case 'getDeclaredSensitivePermissions':
                  final pkg = (call.arguments as Map)['packageName'] as String;
                  if (pkg == 'com.example.noperm') {
                    return {
                      'status': 'ok',
                      'packageName': pkg,
                      'applicationLabel': 'Quiet Notes',
                      'versionName': '1.0',
                      'versionCode': 1,
                      'permissions': [],
                    };
                  }
                  return {
                    'status': 'ok',
                    'packageName': pkg,
                    'applicationLabel': 'Knowunity',
                    'versionName': '6.44.4',
                    'versionCode': 644,
                    'permissions': [
                      {
                        'permission': 'android.permission.CAMERA',
                        'categoryId': 'camera',
                        'title': 'Camera',
                        'whatPermissionMeans': 'Captures photos and video.',
                        'grantStatus': 'denied',
                        'isRuntimePermission': true,
                        'statusNote': 'Declared · Currently denied',
                      },
                    ],
                  };
              }
              return null;
            });

        await tester.pumpWidget(
          const EnpriveApp(
            showSplashOnLaunch: false,
            splashDuration: Duration.zero,
          ),
        );
        await _pumpFrames(tester);

        // Warm start invocation while on Home
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              'com.enprive/companion',
              const StandardMethodCodec().encodeMethodCall(
                const MethodCall('onCompanionInvocation', {
                  'schemaVersion': 1,
                  'invocationId': 'qs-warm-2',
                  'source': 'quick_settings',
                  'timestampMs': 1760000010000,
                  'deviceLocked': false,
                }),
              ),
              (_) {},
            );
        await _pumpFrames(tester);

        // usageAccessDenied fallback UI shown honestly
        expect(find.text('Allow Usage Access (optional)'), findsOneWidget);
        expect(
          find.byKey(const Key('companion_choose_app_manual_btn')),
          findsOneWidget,
        );

        // Pick app with 0 declared sensitive permissions
        await tester.tap(
          find.byKey(const Key('companion_choose_app_manual_btn')),
        );
        await _pumpFrames(tester);
        final quietNotesFinder = find.text('Quiet Notes');
        await tester.ensureVisible(quietNotesFinder);
        await tester.pump();
        await tester.tap(quietNotesFinder);
        await _pumpFrames(tester);

        expect(
          find.text(
            'This app doesn\'t ask for any sensitive permissions on your phone.',
          ),
          findsOneWidget,
        );

        // "I'm not sure which permission" still works gracefully
        final unsureBtn = find.byKey(const Key('companion_unsure_perm_btn'));
        await tester.ensureVisible(unsureBtn);
        await tester.pump();
        await tester.tap(unsureBtn);
        await _pumpFrames(tester);
        expect(
          find.text('Match what the popup on your screen asked for'),
          findsOneWidget,
        );

        // Switch to verified app via Knowunity + test cloud timeout
        final switchAppBtn = find.text('Switch app');
        await tester.ensureVisible(switchAppBtn);
        await tester.pump();
        await tester.tap(switchAppBtn);
        await _pumpFrames(tester);
        final knowunityFinder = find.text('Knowunity');
        await tester.ensureVisible(knowunityFinder);
        await tester.pump();
        await tester.tap(knowunityFinder);
        await _pumpFrames(tester);
        final cameraItem1 = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(cameraItem1);
        await tester.pump();
        await tester.tap(cameraItem1);
        await _pumpFrames(tester);

        // Test attaching verified policy via paste -> CloudConsent -> Timeout
        final savedReceipts = <PolicyReviewReceipt>[];
        final coord = ReviewCoordinator();
        final verifiedPolicy = PolicyReviewReceipt(
          id: 'r_knowunity',
          subjectTitle: 'Knowunity',
          sourceLabel: 'https://knowunity.com/legal/privacy',
          snapshotText: 'When students scan handwritten flashcards using the camera, Knowunity processes camera images to extract study notes. Third-party analytics SDKs are strictly limited for educational stability.',
          snapshotDigest: 'd2',
          createdAt: DateTime(2026, 11, 16),
          overallState: ReviewOverallState.reviewRecommended,
          inferenceSource: InferenceSource.offlineDeterministic,
          summary: 'Summary',
          calibratedDisclaimer: 'Not a certification.',
          findings: const [],
          permissionReport: const AppPermissionComparisonReport(
            snapshot: AppPermissionSnapshot(
              packageName: 'de.knowunity.app',
              appName: 'Knowunity',
              requestedPermissions: ['android.permission.CAMERA'],
              grantedPermissions: [],
            ),
            items: [],
            limitationNotice: 'Local',
          ),
          sourceSnapshot: PolicyIntakeHelper.snapshotForManualOrSharedText(
            sourceType: PolicySourceType.url,
            text: 'When students scan handwritten flashcards using the camera, Knowunity processes camera images to extract study notes. Third-party analytics SDKs are strictly limited for educational stability.',
          ),
        );

        final completerCancelCalls = <String?>[];
        Completer<Map<String, dynamic>>? pendingCloudAsk;

        // First timeout scenario, then switch handler for live cancel scenario
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'getDeviceCapability') {
                return {
                  'isSupported': false,
                  'modelStatus': 'UNAVAILABLE',
                  'apiLevel': 35,
                  'userMessage': 'Unavailable',
                };
              }
              if (call.method == 'listLaunchableApps') {
                return [
                  {
                    'packageName': 'de.knowunity.app',
                    'appName': 'Knowunity',
                    'isSystemApp': false,
                  },
                ];
              }
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                if (args['requestedMode'] == 'ONLY_IN_CLOUD') {
                  cloudRequestCount += 1;
                  if (modeForNextCloud == 'timeout') {
                    return {
                      'schemaVersion': 1,
                      'requestId': args['requestId'],
                      'status': 'cancelled',
                      'inferenceSource': 'UNKNOWN',
                      'errorCode': 'TIMED_OUT',
                      'message': 'Timed out',
                    };
                  }
                  pendingCloudAsk = Completer<Map<String, dynamic>>();
                  return pendingCloudAsk!.future;
                }
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'unavailable',
                  'inferenceSource': 'UNKNOWN',
                  'errorCode': 'Unavailable',
                  'message': 'Nano unavailable',
                };
              }
              if (call.method == 'cancelAnalysis') {
                final args = call.arguments as Map?;
                final reqId = args?['requestId'] as String?;
                cancelCalls.add(reqId);
                completerCancelCalls.add(reqId);
                if (pendingCloudAsk != null && !pendingCloudAsk!.isCompleted) {
                  pendingCloudAsk!.complete({
                    'schemaVersion': 1,
                    'requestId': reqId,
                    'status': 'cancelled',
                    'inferenceSource': 'UNKNOWN',
                    'errorCode': 'CANCELLED',
                    'message': 'Cancelled by user',
                  });
                }
                return true;
              }
              return null;
            });

        // Directly mount CompanionScreen with verified receipt to test CloudConsent + Timeout & User Cancel cleanly
        modeForNextCloud = 'timeout';
        await tester.pumpWidget(
          M3EMaterialApp(
            data: EnpriveM3ETheme.lightThemeData,
            typeface: EnpriveM3ETheme.typefaceConfig,
            autoTheming: false,
            dynamicColoring: false,
            initialTheme: Brightness.light,
            theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
            darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
            localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
            appBuilder: (context, child) => EnpriveM3EBridgeScope(
              themeMode: ThemeMode.light,
              child: child ?? const SizedBox.shrink(),
            ),
            home: CompanionScreen(
              hybridBridge: HybridAiBridge(),
              companionBridge: CompanionBridge(),
              coordinator: coord,
              urlRetriever: PolicyUrlRetriever(),
              savedReceipts: [verifiedPolicy],
              onSaveReceipt: (r) async => savedReceipts.add(r),
            ),
          ),
        );
        await _pumpFrames(tester);

        // Choose Knowunity manually -> verify Camera -> verified policy displayed
        await tester.tap(
          find.byKey(const Key('companion_choose_app_manual_btn')),
        );
        await _pumpFrames(tester);
        final knowunityFinder2 = find.text('Knowunity').first;
        await tester.ensureVisible(knowunityFinder2);
        await tester.pump();
        await tester.tap(knowunityFinder2);
        await _pumpFrames(tester);
        final cameraItem2 = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(cameraItem2);
        await tester.pump();
        await tester.tap(cameraItem2);
        await _pumpFrames(tester);

        expect(find.text('Mentioned in verified policy text'), findsOneWidget);
        expect(find.byKey(const Key('companion_ask_deni_btn')), findsOneWidget);

        // Ask Deni -> triggers CloudConsentSheet -> Use cloud AI -> TIMED_OUT notice, zero answer card fabricated
        final qChip = find.widgetWithText(
          ActionChip,
          'Why does this app need my camera?',
        );
        await tester.ensureVisible(qChip);
        await tester.pump();
        await tester.tap(qChip);
        await _pumpFrames(tester);

        expect(find.text('Choose how to review this text'), findsOneWidget);
        final useCloudBtn = find.text('Use cloud for this check');
        await tester.ensureVisible(useCloudBtn);
        await tester.pump();
        await tester.tap(useCloudBtn);
        await _pumpFrames(tester);

        expect(cloudRequestCount, 1);
        expect(find.text('Cloud answer timed out cleanly.'), findsOneWidget);
        expect(
          find.byKey(const Key('companion_deni_answer_card')),
          findsNothing,
        );

        // Now trigger second cloud question and tap live Cancel button mid-flight
        modeForNextCloud = 'live_hang';
        await tester.ensureVisible(qChip);
        await tester.pump();
        await tester.tap(qChip);
        await _pumpFrames(tester);
        final useCloudBtn2 = find.text('Use cloud for this check');
        await tester.ensureVisible(useCloudBtn2);
        await tester.pump();
        await tester.tap(useCloudBtn2);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final cancelBtn = find.byKey(
          const ValueKey<String>('review_progress_cancel_btn'),
        );
        expect(cancelBtn, findsOneWidget);
        await tester.ensureVisible(cancelBtn);
        await tester.pump();
        await tester.tap(cancelBtn);
        await _pumpFrames(tester);

        expect(completerCancelCalls, isNotEmpty);
        expect(
          find.byKey(const Key('companion_deni_answer_card')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'SettingsScreen displays Quick Settings tile and optional Usage Access onboarding without nagging',
      (WidgetTester tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async => null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(companionChannel, (call) async {
              if (call.method == 'checkUsageAccess') {
                return {'status': 'denied', 'deviceLocked': false};
              }
              if (call.method == 'getQuickSettingsTileStatus') {
                return {
                  'canRequestDirectAdd': true,
                  'isTileAdded': false,
                  'hasDeclinedBefore': false,
                  'apiLevel': 35,
                };
              }
              if (call.method == 'requestQuickSettingsTile') {
                return {'outcome': 'tile_added', 'apiLevel': 35};
              }
              return null;
            });

        await tester.pumpWidget(
          M3EMaterialApp(
            data: EnpriveM3ETheme.lightThemeData,
            typeface: EnpriveM3ETheme.typefaceConfig,
            autoTheming: false,
            dynamicColoring: false,
            initialTheme: Brightness.light,
            theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
            darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
            localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
            appBuilder: (context, child) => EnpriveM3EBridgeScope(
              themeMode: ThemeMode.light,
              child: child ?? const SizedBox.shrink(),
            ),
            home: Scaffold(
              body: SettingsScreen(
                bridge: HybridAiBridge(),
                companionBridge: CompanionBridge(),
                capability: null,
                explanationDepth: ExplanationDepth.balanced,
                currentLocale: const Locale('en'),
                savedReceiptsCount: 0,
                onExplanationDepthChanged: (_) {},
                onLocaleChanged: (_) {},
                onRefreshCapability: () {},
                onClearAllReceipts: () {},
                onOpenCompanion: () {},
              ),
            ),
          ),
        );
        await _pumpFrames(tester);

        expect(find.text('Connect Enprive to Quick Settings'), findsOneWidget);
        expect(find.text('Enprive Check tile'), findsOneWidget);
        expect(find.text('Allow Usage Access (optional)'), findsOneWidget);
        expect(find.text('Open Deni Companion'), findsOneWidget);
        expect(
          find.textContaining(
            'Enprive does not continuously monitor your screen.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('D5.3-D Phase 3a: Companion Unified Policy Intake, Consent Parity & Lifecycle', () {
    Future<List<InternetAddress>> fakePublicDns(String host) async => [
      InternetAddress('93.184.216.34'),
    ];

    void installMathMakersCompanionChannel({
      List<String>? returnedCalls,
      List<String>? playStorePackages,
      bool metadataUnavailable = false,
    }) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(companionChannel, (call) async {
            switch (call.method) {
              case 'getInitialCompanionInvocation':
                return null;
              case 'checkUsageAccess':
                return {'status': 'granted', 'deviceLocked': false};
              case 'getQuickSettingsTileStatus':
                return {
                  'canRequestDirectAdd': true,
                  'isTileAdded': true,
                  'hasDeclinedBefore': false,
                  'apiLevel': 35,
                };
              case 'resolveForegroundApp':
                return {
                  'schemaVersion': 1,
                  'resolutionStatus': 'identified',
                  'packageName': 'com.ululab.numbers',
                  'applicationLabel': 'Math Makers',
                  'eventTimestamp': 1760000001000,
                  'eventAgeMillis': 3000,
                  'confidence': 'high',
                  'candidates': [
                    {
                      'packageName': 'com.ululab.numbers',
                      'applicationLabel': 'Math Makers',
                      'eventTimestamp': 1760000001000,
                      'eventAgeMillis': 3000,
                      'permissionMetadataAvailable': !metadataUnavailable,
                    },
                  ],
                  'permissionMetadataAvailable': !metadataUnavailable,
                };
              case 'getDeclaredSensitivePermissions':
                final pkg = (call.arguments as Map)['packageName'] as String;
                if (metadataUnavailable) {
                  return {
                    'status': 'metadata_unavailable',
                    'packageName': pkg,
                    'errorMessage': 'Metadata unavailable in test.',
                    'permissions': [],
                  };
                }
                if (pkg == 'de.knowunity.app') {
                  return {
                    'status': 'ok',
                    'packageName': pkg,
                    'applicationLabel': 'Knowunity',
                    'versionName': '6.44.4',
                    'versionCode': 644,
                    'permissions': [
                      {
                        'permission': 'android.permission.CAMERA',
                        'categoryId': 'camera',
                        'title': 'Camera',
                        'whatPermissionMeans': 'Captures photos and video.',
                        'grantStatus': 'denied',
                        'isRuntimePermission': true,
                        'statusNote': 'Declared · Currently denied',
                      },
                    ],
                  };
                }
                return {
                  'status': 'ok',
                  'packageName': pkg,
                  'applicationLabel': 'Math Makers',
                  'versionName': '1.3.0',
                  'versionCode': 130,
                  'permissions': [
                    {
                      'permission': 'android.permission.CAMERA',
                      'categoryId': 'camera',
                      'title': 'Camera',
                      'whatPermissionMeans': 'Takes photos and video.',
                      'grantStatus': 'denied',
                      'isRuntimePermission': true,
                      'statusNote': 'Declared · Currently denied',
                    },
                  ],
                };
              case 'openPlayStoreListing':
                final pkg = (call.arguments as Map)['packageName'] as String;
                playStorePackages?.add(pkg);
                return {
                  'status': 'opened_store',
                  'packageName': pkg,
                  'launchedUri': 'market://details?id=$pkg',
                };
              case 'returnToPreviousApp':
                returnedCalls?.add('returned');
                return true;
            }
            return null;
          });
    }

    testWidgets(
      '1. Companion URL intake: locked identity, Play Store link, 404 retry, failed intake preserves context, and unmatched/ambiguous association warnings',
      (WidgetTester tester) async {
        final playStorePackages = <String>[];
        installMathMakersCompanionChannel(playStorePackages: playStorePackages);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'inspectSelectedApp') {
                return {
                  'packageName': 'com.ululab.numbers',
                  'appName': 'Math Makers',
                  'requestedPermissions': ['android.permission.CAMERA'],
                  'grantedPermissions': [],
                };
              }
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'ON_DEVICE',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary': 'Verified URL policy on device.',
                    'concerns': [],
                  },
                };
              }
              return null;
            });

        const validHtmlPolicy =
            'Math Makers uses the device camera only to scan classroom math worksheets on this phone and never sells student personal data.';
        final retriever = PolicyUrlRetriever(
          dnsLookup: fakePublicDns,
          clientFactory: () => MockClient((request) async {
            if (request.url.path == '/missing') {
              return http.Response('Not Found', 404);
            }
            return http.Response(
              '<html><body><main><p>$validHtmlPolicy</p></main></body></html>',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }),
        );
        final repo = ReceiptRepository(useInMemoryOnly: true);

        await tester.pumpWidget(
          _wrapCompanionApp(
            child: CompanionScreen(
              hybridBridge: HybridAiBridge(),
              companionBridge: CompanionBridge(),
              coordinator: ReviewCoordinator(),
              urlRetriever: retriever,
              savedReceipts: const [],
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpFrames(tester);

        await tester.tap(find.byKey(const Key('companion_confirm_app_btn')));
        await _pumpFrames(tester);
        final cameraTile = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(cameraTile);
        await tester.pump();
        await tester.tap(cameraTile);
        await _pumpFrames(tester);

        final attachBtn = find.byKey(const Key('companion_attach_policy_btn'));
        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpFrames(tester);

        // Locked app context + Play Store convenience link
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(
          find.byKey(const Key('intake_locked_app_header')),
          findsOneWidget,
        );
        expect(find.text('Verify policy for Math Makers'), findsOneWidget);
        expect(find.byKey(const Key('intake_title_field')), findsNothing);
        expect(find.byKey(const Key('intake_select_app_btn')), findsNothing);
        expect(find.byKey(const Key('intake_play_store_btn')), findsOneWidget);

        await tester.tap(find.byKey(const Key('intake_play_store_btn')));
        await _pumpFrames(tester);
        expect(playStorePackages, ['com.ululab.numbers']);

        // 404 URL failure keeps sheet open and preserves typed URL
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://ululab.example/missing',
        );
        final submitBtn = find.byKey(const Key('intake_primary_submit_btn'));
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _pumpFrames(tester);

        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_url_field')))
              .controller!
              .text,
          'https://ululab.example/missing',
        );

        // Closing after failure leaves Companion app + permission context intact
        await tester.tap(find.byKey(const Key('intake_close_btn')));
        await _pumpFrames(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        expect(find.text("You're looking at Math Makers."), findsOneWidget);
        expect(
          find.text(CompanionPolicyResolver.unverifiedPolicyHeadline),
          findsWidgets,
        );

        // Re-open, test unmatched & ambiguous association warnings in locked mode, then retry valid URL
        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpFrames(tester);

        await tester.tap(find.text('Paste text'));
        await _pumpFrames(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'This privacy policy for com.rival.tracker explains advertising telemetry and data deletion controls.',
        );
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _pumpFrames(tester);

        // Unmatched warning in locked mode exposes Continue anyway only
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('intake_association_continue_btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('intake_association_change_app_btn')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('intake_association_without_app_btn')),
          findsNothing,
        );

        // Ambiguous identity (selected app name + competing package ID) also warns honestly
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Math Makers and com.rival.tracker share this privacy policy explaining camera usage and account deletion.',
        );
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _pumpFrames(tester);
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );
        expect(
          find.textContaining('do not verify developer ownership'),
          findsOneWidget,
        );

        // Switch to URL mode, fetch valid public HTML -> updates Deni quote & SHA-256 without auto-saving
        await tester.tap(find.text('Policy link'));
        await _pumpFrames(tester);
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://ululab.example/privacy',
        );
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _pumpFrames(tester, count: 8);

        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        expect(find.text('Mentioned in verified policy text'), findsOneWidget);
        expect(
          find.textContaining('scan classroom math worksheets'),
          findsOneWidget,
        );
        expect(find.text('Exact quote from policy'), findsOneWidget);
        expect(find.textContaining('SHA-256 · '), findsNothing);
        final advToggle = find.byKey(
          const Key('companion_advanced_details_toggle'),
        );
        await tester.ensureVisible(advToggle);
        await tester.pump();
        await tester.tap(advToggle);
        await _pumpFrames(tester);
        expect(find.textContaining('SHA-256 · '), findsOneWidget);
        expect(
          find.byKey(const Key('companion_receipt_unsaved_label')),
          findsOneWidget,
        );
        expect(await repo.loadReceipts(), isEmpty);
      },
    );

    testWidgets(
      '2. Companion document intake: supports PDF, TXT, DOCX, picker cancellation without false error, and failure replacement',
      (WidgetTester tester) async {
        installMathMakersCompanionChannel();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'ON_DEVICE',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary': 'Verified document policy locally.',
                    'concerns': [],
                  },
                };
              }
              return null;
            });

        var pickStep = 0;
        final fakeDocs = _FakeCompanionDocBridge();
        fakeDocs.onInspect = (pkg) async => AppPermissionSnapshot(
          packageName: pkg,
          appName: 'Math Makers',
          requestedPermissions: const ['android.permission.CAMERA'],
          grantedPermissions: const [],
        );
        fakeDocs.onPick = () async {
          pickStep++;
          return switch (pickStep) {
            1 => const DocumentExtractionOutcome(
              status: 'cancelled',
              extractedText: '',
              userMessage: 'No document was selected.',
            ),
            2 => const DocumentExtractionOutcome(
              status: 'password_protected',
              documentType: 'pdf',
              fileName: 'locked.pdf',
              mimeType: 'application/pdf',
              byteLength: 256,
              extractedText: '',
              userMessage: 'This PDF is password-protected.',
            ),
            3 => const DocumentExtractionOutcome(
              status: 'ok',
              documentType: 'pdf',
              fileName: 'math_policy.pdf',
              mimeType: 'application/pdf',
              byteLength: 2048,
              extractedText: 'Math Makers PDF policy: camera access is used exclusively to scan geometry flashcards on device.',
              userMessage: 'Extracted PDF.',
            ),
            4 => const DocumentExtractionOutcome(
              status: 'ok',
              documentType: 'txt',
              fileName: 'math_policy.txt',
              mimeType: 'text/plain',
              byteLength: 512,
              extractedText: 'Math Makers TXT policy: camera scanning runs offline on this phone for textbook problems.',
              userMessage: 'Extracted TXT.',
            ),
            _ => const DocumentExtractionOutcome(
              status: 'ok',
              documentType: 'docx',
              fileName: 'math_policy.docx',
              mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              byteLength: 1024,
              extractedText: 'Math Makers DOCX policy: camera captures stay local for classroom board exercises and are never sold.',
              userMessage: 'Extracted DOCX.',
            ),
          };
        };

        final intakeCoordinator = PolicyIntakeCoordinator(
          documentBridge: fakeDocs,
        );
        final repo = ReceiptRepository(useInMemoryOnly: true);

        await tester.pumpWidget(
          _wrapCompanionApp(
            child: CompanionScreen(
              hybridBridge: HybridAiBridge(),
              companionBridge: CompanionBridge(),
              coordinator: ReviewCoordinator(),
              urlRetriever: PolicyUrlRetriever(),
              intakeCoordinator: intakeCoordinator,
              savedReceipts: const [],
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpFrames(tester);

        await tester.tap(find.byKey(const Key('companion_confirm_app_btn')));
        await _pumpFrames(tester);
        final cameraTile = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(cameraTile);
        await tester.pump();
        await tester.tap(cameraTile);
        await _pumpFrames(tester);

        final attachBtn = find.byKey(const Key('companion_attach_policy_btn'));
        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpFrames(tester);

        await tester.tap(find.text('Document'));
        await _pumpFrames(tester);
        final submitBtn = find.byKey(const Key('intake_primary_submit_btn'));

        // Step 1: Picker cancelled -> no false error banner, sheet stays open
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _pumpFrames(tester);
        expect(find.byKey(const Key('intake_error_banner')), findsNothing);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);

        // Step 2: Password-protected failure -> inline error banner
        await tester.tap(submitBtn);
        await _pumpFrames(tester);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(find.text('This PDF is password-protected.'), findsOneWidget);

        // Step 3: Replacement PDF succeeds -> updates Deni excerpt & saves with PDF provenance
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _pumpFrames(tester, count: 8);
        expect(find.textContaining('scan geometry flashcards'), findsOneWidget);
        final saveBtn = find.byKey(const Key('companion_save_receipt_btn'));
        await tester.ensureVisible(saveBtn);
        await tester.pump();
        await tester.tap(saveBtn);
        await _pumpFrames(tester);
        expect(
          (await repo.loadReceipts()).first.sourceSnapshot?.sourceType,
          PolicySourceType.pdf,
        );

        // Step 4: Update with TXT document -> refreshes Deni excerpt & TXT provenance
        final updateBtn = find.byKey(const Key('companion_update_policy_btn'));
        await tester.ensureVisible(updateBtn);
        await tester.pump();
        await tester.tap(updateBtn);
        await _pumpFrames(tester);
        await tester.tap(find.text('Document'));
        await _pumpFrames(tester);
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _pumpFrames(tester, count: 8);
        expect(
          find.textContaining('offline on this phone for textbook problems'),
          findsOneWidget,
        );
        final saveBtn2 = find.byKey(const Key('companion_save_receipt_btn'));
        await tester.ensureVisible(saveBtn2);
        await tester.pump();
        await tester.tap(saveBtn2);
        await _pumpFrames(tester);
        expect(
          (await repo.loadReceipts()).any(
            (r) =>
                r.sourceSnapshot?.sourceType == PolicySourceType.textDocument,
          ),
          isTrue,
        );

        // Step 5: Update with DOCX document -> refreshes Deni excerpt & DOCX provenance
        await tester.ensureVisible(updateBtn);
        await tester.pump();
        await tester.tap(updateBtn);
        await _pumpFrames(tester);
        await tester.tap(find.text('Document'));
        await _pumpFrames(tester);
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _pumpFrames(tester, count: 8);
        expect(
          find.textContaining('classroom board exercises'),
          findsOneWidget,
        );
        final saveBtn3 = find.byKey(const Key('companion_save_receipt_btn'));
        await tester.ensureVisible(saveBtn3);
        await tester.pump();
        await tester.tap(saveBtn3);
        await _pumpFrames(tester);
        expect(
          (await repo.loadReceipts()).any(
            (r) => r.sourceSnapshot?.sourceType == PolicySourceType.docx,
          ),
          isTrue,
        );
      },
    );

    testWidgets(
      '3. Companion review & cloud consent: local review, consent denied, canonicalRedactedPreview byte-for-byte parity, zero permission leakage, cloud unavailable fallback & cancel',
      (WidgetTester tester) async {
        installMathMakersCompanionChannel();
        final cloudPayloads = <String>[];
        final cancelRequests = <String?>[];
        var cloudBehavior = 'success';
        Completer<Map<String, dynamic>>? pendingCloud;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'inspectSelectedApp') {
                return {
                  'packageName': 'com.ululab.numbers',
                  'appName': 'Math Makers',
                  'requestedPermissions': [
                    'android.permission.CAMERA',
                    'android.permission.RECORD_AUDIO',
                  ],
                  'grantedPermissions': ['android.permission.CAMERA'],
                };
              }
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                if (args['requestedMode'] == 'ONLY_ON_DEVICE') {
                  return {
                    'schemaVersion': 1,
                    'requestId': args['requestId'],
                    'status': 'unavailable',
                    'inferenceSource': 'UNKNOWN',
                    'errorCode': 'Unavailable',
                    'message': 'Gemini Nano unavailable on device.',
                  };
                }
                cloudPayloads.add(args['text'] as String);
                if (cloudBehavior == 'unavailable') {
                  return {
                    'schemaVersion': 1,
                    'requestId': args['requestId'],
                    'status': 'unavailable',
                    'inferenceSource': 'UNKNOWN',
                    'errorCode': 'NETWORK_UNAVAILABLE',
                    'message': 'Offline.',
                  };
                }
                if (cloudBehavior == 'hang') {
                  pendingCloud = Completer<Map<String, dynamic>>();
                  return pendingCloud!.future;
                }
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'IN_CLOUD',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary': 'Cloud verified scrubbed policy.',
                    'concerns': [],
                  },
                };
              }
              if (call.method == 'cancelAnalysis') {
                final reqId = (call.arguments as Map?)?['requestId'] as String?;
                cancelRequests.add(reqId);
                if (pendingCloud != null && !pendingCloud!.isCompleted) {
                  pendingCloud!.complete({
                    'schemaVersion': 1,
                    'requestId': reqId,
                    'status': 'cancelled',
                    'inferenceSource': 'UNKNOWN',
                    'errorCode': 'CANCELLED',
                    'message': 'Cancelled by user.',
                  });
                }
                return true;
              }
              return null;
            });

        const piiPolicy =
            'Math Makers uses the camera strictly to scan printed worksheets on device. Contact parent.jane@example.org or call 555-019-2834 for privacy questions.';
        final expectedCanonical = ReviewCoordinator.canonicalCloudPayload(
          piiPolicy,
        );

        final repo = ReceiptRepository(useInMemoryOnly: true);
        await tester.pumpWidget(
          _wrapCompanionApp(
            child: CompanionScreen(
              hybridBridge: HybridAiBridge(),
              companionBridge: CompanionBridge(),
              coordinator: ReviewCoordinator(),
              urlRetriever: PolicyUrlRetriever(),
              savedReceipts: const [],
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpFrames(tester);

        await tester.tap(find.byKey(const Key('companion_confirm_app_btn')));
        await _pumpFrames(tester);
        final cameraTile = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(cameraTile);
        await tester.pump();
        await tester.tap(cameraTile);
        await _pumpFrames(tester);

        Future<void> submitPiiViaSheet({required bool isUpdate}) async {
          final trigger = find.byKey(
            Key(
              isUpdate
                  ? 'companion_update_policy_btn'
                  : 'companion_attach_policy_btn',
            ),
          );
          await tester.ensureVisible(trigger);
          await tester.pump();
          await tester.tap(trigger);
          await _pumpFrames(tester);
          await tester.tap(find.text('Paste text'));
          await _pumpFrames(tester);
          await tester.enterText(
            find.byKey(const Key('intake_paste_field')),
            piiPolicy,
          );
          final submit = find.byKey(const Key('intake_primary_submit_btn'));
          await tester.ensureVisible(submit);
          await tester.pump();
          await tester.tap(submit);
          await _pumpFrames(tester);
        }

        // A) Cloud consent required -> Deny/Cancel -> 0 cloud calls, Companion unchanged
        await submitPiiViaSheet(isUpdate: false);
        expect(find.byType(CloudConsentSheet), findsOneWidget);
        expect(cloudPayloads, isEmpty);
        final consentWidget = tester.widget<CloudConsentSheet>(
          find.byType(CloudConsentSheet),
        );
        expect(consentWidget.policyText, piiPolicy);
        expect(consentWidget.canonicalRedactedPreview, expectedCanonical);
        expect(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.textContaining('parent.jane@example.org'),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.textContaining('555-019-2834'),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.text('Hidden (2)'),
          ),
          findsOneWidget,
        );
        final previewSelectable = tester.widget<SelectableText>(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.byType(SelectableText),
          ),
        );
        final displayedPreview =
            previewSelectable.data ?? previewSelectable.textSpan!.toPlainText();
        expect(displayedPreview, equals(expectedCanonical));

        final cancelConsentBtn = find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.byTooltip('Close'),
        );
        await tester.ensureVisible(cancelConsentBtn);
        await tester.pump();
        await tester.tap(cancelConsentBtn);
        await _pumpFrames(tester);
        expect(cloudPayloads, isEmpty);
        expect(
          find.text(CompanionPolicyResolver.unverifiedPolicyHeadline),
          findsWidgets,
        );

        // B) Explicit cloud consent -> byte-for-byte canonical payload parity + zero permission/package leakage
        await submitPiiViaSheet(isUpdate: false);
        expect(find.byType(CloudConsentSheet), findsOneWidget);
        final useCloudBtn = find.text('Use cloud for this check');
        await tester.ensureVisible(useCloudBtn);
        await tester.pump();
        await tester.tap(useCloudBtn);
        await _pumpFrames(tester, count: 8);

        expect(cloudPayloads, hasLength(1));
        expect(cloudPayloads.single, equals(expectedCanonical));
        expect(cloudPayloads.single, equals(displayedPreview));
        expect(
          cloudPayloads.single,
          isNot(contains('parent.jane@example.org')),
        );
        expect(cloudPayloads.single, isNot(contains('555-019-2834')));
        expect(cloudPayloads.single, isNot(contains('com.ululab.numbers')));
        expect(
          cloudPayloads.single,
          isNot(contains('android.permission.CAMERA')),
        );
        expect(
          cloudPayloads.single,
          isNot(contains('android.permission.RECORD_AUDIO')),
        );
        expect(find.text('Mentioned in verified policy text'), findsOneWidget);

        // C) Local-only review via CloudConsentSheet -> 0 new cloud calls
        await submitPiiViaSheet(isUpdate: true);
        expect(find.byType(CloudConsentSheet), findsOneWidget);
        final localBtn = find.text('Review on this phone');
        await tester.ensureVisible(localBtn);
        await tester.pump();
        await tester.tap(localBtn);
        await _pumpFrames(tester, count: 8);
        expect(cloudPayloads, hasLength(1));
        expect(find.text('Mentioned in verified policy text'), findsOneWidget);

        // D) Cloud unavailable after explicit consent -> clean offline deterministic fallback
        cloudBehavior = 'unavailable';
        await submitPiiViaSheet(isUpdate: true);
        await tester.ensureVisible(useCloudBtn);
        await tester.pump();
        await tester.tap(useCloudBtn);
        await _pumpFrames(tester, count: 8);
        expect(cloudPayloads, hasLength(2));
        expect(find.text('Mentioned in verified policy text'), findsOneWidget);

        // E) Mid-flight cloud cancellation restores UI cleanly
        cloudBehavior = 'hang';
        await submitPiiViaSheet(isUpdate: true);
        await tester.ensureVisible(useCloudBtn);
        await tester.pump();
        await tester.tap(useCloudBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final cancelReviewBtn = find.byKey(
          const ValueKey<String>('review_progress_cancel_btn'),
        );
        expect(cancelReviewBtn, findsOneWidget);
        await tester.ensureVisible(cancelReviewBtn);
        await tester.pump();
        await tester.tap(cancelReviewBtn);
        await _pumpFrames(tester);
        expect(cancelRequests, isNotEmpty);
        expect(
          find.byKey(const Key('companion_update_policy_btn')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '4. Companion lifecycle: AppBar Close returns to caller app, no false permission snapshot when metadata unavailable, and app switch ignores stale async review',
      (WidgetTester tester) async {
        // Part A: AppBar Close button invokes CompanionBridge.returnToPreviousApp()
        final returnedCalls = <String>[];
        installMathMakersCompanionChannel(returnedCalls: returnedCalls);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async => null);

        await tester.pumpWidget(
          _wrapCompanionApp(
            child: Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CompanionScreen(
                            invocation: const CompanionInvocation(
                              invocationId: 'qs-close-check',
                              source: 'quick_settings',
                              timestampMs: 1760000005000,
                              deviceLocked: false,
                            ),
                            hybridBridge: HybridAiBridge(),
                            companionBridge: CompanionBridge(),
                            coordinator: ReviewCoordinator(),
                            urlRetriever: PolicyUrlRetriever(),
                            savedReceipts: const [],
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Companion'),
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpFrames(tester);
        await tester.tap(find.text('Open Companion'));
        await _pumpFrames(tester);
        await tester.tap(find.byKey(const Key('companion_appbar_back_btn')));
        await _pumpFrames(tester);
        expect(returnedCalls, ['returned']);
        expect(find.byType(CompanionScreen), findsNothing);

        // Part B: No false permission snapshot when metadataUnavailable AND inspectSelectedApp is null
        installMathMakersCompanionChannel(metadataUnavailable: true);
        PolicyReviewReceipt? observedReceipt;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'inspectSelectedApp') return null;
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'ON_DEVICE',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary':
                        'Reviewed locally without fabricating permissions.',
                    'concerns': [],
                  },
                };
              }
              return null;
            });

        await tester.pumpWidget(
          _wrapCompanionApp(
            child: CompanionScreen(
              key: const Key('companion_part_b'),
              hybridBridge: HybridAiBridge(),
              companionBridge: CompanionBridge(),
              coordinator: ReviewCoordinator(),
              urlRetriever: PolicyUrlRetriever(),
              savedReceipts: const [],
              onSaveReceipt: (r) async => observedReceipt = r,
            ),
          ),
        );
        await _pumpFrames(tester);
        await tester.tap(find.byKey(const Key('companion_confirm_app_btn')));
        await _pumpFrames(tester);
        expect(find.text("Couldn't read app permissions"), findsOneWidget);
        await tester.tap(find.text("I'm not sure which permission"));
        await _pumpFrames(tester);
        final guidedCam = find.byKey(const Key('companion_guided_camera'));
        await tester.ensureVisible(guidedCam);
        await tester.pump();
        await tester.tap(guidedCam);
        await _pumpFrames(tester);

        final attachBtn = find.byKey(const Key('companion_attach_policy_btn'));
        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpFrames(tester);
        await tester.tap(find.text('Paste text'));
        await _pumpFrames(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Math Makers explains camera privacy controls clearly and never sells personal data to brokers.',
        );
        final submitBtn = find.byKey(const Key('intake_primary_submit_btn'));
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await _pumpFrames(tester, count: 6);
        // No false empty permission snapshot was fabricated, so no false package match occurred
        expect(observedReceipt, isNull);
        expect(tester.takeException(), isNull);

        // Part C: Switching app mid-review cancels and ignores stale asynchronous completion
        installMathMakersCompanionChannel();
        Completer<Map<String, dynamic>>? staleReviewCompleter;
        final cancelledIds = <String?>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'listLaunchableApps') {
                return [
                  {
                    'packageName': 'de.knowunity.app',
                    'appName': 'Knowunity',
                    'isSystemApp': false,
                  },
                ];
              }
              if (call.method == 'inspectSelectedApp') {
                final pkg = (call.arguments as Map)['packageName'] as String;
                return {
                  'packageName': pkg,
                  'appName': pkg == 'de.knowunity.app'
                      ? 'Knowunity'
                      : 'Math Makers',
                  'requestedPermissions': ['android.permission.CAMERA'],
                  'grantedPermissions': [],
                };
              }
              if (call.method == 'analyseText') {
                staleReviewCompleter = Completer<Map<String, dynamic>>();
                return staleReviewCompleter!.future;
              }
              if (call.method == 'cancelAnalysis') {
                cancelledIds.add(
                  (call.arguments as Map?)?['requestId'] as String?,
                );
                return true;
              }
              return null;
            });

        await tester.pumpWidget(
          _wrapCompanionApp(
            child: CompanionScreen(
              key: const Key('companion_part_c'),
              hybridBridge: HybridAiBridge(),
              companionBridge: CompanionBridge(),
              coordinator: ReviewCoordinator(),
              urlRetriever: PolicyUrlRetriever(),
              savedReceipts: const [],
            ),
          ),
        );
        await _pumpFrames(tester);
        await tester.tap(find.byKey(const Key('companion_confirm_app_btn')));
        await _pumpFrames(tester);
        final camTile = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(camTile);
        await tester.pump();
        await tester.tap(camTile);
        await _pumpFrames(tester);

        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpFrames(tester);
        await tester.tap(find.text('Paste text'));
        await _pumpFrames(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Math Makers camera policy keeps worksheet scans strictly on device and never sells student data.',
        );
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(staleReviewCompleter, isNotNull);

        // Switch app while Math Makers review is still in flight
        final switchAppBtn = find.text('Switch app');
        await tester.ensureVisible(switchAppBtn);
        await tester.pump();
        await tester.tap(switchAppBtn);
        await _pumpFrames(tester);
        final knowunityRow = find.text('Knowunity');
        await tester.ensureVisible(knowunityRow);
        await tester.pump();
        await tester.tap(knowunityRow);
        await _pumpFrames(tester);

        expect(cancelledIds, isNotEmpty);
        expect(find.text("You're looking at Knowunity."), findsOneWidget);

        // Complete the stale Math Makers review late -> must not corrupt Knowunity or throw
        staleReviewCompleter!.complete({
          'schemaVersion': 1,
          'requestId': 'stale',
          'status': 'success',
          'inferenceSource': 'ON_DEVICE',
          'structuredOutput': {
            'overall_state': 'NO_CONCERN',
            'summary': 'Stale Math Makers result.',
            'concerns': [],
          },
        });
        await _pumpFrames(tester);
        expect(find.text("You're looking at Knowunity."), findsOneWidget);
        expect(find.textContaining('Stale Math Makers'), findsNothing);
        expect(tester.takeException(), isNull);

        // Part D: Disposing CompanionScreen while an async policy review is still pending
        // cancels the active analysis and ignores late completions with zero framework errors.
        cancelledIds.clear();
        final knowunityCam = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(knowunityCam);
        await tester.pump();
        await tester.tap(knowunityCam);
        await _pumpFrames(tester);

        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpFrames(tester);
        await tester.tap(find.text('Paste text'));
        await _pumpFrames(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Knowunity camera policy processes flashcard scans locally on device and never sells student photos.',
        );
        await tester.ensureVisible(submitBtn);
        await tester.pump();
        await tester.tap(submitBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Dispose CompanionScreen while Knowunity review is still in flight
        await tester.pumpWidget(
          _wrapCompanionApp(child: const Scaffold(body: Text('Disposed'))),
        );
        await _pumpFrames(tester);
        expect(cancelledIds, isNotEmpty);

        // Complete late after disposal -> zero setState-after-dispose exceptions
        staleReviewCompleter!.complete({
          'schemaVersion': 1,
          'requestId': 'late_after_dispose',
          'status': 'success',
          'inferenceSource': 'ON_DEVICE',
          'structuredOutput': {
            'overall_state': 'NO_CONCERN',
            'summary': 'Late completion after dispose.',
            'concerns': [],
          },
        });
        await _pumpFrames(tester);
        expect(find.text('Disposed'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '5. Step B: Companion tactile CTAs are keyboard reachable and Enter activates them',
      (WidgetTester tester) async {
        final returnedCalls = <String>[];
        installMathMakersCompanionChannel(returnedCalls: returnedCalls);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async => null);

        await tester.pumpWidget(
          _wrapCompanionApp(
            child: Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CompanionScreen(
                            invocation: const CompanionInvocation(
                              invocationId: 'qs-keyboard-check',
                              source: 'quick_settings',
                              timestampMs: 1760000005000,
                              deviceLocked: false,
                            ),
                            hybridBridge: HybridAiBridge(),
                            companionBridge: CompanionBridge(),
                            coordinator: ReviewCoordinator(),
                            urlRetriever: PolicyUrlRetriever(),
                            savedReceipts: const [],
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Companion'),
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpFrames(tester);
        await tester.tap(find.text('Open Companion'));
        await _pumpFrames(tester);

        Finder labelOf(String key) => find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(Text),
        );

        await tabTo(tester, labelOf('companion_confirm_app_btn'));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await _pumpFrames(tester);
        expect(find.text("You're looking at Math Makers."), findsOneWidget);

        final returnLabel = labelOf('companion_return_btn');
        expect(
          tester.widget<Text>(returnLabel).data,
          'Done · Return to Math Makers',
        );
        await tabTo(tester, returnLabel);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await _pumpFrames(tester);
        expect(returnedCalls, ['returned']);
        expect(find.byType(CompanionScreen), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
