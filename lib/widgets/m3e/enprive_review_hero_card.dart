import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';
import '../../l10n/app_localizations.dart';
import '../deni_animated_mascot.dart';
import '../enprive_tactile_pressable.dart';
import '../review/enprive_evidence_ring.dart';
import '../review/enprive_state_chip.dart';
import '../review/evidence_category_style.dart';

/// Review result hero ("Calm evidence").
///
/// The review state leads: a state chip (icon and words), the app identity,
/// and the evidence ring (findings per category, a count never a score) with
/// its legend. One filled pill holds the primary action, with compact Deni
/// inside when it starts the AI explanation; Source and Read aloud are tonal
/// icon buttons so emphasis is identical in light and dark.
class EnpriveReviewHeroCard extends StatelessWidget {
  final String subjectTitle;
  final String subtitle;
  final ReviewOverallState overallState;
  final String stateBadgeLabel;
  final String findingsCountValue;
  final String findingsLabel;
  final String verifiedCountValue;
  final String verifiedLabel;
  final String secondaryMetricValue;
  final String secondaryMetricLabel;
  final bool hasPermissionReport;
  final DeniPose mascotPose;
  final String sourceActionLabel;
  final String sourceActionTooltip;
  final VoidCallback onSourceAction;
  final bool isSpeaking;
  final String voiceTooltip;
  final VoidCallback onVoiceAction;
  final String primaryCtaLabel;
  final VoidCallback onPrimaryCta;

  /// Kept for source compatibility; Deni now lives inside the primary pill.
  final VoidCallback? onMascotTap;

  /// Findings per category for the evidence ring, in
  /// [EvidenceCategoryStyle.order]. Empty draws only the ring track.
  final Map<FindingCategory, int> categoryCounts;

  /// Whether the primary pill starts Deni's explanation and so shows Deni.
  final bool primaryCtaShowsDeni;

  const EnpriveReviewHeroCard({
    super.key,
    required this.subjectTitle,
    required this.subtitle,
    required this.overallState,
    required this.stateBadgeLabel,
    required this.findingsCountValue,
    required this.findingsLabel,
    required this.verifiedCountValue,
    required this.verifiedLabel,
    required this.secondaryMetricValue,
    required this.secondaryMetricLabel,
    required this.hasPermissionReport,
    required this.mascotPose,
    required this.sourceActionLabel,
    required this.sourceActionTooltip,
    required this.onSourceAction,
    required this.isSpeaking,
    required this.voiceTooltip,
    required this.onVoiceAction,
    required this.primaryCtaLabel,
    required this.onPrimaryCta,
    this.onMascotTap,
    this.categoryCounts = const {},
    this.primaryCtaShowsDeni = true,
  });

  /// TalkBack label of the evidence ring, e.g. "7 findings: 3 Data
  /// Collection, 1 Third-Party Sharing. Review recommended."
  static String ringSemanticLabel(
    BuildContext context, {
    required int total,
    required Map<FindingCategory, int> counts,
    required String stateLabel,
  }) {
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    final parts = [
      for (final entry in counts.entries)
        '${entry.value} ${EvidenceCategoryStyle.of(context, entry.key).label}',
    ];
    final countPhrase = l10n.findingsCountPhrase(total);
    return parts.isEmpty
        ? '$countPhrase. $stateLabel.'
        : '$countPhrase: ${parts.join(', ')}. $stateLabel.';
  }

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final total = int.tryParse(findingsCountValue) ?? 0;

    final ring = EnpriveEvidenceRing(
      counts: categoryCounts,
      total: total,
      centerUnit: l10n.findingsCountUnit(total),
      semanticLabel: ringSemanticLabel(
        context,
        total: total,
        counts: categoryCounts,
        stateLabel: stateBadgeLabel,
      ),
    );

    final legend = _RingLegend(
      counts: categoryCounts,
      metrics: [
        (verifiedCountValue, verifiedLabel),
        (secondaryMetricValue, secondaryMetricLabel),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(EnpriveRadii.hero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EnpriveStateChip(state: overallState, label: stateBadgeLabel),
          const SizedBox(height: 14),
          Text(
            subjectTitle,
            style: m3e.typography.emphasized.headlineSmall.copyWith(
              color: scheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: m3e.typeScale.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide =
                  constraints.maxWidth >= 300 && textScale <= 1.3;
              if (sideBySide) {
                return Row(
                  children: [
                    ring,
                    const SizedBox(width: 20),
                    Expanded(child: legend),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: ring),
                  const SizedBox(height: 16),
                  legend,
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final iconButtons = [
                _TonalIconButton(
                  tooltip: sourceActionTooltip,
                  semanticLabel: sourceActionLabel,
                  icon: LucideIcons.fileText,
                  onPressed: onSourceAction,
                ),
                _TonalIconButton(
                  tooltip: voiceTooltip,
                  icon: isSpeaking ? LucideIcons.square : LucideIcons.volume2,
                  selected: isSpeaking,
                  onPressed: onVoiceAction,
                ),
              ];
              final pill = _PrimaryPill(
                label: primaryCtaLabel,
                onPressed: onPrimaryCta,
                deniPose: primaryCtaShowsDeni ? mascotPose : null,
              );
              final stack = constraints.maxWidth < 300 || textScale > 1.3;
              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    pill,
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconButtons[0],
                        const SizedBox(width: 8),
                        iconButtons[1],
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: pill),
                  const SizedBox(width: 8),
                  iconButtons[0],
                  const SizedBox(width: 8),
                  iconButtons[1],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Category legend beside the ring, then the evidence metrics.
class _RingLegend extends StatelessWidget {
  final Map<FindingCategory, int> counts;
  final List<(String value, String label)> metrics;

  const _RingLegend({required this.counts, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The ring's single TalkBack node already reads the breakdown.
        ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in counts.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: EvidenceCategoryStyle.of(
                            context,
                            entry.key,
                          ).color.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          EvidenceCategoryStyle.of(context, entry.key).label,
                          style: m3e.typeScale.bodyMedium.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.value}',
                        style: m3e.typeScale.titleSmall.copyWith(
                          color: scheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (counts.isNotEmpty) const SizedBox(height: 6),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            for (final (value, label) in metrics)
              MergeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: m3e.typography.emphasized.titleMedium.copyWith(
                        color: scheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        style: m3e.typeScale.labelMedium.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Tonal round icon button (48dp target) used for Source and Read aloud.
class _TonalIconButton extends StatelessWidget {
  final String tooltip;
  final String? semanticLabel;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const _TonalIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = EnpriveM3ETheme.of(context).colorScheme;
    final button = IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      isSelected: selected,
      style: IconButton.styleFrom(
        backgroundColor: selected ? scheme.primary : scheme.secondaryContainer,
        foregroundColor: selected
            ? scheme.onPrimary
            : scheme.onSecondaryContainer,
        minimumSize: const Size(52, 52),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      icon: Icon(icon, size: 20),
    );
    if (semanticLabel == null) return button;
    return Semantics(label: semanticLabel, child: button);
  }
}

/// The single filled pill on the hero. When it starts Deni's explanation it
/// carries compact Deni and a slow gradient ring that turns three times when
/// results appear, then rests; under reduced motion the ring is static.
class _PrimaryPill extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final DeniPose? deniPose;

  const _PrimaryPill({
    required this.label,
    required this.onPressed,
    required this.deniPose,
  });

  @override
  State<_PrimaryPill> createState() => _PrimaryPillState();
}

class _PrimaryPillState extends State<_PrimaryPill>
    with SingleTickerProviderStateMixin {
  static const int _turns = 3;
  static const Duration _turnDuration = Duration(seconds: 3);

  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: _turnDuration * _turns,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion || widget.deniPose == null) {
      _ring.value = 0;
      _ring.stop();
    } else if (!_ring.isAnimating && _ring.value == 0) {
      _ring.forward();
    }
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveTactilePressable(
      label: widget.label,
      onPressed: widget.onPressed,
      builder: _buildFace,
    );
  }

  Widget _buildFace(BuildContext context, bool isPressed) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final hasDeni = widget.deniPose != null;
    final radius = isPressed && !reduceMotion ? 14.0 : 28.0;

    final face = AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : EnpriveSpringCurve.fastSpatial.duration,
      curve: EnpriveSpringCurve.fastSpatial,
      constraints: const BoxConstraints(minHeight: 56),
      padding: EdgeInsetsDirectional.fromSTEB(hasDeni ? 6 : 24, 6, 24, 6),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasDeni) ...[
            ExcludeSemantics(
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: DeniAnimatedMascot(size: 30, pose: widget.deniPose!),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: m3e.typography.emphasized.titleMedium.copyWith(
                color: scheme.onPrimary,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );

    if (!hasDeni) return face;
    return AnimatedBuilder(
      animation: _ring,
      builder: (context, child) => CustomPaint(
        foregroundPainter: _TurningRingPainter(
          turn: _ring.value * _turns,
          radius: radius,
          colors: [
            scheme.primaryContainer,
            scheme.tertiaryContainer,
            scheme.inversePrimary,
            scheme.primaryContainer,
          ],
        ),
        child: child,
      ),
      child: face,
    );
  }
}

/// A thin sweep-gradient outline inside the pill that turns with [turn].
class _TurningRingPainter extends CustomPainter {
  final double turn;
  final double radius;
  final List<Color> colors;

  const _TurningRingPainter({
    required this.turn,
    required this.radius,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.0;
    final rect = (Offset.zero & size).deflate(stroke / 2 + 1);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.min(radius, rect.shortestSide / 2)),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = SweepGradient(
          colors: colors,
          transform: GradientRotation(turn * 2 * math.pi),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_TurningRingPainter oldDelegate) =>
      oldDelegate.turn != turn ||
      oldDelegate.radius != radius ||
      oldDelegate.colors != colors;
}
