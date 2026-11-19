import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:enprive/domain/companion/companion_policy_resolver.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/main.dart';
import 'package:enprive/screens/companion_screen.dart';
import 'package:enprive/screens/settings_screen.dart';
import 'package:enprive/services/intake/policy_intake_helper.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';
import 'package:enprive/services/platform/companion_bridge.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

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
    test(
      'CompanionPolicyResolver strictly verifies exact package match and builds verified vs unverified explanations',
      () {
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
          calibratedDisclaimer:
              'No concern identified in the reviewed evidence.',
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
      },
    );

    test(
      'ReviewCoordinator.askDeniAboutPermission answers locally with 0 cloud calls when policy is missing, and strips packageName from cloud payloads when verified policy exists',
      () async {
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
                'answer': 'Quoted policy states contacts sync classroom rosters.',
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
          snapshotText:
              'With parental permission, we read your address book contacts to suggest classroom peers. No advertising SDKs are included in student accounts and records stay encrypted.',
          snapshotDigest: 'd1',
          createdAt: DateTime(2026, 11, 16),
          overallState: ReviewOverallState.reviewRecommended,
          inferenceSource: InferenceSource.onDevice,
          summary: 'Summary',
          calibratedDisclaimer: 'Calibrated.',
          findings: const [],
          sourceSnapshot: PolicyIntakeHelper.snapshotForManualOrSharedText(
            sourceType: PolicySourceType.url,
            text:
                'With parental permission, we read your address book contacts to suggest classroom peers. No advertising SDKs are included in student accounts and records stay encrypted.',
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
              exactExcerpt:
                  'Android Manifest Observation: android.permission.CAMERA (REQUESTED) — no matching disclosure found in policy snapshot.',
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
      },
    );

    test(
      'askDeniAboutPermission never substitutes opening snapshot sentence when no matching excerpt exists and distinguishes missing, ambiguous, and verified disclosures',
      () async {
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
          whatPermissionMeans:
              'Allows the app to take photos or record video.',
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
        expect(deterministicDefault.whatPolicySays, isNot(contains('Policy quote:')));
        expect(deterministicDefault.whatPolicySays, isNot(contains(openingSentence)));
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
        expect(deterministicOptOut.whatPolicySays, isNot(contains('Policy quote:')));
        expect(deterministicOptOut.whatPolicySays, isNot(contains(openingSentence)));
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
        expect(
          verifiedCamExp.verbatimExcerpts,
          equals([matchedCameraSentence]),
        );

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
      },
    );
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
        expect(find.text('Declared · Currently denied'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Declared · Currently granted'), findsOneWidget);

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
        expect(find.byKey(const Key('companion_deni_answer_card')), findsOneWidget);

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
          find.text('No sensitive runtime permissions declared by this app.'),
          findsOneWidget,
        );

        // "I'm not sure which permission" still works gracefully
        final unsureBtn = find.byKey(const Key('companion_unsure_perm_btn'));
        await tester.ensureVisible(unsureBtn);
        await tester.pump();
        await tester.tap(unsureBtn);
        await _pumpFrames(tester);
        expect(
          find.text('Match what the Android prompt asked for'),
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
          snapshotText:
              'When students scan handwritten flashcards using the camera, Knowunity processes camera images to extract study notes. Third-party analytics SDKs are strictly limited for educational stability.',
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
            text:
                'When students scan handwritten flashcards using the camera, Knowunity processes camera images to extract study notes. Third-party analytics SDKs are strictly limited for educational stability.',
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
        expect(find.byKey(const Key('companion_deni_answer_card')), findsNothing);

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
        expect(find.byKey(const Key('companion_deni_answer_card')), findsNothing);
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
          find.textContaining('Enprive does not continuously monitor your screen.'),
          findsOneWidget,
        );
      },
    );
  });
}
