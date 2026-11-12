import '../../widgets/enprive_provenance_chip.dart';
import '../permissions/permission_comparator.dart';

/// Calibrated 3-state review outcome (never a binary "Safe" certification).
enum ReviewOverallState {
  noConcern,
  reviewRecommended,
  insufficientEvidence,
}

/// Deterministic verification status of a finding against source evidence.
enum EvidenceStatus {
  sourceMatched,
  deviceObserved,
  interpretation,
  unverified,
}

enum FindingCategory {
  dataCollection,
  sharing,
  tracking,
  retention,
  parentalConsent,
}

enum FindingSeverity {
  high,
  medium,
  low,
}

class VerifiedFinding {
  final String id;
  final String title;
  final FindingCategory category;
  final FindingSeverity severity;
  final String exactExcerpt;
  final String explanation;
  final String whatPolicySays;
  final String whatAndroidReports;
  final List<String> unknowns;
  final EvidenceStatus status;
  final ({String before, String matched, String after})? contextWindow;

  const VerifiedFinding({
    required this.id,
    required this.title,
    required this.category,
    required this.severity,
    required this.exactExcerpt,
    required this.explanation,
    required this.whatPolicySays,
    required this.whatAndroidReports,
    required this.unknowns,
    required this.status,
    this.contextWindow,
  });

  bool get isVerified =>
      status == EvidenceStatus.sourceMatched ||
      status == EvidenceStatus.deviceObserved;
}

class DeniExplanation {
  final String question;
  final String answer;
  final String whatPolicySays;
  final String unknownBoundary;
  final InferenceSource inferenceSource;

  const DeniExplanation({
    required this.question,
    required this.answer,
    required this.whatPolicySays,
    required this.unknownBoundary,
    required this.inferenceSource,
  });
}

class PolicyReviewReceipt {
  final String id;
  final String subjectTitle;
  final String sourceLabel;
  final String snapshotText;
  final String snapshotDigest;
  final DateTime createdAt;
  final ReviewOverallState overallState;
  final InferenceSource inferenceSource;
  final String summary;
  final String calibratedDisclaimer;
  final List<VerifiedFinding> findings;
  final AppPermissionComparisonReport? permissionReport;

  const PolicyReviewReceipt({
    required this.id,
    required this.subjectTitle,
    required this.sourceLabel,
    required this.snapshotText,
    required this.snapshotDigest,
    required this.createdAt,
    required this.overallState,
    required this.inferenceSource,
    required this.summary,
    required this.calibratedDisclaimer,
    required this.findings,
    this.permissionReport,
  });

  int get sourceMatchedCount => findings
      .where(
        (f) =>
            f.status == EvidenceStatus.sourceMatched ||
            f.status == EvidenceStatus.deviceObserved,
      )
      .length;

  int get deviceObservedCount =>
      findings.where((f) => f.status == EvidenceStatus.deviceObserved).length;

  int get unverifiedCount =>
      findings.where((f) => f.status == EvidenceStatus.unverified).length;
}
