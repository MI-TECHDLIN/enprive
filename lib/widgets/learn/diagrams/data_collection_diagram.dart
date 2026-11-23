import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../deni_animated_mascot.dart';

/// Labels for the data collection diagram (Topic 2: What Data Apps Collect).
/// All user-facing strings come from this object for localization.
@immutable
class DataCollectionDiagramLabels {
  const DataCollectionDiagramLabels({
    required this.youTypeTitle,
    required this.youTypeItems,
    required this.runsQuietlyTitle,
    required this.runsQuietlyItems,
    required this.semanticDescription,
    this.quietNote,
  });

  final String youTypeTitle;
  final List<String> youTypeItems;
  final String runsQuietlyTitle;
  final List<String> runsQuietlyItems;
  final String semanticDescription;

  /// Optional localized calm note placed beside Deni in the reserved footer.
  final String? quietNote;
}

/// A diagram showing the two categories of data collection:
/// 1. What you actively type or give (name, email, photos, voice, homework)
/// 2. What runs quietly in the background (advertising ID, device IDs, IP
///    address, crash logs, usage timing)
///
/// Uses Direction A Calm Evidence tonal surfaces in pure flex flow (no Stack
/// overlap). Switches between side-by-side columns on wide screens and stacked
/// cards on narrow widths or high text scales, with Deni in a reserved footer.
class DataCollectionDiagram extends StatelessWidget {
  const DataCollectionDiagram({super.key, required this.labels});

  static const Key mascotKey = Key('data_collection_diagram_mascot');
  static const Key youTypeTitleKey = Key('data_collection_you_type_title');
  static const Key runsQuietlyTitleKey = Key(
    'data_collection_runs_quietly_title',
  );
  static const Key quietNoteKey = Key('data_collection_quiet_note');

  static Key youTypeItemKey(int index) =>
      Key('data_collection_you_type_item_$index');

  static Key runsQuietlyItemKey(int index) =>
      Key('data_collection_runs_quietly_item_$index');

  final DataCollectionDiagramLabels labels;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final categoryColors = context.categoryColors;

    final youTypePalette = categoryColors.dataCollection;
    final runsQuietlyPalette = categoryColors.tracking;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: labels.semanticDescription,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1.0);
            final useSideBySide =
                constraints.maxWidth >= 480 && textScale <= 1.25;
            final stackFooter =
                constraints.maxWidth < 340 && textScale > 1.5;

            final youTypeCard = _DataCategoryCard(
              title: labels.youTypeTitle,
              titleKey: youTypeTitleKey,
              icon: LucideIcons.userPen,
              itemIcon: LucideIcons.pencil,
              items: labels.youTypeItems,
              itemKeyBuilder: youTypeItemKey,
              containerColor: youTypePalette.container,
              onContainerColor: youTypePalette.onContainer,
              accentColor: youTypePalette.color,
              dashedOutline: false,
            );

            final runsQuietlyCard = _DataCategoryCard(
              title: labels.runsQuietlyTitle,
              titleKey: runsQuietlyTitleKey,
              icon: LucideIcons.cpu,
              itemIcon: LucideIcons.radio,
              items: labels.runsQuietlyItems,
              itemKeyBuilder: runsQuietlyItemKey,
              containerColor: runsQuietlyPalette.container,
              onContainerColor: runsQuietlyPalette.onContainer,
              accentColor: runsQuietlyPalette.color,
              dashedOutline: true,
            );

            final quietNoteText = labels.quietNote?.trim();
            final hasQuietNote =
                quietNoteText != null && quietNoteText.isNotEmpty;

            final mascot = const DeniAnimatedMascot(
              key: mascotKey,
              size: 48,
              pose: DeniPose.thinking,
              holdStill: true,
              showAmbientGlow: false,
            );

            final footer = Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(EnpriveRadii.md),
              ),
              child: !hasQuietNote
                  ? Center(child: mascot)
                  : stackFooter
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        mascot,
                        const SizedBox(height: 8),
                        Text(
                          quietNoteText,
                          key: quietNoteKey,
                          style: m3e.typeScale.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                            height: 1.4,
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
                            quietNoteText,
                            key: quietNoteKey,
                            style: m3e.typeScale.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  if (useSideBySide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: youTypeCard),
                          const SizedBox(width: 12),
                          Expanded(child: runsQuietlyCard),
                        ],
                      ),
                    )
                  else ...[
                    youTypeCard,
                    const SizedBox(height: 12),
                    runsQuietlyCard,
                  ],
                  const SizedBox(height: 12),
                  footer,
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

class _DataCategoryCard extends StatelessWidget {
  const _DataCategoryCard({
    required this.title,
    required this.titleKey,
    required this.icon,
    required this.itemIcon,
    required this.items,
    required this.itemKeyBuilder,
    required this.containerColor,
    required this.onContainerColor,
    required this.accentColor,
    required this.dashedOutline,
  });

  final String title;
  final Key titleKey;
  final IconData icon;
  final IconData itemIcon;
  final List<String> items;
  final Key Function(int index) itemKeyBuilder;
  final Color containerColor;
  final Color onContainerColor;
  final Color accentColor;
  final bool dashedOutline;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.78),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  key: titleKey,
                  style: m3e.typography.emphasized.titleSmall.copyWith(
                    color: onContainerColor,
                    height: 1.28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(EnpriveRadii.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(itemIcon, size: 14, color: accentColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      items[i],
                      key: itemKeyBuilder(i),
                      style: m3e.typeScale.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (!dashedOutline) return card;

    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: accentColor.withValues(alpha: 0.65),
        radius: EnpriveRadii.md,
      ),
      child: card,
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
