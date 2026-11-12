import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../core/theme/enprive_theme.dart';
import '../domain/permissions/permission_comparator.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_provenance_chip.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/why_this_finding_sheet.dart';

/// Evidence Result Screen combining the Interactive Learning App header/stat-tile
/// grammar with Brilliant B30's segmented progress bar and docked bottom actions.
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

  DeniPose get _statePose {
    return switch (widget.receipt.overallState) {
      ReviewOverallState.reviewRecommended => DeniPose.explaining,
      ReviewOverallState.noConcern => DeniPose.celebrating,
      ReviewOverallState.insufficientEvidence => DeniPose.support,
    };
  }

  (Color bg, Color fg, IconData icon, String title, String subtitle)
      _stateConfig(AppLocalizations l10n) {
    return switch (widget.receipt.overallState) {
      ReviewOverallState.reviewRecommended => (
          EnpriveColors.stateReviewRecommendedBg,
          EnpriveColors.stateReviewRecommendedFg,
          Symbols.warning_amber_rounded,
          l10n.stateReviewRecommended,
          l10n.stateReviewRecommendedSubtitle,
        ),
      ReviewOverallState.noConcern => (
          EnpriveColors.stateNoConcernBg,
          EnpriveColors.stateNoConcernFg,
          Symbols.check_circle_rounded,
          l10n.stateNoConcern,
          l10n.stateNoConcernSubtitle,
        ),
      ReviewOverallState.insufficientEvidence => (
          EnpriveColors.stateInsufficientEvidenceBg,
          EnpriveColors.stateInsufficientEvidenceFg,
          Symbols.help_outline_rounded,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final receipt = widget.receipt;
    final (stateBg, stateFg, stateIcon, stateTitle, stateSubtitle) =
        _stateConfig(l10n);

    return Scaffold(
      backgroundColor: EnpriveColors.paper,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            IconButton(
              tooltip: 'Close review',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Symbols.close_rounded, size: 24),
            ),
            const SizedBox(width: 8),
            // Brilliant B30 4-segment verification progress bar
            Expanded(
              child: Semantics(
                label: 'Verification complete: 4 of 4 evidence checks finished',
                child: Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: EnpriveColors.teal,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 12),
            EnpriveProvenanceChip(source: receipt.inferenceSource),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  // 1. Calibrated State Header Card (Learning App Pattern)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: stateBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: stateFg.withValues(alpha: 0.22),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(stateIcon, size: 18, color: stateFg),
                                  const SizedBox(width: 6),
                                  Text(
                                    stateTitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: stateFg,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '#${receipt.snapshotDigest.substring(0, 8)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: stateFg.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          receipt.subjectTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(color: EnpriveColors.ink),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          receipt.summary,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: EnpriveColors.ink),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Symbols.info_rounded,
                                size: 16,
                                color: stateFg,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  stateSubtitle,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: EnpriveColors.ink,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Three Pastel Stat Tiles (Interactive Learning App Pattern)
                  Row(
                    children: [
                      Expanded(
                        child: _EvidenceMetricTile(
                          value: '${receipt.findings.length}',
                          label: 'Findings',
                          bg: EnpriveColors.surface,
                          fg: EnpriveColors.ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _EvidenceMetricTile(
                          value: '${receipt.sourceMatchedCount}',
                          label: l10n.statusSourceMatched,
                          bg: EnpriveColors.stateNoConcernBg,
                          fg: EnpriveColors.stateNoConcernFg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _EvidenceMetricTile(
                          value: '${receipt.unverifiedCount}',
                          label: l10n.statusUnverified,
                          bg: EnpriveColors.stateInsufficientEvidenceBg,
                          fg: EnpriveColors.stateInsufficientEvidenceFg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Deni Reactive Companion Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: EnpriveColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: EnpriveColors.teal.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Row(
                      children: [
                        DeniAnimatedMascot(
                          size: 64,
                          pose: _statePose,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deni’s Evidence Check',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: EnpriveColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                receipt.findings.isNotEmpty
                                    ? 'Tap any finding below to see the exact policy quote in context and what Enprive could not verify.'
                                    : receipt.calibratedDisclaimer,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: EnpriveColors.inkSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3b. Local Android OS Permission Comparison Section (when an app was inspected)
                  if (receipt.permissionReport != null) ...[
                    _PermissionComparisonSection(
                      report: receipt.permissionReport!,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 4. Findings List Header
                  Text(
                    receipt.findings.isNotEmpty
                        ? 'VERIFIED POLICY & DEVICE EVIDENCE (${receipt.findings.length})'
                        : 'CAPTURED POLICY SNAPSHOT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: EnpriveColors.inkSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),

                  if (receipt.findings.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: EnpriveColors.quoteSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: const Border(
                          left: BorderSide(color: EnpriveColors.teal, width: 4),
                        ),
                      ),
                      child: Text(
                        receipt.snapshotText,
                        style: const TextStyle(
                          fontFamily: EnpriveTheme.primaryDisplayFontFamily,
                          fontSize: 15,
                          height: 1.55,
                          color: EnpriveColors.ink,
                        ),
                      ),
                    )
                  else
                    ...receipt.findings.map(
                      (finding) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _FindingEvidenceCard(
                          finding: finding,
                          l10n: l10n,
                          onInspect: () => _openFindingDetails(finding),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 5. Sticky Bottom Bar (Brilliant B30 Pattern: [Ask Deni] + [Save to Receipts])
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                color: EnpriveColors.paper,
                border: Border(
                  top: BorderSide(
                    color: EnpriveColors.ink.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (receipt.findings.isNotEmpty) ...[
                    Expanded(
                      flex: 5,
                      child: EnpriveTactileButton(
                        label: l10n.btnAskDeni,
                        isSecondary: true,
                        leading: const Icon(
                          Symbols.chat_bubble_rounded,
                          size: 18,
                          color: EnpriveColors.tealStrong,
                        ),
                        onPressed: () =>
                            _openFindingDetails(receipt.findings.first),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 6,
                    child: EnpriveTactileButton(
                      label: _isSaved ? 'Saved to Receipts' : l10n.btnSaveToReceipts,
                      leading: Icon(
                        _isSaved
                            ? Symbols.bookmark_added_rounded
                            : Symbols.bookmark_add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        if (!_isSaved) {
                          setState(() => _isSaved = true);
                          widget.onSaveReceipt?.call(receipt);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Evidence receipt saved locally on this phone.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
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
  }
}

class _EvidenceMetricTile extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color fg;

  const _EvidenceMetricTile({
    required this.value,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: fg.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: fg.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _FindingEvidenceCard extends StatelessWidget {
  final VerifiedFinding finding;
  final AppLocalizations l10n;
  final VoidCallback onInspect;

  const _FindingEvidenceCard({
    required this.finding,
    required this.l10n,
    required this.onInspect,
  });

  String _categoryLabel(FindingCategory category) {
    return switch (category) {
      FindingCategory.dataCollection => 'Data Collection',
      FindingCategory.sharing => 'Third-Party Sharing',
      FindingCategory.tracking => 'Location / Tracking',
      FindingCategory.retention => 'Retention & Training',
      FindingCategory.parentalConsent => 'Parental Controls',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isMatched = finding.status == EvidenceStatus.sourceMatched;
    final isDeviceObserved = finding.status == EvidenceStatus.deviceObserved;
    final isVerified = isMatched || isDeviceObserved;

    final String statusLabel = isDeviceObserved
        ? l10n.statusDeviceObserved
        : (isMatched ? l10n.statusSourceMatched : l10n.statusUnverified);
    final Color statusBg = isDeviceObserved
        ? EnpriveColors.chipOnDeviceBg
        : (isMatched
            ? EnpriveColors.stateNoConcernBg
            : EnpriveColors.stateInsufficientEvidenceBg);
    final Color statusFg = isDeviceObserved
        ? EnpriveColors.chipOnDeviceFg
        : (isMatched
            ? EnpriveColors.stateNoConcernFg
            : EnpriveColors.stateInsufficientEvidenceFg);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EnpriveColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: EnpriveColors.ink.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E4A43).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top badges row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: EnpriveColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _categoryLabel(finding.category),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: EnpriveColors.inkSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDeviceObserved
                          ? Symbols.phone_android_rounded
                          : (isVerified
                              ? Symbols.verified_rounded
                              : Symbols.help_outline_rounded),
                      size: 14,
                      color: statusFg,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Finding title
          Text(
            finding.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),

          // Verbatim Policy Excerpt (Source Serif 4 on quoteSurface)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: EnpriveColors.quoteSurface,
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                left: BorderSide(color: EnpriveColors.teal, width: 3.5),
              ),
            ),
            child: Text(
              '“${finding.exactExcerpt}”',
              style: const TextStyle(
                fontFamily: EnpriveTheme.primaryDisplayFontFamily,
                fontSize: 15,
                height: 1.5,
                color: EnpriveColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Plain-language explanation
          Text(
            finding.explanation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EnpriveColors.ink,
                ),
          ),
          const SizedBox(height: 14),

          // Action: "Why this finding?"
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onInspect,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Symbols.manage_search_rounded,
                    size: 18,
                    color: EnpriveColors.tealStrong,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.btnWhyThisFinding,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: EnpriveColors.tealStrong,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Symbols.arrow_forward_rounded,
                    size: 15,
                    color: EnpriveColors.tealStrong,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionComparisonSection extends StatelessWidget {
  final AppPermissionComparisonReport report;
  final AppLocalizations l10n;

  const _PermissionComparisonSection({
    required this.report,
    required this.l10n,
  });

  (Color bg, Color fg, String label, IconData icon) _alignmentStyle(
    PermissionAlignmentState state,
  ) {
    return switch (state) {
      PermissionAlignmentState.undisclosedInPolicy => (
          EnpriveColors.stateReviewRecommendedBg,
          EnpriveColors.stateReviewRecommendedFg,
          'Undisclosed in Policy',
          Symbols.warning_amber_rounded,
        ),
      PermissionAlignmentState.grantedAndDisclosed => (
          EnpriveColors.chipOnDeviceBg,
          EnpriveColors.chipOnDeviceFg,
          'Granted & Disclosed',
          Symbols.check_circle_rounded,
        ),
      PermissionAlignmentState.disclosedNotGranted => (
          EnpriveColors.stateInsufficientEvidenceBg,
          EnpriveColors.stateInsufficientEvidenceFg,
          'Denied on Phone',
          Symbols.block_rounded,
        ),
      PermissionAlignmentState.notRequested => (
          EnpriveColors.stateNoConcernBg,
          EnpriveColors.stateNoConcernFg,
          'Not Requested',
          Symbols.verified_user_rounded,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EnpriveColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: EnpriveColors.teal.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Symbols.phone_android_rounded,
                size: 18,
                color: EnpriveColors.tealStrong,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ANDROID OS PERMISSION CHECK (${report.snapshot.packageName})',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: EnpriveColors.tealStrong,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (report.items.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: EnpriveColors.stateNoConcernBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Symbols.verified_user_rounded,
                    color: EnpriveColors.stateNoConcernFg,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No sensitive permissions (Location, Microphone, Camera, Contacts, or Ad ID) are requested by this APK on Android.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: EnpriveColors.stateNoConcernFg,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...report.items.map((item) {
              final (bg, fg, label, icon) = _alignmentStyle(item.alignmentState);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: EnpriveColors.paper,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: EnpriveColors.ink.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.friendlyName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: EnpriveColors.ink,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 13, color: fg),
                                const SizedBox(width: 4),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: fg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.parentExplanation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: EnpriveColors.ink,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.osStatusSummary,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: EnpriveColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 6),
          Text(
            l10n.permissionLimitationNotice,
            style: const TextStyle(
              fontSize: 12,
              color: EnpriveColors.inkSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
