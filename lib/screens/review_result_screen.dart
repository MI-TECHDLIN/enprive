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

/// Evidence Result Screen crafted directly from the Interactive Learning App
/// (`x-learning-app.jpeg`) and Brilliant Lesson (`b30-lesson-check.png`) patterns:
/// - Full-bleed state-tinted hero header with centered Deni + state pill + serif title
/// - Curved white sheet with 3 pastel stat tiles
/// - Scannable quote-first finding cards without nested box noise
/// - Docked bottom bar with bookmark button + primary CTA
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
    return switch (widget.receipt.overallState) {
      ReviewOverallState.reviewRecommended => DeniPose.explaining,
      ReviewOverallState.noConcern => DeniPose.celebrating,
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
    await widget.coordinator.bridge.speakText(
      spokenText,
      languageCode: lang,
    );
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

  void _handleSave(PolicyReviewReceipt receipt) {
    if (_isSaved) return;
    setState(() => _isSaved = true);
    widget.onSaveReceipt?.call(receipt);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved to your local receipts.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final receipt = widget.receipt;
    final (stateBg, stateFg, stateIcon, stateTitle, stateSubtitle) =
        _stateConfig(l10n);

    return Scaffold(
      backgroundColor: stateBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Navigation Row inside tinted header (x-learning-app.jpeg pattern)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Symbols.close_rounded,
                        size: 20,
                        color: EnpriveColors.ink,
                      ),
                    ),
                  ),
                  const Spacer(),
                  EnpriveProvenanceChip(source: receipt.inferenceSource),
                  const SizedBox(width: 8),
                  Material(
                    color: _isSpeaking
                        ? EnpriveColors.teal
                        : Colors.white.withValues(alpha: 0.85),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: _isSpeaking
                          ? 'Stop reading aloud'
                          : 'Read summary aloud',
                      onPressed: () => _toggleVoicePlayback(stateTitle),
                      icon: Icon(
                        _isSpeaking
                            ? Symbols.stop_rounded
                            : Symbols.volume_up_rounded,
                        size: 20,
                        color:
                            _isSpeaking ? Colors.white : EnpriveColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Hero + Curved Sheet Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Centered Tinted Hero Stage (x-learning-app.jpeg)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                      child: Column(
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: DeniAnimatedMascot(
                              size: 84,
                              pose: _statePose,
                              onTap: () => _toggleVoicePlayback(stateTitle),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(stateIcon, size: 15, color: stateFg),
                                const SizedBox(width: 6),
                                Text(
                                  stateTitle,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: stateFg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            receipt.subjectTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontSize: 26,
                                  color: EnpriveColors.ink,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Curved White Content Sheet (x-learning-app.jpeg)
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.58,
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      decoration: const BoxDecoration(
                        color: EnpriveColors.paper,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 3 Pastel Stat Tiles (x-learning-app.jpeg exact layout)
                          Row(
                            children: [
                              Expanded(
                                child: _PastelStatTile(
                                  icon: Symbols.article_rounded,
                                  iconColor: EnpriveColors.chipInCloudFg,
                                  bg: const Color(0xFFEAF2FC),
                                  value: '${receipt.findings.length}',
                                  label: 'Findings',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PastelStatTile(
                                  icon: Symbols.format_quote_rounded,
                                  iconColor: EnpriveColors.stateNoConcernFg,
                                  bg: EnpriveColors.stateNoConcernBg,
                                  value: '${receipt.sourceMatchedCount}',
                                  label: 'Verified',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PastelStatTile(
                                  icon: receipt.permissionReport != null
                                      ? Symbols.phone_android_rounded
                                      : Symbols.help_outline_rounded,
                                  iconColor:
                                      EnpriveColors.stateReviewRecommendedFg,
                                  bg: EnpriveColors.stateReviewRecommendedBg,
                                  value: receipt.permissionReport != null
                                      ? '${receipt.permissionReport!.grantedSensitiveCount}'
                                      : '${receipt.unverifiedCount}',
                                  label: receipt.permissionReport != null
                                      ? 'OS Granted'
                                      : 'Unverified',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Summary & Calibrated Note (no heavy boxes)
                          Text(
                            receipt.summary,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: EnpriveColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stateSubtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: EnpriveColors.inkSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Findings List ("Lessons" list rhythm from x-learning-app.jpeg)
                          Text(
                            receipt.findings.isNotEmpty
                                ? 'Key Findings'
                                : 'Reviewed Excerpt',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: EnpriveColors.ink,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (receipt.findings.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: EnpriveColors.quoteSurface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                receipt.snapshotText,
                                style: const TextStyle(
                                  fontFamily: EnpriveTheme.quoteFontFamily,
                                  fontSize: 15,
                                  height: 1.55,
                                  color: EnpriveColors.ink,
                                ),
                              ),
                            )
                          else
                            ...receipt.findings.map(
                              (finding) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _CleanFindingCard(
                                  finding: finding,
                                  onTap: () => _openFindingDetails(finding),
                                ),
                              ),
                            ),

                          // Optional Permission Check Section (clean single list card)
                          if (receipt.permissionReport != null &&
                              receipt.permissionReport!.items.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Permissions on this phone',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: EnpriveColors.ink,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _CleanPermissionListCard(
                              report: receipt.permissionReport!,
                              l10n: l10n,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Bar (x-learning-app.jpeg: square bookmark + dark pill CTA)
            Container(
              color: EnpriveColors.paper,
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
                      onTap: () => _handleSave(receipt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _isSaved
                              ? EnpriveColors.stateNoConcernBg
                              : EnpriveColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _isSaved
                                ? EnpriveColors.stateNoConcernFg
                                : EnpriveColors.ink.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Icon(
                          _isSaved
                              ? Symbols.bookmark_added_rounded
                              : Symbols.bookmark_add_rounded,
                          color: _isSaved
                              ? EnpriveColors.stateNoConcernFg
                              : EnpriveColors.ink,
                          size: 22,
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
                              ? 'Saved to Receipts'
                              : l10n.btnSaveToReceipts),
                      onPressed: () {
                        if (receipt.findings.isNotEmpty) {
                          _openFindingDetails(receipt.findings.first);
                        } else {
                          _handleSave(receipt);
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

class _PastelStatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final String value;
  final String label;

  const _PastelStatTile({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: EnpriveColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: EnpriveColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanFindingCard extends StatelessWidget {
  final VerifiedFinding finding;
  final VoidCallback onTap;

  const _CleanFindingCard({
    required this.finding,
    required this.onTap,
  });

  IconData _categoryIcon(FindingCategory category) {
    return switch (category) {
      FindingCategory.dataCollection => Symbols.folder_shared_rounded,
      FindingCategory.sharing => Symbols.share_rounded,
      FindingCategory.tracking => Symbols.location_on_rounded,
      FindingCategory.retention => Symbols.history_rounded,
      FindingCategory.parentalConsent => Symbols.family_restroom_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = finding.isVerified;

    return Material(
      color: EnpriveColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: EnpriveColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categoryIcon(finding.category),
                      size: 20,
                      color: EnpriveColors.tealStrong,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          finding.title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: EnpriveColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          finding.status == EvidenceStatus.deviceObserved
                              ? 'Observed on this phone'
                              : (isVerified
                                  ? 'Quote verified in policy'
                                  : 'Unverified claim'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isVerified
                                ? EnpriveColors.tealStrong
                                : EnpriveColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isVerified
                        ? Symbols.check_circle_rounded
                        : Symbols.help_outline_rounded,
                    size: 20,
                    color: isVerified
                        ? EnpriveColors.stateNoConcernFg
                        : EnpriveColors.inkSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                finding.explanation,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: EnpriveColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: EnpriveColors.quoteSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '“${finding.exactExcerpt}”',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: EnpriveTheme.quoteFontFamily,
                    fontSize: 14,
                    height: 1.45,
                    color: EnpriveColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CleanPermissionListCard extends StatelessWidget {
  final AppPermissionComparisonReport report;
  final AppLocalizations l10n;

  const _CleanPermissionListCard({
    required this.report,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EnpriveColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...report.items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isMismatch = item.alignmentState ==
                PermissionAlignmentState.undisclosedInPolicy;
            return Column(
              children: [
                if (idx > 0)
                  Divider(
                    height: 20,
                    color: EnpriveColors.ink.withValues(alpha: 0.06),
                  ),
                Row(
                  children: [
                    Icon(
                      isMismatch
                          ? Symbols.warning_amber_rounded
                          : (item.isGranted
                              ? Symbols.check_circle_rounded
                              : Symbols.remove_circle_outline_rounded),
                      size: 18,
                      color: isMismatch
                          ? EnpriveColors.stateReviewRecommendedFg
                          : (item.isGranted
                              ? EnpriveColors.tealStrong
                              : EnpriveColors.inkSecondary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.friendlyName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: EnpriveColors.ink,
                            ),
                          ),
                          Text(
                            item.parentExplanation,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.35,
                              color: EnpriveColors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
