import 'package:flutter/material.dart';

import '../../core/theme/enprive_theme.dart';
import 'enprive_material_card_surface.dart';

/// Tactile Material 3 Expressive metric tile card inspired by the `_.jpeg`
/// asymmetric metric board and the `android-design` Metric card archetype.
///
/// Enforces strict metric hierarchy: the tabular value dominates in
/// [EnpriveTypographyExtension.tabularMetricLarge] while the category label
/// whispers cleanly in `onSurfaceVariant`, anchored by a semantic tonal icon
/// squircle and bottom accent shelf pill.
class EnpriveMetricTileCard extends StatelessWidget {
  final String value;
  final String label;
  final String? sublabel;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? accentColor;
  final Color? accentBackground;
  final double? meterFraction;
  final VoidCallback? onPressed;

  const EnpriveMetricTileCard({
    super.key,
    required this.value,
    required this.label,
    this.sublabel,
    this.icon,
    this.iconWidget,
    this.accentColor,
    this.accentBackground,
    this.meterFraction,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final typeExt = context.enpriveType;

    final Color effectiveAccent = accentColor ?? scheme.primary;
    final Color effectiveIconBg =
        accentBackground ?? surfaces.cardMuted;
    final double clampedMeter = (meterFraction ?? 1.0).clamp(0.18, 1.0);

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.elevated,
      backgroundColor: surfaces.card,
      borderRadius: BorderRadius.circular(20),
      lipHeight: onPressed != null ? 3.5 : 2.5,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      onPressed: onPressed,
      semanticLabel: '$value $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typeExt.tabularMetricLarge.copyWith(
                    fontSize: 24,
                    height: 1.05,
                    color: accentColor ?? scheme.onSurface,
                  ),
                ),
              ),
              if (iconWidget != null || icon != null)
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: effectiveIconBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child:
                      iconWidget ??
                      Icon(icon, size: 15, color: effectiveAccent),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: m3e.typeScale.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (sublabel != null && sublabel!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              sublabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: m3e.typeScale.labelSmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Signature `_.jpeg` subtle bottom posture bar inside the card
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 4,
              width: double.infinity,
              color: surfaces.cardMuted,
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: clampedMeter,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: effectiveAccent.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
