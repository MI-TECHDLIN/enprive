import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';
import '../../l10n/app_localizations.dart';

/// The single color, icon and name each evidence category owns everywhere
/// (icon well, evidence ring arc, Learn tile). Color marks the category,
/// never severity.
@immutable
class EvidenceCategoryStyle {
  final FindingCategory category;
  final EnpriveStaticColor color;
  final IconData icon;
  final String label;

  const EvidenceCategoryStyle({
    required this.category,
    required this.color,
    required this.icon,
    required this.label,
  });

  /// Ring and legend order.
  static const List<FindingCategory> order = [
    FindingCategory.dataCollection,
    FindingCategory.sharing,
    FindingCategory.tracking,
    FindingCategory.retention,
    FindingCategory.parentalConsent,
  ];

  static EvidenceCategoryStyle of(
    BuildContext context,
    FindingCategory category,
  ) {
    final colors = context.categoryColors;
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    return switch (category) {
      FindingCategory.dataCollection => EvidenceCategoryStyle(
        category: category,
        color: colors.dataCollection,
        icon: LucideIcons.database,
        label: l10n.categoryDataCollection,
      ),
      FindingCategory.sharing => EvidenceCategoryStyle(
        category: category,
        color: colors.sharing,
        icon: LucideIcons.share2,
        label: l10n.categorySharing,
      ),
      FindingCategory.tracking => EvidenceCategoryStyle(
        category: category,
        color: colors.tracking,
        icon: LucideIcons.mapPin,
        label: l10n.categoryTracking,
      ),
      FindingCategory.retention => EvidenceCategoryStyle(
        category: category,
        color: colors.retention,
        icon: LucideIcons.archive,
        label: l10n.categoryRetention,
      ),
      FindingCategory.parentalConsent => EvidenceCategoryStyle(
        category: category,
        color: colors.parentalConsent,
        icon: LucideIcons.users,
        label: l10n.categoryParentalControls,
      ),
    };
  }

  /// Counts findings per category, in [order], skipping empty categories.
  static Map<FindingCategory, int> countsOf(
    Iterable<VerifiedFinding> findings,
  ) {
    final counts = <FindingCategory, int>{};
    for (final finding in findings) {
      counts.update(finding.category, (n) => n + 1, ifAbsent: () => 1);
    }
    return {
      for (final category in order)
        if ((counts[category] ?? 0) > 0) category: counts[category]!,
    };
  }
}
