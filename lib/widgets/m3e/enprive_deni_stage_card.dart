import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../deni_animated_mascot.dart';

/// Reusable Material 3 Expressive companion card pairing [DeniAnimatedMascot]
/// at any of the 3 LOD tiers (`52dp` compact, `84dp` standard, `144dp` hero)
/// with calibrated privacy guidance and optional action controls.
///
/// Inspired by `_ (1).jpeg` (Marshmallow companion card), `plan check up.jpeg`,
/// and `Growth_ Mental Health App & Brand Identity - Fiona Bui.jpeg`.
class EnpriveDeniStageCard extends StatelessWidget {
  final DeniPose pose;
  final DeniLodTier lodTier;
  final String title;
  final String message;
  final String? badgeText;
  final Widget? actionArea;
  final VoidCallback? onTap;

  const EnpriveDeniStageCard({
    super.key,
    this.pose = DeniPose.idle,
    this.lodTier = DeniLodTier.standard,
    required this.title,
    required this.message,
    this.badgeText,
    this.actionArea,
    this.onTap,
  });

  double get _mascotSize => switch (lodTier) {
        DeniLodTier.compact => 52,
        DeniLodTier.standard => 84,
        DeniLodTier.hero => 144,
      };

  @override
  Widget build(BuildContext context) {
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;

    final isHero = lodTier == DeniLodTier.hero;

    return M3ECard(
      color: surfaces.card,
      borderRadius: BorderRadius.circular(isHero ? 28 : 24),
      border: BorderSide(color: surfaces.hairlineBorder),
      padding: EdgeInsets.all(isHero ? 22 : 16),
      onPressed: onTap,
      child: Column(
        crossAxisAlignment:
            isHero ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHero) ...[
            if (badgeText != null && badgeText!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText!,
                  style: m3e.typography.emphasized.labelSmall.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            DeniAnimatedMascot(
              size: _mascotSize,
              pose: pose,
              lodOverride: lodTier,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: m3e.typography.emphasized.headlineSmall.copyWith(
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: m3e.typeScale.bodyMedium.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DeniAnimatedMascot(
                  size: _mascotSize,
                  pose: pose,
                  lodOverride: lodTier,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (badgeText != null && badgeText!.isNotEmpty) ...[
                        Text(
                          badgeText!.toUpperCase(),
                          style: m3e.typography.emphasized.labelSmall.copyWith(
                            color: scheme.primary,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 3),
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
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (actionArea != null) ...[
            const SizedBox(height: 14),
            actionArea!,
          ],
        ],
      ),
    );
  }
}
