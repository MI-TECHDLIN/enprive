import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Localized labels for [PolicyLimitDiagram] (Lesson 1).
@immutable
class PolicyLimitDiagramLabels {
  final String policySaysTitle;
  final String policySaysBody;
  final String policyQuoteSample;
  final String phoneShowsTitle;
  final String phoneShowsBody;
  final String unknownTitle;
  final String unknownBody;
  final String caption;
  final String semanticDescription;

  const PolicyLimitDiagramLabels({
    required this.policySaysTitle,
    required this.policySaysBody,
    required this.policyQuoteSample,
    required this.phoneShowsTitle,
    required this.phoneShowsBody,
    required this.unknownTitle,
    required this.unknownBody,
    required this.caption,
    required this.semanticDescription,
  });
}

/// Lesson 1 vector diagram comparing what a privacy policy promises, what
/// Android permissions show on this phone, and what stays unknown (live
/// internet traffic Enprive cannot observe).
///
/// Built strictly on Direction A tonal surfaces (`surfaceContainerLow` /
/// `surfaceContainer`), `EnpriveCategoryColors`, `LucideIcons`, and compact
/// still `DeniAnimatedMascot`. Uses icons, solid vs. dashed strokes, and
/// explicit labels so meaning never relies on color alone; exposes one
/// plain-language TalkBack node via [Semantics].
class PolicyLimitDiagram extends StatelessWidget {
  final PolicyLimitDiagramLabels labels;

  const PolicyLimitDiagram({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;
    final quoteStyle = context.enpriveType.policyQuotation;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: labels.semanticDescription,
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(EnpriveRadii.card),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1.0);
              final useVertical =
                  constraints.maxWidth < 360 || textScale > 1.35;

              final policyCard = _ZoneCard(
                icon: LucideIcons.fileText,
                title: labels.policySaysTitle,
                body: labels.policySaysBody,
                quoteSample: labels.policyQuoteSample,
                quoteStyle: quoteStyle,
                background: categoryColors.dataCollection.container,
                foreground: categoryColors.dataCollection.onContainer,
                accentColor: categoryColors.dataCollection.color,
              );

              final phoneCard = _ZoneCard(
                icon: LucideIcons.smartphone,
                title: labels.phoneShowsTitle,
                body: labels.phoneShowsBody,
                background: scheme.secondaryContainer,
                foreground: scheme.onSecondaryContainer,
                accentColor: scheme.secondary,
              );

              final unknownCard = _ZoneCard(
                icon: LucideIcons.helpCircle,
                title: labels.unknownTitle,
                body: labels.unknownBody,
                background: scheme.surfaceContainerHighest,
                foreground: scheme.onSurface,
                accentColor: scheme.outline,
                dashedOutline: true,
              );

              final diagramColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (useVertical) ...[
                    policyCard,
                    _FlowConnector(
                      vertical: true,
                      dashed: false,
                      isRtl: isRtl,
                      color: scheme.primary,
                    ),
                    phoneCard,
                    _FlowConnector(
                      vertical: true,
                      dashed: true,
                      isRtl: isRtl,
                      color: scheme.outline,
                    ),
                    unknownCard,
                  ] else
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: policyCard),
                          _FlowConnector(
                            vertical: false,
                            dashed: false,
                            isRtl: isRtl,
                            color: scheme.primary,
                          ),
                          Expanded(child: phoneCard),
                          _FlowConnector(
                            vertical: false,
                            dashed: true,
                            isRtl: isRtl,
                            color: scheme.outline,
                          ),
                          Expanded(child: unknownCard),
                        ],
                      ),
                    ),
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
                        const DeniAnimatedMascot(
                          size: 48,
                          pose: DeniPose.explaining,
                          holdStill: true,
                          showAmbientGlow: false,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            labels.caption,
                            style: m3e.typography.emphasized.labelLarge
                                .copyWith(
                                  color: scheme.onSurface,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              return constraints.maxHeight.isFinite
                  ? SingleChildScrollView(primary: false, child: diagramColumn)
                  : diagramColumn;
            },
          ),
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? quoteSample;
  final TextStyle? quoteStyle;
  final Color background;
  final Color foreground;
  final Color accentColor;
  final bool dashedOutline;

  const _ZoneCard({
    required this.icon,
    required this.title,
    required this.body,
    this.quoteSample,
    this.quoteStyle,
    required this.background,
    required this.foreground,
    required this.accentColor,
    this.dashedOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    final inner = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.72),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: m3e.typography.emphasized.titleSmall.copyWith(
              color: foreground,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: m3e.typeScale.bodySmall.copyWith(
              color: foreground.withValues(alpha: 0.88),
              height: 1.35,
            ),
          ),
          if (quoteSample != null && quoteSample!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(EnpriveRadii.chip),
              ),
              child: Text(
                quoteSample!,
                style: (quoteStyle ?? m3e.typeScale.bodySmall).copyWith(
                  fontSize: 11.5,
                  height: 1.3,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (!dashedOutline) return inner;

    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: accentColor,
        radius: EnpriveRadii.md,
      ),
      child: inner,
    );
  }
}

class _FlowConnector extends StatelessWidget {
  final bool vertical;
  final bool dashed;
  final bool isRtl;
  final Color color;

  const _FlowConnector({
    required this.vertical,
    required this.dashed,
    required this.isRtl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: vertical ? double.infinity : 26,
      height: vertical ? 24 : 36,
      child: CustomPaint(
        painter: _ConnectorArrowPainter(
          vertical: vertical,
          dashed: dashed,
          isRtl: isRtl,
          color: color,
        ),
      ),
    );
  }
}

class _ConnectorArrowPainter extends CustomPainter {
  final bool vertical;
  final bool dashed;
  final bool isRtl;
  final Color color;

  const _ConnectorArrowPainter({
    required this.vertical,
    required this.dashed,
    required this.isRtl,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    late final Offset start;
    late final Offset end;
    if (vertical) {
      start = Offset(size.width / 2, 2);
      end = Offset(size.width / 2, size.height - 4);
    } else if (isRtl) {
      start = Offset(size.width - 2, size.height / 2);
      end = Offset(4, size.height / 2);
    } else {
      start = Offset(2, size.height / 2);
      end = Offset(size.width - 4, size.height / 2);
    }

    final linePath = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    if (dashed) {
      final dashPath = Path();
      for (final metric in linePath.computeMetrics()) {
        double dist = 0;
        while (dist < metric.length) {
          final next = math.min(dist + 4.0, metric.length);
          dashPath.addPath(metric.extractPath(dist, next), Offset.zero);
          dist = next + 3.5;
        }
      }
      canvas.drawPath(dashPath, paint);
    } else {
      canvas.drawPath(linePath, paint);
    }

    // Small arrowhead at `end`
    final vector = end - start;
    final len = vector.distance;
    if (len == 0) return;
    final dir = vector / len;
    final perp = Offset(-dir.dy, dir.dx);
    const headLen = 6.0;
    const headHalfWidth = 4.0;
    final base = end - dir * headLen;
    final arrow = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(base.dx + perp.dx * headHalfWidth, base.dy + perp.dy * headHalfWidth)
      ..lineTo(base.dx - perp.dx * headHalfWidth, base.dy - perp.dy * headHalfWidth)
      ..close();
    canvas.drawPath(
      arrow,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ConnectorArrowPainter oldDelegate) =>
      oldDelegate.vertical != vertical ||
      oldDelegate.dashed != dashed ||
      oldDelegate.isRtl != isRtl ||
      oldDelegate.color != color;
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1.0),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + 6.0, metric.length);
        dashPath.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + 4.5;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
