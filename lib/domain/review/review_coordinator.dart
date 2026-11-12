import '../../services/platform/hybrid_ai_bridge.dart';
import '../../widgets/enprive_provenance_chip.dart';
import '../evidence/evidence_validator.dart';
import 'review_models.dart';

class ReviewExecutionResult {
  final PolicyReviewReceipt? receipt;
  final bool needsCloudConsentOrManual;
  final String? errorReason;

  const ReviewExecutionResult._({
    this.receipt,
    required this.needsCloudConsentOrManual,
    this.errorReason,
  });

  factory ReviewExecutionResult.completed(PolicyReviewReceipt receipt) {
    return ReviewExecutionResult._(
      receipt: receipt,
      needsCloudConsentOrManual: false,
    );
  }

  factory ReviewExecutionResult.requiresConsentChoice({String? reason}) {
    return ReviewExecutionResult._(
      needsCloudConsentOrManual: true,
      errorReason: reason,
    );
  }
}

/// Coordinates privacy policy analysis across HybridAiBridge (Gemini Nano 4
/// on-device & consented Gemini 3.8 Flash cloud) and EvidenceValidator.
class ReviewCoordinator {
  static const String calibratedDefaultDisclaimer =
      'No concern identified in the reviewed evidence. This is not a safety certification.';

  final HybridAiBridge _bridge;

  ReviewCoordinator({HybridAiBridge? bridge})
      : _bridge = bridge ?? HybridAiBridge();

  Future<ReviewExecutionResult> runPolicyReview({
    required String subjectTitle,
    required String sourceLabel,
    required String policyText,
    bool cloudConsent = false,
    bool forceLocalManualScan = false,
  }) async {
    final trimmed = policyText.trim();
    if (trimmed.isEmpty) {
      return ReviewExecutionResult.completed(
        _buildInsufficientReceipt(
          subjectTitle: subjectTitle,
          sourceLabel: sourceLabel,
          snapshotText: '',
          reason: 'No policy text was provided for review.',
        ),
      );
    }

    if (forceLocalManualScan) {
      final receipt = buildDeterministicLocalReceipt(
        subjectTitle: subjectTitle,
        sourceLabel: sourceLabel,
        policyText: trimmed,
        source: InferenceSource.onDevice,
      );
      return ReviewExecutionResult.completed(receipt);
    }

    final reqId = 'rev_${DateTime.now().millisecondsSinceEpoch}';
    final bridgeResult = await _bridge.analyseText(
      requestId: reqId,
      task: 'summarise_concerns',
      text: trimmed,
      cloudConsent: cloudConsent,
    );

    if (bridgeResult.status == HybridStatus.success &&
        bridgeResult.structuredOutput != null) {
      final receipt = _parseAndValidateBridgeOutput(
        subjectTitle: subjectTitle,
        sourceLabel: sourceLabel,
        snapshotText: trimmed,
        bridgeResult: bridgeResult,
      );
      return ReviewExecutionResult.completed(receipt);
    }

    // If on-device Nano 4 was unavailable and cloud consent has not been asked yet,
    // prompt the user with the explicit per-check Cloud Consent / Manual Review modal.
    if (!cloudConsent) {
      return ReviewExecutionResult.requiresConsentChoice(
        reason: bridgeResult.message ??
            'On-device Gemini Nano 4 is not ready on this device.',
      );
    }

    // If cloud consent was granted but network / App Check failed (e.g. offline),
    // fall back to deterministic local clause matching on-device so the parent
    // or teacher still gets verified verbatim quotes.
    final fallbackReceipt = buildDeterministicLocalReceipt(
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      policyText: trimmed,
      source: InferenceSource.onDevice,
    );
    return ReviewExecutionResult.completed(fallbackReceipt);
  }

  /// 1-turn grounded explanation from Deni for the "Why this finding?" sheet.
  Future<DeniExplanation> askDeniAboutFinding({
    required VerifiedFinding finding,
    required String question,
    required String snapshotText,
    bool cloudConsent = false,
  }) async {
    final reqId = 'deni_${DateTime.now().millisecondsSinceEpoch}';
    final compositeInput =
        'Question: $question\nQuoted Clause: "${finding.exactExcerpt}"\n\n$snapshotText';

    final res = await _bridge.analyseText(
      requestId: reqId,
      task: 'explain_finding',
      text: compositeInput,
      cloudConsent: cloudConsent,
    );

    if (res.status == HybridStatus.success && res.structuredOutput != null) {
      final out = res.structuredOutput!;
      final answer = (out['answer'] as String?)?.trim();
      if (answer != null && answer.isNotEmpty) {
        return DeniExplanation(
          question: question,
          answer: answer,
          whatPolicySays: (out['whatPolicySays'] as String?)?.trim() ??
              finding.whatPolicySays,
          unknownBoundary: (out['unknownBoundary'] as String?)?.trim() ??
              (finding.unknowns.isNotEmpty
                  ? finding.unknowns.first
                  : 'The policy text does not state how often this occurs in practice.'),
          inferenceSource: res.inferenceSource == 'IN_CLOUD'
              ? InferenceSource.inCloud
              : InferenceSource.onDevice,
        );
      }
    }

    // Grounded deterministic on-device response when offline or without AICore
    return DeniExplanation(
      question: question,
      answer:
          'Based strictly on the captured excerpt, ${finding.explanation} '
          'Because Enprive only trusts verbatim evidence, I recommend checking whether this setting can be disabled before a child uses the app.',
      whatPolicySays:
          'The policy explicitly states: "${finding.exactExcerpt}"',
      unknownBoundary: finding.unknowns.isNotEmpty
          ? finding.unknowns.first
          : 'This policy excerpt alone cannot verify whether the app actively transmits this data right now.',
      inferenceSource: InferenceSource.onDevice,
    );
  }

  PolicyReviewReceipt _parseAndValidateBridgeOutput({
    required String subjectTitle,
    required String sourceLabel,
    required String snapshotText,
    required HybridAnalysisResult bridgeResult,
  }) {
    final map = bridgeResult.structuredOutput!;
    final rawConcerns = (map['concerns'] as List?) ?? const [];
    final findings = <VerifiedFinding>[];

    for (var i = 0; i < rawConcerns.length; i++) {
      final item = rawConcerns[i];
      if (item is! Map) continue;
      final rawMap = item.cast<String, dynamic>();
      final quote = (rawMap['quote'] as String?) ??
          (rawMap['exact_excerpt'] as String?) ??
          '';

      final validated = EvidenceValidator.validateFinding(
        rawFinding: {
          ...rawMap,
          'exact_excerpt': quote,
        },
        snapshotText: snapshotText,
        validEvidenceIds: {'finding_${i + 1}'},
      );

      final isSourceMatched = validated['status'] == 'SOURCE_MATCHED';
      final contextWin = isSourceMatched
          ? EvidenceValidator.extractContextWindow(
              quote: quote,
              snapshotText: snapshotText,
            )
          : null;

      final rawUnknowns = (validated['unknowns'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];
      if (rawUnknowns.isEmpty) {
        rawUnknowns.add(
          'Policy text alone does not prove runtime network transmission frequency.',
        );
      }

      final categoryStr =
          (rawMap['category'] as String?)?.toUpperCase() ?? 'DATA_COLLECTION';
      final severityStr =
          (rawMap['severity'] as String?)?.toUpperCase() ?? 'MEDIUM';

      findings.add(
        VerifiedFinding(
          id: (rawMap['id'] as String?) ?? 'finding_${i + 1}',
          title: (rawMap['title'] as String?) ??
              _defaultTitleForCategory(categoryStr),
          category: _parseCategory(categoryStr),
          severity: _parseSeverity(severityStr),
          exactExcerpt: quote.isEmpty
              ? 'No verbatim quote supplied by model.'
              : EvidenceValidator.normalize(quote),
          explanation: (rawMap['explanation'] as String?) ??
              'This clause describes data handling that warrants parent or teacher review.',
          whatPolicySays: isSourceMatched
              ? 'Verbatim match confirmed in captured snapshot (${EvidenceValidator.normalize(quote).length} chars).'
              : 'Model cited a passage that could not be matched verbatim in the captured snapshot.',
          whatAndroidReports:
              'Text-only policy review. Run "Check an app" to compare against live Android OS permissions.',
          unknowns: rawUnknowns,
          status: isSourceMatched
              ? EvidenceStatus.sourceMatched
              : EvidenceStatus.unverified,
          contextWindow: contextWin,
        ),
      );
    }

    final hasVerifiedConcerns = findings.any(
      (f) => f.status == EvidenceStatus.sourceMatched,
    );
    final rawState = (map['overall_state'] as String?)?.toUpperCase() ?? '';

    final ReviewOverallState overallState;
    if (hasVerifiedConcerns || rawState == 'REVIEW_RECOMMENDED') {
      overallState = findings.isEmpty && rawState == 'REVIEW_RECOMMENDED'
          ? ReviewOverallState.insufficientEvidence
          : (hasVerifiedConcerns
              ? ReviewOverallState.reviewRecommended
              : ReviewOverallState.insufficientEvidence);
    } else if (rawState == 'NO_CONCERN' && findings.isEmpty) {
      overallState = ReviewOverallState.noConcern;
    } else if (findings.isNotEmpty && !hasVerifiedConcerns) {
      overallState = ReviewOverallState.insufficientEvidence;
    } else {
      overallState = ReviewOverallState.noConcern;
    }

    final sourceChip = switch (bridgeResult.inferenceSource.toUpperCase()) {
      'IN_CLOUD' => InferenceSource.inCloud,
      'ON_DEVICE' => InferenceSource.onDevice,
      _ => InferenceSource.locationUnavailable,
    };

    return PolicyReviewReceipt(
      id: bridgeResult.requestId,
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      snapshotText: snapshotText,
      snapshotDigest: EvidenceValidator.computeSnapshotDigest(snapshotText),
      createdAt: DateTime.now(),
      overallState: overallState,
      inferenceSource: sourceChip,
      summary: (map['summary'] as String?) ??
          _defaultSummaryForState(overallState, findings.length),
      calibratedDisclaimer:
          (map['calibratedDisclaimer'] as String?) ?? calibratedDefaultDisclaimer,
      findings: findings,
    );
  }

  /// Deterministic on-device clause scanner that extracts verbatim sentences
  /// matching high-signal privacy patterns and validates them through
  /// [EvidenceValidator]. Used for manual local review or offline environments.
  PolicyReviewReceipt buildDeterministicLocalReceipt({
    required String subjectTitle,
    required String sourceLabel,
    required String policyText,
    required InferenceSource source,
  }) {
    final sentences = policyText
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.length >= 25)
        .toList();

    final findings = <VerifiedFinding>[];
    int idx = 1;

    for (final sentence in sentences) {
      final lower = sentence.toLowerCase();

      // Skip explicit non-collection reassurance clauses
      final isNegatedReassurance = lower.contains('we do not collect') ||
          lower.contains('we never sell') ||
          lower.contains('stored exclusively on this device') ||
          lower.contains('do not integrate third-party advertising');
      if (isNegatedReassurance) continue;

      if (lower.contains('location') &&
          (lower.contains('gps') ||
              lower.contains('background') ||
              lower.contains('precise') ||
              lower.contains('share'))) {
        findings.add(_buildVerifiedLocalFinding(
          id: 'local_$idx',
          title: 'Precise or Background Location Collection',
          category: FindingCategory.tracking,
          severity: FindingSeverity.high,
          excerpt: sentence,
          explanation:
              'This clause indicates that precise or background location data may be collected or shared while a student uses the app.',
          unknown:
              'The policy text does not prove whether Android OS location permissions are currently granted on this phone.',
          snapshotText: policyText,
        ));
        idx++;
      } else if ((lower.contains('voice') ||
              lower.contains('microphone') ||
              lower.contains('biometric')) &&
          (lower.contains('retain') ||
              lower.contains('indefinitely') ||
              lower.contains('train') ||
              lower.contains('record'))) {
        findings.add(_buildVerifiedLocalFinding(
          id: 'local_$idx',
          title: 'Voice Recording & Model Training Retention',
          category: FindingCategory.retention,
          severity: FindingSeverity.high,
          excerpt: sentence,
          explanation:
              'Student voice recordings or transcripts may be stored long-term and used to train automated recognition models.',
          unknown:
              'Does not specify whether parents can delete individual recordings directly without a school administrator.',
          snapshotText: policyText,
        ));
        idx++;
      } else if (lower.contains('advertising') ||
          lower.contains('third-party') ||
          lower.contains('behavioral promotions')) {
        findings.add(_buildVerifiedLocalFinding(
          id: 'local_$idx',
          title: 'Third-Party Advertising & Analytics Sharing',
          category: FindingCategory.sharing,
          severity: FindingSeverity.medium,
          excerpt: sentence,
          explanation:
              'Identifiers or usage events may be shared with external advertising or analytics partners.',
          unknown:
              'Does not list the specific third-party ad networks or whether child-directed treatment flags are enforced.',
          snapshotText: policyText,
        ));
        idx++;
      } else if (lower.contains('disable core') ||
          lower.contains('revoking') && lower.contains('permissions')) {
        findings.add(_buildVerifiedLocalFinding(
          id: 'local_$idx',
          title: 'Permission Revocation Trade-Off',
          category: FindingCategory.parentalConsent,
          severity: FindingSeverity.low,
          excerpt: sentence,
          explanation:
              'Turning off microphone or location permissions in Android Settings may restrict certain homework features.',
          unknown:
              'Does not specify which offline features remain usable when permissions are denied.',
          snapshotText: policyText,
        ));
        idx++;
      }
    }

    final overallState = findings.isNotEmpty
        ? ReviewOverallState.reviewRecommended
        : (sentences.isEmpty
            ? ReviewOverallState.insufficientEvidence
            : ReviewOverallState.noConcern);

    return PolicyReviewReceipt(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      snapshotText: policyText,
      snapshotDigest: EvidenceValidator.computeSnapshotDigest(policyText),
      createdAt: DateTime.now(),
      overallState: overallState,
      inferenceSource: source,
      summary: _defaultSummaryForState(overallState, findings.length),
      calibratedDisclaimer: calibratedDefaultDisclaimer,
      findings: findings,
    );
  }

  VerifiedFinding _buildVerifiedLocalFinding({
    required String id,
    required String title,
    required FindingCategory category,
    required FindingSeverity severity,
    required String excerpt,
    required String explanation,
    required String unknown,
    required String snapshotText,
  }) {
    final validated = EvidenceValidator.validateFinding(
      rawFinding: {
        'id': id,
        'exact_excerpt': excerpt,
      },
      snapshotText: snapshotText,
      validEvidenceIds: {id},
    );
    final isMatched = validated['status'] == 'SOURCE_MATCHED';
    return VerifiedFinding(
      id: id,
      title: title,
      category: category,
      severity: severity,
      exactExcerpt: EvidenceValidator.normalize(excerpt),
      explanation: explanation,
      whatPolicySays:
          'Matched verbatim in the captured policy snapshot (${EvidenceValidator.normalize(excerpt).length} chars).',
      whatAndroidReports:
          'Local policy snapshot check. Use "Check an app" to compare against Android OS permission state.',
      unknowns: [unknown],
      status: isMatched ? EvidenceStatus.sourceMatched : EvidenceStatus.unverified,
      contextWindow: EvidenceValidator.extractContextWindow(
        quote: excerpt,
        snapshotText: snapshotText,
      ),
    );
  }

  PolicyReviewReceipt _buildInsufficientReceipt({
    required String subjectTitle,
    required String sourceLabel,
    required String snapshotText,
    required String reason,
  }) {
    return PolicyReviewReceipt(
      id: 'insuf_${DateTime.now().millisecondsSinceEpoch}',
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      snapshotText: snapshotText,
      snapshotDigest: EvidenceValidator.computeSnapshotDigest(snapshotText),
      createdAt: DateTime.now(),
      overallState: ReviewOverallState.insufficientEvidence,
      inferenceSource: InferenceSource.onDevice,
      summary: reason,
      calibratedDisclaimer: calibratedDefaultDisclaimer,
      findings: const [],
    );
  }

  static String _defaultTitleForCategory(String category) {
    return switch (category) {
      'SHARING' => 'Third-Party Data Sharing Clause',
      'TRACKING' => 'Location or Identifier Tracking Clause',
      'RETENTION' => 'Data Retention & Storage Clause',
      'PARENTAL_CONSENT' => 'Parental Consent & Controls Clause',
      _ => 'Data Collection Clause',
    };
  }

  static FindingCategory _parseCategory(String raw) {
    return switch (raw) {
      'SHARING' => FindingCategory.sharing,
      'TRACKING' => FindingCategory.tracking,
      'RETENTION' => FindingCategory.retention,
      'PARENTAL_CONSENT' => FindingCategory.parentalConsent,
      _ => FindingCategory.dataCollection,
    };
  }

  static FindingSeverity _parseSeverity(String raw) {
    return switch (raw) {
      'HIGH' => FindingSeverity.high,
      'LOW' => FindingSeverity.low,
      _ => FindingSeverity.medium,
    };
  }

  static String _defaultSummaryForState(
    ReviewOverallState state,
    int findingCount,
  ) {
    return switch (state) {
      ReviewOverallState.reviewRecommended =>
        '$findingCount source-matched policy ${findingCount == 1 ? 'passage deserves' : 'passages deserve'} a closer look by a parent or teacher.',
      ReviewOverallState.noConcern =>
        'No concerning data collection, sharing, or indefinite retention clauses were identified in the reviewed text.',
      ReviewOverallState.insufficientEvidence =>
        'The provided excerpt did not contain enough verifiable policy statements to reach a conclusion.',
    };
  }
}
