import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Labels for the evidence layers diagram.
/// All user-facing strings come from this object for localization.
@immutable
class EvidenceLayersDiagramLabels {
  const EvidenceLayersDiagramLabels({
    required this.policySays,
    required this.phoneShows,
    required this.deniExplains,
    required this.notFound,
    required this.semanticDescription,
    this.policySaysDetail = 'Exact quote from the privacy policy',
    this.phoneShowsDetail = 'Android permissions on this device',
    this.deniExplainsDetail = 'Plain-language interpretation by Deni',
    this.notFoundDetail = 'Silence in a policy is not a promise',
  });

  final String policySays;
  final String phoneShows;
  final String deniExplains;
  final String notFound;
  final String semanticDescription;
  final String policySaysDetail;
  final String phoneShowsDetail;
  final String deniExplainsDetail;
  final String notFoundDetail;
}

/// A diagram showing Enprive's four evidence layers:
/// 1. What the policy says (exact quote)
/// 2. What your phone shows (permissions)
/// 3. Deni's explanation
/// 4. Not found / not sure (silence is not a promise)
///
/// Uses the same icons and hues as the Review screen's evidence categories.
class EvidenceLayersDiagram extends StatelessWidget {
  const EvidenceLayersDiagram({super.key, required this.labels});

  final EvidenceLayersDiagramLabels labels;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: labels.semanticDescription,
      child: _EvidenceLayersContent(
        labels: labels,
        isRtl: isRtl,
        reduceMotion: reduceMotion,
      ),
    );
  }
}

/// Painter for the connector lines between layers.
class _EvidenceLayersPainter extends CustomPainter {
  const _EvidenceLayersPainter({
    required this.isRtl,
    required this.useVerticalLayout,
    required this.reduceMotion,
    required this.layerCenters,
    required this.connectorColor,
    required this.dashedConnectorColor,
    this.isDashedOverride,
  });

  final bool isRtl;
  final bool useVerticalLayout;
  final bool reduceMotion;
  final List<Offset> layerCenters;
  final Color connectorColor;
  final Color dashedConnectorColor;
  final bool? isDashedOverride;

  @override
  void paint(Canvas canvas, Size size) {
    if (layerCenters.length < 2) return;

    final strokeWidth = 2.0;
    final dashWidth = 5.0;
    final dashSpace = 4.0;

    // Draw connectors between consecutive layers
    for (int i = 0; i < layerCenters.length - 1; i++) {
      final from = layerCenters[i];
      final to = layerCenters[i + 1];
      final segmentLen = (to - from).distance;
      final inset = segmentLen > 56 ? 24.0 : 2.0;
      final direction = (to - from).normalize();
      final start = from + direction * inset;
      final end = to - direction * inset;

      final isDashed = isDashedOverride ?? (i == layerCenters.length - 2);

      final paint = Paint()
        ..color = isDashed ? dashedConnectorColor : connectorColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);

      if (isDashed) {
        // Dashed line for "not found" boundary
        final metric = path.computeMetrics().first;
        double distance = 0;
        final dashPath = Path();
        while (distance < metric.length) {
          final nextDistance = math.min(distance + dashWidth, metric.length);
          final segment = metric.extractPath(distance, nextDistance);
          dashPath.addPath(segment, Offset.zero);
          distance = nextDistance + dashSpace;
        }
        canvas.drawPath(dashPath, paint);
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EvidenceLayersPainter oldDelegate) =>
      oldDelegate.isRtl != isRtl ||
      oldDelegate.useVerticalLayout != useVerticalLayout ||
      oldDelegate.reduceMotion != reduceMotion ||
      oldDelegate.layerCenters != layerCenters ||
      oldDelegate.connectorColor != connectorColor ||
      oldDelegate.dashedConnectorColor != dashedConnectorColor ||
      oldDelegate.isDashedOverride != isDashedOverride;
}

class _EvidenceLayersContent extends StatelessWidget {
  const _EvidenceLayersContent({
    required this.labels,
    required this.isRtl,
    required this.reduceMotion,
  });

  final EvidenceLayersDiagramLabels labels;
  final bool isRtl;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;

    // Colors from evidence categories
    final dataCollectionColor = categoryColors.dataCollection.color;
    final trackingColor = categoryColors.tracking.color;
    final parentalConsentColor = categoryColors.parentalConsent.color;

    // Layer definitions with their colors and icons
    final layers = [
      _EvidenceLayer(
        title: labels.policySays,
        icon: LucideIcons.fileText,
        color: dataCollectionColor,
        iconBackground: dataCollectionColor.withValues(alpha: 0.12),
        description: labels.policySaysDetail,
      ),
      _EvidenceLayer(
        title: labels.phoneShows,
        icon: LucideIcons.smartphone,
        color: trackingColor,
        iconBackground: trackingColor.withValues(alpha: 0.12),
        description: labels.phoneShowsDetail,
      ),
      _EvidenceLayer(
        title: labels.deniExplains,
        icon: LucideIcons.messageSquare,
        color: parentalConsentColor,
        iconBackground: parentalConsentColor.withValues(alpha: 0.12),
        description: labels.deniExplainsDetail,
      ),
      _EvidenceLayer(
        title: labels.notFound,
        icon: LucideIcons.helpCircle,
        color: scheme.outline,
        iconBackground: scheme.surfaceContainerHighest,
        description: labels.notFoundDetail,
        isUnknown: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final clampedTextScale = textScale.clamp(1.0, 1.35);
        final useVerticalLayout =
            constraints.maxWidth < 360 || textScale > 1.35;
        final nodeSize = 42.0 * clampedTextScale;
        final cardWidth = useVerticalLayout
            ? width
            : (width - 12) / 2;
        final deniSize = 56.0;

        Widget buildConnector({required bool isDashed}) {
          return SizedBox(
            height: 18,
            width: double.infinity,
            child: CustomPaint(
              painter: _EvidenceLayersPainter(
                isRtl: isRtl,
                useVerticalLayout: true,
                reduceMotion: reduceMotion,
                layerCenters: [
                  Offset(isRtl ? width - 56 : 28, 0),
                  Offset(isRtl ? width - 56 : 28, 18),
                ],
                connectorColor: scheme.onSurfaceVariant.withValues(alpha: 0.45),
                dashedConnectorColor: scheme.outline.withValues(alpha: 0.7),
                isDashedOverride: isDashed,
              ),
            ),
          );
        }

        final diagramBody = Container(
          width: width,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(EnpriveRadii.card),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (useVerticalLayout)
                for (var i = 0; i < layers.length; i++) ...[
                  if (i > 0) buildConnector(isDashed: i == layers.length - 1),
                  _EvidenceLayerCard(
                    layer: layers[i],
                    index: i + 1,
                    total: layers.length,
                    width: cardWidth,
                    nodeSize: nodeSize,
                    textScale: clampedTextScale,
                    center: Offset.zero,
                  ),
                ]
              else ...[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _EvidenceLayerCard(
                          layer: layers[0],
                          index: 1,
                          total: layers.length,
                          width: cardWidth,
                          nodeSize: nodeSize,
                          textScale: clampedTextScale,
                          center: Offset.zero,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _EvidenceLayerCard(
                          layer: layers[1],
                          index: 2,
                          total: layers.length,
                          width: cardWidth,
                          nodeSize: nodeSize,
                          textScale: clampedTextScale,
                          center: Offset.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _EvidenceLayerCard(
                          layer: layers[2],
                          index: 3,
                          total: layers.length,
                          width: cardWidth,
                          nodeSize: nodeSize,
                          textScale: clampedTextScale,
                          center: Offset.zero,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _EvidenceLayerCard(
                          layer: layers[3],
                          index: 4,
                          total: layers.length,
                          width: cardWidth,
                          nodeSize: nodeSize,
                          textScale: clampedTextScale,
                          center: Offset.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(EnpriveRadii.md),
                ),
                child: Row(
                  children: [
                    DeniAnimatedMascot(
                      size: deniSize,
                      pose: DeniPose.explaining,
                      holdStill: true,
                      showAmbientGlow: false,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              LucideIcons.info,
                              size: 15,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              layers.last.description,
                              style: m3e.typeScale.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return ExcludeSemantics(
          child: constraints.maxHeight.isFinite
              ? SingleChildScrollView(primary: false, child: diagramBody)
              : diagramBody,
        );
      },
    );
  }
}

class _EvidenceLayer {
  const _EvidenceLayer({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconBackground,
    required this.description,
    this.isUnknown = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Color iconBackground;
  final String description;
  final bool isUnknown;
}

class _EvidenceLayerCard extends StatelessWidget {
  const _EvidenceLayerCard({
    required this.layer,
    required this.index,
    required this.total,
    required this.width,
    required this.nodeSize,
    required this.textScale,
    required this.center,
  });

  final _EvidenceLayer layer;
  final int index;
  final int total;
  final double width;
  final double nodeSize;
  final double textScale;
  final Offset center;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surfaces = context.enpriveSurfaces;

    final card = Container(
      width: width,
      decoration: BoxDecoration(
        color: surfaces.card,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact badge row: step number + category icon
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: layer.isUnknown
                        ? scheme.surfaceContainerHighest
                        : layer.color,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: layer.isUnknown
                          ? scheme.onSurfaceVariant
                          : scheme.surface,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: layer.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    layer.icon,
                    size: 15,
                    color: layer.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Full-width title so words never break awkwardly mid-word
            Text(
              layer.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              layer.description,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: scheme.onSurfaceVariant,
                height: 1.38,
              ),
            ),
          ],
        ),
      ),
    );

    return ExcludeSemantics(
      child: layer.isUnknown
          ? CustomPaint(
              foregroundPainter: _DashedCardBorderPainter(
                color: scheme.outline.withValues(alpha: 0.75),
                radius: EnpriveRadii.md,
              ),
              child: card,
            )
          : card,
    );
  }
}

class _DashedCardBorderPainter extends CustomPainter {
  const _DashedCardBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.8),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
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
  bool shouldRepaint(covariant _DashedCardBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

extension _OffsetNormalize on Offset {
  Offset normalize() {
    final len = distance;
    if (len == 0) return Offset.zero;
    return this / len;
  }
}