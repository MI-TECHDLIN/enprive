import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/enprive_languages.dart';
import '../services/platform/companion_bridge.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_duotone_icon.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/m3e/enprive_m3e_components.dart';
import '../widgets/private_readiness_sheet.dart';

/// Settings & Private Analysis Readiness Screen with Material 3 Expressive
/// token integration, System/Light/Dark appearance control, and 3-tier Deni LOD.
class SettingsScreen extends StatefulWidget {
  final HybridAiBridge bridge;
  final CompanionBridge? companionBridge;
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
  final VoidCallback? onOpenCompanion;
  final bool showAppBar;

  const SettingsScreen({
    super.key,
    required this.bridge,
    this.companionBridge,
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
    this.onOpenCompanion,
    this.showAppBar = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _isCheckingModel = false;
  bool? _lastCheckWasOnDeviceReady;
  UsageAccessState _usageAccessState = UsageAccessState.denied;
  QuickSettingsTileStatus? _tileStatus;

  CompanionBridge get _companion =>
      widget.companionBridge ?? CompanionBridge();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshCompanionStatuses());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshCompanionStatuses());
    }
  }

  Future<void> _refreshCompanionStatuses() async {
    final access = await _companion.checkUsageAccess();
    final tile = await _companion.getQuickSettingsTileStatus();
    if (!mounted) return;
    setState(() {
      _usageAccessState = access.status;
      _tileStatus = tile;
    });
  }

  Future<void> _handleTileAction(BuildContext context) async {
    final status = _tileStatus ?? await _companion.getQuickSettingsTileStatus();
    if (!context.mounted) return;
    if (status.isTileAdded) {
      _showQuickSettingsInstructionsDialog(
        context,
        title: 'Enprive Check is ready in Quick Settings',
        body:
            'Swipe down twice from the top of your screen and tap "Enprive Check" anytime you want Deni to explain an app\'s permissions.',
      );
      return;
    }
    if (!status.canRequestDirectAdd || status.hasDeclinedBefore) {
      _showQuickSettingsInstructionsDialog(
        context,
        title: 'Add Enprive Check manually',
        body:
            '1. Swipe down twice from the top of your Android screen to open Quick Settings.\n'
            '2. Tap the Edit (pencil) button.\n'
            '3. Find "Enprive Check" and drag it into your active Quick Settings tiles.',
      );
      return;
    }

    final outcome = await _companion.requestQuickSettingsTile();
    await _refreshCompanionStatuses();
    if (!context.mounted) return;

    final note = switch (outcome) {
      TileAddOutcome.tileAdded =>
        'Enprive Check added to your Quick Settings tray.',
      TileAddOutcome.alreadyAdded =>
        'Enprive Check is already in your Quick Settings tray.',
      TileAddOutcome.declined =>
        'Request dismissed. Enprive won\'t ask again unless you choose Edit in Quick Settings.',
      TileAddOutcome.manualRequired =>
        'Swipe down Quick Settings, tap Edit, and drag Enprive Check into your tiles.',
      TileAddOutcome.failed || TileAddOutcome.unavailable =>
        'System prompt unavailable here; you can drag Enprive Check manually from Quick Settings Edit.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(note), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openUsageAccessFlow(BuildContext context) async {
    final opened = await _companion.openUsageAccessSettings();
    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Usage Access Settings on this device.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showQuickSettingsInstructionsDialog(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final surfaces = context.enpriveSurfaces;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surfaces.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.xl),
          side: BorderSide(color: surfaces.hairlineBorder),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

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

          final scrollBody = SafeArea(
            top: !widget.showAppBar,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    widget.showAppBar ? 8 : 12,
                    20,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.showAppBar) ...[
                        Text(
                          l10n.settingsTitle,
                          style: m3e.typography.emphasized.headlineMedium
                              .copyWith(color: scheme.onSurface),
                        ),
                        const SizedBox(height: 20),
                      ],

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
                        EnpriveMaterialCardSurface(
                          variant: EnpriveCardVariant.elevated,
                          backgroundColor: surfaces.card,
                          borderRadius: BorderRadius.circular(EnpriveRadii.xl),
                          lipHeight: 3.0,
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
                      final (iconData, label) = switch (depth) {
                        ExplanationDepth.simple => (
                          LucideIcons.sparkles,
                          l10n.depthQuick,
                        ),
                        ExplanationDepth.balanced => (
                          LucideIcons.scale,
                          l10n.depthBalanced,
                        ),
                        ExplanationDepth.detailed => (
                          LucideIcons.bookOpen,
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
                          child: EnpriveBentoChoiceCard.compactOption(
                            title: label,
                            icon: iconData,
                            selected: isSelected,
                            onPressed: () =>
                                widget.onExplanationDepthChanged(depth),
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
                            child: EnpriveBentoChoiceCard.compactOption(
                              key: Key('theme_mode_option_${entry.$1.name}'),
                              title: entry.$3,
                              icon: entry.$2,
                              selected: widget.currentThemeMode == entry.$1,
                              onPressed: () =>
                                  widget.onThemeModeChanged?.call(entry.$1),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // 4. Preferences Group (M3E Tactile Segmented Containment)
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
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: idx < prefRows.length - 1 ? 4.0 : 0.0,
                        ),
                        child: EnpriveSegmentedCardTile(
                          index: idx,
                          totalCount: prefRows.length,
                          lipHeight: 2.0,
                          padding: EdgeInsets.zero,
                          child: Material(
                            color: Colors.transparent,
                            child: entry.value,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // 5. Connect Enprive to Quick Settings & Optional Usage Access
                  Text(
                    'Connect Enprive to Quick Settings',
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add Enprive Check to your Android Quick Settings panel so you can ask Deni about applications without leaving what you\'re doing.',
                    style: m3e.typeScale.bodySmall.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildCompanionSetupCards(
                    context,
                    m3e,
                    scheme,
                    semantics,
                  ),
                    ],
                  ),
                ),
              ),
            ),
          );

          if (!widget.showAppBar) {
            return scrollBody;
          }

          return Scaffold(
            backgroundColor: scheme.surface,
            appBar: AppBar(
              leading: IconButton(
                key: const Key('settings_back_btn'),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: Icon(LucideIcons.arrowLeft, color: scheme.onSurface),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(
                l10n.settingsTitle,
                style: m3e.typeScale.titleLarge.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            body: scrollBody,
          );
        },
      ),
    );
  }

  List<Widget> _buildCompanionSetupCards(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSemanticColors semantics,
  ) {
    final tile = _tileStatus;
    final tileLabel = (tile?.isTileAdded == true)
        ? 'Added'
        : (tile?.hasDeclinedBefore == true
              ? 'Manual'
              : (tile?.canRequestDirectAdd == false ? 'Manual' : 'Not added'));
    final usageGranted = _usageAccessState == UsageAccessState.granted;
    final usageLabel = usageGranted ? 'Granted' : 'Not granted';

    final rows = <Widget>[
      ListTile(
        key: const Key('settings_qs_tile_row'),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 6,
        ),
        onTap: () => _handleTileAction(context),
        title: Text(
          'Enprive Check tile',
          style: m3e.typeScale.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Add Enprive Check to Quick Settings to ask Deni about the app you\'re using without searching for Enprive first.',
            style: m3e.typeScale.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: tile?.isTileAdded == true
                    ? semantics.noConcern.background
                    : semantics.onDevice.background,
                borderRadius: BorderRadius.circular(EnpriveRadii.pill),
                border: Border.all(
                  color: tile?.isTileAdded == true
                      ? semantics.noConcern.border
                      : semantics.onDevice.border,
                ),
              ),
              child: Text(
                tileLabel,
                style: m3e.typeScale.labelMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tile?.isTileAdded == true
                      ? semantics.noConcern.foreground
                      : semantics.onDevice.foreground,
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
      ListTile(
        key: const Key('settings_usage_access_row'),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 6,
        ),
        onTap: () => _openUsageAccessFlow(context),
        title: Text(
          'Allow Usage Access (optional)',
          style: m3e.typeScale.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enprive uses Usage Access only when you tap Enprive Check to identify the app you were just using. This helps Deni find the correct app and its privacy information. Enprive does not continuously monitor your screen.',
                style: m3e.typeScale.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  GestureDetector(
                    onTap: () => _showQuickSettingsInstructionsDialog(
                      context,
                      title: 'Manage or revoke Usage Access',
                      body:
                          'Usage Access is a special Android Settings toggle (not an automatic popup). You can turn it off anytime under Android Settings → Apps → Special app access → Usage access → enprive. Deni remains usable without it via manual app selection.',
                    ),
                    child: Text(
                      'How to manage / revoke',
                      style: m3e.typeScale.labelMedium.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: usageGranted
                ? semantics.noConcern.background
                : semantics.reviewRecommended.background,
            borderRadius: BorderRadius.circular(EnpriveRadii.pill),
            border: Border.all(
              color: usageGranted
                  ? semantics.noConcern.border
                  : semantics.reviewRecommended.border,
            ),
          ),
          child: Text(
            usageLabel,
            style: m3e.typeScale.labelMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: usageGranted
                  ? semantics.noConcern.foreground
                  : semantics.reviewRecommended.foreground,
            ),
          ),
        ),
      ),
      if (widget.onOpenCompanion != null)
        ListTile(
          key: const Key('settings_open_companion_row'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          onTap: widget.onOpenCompanion,
          title: Text(
            'Open Deni Companion',
            style: m3e.typeScale.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Check a recent or selected app\'s permissions without Quick Settings.',
            style: m3e.typeScale.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          trailing: Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
        ),
    ];

    return [
      Column(
        children: rows.asMap().entries.map((entry) {
          final idx = entry.key;
          return Padding(
            padding: EdgeInsets.only(bottom: idx < rows.length - 1 ? 4.0 : 0.0),
            child: EnpriveSegmentedCardTile(
              index: idx,
              totalCount: rows.length,
              lipHeight: 2.0,
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: entry.value,
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }
}
