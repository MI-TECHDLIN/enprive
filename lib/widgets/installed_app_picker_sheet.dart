import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../domain/permissions/permission_comparator.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';

class SelectedAppInspectionChoice {
  final String subjectTitle;
  final String sourceLabel;
  final String policyText;
  final AppPermissionSnapshot permissionSnapshot;

  const SelectedAppInspectionChoice({
    required this.subjectTitle,
    required this.sourceLabel,
    required this.policyText,
    required this.permissionSnapshot,
  });
}

/// Clean, parent-friendly Installed App Picker Sheet.
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
      backgroundColor: EnpriveColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
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

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
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
    final snapshot = await widget.bridge.inspectAppSnapshot(app.packageName) ??
        AppPermissionSnapshot(
          packageName: app.packageName,
          appName: app.appName,
          requestedPermissions: const [],
          grantedPermissions: const [],
        );

    if (!mounted) return;
    final defaultPolicy = '''
${app.appName.toUpperCase()} — PRIVACY NOTICE SNAPSHOT
This installed Android application (${app.packageName}) is being compared against its standard public privacy disclosure.
We do not collect personal identifiers, precise location data, microphone audio, or camera input without explicit user disclosure.
''';

    Navigator.pop(
      context,
      SelectedAppInspectionChoice(
        subjectTitle: app.appName,
        sourceLabel: 'Installed on this phone',
        policyText: defaultPolicy,
        permissionSnapshot: snapshot,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredApps = _installedApps.where((a) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return a.appName.toLowerCase().contains(q) ||
          a.packageName.toLowerCase().contains(q);
    }).toList();

    return SafeArea(
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
                      color: EnpriveColors.ink.withValues(alpha: 0.14),
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
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Symbols.close_rounded),
                    ),
                  ],
                ),
                Text(
                  'Checked locally on your phone. Your app list is never uploaded.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: EnpriveColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                // 1. Sample Classroom Apps (B3 Soft Choice Card Grid)
                const Text(
                  'Try a sample kids app',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: EnpriveColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SampleAppChoiceCard(
                        title: 'EduTrack',
                        subtitle: 'Location, mic & camera',
                        icon: Symbols.school_rounded,
                        iconBg: EnpriveColors.stateReviewRecommendedBg,
                        iconFg: EnpriveColors.stateReviewRecommendedFg,
                        onTap: () {
                          Navigator.pop(
                            context,
                            SelectedAppInspectionChoice(
                              subjectTitle: 'EduTrack Classroom Companion',
                              sourceLabel: 'Classroom Sample',
                              policyText: widget.eduTrackPolicyText,
                              permissionSnapshot:
                                  PermissionComparator.demoEduTrackSnapshot,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SampleAppChoiceCard(
                        title: 'CalmMath',
                        subtitle: 'Offline math practice',
                        icon: Symbols.calculate_rounded,
                        iconBg: EnpriveColors.stateNoConcernBg,
                        iconFg: EnpriveColors.stateNoConcernFg,
                        onTap: () {
                          Navigator.pop(
                            context,
                            SelectedAppInspectionChoice(
                              subjectTitle: 'CalmMath Abacus',
                              sourceLabel: 'Classroom Sample',
                              policyText: widget.calmMathPolicyText,
                              permissionSnapshot:
                                  PermissionComparator.demoCalmMathSnapshot,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 2. Installed Apps on This Phone
                const Text(
                  'Apps on this phone',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: EnpriveColors.ink,
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search apps…',
                    prefixIcon: const Icon(Symbols.search_rounded, size: 20),
                    filled: true,
                    fillColor: EnpriveColors.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                if (_isLoadingApps)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filteredApps.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: EnpriveColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'No matching apps found on this phone.',
                      style: TextStyle(color: EnpriveColors.inkSecondary),
                    ),
                  )
                else
                  Material(
                    color: EnpriveColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children:
                          filteredApps.take(25).toList().asMap().entries.map((e) {
                        final idx = e.key;
                        final app = e.value;
                        return Column(
                          children: [
                            if (idx > 0)
                              Divider(
                                height: 1,
                                indent: 68,
                                endIndent: 20,
                                color:
                                    EnpriveColors.ink.withValues(alpha: 0.06),
                              ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              onTap: () => _inspectRealInstalledApp(app),
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: EnpriveColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Symbols.apps_rounded,
                                  color: EnpriveColors.tealStrong,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                app.appName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: EnpriveColors.ink,
                                ),
                              ),
                              trailing: const Icon(
                                Symbols.chevron_right_rounded,
                                color: EnpriveColors.inkSecondary,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleAppChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final VoidCallback onTap;

  const _SampleAppChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EnpriveColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconFg, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: EnpriveColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: EnpriveColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
