import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptRepository & JSON serialization', () {
    test('round-trips PolicyReviewReceipt with PermissionComparisonReport cleanly', () {
      const policy = 'EduTrack collects precise GPS location coordinates.';
      final report = PermissionComparator.compare(
        snapshot: PermissionComparator.demoEduTrackSnapshot,
        policyText: policy,
      );

      final receipt = PolicyReviewReceipt(
        id: 'rcpt_test_1',
        subjectTitle: 'EduTrack Classroom Companion',
        sourceLabel: 'Installed App',
        snapshotText: policy,
        snapshotDigest: 'abc12345',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1731440000000),
        overallState: ReviewOverallState.reviewRecommended,
        inferenceSource: InferenceSource.onDevice,
        summary: 'Collects precise location coordinates.',
        calibratedDisclaimer:
            'No concern identified in the reviewed evidence. This is not a safety certification.',
        findings: [
          VerifiedFinding(
            id: 'f_loc',
            title: 'Location Tracking',
            category: FindingCategory.tracking,
            severity: FindingSeverity.high,
            exactExcerpt: 'collects precise GPS location coordinates',
            explanation: 'Reads GPS location.',
            whatPolicySays: 'Discloses GPS collection.',
            whatAndroidReports: 'ACCESS_FINE_LOCATION granted.',
            unknowns: const ['Cannot verify server retention duration.'],
            status: EvidenceStatus.sourceMatched,
            contextWindow: (
              before: 'EduTrack ',
              matched: 'collects precise GPS location coordinates',
              after: '.',
            ),
          ),
        ],
        permissionReport: report,
      );

      final json = receipt.toJson();
      final decoded = PolicyReviewReceipt.fromJson(json);

      expect(decoded.id, equals('rcpt_test_1'));
      expect(decoded.subjectTitle, equals('EduTrack Classroom Companion'));
      expect(decoded.overallState, equals(ReviewOverallState.reviewRecommended));
      expect(decoded.inferenceSource, equals(InferenceSource.onDevice));
      expect(decoded.findings.length, equals(1));
      expect(decoded.findings.first.contextWindow?.matched,
          equals('collects precise GPS location coordinates'));
      expect(decoded.permissionReport, isNotNull);
      expect(decoded.permissionReport!.snapshot.packageName,
          equals('com.edutrack.classroom.demo'));
      expect(decoded.permissionReport!.mismatchCount,
          equals(report.mismatchCount));
    });

    test('saves, sorts newest-first, deletes, and clears receipts in local store', () async {
      final repo = ReceiptRepository(useInMemoryOnly: true);

      final older = PolicyReviewReceipt(
        id: 'rcpt_old',
        subjectTitle: 'CalmMath Abacus',
        sourceLabel: 'Sample',
        snapshotText: 'Stored locally.',
        snapshotDigest: '11112222',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        overallState: ReviewOverallState.noConcern,
        inferenceSource: InferenceSource.onDevice,
        summary: 'No concerns.',
        calibratedDisclaimer:
            'No concern identified in the reviewed evidence. This is not a safety certification.',
        findings: const [],
      );

      final newer = PolicyReviewReceipt(
        id: 'rcpt_new',
        subjectTitle: 'EduTrack',
        sourceLabel: 'Installed App',
        snapshotText: 'Shares AD_ID.',
        snapshotDigest: '33334444',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1730000000000),
        overallState: ReviewOverallState.reviewRecommended,
        inferenceSource: InferenceSource.onDevice,
        summary: 'Review recommended.',
        calibratedDisclaimer:
            'No concern identified in the reviewed evidence. This is not a safety certification.',
        findings: const [],
      );

      await repo.saveReceipt(older);
      await repo.saveReceipt(newer);

      var list = await repo.loadReceipts();
      expect(list.map((r) => r.id), equals(['rcpt_new', 'rcpt_old']));

      await repo.deleteReceipt('rcpt_new');
      list = await repo.loadReceipts();
      expect(list.map((r) => r.id), equals(['rcpt_old']));

      await repo.clearAllReceipts();
      list = await repo.loadReceipts();
      expect(list, isEmpty);
    });
  });
}
