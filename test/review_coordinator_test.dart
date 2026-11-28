import 'package:flutter/material.dart' show Locale;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.enprive/hybrid_ai');

  const sampleEduTrackPolicy = '''
When a student uses EduTrack on a mobile device, we collect device identifiers, operating system telemetry, and session duration logs. In addition, our mobile application collects precise GPS location coordinates even when the application is running in the background to verify school bus zone attendance and regional classroom routing.
Student voice recordings and derived speech-fluency transcripts are retained indefinitely on our cloud servers to train and improve our automated speech recognition models unless a verified school administrator submits a written deletion ticket.
''';

  const sampleCalmMathPolicy = '''
CalmMath Abacus is designed for early elementary arithmetic practice. All math problem sets, practice scores, and learning progress are stored exclusively on this device inside local application storage.
We do not collect personal identifiers, precise location data, microphone audio, or camera input. We do not integrate third-party advertising SDKs, and we never sell, rent, or transmit student usage data to external analytics brokers.
''';

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('ReviewCoordinator Hybrid & Evidence Tests', () {
    test('validates on-device Gemini Nano 4 structured output and marks hallucinated quotes UNVERIFIED', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': 'test_req_1',
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'REVIEW_RECOMMENDED',
                  'summary':
                      'Background GPS and indefinite voice retention found.',
                  'concerns': [
                    {
                      'id': 'f_valid',
                      'title': 'Background GPS Tracking',
                      'category': 'TRACKING',
                      'severity': 'HIGH',
                      'quote': 'collects precise GPS location coordinates even when the application is running in the background',
                      'explanation':
                          'Tracks student location in the background.',
                    },
                    {
                      'id': 'f_hallucinated',
                      'title': 'Fabricated Biometric Sale',
                      'category': 'SHARING',
                      'severity': 'HIGH',
                      'quote': 'We sell student fingerprints to data brokers.',
                      'explanation': 'Hallucinated claim that must be caught.',
                    },
                  ],
                  'calibratedDisclaimer':
                      ReviewCoordinator.calibratedDefaultDisclaimer,
                },
              };
            }
            return null;
          });

      final coordinator = ReviewCoordinator();
      final outcome = await coordinator.runPolicyReview(
        subjectTitle: 'EduTrack',
        sourceLabel: 'Test Snapshot',
        policyText: sampleEduTrackPolicy,
      );

      expect(outcome.needsCloudConsentOrManual, isFalse);
      final receipt = outcome.receipt!;
      expect(receipt.overallState, ReviewOverallState.reviewRecommended);
      expect(receipt.inferenceSource, InferenceSource.onDevice);
      expect(receipt.findings.length, 2);
      expect(receipt.sourceMatchedCount, 1);
      expect(receipt.unverifiedCount, 1);

      final matchedFinding = receipt.findings.first;
      expect(matchedFinding.status, EvidenceStatus.sourceMatched);
      expect(matchedFinding.contextWindow, isNotNull);
      expect(
        matchedFinding.contextWindow!.matched,
        contains('collects precise GPS location coordinates'),
      );

      final unverifiedFinding = receipt.findings.last;
      expect(unverifiedFinding.status, EvidenceStatus.unverified);
    });

    test('blocks cloud escalation when on-device Nano 4 is unavailable without consent, provides scrubbed preview, and runs ONLY_IN_CLOUD only after explicit consent', () async {
      final recordedCalls = <Map<String, dynamic>>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              recordedCalls.add(args);
              final mode = args['requestedMode'] as String?;
              if (mode == 'ONLY_ON_DEVICE') {
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'unavailable',
                  'inferenceSource': 'UNKNOWN',
                  'message': 'AICore Gemini Nano 4 not installed on emulator.',
                };
              }
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'success',
                'inferenceSource': 'IN_CLOUD',
                'structuredOutput': {
                  'overall_state': 'REVIEW_RECOMMENDED',
                  'summary': 'Background GPS tracking found.',
                  'concerns': [
                    {
                      'id': 'f_1',
                      'title': 'Tracks location in background',
                      'category': 'TRACKING',
                      'severity': 'HIGH',
                      'quote': 'collects precise GPS location coordinates even when the application is running in the background',
                      'explanation':
                          'Tracks student location in the background.',
                    },
                  ],
                  'calibratedDisclaimer':
                      ReviewCoordinator.calibratedDefaultDisclaimer,
                },
              };
            }
            return null;
          });

      const policyWithPii = '''
Child: Maya Lin (privacy@school.edu, +1 415-555-0199) uses EduTrack.
Our mobile application collects precise GPS location coordinates even when the application is running in the background to verify school bus zone attendance.
''';

      final coordinator = ReviewCoordinator();
      final blockedOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'EduTrack',
        sourceLabel: 'Test Snapshot',
        policyText: policyWithPii,
      );

      // Zero cloud calls occurred without explicit consent.
      expect(blockedOutcome.needsCloudConsentOrManual, isTrue);
      expect(blockedOutcome.receipt, isNull);
      expect(recordedCalls.length, 1);
      expect(recordedCalls[0]['requestedMode'], 'ONLY_ON_DEVICE');
      expect(recordedCalls[0]['cloudConsent'], isFalse);

      // Preview passed to CloudConsentSheet is already PII-scrubbed.
      expect(blockedOutcome.redactedPreview, isNotNull);
      expect(blockedOutcome.redactedPreview, isNot(contains('Maya Lin')));
      expect(
        blockedOutcome.redactedPreview,
        isNot(contains('privacy@school.edu')),
      );
      expect(blockedOutcome.redactedPreview, isNot(contains('415-555-0199')));
      expect(blockedOutcome.redactedPreview, contains('[PERSON]'));
      expect(blockedOutcome.redactedPreview, contains('[EMAIL]'));
      expect(blockedOutcome.redactedPreview, contains('[PHONE]'));

      // After explicit consent, only the redacted payload is sent via ONLY_IN_CLOUD.
      final consentedOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'EduTrack',
        sourceLabel: 'Test Snapshot',
        policyText: policyWithPii,
        cloudConsent: true,
      );

      expect(consentedOutcome.needsCloudConsentOrManual, isFalse);
      expect(consentedOutcome.receipt, isNotNull);
      expect(
        consentedOutcome.receipt!.inferenceSource,
        InferenceSource.inCloud,
      );
      expect(recordedCalls.length, 2);
      expect(recordedCalls[1]['requestedMode'], 'ONLY_IN_CLOUD');
      expect(recordedCalls[1]['cloudConsent'], isTrue);

      final sentText = recordedCalls[1]['text'] as String;
      expect(sentText, equals(blockedOutcome.redactedPreview));
      expect(sentText, isNot(contains('Maya Lin')));
      expect(sentText, isNot(contains('privacy@school.edu')));
      expect(sentText, isNot(contains('415-555-0199')));
      expect(sentText, contains('[PERSON]'));
      expect(sentText, contains('[EMAIL]'));
      expect(sentText, contains('[PHONE]'));
    });

    test('blocks cloud escalation on comprehensive policies without consent even after PII redaction, and routes ONLY_IN_CLOUD after consent', () async {
      final recordedCalls = <Map<String, dynamic>>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              recordedCalls.add(args);
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'success',
                'inferenceSource': 'IN_CLOUD',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'Reviewed comprehensive policy.',
                  'concerns': const [],
                  'calibratedDisclaimer':
                      ReviewCoordinator.calibratedDefaultDisclaimer,
                },
              };
            }
            return null;
          });

      final longPolicy =
          'Parent: Sarah Kim (sarah@example.org). '
          '${'This classroom app stores math scores only in local storage. ' * 40}';

      final coordinator = ReviewCoordinator();
      final blockedOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'Long Policy',
        sourceLabel: 'Test Snapshot',
        policyText: longPolicy,
      );

      expect(blockedOutcome.needsCloudConsentOrManual, isTrue);
      expect(blockedOutcome.receipt, isNull);
      expect(recordedCalls, isEmpty);
      expect(blockedOutcome.redactedPreview, isNot(contains('Sarah Kim')));
      expect(
        blockedOutcome.redactedPreview,
        isNot(contains('sarah@example.org')),
      );
      expect(blockedOutcome.redactedPreview, contains('[PERSON]'));
      expect(blockedOutcome.redactedPreview, contains('[EMAIL]'));

      final consentedOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'Long Policy',
        sourceLabel: 'Test Snapshot',
        policyText: longPolicy,
        cloudConsent: true,
      );

      expect(consentedOutcome.receipt, isNotNull);
      expect(
        consentedOutcome.receipt!.inferenceSource,
        InferenceSource.inCloud,
      );
      expect(recordedCalls.length, 1);
      expect(recordedCalls[0]['requestedMode'], 'ONLY_IN_CLOUD');
      expect(recordedCalls[0]['cloudConsent'], isTrue);
      expect(recordedCalls[0]['text'], isNot(contains('Sarah Kim')));
      expect(recordedCalls[0]['text'], isNot(contains('sarah@example.org')));
      expect(recordedCalls[0]['text'], contains('[PERSON]'));
      expect(recordedCalls[0]['text'], contains('[EMAIL]'));
    });

    test('pauses for consent when Nano is unavailable without consent, and falls back to OFFLINE_DETERMINISTIC when consented cloud is offline', () async {
      final recordedCalls = <Map<String, dynamic>>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              recordedCalls.add(args);
              return {
                'schemaVersion': 1,
                'requestId': 'offline_req',
                'status': 'unavailable',
                'inferenceSource': 'UNKNOWN',
                'message': 'Offline.',
              };
            }
            return null;
          });

      final coordinator = ReviewCoordinator();
      final unconsentedOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'EduTrack',
        sourceLabel: 'Offline Test',
        policyText: sampleEduTrackPolicy,
      );

      expect(unconsentedOutcome.needsCloudConsentOrManual, isTrue);
      expect(recordedCalls.length, 1);
      expect(recordedCalls.single['cloudConsent'], isFalse);

      final offlineFallbackOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'EduTrack',
        sourceLabel: 'Offline Test',
        policyText: sampleEduTrackPolicy,
        cloudConsent: true,
      );

      expect(offlineFallbackOutcome.needsCloudConsentOrManual, isFalse);
      expect(
        offlineFallbackOutcome.receipt!.overallState,
        ReviewOverallState.reviewRecommended,
      );
      expect(
        offlineFallbackOutcome.receipt!.inferenceSource,
        InferenceSource.offlineDeterministic,
      );
    });

    test('deterministic local clause scanner identifies verbatim concerns on EduTrack and no concern on CalmMath with OFFLINE_DETERMINISTIC provenance', () async {
      final recordedCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            recordedCalls.add(call);
            return null;
          });

      final coordinator = ReviewCoordinator();

      final eduOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'EduTrack',
        sourceLabel: 'Local Scan',
        policyText: sampleEduTrackPolicy,
        forceLocalManualScan: true,
      );
      expect(
        eduOutcome.receipt!.overallState,
        ReviewOverallState.reviewRecommended,
      );
      expect(
        eduOutcome.receipt!.inferenceSource,
        InferenceSource.offlineDeterministic,
      );
      expect(eduOutcome.receipt!.sourceMatchedCount, greaterThanOrEqualTo(2));

      final calmOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'CalmMath',
        sourceLabel: 'Local Scan',
        policyText: sampleCalmMathPolicy,
        forceLocalManualScan: true,
      );
      expect(calmOutcome.receipt!.overallState, ReviewOverallState.noConcern);
      expect(
        calmOutcome.receipt!.inferenceSource,
        InferenceSource.offlineDeterministic,
      );
      expect(calmOutcome.receipt!.findings, isEmpty);
      expect(
        calmOutcome.receipt!.calibratedDisclaimer,
        contains('This is not a safety certification'),
      );
      expect(recordedCalls, isEmpty);
    });

    test('propagates streamed process steps, model thoughtSummary, and thoughtSignature onto receipt and DeniExplanation', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              final task = args['task'] as String?;
              if (task == 'explain_finding') {
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'IN_CLOUD',
                  'thoughtSummary': 'Checking whether the quote specifies third-party advertising.',
                  'thoughtSignature': 'sig_deni_9876543210abcdef',
                  'structuredOutput': {
                    'answer': 'The quote states advertising partners receive engagement scores.',
                    'whatPolicySays': 'Engagement scores may be shared.',
                    'unknownBoundary': 'Does not state deletion timing.',
                  },
                };
              }
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'success',
                'inferenceSource': 'IN_CLOUD',
                'thoughtSummary': 'Inspecting data sharing clauses and checking opt-out clarity.',
                'thoughtSignature': 'sig_review_1234567890fedcba',
                'thoughtSignatures': ['sig_review_1234567890fedcba'],
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'Reviewed with thinking enabled.',
                  'concerns': const [],
                  'calibratedDisclaimer':
                      ReviewCoordinator.calibratedDefaultDisclaimer,
                },
              };
            }
            return null;
          });

      final coordinator = ReviewCoordinator();
      final emittedStages = <String>[];
      final sub = coordinator.analysisEvents.listen((event) {
        emittedStages.add(event.stage);
      });

      final outcome = await coordinator.runPolicyReview(
        subjectTitle: 'Trace App',
        sourceLabel: 'Test Snapshot',
        policyText: 'We do not sell personal data.',
        cloudConsent: true,
      );

      await Future<void>.delayed(Duration.zero);
      expect(
        emittedStages,
        containsAll([
          'redacting_pii',
          'sending_appcheck',
          'verifying_evidence',
        ]),
      );

      final receipt = outcome.receipt!;
      expect(receipt.processSteps, isNotEmpty);
      expect(
        receipt.thoughtSummary,
        'Inspecting data sharing clauses and checking opt-out clarity.',
      );
      expect(receipt.thoughtSignature, 'sig_review_1234567890fedcba');

      final roundtrip = PolicyReviewReceipt.fromJson(receipt.toJson());
      expect(roundtrip.processSteps, receipt.processSteps);
      expect(roundtrip.thoughtSummary, receipt.thoughtSummary);
      expect(roundtrip.thoughtSignature, receipt.thoughtSignature);

      const finding = VerifiedFinding(
        id: 'f1',
        title: 'Sharing',
        category: FindingCategory.sharing,
        severity: FindingSeverity.medium,
        exactExcerpt: 'Engagement scores may be shared with ad networks.',
        explanation: 'Shares engagement scores.',
        whatPolicySays: 'Engagement scores may be shared.',
        whatAndroidReports: 'Text-only check.',
        unknowns: ['Opt-out steps'],
        status: EvidenceStatus.sourceMatched,
      );

      final explanation = await coordinator.askDeniAboutFinding(
        finding: finding,
        question: 'What does this mean?',
        snapshotText: 'Engagement scores may be shared with ad networks.',
        cloudConsent: true,
      );
      expect(explanation.processSteps, isNotEmpty);
      expect(
        explanation.thoughtSummary,
        'Checking whether the quote specifies third-party advertising.',
      );
      expect(explanation.thoughtSignature, 'sig_deni_9876543210abcdef');

      await sub.cancel();
    });

    test('HybridAiBridge rejects cloud-capable modes immediately without invoking platform channel when cloudConsent is false', () async {
      final recordedCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            recordedCalls.add(call);
            return null;
          });

      final bridge = HybridAiBridge();
      final cloudRes = await bridge.analyseText(
        requestId: 'deny_cloud',
        task: 'summarise_concerns',
        text: 'Policy text.',
        cloudConsent: false,
        requestedMode: 'ONLY_IN_CLOUD',
      );
      final preferRes = await bridge.analyseText(
        requestId: 'deny_prefer',
        task: 'summarise_concerns',
        text: 'Policy text.',
        cloudConsent: false,
        requestedMode: 'PREFER_ON_DEVICE',
      );

      expect(recordedCalls, isEmpty);
      expect(cloudRes.status, HybridStatus.unavailable);
      expect(cloudRes.errorCode, 'CLOUD_CONSENT_REQUIRED');
      expect(cloudRes.inferenceSource, 'UNKNOWN');
      expect(preferRes.status, HybridStatus.unavailable);
      expect(preferRes.errorCode, 'CLOUD_CONSENT_REQUIRED');
      expect(preferRes.inferenceSource, 'UNKNOWN');
    });

    test('askDeniAboutFinding never escalates to cloud without consent on Nano failure or comprehensive input, and supports OFFLINE_DETERMINISTIC fallback', () async {
      final recordedCalls = <Map<String, dynamic>>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              recordedCalls.add(args);
              final mode = args['requestedMode'] as String?;
              if (mode == 'ONLY_ON_DEVICE') {
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'unavailable',
                  'inferenceSource': 'UNKNOWN',
                  'message': 'Nano unavailable on device.',
                };
              }
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'success',
                'inferenceSource': 'IN_CLOUD',
                'structuredOutput': {
                  'answer': 'Verified cloud answer.',
                  'whatPolicySays': 'Engagement scores may be shared.',
                  'unknownBoundary': 'Deletion timing is unspecified.',
                },
              };
            }
            return null;
          });

      const finding = VerifiedFinding(
        id: 'f1',
        title: 'Sharing',
        category: FindingCategory.sharing,
        severity: FindingSeverity.medium,
        exactExcerpt: 'Engagement scores may be shared with ad networks.',
        explanation: 'Shares engagement scores.',
        whatPolicySays: 'Engagement scores may be shared.',
        whatAndroidReports: 'Text-only check.',
        unknowns: ['Opt-out steps'],
        status: EvidenceStatus.sourceMatched,
      );

      final coordinator = ReviewCoordinator();

      // 1. Short input + Nano unavailable -> requires consent, 0 cloud calls
      final shortBlocked = await coordinator.askDeniAboutFinding(
        finding: finding,
        question: 'What does this mean?',
        snapshotText: 'Child: Leo Ng (leo@school.org). Engagement scores may be shared with ad networks.',
        cloudConsent: false,
      );
      expect(shortBlocked.requiresCloudConsent, isTrue);
      expect(shortBlocked.redactedPreview, isNot(contains('Leo Ng')));
      expect(shortBlocked.redactedPreview, isNot(contains('leo@school.org')));
      expect(shortBlocked.redactedPreview, contains('[PERSON]'));
      expect(shortBlocked.redactedPreview, contains('[EMAIL]'));
      expect(recordedCalls.length, 1);
      expect(recordedCalls.single['cloudConsent'], isFalse);

      // 2. Comprehensive input -> requires consent immediately, 0 bridge calls
      final longBlocked = await coordinator.askDeniAboutFinding(
        finding: finding,
        question: 'What does this mean?',
        snapshotText:
            'Parent: Mia Cho (mia@example.com). ${'Engagement scores may be shared with ad networks. ' * 40}',
        cloudConsent: false,
      );
      expect(longBlocked.requiresCloudConsent, isTrue);
      expect(longBlocked.redactedPreview, isNot(contains('Mia Cho')));
      expect(longBlocked.redactedPreview, isNot(contains('mia@example.com')));
      expect(recordedCalls.length, 1);

      // 3. Explicit manual local fallback -> OFFLINE_DETERMINISTIC, 0 bridge calls
      final manualLocal = await coordinator.askDeniAboutFinding(
        finding: finding,
        question: 'Can we opt out?',
        snapshotText: 'Engagement scores may be shared with ad networks.',
        forceLocalManualFallback: true,
        intentHint: 'opt_out',
      );
      expect(manualLocal.requiresCloudConsent, isFalse);
      expect(manualLocal.inferenceSource, InferenceSource.offlineDeterministic);
      expect(recordedCalls.length, 1);

      // 4. Explicit consent -> ONLY_IN_CLOUD with scrubbed text matching preview
      final consented = await coordinator.askDeniAboutFinding(
        finding: finding,
        question: 'What does this mean?',
        snapshotText: 'Child: Leo Ng (leo@school.org). Engagement scores may be shared with ad networks.',
        cloudConsent: true,
      );
      expect(consented.requiresCloudConsent, isFalse);
      expect(consented.inferenceSource, InferenceSource.inCloud);
      expect(recordedCalls.length, 2);
      expect(recordedCalls[1]['cloudConsent'], isTrue);
      expect(recordedCalls[1]['requestedMode'], 'ONLY_IN_CLOUD');
      expect(recordedCalls[1]['text'], equals(shortBlocked.redactedPreview));
      expect(recordedCalls[1]['text'], isNot(contains('Leo Ng')));
      expect(recordedCalls[1]['text'], isNot(contains('leo@school.org')));
    });

    test('maps UNKNOWN native inferenceSource to explicit unknown instead of locationUnavailable or onDevice', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              if (args['task'] == 'explain_finding') {
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'UNKNOWN',
                  'structuredOutput': {
                    'answer': 'This clause allows analytics sharing.',
                    'whatPolicySays': 'Analytics partners receive diagnostics.',
                    'unknownBoundary': 'Retention period is not stated.',
                  },
                };
              }
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'success',
                'inferenceSource': 'UNKNOWN',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'Reviewed locally without reported chunk source.',
                  'concerns': const [],
                  'calibratedDisclaimer':
                      ReviewCoordinator.calibratedDefaultDisclaimer,
                },
              };
            }
            return null;
          });

      final coordinator = ReviewCoordinator();
      final reviewOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'Unknown Source App',
        sourceLabel: 'Test Snapshot',
        policyText: 'We do not sell personal data.',
      );
      expect(reviewOutcome.receipt, isNotNull);
      expect(reviewOutcome.receipt!.inferenceSource, InferenceSource.unknown);

      const finding = VerifiedFinding(
        id: 'f_u',
        title: 'Analytics',
        category: FindingCategory.sharing,
        severity: FindingSeverity.low,
        exactExcerpt: 'Analytics partners receive diagnostics.',
        explanation: 'Shares diagnostics.',
        whatPolicySays: 'Analytics partners receive diagnostics.',
        whatAndroidReports: 'Text-only check.',
        unknowns: ['Retention period'],
        status: EvidenceStatus.sourceMatched,
      );
      final deniOutcome = await coordinator.askDeniAboutFinding(
        finding: finding,
        question: 'What does this mean?',
        snapshotText: 'Analytics partners receive diagnostics.',
      );
      expect(deniOutcome.requiresCloudConsent, isFalse);
      expect(deniOutcome.inferenceSource, InferenceSource.unknown);
    });

    test('consented cloud errors (429, airplane mode, App Check, generic, unsupported thinking) invoke bridge once without retry and fall back to offlineDeterministic', () async {
      final scenarios = <Map<String, dynamic>>[
        {
          'name': 'HTTP 429 quota error',
          'errorCode': 'QuotaExceededException',
          'message': 'Quota exceeded (HTTP 429)',
          'expectUnavailableFallback': true,
        },
        {
          'name': 'Airplane mode network failure',
          'errorCode': 'UnknownHostException',
          'message': 'Unable to resolve host: offline',
          'expectUnavailableFallback': true,
        },
        {
          'name': 'App Check failure',
          'errorCode': 'ServiceConnectionHandshakeFailedException',
          'message': 'App Check verification failed',
          'expectUnavailableFallback': true,
        },
        {
          'name': 'Unsupported thinking configuration',
          'errorCode': 'InvalidStateException',
          'message': 'Thinking config not supported',
          'expectUnavailableFallback': false,
        },
        {
          'name': 'Offline network failure',
          'errorCode': 'UnknownException',
          'message': 'Request failed',
          'expectUnavailableFallback': true,
        },
        {
          'name': 'Server error',
          'errorCode': 'ServerException',
          'message': 'Unexpected model failure',
          'expectUnavailableFallback': true,
        },
      ];

      const finding = VerifiedFinding(
        id: 'f_cloud_err',
        title: 'Third-party Tracking',
        category: FindingCategory.tracking,
        severity: FindingSeverity.medium,
        exactExcerpt:
            'We collect device identifiers to share telemetry with partners.',
        explanation: 'Shares device identifiers with partner telemetry.',
        whatPolicySays:
            'We collect device identifiers to share telemetry with partners.',
        whatAndroidReports: 'Text-only check.',
        unknowns: ['Partner retention period'],
        status: EvidenceStatus.sourceMatched,
      );

      for (final scenario in scenarios) {
        final cloudCalls = <Map<String, dynamic>>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                cloudCalls.add(args);
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'failed',
                  'inferenceSource': 'UNKNOWN',
                  'errorCode': scenario['errorCode'],
                  'message': scenario['message'],
                };
              }
              return null;
            });

        final coordinator = ReviewCoordinator();

        final reviewOutcome = await coordinator.runPolicyReview(
          subjectTitle: 'Scenario App',
          sourceLabel: 'Test Policy',
          policyText:
              'We collect device identifiers to share telemetry with partners.',
          cloudConsent: true,
        );
        expect(
          cloudCalls.length,
          1,
          reason: '${scenario['name']} review must invoke cloud bridge once',
        );
        expect(cloudCalls.single['requestedMode'], 'ONLY_IN_CLOUD');
        expect(reviewOutcome.needsCloudConsentOrManual, isFalse);
        expect(reviewOutcome.receipt, isNotNull);
        expect(
          reviewOutcome.receipt!.inferenceSource,
          InferenceSource.offlineDeterministic,
          reason: '${scenario['name']} must record offlineDeterministic',
        );
        expect(
          reviewOutcome.receipt!.inferenceSource,
          isNot(InferenceSource.onDevice),
        );
        expect(
          reviewOutcome.receipt!.inferenceSource,
          isNot(InferenceSource.inCloud),
        );
        final expectUnavailable = scenario['expectUnavailableFallback'] == true;
        expect(
          reviewOutcome.receipt!.diagnosticKind,
          expectUnavailable
              ? ReviewDiagnosticKind.cloudUnavailableLocalFallback
              : ReviewDiagnosticKind.failedModelInference,
          reason:
              '${scenario['name']} must preserve expected fallback diagnosticKind even when deterministic findings match',
        );
        expect(
          reviewOutcome.receipt!.summary.toLowerCase(),
          expectUnavailable
              ? allOf(contains('cloud'), contains('on-device'))
              : allOf(
                  contains('failed'),
                  contains('local deterministic scanner'),
                ),
          reason:
              '${scenario['name']} summary must explicitly disclose local fallback cause',
        );

        final deniOutcome = await coordinator.askDeniAboutFinding(
          finding: finding,
          question: 'What does this mean?',
          snapshotText:
              'We collect device identifiers to share telemetry with partners.',
          cloudConsent: true,
        );
        expect(
          cloudCalls.length,
          2,
          reason:
              '${scenario['name']} Q&A must invoke cloud bridge once (no retry)',
        );
        expect(cloudCalls.last['requestedMode'], 'ONLY_IN_CLOUD');
        expect(
          deniOutcome.inferenceSource,
          InferenceSource.offlineDeterministic,
        );
        expect(deniOutcome.inferenceSource, isNot(InferenceSource.onDevice));
      }
    });

    test('successful cloud stream executes once with IN_CLOUD provenance while cancelled consent and offline fallback execute zero cloud calls', () async {
      final recordedCalls = <Map<String, dynamic>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              recordedCalls.add(args);
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'success',
                'inferenceSource': 'IN_CLOUD',
                'structuredOutput': {
                  'overall_state': 'REVIEW_RECOMMENDED',
                  'summary': 'Shares device identifiers for telemetry.',
                  'concerns': [
                    {
                      'id': 'f_1',
                      'title': 'Device Identifiers',
                      'category': 'SHARING',
                      'severity': 'MEDIUM',
                      'quote': 'We collect device identifiers to share telemetry with partners.',
                      'explanation':
                          'Device identifiers are shared externally.',
                    },
                  ],
                  'calibratedDisclaimer':
                      ReviewCoordinator.calibratedDefaultDisclaimer,
                },
              };
            }
            return null;
          });

      final coordinator = ReviewCoordinator();

      // 1. Offline deterministic fallback after cancelled consent -> 0 bridge/cloud calls.
      final cancelledFallback = await coordinator.runPolicyReview(
        subjectTitle: 'Local Choice App',
        sourceLabel: 'Test Policy',
        policyText:
            'We collect device identifiers to share telemetry with partners.',
        forceLocalManualScan: true,
      );
      expect(recordedCalls, isEmpty);
      expect(cancelledFallback.needsCloudConsentOrManual, isFalse);
      expect(
        cancelledFallback.receipt!.inferenceSource,
        InferenceSource.offlineDeterministic,
      );

      // 2. Consented cloud review -> 1 bridge call and preserves IN_CLOUD provenance.
      final cloudSuccess = await coordinator.runPolicyReview(
        subjectTitle: 'Cloud Choice App',
        sourceLabel: 'Test Policy',
        policyText:
            'We collect device identifiers to share telemetry with partners.',
        cloudConsent: true,
      );
      expect(recordedCalls.length, 1);
      expect(recordedCalls.single['cloudConsent'], isTrue);
      expect(recordedCalls.single['requestedMode'], 'ONLY_IN_CLOUD');
      expect(cloudSuccess.receipt!.inferenceSource, InferenceSource.inCloud);

      // 3. Second independent approved operation is NOT blocked and runs once cleanly.
      final secondSuccess = await coordinator.runPolicyReview(
        subjectTitle: 'Second Cloud App',
        sourceLabel: 'Test Policy',
        policyText:
            'We collect device identifiers to share telemetry with partners.',
        cloudConsent: true,
      );
      expect(recordedCalls.length, 2);
      expect(secondSuccess.receipt!.inferenceSource, InferenceSource.inCloud);
    });

    test('native cancellation propagates cleanly without becoming a deterministic fallback or triggering a retry while ordinary failures still fall back', () async {
      const finding = VerifiedFinding(
        id: 'f_cancel',
        title: 'Telemetry Sharing',
        category: FindingCategory.sharing,
        severity: FindingSeverity.medium,
        exactExcerpt:
            'We collect device identifiers to share telemetry with partners.',
        explanation: 'Shares identifiers.',
        whatPolicySays:
            'We collect device identifiers to share telemetry with partners.',
        whatAndroidReports: 'Text-only check.',
        unknowns: ['Partner list'],
        status: EvidenceStatus.sourceMatched,
      );

      // A. PlatformException(code: CANCELLED) in runPolicyReview & askDeniAboutFinding
      final platformCancelCalls = <Map<String, dynamic>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              platformCancelCalls.add(
                Map<String, dynamic>.from(call.arguments as Map),
              );
              throw PlatformException(
                code: 'CANCELLED',
                message: 'Child analysis cancelled',
              );
            }
            return null;
          });

      final coordinator = ReviewCoordinator();
      await expectLater(
        coordinator.runPolicyReview(
          subjectTitle: 'Cancel App',
          sourceLabel: 'Test Policy',
          policyText:
              'We collect device identifiers to share telemetry with partners.',
          cloudConsent: true,
        ),
        throwsA(isA<HybridOperationCancelledException>()),
      );
      expect(platformCancelCalls.length, 1);

      await expectLater(
        coordinator.askDeniAboutFinding(
          finding: finding,
          question: 'What does this share?',
          snapshotText:
              'We collect device identifiers to share telemetry with partners.',
          cloudConsent: true,
        ),
        throwsA(isA<HybridOperationCancelledException>()),
      );
      expect(platformCancelCalls.length, 2);

      // B. Status "cancelled" / TIMED_OUT propagates as HybridOperationCancelledException(isTimeout: true)
      final mapCancelCalls = <Map<String, dynamic>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              mapCancelCalls.add(args);
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'cancelled',
                'inferenceSource': 'UNKNOWN',
                'errorCode': 'TIMED_OUT',
                'message':
                    'Cloud inference exceeded the bounded timeout budget.',
              };
            }
            return null;
          });

      // A native timeout is a failed cloud check, not a user cancel: the user
      // keeps the on-device result, labelled honestly, with no silent retry.
      final timedOut = await coordinator.runPolicyReview(
        subjectTitle: 'Timeout Cancel App',
        sourceLabel: 'Test Policy',
        policyText:
            'We collect device identifiers to share telemetry with partners.',
        cloudConsent: true,
      );
      expect(timedOut.needsCloudConsentOrManual, isFalse);
      expect(
        timedOut.receipt!.diagnosticKind,
        ReviewDiagnosticKind.cloudUnavailableLocalFallback,
      );
      expect(
        timedOut.receipt!.inferenceSource,
        InferenceSource.offlineDeterministic,
      );
      expect(timedOut.receipt!.snapshotText, contains('device identifiers'));
      expect(mapCancelCalls.length, 1, reason: 'no silent cloud retry');

      // B2. Status "cancelled" / CANCELLED propagates with isTimeout == false
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'cancelled',
                'inferenceSource': 'UNKNOWN',
                'errorCode': 'CANCELLED',
                'message': 'User cancelled analysis.',
              };
            }
            return null;
          });

      await expectLater(
        coordinator.runPolicyReview(
          subjectTitle: 'User Cancel App',
          sourceLabel: 'Test Policy',
          policyText:
              'We collect device identifiers to share telemetry with partners.',
          cloudConsent: true,
        ),
        throwsA(
          isA<HybridOperationCancelledException>().having(
            (e) => e.isTimeout,
            'isTimeout',
            isFalse,
          ),
        ),
      );

      // C. Ordinary quota / network errors immediately afterward still retain offlineDeterministic fallback
      final ordinaryFailureCalls = <Map<String, dynamic>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              final args = Map<String, dynamic>.from(call.arguments as Map);
              ordinaryFailureCalls.add(args);
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'],
                'status': 'failed',
                'inferenceSource': 'UNKNOWN',
                'errorCode': 'QuotaExceededException',
                'message': 'Quota exceeded (HTTP 429)',
              };
            }
            return null;
          });

      final recoveredAfterCancel = await coordinator.runPolicyReview(
        subjectTitle: 'Quota App',
        sourceLabel: 'Test Policy',
        policyText:
            'We collect device identifiers to share telemetry with partners.',
        cloudConsent: true,
      );
      expect(ordinaryFailureCalls.length, 1);
      expect(
        recoveredAfterCancel.receipt!.inferenceSource,
        InferenceSource.offlineDeterministic,
      );
    });

    test('P0-A: fails closed to insufficientEvidence for empty, placeholder, random, rawText, missing fields, or failed zero-finding outputs', () async {
      var nativeAnalyseCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getDeviceCapability') {
              return {
                'isSupported': true,
                'deviceTier': 'SUPPORTED',
                'modelStatus': 'AVAILABLE',
              };
            }
            if (call.method == 'analyseText') {
              nativeAnalyseCalls += 1;
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'Looks fine',
                  'concerns': [],
                },
              };
            }
            return null;
          });

      final coordinator = ReviewCoordinator();

      // 1. "Privacy notice unavailable." -> insufficientEvidence (0 AI calls)
      final unavailableResult = await coordinator.runPolicyReview(
        subjectTitle: 'QuickTest',
        sourceLabel: 'Quick check',
        policyText: 'Privacy notice unavailable.',
      );
      expect(
        unavailableResult.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );
      expect(
        unavailableResult.receipt!.diagnosticKind,
        ReviewDiagnosticKind.insufficientPolicyMaterial,
      );

      // 2. Random prose -> insufficientEvidence (0 AI calls)
      final randomResult = await coordinator.runPolicyReview(
        subjectTitle: 'Random',
        sourceLabel: 'Paste',
        policyText: 'Yesterday the yellow bicycle leaned against a brick garden wall after lunch.',
      );
      expect(
        randomResult.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );
      expect(
        randomResult.receipt!.diagnosticKind,
        ReviewDiagnosticKind.insufficientPolicyMaterial,
      );

      // 3. Empty text -> insufficientEvidence (0 AI calls)
      final emptyResult = await coordinator.runPolicyReview(
        subjectTitle: 'Empty',
        sourceLabel: 'Paste',
        policyText: '   \n  ',
      );
      expect(
        emptyResult.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );
      expect(nativeAnalyseCalls, 0);

      // 4. rawText fallback (missing structured JSON) -> insufficientEvidence
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'rawText': 'Everything is completely fine!',
                },
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final rawTextResult = await coordinator.runPolicyReview(
        subjectTitle: 'RawTextApp',
        sourceLabel: 'Paste',
        policyText: 'We do not sell personal data.',
      );
      expect(
        rawTextResult.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );

      // 4b. Unparseable/missing structuredOutput with success status -> insufficientEvidence
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': null,
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final missingJsonResult = await coordinator.runPolicyReview(
        subjectTitle: 'UnparseableApp',
        sourceLabel: 'Paste',
        policyText: 'We do not sell personal data.',
      );
      expect(
        missingJsonResult.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );

      // 5. Missing required overall_state -> insufficientEvidence
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'summary': 'Privacy policy reviewed.',
                  'concerns': [],
                },
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final missingStateResult = await coordinator.runPolicyReview(
        subjectTitle: 'MissingStateApp',
        sourceLabel: 'Paste',
        policyText: 'We do not sell personal data.',
      );
      expect(
        missingStateResult.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );

      // 6. Failed inference on valid clean zero-keyword policy -> insufficientEvidence (never silent noConcern)
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'failed',
                'inferenceSource': 'UNKNOWN',
                'errorCode': 'InferenceRuntimeException',
                'message': 'On-device session failed unexpectedly.',
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final failedInferenceResult = await coordinator.runPolicyReview(
        subjectTitle: 'FailedModelApp',
        sourceLabel: 'Paste',
        policyText: 'All homework progress stays strictly on this tablet and is never collected.',
        cloudConsent: true,
      );
      expect(
        failedInferenceResult.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );
      expect(
        failedInferenceResult.receipt!.diagnosticKind,
        ReviewDiagnosticKind.failedModelInference,
      );

      // 6b. Cloud ServerException (high demand) -> on-device result with the
      // cloud-could-not-finish fallback kind, never a silent drop.
      var serverCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              serverCalls++;
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'failed',
                'inferenceSource': 'UNKNOWN',
                'errorCode': 'ServerException',
                'message': 'The model is overloaded due to high demand.',
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final serverError = await coordinator.runPolicyReview(
        subjectTitle: 'ServerErrorApp',
        sourceLabel: 'Paste',
        policyText:
            'We collect device identifiers to share telemetry with partners.',
        cloudConsent: true,
      );
      expect(
        serverError.receipt!.diagnosticKind,
        ReviewDiagnosticKind.cloudUnavailableLocalFallback,
      );
      expect(serverCalls, 1, reason: 'no silent cloud retry');

      // 7. Unavailable cloud fallback on clean zero-keyword policy -> insufficientEvidence (cloudUnavailableLocalFallback)
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'failed',
                'inferenceSource': 'UNKNOWN',
                'errorCode': 'QuotaExceededException',
                'message': 'Cloud quota exceeded',
              };
            }
            return {'isSupported': false, 'modelStatus': 'UNAVAILABLE'};
          });
      final unavailableCloudResult = await coordinator.runPolicyReview(
        subjectTitle: 'CloudDownApp',
        sourceLabel: 'Paste',
        policyText: 'All homework progress stays strictly on this tablet and is never collected.',
        cloudConsent: true,
      );
      expect(
        unavailableCloudResult.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );
      expect(
        unavailableCloudResult.receipt!.diagnosticKind,
        ReviewDiagnosticKind.cloudUnavailableLocalFallback,
      );

      // 8. Valid policy with completed clean AI output still yields calibrated noConcern
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'No personal collection clauses found.',
                  'concerns': [],
                },
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final validNoConcern = await coordinator.runPolicyReview(
        subjectTitle: 'ValidCleanApp',
        sourceLabel: 'Paste',
        policyText: 'We do not sell personal data.',
      );
      expect(
        validNoConcern.receipt!.overallState,
        ReviewOverallState.noConcern,
      );
      expect(
        validNoConcern.receipt!.diagnosticKind,
        ReviewDiagnosticKind.validated,
      );
    });

    test('Section 3: permission comparison preserves diagnosticKind, inferenceSource, sourceSnapshot, languageCode, and insufficient verdict precedence', () async {
      final coordinator = ReviewCoordinator();
      const permissions = AppPermissionSnapshot(
        packageName: 'com.example.trackerapp',
        appName: 'TrackerApp',
        requestedPermissions: [
          'android.permission.ACCESS_FINE_LOCATION',
          'android.permission.RECORD_AUDIO',
        ],
        grantedPermissions: ['android.permission.ACCESS_FINE_LOCATION'],
      );
      final snapshotProvenance = PolicySourceSnapshot(
        snapshotId: 'snap_perm_test',
        sourceType: PolicySourceType.url,
        retrievedAt: DateTime.utc(2026, 11, 15, 12, 0),
        retrievalStatus: PolicyRetrievalStatus.retrieved,
        canonicalUrl: 'https://example.org/privacy',
        appIdentityMatchStatus: AppIdentityMatchStatus.unverifiedUserSupplied,
        sourceSha256Hash:
            '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      // 3.1 Validated NO_CONCERN + undisclosed device permissions -> upgrades to reviewRecommended while preserving provenance
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'All learning data stays strictly on device.',
                  'concerns': [],
                },
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });

      final validatedMismatch = await coordinator.runPolicyReview(
        subjectTitle: 'TrackerApp',
        sourceLabel: 'https://example.org/privacy',
        policyText: sampleCalmMathPolicy,
        appPermissions: permissions,
        sourceSnapshot: snapshotProvenance,
        languageCode: 'de',
      );
      final r1 = validatedMismatch.receipt!;
      expect(r1.overallState, ReviewOverallState.reviewRecommended);
      expect(r1.diagnosticKind, ReviewDiagnosticKind.validated);
      expect(r1.inferenceSource, InferenceSource.onDevice);
      expect(r1.permissionReport, isNotNull);
      expect(r1.permissionReport!.mismatchCount, greaterThan(0));
      expect(r1.sourceSnapshot?.snapshotId, 'snap_perm_test');
      expect(r1.languageCode, 'de');

      // 3.2 Insufficient policy material + undisclosed permissions -> MUST stay insufficientEvidence AND preserve permission report & provenance
      final insufficientPerm = await coordinator.runPolicyReview(
        subjectTitle: 'TrackerApp',
        sourceLabel: 'https://example.org/privacy',
        policyText: 'Privacy notice unavailable.',
        appPermissions: permissions,
        sourceSnapshot: snapshotProvenance,
        languageCode: 'de',
      );
      final r2 = insufficientPerm.receipt!;
      expect(r2.overallState, ReviewOverallState.insufficientEvidence);
      expect(
        r2.diagnosticKind,
        ReviewDiagnosticKind.insufficientPolicyMaterial,
      );
      expect(r2.permissionReport, isNotNull);
      expect(r2.permissionReport!.mismatchCount, greaterThan(0));
      expect(
        r2.findings.any((f) => f.status == EvidenceStatus.deviceObserved),
        isTrue,
      );
      expect(r2.sourceSnapshot?.snapshotId, 'snap_perm_test');
      expect(r2.languageCode, 'de');

      // 3.3 failedModelInference + undisclosed permissions -> MUST stay insufficientEvidence & preserve diagnosticKind/inferenceSource/processSteps
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'failed',
                'inferenceSource': 'UNKNOWN',
                'errorCode': 'InferenceRuntimeException',
                'message': 'On-device session failed unexpectedly.',
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final failedModelPerm = await coordinator.runPolicyReview(
        subjectTitle: 'TrackerApp',
        sourceLabel: 'https://example.org/privacy',
        policyText: 'All homework progress stays strictly on this tablet and is never shared.',
        appPermissions: permissions,
        sourceSnapshot: snapshotProvenance,
        cloudConsent: true,
      );
      final r3 = failedModelPerm.receipt!;
      expect(r3.overallState, ReviewOverallState.insufficientEvidence);
      expect(r3.diagnosticKind, ReviewDiagnosticKind.failedModelInference);
      expect(r3.permissionReport, isNotNull);
      expect(r3.permissionReport!.mismatchCount, greaterThan(0));
      expect(r3.sourceSnapshot?.snapshotId, 'snap_perm_test');

      // 3.4 cloudUnavailableLocalFallback + undisclosed permissions -> MUST stay insufficientEvidence & preserve diagnosticKind
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'failed',
                'inferenceSource': 'UNKNOWN',
                'errorCode': 'QuotaExceededException',
                'message': 'Cloud quota exceeded',
              };
            }
            return {'isSupported': false, 'modelStatus': 'UNAVAILABLE'};
          });
      final cloudFallbackPerm = await coordinator.runPolicyReview(
        subjectTitle: 'TrackerApp',
        sourceLabel: 'https://example.org/privacy',
        policyText: 'All homework progress stays strictly on this tablet and is never shared.',
        appPermissions: permissions,
        sourceSnapshot: snapshotProvenance,
        cloudConsent: true,
      );
      final r4 = cloudFallbackPerm.receipt!;
      expect(r4.overallState, ReviewOverallState.insufficientEvidence);
      expect(
        r4.diagnosticKind,
        ReviewDiagnosticKind.cloudUnavailableLocalFallback,
      );
      expect(r4.permissionReport, isNotNull);
      expect(r4.permissionReport!.mismatchCount, greaterThan(0));
      expect(r4.sourceSnapshot?.snapshotId, 'snap_perm_test');
    });

    test('Section 4: citation verification Cases A, B, and C fail closed on unsupported claims', () async {
      final coordinator = ReviewCoordinator();

      // Case A: All candidate findings fail quote verification -> INSUFFICIENT_EVIDENCE
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'REVIEW_RECOMMENDED',
                  'summary': 'Claimed concerns that do not exist in snapshot.',
                  'concerns': [
                    {
                      'id': 'a1',
                      'title': 'Fabricated Location Sale',
                      'category': 'SHARING',
                      'severity': 'HIGH',
                      'quote': 'We stream student heartbeats to ad auctions every minute.',
                      'explanation': 'Unsupported claim.',
                    },
                    {
                      'id': 'a2',
                      'title': 'Fabricated Audio Sale',
                      'category': 'COLLECTION',
                      'severity': 'MEDIUM',
                      'quote': 'All keystrokes are monetized.',
                      'explanation': 'Unsupported claim.',
                    },
                  ],
                },
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final caseA = await coordinator.runPolicyReview(
        subjectTitle: 'CaseAApp',
        sourceLabel: 'Paste',
        policyText: sampleCalmMathPolicy,
      );
      expect(
        caseA.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );
      expect(
        caseA.receipt!.diagnosticKind,
        ReviewDiagnosticKind.failedModelInference,
      );
      expect(caseA.receipt!.sourceMatchedCount, 0);
      expect(caseA.receipt!.unverifiedCount, 2);

      // Case B: Model returns NO_CONCERN alongside an unverified concern -> INSUFFICIENT_EVIDENCE
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'Safe overall.',
                  'concerns': [
                    {
                      'id': 'b1',
                      'title': 'Hallucinated Concern Under NO_CONCERN',
                      'category': 'TRACKING',
                      'severity': 'LOW',
                      'quote':
                          'This exact quote is completely absent from text.',
                      'explanation': 'Contradictory unverified concern.',
                    },
                  ],
                },
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final caseB = await coordinator.runPolicyReview(
        subjectTitle: 'CaseBApp',
        sourceLabel: 'Paste',
        policyText: sampleCalmMathPolicy,
      );
      expect(
        caseB.receipt!.overallState,
        ReviewOverallState.insufficientEvidence,
      );
      expect(
        caseB.receipt!.diagnosticKind,
        ReviewDiagnosticKind.failedModelInference,
      );
      expect(caseB.receipt!.sourceMatchedCount, 0);

      // Case C: Mixed verified finding + unverified hallucination -> verified evidence drives verdict, unverified item remains unverified & excluded from verified findings
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'Contains background GPS collection.',
                  'concerns': [
                    {
                      'id': 'c1',
                      'title': 'Background GPS Collection',
                      'category': 'TRACKING',
                      'severity': 'HIGH',
                      'quote': 'collects precise GPS location coordinates even when the application is running in the background',
                      'explanation': 'Verified exact policy quote.',
                    },
                    {
                      'id': 'c2',
                      'title': 'Hallucinated Concern',
                      'category': 'SHARING',
                      'severity': 'MEDIUM',
                      'quote': 'Quote never present in EduTrack policy text.',
                      'explanation': 'Unverified hallucination.',
                    },
                  ],
                },
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });
      final caseC = await coordinator.runPolicyReview(
        subjectTitle: 'CaseCApp',
        sourceLabel: 'Paste',
        policyText: sampleEduTrackPolicy,
      );
      final rC = caseC.receipt!;
      expect(rC.overallState, ReviewOverallState.reviewRecommended);
      expect(rC.sourceMatchedCount, 1);
      expect(rC.unverifiedCount, 1);
      final matchedIds = rC.findings
          .where((f) => f.status == EvidenceStatus.sourceMatched)
          .map((f) => f.id)
          .toList();
      final unverifiedIds = rC.findings
          .where((f) => f.status == EvidenceStatus.unverified)
          .map((f) => f.id)
          .toList();
      expect(matchedIds, ['c1']);
      expect(unverifiedIds, ['c2']);
    });

    test('Section 7: ignores tampered calibratedDisclaimer in model JSON and uses localized non-certification copy', () async {
      final coordinator = ReviewCoordinator();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'analyseText') {
              return {
                'schemaVersion': 1,
                'requestId': (call.arguments as Map)['requestId'],
                'status': 'success',
                'inferenceSource': 'ON_DEVICE',
                'structuredOutput': {
                  'overall_state': 'NO_CONCERN',
                  'summary': 'All learning data remains strictly on device.',
                  'concerns': [],
                  'calibratedDisclaimer': 'CERTIFIED 100% SAFE SEAL BY MODEL',
                },
              };
            }
            return {'isSupported': true, 'modelStatus': 'AVAILABLE'};
          });

      final enOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'TamperedEnApp',
        sourceLabel: 'Paste',
        policyText: sampleCalmMathPolicy,
        languageCode: 'en',
      );
      expect(
        enOutcome.receipt!.calibratedDisclaimer,
        ReviewCoordinator.calibratedDefaultDisclaimer,
      );
      expect(
        enOutcome.receipt!.calibratedDisclaimer,
        isNot(contains('CERTIFIED 100% SAFE')),
      );

      final deOutcome = await coordinator.runPolicyReview(
        subjectTitle: 'TamperedDeApp',
        sourceLabel: 'Paste',
        policyText: sampleCalmMathPolicy,
        languageCode: 'de',
      );
      final expectedDe = lookupAppLocalizations(const Locale('de'))
          .stateNoConcernSubtitle;
      expect(deOutcome.receipt!.calibratedDisclaimer, expectedDe);
      expect(
        deOutcome.receipt!.calibratedDisclaimer,
        isNot(contains('CERTIFIED 100% SAFE')),
      );
    });
  });
}
