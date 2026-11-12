import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../core/theme/enprive_theme.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import 'deni_animated_mascot.dart';
import 'enprive_provenance_chip.dart';
import 'enprive_tactile_button.dart';

/// Brilliant B30-inspired 4-Part Evidence Inspection Sheet + 1-Turn "Ask Deni".
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
      backgroundColor: EnpriveColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.55,
        maxChildSize: 0.94,
        builder: (context, scrollController) => WhyThisFindingSheet(
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
  String _selectedQuestion = 'What does this mean for a child or classroom?';

  static const List<String> _presetQuestions = [
    'What does this mean for a child or classroom?',
    'Can a parent or teacher opt out of this?',
    'What does this policy excerpt leave unverified?',
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final finding = widget.finding;
    final isMatched = finding.status == EvidenceStatus.sourceMatched;

    return SafeArea(
      child: Column(
        children: [
          // Top drag handle + header bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: EnpriveColors.ink.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isMatched
                            ? EnpriveColors.stateNoConcernBg
                            : EnpriveColors.stateInsufficientEvidenceBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMatched
                                ? Symbols.verified_rounded
                                : Symbols.help_outline_rounded,
                            size: 15,
                            color: isMatched
                                ? EnpriveColors.stateNoConcernFg
                                : EnpriveColors.stateInsufficientEvidenceFg,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isMatched
                                ? l10n.statusSourceMatched
                                : l10n.statusUnverified,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isMatched
                                  ? EnpriveColors.stateNoConcernFg
                                  : EnpriveColors.stateInsufficientEvidenceFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Symbols.close_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              children: [
                Text(
                  l10n.btnWhyThisFinding,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: EnpriveColors.tealStrong,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  finding.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 20),

                // SECTION 1: What the policy says (Verbatim Source Serif 4 Quote + Context)
                _EvidenceSectionCard(
                  stepNumber: '01',
                  title: 'What the policy says (Verbatim Quote)',
                  icon: Symbols.format_quote_rounded,
                  accentColor: EnpriveColors.tealStrong,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: EnpriveColors.quoteSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(
                            left: BorderSide(
                              color: EnpriveColors.teal,
                              width: 4,
                            ),
                          ),
                        ),
                        child: finding.contextWindow != null
                            ? RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily:
                                        EnpriveTheme.primaryDisplayFontFamily,
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
                                            .withValues(alpha: 0.25),
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
                                  fontFamily:
                                      EnpriveTheme.primaryDisplayFontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  color: EnpriveColors.ink,
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Symbols.tag_rounded,
                            size: 14,
                            color: EnpriveColors.inkSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Snapshot Hash: ${widget.snapshotDigest} · ${finding.whatPolicySays}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: EnpriveColors.inkSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SECTION 2: Plain-language interpretation
                _EvidenceSectionCard(
                  stepNumber: '02',
                  title: 'Plain-language interpretation',
                  icon: Symbols.lightbulb_rounded,
                  accentColor: EnpriveColors.ctaInk,
                  child: Text(
                    finding.explanation,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 16),

                // SECTION 3: What Android reports (Device Observation)
                _EvidenceSectionCard(
                  stepNumber: '03',
                  title: 'What Android reports on this phone',
                  icon: Symbols.phone_android_rounded,
                  accentColor: EnpriveColors.chipOnDeviceFg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        finding.whatAndroidReports,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.permissionLimitationNotice,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: EnpriveColors.inkSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SECTION 4: What remains unknown (Evidence Boundary)
                _EvidenceSectionCard(
                  stepNumber: '04',
                  title: 'What remains unknown (Evidence Boundary)',
                  icon: Symbols.privacy_tip_rounded,
                  accentColor: EnpriveColors.stateReviewRecommendedFg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: finding.unknowns
                        .map(
                          (u) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color:
                                        EnpriveColors.stateReviewRecommendedFg,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    u,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // INTERACTIVE 1-TURN "ASK DENI" STAGE
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: EnpriveColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: EnpriveColors.teal.withValues(alpha: 0.22),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0E4A43).withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          DeniAnimatedMascot(
                            size: 68,
                            pose: _deniPose,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      l10n.btnAskDeni,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: EnpriveColors.ink,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (_deniExplanation != null)
                                      EnpriveProvenanceChip(
                                        source:
                                            _deniExplanation!.inferenceSource,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'One-turn evidence Q&A anchored strictly to this quote.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: EnpriveColors.inkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Preset question pills
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _presetQuestions.map((q) {
                          final isSelected = q == _selectedQuestion &&
                              _deniExplanation != null;
                          return InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _isAskingDeni ? null : () => _askDeni(q),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? EnpriveColors.teal.withValues(alpha: 0.14)
                                    : EnpriveColors.paper,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? EnpriveColors.teal
                                      : EnpriveColors.ink
                                          .withValues(alpha: 0.12),
                                ),
                              ),
                              child: Text(
                                q,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
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
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Deni is checking the verbatim policy clause…',
                              style: TextStyle(
                                fontSize: 13,
                                color: EnpriveColors.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ] else if (_deniExplanation != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: EnpriveColors.paper,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _deniExplanation!.answer,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Boundary: ${_deniExplanation!.unknownBoundary}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: EnpriveColors.tealStrong,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        EnpriveTactileButton(
                          label: l10n.btnAskDeni,
                          leading: const Icon(
                            Symbols.chat_bubble_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () => _askDeni(_selectedQuestion),
                        ),
                      ],
                    ],
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

class _EvidenceSectionCard extends StatelessWidget {
  final String stepNumber;
  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  const _EvidenceSectionCard({
    required this.stepNumber,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EnpriveColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EnpriveColors.ink.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stepNumber,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: EnpriveColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
