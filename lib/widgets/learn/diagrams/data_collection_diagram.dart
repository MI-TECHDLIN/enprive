import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Labels for the data collection diagram (Topic 2: What Data Apps Collect).
/// All user-facing strings come from this object for localization.
@immutable
class DataCollectionDiagramLabels {
  const DataCollectionDiagramLabels({
    required this.youTypeTitle,
    required this.youTypeItems,
    required this.runsQuietlyTitle,
    required this.runsQuietlyItems,
    required this.semanticDescription,
  });

  final String youTypeTitle;
  final List<String> youTypeItems;
  final String runsQuietlyTitle;
  final List<String> runsQuietlyItems;
  final String semanticDescription;
}

/// A diagram showing the two categories of data collection:
/// 1. What you actively type or give (name, email, photos, voice, homework)
/// 2. What runs quietly in the background (IP address, device ID, ad ID, crash logs, usage timing)
///
/// Uses a split-card "iceberg" layout with clear visual separation.
/// 'Quiet does not mean bad' tone - neutral styling for both groups.
class DataCollectionDiagram extends StatelessWidget {
  const DataCollectionDiagram({super.key, required this.labels});

  final DataCollectionDiagramLabels labels;

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

          return _DataCollectionContent(
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

class _DataCollectionContent extends StatelessWidget {
  const _DataCollectionContent({
    required this.labels,
    required this.isRtl,
    required this.useVerticalLayout,
    required this.reduceMotion,
    required this.maxWidth,
  });

  final DataCollectionDiagramLabels labels;
  final bool isRtl;
  final bool useVerticalLayout;
  final bool reduceMotion;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;

    // Colors from evidence categories
    final youTypeColor = categoryColors.dataCollection.color;
    final runsQuietlyColor = categoryColors.tracking.color;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final clampedTextScale = textScale.clamp(1.0, 1.5);
        final chipHeight = 40.0 * clampedTextScale;
        final cardPadding = 16.0 * clampedTextScale;
        final spacing = 16.0 * clampedTextScale;
        final titleSize = 16 * clampedTextScale;
        final chipFontSize = 13 * clampedTextScale;
        final deniSize = 56 * clampedTextScale;

        // Calculate card dimensions
        final cardWidth = useVerticalLayout
            ? width - 32
            : (width - 40) / 2; // 16 left + 16 right + 8 gap

        // Calculate content height
        final youTypeCardHeight =
            56 + (labels.youTypeItems.length * (chipHeight + 8)).toDouble();
        final runsQuietlyCardHeight =
            56 + (labels.runsQuietlyItems.length * (chipHeight + 8)).toDouble();

        double contentHeight;
        if (useVerticalLayout) {
          contentHeight =
              youTypeCardHeight + runsQuietlyCardHeight + spacing * 3 + deniSize + 32;
        } else {
          contentHeight =
              math.max(youTypeCardHeight, runsQuietlyCardHeight) +
              spacing * 2 +
              deniSize +
              32;
        }

        return SizedBox(
          width: width,
          height: contentHeight,
          child: Stack(
            children: [
              // You Type card (top in vertical, left in horizontal)
              if (useVerticalLayout)
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  child: _DataCategoryCard(
                    title: labels.youTypeTitle,
                    icon: LucideIcons.userPen,
                    items: labels.youTypeItems,
                    accentColor: youTypeColor,
                    backgroundColor: scheme.surfaceContainerLow,
                    borderColor: youTypeColor,
                    chipHeight: chipHeight,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    chipFontSize: chipFontSize,
                    clampedTextScale: clampedTextScale,
                  ),
                )
              else
                Positioned(
                  top: 0,
                  left: isRtl ? width / 2 + 4 : 16,
                  width: cardWidth,
                  bottom: spacing + deniSize + 16,
                  child: _DataCategoryCard(
                    title: labels.youTypeTitle,
                    icon: LucideIcons.userPen,
                    items: labels.youTypeItems,
                    accentColor: youTypeColor,
                    backgroundColor: scheme.surfaceContainerLow,
                    borderColor: youTypeColor,
                    chipHeight: chipHeight,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    chipFontSize: chipFontSize,
                    clampedTextScale: clampedTextScale,
                  ),
                ),

              // Runs Quietly card (bottom in vertical, right in horizontal)
              if (useVerticalLayout)
                Positioned(
                  top: youTypeCardHeight + spacing,
                  left: 16,
                  right: 16,
                  child: _DataCategoryCard(
                    title: labels.runsQuietlyTitle,
                    icon: LucideIcons.cpu,
                    items: labels.runsQuietlyItems,
                    accentColor: runsQuietlyColor,
                    backgroundColor: scheme.surfaceContainer,
                    borderColor: runsQuietlyColor,
                    chipHeight: chipHeight,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    chipFontSize: chipFontSize,
                    clampedTextScale: clampedTextScale,
                    isQuietNote: true,
                  ),
                )
              else
                Positioned(
                  top: 0,
                  left: isRtl ? 16 : width / 2 + 4,
                  width: cardWidth,
                  bottom: spacing + deniSize + 16,
                  child: _DataCategoryCard(
                    title: labels.runsQuietlyTitle,
                    icon: LucideIcons.cpu,
                    items: labels.runsQuietlyItems,
                    accentColor: runsQuietlyColor,
                    backgroundColor: scheme.surfaceContainer,
                    borderColor: runsQuietlyColor,
                    chipHeight: chipHeight,
                    cardPadding: cardPadding,
                    titleSize: titleSize,
                    chipFontSize: chipFontSize,
                    clampedTextScale: clampedTextScale,
                    isQuietNote: true,
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
                    pose: DeniPose.thinking,
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

class _DataCategoryCard extends StatelessWidget {
  const _DataCategoryCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.chipHeight,
    required this.cardPadding,
    required this.titleSize,
    required this.chipFontSize,
    required this.clampedTextScale,
    this.isQuietNote = false,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final double chipHeight;
  final double cardPadding;
  final double titleSize;
  final double chipFontSize;
  final double clampedTextScale;
  final bool isQuietNote;

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
            // Title with icon
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
            // Item chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Container(
                  height: chipHeight,
                  padding: EdgeInsets.symmetric(horizontal: 12 * clampedTextScale),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(EnpriveRadii.chip),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: chipFontSize,
                        fontWeight: FontWeight.w500,
                        color: accentColor,
                        height: 1.2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (isQuietNote) ...[
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12 * clampedTextScale),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(EnpriveRadii.md),
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 16 * clampedTextScale,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Quiet does not mean bad — these signals help apps run smoothly.',
                        style: TextStyle(
                          fontSize: 12 * clampedTextScale,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}