import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_colors.dart';
import '../core/theme/enprive_theme.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import 'analysis_process_trace.dart';
import 'deni_animated_mascot.dart';
import 'enprive_duotone_icon.dart';
import 'enprive_provenance_chip.dart';

/// Brilliant B30-inspired Evidence Work Card + Docked "Ask Deni" Sheet.
/// Eliminates multi-box clutter in favor of a single cohesive work card
/// (`b30-lesson-check.png`) with highlighted verbatim quote and 3 clear rows.
class WhyThisFindingSheet extends StatefulWidget {
  final VerifiedFinding finding;
  final String snapshotText;
  final String snapshotDigest;
  final ReviewCoordinator coordinator;
  final bool cloudConsentGrantedForSession;

  const WhyThisFindingSheet({
    super.key,
    required this.finding,
    required this.snapshotText,
    required this.snapshotDigest,
    required this.coordinator,
    this.cloudConsentGrantedForSession = false,
  });

  static Future<void> show(
    BuildContext context, {
    required VerifiedFinding finding,
    required String snapshotText,
    required String snapshotDigest,
    required ReviewCoordinator coordinator,
    bool cloudConsentGrantedForSession = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: EnpriveColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.55,
        maxChildSize: 0.94,
        builder: (context, _) => WhyThisFindingSheet(
          finding: finding,
          snapshotText: snapshotText,
          snapshotDigest: snapshotDigest,
          coordinator: coordinator,
          cloudConsentGrantedForSession: cloudConsentGrantedForSession,
        ),
      ),
    );
  }

  @override
  State<WhyThisFindingSheet> createState() => _WhyThisFindingSheetState();
}

class _WhyThisFindingSheetState extends State<WhyThisFindingSheet> {
  DeniPose _deniPose = DeniPose.explaining;
  bool _isAskingDeni = false;
  DeniExplanation? _deniExplanation;
  int _selectedQuestionIndex = 0;

  Future<void> _askDeni(
    int questionIndex,
    String question,
    String languageCode,
  ) async {
    setState(() {
      _selectedQuestionIndex = questionIndex;
      _isAskingDeni = true;
      _deniPose = DeniPose.thinking;
    });

    final explanation = await widget.coordinator.askDeniAboutFinding(
      finding: widget.finding,
      question: question,
      snapshotText: widget.snapshotText,
      cloudConsent: widget.cloudConsentGrantedForSession,
      languageCode: languageCode,
      intentHint: switch (questionIndex) {
        1 => 'opt_out',
        2 => 'unknown',
        _ => 'meaning',
      },
    );

    if (!mounted) return;
    setState(() {
      _isAskingDeni = false;
      _deniExplanation = explanation;
      _deniPose = DeniPose.explaining;
    });
  }

  String _categoryLabel(AppLocalizations l10n, FindingCategory category) {
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
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final languageCode =
        Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    final presetQuestions = [
      l10n.presetQuestionMeaning,
      l10n.presetQuestionOptOut,
      l10n.presetQuestionUnknown,
    ];
    final activeQuestion = presetQuestions[_selectedQuestionIndex];
    final finding = widget.finding;
    final isVerified = finding.isVerified;

    return SafeArea(
      child: Column(
        children: [
          // Minimal B30 Top Bar: × close + segmented progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: l10n.tooltipClose,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 22),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 168),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _deniExplanation != null ? 1.0 : 0.65,
                          minHeight: 7,
                          backgroundColor: EnpriveColors.surfaceMuted,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            EnpriveColors.teal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                // Instruction / Title (Brilliant B30 top sentence)
                Text(
                  finding.title,
                  style: Theme.of(context).textTheme.headlineLarge
                      ?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 16),

                // Single Unified Evidence Work Card (Brilliant B30 central card)
                Container(
                  decoration: BoxDecoration(
                    color: EnpriveColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: EnpriveColors.ink.withValues(alpha: 0.12),
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Header Row (status dot + label on left, category chip on right)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? EnpriveColors.teal
                                    : EnpriveColors.inkSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              finding.status == EvidenceStatus.deviceObserved
                                  ? l10n.statusDeviceObserved
                                  : (isVerified
                                        ? l10n.statusSourceMatched
                                        : l10n.statusUnverified),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: EnpriveColors.ink,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: EnpriveColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _categoryLabel(l10n, finding.category),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: EnpriveColors.inkSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Highlighted Policy Excerpt Stage (middle canvas of B30 card)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: EnpriveColors.quoteSurface,
                        child: finding.contextWindow != null
                            ? RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: EnpriveTheme.quoteFontFamily,
                                    fontSize: 15.5,
                                    height: 1.55,
                                    color: EnpriveColors.inkSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: finding.contextWindow!.before,
                                    ),
                                    TextSpan(
                                      text: finding.contextWindow!.matched,
                                      style: TextStyle(
                                        color: EnpriveColors.ink,
                                        fontWeight: FontWeight.w700,
                                        backgroundColor: EnpriveColors.apricot
                                            .withValues(alpha: 0.28),
                                      ),
                                    ),
                                    TextSpan(
                                      text: finding.contextWindow!.after,
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                '“${finding.exactExcerpt}”',
                                style: const TextStyle(
                                  fontFamily: EnpriveTheme.quoteFontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  color: EnpriveColors.ink,
                                ),
                              ),
                      ),

                      // Clean 3-Row Breakdown inside the card (Meaning · Device · Unknown)
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _CompactEvidenceRow(
                              iconSvg: Ph.lightbulb_duotone,
                              iconColor: EnpriveColors.tealStrong,
                              label: l10n.labelInPlainLanguage,
                              body: finding.explanation,
                            ),
                            Divider(
                              height: 24,
                              color: EnpriveColors.ink.withValues(alpha: 0.08),
                            ),
                            _CompactEvidenceRow(
                              iconSvg: Ph.device_mobile_duotone,
                              iconColor: EnpriveColors.chipOnDeviceFg,
                              label: l10n.labelOnThisPhone,
                              body: finding.whatAndroidReports,
                            ),
                            if (finding.unknowns.isNotEmpty) ...[
                              Divider(
                                height: 24,
                                color: EnpriveColors.ink.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                              _CompactEvidenceRow(
                                iconSvg: Ph.question_duotone,
                                iconColor:
                                    EnpriveColors.stateReviewRecommendedFg,
                                label: l10n.labelWhatRemainsUnknown,
                                body: finding.unknowns.first,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Question Chips (B30 interactive blocks below the card)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presetQuestions.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final q = entry.value;
                    final isSelected =
                        idx == _selectedQuestionIndex &&
                        _deniExplanation != null;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _isAskingDeni
                          ? null
                          : () => _askDeni(idx, q, languageCode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? EnpriveColors.teal.withValues(alpha: 0.12)
                              : EnpriveColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? EnpriveColors.teal
                                : EnpriveColors.ink.withValues(alpha: 0.14),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          q,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? EnpriveColors.tealStrong
                                : EnpriveColors.ink,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (_isAskingDeni) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: EnpriveColors.paper,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: AnalysisLiveProcessView(
                      stream: widget.coordinator.analysisEvents,
                      initialLabel: l10n.readingCitedClause,
                      compact: true,
                    ),
                  ),
                ] else if (_deniExplanation != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: EnpriveColors.paper,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.deniAnswerTitle,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: EnpriveColors.tealStrong,
                              ),
                            ),
                            const Spacer(),
                            EnpriveProvenanceChip(
                              source: _deniExplanation!.inferenceSource,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _deniExplanation!.answer,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.48,
                            color: EnpriveColors.ink,
                          ),
                        ),
                        if (_deniExplanation!.processSteps.isNotEmpty ||
                            _deniExplanation!.thoughtSummary != null ||
                            _deniExplanation!.thoughtSignature != null) ...[
                          const SizedBox(height: 12),
                          AnalysisSavedTraceCard(
                            processSteps: _deniExplanation!.processSteps,
                            thoughtSummary: _deniExplanation!.thoughtSummary,
                            thoughtSignature:
                                _deniExplanation!.thoughtSignature,
                            title: l10n.stepsAndReasoning,
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Docked Bottom Bar (Exact B30 Pattern: Deni on left + Dark Pill CTA on right)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
            decoration: BoxDecoration(
              color: EnpriveColors.surface,
              border: Border(
                top: BorderSide(
                  color: EnpriveColors.ink.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Row(
              children: [
                DeniAnimatedMascot(
                  size: 56,
                  pose: _deniPose,
                  onTap: () => _askDeni(
                    _selectedQuestionIndex,
                    activeQuestion,
                    languageCode,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: EnpriveColors.ctaInk,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: _isAskingDeni
                          ? null
                          : () {
                              if (_deniExplanation == null) {
                                _askDeni(
                                  _selectedQuestionIndex,
                                  activeQuestion,
                                  languageCode,
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            },
                      child: Text(
                        _deniExplanation == null
                            ? l10n.btnAskDeni
                            : l10n.btnDone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactEvidenceRow extends StatelessWidget {
  final String iconSvg;
  final Color iconColor;
  final String label;
  final String body;

  const _CompactEvidenceRow({
    required this.iconSvg,
    required this.iconColor,
    required this.label,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: EnpriveDuotoneIcon(iconSvg, size: 17, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: EnpriveColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: EnpriveColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
