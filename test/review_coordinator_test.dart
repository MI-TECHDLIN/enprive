import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
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
    test(
      'validates on-device Gemini Nano 4 structured output and marks hallucinated quotes UNVERIFIED',
      () async {
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
                'summary': 'Background GPS and indefinite voice retention found.',
                'concerns': [
                  {
                    'id': 'f_valid',
                    'title': 'Background GPS Tracking',
                    'category': 'TRACKING',
                    'severity': 'HIGH',
                    'quote':
                        'collects precise GPS location coordinates even when the application is running in the background',
                    'explanation': 'Tracks student location in the background.',
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
      },
    );

    test(
      'blocks cloud escalation when on-device Nano 4 is unavailable without consent, provides scrubbed preview, and runs ONLY_IN_CLOUD only after explicit consent',
      () async {
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
                    'quote':
                        'collects precise GPS location coordinates even when the application is running in the background',
                    'explanation': 'Tracks student location in the background.',
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
        expect(consentedOutcome.receipt!.inferenceSource, InferenceSource.inCloud);
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
      },
    );

    test(
      'blocks cloud escalation on comprehensive policies without consent even after PII redaction, and routes ONLY_IN_CLOUD after consent',
      () async {
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
        expect(consentedOutcome.receipt!.inferenceSource, InferenceSource.inCloud);
        expect(recordedCalls.length, 1);
        expect(recordedCalls[0]['requestedMode'], 'ONLY_IN_CLOUD');
        expect(recordedCalls[0]['cloudConsent'], isTrue);
        expect(recordedCalls[0]['text'], isNot(contains('Sarah Kim')));
        expect(recordedCalls[0]['text'], isNot(contains('sarah@example.org')));
        expect(recordedCalls[0]['text'], contains('[PERSON]'));
        expect(recordedCalls[0]['text'], contains('[EMAIL]'));
      },
    );

    test(
      'pauses for consent when Nano is unavailable without consent, and falls back to OFFLINE_DETERMINISTIC when consented cloud is offline',
      () async {
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
      },
    );

    test(
      'deterministic local clause scanner identifies verbatim concerns on EduTrack and no concern on CalmMath with OFFLINE_DETERMINISTIC provenance',
      () async {
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
        expect(eduOutcome.receipt!.overallState,
            ReviewOverallState.reviewRecommended);
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
      },
    );

    test(
      'propagates streamed process steps, model thoughtSummary, and thoughtSignature onto receipt and DeniExplanation',
      () async {
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
                'thoughtSummary':
                    'Checking whether the quote specifies third-party advertising.',
                'thoughtSignature': 'sig_deni_9876543210abcdef',
                'structuredOutput': {
                  'answer':
                      'The quote states advertising partners receive engagement scores.',
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
              'thoughtSummary':
                  'Inspecting data sharing clauses and checking opt-out clarity.',
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
        expect(emittedStages, containsAll(['redacting_pii', 'sending_appcheck', 'verifying_evidence']));

        final receipt = outcome.receipt!;
        expect(receipt.processSteps, isNotEmpty);
        expect(receipt.thoughtSummary,
            'Inspecting data sharing clauses and checking opt-out clarity.');
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
        expect(explanation.thoughtSummary,
            'Checking whether the quote specifies third-party advertising.');
        expect(explanation.thoughtSignature, 'sig_deni_9876543210abcdef');

        await sub.cancel();
      },
    );

    test(
      'HybridAiBridge rejects cloud-capable modes immediately without invoking platform channel when cloudConsent is false',
      () async {
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
      },
    );

    test(
      'askDeniAboutFinding never escalates to cloud without consent on Nano failure or comprehensive input, and supports OFFLINE_DETERMINISTIC fallback',
      () async {
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
          snapshotText:
              'Child: Leo Ng (leo@school.org). Engagement scores may be shared with ad networks.',
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
          snapshotText:
              'Child: Leo Ng (leo@school.org). Engagement scores may be shared with ad networks.',
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
      },
    );

    test(
      'maps UNKNOWN native inferenceSource to explicit unknown instead of locationUnavailable or onDevice',
      () async {
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
        expect(
          reviewOutcome.receipt!.inferenceSource,
          InferenceSource.unknown,
        );

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
        expect(
          deniOutcome.inferenceSource,
          InferenceSource.unknown,
        );
      },
    );

    test(
      'consented cloud errors (429, airplane mode, App Check, generic, unsupported thinking) invoke bridge once without retry and fall back to offlineDeterministic',
      () async {
        final scenarios = <Map<String, String>>[
          {
            'name': 'HTTP 429 quota error',
            'errorCode': 'QuotaExceededException',
            'message': 'Quota exceeded (HTTP 429)',
          },
          {
            'name': 'Airplane mode network failure',
            'errorCode': 'UnknownException',
            'message': 'Unable to resolve host: offline',
          },
          {
            'name': 'App Check failure',
            'errorCode': 'ServiceConnectionHandshakeFailedException',
            'message': 'App Check verification failed',
          },
          {
            'name': 'Unsupported thinking configuration',
            'errorCode': 'InvalidStateException',
            'message': 'Thinking config not supported',
          },
          {
            'name': 'Generic model error',
            'errorCode': 'ServerException',
            'message': 'Unexpected model failure',
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
          expect(
            deniOutcome.inferenceSource,
            isNot(InferenceSource.onDevice),
          );
        }
      },
    );

    test(
      'successful cloud stream executes once with IN_CLOUD provenance while cancelled consent and offline fallback execute zero cloud calls',
      () async {
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
                    'quote':
                        'We collect device identifiers to share telemetry with partners.',
                    'explanation': 'Device identifiers are shared externally.',
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
      },
    );

    test(
      'native cancellation propagates cleanly without becoming a deterministic fallback or triggering a retry while ordinary failures still fall back',
      () async {
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

        // B. Status "cancelled" / TimeoutCancellationException map also propagates
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
              'errorCode': 'TimeoutCancellationException',
              'message': 'Operation timed out and cancelled',
            };
          }
          return null;
        });

        await expectLater(
          coordinator.runPolicyReview(
            subjectTitle: 'Timeout Cancel App',
            sourceLabel: 'Test Policy',
            policyText:
                'We collect device identifiers to share telemetry with partners.',
            cloudConsent: true,
          ),
          throwsA(isA<HybridOperationCancelledException>()),
        );
        expect(mapCancelCalls.length, 1);

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
      },
    );
  });
}
