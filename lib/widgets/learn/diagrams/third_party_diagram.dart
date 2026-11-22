import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Labels for the third-party data flow diagram.
/// All user-facing strings come from this object for localization.
@immutable
class ThirdPartyDiagramLabels {
  const ThirdPartyDiagramLabels({
    required this.app,
    required this.you,
    required this.hosting,
    required this.analytics,
    required this.ads,
    required this.firstParty,
    required this.thirdParty,
    required this.semanticDescription,
  });

  final String app;
  final String you;
  final String hosting;
  final String analytics;
  final String ads;
  final String firstParty;
  final String thirdParty;
  final String semanticDescription;
}

/// A diagram showing how data flows from a child's learning app to first-party
/// (the app maker) and third-party services (hosting/crash tools, analytics,
/// ad networks). Visual distinctions use shape, line style, and text labels,
/// never color alone.
class ThirdPartyDiagram extends StatelessWidget {
  const ThirdPartyDiagram({super.key, required this.labels});

  final ThirdPartyDiagramLabels labels;

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
              constraints.maxWidth < 360 || textScale > 1.35;

          return _ThirdPartyFlowContent(
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

class _ThirdPartyFlowContent extends StatelessWidget {
  const _ThirdPartyFlowContent({
    required this.labels,
    required this.isRtl,
    required this.useVerticalLayout,
    required this.reduceMotion,
    required this.maxWidth,
  });

  final ThirdPartyDiagramLabels labels;
  final bool isRtl;
  final bool useVerticalLayout;
  final bool reduceMotion;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;
    final categoryColors = context.categoryColors;

    // Colors for the diagram
    final firstPartyColor = categoryColors.dataCollection.color;
    final thirdPartyColor = categoryColors.sharing.color;
    final hostingColor = scheme.outline;
    final adsPathColor = semantics.reviewRecommended.icon;
    final analyticsPathColor = categoryColors.tracking.color;
    final appMakerPathColor = firstPartyColor;

    // Calculate layout positions and required size
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final clampedTextScale = textScale.clamp(1.0, 1.35);
        final nodeSize = 52.0;
        final nodeBoxWidth = math.min(width - 24, 118.0 * clampedTextScale);
        final deniSize = 52.0;

        // Calculate positions and total height/width
        late Offset youCenter;
        late Offset appCenter;
        late Offset hostingCenter;
        late Offset analyticsCenter;
        late Offset adsCenter;
        late double contentHeight;
        final double contentWidth = width;
        final double badgeTopOffset = 46.0;

        if (useVerticalLayout) {
          // Vertical stack: You -> App -> (Hosting, Analytics, Ads)
          final centerX = width / 2;
          final verticalStep = 108.0 + (textScale - 1.0).clamp(0.0, 1.0) * 58.0;
          final thirdPartyStep =
              124.0 + (textScale - 1.0).clamp(0.0, 1.0) * 68.0;

          youCenter = Offset(centerX, badgeTopOffset + nodeSize / 2 + 8);
          appCenter = Offset(centerX, youCenter.dy + verticalStep);

          final thirdPartyStartY = appCenter.dy + verticalStep + 20;
          hostingCenter = Offset(centerX, thirdPartyStartY);
          analyticsCenter = Offset(centerX, hostingCenter.dy + thirdPartyStep);
          adsCenter = Offset(centerX, analyticsCenter.dy + thirdPartyStep);

          contentHeight = adsCenter.dy + thirdPartyStep * 0.72 + deniSize + 24;
        } else {
          // Horizontal: You -> App -> three branches (mirrored in RTL)
          final leftX = math.max(nodeBoxWidth / 2 + 4, width * 0.16);
          final midX = width * 0.45;
          final rightX = math.min(width - nodeBoxWidth / 2 - 4, width * 0.80);

          final youX = isRtl ? rightX : leftX;
          final appX = isRtl ? width - midX : midX;
          final thirdPartyX = isRtl ? leftX : rightX;

          const branchStep = 108.0;
          final startY = badgeTopOffset + nodeSize / 2 + 12;
          hostingCenter = Offset(thirdPartyX, startY);
          analyticsCenter = Offset(thirdPartyX, startY + branchStep);
          adsCenter = Offset(thirdPartyX, startY + branchStep * 2);

          final centerY = analyticsCenter.dy;
          youCenter = Offset(youX, centerY);
          appCenter = Offset(appX, centerY);

          contentHeight = adsCenter.dy + 94 + deniSize * 0.4;
        }

        final painter = _FlowPainter(
          isRtl: isRtl,
          useVerticalLayout: useVerticalLayout,
          reduceMotion: reduceMotion,
          appCenter: appCenter,
          youCenter: youCenter,
          hostingCenter: hostingCenter,
          analyticsCenter: analyticsCenter,
          adsCenter: adsCenter,
          firstPartyColor: firstPartyColor,
          thirdPartyColor: thirdPartyColor,
          hostingColor: hostingColor,
          adsPathColor: adsPathColor,
          analyticsPathColor: analyticsPathColor,
          appMakerPathColor: appMakerPathColor,
          surfaceColor: scheme.surface,
          onSurfaceColor: scheme.onSurface,
        );

        final diagramBody = Container(
          width: contentWidth,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(EnpriveRadii.card),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: SizedBox(
            width: contentWidth - 12,
            height: contentHeight,
            child: CustomPaint(
              painter: painter,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Top legend badges: First party & Third parties (never overlapping)
                  Positioned(
                    top: 0,
                    left: 6,
                    right: 6,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _CategoryBadge(
                          label: labels.firstParty,
                          color: firstPartyColor,
                          textScale: 1.0,
                          maxWidth: width * 0.46,
                          isFirstParty: true,
                        ),
                        _CategoryBadge(
                          label: labels.thirdParty,
                          color: thirdPartyColor,
                          textScale: 1.0,
                          maxWidth: width * 0.46,
                          isFirstParty: false,
                        ),
                      ],
                    ),
                  ),
                  // You (Child) node
                  Positioned(
                    left: youCenter.dx - nodeBoxWidth / 2,
                    top: youCenter.dy - nodeSize / 2,
                    width: nodeBoxWidth,
                    child: _DiagramNode(
                      icon: LucideIcons.user,
                      label: labels.you,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      size: nodeSize,
                      textScale: 1.0,
                    ),
                  ),
                  // App node
                  Positioned(
                    left: appCenter.dx - nodeBoxWidth / 2,
                    top: appCenter.dy - nodeSize / 2,
                    width: nodeBoxWidth,
                    child: _DiagramNode(
                      icon: LucideIcons.smartphone,
                      label: labels.app,
                      backgroundColor: scheme.secondaryContainer,
                      foregroundColor: scheme.onSecondaryContainer,
                      size: nodeSize,
                      textScale: 1.0,
                      isPrimary: true,
                    ),
                  ),
                  // Hosting/Crash node
                  Positioned(
                    left: hostingCenter.dx - nodeBoxWidth / 2,
                    top: hostingCenter.dy - nodeSize / 2,
                    width: nodeBoxWidth,
                    child: _ThirdPartyNode(
                      icon: LucideIcons.server,
                      label: labels.hosting,
                      categoryLabel: labels.thirdParty,
                      pathColor: hostingColor,
                      backgroundColor: surfaces.card,
                      foregroundColor: scheme.onSurface,
                      size: nodeSize,
                      textScale: 1.0,
                      lineStyle: _LineStyle.dashed,
                    ),
                  ),
                  // Analytics node
                  Positioned(
                    left: analyticsCenter.dx - nodeBoxWidth / 2,
                    top: analyticsCenter.dy - nodeSize / 2,
                    width: nodeBoxWidth,
                    child: _ThirdPartyNode(
                      icon: LucideIcons.barChart2,
                      label: labels.analytics,
                      categoryLabel: labels.thirdParty,
                      pathColor: analyticsPathColor,
                      backgroundColor: surfaces.card,
                      foregroundColor: scheme.onSurface,
                      size: nodeSize,
                      textScale: 1.0,
                      lineStyle: _LineStyle.dashed,
                    ),
                  ),
                  // Ads node
                  Positioned(
                    left: adsCenter.dx - nodeBoxWidth / 2,
                    top: adsCenter.dy - nodeSize / 2,
                    width: nodeBoxWidth,
                    child: _ThirdPartyNode(
                      icon: LucideIcons.signal,
                      label: labels.ads,
                      categoryLabel: labels.thirdParty,
                      pathColor: adsPathColor,
                      backgroundColor: surfaces.card,
                      foregroundColor: scheme.onSurface,
                      size: nodeSize,
                      textScale: 1.0,
                      lineStyle: _LineStyle.dashed,
                      isWarning: true,
                    ),
                  ),
                  // Deni mascot
                  if (!useVerticalLayout)
                    PositionedDirectional(
                      bottom: 4,
                      start: 10,
                      child: DeniAnimatedMascot(
                        size: deniSize,
                        pose: DeniPose.explaining,
                        holdStill: true,
                        showAmbientGlow: false,
                      ),
                    )
                  else
                    Positioned(
                      bottom: 4,
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
                ],
              ),
            ),
          ),
        );

        return constraints.maxHeight.isFinite
            ? SingleChildScrollView(primary: false, child: diagramBody)
            : diagramBody;
      },
    );
  }
}

/// Painter for the flow arrows and connecting lines.
class _FlowPainter extends CustomPainter {
  const _FlowPainter({
    required this.isRtl,
    required this.useVerticalLayout,
    required this.reduceMotion,
    required this.appCenter,
    required this.youCenter,
    required this.hostingCenter,
    required this.analyticsCenter,
    required this.adsCenter,
    required this.firstPartyColor,
    required this.thirdPartyColor,
    required this.hostingColor,
    required this.adsPathColor,
    required this.analyticsPathColor,
    required this.appMakerPathColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
  });

  final bool isRtl;
  final bool useVerticalLayout;
  final bool reduceMotion;
  final Offset appCenter;
  final Offset youCenter;
  final Offset hostingCenter;
  final Offset analyticsCenter;
  final Offset adsCenter;
  final Color firstPartyColor;
  final Color thirdPartyColor;
  final Color hostingColor;
  final Color adsPathColor;
  final Color analyticsPathColor;
  final Color appMakerPathColor;
  final Color surfaceColor;
  final Color onSurfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final arrowHeadLength = 12.0;
    final arrowHeadAngle = math.pi / 6;
    final strokeWidth = 2.5;
    final dashWidth = 6.0;
    final dashSpace = 4.0;

    // Draw "You" (child) to App arrow
    _drawArrow(
      canvas,
      youCenter,
      appCenter,
      appMakerPathColor,
      strokeWidth,
      arrowHeadLength,
      arrowHeadAngle,
      isRtl,
      isSolid: true,
    );

    if (useVerticalLayout) {
      // Draw a clean side trunk in vertical mode so dashed arrows never cut
      // through intermediate nodes or text labels.
      final trunkX = isRtl ? size.width - 14.0 : 14.0;
      _drawBranchedConnector(
        canvas,
        from: appCenter,
        to: hostingCenter,
        trunkX: trunkX,
        color: hostingColor,
        strokeWidth: strokeWidth,
        headLength: arrowHeadLength,
        headAngle: arrowHeadAngle,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      );
      _drawBranchedConnector(
        canvas,
        from: appCenter,
        to: analyticsCenter,
        trunkX: trunkX,
        color: analyticsPathColor,
        strokeWidth: strokeWidth,
        headLength: arrowHeadLength,
        headAngle: arrowHeadAngle,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      );
      _drawBranchedConnector(
        canvas,
        from: appCenter,
        to: adsCenter,
        trunkX: trunkX,
        color: adsPathColor,
        strokeWidth: strokeWidth,
        headLength: arrowHeadLength,
        headAngle: arrowHeadAngle,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      );
      return;
    }

    // Horizontal branches: smooth cubic connectors entering the side of each
    // third-party circle so lines never cross node labels below the circles.
    _drawCurvedHorizontalBranch(
      canvas,
      from: appCenter,
      to: hostingCenter,
      color: hostingColor,
      strokeWidth: strokeWidth,
      headLength: arrowHeadLength,
      headAngle: arrowHeadAngle,
      dashWidth: dashWidth,
      dashSpace: dashSpace,
    );

    _drawCurvedHorizontalBranch(
      canvas,
      from: appCenter,
      to: analyticsCenter,
      color: analyticsPathColor,
      strokeWidth: strokeWidth,
      headLength: arrowHeadLength,
      headAngle: arrowHeadAngle,
      dashWidth: dashWidth,
      dashSpace: dashSpace,
    );

    _drawCurvedHorizontalBranch(
      canvas,
      from: appCenter,
      to: adsCenter,
      color: adsPathColor,
      strokeWidth: strokeWidth,
      headLength: arrowHeadLength,
      headAngle: arrowHeadAngle,
      dashWidth: dashWidth,
      dashSpace: dashSpace,
    );
  }

  void _drawCurvedHorizontalBranch(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required Color color,
    required double strokeWidth,
    required double headLength,
    required double headAngle,
    required double dashWidth,
    required double dashSpace,
  }) {
    const nodeRadius = 28.0;
    final dirX = to.dx >= from.dx ? 1.0 : -1.0;
    final start = Offset(from.dx + dirX * nodeRadius, from.dy);
    final end = Offset(to.dx - dirX * nodeRadius, to.dy);
    final midX = (start.dx + end.dx) / 2;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashWidth, metric.length);
        dashPath.addPath(metric.extractPath(distance, nextDistance), Offset.zero);
        distance = nextDistance + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);

    final direction = Offset(dirX, 0);
    final perpendicular = const Offset(0, 1);
    final arrowBase = end - direction * headLength;
    final left = arrowBase + perpendicular * headLength * math.sin(headAngle);
    final right = arrowBase - perpendicular * headLength * math.sin(headAngle);
    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawBranchedConnector(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required double trunkX,
    required Color color,
    required double strokeWidth,
    required double headLength,
    required double headAngle,
    required double dashWidth,
    required double dashSpace,
  }) {
    const nodeRadius = 28.0;
    final dirToTrunk = trunkX < from.dx ? -1.0 : 1.0;
    final start = Offset(from.dx + dirToTrunk * nodeRadius, from.dy);
    final corner1 = Offset(trunkX, from.dy);
    final corner2 = Offset(trunkX, to.dy);
    final end = Offset(to.dx + dirToTrunk * nodeRadius, to.dy);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(corner1.dx, corner1.dy)
      ..lineTo(corner2.dx, corner2.dy)
      ..lineTo(end.dx, end.dy);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashWidth, metric.length);
        dashPath.addPath(metric.extractPath(distance, nextDistance), Offset.zero);
        distance = nextDistance + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);

    final direction = Offset(-dirToTrunk, 0);
    final perpendicular = const Offset(0, 1);
    final arrowBase = end - direction * headLength;
    final left = arrowBase + perpendicular * headLength * math.sin(headAngle);
    final right = arrowBase - perpendicular * headLength * math.sin(headAngle);
    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color,
    double strokeWidth,
    double headLength,
    double headAngle,
    bool isRtl, {
    bool isSolid = true,
    double dashWidth = 6.0,
    double dashSpace = 4.0,
  }) {
    final direction = (to - from).normalize();
    final perpendicular = Offset(-direction.dy, direction.dx);

    // Adjust start/end points to leave space for node circles
    const nodeRadius = 28.0;
    final start = from + direction * nodeRadius;
    final end = to - direction * nodeRadius;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    if (!isSolid) {
      final dashPath = Path();
      final metric = path.computeMetrics().first;
      double distance = 0;
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
      ..color = color
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    final arrowBase = end - direction * headLength;
    final left = arrowBase + perpendicular * headLength * math.sin(headAngle);
    final right = arrowBase - perpendicular * headLength * math.sin(headAngle);
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(left.dx, left.dy);
    arrowPath.lineTo(right.dx, right.dy);
    arrowPath.close();
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _FlowPainter oldDelegate) =>
      oldDelegate.isRtl != isRtl ||
      oldDelegate.useVerticalLayout != useVerticalLayout ||
      oldDelegate.reduceMotion != reduceMotion ||
      oldDelegate.appCenter != appCenter ||
      oldDelegate.youCenter != youCenter ||
      oldDelegate.hostingCenter != hostingCenter ||
      oldDelegate.analyticsCenter != analyticsCenter ||
      oldDelegate.adsCenter != adsCenter ||
      oldDelegate.firstPartyColor != firstPartyColor ||
      oldDelegate.thirdPartyColor != thirdPartyColor ||
      oldDelegate.hostingColor != hostingColor ||
      oldDelegate.adsPathColor != adsPathColor ||
      oldDelegate.analyticsPathColor != analyticsPathColor ||
      oldDelegate.appMakerPathColor != appMakerPathColor ||
      oldDelegate.surfaceColor != surfaceColor ||
      oldDelegate.onSurfaceColor != onSurfaceColor;
}

enum _LineStyle { dashed }

class _DiagramNode extends StatelessWidget {
  const _DiagramNode({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.size,
    required this.textScale,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final double size;
  final double textScale;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: isPrimary
                  ? Border.all(color: foregroundColor, width: 2.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: size * 0.45, color: foregroundColor),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size * 2.2),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12 * textScale,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThirdPartyNode extends StatelessWidget {
  const _ThirdPartyNode({
    required this.icon,
    required this.label,
    required this.categoryLabel,
    required this.pathColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.size,
    required this.textScale,
    required this.lineStyle,
    this.isWarning = false,
  });

  final IconData icon;
  final String label;
  final String categoryLabel;
  final Color pathColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final double size;
  final double textScale;
  final _LineStyle lineStyle;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = isWarning
        ? scheme.error
        : (lineStyle == _LineStyle.dashed ? scheme.outline : pathColor);

    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: size * 0.45, color: pathColor),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size * 2.2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * textScale,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: pathColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: pathColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    categoryLabel,
                    style: TextStyle(
                      fontSize: 10 * textScale,
                      fontWeight: FontWeight.w600,
                      color: pathColor,
                      height: 1.1,
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

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.label,
    required this.color,
    required this.textScale,
    required this.maxWidth,
    required this.isFirstParty,
  });

  final String label;
  final Color color;
  final double textScale;
  final double maxWidth;
  final bool isFirstParty;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFirstParty ? LucideIcons.shieldCheck : LucideIcons.users,
                size: 14 * textScale,
                color: color,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * textScale,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.2,
                  ),
                ),
              ),
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