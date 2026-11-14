import 'package:flutter/material.dart';

import '../../core/theme/enprive_theme.dart';
import '../deni_animated_mascot.dart';
import 'enprive_material_card_surface.dart';

/// Placement style of [DeniAnimatedMascot] inside [EnpriveCompanionCard].
enum EnpriveCompanionLayout {
  /// Deni sits inside a subtle tonal alcove beside the calibrated message.
  inline,

  /// Deni peeks over the top edge of the tactile card frame (`plan check up.jpeg`).
  peeking,
}

/// Tactile Material 3 Expressive companion card pairing [DeniAnimatedMascot]
/// with calibrated privacy guidance and an optional single action slot.
///
/// Designed after the `plan check up.jpeg` peeking card motif and `_ (1).jpeg`
/// friendly companion surfaces: crisp `1.5dp` outline, `3.0dp` physical bottom
/// lip, tonal badge crest, and strict single-action compliance (`onPressed` is
/// omitted when [action] is supplied).
class EnpriveCompanionCard extends StatelessWidget {
  final DeniPose pose;
  final DeniLodTier? lodTier;
  final double? mascotSize;
  final EnpriveCompanionLayout layout;
  final String? badgeText;
  final IconData? badgeIcon;
  final String title;
  final String message;
  final Widget? action;
  final Widget? footer;
  final Color? accentColor;
  final Color? accentBackground;
  final Color? backgroundColor;
  final BorderRadius borderRadius;

  const EnpriveCompanionCard({
    super.key,
    required this.pose,
    this.lodTier,
    this.mascotSize,
    this.layout = EnpriveCompanionLayout.inline,
    this.badgeText,
    this.badgeIcon,
    required this.title,
    required this.message,
    this.action,
    this.footer,
    this.accentColor,
    this.accentBackground,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  double _resolvedMascotSize() {
    if (mascotSize != null) return mascotSize!;
    if (layout == EnpriveCompanionLayout.peeking) return 84;
    return switch (lodTier) {
      DeniLodTier.compact => 52,
      DeniLodTier.standard || null => 84,
      DeniLodTier.hero => 144,
    };
  }

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;

    final Color resolvedBadgeFg = accentColor ?? semantics.onDevice.foreground;
    final Color resolvedBadgeBg =
        accentBackground ?? semantics.onDevice.background;
    final double effectiveMascotSize = _resolvedMascotSize();

    final Widget badgeWidget =
        (badgeText != null && badgeText!.trim().isNotEmpty)
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: resolvedBadgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badgeIcon != null) ...[
                  Icon(badgeIcon, size: 13, color: resolvedBadgeFg),
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: Text(
                    badgeText!,
                    style: m3e.typography.emphasized.labelSmall.copyWith(
                      color: resolvedBadgeFg,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    final Widget mascotWidget = DeniAnimatedMascot(
      pose: pose,
      size: effectiveMascotSize,
      lodOverride: lodTier,
    );

    if (layout == EnpriveCompanionLayout.peeking) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, 10),
            child: mascotWidget,
          ),
          EnpriveMaterialCardSurface(
            variant: EnpriveCardVariant.elevated,
            backgroundColor: backgroundColor ?? surfaces.card,
            borderRadius: borderRadius,
            lipHeight: 3.0,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badgeText != null && badgeText!.trim().isNotEmpty) ...[
                  Center(child: badgeWidget),
                  const SizedBox(height: 12),
                ],
                Text(
                  title,
                  style: m3e.typography.emphasized.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: m3e.typeScale.bodyMedium.copyWith(
                    height: 1.48,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (footer != null) ...[
                  const SizedBox(height: 12),
                  footer!,
                ],
                if (action != null) ...[
                  const SizedBox(height: 16),
                  action!,
                ],
              ],
            ),
          ),
        ],
      );
    }

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.elevated,
      backgroundColor: backgroundColor ?? surfaces.card,
      borderRadius: borderRadius,
      lipHeight: 3.0,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Grounded tonal alcove framing Deni inside the card
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: resolvedBadgeBg.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: resolvedBadgeFg.withValues(alpha: 0.14),
                  ),
                ),
                child: mascotWidget,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badgeText != null && badgeText!.trim().isNotEmpty) ...[
                      badgeWidget,
                      const SizedBox(height: 8),
                    ],
                    Text(
                      title,
                      style: m3e.typography.emphasized.titleMedium.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: m3e.typeScale.bodySmall.copyWith(
                        height: 1.44,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
