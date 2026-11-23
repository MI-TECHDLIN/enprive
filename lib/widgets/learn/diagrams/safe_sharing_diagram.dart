import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Labels for the safe sharing diagram (Topic 9: Safe-Sharing Habits for Kids).
/// All user-facing strings come from this object for localization.
@immutable
class SafeSharingDiagramLabels {
  const SafeSharingDiagramLabels({
    required this.stop,
    required this.think,
    required this.connect,
    required this.cafeteriaTest,
    required this.semanticDescription,
  });

  final String stop;
  final String think;
  final String connect;
  final String cafeteriaTest;
  final String semanticDescription;
}

/// A diagram showing the three steps 'Stop, Think, Connect' plus the
/// 'Cafeteria Test' callout paired with Deni in a reserved footer card.
///
/// Built in pure flex flow (no Stack overlap) using Direction A tonal surfaces
/// with uniform step spacing, zero repeated text, and clean reflow across
/// 320dp to wide screens, light/dark themes, RTL, and 200% text scale.
class SafeSharingDiagram extends StatelessWidget {
  const SafeSharingDiagram({super.key, required this.labels});

  static const Key mascotKey = Key('safe_sharing_diagram_mascot');
  static const Key cafeteriaTextKey = Key('safe_sharing_cafeteria_text');

  static Key stepBadgeKey(int index) => Key('safe_sharing_step_badge_$index');

  static Key stepLabelKey(int index) => Key('safe_sharing_step_label_$index');

  final SafeSharingDiagramLabels labels;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;
    final reviewAmber = EnpriveStaticColors.reviewAmber(
      Theme.of(context).brightness,
    );

    final steps = <_SafeSharingStepData>[
      _SafeSharingStepData(
        index: 0,
        text: labels.stop,
        icon: LucideIcons.hand,
        containerColor: categoryColors.tracking.container,
        onContainerColor: categoryColors.tracking.onContainer,
        accentColor: categoryColors.tracking.color,
      ),
      _SafeSharingStepData(
        index: 1,
        text: labels.think,
        icon: LucideIcons.brain,
        containerColor: categoryColors.retention.container,
        onContainerColor: categoryColors.retention.onContainer,
        accentColor: categoryColors.retention.color,
      ),
      _SafeSharingStepData(
        index: 2,
        text: labels.connect,
        icon: LucideIcons.users,
        containerColor: categoryColors.parentalConsent.container,
        onContainerColor: categoryColors.parentalConsent.onContainer,
        accentColor: categoryColors.parentalConsent.color,
      ),
    ];

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: labels.semanticDescription,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1.0);
            final useHorizontalSteps =
                constraints.maxWidth >= 560 && textScale <= 1.25;
            final stackCallout =
                constraints.maxWidth < 340 && textScale > 1.5;

            final mascot = const DeniAnimatedMascot(
              key: mascotKey,
              size: 48,
              pose: DeniPose.raiseHand,
              holdStill: true,
              showAmbientGlow: false,
            );

            final cafeteriaInner = Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: reviewAmber.container,
                borderRadius: BorderRadius.circular(EnpriveRadii.md),
              ),
              child: stackCallout
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        mascot,
                        const SizedBox(height: 8),
                        Text(
                          labels.cafeteriaTest,
                          key: cafeteriaTextKey,
                          style: m3e.typeScale.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: reviewAmber.onContainer,
                            height: 1.42,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        mascot,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            labels.cafeteriaTest,
                            key: cafeteriaTextKey,
                            style: m3e.typeScale.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: reviewAmber.onContainer,
                              height: 1.42,
                            ),
                          ),
                        ),
                      ],
                    ),
            );

            final cafeteriaCallout = CustomPaint(
              foregroundPainter: _DashedRRectPainter(
                color: reviewAmber.color,
                radius: EnpriveRadii.md,
              ),
              child: cafeteriaInner,
            );

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
                  if (useHorizontalSteps)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < steps.length; i++) ...[
                            if (i > 0) const SizedBox(width: 10),
                            Expanded(
                              child: _SafeSharingStepCard(
                                step: steps[i],
                                verticalCardLayout: true,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    for (var i = 0; i < steps.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _SafeSharingStepCard(
                        step: steps[i],
                        verticalCardLayout: false,
                      ),
                    ],
                  const SizedBox(height: 12),
                  cafeteriaCallout,
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

class _SafeSharingStepData {
  const _SafeSharingStepData({
    required this.index,
    required this.text,
    required this.icon,
    required this.containerColor,
    required this.onContainerColor,
    required this.accentColor,
  });

  final int index;
  final String text;
  final IconData icon;
  final Color containerColor;
  final Color onContainerColor;
  final Color accentColor;
}

class _SafeSharingStepCard extends StatelessWidget {
  const _SafeSharingStepCard({
    required this.step,
    required this.verticalCardLayout,
  });

  final _SafeSharingStepData step;
  final bool verticalCardLayout;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    final iconCircle = Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.82),
        shape: BoxShape.circle,
        border: Border.all(color: step.accentColor, width: 1.8),
      ),
      child: Icon(step.icon, size: 18, color: step.accentColor),
    );

    final stepBadge = Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(EnpriveRadii.pill),
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          '${step.index + 1}',
          key: SafeSharingDiagram.stepBadgeKey(step.index),
          style: m3e.typography.emphasized.labelSmall.copyWith(
            color: step.onContainerColor,
            height: 1.15,
          ),
        ),
      ),
    );

    final labelText = Text(
      step.text,
      key: SafeSharingDiagram.stepLabelKey(step.index),
      style: m3e.typography.emphasized.titleSmall.copyWith(
        color: step.onContainerColor,
        height: 1.32,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: step.containerColor,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
      ),
      child: verticalCardLayout
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    iconCircle,
                    const SizedBox(width: 8),
                    stepBadge,
                  ],
                ),
                const SizedBox(height: 10),
                labelText,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconCircle,
                const SizedBox(width: 10),
                stepBadge,
                const SizedBox(width: 10),
                Expanded(child: labelText),
              ],
            ),
    );
  }
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
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
