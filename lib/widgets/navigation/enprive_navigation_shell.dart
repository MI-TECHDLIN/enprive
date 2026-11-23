import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../../l10n/app_localizations.dart';

/// Canonical top-level destinations for Enprive's 3-pillar architecture:
/// - [check]: Protect (inspect installed apps, URLs, documents, and Quick Settings Companion)
/// - [receipts]: Understand (searchable archive of verified local review receipts)
/// - [learn]: Learn (offline privacy literacy, permissions, policies, and scam awareness)
enum EnpriveNavDestination { check, receipts, learn }

/// Window size class breakpoints per Material 3 Expressive adaptive guidance.
abstract final class EnpriveBreakpoints {
  /// Compact phone screens (`< 600dp`) use docked [M3ENavigationBar].
  static const double medium = 600.0;

  /// Expanded tablet/foldable screens (`>= 840dp`) use leading [M3ENavigationRail].
  static const double expanded = 840.0;

  /// Large windows (`>= 1200dp`) use expanded [M3ENavigationRail].
  static const double large = 1200.0;
}

/// Standard Material icon button with a gear for Settings, rendered in
/// top-level compact app bars (and in the rail footer on wider windows).
/// Kept as a framework [IconButton] (not `M3EIconButton`) so its tooltip and
/// semantics stay a single node.
class EnpriveSettingsAppBarButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const EnpriveSettingsAppBarButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = EnpriveM3ETheme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      icon: const Icon(LucideIcons.settings, size: 22),
    );
  }
}

/// Adaptive Material 3 Expressive navigation shell hosting Enprive's 3 primary
/// destinations (`Check` · `Receipts` · `Learn`) with:
/// - Grounded [M3ENavigationBar] on Compact (`< 600dp`) — zero floating dock
///   overlap with scrollable content or Android gesture bars.
/// - Leading [M3ENavigationRail] on Medium (`600–839dp`, collapsed) and
///   Expanded/Large (`>= 840dp` / `>= 1200dp`) with Settings anchored to the
///   rail footer (`trailingAtBottom: true`).
/// - [PopScope] back-navigation restoration returning from `Receipts` or `Learn`
///   to `Check` before exiting the app.
/// - Reselect-to-scroll-top callback when tapping the already active destination.
class EnpriveNavigationShell extends StatelessWidget {
  final int selectedIndex;
  final int receiptsCount;
  final ValueChanged<int> onSelectDestination;
  final ValueChanged<int>? onReselectDestination;
  final VoidCallback onOpenSettings;
  final Widget Function(BuildContext context, bool isCompactLayout) bodyBuilder;

  const EnpriveNavigationShell({
    super.key,
    required this.selectedIndex,
    required this.receiptsCount,
    required this.onSelectDestination,
    required this.onOpenSettings,
    required this.bodyBuilder,
    this.onReselectDestination,
  });

  void _handleDestinationTap(int index) {
    if (index == selectedIndex) {
      onReselectDestination?.call(index);
      return;
    }
    onSelectDestination(index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selectedIndex != 0) {
          onSelectDestination(0);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isCompact = width < EnpriveBreakpoints.medium;

          if (isCompact) {
            final barTheme = textScale > 1.25
                ? m3e.copyWith(
                    badgeTheme: m3e.badgeTheme.copyWith(
                      largeOffset: Offset(12, 14 * textScale.clamp(1.0, 1.65)),
                    ),
                  )
                : m3e;
            return Scaffold(
              backgroundColor: scheme.surface,
              extendBody: false,
              body: bodyBuilder(context, true),
              bottomNavigationBar: ColoredBox(
                color: scheme.surfaceContainer,
                child: Padding(
                  padding: EdgeInsets.only(top: textScale > 1.3 ? 6.0 : 0.0),
                  child: M3ETheme(
                    data: barTheme,
                    child: M3ENavigationBar(
                      key: const Key('enprive_m3e_nav_bar'),
                      selectedIndex: selectedIndex,
                      onDestinationSelected: _handleDestinationTap,
                      autoLayout: false,
                      layout: M3ENavBarLayout.compact,
                      size: M3ENavBarSize.small,
                      labelBehavior: M3ENavBarLabelBehavior.alwaysShow,
                      indicatorStyle: M3ENavBarIndicatorStyle.pill,
                      backgroundColor: scheme.surfaceContainer,
                      indicatorColor: scheme.secondaryContainer,
                      elevation: 0,
                      safeArea: true,
                      semanticLabel: l10n.semanticsPrimaryNavigation,
                      destinations: [
                        M3ENavigationBarDestination(
                          icon: const Icon(LucideIcons.shield),
                          selectedIcon: const Icon(LucideIcons.shieldCheck),
                          label: l10n.navCheck,
                          semanticLabel: l10n.navCheck,
                        ),
                        M3ENavigationBarDestination(
                          icon: const Icon(LucideIcons.receiptText),
                          selectedIcon: const Icon(LucideIcons.receiptText),
                          label: l10n.navReceipts,
                          semanticLabel: receiptsCount > 0
                              ? '${l10n.navReceipts} ($receiptsCount)'
                              : l10n.navReceipts,
                        ),
                        M3ENavigationBarDestination(
                          icon: const Icon(LucideIcons.bookOpen),
                          selectedIcon: const Icon(LucideIcons.bookOpenCheck),
                          label: l10n.navLearn,
                          semanticLabel: l10n.navLearn,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final isExpandedRail = width >= EnpriveBreakpoints.large;
          return Scaffold(
            backgroundColor: scheme.surface,
            body: Row(
              children: [
                M3ENavigationRail(
                  key: const Key('enprive_m3e_nav_rail'),
                  type: isExpandedRail
                      ? M3ENavigationRailType.expanded
                      : M3ENavigationRailType.collapsed,
                  modality: M3ENavigationRailModality.standard,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: _handleDestinationTap,
                  background: scheme.surface,
                  showDivider: false,
                  trailingAtBottom: true,
                  labelBehavior: M3ENavigationRailLabelBehavior.alwaysShow,
                  sections: [
                    M3ENavigationRailSection(
                      destinations: [
                        M3ENavigationRailDestination(
                          icon: const Icon(LucideIcons.shield),
                          selectedIcon: const Icon(LucideIcons.shieldCheck),
                          label: l10n.navCheck,
                          semanticLabel: l10n.navCheck,
                        ),
                        M3ENavigationRailDestination(
                          icon: const Icon(LucideIcons.receiptText),
                          selectedIcon: const Icon(LucideIcons.receiptText),
                          label: l10n.navReceipts,
                          semanticLabel: receiptsCount > 0
                              ? '${l10n.navReceipts} ($receiptsCount)'
                              : l10n.navReceipts,
                        ),
                        M3ENavigationRailDestination(
                          icon: const Icon(LucideIcons.bookOpen),
                          selectedIcon: const Icon(LucideIcons.bookOpenCheck),
                          label: l10n.navLearn,
                          semanticLabel: l10n.navLearn,
                        ),
                      ],
                    ),
                  ],
                  trailing: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: isExpandedRail
                        ? TextButton.icon(
                            key: const Key('nav_settings_btn'),
                            onPressed: onOpenSettings,
                            icon: const Icon(LucideIcons.settings, size: 20),
                            label: Text(l10n.navSettings),
                          )
                        : EnpriveSettingsAppBarButton(
                            key: const Key('nav_settings_btn'),
                            tooltip: l10n.navSettings,
                            onPressed: onOpenSettings,
                          ),
                  ),
                ),
                Expanded(child: bodyBuilder(context, false)),
              ],
            ),
          );
        },
      ),
    );
  }
}
