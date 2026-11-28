import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import 'enprive_material_card_surface.dart';

/// Material 3 Expressive + tactile Bento & selection choice card.
///
/// Inspired by the `colo.jpeg` and `_ (3).jpeg` tactile bento boards and the
/// Material 3 Expressive dual-cue selection pattern:
/// - **Bento card** ([EnpriveBentoChoiceCard]): Rich 2-column feature or
///   onboarding choice tile with optical nested icon well (`nested = outer - padding`),
///   optional subtle tonal corner watermark, top-trailing directional/check
///   affordance, and `3.5dp` tactile press lip.
/// - **Compact selector tile** ([EnpriveBentoChoiceCard.compactOption]):
///   Dense 3-up horizontal selector (e.g., Explanation Depth, Theme Appearance)
///   with dual-cue selection (`2dp` primary border + tonal container fill +
///   check mark badge + corner tighten).
class EnpriveBentoChoiceCard extends StatelessWidget {
  final String title;
  final String? metricHighlight;
  final Color? metricHighlightColor;
  final String? subtitle;
  final String? footerTag;
  final IconData icon;
  final Color? accentColor;
  final Color? accentBackground;
  final Color? accentBorder;
  final bool selected;
  final bool isCompact;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  const EnpriveBentoChoiceCard({
    super.key,
    required this.title,
    this.metricHighlight,
    this.metricHighlightColor,
    this.subtitle,
    this.footerTag,
    required this.icon,
    this.accentColor,
    this.accentBackground,
    this.accentBorder,
    this.selected = false,
    this.onPressed,
    this.semanticLabel,
  }) : isCompact = false;

  const EnpriveBentoChoiceCard.compactOption({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.accentBackground,
    this.accentBorder,
    this.selected = false,
    this.onPressed,
    this.semanticLabel,
  }) : metricHighlight = null,
       metricHighlightColor = null,
       footerTag = null,
       isCompact = true;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;

    final Color iconFg =
        accentColor ?? (selected ? semantics.onDevice.foreground : scheme.primary);
    final Color iconBg =
        accentBackground ??
        (selected ? semantics.onDevice.background : surfaces.cardMuted);

    final Color cardBg = selected
        ? (accentBackground ?? scheme.primaryContainer)
        : surfaces.card;
    final Color selectedBorder = accentColor ?? scheme.primary;
    final BorderRadius baseRadius = isCompact
        ? BorderRadius.circular(selected ? 18 : 20)
        : BorderRadius.circular(selected ? 20 : 24);

    return Semantics(
      selected: selected,
      button: onPressed != null,
      label: semanticLabel ?? title,
      child: EnpriveMaterialCardSurface(
        variant: selected
            ? EnpriveCardVariant.selected
            : EnpriveCardVariant.elevated,
        selected: selected,
        backgroundColor: cardBg,
        accentColor: selectedBorder,
        borderColor: selected ? selectedBorder : accentBorder,
        borderRadius: baseRadius,
        lipHeight: isCompact ? 3.0 : 3.5,
        padding: isCompact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 12)
            : const EdgeInsets.all(16),
        onPressed: onPressed,
        child: isCompact
            ? _buildCompactBody(context, m3e, scheme, surfaces, iconFg, iconBg)
            : _buildBentoBody(
                context,
                m3e,
                scheme,
                surfaces,
                iconFg,
                iconBg,
                selectedBorder,
              ),
      ),
    );
  }

  Widget _buildBentoBody(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    Color iconFg,
    Color iconBg,
    Color selectedBorder,
  ) {
    final bool hasMetric =
        metricHighlight != null && metricHighlight!.trim().isNotEmpty;
    final bool hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final bool hasFooterTag = footerTag != null && footerTag!.trim().isNotEmpty;
    final motion = context.enpriveMotion;
    final typeExt = context.enpriveType;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Subtle tonal watermark echo inspired by colo.jpeg Bento surfaces
        PositionedDirectional(
          end: -10,
          bottom: -14,
          child: IgnorePointer(
            child: Icon(
              icon,
              size: 54,
              color: (selected ? selectedBorder : iconFg).withValues(
                alpha: selected ? 0.11 : 0.06,
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optical nested corner radius: 24dp outer - 16dp padding -> ~12dp inner well
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (selected ? selectedBorder : iconFg).withValues(
                        alpha: 0.22,
                      ),
                    ),
                  ),
                  child: Icon(icon, size: 20, color: iconFg),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: motion.effectiveDuration(
                    context,
                    motion.spatialFast,
                  ),
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? selectedBorder : surfaces.cardMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected
                        ? LucideIcons.check
                        : (onPressed != null
                              ? LucideIcons.arrowUpRight
                              : LucideIcons.sparkles),
                    size: 14,
                    color: selected
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: m3e.typography.emphasized.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.24,
                color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
              ),
            ),
            if (hasMetric) ...[
              const SizedBox(height: 6),
              Text(
                metricHighlight!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typeExt.tabularMetricMedium.copyWith(
                  fontSize: 22,
                  color: metricHighlightColor ?? iconFg,
                ),
              ),
            ],
            if (hasSubtitle) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: m3e.typeScale.bodySmall.copyWith(
                  height: 1.32,
                  color: selected
                      ? scheme.onPrimaryContainer.withValues(alpha: 0.85)
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (hasFooterTag) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.surface.withValues(alpha: 0.55)
                      : surfaces.cardMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  footerTag!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: m3e.typography.emphasized.labelSmall.copyWith(
                    fontSize: 10.5,
                    color: selected ? selectedBorder : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCompactBody(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    Color iconFg,
    Color iconBg,
  ) {
    final Color titleColor = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    final Color subtitleColor = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? scheme.primary : surfaces.cardMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                selected ? LucideIcons.check : icon,
                size: 16,
                color: selected ? scheme.onPrimary : iconFg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: m3e.typography.emphasized.labelLarge.copyWith(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            color: titleColor,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: m3e.typeScale.labelSmall.copyWith(
              height: 1.25,
              color: subtitleColor,
            ),
          ),
        ],
      ],
    );
  }
}
