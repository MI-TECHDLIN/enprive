import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
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
      'automatically scrubs personal details and falls back via App Check PREFER_ON_DEVICE when on-device Nano 4 is unavailable',
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
        final outcome = await coordinator.runPolicyReview(
          subjectTitle: 'EduTrack',
          sourceLabel: 'Test Snapshot',
          policyText: policyWithPii,
        );

        expect(outcome.needsCloudConsentOrManual, isFalse);
        expect(outcome.receipt, isNotNull);
        expect(outcome.receipt!.inferenceSource, InferenceSource.inCloud);
        expect(recordedCalls.length, 2);
        expect(recordedCalls[0]['requestedMode'], 'ONLY_ON_DEVICE');
        expect(recordedCalls[1]['requestedMode'], 'PREFER_ON_DEVICE');
        expect(recordedCalls[1]['cloudConsent'], isTrue);

        final sentText = recordedCalls[1]['text'] as String;
        expect(sentText, isNot(contains('Maya Lin')));
        expect(sentText, isNot(contains('privacy@school.edu')));
        expect(sentText, isNot(contains('415-555-0199')));
        expect(sentText, contains('[PERSON]'));
        expect(sentText, contains('[EMAIL]'));
        expect(sentText, contains('[PHONE]'));
      },
    );

    test(
      'scrubs personal details and routes comprehensive policies directly through App Check PREFER_ON_DEVICE',
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
        final outcome = await coordinator.runPolicyReview(
          subjectTitle: 'Long Policy',
          sourceLabel: 'Test Snapshot',
          policyText: longPolicy,
        );

        expect(outcome.receipt, isNotNull);
        expect(recordedCalls.length, 1);
        expect(recordedCalls[0]['requestedMode'], 'PREFER_ON_DEVICE');
        expect(recordedCalls[0]['text'], isNot(contains('Sarah Kim')));
        expect(recordedCalls[0]['text'], isNot(contains('sarah@example.org')));
        expect(recordedCalls[0]['text'], contains('[PERSON]'));
        expect(recordedCalls[0]['text'], contains('[EMAIL]'));
      },
    );

    test(
      'falls back cleanly to deterministic local clause scan when both Nano and network are unavailable',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'analyseText') {
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
        final outcome = await coordinator.runPolicyReview(
          subjectTitle: 'EduTrack',
          sourceLabel: 'Offline Test',
          policyText: sampleEduTrackPolicy,
        );

        expect(outcome.needsCloudConsentOrManual, isFalse);
        expect(outcome.receipt!.overallState,
            ReviewOverallState.reviewRecommended);
        expect(outcome.receipt!.inferenceSource, InferenceSource.onDevice);
      },
    );

    test(
      'deterministic local clause scanner identifies verbatim concerns on EduTrack and no concern on CalmMath',
      () async {
        final coordinator = ReviewCoordinator();

        final eduOutcome = await coordinator.runPolicyReview(
          subjectTitle: 'EduTrack',
          sourceLabel: 'Local Scan',
          policyText: sampleEduTrackPolicy,
          forceLocalManualScan: true,
        );
        expect(eduOutcome.receipt!.overallState,
            ReviewOverallState.reviewRecommended);
        expect(eduOutcome.receipt!.sourceMatchedCount, greaterThanOrEqualTo(2));

        final calmOutcome = await coordinator.runPolicyReview(
          subjectTitle: 'CalmMath',
          sourceLabel: 'Local Scan',
          policyText: sampleCalmMathPolicy,
          forceLocalManualScan: true,
        );
        expect(calmOutcome.receipt!.overallState, ReviewOverallState.noConcern);
        expect(calmOutcome.receipt!.findings, isEmpty);
        expect(
          calmOutcome.receipt!.calibratedDisclaimer,
          contains('This is not a safety certification'),
        );
      },
    );
  });
}
