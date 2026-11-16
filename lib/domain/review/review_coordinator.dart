import '../../l10n/app_localizations.dart';
import '../../l10n/enprive_languages.dart';
import '../../services/platform/hybrid_ai_bridge.dart';
import '../../widgets/enprive_provenance_chip.dart';
import '../evidence/evidence_validator.dart';
import '../permissions/permission_comparator.dart';
import '../privacy/pii_redactor.dart';
import 'policy_sufficiency.dart';
import 'review_models.dart';

class ReviewExecutionResult {
  final PolicyReviewReceipt? receipt;
  final bool needsCloudConsentOrManual;
  final String? errorReason;
  final String? redactedPreview;

  const ReviewExecutionResult._({
    this.receipt,
    required this.needsCloudConsentOrManual,
    this.errorReason,
    this.redactedPreview,
  });

  factory ReviewExecutionResult.completed(PolicyReviewReceipt receipt) {
    return ReviewExecutionResult._(
      receipt: receipt,
      needsCloudConsentOrManual: false,
    );
  }

  factory ReviewExecutionResult.requiresConsentChoice({
    String? reason,
    String? redactedPreview,
  }) {
    return ReviewExecutionResult._(
      needsCloudConsentOrManual: true,
      errorReason: reason,
      redactedPreview: redactedPreview,
    );
  }
}

/// Coordinates privacy policy analysis across HybridAiBridge (Gemini Nano 4
/// on-device & consented Gemini 3.8 Flash cloud) and EvidenceValidator.
class ReviewCoordinator {
  static const String calibratedDefaultDisclaimer =
      'No concern identified in the reviewed evidence. This is not a safety certification.';

  final HybridAiBridge _bridge;
  HybridAiBridge get bridge => _bridge;
  Stream<AnalysisStreamEvent> get analysisEvents => _bridge.analysisEvents;

  ReviewCoordinator({HybridAiBridge? bridge})
    : _bridge = bridge ?? HybridAiBridge();

  void _recordAndEmitStep({
    required String requestId,
    required List<String> steps,
    required String stage,
    required String label,
    String? detail,
    String? thoughtSummary,
    String? thoughtSignature,
    String? inferenceSource,
    bool isCompleted = false,
  }) {
    if (!steps.contains(label)) {
      steps.add(label);
    }
    _bridge.emitProcessEvent(
      AnalysisStreamEvent(
        requestId: requestId,
        stage: stage,
        label: label,
        detail: detail,
        thoughtSummary: thoughtSummary,
        thoughtSignature: thoughtSignature,
        inferenceSource: inferenceSource,
        isCompleted: isCompleted,
      ),
    );
  }

  static String _localizedDisclaimerFor(String languageCode) {
    final normalized = enpriveLanguageByCode(languageCode);
    if (normalized.code == 'en') return calibratedDefaultDisclaimer;
    return lookupAppLocalizations(normalized.locale).stateNoConcernSubtitle;
  }

  /// Produces the canonical PII-redacted string used identically for both the
  /// [CloudConsentSheet] preview and the App Check protected cloud bridge payload.
  static String canonicalCloudPayload(String policyText) =>
      PiiRedactor.redact(policyText.trim()).redactedText;

  Future<ReviewExecutionResult> runPolicyReview({
    required String subjectTitle,
    required String sourceLabel,
    required String policyText,
    AppPermissionSnapshot? appPermissions,
    bool cloudConsent = false,
    bool forceLocalManualScan = false,
    String languageCode = 'en',
    PolicySourceSnapshot? sourceSnapshot,
    String? canonicalRedactedPayload,
  }) async {
    final trimmed = policyText.trim();
    final resolvedSnapshot =
        sourceSnapshot ??
        PolicySourceSnapshot(
          snapshotId: 'snap_${DateTime.now().millisecondsSinceEpoch}',
          sourceType: PolicySourceType.pastedText,
          retrievedAt: DateTime.now().toUtc(),
          retrievalStatus: PolicyRetrievalStatus.localProvided,
          appIdentityMatchStatus: appPermissions != null
              ? AppIdentityMatchStatus.unverifiedUserSupplied
              : AppIdentityMatchStatus.notApplicable,
          sourceSha256Hash: trimmed.isEmpty
              ? ''
              : EvidenceValidator.computeSha256SourceHash(trimmed),
        );

    final sufficiency = PolicySufficiencyValidator.assess(trimmed);
    if (!sufficiency.isSufficient) {
      final insufficient = _buildInsufficientReceipt(
        subjectTitle: subjectTitle,
        sourceLabel: sourceLabel,
        snapshotText: trimmed,
        reason: sufficiency.explanation,
        diagnosticKind: ReviewDiagnosticKind.insufficientPolicyMaterial,
        languageCode: languageCode,
        sourceSnapshot: resolvedSnapshot,
      );
      return ReviewExecutionResult.completed(
        _attachPermissionComparison(insufficient, appPermissions),
      );
    }

    final reqId = 'rev_${DateTime.now().millisecondsSinceEpoch}';
    final processSteps = <String>[];
    String? streamedThought;
    String? streamedSignature;

    final sub = _bridge.analysisEvents.listen((event) {
      if (event.requestId != reqId && event.requestId != '${reqId}_appcheck') {
        return;
      }
      if (event.thoughtSummary != null && event.thoughtSummary!.isNotEmpty) {
        streamedThought = event.thoughtSummary;
      }
      if (event.thoughtSignature != null &&
          event.thoughtSignature!.isNotEmpty) {
        streamedSignature = event.thoughtSignature;
      }
    });

    try {
      if (forceLocalManualScan) {
        return _completeDeterministicPolicyScan(
          requestId: reqId,
          steps: processSteps,
          stage: 'local_clause_scan',
          label: 'Running offline local clause scan',
          subjectTitle: subjectTitle,
          sourceLabel: sourceLabel,
          policyText: trimmed,
          appPermissions: appPermissions,
          thoughtSummary: streamedThought,
          thoughtSignature: streamedSignature,
          languageCode: languageCode,
          sourceSnapshot: resolvedSnapshot,
        );
      }

      // Privacy Guardrail: Installed app lists and Android OS permission observations
      // stay strictly on this phone and NEVER enter AI prompts.
      final isComprehensive = PiiRedactor.isComprehensivePolicy(trimmed);

      // 1. Strict Privacy Boundary: without explicit cloudConsent, only ONLY_ON_DEVICE
      // is permitted for concise text. Any failure or comprehensive length pauses for
      // explicit user consent — never silently escalating to cloud.
      if (!cloudConsent) {
        if (isComprehensive) {
          _recordAndEmitStep(
            requestId: reqId,
            steps: processSteps,
            stage: 'on_device_consent_required',
            label: 'Policy exceeds on-device limit — waiting for your choice',
          );
          final preview = canonicalCloudPayload(trimmed);
          return ReviewExecutionResult.requiresConsentChoice(
            reason:
                'This policy is too detailed for on-device AI processing.',
            redactedPreview: preview,
          );
        }

        _recordAndEmitStep(
          requestId: reqId,
          steps: processSteps,
          stage: 'checking_on_device',
          label: 'Reading policy text on this phone',
          inferenceSource: 'ON_DEVICE',
        );
        final localResult = await _bridge.analyseText(
          requestId: reqId,
          task: 'summarise_concerns',
          text: trimmed,
          cloudConsent: false,
          requestedMode: 'ONLY_ON_DEVICE',
          languageCode: languageCode,
        );

        if (localResult.status == HybridStatus.success) {
          return _completeBridgePolicyReceipt(
            requestId: reqId,
            steps: processSteps,
            subjectTitle: subjectTitle,
            sourceLabel: sourceLabel,
            snapshotText: trimmed,
            bridgeResult: localResult,
            appPermissions: appPermissions,
            streamedThought: streamedThought,
            streamedSignature: streamedSignature,
            languageCode: languageCode,
            sourceSnapshot: resolvedSnapshot,
          );
        }

        _recordAndEmitStep(
          requestId: reqId,
          steps: processSteps,
          stage: 'on_device_unavailable',
          label: 'On-device AI unavailable — waiting for your choice',
        );
        final preview = canonicalCloudPayload(trimmed);
        return ReviewExecutionResult.requiresConsentChoice(
          reason: localResult.message ??
              'On-device AI is unavailable on this phone right now.',
          redactedPreview: preview,
        );
      }

      // 2. Explicit cloudConsent granted for this check: scrub PII strictly for
      // data minimization, then invoke App Check protected ONLY_IN_CLOUD inference.
      final redaction = PiiRedactor.redact(trimmed);
      final textForCloud = canonicalRedactedPayload ?? redaction.redactedText;
      _recordAndEmitStep(
        requestId: reqId,
        steps: processSteps,
        stage: 'redacting_pii',
        label: redaction.hadPersonalDetails
            ? 'Masked ${redaction.replacementCount} personal ${redaction.replacementCount == 1 ? 'detail' : 'details'} with placeholders'
            : 'Verified no personal details before sending',
      );
      _recordAndEmitStep(
        requestId: '${reqId}_appcheck',
        steps: processSteps,
        stage: 'sending_appcheck',
        label: 'Streaming reasoning with App Check protection',
        inferenceSource: 'IN_CLOUD',
      );

      final cloudResult = await _bridge.analyseText(
        requestId: '${reqId}_appcheck',
        task: 'summarise_concerns',
        text: textForCloud,
        cloudConsent: true,
        requestedMode: 'ONLY_IN_CLOUD',
        languageCode: languageCode,
      );

      if (cloudResult.status == HybridStatus.success) {
        return _completeBridgePolicyReceipt(
          requestId: '${reqId}_appcheck',
          steps: processSteps,
          subjectTitle: subjectTitle,
          sourceLabel: sourceLabel,
          snapshotText: trimmed,
          redactedSnapshotText: textForCloud,
          bridgeResult: cloudResult,
          appPermissions: appPermissions,
          streamedThought: streamedThought,
          streamedSignature: streamedSignature,
          languageCode: languageCode,
          thoughtStepLabel: 'Streamed model thoughts',
          signatureStepLabel: 'Verified thought signature',
          sourceSnapshot: resolvedSnapshot,
        );
      }

      // 3. Offline / network failure safety net after explicit cloud consent:
      // run deterministic local clause scan and record OFFLINE_DETERMINISTIC,
      // while distinguishing unavailable cloud inference from failed model inference.
      final isUnavailable = _isUnavailableCloudFailure(cloudResult);
      return _completeDeterministicPolicyScan(
        requestId: reqId,
        steps: processSteps,
        stage: 'offline_fallback',
        label: 'Scanning policy clauses offline on this phone',
        subjectTitle: subjectTitle,
        sourceLabel: sourceLabel,
        policyText: trimmed,
        appPermissions: appPermissions,
        thoughtSummary: streamedThought,
        thoughtSignature: streamedSignature,
        languageCode: languageCode,
        fallbackDiagnosticKind: isUnavailable
            ? ReviewDiagnosticKind.cloudUnavailableLocalFallback
            : ReviewDiagnosticKind.failedModelInference,
        failureDetail: cloudResult.message,
        sourceSnapshot: resolvedSnapshot,
      );
    } finally {
      await sub.cancel();
    }
  }

  /// Creates an honest, local-only Android Device Permission Inspection receipt
  /// without synthesizing or inventing privacy-policy disclosures.
  PolicyReviewReceipt buildDevicePermissionInspectionReceipt({
    required String subjectTitle,
    required String sourceLabel,
    required AppPermissionSnapshot appPermissions,
    String languageCode = 'en',
  }) {
    final report = PermissionComparator.inspectPermissionsOnly(
      snapshot: appPermissions,
    );
    final requestedCount = appPermissions.requestedPermissions.length;
    final grantedCount = appPermissions.grantedPermissions.length;

    return PolicyReviewReceipt(
      id: 'perm_${DateTime.now().millisecondsSinceEpoch}',
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      snapshotText: '',
      snapshotDigest: '',
      createdAt: DateTime.now(),
      overallState: ReviewOverallState.insufficientEvidence,
      inferenceSource: InferenceSource.offlineDeterministic,
      summary:
          'Device Permission Inspection for ${appPermissions.appName} '
          '(${appPermissions.packageName}): $requestedCount Android '
          '${requestedCount == 1 ? 'permission' : 'permissions'} declared '
          '($grantedCount granted). No privacy policy was provided or '
          'compared yet.',
      calibratedDisclaimer:
          'Permission inspection only — no privacy policy has been reviewed. '
          '${_localizedDisclaimerFor(languageCode)}',
      findings: const [],
      permissionReport: report,
      processSteps: const [
        'Queried Android PackageManager locally on this phone',
        'Skipped AI/cloud calls because no privacy policy was supplied',
      ],
      diagnosticKind: ReviewDiagnosticKind.devicePermissionInspection,
      sourceSnapshot: PolicySourceSnapshot(
        snapshotId: 'perm_${DateTime.now().millisecondsSinceEpoch}',
        sourceType: PolicySourceType.devicePermissions,
        retrievedAt: DateTime.now().toUtc(),
        retrievalStatus: PolicyRetrievalStatus.localProvided,
        appIdentityMatchStatus: AppIdentityMatchStatus.notApplicable,
        sourceSha256Hash: '',
        limitationNote:
            'Android PackageManager inspection on this device only; no privacy policy was supplied.',
      ),
      languageCode: languageCode,
    );
  }

  static bool _isUnavailableCloudFailure(HybridAnalysisResult result) {
    final code = (result.errorCode ?? '').toLowerCase();
    final msg = (result.message ?? '').toLowerCase();
    final combined = '$code $msg';
    return combined.contains('quota') ||
        combined.contains('429') ||
        combined.contains('offline') ||
        combined.contains('unable to resolve host') ||
        combined.contains('network') ||
        combined.contains('socket') ||
        combined.contains('timeout') ||
        combined.contains('handshake') ||
        combined.contains('app check') ||
        combined.contains('appcheck') ||
        combined.contains('unavailable');
  }

  ReviewExecutionResult _completeBridgePolicyReceipt({
    required String requestId,
    required List<String> steps,
    required String subjectTitle,
    required String sourceLabel,
    required String snapshotText,
    String? redactedSnapshotText,
    required HybridAnalysisResult bridgeResult,
    required AppPermissionSnapshot? appPermissions,
    required String? streamedThought,
    required String? streamedSignature,
    required String languageCode,
    String thoughtStepLabel = 'Captured policy reasoning',
    String signatureStepLabel = 'Captured thought signature',
    PolicySourceSnapshot? sourceSnapshot,
  }) {
    final thought = bridgeResult.thoughtSummary ?? streamedThought;
    final signature = bridgeResult.thoughtSignature ?? streamedSignature;
    if (thought != null) {
      steps.add(thoughtStepLabel);
    }
    if (signature != null) {
      steps.add(signatureStepLabel);
    }
    _recordAndEmitStep(
      requestId: requestId,
      steps: steps,
      stage: 'verifying_evidence',
      label: appPermissions != null
          ? 'Matching verbatim quotes & phone permissions'
          : 'Matching verbatim quotes in policy',
      thoughtSummary: thought,
      thoughtSignature: signature,
      inferenceSource: bridgeResult.inferenceSource,
      isCompleted: true,
    );
    final receipt = _parseAndValidateBridgeOutput(
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      snapshotText: snapshotText,
      redactedSnapshotText: redactedSnapshotText,
      bridgeResult: bridgeResult,
      processSteps: List<String>.unmodifiable(steps),
      thoughtSummary: thought,
      thoughtSignature: signature,
      languageCode: languageCode,
      sourceSnapshot: sourceSnapshot,
    );
    return ReviewExecutionResult.completed(
      _attachPermissionComparison(receipt, appPermissions),
    );
  }

  ReviewExecutionResult _completeDeterministicPolicyScan({
    required String requestId,
    required List<String> steps,
    required String stage,
    required String label,
    required String subjectTitle,
    required String sourceLabel,
    required String policyText,
    required AppPermissionSnapshot? appPermissions,
    String? thoughtSummary,
    String? thoughtSignature,
    required String languageCode,
    ReviewDiagnosticKind? fallbackDiagnosticKind,
    String? failureDetail,
    PolicySourceSnapshot? sourceSnapshot,
  }) {
    _recordAndEmitStep(
      requestId: requestId,
      steps: steps,
      stage: stage,
      label: label,
      inferenceSource: 'OFFLINE_DETERMINISTIC',
    );
    _recordAndEmitStep(
      requestId: requestId,
      steps: steps,
      stage: 'verifying_evidence',
      label: appPermissions != null
          ? 'Matching verbatim quotes & phone permissions'
          : 'Matching verbatim quotes in policy',
      inferenceSource: 'OFFLINE_DETERMINISTIC',
      isCompleted: true,
    );
    final receipt = buildDeterministicLocalReceipt(
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      policyText: policyText,
      source: InferenceSource.offlineDeterministic,
      processSteps: List<String>.unmodifiable(steps),
      thoughtSummary: thoughtSummary,
      thoughtSignature: thoughtSignature,
      languageCode: languageCode,
      fallbackDiagnosticKind: fallbackDiagnosticKind,
      failureDetail: failureDetail,
      sourceSnapshot: sourceSnapshot,
    );
    return ReviewExecutionResult.completed(
      _attachPermissionComparison(receipt, appPermissions),
    );
  }

  PolicyReviewReceipt _attachPermissionComparison(
    PolicyReviewReceipt baseReceipt,
    AppPermissionSnapshot? appPermissions,
  ) {
    if (appPermissions == null) return baseReceipt;

    final report = PermissionComparator.compare(
      snapshot: appPermissions,
      policyText: baseReceipt.snapshotText,
    );
    final enrichedFindings =
        PermissionComparator.enrichFindingsWithDeviceReport(
          policyFindings: baseReceipt.findings,
          report: report,
        );

    // Explicit verdict-state precedence:
    // Local Android permission observations can promote a validated clean check
    // (NO_CONCERN) to reviewRecommended when undisclosed permissions exist, OR
    // preserve an already-validated reviewRecommended finding. They MUST NEVER
    // promote an insufficient, failed-inference, or unavailable-cloud receipt
    // into a valid reviewRecommended or noConcern outcome, and MUST preserve
    // diagnosticKind, inferenceSource, and sourceSnapshot provenance.
    final ReviewOverallState updatedState;
    if (baseReceipt.overallState == ReviewOverallState.insufficientEvidence) {
      updatedState = ReviewOverallState.insufficientEvidence;
    } else if (baseReceipt.overallState ==
        ReviewOverallState.reviewRecommended) {
      updatedState = ReviewOverallState.reviewRecommended;
    } else {
      final hasConcerns =
          enrichedFindings.any((f) => f.isVerified) || report.mismatchCount > 0;
      updatedState = hasConcerns
          ? ReviewOverallState.reviewRecommended
          : baseReceipt.overallState;
    }

    final permissionNote = report.mismatchCount > 0
        ? ' Local Android inspection also spotted ${report.mismatchCount} undisclosed permission ${report.mismatchCount == 1 ? 'request' : 'requests'}.'
        : '';

    return PolicyReviewReceipt(
      id: baseReceipt.id,
      subjectTitle: baseReceipt.subjectTitle,
      sourceLabel: baseReceipt.sourceLabel,
      snapshotText: baseReceipt.snapshotText,
      snapshotDigest: baseReceipt.snapshotDigest,
      createdAt: baseReceipt.createdAt,
      overallState: updatedState,
      inferenceSource: baseReceipt.inferenceSource,
      summary: '${baseReceipt.summary}$permissionNote',
      calibratedDisclaimer: baseReceipt.calibratedDisclaimer,
      findings: enrichedFindings,
      permissionReport: report,
      processSteps: baseReceipt.processSteps,
      thoughtSummary: baseReceipt.thoughtSummary,
      thoughtSignature: baseReceipt.thoughtSignature,
      diagnosticKind: baseReceipt.diagnosticKind,
      sourceSnapshot: baseReceipt.sourceSnapshot,
      languageCode: baseReceipt.languageCode,
    );
  }

  /// 1-turn grounded explanation from Deni for the "Why this finding?" sheet.
  Future<DeniExplanation> askDeniAboutFinding({
    required VerifiedFinding finding,
    required String question,
    required String snapshotText,
    bool cloudConsent = false,
    bool forceLocalManualFallback = false,
    String languageCode = 'en',
    String? intentHint,
  }) async {
    final reqId = 'deni_${DateTime.now().millisecondsSinceEpoch}';
    final compositeInput =
        'Question: ${question.trim()}\nQuoted Clause: "${finding.exactExcerpt.trim()}"\n\n${snapshotText.trim()}';
    final processSteps = <String>[];
    String? streamedThought;
    String? streamedSignature;

    final sub = _bridge.analysisEvents.listen((event) {
      if (event.requestId != reqId && event.requestId != '${reqId}_appcheck') {
        return;
      }
      if (event.thoughtSummary != null && event.thoughtSummary!.isNotEmpty) {
        streamedThought = event.thoughtSummary;
      }
      if (event.thoughtSignature != null &&
          event.thoughtSignature!.isNotEmpty) {
        streamedSignature = event.thoughtSignature;
      }
    });

    try {
      if (forceLocalManualFallback) {
        return _buildDeterministicDeniExplanation(
          requestId: reqId,
          steps: processSteps,
          finding: finding,
          question: question,
          intentHint: intentHint,
          thoughtSummary: streamedThought,
          thoughtSignature: streamedSignature,
        );
      }

      final defaultUnknown = finding.unknowns.isNotEmpty
          ? finding.unknowns.first
          : 'The policy text does not state how often this occurs in practice.';

      HybridAnalysisResult? res;
      if (!cloudConsent) {
        if (PiiRedactor.isComprehensivePolicy(compositeInput)) {
          _recordAndEmitStep(
            requestId: reqId,
            steps: processSteps,
            stage: 'on_device_consent_required',
            label: 'Policy excerpt exceeds on-device limit — waiting for your choice',
          );
          final scrubbed = PiiRedactor.redact(compositeInput);
          return DeniExplanation.requiresConsentChoice(
            question: question,
            whatPolicySays: finding.whatPolicySays,
            unknownBoundary: defaultUnknown,
            consentReason:
                'This finding excerpt is too detailed for on-device AI processing.',
            redactedPreview: scrubbed.redactedText,
            processSteps: List<String>.unmodifiable(processSteps),
          );
        }

        _recordAndEmitStep(
          requestId: reqId,
          steps: processSteps,
          stage: 'checking_on_device',
          label: 'Reading cited clause on this phone',
          inferenceSource: 'ON_DEVICE',
        );
        final localRes = await _bridge.analyseText(
          requestId: reqId,
          task: 'explain_finding',
          text: compositeInput,
          cloudConsent: false,
          requestedMode: 'ONLY_ON_DEVICE',
          languageCode: languageCode,
        );
        final localAnswer =
            (localRes.structuredOutput?['answer'] as String?)?.trim();
        if (localRes.status == HybridStatus.success &&
            localRes.structuredOutput != null &&
            localAnswer != null &&
            localAnswer.isNotEmpty) {
          res = localRes;
        } else {
          _recordAndEmitStep(
            requestId: reqId,
            steps: processSteps,
            stage: 'on_device_unavailable',
            label: 'On-device AI unavailable — waiting for your choice',
          );
          final scrubbed = PiiRedactor.redact(compositeInput);
          return DeniExplanation.requiresConsentChoice(
            question: question,
            whatPolicySays: finding.whatPolicySays,
            unknownBoundary: defaultUnknown,
            consentReason: localRes.message ??
                'On-device AI could not answer from this device right now.',
            redactedPreview: scrubbed.redactedText,
            processSteps: List<String>.unmodifiable(processSteps),
          );
        }
      } else {
        final scrubbed = PiiRedactor.redact(compositeInput);
        _recordAndEmitStep(
          requestId: reqId,
          steps: processSteps,
          stage: 'redacting_pii',
          label: scrubbed.hadPersonalDetails
              ? 'Masked ${scrubbed.replacementCount} personal ${scrubbed.replacementCount == 1 ? 'detail' : 'details'} with placeholders'
              : 'Verified no personal details before sending',
        );
        _recordAndEmitStep(
          requestId: '${reqId}_appcheck',
          steps: processSteps,
          stage: 'sending_appcheck',
          label: 'Streaming explanation with App Check protection',
          inferenceSource: 'IN_CLOUD',
        );
        res = await _bridge.analyseText(
          requestId: '${reqId}_appcheck',
          task: 'explain_finding',
          text: scrubbed.redactedText,
          cloudConsent: true,
          requestedMode: 'ONLY_IN_CLOUD',
          languageCode: languageCode,
        );
      }

      if (res.status == HybridStatus.success && res.structuredOutput != null) {
        final thought = res.thoughtSummary ?? streamedThought;
        final signature = res.thoughtSignature ?? streamedSignature;
        if (thought != null) {
          processSteps.add('Streamed model thoughts');
        }
        if (signature != null) {
          processSteps.add('Verified thought signature');
        }
        _recordAndEmitStep(
          requestId: res.requestId.isNotEmpty ? res.requestId : reqId,
          steps: processSteps,
          stage: 'completed',
          label: 'Grounded answer verified against policy quote',
          thoughtSummary: thought,
          thoughtSignature: signature,
          inferenceSource: res.inferenceSource,
          isCompleted: true,
        );

        final out = res.structuredOutput!;
        final answer = (out['answer'] as String?)?.trim();
        if (answer != null && answer.isNotEmpty) {
          return DeniExplanation(
            question: question,
            answer: answer,
            whatPolicySays:
                (out['whatPolicySays'] as String?)?.trim() ??
                finding.whatPolicySays,
            unknownBoundary:
                (out['unknownBoundary'] as String?)?.trim() ?? defaultUnknown,
            inferenceSource: parseInferenceSource(res.inferenceSource),
            processSteps: List<String>.unmodifiable(processSteps),
            thoughtSummary: thought,
            thoughtSignature: signature,
          );
        }
      }

      return _buildDeterministicDeniExplanation(
        requestId: reqId,
        steps: processSteps,
        finding: finding,
        question: question,
        intentHint: intentHint,
        thoughtSummary: streamedThought,
        thoughtSignature: streamedSignature,
      );
    } finally {
      await sub.cancel();
    }
  }

  DeniExplanation _buildDeterministicDeniExplanation({
    required String requestId,
    required List<String> steps,
    required VerifiedFinding finding,
    required String question,
    String? intentHint,
    String? thoughtSummary,
    String? thoughtSignature,
  }) {
    _recordAndEmitStep(
      requestId: requestId,
      steps: steps,
      stage: 'offline_fallback',
      label: 'Answering directly from verified quote',
      inferenceSource: 'OFFLINE_DETERMINISTIC',
      isCompleted: true,
    );
    final qLower = question.toLowerCase();
    final isOptOutQuestion =
        intentHint == 'opt_out' ||
        qLower.contains('turn this off') ||
        qLower.contains('opt out');
    final isUnknownQuestion =
        intentHint == 'unknown' || qLower.contains('unknown');
    final String groundedAnswer;
    if (isOptOutQuestion) {
      groundedAnswer =
          'Look for a toggle in the app’s settings or Android App Permissions, '
          'and check whether a parent or school admin must request deletion. '
          'The quoted line does not show a one-tap opt-out.';
    } else if (isUnknownQuestion) {
      groundedAnswer = finding.unknowns.isNotEmpty
          ? finding.unknowns.first
          : 'This policy text does not prove how often data leaves the phone in practice.';
    } else {
      groundedAnswer = finding.explanation;
    }

    return DeniExplanation(
      question: question,
      answer: groundedAnswer,
      whatPolicySays: 'Policy quote: “${finding.exactExcerpt}”',
      unknownBoundary: finding.unknowns.isNotEmpty
          ? finding.unknowns.first
          : 'The policy text alone cannot show whether the app transmits this data right now.',
      inferenceSource: InferenceSource.offlineDeterministic,
      processSteps: List<String>.unmodifiable(steps),
      thoughtSummary: thoughtSummary,
      thoughtSignature: thoughtSignature,
    );
  }

  PolicyReviewReceipt _parseAndValidateBridgeOutput({
    required String subjectTitle,
    required String sourceLabel,
    required String snapshotText,
    String? redactedSnapshotText,
    required HybridAnalysisResult bridgeResult,
    List<String> processSteps = const [],
    String? thoughtSummary,
    String? thoughtSignature,
    String languageCode = 'en',
    PolicySourceSnapshot? sourceSnapshot,
  }) {
    final map = bridgeResult.structuredOutput ?? const <String, dynamic>{};
    final rawConcernsValue = map['concerns'];
    final rawConcerns = rawConcernsValue is List ? rawConcernsValue : const [];
    final rawSummary = (map['summary'] as String?)?.trim() ?? '';
    final rawState = (map['overall_state'] as String?)?.trim().toUpperCase() ?? '';
    final isRawTextFallback =
        map.containsKey('rawText') &&
        (rawState.isEmpty || rawConcernsValue is! List || rawSummary.isEmpty);
    final hasRecognizedState =
        rawState == 'REVIEW_RECOMMENDED' ||
        rawState == 'NO_CONCERN' ||
        rawState == 'INSUFFICIENT_EVIDENCE';
    final hasValidStructure =
        !isRawTextFallback &&
        hasRecognizedState &&
        rawConcernsValue is List &&
        rawSummary.isNotEmpty;

    final findings = <VerifiedFinding>[];

    for (var i = 0; i < rawConcerns.length; i++) {
      final item = rawConcerns[i];
      if (item is! Map) continue;
      final rawMap = item.cast<String, dynamic>();
      final quote =
          (rawMap['quote'] as String?) ??
          (rawMap['exact_excerpt'] as String?) ??
          '';

      var validated = EvidenceValidator.validateFinding(
        rawFinding: {...rawMap, 'exact_excerpt': quote},
        snapshotText: snapshotText,
        validEvidenceIds: {'finding_${i + 1}'},
      );
      var contextSourceText = snapshotText;
      if (validated['status'] != 'SOURCE_MATCHED' &&
          redactedSnapshotText != null) {
        final redactedValidation = EvidenceValidator.validateFinding(
          rawFinding: {...rawMap, 'exact_excerpt': quote},
          snapshotText: redactedSnapshotText,
          validEvidenceIds: {'finding_${i + 1}'},
        );
        if (redactedValidation['status'] == 'SOURCE_MATCHED') {
          validated = redactedValidation;
          contextSourceText = redactedSnapshotText;
        }
      }

      final isSourceMatched = validated['status'] == 'SOURCE_MATCHED';
      final contextWin = isSourceMatched
          ? EvidenceValidator.extractContextWindow(
              quote: quote,
              snapshotText: contextSourceText,
            )
          : null;

      final rawUnknowns =
          (validated['unknowns'] as List?)?.map((e) => e.toString()).toList() ??
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
          title:
              (rawMap['title'] as String?) ??
              _defaultTitleForCategory(categoryStr),
          category: _parseCategory(categoryStr),
          severity: _parseSeverity(severityStr),
          exactExcerpt: quote.isEmpty
              ? 'No verbatim quote supplied by model.'
              : EvidenceValidator.normalize(quote),
          explanation: (rawMap['explanation'] as String?) ?? 'This clause describes data handling that warrants parent or teacher review.',
          whatPolicySays: isSourceMatched
              ? 'Verbatim match confirmed in captured snapshot (${EvidenceValidator.normalize(quote).length} chars).'
              : 'Model cited a passage that could not be matched verbatim in the captured snapshot.',
          whatAndroidReports: 'Text-only policy review. Run "Check an app" to compare against live Android OS permissions.',
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
    final sufficiency = PolicySufficiencyValidator.assess(snapshotText);

    final ReviewOverallState overallState;
    final ReviewDiagnosticKind diagnosticKind;
    final String resolvedSummary;

    if (!sufficiency.isSufficient) {
      overallState = ReviewOverallState.insufficientEvidence;
      diagnosticKind = ReviewDiagnosticKind.insufficientPolicyMaterial;
      resolvedSummary = sufficiency.explanation;
    } else if (!hasValidStructure) {
      overallState = ReviewOverallState.insufficientEvidence;
      diagnosticKind = ReviewDiagnosticKind.failedModelInference;
      resolvedSummary =
          'Model inference returned incomplete or unparseable analysis output, so a reliable review could not be completed.';
    } else if (rawState == 'INSUFFICIENT_EVIDENCE') {
      overallState = ReviewOverallState.insufficientEvidence;
      diagnosticKind = ReviewDiagnosticKind.insufficientPolicyMaterial;
      resolvedSummary = rawSummary;
    } else if (hasVerifiedConcerns &&
        (rawState == 'REVIEW_RECOMMENDED' || findings.isNotEmpty)) {
      overallState = ReviewOverallState.reviewRecommended;
      diagnosticKind = ReviewDiagnosticKind.validated;
      resolvedSummary = rawSummary;
    } else if (rawState == 'NO_CONCERN' &&
        rawConcerns.isEmpty &&
        findings.isEmpty) {
      overallState = ReviewOverallState.noConcern;
      diagnosticKind = ReviewDiagnosticKind.validated;
      resolvedSummary = rawSummary;
    } else {
      overallState = ReviewOverallState.insufficientEvidence;
      diagnosticKind = ReviewDiagnosticKind.failedModelInference;
      resolvedSummary =
          'Model output could not be verified against exact quotes in this snapshot (${findings.length} unverified).';
    }

    final sourceChip = parseInferenceSource(bridgeResult.inferenceSource);

    return PolicyReviewReceipt(
      id: bridgeResult.requestId,
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      snapshotText: snapshotText,
      snapshotDigest: EvidenceValidator.computeSnapshotDigest(snapshotText),
      createdAt: DateTime.now(),
      overallState: overallState,
      inferenceSource: sourceChip,
      summary: resolvedSummary,
      // Security & trust integrity: never accept untrusted disclaimers from
      // model JSON output; always resolve localized calibrated non-certification copy.
      calibratedDisclaimer: _localizedDisclaimerFor(languageCode),
      findings: findings,
      processSteps: processSteps,
      thoughtSummary: thoughtSummary ?? bridgeResult.thoughtSummary,
      thoughtSignature: thoughtSignature ?? bridgeResult.thoughtSignature,
      diagnosticKind: diagnosticKind,
      sourceSnapshot: sourceSnapshot,
      languageCode: languageCode,
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
    List<String> processSteps = const [],
    String? thoughtSummary,
    String? thoughtSignature,
    String languageCode = 'en',
    ReviewDiagnosticKind? fallbackDiagnosticKind,
    String? failureDetail,
    PolicySourceSnapshot? sourceSnapshot,
  }) {
    final sufficiency = PolicySufficiencyValidator.assess(policyText);
    if (!sufficiency.isSufficient) {
      return PolicyReviewReceipt(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        subjectTitle: subjectTitle,
        sourceLabel: sourceLabel,
        snapshotText: policyText,
        snapshotDigest: EvidenceValidator.computeSnapshotDigest(policyText),
        createdAt: DateTime.now(),
        overallState: ReviewOverallState.insufficientEvidence,
        inferenceSource: source,
        summary: sufficiency.explanation,
        calibratedDisclaimer: _localizedDisclaimerFor(languageCode),
        findings: const [],
        processSteps: processSteps,
        thoughtSummary: thoughtSummary,
        thoughtSignature: thoughtSignature,
        diagnosticKind: ReviewDiagnosticKind.insufficientPolicyMaterial,
        sourceSnapshot: sourceSnapshot,
        languageCode: languageCode,
      );
    }

    final splitSentences = policyText
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.length >= 25)
        .toList();
    final sentences = splitSentences.isNotEmpty
        ? splitSentences
        : [policyText.trim()];

    final findings = <VerifiedFinding>[];
    int idx = 1;

    for (final sentence in sentences) {
      final lower = sentence.toLowerCase();

      // Skip explicit non-collection reassurance clauses
      final isNegatedReassurance =
          lower.contains('we do not collect') ||
          lower.contains('we never sell') ||
          lower.contains('stored exclusively on this device') ||
          lower.contains('do not integrate third-party advertising');
      if (isNegatedReassurance) continue;

      if (lower.contains('location') &&
          (lower.contains('gps') ||
              lower.contains('background') ||
              lower.contains('precise') ||
              lower.contains('share'))) {
        findings.add(
          _buildVerifiedLocalFinding(
            id: 'local_$idx',
            title: 'Tracks location even in the background',
            category: FindingCategory.tracking,
            severity: FindingSeverity.high,
            excerpt: sentence,
            explanation: 'The app can read your child’s exact GPS location even when it isn’t open on screen.',
            unknown: 'The policy text doesn’t show whether location permission is actually granted on this phone.',
            snapshotText: policyText,
          ),
        );
        idx++;
      } else if ((lower.contains('voice') ||
              lower.contains('microphone') ||
              lower.contains('biometric')) &&
          (lower.contains('retain') ||
              lower.contains('indefinitely') ||
              lower.contains('train') ||
              lower.contains('record'))) {
        findings.add(
          _buildVerifiedLocalFinding(
            id: 'local_$idx',
            title: 'Keeps child voice recordings to train AI',
            category: FindingCategory.retention,
            severity: FindingSeverity.high,
            excerpt: sentence,
            explanation: 'Your child’s voice recordings are kept indefinitely to train speech models unless a school admin requests deletion.',
            unknown: 'It doesn’t say if a parent can delete recordings directly without going through a school admin.',
            snapshotText: policyText,
          ),
        );
        idx++;
      } else if (lower.contains('advertising') ||
          lower.contains('third-party') ||
          lower.contains('behavioral promotions')) {
        findings.add(
          _buildVerifiedLocalFinding(
            id: 'local_$idx',
            title: 'Shares ad IDs with external partners',
            category: FindingCategory.sharing,
            severity: FindingSeverity.medium,
            excerpt: sentence,
            explanation: 'Ad partners can follow what your child taps in the app using a persistent advertising ID.',
            unknown: 'It doesn’t name the ad networks or confirm whether child-directed ad limits are turned on.',
            snapshotText: policyText,
          ),
        );
        idx++;
      } else if (lower.contains('disable core') ||
          lower.contains('revoking') && lower.contains('permissions')) {
        findings.add(
          _buildVerifiedLocalFinding(
            id: 'local_$idx',
            title: 'Features may break if permissions are off',
            category: FindingCategory.parentalConsent,
            severity: FindingSeverity.low,
            excerpt: sentence,
            explanation: 'Turning off mic or location access in Android Settings may lock some classroom or homework tools.',
            unknown: 'It doesn’t list which offline activities still work with permissions turned off.',
            snapshotText: policyText,
          ),
        );
        idx++;
      }
    }

    final ReviewOverallState overallState;
    final ReviewDiagnosticKind diagnosticKind;
    final String summaryText;

    if (findings.isNotEmpty) {
      overallState = ReviewOverallState.reviewRecommended;
      diagnosticKind =
          fallbackDiagnosticKind ?? ReviewDiagnosticKind.validated;
      summaryText = _defaultSummaryForState(overallState, findings.length);
    } else if (fallbackDiagnosticKind ==
        ReviewDiagnosticKind.failedModelInference) {
      overallState = ReviewOverallState.insufficientEvidence;
      diagnosticKind = ReviewDiagnosticKind.failedModelInference;
      final detail = (failureDetail ?? '').trim();
      summaryText =
          'Model inference failed${detail.isNotEmpty ? ' ($detail)' : ''}. '
          'A local keyword scan matched no common risk phrases, so a full review could not be completed.';
    } else if (fallbackDiagnosticKind ==
        ReviewDiagnosticKind.cloudUnavailableLocalFallback) {
      overallState = ReviewOverallState.insufficientEvidence;
      diagnosticKind = ReviewDiagnosticKind.cloudUnavailableLocalFallback;
      summaryText =
          'Cloud inference was unavailable. A deterministic local keyword scan matched no flagged clauses, but full semantic analysis did not run.';
    } else {
      overallState = ReviewOverallState.noConcern;
      diagnosticKind = ReviewDiagnosticKind.validated;
      summaryText = _defaultSummaryForState(overallState, findings.length);
    }

    return PolicyReviewReceipt(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      snapshotText: policyText,
      snapshotDigest: EvidenceValidator.computeSnapshotDigest(policyText),
      createdAt: DateTime.now(),
      overallState: overallState,
      inferenceSource: source,
      summary: summaryText,
      calibratedDisclaimer: _localizedDisclaimerFor(languageCode),
      findings: findings,
      processSteps: processSteps,
      thoughtSummary: thoughtSummary,
      thoughtSignature: thoughtSignature,
      diagnosticKind: diagnosticKind,
      sourceSnapshot: sourceSnapshot,
      languageCode: languageCode,
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
      rawFinding: {'id': id, 'exact_excerpt': excerpt},
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
          'Exact match found in this policy (${EvidenceValidator.normalize(excerpt).length} chars).',
      whatAndroidReports: 'Text-only check. Pick this app under Check an app to see what Android actually allows.',
      unknowns: [unknown],
      status: isMatched
          ? EvidenceStatus.sourceMatched
          : EvidenceStatus.unverified,
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
    ReviewDiagnosticKind diagnosticKind =
        ReviewDiagnosticKind.insufficientPolicyMaterial,
    String languageCode = 'en',
    PolicySourceSnapshot? sourceSnapshot,
  }) {
    return PolicyReviewReceipt(
      id: 'insuf_${DateTime.now().millisecondsSinceEpoch}',
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      snapshotText: snapshotText,
      snapshotDigest: EvidenceValidator.computeSnapshotDigest(snapshotText),
      createdAt: DateTime.now(),
      overallState: ReviewOverallState.insufficientEvidence,
      inferenceSource: InferenceSource.unknown,
      summary: reason,
      calibratedDisclaimer: _localizedDisclaimerFor(languageCode),
      findings: const [],
      diagnosticKind: diagnosticKind,
      sourceSnapshot: sourceSnapshot,
      languageCode: languageCode,
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
        '$findingCount ${findingCount == 1 ? 'part of this policy needs' : 'parts of this policy need'} a closer look before a child uses this app.',
      ReviewOverallState.noConcern => 'No data sharing, tracking, or long-term retention clauses stood out in the text we reviewed.',
      ReviewOverallState.insufficientEvidence => 'There wasn’t enough clear policy text here to verify what the app collects.',
    };
  }
}
