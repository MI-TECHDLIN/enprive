import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/permissions/permission_comparator.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../widgets/analysis_process_trace.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_duotone_icon.dart';
import '../widgets/enprive_provenance_chip.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/m3e/enprive_m3e_components.dart';
import '../widgets/why_this_finding_sheet.dart';

/// Material 3 Expressive Evidence Result Screen:
/// - State-tinted M3E hero stage with Deni Standard LOD (`84dp`) + AAA state pill
/// - Curved archival sheet with 3 `M3ECard` tabular metric tiles
/// - Segmented quote-first `M3ECard` finding cards (`EnpriveRadii.groupedCardRadius`)
/// - Docked bottom bar with bookmark action + primary tactile CTA
class ReviewResultScreen extends StatefulWidget {
  final PolicyReviewReceipt receipt;
  final ReviewCoordinator coordinator;
  final ValueChanged<PolicyReviewReceipt>? onSaveReceipt;
  final bool cloudConsentGrantedForSession;

  const ReviewResultScreen({
    super.key,
    required this.receipt,
    required this.coordinator,
    this.onSaveReceipt,
    this.cloudConsentGrantedForSession = false,
  });

  @override
  State<ReviewResultScreen> createState() => _ReviewResultScreenState();
}

class _ReviewResultScreenState extends State<ReviewResultScreen> {
  bool _isSaved = false;
  bool _isSpeaking = false;

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
    return switch (widget.receipt.overallState) {
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
        '${widget.receipt.subjectTitle}. $stateTitle. ${widget.receipt.summary}';
    await widget.coordinator.bridge.speakText(spokenText, languageCode: lang);
  }

  (
    SemanticColorPair pair,
    IconData icon,
    String title,
    String subtitle,
  ) _stateConfig(AppLocalizations l10n, EnpriveSemanticColors semantics) {
    return switch (widget.receipt.overallState) {
      ReviewOverallState.reviewRecommended => (
        semantics.reviewRecommended,
        LucideIcons.shieldAlert,
        l10n.stateReviewRecommended,
        l10n.stateReviewRecommendedSubtitle,
      ),
      ReviewOverallState.noConcern => (
        semantics.noConcern,
        LucideIcons.shieldCheck,
        l10n.stateNoConcern,
        l10n.stateNoConcernSubtitle,
      ),
      ReviewOverallState.insufficientEvidence => (
        semantics.insufficientEvidence,
        LucideIcons.circleHelp,
        l10n.stateInsufficientEvidence,
        l10n.stateInsufficientEvidenceSubtitle,
      ),
    };
  }

  void _openFindingDetails(VerifiedFinding finding) {
    WhyThisFindingSheet.show(
      context,
      finding: finding,
      snapshotText: widget.receipt.snapshotText,
      snapshotDigest: widget.receipt.snapshotDigest,
      coordinator: widget.coordinator,
      cloudConsentGrantedForSession: widget.cloudConsentGrantedForSession,
    );
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
    final surfaces = context.enpriveSurfaces;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaces.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return EnpriveM3EBridgeScope.ensure(
          sheetContext,
          child: Builder(
            builder: (innerContext) {
              final m3e = EnpriveM3ETheme.of(innerContext);
              final scheme = m3e.colorScheme;
              final innerSurfaces = innerContext.enpriveSurfaces;
              final typeExt = innerContext.enpriveType;

              return DraggableScrollableSheet(
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
                        style: m3e.typography.emphasized.headlineSmall.copyWith(
                          color: scheme.onSurface,
                        ),
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
                              '${l10n.snapshotReviewedPrefix} · $dateStr  |  ${l10n.snapshotDigestPrefix} · #${receipt.snapshotDigest}',
                              style: typeExt.sha256Hash.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      EnpriveQuoteCard(
                        quote: receipt.snapshotText,
                        sha256Digest: receipt.snapshotDigest,
                        borderRadius: BorderRadius.circular(EnpriveRadii.xl),
                        padding: const EdgeInsets.all(20),
                      ),
                    ],
                  );
                },
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
          final receipt = widget.receipt;
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final surfaces = context.enpriveSurfaces;
          final semantics = context.enpriveSemantics;
          final (statePair, stateIcon, stateTitle, stateSubtitle) =
              _stateConfig(l10n, semantics);

          return Scaffold(
            backgroundColor: statePair.background,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Navigation Row inside state-tinted M3E hero stage
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
                          onTap: () => _showSnapshotReceiptSheet(
                            context,
                            l10n,
                            receipt,
                          ),
                          child: EnpriveProvenanceChip(
                            source: receipt.inferenceSource,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: _isSpeaking
                              ? scheme.primary
                              : surfaces.card.withValues(alpha: 0.90),
                          shape: CircleBorder(
                            side: BorderSide(color: surfaces.hairlineBorder),
                          ),
                          child: IconButton(
                            tooltip: _isSpeaking
                                ? 'Stop reading aloud'
                                : 'Read summary aloud',
                            onPressed: () => _toggleVoicePlayback(stateTitle),
                            icon: Icon(
                              _isSpeaking
                                  ? LucideIcons.square
                                  : LucideIcons.volume2,
                              size: 19,
                              color: _isSpeaking
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Hero + Curved Archival Sheet Body
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Centered Tinted Hero Stage with Deni Standard LOD (84dp)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                            child: Column(
                              children: [
                                Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    color: surfaces.card.withValues(
                                      alpha: 0.76,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: statePair.border,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: DeniAnimatedMascot(
                                    size: 84,
                                    pose: _statePose,
                                    onTap: () =>
                                        _toggleVoicePlayback(stateTitle),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surfaces.card.withValues(
                                      alpha: 0.92,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: statePair.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        stateIcon,
                                        size: 15,
                                        color: statePair.foreground,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        stateTitle,
                                        style: m3e.typeScale.labelMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: statePair.foreground,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  receipt.subjectTitle,
                                  textAlign: TextAlign.center,
                                  style: m3e.typography.emphasized.headlineMedium
                                      .copyWith(
                                        color: statePair.foreground,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // Curved Archival Content Sheet
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height * 0.58,
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                            decoration: BoxDecoration(
                              color: surfaces.canvas,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(32),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 3 M3E Tabular Metric Stat Tiles
                                Row(
                                  children: [
                                    Expanded(
                                      child: _M3EStatTile(
                                        iconSvg: Ph.file_text_duotone,
                                        semanticPair: semantics.inCloud,
                                        value: '${receipt.findings.length}',
                                        label: l10n.statFindings,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _M3EStatTile(
                                        iconSvg: Ph.quotes_duotone,
                                        semanticPair: semantics.noConcern,
                                        value: '${receipt.sourceMatchedCount}',
                                        label: l10n.statVerified,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _M3EStatTile(
                                        iconSvg:
                                            receipt.permissionReport != null
                                            ? Ph.device_mobile_duotone
                                            : Ph.question_duotone,
                                        semanticPair:
                                            semantics.reviewRecommended,
                                        value: receipt.permissionReport != null
                                            ? '${receipt.permissionReport!.grantedSensitiveCount}'
                                            : '${receipt.unverifiedCount}',
                                        label: receipt.permissionReport != null
                                            ? l10n.statOsGranted
                                            : l10n.statUnverified,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

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

                                // Findings List
                                Text(
                                  receipt.findings.isNotEmpty
                                      ? l10n.keyFindingsTitle
                                      : l10n.reviewedExcerptTitle,
                                  style: m3e.typography.emphasized.titleMedium
                                      .copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: scheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 12),

                                if (receipt.findings.isEmpty)
                                  EnpriveQuoteCard(
                                    quote: receipt.snapshotText,
                                    sha256Digest: receipt.snapshotDigest,
                                    borderRadius: BorderRadius.circular(
                                      EnpriveRadii.lg,
                                    ),
                                    padding: const EdgeInsets.all(20),
                                  )
                                else
                                  ...receipt.findings.asMap().entries.map(
                                    (entry) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            entry.key <
                                                receipt.findings.length - 1
                                            ? 6.0
                                            : 0.0,
                                      ),
                                      child: _M3EFindingCard(
                                        finding: entry.value,
                                        index: entry.key,
                                        totalCount: receipt.findings.length,
                                        l10n: l10n,
                                        onTap: () =>
                                            _openFindingDetails(entry.value),
                                      ),
                                    ),
                                  ),

                                // Optional Permission Check Section
                                if (receipt.permissionReport != null &&
                                    receipt
                                        .permissionReport!
                                        .items
                                        .isNotEmpty) ...[
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sticky Bottom Bar
                  Container(
                    decoration: BoxDecoration(
                      color: surfaces.canvas,
                      border: Border(
                        top: BorderSide(color: surfaces.hairlineBorder),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      24,
                      12,
                      24,
                      MediaQuery.of(context).padding.bottom + 16,
                    ),
                    child: Row(
                      children: [
                        if (widget.onSaveReceipt != null) ...[
                          InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _handleSave(context, l10n, receipt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _isSaved
                                    ? semantics.noConcern.background
                                    : surfaces.card,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _isSaved
                                      ? semantics.noConcern.border
                                      : surfaces.hairlineBorder,
                                ),
                              ),
                              child: Icon(
                                _isSaved
                                    ? LucideIcons.bookmarkCheck
                                    : LucideIcons.bookmarkPlus,
                                color: _isSaved
                                    ? semantics.noConcern.foreground
                                    : scheme.onSurface,
                                size: 21,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: EnpriveTactileButton(
                            label: receipt.findings.isNotEmpty
                                ? l10n.btnAskDeni
                                : (_isSaved
                                      ? l10n.btnSavedToReceipts
                                      : l10n.btnSaveToReceipts),
                            onPressed: () {
                              if (receipt.findings.isNotEmpty) {
                                _openFindingDetails(receipt.findings.first);
                              } else {
                                _handleSave(context, l10n, receipt);
                              }
                            },
                          ),
                        ),
                      ],
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

class _M3EStatTile extends StatelessWidget {
  final String iconSvg;
  final SemanticColorPair semanticPair;
  final String value;
  final String label;

  const _M3EStatTile({
    required this.iconSvg,
    required this.semanticPair,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final numVal = int.tryParse(value) ?? 0;
    return EnpriveMetricTileCard(
      value: value,
      label: label,
      accentColor: semanticPair.foreground,
      accentBackground: semanticPair.background,
      meterFraction: numVal > 0 ? 1.0 : 0.35,
      iconWidget: EnpriveDuotoneIcon(
        iconSvg,
        size: 17,
        color: semanticPair.icon,
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
        : (isVerified
              ? l10n.quoteVerifiedLabel
              : l10n.unverifiedClaimLabel);

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
                          Text(
                            item.friendlyName,
                            style: m3e.typography.emphasized.titleSmall
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 2),
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
