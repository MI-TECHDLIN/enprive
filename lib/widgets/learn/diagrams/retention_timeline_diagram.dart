import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Labels for the retention timeline diagram (Topic 5: Retention and Deletion).
/// All user-facing strings come from this object for localization.
@immutable
class RetentionTimelineDiagramLabels {
  const RetentionTimelineDiagramLabels({
    required this.collected,
    required this.stored,
    required this.uninstall,
    required this.deleteRequest,
    required this.unknownTail,
    required this.semanticDescription,
  });

  final String collected;
  final String stored;
  final String uninstall;
  final String deleteRequest;
  final String unknownTail;
  final String semanticDescription;
}

/// A diagram showing the data lifecycle and retention timeline:
/// 1. Data collected during app use
/// 2. Stored on company servers
/// 3. You uninstall the app: phone files go but uploaded data stays
/// 4. A deletion request
/// 5. Dashed 'unknown retention' tail for policies that say 'as long as needed'
///
/// Uses a 4-node timeline with distinct node shapes and a dashed unknown tail.
class RetentionTimelineDiagram extends StatelessWidget {
  const RetentionTimelineDiagram({super.key, required this.labels});

  final RetentionTimelineDiagramLabels labels;

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

          return _RetentionTimelineContent(
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

class _RetentionTimelineContent extends StatelessWidget {
  const _RetentionTimelineContent({
    required this.labels,
    required this.isRtl,
    required this.useVerticalLayout,
    required this.reduceMotion,
    required this.maxWidth,
  });

  final RetentionTimelineDiagramLabels labels;
  final bool isRtl;
  final bool useVerticalLayout;
  final bool reduceMotion;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;

    // Colors from evidence categories - compute once in build
    final nodeColors = <Color>[
      categoryColors.dataCollection.color,   // 0: collected
      categoryColors.retention.color,        // 1: stored
      categoryColors.tracking.color,         // 2: uninstall
      categoryColors.parentalConsent.color,  // 3: deleteRequest
      scheme.outline,                        // 4: unknownTail
    ];
    final segmentColors = <Color>[
      categoryColors.dataCollection.color,   // 0 -> 1
      categoryColors.retention.color,        // 1 -> 2
      categoryColors.tracking.color,         // 2 -> 3
      scheme.outline,                        // 3 -> 4 (dashed)
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final clampedTextScale = textScale.clamp(1.0, 1.5);
        final nodeSize = 56.0 * clampedTextScale;
        final spacing = 24.0 * clampedTextScale;
        final deniSize = 56 * clampedTextScale;
        final labelMaxWidth = useVerticalLayout
            ? width - 32
            : (width - spacing * 3) / 4;

        // Calculate positions
        late List<Offset> nodeCenters;
        late double contentWidth;
        late double contentHeight;

        if (useVerticalLayout) {
          // Vertical layout: nodes stacked top to bottom
          final centerX = width / 2;
          final startY = nodeSize / 2 + 16;
          final verticalSpacing = nodeSize + spacing;

          nodeCenters = List.generate(5, (i) {
            return Offset(centerX, startY + i * verticalSpacing);
          });

          contentWidth = width;
          contentHeight = nodeCenters.last.dy + nodeSize / 2 + 16 + deniSize + 16;
        } else {
          // Horizontal layout: nodes left to right (mirrored in RTL)
          final centerY = 180 * clampedTextScale;
          final availableWidth = width - 32;
          final horizontalSpacing = (availableWidth - nodeSize * 4) / 3;
          final startX = isRtl ? width - 16 - nodeSize / 2 : 16 + nodeSize / 2;

          nodeCenters = List.generate(5, (i) {
            final x = isRtl
                ? startX - i * (nodeSize + horizontalSpacing)
                : startX + i * (nodeSize + horizontalSpacing);
            return Offset(x, centerY);
          });

          contentWidth = width;
          contentHeight =
              centerY + nodeSize / 2 + 16 + deniSize + 16 + 60; // Extra for labels
        }

        final painter = _TimelinePainter(
          isRtl: isRtl,
          useVerticalLayout: useVerticalLayout,
          reduceMotion: reduceMotion,
          nodeCenters: nodeCenters,
          nodeSize: nodeSize,
          segmentColors: segmentColors,
          surfaceColor: scheme.surface,
          onSurfaceColor: scheme.onSurface,
        );

        return SizedBox(
          width: contentWidth,
          height: contentHeight,
          child: CustomPaint(
            painter: painter,
            child: Stack(
              children: [
                // Nodes and labels
                for (int i = 0; i < 5; i++)
                  Positioned(
                    left: nodeCenters[i].dx - nodeSize / 2,
                    top: nodeCenters[i].dy - nodeSize / 2,
                    child: _TimelineNode(
                      index: i,
                      label: _nodeLabel(i),
                      icon: _nodeIcon(i),
                      nodeSize: nodeSize,
                      textScale: clampedTextScale,
                      labelMaxWidth: labelMaxWidth,
                      isUnknown: i == 4,
                      accentColor: nodeColors[i],
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
                      pose: DeniPose.carryReceipt,
                      holdStill: true,
                      showAmbientGlow: false,
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

  String _nodeLabel(int index) {
    switch (index) {
      case 0:
        return labels.collected;
      case 1:
        return labels.stored;
      case 2:
        return labels.uninstall;
      case 3:
        return labels.deleteRequest;
      case 4:
        return labels.unknownTail;
      default:
        return '';
    }
  }

  IconData _nodeIcon(int index) {
    switch (index) {
      case 0:
        return LucideIcons.database;
      case 1:
        return LucideIcons.server;
      case 2:
        return LucideIcons.smartphone;
      case 3:
        return LucideIcons.trash2;
      case 4:
        return LucideIcons.helpCircle;
      default:
        return LucideIcons.circle;
    }
  }
}

class _TimelinePainter extends CustomPainter {
  const _TimelinePainter({
    required this.isRtl,
    required this.useVerticalLayout,
    required this.reduceMotion,
    required this.nodeCenters,
    required this.nodeSize,
    required this.segmentColors,
    required this.surfaceColor,
    required this.onSurfaceColor,
  });

  final bool isRtl;
  final bool useVerticalLayout;
  final bool reduceMotion;
  final List<Offset> nodeCenters;
  final double nodeSize;
  final List<Color> segmentColors;
  final Color surfaceColor;
  final Color onSurfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCenters.length < 2) return;

    final strokeWidth = 3.0;
    final dashWidth = 8.0;
    final dashSpace = 6.0;
    final nodeRadius = nodeSize / 2;

    for (int i = 0; i < nodeCenters.length - 1; i++) {
      final from = nodeCenters[i];
      final to = nodeCenters[i + 1];
      final direction = (to - from).normalize();
      final start = from + direction * nodeRadius;
      final end = to - direction * nodeRadius;

      final isLastSegment = i == nodeCenters.length - 2;
      final color = segmentColors[i];

      final paint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);

      if (isLastSegment) {
        // Dashed line for unknown retention tail
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

      // Draw arrowhead
      final arrowPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      final arrowHeadLength = 12.0;
      final arrowHeadAngle = math.pi / 6;
      final perpendicular = Offset(-direction.dy, direction.dx);
      final arrowBase = end - direction * arrowHeadLength;
      final left = arrowBase + perpendicular * arrowHeadLength * math.sin(arrowHeadAngle);
      final right = arrowBase - perpendicular * arrowHeadLength * math.sin(arrowHeadAngle);

      final arrowPath = Path();
      arrowPath.moveTo(end.dx, end.dy);
      arrowPath.lineTo(left.dx, left.dy);
      arrowPath.lineTo(right.dx, right.dy);
      arrowPath.close();
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) =>
      oldDelegate.isRtl != isRtl ||
      oldDelegate.useVerticalLayout != useVerticalLayout ||
      oldDelegate.reduceMotion != reduceMotion ||
      oldDelegate.nodeCenters != nodeCenters ||
      oldDelegate.nodeSize != nodeSize ||
      oldDelegate.segmentColors != segmentColors ||
      oldDelegate.surfaceColor != surfaceColor ||
      oldDelegate.onSurfaceColor != onSurfaceColor;
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.index,
    required this.label,
    required this.icon,
    required this.nodeSize,
    required this.textScale,
    required this.labelMaxWidth,
    required this.isUnknown,
    required this.accentColor,
  });

  final int index;
  final String label;
  final IconData icon;
  final double nodeSize;
  final double textScale;
  final double labelMaxWidth;
  final bool isUnknown;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Node circle
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              color: isUnknown
                  ? scheme.surfaceContainerHighest
                  : accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnknown
                    ? scheme.outlineVariant
                    : accentColor,
                width: isUnknown ? 2 : 2.5,
                style: isUnknown ? BorderStyle.solid : BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: nodeSize * 0.45,
              color: isUnknown ? scheme.onSurfaceVariant : accentColor,
            ),
          ),
          const SizedBox(height: 8),
          // Step number badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isUnknown
                  ? scheme.surfaceContainerHighest
                  : accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isUnknown
                    ? scheme.outlineVariant
                    : accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Step ${index + 1}',
              style: TextStyle(
                fontSize: 10 * textScale,
                fontWeight: FontWeight.w700,
                color: isUnknown ? scheme.onSurfaceVariant : accentColor,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Label
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: labelMaxWidth),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12 * textScale,
                fontWeight: FontWeight.w600,
                color: isUnknown ? scheme.onSurfaceVariant : scheme.onSurface,
                height: 1.25,
              ),
            ),
          ),
        ],
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