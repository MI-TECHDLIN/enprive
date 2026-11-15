import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';
import 'enprive_material_card_surface.dart';

/// Editorial Material 3 Expressive stacked-receipt card for saved
/// [PolicyReviewReceipt]s.
///
/// Follows a monochrome archival cardstock silhouette inspired by stacked paper
/// receipts — free of internal pastel color blocks or technical hash clutter:
/// - 3-sheet stepped paper deck using neutral surface & hairline tokens
/// - Quiet top-left tabular findings/verified readout + ghost delete control
/// - Wide editorial title & 2-line insight paired with a minimalist 3-step
///   vertical posture indicator (`| · ·`)
/// - Inset hairline divider anchoring a bare semantic shield emblem, verdict/date
///   origin, and a high-contrast dark-ink / ceramic-teal `M3EButton` CTA pill
class EnpriveReceiptCard extends StatelessWidget {
  final PolicyReviewReceipt receipt;
  final String stateBadgeLabel;
  final String metaLine;
  final String openLabel;
  final String deleteTooltip;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final String? findingsLabel;
  final String? verifiedLabel;

  const EnpriveReceiptCard({
    super.key,
    required this.receipt,
    required this.stateBadgeLabel,
    required this.metaLine,
    required this.openLabel,
    required this.deleteTooltip,
    required this.onOpen,
    required this.onDelete,
    this.findingsLabel,
    this.verifiedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;

    final (SemanticColorPair statePair, IconData stateIcon) =
        switch (receipt.overallState) {
          ReviewOverallState.reviewRecommended => (
            semantics.reviewRecommended,
            LucideIcons.shieldAlert,
          ),
          ReviewOverallState.noConcern => (
            semantics.noConcern,
            LucideIcons.fileText,
          ),
          ReviewOverallState.insufficientEvidence => (
            semantics.insufficientEvidence,
            LucideIcons.circleHelp,
          ),
        };

    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final bool isLargeScale = textScale > 1.25;

    final int findingsCount = receipt.findings.length;
    final int verifiedCount = receipt.sourceMatchedCount;
    final String resolvedFindings = findingsLabel ?? 'Findings';
    final String resolvedVerified = verifiedLabel ?? 'Verified';
    final String metricsSummary =
        '$findingsCount $resolvedFindings · $verifiedCount $resolvedVerified';

    return Semantics(
      container: true,
      label:
          '${receipt.subjectTitle}, $stateBadgeLabel, $metricsSummary, $metaLine',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottommost receipt deck sheet edge
          Positioned(
            left: 14,
            right: 14,
            bottom: 0,
            height: 30,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surfaces.cardMuted,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: surfaces.strongBorder.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: surfaces.ambientShadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Middle receipt deck sheet edge
          Positioned(
            left: 7,
            right: 7,
            bottom: 4.5,
            height: 30,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surfaces.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: surfaces.strongBorder.withValues(alpha: 0.40),
                  ),
                ),
              ),
            ),
          ),
          // Primary crisp cardstock face
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: EnpriveMaterialCardSurface(
              variant: EnpriveCardVariant.elevated,
              backgroundColor: surfaces.card,
              borderRadius: BorderRadius.circular(22),
              lipHeight: 0,
              borderWidth: 1.2,
              padding: const EdgeInsets.fromLTRB(18, 12, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row: Full-width source/timestamp meta + ghost delete action
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          metaLine,
                          maxLines: isLargeScale ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: m3e.typeScale.labelMedium.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: deleteTooltip,
                        onPressed: onDelete,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: scheme.onSurfaceVariant,
                          minimumSize: const Size(40, 40),
                          tapTargetSize: MaterialTapTargetSize.padded,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(LucideIcons.trash2, size: 17),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Middle Editorial Zone: Wide title & insight + vertical 3-step meter
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                receipt.subjectTitle,
                                maxLines: isLargeScale ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                                style: m3e.typography.emphasized.titleLarge
                                    .copyWith(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                      height: 1.18,
                                    ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                receipt.summary,
                                maxLines: isLargeScale ? 3 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: m3e.typeScale.bodyMedium.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        ExcludeSemantics(
                          child: _VerticalPostureMeter(
                            overallState: receipt.overallState,
                            activeColor: scheme.onSurface,
                            inactiveColor: surfaces.strongBorder.withValues(
                              alpha: 0.48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Subtle inset hairline divider
                  Container(
                    height: 1,
                    margin: const EdgeInsetsDirectional.only(end: 4),
                    color: surfaces.hairlineBorder.withValues(alpha: 0.72),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Footer: Bare status emblem + verdict/date + decisive CTA pill
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 4),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool stackVertically =
                            isLargeScale || constraints.maxWidth < 260;

                        final Widget originCluster = Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ExcludeSemantics(
                              child: Icon(
                                stateIcon,
                                size: 22,
                                color: statePair.icon,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    stateBadgeLabel,
                                    maxLines: isLargeScale ? 2 : 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: m3e.typography.emphasized.labelLarge
                                        .copyWith(
                                          color: scheme.onSurface,
                                          fontWeight: FontWeight.w700,
                                          height: 1.18,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    metricsSummary,
                                    maxLines: isLargeScale ? 2 : 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: m3e.typeScale.labelSmall.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );

                        final Widget openButton = M3EButton(
                          onPressed: onOpen,
                          style: M3EButtonStyle.filled,
                          size: M3EButtonSize.sm.copyWith(
                            height: 40,
                            hPadding: 16,
                          ),
                          shape: M3EButtonShape.round,
                          decoration: M3EButtonDecoration(
                            backgroundColor: WidgetStatePropertyAll<Color?>(
                              surfaces.tactilePrimaryBg,
                            ),
                            foregroundColor: WidgetStatePropertyAll<Color?>(
                              surfaces.tactilePrimaryFg,
                            ),
                            textStyle: m3e.typography.emphasized.labelLarge,
                            motion: M3EButtonMotion.expressiveSpatialPress,
                            haptic: M3EHapticFeedback.light,
                            borderRadius: 999,
                            pressedRadius: 14,
                          ),
                          label: Text(openLabel),
                        );

                        if (stackVertically) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              originCluster,
                              const SizedBox(height: 12),
                              openButton,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: originCluster),
                            const SizedBox(width: 12),
                            openButton,
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimalist 3-step vertical posture indicator (`┃ • •`) encoding review state
/// without heavy color fills.
class _VerticalPostureMeter extends StatelessWidget {
  final ReviewOverallState overallState;
  final Color activeColor;
  final Color inactiveColor;

  const _VerticalPostureMeter({
    required this.overallState,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final int activeIndex = switch (overallState) {
      ReviewOverallState.reviewRecommended => 0,
      ReviewOverallState.insufficientEvidence => 1,
      ReviewOverallState.noConcern => 2,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (index) {
        final bool isActive = index == activeIndex;
        return Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 4.5),
          child: Container(
            width: 4.5,
            height: isActive ? 22 : 4.5,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
