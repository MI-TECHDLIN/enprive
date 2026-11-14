import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/enprive_languages.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_duotone_icon.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/private_readiness_sheet.dart';
import 'design_system_preview_screen.dart';

/// Settings & Private Analysis Readiness Screen with Material 3 Expressive
/// token integration, System/Light/Dark appearance control, and 3-tier Deni LOD.
class SettingsScreen extends StatefulWidget {
  final HybridAiBridge bridge;
  final DeviceCapability? capability;
  final ExplanationDepth explanationDepth;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final int savedReceiptsCount;
  final ValueChanged<ExplanationDepth> onExplanationDepthChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final VoidCallback onRefreshCapability;
  final VoidCallback onClearAllReceipts;
  final VoidCallback? onReplayOnboarding;

  const SettingsScreen({
    super.key,
    required this.bridge,
    required this.capability,
    required this.explanationDepth,
    required this.currentLocale,
    this.currentThemeMode = ThemeMode.system,
    required this.savedReceiptsCount,
    required this.onExplanationDepthChanged,
    required this.onLocaleChanged,
    this.onThemeModeChanged,
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
    final surfaces = context.enpriveSurfaces;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surfaces.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.xl),
          side: BorderSide(color: surfaces.hairlineBorder),
        ),
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
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final activeLang = enpriveLanguageByCode(
            widget.currentLocale.languageCode,
          );
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final surfaces = context.enpriveSurfaces;
          final semantics = context.enpriveSemantics;

          final cap = widget.capability;
          final isReady =
              cap?.isSupported == true &&
              cap?.modelStatus == ModelDownloadStatus.available;
          final effectiveReady = _lastCheckWasOnDeviceReady ?? isReady;

          final prefRows = <Widget>[
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
                style: m3e.typeScale.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
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
                      color: semantics.onDevice.background,
                      borderRadius: BorderRadius.circular(EnpriveRadii.pill),
                      border: Border.all(color: semantics.onDevice.border),
                    ),
                    child: Text(
                      activeLang.nativeName,
                      style: m3e.typeScale.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: semantics.onDevice.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            if (widget.onReplayOnboarding != null)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                onTap: widget.onReplayOnboarding,
                title: Text(
                  l10n.meetDeniGuide,
                  style: m3e.typeScale.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                trailing: Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ListTile(
              key: const Key('open_design_system_preview_tile'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DesignSystemPreviewScreen(
                      currentThemeMode: widget.currentThemeMode,
                      onThemeModeChanged: widget.onThemeModeChanged,
                    ),
                  ),
                );
              },
              title: Text(
                'Theme & Deni LOD Preview',
                style: m3e.typeScale.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              trailing: Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              title: Text(
                l10n.clearSavedReceiptsCount(widget.savedReceiptsCount),
                style: m3e.typeScale.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
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
                        ? surfaces.disabledFg
                        : semantics.reviewRecommended.foreground,
                  ),
                ),
              ),
            ),
          ];

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsTitle,
                    style: m3e.typography.emphasized.headlineMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Deni Companion Status M3ECard (LOD 2: 76dp standard companion)
                  Center(
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 10),
                          child: DeniAnimatedMascot(
                            size: 76,
                            pose: _isCheckingModel
                                ? DeniPose.thinking
                                : (effectiveReady
                                      ? DeniPose.idle
                                      : DeniPose.support),
                          ),
                        ),
                        M3ECard(
                          color: surfaces.card,
                          elevation: 0,
                          borderRadius: BorderRadius.circular(EnpriveRadii.xl),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: semantics.onDevice.background,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: semantics.onDevice.border,
                                      ),
                                    ),
                                    child: EnpriveDuotoneIcon(
                                      Ph.shield_check_duotone,
                                      color: semantics.onDevice.icon,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.privateAnalysisTitle,
                                          style: m3e.typeScale.titleMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: scheme.onSurface,
                                              ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          effectiveReady
                                              ? l10n.onDeviceReadyMsg
                                              : l10n.localScannerProtectedMsg,
                                          style: m3e.typeScale.bodySmall
                                              .copyWith(
                                                color: scheme.onSurfaceVariant,
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

                  // 2. Explanation Depth Selector (48dp+ accessible touch targets)
                  Text(
                    l10n.howShouldDeniExplain,
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
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
                            end: depth != ExplanationDepth.detailed
                                ? 10.0
                                : 0.0,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              EnpriveRadii.lg,
                            ),
                            onTap: () =>
                                widget.onExplanationDepthChanged(depth),
                            child: AnimatedContainer(
                              duration: context.motionTokens.effectiveDuration(
                                context,
                                context.motionTokens.effectsFast,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? surfaces.card
                                    : surfaces.cardMuted,
                                borderRadius: BorderRadius.circular(
                                  EnpriveRadii.lg,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? scheme.primary
                                      : surfaces.hairlineBorder,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? semantics.onDevice.background
                                          : surfaces.card,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: EnpriveDuotoneIcon(
                                      iconSvg,
                                      size: 20,
                                      color: isSelected
                                          ? semantics.onDevice.icon
                                          : scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: m3e.typeScale.labelLarge.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? scheme.onSurface
                                          : scheme.onSurfaceVariant,
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

                  // 3. Appearance (System / Light / Dark — Brand-Locked HCT)
                  Text(
                    'Appearance',
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final (index, entry) in [
                        (ThemeMode.system, LucideIcons.smartphone, 'System'),
                        (ThemeMode.light, LucideIcons.sun, 'Light'),
                        (ThemeMode.dark, LucideIcons.moon, 'Dark'),
                      ].indexed)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: index < 2 ? 10.0 : 0.0,
                            ),
                            child: InkWell(
                              key: Key('theme_mode_option_${entry.$1.name}'),
                              borderRadius: BorderRadius.circular(
                                EnpriveRadii.lg,
                              ),
                              onTap: () =>
                                  widget.onThemeModeChanged?.call(entry.$1),
                              child: AnimatedContainer(
                                duration: context.motionTokens
                                    .effectiveDuration(
                                      context,
                                      context.motionTokens.effectsFast,
                                    ),
                                constraints: const BoxConstraints(
                                  minHeight: EnpriveSpacing.minTouchTarget,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.currentThemeMode == entry.$1
                                      ? surfaces.card
                                      : surfaces.cardMuted,
                                  borderRadius: BorderRadius.circular(
                                    EnpriveRadii.lg,
                                  ),
                                  border: Border.all(
                                    color: widget.currentThemeMode == entry.$1
                                        ? scheme.primary
                                        : surfaces.hairlineBorder,
                                    width: widget.currentThemeMode == entry.$1
                                        ? 2.0
                                        : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      entry.$2,
                                      size: 16,
                                      color: widget.currentThemeMode == entry.$1
                                          ? semantics.onDevice.icon
                                          : scheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        entry.$3,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: m3e.typeScale.labelLarge
                                            .copyWith(
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  widget.currentThemeMode ==
                                                      entry.$1
                                                  ? scheme.onSurface
                                                  : scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // 4. Preferences Group (M3E Segmented Containment)
                  Text(
                    l10n.preferencesSection,
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: prefRows.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final radius = EnpriveRadii.groupedCardRadius(
                        index: idx,
                        count: prefRows.length,
                      );
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: idx < prefRows.length - 1 ? 4.0 : 0.0,
                        ),
                        child: M3ECard(
                          color: surfaces.card,
                          elevation: 0,
                          borderRadius: radius,
                          padding: EdgeInsets.zero,
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: radius,
                            clipBehavior: Clip.antiAlias,
                            child: entry.value,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
