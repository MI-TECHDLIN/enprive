import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_colors.dart';
import '../l10n/app_localizations.dart';
import '../l10n/enprive_languages.dart';
import 'enprive_duotone_icon.dart';

/// Shared bottom sheet allowing the user to pick any of Enprive's 12 local &
/// Cloud Gemini languages.
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
      backgroundColor: EnpriveColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => EnpriveLanguagePickerSheet(selectedLocale: currentLocale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(selectedLocale);
    final selectedCode = enpriveLanguageByCode(selectedLocale.languageCode).code;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.78;

    return SafeArea(
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
                    color: EnpriveColors.ink.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: EnpriveColors.chipOnDeviceBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const EnpriveDuotoneIcon(
                      Ph.translate_duotone,
                      color: EnpriveColors.tealStrong,
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
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.languageSubtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: EnpriveColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.tooltipClose,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Material(
                  color: EnpriveColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: kEnpriveLanguages.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      color: EnpriveColors.ink.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (context, index) {
                      final option = kEnpriveLanguages[index];
                      final isSelected = option.code == selectedCode;

                      return ListTile(
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
                                ? EnpriveColors.chipOnDeviceBg
                                : EnpriveColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            option.code.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? EnpriveColors.tealStrong
                                  : EnpriveColors.inkSecondary,
                            ),
                          ),
                        ),
                        title: Text(
                          option.nativeName,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: EnpriveColors.ink,
                          ),
                        ),
                        subtitle: option.nativeName == option.englishName
                            ? null
                            : Text(
                                option.englishName,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: EnpriveColors.inkSecondary,
                                ),
                              ),
                        trailing: isSelected
                            ? const Icon(
                                LucideIcons.circleCheck,
                                color: EnpriveColors.tealStrong,
                                size: 20,
                              )
                            : const SizedBox(width: 20),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
