import '../../domain/evidence/evidence_validator.dart';
import '../../domain/intake/policy_intake_models.dart';
import '../../domain/review/app_policy_association.dart';
import '../../domain/review/policy_sufficiency.dart';
import '../../domain/review/review_models.dart';
import '../network/policy_url_retriever.dart';
import '../platform/hybrid_ai_bridge.dart';
import 'policy_intake_helper.dart';

/// Minimal platform boundary required by [PolicyIntakeCoordinator] for local
/// document picking and on-device package permission inspection.
///
/// Unit tests inject a pure-Dart fake implementing this interface so tests run
/// deterministically without live Android method channels.
abstract interface class PolicyDocumentPlatformBridge {
  Future<DocumentExtractionOutcome> pickAndExtractDocument();

  Future<AppPermissionSnapshot?> inspectAppSnapshot(String packageName);
}

/// Default production adapter backed by [HybridAiBridge].
final class HybridAiDocumentPlatformBridge
    implements PolicyDocumentPlatformBridge {
  final HybridAiBridge _bridge;

  const HybridAiDocumentPlatformBridge(this._bridge);

  @override
  Future<DocumentExtractionOutcome> pickAndExtractDocument() =>
      _bridge.pickAndExtractDocument();

  @override
  Future<AppPermissionSnapshot?> inspectAppSnapshot(String packageName) =>
      _bridge.inspectAppSnapshot(packageName);
}

/// Shared, UI-independent policy acquisition, validation, provenance, and
/// D5.3-B app-association coordinator.
///
/// Boundaries:
/// - Delegates URL validation & fetching solely to [PolicyUrlRetriever].
/// - Delegates document picking to [PolicyDocumentPlatformBridge].
/// - Delegates sufficiency checks solely to [PolicySufficiencyValidator].
/// - Delegates snapshot construction solely to [PolicyIntakeHelper].
/// - Delegates identity association solely to [AppPolicyAssociationEvaluator].
/// - Never invokes AI inference, cloud consent prompts, UI widgets, or SQLite.
class PolicyIntakeCoordinator {
  final PolicyUrlRetriever _urlRetriever;
  final PolicyDocumentPlatformBridge? _documentBridge;
  final DateTime Function() _clock;

  PolicyIntakeCoordinator({
    PolicyUrlRetriever? urlRetriever,
    PolicyDocumentPlatformBridge? documentBridge,
    HybridAiBridge? hybridBridge,
    DateTime Function()? clock,
  }) : _urlRetriever = urlRetriever ?? PolicyUrlRetriever(),
       _documentBridge =
           documentBridge ??
           (hybridBridge != null
               ? HybridAiDocumentPlatformBridge(hybridBridge)
               : null),
       _clock = clock ?? DateTime.now;

  static String sourceLabelForTextType(PolicySourceType sourceType) {
    return switch (sourceType) {
      PolicySourceType.sharedText => 'Shared text',
      PolicySourceType.selectedText => 'Selected text',
      _ => 'Pasted policy text',
    };
  }

  /// Acquires and validates manually pasted policy text.
  PolicyIntakeOutcome capturePastedText({
    required String rawText,
    String? userSubjectTitle,
    SelectedAppReference? selectedApp,
    String? defaultSubjectTitle,
  }) {
    return captureText(
      locator: TextPolicyLocator(
        rawText: rawText,
        sourceType: PolicySourceType.pastedText,
        userSubjectTitle: userSubjectTitle,
      ),
      selectedApp: selectedApp,
      defaultSubjectTitle: defaultSubjectTitle,
    );
  }

  /// Acquires and validates plain text received via Android `ACTION_SEND`.
  PolicyIntakeOutcome captureSharedText({
    required String rawText,
    String? userSubjectTitle,
    SelectedAppReference? selectedApp,
    String? defaultSubjectTitle,
  }) {
    return captureText(
      locator: TextPolicyLocator(
        rawText: rawText,
        sourceType: PolicySourceType.sharedText,
        userSubjectTitle: userSubjectTitle,
        sourceAction: 'ACTION_SEND',
      ),
      selectedApp: selectedApp,
      defaultSubjectTitle: defaultSubjectTitle,
    );
  }

  /// Acquires and validates selected text received via `ACTION_PROCESS_TEXT`.
  PolicyIntakeOutcome captureSelectedText({
    required String rawText,
    String? userSubjectTitle,
    SelectedAppReference? selectedApp,
    String? defaultSubjectTitle,
  }) {
    return captureText(
      locator: TextPolicyLocator(
        rawText: rawText,
        sourceType: PolicySourceType.selectedText,
        userSubjectTitle: userSubjectTitle,
        sourceAction: 'ACTION_PROCESS_TEXT',
      ),
      selectedApp: selectedApp,
      defaultSubjectTitle: defaultSubjectTitle,
    );
  }

  /// Validates and captures pasted, shared, or selected policy text.
  PolicyIntakeOutcome captureText({
    required TextPolicyLocator locator,
    SelectedAppReference? selectedApp,
    String? defaultSubjectTitle,
  }) {
    final trimmed = locator.rawText.trim();
    final sufficiency = PolicySufficiencyValidator.assess(trimmed);
    if (!sufficiency.isSufficient) {
      final isEmpty = sufficiency.reason == PolicyInsufficiencyReason.empty;
      return PolicyIntakeFailure(
        kind: isEmpty
            ? PolicyIntakeFailureKind.emptyInput
            : PolicyIntakeFailureKind.insufficientPolicy,
        locator: locator,
        selectedApp: selectedApp,
        userMessage: sufficiency.explanation,
        recoveryHint: isEmpty
            ? 'Paste privacy policy paragraphs, enter a public https:// link, or choose a PDF, TXT, or DOCX document.'
            : 'Paste full privacy policy disclosures instead of a short stub or placeholder, or import a local policy document.',
        canRetrySameLocator: true,
        sufficiencyResult: sufficiency,
      );
    }

    final snapshot = PolicyIntakeHelper.snapshotForManualOrSharedText(
      sourceType: locator.sourceType,
      text: trimmed,
      hasAppPermissions: selectedApp != null,
    );
    final subjectTitle = _resolveTextSubjectTitle(
      userSubjectTitle: locator.userSubjectTitle,
      selectedApp: selectedApp,
      defaultSubjectTitle: defaultSubjectTitle,
      sourceType: locator.sourceType,
    );
    final captured = CapturedPolicySnapshot(
      normalizedPolicyText: trimmed,
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabelForTextType(locator.sourceType),
      sourceSnapshot: snapshot,
      sufficiency: sufficiency,
    );

    final association = _evaluateAssociation(
      selectedApp: selectedApp,
      policyText: trimmed,
      policyUrl: null,
      trustedSampleFixture: null,
    );

    return PolicyIntakeSuccess(
      locator: locator,
      capturedSnapshot: captured,
      selectedApp: selectedApp,
      associationReport: association,
    );
  }

  /// Fetches and validates a public HTTP(S) privacy policy URL via
  /// [PolicyUrlRetriever], supporting cooperative cancellation.
  Future<PolicyIntakeOutcome> captureFromUrl({
    required UrlPolicyLocator locator,
    SelectedAppReference? selectedApp,
    PolicyUrlCancellationToken? cancelToken,
  }) async {
    final retrieval = await _urlRetriever.fetchPolicy(
      locator.rawUrl,
      cancelToken: cancelToken,
      hasSelectedApp: selectedApp != null,
    );

    if (cancelToken?.isCancelled == true ||
        retrieval.status == PolicyRetrievalStatus.cancelled) {
      return PolicyIntakeFailure(
        kind: PolicyIntakeFailureKind.cancelled,
        locator: locator,
        selectedApp: selectedApp,
        userMessage: 'Privacy policy link retrieval was cancelled.',
        recoveryHint: 'Retry the link or switch to Paste text or Document.',
        canRetrySameLocator: true,
        failedSourceSnapshot: retrieval.sourceSnapshot,
        urlRetrievalResult: retrieval,
      );
    }

    if (!retrieval.isUsablePolicy ||
        retrieval.sourceSnapshot == null ||
        retrieval.extractedText == null ||
        retrieval.extractedText!.trim().isEmpty) {
      final failureKind = _mapUrlFailureKind(retrieval.status);
      return PolicyIntakeFailure(
        kind: failureKind,
        locator: locator,
        selectedApp: selectedApp,
        userMessage: retrieval.userMessage,
        recoveryHint: _urlRecoveryHint(failureKind),
        canRetrySameLocator: _canRetryUrlFailure(failureKind),
        failedSourceSnapshot: retrieval.sourceSnapshot,
        urlRetrievalResult: retrieval,
        sufficiencyResult: retrieval.sufficiencyResult,
      );
    }

    final trimmed = retrieval.extractedText!.trim();
    final sufficiency =
        retrieval.sufficiencyResult ??
        PolicySufficiencyValidator.assess(trimmed);
    if (!sufficiency.isSufficient) {
      return PolicyIntakeFailure(
        kind: PolicyIntakeFailureKind.insufficientPolicy,
        locator: locator,
        selectedApp: selectedApp,
        userMessage: sufficiency.explanation,
        recoveryHint: 'Paste the privacy policy text directly or import a saved PDF, TXT, or DOCX file instead.',
        canRetrySameLocator: true,
        failedSourceSnapshot: retrieval.sourceSnapshot,
        urlRetrievalResult: retrieval,
        sufficiencyResult: sufficiency,
      );
    }

    final canonicalOrRequested =
        retrieval.canonicalUrl ?? retrieval.requestedUrl;
    final cleanUserTitle = locator.userSubjectTitle?.trim();
    final subjectTitle = (cleanUserTitle != null && cleanUserTitle.isNotEmpty)
        ? cleanUserTitle
        : PolicyUrlRetriever.deriveSubjectTitle(canonicalOrRequested);

    final captured = CapturedPolicySnapshot(
      normalizedPolicyText: trimmed,
      subjectTitle: subjectTitle,
      sourceLabel: canonicalOrRequested,
      sourceSnapshot: retrieval.sourceSnapshot!,
      sufficiency: sufficiency,
    );

    final association = _evaluateAssociation(
      selectedApp: selectedApp,
      policyText: trimmed,
      policyUrl: canonicalOrRequested,
      trustedSampleFixture: null,
    );

    return PolicyIntakeSuccess(
      locator: locator,
      capturedSnapshot: captured,
      selectedApp: selectedApp,
      associationReport: association,
    );
  }

  /// Launches the native Android document picker via
  /// [PolicyDocumentPlatformBridge] and validates the extracted text locally.
  Future<PolicyIntakeOutcome> captureFromDocumentPicker({
    SelectedAppReference? selectedApp,
    String? userSubjectTitle,
  }) async {
    final bridge = _documentBridge;
    if (bridge == null) {
      return PolicyIntakeFailure(
        kind: PolicyIntakeFailureKind.documentReadError,
        locator: DocumentPolicyLocator(
          userSubjectTitle: userSubjectTitle,
          sourceAction: 'ACTION_OPEN_DOCUMENT',
          isPreExtractedIncomingShare: false,
        ),
        selectedApp: selectedApp,
        userMessage:
            'Document picker is not available in the current environment.',
        recoveryHint: 'Paste the privacy policy text manually or enter a public https:// policy link.',
        canRetrySameLocator: false,
      );
    }

    final outcome = await bridge.pickAndExtractDocument();
    return _processDocumentOutcome(
      outcome: outcome,
      selectedApp: selectedApp,
      userSubjectTitle: userSubjectTitle,
      sourceAction: 'ACTION_OPEN_DOCUMENT',
      isPreExtractedIncomingShare: false,
    );
  }

  /// Validates and captures an already-extracted Android incoming document share.
  PolicyIntakeOutcome captureIncomingDocument({
    required DocumentExtractionOutcome outcome,
    SelectedAppReference? selectedApp,
    String? userSubjectTitle,
    String sourceAction = 'ACTION_SEND',
  }) {
    return _processDocumentOutcome(
      outcome: outcome,
      selectedApp: selectedApp,
      userSubjectTitle: userSubjectTitle,
      sourceAction: sourceAction,
      isPreExtractedIncomingShare: true,
    );
  }

  /// Captures an explicit built-in Enprive sample fixture with
  /// [AppPolicyAssociationState.sampleFixture] provenance.
  PolicyIntakeOutcome captureSampleFixture({
    required SampleFixturePolicyLocator locator,
    AppPermissionSnapshot? permissionSnapshot,
    bool isLocked = true,
    String sourceLabel = 'Synthetic example',
  }) {
    final sampleApp = SelectedAppReference.forTrustedSample(
      locator.fixture,
      permissionSnapshot: permissionSnapshot,
      isLocked: isLocked,
    );
    final trimmed = locator.policyText.trim();
    final sufficiency = PolicySufficiencyValidator.assess(trimmed);
    if (!sufficiency.isSufficient) {
      final isEmpty = sufficiency.reason == PolicyInsufficiencyReason.empty;
      return PolicyIntakeFailure(
        kind: isEmpty
            ? PolicyIntakeFailureKind.emptyInput
            : PolicyIntakeFailureKind.insufficientPolicy,
        locator: locator,
        selectedApp: sampleApp,
        userMessage: sufficiency.explanation,
        recoveryHint: 'Select another sample check or paste policy text.',
        canRetrySameLocator: false,
        sufficiencyResult: sufficiency,
      );
    }

    final snapshot = PolicyIntakeHelper.snapshotForManualOrSharedText(
      sourceType: PolicySourceType.sample,
      text: trimmed,
      hasAppPermissions: true,
    );
    final captured = CapturedPolicySnapshot(
      normalizedPolicyText: trimmed,
      subjectTitle: locator.fixture.appName,
      sourceLabel: sourceLabel,
      sourceSnapshot: snapshot,
      sufficiency: sufficiency,
    );

    final association = _evaluateAssociation(
      selectedApp: sampleApp,
      policyText: trimmed,
      policyUrl: null,
      trustedSampleFixture: locator.fixture,
    );

    return PolicyIntakeSuccess(
      locator: locator,
      capturedSnapshot: captured,
      selectedApp: sampleApp,
      associationReport: association,
    );
  }

  /// Routes a structured Android share (`ACTION_SEND`) or text selection
  /// (`ACTION_PROCESS_TEXT`) payload through the shared intake pipeline.
  Future<PolicyIntakeOutcome> captureIncomingPayload({
    required IncomingIntentPayload payload,
    SelectedAppReference? selectedApp,
    PolicyUrlCancellationToken? cancelToken,
  }) async {
    if (payload.kind == 'document') {
      final doc = payload.document;
      if (doc == null) {
        return PolicyIntakeFailure(
          kind: PolicyIntakeFailureKind.documentReadError,
          locator: DocumentPolicyLocator(
            userSubjectTitle: payload.subject,
            sourceAction: payload.sourceAction,
            isPreExtractedIncomingShare: true,
          ),
          selectedApp: selectedApp,
          userMessage: 'No readable document data was received from Android.',
          recoveryHint: 'Choose a local PDF, TXT, or DOCX file inside Enprive or paste the privacy policy text manually.',
          canRetrySameLocator: false,
        );
      }
      return captureIncomingDocument(
        outcome: doc,
        selectedApp: selectedApp,
        userSubjectTitle: payload.subject,
        sourceAction: payload.sourceAction,
      );
    }

    final rawText = payload.text ?? '';
    final sharedUrl = PolicyUrlRetriever.extractSharedUrl(rawText);
    if (sharedUrl != null) {
      return captureFromUrl(
        locator: UrlPolicyLocator(
          rawUrl: sharedUrl,
          userSubjectTitle: payload.subject,
          sourceAction: payload.sourceAction,
        ),
        selectedApp: selectedApp,
        cancelToken: cancelToken,
      );
    }

    final sourceType = payload.sourceAction == 'ACTION_SEND'
        ? PolicySourceType.sharedText
        : PolicySourceType.selectedText;
    return captureText(
      locator: TextPolicyLocator(
        rawText: rawText,
        sourceType: sourceType,
        userSubjectTitle: payload.subject,
        sourceAction: payload.sourceAction,
      ),
      selectedApp: selectedApp,
    );
  }

  /// Hydrates on-device Android permissions for [app] without leaving the phone.
  Future<SelectedAppReference> hydrateAppPermissions(
    SelectedAppReference app,
  ) async {
    if (app.permissionSnapshot != null) return app;
    final bridge = _documentBridge;
    if (bridge == null) return app;
    final snapshot = await bridge.inspectAppSnapshot(app.packageName);
    if (snapshot == null) return app;
    return app.withPermissionSnapshot(snapshot);
  }

  PolicyIntakeOutcome _processDocumentOutcome({
    required DocumentExtractionOutcome outcome,
    required SelectedAppReference? selectedApp,
    required String? userSubjectTitle,
    required String sourceAction,
    required bool isPreExtractedIncomingShare,
  }) {
    final locator = DocumentPolicyLocator(
      userSubjectTitle: userSubjectTitle,
      fileName: outcome.fileName,
      mimeType: outcome.mimeType,
      byteLength: outcome.byteLength,
      documentType: outcome.documentType,
      sourceAction: sourceAction,
      isPreExtractedIncomingShare: isPreExtractedIncomingShare,
    );

    if (outcome.isCancelled) {
      return PolicyIntakeFailure(
        kind: PolicyIntakeFailureKind.cancelled,
        locator: locator,
        selectedApp: selectedApp,
        userMessage: outcome.userMessage.trim().isNotEmpty
            ? outcome.userMessage.trim()
            : 'No document was selected.',
        recoveryHint: 'Choose a PDF, TXT, or DOCX document, or switch to Paste text or Public URL.',
        canRetrySameLocator: !isPreExtractedIncomingShare,
        documentOutcome: outcome,
      );
    }

    if (!outcome.isSuccess) {
      final isBlankExtractedOk =
          outcome.status == 'ok' && outcome.extractedText.trim().isEmpty;
      final mappedStatus = isBlankExtractedOk
          ? DocumentExtractionStatus.empty
          : PolicyIntakeHelper.mapDocumentStatus(outcome.status);
      final failureKind = _mapDocumentFailureKind(mappedStatus);
      final userMessage = outcome.userMessage.trim().isNotEmpty
          ? outcome.userMessage.trim()
          : (isBlankExtractedOk
                ? 'No readable privacy policy text could be extracted from this document.'
                : 'Could not extract readable privacy policy text from this document.');
      final recoveryHint = isPreExtractedIncomingShare
          ? 'Open the document picker inside Enprive to select a readable PDF, TXT, or DOCX file, or paste the policy text manually.'
          : 'Choose another supported PDF, TXT, or DOCX file, or paste the privacy policy text manually.';

      final nowUtc = _clock().toUtc();
      final failedSnapshot = PolicySourceSnapshot(
        snapshotId: 'docfail_${nowUtc.millisecondsSinceEpoch}',
        sourceType: locator.sourceType,
        retrievedAt: nowUtc,
        retrievalStatus: PolicyRetrievalStatus.localProvided,
        appIdentityMatchStatus: selectedApp != null
            ? AppIdentityMatchStatus.unverifiedUserSupplied
            : AppIdentityMatchStatus.notApplicable,
        sourceSha256Hash: '',
        originalFilename: outcome.fileName,
        mimeType: outcome.mimeType,
        byteLength: outcome.byteLength,
        extractionStatus: mappedStatus,
        limitationNote: '$userMessage $recoveryHint',
      );

      return PolicyIntakeFailure(
        kind: failureKind,
        locator: locator,
        selectedApp: selectedApp,
        userMessage: userMessage,
        recoveryHint: recoveryHint,
        canRetrySameLocator: !isPreExtractedIncomingShare,
        failedSourceSnapshot: failedSnapshot,
        documentOutcome: outcome,
      );
    }

    final trimmed = outcome.extractedText.trim();
    final sufficiency = PolicySufficiencyValidator.assess(trimmed);
    if (!sufficiency.isSufficient) {
      final nowUtc = _clock().toUtc();
      final insufficientSnapshot = PolicySourceSnapshot(
        snapshotId: 'doc_${nowUtc.millisecondsSinceEpoch}',
        sourceType: locator.sourceType,
        retrievedAt: nowUtc,
        retrievalStatus: PolicyRetrievalStatus.insufficientPolicy,
        appIdentityMatchStatus: selectedApp != null
            ? AppIdentityMatchStatus.unverifiedUserSupplied
            : AppIdentityMatchStatus.notApplicable,
        sourceSha256Hash: EvidenceValidator.computeSha256SourceHash(trimmed),
        originalFilename: outcome.fileName,
        mimeType: outcome.mimeType,
        byteLength: outcome.byteLength,
        extractionStatus: DocumentExtractionStatus.extracted,
        limitationNote: sufficiency.explanation,
      );
      return PolicyIntakeFailure(
        kind: PolicyIntakeFailureKind.insufficientPolicy,
        locator: locator,
        selectedApp: selectedApp,
        userMessage: sufficiency.explanation,
        recoveryHint: isPreExtractedIncomingShare
            ? 'Select another PDF, TXT, or DOCX file inside Enprive, or paste the privacy policy text manually.'
            : 'Choose another readable PDF, TXT, or DOCX file, or paste the privacy policy text manually.',
        canRetrySameLocator: !isPreExtractedIncomingShare,
        failedSourceSnapshot: insufficientSnapshot,
        documentOutcome: outcome,
        sufficiencyResult: sufficiency,
      );
    }

    final sourceSnapshot = PolicyIntakeHelper.snapshotFromDocumentSuccess(
      outcome,
      hasAppPermissions: selectedApp != null,
    );
    final cleanUserTitle = userSubjectTitle?.trim();
    final cleanFileName = outcome.fileName?.trim();
    final subjectTitle = (cleanUserTitle != null && cleanUserTitle.isNotEmpty)
        ? cleanUserTitle
        : ((cleanFileName != null && cleanFileName.isNotEmpty)
              ? cleanFileName
              : (selectedApp?.appName ?? 'Document Intake'));
    final sourceLabel = (cleanFileName != null && cleanFileName.isNotEmpty)
        ? 'Document · $cleanFileName'
        : 'Document Intake';

    final captured = CapturedPolicySnapshot(
      normalizedPolicyText: trimmed,
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      sourceSnapshot: sourceSnapshot,
      sufficiency: sufficiency,
    );

    final association = _evaluateAssociation(
      selectedApp: selectedApp,
      policyText: trimmed,
      policyUrl: null,
      trustedSampleFixture: null,
    );

    return PolicyIntakeSuccess(
      locator: locator,
      capturedSnapshot: captured,
      selectedApp: selectedApp,
      associationReport: association,
    );
  }

  AppPolicyAssociationReport _evaluateAssociation({
    required SelectedAppReference? selectedApp,
    required String policyText,
    required String? policyUrl,
    required TrustedSampleFixture? trustedSampleFixture,
  }) {
    return AppPolicyAssociationEvaluator.evaluate(
      AppPolicyAssociationInput(
        packageName: selectedApp?.packageName,
        appName: selectedApp?.appName,
        policyText: policyText,
        policyUrl: policyUrl,
        sampleFixture: trustedSampleFixture,
        candidateApps:
            selectedApp?.peerCandidates ?? const <AppIdentityCandidate>[],
        evaluatedAt: _clock().toUtc(),
      ),
    );
  }

  static String _resolveTextSubjectTitle({
    required String? userSubjectTitle,
    required SelectedAppReference? selectedApp,
    required String? defaultSubjectTitle,
    required PolicySourceType sourceType,
  }) {
    final cleanTitle = userSubjectTitle?.trim();
    if (cleanTitle != null && cleanTitle.isNotEmpty) return cleanTitle;
    if (selectedApp != null) return selectedApp.appName;
    final cleanDefault = defaultSubjectTitle?.trim();
    if (cleanDefault != null && cleanDefault.isNotEmpty) return cleanDefault;
    return switch (sourceType) {
      PolicySourceType.selectedText => 'Selected Excerpt',
      PolicySourceType.sharedText => 'Shared Policy',
      _ => 'Privacy Policy',
    };
  }

  static PolicyIntakeFailureKind _mapUrlFailureKind(
    PolicyRetrievalStatus status,
  ) {
    return switch (status) {
      PolicyRetrievalStatus.invalidUrl => PolicyIntakeFailureKind.invalidUrl,
      PolicyRetrievalStatus.unsafeDestination =>
        PolicyIntakeFailureKind.unsafeDestination,
      PolicyRetrievalStatus.networkError =>
        PolicyIntakeFailureKind.networkError,
      PolicyRetrievalStatus.timeout => PolicyIntakeFailureKind.timeout,
      PolicyRetrievalStatus.sizeExceeded =>
        PolicyIntakeFailureKind.sizeExceeded,
      PolicyRetrievalStatus.unsupportedContentType =>
        PolicyIntakeFailureKind.unsupportedContentType,
      PolicyRetrievalStatus.httpError => PolicyIntakeFailureKind.httpError,
      PolicyRetrievalStatus.emptyOrErrorPage =>
        PolicyIntakeFailureKind.emptyOrErrorPage,
      PolicyRetrievalStatus.insufficientPolicy =>
        PolicyIntakeFailureKind.insufficientPolicy,
      PolicyRetrievalStatus.cancelled => PolicyIntakeFailureKind.cancelled,
      PolicyRetrievalStatus.localProvided || PolicyRetrievalStatus.retrieved =>
        PolicyIntakeFailureKind.insufficientPolicy,
    };
  }

  static PolicyIntakeFailureKind _mapDocumentFailureKind(
    DocumentExtractionStatus status,
  ) {
    return switch (status) {
      DocumentExtractionStatus.unsupportedMime =>
        PolicyIntakeFailureKind.documentUnsupportedMime,
      DocumentExtractionStatus.tooLarge =>
        PolicyIntakeFailureKind.documentTooLarge,
      DocumentExtractionStatus.empty => PolicyIntakeFailureKind.documentEmpty,
      DocumentExtractionStatus.corrupt =>
        PolicyIntakeFailureKind.documentCorrupt,
      DocumentExtractionStatus.passwordProtected =>
        PolicyIntakeFailureKind.documentPasswordProtected,
      DocumentExtractionStatus.permissionDenied =>
        PolicyIntakeFailureKind.documentPermissionDenied,
      DocumentExtractionStatus.cancelled => PolicyIntakeFailureKind.cancelled,
      DocumentExtractionStatus.none ||
      DocumentExtractionStatus.extracted ||
      DocumentExtractionStatus.readError =>
        PolicyIntakeFailureKind.documentReadError,
    };
  }

  static bool _canRetryUrlFailure(PolicyIntakeFailureKind kind) {
    return switch (kind) {
      PolicyIntakeFailureKind.unsafeDestination ||
      PolicyIntakeFailureKind.invalidUrl ||
      PolicyIntakeFailureKind.sizeExceeded ||
      PolicyIntakeFailureKind.unsupportedContentType => false,
      PolicyIntakeFailureKind.networkError ||
      PolicyIntakeFailureKind.timeout ||
      PolicyIntakeFailureKind.httpError ||
      PolicyIntakeFailureKind.emptyOrErrorPage ||
      PolicyIntakeFailureKind.insufficientPolicy ||
      PolicyIntakeFailureKind.cancelled => true,
      _ => false,
    };
  }

  static String _urlRecoveryHint(PolicyIntakeFailureKind kind) {
    return switch (kind) {
      PolicyIntakeFailureKind.unsafeDestination =>
        'Edit the URL to a public https:// privacy policy link, paste the policy text directly, or import a local PDF, TXT, or DOCX document.',
      PolicyIntakeFailureKind.invalidUrl =>
        'Edit the URL to a valid public https:// privacy policy link, paste the policy text directly, or import a local PDF, TXT, or DOCX document.',
      PolicyIntakeFailureKind.sizeExceeded =>
        'Edit the URL to a smaller privacy policy page, paste the policy text directly, or import a saved PDF, TXT, or DOCX document.',
      PolicyIntakeFailureKind.unsupportedContentType =>
        'Save supported PDF, TXT, or DOCX documents locally and import them with Document mode, or paste the policy text directly.',
      PolicyIntakeFailureKind.emptyOrErrorPage ||
      PolicyIntakeFailureKind.insufficientPolicy =>
        'Open the policy page in your browser and copy/paste the policy paragraphs or share the text to Enprive.',
      _ =>
        'Check the web address, paste the privacy policy text directly, or import a local PDF, TXT, or DOCX document.',
    };
  }
}
