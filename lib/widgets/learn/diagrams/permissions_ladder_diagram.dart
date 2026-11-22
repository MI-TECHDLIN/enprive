import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Localized labels for [PermissionsLadderDiagram] (Lesson 2).
@immutable
class PermissionsLadderDiagramLabels {
  final String headerTitle;
  final String denyTitle;
  final String denyDetail;
  final String askTitle;
  final String askDetail;
  final String whileUsingTitle;
  final String whileUsingDetail;
  final String allTimeTitle;
  final String allTimeDetail;
  final String featureFitNote;
  final String semanticDescription;

  const PermissionsLadderDiagramLabels({
    required this.headerTitle,
    required this.denyTitle,
    required this.denyDetail,
    required this.askTitle,
    required this.askDetail,
    required this.whileUsingTitle,
    required this.whileUsingDetail,
    required this.allTimeTitle,
    required this.allTimeDetail,
    required this.featureFitNote,
    required this.semanticDescription,
  });
}

/// Lesson 2 vector diagram showing Android's four permission choices as a
/// stepped scope ladder (from narrowest to broadest access), paired with a
/// feature-fit reminder and compact still Deni.
///
/// Meaning is carried by step number, distinct icon, scope bar length, solid
/// vs. dashed styling, and plain labels — never color alone. Mirrors cleanly
/// in RTL and reflows cleanly at 200% text scale and 320dp width.
class PermissionsLadderDiagram extends StatelessWidget {
  final PermissionsLadderDiagramLabels labels;

  const PermissionsLadderDiagram({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;
    final reviewAmber = EnpriveStaticColors.reviewAmber(
      Theme.of(context).brightness,
    );
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final rungs = <_LadderRungData>[
      _LadderRungData(
        step: 1,
        icon: LucideIcons.shieldOff,
        title: labels.denyTitle,
        detail: labels.denyDetail,
        scopeFraction: 0.22,
        fillColor: scheme.secondaryContainer,
        inkColor: scheme.onSecondaryContainer,
        barColor: scheme.secondary,
        dashedCaution: false,
      ),
      _LadderRungData(
        step: 2,
        icon: LucideIcons.helpCircle,
        title: labels.askTitle,
        detail: labels.askDetail,
        scopeFraction: 0.48,
        fillColor: scheme.primaryContainer,
        inkColor: scheme.onPrimaryContainer,
        barColor: scheme.primary,
        dashedCaution: false,
      ),
      _LadderRungData(
        step: 3,
        icon: LucideIcons.clock,
        title: labels.whileUsingTitle,
        detail: labels.whileUsingDetail,
        scopeFraction: 0.74,
        fillColor: categoryColors.dataCollection.container,
        inkColor: categoryColors.dataCollection.onContainer,
        barColor: categoryColors.dataCollection.color,
        dashedCaution: false,
      ),
      _LadderRungData(
        step: 4,
        icon: LucideIcons.globe,
        title: labels.allTimeTitle,
        detail: labels.allTimeDetail,
        scopeFraction: 1.0,
        fillColor: reviewAmber.container,
        inkColor: reviewAmber.onContainer,
        barColor: reviewAmber.color,
        dashedCaution: true,
      ),
    ];

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: labels.semanticDescription,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = Container(
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
                  Text(
                    labels.headerTitle,
                    style: m3e.typography.emphasized.labelLarge.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < rungs.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _LadderRungCard(
                      rung: rungs[i],
                      isRtl: isRtl,
                      trackColor: scheme.surfaceContainerHighest,
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
                        const DeniAnimatedMascot(
                          size: 48,
                          pose: DeniPose.pointing,
                          holdStill: true,
                          showAmbientGlow: false,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            labels.featureFitNote,
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
              ),
            );
            return constraints.maxHeight.isFinite
                ? SingleChildScrollView(primary: false, child: content)
                : content;
          },
        ),
      ),
    );
  }
}

class _LadderRungData {
  final int step;
  final IconData icon;
  final String title;
  final String detail;
  final double scopeFraction;
  final Color fillColor;
  final Color inkColor;
  final Color barColor;
  final bool dashedCaution;

  const _LadderRungData({
    required this.step,
    required this.icon,
    required this.title,
    required this.detail,
    required this.scopeFraction,
    required this.fillColor,
    required this.inkColor,
    required this.barColor,
    required this.dashedCaution,
  });
}

class _LadderRungCard extends StatelessWidget {
  final _LadderRungData rung;
  final bool isRtl;
  final Color trackColor;

  const _LadderRungCard({
    required this.rung,
    required this.isRtl,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rung.fillColor,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.78),
                  shape: BoxShape.circle,
                ),
                child: Icon(rung.icon, size: 16, color: rung.barColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${rung.step}. ${rung.title}',
                      style: m3e.typography.emphasized.titleSmall.copyWith(
                        color: rung.inkColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rung.detail,
                      style: m3e.typeScale.bodySmall.copyWith(
                        color: rung.inkColor.withValues(alpha: 0.88),
                        height: 1.32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 8,
            width: double.infinity,
            child: CustomPaint(
              painter: _ScopeBarPainter(
                fraction: rung.scopeFraction,
                trackColor: trackColor,
                barColor: rung.barColor,
                isRtl: isRtl,
                hatched: rung.dashedCaution,
              ),
            ),
          ),
        ],
      ),
    );

    if (!rung.dashedCaution) return card;

    return CustomPaint(
      foregroundPainter: _CautionDashedBorderPainter(
        color: rung.barColor,
        radius: EnpriveRadii.md,
      ),
      child: card,
    );
  }
}

class _ScopeBarPainter extends CustomPainter {
  final double fraction;
  final Color trackColor;
  final Color barColor;
  final bool isRtl;
  final bool hatched;

  const _ScopeBarPainter({
    required this.fraction,
    required this.trackColor,
    required this.barColor,
    required this.isRtl,
    required this.hatched,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final trackRRect = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(trackRRect, Paint()..color = trackColor);

    final fillWidth = (size.width * fraction.clamp(0.1, 1.0)).clamp(
      size.height,
      size.width,
    );
    final fillRect = isRtl
        ? Rect.fromLTWH(size.width - fillWidth, 0, fillWidth, size.height)
        : Rect.fromLTWH(0, 0, fillWidth, size.height);
    final fillRRect = RRect.fromRectAndRadius(fillRect, radius);

    if (!hatched) {
      canvas.drawRRect(fillRRect, Paint()..color = barColor);
    } else {
      // Segmented caution bar for background "All the time" access.
      canvas.save();
      canvas.clipRRect(fillRRect);
      canvas.drawRect(fillRect, Paint()..color = barColor.withValues(alpha: 0.35));
      final stripePaint = Paint()
        ..color = barColor
        ..strokeWidth = 3.0;
      for (double x = -size.height; x < size.width + size.height; x += 9.0) {
        canvas.drawLine(
          Offset(x, size.height),
          Offset(x + size.height, 0),
          stripePaint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ScopeBarPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.barColor != barColor ||
      oldDelegate.isRtl != isRtl ||
      oldDelegate.hatched != hatched;
}

class _CautionDashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _CautionDashedBorderPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1.0),
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
  bool shouldRepaint(covariant _CautionDashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
