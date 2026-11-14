import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../enprive_provenance_chip.dart';
import 'enprive_material_card_surface.dart';

/// Asymmetric 2-column Material 3 Expressive Bento posture summary widget
/// inspired by `_.jpeg`, `colo.jpeg`, and Enprive's tactile button language.
///
/// Pairs one dominant tabular-metric posture card with two stacked tonal tiles,
/// each framed inside [EnpriveMaterialCardSurface] (`1.5dp` border + `2.5dp`
/// physical bottom lip) with accessible semantic contrast across Light and Dark
/// themes.
class EnpriveBentoPostureCard extends StatelessWidget {
  final InferenceSource source;
  final String primaryMetricValue;
  final String primaryMetricTitle;
  final String primaryMetricSubtitle;
  final double progressValue;
  final String topTileTitle;
  final String topTileSubtitle;
  final bool isTopTileLoading;
  final String bottomTileTitle;
  final String bottomTileSubtitle;
  final int flagCount;
  final VoidCallback? onFlagsTap;

  const EnpriveBentoPostureCard({
    super.key,
    this.source = InferenceSource.onDevice,
    required this.primaryMetricValue,
    required this.primaryMetricTitle,
    required this.primaryMetricSubtitle,
    this.progressValue = 0.86,
    required this.topTileTitle,
    required this.topTileSubtitle,
    this.isTopTileLoading = false,
    required this.bottomTileTitle,
    required this.bottomTileSubtitle,
    this.flagCount = 0,
    this.onFlagsTap,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final typeExt = context.enpriveType;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;

    final SemanticColorPair bottomPair = flagCount > 0
        ? semantics.reviewRecommended
        : semantics.noConcern;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dominant asymmetric primary posture card
          Expanded(
            flex: 6,
            child: EnpriveMaterialCardSurface(
              variant: EnpriveCardVariant.elevated,
              backgroundColor: surfaces.card,
              borderRadius: BorderRadius.circular(28),
              lipHeight: 2.5,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  EnpriveProvenanceChip(source: source),
                  const SizedBox(height: 14),
                  Text(
                    primaryMetricValue,
                    style: typeExt.tabularMetricLarge.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    primaryMetricTitle,
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    primaryMetricSubtitle,
                    style: m3e.typeScale.bodySmall.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  M3EProgressIndicator.linearWavy(
                    value: progressValue.clamp(0.0, 1.0),
                    color: scheme.primary,
                    trackColor: scheme.surfaceContainerHighest,
                    semanticsLabel: primaryMetricTitle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Right column: two stacked tonal/semantic tactile tiles
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Expanded(
                  child: EnpriveMaterialCardSurface(
                    variant: EnpriveCardVariant.tonal,
                    backgroundColor: semantics.onDevice.background,
                    borderColor: semantics.onDevice.border,
                    accentColor: semantics.onDevice.foreground,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    lipHeight: 2.0,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                topTileTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: m3e.typography.emphasized.titleMedium
                                    .copyWith(
                                      color: semantics.onDevice.foreground,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isTopTileLoading)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: M3ELoadingIndicator(
                                  size: 24,
                                  color: semantics.onDevice.foreground,
                                ),
                              )
                            else
                              Icon(
                                LucideIcons.cpu,
                                size: 18,
                                color: semantics.onDevice.icon,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          topTileSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: m3e.typeScale.labelSmall.copyWith(
                            color: semantics.onDevice.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: EnpriveMaterialCardSurface(
                    variant: EnpriveCardVariant.tonal,
                    backgroundColor: bottomPair.background,
                    borderColor: bottomPair.border,
                    accentColor: bottomPair.foreground,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                    lipHeight: onFlagsTap != null ? 3.0 : 2.5,
                    padding: const EdgeInsets.all(14),
                    onPressed: onFlagsTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                bottomTileTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: m3e.typography.emphasized.titleMedium
                                    .copyWith(color: bottomPair.foreground),
                              ),
                            ),
                            Icon(
                              flagCount > 0
                                  ? LucideIcons.triangleAlert
                                  : LucideIcons.circleCheck,
                              size: 18,
                              color: bottomPair.icon,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bottomTileSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: m3e.typeScale.labelSmall.copyWith(
                            color: bottomPair.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
