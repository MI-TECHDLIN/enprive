import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Labels for the safe sharing diagram (Topic 9: Safe-Sharing Habits for Kids).
/// All user-facing strings come from this object for localization.
@immutable
class SafeSharingDiagramLabels {
  const SafeSharingDiagramLabels({
    required this.stop,
    required this.think,
    required this.connect,
    required this.cafeteriaTest,
    required this.semanticDescription,
  });

  final String stop;
  final String think;
  final String connect;
  final String cafeteriaTest;
  final String semanticDescription;
}

/// A diagram showing the three steps 'Stop, Think, Connect' plus the
/// 'cafeteria test' callout (would I be happy if everyone at school saw this?).
class SafeSharingDiagram extends StatelessWidget {
  const SafeSharingDiagram({super.key, required this.labels});

  final SafeSharingDiagramLabels labels;

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

          return _SafeSharingContent(
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

class _SafeSharingContent extends StatelessWidget {
  const _SafeSharingContent({
    required this.labels,
    required this.isRtl,
    required this.useVerticalLayout,
    required this.reduceMotion,
    required this.maxWidth,
  });

  final SafeSharingDiagramLabels labels;
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

    // Colors from evidence categories
    final stopColor = categoryColors.tracking.color;
    final thinkColor = categoryColors.retention.color;
    final connectColor = categoryColors.parentalConsent.color;
    final cafeteriaColor = semantics.reviewRecommended.icon;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final clampedTextScale = textScale.clamp(1.0, 1.5);
        final nodeSize = 72.0 * clampedTextScale;
        final spacing = 16.0 * clampedTextScale;
        final cardPadding = 16.0 * clampedTextScale;
        final titleSize = 15 * clampedTextScale;
        final descSize = 13 * clampedTextScale;
        final deniSize = 56 * clampedTextScale;

        // Calculate card dimensions
        final cardWidth = useVerticalLayout
            ? width - 32
            : (width - 48) / 3; // 16 left + 16 right + 16 gap * 2

        // Calculate content height
        final stepCardHeight = 56 + 8 + titleSize * 1.25 + 8 + descSize * 1.4 * 2 + cardPadding * 2;
        final cafeteriaCardHeight = 56 + 8 + titleSize * 1.25 + 8 + descSize * 1.4 * 3 + cardPadding * 2;

        double contentHeight;
        if (useVerticalLayout) {
          contentHeight =
              stepCardHeight * 3 +
              cafeteriaCardHeight +
              spacing * 4 +
              deniSize +
              32;
        } else {
          contentHeight =
              math.max(stepCardHeight, cafeteriaCardHeight) +
              spacing * 2 +
              deniSize +
              32;
        }

        return SizedBox(
          width: width,
          height: contentHeight,
          child: Stack(
            children: [
              // Step 1: Stop
              if (useVerticalLayout)
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  child: _SafeSharingStepCard(
                    stepNumber: 1,
                    title: labels.stop,
                    description: 'Pause before you post a photo, video, name, or location.',
                    icon: LucideIcons.hand,
                    accentColor: stopColor,
                    backgroundColor: scheme.surfaceContainerLow,
                    borderColor: stopColor,
                    nodeSize: nodeSize,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    descSize: descSize,
                    clampedTextScale: clampedTextScale,
                  )
                )
              else
                Positioned(
                  top: 0,
                  left: isRtl ? width * 2 / 3 + 16 : 16,
                  width: cardWidth,
                  bottom: spacing * 2 + deniSize + 16,
                  child: _SafeSharingStepCard(
                    stepNumber: 1,
                    title: labels.stop,
                    description: 'Pause before you post a photo, video, name, or location.',
                    icon: LucideIcons.hand,
                    accentColor: stopColor,
                    backgroundColor: scheme.surfaceContainerLow,
                    borderColor: stopColor,
                    nodeSize: nodeSize,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    descSize: descSize,
                    clampedTextScale: clampedTextScale,
                  ),
                ),

              // Step 2: Think
              if (useVerticalLayout)
                Positioned(
                  top: stepCardHeight + spacing,
                  left: 16,
                  right: 16,
                  child: _SafeSharingStepCard(
                    stepNumber: 2,
                    title: labels.think,
                    description: 'Does this reveal my school, home, or where I am right now? Did I ask my friends?',
                    icon: LucideIcons.brain,
                    accentColor: thinkColor,
                    backgroundColor: scheme.surfaceContainer,
                    borderColor: thinkColor,
                    nodeSize: nodeSize,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    descSize: descSize,
                    clampedTextScale: clampedTextScale,
                  )
                )
              else
                Positioned(
                  top: 0,
                  left: isRtl ? width / 3 + 16 : width / 3 + 16,
                  width: cardWidth,
                  bottom: spacing * 2 + deniSize + 16,
                  child: _SafeSharingStepCard(
                    stepNumber: 2,
                    title: labels.think,
                    description: 'Does this reveal my school, home, or where I am right now? Did I ask my friends?',
                    icon: LucideIcons.brain,
                    accentColor: thinkColor,
                    backgroundColor: scheme.surfaceContainer,
                    borderColor: thinkColor,
                    nodeSize: nodeSize,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    descSize: descSize,
                    clampedTextScale: clampedTextScale,
                  ),
                ),

              // Step 3: Connect
              if (useVerticalLayout)
                Positioned(
                  top: stepCardHeight * 2 + spacing * 2,
                  left: 16,
                  right: 16,
                  child: _SafeSharingStepCard(
                    stepNumber: 3,
                    title: labels.connect,
                    description: 'Share with people you trust. Ask a trusted adult if you are not sure.',
                    icon: LucideIcons.users,
                    accentColor: connectColor,
                    backgroundColor: scheme.surfaceContainerHigh,
                    borderColor: connectColor,
                    nodeSize: nodeSize,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    descSize: descSize,
                    clampedTextScale: clampedTextScale,
                  )
                )
              else
                Positioned(
                  top: 0,
                  left: isRtl ? 16 : width * 2 / 3 + 16,
                  width: cardWidth,
                  bottom: spacing * 2 + deniSize + 16,
                  child: _SafeSharingStepCard(
                    stepNumber: 3,
                    title: labels.connect,
                    description: 'Share with people you trust. Ask a trusted adult if you are not sure.',
                    icon: LucideIcons.users,
                    accentColor: connectColor,
                    backgroundColor: scheme.surfaceContainerHigh,
                    borderColor: connectColor,
                    nodeSize: nodeSize,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    descSize: descSize,
                    clampedTextScale: clampedTextScale,
                  ),
                ),

              // Cafeteria Test Callout
              if (useVerticalLayout)
                Positioned(
                  top: stepCardHeight * 3 + spacing * 3,
                  left: 16,
                  right: 16,
                  child: _CafeteriaTestCard(
                    title: 'The Cafeteria Test',
                    description: labels.cafeteriaTest,
                    accentColor: cafeteriaColor,
                    backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderColor: cafeteriaColor,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    descSize: descSize,
                    clampedTextScale: clampedTextScale,
                  )
                )
              else
                Positioned(
                  top: 0,
                  left: isRtl ? 16 : width * 2 / 3 + 16,
                  width: cardWidth,
                  bottom: spacing * 2 + deniSize + 16,
                  child: _CafeteriaTestCard(
                    title: 'The Cafeteria Test',
                    description: labels.cafeteriaTest,
                    accentColor: cafeteriaColor,
                    backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderColor: cafeteriaColor,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    descSize: descSize,
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
                    pose: DeniPose.raiseHand,
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
}

class _SafeSharingStepCard extends StatelessWidget {
  const _SafeSharingStepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.nodeSize,
    required this.cardPadding,
    required this.titleSize,
    required this.descSize,
    required this.clampedTextScale,
  });

  final int stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final double nodeSize;
  final double cardPadding;
  final double titleSize;
  final double descSize;
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step circle with number
            Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: nodeSize * 0.35,
                      color: accentColor,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$stepNumber',
                      style: TextStyle(
                        fontSize: nodeSize * 0.22,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: descSize,
                      fontWeight: FontWeight.w400,
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
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

class _CafeteriaTestCard extends StatelessWidget {
  const _CafeteriaTestCard({
    required this.title,
    required this.description,
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.cardPadding,
    required this.titleSize,
    required this.descSize,
    required this.clampedTextScale,
  });

  final String title;
  final String description;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final double cardPadding;
  final double titleSize;
  final double descSize;
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
                    LucideIcons.users,
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
                description,
                style: TextStyle(
                  fontSize: descSize,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
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
                    'Even disappearing posts can be screenshotted and stay online permanently.',
                    style: TextStyle(
                      fontSize: 11 * clampedTextScale,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}