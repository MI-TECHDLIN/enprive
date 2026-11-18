import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/m3e/enprive_m3e_components.dart';
import '../widgets/navigation/enprive_navigation_shell.dart';

enum _LearnTopicCategory {
  all,
  permissions,
  policies,
  scams,
  darkPatterns,
}

class _LearnPillarGuide {
  final String id;
  final _LearnTopicCategory category;
  final String title;
  final String shortStat;
  final String subtitle;
  final IconData icon;
  final List<String> keyTakeaways;
  final String quickCheckQuestion;

  const _LearnPillarGuide({
    required this.id,
    required this.category,
    required this.title,
    required this.shortStat,
    required this.subtitle,
    required this.icon,
    required this.keyTakeaways,
    required this.quickCheckQuestion,
  });
}

/// Offline-first Privacy Literacy landing surface (Tab 2: `Learn`).
///
/// Built strictly on `EnpriveM3ETheme` with sculpted [EnpriveFolderTabCard]
/// topic folders and an [EnpriveStackedFolderDeck] of quick guides. Completely
/// isolated from app inventories and [PolicyReviewReceipt] evidence state.
class LearnHomeScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final VoidCallback onCheckAppRequested;
  final VoidCallback? onOpenSettings;
  final bool isActiveTab;

  const LearnHomeScreen({
    super.key,
    this.scrollController,
    required this.onCheckAppRequested,
    this.onOpenSettings,
    this.isActiveTab = false,
  });

  @override
  State<LearnHomeScreen> createState() => _LearnHomeScreenState();
}

class _LearnHomeScreenState extends State<LearnHomeScreen> {
  _LearnTopicCategory _selectedCategory = _LearnTopicCategory.all;

  static const List<_LearnPillarGuide> _guides = [
    _LearnPillarGuide(
      id: 'permissions_consent',
      category: _LearnTopicCategory.permissions,
      title: 'Permissions & Consent',
      shortStat: '3 guides',
      subtitle: 'Camera, mic, location & AD_ID',
      icon: LucideIcons.shieldCheck,
      keyTakeaways: [
        'Match the permission to the feature you tapped: a flashlight or math quiz rarely needs Contacts or Background Location.',
        'Prefer "Only this time" or "While using the app" instead of "Always" when trying a new app.',
        'Declaring a permission in an Android manifest means the app can ask for it — check Android App Permissions anytime to revoke access.',
      ],
      quickCheckQuestion:
          'Ask yourself: Does this feature still work if I tap "Don\'t allow"?',
    ),
    _LearnPillarGuide(
      id: 'reading_policies',
      category: _LearnTopicCategory.policies,
      title: 'Reading Policies',
      shortStat: '3 guides',
      subtitle: 'Vague sharing & retention terms',
      icon: LucideIcons.fileText,
      keyTakeaways: [
        'Watch for open-ended verbs like "may share with partners" or "retain as long as needed" without concrete deletion timelines.',
        'Separate operational service providers (hosting, crash fixes) from third-party advertising networks and data brokers.',
        'Silence is not a promise: when a policy does not mention camera or location data, it does not guarantee the app avoids collecting it.',
      ],
      quickCheckQuestion:
          'Ask yourself: Does the policy explain how to delete a child\'s or student\'s data?',
    ),
    _LearnPillarGuide(
      id: 'scams_safety',
      category: _LearnTopicCategory.scams,
      title: 'Scams & Safety',
      shortStat: '3 guides',
      subtitle: 'Fake links, OTPs & identity theft',
      icon: LucideIcons.triangleAlert,
      keyTakeaways: [
        'Pause on artificial urgency ("Account closes in 10 minutes", "Verify your card now") — legitimate schools and banks rarely demand instant links.',
        'Never share one-time passcodes (SMS/OTP), bank details, or government ID photos inside unfamiliar links or chat popups.',
        'Inspect the exact domain name before signing in or sharing sensitive information; misspelled domains are a primary phishing signal.',
      ],
      quickCheckQuestion:
          'Ask yourself: Can I verify this request independently inside the official app or website?',
    ),
    _LearnPillarGuide(
      id: 'manipulative_consent',
      category: _LearnTopicCategory.darkPatterns,
      title: 'Dark Patterns',
      shortStat: '3 guides',
      subtitle: 'Spotting pressured consent UI',
      icon: LucideIcons.eye,
      keyTakeaways: [
        'Bright oversized "Accept all" buttons paired with tiny muted "Manage preferences" links are designed to rush your choice.',
        'Pre-checked boxes for personalized ads or third-party marketing are optional — untick them before continuing.',
        'Repeated nagging prompts after you tap "Deny" are a warning sign worth reviewing in Android Settings.',
      ],
      quickCheckQuestion:
          'Ask yourself: Is saying "No" just as clear and easy as saying "Yes"?',
    ),
  ];

  SemanticColorPair _pairForCategory(
    EnpriveSemanticColors semantics,
    _LearnTopicCategory category,
  ) {
    return switch (category) {
      _LearnTopicCategory.permissions => semantics.onDevice,
      _LearnTopicCategory.policies => semantics.noConcern,
      _LearnTopicCategory.scams => semantics.reviewRecommended,
      _LearnTopicCategory.darkPatterns => semantics.inCloud,
      _LearnTopicCategory.all => semantics.onDevice,
    };
  }

  String _categoryChipLabel(_LearnTopicCategory category) {
    return switch (category) {
      _LearnTopicCategory.all => 'All topics',
      _LearnTopicCategory.permissions => 'Permissions',
      _LearnTopicCategory.policies => 'Policies',
      _LearnTopicCategory.scams => 'Scams',
      _LearnTopicCategory.darkPatterns => 'Dark patterns',
    };
  }

  void _openGuideSheet(
    BuildContext context,
    _LearnPillarGuide guide,
    SemanticColorPair pair,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return EnpriveM3EBridgeScope.ensure(
          sheetContext,
          child: Builder(
            builder: (sheetContext) {
              final m3e = EnpriveM3ETheme.of(sheetContext);
              final scheme = m3e.colorScheme;
              final surfaces = sheetContext.enpriveSurfaces;

              return Material(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                clipBehavior: Clip.antiAlias,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: pair.background,
                                shape: BoxShape.circle,
                                border: Border.all(color: pair.border),
                              ),
                              child: Icon(
                                guide.icon,
                                size: 20,
                                color: pair.foreground,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    guide.title,
                                    style: m3e.typography.emphasized.titleLarge
                                        .copyWith(color: scheme.onSurface),
                                  ),
                                  Text(
                                    guide.subtitle,
                                    style: m3e.typeScale.bodySmall.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: Icon(
                                LucideIcons.x,
                                size: 20,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        for (final (idx, tip) in guide.keyTakeaways.indexed)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: idx < guide.keyTakeaways.length - 1
                                  ? 6
                                  : 0,
                            ),
                            child: EnpriveSegmentedCardTile(
                              index: idx,
                              totalCount: guide.keyTakeaways.length,
                              backgroundColor: surfaces.card,
                              lipHeight: 1.5,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: pair.background,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${idx + 1}',
                                      style: m3e.typography.emphasized.labelSmall
                                          .copyWith(color: pair.foreground),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: m3e.typeScale.bodyMedium.copyWith(
                                        color: scheme.onSurface,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        EnpriveMaterialCardSurface(
                          variant: EnpriveCardVariant.outlined,
                          backgroundColor: pair.background,
                          borderColor: pair.border,
                          borderRadius: BorderRadius.circular(18),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const DeniAnimatedMascot(
                                size: 48,
                                pose: DeniPose.explaining,
                                showAmbientGlow: false,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  guide.quickCheckQuestion,
                                  style: m3e.typeScale.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: pair.foreground,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        EnpriveTactileButton(
                          label: 'Check an app on this phone',
                          isSecondary: true,
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            widget.onCheckAppRequested();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final surfaces = context.enpriveSurfaces;
          final semantics = context.enpriveSemantics;

          final visibleGuides = _selectedCategory == _LearnTopicCategory.all
              ? _guides
              : _guides
                    .where((g) => g.category == _selectedCategory)
                    .toList(growable: false);

          return SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Single clean editorial top header (no duplicate global AppBar)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.navLearn,
                                  style: m3e.typography.emphasized.headlineMedium
                                      .copyWith(color: scheme.onSurface),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Offline privacy & consent guides',
                                  style: m3e.typeScale.bodySmall.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.onOpenSettings != null)
                            EnpriveSettingsAppBarButton(
                              key: widget.isActiveTab
                                  ? const Key('nav_settings_btn')
                                  : null,
                              tooltip: l10n.navSettings,
                              onPressed: widget.onOpenSettings!,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Filter chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children: _LearnTopicCategory.values.map((category) {
                          return EnpriveFilterChip(
                            selected: _selectedCategory == category,
                            label: _categoryChipLabel(category),
                            onPressed: () {
                              setState(() => _selectedCategory = category);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Signature 2x2 sculpted archival folder-tab cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final textScale = MediaQuery.textScalerOf(
                            context,
                          ).scale(1.0);
                          final singleColumn =
                              constraints.maxWidth < 330 ||
                              textScale > 1.45 ||
                              visibleGuides.length == 1;

                          Widget buildFolderTile(_LearnPillarGuide guide) {
                            final pair = _pairForCategory(
                              semantics,
                              guide.category,
                            );
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;
                            return EnpriveFolderTabCard(
                              key: Key('learn_folder_${guide.id}'),
                              backgroundColor: pair.background,
                              borderColor: pair.border,
                              leadingIcon: guide.icon,
                              iconBadgeColor: isDark
                                  ? scheme.surfaceContainerLowest
                                  : scheme.onSurface,
                              iconColor: isDark
                                  ? pair.foreground
                                  : scheme.surface,
                              semanticLabel:
                                  '${guide.title}. ${guide.shortStat}. ${guide.subtitle}',
                              onTap: () => _openGuideSheet(context, guide, pair),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    guide.shortStat,
                                    style: m3e.typography.emphasized.titleLarge
                                        .copyWith(
                                          color: pair.foreground,
                                          height: 1.15,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    guide.title,
                                    style: m3e.typography.emphasized.titleSmall
                                        .copyWith(color: scheme.onSurface),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    guide.subtitle,
                                    style: m3e.typeScale.bodySmall.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (singleColumn) {
                            return Column(
                              children: [
                                for (final (idx, g) in visibleGuides.indexed)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: idx > 0 ? 12 : 0,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: buildFolderTile(g),
                                    ),
                                  ),
                              ],
                            );
                          }

                          final rows = <Widget>[];
                          for (var i = 0; i < visibleGuides.length; i += 2) {
                            final first = visibleGuides[i];
                            final second = i + 1 < visibleGuides.length
                                ? visibleGuides[i + 1]
                                : null;
                            rows.add(
                              Padding(
                                padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: buildFolderTile(first)),
                                      if (second != null) ...[
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: buildFolderTile(second),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(children: rows);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Layered archival folder deck — quick offline takeaways + Check bridge
                      EnpriveStackedFolderDeck(
                        frontColor: surfaces.card,
                        frontBorderColor: surfaces.hairlineBorder,
                        middleLayerColor: semantics.onDevice.background,
                        backLayerColor: semantics.reviewRecommended.background,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const DeniAnimatedMascot(
                                  size: 56,
                                  pose: DeniPose.idle,
                                  showAmbientGlow: false,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Practice privacy habits locally',
                                        style: m3e
                                            .typography
                                            .emphasized
                                            .titleMedium
                                            .copyWith(color: scheme.onSurface),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '100% offline literacy guides. Your installed apps and receipts never enter Learn.',
                                        style: m3e.typeScale.bodySmall.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          height: 1.38,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            EnpriveTactileButton(
                              key: const Key('learn_check_app_bridge_btn'),
                              label: 'Apply it · Check an app',
                              isSecondary: true,
                              onPressed: widget.onCheckAppRequested,
                            ),
                          ],
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
