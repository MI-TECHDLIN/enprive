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
  });

  final String policySays;
  final String phoneShows;
  final String deniExplains;
  final String notFound;
  final String semanticDescription;
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
  });

  final bool isRtl;
  final bool useVerticalLayout;
  final bool reduceMotion;
  final List<Offset> layerCenters;
  final Color connectorColor;
  final Color dashedConnectorColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (layerCenters.length < 2) return;

    final strokeWidth = 2.0;
    final dashWidth = 8.0;
    final dashSpace = 6.0;
    final nodeRadius = 24.0;

    // Draw connectors between consecutive layers
    for (int i = 0; i < layerCenters.length - 1; i++) {
      final from = layerCenters[i];
      final to = layerCenters[i + 1];
      final direction = (to - from).normalize();
      final start = from + direction * nodeRadius;
      final end = to - direction * nodeRadius;

      final isLastLayer = i == layerCenters.length - 2;

      final paint = Paint()
        ..color = isLastLayer ? dashedConnectorColor : connectorColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);

      if (isLastLayer) {
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
      oldDelegate.dashedConnectorColor != dashedConnectorColor;
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
        description: 'Exact quote from the privacy policy',
      ),
      _EvidenceLayer(
        title: labels.phoneShows,
        icon: LucideIcons.smartphone,
        color: trackingColor,
        iconBackground: trackingColor.withValues(alpha: 0.12),
        description: 'Android permissions on this device',
      ),
      _EvidenceLayer(
        title: labels.deniExplains,
        icon: LucideIcons.messageSquare,
        color: parentalConsentColor,
        iconBackground: parentalConsentColor.withValues(alpha: 0.12),
        description: 'Plain-language interpretation by Deni',
      ),
      _EvidenceLayer(
        title: labels.notFound,
        icon: LucideIcons.helpCircle,
        color: scheme.outline,
        iconBackground: scheme.surfaceContainerHighest,
        description: 'Silence in a policy is not a promise',
        isUnknown: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final clampedTextScale = textScale.clamp(1.0, 1.4);
        final useVerticalLayout =
            constraints.maxWidth < 360 || textScale > 1.35;
        final nodeSize = 48.0 * clampedTextScale;
        final cardWidth = useVerticalLayout
            ? width - 32
            : (width - 48) / 2;
        final spacing = 16.0 * clampedTextScale;
        final deniSize = 56 * clampedTextScale;
        final cardHeight = 140.0 * clampedTextScale; // Increased from 120 to accommodate content

        // Calculate layer centers for the painter and total content height
        final layerCenters = <Offset>[];
        double contentHeight = 0;

        if (useVerticalLayout) {
          double y = nodeSize / 2 + 16;
          for (int i = 0; i < layers.length; i++) {
            layerCenters.add(Offset(width / 2, y));
            y += cardHeight;
            if (i < layers.length - 1) y += spacing;
          }
          // Add extra padding for Deni, note, and card content overflow
          contentHeight = y + 32 + deniSize + 32 + 80;
        } else {
          // 2x2 grid
          final colWidth = (width - 24) / 2;
          for (int i = 0; i < layers.length; i++) {
            final col = i % 2;
            final row = i ~/ 2;
            final x = col * (colWidth + 24) + colWidth / 2;
            final y = row * (cardHeight + spacing) + nodeSize / 2 + 16;
            layerCenters.add(Offset(x, y));
          }
          contentHeight = 2 * (cardHeight + spacing) + nodeSize + 32 + deniSize + 32 + 80;
        }

        return SizedBox(
          width: width,
          height: contentHeight,
          child: CustomPaint(
            painter: _EvidenceLayersPainter(
              isRtl: isRtl,
              useVerticalLayout: useVerticalLayout,
              reduceMotion: reduceMotion,
              layerCenters: layerCenters,
              connectorColor: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              dashedConnectorColor: scheme.outline.withValues(alpha: 0.5),
            ),
            child: Stack(
              children: [
                // Layer cards
                if (useVerticalLayout)
                  Positioned(
                    top: 0,
                    left: 16,
                    right: 16,
                    bottom: 16 + deniSize + 24 + 60,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: layers.asMap().entries.map((entry) {
                          final i = entry.key;
                          final layer = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              top: i == 0 ? 0 : spacing,
                            ),
                            child: _EvidenceLayerCard(
                              layer: layer,
                              index: i + 1,
                              total: layers.length,
                              width: cardWidth,
                              nodeSize: nodeSize,
                              textScale: clampedTextScale,
                              center: layerCenters[i],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 16 + deniSize + 24 + 60,
                    child: Column(
                      children: [
                        // Row 0: layers 0 and 1
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _EvidenceLayerCard(
                                layer: layers[0],
                                index: 1,
                                total: layers.length,
                                width: cardWidth,
                                nodeSize: nodeSize,
                                textScale: clampedTextScale,
                                center: layerCenters[0],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _EvidenceLayerCard(
                                layer: layers[1],
                                index: 2,
                                total: layers.length,
                                width: cardWidth,
                                nodeSize: nodeSize,
                                textScale: clampedTextScale,
                                center: layerCenters[1],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing),
                        // Row 1: layers 2 and 3
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _EvidenceLayerCard(
                                layer: layers[2],
                                index: 3,
                                total: layers.length,
                                width: cardWidth,
                                nodeSize: nodeSize,
                                textScale: clampedTextScale,
                                center: layerCenters[2],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _EvidenceLayerCard(
                                layer: layers[3],
                                index: 4,
                                total: layers.length,
                                width: cardWidth,
                                nodeSize: nodeSize,
                                textScale: clampedTextScale,
                                center: layerCenters[3],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                // Deni mascot
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: DeniAnimatedMascot(
                      size: deniSize,
                      pose: DeniPose.explaining,
                      holdStill: true,
                      showAmbientGlow: false,
                    ),
                  ),
                ),
                // "Silence is not a promise" note at bottom
                Positioned(
                  bottom: 80 * clampedTextScale,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(
                          alpha: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: scheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.info,
                            size: 16 * clampedTextScale,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              layers.last.description,
                              textAlign: TextAlign.center,
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
                  ),
                ),
              ],
            ),
          ),
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

    return ExcludeSemantics(
      child: Container(
        width: width,
        constraints: BoxConstraints(
          minHeight: 140 * textScale,
        ),
        decoration: BoxDecoration(
          color: surfaces.card,
          borderRadius: BorderRadius.circular(EnpriveRadii.card),
          border: Border.all(
            color: layer.isUnknown
                ? scheme.outlineVariant.withValues(alpha: 0.5)
                : layer.color.withValues(alpha: 0.3),
            width: layer.isUnknown ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with number, icon, and title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number badge
                  Container(
                    width: nodeSize * 0.6,
                    height: nodeSize * 0.6,
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
                        fontSize: nodeSize * 0.28,
                        fontWeight: FontWeight.w800,
                        color: layer.isUnknown
                            ? scheme.onSurfaceVariant
                            : Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Icon
                  Container(
                    width: nodeSize * 0.7,
                    height: nodeSize * 0.7,
                    decoration: BoxDecoration(
                      color: layer.iconBackground,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      layer.icon,
                      size: nodeSize * 0.35,
                      color: layer.color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          layer.title,
                          style: TextStyle(
                            fontSize: 15 * textScale,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                            height: 1.25,
                          ),
                        ),
                        if (layer.isUnknown) ...[
                          const SizedBox(height: 2),
                          Text(
                            layer.description,
                            style: TextStyle(
                              fontSize: 11 * textScale,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurfaceVariant,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (!layer.isUnknown) ...[
                const SizedBox(height: 12),
                // Description
                Text(
                  layer.description,
                  style: TextStyle(
                    fontSize: 13 * textScale,
                    fontWeight: FontWeight.w400,
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension _OffsetNormalize on Offset {
  Offset normalize() {
    final len = distance;
    if (len == 0) return Offset.zero;
    return this / len;
  }
}