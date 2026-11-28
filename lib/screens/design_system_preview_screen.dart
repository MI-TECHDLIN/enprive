import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_provenance_chip.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/m3e/enprive_m3e_components.dart';

/// Standalone Stage 0 `M3EMaterialApp` wrapper for isolated proof-of-concept
/// booting and widget verification.
class EnpriveM3EStage0App extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final Locale locale;

  const EnpriveM3EStage0App({
    super.key,
    this.initialThemeMode = ThemeMode.light,
    this.locale = const Locale('en'),
  });

  @override
  State<EnpriveM3EStage0App> createState() => _EnpriveM3EStage0AppState();
}

class _EnpriveM3EStage0AppState extends State<EnpriveM3EStage0App> {
  late ThemeMode _themeMode = widget.initialThemeMode;

  @override
  Widget build(BuildContext context) {
    final platformBrightness =
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    final activeData = EnpriveM3ETheme.resolve(
      mode: _themeMode,
      platformBrightness: platformBrightness,
    );

    return M3EMaterialApp(
      title: 'Enprive M3E Stage 0 PoC',
      debugShowCheckedModeBanner: false,
      data: activeData,
      typeface: EnpriveM3ETheme.typefaceConfig,
      autoTheming: _themeMode == ThemeMode.system,
      dynamicColoring: false,
      initialTheme: activeData.brightness,
      theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
      darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
      locale: widget.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
      appBuilder: (context, child) {
        return EnpriveM3EBridgeScope(
          themeMode: _themeMode,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: DesignSystemPreviewScreen(
        currentThemeMode: _themeMode,
        onThemeModeChanged: (next) => setState(() => _themeMode = next),
      ),
    );
  }
}

/// Stage 0 — Material 3 Expressive (`material_3_expressive: 1.2.1`) Application
/// Shell & Visual Inspiration Proof of Concept.
///
/// Demonstrates:
/// 1. `M3EAppBar.top`, `M3ENavigationBar`, `M3ESegmentedButton`, `M3EButtonGroup`,
///    `M3EButton`, `M3ECard`, `M3EList` + `M3EListItem`, `M3EChip`,
///    `M3ESearchBar`, `M3EProgressIndicator.linearWavy`, `M3ELoadingIndicator`,
///    and `M3EBottomSheet.show`.
/// 2. Visual inspiration synthesis (`Music OS` stacked tabular cards, `_.jpeg`
///    asymmetric bento metrics, `Marshmallow` & `Growth` companion staging,
///    `plan check up` insight callout).
/// 3. Deni 3-Tier LOD System at exact `52dp` (`LOD 1`), `84dp` (`LOD 2`), and
///    `144dp` (`LOD 3`) across every [DeniPose], including the intent poses.
/// 4. Light ("Warm Archival Paper") and Dark ("Obsidian Ceramic Slate") semantic
///    tokens with live calculated sRGB WCAG 2.1 contrast ratios.
class DesignSystemPreviewScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final DeniPose initialPose;

  const DesignSystemPreviewScreen({
    super.key,
    this.currentThemeMode = ThemeMode.system,
    this.onThemeModeChanged,
    this.initialPose = DeniPose.explaining,
  });

  @override
  State<DesignSystemPreviewScreen> createState() =>
      _DesignSystemPreviewScreenState();
}

class _DesignSystemPreviewScreenState extends State<DesignSystemPreviewScreen> {
  late DeniPose _selectedPose = widget.initialPose;
  late ThemeMode _localMode = widget.currentThemeMode;
  int _selectedNavIndex = 0;
  int? _selectedActionGroupIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cycleThemeMode(ThemeMode nextMode) {
    setState(() => _localMode = nextMode);
    widget.onThemeModeChanged?.call(nextMode);
  }

  Future<void> _openM3EWhyThisMattersSheet(BuildContext context) async {
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final typeExt = context.enpriveType;

    await M3EBottomSheet.show<void>(
      context,
      showDragHandle: true,
      initialValue: M3EBottomSheetValue.expanded,
      builder: (sheetContext) {
        return SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const DeniAnimatedMascot(
                    size: 52,
                    pose: DeniPose.explaining,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Why This Clause Matters',
                          style: m3e.typography.emphasized.titleLarge.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          'Verified on-device · Source-aligned quote',
                          style: m3e.typeScale.labelMedium.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              M3ECard(
                variant: M3ECardVariant.filled,
                color: scheme.surfaceContainerHigh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“We may share persistent advertising identifiers and app usage events with third-party advertising partners.”',
                      style: typeExt.policyQuotation.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No concern identified in the reviewed evidence is never shown as a binary Safe seal. This clause warrants parent/educator review.',
                      style: m3e.typeScale.bodySmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: M3EButton.filled(
                  size: M3EButtonSize.md,
                  onPressed: () => Navigator.of(sheetContext).maybePop(),
                  label: const Text('Got It · Close Sheet'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope(
      themeMode: _localMode,
      child: Builder(
        builder: (themedContext) {
          final m3e = M3ETheme.of(themedContext);
          final scheme = m3e.colorScheme;
          final surfaces = themedContext.surfaceTokens;
          final semantics = themedContext.semanticColors;
          final typeExt = themedContext.enpriveType;

          return Scaffold(
            backgroundColor: scheme.surface,
            appBar: M3EAppBar.top(
              backgroundColor: scheme.surface,
              leading: Navigator.of(themedContext).canPop()
                  ? IconButton(
                      icon: Icon(
                        LucideIcons.arrowLeft,
                        color: scheme.onSurface,
                      ),
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(themedContext).maybePop(),
                    )
                  : null,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enprive M3E',
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    'Stage 0 Shell Preview',
                    style: m3e.typeScale.labelSmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: SizedBox(
                    width: 144,
                    child: M3ESegmentedButton<ThemeMode>(
                      key: const Key('m3e_stage0_theme_segmented'),
                      density: M3ESegmentedButtonDensity.compact,
                      showSelectedIcon: false,
                      segments: const [
                        M3ESegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: 'Light',
                          semanticLabel: 'Light Mode',
                        ),
                        M3ESegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: 'Dark',
                          semanticLabel: 'Dark Mode',
                        ),
                      ],
                      selected: {
                        _localMode == ThemeMode.dark
                            ? ThemeMode.dark
                            : ThemeMode.light,
                      },
                      onSelectionChanged: (selection) {
                        _cycleThemeMode(selection.first);
                      },
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              key: const Key('design_phase1_scroll_view'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 0. Two-Tone Editorial Header + M3ESearchBar
                  RichText(
                    text: TextSpan(
                      style: m3e.typography.emphasized.headlineMedium.copyWith(
                        color: scheme.onSurface,
                        height: 1.15,
                      ),
                      children: [
                        const TextSpan(text: 'Privacy Posture\n'),
                        TextSpan(
                          text: 'Material 3 Expressive Shell',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  M3ESearchBar(
                    key: const Key('m3e_stage0_search_bar'),
                    controller: _searchController,
                    margin: 0,
                    focusedMargin: 0,
                    hintText: 'Search clauses, permissions, or digest…',
                    leading: Icon(
                      LucideIcons.search,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    showClearButton: true,
                  ),

                  const SizedBox(height: 20),

                  // 1. Asymmetric Bento Posture Grid (Inspired by _.jpeg & Music OS)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 6,
                          child: M3ECard(
                            variant: M3ECardVariant.filled,
                            color: scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(28),
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        'ON-DEVICE',
                                        style: m3e.typeScale.labelSmall
                                            .copyWith(
                                              color: scheme.onPrimaryContainer,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                    Icon(
                                      LucideIcons.shieldCheck,
                                      size: 20,
                                      color: scheme.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  '03',
                                  style: typeExt.tabularMetricLarge.copyWith(
                                    fontSize: 44,
                                    height: 1.0,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Verified Clauses\n100% Quote Aligned',
                                  style: m3e.typeScale.bodySmall.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                M3EProgressIndicator.linearWavy(
                                  key: const Key('m3e_stage0_wavy_progress'),
                                  value: 0.82,
                                  color: scheme.primary,
                                  trackColor: scheme.surfaceContainerHighest,
                                  semanticsLabel: 'Evidence alignment wave',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              Expanded(
                                child: M3ECard(
                                  variant: M3ECardVariant.filled,
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(24),
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Nano 4',
                                            style: m3e
                                                .typography
                                                .emphasized
                                                .titleMedium
                                                .copyWith(
                                                  color:
                                                      scheme.onPrimaryContainer,
                                                ),
                                          ),
                                          const M3ELoadingIndicator(
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Zero cloud egress without consent',
                                        style: m3e.typeScale.labelSmall
                                            .copyWith(
                                              color: scheme.onPrimaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: M3ECard(
                                  variant: M3ECardVariant.filled,
                                  color: scheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(24),
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '02 Flags',
                                            style: m3e
                                                .typography
                                                .emphasized
                                                .titleMedium
                                                .copyWith(
                                                  color: scheme
                                                      .onTertiaryContainer,
                                                ),
                                          ),
                                          Icon(
                                            LucideIcons.arrowUpRight,
                                            size: 18,
                                            color: scheme.onTertiaryContainer,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Review recommended · Not a safe seal',
                                        style: m3e.typeScale.labelSmall
                                            .copyWith(
                                              color: scheme.onTertiaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Deni 3-Tier LOD Stage (52dp, 84dp, 144dp) with M3EChip Filter Row
                  Text(
                    '1. Deni 3-Tier LOD System (52dp · 84dp · 144dp)',
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DeniPose.values.map((pose) {
                      final selected = pose == _selectedPose;
                      return M3EChip(
                        key: Key('lod_pose_chip_${pose.name}'),
                        label: pose.name,
                        type: M3EChipType.filter,
                        selected: selected,
                        onPressed: () => setState(() => _selectedPose = pose),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  M3ECard(
                    variant: M3ECardVariant.outlined,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _LodSpecimenColumn(
                              label: 'LOD 1 · 52dp',
                              sublabel: 'Compact Avatar',
                              size: 52,
                              pose: _selectedPose,
                            ),
                            _LodSpecimenColumn(
                              label: 'LOD 2 · 84dp',
                              sublabel: 'Companion',
                              size: 84,
                              pose: _selectedPose,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const M3EDivider(),
                        const SizedBox(height: 12),
                        _LodSpecimenColumn(
                          label: 'LOD 3 · 144dp',
                          sublabel: 'Hero Stage (${_selectedPose.name})',
                          size: 144,
                          pose: _selectedPose,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Segmented Expressive List (M3EList + M3EListItem, 2dp gap, no dividers)
                  Text(
                    '2. Expressive Segmented Containment (M3EList)',
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  M3EList(
                    key: const Key('m3e_stage0_segmented_list'),
                    outerRadius: 20,
                    innerRadius: 4,
                    gap: 2,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return switch (index) {
                        0 => M3EListItem(
                          overline: 'GUARDRAIL 01 · LOCAL ONLY',
                          headline: 'On-Device Package & Permission Scan',
                          supportingText:
                              'Installed package lists never leave the Android device.',
                          leading: Icon(
                            LucideIcons.smartphone,
                            color: scheme.primary,
                          ),
                          trailingText: 'LOCAL',
                        ),
                        1 => M3EListItem(
                          overline: 'GUARDRAIL 02 · CONSENT GATE',
                          headline: 'Per-Request Cloud Redaction & Consent',
                          supportingText:
                              'SingleGenerationGuard enforces 1 request per approval.',
                          leading: Icon(
                            LucideIcons.cloudCog,
                            color: scheme.tertiary,
                          ),
                          trailingText: '1-SHOT',
                        ),
                        _ => M3EListItem(
                          overline: 'GUARDRAIL 03 · EVIDENCE VALIDATOR',
                          headline: 'No Binary Safe Certification',
                          supportingText:
                              'No concern identified in the reviewed evidence. This is not a safety certification.',
                          leading: Icon(
                            LucideIcons.fileCheck2,
                            color: scheme.secondary,
                          ),
                          trailingText: 'FNV-1a 64-bit',
                        ),
                      };
                    },
                  ),

                  const SizedBox(height: 24),

                  // 4. Semantic & Provenance Contrast Matrix
                  Text(
                    '3. Semantic & Provenance Tokens (WCAG 2.1 Verified)',
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SemanticContrastTile(
                    index: 0,
                    count: 5,
                    title: 'No Concern Identified (Calibrated)',
                    subtitle: 'Not a safety certification · Source matched',
                    pair: semantics.noConcern,
                  ),
                  const SizedBox(height: 4),
                  _SemanticContrastTile(
                    index: 1,
                    count: 5,
                    title: 'Review Recommended (Attention)',
                    subtitle: 'Clause warrants closer parent/educator review',
                    pair: semantics.reviewRecommended,
                  ),
                  const SizedBox(height: 4),
                  _SemanticContrastTile(
                    index: 2,
                    count: 5,
                    title: 'High Concern / Unverified Claim',
                    subtitle: 'Sensitive data sharing or unaligned quote',
                    pair: semantics.highConcern,
                  ),
                  const SizedBox(height: 4),
                  _SemanticContrastTile(
                    index: 3,
                    count: 5,
                    title: 'Insufficient Evidence',
                    subtitle: 'Policy text omits explicit retention details',
                    pair: semantics.insufficientEvidence,
                  ),
                  const SizedBox(height: 4),
                  _SemanticContrastTile(
                    index: 4,
                    count: 5,
                    title: 'Primary Surface Ink Contrast',
                    subtitle: 'Primary & secondary typography on card surface',
                    pair: SemanticColorPair(
                      background: surfaces.card,
                      foreground: scheme.onSurface,
                      border: surfaces.hairlineBorder,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      EnpriveProvenanceChip(source: InferenceSource.onDevice),
                      EnpriveProvenanceChip(source: InferenceSource.inCloud),
                      EnpriveProvenanceChip(
                        source: InferenceSource.offlineDeterministic,
                      ),
                      EnpriveProvenanceChip(source: InferenceSource.unknown),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 5. Dedicated Typography Extensions & M3E Interactive Controls
                  Text(
                    '4. Typography Extensions & M3E Tactile Controls',
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  M3ECard(
                    variant: M3ECardVariant.outlined,
                    color: surfaces.quoteSurface,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'Q1',
                                style: m3e.typeScale.labelMedium.copyWith(
                                  color: scheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Icon(
                              LucideIcons.arrowUpRight,
                              size: 20,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '“We may share persistent advertising identifiers and app usage events with third-party advertising partners.”',
                          style: typeExt.policyQuotation,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Snapshot digest · FNV-1a 64-bit · 8f4b2e9c10a74d3b',
                          style: typeExt.sha256Hash,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('03', style: typeExt.tabularMetricLarge),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Verified quotes · 100% source aligned',
                                style: m3e.typeScale.bodyMedium.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  M3EButtonGroup(
                    key: const Key('m3e_stage0_button_group'),
                    type: M3EButtonGroupType.connected,
                    style: M3EButtonStyle.tonal,
                    size: M3EButtonSize.sm,
                    selectedIndex: _selectedActionGroupIndex,
                    onSelectedIndexChanged: (index) {
                      setState(() => _selectedActionGroupIndex = index);
                    },
                    actions: const [
                      M3EButtonGroupAction(
                        icon: Icon(LucideIcons.scanSearch, size: 16),
                        label: Text('Inspect'),
                      ),
                      M3EButtonGroupAction(
                        icon: Icon(LucideIcons.fileText, size: 16),
                        label: Text('Paste'),
                      ),
                      M3EButtonGroupAction(
                        icon: Icon(LucideIcons.receiptText, size: 16),
                        label: Text('Receipts'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: M3EButton.filled(
                      key: const Key('m3e_stage0_open_sheet_btn'),
                      size: M3EButtonSize.md,
                      icon: const Icon(LucideIcons.sparkles, size: 20),
                      label: const Text('Open M3E Bottom Sheet Preview'),
                      onPressed: () =>
                          _openM3EWhyThisMattersSheet(themedContext),
                    ),
                  ),
                  const SizedBox(height: 12),
                  EnpriveTactileButton(
                    label: 'Primary Tactile Action (48dp+)',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  EnpriveTactileButton(
                    label: 'Secondary Tactile Action',
                    isSecondary: true,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  const EnpriveTactileButton(
                    label: 'Disabled Tactile State (WCAG AA)',
                    onPressed: null,
                  ),

                  const SizedBox(height: 28),

                  // 6. Custom Tactile Material Card Family
                  Text(
                    '5. Custom Material 3 Expressive Card Family',
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: EnpriveBentoChoiceCard(
                          title: 'Sample Bento',
                          metricHighlight: '06',
                          metricHighlightColor: semantics.onDevice.foreground,
                          subtitle: 'Grounded 3.5dp lip + morph',
                          footerTag: 'ON-DEVICE',
                          icon: LucideIcons.shieldCheck,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EnpriveBentoChoiceCard(
                          title: 'Selected Bento',
                          subtitle: 'Dual-cue fill + 2dp border',
                          footerTag: 'ACTIVE',
                          icon: LucideIcons.sparkles,
                          selected: true,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: EnpriveMetricTileCard(
                          value: '04',
                          label: 'Verified Clauses',
                          icon: LucideIcons.quote,
                          accentColor: semantics.noConcern.foreground,
                          accentBackground: semantics.noConcern.background,
                          meterFraction: 1.0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: EnpriveMetricTileCard(
                          value: '01',
                          label: 'Review Item',
                          icon: LucideIcons.triangleAlert,
                          accentColor: semantics.reviewRecommended.foreground,
                          accentBackground:
                              semantics.reviewRecommended.background,
                          meterFraction: 0.45,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  EnpriveQuoteCard(
                    statusLabel: 'Source matched',
                    categoryLabel: 'Third-party sharing',
                    spineColor: semantics.onDevice.icon,
                    quote:
                        'We only retain diagnostic crash logs to keep the classroom workspace reliable.',
                    sha256Digest: '8f4b2e9c10a74d3b6e12c9805f1a3d7e',
                  ),
                  const SizedBox(height: 12),
                  EnpriveReceiptCard(
                    receipt: PolicyReviewReceipt(
                      id: 'preview_rcpt',
                      subjectTitle: 'Example Learning App',
                      sourceLabel: 'Pasted policy text',
                      createdAt: DateTime(2026, 11, 14, 10, 30),
                      overallState: ReviewOverallState.reviewRecommended,
                      inferenceSource: InferenceSource.onDevice,
                      summary:
                          'Discloses ad telemetry identifier alongside microphone classroom notes.',
                      calibratedDisclaimer:
                          ReviewCoordinator.calibratedDefaultDisclaimer,
                      snapshotText: 'Archival snapshot excerpt.',
                      snapshotDigest: '8f4b2e9c10a7',
                      findings: const [],
                    ),
                    stateBadgeLabel: 'Review recommended',
                    metaLine: 'Pasted policy text · Nov 14',
                    openLabel: 'Open receipt',
                    deleteTooltip: 'Delete',
                    onOpen: () {},
                    onDelete: () {},
                  ),
                ],
              ),
            ),
            bottomNavigationBar: M3ENavigationBar(
              key: const Key('m3e_stage0_nav_bar'),
              selectedIndex: _selectedNavIndex,
              onDestinationSelected: (idx) {
                setState(() => _selectedNavIndex = idx);
              },
              destinations: const [
                M3ENavigationBarDestination(
                  icon: Icon(LucideIcons.shield),
                  selectedIcon: Icon(LucideIcons.shieldCheck),
                  label: 'Review',
                ),
                M3ENavigationBarDestination(
                  icon: Icon(LucideIcons.receiptText),
                  selectedIcon: Icon(LucideIcons.receipt),
                  label: 'Receipts',
                ),
                M3ENavigationBarDestination(
                  icon: Icon(LucideIcons.slidersHorizontal),
                  selectedIcon: Icon(LucideIcons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LodSpecimenColumn extends StatelessWidget {
  final String label;
  final String sublabel;
  final double size;
  final DeniPose pose;

  const _LodSpecimenColumn({
    required this.label,
    required this.sublabel,
    required this.size,
    required this.pose,
  });

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaceTokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: surfaces.cardMuted,
            borderRadius: BorderRadius.circular(EnpriveRadii.md),
            border: Border.all(color: surfaces.hairlineBorder),
          ),
          child: DeniAnimatedMascot(
            size: size,
            pose: pose,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: context.enpriveType.evidenceBadge,
        ),
        Text(
          sublabel,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SemanticContrastTile extends StatelessWidget {
  final int index;
  final int count;
  final String title;
  final String subtitle;
  final SemanticColorPair pair;

  const _SemanticContrastTile({
    required this.index,
    required this.count,
    required this.title,
    required this.subtitle,
    required this.pair,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = pair.contrastRatio;
    final badge = ratio >= 7.0 ? 'AAA' : (ratio >= 4.5 ? 'AA' : 'LOW');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: EnpriveRadii.groupedCardRadius(
          index: index,
          count: count,
        ),
        border: Border.all(color: pair.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: EnpriveTheme.primaryDisplayFontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: pair.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: EnpriveTheme.secondaryFontBaseFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: pair.foreground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: pair.foreground,
              borderRadius: BorderRadius.circular(EnpriveRadii.pill),
            ),
            child: Text(
              '${ratio.toStringAsFixed(1)}:1 $badge',
              style: TextStyle(
                fontFamily: EnpriveTheme.secondaryFontBaseFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: pair.background,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
