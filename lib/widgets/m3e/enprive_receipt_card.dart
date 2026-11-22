import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';
import '../../l10n/app_localizations.dart';
import '../review/enprive_state_chip.dart';
import 'enprive_material_card_surface.dart';

/// Rich card for a saved [PolicyReviewReceipt] on Receipts and the Check
/// tab's "Recently reviewed" list.
///
/// The whole card opens the receipt. It shows the app initial, title, source
/// and date, the shared review-state chip, and the finding count as a large
/// numeral (a count of evidence, never a score). Delete lives in the overflow
/// menu (and the swipe gesture on Receipts), not on the card face.
///
/// [openLabel] is the TalkBack hint for opening the receipt. [findingsLabel],
/// [verifiedLabel] and [deviceObservedLabel] are kept for source
/// compatibility; the card shows the localized finding count instead.
class EnpriveReceiptCard extends StatelessWidget {
  final PolicyReviewReceipt receipt;
  final String stateBadgeLabel;
  final String metaLine;
  final String openLabel;
  final String deleteTooltip;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;
  final String? findingsLabel;
  final String? verifiedLabel;
  final String? deviceObservedLabel;
  final BorderRadius borderRadius;

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
    this.deviceObservedLabel,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  /// Key of the overflow menu button.
  static const Key overflowKey = Key('receipt_card_overflow');

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    final findingsCount = receipt.findings.length;
    // Proof layers stay separate: quotes matched in the policy versus
    // observations made on this phone.
    final evidenceLine = [
      if (receipt.sourceMatchedCount > 0)
        l10n.quotesVerifiedCount(receipt.sourceMatchedCount),
      if (receipt.deviceObservedCount > 0)
        l10n.observedOnPhoneCount(receipt.deviceObservedCount),
    ].join(' · ');
    final title = receipt.subjectTitle.trim();
    final initial = title.isEmpty ? '?' : title.characters.first.toUpperCase();

    final card = EnpriveMaterialCardSurface(
      backgroundColor: scheme.surfaceContainer,
      borderRadius: borderRadius,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 4, 16),
      onPressed: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                initial,
                style: m3e.typeScale.titleLarge.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: m3e.typeScale.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metaLine,
                  style: m3e.typeScale.bodyMedium.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (evidenceLine.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    evidenceLine,
                    style: m3e.typeScale.bodyMedium.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                EnpriveStateChip(
                  state: receipt.overallState,
                  label: stateBadgeLabel,
                  dense: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$findingsCount',
                style: m3e.typography.emphasized.headlineMedium.copyWith(
                  color: scheme.onSurface,
                  height: 1.1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                l10n.findingsCountUnit(findingsCount),
                style: m3e.typeScale.labelMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (onDelete != null)
            PopupMenuButton<String>(
              key: overflowKey,
              tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
              icon: Icon(
                LucideIcons.ellipsisVertical,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              onSelected: (_) => onDelete!(),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.trash2,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Flexible(child: Text(deleteTooltip)),
                    ],
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );

    return Semantics(
      onTapHint: openLabel,
      customSemanticsActions: onDelete == null
          ? null
          : {CustomSemanticsAction(label: deleteTooltip): onDelete!},
      child: card,
    );
  }
}
