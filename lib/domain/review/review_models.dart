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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'severity': severity.name,
        'exactExcerpt': exactExcerpt,
        'explanation': explanation,
        'whatPolicySays': whatPolicySays,
        'whatAndroidReports': whatAndroidReports,
        'unknowns': unknowns,
        'status': status.name,
        if (contextWindow != null)
          'contextWindow': {
            'before': contextWindow!.before,
            'matched': contextWindow!.matched,
            'after': contextWindow!.after,
          },
      };

  factory VerifiedFinding.fromJson(Map<String, dynamic> json) {
    final cwMap = (json['contextWindow'] as Map?)?.cast<String, dynamic>();
    return VerifiedFinding(
      id: json['id'] as String? ?? 'f_0',
      title: json['title'] as String? ?? '',
      category: FindingCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => FindingCategory.dataCollection,
      ),
      severity: FindingSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => FindingSeverity.medium,
      ),
      exactExcerpt: json['exactExcerpt'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      whatPolicySays: json['whatPolicySays'] as String? ?? '',
      whatAndroidReports: json['whatAndroidReports'] as String? ?? '',
      unknowns: (json['unknowns'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
      status: EvidenceStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EvidenceStatus.unverified,
      ),
      contextWindow: cwMap == null
          ? null
          : (
              before: cwMap['before'] as String? ?? '',
              matched: cwMap['matched'] as String? ?? '',
              after: cwMap['after'] as String? ?? '',
            ),
    );
  }
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectTitle': subjectTitle,
        'sourceLabel': sourceLabel,
        'snapshotText': snapshotText,
        'snapshotDigest': snapshotDigest,
        'createdAtMs': createdAt.millisecondsSinceEpoch,
        'overallState': overallState.name,
        'inferenceSource': inferenceSource.name,
        'summary': summary,
        'calibratedDisclaimer': calibratedDisclaimer,
        'findings': findings.map((f) => f.toJson()).toList(),
        if (permissionReport != null)
          'permissionReport': permissionReport!.toJson(),
      };

  factory PolicyReviewReceipt.fromJson(Map<String, dynamic> json) {
    final findingsList = (json['findings'] as List?) ?? const [];
    final permMap =
        (json['permissionReport'] as Map?)?.cast<String, dynamic>();
    return PolicyReviewReceipt(
      id: json['id'] as String? ?? 'rcpt_unknown',
      subjectTitle: json['subjectTitle'] as String? ?? 'Policy Snapshot',
      sourceLabel: json['sourceLabel'] as String? ?? 'Local Snapshot',
      snapshotText: json['snapshotText'] as String? ?? '',
      snapshotDigest: json['snapshotDigest'] as String? ?? '00000000',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      overallState: ReviewOverallState.values.firstWhere(
        (s) => s.name == json['overallState'],
        orElse: () => ReviewOverallState.insufficientEvidence,
      ),
      inferenceSource: InferenceSource.values.firstWhere(
        (s) => s.name == json['inferenceSource'],
        orElse: () => InferenceSource.onDevice,
      ),
      summary: json['summary'] as String? ?? '',
      calibratedDisclaimer: json['calibratedDisclaimer'] as String? ??
          'No concern identified in the reviewed evidence. This is not a safety certification.',
      findings: findingsList
          .whereType<Map>()
          .map((m) => VerifiedFinding.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      permissionReport: permMap == null
          ? null
          : AppPermissionComparisonReport.fromJson(permMap),
    );
  }
}
