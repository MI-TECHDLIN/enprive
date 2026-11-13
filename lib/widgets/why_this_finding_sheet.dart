import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../core/theme/enprive_theme.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import 'analysis_process_trace.dart';
import 'deni_animated_mascot.dart';
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
  String _selectedQuestion = 'What does this mean for my child?';

  static const List<String> _presetQuestions = [
    'What does this mean for my child?',
    'Can we turn this off or opt out?',
    'What is still unknown here?',
  ];

  Future<void> _askDeni(String question) async {
    setState(() {
      _selectedQuestion = question;
      _isAskingDeni = true;
      _deniPose = DeniPose.thinking;
    });

    final explanation = await widget.coordinator.askDeniAboutFinding(
      finding: widget.finding,
      question: question,
      snapshotText: widget.snapshotText,
      cloudConsent: widget.cloudConsentGrantedForSession,
    );

    if (!mounted) return;
    setState(() {
      _isAskingDeni = false;
      _deniExplanation = explanation;
      _deniPose = DeniPose.explaining;
    });
  }

  String _categoryLabel(FindingCategory category) {
    return switch (category) {
      FindingCategory.dataCollection => 'Data Collection',
      FindingCategory.sharing => 'Third-Party Sharing',
      FindingCategory.tracking => 'Location & Tracking',
      FindingCategory.retention => 'Retention & Voice',
      FindingCategory.parentalConsent => 'Parental Controls',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Symbols.close_rounded, size: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
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
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 24,
                      ),
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
                                _categoryLabel(finding.category),
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
                              icon: Symbols.lightbulb_rounded,
                              iconColor: EnpriveColors.tealStrong,
                              label: 'In plain language',
                              body: finding.explanation,
                            ),
                            Divider(
                              height: 24,
                              color: EnpriveColors.ink.withValues(alpha: 0.08),
                            ),
                            _CompactEvidenceRow(
                              icon: Symbols.phone_android_rounded,
                              iconColor: EnpriveColors.chipOnDeviceFg,
                              label: 'On this phone',
                              body: finding.whatAndroidReports,
                            ),
                            if (finding.unknowns.isNotEmpty) ...[
                              Divider(
                                height: 24,
                                color:
                                    EnpriveColors.ink.withValues(alpha: 0.08),
                              ),
                              _CompactEvidenceRow(
                                icon: Symbols.help_outline_rounded,
                                iconColor:
                                    EnpriveColors.stateReviewRecommendedFg,
                                label: 'What remains unknown',
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
                  children: _presetQuestions.map((q) {
                    final isSelected =
                        q == _selectedQuestion && _deniExplanation != null;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _isAskingDeni ? null : () => _askDeni(q),
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
                      initialLabel: 'Checking on-device Gemini Nano…',
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
                            const Text(
                              'Deni’s Answer',
                              style: TextStyle(
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
                            thoughtSignature: _deniExplanation!.thoughtSignature,
                            title: 'Steps & model reasoning',
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
                  onTap: () => _askDeni(_selectedQuestion),
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
                                _askDeni(_selectedQuestion);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                      child: Text(
                        _deniExplanation == null ? l10n.btnAskDeni : 'Done',
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
  final IconData icon;
  final Color iconColor;
  final String label;
  final String body;

  const _CompactEvidenceRow({
    required this.icon,
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
          child: Icon(icon, size: 17, color: iconColor),
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
