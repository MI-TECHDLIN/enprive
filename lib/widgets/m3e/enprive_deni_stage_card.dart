import 'package:flutter/material.dart';

import '../deni_animated_mascot.dart';
import 'enprive_companion_card.dart';

/// Reusable Material 3 Expressive companion card pairing [DeniAnimatedMascot]
/// at any of the 3 LOD tiers (`52dp` compact, `84dp` standard, `144dp` hero)
/// with calibrated privacy guidance and optional action controls.
///
/// Backed by [EnpriveCompanionCard] so all Deni companion containers share
/// Enprive's tactile `1.5dp` Material border and grounded bottom lip.
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

  @override
  Widget build(BuildContext context) {
    final card = EnpriveCompanionCard(
      pose: pose,
      lodTier: lodTier,
      badgeText: badgeText,
      title: title,
      message: message,
      action: onTap == null ? actionArea : null,
    );

    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}
