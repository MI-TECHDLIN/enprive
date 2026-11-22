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
  });

  final String clearTitle;
  final String clearExample;
  final String foggyTitle;
  final String foggyExample;
  final String tipsTitle;
  final List<String> tips;
  final String semanticDescription;
}

/// A side-by-side (stacked above 1.35x text scale) comparison of a clear policy sentence
/// versus a foggy one ('may share with trusted partners for business purposes') with
/// marker icons and 2-3 fog-spotting tips, including that silence is not a promise.
class PolicyFogDiagram extends StatelessWidget {
  const PolicyFogDiagram({super.key, required this.labels});

  final PolicyFogDiagramLabels labels;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: labels.semanticDescription,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1.0);
          final useVerticalLayout =
              constraints.maxWidth < 480 || textScale > 1.35;

          return _PolicyFogContent(
            labels: labels,
            isRtl: isRtl,
            useVerticalLayout: useVerticalLayout,
            reduceMotion: reduceMotion,
            maxWidth: constraints.maxWidth,
          );
        },
      ),
    );
  }
}

class _PolicyFogContent extends StatelessWidget {
  const _PolicyFogContent({
    required this.labels,
    required this.isRtl,
    required this.useVerticalLayout,
    required this.reduceMotion,
    required this.maxWidth,
  });

  final PolicyFogDiagramLabels labels;
  final bool isRtl;
  final bool useVerticalLayout;
  final bool reduceMotion;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;
    final semantics = context.enpriveSemantics;

    // Colors
    final clearColor = categoryColors.parentalConsent.color;
    final foggyColor = semantics.reviewRecommended.icon;
    final tipColor = categoryColors.tracking.color;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final clampedTextScale = textScale.clamp(1.0, 1.5);
        final cardPadding = 16.0 * clampedTextScale;
        final spacing = 16.0 * clampedTextScale;
        final titleSize = 16 * clampedTextScale;
        final exampleSize = 13 * clampedTextScale;
        final tipSize = 13 * clampedTextScale;
        final deniSize = 56 * clampedTextScale;

        // Calculate card dimensions
        final cardWidth = useVerticalLayout
            ? width - 32
            : (width - 48) / 3; // 16 left + 16 right + 16 gap * 2

        // Estimate card heights (rough estimate for layout)
        final clearCardHeight = _estimateCardHeight(
          titleSize: titleSize,
          exampleSize: exampleSize,
          cardPadding: cardPadding,
          clampedTextScale: clampedTextScale,
        );
        final foggyCardHeight = _estimateCardHeight(
          titleSize: titleSize,
          exampleSize: exampleSize,
          cardPadding: cardPadding,
          clampedTextScale: clampedTextScale,
        );
        final tipsCardHeight = _estimateTipsCardHeight(
          tipSize: tipSize,
          cardPadding: cardPadding,
          clampedTextScale: clampedTextScale,
          tipsCount: labels.tips.length,
        );

        double contentHeight;
        if (useVerticalLayout) {
          contentHeight =
              clearCardHeight + foggyCardHeight + tipsCardHeight +
              spacing * 3 + deniSize + 32;
        } else {
          contentHeight =
              math.max(math.max(clearCardHeight, foggyCardHeight), tipsCardHeight) +
              spacing * 2 +
              deniSize +
              32;
        }

        return SizedBox(
          width: width,
          height: contentHeight,
          child: Stack(
            children: [
              // Clear Policy Card (top in vertical, left in horizontal)
              if (useVerticalLayout)
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  child: _PolicyExampleCard(
                    title: labels.clearTitle,
                    example: labels.clearExample,
                    icon: LucideIcons.checkCircle2,
                    accentColor: clearColor,
                    backgroundColor: scheme.surfaceContainerLow,
                    borderColor: clearColor,
                    badgeLabel: 'Clear',
                    badgeIcon: LucideIcons.shieldCheck,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    exampleSize: exampleSize,
                    clampedTextScale: clampedTextScale,
                  )
                )
              else
                Positioned(
                  top: 0,
                  left: isRtl ? width * 2 / 3 + 16 : 16,
                  width: cardWidth,
                  bottom: spacing + deniSize + 16,
                  child: _PolicyExampleCard(
                    title: labels.clearTitle,
                    example: labels.clearExample,
                    icon: LucideIcons.checkCircle2,
                    accentColor: clearColor,
                    backgroundColor: scheme.surfaceContainerLow,
                    borderColor: clearColor,
                    badgeLabel: 'Clear',
                    badgeIcon: LucideIcons.shieldCheck,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    exampleSize: exampleSize,
                    clampedTextScale: clampedTextScale,
                  ),
                ),

              // Foggy Policy Card (middle in vertical, center in horizontal)
              if (useVerticalLayout)
                Positioned(
                  top: clearCardHeight + spacing,
                  left: 16,
                  right: 16,
                  child: _PolicyExampleCard(
                    title: labels.foggyTitle,
                    example: labels.foggyExample,
                    icon: LucideIcons.alertCircle,
                    accentColor: foggyColor,
                    backgroundColor: scheme.surfaceContainer,
                    borderColor: foggyColor,
                    badgeLabel: 'Foggy',
                    badgeIcon: LucideIcons.cloud,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    exampleSize: exampleSize,
                    clampedTextScale: clampedTextScale,
                    isFoggy: true,
                  )
                )
              else
                Positioned(
                  top: 0,
                  left: isRtl ? width / 3 + 16 : width / 3 + 16,
                  width: cardWidth,
                  bottom: spacing + deniSize + 16,
                  child: _PolicyExampleCard(
                    title: labels.foggyTitle,
                    example: labels.foggyExample,
                    icon: LucideIcons.alertCircle,
                    accentColor: foggyColor,
                    backgroundColor: scheme.surfaceContainer,
                    borderColor: foggyColor,
                    badgeLabel: 'Foggy',
                    badgeIcon: LucideIcons.cloud,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    exampleSize: exampleSize,
                    clampedTextScale: clampedTextScale,
                    isFoggy: true,
                  ),
                ),

              // Tips Card (bottom in vertical, right in horizontal)
              if (useVerticalLayout)
                Positioned(
                  top: clearCardHeight + foggyCardHeight + spacing * 2,
                  left: 16,
                  right: 16,
                  child: _FogTipsCard(
                    title: labels.tipsTitle,
                    tips: labels.tips,
                    accentColor: tipColor,
                    backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderColor: tipColor,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    tipSize: tipSize,
                    clampedTextScale: clampedTextScale,
                  )
                )
              else
                Positioned(
                  top: 0,
                  left: isRtl ? 16 : width * 2 / 3 + 16,
                  width: cardWidth,
                  bottom: spacing + deniSize + 16,
                  child: _FogTipsCard(
                    title: labels.tipsTitle,
                    tips: labels.tips,
                    accentColor: tipColor,
                    backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderColor: tipColor,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    tipSize: tipSize,
                    clampedTextScale: clampedTextScale,
                  ),
                ),

              // Deni mascot
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Center(
                  child: DeniAnimatedMascot(
                    size: deniSize,
                    pose: DeniPose.peek,
                    holdStill: true,
                    showAmbientGlow: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _estimateCardHeight({
    required double titleSize,
    required double exampleSize,
    required double cardPadding,
    required double clampedTextScale,
  }) {
    return cardPadding * 2 + titleSize * 1.25 + 8 + exampleSize * 1.4 * 3 + 24;
  }

  double _estimateTipsCardHeight({
    required double tipSize,
    required double cardPadding,
    required double clampedTextScale,
    required int tipsCount,
  }) {
    return cardPadding * 2 + 16 * clampedTextScale * 1.25 + 8 + tipsCount * (tipSize * 1.4 + 8);
  }
}

class _PolicyExampleCard extends StatelessWidget {
  const _PolicyExampleCard({
    required this.title,
    required this.example,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.cardPadding,
    required this.titleSize,
    required this.exampleSize,
    required this.clampedTextScale,
    this.isFoggy = false,
  });

  final String title;
  final String example;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final String badgeLabel;
  final IconData badgeIcon;
  final double cardPadding;
  final double titleSize;
  final double exampleSize;
  final double clampedTextScale;
  final bool isFoggy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(EnpriveRadii.card),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge + icon + title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * clampedTextScale,
                    vertical: 4 * clampedTextScale,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(EnpriveRadii.chip),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        badgeIcon,
                        size: 12 * clampedTextScale,
                        color: accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 11 * clampedTextScale,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36 * clampedTextScale,
                  height: 36 * clampedTextScale,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 18 * clampedTextScale,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Example text
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12 * clampedTextScale),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(EnpriveRadii.md),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                example,
                style: TextStyle(
                  fontSize: exampleSize,
                  fontWeight: FontWeight.w400,
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                  fontFamily: 'SourceSerif4',
                ),
              ),
            ),
            if (isFoggy) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 14 * clampedTextScale,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Silence in a policy is not a promise.',
                      style: TextStyle(
                        fontSize: 11 * clampedTextScale,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FogTipsCard extends StatelessWidget {
  const _FogTipsCard({
    required this.title,
    required this.tips,
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.cardPadding,
    required this.titleSize,
    required this.tipSize,
    required this.clampedTextScale,
  });

  final String title;
  final List<String> tips;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final double cardPadding;
  final double titleSize;
  final double tipSize;
  final double clampedTextScale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(EnpriveRadii.card),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36 * clampedTextScale,
                  height: 36 * clampedTextScale,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.lightbulb,
                    size: 18 * clampedTextScale,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.asMap().entries.map((entry) {
              final index = entry.key;
              final tip = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index == tips.length - 1 ? 0 : 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20 * clampedTextScale,
                      height: 20 * clampedTextScale,
                      margin: EdgeInsets.only(top: 2 * clampedTextScale),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10 * clampedTextScale,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: tipSize,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}