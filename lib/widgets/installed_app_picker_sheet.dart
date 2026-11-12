import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../domain/permissions/permission_comparator.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'enprive_provenance_chip.dart';

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

/// Local-only Installed App Picker & Permission Inspector Sheet.
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
        sourceLabel: 'Android OS Package (${app.packageName})',
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
                      color: EnpriveColors.ink.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const EnpriveProvenanceChip(
                      source: InferenceSource.onDevice,
                      customLabel: 'Local OS Inspector',
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Symbols.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.btnCheckApp,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.permissionLimitationNotice,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: EnpriveColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                // 1. Classroom Sandbox Profiles (Selection Over Manual Input)
                Text(
                  'CLASSROOM BENCHMARK PROFILES',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: EnpriveColors.tealStrong,
                      ),
                ),
                const SizedBox(height: 10),
                _DemoAppTile(
                  title: 'EduTrack Classroom Companion',
                  subtitle:
                      '4 granted OS permissions (GPS, Mic, Camera, Ad ID) · 1 undisclosed Camera mismatch',
                  badgeLabel: 'Mismatch Demo',
                  badgeBg: EnpriveColors.stateReviewRecommendedBg,
                  badgeFg: EnpriveColors.stateReviewRecommendedFg,
                  icon: Symbols.school_rounded,
                  onTap: () {
                    Navigator.pop(
                      context,
                      SelectedAppInspectionChoice(
                        subjectTitle: 'EduTrack Classroom Companion',
                        sourceLabel:
                            'com.edutrack.classroom.demo + Policy v2026.11-R2',
                        policyText: widget.eduTrackPolicyText,
                        permissionSnapshot:
                            PermissionComparator.demoEduTrackSnapshot,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _DemoAppTile(
                  title: 'CalmMath Abacus',
                  subtitle:
                      '0 sensitive OS permissions · Local storage only',
                  badgeLabel: 'Aligned Demo',
                  badgeBg: EnpriveColors.stateNoConcernBg,
                  badgeFg: EnpriveColors.stateNoConcernFg,
                  icon: Symbols.calculate_rounded,
                  onTap: () {
                    Navigator.pop(
                      context,
                      SelectedAppInspectionChoice(
                        subjectTitle: 'CalmMath Abacus',
                        sourceLabel:
                            'com.calmmath.abacus.demo + Policy v2026.11-LOCAL',
                        policyText: widget.calmMathPolicyText,
                        permissionSnapshot:
                            PermissionComparator.demoCalmMathSnapshot,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 2. Live Installed Apps on This Phone
                Row(
                  children: [
                    Text(
                      'INSTALLED ON THIS PHONE (${_installedApps.length})',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: EnpriveColors.inkSecondary,
                          ),
                    ),
                    const Spacer(),
                    const Icon(
                      Symbols.lock_rounded,
                      size: 14,
                      color: EnpriveColors.tealStrong,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Never sent to cloud',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: EnpriveColors.tealStrong,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Filter installed apps by name or package…',
                    prefixIcon: const Icon(Symbols.search_rounded, size: 20),
                    filled: true,
                    fillColor: EnpriveColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: EnpriveColors.ink.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (_isLoadingApps)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filteredApps.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: EnpriveColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'No matching launchable apps found on this device.',
                      style: TextStyle(color: EnpriveColors.inkSecondary),
                    ),
                  )
                else
                  ...filteredApps.take(25).map((app) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _inspectRealInstalledApp(app),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: EnpriveColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: EnpriveColors.ink.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      EnpriveColors.teal.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Symbols.android_rounded,
                                  color: EnpriveColors.tealStrong,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.appName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                        color: EnpriveColors.ink,
                                      ),
                                    ),
                                    Text(
                                      app.packageName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: EnpriveColors.inkSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Symbols.manage_search_rounded,
                                color: EnpriveColors.tealStrong,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoAppTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeFg;
  final IconData icon;
  final VoidCallback onTap;

  const _DemoAppTile({
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeFg,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EnpriveColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: EnpriveColors.teal.withValues(alpha: 0.18),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: badgeFg, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: EnpriveColors.ink,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: badgeFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: EnpriveColors.inkSecondary,
                      height: 1.35,
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
