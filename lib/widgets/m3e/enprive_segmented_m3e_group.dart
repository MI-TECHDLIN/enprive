import 'package:flutter/material.dart';

import '../../core/theme/enprive_theme.dart';
import 'enprive_material_card_surface.dart';

/// Descriptor for an individual item inside [EnpriveSegmentedM3EGroup].
class EnpriveSegmentedM3EItem {
  final Key? tileKey;
  final Widget? leading;
  final String? overline;
  final String title;
  final String? supportingText;
  final String? trailingMeta;
  final Widget? trailing;
  final VoidCallback? onTap;

  const EnpriveSegmentedM3EItem({
    this.tileKey,
    this.leading,
    this.overline,
    required this.title,
    this.supportingText,
    this.trailingMeta,
    this.trailing,
    this.onTap,
  });
}

/// Reusable tactile segmented card item matching the `Music OS` &
/// `_ (1).jpeg` stacked slab pattern (`22dp` outer cap, `6dp` inner seam,
/// `4dp` vertical gap, `1.5dp` crisp border, and subtle grounded bottom lip).
class EnpriveSegmentedCardTile extends StatelessWidget {
  final int index;
  final int totalCount;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double? lipHeight;
  final String? semanticLabel;

  const EnpriveSegmentedCardTile({
    super.key,
    required this.index,
    required this.totalCount,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.lipHeight,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius cardRadius = EnpriveRadii.groupedCardRadius(
      index: index,
      count: totalCount,
      outer: 22,
      inner: 6,
    );
    final bool interactive = onTap != null || onLongPress != null;
    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.elevated,
      backgroundColor: backgroundColor ?? context.enpriveSurfaces.card,
      borderColor: borderColor,
      borderRadius: cardRadius,
      lipHeight: lipHeight ?? (interactive ? 2.5 : 1.5),
      padding: padding,
      onPressed: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}

/// Tactile Material 3 Expressive segmented container group where outer cap
/// items use `22dp` radii and inner seams tighten to `6dp`, separated by clean
/// `4dp` negative space without noisy horizontal divider lines.
class EnpriveSegmentedM3EGroup extends StatelessWidget {
  final String? sectionTitle;
  final String? sectionSubtitle;
  final List<EnpriveSegmentedM3EItem> items;

  const EnpriveSegmentedM3EGroup({
    super.key,
    this.sectionTitle,
    this.sectionSubtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != null) ...[
          Text(
            sectionTitle!,
            style: m3e.typography.emphasized.titleMedium.copyWith(
              color: scheme.onSurface,
            ),
          ),
          if (sectionSubtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              sectionSubtitle!,
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
        ],
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          EnpriveSegmentedCardTile(
            key: items[i].tileKey,
            index: i,
            totalCount: items.length,
            onTap: items[i].onTap,
            child: Row(
              children: [
                if (items[i].leading != null) ...[
                  items[i].leading!,
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (items[i].overline != null &&
                          items[i].overline!.trim().isNotEmpty) ...[
                        Text(
                          items[i].overline!,
                          style: m3e.typeScale.labelSmall.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        items[i].title,
                        style: m3e.typography.emphasized.titleSmall.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (items[i].supportingText != null &&
                          items[i].supportingText!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          items[i].supportingText!,
                          style: m3e.typeScale.bodySmall.copyWith(
                            height: 1.38,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (items[i].trailing != null) ...[
                  const SizedBox(width: 10),
                  items[i].trailing!,
                ] else if (items[i].trailingMeta != null &&
                    items[i].trailingMeta!.trim().isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: surfaces.cardMuted,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: surfaces.hairlineBorder),
                    ),
                    child: Text(
                      items[i].trailingMeta!,
                      style: m3e.typography.emphasized.labelSmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
