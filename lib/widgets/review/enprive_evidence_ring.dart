import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart'
    show M3EMotion;

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';
import 'evidence_category_style.dart';

/// Evidence ring for the Review result hero: one arc per finding category,
/// arc length proportional to that category's findings, and the finding
/// count in the center. It is a count of evidence, never a score or grade,
/// and it never fills with a "safe" color.
///
/// - Arcs draw in one after another (700ms emphasized decelerate, 90ms
///   stagger) while the center count rolls up; under reduced motion the ring
///   appears complete.
/// - TalkBack reads one node, [semanticLabel].
/// - The ring starts at the top and runs clockwise, counter-clockwise in RTL.
class EnpriveEvidenceRing extends StatefulWidget {
  /// Findings per category, in [EvidenceCategoryStyle.order].
  final Map<FindingCategory, int> counts;
  final int total;

  /// Word under the count ("findings").
  final String centerUnit;
  final String semanticLabel;
  final double size;
  final double strokeWidth;

  const EnpriveEvidenceRing({
    super.key,
    required this.counts,
    required this.total,
    required this.centerUnit,
    required this.semanticLabel,
    this.size = 128,
    this.strokeWidth = 12,
  });

  static const Duration arcDuration = Duration(milliseconds: 700);
  static const Duration arcStagger = Duration(milliseconds: 90);

  @override
  State<EnpriveEvidenceRing> createState() => _EnpriveEvidenceRingState();
}

class _EnpriveEvidenceRingState extends State<EnpriveEvidenceRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _totalDuration,
  );
  bool _started = false;

  int get _arcCount => math.max(1, widget.counts.length);

  Duration get _totalDuration =>
      EnpriveEvidenceRing.arcDuration +
      EnpriveEvidenceRing.arcStagger * (_arcCount - 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _controller.value = 1;
    } else if (!_started) {
      _controller.forward();
    }
    _started = true;
  }

  @override
  void didUpdateWidget(EnpriveEvidenceRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = _totalDuration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final segments = [
      for (final entry in widget.counts.entries)
        if (entry.value > 0)
          (
            fraction: widget.total == 0 ? 0.0 : entry.value / widget.total,
            color: EvidenceCategoryStyle.of(context, entry.key).color.color,
          ),
    ];

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: widget.semanticLabel,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final elapsed =
                _controller.value * _totalDuration.inMicroseconds.toDouble();
            final arcProgress = [
              for (var i = 0; i < segments.length; i++)
                M3EMotion.emphasizedDecelerate.transform(
                  ((elapsed -
                              EnpriveEvidenceRing.arcStagger.inMicroseconds *
                                  i) /
                          EnpriveEvidenceRing.arcDuration.inMicroseconds)
                      .clamp(0.0, 1.0),
                ),
            ];
            final countProgress = M3EMotion.emphasizedDecelerate.transform(
              _controller.value,
            );
            return CustomPaint(
              painter: _EvidenceRingPainter(
                segments: segments,
                progress: arcProgress,
                trackColor: scheme.surfaceContainerHighest,
                strokeWidth: widget.strokeWidth,
                counterClockwise: isRtl,
              ),
              child: Padding(
                padding: EdgeInsets.all(widget.strokeWidth + 10),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(widget.total * countProgress).round()}',
                          style: m3e.typography.emphasized.displaySmall
                              .copyWith(
                                color: scheme.onSurface,
                                height: 1.05,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                        Text(
                          widget.centerUnit,
                          style: m3e.typeScale.labelMedium.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EvidenceRingPainter extends CustomPainter {
  final List<({double fraction, Color color})> segments;
  final List<double> progress;
  final Color trackColor;
  final double strokeWidth;
  final bool counterClockwise;

  const _EvidenceRingPainter({
    required this.segments,
    required this.progress,
    required this.trackColor,
    required this.strokeWidth,
    required this.counterClockwise,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(rect.center, radius, track);
    if (segments.isEmpty) return;

    // Round caps eat into neighbouring arcs, so each gap is the cap width
    // plus a few degrees of visible space.
    final capAngle = strokeWidth / radius;
    final gap = segments.length > 1 ? capAngle + 0.07 : 0.0;
    final direction = counterClockwise ? -1.0 : 1.0;
    var start = -math.pi / 2 + direction * gap / 2;
    for (var i = 0; i < segments.length; i++) {
      final full = segments[i].fraction * 2 * math.pi;
      final sweep = math.max(0.0, full - gap) * progress[i];
      if (sweep > 0) {
        canvas.drawArc(
          rect,
          start,
          direction * sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round
            ..color = segments[i].color,
        );
      }
      start += direction * full;
    }
  }

  @override
  bool shouldRepaint(_EvidenceRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.segments != segments ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.counterClockwise != counterClockwise;
}
