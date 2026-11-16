import '../../domain/evidence/evidence_validator.dart';
import '../../domain/permissions/permission_comparator.dart';
import '../../domain/review/review_coordinator.dart';
import '../../domain/review/review_models.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/enprive_languages.dart';
import '../../widgets/enprive_provenance_chip.dart';
import '../network/policy_url_retriever.dart';
import '../platform/hybrid_ai_bridge.dart';

/// Constructs honest local [PolicySourceSnapshot] records and fail-closed
/// [PolicyReviewReceipt]s for URL retrieval, local document intake, and
/// Android share/selection entry points.
abstract final class PolicyIntakeHelper {
  static String localizedNonCertificationDisclaimer(String languageCode) {
    final normalized = enpriveLanguageByCode(languageCode);
    if (normalized.code == 'en') {
      return ReviewCoordinator.calibratedDefaultDisclaimer;
    }
    return lookupAppLocalizations(normalized.locale).stateNoConcernSubtitle;
  }

  static DocumentExtractionStatus mapDocumentStatus(String raw) {
    return switch (raw) {
      'ok' => DocumentExtractionStatus.extracted,
      'unsupported_mime' => DocumentExtractionStatus.unsupportedMime,
      'too_large' => DocumentExtractionStatus.tooLarge,
      'empty' => DocumentExtractionStatus.empty,
      'corrupt' => DocumentExtractionStatus.corrupt,
      'password_protected' => DocumentExtractionStatus.passwordProtected,
      'permission_denied' => DocumentExtractionStatus.permissionDenied,
      'cancelled' => DocumentExtractionStatus.cancelled,
      _ => DocumentExtractionStatus.readError,
    };
  }

  static PolicySourceType sourceTypeForDocument(String? docType, {String? mime}) {
    final cleanDoc = docType?.toLowerCase();
    final cleanMime = mime?.split(';').first.trim().toLowerCase();
    if (cleanDoc == 'pdf' || cleanMime == 'application/pdf') {
      return PolicySourceType.pdf;
    }
    if (cleanDoc == 'docx' ||
        cleanMime ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return PolicySourceType.docx;
    }
    return PolicySourceType.textDocument;
  }

  static PolicySourceSnapshot snapshotFromDocumentSuccess(
    DocumentExtractionOutcome doc, {
    bool hasAppPermissions = false,
  }) {
    final type = sourceTypeForDocument(doc.documentType, mime: doc.mimeType);
    final label = switch (type) {
      PolicySourceType.pdf => 'PDF',
      PolicySourceType.docx => 'DOCX',
      _ => 'TXT',
    };
    final nowUtc = DateTime.now().toUtc();
    return PolicySourceSnapshot(
      snapshotId: 'doc_${nowUtc.millisecondsSinceEpoch}',
      sourceType: type,
      retrievedAt: nowUtc,
      retrievalStatus: PolicyRetrievalStatus.localProvided,
      appIdentityMatchStatus: hasAppPermissions
          ? AppIdentityMatchStatus.unverifiedUserSupplied
          : AppIdentityMatchStatus.notApplicable,
      sourceSha256Hash: EvidenceValidator.computeSha256SourceHash(
        doc.extractedText,
      ),
      originalFilename: doc.fileName,
      mimeType: doc.mimeType,
      byteLength: doc.byteLength,
      extractionStatus: DocumentExtractionStatus.extracted,
      limitationNote:
          'Extracted locally from user-supplied $label document'
          '${doc.fileName != null ? ' (${doc.fileName})' : ''}'
          '${doc.pageCount != null ? ' · ${doc.pageCount} page${doc.pageCount == 1 ? '' : 's'}' : ''}. '
          'Binary document bytes remained strictly on this phone.',
    );
  }

  static PolicySourceSnapshot snapshotForManualOrSharedText({
    required PolicySourceType sourceType,
    required String text,
    bool hasAppPermissions = false,
    String? customLimitation,
  }) {
    final nowUtc = DateTime.now().toUtc();
    return PolicySourceSnapshot(
      snapshotId: 'txt_${nowUtc.millisecondsSinceEpoch}',
      sourceType: sourceType,
      retrievedAt: nowUtc,
      retrievalStatus: sourceType == PolicySourceType.sample
          ? PolicyRetrievalStatus.localProvided
          : PolicyRetrievalStatus.localProvided,
      appIdentityMatchStatus: sourceType == PolicySourceType.sample
          ? AppIdentityMatchStatus.sampleFixture
          : (hasAppPermissions
                ? AppIdentityMatchStatus.unverifiedUserSupplied
                : AppIdentityMatchStatus.notApplicable),
      sourceSha256Hash: text.trim().isEmpty
          ? ''
          : EvidenceValidator.computeSha256SourceHash(text),
      limitationNote: customLimitation,
    );
  }

  /// Creates an [ReviewOverallState.insufficientEvidence] receipt when URL
  /// retrieval fails, blocks an unsafe target, or returns unusable HTML.
  static PolicyReviewReceipt buildUrlFailureReceipt({
    required String subjectTitle,
    required PolicyUrlRetrievalResult retrieval,
    String languageCode = 'en',
    AppPermissionSnapshot? appPermissions,
  }) {
    final snapshot = retrieval.sourceSnapshot;
    final extracted = (retrieval.extractedText ?? '').trim();
    final now = DateTime.now();
    final permReport = appPermissions == null
        ? null
        : PermissionComparator.compare(
            snapshot: appPermissions,
            policyText: extracted,
          );
    final enrichedFindings = permReport == null
        ? const <VerifiedFinding>[]
        : PermissionComparator.enrichFindingsWithDeviceReport(
            policyFindings: const [],
            report: permReport,
          );

    final fallbackPrompt =
        '${retrieval.userMessage} Paste the privacy policy text manually or import a local PDF, TXT, or DOCX document instead.';
    final permNote = permReport != null && permReport.mismatchCount > 0
        ? ' (${permReport.mismatchCount} undisclosed Android permission ${permReport.mismatchCount == 1 ? 'request' : 'requests'} also observed on device.)'
        : '';

    return PolicyReviewReceipt(
      id: 'urlfail_${now.millisecondsSinceEpoch}',
      subjectTitle: subjectTitle.trim().isNotEmpty
          ? subjectTitle.trim()
          : PolicyUrlRetriever.deriveSubjectTitle(
              retrieval.canonicalUrl ?? retrieval.requestedUrl,
            ),
      sourceLabel: retrieval.canonicalUrl ?? retrieval.requestedUrl,
      snapshotText: extracted,
      snapshotDigest: extracted.isEmpty
          ? ''
          : EvidenceValidator.computeSnapshotDigest(extracted),
      createdAt: now,
      overallState: ReviewOverallState.insufficientEvidence,
      inferenceSource: InferenceSource.unknown,
      summary: '$fallbackPrompt$permNote',
      calibratedDisclaimer: localizedNonCertificationDisclaimer(languageCode),
      findings: enrichedFindings,
      permissionReport: permReport,
      processSteps: [
        'Attempted public HTTP(S) retrieval: ${retrieval.requestedUrl}',
        if (retrieval.redirectChain.length > 1)
          'Followed ${retrieval.redirectChain.length - 1} redirect(s) safely',
        'Retrieval ended with status: ${retrieval.status.name}',
        if (permReport != null)
          'Preserved on-device Android permission comparison',
      ],
      diagnosticKind: ReviewDiagnosticKind.insufficientPolicyMaterial,
      sourceSnapshot: snapshot,
      languageCode: languageCode,
    );
  }

  /// Creates an [ReviewOverallState.insufficientEvidence] receipt when local
  /// document intake fails or yields unreadable/empty content.
  static PolicyReviewReceipt buildDocumentFailureReceipt({
    required String subjectTitle,
    required DocumentExtractionOutcome doc,
    String languageCode = 'en',
    AppPermissionSnapshot? appPermissions,
  }) {
    final now = DateTime.now();
    final nowUtc = now.toUtc();
    final docStatus = mapDocumentStatus(doc.status);
    final sourceType = sourceTypeForDocument(doc.documentType, mime: doc.mimeType);
    final fallbackPrompt = doc.userMessage.trim().isNotEmpty
        ? '${doc.userMessage.trim()} Try another supported PDF, TXT, or DOCX file or paste the privacy policy text manually.'
        : 'Could not extract readable privacy policy text from this document. Paste the privacy policy text manually instead.';

    final permReport = appPermissions == null
        ? null
        : PermissionComparator.compare(snapshot: appPermissions, policyText: '');
    final enrichedFindings = permReport == null
        ? const <VerifiedFinding>[]
        : PermissionComparator.enrichFindingsWithDeviceReport(
            policyFindings: const [],
            report: permReport,
          );

    final snapshot = PolicySourceSnapshot(
      snapshotId: 'docfail_${nowUtc.millisecondsSinceEpoch}',
      sourceType: sourceType,
      retrievedAt: nowUtc,
      retrievalStatus: PolicyRetrievalStatus.localProvided,
      appIdentityMatchStatus: appPermissions != null
          ? AppIdentityMatchStatus.unverifiedUserSupplied
          : AppIdentityMatchStatus.notApplicable,
      sourceSha256Hash: '',
      originalFilename: doc.fileName,
      mimeType: doc.mimeType,
      byteLength: doc.byteLength,
      extractionStatus: docStatus,
      limitationNote: fallbackPrompt,
    );

    return PolicyReviewReceipt(
      id: 'docfail_${now.millisecondsSinceEpoch}',
      subjectTitle: subjectTitle.trim().isNotEmpty
          ? subjectTitle.trim()
          : (doc.fileName ?? 'Document Intake'),
      sourceLabel: doc.fileName != null
          ? 'Document · ${doc.fileName}'
          : 'Document Intake',
      snapshotText: '',
      snapshotDigest: '',
      createdAt: now,
      overallState: ReviewOverallState.insufficientEvidence,
      inferenceSource: InferenceSource.unknown,
      summary: fallbackPrompt,
      calibratedDisclaimer: localizedNonCertificationDisclaimer(languageCode),
      findings: enrichedFindings,
      permissionReport: permReport,
      processSteps: [
        'Inspected local document metadata (${doc.mimeType ?? "unknown MIME"})',
        'Extraction stopped cleanly with status: ${docStatus.name}',
      ],
      diagnosticKind: ReviewDiagnosticKind.insufficientPolicyMaterial,
      sourceSnapshot: snapshot,
      languageCode: languageCode,
    );
  }
}
