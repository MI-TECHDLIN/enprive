import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Labels for the policy fog diagram (Topic 7: Spotting Unclear Policies & Dark Patterns).
/// All user-facing strings come from this object for localization.
@immutable
class PolicyFogDiagramLabels {
  const PolicyFogDiagramLabels({
    required this.clearTitle,
    required this.clearExample,
    required this.foggyTitle,
    required this.foggyExample,
    required this.tipsTitle,
    required this.tips,
    required this.semanticDescription,
    this.silenceNote,
  });

  final String clearTitle;
  final String clearExample;
  final String foggyTitle;
  final String foggyExample;
  final String tipsTitle;
  final List<String> tips;
  final String semanticDescription;

  /// Optional localized reminder note displayed in the reserved Deni footer.
  final String? silenceNote;
}

/// A comparison diagram of a clear policy sentence versus a foggy one, followed
/// by fog-spotting tips and a separate silence-is-not-a-promise footer note
/// paired with Deni.
///
/// Built in pure flex flow (no Stack overlap) with Direction A tonal surfaces,
/// solid vs. dashed framing so meaning never relies on color alone, and clean
/// reflow from 320dp widths up to wide screens and 200% text scale.
class PolicyFogDiagram extends StatelessWidget {
  const PolicyFogDiagram({super.key, required this.labels});

  static const Key mascotKey = Key('policy_fog_diagram_mascot');
  static const Key clearTitleKey = Key('policy_fog_clear_title');
  static const Key clearExampleKey = Key('policy_fog_clear_example');
  static const Key foggyTitleKey = Key('policy_fog_foggy_title');
  static const Key foggyExampleKey = Key('policy_fog_foggy_example');
  static const Key tipsTitleKey = Key('policy_fog_tips_title');
  static const Key silenceNoteKey = Key('policy_fog_silence_note');

  static Key tipBadgeKey(int index) => Key('policy_fog_tip_badge_$index');

  static Key tipTextKey(int index) => Key('policy_fog_tip_text_$index');

  final PolicyFogDiagramLabels labels;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;
    final reviewAmber = EnpriveStaticColors.reviewAmber(
      Theme.of(context).brightness,
    );
    final quoteStyle = context.enpriveType.policyQuotation;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: labels.semanticDescription,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1.0);
            final useSideBySide =
                constraints.maxWidth >= 520 && textScale <= 1.25;
            final stackFooter =
                constraints.maxWidth < 340 && textScale > 1.5;

            final clearCard = _PolicyExampleCard(
              title: labels.clearTitle,
              titleKey: clearTitleKey,
              example: labels.clearExample,
              exampleKey: clearExampleKey,
              icon: LucideIcons.checkCircle2,
              containerColor: scheme.secondaryContainer,
              onContainerColor: scheme.onSecondaryContainer,
              accentColor: scheme.secondary,
              quoteStyle: quoteStyle,
              dashedOutline: false,
            );

            final foggyCard = _PolicyExampleCard(
              title: labels.foggyTitle,
              titleKey: foggyTitleKey,
              example: labels.foggyExample,
              exampleKey: foggyExampleKey,
              icon: LucideIcons.cloud,
              containerColor: reviewAmber.container,
              onContainerColor: reviewAmber.onContainer,
              accentColor: reviewAmber.color,
              quoteStyle: quoteStyle,
              dashedOutline: true,
            );

            final tipsCard = _FogTipsCard(
              title: labels.tipsTitle,
              titleKey: tipsTitleKey,
              tips: labels.tips,
              badgeContainerColor: categoryColors.tracking.container,
              badgeOnContainerColor: categoryColors.tracking.onContainer,
              accentColor: categoryColors.tracking.color,
            );

            final noteText = labels.silenceNote?.trim();
            final hasSilenceNote = noteText != null && noteText.isNotEmpty;

            final mascot = const DeniAnimatedMascot(
              key: mascotKey,
              size: 48,
              pose: DeniPose.peek,
              holdStill: true,
              showAmbientGlow: false,
            );

            final footer = Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(EnpriveRadii.md),
              ),
              child: !hasSilenceNote
                  ? Center(child: mascot)
                  : stackFooter
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        mascot,
                        const SizedBox(height: 8),
                        Text(
                          noteText,
                          key: silenceNoteKey,
                          style: m3e.typeScale.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        mascot,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            noteText,
                            key: silenceNoteKey,
                            style: m3e.typeScale.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
            );

            final diagramBody = Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(EnpriveRadii.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (useSideBySide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: clearCard),
                          const SizedBox(width: 12),
                          Expanded(child: foggyCard),
                        ],
                      ),
                    )
                  else ...[
                    clearCard,
                    const SizedBox(height: 12),
                    foggyCard,
                  ],
                  const SizedBox(height: 12),
                  tipsCard,
                  const SizedBox(height: 12),
                  footer,
                ],
              ),
            );

            return constraints.maxHeight.isFinite
                ? SingleChildScrollView(primary: false, child: diagramBody)
                : diagramBody;
          },
        ),
      ),
    );
  }
}

class _PolicyExampleCard extends StatelessWidget {
  const _PolicyExampleCard({
    required this.title,
    required this.titleKey,
    required this.example,
    required this.exampleKey,
    required this.icon,
    required this.containerColor,
    required this.onContainerColor,
    required this.accentColor,
    required this.quoteStyle,
    required this.dashedOutline,
  });

  final String title;
  final Key titleKey;
  final String example;
  final Key exampleKey;
  final IconData icon;
  final Color containerColor;
  final Color onContainerColor;
  final Color accentColor;
  final TextStyle quoteStyle;
  final bool dashedOutline;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.78),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  key: titleKey,
                  style: m3e.typography.emphasized.titleSmall.copyWith(
                    color: onContainerColor,
                    height: 1.28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(EnpriveRadii.sm),
            ),
            child: Text(
              example,
              key: exampleKey,
              style: quoteStyle.copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
                height: 1.44,
              ),
            ),
          ),
        ],
      ),
    );

    if (!dashedOutline) return card;

    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: accentColor,
        radius: EnpriveRadii.md,
      ),
      child: card,
    );
  }
}

class _FogTipsCard extends StatelessWidget {
  const _FogTipsCard({
    required this.title,
    required this.titleKey,
    required this.tips,
    required this.badgeContainerColor,
    required this.badgeOnContainerColor,
    required this.accentColor,
  });

  final String title;
  final Key titleKey;
  final List<String> tips;
  final Color badgeContainerColor;
  final Color badgeOnContainerColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeContainerColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.lightbulb,
                  size: 18,
                  color: badgeOnContainerColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  key: titleKey,
                  style: m3e.typography.emphasized.titleSmall.copyWith(
                    color: scheme.onSurface,
                    height: 1.28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < tips.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeContainerColor,
                    borderRadius: BorderRadius.circular(EnpriveRadii.pill),
                  ),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Text(
                      '${i + 1}',
                      key: PolicyFogDiagram.tipBadgeKey(i),
                      style: m3e.typography.emphasized.labelSmall.copyWith(
                        color: badgeOnContainerColor,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tips[i],
                    key: PolicyFogDiagram.tipTextKey(i),
                    style: m3e.typeScale.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                      height: 1.42,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1.0),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = math.min(dist + 6.0, metric.length);
        dashPath.addPath(metric.extractPath(dist, next), Offset.zero);
        dist = next + 4.5;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
