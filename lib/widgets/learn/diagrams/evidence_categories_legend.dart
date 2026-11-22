import 'package:flutter/material.dart';

import '../../../core/theme/enprive_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../review/evidence_category_style.dart';

/// Displays Enprive's five evidence categories using the exact icons, hues,
/// order, and localized names from [EvidenceCategoryStyle] as shown on the
/// Review screen.
class EvidenceCategoriesLegend extends StatelessWidget {
  const EvidenceCategoriesLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final styles = [
      for (final category in EvidenceCategoryStyle.order)
        EvidenceCategoryStyle.of(context, category),
    ];

    final semanticLabel = l10n.learnDiagramCategoriesSemantic(
      l10n.categoryDataCollection,
      l10n.categorySharing,
      l10n.categoryTracking,
      l10n.categoryRetention,
      l10n.categoryParentalControls,
    );

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(EnpriveRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.learnDiagramCategoriesTitle,
                style: m3e.typography.emphasized.titleSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final style in styles)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: style.color.container,
                        borderRadius: BorderRadius.circular(EnpriveRadii.chip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            style.icon,
                            size: 16,
                            color: style.color.onContainer,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              style.label,
                              style: m3e.typography.emphasized.labelMedium
                                  .copyWith(color: style.color.onContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.learnDiagramCategoriesNote,
                style: m3e.typeScale.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
