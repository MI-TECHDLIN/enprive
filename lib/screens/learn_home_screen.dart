import 'package:flutter/material.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/learn/learn_lesson.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/m3e/enprive_m3e_components.dart';
import '../widgets/navigation/enprive_navigation_shell.dart';
import 'learn_lesson_screen.dart';

/// Offline-first Privacy Literacy landing surface (Tab 2: `Learn`).
///
/// Built strictly on `EnpriveM3ETheme` with sculpted [EnpriveFolderTabCard]
/// topic folders that open dedicated full-screen [LearnLessonScreen] lessons
/// with vector diagrams and offline voice playback, plus an
/// [EnpriveStackedFolderDeck] Check bridge. Completely isolated from app
/// inventories and [PolicyReviewReceipt] evidence state.
class LearnHomeScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final VoidCallback onCheckAppRequested;
  final VoidCallback? onOpenSettings;
  final bool isActiveTab;
  final HybridAiBridge? hybridBridge;

  const LearnHomeScreen({
    super.key,
    this.scrollController,
    required this.onCheckAppRequested,
    this.onOpenSettings,
    this.isActiveTab = false,
    this.hybridBridge,
  });

  @override
  State<LearnHomeScreen> createState() => _LearnHomeScreenState();
}

class _LearnHomeScreenState extends State<LearnHomeScreen> {
  LearnTopicCategory _selectedCategory = LearnTopicCategory.all;
  HybridAiBridge? _fallbackBridge;

  HybridAiBridge get _effectiveBridge =>
      widget.hybridBridge ?? (_fallbackBridge ??= HybridAiBridge());

  String _categoryChipLabel(
    AppLocalizations l10n,
    LearnTopicCategory category,
  ) {
    return switch (category) {
      LearnTopicCategory.all => l10n.learnFilterAll,
      LearnTopicCategory.policies => l10n.learnFilterPolicies,
      LearnTopicCategory.permissions => l10n.learnFilterPermissions,
      LearnTopicCategory.sharing => l10n.learnFilterSharing,
      LearnTopicCategory.evidence => l10n.learnFilterEvidence,
    };
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

          final allLessons = buildLearnLessons(l10n);
          final visibleLessons = _selectedCategory == LearnTopicCategory.all
              ? allLessons
              : allLessons
                    .where((lesson) => lesson.category == _selectedCategory)
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
                                  l10n.learnHeaderSubtitle,
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
                        children: LearnTopicCategory.values.map((category) {
                          return EnpriveFilterChip(
                            selected: _selectedCategory == category,
                            label: _categoryChipLabel(l10n, category),
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
                              visibleLessons.length == 1;

                          Widget buildFolderTile(LearnLesson lesson) {
                            final palette = learnPaletteForCategory(
                              context,
                              lesson.category,
                            );
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;
                            final stat = lesson.shortStat(l10n);
                            final lessonIndex = allLessons.indexWhere(
                              (item) => item.id == lesson.id,
                            );
                            return EnpriveFolderTabCard(
                              key: Key('learn_folder_${lesson.id}'),
                              backgroundColor: palette.container,
                              borderColor: palette.accent.withValues(
                                alpha: 0.28,
                              ),
                              leadingIcon: lesson.icon,
                              iconBadgeColor: isDark
                                  ? scheme.surfaceContainerLowest
                                  : scheme.onSurface,
                              iconColor: isDark
                                  ? palette.accent
                                  : scheme.surface,
                              semanticLabel:
                                  '${lesson.folderTitle}. $stat. ${lesson.subtitle}',
                              onTap: () => LearnLessonScreen.open(
                                context,
                                lessons: allLessons,
                                initialIndex: lessonIndex < 0 ? 0 : lessonIndex,
                                hybridBridge: _effectiveBridge,
                                onCheckAppRequested: widget.onCheckAppRequested,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stat,
                                    style: m3e.typography.emphasized.titleLarge
                                        .copyWith(
                                          color: palette.onContainer,
                                          height: 1.15,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lesson.folderTitle,
                                    style: m3e.typography.emphasized.titleSmall
                                        .copyWith(color: palette.onContainer),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lesson.subtitle,
                                    style: m3e.typeScale.bodySmall.copyWith(
                                      color: palette.onContainer.withValues(
                                        alpha: 0.85,
                                      ),
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
                                for (final (idx, lesson)
                                    in visibleLessons.indexed)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: idx > 0 ? 12 : 0,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: buildFolderTile(lesson),
                                    ),
                                  ),
                              ],
                            );
                          }

                          final rows = <Widget>[];
                          for (var i = 0; i < visibleLessons.length; i += 2) {
                            final first = visibleLessons[i];
                            final second = i + 1 < visibleLessons.length
                                ? visibleLessons[i + 1]
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
                                        l10n.learnDeckTitle,
                                        style: m3e
                                            .typography
                                            .emphasized
                                            .titleMedium
                                            .copyWith(color: scheme.onSurface),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.learnDeckBody,
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
                              label: l10n.learnDeckCheckBtn,
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
