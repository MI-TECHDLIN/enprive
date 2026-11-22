import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/privacy/pii_redactor.dart';
import 'package:enprive/domain/review/app_policy_association.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/domain/voice/deni_voice_summary.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeVoiceHybridBridge extends HybridAiBridge {
  final Future<HybridAnalysisResult> Function({
    required String requestId,
    required String task,
    required String text,
    required bool cloudConsent,
    String? requestedMode,
    String languageCode,
  })? onAnalyseText;

  final List<Map<String, Object?>> analyseCalls = [];

  _FakeVoiceHybridBridge({this.onAnalyseText});

  @override
  Future<HybridAnalysisResult> analyseText({
    required String requestId,
    required String task,
    required String text,
    required bool cloudConsent,
    String? requestedMode,
    String? sourceSnapshotId,
    String languageCode = 'en',
  }) async {
    analyseCalls.add({
      'requestId': requestId,
      'task': task,
      'text': text,
      'cloudConsent': cloudConsent,
      'requestedMode': requestedMode,
      'languageCode': languageCode,
    });
    if (onAnalyseText != null) {
      return onAnalyseText!(
        requestId: requestId,
        task: task,
        text: text,
        cloudConsent: cloudConsent,
        requestedMode: requestedMode,
        languageCode: languageCode,
      );
    }
    return HybridAnalysisResult(
      schemaVersion: 1,
      requestId: requestId,
      status: HybridStatus.unavailable,
      inferenceSource: 'UNKNOWN',
      message: 'On-device AI unavailable.',
    );
  }
}

PolicyReviewReceipt _buildSamplePolicyReceipt({
  bool withPermissions = true,
  bool isSample = false,
  bool includeUnverified = false,
}) {
  const snapshotText =
      'EduTrack collects precise GPS location in the background even when the app is closed. '
      'Voice recordings are retained indefinitely to train speech models. '
      'Contact Parent: Jane Doe at jane.doe@school.edu or 555-234-5678 (Student ID: STU-90421).';

  final findings = <VerifiedFinding>[
    const VerifiedFinding(
      id: 'finding_loc',
      title: 'Tracks location in the background',
      category: FindingCategory.tracking,
      severity: FindingSeverity.high,
      exactExcerpt:
          'EduTrack collects precise GPS location in the background even when the app is closed.',
      explanation:
          'The policy states precise GPS location is collected in the background.',
      whatPolicySays: 'Verbatim match confirmed.',
      whatAndroidReports: 'Text-only review.',
      unknowns: [
        'The policy does not state how long background location logs are kept.',
      ],
      status: EvidenceStatus.sourceMatched,
    ),
    const VerifiedFinding(
      id: 'finding_voice',
      title: 'Retains voice, audio, or biometric data',
      category: FindingCategory.retention,
      severity: FindingSeverity.high,
      exactExcerpt:
          'Voice recordings are retained indefinitely to train speech models.',
      explanation:
          'The quoted passage describes retaining voice recordings indefinitely for model training.',
      whatPolicySays: 'Verbatim match confirmed.',
      whatAndroidReports: 'Text-only review.',
      unknowns: ['Contact Parent: Jane Doe at jane.doe@school.edu to delete.'],
      status: EvidenceStatus.sourceMatched,
    ),
    if (withPermissions)
      const VerifiedFinding(
        id: 'perm_camera',
        title: 'Undisclosed Permission: Camera & Photo Capture',
        category: FindingCategory.dataCollection,
        severity: FindingSeverity.high,
        exactExcerpt:
            'Android Manifest Observation: android.permission.CAMERA (GRANTED)',
        explanation: 'Camera permission observed locally on Android.',
        whatPolicySays: 'No matching disclosure found in policy.',
        whatAndroidReports: 'Requested and granted on this phone.',
        unknowns: ['Permission state does not prove runtime camera capture.'],
        status: EvidenceStatus.deviceObserved,
      ),
    if (includeUnverified)
      const VerifiedFinding(
        id: 'finding_hallucinated',
        title: 'Unmatched claim',
        category: FindingCategory.sharing,
        severity: FindingSeverity.medium,
        exactExcerpt: 'Not actually present in policy.',
        explanation: 'Should never enter voice prompts or accepted points.',
        whatPolicySays: 'Unverified.',
        whatAndroidReports: 'N/A',
        unknowns: ['Unverified.'],
        status: EvidenceStatus.unverified,
      ),
  ];

  final permReport = withPermissions
      ? PermissionComparator.compare(
          snapshot: const AppPermissionSnapshot(
            packageName: 'edu.example.realtrack',
            appName: 'EduTrack',
            requestedPermissions: [
              'android.permission.ACCESS_FINE_LOCATION',
              'android.permission.CAMERA',
            ],
            grantedPermissions: ['android.permission.CAMERA'],
          ),
          policyText: snapshotText,
          isSampleFixture: isSample,
        )
      : null;

  return PolicyReviewReceipt(
    id: 'rcpt_voice_1',
    subjectTitle: 'EduTrack',
    sourceLabel: isSample ? 'Classroom Sample' : 'Public URL',
    snapshotText: snapshotText,
    snapshotDigest: '1234567890abcdef',
    createdAt: DateTime.utc(2026, 11, 21, 18, 0),
    overallState: ReviewOverallState.reviewRecommended,
    inferenceSource: InferenceSource.offlineDeterministic,
    summary: '2 parts of this policy need a closer look.',
    calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
    findings: findings,
    permissionReport: permReport,
    sourceSnapshot: PolicySourceSnapshot(
      snapshotId: 'snap_1',
      sourceType: isSample ? PolicySourceType.sample : PolicySourceType.url,
      retrievedAt: DateTime.utc(2026, 11, 21, 18, 0),
      retrievalStatus: PolicyRetrievalStatus.retrieved,
      appIdentityMatchStatus: isSample
          ? AppIdentityMatchStatus.sampleFixture
          : AppIdentityMatchStatus.unverifiedUserSupplied,
      sourceSha256Hash: 'abc123',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeniVoiceSummaryBuilder product guardrails', () {
    test(
      'buildPromptPayload includes only sourceMatched findings and strips package names and Android permissions',
      () {
        final receipt = _buildSamplePolicyReceipt(
          withPermissions: true,
          includeUnverified: true,
        );
        final payload = DeniVoiceSummaryBuilder.buildPromptPayload(receipt);

        expect(payload, contains('finding_loc'));
        expect(payload, contains('finding_voice'));
        expect(payload, isNot(contains('perm_camera')));
        expect(payload, isNot(contains('finding_hallucinated')));
        expect(payload, isNot(contains('android.permission.CAMERA')));
        expect(payload, isNot(contains('edu.example.realtrack')));
      },
    );

    test(
      'buildDeterministic links every policy point to its verbatim excerpt, keeps permission notes separate, and adds association & non-certification notes',
      () {
        final receipt = _buildSamplePolicyReceipt(withPermissions: true);
        final assoc = AppPolicyAssociationReport(
          state: AppPolicyAssociationState.unmatched,
          selectedPackageName: 'edu.example.realtrack',
          selectedAppName: 'EduTrack',
          explanation: 'Selected app was not mentioned.',
          ownershipLimitationNotice:
              'Linking a policy does not prove developer ownership.',
          evaluatedAt: DateTime.utc(2026, 11, 21, 18, 0),
        );

        final summary = DeniVoiceSummaryBuilder.buildDeterministic(
          receipt: receipt,
          associationReport: assoc,
        );

        expect(summary.summarySource, InferenceSource.offlineDeterministic);
        expect(summary.policyPoints.length, 2);
        expect(
          summary.policyPoints.first.sourceExcerpt,
          contains('precise GPS location in the background'),
        );
        expect(
          summary.policyPoints.last.sourceExcerpt,
          contains('Voice recordings are retained indefinitely'),
        );

        final devicePoints = summary.points
            .where((p) => p.kind == DeniSummaryPointKind.devicePermissionNote)
            .toList();
        expect(devicePoints, hasLength(1));
        expect(devicePoints.first.plainText, contains('not a policy disclosure'));
        expect(devicePoints.first.plainText, contains('does not prove'));
        expect(devicePoints.first.hasPolicyExcerpt, isFalse);

        final assocPoints = summary.points
            .where((p) => p.kind == DeniSummaryPointKind.associationNote)
            .toList();
        expect(assocPoints, hasLength(1));
        expect(assocPoints.first.plainText, contains('does not prove'));

        expect(
          summary.calibrationNotice.toLowerCase(),
          contains('not a safety certification'),
        );
        expect(
          summary.spokenScript.toLowerCase(),
          contains('not a safety certification'),
        );
        expect(
          DeniVoiceSummaryBuilder.containsProhibitedCertificationClaim(
            summary.spokenScript,
          ),
          isFalse,
        );
      },
    );

    test(
      'buildDeterministic handles synthetic sample permissions without claiming live device inspection',
      () {
        final receipt = _buildSamplePolicyReceipt(
          withPermissions: true,
          isSample: true,
        );
        final summary = DeniVoiceSummaryBuilder.buildDeterministic(
          receipt: receipt,
        );

        expect(
          summary.points.any(
            (p) => p.kind == DeniSummaryPointKind.devicePermissionNote,
          ),
          isFalse,
        );
        final sampleNotes = summary.points
            .where((p) => p.kind == DeniSummaryPointKind.samplePermissionNote)
            .toList();
        expect(sampleNotes, hasLength(1));
        expect(sampleNotes.first.plainText, contains('Synthetic sample'));
        expect(
          summary.points.any(
            (p) => p.kind == DeniSummaryPointKind.associationNote,
          ),
          isFalse,
        );
      },
    );

    test(
      'buildDeterministic handles permission-only inspection honestly without inventing policy claims',
      () {
        final coordinator = ReviewCoordinator(bridge: _FakeVoiceHybridBridge());
        final receipt = coordinator.buildDevicePermissionInspectionReceipt(
          subjectTitle: 'Curre',
          sourceLabel: 'Installed app',
          appPermissions: const AppPermissionSnapshot(
            packageName: 'com.mitech.curre',
            appName: 'Curre',
            requestedPermissions: ['android.permission.CAMERA'],
            grantedPermissions: ['android.permission.CAMERA'],
          ),
        );

        final summary = DeniVoiceSummaryBuilder.buildDeterministic(
          receipt: receipt,
        );

        expect(summary.policyPoints, isEmpty);
        expect(summary.headline, contains('no privacy policy has been reviewed'));
        expect(
          summary.points.first.kind,
          DeniSummaryPointKind.devicePermissionNote,
        );
        expect(summary.points.first.plainText, contains('not privacy policy disclosures'));
        expect(summary.unknownSummary, contains('no privacy policy text'));
      },
    );

    test(
      'validateAndMergeModelOutput rejects invented IDs, unverified IDs, deviceObserved IDs, and safety certifications while keeping local verbatim excerpts',
      () {
        final receipt = _buildSamplePolicyReceipt(
          withPermissions: true,
          includeUnverified: true,
        );

        final summary = DeniVoiceSummaryBuilder.validateAndMergeModelOutput(
          structuredOutput: {
            'headline': 'This app is 100% safe for kids and COPPA compliant.',
            'points': [
              {
                'finding_id': 'finding_loc',
                'plain_text':
                    'The app says it can track exact GPS location even when closed.',
              },
              {
                'finding_id': 'finding_voice',
                'plain_text':
                    'This app is completely safe and certified safe with no privacy risks.',
              },
              {
                'finding_id': 'perm_camera',
                'plain_text': 'Camera permission disclosed in policy.',
              },
              {
                'finding_id': 'finding_hallucinated',
                'plain_text': 'Invented claim.',
              },
              {
                'finding_id': 'invented_999',
                'plain_text': 'Totally fabricated finding.',
              },
            ],
            'unknown_summary':
                'The text does not show how often data leaves the device.',
          },
          receipt: receipt,
          inferenceSource: InferenceSource.onDevice,
        );

        expect(summary.summarySource, InferenceSource.onDevice);
        // Prohibited certification headline must be replaced by deterministic safe headline
        expect(summary.headline.toLowerCase(), isNot(contains('100% safe')));
        expect(summary.headline.toLowerCase(), isNot(contains('coppa compliant')));

        // Exactly the 2 sourceMatched findings appear as policy points (finding_voice backfilled deterministically)
        expect(summary.policyPoints.map((p) => p.findingId).toList(), [
          'finding_loc',
          'finding_voice',
        ]);
        expect(
          summary.policyPoints.first.plainText,
          'The app says it can track exact GPS location even when closed.',
        );
        // Verbatim quote stays anchored to trusted local receipt
        expect(
          summary.policyPoints.first.sourceExcerpt,
          'EduTrack collects precise GPS location in the background even when the app is closed.',
        );
        // Rejected safety certification on finding_voice was replaced deterministically
        expect(
          summary.policyPoints.last.plainText.toLowerCase(),
          isNot(contains('completely safe')),
        );
        expect(
          summary.policyPoints.last.sourceExcerpt,
          'Voice recordings are retained indefinitely to train speech models.',
        );
        // Local device permission note appended strictly on-device
        expect(
          summary.points.any(
            (p) => p.kind == DeniSummaryPointKind.devicePermissionNote,
          ),
          isTrue,
        );
      },
    );

    test(
      'validateAndMergeModelOutput fails closed to deterministic template when zero model points validate',
      () {
        final receipt = _buildSamplePolicyReceipt(withPermissions: false);
        final summary = DeniVoiceSummaryBuilder.validateAndMergeModelOutput(
          structuredOutput: {
            'headline': 'Summary',
            'points': [
              {'finding_id': 'does_not_exist', 'plain_text': 'Invented point'},
            ],
          },
          receipt: receipt,
          inferenceSource: InferenceSource.inCloud,
        );

        expect(summary.summarySource, InferenceSource.offlineDeterministic);
        expect(summary.fallbackNote, isNotNull);
        expect(summary.policyPoints.length, 2);
      },
    );

    test('containsProhibitedCertificationClaim distinguishes claims from disclaimers', () {
      expect(
        DeniVoiceSummaryBuilder.containsProhibitedCertificationClaim(
          'This app is safe for children.',
        ),
        isTrue,
      );
      expect(
        DeniVoiceSummaryBuilder.containsProhibitedCertificationClaim(
          'The service is GDPR compliant and guaranteed private.',
        ),
        isTrue,
      );
      expect(
        DeniVoiceSummaryBuilder.containsProhibitedCertificationClaim(
          'No concern identified in the reviewed evidence. This is not a safety certification.',
        ),
        isFalse,
      );
      expect(
        DeniVoiceSummaryBuilder.containsProhibitedCertificationClaim(
          'Enprive cannot say this app is safe.',
        ),
        isFalse,
      );
    });

    test(
      'deterministic headline does not trigger false-positive [ADDRESS] redaction when reviewed for voice consent',
      () {
        final receipt = _buildSamplePolicyReceipt(withPermissions: false);
        final summary = DeniVoiceSummaryBuilder.buildDeterministic(
          receipt: receipt,
        );
        final redacted = PiiRedactor.redact(summary.headline);
        expect(redacted.redactedText, isNot(contains('[ADDRESS]')));
        expect(redacted.replacementCount, 0);
      },
    );
  });

  group('ReviewCoordinator.generateDeniVoiceSummary hybrid routing', () {
    test(
      'uses ONLY_ON_DEVICE first without touching cloud when on-device model succeeds',
      () async {
        final bridge = _FakeVoiceHybridBridge(
          onAnalyseText: ({
            required requestId,
            required task,
            required text,
            required cloudConsent,
            requestedMode,
            languageCode = 'en',
          }) async {
            expect(task, 'summarize_voice');
            expect(cloudConsent, isFalse);
            expect(requestedMode, 'ONLY_ON_DEVICE');
            return HybridAnalysisResult(
              schemaVersion: 1,
              requestId: requestId,
              status: HybridStatus.success,
              inferenceSource: 'ON_DEVICE',
              structuredOutput: {
                'headline': 'Two clauses in EduTrack deserve a look.',
                'points': [
                  {
                    'finding_id': 'finding_loc',
                    'plain_text': 'It may check exact location in the background.',
                  },
                  {
                    'finding_id': 'finding_voice',
                    'plain_text': 'Voice clips may be kept indefinitely.',
                  },
                ],
                'unknown_summary': 'Retention end dates are not listed.',
              },
            );
          },
        );
        final coordinator = ReviewCoordinator(bridge: bridge);
        final receipt = _buildSamplePolicyReceipt(withPermissions: true);

        final summary = await coordinator.generateDeniVoiceSummary(
          receipt: receipt,
          cloudConsent: false,
        );

        expect(bridge.analyseCalls, hasLength(1));
        expect(summary.summarySource, InferenceSource.onDevice);
        expect(summary.requiresCloudConsent, isFalse);
        expect(summary.headline, 'Two clauses in EduTrack deserve a look.');
        expect(summary.policyPoints.length, 2);
      },
    );

    test(
      'when on-device AI is unavailable, returns deterministic summary with redacted cloud preview and makes 0 cloud calls',
      () async {
        final bridge = _FakeVoiceHybridBridge();
        final coordinator = ReviewCoordinator(bridge: bridge);
        final receipt = _buildSamplePolicyReceipt(withPermissions: true);

        final summary = await coordinator.generateDeniVoiceSummary(
          receipt: receipt,
          cloudConsent: false,
        );

        expect(bridge.analyseCalls, hasLength(1));
        expect(bridge.analyseCalls.first['cloudConsent'], isFalse);
        expect(bridge.analyseCalls.first['requestedMode'], 'ONLY_ON_DEVICE');
        expect(summary.summarySource, InferenceSource.offlineDeterministic);
        expect(summary.requiresCloudConsent, isTrue);
        expect(summary.redactedCloudPayload, isNotNull);
        expect(summary.redactedCloudPayload, contains('[EMAIL]'));
        expect(summary.redactedCloudPayload, contains('[PERSON]'));
        expect(summary.redactedCloudPayload, isNot(contains('jane.doe@school.edu')));
        expect(summary.redactedCloudPayload, isNot(contains('edu.example.realtrack')));
        expect(summary.redactedCloudPayload, isNot(contains('CAMERA')));
      },
    );

    test(
      'consented cloud summary sends exact canonical redacted payload once and falls back deterministically on timeout with 0 retries',
      () async {
        final bridge = _FakeVoiceHybridBridge(
          onAnalyseText: ({
            required requestId,
            required task,
            required text,
            required cloudConsent,
            requestedMode,
            languageCode = 'en',
          }) async {
            expect(task, 'summarize_voice');
            expect(cloudConsent, isTrue);
            expect(requestedMode, 'ONLY_IN_CLOUD');
            expect(requestId, endsWith('_appcheck'));
            throw HybridOperationCancelledException(
              requestId: requestId,
              message: 'Timed out',
              isTimeout: true,
            );
          },
        );
        final coordinator = ReviewCoordinator(bridge: bridge);
        final receipt = _buildSamplePolicyReceipt(withPermissions: false);
        final canonical = ReviewCoordinator.canonicalCloudPayload(
          DeniVoiceSummaryBuilder.buildPromptPayload(receipt),
        );

        final summary = await coordinator.generateDeniVoiceSummary(
          receipt: receipt,
          cloudConsent: true,
          canonicalRedactedPayload: canonical,
          requestId: 'vsum_42',
        );

        expect(bridge.analyseCalls, hasLength(1));
        expect(bridge.analyseCalls.first['text'], equals(canonical));
        expect(summary.summarySource, InferenceSource.offlineDeterministic);
        expect(summary.fallbackNote, contains('timed out'));
        expect(summary.policyPoints.length, 2);
      },
    );

    test(
      'receipt JSON persistence format remains strictly unchanged (no voice summary persisted)',
      () {
        final receipt = _buildSamplePolicyReceipt(withPermissions: true);
        final json = receipt.toJson();
        final roundTripped = PolicyReviewReceipt.fromJson(json);

        expect(json.containsKey('voiceSummary'), isFalse);
        expect(json.containsKey('spokenScript'), isFalse);
        expect(roundTripped.id, receipt.id);
        expect(roundTripped.findings.length, receipt.findings.length);
      },
    );
  });

  group('HybridAiBridge Gemini TTS consent gate & playback events', () {
    final recordedCalls = <MethodCall>[];

    setUp(() {
      recordedCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.enprive/hybrid_ai'),
            (call) async {
              recordedCalls.add(call);
              if (call.method == 'speakWithGeminiTts') {
                return {
                  'status': 'fallback_local',
                  'route': 'ANDROID_LOCAL_TTS',
                  'modelName': 'gemini-3.8-flash-tts',
                  'fallbackReason': 'timeout',
                  'errorCode': 'TIMED_OUT',
                  'message':
                      'Expressive cloud voice timed out. Using this phone\'s offline voice instead.',
                };
              }
              if (call.method == 'checkTtsAvailability') {
                return {
                  'isReady': true,
                  'isLanguageAvailable': true,
                  'resolvedLocale': 'en-US',
                  'message': 'On-device voice is available for English.',
                };
              }
              return true;
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.enprive/hybrid_ai'),
            null,
          );
    });

    test(
      'speakWithGeminiTts blocks locally with 0 native calls when cloudConsent is false',
      () async {
        final bridge = HybridAiBridge();
        final res = await bridge.speakWithGeminiTts(
          requestId: 'tts_blocked',
          text: 'Plain summary text.',
          cloudConsent: false,
        );

        expect(res.wasBlocked, isTrue);
        expect(res.errorCode, 'CLOUD_CONSENT_REQUIRED');
        expect(recordedCalls, isEmpty);
      },
    );

    test(
      'speakWithGeminiTts invokes native channel when consented and parses local fallback honestly',
      () async {
        final bridge = HybridAiBridge();
        final res = await bridge.speakWithGeminiTts(
          requestId: 'tts_ok',
          text: 'Plain summary text.',
          cloudConsent: true,
          languageCode: 'ko',
        );

        expect(recordedCalls, hasLength(1));
        expect(recordedCalls.first.method, 'speakWithGeminiTts');
        expect(
          (recordedCalls.first.arguments as Map)['cloudConsent'],
          isTrue,
        );
        expect((recordedCalls.first.arguments as Map)['languageCode'], 'ko');
        expect(res.fellBackToLocal, isTrue);
        expect(res.route, VoicePlaybackRoute.androidLocalTts);
        expect(res.modelName, 'gemini-3.8-flash-tts');
        expect(res.errorCode, 'TIMED_OUT');
      },
    );

    test(
      'checkTtsAvailability and voicePlaybackEvents stream parse platform data accurately',
      () async {
        final bridge = HybridAiBridge();
        final avail = await bridge.checkTtsAvailability(languageCode: 'en');
        expect(avail.canSpeakLocally, isTrue);
        expect(avail.resolvedLocale, 'en-US');

        final received = <VoicePlaybackEvent>[];
        final sub = bridge.voicePlaybackEvents.listen(received.add);
        addTearDown(sub.cancel);

        bridge.emitVoicePlaybackEvent(
          const VoicePlaybackEvent(
            requestId: 'tts_1',
            state: VoicePlaybackState.playing,
            route: VoicePlaybackRoute.geminiCloudTts,
            voiceName: 'Puck',
            modelName: 'gemini-3.8-flash-tts',
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(received, hasLength(1));
        expect(received.first.state, VoicePlaybackState.playing);
        expect(received.first.route, VoicePlaybackRoute.geminiCloudTts);
        expect(received.first.voiceName, 'Puck');
      },
    );
  });
}
