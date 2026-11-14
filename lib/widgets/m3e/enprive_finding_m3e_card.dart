import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';

/// Expressive segmented or standalone finding card inspired by the "Music OS"
/// and `_ (3).jpeg` reference boards.
///
/// Features:
/// - Segmented outer/inner radii via [EnpriveRadii.groupedCardRadius] when part
///   of a vertical finding group.
/// - Circular index badge (`01`, `02`) in tabular numerals.
/// - AAA-contrasted semantic severity pill (`Review Recommended`, `High Concern`,
///   `No Concern Identified`, `Unverified Claim`).
/// - Deterministic source-alignment badge (`QUOTE MATCHED` vs `UNVERIFIED`).
/// - Embedded verbatim quotation callout (`SourceSerif4` italic) + optional
///   `SHA-256` snippet (`JetBrainsMono`).
/// - Tactile "Ask Deni · Why this matters" M3E action button.
class EnpriveFindingM3ECard extends StatelessWidget {
  final VerifiedFinding finding;
  final int index;
  final int totalCount;
  final String? sha256Preview;
  final String askDeniLabel;
  final VoidCallback? onAskDeni;

  const EnpriveFindingM3ECard({
    super.key,
    required this.finding,
    required this.index,
    required this.totalCount,
    this.sha256Preview,
    this.askDeniLabel = 'Ask Deni · Why this matters',
    this.onAskDeni,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;
    final typeExt = context.enpriveType;

    final isVerified = finding.isVerified;

    final severityPair = !isVerified
        ? semantics.highConcern
        : switch (finding.severity) {
            FindingSeverity.high => semantics.highConcern,
            FindingSeverity.medium => semantics.reviewRecommended,
            FindingSeverity.low => semantics.noConcern,
          };

    final severityLabel = !isVerified
        ? 'Unverified Claim'
        : switch (finding.severity) {
            FindingSeverity.high => 'High Concern',
            FindingSeverity.medium => 'Review Recommended',
            FindingSeverity.low => 'Low / Informational',
          };

    final borderRadius = totalCount > 1
        ? EnpriveRadii.groupedCardRadius(index: index, count: totalCount)
        : BorderRadius.circular(24);

    final indexBadgeText = (index + 1).toString().padLeft(2, '0');

    return M3ECard(
      color: surfaces.card,
      borderRadius: borderRadius,
      border: BorderSide(color: surfaces.hairlineBorder),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Circular index badge + Severity pill + Source verification badge
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  indexBadgeText,
                  style: m3e.typography.emphasized.labelMedium.copyWith(
                    color: scheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: severityPair.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: severityPair.border.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  severityLabel,
                  style: m3e.typography.emphasized.labelSmall.copyWith(
                    color: severityPair.foreground,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isVerified
                      ? semantics.noConcern.background
                      : semantics.highConcern.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified
                          ? LucideIcons.fileCheck2
                          : LucideIcons.triangleAlert,
                      size: 13,
                      color: isVerified
                          ? semantics.noConcern.foreground
                          : semantics.highConcern.foreground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'QUOTE MATCHED' : 'UNVERIFIED',
                      style: m3e.typography.emphasized.labelSmall.copyWith(
                        fontSize: 10.5,
                        color: isVerified
                            ? semantics.noConcern.foreground
                            : semantics.highConcern.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Plain-Language Explanation
          Text(
            finding.title,
            style: m3e.typography.emphasized.titleMedium.copyWith(
              color: scheme.onSurface,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            finding.explanation,
            style: m3e.typeScale.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),

          // Verbatim Evidence Quote Callout
          if (finding.exactExcerpt.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaces.quoteCallout,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: surfaces.hairlineBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '“${finding.exactExcerpt.trim()}”',
                    style: typeExt.policyQuotation,
                  ),
                  if (sha256Preview != null && sha256Preview!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'SHA-256 · $sha256Preview',
                      style: typeExt.sha256Hash,
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (onAskDeni != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: M3EButton.tonal(
                onPressed: onAskDeni,
                size: M3EButtonSize.sm,
                icon: const Icon(LucideIcons.sparkles, size: 16),
                label: Text(askDeniLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
