import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';
import '../enprive_provenance_chip.dart';
import 'enprive_material_card_surface.dart';

/// Archival tactile Material 3 Expressive receipt card for [ReceiptsScreen].
///
/// Features a calibrated posture header strip (`Review recommended` vs
/// `No concern identified`), [EnpriveProvenanceChip], tabular timestamp & source
/// metadata, calibrated summary excerpt, and a single clear action bar
/// (`Open receipt` + `Delete`) — never mixing card-wide tap with nested buttons
/// per `android-design` (`components.md`) rules.
class EnpriveReceiptCard extends StatelessWidget {
  final PolicyReviewReceipt receipt;
  final String stateBadgeLabel;
  final String metaLine;
  final String openLabel;
  final String deleteTooltip;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const EnpriveReceiptCard({
    super.key,
    required this.receipt,
    required this.stateBadgeLabel,
    required this.metaLine,
    required this.openLabel,
    required this.deleteTooltip,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;

    final SemanticColorPair statePair = switch (receipt.overallState) {
      ReviewOverallState.noConcern => semantics.noConcern,
      ReviewOverallState.reviewRecommended => semantics.reviewRecommended,
      ReviewOverallState.insufficientEvidence => semantics.insufficientEvidence,
    };

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.elevated,
      backgroundColor: surfaces.card,
      borderRadius: BorderRadius.circular(24),
      lipHeight: 3.0,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top edge-to-edge calibrated posture & provenance header strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: statePair.background,
              border: Border(
                bottom: BorderSide(
                  color: statePair.border.withValues(alpha: 0.7),
                  width: 1,
                ),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: statePair.icon,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stateBadgeLabel,
                      style: m3e.typography.emphasized.labelMedium.copyWith(
                        color: statePair.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                EnpriveProvenanceChip(source: receipt.inferenceSource),
              ],
            ),
          ),

          // Main receipt summary content
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipt.subjectTitle,
                  style: m3e.typography.emphasized.titleMedium.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metaLine,
                  style: m3e.typeScale.labelSmall.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  receipt.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: m3e.typeScale.bodyMedium.copyWith(
                    height: 1.44,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Grounded tactile footer strip (explicit actions; card body non-clickable)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: surfaces.cardMuted.withValues(alpha: 0.55),
              border: Border(
                top: BorderSide(color: surfaces.hairlineBorder, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: M3EButton.tonal(
                    size: M3EButtonSize.sm,
                    icon: const Icon(LucideIcons.arrowUpRight, size: 17),
                    label: Text(openLabel),
                    onPressed: onOpen,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: deleteTooltip,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: semantics.highConcern.background,
                    side: BorderSide(color: semantics.highConcern.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onDelete,
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: semantics.highConcern.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
