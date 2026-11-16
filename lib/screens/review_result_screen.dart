import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/permissions/permission_comparator.dart';
import '../domain/review/policy_sufficiency.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../services/intake/policy_intake_helper.dart';
import '../services/network/policy_url_retriever.dart';
import '../widgets/analysis_process_trace.dart';
import '../widgets/cloud_consent_sheet.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_provenance_chip.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/m3e/enprive_m3e_components.dart';
import '../widgets/why_this_finding_sheet.dart';

/// Material 3 Expressive Evidence Result Screen:
/// - Archival canvas with [EnpriveReviewHeroCard] (inset teal mesh banner,
///   overlapping Deni Standard LOD medallion, borderless 3-column metrics, and
///   leading-arrow tactile CTA)
/// - Segmented quote-first `M3ECard` finding cards (`EnpriveRadii.groupedCardRadius`)
/// - Contextual bookmark save action in top bar when reviewing unsaved results
class ReviewResultScreen extends StatefulWidget {
  final PolicyReviewReceipt receipt;
  final ReviewCoordinator coordinator;
  final ValueChanged<PolicyReviewReceipt>? onSaveReceipt;
  final bool cloudConsentGrantedForSession;
  final PolicyUrlRetriever? urlRetriever;

  const ReviewResultScreen({
    super.key,
    required this.receipt,
    required this.coordinator,
    this.onSaveReceipt,
    this.cloudConsentGrantedForSession = false,
    this.urlRetriever,
  });

  @override
  State<ReviewResultScreen> createState() => _ReviewResultScreenState();
}

class _ReviewResultScreenState extends State<ReviewResultScreen> {
  late PolicyReviewReceipt _activeReceipt = widget.receipt;
  bool _isSaved = false;
  bool _isSpeaking = false;
  bool _isAttachingPolicy = false;

  @override
  void didUpdateWidget(covariant ReviewResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receipt != widget.receipt) {
      _activeReceipt = widget.receipt;
    }
  }

  @override
  void dispose() {
    if (_isSpeaking) {
      widget.coordinator.bridge.stopSpeaking();
    }
    super.dispose();
  }

  DeniPose get _statePose {
    if (_isSpeaking) return DeniPose.listening;
    if (_isSaved) return DeniPose.celebrating;
    return switch (_activeReceipt.overallState) {
      ReviewOverallState.reviewRecommended => DeniPose.explaining,
      ReviewOverallState.noConcern => DeniPose.idle,
      ReviewOverallState.insufficientEvidence => DeniPose.support,
    };
  }

  Future<void> _toggleVoicePlayback(String stateTitle) async {
    if (_isSpeaking) {
      await widget.coordinator.bridge.stopSpeaking();
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    final lang = Localizations.localeOf(context).languageCode;
    final spokenText =
        '${_activeReceipt.subjectTitle}. $stateTitle. ${_activeReceipt.summary}';
    await widget.coordinator.bridge.speakText(spokenText, languageCode: lang);
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

  Future<void> _openAttachPolicySheet(
    BuildContext context,
    AppLocalizations l10n,
    PolicyReviewReceipt receipt,
  ) async {
    final snapshot = receipt.permissionReport?.snapshot;
    if (snapshot == null || _isAttachingPolicy) return;

    final lang = Localizations.localeOf(context).languageCode;
    final attached = await showModalBottomSheet<_AttachedPolicyInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttachPolicySheet(
        appName: snapshot.appName,
        packageName: snapshot.packageName,
        coordinator: widget.coordinator,
        urlRetriever: widget.urlRetriever ?? PolicyUrlRetriever(),
        l10n: l10n,
      ),
    );

    if (attached == null || !mounted) return;

    setState(() => _isAttachingPolicy = true);
    try {
      final sourceLabel = '${receipt.sourceLabel} · ${attached.sourceLabel}';
      var outcome = await widget.coordinator.runPolicyReview(
        subjectTitle: receipt.subjectTitle,
        sourceLabel: sourceLabel,
        policyText: attached.policyText,
        appPermissions: snapshot,
        languageCode: lang,
        sourceSnapshot: attached.sourceSnapshot,
      );

      if (outcome.needsCloudConsentOrManual) {
        if (!mounted || !context.mounted) return;
        final canonicalPayload =
            outcome.redactedPreview ??
            ReviewCoordinator.canonicalCloudPayload(attached.policyText);
        final decision = await CloudConsentSheet.show(
          context,
          subjectTitle: receipt.subjectTitle,
          policyText: attached.policyText,
          canonicalRedactedPreview: canonicalPayload,
          deviceReason: outcome.errorReason,
        );
        if (!mounted || decision == CloudConsentDecision.cancelled) return;
        outcome = await widget.coordinator.runPolicyReview(
          subjectTitle: receipt.subjectTitle,
          sourceLabel: sourceLabel,
          policyText: attached.policyText,
          appPermissions: snapshot,
          cloudConsent: decision == CloudConsentDecision.useCloudOnce,
          forceLocalManualScan: decision == CloudConsentDecision.reviewLocally,
          languageCode: lang,
          sourceSnapshot: attached.sourceSnapshot,
          canonicalRedactedPayload:
              decision == CloudConsentDecision.useCloudOnce
                  ? canonicalPayload
                  : null,
        );
      }

      if (!mounted || outcome.receipt == null) return;
      final updated = outcome.receipt!;
      setState(() {
        _activeReceipt = updated;
      });
      widget.onSaveReceipt?.call(updated);
    } finally {
      if (mounted) {
        setState(() => _isAttachingPolicy = false);
      }
    }
  }

  void _handleSave(
    BuildContext context,
    AppLocalizations l10n,
    PolicyReviewReceipt receipt,
  ) {
    if (_isSaved) return;
    setState(() => _isSaved = true);
    widget.onSaveReceipt?.call(receipt);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.savedToLocalReceiptsSnack),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final surfaces = context.enpriveSurfaces;
          final semantics = context.enpriveSemantics;
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

          return Scaffold(
            backgroundColor: surfaces.canvas,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Navigation Row on calm editorial canvas
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Material(
                          color: surfaces.card.withValues(alpha: 0.90),
                          shape: CircleBorder(
                            side: BorderSide(color: surfaces.hairlineBorder),
                          ),
                          child: IconButton(
                            tooltip: l10n.tooltipClose,
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              LucideIcons.x,
                              size: 20,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () =>
                              _showSnapshotReceiptSheet(context, l10n, receipt),
                          child: EnpriveProvenanceChip(
                            source: receipt.inferenceSource,
                          ),
                        ),
                        if (widget.onSaveReceipt != null) ...[
                          const SizedBox(width: 8),
                          Material(
                            color: _isSaved
                                ? semantics.noConcern.background
                                : surfaces.card.withValues(alpha: 0.90),
                            shape: CircleBorder(
                              side: BorderSide(
                                color: _isSaved
                                    ? semantics.noConcern.border
                                    : surfaces.hairlineBorder,
                              ),
                            ),
                            child: IconButton(
                              tooltip: _isSaved
                                  ? l10n.btnSavedToReceipts
                                  : l10n.btnSaveToReceipts,
                              onPressed: () =>
                                  _handleSave(context, l10n, receipt),
                              icon: Icon(
                                _isSaved
                                    ? LucideIcons.bookmarkCheck
                                    : LucideIcons.bookmarkPlus,
                                size: 19,
                                color: _isSaved
                                    ? semantics.noConcern.foreground
                                    : scheme.onSurface,
                              ),
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
                        20,
                        4,
                        20,
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
                            verifiedCountValue: '${receipt.sourceMatchedCount}',
                            verifiedLabel: l10n.statVerified,
                            secondaryMetricValue:
                                receipt.permissionReport != null
                                ? '${receipt.permissionReport!.grantedSensitiveCount}'
                                : '${receipt.unverifiedCount}',
                            secondaryMetricLabel:
                                receipt.permissionReport != null
                                ? l10n.statOsGranted
                                : l10n.statUnverified,
                            hasPermissionReport:
                                receipt.permissionReport != null,
                            mascotPose: _statePose,
                            sourceActionLabel: receipt.isPermissionOnlyInspection
                                ? l10n.permissionInspectionTitle
                                : l10n.snapshotSourcePrefix,
                            sourceActionTooltip: receipt.isPermissionOnlyInspection
                                ? l10n.addAppPrivacyPolicyBtn
                                : l10n.viewReviewedSnapshot,
                            onSourceAction: () {
                              if (receipt.isPermissionOnlyInspection) {
                                _openAttachPolicySheet(context, l10n, receipt);
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
                                ? 'Stop reading aloud'
                                : 'Read summary aloud',
                            onVoiceAction: () =>
                                _toggleVoicePlayback(stateTitle),
                            primaryCtaLabel: receipt.isPermissionOnlyInspection
                                ? l10n.addAppPrivacyPolicyBtn
                                : (receipt.findings.isNotEmpty
                                      ? l10n.btnAskDeni
                                      : (widget.onSaveReceipt != null
                                            ? (_isSaved
                                                  ? l10n.btnSavedToReceipts
                                                  : l10n.btnSaveToReceipts)
                                            : l10n.viewReviewedSnapshot)),
                            onPrimaryCta: () {
                              if (receipt.isPermissionOnlyInspection) {
                                _openAttachPolicySheet(context, l10n, receipt);
                              } else if (receipt.findings.isNotEmpty) {
                                _openFindingDetails(receipt.findings.first);
                              } else if (widget.onSaveReceipt != null) {
                                _handleSave(context, l10n, receipt);
                              } else {
                                _showSnapshotReceiptSheet(
                                  context,
                                  l10n,
                                  receipt,
                                );
                              }
                            },
                            onMascotTap: () => _toggleVoicePlayback(stateTitle),
                          ),
                          const SizedBox(height: 22),

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
                            style: m3e.typography.emphasized.titleMedium
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                          ),
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
                                    onPressed: _isAttachingPolicy
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
                                      ? 6.0
                                      : 0.0,
                                ),
                                child: _M3EFindingCard(
                                  finding: entry.value,
                                  index: entry.key,
                                  totalCount: receipt.findings.length,
                                  l10n: l10n,
                                  onTap: () => _openFindingDetails(entry.value),
                                ),
                              ),
                            ),

                          // Optional Permission Check Section
                          if (receipt.permissionReport != null &&
                              receipt.permissionReport!.items.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              l10n.permissionsOnPhoneTitle,
                              style: m3e.typography.emphasized.titleMedium
                                  .copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _M3EPermissionListCard(
                              report: receipt.permissionReport!,
                              l10n: l10n,
                            ),
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
                                  LucideIcons.shieldCheck,
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
                              child: TextButton.icon(
                                onPressed: () => _showSnapshotReceiptSheet(
                                  context,
                                  l10n,
                                  receipt,
                                ),
                                icon: Icon(
                                  LucideIcons.fileText,
                                  size: 17,
                                  color: scheme.onSurfaceVariant,
                                ),
                                label: Text(
                                  l10n.viewReviewedSnapshot,
                                  style: m3e.typeScale.labelLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurfaceVariant,
                                  ),
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
          );
        },
      ),
    );
  }
}

class _M3EFindingCard extends StatelessWidget {
  final VerifiedFinding finding;
  final int index;
  final int totalCount;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _M3EFindingCard({
    required this.finding,
    required this.index,
    required this.totalCount,
    required this.l10n,
    required this.onTap,
  });

  String _categoryLabel(FindingCategory category) {
    return switch (category) {
      FindingCategory.dataCollection => l10n.categoryDataCollection,
      FindingCategory.sharing => l10n.categorySharing,
      FindingCategory.tracking => l10n.categoryTracking,
      FindingCategory.retention => l10n.categoryRetention,
      FindingCategory.parentalConsent => l10n.categoryParentalControls,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = finding.isVerified;
    final String verifyLabel = finding.status == EvidenceStatus.deviceObserved
        ? l10n.observedOnPhoneLabel
        : (isVerified ? l10n.quoteVerifiedLabel : l10n.unverifiedClaimLabel);

    return EnpriveFindingM3ECard(
      finding: finding,
      index: index,
      totalCount: totalCount,
      categoryLabel: _categoryLabel(finding.category),
      severityLabel: finding.severity == FindingSeverity.high
          ? l10n.stateReviewRecommended
          : null,
      verificationLabel: verifyLabel,
      onTapCard: onTap,
    );
  }
}

class _M3EPermissionListCard extends StatelessWidget {
  final AppPermissionComparisonReport report;
  final AppLocalizations l10n;

  const _M3EPermissionListCard({required this.report, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;

    return Column(
      children: [
        for (var idx = 0; idx < report.items.length; idx++) ...[
          if (idx > 0) const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final item = report.items[idx];
              final isMismatch =
                  item.alignmentState ==
                  PermissionAlignmentState.undisclosedInPolicy;
              final Color iconBg = isMismatch
                  ? semantics.reviewRecommended.background
                  : (item.isGranted
                        ? semantics.onDevice.background
                        : surfaces.cardMuted);
              final Color iconFg = isMismatch
                  ? semantics.reviewRecommended.foreground
                  : (item.isGranted
                        ? semantics.onDevice.foreground
                        : scheme.onSurfaceVariant);

              return EnpriveSegmentedCardTile(
                index: idx,
                totalCount: report.items.length,
                lipHeight: 1.5,
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        isMismatch
                            ? LucideIcons.triangleAlert
                            : (item.isGranted
                                  ? LucideIcons.circleCheck
                                  : LucideIcons.circleMinus),
                        size: 17,
                        color: iconFg,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                item.friendlyName,
                                style: m3e.typography.emphasized.titleSmall
                                    .copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: scheme.onSurface,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: item.isGranted
                                      ? semantics.onDevice.background
                                      : surfaces.cardMuted,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: item.isGranted
                                        ? semantics.onDevice.border
                                              .withValues(alpha: 0.45)
                                        : surfaces.hairlineBorder,
                                  ),
                                ),
                                child: Text(
                                  item.isGranted
                                      ? l10n.permissionGrantedBadge
                                      : l10n.permissionNotGrantedBadge,
                                  style: m3e.typography.emphasized.labelSmall
                                      .copyWith(
                                        fontSize: 10.5,
                                        color: item.isGranted
                                            ? semantics.onDevice.foreground
                                            : scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.parentExplanation,
                            style: m3e.typeScale.bodySmall.copyWith(
                              height: 1.38,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

enum _AttachPolicyMode { paste, link, document }

class _AttachedPolicyInput {
  final String policyText;
  final String sourceLabel;
  final PolicySourceSnapshot sourceSnapshot;

  const _AttachedPolicyInput({
    required this.policyText,
    required this.sourceLabel,
    required this.sourceSnapshot,
  });
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaces.cardMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: surfaces.hairlineBorder),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SHA-256 source hash: ${snapshot.sourceSha256Hash}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typeExt.sha256Hash.copyWith(
                      color: scheme.onSurface,
                    ),
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

class _AttachPolicySheet extends StatefulWidget {
  final String appName;
  final String packageName;
  final ReviewCoordinator coordinator;
  final PolicyUrlRetriever urlRetriever;
  final AppLocalizations l10n;

  const _AttachPolicySheet({
    required this.appName,
    required this.packageName,
    required this.coordinator,
    required this.urlRetriever,
    required this.l10n,
  });

  @override
  State<_AttachPolicySheet> createState() => _AttachPolicySheetState();
}

class _AttachPolicySheetState extends State<_AttachPolicySheet> {
  final TextEditingController _policyController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  _AttachPolicyMode _mode = _AttachPolicyMode.paste;
  String? _inlineError;
  bool _isBusy = false;

  @override
  void dispose() {
    _policyController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _submitLink(BuildContext innerCtx) async {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) {
      setState(
        () => _inlineError = 'Enter a public https:// privacy policy URL.',
      );
      return;
    }
    setState(() {
      _isBusy = true;
      _inlineError = null;
    });
    try {
      final result = await widget.urlRetriever.fetchPolicy(rawUrl);
      if (!mounted || !innerCtx.mounted) return;
      if (result.isUsablePolicy) {
        Navigator.pop(
          innerCtx,
          _AttachedPolicyInput(
            policyText: result.extractedText!,
            sourceLabel: result.canonicalUrl ?? rawUrl,
            sourceSnapshot: result.sourceSnapshot!,
          ),
        );
        return;
      }
      setState(() {
        _isBusy = false;
        _inlineError =
            '${result.userMessage} Paste the policy text or import a local document instead.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _inlineError =
            'Could not retrieve that link. Paste the policy text or import a PDF, TXT, or DOCX document instead.';
      });
    }
  }

  Future<void> _pickDocument(BuildContext innerCtx) async {
    setState(() {
      _isBusy = true;
      _inlineError = null;
    });
    final doc = await widget.coordinator.bridge.pickAndExtractDocument();
    if (!mounted || !innerCtx.mounted) return;
    if (doc.isCancelled) {
      setState(() => _isBusy = false);
      return;
    }
    if (!doc.isSuccess) {
      setState(() {
        _isBusy = false;
        _inlineError =
            '${doc.userMessage} Choose another PDF, TXT, or DOCX file or paste the policy text manually.';
      });
      return;
    }
    final validation = PolicySufficiencyValidator.assess(doc.extractedText);
    if (!validation.isSufficient) {
      setState(() {
        _isBusy = false;
        _inlineError = validation.explanation;
      });
      return;
    }
    Navigator.pop(
      innerCtx,
      _AttachedPolicyInput(
        policyText: doc.extractedText,
        sourceLabel: doc.fileName ?? 'Document',
        sourceSnapshot: PolicyIntakeHelper.snapshotFromDocumentSuccess(
          doc,
          hasAppPermissions: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (innerCtx) {
          final m3e = EnpriveM3ETheme.of(innerCtx);
          final scheme = m3e.colorScheme;
          final surfaces = innerCtx.enpriveSurfaces;
          final viewInsets = MediaQuery.viewInsetsOf(innerCtx);

          return Material(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  24 + viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.l10n.addAppPrivacyPolicyBtn,
                            style: m3e.typography.emphasized.titleLarge
                                .copyWith(color: scheme.onSurface),
                          ),
                        ),
                        IconButton(
                          tooltip: widget.l10n.tooltipClose,
                          onPressed: () => Navigator.pop(innerCtx),
                          icon: Icon(
                            LucideIcons.x,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${widget.appName} (${widget.packageName})',
                      style: m3e.typeScale.labelMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: M3ESegmentedButton<_AttachPolicyMode>(
                        showSelectedIcon: false,
                        segments: [
                          M3ESegment<_AttachPolicyMode>(
                            value: _AttachPolicyMode.paste,
                            icon: const Icon(LucideIcons.fileText, size: 15),
                            label: widget.l10n.modePasteText,
                          ),
                          M3ESegment<_AttachPolicyMode>(
                            value: _AttachPolicyMode.link,
                            icon: const Icon(LucideIcons.link2, size: 15),
                            label: widget.l10n.modePolicyLink,
                          ),
                          const M3ESegment<_AttachPolicyMode>(
                            value: _AttachPolicyMode.document,
                            icon: Icon(LucideIcons.fileUp, size: 15),
                            label: 'Document',
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (sel) {
                          setState(() {
                            _mode = sel.first;
                            _inlineError = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_mode == _AttachPolicyMode.paste)
                      TextField(
                        controller: _policyController,
                        maxLines: 6,
                        minLines: 4,
                        onChanged: (_) {
                          if (_inlineError != null) {
                            setState(() => _inlineError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: widget.l10n.hintPastePolicy,
                          errorText: _inlineError,
                          filled: true,
                          fillColor: surfaces.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: surfaces.hairlineBorder,
                            ),
                          ),
                        ),
                      )
                    else if (_mode == _AttachPolicyMode.link) ...[
                      TextField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        onChanged: (_) {
                          if (_inlineError != null) {
                            setState(() => _inlineError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'https://example.com/privacy-policy',
                          prefixIcon: Icon(
                            LucideIcons.link2,
                            size: 18,
                            color: scheme.primary,
                          ),
                          errorText: _inlineError,
                          errorMaxLines: 4,
                          filled: true,
                          fillColor: surfaces.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: surfaces.hairlineBorder,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fetches the public URL directly. User-supplied links do not prove app ownership.',
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      EnpriveMaterialCardSurface(
                        variant: EnpriveCardVariant.outlined,
                        backgroundColor: surfaces.card,
                        borderRadius: BorderRadius.circular(18),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Import PDF, TXT, or DOCX policy file',
                              style: m3e.typeScale.titleSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Text is extracted strictly on this phone with a local SHA-256 snapshot hash. Files never upload directly.',
                              style: m3e.typeScale.bodySmall.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            if (_inlineError != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _inlineError!,
                                style: m3e.typeScale.bodySmall.copyWith(
                                  color: scheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (_inlineError != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (_mode != _AttachPolicyMode.paste)
                            TextButton(
                              onPressed: () => setState(() {
                                _mode = _AttachPolicyMode.paste;
                                _inlineError = null;
                              }),
                              child: Text(widget.l10n.modePasteText),
                            ),
                          if (_mode != _AttachPolicyMode.document)
                            TextButton(
                              onPressed: () => setState(() {
                                _mode = _AttachPolicyMode.document;
                                _inlineError = null;
                              }),
                              child: const Text('Import document'),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    EnpriveTactileButton(
                      label: _isBusy
                          ? 'Working…'
                          : (_mode == _AttachPolicyMode.document
                                ? 'Choose document (PDF, TXT, DOCX)'
                                : widget.l10n.btnReviewOnPhone),
                      onPressed: _isBusy
                          ? null
                          : () {
                              if (_mode == _AttachPolicyMode.link) {
                                _submitLink(innerCtx);
                                return;
                              }
                              if (_mode == _AttachPolicyMode.document) {
                                _pickDocument(innerCtx);
                                return;
                              }
                              final text = _policyController.text.trim();
                              final validation =
                                  PolicySufficiencyValidator.assess(text);
                              if (!validation.isSufficient) {
                                setState(
                                  () => _inlineError = validation.explanation,
                                );
                                return;
                              }
                              Navigator.pop(
                                innerCtx,
                                _AttachedPolicyInput(
                                  policyText: text,
                                  sourceLabel: 'Policy compared',
                                  sourceSnapshot:
                                      PolicyIntakeHelper
                                          .snapshotForManualOrSharedText(
                                            sourceType:
                                                PolicySourceType.pastedText,
                                            text: text,
                                            hasAppPermissions: true,
                                          ),
                                ),
                              );
                            },
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
