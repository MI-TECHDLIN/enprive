import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_colors.dart';
import '../l10n/app_localizations.dart';
import '../l10n/enprive_languages.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_duotone_icon.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/private_readiness_sheet.dart';

/// Settings & Private Analysis Readiness Screen crafted from Brilliant B19
/// (`b19-permission-prime.png` — Deni peeking over a mock status card) and
/// Brilliant B3 (`b03-question-cards.png` — soft grey choice cards).
class SettingsScreen extends StatefulWidget {
  final HybridAiBridge bridge;
  final DeviceCapability? capability;
  final ExplanationDepth explanationDepth;
  final Locale currentLocale;
  final int savedReceiptsCount;
  final ValueChanged<ExplanationDepth> onExplanationDepthChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onRefreshCapability;
  final VoidCallback onClearAllReceipts;
  final VoidCallback? onReplayOnboarding;

  const SettingsScreen({
    super.key,
    required this.bridge,
    required this.capability,
    required this.explanationDepth,
    required this.currentLocale,
    required this.savedReceiptsCount,
    required this.onExplanationDepthChanged,
    required this.onLocaleChanged,
    required this.onRefreshCapability,
    required this.onClearAllReceipts,
    this.onReplayOnboarding,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isCheckingModel = false;
  bool? _lastCheckWasOnDeviceReady;

  Future<void> _handleCheckOrPrepareModel() async {
    if (_isCheckingModel) return;
    setState(() => _isCheckingModel = true);
    final updated = await PrivateReadinessSheet.show(
      context,
      bridge: widget.bridge,
      initialCapability: widget.capability,
    );
    widget.onRefreshCapability();
    if (!mounted) return;
    setState(() {
      _isCheckingModel = false;
      if (updated != null) {
        _lastCheckWasOnDeviceReady =
            updated.isSupported &&
            updated.modelStatus == ModelDownloadStatus.available;
      }
    });
  }

  Future<void> _confirmClearReceipts(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: EnpriveColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.confirmClearReceiptsTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.confirmClearReceiptsBody(widget.savedReceiptsCount),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: EnpriveColors.ctaInk,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.btnClear),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onClearAllReceipts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeLang = enpriveLanguageByCode(widget.currentLocale.languageCode);
    final cap = widget.capability;
    final isReady =
        cap?.isSupported == true &&
        cap?.modelStatus == ModelDownloadStatus.available;
    final effectiveReady = _lastCheckWasOnDeviceReady ?? isReady;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),

            // 1. Brilliant B19 Pattern: Deni peeking over a clean status card
            Center(
              child: Column(
                children: [
                  Transform.translate(
                    offset: const Offset(0, 10),
                    child: DeniAnimatedMascot(
                      size: 72,
                      pose: _isCheckingModel
                          ? DeniPose.thinking
                          : (isReady ? DeniPose.celebrating : DeniPose.idle),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: EnpriveColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: EnpriveColors.ink.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: EnpriveColors.chipOnDeviceBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const EnpriveDuotoneIcon(
                                Ph.shield_check_duotone,
                                color: EnpriveColors.tealStrong,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.privateAnalysisTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: EnpriveColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    effectiveReady
                                        ? l10n.onDeviceReadyMsg
                                        : l10n.localScannerProtectedMsg,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: EnpriveColors.inkSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        EnpriveTactileButton(
                          label: _isCheckingModel
                              ? l10n.statusChecking
                              : l10n.btnCheckReadiness,
                          isSecondary: true,
                          onPressed: _isCheckingModel
                              ? null
                              : _handleCheckOrPrepareModel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 2. Brilliant B3 Pattern: Soft Choice Cards for Explanation Style
            Text(
              l10n.howShouldDeniExplain,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: EnpriveColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ExplanationDepth.values.map((depth) {
                final isSelected = widget.explanationDepth == depth;
                final (iconSvg, label) = switch (depth) {
                  ExplanationDepth.simple => (
                    Ph.sparkle_duotone,
                    l10n.depthQuick,
                  ),
                  ExplanationDepth.balanced => (
                    Ph.scales_duotone,
                    l10n.depthBalanced,
                  ),
                  ExplanationDepth.detailed => (
                    Ph.book_open_duotone,
                    l10n.depthFull,
                  ),
                };
                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: depth != ExplanationDepth.detailed ? 10.0 : 0,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => widget.onExplanationDepthChanged(depth),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? EnpriveColors.surface
                              : EnpriveColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? EnpriveColors.teal
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? EnpriveColors.chipOnDeviceBg
                                    : EnpriveColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: EnpriveDuotoneIcon(
                                iconSvg,
                                size: 20,
                                color: isSelected
                                    ? EnpriveColors.tealStrong
                                    : EnpriveColors.inkSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? EnpriveColors.ink
                                    : EnpriveColors.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // 3. Clean Minimal Preferences Group
            Text(
              l10n.preferencesSection,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: EnpriveColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: EnpriveColors.surface,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    onTap: () async {
                      final picked = await EnpriveLanguagePickerSheet.show(
                        context,
                        currentLocale: widget.currentLocale,
                      );
                      if (picked != null) {
                        widget.onLocaleChanged(picked);
                      }
                    },
                    title: Text(
                      l10n.languageTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: EnpriveColors.ink,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: EnpriveColors.chipOnDeviceBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            activeLang.nativeName,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: EnpriveColors.tealStrong,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: EnpriveColors.inkSecondary,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: EnpriveColors.ink.withValues(alpha: 0.06),
                  ),
                  if (widget.onReplayOnboarding != null) ...[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      onTap: widget.onReplayOnboarding,
                      title: Text(
                        l10n.meetDeniGuide,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: EnpriveColors.ink,
                        ),
                      ),
                      trailing: const Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: EnpriveColors.inkSecondary,
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      color: EnpriveColors.ink.withValues(alpha: 0.06),
                    ),
                  ],
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    title: Text(
                      l10n.clearSavedReceiptsCount(widget.savedReceiptsCount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: EnpriveColors.ink,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: widget.savedReceiptsCount == 0
                          ? null
                          : () => _confirmClearReceipts(context, l10n),
                      child: Text(
                        l10n.btnClear,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: widget.savedReceiptsCount == 0
                              ? EnpriveColors.inkDisabled
                              : EnpriveColors.stateReviewRecommendedFg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
