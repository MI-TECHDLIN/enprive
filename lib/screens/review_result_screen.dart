import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/intake/policy_intake_models.dart';
import '../domain/review/app_policy_association.dart'
    show AppPolicyAssociationReport, AppPolicyAssociationState;
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../domain/voice/deni_voice_summary.dart';
import '../l10n/app_localizations.dart';
import '../services/intake/policy_intake_coordinator.dart';
import '../services/network/policy_url_retriever.dart';
import '../services/platform/companion_bridge.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../services/storage/receipt_repository.dart';
import 'finding_detail_screen.dart';
import '../widgets/analysis_process_trace.dart';
import '../widgets/cloud_consent_sheet.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/deni_voice_summary_card.dart';
import '../widgets/enprive_provenance_chip.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/installed_app_picker_sheet.dart';
import '../widgets/intake/unified_policy_intake_sheet.dart';
import '../widgets/m3e/enprive_m3e_components.dart';
import '../widgets/review/enprive_finding_row.dart';
import '../widgets/review/enprive_linked_app_section.dart';
import '../widgets/review/evidence_category_style.dart';
import '../widgets/review/unsaved_review_exit_sheet.dart';
import '../widgets/review_progress_sheet.dart';
import '../widgets/why_this_finding_sheet.dart';

/// Coordinates external navigation requests (such as warm Android shares,
/// `ACTION_PROCESS_TEXT`, or Quick Settings invocations) with an active
/// [ReviewResultScreen] so unsaved review drafts always present
/// [UnsavedReviewExitSheet] instead of being dropped silently by `popUntil`.
class ReviewExitGuardController {
  Future<bool> Function()? _requestExitHandler;

  bool get hasActiveScreen => _requestExitHandler != null;

  void attach(Future<bool> Function() handler) {
    _requestExitHandler = handler;
  }

  void detach(Future<bool> Function() handler) {
    if (identical(_requestExitHandler, handler)) {
      _requestExitHandler = null;
    }
  }

  /// Requests the active [ReviewResultScreen] to exit cleanly.
  ///
  /// Returns `true` if no guarded screen is active or after the user saves or
  /// discards the draft and the route pops; returns `false` if the user chose
  /// "Continue reviewing", dismissed the sheet, or saving failed.
  Future<bool> requestExit() async {
    final handler = _requestExitHandler;
    if (handler == null) return true;
    return handler();
  }
}

/// Material 3 Expressive Evidence Result Screen:
/// - Archival canvas with [EnpriveReviewHeroCard] (inset teal mesh banner,
///   overlapping Deni Standard LOD medallion, borderless 3-column metrics, and
///   leading-arrow tactile CTA)
/// - Segmented quote-first `M3ECard` finding cards (`EnpriveRadii.groupedCardRadius`)
/// - Explicit user-controlled persistence (`ReceiptLifecycleState`), historical
///   receipt protection on policy attachment, and calm unsaved-exit confirmation
class ReviewResultScreen extends StatefulWidget {
  final PolicyReviewReceipt receipt;
  final ReviewCoordinator coordinator;
  final FutureOr<void> Function(PolicyReviewReceipt)? onSaveReceipt;
  final FutureOr<void> Function(String receiptId)? onDeleteReceipt;
  final List<PolicyReviewReceipt> savedReceipts;
  final ReceiptRepository? receiptRepository;
  final bool Function(String receiptId)? isReceiptSaved;
  final bool isInitiallySaved;
  final bool cloudConsentGrantedForSession;
  final PolicyUrlRetriever? urlRetriever;
  final PolicyIntakeCoordinator? intakeCoordinator;
  final CompanionBridge? companionBridge;
  final AppPolicyAssociationReport? initialAssociationReport;
  final ReviewExitGuardController? exitGuardController;

  const ReviewResultScreen({
    super.key,
    required this.receipt,
    required this.coordinator,
    this.onSaveReceipt,
    this.onDeleteReceipt,
    this.savedReceipts = const [],
    this.receiptRepository,
    this.isReceiptSaved,
    this.isInitiallySaved = false,
    this.cloudConsentGrantedForSession = false,
    this.urlRetriever,
    this.intakeCoordinator,
    this.companionBridge,
    this.initialAssociationReport,
    this.exitGuardController,
  });

  @override
  State<ReviewResultScreen> createState() => _ReviewResultScreenState();
}

class _ReviewResultScreenState extends State<ReviewResultScreen> {
  late PolicyIntakeCoordinator _intakeCoordinator;
  late CompanionBridge _companionBridge;
  late PolicyReviewReceipt _activeReceipt = widget.receipt;
  PolicyReviewReceipt? _persistedBaselineReceipt;
  AppPolicyAssociationReport? _activeAssociationReport;
  late ReceiptLifecycleState _lifecycleState;
  String? _saveErrorMessage;
  bool _isExitSheetOpen = false;
  bool _isExiting = false;
  bool _allowImmediatePop = false;
  Completer<bool>? _pendingExitCompleter;
  bool _isDeleting = false;
  DeniVoiceSummary? _voiceSummary;
  bool _isGeneratingSummary = false;
  bool _isVoiceConsentOpen = false;
  VoicePlaybackState _voicePlaybackState = VoicePlaybackState.idle;
  VoicePlaybackRoute _activeVoiceRoute = VoicePlaybackRoute.none;
  String? _voiceStatusNotice;
  int _voiceSequence = 0;
  int _summarySequence = 0;
  String? _activeSummaryRequestId;
  bool _isSummaryCloudRequest = false;
  StreamSubscription<VoicePlaybackEvent>? _voiceEventsSub;
  bool _isOpeningAttachSheet = false;
  bool _isOpeningLinkPicker = false;
  bool _isAttachingPolicy = false;
  bool _isAttachingCloud = false;
  bool _isCancellingAttach = false;
  int _attachSequence = 0;
  int _linkSequence = 0;
  int _draftCounter = 0;
  String? _attachRequestId;

  bool get _isSpeaking =>
      _voicePlaybackState == VoicePlaybackState.synthesizing ||
      _voicePlaybackState == VoicePlaybackState.playing;

  PolicyIntakeCoordinator _resolveIntakeCoordinator() =>
      widget.intakeCoordinator ??
      PolicyIntakeCoordinator(
        urlRetriever: widget.urlRetriever,
        hybridBridge: widget.coordinator.bridge,
      );

  bool _isSampleReceipt(PolicyReviewReceipt receipt) =>
      receipt.sourceSnapshot?.sourceType == PolicySourceType.sample ||
      receipt.sourceSnapshot?.appIdentityMatchStatus ==
          AppIdentityMatchStatus.sampleFixture;

  /// Resolves the in-memory [AppPolicyAssociationReport] for [receipt].
  ///
  /// Association reports remain strictly in memory (never persisted to the
  /// receipt database schema). When a previously saved linked receipt is
  /// reopened without an [initialAssociationReport], recomputes the exact
  /// deterministic textual/URL signals on-device.
  AppPolicyAssociationReport? _resolveInitialAssociationReport(
    PolicyReviewReceipt receipt,
  ) {
    if (widget.initialAssociationReport != null) {
      return widget.initialAssociationReport;
    }
    if (receipt.isPermissionOnlyInspection ||
        _isSampleReceipt(receipt) ||
        receipt.snapshotText.trim().isEmpty) {
      return null;
    }
    final snapshot = _validPermissionSnapshot(receipt);
    if (snapshot == null) return null;
    final policyUrl =
        receipt.sourceSnapshot?.canonicalUrl?.trim().isNotEmpty == true
            ? receipt.sourceSnapshot!.canonicalUrl!.trim()
            : receipt.sourceSnapshot?.requestedUrl?.trim();
    return _intakeCoordinator.evaluateAppPolicyAssociation(
      selectedApp: SelectedAppReference(
        packageName: snapshot.packageName.trim(),
        appName: snapshot.appName.trim().isNotEmpty
            ? snapshot.appName.trim()
            : snapshot.packageName.trim(),
        permissionSnapshot: snapshot,
      ),
      policyText: receipt.snapshotText,
      policyUrl: policyUrl,
    );
  }

  @override
  void initState() {
    super.initState();
    _intakeCoordinator = _resolveIntakeCoordinator();
    _companionBridge = widget.companionBridge ?? CompanionBridge();
    _activeAssociationReport = _resolveInitialAssociationReport(_activeReceipt);
    _initLifecycleFromTruthSource();
    widget.exitGuardController?.attach(_requestExternalExit);
    _voiceSummary = DeniVoiceSummaryBuilder.buildDeterministic(
      receipt: _activeReceipt,
      associationReport: _activeAssociationReport,
      languageCode: _activeReceipt.languageCode,
    );
    _bindVoicePlaybackStream();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_refreshVoiceSummaryOnDeviceFirst());
      }
    });
  }

  void _bindVoicePlaybackStream() {
    _voiceEventsSub?.cancel();
    _voiceEventsSub = widget.coordinator.bridge.voicePlaybackEvents.listen((
      event,
    ) {
      if (!mounted) return;
      switch (event.state) {
        case VoicePlaybackState.synthesizing:
          setState(() {
            _voicePlaybackState = VoicePlaybackState.synthesizing;
            _activeVoiceRoute = event.route;
          });
          break;
        case VoicePlaybackState.playing:
          setState(() {
            _voicePlaybackState = VoicePlaybackState.playing;
            if (event.route != VoicePlaybackRoute.none) {
              _activeVoiceRoute = event.route;
            }
          });
          break;
        case VoicePlaybackState.completed:
        case VoicePlaybackState.stopped:
        case VoicePlaybackState.idle:
          setState(() {
            _voicePlaybackState = VoicePlaybackState.idle;
          });
          break;
        case VoicePlaybackState.error:
          setState(() {
            _voicePlaybackState = VoicePlaybackState.idle;
            if (event.message != null && event.message!.isNotEmpty) {
              _voiceStatusNotice = event.message;
            }
          });
          break;
      }
    });
  }

  bool _isPersistedInTruthSource(String receiptId) {
    final hasExternalTruth =
        widget.isReceiptSaved != null || widget.receiptRepository != null;
    if (hasExternalTruth) {
      final inCallback = widget.isReceiptSaved?.call(receiptId) ?? false;
      final inRepo =
          widget.receiptRepository?.containsReceiptSync(receiptId) ?? false;
      return inCallback || inRepo;
    }
    return receiptId == widget.receipt.id && widget.isInitiallySaved;
  }

  void _initLifecycleFromTruthSource() {
    final initiallyPersisted = _isPersistedInTruthSource(_activeReceipt.id);
    if (initiallyPersisted) {
      _lifecycleState = ReceiptLifecycleState.saved;
      _persistedBaselineReceipt = _activeReceipt;
    } else {
      _lifecycleState = ReceiptLifecycleState.draft;
      _persistedBaselineReceipt = null;
    }
    _saveErrorMessage = null;
    if (!initiallyPersisted && widget.receiptRepository != null) {
      unawaited(_syncFromRepositoryAsync(_activeReceipt.id));
    }
  }

  Future<void> _syncFromRepositoryAsync(String receiptId) async {
    final repo = widget.receiptRepository;
    if (repo == null) return;
    final exists = await repo.containsReceipt(receiptId);
    if (!mounted) return;
    if (exists &&
        _activeReceipt.id == receiptId &&
        _lifecycleState == ReceiptLifecycleState.draft) {
      setState(() {
        _lifecycleState = ReceiptLifecycleState.saved;
        _persistedBaselineReceipt = _activeReceipt;
        _saveErrorMessage = null;
      });
    }
  }

  bool get _isSaved => _lifecycleState == ReceiptLifecycleState.saved;

  bool get _canPersist =>
      widget.onSaveReceipt != null || widget.receiptRepository != null;

  bool get _canDelete =>
      widget.onDeleteReceipt != null || widget.receiptRepository != null;

  bool get _requiresExitConfirmation =>
      _canPersist &&
      !_allowImmediatePop &&
      (_lifecycleState == ReceiptLifecycleState.draft ||
          _lifecycleState == ReceiptLifecycleState.modifiedSavedDraft ||
          _lifecycleState == ReceiptLifecycleState.saveFailure);

  @override
  void didUpdateWidget(covariant ReviewResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intakeCoordinator != widget.intakeCoordinator ||
        oldWidget.urlRetriever != widget.urlRetriever ||
        oldWidget.coordinator != widget.coordinator) {
      _intakeCoordinator = _resolveIntakeCoordinator();
    }
    if (oldWidget.companionBridge != widget.companionBridge) {
      _companionBridge = widget.companionBridge ?? CompanionBridge();
    }
    if (oldWidget.exitGuardController != widget.exitGuardController) {
      oldWidget.exitGuardController?.detach(_requestExternalExit);
      widget.exitGuardController?.attach(_requestExternalExit);
    }
    if (oldWidget.coordinator != widget.coordinator) {
      _bindVoicePlaybackStream();
    }
    if (oldWidget.receipt.id != widget.receipt.id ||
        oldWidget.receipt != widget.receipt) {
      _cancelInFlightAttachSilently();
      _cancelVoiceAndSummarySilently();
      _activeReceipt = widget.receipt;
      _activeAssociationReport = _resolveInitialAssociationReport(
        _activeReceipt,
      );
      _allowImmediatePop = false;
      _isExiting = false;
      _initLifecycleFromTruthSource();
      _voiceSummary = DeniVoiceSummaryBuilder.buildDeterministic(
        receipt: _activeReceipt,
        associationReport: _activeAssociationReport,
        languageCode: _activeReceipt.languageCode,
      );
      unawaited(_refreshVoiceSummaryOnDeviceFirst());
    } else if (oldWidget.isInitiallySaved != widget.isInitiallySaved ||
        oldWidget.receiptRepository != widget.receiptRepository ||
        oldWidget.isReceiptSaved != widget.isReceiptSaved) {
      if (_lifecycleState == ReceiptLifecycleState.draft ||
          _lifecycleState == ReceiptLifecycleState.saved) {
        _initLifecycleFromTruthSource();
      }
    }
  }

  void _cancelInFlightAttachSilently() {
    final reqId = _attachRequestId;
    final wasCloud = _isAttachingCloud;
    _attachSequence++;
    _linkSequence++;
    _isAttachingPolicy = false;
    _isAttachingCloud = false;
    _isCancellingAttach = false;
    _attachRequestId = null;
    if (reqId != null) {
      final cancelId = wasCloud ? '${reqId}_appcheck' : reqId;
      unawaited(widget.coordinator.bridge.cancelAnalysis(requestId: cancelId));
    }
  }

  void _cancelVoiceAndSummarySilently() {
    _voiceSequence++;
    _summarySequence++;
    final sumReq = _activeSummaryRequestId;
    final wasCloudSummary = _isSummaryCloudRequest;
    _activeSummaryRequestId = null;
    _isSummaryCloudRequest = false;
    _isGeneratingSummary = false;
    _voiceStatusNotice = null;
    if (sumReq != null) {
      final cancelId = wasCloudSummary ? '${sumReq}_appcheck' : sumReq;
      unawaited(widget.coordinator.bridge.cancelAnalysis(requestId: cancelId));
    }
    if (_isSpeaking) {
      _voicePlaybackState = VoicePlaybackState.idle;
      unawaited(widget.coordinator.bridge.stopSpeaking());
    }
  }

  @override
  void dispose() {
    widget.exitGuardController?.detach(_requestExternalExit);
    final pending = _pendingExitCompleter;
    if (pending != null && !pending.isCompleted) {
      pending.complete(true);
    }
    _pendingExitCompleter = null;
    _voiceEventsSub?.cancel();
    _voiceEventsSub = null;
    _cancelInFlightAttachSilently();
    _cancelVoiceAndSummarySilently();
    super.dispose();
  }

  /// Pose of the compact Deni inside the "Ask Deni" button: listening or
  /// thinking while voice work runs, otherwise a raised hand ("I can explain
  /// this"). Hands show intent, never a verdict, so the review state is not
  /// mirrored in the pose.
  DeniPose get _statePose {
    if (_voicePlaybackState == VoicePlaybackState.playing) {
      return DeniPose.listening;
    }
    if (_voicePlaybackState == VoicePlaybackState.synthesizing ||
        _isGeneratingSummary) {
      return DeniPose.thinking;
    }
    return DeniPose.raiseHand;
  }

  DeniVoiceSummary get _effectiveVoiceSummary =>
      _voiceSummary ??
      DeniVoiceSummaryBuilder.buildDeterministic(
        receipt: _activeReceipt,
        associationReport: _activeAssociationReport,
        languageCode: _activeReceipt.languageCode,
      );

  Future<void> _refreshVoiceSummaryOnDeviceFirst() async {
    final receipt = _activeReceipt;
    final association = _activeAssociationReport;
    final lang = mounted
        ? (Localizations.maybeLocaleOf(context)?.languageCode ??
              receipt.languageCode)
        : receipt.languageCode;

    final baseline = DeniVoiceSummaryBuilder.buildDeterministic(
      receipt: receipt,
      associationReport: association,
      languageCode: lang,
    );

    if (DeniVoiceSummaryBuilder.selectSourceMatchedFindings(receipt).isEmpty) {
      if (!mounted) return;
      setState(() {
        _voiceSummary = baseline;
        _isGeneratingSummary = false;
      });
      return;
    }

    final seq = ++_summarySequence;
    final reqId = 'vsum_${DateTime.now().microsecondsSinceEpoch}';
    if (mounted) {
      setState(() {
        _voiceSummary = baseline;
        _isGeneratingSummary = true;
        _activeSummaryRequestId = reqId;
        _isSummaryCloudRequest = false;
      });
    }

    try {
      final generated = await widget.coordinator.generateDeniVoiceSummary(
        receipt: receipt,
        associationReport: association,
        cloudConsent: false,
        languageCode: lang,
        requestId: reqId,
      );
      if (!mounted || seq != _summarySequence) return;
      setState(() {
        _voiceSummary = generated;
        _isGeneratingSummary = false;
        _activeSummaryRequestId = null;
      });
    } on HybridOperationCancelledException {
      if (!mounted || seq != _summarySequence) return;
      setState(() {
        _isGeneratingSummary = false;
        _activeSummaryRequestId = null;
      });
    } catch (_) {
      if (!mounted || seq != _summarySequence) return;
      setState(() {
        _voiceSummary = baseline;
        _isGeneratingSummary = false;
        _activeSummaryRequestId = null;
      });
    }
  }

  Future<void> _enhanceSummaryWithCloud(AppLocalizations l10n) async {
    if (_isGeneratingSummary || _isVoiceConsentOpen) return;
    final receipt = _activeReceipt;
    final association = _activeAssociationReport;
    final rawPayload = DeniVoiceSummaryBuilder.buildPromptPayload(receipt);
    if (rawPayload.isEmpty) return;
    final canonicalPayload =
        _voiceSummary?.redactedCloudPayload ??
        ReviewCoordinator.canonicalCloudPayload(rawPayload);

    _isVoiceConsentOpen = true;
    final CloudConsentDecision decision;
    try {
      decision = await CloudConsentSheet.show(
        context,
        subjectTitle: receipt.subjectTitle,
        policyText: rawPayload,
        canonicalRedactedPreview: canonicalPayload,
        deviceReason: _voiceSummary?.consentReason,
        titleOverride: l10n.voiceSummaryConsentTitle,
        disclosureOverride: l10n.voiceSummaryConsentDisclosure,
      );
    } finally {
      _isVoiceConsentOpen = false;
    }
    if (!mounted || decision == CloudConsentDecision.cancelled) return;

    final lang =
        Localizations.maybeLocaleOf(context)?.languageCode ??
        receipt.languageCode;

    if (decision == CloudConsentDecision.reviewLocally) {
      setState(() {
        _voiceSummary = DeniVoiceSummaryBuilder.buildDeterministic(
          receipt: receipt,
          associationReport: association,
          languageCode: lang,
          requiresCloudConsent: true,
          redactedCloudPayload: canonicalPayload,
        );
      });
      return;
    }

    final seq = ++_summarySequence;
    final reqId = 'vsum_${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _isGeneratingSummary = true;
      _activeSummaryRequestId = reqId;
      _isSummaryCloudRequest = true;
    });

    try {
      final generated = await widget.coordinator.generateDeniVoiceSummary(
        receipt: receipt,
        associationReport: association,
        cloudConsent: true,
        languageCode: lang,
        canonicalRedactedPayload: canonicalPayload,
        requestId: reqId,
      );
      if (!mounted || seq != _summarySequence) return;
      setState(() {
        _voiceSummary = generated;
        _isGeneratingSummary = false;
        _activeSummaryRequestId = null;
        _isSummaryCloudRequest = false;
      });
    } on HybridOperationCancelledException {
      if (!mounted || seq != _summarySequence) return;
      setState(() {
        _isGeneratingSummary = false;
        _activeSummaryRequestId = null;
        _isSummaryCloudRequest = false;
      });
    }
  }

  Future<void> _stopVoicePlayback() async {
    _voiceSequence++;
    await widget.coordinator.bridge.stopSpeaking();
    if (!mounted) return;
    setState(() {
      _voicePlaybackState = VoicePlaybackState.idle;
    });
  }

  Future<void> _playSummaryLocally(AppLocalizations l10n) async {
    final summary = _effectiveVoiceSummary;
    final script = summary.spokenScript;
    if (script.trim().isEmpty) return;

    final lang =
        Localizations.maybeLocaleOf(context)?.languageCode ??
        _activeReceipt.languageCode;
    final seq = ++_voiceSequence;
    final reqId = 'tts_local_${DateTime.now().microsecondsSinceEpoch}';

    setState(() {
      _voicePlaybackState = VoicePlaybackState.playing;
      _activeVoiceRoute = VoicePlaybackRoute.androidLocalTts;
      _voiceStatusNotice = null;
    });

    final spoke = await widget.coordinator.bridge.speakText(
      script,
      languageCode: lang,
      requestId: reqId,
    );
    if (!mounted || seq != _voiceSequence) return;
    if (!spoke) {
      setState(() {
        _voicePlaybackState = VoicePlaybackState.idle;
        _activeVoiceRoute = VoicePlaybackRoute.transcriptOnly;
        _voiceStatusNotice = l10n.voiceUnavailableNotice;
      });
    }
  }

  Future<void> _requestExpressiveVoicePlayback(AppLocalizations l10n) async {
    if (_isSpeaking) {
      await _stopVoicePlayback();
      return;
    }
    if (_isVoiceConsentOpen) return;

    final summary = _effectiveVoiceSummary;
    final rawScript = summary.spokenScript;
    if (rawScript.trim().isEmpty) return;
    final canonicalScript = ReviewCoordinator.canonicalCloudPayload(rawScript);

    _isVoiceConsentOpen = true;
    final CloudConsentDecision decision;
    try {
      decision = await CloudConsentSheet.show(
        context,
        subjectTitle: _activeReceipt.subjectTitle,
        policyText: rawScript,
        canonicalRedactedPreview: canonicalScript,
        titleOverride: l10n.voiceConsentTitle,
        disclosureOverride: l10n.voiceConsentDisclosure,
        primaryActionLabelOverride: l10n.voiceConsentPrimaryAction,
        secondaryActionLabelOverride: l10n.voiceConsentSecondaryAction,
        payloadCategoryLabelOverride: l10n.voiceConsentPayloadLabel,
      );
    } finally {
      _isVoiceConsentOpen = false;
    }
    if (!mounted || decision == CloudConsentDecision.cancelled) return;

    if (decision == CloudConsentDecision.reviewLocally) {
      await _playSummaryLocally(l10n);
      return;
    }

    final lang =
        Localizations.maybeLocaleOf(context)?.languageCode ??
        _activeReceipt.languageCode;
    final seq = ++_voiceSequence;
    final reqId = 'tts_gemini_${DateTime.now().microsecondsSinceEpoch}';

    setState(() {
      _voicePlaybackState = VoicePlaybackState.synthesizing;
      _activeVoiceRoute = VoicePlaybackRoute.geminiCloudTts;
      _voiceStatusNotice = null;
    });

    final result = await widget.coordinator.bridge.speakWithGeminiTts(
      requestId: reqId,
      text: canonicalScript,
      cloudConsent: true,
      languageCode: lang,
      fallbackToLocalOnFailure: true,
    );
    if (!mounted || seq != _voiceSequence) return;

    if (result.wasCancelled) {
      setState(() {
        _voicePlaybackState = VoicePlaybackState.idle;
      });
      return;
    }

    if (result.fellBackToLocal) {
      setState(() {
        _voicePlaybackState = VoicePlaybackState.playing;
        _activeVoiceRoute = VoicePlaybackRoute.androidLocalTts;
        _voiceStatusNotice =
            result.message ?? l10n.voiceFallbackDeviceNotice;
      });
      return;
    }

    if (result.status == 'completed') {
      setState(() {
        _voicePlaybackState = VoicePlaybackState.idle;
        _activeVoiceRoute = VoicePlaybackRoute.geminiCloudTts;
        _voiceStatusNotice = null;
      });
      return;
    }

    // Cloud failed and native player did not report local fallback (e.g. plugin unavailable)
    final spokeLocal = await widget.coordinator.bridge.speakText(
      canonicalScript,
      languageCode: lang,
      requestId: '${reqId}_dart_fallback',
    );
    if (!mounted || seq != _voiceSequence) return;
    if (spokeLocal) {
      setState(() {
        _voicePlaybackState = VoicePlaybackState.playing;
        _activeVoiceRoute = VoicePlaybackRoute.androidLocalTts;
        _voiceStatusNotice =
            result.message ?? l10n.voiceFallbackDeviceNotice;
      });
    } else {
      setState(() {
        _voicePlaybackState = VoicePlaybackState.idle;
        _activeVoiceRoute = VoicePlaybackRoute.transcriptOnly;
        _voiceStatusNotice =
            result.message ?? l10n.voiceUnavailableNotice;
      });
    }
  }

  Future<void> _toggleVoicePlayback(AppLocalizations l10n) async {
    if (_isSpeaking) {
      await _stopVoicePlayback();
      return;
    }
    await _requestExpressiveVoicePlayback(l10n);
  }

  void _openFindingById(String findingId) {
    for (final finding in _activeReceipt.findings) {
      if (finding.id == findingId) {
        _openFindingDetails(finding);
        return;
      }
    }
  }

  (SemanticColorPair pair, IconData icon, String title, String subtitle)
  _stateConfig(AppLocalizations l10n, EnpriveSemanticColors semantics) {
    if (_activeReceipt.isPermissionOnlyInspection) {
      return (
        semantics.onDevice,
        LucideIcons.smartphone,
        l10n.permissionInspectionTitle,
        _activeReceipt.calibratedDisclaimer,
      );
    }
    return switch (_activeReceipt.overallState) {
      ReviewOverallState.reviewRecommended => (
        semantics.reviewRecommended,
        LucideIcons.shieldAlert,
        l10n.stateReviewRecommended,
        l10n.stateReviewRecommendedSubtitle,
      ),
      ReviewOverallState.noConcern => (
        semantics.noConcern,
        LucideIcons.fileText,
        l10n.stateNoConcern,
        l10n.stateNoConcernSubtitle,
      ),
      ReviewOverallState.insufficientEvidence => (
        semantics.insufficientEvidence,
        (_activeReceipt.diagnosticKind ==
                    ReviewDiagnosticKind.failedModelInference ||
                _activeReceipt.diagnosticKind ==
                    ReviewDiagnosticKind.cloudUnavailableLocalFallback)
            ? LucideIcons.info
            : LucideIcons.circleHelp,
        l10n.stateInsufficientEvidence,
        _activeReceipt.summary.trim().isNotEmpty
            ? _activeReceipt.summary
            : l10n.stateInsufficientEvidenceSubtitle,
      ),
    };
  }

  String _proofLabelFor(
    VerifiedFinding finding,
    AppLocalizations l10n, {
    required bool isSampleReceipt,
  }) {
    if (finding.isDeviceObserved) {
      return isSampleReceipt
          ? l10n.sampleSyntheticBadge
          : l10n.observedOnPhoneLabel;
    }
    if (finding.isSourceMatched) return l10n.quoteVerifiedLabel;
    return isSampleReceipt && finding.status == EvidenceStatus.interpretation
        ? l10n.sampleSyntheticBadge
        : l10n.unverifiedClaimLabel;
  }

  void _openFindingDetailPage(
    PolicyReviewReceipt receipt,
    int index, {
    required bool isSampleReceipt,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final finding = receipt.findings[index];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FindingDetailScreen(
          finding: finding,
          index: index,
          totalCount: receipt.findings.length,
          proofLabel: _proofLabelFor(
            finding,
            l10n,
            isSampleReceipt: isSampleReceipt,
          ),
          reviewChipLabel: finding.severity == FindingSeverity.high
              ? l10n.findingReviewChip
              : null,
          snapshotDigest: receipt.snapshotDigest,
          onAskDeni: () => _openFindingDetails(finding),
        ),
      ),
    );
  }

  void _openFindingDetails(VerifiedFinding finding) {
    WhyThisFindingSheet.show(
      context,
      finding: finding,
      snapshotText: _activeReceipt.snapshotText,
      snapshotDigest: _activeReceipt.snapshotDigest,
      coordinator: widget.coordinator,
      cloudConsentGrantedForSession: widget.cloudConsentGrantedForSession,
    );
  }

  AppPermissionSnapshot? _validPermissionSnapshot(PolicyReviewReceipt receipt) {
    final snapshot = receipt.permissionReport?.snapshot;
    if (snapshot == null || snapshot.packageName.trim().isEmpty) {
      return null;
    }
    return snapshot;
  }

  static bool _samePermissionSet(List<String> a, List<String> b) {
    final setA = a.map((p) => p.trim()).where((p) => p.isNotEmpty).toSet();
    final setB = b.map((p) => p.trim()).where((p) => p.isNotEmpty).toSet();
    return setA.length == setB.length && setA.containsAll(setB);
  }

  ({String id, DateTime createdAt, String? supersedesReceiptId})
  _nextSafeDraftIdentity({String? candidateId, DateTime? candidateCreatedAt}) {
    final baseId = _persistedBaselineReceipt?.id;
    final cleanCandidate = candidateId?.trim();
    final needsDistinctDraftId =
        cleanCandidate == null ||
        cleanCandidate.isEmpty ||
        cleanCandidate == baseId ||
        cleanCandidate == _activeReceipt.id ||
        _isPersistedInTruthSource(cleanCandidate);
    final safeDraftId = needsDistinctDraftId
        ? 'draft_${DateTime.now().microsecondsSinceEpoch}_${++_draftCounter}'
        : cleanCandidate;
    var createdAt = candidateCreatedAt ?? DateTime.now();
    final baseline = _persistedBaselineReceipt;
    if (baseline != null && !createdAt.isAfter(baseline.createdAt)) {
      createdAt = baseline.createdAt.add(const Duration(milliseconds: 1));
    }
    if (!createdAt.isAfter(_activeReceipt.createdAt)) {
      createdAt = _activeReceipt.createdAt.add(const Duration(milliseconds: 1));
    }
    return (
      id: safeDraftId,
      createdAt: createdAt,
      supersedesReceiptId: baseId ?? _activeReceipt.supersedesReceiptId,
    );
  }

  Future<void> _openLinkAppPicker(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isChanging,
  }) async {
    final receipt = _activeReceipt;
    if (_isAttachingPolicy ||
        _isOpeningAttachSheet ||
        _isOpeningLinkPicker ||
        receipt.isPermissionOnlyInspection ||
        _isSampleReceipt(receipt) ||
        receipt.snapshotText.trim().isEmpty) {
      return;
    }

    final currentSnapshot = _validPermissionSnapshot(receipt);
    final openSeq = ++_linkSequence;
    final expectedReceiptId = receipt.id;
    final messenger = ScaffoldMessenger.of(context);

    _isOpeningLinkPicker = true;
    SelectedAppInspectionChoice? choice;
    try {
      choice = await InstalledAppPickerSheet.show(
        context,
        bridge: widget.coordinator.bridge,
        eduTrackPolicyText: '',
        calmMathPolicyText: '',
        savedReceipts: widget.savedReceipts,
        receiptRepository: widget.receiptRepository,
        titleOverride: isChanging
            ? l10n.changeLinkedAppPickerTitle
            : l10n.linkAppPickerTitle,
        subtitleOverride: l10n.linkAppPickerSubtitle,
        selectedPackageName: isChanging ? currentSnapshot?.packageName : null,
      );
    } finally {
      _isOpeningLinkPicker = false;
    }

    if (choice == null ||
        choice.isSyntheticSample ||
        !mounted ||
        openSeq != _linkSequence ||
        _activeReceipt.id != expectedReceiptId) {
      return;
    }

    final pickedSnapshot = choice.permissionSnapshot;
    if (pickedSnapshot.packageName.trim().isEmpty) return;

    final displayAppName = pickedSnapshot.appName.trim().isNotEmpty
        ? pickedSnapshot.appName.trim()
        : (choice.subjectTitle.trim().isNotEmpty
              ? choice.subjectTitle.trim()
              : pickedSnapshot.packageName.trim());

    final isSamePackage =
        currentSnapshot != null &&
        currentSnapshot.packageName.trim().toLowerCase() ==
            pickedSnapshot.packageName.trim().toLowerCase();
    final isSamePermissions =
        isSamePackage &&
        _samePermissionSet(
          currentSnapshot.requestedPermissions,
          pickedSnapshot.requestedPermissions,
        ) &&
        _samePermissionSet(
          currentSnapshot.grantedPermissions,
          pickedSnapshot.grantedPermissions,
        );

    final policyUrl =
        receipt.sourceSnapshot?.canonicalUrl?.trim().isNotEmpty == true
        ? receipt.sourceSnapshot!.canonicalUrl!.trim()
        : receipt.sourceSnapshot?.requestedUrl?.trim();

    if (isSamePermissions) {
      // Refresh in-memory association (including peer installed app candidates)
      // without mutating the receipt or creating a redundant draft.
      final refreshedAssociation = _intakeCoordinator
          .evaluateAppPolicyAssociation(
            selectedApp: SelectedAppReference(
              packageName: pickedSnapshot.packageName.trim(),
              appName: displayAppName,
              permissionSnapshot: pickedSnapshot,
              peerCandidates: choice.peerCandidates,
            ),
            policyText: receipt.snapshotText,
            policyUrl: policyUrl,
          );
      final previousSummary = _effectiveVoiceSummary;
      _cancelVoiceAndSummarySilently();
      setState(() {
        _activeAssociationReport = refreshedAssociation;
        _voiceSummary = DeniVoiceSummaryBuilder.withUpdatedDeviceContext(
          current: previousSummary,
          receipt: _activeReceipt,
          associationReport: refreshedAssociation,
        );
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.linkedAppUnchangedSnack(displayAppName)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final draftIdentity = _nextSafeDraftIdentity();
    final linkResult = widget.coordinator.linkInstalledAppToReceipt(
      receipt: receipt,
      appPermissions: pickedSnapshot,
      peerCandidates: choice.peerCandidates,
      draftId: draftIdentity.id,
      createdAt: draftIdentity.createdAt,
      supersedesReceiptId: draftIdentity.supersedesReceiptId,
    );

    final previousSummary = _effectiveVoiceSummary;
    _cancelVoiceAndSummarySilently();
    setState(() {
      _activeReceipt = linkResult.receipt;
      _activeAssociationReport = linkResult.associationReport;
      _lifecycleState = _persistedBaselineReceipt != null
          ? ReceiptLifecycleState.modifiedSavedDraft
          : ReceiptLifecycleState.draft;
      _saveErrorMessage = null;
      _voiceSummary = DeniVoiceSummaryBuilder.withUpdatedDeviceContext(
        current: previousSummary,
        receipt: linkResult.receipt,
        associationReport: linkResult.associationReport,
      );
    });

    final hasAssociationWarning =
        linkResult.associationReport.state ==
            AppPolicyAssociationState.unmatched ||
        linkResult.associationReport.state ==
            AppPolicyAssociationState.ambiguousIdentity;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            hasAssociationWarning
                ? l10n.linkedAppCheckMatchSnack(displayAppName)
                : l10n.linkedAppSnack(displayAppName),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _unlinkInstalledApp(BuildContext context, AppLocalizations l10n) {
    final receipt = _activeReceipt;
    final currentSnapshot = _validPermissionSnapshot(receipt);
    if (currentSnapshot == null ||
        _isAttachingPolicy ||
        _isOpeningAttachSheet ||
        _isOpeningLinkPicker ||
        receipt.isPermissionOnlyInspection ||
        _isSampleReceipt(receipt)) {
      return;
    }

    final unlinkedAppName = currentSnapshot.appName.trim().isNotEmpty
        ? currentSnapshot.appName.trim()
        : currentSnapshot.packageName.trim();
    final previousSummary = _effectiveVoiceSummary;
    _cancelVoiceAndSummarySilently();

    final baseline = _persistedBaselineReceipt;
    final restoresSavedStandalone =
        baseline != null &&
        baseline.permissionReport == null &&
        baseline.snapshotDigest == receipt.snapshotDigest &&
        baseline.snapshotText == receipt.snapshotText;

    if (restoresSavedStandalone) {
      setState(() {
        _activeReceipt = baseline;
        _activeAssociationReport = null;
        _lifecycleState = ReceiptLifecycleState.saved;
        _saveErrorMessage = null;
        _voiceSummary = DeniVoiceSummaryBuilder.withUpdatedDeviceContext(
          current: previousSummary,
          receipt: baseline,
          associationReport: null,
        );
      });
    } else {
      final draftIdentity = _nextSafeDraftIdentity();
      final unlinkResult = widget.coordinator.unlinkInstalledAppFromReceipt(
        receipt: receipt,
        draftId: draftIdentity.id,
        createdAt: draftIdentity.createdAt,
        supersedesReceiptId: draftIdentity.supersedesReceiptId,
      );
      setState(() {
        _activeReceipt = unlinkResult.receipt;
        _activeAssociationReport = unlinkResult.associationReport;
        _lifecycleState = _persistedBaselineReceipt != null
            ? ReceiptLifecycleState.modifiedSavedDraft
            : ReceiptLifecycleState.draft;
        _saveErrorMessage = null;
        _voiceSummary = DeniVoiceSummaryBuilder.withUpdatedDeviceContext(
          current: previousSummary,
          receipt: unlinkResult.receipt,
          associationReport: unlinkResult.associationReport,
        );
      });
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.unlinkedAppSnack(unlinkedAppName)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _cancelAttachPolicy(AppLocalizations l10n) {
    if (!_isAttachingPolicy) return;
    final reqId = _attachRequestId;
    final wasCloud = _isAttachingCloud;
    _attachSequence++;
    setState(() {
      _isAttachingPolicy = false;
      _isAttachingCloud = false;
      _isCancellingAttach = false;
      _attachRequestId = null;
    });
    if (reqId != null) {
      final cancelId = wasCloud ? '${reqId}_appcheck' : reqId;
      unawaited(widget.coordinator.bridge.cancelAnalysis(requestId: cancelId));
    } else {
      unawaited(widget.coordinator.bridge.cancelAnalysis());
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.analysisCancelledNotice),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _openAttachPolicySheet(
    BuildContext context,
    AppLocalizations l10n,
    PolicyReviewReceipt receipt,
  ) async {
    final snapshot = _validPermissionSnapshot(receipt);
    if (snapshot == null || _isAttachingPolicy || _isOpeningAttachSheet) return;

    final lang = Localizations.localeOf(context).languageCode;
    final messenger = ScaffoldMessenger.of(context);
    final openSeq = _attachSequence;
    final expectedReceiptId = receipt.id;

    final cleanPackageName = snapshot.packageName.trim();
    final cleanAppName = snapshot.appName.trim().isNotEmpty
        ? snapshot.appName.trim()
        : (receipt.subjectTitle.trim().isNotEmpty
              ? receipt.subjectTitle.trim()
              : cleanPackageName);
    final displayTitle = receipt.subjectTitle.trim().isNotEmpty
        ? receipt.subjectTitle.trim()
        : cleanAppName;
    final lockedApp = SelectedAppReference(
      packageName: cleanPackageName,
      appName: cleanAppName,
      permissionSnapshot: snapshot,
      isLocked: true,
    );

    final isInitialAttachment = receipt.isPermissionOnlyInspection;
    final existingUrl = !isInitialAttachment
        ? (receipt.sourceSnapshot?.canonicalUrl?.trim().isNotEmpty == true
              ? receipt.sourceSnapshot!.canonicalUrl!.trim()
              : (receipt.sourceSnapshot?.requestedUrl?.trim().isNotEmpty == true
                    ? receipt.sourceSnapshot!.requestedUrl!.trim()
                    : null))
        : null;
    final initialLocator = existingUrl != null
        ? UrlPolicyLocator(
            rawUrl: existingUrl,
            userSubjectTitle: displayTitle,
          )
        : null;
    final sheetTitle = isInitialAttachment
        ? l10n.addAppPrivacyPolicyBtn
        : 'Update privacy policy for $displayTitle';

    _isOpeningAttachSheet = true;
    PolicyIntakeSuccess? intake;
    try {
      intake = await UnifiedPolicyIntakeSheet.show(
        context,
        config: PolicyIntakeSheetConfig(
          coordinator: _intakeCoordinator,
          titleOverride: sheetTitle,
          initialMode: PolicyIntakeMode.paste,
          initialSelectedApp: lockedApp,
          initialLocator: initialLocator,
          companionBridge: _companionBridge,
        ),
      );
    } finally {
      _isOpeningAttachSheet = false;
    }

    if (intake == null ||
        !mounted ||
        openSeq != _attachSequence ||
        _activeReceipt.id != expectedReceiptId) {
      return;
    }

    final captured = intake.capturedSnapshot;
    final policyText = captured.normalizedPolicyText;
    final sourceSnapshot = captured.sourceSnapshot;
    final sourceLabel = isInitialAttachment
        ? '${receipt.sourceLabel} · ${captured.sourceLabel}'
        : '$cleanAppName · ${captured.sourceLabel}';

    final seq = ++_attachSequence;
    var reqId = 'att_${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _isAttachingPolicy = true;
      _isAttachingCloud = false;
      _isCancellingAttach = false;
      _attachRequestId = reqId;
    });
    try {
      var outcome = await widget.coordinator.runPolicyReview(
        requestId: reqId,
        subjectTitle: displayTitle,
        sourceLabel: sourceLabel,
        policyText: policyText,
        appPermissions: snapshot,
        languageCode: lang,
        sourceSnapshot: sourceSnapshot,
      );
      if (!mounted || seq != _attachSequence) return;

      if (outcome.needsCloudConsentOrManual) {
        if (!context.mounted) return;
        final canonicalPayload =
            outcome.redactedPreview ??
            ReviewCoordinator.canonicalCloudPayload(policyText);
        final decision = await CloudConsentSheet.show(
          context,
          subjectTitle: displayTitle,
          policyText: policyText,
          canonicalRedactedPreview: canonicalPayload,
          deviceReason: outcome.errorReason,
        );
        if (!mounted ||
            seq != _attachSequence ||
            decision == CloudConsentDecision.cancelled) {
          return;
        }
        reqId = 'att_${DateTime.now().microsecondsSinceEpoch}';
        setState(() {
          _attachRequestId = reqId;
          _isAttachingCloud = decision == CloudConsentDecision.useCloudOnce;
        });
        outcome = await widget.coordinator.runPolicyReview(
          requestId: reqId,
          subjectTitle: displayTitle,
          sourceLabel: sourceLabel,
          policyText: policyText,
          appPermissions: snapshot,
          cloudConsent: decision == CloudConsentDecision.useCloudOnce,
          forceLocalManualScan: decision == CloudConsentDecision.reviewLocally,
          languageCode: lang,
          sourceSnapshot: sourceSnapshot,
          canonicalRedactedPayload:
              decision == CloudConsentDecision.useCloudOnce
              ? canonicalPayload
              : null,
        );
      }

      if (!mounted || seq != _attachSequence || outcome.receipt == null) return;
      final rawUpdated = outcome.receipt!;
      final draftIdentity = _nextSafeDraftIdentity(
        candidateId: rawUpdated.id,
        candidateCreatedAt: rawUpdated.createdAt,
      );
      final updated = rawUpdated.copyWith(
        id: draftIdentity.id,
        createdAt: draftIdentity.createdAt,
        supersedesReceiptId: draftIdentity.supersedesReceiptId,
      );
      // Do NOT auto-save when attaching or updating a policy: keep historical
      // receipts untouched and require an explicit Save action.
      _cancelVoiceAndSummarySilently();
      setState(() {
        _activeReceipt = updated;
        _activeAssociationReport = intake!.associationReport;
        _lifecycleState = _persistedBaselineReceipt != null
            ? ReceiptLifecycleState.modifiedSavedDraft
            : ReceiptLifecycleState.draft;
        _saveErrorMessage = null;
        _voiceSummary = DeniVoiceSummaryBuilder.buildDeterministic(
          receipt: updated,
          associationReport: intake.associationReport,
          languageCode: updated.languageCode,
        );
      });
      unawaited(_refreshVoiceSummaryOnDeviceFirst());
    } on HybridOperationCancelledException catch (e) {
      if (mounted && seq == _attachSequence && e.isTimeout) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.cloudTimedOutNotice),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted && seq == _attachSequence) {
        setState(() {
          _isAttachingPolicy = false;
          _isAttachingCloud = false;
          _isCancellingAttach = false;
          _attachRequestId = null;
        });
      }
    }
  }

  Future<bool> _handleSave(
    BuildContext context,
    AppLocalizations l10n,
    PolicyReviewReceipt receipt,
  ) async {
    if (_lifecycleState == ReceiptLifecycleState.saved) return true;
    if (_lifecycleState == ReceiptLifecycleState.saving) return false;
    if (!_canPersist) return false;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _lifecycleState = ReceiptLifecycleState.saving;
      _saveErrorMessage = null;
    });

    try {
      if (widget.onSaveReceipt != null) {
        await widget.onSaveReceipt!(receipt);
      } else if (widget.receiptRepository != null) {
        await widget.receiptRepository!.saveReceipt(receipt);
      }
      if (!mounted) return true;
      setState(() {
        _lifecycleState = ReceiptLifecycleState.saved;
        _persistedBaselineReceipt = receipt;
        _saveErrorMessage = null;
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.savedToLocalReceiptsSnack),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return true;
    } catch (_) {
      if (!mounted) return false;
      const errMsg =
          'Could not save receipt. Your review draft is still open.';
      setState(() {
        _lifecycleState = ReceiptLifecycleState.saveFailure;
        _saveErrorMessage = errMsg;
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(errMsg),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return false;
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    AppLocalizations l10n,
    PolicyReviewReceipt receipt,
  ) async {
    if (_lifecycleState != ReceiptLifecycleState.saved ||
        !_canDelete ||
        _isDeleting) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isDeleting = true);
    try {
      if (widget.onDeleteReceipt != null) {
        await widget.onDeleteReceipt!(receipt.id);
      } else if (widget.receiptRepository != null) {
        await widget.receiptRepository!.deleteReceipt(receipt.id);
      }
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _lifecycleState = ReceiptLifecycleState.deleted;
        _persistedBaselineReceipt = null;
        _saveErrorMessage = null;
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Removed from saved receipts.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Could not remove saved receipt.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<bool> _requestExternalExit() async {
    if (_pendingExitCompleter != null) {
      return _pendingExitCompleter!.future;
    }
    if (!mounted || _isExiting) return true;
    if (_lifecycleState == ReceiptLifecycleState.saving) {
      return false;
    }

    // Dismiss any transient sheet/dialog stacked above this ReviewResultScreen
    // (for example WhyThisFindingSheet, UnifiedPolicyIntakeSheet, or
    // CloudConsentSheet) before consulting this screen's unsaved-draft guard.
    final myRoute = ModalRoute.of(context);
    if (myRoute != null && !myRoute.isCurrent) {
      Navigator.of(context).popUntil((route) => route == myRoute);
    }
    if (!mounted) return true;

    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    return _handleExitRequest(context, l10n);
  }

  Future<bool> _handleExitRequest(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    if (_pendingExitCompleter != null) {
      return _pendingExitCompleter!.future;
    }
    if (_isExiting) return true;
    if (!_requiresExitConfirmation) {
      _isExiting = true;
      await Navigator.of(context).maybePop();
      if (mounted) _isExiting = false;
      return true;
    }
    if (_isExitSheetOpen || _lifecycleState == ReceiptLifecycleState.saving) {
      return false;
    }

    final completer = Completer<bool>();
    _pendingExitCompleter = completer;
    _isExitSheetOpen = true;
    var exited = false;
    try {
      final decision = await UnsavedReviewExitSheet.show(
        context,
        isModifiedSavedDraft:
            _lifecycleState == ReceiptLifecycleState.modifiedSavedDraft,
      );
      _isExitSheetOpen = false;
      if (!mounted || !context.mounted || _isExiting) {
        exited = !mounted || _isExiting;
        return exited;
      }

      switch (decision) {
        case UnsavedReviewExitDecision.continueReviewing:
        case null:
          exited = false;
          return false;
        case UnsavedReviewExitDecision.discard:
          _isExiting = true;
          setState(() {
            _lifecycleState = ReceiptLifecycleState.discarded;
            _allowImmediatePop = true;
          });
          Navigator.of(context).pop();
          exited = true;
          return true;
        case UnsavedReviewExitDecision.save:
          final savedOk = await _handleSave(context, l10n, _activeReceipt);
          if (savedOk && mounted && context.mounted && !_isExiting) {
            _isExiting = true;
            setState(() => _allowImmediatePop = true);
            Navigator.of(context).pop();
            exited = true;
            return true;
          }
          exited = false;
          return false;
      }
    } finally {
      _isExitSheetOpen = false;
      if (!completer.isCompleted) {
        completer.complete(exited);
      }
      if (identical(_pendingExitCompleter, completer)) {
        _pendingExitCompleter = null;
      }
    }
  }

  void _showSnapshotReceiptSheet(
    BuildContext context,
    AppLocalizations l10n,
    PolicyReviewReceipt receipt,
  ) {
    final dt = receipt.createdAt;
    final dateStr =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return EnpriveM3EBridgeScope.ensure(
          sheetContext,
          child: Builder(
            builder: (innerContext) {
              final m3e = EnpriveM3ETheme.of(innerContext);
              final scheme = m3e.colorScheme;
              final innerSurfaces = innerContext.enpriveSurfaces;
              final typeExt = innerContext.enpriveType;

              return Material(
                color: innerSurfaces.canvas,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                clipBehavior: Clip.antiAlias,
                child: DraggableScrollableSheet(
                  initialChildSize: 0.68,
                  minChildSize: 0.45,
                  maxChildSize: 0.92,
                  expand: false,
                  builder: (_, scrollController) {
                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: scheme.outlineVariant,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.snapshotSheetTitle,
                          style: m3e.typography.emphasized.headlineSmall
                              .copyWith(color: scheme.onSurface),
                        ),
                        const SizedBox(height: 14),
                        EnpriveMaterialCardSurface(
                          variant: EnpriveCardVariant.elevated,
                          backgroundColor: innerSurfaces.card,
                          borderRadius: BorderRadius.circular(EnpriveRadii.lg),
                          lipHeight: 2.5,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.snapshotSourcePrefix} · ${receipt.sourceLabel}',
                                style: m3e.typeScale.titleSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.snapshotReviewedPrefix} · $dateStr',
                                style: m3e.typeScale.bodySmall.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              if (receipt.snapshotDigest.trim().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: innerSurfaces.cardMuted,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: innerSurfaces.hairlineBorder,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${l10n.snapshotDigestLabel} · #${receipt.snapshotDigest}',
                                              style: typeExt.sha256Hash
                                                  .copyWith(
                                                    color: scheme.onSurface,
                                                  ),
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text: receipt.snapshotDigest,
                                                ),
                                              );
                                              ScaffoldMessenger.of(innerContext)
                                                ..hideCurrentSnackBar()
                                                ..showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.digestCopiedMsg,
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                            },
                                            icon: Icon(
                                              LucideIcons.copy,
                                              size: 14,
                                              color: scheme.primary,
                                            ),
                                            label: Text(l10n.copyDigestBtn),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.snapshotDigestExplanation,
                                        style: m3e.typeScale.bodySmall.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          height: 1.38,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (receipt.sourceSnapshot != null) ...[
                                const SizedBox(height: 10),
                                _SourceProvenanceBlock(
                                  snapshot: receipt.sourceSnapshot!,
                                  l10n: l10n,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (receipt.snapshotText.trim().isNotEmpty)
                          EnpriveQuoteCard(
                            quote: receipt.snapshotText,
                            sha256Digest: receipt.snapshotDigest,
                            footerCaption: l10n.snapshotDigestExplanation,
                            borderRadius: BorderRadius.circular(
                              EnpriveRadii.xl,
                            ),
                            padding: const EdgeInsets.all(20),
                          )
                        else
                          EnpriveMaterialCardSurface(
                            variant: EnpriveCardVariant.elevated,
                            backgroundColor: innerSurfaces.card,
                            borderRadius: BorderRadius.circular(
                              EnpriveRadii.xl,
                            ),
                            lipHeight: 2.5,
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              receipt.summary,
                              style: m3e.typeScale.bodyMedium.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final receipt = _activeReceipt;
          final validSnapshot = _validPermissionSnapshot(receipt);
          final isSampleReceipt = _isSampleReceipt(receipt);
          final canTwoWayLink =
              !receipt.isPermissionOnlyInspection &&
              !isSampleReceipt &&
              receipt.snapshotText.trim().isNotEmpty;
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final surfaces = context.enpriveSurfaces;
          final semantics = context.enpriveSemantics;
          final margin = EnpriveSpacing.marginFor(
            MediaQuery.sizeOf(context).width,
          );
          final (_, _, stateTitle, stateSubtitle) = _stateConfig(
            l10n,
            semantics,
          );
          final MaterialLocalizations? matL10n =
              Localizations.of<MaterialLocalizations>(
                context,
                MaterialLocalizations,
              );
          final String formattedDate = matL10n != null
              ? matL10n.formatShortMonthDay(receipt.createdAt)
              : '${receipt.createdAt.year}-${receipt.createdAt.month.toString().padLeft(2, '0')}-${receipt.createdAt.day.toString().padLeft(2, '0')}';

          return PopScope(
            canPop: !_requiresExitConfirmation,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              unawaited(_handleExitRequest(context, l10n));
            },
            child: Scaffold(
              backgroundColor: surfaces.canvas,
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top Navigation Row on calm editorial canvas
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: l10n.tooltipClose,
                            onPressed: () =>
                                unawaited(_handleExitRequest(context, l10n)),
                            icon: Icon(
                              LucideIcons.x,
                              size: 22,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerEnd,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () => _showSnapshotReceiptSheet(
                                    context,
                                    l10n,
                                    receipt,
                                  ),
                                  child: EnpriveProvenanceChip(
                                    source: receipt.inferenceSource,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_canPersist || _isSaved) ...[
                            const SizedBox(width: 4),
                            IconButton(
                                isSelected: _isSaved,
                                style: IconButton.styleFrom(
                                  backgroundColor: _isSaved
                                      ? scheme.secondaryContainer
                                      : null,
                                ),
                                key: const Key('review_result_save_btn'),
                                tooltip: _isSaved
                                    ? l10n.btnSavedToReceipts
                                    : l10n.btnSaveToReceipts,
                                onPressed:
                                    _lifecycleState ==
                                        ReceiptLifecycleState.saving
                                    ? null
                                    : () => unawaited(
                                        _handleSave(context, l10n, receipt),
                                      ),
                                icon:
                                    _lifecycleState ==
                                        ReceiptLifecycleState.saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        _isSaved
                                            ? LucideIcons.bookmarkCheck
                                            : LucideIcons.bookmarkPlus,
                                        size: 20,
                                        color: _isSaved
                                            ? scheme.onSecondaryContainer
                                            : scheme.onSurface,
                                      ),
                            ),
                          ],
                          if (_isSaved && _canDelete) ...[
                            const SizedBox(width: 4),
                            IconButton(
                                key: const Key('review_result_delete_btn'),
                                tooltip: l10n.btnDelete,
                                onPressed: _isDeleting
                                    ? null
                                    : () => unawaited(
                                        _handleDelete(context, l10n, receipt),
                                      ),
                                icon: Icon(
                                  LucideIcons.trash2,
                                  size: 20,
                                  color: scheme.onSurfaceVariant,
                                ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Scrollable M3E Hero Posture Card + Editorial Evidence Sheet
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          margin,
                          4,
                          margin,
                          MediaQuery.of(context).padding.bottom + 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EnpriveReviewHeroCard(
                              subjectTitle: receipt.subjectTitle,
                              subtitle: '${receipt.sourceLabel} · $formattedDate',
                              overallState: receipt.overallState,
                              stateBadgeLabel: stateTitle,
                              findingsCountValue: '${receipt.findings.length}',
                              findingsLabel: l10n.statFindings,
                              verifiedCountValue:
                                  '${receipt.sourceMatchedCount}',
                              verifiedLabel: l10n.statVerified,
                              secondaryMetricValue:
                                  receipt.permissionReport != null
                                  ? '${receipt.permissionReport!.grantedSensitiveCount}'
                                  : '${receipt.unverifiedCount}',
                              secondaryMetricLabel:
                                  receipt.permissionReport != null
                                  ? (isSampleReceipt
                                        ? l10n.permissionAllowedInSample
                                        : l10n.statOsGranted)
                                  : l10n.statUnverified,
                              hasPermissionReport:
                                  receipt.permissionReport != null,
                              mascotPose: _statePose,
                              sourceActionLabel:
                                  receipt.isPermissionOnlyInspection
                                  ? l10n.permissionInspectionTitle
                                  : l10n.snapshotSourcePrefix,
                              sourceActionTooltip:
                                  receipt.isPermissionOnlyInspection
                                  ? l10n.addAppPrivacyPolicyBtn
                                  : l10n.viewReviewedSnapshot,
                              onSourceAction: () {
                                if (receipt.isPermissionOnlyInspection) {
                                  _openAttachPolicySheet(
                                    context,
                                    l10n,
                                    receipt,
                                  );
                                } else {
                                  _showSnapshotReceiptSheet(
                                    context,
                                    l10n,
                                    receipt,
                                  );
                                }
                              },
                              isSpeaking: _isSpeaking,
                              voiceTooltip: _isSpeaking
                                  ? l10n.voiceTooltipStopReading
                                  : l10n.voiceTooltipReadSummary,
                              onVoiceAction: () => _toggleVoicePlayback(l10n),
                              primaryCtaLabel:
                                  receipt.isPermissionOnlyInspection
                                  ? l10n.addAppPrivacyPolicyBtn
                                  : (receipt.findings.isNotEmpty
                                        ? l10n.btnAskDeni
                                        : (_canPersist
                                              ? (_isSaved
                                                    ? l10n.btnSavedToReceipts
                                                    : l10n.btnSaveToReceipts)
                                              : l10n.viewReviewedSnapshot)),
                              onPrimaryCta: () {
                                if (receipt.isPermissionOnlyInspection) {
                                  _openAttachPolicySheet(
                                    context,
                                    l10n,
                                    receipt,
                                  );
                                } else if (receipt.findings.isNotEmpty) {
                                  _openFindingDetails(receipt.findings.first);
                                } else if (_canPersist) {
                                  unawaited(
                                    _handleSave(context, l10n, receipt),
                                  );
                                } else {
                                  _showSnapshotReceiptSheet(
                                    context,
                                    l10n,
                                    receipt,
                                  );
                                }
                              },
                              onMascotTap: () => _toggleVoicePlayback(l10n),
                              categoryCounts: EvidenceCategoryStyle.countsOf(
                                receipt.findings,
                              ),
                              primaryCtaShowsDeni:
                                  !receipt.isPermissionOnlyInspection &&
                                  receipt.findings.isNotEmpty,
                            ),
                            const SizedBox(height: 18),

                            DeniVoiceSummaryCard(
                              summary: _effectiveVoiceSummary,
                              isGeneratingSummary: _isGeneratingSummary,
                              playbackState: _voicePlaybackState,
                              activeRoute: _activeVoiceRoute,
                              statusNotice: _voiceStatusNotice,
                              onPlayOffline: () =>
                                  unawaited(_playSummaryLocally(l10n)),
                              onPlayExpressiveCloud: () => unawaited(
                                _requestExpressiveVoicePlayback(l10n),
                              ),
                              onStop: () => unawaited(_stopVoicePlayback()),
                              onEnhanceSummaryWithCloud: () =>
                                  unawaited(_enhanceSummaryWithCloud(l10n)),
                              onOpenFinding: _openFindingById,
                            ),
                            const SizedBox(height: 22),

                            if (_isAttachingPolicy) ...[
                              ReviewProgressCard(
                                subjectTitle: receipt.subjectTitle,
                                isCloudCheck: _isAttachingCloud,
                                processStream: widget.coordinator.analysisEvents,
                                onCancel: () => _cancelAttachPolicy(l10n),
                                isCancelling: _isCancellingAttach,
                              ),
                              const SizedBox(height: 18),
                            ],

                            if (_lifecycleState ==
                                ReceiptLifecycleState.modifiedSavedDraft) ...[
                              EnpriveMaterialCardSurface(
                                key: const Key(
                                  'review_result_modified_draft_banner',
                                ),
                                variant: EnpriveCardVariant.outlined,
                                backgroundColor: semantics.onDevice.background
                                    .withValues(alpha: 0.55),
                                borderColor: semantics.onDevice.border,
                                borderRadius: BorderRadius.circular(
                                  EnpriveRadii.lg,
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      LucideIcons.gitBranch,
                                      size: 18,
                                      color: semantics.onDevice.foreground,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'New draft from saved receipt',
                                            style: m3e.typeScale.labelLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: scheme.onSurface,
                                                ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Save to Receipts to keep this updated review — your original saved receipt remains unchanged.',
                                            style: m3e.typeScale.bodySmall
                                                .copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                  height: 1.38,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (_lifecycleState ==
                                    ReceiptLifecycleState.saveFailure &&
                                _saveErrorMessage != null) ...[
                              EnpriveMaterialCardSurface(
                                key: const Key(
                                  'review_result_save_failure_banner',
                                ),
                                variant: EnpriveCardVariant.outlined,
                                backgroundColor: semantics
                                    .reviewRecommended
                                    .background
                                    .withValues(alpha: 0.55),
                                borderColor: semantics.reviewRecommended.border,
                                borderRadius: BorderRadius.circular(
                                  EnpriveRadii.lg,
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      LucideIcons.triangleAlert,
                                      size: 18,
                                      color: semantics
                                          .reviewRecommended
                                          .foreground,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _saveErrorMessage!,
                                            style: m3e.typeScale.bodySmall
                                                .copyWith(
                                                  color: scheme.onSurface,
                                                  height: 1.38,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          if (_canPersist) ...[
                                            const SizedBox(height: 6),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                minimumSize: const Size(48, 36),
                                              ),
                                              onPressed: () => unawaited(
                                                _handleSave(
                                                  context,
                                                  l10n,
                                                  receipt,
                                                ),
                                              ),
                                              child: const Text('Retry save'),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                          // Summary & Calibrated Note
                          Text(
                            receipt.summary,
                            style: m3e.typeScale.bodyLarge.copyWith(
                              height: 1.5,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stateSubtitle,
                            style: m3e.typeScale.bodySmall.copyWith(
                              height: 1.4,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (receipt.diagnosticKind ==
                              ReviewDiagnosticKind
                                  .cloudUnavailableLocalFallback) ...[
                            const SizedBox(height: 14),
                            EnpriveMaterialCardSurface(
                              key: const ValueKey<String>(
                                'cloud_fallback_notice_card',
                              ),
                              variant: EnpriveCardVariant.outlined,
                              backgroundColor: semantics.inCloud.background
                                  .withValues(alpha: 0.45),
                              borderColor: semantics.inCloud.border,
                              borderRadius: BorderRadius.circular(
                                EnpriveRadii.lg,
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    LucideIcons.cloudOff,
                                    size: 18,
                                    color: semantics.inCloud.foreground,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.cloudFallbackBannerTitle,
                                          style: m3e.typeScale.labelLarge
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: scheme.onSurface,
                                              ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          l10n.cloudFallbackBannerBody,
                                          style: m3e.typeScale.bodySmall
                                              .copyWith(
                                                color: scheme.onSurfaceVariant,
                                                height: 1.38,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (receipt.processSteps.isNotEmpty ||
                              receipt.thoughtSummary != null ||
                              receipt.thoughtSignature != null) ...[
                            const SizedBox(height: 18),
                            AnalysisSavedTraceCard(
                              processSteps: receipt.processSteps,
                              thoughtSummary: receipt.thoughtSummary,
                              thoughtSignature: receipt.thoughtSignature,
                            ),
                          ],
                          const SizedBox(height: 28),

                          // Findings or Permission-Only Inspection Section
                          Text(
                            receipt.isPermissionOnlyInspection
                                ? l10n.permissionInspectionTitle
                                : (receipt.findings.isNotEmpty
                                      ? l10n.keyFindingsTitle
                                      : l10n.reviewedExcerptTitle),
                            style: m3e.typeScale.titleLarge.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                          if (!receipt.isPermissionOnlyInspection &&
                              receipt.deviceObservedCount > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.quotesVerifiedCount(receipt.sourceMatchedCount)} · ${l10n.observedOnPhoneCount(receipt.deviceObservedCount)}',
                              style: m3e.typeScale.bodyMedium.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          if (receipt.isPermissionOnlyInspection)
                            EnpriveMaterialCardSurface(
                              variant: EnpriveCardVariant.elevated,
                              backgroundColor: surfaces.card,
                              borderRadius: BorderRadius.circular(
                                EnpriveRadii.lg,
                              ),
                              lipHeight: 2.5,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (receipt.permissionReport != null) ...[
                                    Text(
                                      '${receipt.permissionReport!.snapshot.appName} · ${receipt.permissionReport!.snapshot.packageName}',
                                      style: m3e.typeScale.titleSmall.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      receipt.permissionReport!.limitationNotice,
                                      style: m3e.typeScale.bodySmall.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  EnpriveTactileButton(
                                    label: l10n.addAppPrivacyPolicyBtn,
                                    isSecondary: true,
                                    onPressed:
                                        (_isAttachingPolicy ||
                                            _isOpeningAttachSheet ||
                                            validSnapshot == null)
                                        ? null
                                        : () => _openAttachPolicySheet(
                                            context,
                                            l10n,
                                            receipt,
                                          ),
                                  ),
                                ],
                              ),
                            )
                          else if (receipt.findings.isEmpty)
                            if (receipt.snapshotText.trim().isNotEmpty)
                              EnpriveQuoteCard(
                                quote: receipt.snapshotText,
                                sha256Digest: receipt.snapshotDigest,
                                footerCaption: l10n.snapshotDigestExplanation,
                                borderRadius: BorderRadius.circular(
                                  EnpriveRadii.lg,
                                ),
                                padding: const EdgeInsets.all(20),
                              )
                            else
                              EnpriveMaterialCardSurface(
                                variant: EnpriveCardVariant.elevated,
                                backgroundColor: surfaces.card,
                                borderRadius: BorderRadius.circular(
                                  EnpriveRadii.lg,
                                ),
                                lipHeight: 2.5,
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  receipt.summary,
                                  style: m3e.typeScale.bodyMedium.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    height: 1.45,
                                  ),
                                ),
                              )
                          else
                            ...receipt.findings.asMap().entries.map(
                              (entry) => Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      entry.key < receipt.findings.length - 1
                                      ? 2.0
                                      : 0.0,
                                ),
                                child: EnpriveFindingRow(
                                  finding: entry.value,
                                  index: entry.key,
                                  totalCount: receipt.findings.length,
                                  proofLabel: _proofLabelFor(
                                    entry.value,
                                    l10n,
                                    isSampleReceipt: isSampleReceipt,
                                  ),
                                  reviewChipLabel:
                                      entry.value.severity ==
                                          FindingSeverity.high
                                      ? l10n.findingReviewChip
                                      : null,
                                  onTap: () => _openFindingDetailPage(
                                    receipt,
                                    entry.key,
                                    isSampleReceipt: isSampleReceipt,
                                  ),
                                ),
                              ),
                            ),

                          // Two-Way App Linking & On-Device Permission Comparison Section
                          if (canTwoWayLink) ...[
                            const SizedBox(height: 24),
                            EnpriveLinkedAppSection(
                              permissionReport: validSnapshot != null
                                  ? receipt.permissionReport
                                  : null,
                              associationReport: _activeAssociationReport,
                              bridge: widget.coordinator.bridge,
                              l10n: l10n,
                              isBusy:
                                  _isAttachingPolicy ||
                                  _isOpeningAttachSheet ||
                                  _isOpeningLinkPicker,
                              onLinkApp: () => unawaited(
                                _openLinkAppPicker(
                                  context,
                                  l10n,
                                  isChanging: false,
                                ),
                              ),
                              onChangeApp: () => unawaited(
                                _openLinkAppPicker(
                                  context,
                                  l10n,
                                  isChanging: true,
                                ),
                              ),
                              onUnlinkApp: () =>
                                  _unlinkInstalledApp(context, l10n),
                            ),
                            if (validSnapshot != null) ...[
                              const SizedBox(height: 16),
                              EnpriveTactileButton(
                                key: const Key(
                                  'review_result_attach_new_policy_btn',
                                ),
                                label: l10n.btnUpdatePrivacyPolicy,
                                isSecondary: true,
                                onPressed:
                                    (_isAttachingPolicy ||
                                        _isOpeningAttachSheet ||
                                        _isOpeningLinkPicker)
                                    ? null
                                    : () => _openAttachPolicySheet(
                                        context,
                                        l10n,
                                        receipt,
                                      ),
                              ),
                            ],
                          ] else ...[
                            // Permission-Only Inspection or Synthetic Sample Permissions
                            if (receipt.permissionReport != null &&
                                receipt.permissionReport!.items.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                isSampleReceipt
                                    ? 'Sample permissions (${l10n.sampleSyntheticBadge})'
                                    : l10n.permissionsOnPhoneTitle,
                                style: m3e.typeScale.titleLarge.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              EnprivePermissionComparisonList(
                                report: receipt.permissionReport!,
                                l10n: l10n,
                                isSampleReceipt: isSampleReceipt,
                              ),
                            ],
                            if (validSnapshot != null &&
                                !receipt.isPermissionOnlyInspection &&
                                !isSampleReceipt) ...[
                              const SizedBox(height: 16),
                              EnpriveTactileButton(
                                key: const Key(
                                  'review_result_attach_new_policy_btn',
                                ),
                                label: l10n.btnUpdatePrivacyPolicy,
                                isSecondary: true,
                                onPressed:
                                    (_isAttachingPolicy ||
                                        _isOpeningAttachSheet ||
                                        _isOpeningLinkPicker)
                                    ? null
                                    : () => _openAttachPolicySheet(
                                        context,
                                        l10n,
                                        receipt,
                                      ),
                              ),
                            ],
                            if (_activeAssociationReport != null &&
                                (_activeAssociationReport!.state ==
                                        AppPolicyAssociationState.unmatched ||
                                    _activeAssociationReport!.state ==
                                        AppPolicyAssociationState
                                            .ambiguousIdentity)) ...[
                              const SizedBox(height: 16),
                              EnpriveMaterialCardSurface(
                                key: const Key(
                                  'review_result_association_notice',
                                ),
                                variant: EnpriveCardVariant.outlined,
                                backgroundColor: semantics
                                    .reviewRecommended
                                    .background
                                    .withValues(alpha: 0.55),
                                borderColor: semantics.reviewRecommended.border,
                                borderRadius: BorderRadius.circular(
                                  EnpriveRadii.lg,
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      LucideIcons.triangleAlert,
                                      size: 18,
                                      color: semantics
                                          .reviewRecommended
                                          .foreground,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _activeAssociationReport!
                                                .explanation,
                                            style: m3e.typeScale.bodySmall
                                                .copyWith(
                                                  color: scheme.onSurface,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.38,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _activeAssociationReport!
                                                .ownershipLimitationNotice,
                                            style: m3e.typeScale.bodySmall
                                                .copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                  height: 1.38,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                          if (receipt.sourceSnapshot != null &&
                              (receipt.sourceSnapshot!.canonicalUrl != null ||
                                  receipt.sourceSnapshot!.originalFilename !=
                                      null ||
                                  receipt.sourceSnapshot!.sourceSha256Hash
                                      .isNotEmpty)) ...[
                            const SizedBox(height: 20),
                            _SourceProvenanceBlock(
                              snapshot: receipt.sourceSnapshot!,
                              l10n: l10n,
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Localized calibrated non-certification notice anchored strictly
                          // to trusted app resources (never raw model JSON strings).
                          EnpriveMaterialCardSurface(
                            variant: EnpriveCardVariant.outlined,
                            backgroundColor: surfaces.cardMuted,
                            borderRadius: BorderRadius.circular(
                              EnpriveRadii.lg,
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  LucideIcons.info,
                                  size: 16,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.stateNoConcernSubtitle,
                                    style: m3e.typeScale.bodySmall.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!receipt.isPermissionOnlyInspection &&
                              receipt.snapshotText.trim().isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Center(
                              child: TextButton(
                                onPressed: () => _showSnapshotReceiptSheet(
                                  context,
                                  l10n,
                                  receipt,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.fileText,
                                      size: 17,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        l10n.viewReviewedSnapshot,
                                        textAlign: TextAlign.center,
                                        style: m3e.typeScale.labelLarge
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SourceProvenanceBlock extends StatelessWidget {
  final PolicySourceSnapshot snapshot;
  final AppLocalizations l10n;

  const _SourceProvenanceBlock({
    required this.snapshot,
    required this.l10n,
  });

  String _formatUtcTimestamp(DateTime dt) {
    final u = dt.toUtc();
    return '${u.year}-${u.month.toString().padLeft(2, '0')}-${u.day.toString().padLeft(2, '0')} '
        '${u.hour.toString().padLeft(2, '0')}:${u.minute.toString().padLeft(2, '0')} UTC';
  }

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final typeExt = context.enpriveType;

    final sourceKindLabel = switch (snapshot.sourceType) {
      PolicySourceType.url => 'Public URL',
      PolicySourceType.pdf => 'Local PDF document',
      PolicySourceType.docx => 'Local DOCX document',
      PolicySourceType.textDocument => 'Local text document',
      PolicySourceType.sharedText => 'Shared text',
      PolicySourceType.selectedText => 'Selected text',
      PolicySourceType.sample => 'Synthetic sample',
      PolicySourceType.devicePermissions => 'Android permissions',
      PolicySourceType.pastedText => 'Pasted text',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaces.cardMuted,
        borderRadius: BorderRadius.circular(EnpriveRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Source provenance · $sourceKindLabel (${_formatUtcTimestamp(snapshot.retrievedAt)})',
            style: m3e.typeScale.labelMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          if (snapshot.canonicalUrl != null &&
              snapshot.canonicalUrl!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Canonical URL: ${snapshot.canonicalUrl}',
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (snapshot.hasRedirect &&
              snapshot.requestedUrl != null &&
              snapshot.requestedUrl!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Redirected from: ${snapshot.requestedUrl}',
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (snapshot.originalFilename != null &&
              snapshot.originalFilename!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'File: ${snapshot.originalFilename}'
              '${snapshot.mimeType != null ? ' (${snapshot.mimeType})' : ''}'
              ' · Status: ${snapshot.extractionStatus.name}',
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (snapshot.sourceSha256Hash.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'SHA-256 source hash: ${snapshot.sourceSha256Hash}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typeExt.sha256Hash.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: snapshot.sourceSha256Hash),
                    );
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(l10n.digestCopiedMsg),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  },
                  icon: Icon(
                    LucideIcons.copy,
                    size: 14,
                    color: scheme.primary,
                  ),
                  label: Text(l10n.copyDigestBtn),
                ),
              ],
            ),
          ],
          if (snapshot.limitationNote != null &&
              snapshot.limitationNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              snapshot.limitationNote!,
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
