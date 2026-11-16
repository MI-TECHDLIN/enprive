import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/enprive_languages.dart';

/// Shared Material 3 Expressive bottom sheet allowing the user to pick any of
/// Enprive's 12 local & Cloud Gemini languages.
class EnpriveLanguagePickerSheet extends StatelessWidget {
  final Locale selectedLocale;

  const EnpriveLanguagePickerSheet({
    super.key,
    required this.selectedLocale,
  });

  static Future<Locale?> show(
    BuildContext context, {
    required Locale currentLocale,
  }) {
    return showModalBottomSheet<Locale>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EnpriveLanguagePickerSheet(selectedLocale: currentLocale),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context) ??
              lookupAppLocalizations(selectedLocale);
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final semantics = context.enpriveSemantics;
          final surfaces = context.enpriveSurfaces;

          final selectedCode =
              enpriveLanguageByCode(selectedLocale.languageCode).code;
          final maxSheetHeight = MediaQuery.of(context).size.height * 0.78;

          return Material(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: semantics.onDevice.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      LucideIcons.languages,
                      color: semantics.onDevice.foreground,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.chooseLanguage,
                          style: m3e.typography.emphasized.titleLarge.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.languageSubtitle,
                          style: m3e.typeScale.bodySmall.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.tooltipClose,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: kEnpriveLanguages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 3),
                  itemBuilder: (context, index) {
                    final option = kEnpriveLanguages[index];
                    final isSelected = option.code == selectedCode;
                    final radius = EnpriveRadii.groupedCardRadius(
                      index: index,
                      count: kEnpriveLanguages.length,
                      outer: 20,
                      inner: 4,
                    );

                    return Material(
                      color: isSelected
                          ? semantics.onDevice.background
                          : surfaces.card,
                      borderRadius: radius,
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4,
                        ),
                        onTap: () => Navigator.pop(context, option.locale),
                        leading: Container(
                          width: 42,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scheme.primary
                                : scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            option.code.toUpperCase(),
                            style: m3e.typography.emphasized.labelSmall.copyWith(
                              color: isSelected
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        title: Text(
                          option.nativeName,
                          style: m3e.typography.emphasized.bodyLarge.copyWith(
                            color: isSelected
                                ? semantics.onDevice.foreground
                                : scheme.onSurface,
                          ),
                        ),
                        subtitle: option.nativeName == option.englishName
                            ? null
                            : Text(
                                option.englishName,
                                style: m3e.typeScale.bodySmall.copyWith(
                                  color: isSelected
                                      ? semantics.onDevice.foreground
                                          .withValues(alpha: 0.85)
                                      : scheme.onSurfaceVariant,
                                ),
                              ),
                        trailing: isSelected
                            ? Icon(
                                LucideIcons.circleCheck,
                                color: semantics.onDevice.foreground,
                                size: 20,
                              )
                            : const SizedBox(width: 20),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
          );
        },
      ),
    );
  }
}
