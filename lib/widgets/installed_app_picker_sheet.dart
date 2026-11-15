import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/permissions/permission_comparator.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'deni_animated_mascot.dart';
import 'installed_app_icon.dart';
import 'm3e/enprive_m3e_components.dart';

class SelectedAppInspectionChoice {
  final String subjectTitle;
  final String sourceLabel;
  final String policyText;
  final AppPermissionSnapshot permissionSnapshot;
  final bool hasSuppliedPolicy;
  final bool isSyntheticSample;

  const SelectedAppInspectionChoice({
    required this.subjectTitle,
    required this.sourceLabel,
    required this.policyText,
    required this.permissionSnapshot,
    this.hasSuppliedPolicy = false,
    this.isSyntheticSample = false,
  });
}

/// Material 3 Expressive Installed App Picker Sheet.
/// Queries Android `PackageManager` strictly on-device (`listLaunchableApps`
/// and `inspectSelectedApp`). Installed app lists never leave the phone.
class InstalledAppPickerSheet extends StatefulWidget {
  final HybridAiBridge bridge;
  final String eduTrackPolicyText;
  final String calmMathPolicyText;

  const InstalledAppPickerSheet({
    super.key,
    required this.bridge,
    required this.eduTrackPolicyText,
    required this.calmMathPolicyText,
  });

  static Future<SelectedAppInspectionChoice?> show(
    BuildContext context, {
    required HybridAiBridge bridge,
    required String eduTrackPolicyText,
    required String calmMathPolicyText,
  }) {
    return showModalBottomSheet<SelectedAppInspectionChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.84,
        minChildSize: 0.55,
        maxChildSize: 0.94,
        builder: (context, _) => InstalledAppPickerSheet(
          bridge: bridge,
          eduTrackPolicyText: eduTrackPolicyText,
          calmMathPolicyText: calmMathPolicyText,
        ),
      ),
    );
  }

  @override
  State<InstalledAppPickerSheet> createState() =>
      _InstalledAppPickerSheetState();
}

class _InstalledAppPickerSheetState extends State<InstalledAppPickerSheet> {
  List<InstalledAppEntry> _installedApps = const [];
  bool _isLoadingApps = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstalledApps() async {
    final apps = await widget.bridge.listLaunchableApps();
    if (!mounted) return;
    setState(() {
      _installedApps = apps;
      _isLoadingApps = false;
    });
  }

  Future<void> _inspectRealInstalledApp(InstalledAppEntry app) async {
    final snapshot =
        await widget.bridge.inspectAppSnapshot(app.packageName) ??
        AppPermissionSnapshot(
          packageName: app.packageName,
          appName: app.appName,
          requestedPermissions: const [],
          grantedPermissions: const [],
        );

    if (!mounted) return;

    Navigator.pop(
      context,
      SelectedAppInspectionChoice(
        subjectTitle: app.appName,
        sourceLabel: 'Installed on this phone',
        policyText: '',
        permissionSnapshot: snapshot,
        hasSuppliedPolicy: false,
        isSyntheticSample: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (context) {
          final l10n =
              AppLocalizations.of(context) ??
              lookupAppLocalizations(const Locale('en'));
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final semantics = context.enpriveSemantics;

          final filteredApps = _installedApps.where((a) {
            if (_searchQuery.trim().isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return a.appName.toLowerCase().contains(q) ||
                a.packageName.toLowerCase().contains(q);
          }).toList();

          final visibleApps = filteredApps.take(25).toList();

          return Material(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 8),
            child: Column(
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.btnCheckApp,
                        style: m3e.typography.emphasized.headlineMedium
                            .copyWith(
                              color: scheme.onSurface,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.tooltipClose,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        LucideIcons.x,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  l10n.checkAppSheetSubtitle,
                  style: m3e.typeScale.bodyMedium.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                // 1. Sample Classroom Apps (M3E Bento Choice Grid)
                Text(
                  l10n.trySampleKidsApp,
                  style: m3e.typography.emphasized.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SampleAppChoiceCard(
                        title: 'EduTrack',
                        subtitle: l10n.sampleEduTrackSubtitle,
                        footerTag: l10n.sampleSyntheticBadge,
                        icon: LucideIcons.graduationCap,
                        badgePair: semantics.reviewRecommended,
                        onTap: () {
                          Navigator.pop(
                            context,
                            SelectedAppInspectionChoice(
                              subjectTitle: 'EduTrack Classroom Companion',
                              sourceLabel: 'Synthetic Example',
                              policyText: widget.eduTrackPolicyText,
                              permissionSnapshot:
                                  PermissionComparator.demoEduTrackSnapshot,
                              hasSuppliedPolicy: true,
                              isSyntheticSample: true,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SampleAppChoiceCard(
                        title: 'CalmMath',
                        subtitle: l10n.sampleCalmMathSubtitle,
                        footerTag: l10n.sampleSyntheticBadge,
                        icon: LucideIcons.calculator,
                        badgePair: semantics.noConcern,
                        onTap: () {
                          Navigator.pop(
                            context,
                            SelectedAppInspectionChoice(
                              subjectTitle: 'CalmMath Abacus',
                              sourceLabel: 'Synthetic Example',
                              policyText: widget.calmMathPolicyText,
                              permissionSnapshot:
                                  PermissionComparator.demoCalmMathSnapshot,
                              hasSuppliedPolicy: true,
                              isSyntheticSample: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 2. Installed Apps on This Phone
                Text(
                  l10n.appsOnThisPhone,
                  style: m3e.typography.emphasized.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),

                M3ESearchBar(
                  controller: _searchController,
                  margin: 0,
                  focusedMargin: 0,
                  hintText: l10n.hintSearchApps,
                  leading: Icon(
                    LucideIcons.search,
                    size: 19,
                    color: scheme.onSurfaceVariant,
                  ),
                  showClearButton: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 14),

                if (_isLoadingApps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: M3ELoadingIndicator(
                        size: 36,
                        color: scheme.primary,
                      ),
                    ),
                  )
                else if (visibleApps.isEmpty)
                  EnpriveCompanionCard(
                    pose: DeniPose.thinking,
                    lodTier: DeniLodTier.compact,
                    mascotSize: 64,
                    title: l10n.appsOnThisPhone,
                    message: l10n.noMatchingApps,
                  )
                else
                  Column(
                    children: [
                      for (var idx = 0; idx < visibleApps.length; idx++) ...[
                        if (idx > 0) const SizedBox(height: 4),
                        EnpriveSegmentedCardTile(
                          index: idx,
                          totalCount: visibleApps.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          onTap: () =>
                              _inspectRealInstalledApp(visibleApps[idx]),
                          child: Row(
                            children: [
                              InstalledAppIcon(
                                key: ValueKey(visibleApps[idx].packageName),
                                packageName: visibleApps[idx].packageName,
                                bridge: widget.bridge,
                                initialBytes: visibleApps[idx].iconBytes,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  visibleApps[idx].appName,
                                  style: m3e.typography.emphasized.bodyLarge
                                      .copyWith(
                                        color: scheme.onSurface,
                                      ),
                                ),
                              ),
                              Icon(
                                LucideIcons.chevronRight,
                                color: scheme.onSurfaceVariant,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
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

class _SampleAppChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String footerTag;
  final IconData icon;
  final SemanticColorPair badgePair;
  final VoidCallback onTap;

  const _SampleAppChoiceCard({
    required this.title,
    required this.subtitle,
    required this.footerTag,
    required this.icon,
    required this.badgePair,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EnpriveBentoChoiceCard(
      title: title,
      subtitle: subtitle,
      footerTag: footerTag,
      icon: icon,
      accentColor: badgePair.foreground,
      accentBackground: badgePair.background,
      accentBorder: badgePair.border.withValues(alpha: 0.4),
      onPressed: onTap,
    );
  }
}
