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
        final clampedTextScale = textScale.clamp(1.0, 1.5);
        final nodeSize = 56.0 * clampedTextScale;
        final spacing = 24.0 * clampedTextScale;
        final deniSize = 56 * clampedTextScale;

        // Calculate positions and total height/width
        late Offset youCenter;
        late Offset appCenter;
        late Offset hostingCenter;
        late Offset analyticsCenter;
        late Offset adsCenter;
        late double contentHeight;
        late double contentWidth;

        if (useVerticalLayout) {
          // Vertical stack: You -> App -> (App Maker, Hosting, Analytics, Ads)
          final centerX = width / 2;
          final startY = nodeSize / 2 + 16;

          youCenter = Offset(centerX, startY);
          appCenter = Offset(centerX, youCenter.dy + nodeSize + spacing);

          final thirdPartyStartY = appCenter.dy + nodeSize + spacing;
          final thirdPartySpacing = nodeSize + 16;

          hostingCenter = Offset(centerX, thirdPartyStartY);
          analyticsCenter = Offset(
            centerX,
            hostingCenter.dy + thirdPartySpacing,
          );
          adsCenter = Offset(centerX, analyticsCenter.dy + thirdPartySpacing);

          // Add space for Deni at bottom
          contentHeight = adsCenter.dy + nodeSize / 2 + 16 + deniSize + 16;
          contentWidth = width;
        } else {
          // Horizontal: You (left) -> App (center) -> three branches right
          final centerY = 200 * clampedTextScale;
          final appX = width * 0.4;
          final youX = appX - nodeSize - spacing * 2;

          youCenter = Offset(youX, centerY);
          appCenter = Offset(appX, centerY);

          // Three third-party nodes to the right, vertically stacked
          final thirdPartyX = appX + nodeSize + spacing * 2;
          final startY = centerY - (nodeSize * 1.5 + spacing);
          hostingCenter = Offset(thirdPartyX, startY);
          analyticsCenter = Offset(
            thirdPartyX,
            startY + nodeSize + spacing,
          );
          adsCenter = Offset(thirdPartyX, startY + (nodeSize + spacing) * 2);

          // Height accommodates the three third-party nodes plus Deni
          contentHeight = math.max(
            adsCenter.dy + nodeSize / 2 + 16 + deniSize + 16,
            centerY + nodeSize / 2 + 16 + deniSize + 16,
          );
          contentWidth = width;
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

        return SizedBox(
          width: contentWidth,
          height: contentHeight,
          child: CustomPaint(
            painter: painter,
            child: Stack(
              children: [
                // You (Child) node
                Positioned(
                  left: youCenter.dx - nodeSize / 2,
                  top: youCenter.dy - nodeSize / 2,
                  child: _DiagramNode(
                    icon: LucideIcons.user,
                    label: labels.you,
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    size: nodeSize,
                    textScale: clampedTextScale,
                  ),
                ),
                // App node
                Positioned(
                  left: appCenter.dx - nodeSize / 2,
                  top: appCenter.dy - nodeSize / 2,
                  child: _DiagramNode(
                    icon: LucideIcons.smartphone,
                    label: labels.app,
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                    size: nodeSize,
                    textScale: clampedTextScale,
                    isPrimary: true,
                  ),
                ),
                // Hosting/Crash node
                Positioned(
                  left: hostingCenter.dx - nodeSize / 2,
                  top: hostingCenter.dy - nodeSize / 2,
                  child: _ThirdPartyNode(
                    icon: LucideIcons.server,
                    label: labels.hosting,
                    categoryLabel: labels.thirdParty,
                    pathColor: hostingColor,
                    backgroundColor: surfaces.card,
                    foregroundColor: scheme.onSurface,
                    size: nodeSize,
                    textScale: clampedTextScale,
                    lineStyle: _LineStyle.dashed,
                  ),
                ),
                // Analytics node
                Positioned(
                  left: analyticsCenter.dx - nodeSize / 2,
                  top: analyticsCenter.dy - nodeSize / 2,
                  child: _ThirdPartyNode(
                    icon: LucideIcons.barChart2,
                    label: labels.analytics,
                    categoryLabel: labels.thirdParty,
                    pathColor: analyticsPathColor,
                    backgroundColor: surfaces.card,
                    foregroundColor: scheme.onSurface,
                    size: nodeSize,
                    textScale: clampedTextScale,
                    lineStyle: _LineStyle.dashed,
                  ),
                ),
                // Ads node
                Positioned(
                  left: adsCenter.dx - nodeSize / 2,
                  top: adsCenter.dy - nodeSize / 2,
                  child: _ThirdPartyNode(
                    icon: LucideIcons.signal,
                    label: labels.ads,
                    categoryLabel: labels.thirdParty,
                    pathColor: adsPathColor,
                    backgroundColor: surfaces.card,
                    foregroundColor: scheme.onSurface,
                    size: nodeSize,
                    textScale: clampedTextScale,
                    lineStyle: _LineStyle.dashed,
                    isWarning: true,
                  ),
                ),
                // First Party label (above hosting/app maker)
                if (!useVerticalLayout)
                  Positioned(
                    top: 8,
                    left: hostingCenter.dx - 60,
                    right: hostingCenter.dx + 60,
                    child: Center(
                      child: _CategoryBadge(
                        label: labels.firstParty,
                        color: firstPartyColor,
                        textScale: clampedTextScale,
                        maxWidth: width * 0.5,
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: hostingCenter.dy - nodeSize / 2 - 28,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: _CategoryBadge(
                        label: labels.firstParty,
                        color: firstPartyColor,
                        textScale: clampedTextScale,
                        maxWidth: width - 32,
                      ),
                    ),
                  ),
                // Third Party label (above analytics/ads)
                if (!useVerticalLayout)
                  Positioned(
                    top: 8,
                    left: analyticsCenter.dx - 80,
                    right: analyticsCenter.dx + 80,
                    child: Center(
                      child: _CategoryBadge(
                        label: labels.thirdParty,
                        color: thirdPartyColor,
                        textScale: clampedTextScale,
                        maxWidth: width * 0.5,
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: analyticsCenter.dy - nodeSize / 2 - 28,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: _CategoryBadge(
                        label: labels.thirdParty,
                        color: thirdPartyColor,
                        textScale: clampedTextScale,
                        maxWidth: width - 32,
                      ),
                    ),
                  ),
                // Deni mascot
                if (!useVerticalLayout)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: DeniAnimatedMascot(
                      size: deniSize,
                      pose: DeniPose.explaining,
                      holdStill: true,
                      showAmbientGlow: false,
                    ),
                  )
                else
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
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
        );
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
      onSurfaceColor.withValues(alpha: 0.6),
      strokeWidth,
      arrowHeadLength,
      arrowHeadAngle,
      isRtl,
    );

    // App to App Maker (first party) - solid teal
    _drawArrow(
      canvas,
      appCenter,
      hostingCenter,
      appMakerPathColor,
      strokeWidth,
      arrowHeadLength,
      arrowHeadAngle,
      isRtl,
      isSolid: true,
    );

    // App to Hosting/Crash (third party, neutral) - dashed
    _drawArrow(
      canvas,
      appCenter,
      analyticsCenter,
      hostingColor,
      strokeWidth,
      arrowHeadLength,
      arrowHeadAngle,
      isRtl,
      isSolid: false,
      dashWidth: dashWidth,
      dashSpace: dashSpace,
    );

    // App to Analytics (third party) - dashed
    _drawArrow(
      canvas,
      appCenter,
      adsCenter,
      analyticsPathColor,
      strokeWidth,
      arrowHeadLength,
      arrowHeadAngle,
      isRtl,
      isSolid: false,
      dashWidth: dashWidth,
      dashSpace: dashSpace,
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
  });

  final String label;
  final Color color;
  final double textScale;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                label == 'First party' || label.contains('First') ||
                        label.contains('First-party') ||
                        label.contains('first party') ||
                        label.contains('first-party')
                    ? LucideIcons.shieldCheck
                    : LucideIcons.users,
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