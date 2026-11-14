import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../enprive_provenance_chip.dart';

/// Asymmetric 2-column Material 3 Expressive Bento posture summary widget
/// inspired by the `_.jpeg` (Asymmetric Bento Metric) and `colo.jpeg` (Dark
/// Bento Grid) reference boards.
///
/// - **Left Tall Card (`28dp` radius)**: Provenance badge, oversized tabular
///   metric (`tabularMetricLarge`), calibrated summary copy, and
///   [M3EProgressIndicator.linearWavy] (respecting reduced motion).
/// - **Right Stacked Cards (`24dp` radius)**:
///   - Top card: Engine / readiness status with optional [M3ELoadingIndicator]
///     morphing polygon (`28dp`).
///   - Bottom card: Semantic flag/attention tile with AAA-contrasted
///     [SemanticColorPair] and optional tap handler.
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
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onTopTileTap;
  final VoidCallback? onBottomTileTap;

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
    this.onPrimaryTap,
    this.onTopTileTap,
    this.onBottomTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final typeExt = context.enpriveType;
    final reducedMotion = EnpriveMotionTokens.isReducedMotion(context);

    final provenancePair = switch (source) {
      InferenceSource.onDevice => semantics.onDevice,
      InferenceSource.inCloud => semantics.inCloud,
      InferenceSource.offlineDeterministic => semantics.offlineFallback,
      InferenceSource.unknown ||
      InferenceSource.locationUnavailable =>
        semantics.unknown,
    };

    final provenanceLabel = switch (source) {
      InferenceSource.onDevice => 'ON-DEVICE',
      InferenceSource.inCloud => 'IN THE CLOUD',
      InferenceSource.offlineDeterministic => 'OFFLINE SCAN',
      InferenceSource.unknown ||
      InferenceSource.locationUnavailable =>
        'SOURCE UNKNOWN',
    };

    final flagSemanticPair = flagCount == 0
        ? semantics.noConcern
        : (flagCount >= 3
              ? semantics.highConcern
              : semantics.reviewRecommended);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Tall Bento Card
          Expanded(
            flex: 11,
            child: M3ECard(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(28),
              padding: const EdgeInsets.all(18),
              onPressed: onPrimaryTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: provenancePair.background,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          provenanceLabel,
                          style: m3e.typography.emphasized.labelSmall.copyWith(
                            color: provenancePair.foreground,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      Icon(
                        source == InferenceSource.inCloud
                            ? LucideIcons.cloudCheck
                            : LucideIcons.shieldCheck,
                        size: 20,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    primaryMetricValue,
                    style: typeExt.tabularMetricLarge.copyWith(
                      fontSize: 42,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$primaryMetricTitle\n$primaryMetricSubtitle',
                    style: m3e.typeScale.labelMedium.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  M3EProgressIndicator.linearWavy(
                    value: progressValue.clamp(0.0, 1.0),
                    color: scheme.primary,
                    trackColor: scheme.surfaceContainerHighest,
                    waveSpeed: reducedMotion ? 0 : 28.0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right Stacked Semantic Tiles
          Expanded(
            flex: 10,
            child: Column(
              children: [
                Expanded(
                  child: M3ECard(
                    color: semantics.onDevice.background,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(14),
                    onPressed: onTopTileTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
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
                            if (isTopTileLoading && !reducedMotion)
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: M3ELoadingIndicator(
                                  size: 28,
                                  color: semantics.onDevice.foreground,
                                ),
                              )
                            else
                              Icon(
                                LucideIcons.sparkles,
                                size: 18,
                                color: semantics.onDevice.foreground,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          topTileSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: m3e.typeScale.labelSmall.copyWith(
                            color: semantics.onDevice.foreground,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: M3ECard(
                    color: flagSemanticPair.background,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(14),
                    onPressed: onBottomTileTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                bottomTileTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: m3e.typography.emphasized.titleMedium
                                    .copyWith(
                                      color: flagSemanticPair.foreground,
                                    ),
                              ),
                            ),
                            Icon(
                              LucideIcons.arrowUpRight,
                              size: 18,
                              color: flagSemanticPair.foreground,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bottomTileSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: m3e.typeScale.labelSmall.copyWith(
                            color: flagSemanticPair.foreground,
                            height: 1.3,
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
