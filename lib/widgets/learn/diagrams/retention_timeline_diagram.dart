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

/// A clean vertical timeline diagram showing the data retention lifecycle:
/// 1. Data collected during app use
/// 2. Stored on company servers
/// 3. Uninstalling removes phone files while server copies may remain
/// 4. Requesting account deletion
/// 5. Dashed 'unknown retention' step for vague "as long as needed" policies
///
/// Built with a start-aligned vertical rail of five circular icon nodes paired
/// with full-wrapping step cards beside them (mirroring cleanly in RTL), and
/// Deni in a reserved bottom row so labels and mascot never overlap at any
/// width or text scale.
class RetentionTimelineDiagram extends StatelessWidget {
  const RetentionTimelineDiagram({super.key, required this.labels});

  static const Key mascotKey = Key('retention_timeline_diagram_mascot');

  static Key stepNodeKey(int index) =>
      Key('retention_timeline_step_node_$index');

  static Key stepBadgeKey(int index) =>
      Key('retention_timeline_step_badge_$index');

  static Key stepLabelKey(int index) =>
      Key('retention_timeline_step_label_$index');

  final RetentionTimelineDiagramLabels labels;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;

    final steps = <_TimelineStepData>[
      _TimelineStepData(
        index: 0,
        label: labels.collected,
        icon: LucideIcons.database,
        accentColor: categoryColors.dataCollection.color,
        containerColor: categoryColors.dataCollection.container,
        onContainerColor: categoryColors.dataCollection.onContainer,
        isUnknown: false,
      ),
      _TimelineStepData(
        index: 1,
        label: labels.stored,
        icon: LucideIcons.server,
        accentColor: categoryColors.retention.color,
        containerColor: categoryColors.retention.container,
        onContainerColor: categoryColors.retention.onContainer,
        isUnknown: false,
      ),
      _TimelineStepData(
        index: 2,
        label: labels.uninstall,
        icon: LucideIcons.smartphone,
        accentColor: categoryColors.tracking.color,
        containerColor: categoryColors.tracking.container,
        onContainerColor: categoryColors.tracking.onContainer,
        isUnknown: false,
      ),
      _TimelineStepData(
        index: 3,
        label: labels.deleteRequest,
        icon: LucideIcons.trash2,
        accentColor: categoryColors.parentalConsent.color,
        containerColor: categoryColors.parentalConsent.container,
        onContainerColor: categoryColors.parentalConsent.onContainer,
        isUnknown: false,
      ),
      _TimelineStepData(
        index: 4,
        label: labels.unknownTail,
        icon: LucideIcons.helpCircle,
        accentColor: scheme.outline,
        containerColor: scheme.surfaceContainerHighest,
        onContainerColor: scheme.onSurfaceVariant,
        isUnknown: true,
      ),
    ];

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: labels.semanticDescription,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                  for (var i = 0; i < steps.length; i++)
                    _TimelineStepRow(
                      step: steps[i],
                      isLast: i == steps.length - 1,
                      connectorIsDashed: i == steps.length - 2,
                      connectorColor: i == steps.length - 2
                          ? scheme.outline
                          : steps[i].accentColor,
                    ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(EnpriveRadii.md),
                    ),
                    child: const Center(
                      child: DeniAnimatedMascot(
                        key: mascotKey,
                        size: 48,
                        pose: DeniPose.carryReceipt,
                        holdStill: true,
                        showAmbientGlow: false,
                      ),
                    ),
                  ),
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

class _TimelineStepData {
  const _TimelineStepData({
    required this.index,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.containerColor,
    required this.onContainerColor,
    required this.isUnknown,
  });

  final int index;
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color containerColor;
  final Color onContainerColor;
  final bool isUnknown;
}

class _TimelineStepRow extends StatelessWidget {
  const _TimelineStepRow({
    required this.step,
    required this.isLast,
    required this.connectorIsDashed,
    required this.connectorColor,
  });

  final _TimelineStepData step;
  final bool isLast;
  final bool connectorIsDashed;
  final Color connectorColor;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    final nodeCircle = Container(
      key: RetentionTimelineDiagram.stepNodeKey(step.index),
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: step.containerColor,
        shape: BoxShape.circle,
        border: step.isUnknown
            ? null
            : Border.all(color: step.accentColor, width: 2),
      ),
      child: Icon(step.icon, size: 20, color: step.onContainerColor),
    );

    final railNode = step.isUnknown
        ? CustomPaint(
            foregroundPainter: _DashedCirclePainter(color: step.accentColor),
            child: nodeCircle,
          )
        : nodeCircle;

    final cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: step.isUnknown
            ? scheme.surfaceContainerHighest
            : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: step.isUnknown ? scheme.surface : step.containerColor,
              borderRadius: BorderRadius.circular(EnpriveRadii.pill),
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                '${step.index + 1}',
                key: RetentionTimelineDiagram.stepBadgeKey(step.index),
                style: m3e.typography.emphasized.labelSmall.copyWith(
                  color: step.onContainerColor,
                  height: 1.15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                step.label,
                key: RetentionTimelineDiagram.stepLabelKey(step.index),
                style: m3e.typeScale.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: step.isUnknown
                      ? scheme.onSurfaceVariant
                      : scheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final stepCard = step.isUnknown
        ? CustomPaint(
            foregroundPainter: _DashedRRectPainter(
              color: scheme.outline,
              radius: EnpriveRadii.md,
            ),
            child: cardContent,
          )
        : cardContent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                railNode,
                if (!isLast)
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 18),
                      child: SizedBox(
                        width: 44,
                        child: CustomPaint(
                          painter: _VerticalRailConnectorPainter(
                            color: connectorColor,
                            isDashed: connectorIsDashed,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: stepCard,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalRailConnectorPainter extends CustomPainter {
  const _VerticalRailConnectorPainter({
    required this.color,
    required this.isDashed,
  });

  final Color color;
  final bool isDashed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 4) return;

    final centerX = size.width / 2;
    const topGap = 3.0;
    const bottomGap = 3.0;
    const arrowHeight = 6.0;
    const arrowHalfWidth = 4.0;

    final startY = topGap;
    final tipY = math.max(startY + 4.0, size.height - bottomGap);
    final lineEndY = math.max(startY, tipY - arrowHeight);

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.78)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (lineEndY > startY) {
      final path = Path()
        ..moveTo(centerX, startY)
        ..lineTo(centerX, lineEndY);

      if (isDashed) {
        final dashPath = Path();
        for (final metric in path.computeMetrics()) {
          double distance = 0;
          while (distance < metric.length) {
            final next = math.min(distance + 4.5, metric.length);
            dashPath.addPath(metric.extractPath(distance, next), Offset.zero);
            distance = next + 3.5;
          }
        }
        canvas.drawPath(dashPath, strokePaint);
      } else {
        canvas.drawPath(path, strokePaint);
      }
    }

    final arrowPath = Path()
      ..moveTo(centerX, tipY)
      ..lineTo(centerX - arrowHalfWidth, tipY - arrowHeight)
      ..lineTo(centerX + arrowHalfWidth, tipY - arrowHeight)
      ..close();
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = color.withValues(alpha: 0.78)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _VerticalRailConnectorPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isDashed != isDashed;
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.0);
    final path = Path()..addOval(rect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + 5.0, metric.length);
        dashPath.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + 4.0;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
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
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
