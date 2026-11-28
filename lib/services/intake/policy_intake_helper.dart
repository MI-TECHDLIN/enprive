import '../../domain/evidence/evidence_validator.dart';
import '../../domain/review/review_coordinator.dart';
import '../../domain/review/review_models.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/enprive_languages.dart';
import '../platform/hybrid_ai_bridge.dart';

/// Constructs honest local [PolicySourceSnapshot] records for local document
/// intake and text snapshots on behalf of [PolicyIntakeCoordinator].
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
      'empty' || 'empty_share' => DocumentExtractionStatus.empty,
      'invalid_share' => DocumentExtractionStatus.readError,
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
      retrievalStatus: PolicyRetrievalStatus.localProvided,
      appIdentityMatchStatus: hasAppPermissions
          ? AppIdentityMatchStatus.unverifiedUserSupplied
          : AppIdentityMatchStatus.notApplicable,
      sourceSha256Hash: text.trim().isEmpty
          ? ''
          : EvidenceValidator.computeSha256SourceHash(text),
      limitationNote: customLimitation,
    );
  }
}
