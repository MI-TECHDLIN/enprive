import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';

/// The one review-state chip used on every screen: icon plus words, in the
/// same color everywhere. "Review recommended" is amber, "No concern
/// identified" the quiet secondary container with a check, "Insufficient
/// evidence" neutral. It never says "safe".
class EnpriveStateChip extends StatelessWidget {
  final ReviewOverallState state;
  final String label;

  /// Smaller padding and type for rows and cards.
  final bool dense;

  const EnpriveStateChip({
    super.key,
    required this.state,
    required this.label,
    this.dense = false,
  });

  static (SemanticColorPair, IconData) styleOf(
    BuildContext context,
    ReviewOverallState state,
  ) {
    final semantics = context.enpriveSemantics;
    return switch (state) {
      ReviewOverallState.reviewRecommended => (
        semantics.reviewRecommended,
        LucideIcons.eye,
      ),
      ReviewOverallState.noConcern => (semantics.noConcern, LucideIcons.check),
      ReviewOverallState.insufficientEvidence => (
        semantics.insufficientEvidence,
        LucideIcons.circleHelp,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final (pair, icon) = styleOf(context, state);
    final TextStyle textStyle =
        (dense ? m3e.typeScale.labelMedium : m3e.typeScale.labelLarge).copyWith(
          color: pair.foreground,
          fontWeight: FontWeight.w600,
        );

    return Container(
      constraints: BoxConstraints(minHeight: dense ? 24 : 32),
      padding: EdgeInsetsDirectional.fromSTEB(
        dense ? 8 : 10,
        dense ? 3 : 6,
        dense ? 10 : 12,
        dense ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(EnpriveRadii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dense ? 14 : 16, color: pair.icon),
          SizedBox(width: dense ? 4 : 6),
          Flexible(child: Text(label, style: textStyle)),
        ],
      ),
    );
  }
}
