import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/enprive_theme.dart';
import '../../l10n/app_localizations.dart';
import '../enprive_tactile_button.dart';

/// User choices when closing an unsaved or modified privacy review draft.
enum UnsavedReviewExitDecision {
  save,
  discard,
  continueReviewing,
}

/// Calm Material 3 Expressive confirmation sheet presented when leaving an
/// unsaved review or a newly modified draft created from a historical receipt.
class UnsavedReviewExitSheet extends StatelessWidget {
  final bool isModifiedSavedDraft;

  const UnsavedReviewExitSheet({
    super.key,
    this.isModifiedSavedDraft = false,
  });

  static Future<UnsavedReviewExitDecision?> show(
    BuildContext context, {
    bool isModifiedSavedDraft = false,
  }) {
    return showModalBottomSheet<UnsavedReviewExitDecision>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnsavedReviewExitSheet(
        isModifiedSavedDraft: isModifiedSavedDraft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (sheetContext) {
          final l10n = AppLocalizations.of(sheetContext) ??
              lookupAppLocalizations(
                Localizations.maybeLocaleOf(sheetContext) ?? const Locale('en'),
              );
          final m3e = EnpriveM3ETheme.of(sheetContext);
          final scheme = m3e.colorScheme;
          final surfaces = sheetContext.enpriveSurfaces;
          final semantics = sheetContext.enpriveSemantics;

          return Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Material(
                color: surfaces.canvas,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                clipBehavior: Clip.antiAlias,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: semantics.onDevice.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: semantics.onDevice.border,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.bookmarkPlus,
                                size: 20,
                                color: semantics.onDevice.foreground,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.unsavedExitTitle,
                                    style: m3e
                                        .typography
                                        .emphasized
                                        .headlineSmall
                                        .copyWith(color: scheme.onSurface),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isModifiedSavedDraft
                                        ? l10n.unsavedExitModifiedBody
                                        : l10n.unsavedExitDraftBody,
                                    style: m3e.typeScale.bodyMedium.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        EnpriveTactileButton(
                          key: const Key('unsaved_exit_save_btn'),
                          label: l10n.btnSaveToReceipts,
                          onPressed: () => Navigator.of(
                            sheetContext,
                          ).pop(UnsavedReviewExitDecision.save),
                        ),
                        const SizedBox(height: 10),
                        EnpriveTactileButton(
                          key: const Key('unsaved_exit_discard_btn'),
                          label: l10n.unsavedExitDiscardBtn,
                          isSecondary: true,
                          onPressed: () => Navigator.of(
                            sheetContext,
                          ).pop(UnsavedReviewExitDecision.discard),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            key: const Key('unsaved_exit_continue_btn'),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(64, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onPressed: () => Navigator.of(
                              sheetContext,
                            ).pop(UnsavedReviewExitDecision.continueReviewing),
                            child: Text(
                              l10n.unsavedExitContinueBtn,
                              style: m3e.typeScale.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
