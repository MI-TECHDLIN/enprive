import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';
import 'enprive_material_card_surface.dart';

/// Tactile Material 3 Expressive segmented finding card inspired by the
/// "Music OS" and `_ (3).jpeg` boards.
///
/// Combines segmented outer/inner corner radii (`22dp` outer / `6dp` inner
/// seam), circular tabular index badge, AAA severity & quote-verification
/// indicators, embedded Warm Paper / Slate quotation well (`3.0dp` left spine),
/// and strict single-action compliance (`onTapCard` OR `onAskDeni`, never both).
class EnpriveFindingM3ECard extends StatelessWidget {
  final VerifiedFinding finding;
  final int index;
  final int totalCount;
  final String? sha256Preview;
  final String askDeniLabel;
  final VoidCallback? onAskDeni;
  final VoidCallback? onTapCard;
  final String? categoryLabel;
  final String? severityLabel;
  final String? verificationLabel;
  final String? inspectHintLabel;

  const EnpriveFindingM3ECard({
    super.key,
    required this.finding,
    required this.index,
    required this.totalCount,
    this.sha256Preview,
    this.askDeniLabel = 'Ask Deni · Why this matters',
    this.onAskDeni,
    this.onTapCard,
    this.categoryLabel,
    this.severityLabel,
    this.verificationLabel,
    this.inspectHintLabel,
  }) : assert(
         onTapCard == null || onAskDeni == null,
         'EnpriveFindingM3ECard follows android-design single-action rule: supply either onTapCard or onAskDeni, never both.',
       );

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;
    final typeExt = context.enpriveType;

    final SemanticColorPair severityPair = switch (finding.severity) {
      FindingSeverity.high => semantics.highConcern,
      FindingSeverity.medium => semantics.reviewRecommended,
      FindingSeverity.low => semantics.onDevice,
    };

    final bool isSourceMatched = finding.isSourceMatched;
    final bool isDeviceObserved = finding.isDeviceObserved;
    final SemanticColorPair verifyPair = isSourceMatched
        ? semantics.onDevice
        : (isDeviceObserved ? semantics.inCloud : semantics.unknown);

    final BorderRadius cardRadius = EnpriveRadii.groupedCardRadius(
      index: index,
      count: totalCount,
      outer: 22,
      inner: 6,
    );

    final String? effectiveSeverityText =
        severityLabel ??
        (onTapCard == null
            ? switch (finding.severity) {
                FindingSeverity.high => 'HIGH CONCERN',
                FindingSeverity.medium => 'REVIEW ADVISED',
                FindingSeverity.low => 'LOW',
              }
            : null);

    final String effectiveVerificationText =
        verificationLabel ??
        (isSourceMatched
            ? 'QUOTE MATCHED'
            : (isDeviceObserved ? 'DEVICE OBSERVED' : 'UNVERIFIED'));

    final bool hasActionCardTap = onTapCard != null;

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.elevated,
      backgroundColor: surfaces.card,
      borderRadius: cardRadius,
      lipHeight: hasActionCardTap ? 3.5 : 2.5,
      padding: const EdgeInsets.all(16),
      onPressed: onTapCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Circular index badge + category pill + open affordance
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: severityPair.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: severityPair.border),
                ),
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: m3e.typography.emphasized.labelMedium.copyWith(
                    color: severityPair.foreground,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: (categoryLabel != null &&
                          categoryLabel!.trim().isNotEmpty)
                      ? _MetaPill(
                          label: categoryLabel!,
                          background: surfaces.cardMuted,
                          foreground: scheme.onSurfaceVariant,
                          borderColor: surfaces.hairlineBorder,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (hasActionCardTap) ...[
                const SizedBox(width: 6),
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: surfaces.cardMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.arrowUpRight,
                    size: 15,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (effectiveSeverityText != null &&
                  effectiveSeverityText.trim().isNotEmpty)
                _MetaPill(
                  label: effectiveSeverityText,
                  background: severityPair.background,
                  foreground: severityPair.foreground,
                  borderColor: severityPair.border,
                ),
              _MetaPill(
                icon: isSourceMatched
                    ? LucideIcons.circleCheck
                    : (isDeviceObserved
                          ? LucideIcons.smartphone
                          : LucideIcons.circleHelp),
                label: effectiveVerificationText,
                background: verifyPair.background,
                foreground: verifyPair.foreground,
                borderColor: verifyPair.border,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Emphasized finding title & plain-English explanation
          Text(
            finding.title,
            style: m3e.typography.emphasized.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            finding.explanation,
            style: m3e.typeScale.bodyMedium.copyWith(
              height: 1.44,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Embedded Warm Paper / Obsidian archival quotation strip
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: surfaces.quoteSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: surfaces.hairlineBorder),
              ),
              child: Stack(
                children: [
                  PositionedDirectional(
                    top: 11,
                    bottom: 11,
                    start: 10,
                    width: 3.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isSourceMatched
                            ? severityPair.icon
                            : (isDeviceObserved
                                  ? semantics.inCloud.icon
                                  : surfaces.strongBorder),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      21,
                      11,
                      12,
                      11,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDeviceObserved) ...[
                          Text(
                            finding.exactExcerpt.trim().isNotEmpty
                                ? finding.exactExcerpt
                                : finding.whatAndroidReports,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: m3e.typeScale.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                              height: 1.38,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            finding.whatPolicySays,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: m3e.typeScale.labelSmall.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '“${finding.exactExcerpt}”',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: typeExt.policyQuotation.copyWith(
                              fontSize: 13.5,
                              color: scheme.onSurface,
                            ),
                          ),
                          if (sha256Preview != null &&
                              sha256Preview!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Snapshot digest · FNV-1a 64-bit · $sha256Preview',
                              style: typeExt.sha256Hash.copyWith(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (inspectHintLabel != null &&
              inspectHintLabel!.trim().isNotEmpty &&
              hasActionCardTap) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  LucideIcons.fileSearch,
                  size: 14,
                  color: scheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  inspectHintLabel!,
                  style: m3e.typography.emphasized.labelSmall.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ],

          if (onAskDeni != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: M3EButton.tonal(
                size: M3EButtonSize.sm,
                icon: const Icon(LucideIcons.messageCircleQuestionMark, size: 17),
                label: Text(askDeniLabel),
                onPressed: onAskDeni,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color borderColor;

  const _MetaPill({
    this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: m3e.typography.emphasized.labelSmall.copyWith(
              color: foreground,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
