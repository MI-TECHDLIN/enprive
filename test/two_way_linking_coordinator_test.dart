import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enprive/domain/evidence/evidence_validator.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/app_policy_association.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/domain/voice/deni_voice_summary.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hybridChannel = MethodChannel('com.enprive/hybrid_ai');

  late List<MethodCall> bridgeCalls;
  late ReviewCoordinator coordinator;

  const cleanPolicyText =
      'Focus Reader (com.focus.reader) stores reading lists locally on your phone. '
      'We use your camera only when you scan book barcodes. '
      'We never sell your data to advertisers or third-party brokers. '
      'Contact privacy@focusreader.example for deletion.';

  const trackingPolicyText =
      'Bright Study Privacy Policy. We share precise location data and advertising '
      'identifiers with third-party marketing partners and ad networks for targeted '
      'campaigns. We keep analytics records for up to 36 months.';

  const focusSnapshotWithUndisclosedLocation = AppPermissionSnapshot(
    packageName: 'com.focus.reader',
    appName: 'Focus Reader',
    requestedPermissions: [
      'android.permission.CAMERA',
      'android.permission.ACCESS_FINE_LOCATION',
    ],
    grantedPermissions: [
      'android.permission.CAMERA',
      'android.permission.ACCESS_FINE_LOCATION',
    ],
  );

  const focusSnapshotCameraOnly = AppPermissionSnapshot(
    packageName: 'com.focus.reader',
    appName: 'Focus Reader',
    requestedPermissions: ['android.permission.CAMERA'],
    grantedPermissions: ['android.permission.CAMERA'],
  );

  const otherAppContactsOnly = AppPermissionSnapshot(
    packageName: 'com.other.diary',
    appName: 'Other Diary',
    requestedPermissions: ['android.permission.READ_CONTACTS'],
    grantedPermissions: ['android.permission.READ_CONTACTS'],
  );

  const nonSensitiveOnlySnapshot = AppPermissionSnapshot(
    packageName: 'com.calm.timer',
    appName: 'Calm Timer',
    requestedPermissions: [
      'android.permission.INTERNET',
      'android.permission.VIBRATE',
    ],
    grantedPermissions: ['android.permission.INTERNET'],
  );

  PolicyReviewReceipt makeStandaloneReceipt({
    String id = 'rcpt_standalone_1',
    String subjectTitle = 'Focus Reader Policy',
    String policyText = cleanPolicyText,
    String? canonicalUrl,
    ReviewOverallState overallState = ReviewOverallState.noConcern,
    ReviewDiagnosticKind diagnosticKind = ReviewDiagnosticKind.validated,
    List<VerifiedFinding> findings = const [],
    String summary = 'No privacy concerns were found in the reviewed text.',
  }) {
    return PolicyReviewReceipt(
      id: id,
      subjectTitle: subjectTitle,
      sourceLabel: canonicalUrl ?? 'Pasted text',
      snapshotText: policyText,
      snapshotDigest: EvidenceValidator.computeSnapshotDigest(policyText),
      createdAt: DateTime(2026, 11, 20, 10, 0),
      overallState: overallState,
      inferenceSource: InferenceSource.onDevice,
      summary: summary,
      calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
      findings: findings,
      processSteps: const ['Reviewed policy text on this phone'],
      diagnosticKind: diagnosticKind,
      sourceSnapshot: PolicySourceSnapshot(
        snapshotId: 'snap_$id',
        sourceType: canonicalUrl != null
            ? PolicySourceType.url
            : PolicySourceType.pastedText,
        requestedUrl: canonicalUrl,
        canonicalUrl: canonicalUrl,
        retrievedAt: DateTime.utc(2026, 11, 20, 10, 0),
        retrievalStatus: canonicalUrl != null
            ? PolicyRetrievalStatus.retrieved
            : PolicyRetrievalStatus.localProvided,
        appIdentityMatchStatus: AppIdentityMatchStatus.notApplicable,
        sourceSha256Hash: EvidenceValidator.computeSha256SourceHash(policyText),
      ),
    );
  }

  setUp(() {
    bridgeCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, (call) async {
          bridgeCalls.add(call);
          return null;
        });
    coordinator = ReviewCoordinator(bridge: HybridAiBridge());
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, null);
  });

  group('D5.3-E ReviewCoordinator two-way linking', () {
    test(
      '1. linking an installed app attaches local permission comparison and association with 0 AI/cloud calls',
      () {
        final policyFinding = VerifiedFinding(
          id: 'finding_1',
          title: 'Third-Party Data Sharing Clause',
          category: FindingCategory.sharing,
          severity: FindingSeverity.high,
          exactExcerpt:
              'We share precise location data and advertising identifiers with third-party marketing partners',
          explanation: 'Shares location and advertising IDs with marketing partners.',
          whatPolicySays: 'Verbatim match confirmed.',
          whatAndroidReports: PermissionComparator.standaloneAndroidReportText,
          unknowns: const ['Cannot verify runtime network payloads.'],
          status: EvidenceStatus.sourceMatched,
        );
        final standalone = makeStandaloneReceipt(
          subjectTitle: 'Bright Study Privacy Policy',
          policyText: trackingPolicyText,
          canonicalUrl: 'https://brightstudy.example.org/privacy',
          overallState: ReviewOverallState.reviewRecommended,
          findings: [policyFinding],
          summary: 'Found 1 clause to review.',
        );

        final linked = coordinator.linkInstalledAppToReceipt(
          receipt: standalone,
          appPermissions: focusSnapshotWithUndisclosedLocation,
          draftId: 'draft_linked_1',
          createdAt: DateTime(2026, 11, 20, 10, 5),
          supersedesReceiptId: standalone.id,
          evaluatedAt: DateTime.utc(2026, 11, 20, 10, 5),
        );

        // Zero native AI or cloud calls
        expect(bridgeCalls, isEmpty);

        // Preserves policy title, verbatim snapshot, SHA-256, and URL provenance
        expect(linked.receipt.id, 'draft_linked_1');
        expect(linked.receipt.subjectTitle, standalone.subjectTitle);
        expect(linked.receipt.snapshotText, standalone.snapshotText);
        expect(linked.receipt.snapshotDigest, standalone.snapshotDigest);
        expect(
          linked.receipt.sourceSnapshot?.sourceSha256Hash,
          standalone.sourceSnapshot?.sourceSha256Hash,
        );
        expect(
          linked.receipt.sourceSnapshot?.canonicalUrl,
          'https://brightstudy.example.org/privacy',
        );
        expect(
          linked.receipt.sourceSnapshot?.appIdentityMatchStatus,
          AppIdentityMatchStatus.unverifiedUserSupplied,
        );
        expect(linked.receipt.supersedesReceiptId, standalone.id);

        // Attaches permission report and device-observed camera mismatch
        expect(linked.receipt.permissionReport, isNotNull);
        expect(
          linked.receipt.permissionReport!.snapshot.packageName,
          'com.focus.reader',
        );
        expect(linked.receipt.deviceObservedCount, greaterThan(0));
        expect(linked.receipt.sourceMatchedCount, 1);
        expect(
          linked.receipt.findings
              .firstWhere((f) => f.id == 'finding_1')
              .whatAndroidReports,
          isNot(PermissionComparator.standaloneAndroidReportText),
        );
        expect(
          linked.receipt.processSteps,
          contains('Compared policy with permissions on this phone'),
        );

        // Association report is calibrated and never claims ownership
        expect(linked.associationReport.provesDeveloperOwnership, isFalse);
        expect(
          linked.associationReport.state,
          AppPolicyAssociationState.userLinkedUnverified,
        );

        // Receipt JSON schema remains untouched (no associationReport persisted)
        final json = linked.receipt.toJson();
        expect(json.containsKey('associationReport'), isFalse);
        final roundTripped = PolicyReviewReceipt.fromJson(json);
        expect(
          roundTripped.permissionReport?.snapshot.packageName,
          'com.focus.reader',
        );
        expect(roundTripped.supersedesReceiptId, standalone.id);
      },
    );

    test(
      '2. Link -> Change -> Unlink -> Relink is strictly idempotent with clean state recalculation',
      () {
        final standalone = makeStandaloneReceipt(
          policyText: cleanPolicyText,
          overallState: ReviewOverallState.noConcern,
        );

        // Step A: Link Focus Reader with undisclosed Location -> reviewRecommended
        final linkedA = coordinator.linkInstalledAppToReceipt(
          receipt: standalone,
          appPermissions: focusSnapshotWithUndisclosedLocation,
          draftId: 'draft_a',
        );
        expect(linkedA.receipt.overallState, ReviewOverallState.reviewRecommended);
        expect(linkedA.receipt.deviceObservedCount, 1);
        expect(
          linkedA.associationReport.state,
          AppPolicyAssociationState.packageIdentifierMentioned,
        );
        expect(linkedA.associationReport.provesDeveloperOwnership, isFalse);

        // Step B: Change to Other Diary (undisclosed Contacts; unmatched policy!)
        final linkedB = coordinator.linkInstalledAppToReceipt(
          receipt: linkedA.receipt,
          appPermissions: otherAppContactsOnly,
          draftId: 'draft_b',
        );
        expect(linkedB.receipt.permissionReport!.snapshot.packageName, 'com.other.diary');
        expect(linkedB.receipt.deviceObservedCount, 1);
        expect(
          linkedB.receipt.findings.single.id,
          contains('contacts'),
        );
        expect(
          linkedB.associationReport.state,
          AppPolicyAssociationState.unmatched,
        );
        expect(
          linkedB.associationReport.conflictingPackageIdentifiers,
          contains('com.focus.reader'),
        );
        expect(linkedB.associationReport.provesDeveloperOwnership, isFalse);
        // Process step and summary suffix are never duplicated
        expect(
          linkedB.receipt.processSteps
              .where((s) => s == 'Compared policy with permissions on this phone')
              .length,
          1,
        );

        // Step C: Change to Focus Reader (Camera only, disclosed in policy) -> returns to noConcern
        final linkedC = coordinator.linkInstalledAppToReceipt(
          receipt: linkedB.receipt,
          appPermissions: focusSnapshotCameraOnly,
          draftId: 'draft_c',
        );
        expect(linkedC.receipt.overallState, ReviewOverallState.noConcern);
        expect(linkedC.receipt.deviceObservedCount, 0);
        expect(linkedC.receipt.findings, isEmpty);
        expect(linkedC.receipt.summary, standalone.summary);

        // Step D: Unlink app -> cleanly restores policy-only state
        final unlinked = coordinator.unlinkInstalledAppFromReceipt(
          receipt: linkedA.receipt,
          draftId: 'draft_unlinked',
          supersedesReceiptId: 'rcpt_saved_base',
        );
        expect(unlinked.receipt.permissionReport, isNull);
        expect(unlinked.receipt.findings, isEmpty);
        expect(unlinked.receipt.overallState, ReviewOverallState.noConcern);
        expect(unlinked.receipt.summary, standalone.summary);
        expect(unlinked.receipt.supersedesReceiptId, 'rcpt_saved_base');
        expect(
          unlinked.receipt.sourceSnapshot?.appIdentityMatchStatus,
          AppIdentityMatchStatus.notApplicable,
        );
        expect(
          unlinked.receipt.processSteps,
          isNot(contains('Compared policy with permissions on this phone')),
        );
        expect(
          unlinked.associationReport.state,
          AppPolicyAssociationState.unlinked,
        );
        expect(unlinked.associationReport.provesDeveloperOwnership, isFalse);
      },
    );

    test(
      '3. linking never promotes insufficientEvidence or failedModelInference receipts',
      () {
        final insufficient = makeStandaloneReceipt(
          policyText: 'Short policy snippet without full disclosures.',
          overallState: ReviewOverallState.insufficientEvidence,
          diagnosticKind: ReviewDiagnosticKind.insufficientPolicyMaterial,
          summary: 'Not enough policy text was provided for a reliable review.',
        );

        final linked = coordinator.linkInstalledAppToReceipt(
          receipt: insufficient,
          appPermissions: focusSnapshotWithUndisclosedLocation,
          draftId: 'draft_insuf_linked',
        );

        expect(
          linked.receipt.overallState,
          ReviewOverallState.insufficientEvidence,
        );
        expect(linked.receipt.permissionReport, isNotNull);

        final unlinked = coordinator.unlinkInstalledAppFromReceipt(
          receipt: linked.receipt,
          draftId: 'draft_insuf_unlinked',
        );
        expect(
          unlinked.receipt.overallState,
          ReviewOverallState.insufficientEvidence,
        );
      },
    );

    test(
      '4. peer installed app name collision produces ambiguousIdentity with provesDeveloperOwnership == false',
      () {
        final standalone = makeStandaloneReceipt(
          subjectTitle: 'Study Notes Policy',
          policyText:
              'Study Notes respects your privacy and keeps your notes encrypted locally on your device. '
              'We do not sell personal information to third-party advertisers.',
        );

        final linked = coordinator.linkInstalledAppToReceipt(
          receipt: standalone,
          appPermissions: const AppPermissionSnapshot(
            packageName: 'com.alpha.notes',
            appName: 'Study Notes',
            requestedPermissions: ['android.permission.CAMERA'],
            grantedPermissions: [],
          ),
          peerCandidates: const [
            AppIdentityCandidate(
              packageName: 'com.alpha.notes',
              appName: 'Study Notes',
            ),
            AppIdentityCandidate(
              packageName: 'com.beta.notes',
              appName: 'Study Notes',
            ),
          ],
          draftId: 'draft_peer',
        );

        expect(
          linked.associationReport.state,
          AppPolicyAssociationState.ambiguousIdentity,
        );
        expect(
          linked.associationReport.ambiguousCandidatePackages,
          contains('com.beta.notes'),
        );
        expect(linked.associationReport.provesDeveloperOwnership, isFalse);
      },
    );

    test(
      '5. app with zero sensitive permissions reports notRequested for policy-mentioned permissions and empty items when neither side involves sensitive categories',
      () {
        // Policy mentions camera -> app does not request camera -> notRequested
        final cameraPolicy = makeStandaloneReceipt(policyText: cleanPolicyText);
        final linkedToCameraPolicy = coordinator.linkInstalledAppToReceipt(
          receipt: cameraPolicy,
          appPermissions: nonSensitiveOnlySnapshot,
          draftId: 'draft_timer_camera_policy',
        );
        expect(linkedToCameraPolicy.receipt.permissionReport, isNotNull);
        expect(linkedToCameraPolicy.receipt.permissionReport!.items, hasLength(1));
        expect(
          linkedToCameraPolicy.receipt.permissionReport!.items.single.isRequested,
          isFalse,
        );
        expect(
          linkedToCameraPolicy
              .receipt
              .permissionReport!
              .items
              .single
              .alignmentState,
          PermissionAlignmentState.notRequested,
        );
        expect(linkedToCameraPolicy.receipt.permissionReport!.mismatchCount, 0);
        expect(
          linkedToCameraPolicy.receipt.overallState,
          ReviewOverallState.noConcern,
        );

        // Policy mentions no sensitive catalog permissions -> items is empty
        final textOnlyPolicy = makeStandaloneReceipt(
          policyText:
              'Calm Timer (com.calm.timer) stores study timers strictly on your phone. '
              'We do not require accounts, do not track you across services, and let you '
              'erase saved sessions at any time.',
        );
        final linkedEmpty = coordinator.linkInstalledAppToReceipt(
          receipt: textOnlyPolicy,
          appPermissions: nonSensitiveOnlySnapshot,
          draftId: 'draft_timer_empty',
        );

        expect(linkedEmpty.receipt.permissionReport, isNotNull);
        expect(linkedEmpty.receipt.permissionReport!.items, isEmpty);
        expect(linkedEmpty.receipt.permissionReport!.mismatchCount, 0);
        expect(linkedEmpty.receipt.overallState, ReviewOverallState.noConcern);
      },
    );

    test(
      '6. DeniVoiceSummaryBuilder.withUpdatedDeviceContext refreshes device & association points without AI calls while preserving AI policy bullets',
      () {
        final policyFinding = VerifiedFinding(
          id: 'finding_ai_1',
          title: 'Advertising Data Sharing',
          category: FindingCategory.sharing,
          severity: FindingSeverity.high,
          exactExcerpt:
              'We share precise location data and advertising identifiers with third-party marketing partners',
          explanation: 'Shares location and ad IDs with third-party partners.',
          whatPolicySays: 'Verbatim match confirmed.',
          whatAndroidReports: PermissionComparator.standaloneAndroidReportText,
          unknowns: const ['Runtime cadence unknown.'],
          status: EvidenceStatus.sourceMatched,
        );
        final standalone = makeStandaloneReceipt(
          policyText: trackingPolicyText,
          overallState: ReviewOverallState.reviewRecommended,
          findings: [policyFinding],
        );

        final aiPolicySummary = DeniVoiceSummary(
          headline: 'On-device AI summary of key policy points',
          points: const [
            DeniSummaryPoint(
              id: 'pt_ai_1',
              kind: DeniSummaryPointKind.policyFinding,
              plainText:
                  'The policy states it shares location and advertising IDs with marketing partners.',
              findingId: 'finding_ai_1',
              sourceExcerpt:
                  'We share precise location data and advertising identifiers with third-party marketing partners',
            ),
          ],
          unknownSummary: 'Policy text alone cannot show live network traffic.',
          calibrationNotice: 'Summary covers reviewed policy text only.',
          summarySource: InferenceSource.onDevice,
          languageCode: 'en',
        );

        final linked = coordinator.linkInstalledAppToReceipt(
          receipt: standalone,
          appPermissions: focusSnapshotWithUndisclosedLocation,
          draftId: 'draft_voice_linked',
        );

        final updatedLinkedSummary =
            DeniVoiceSummaryBuilder.withUpdatedDeviceContext(
              current: aiPolicySummary,
              receipt: linked.receipt,
              associationReport: linked.associationReport,
            );

        // AI inference source & policy bullet preserved; device bullet added
        expect(updatedLinkedSummary.summarySource, InferenceSource.onDevice);
        expect(
          updatedLinkedSummary.points.any(
            (p) =>
                p.kind == DeniSummaryPointKind.policyFinding &&
                p.findingId == 'finding_ai_1',
          ),
          isTrue,
        );
        expect(
          updatedLinkedSummary.points.any(
            (p) => p.kind == DeniSummaryPointKind.devicePermissionNote,
          ),
          isTrue,
        );
        expect(bridgeCalls, isEmpty);

        // Unlinking strips the device observation bullet cleanly
        final unlinked = coordinator.unlinkInstalledAppFromReceipt(
          receipt: linked.receipt,
          draftId: 'draft_voice_unlinked',
        );
        final updatedUnlinkedSummary =
            DeniVoiceSummaryBuilder.withUpdatedDeviceContext(
              current: updatedLinkedSummary,
              receipt: unlinked.receipt,
              associationReport: unlinked.associationReport,
            );
        expect(
          updatedUnlinkedSummary.points.any(
            (p) => p.kind == DeniSummaryPointKind.devicePermissionNote,
          ),
          isFalse,
        );
        expect(
          updatedUnlinkedSummary.points.any(
            (p) => p.kind == DeniSummaryPointKind.policyFinding,
          ),
          isTrue,
        );
      },
    );
  });
}
