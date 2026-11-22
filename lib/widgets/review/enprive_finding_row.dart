import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';
import '../m3e/enprive_material_card_surface.dart';
import 'evidence_category_style.dart';

/// Proof layer of a finding, shown as icon plus words (never color alone).
IconData evidenceProofIcon(VerifiedFinding finding) {
  if (finding.isDeviceObserved) return LucideIcons.smartphone;
  if (finding.isSourceMatched) return LucideIcons.quote;
  if (finding.status == EvidenceStatus.interpretation) {
    return LucideIcons.lightbulb;
  }
  return LucideIcons.circleHelp;
}

/// One segmented summary row of the Review result findings list: category
/// icon well, title, one proof line, and an amber "Review" chip only for
/// findings that deserve a human look. The whole row opens the detail page.
class EnpriveFindingRow extends StatelessWidget {
  final VerifiedFinding finding;
  final int index;
  final int totalCount;
  final String proofLabel;
  final String? reviewChipLabel;
  final VoidCallback onTap;

  const EnpriveFindingRow({
    super.key,
    required this.finding,
    required this.index,
    required this.totalCount,
    required this.proofLabel,
    required this.onTap,
    this.reviewChipLabel,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final category = EvidenceCategoryStyle.of(context, finding.category);

    return EnpriveMaterialCardSurface(
      key: ValueKey<String>('finding_row_${finding.id}'),
      backgroundColor: scheme.surfaceContainer,
      borderRadius: EnpriveRadii.groupedCardRadius(
        index: index,
        count: totalCount,
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 14, 16, 14),
      onPressed: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: category.color.container,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                size: 20,
                color: category.color.onContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finding.title,
                  style: m3e.typeScale.titleMedium.copyWith(
                    color: scheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      evidenceProofIcon(finding),
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        proofLabel,
                        style: m3e.typeScale.bodyMedium.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (reviewChipLabel != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(6, 3, 8, 3),
              decoration: BoxDecoration(
                color: semantics.reviewRecommended.background,
                borderRadius: BorderRadius.circular(EnpriveRadii.chip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.eye,
                    size: 13,
                    color: semantics.reviewRecommended.icon,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reviewChipLabel!,
                    style: m3e.typeScale.labelMedium.copyWith(
                      color: semantics.reviewRecommended.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
