import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/permissions/permission_comparator.dart';
import '../domain/review/app_policy_association.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../services/storage/receipt_repository.dart';
import 'deni_animated_mascot.dart';
import 'installed_app_icon.dart';
import 'm3e/enprive_m3e_components.dart';

/// Filter category for installed Android applications shown in
/// [InstalledAppPickerSheet].
enum InstalledAppFilter { all, downloaded, system }

/// Evidence-neutral review status derived strictly from locally saved
/// [PolicyReviewReceipt]s — never implies safety, trust, or verified ownership.
enum InstalledAppReviewStatus {
  policyReviewSaved,
  permissionsInspected,
  notReviewed,
}

class SelectedAppInspectionChoice {
  final String subjectTitle;
  final String sourceLabel;
  final String policyText;
  final AppPermissionSnapshot permissionSnapshot;
  final List<AppIdentityCandidate> peerCandidates;
  final bool hasSuppliedPolicy;
  final bool isSyntheticSample;

  const SelectedAppInspectionChoice({
    required this.subjectTitle,
    required this.sourceLabel,
    required this.policyText,
    required this.permissionSnapshot,
    this.peerCandidates = const <AppIdentityCandidate>[],
    this.hasSuppliedPolicy = false,
    this.isSyntheticSample = false,
  });
}

/// Pure on-device helper logic powering search, filtering, receipt-backed
/// status mapping, and "Recently checked" derivation for [InstalledAppPickerSheet].
class InstalledAppPickerModel {
  InstalledAppPickerModel._();

  static final Set<String> syntheticSamplePackages = <String>{
    PermissionComparator.demoEduTrackSnapshot.packageName.toLowerCase(),
    PermissionComparator.demoCalmMathSnapshot.packageName.toLowerCase(),
  };

  /// Indexes the latest saved receipt per unique Android package identifier
  /// strictly from in-memory persisted [PolicyReviewReceipt] records.
  static Map<String, PolicyReviewReceipt> latestSavedReceiptByPackage(
    List<PolicyReviewReceipt> savedReceipts,
  ) {
    final latestByPkg = <String, PolicyReviewReceipt>{};
    for (final receipt in savedReceipts) {
      final rawPkg = receipt.permissionReport?.snapshot.packageName;
      final pkg = rawPkg?.trim().toLowerCase();
      if (pkg == null || pkg.isEmpty) continue;

      final existing = latestByPkg[pkg];
      if (existing == null) {
        latestByPkg[pkg] = receipt;
        continue;
      }

      final dateCompare = receipt.createdAt.compareTo(existing.createdAt);
      if (dateCompare > 0 ||
          (dateCompare == 0 &&
              !hasCompletedPolicyReview(existing) &&
              hasCompletedPolicyReview(receipt))) {
        latestByPkg[pkg] = receipt;
      }
    }
    return Map<String, PolicyReviewReceipt>.unmodifiable(latestByPkg);
  }

  /// Resolves an evidence-neutral status badge for [packageName].
  static InstalledAppReviewStatus statusForPackage(
    String packageName,
    Map<String, PolicyReviewReceipt> latestByPackage,
  ) {
    final latest = latestByPackage[packageName.trim().toLowerCase()];
    if (latest == null) {
      return InstalledAppReviewStatus.notReviewed;
    }
    if (hasCompletedPolicyReview(latest)) {
      return InstalledAppReviewStatus.policyReviewSaved;
    }
    // Permission-only inspections and reviews whose policy material was
    // insufficient (or whose inference failed) only evidence that the app's
    // permissions were inspected; never claim a saved policy review.
    return InstalledAppReviewStatus.permissionsInspected;
  }

  /// Whether [receipt] records a completed, evidence-backed policy review.
  ///
  /// Only [ReviewDiagnosticKind.validated] and
  /// [ReviewDiagnosticKind.cloudUnavailableLocalFallback] receipts that carry
  /// non-empty policy snapshot text and are not permission-only inspections
  /// qualify.
  static bool hasCompletedPolicyReview(PolicyReviewReceipt receipt) {
    if (receipt.isPermissionOnlyInspection) return false;
    if (receipt.snapshotText.trim().isEmpty) return false;
    return receipt.diagnosticKind == ReviewDiagnosticKind.validated ||
        receipt.diagnosticKind ==
            ReviewDiagnosticKind.cloudUnavailableLocalFallback;
  }

  /// Derives up to [maxCount] unique recently checked installed applications
  /// from [latestByPackage], excluding synthetic samples and uninstalled apps.
  static List<InstalledAppEntry> recentCheckedApps({
    required List<InstalledAppEntry> installedApps,
    required Map<String, PolicyReviewReceipt> latestByPackage,
    int maxCount = 3,
  }) {
    if (installedApps.isEmpty || latestByPackage.isEmpty || maxCount <= 0) {
      return const <InstalledAppEntry>[];
    }

    final installedByPkg = <String, InstalledAppEntry>{};
    for (final app in installedApps) {
      final key = app.packageName.trim().toLowerCase();
      if (key.isEmpty) continue;
      installedByPkg.putIfAbsent(key, () => app);
    }

    final sortedEntries = latestByPackage.entries.toList()
      ..sort((a, b) {
        final dateCmp = b.value.createdAt.compareTo(a.value.createdAt);
        if (dateCmp != 0) return dateCmp;
        final aCompleted = hasCompletedPolicyReview(a.value);
        final bCompleted = hasCompletedPolicyReview(b.value);
        if (aCompleted != bCompleted) {
          return aCompleted ? -1 : 1;
        }
        return a.key.compareTo(b.key);
      });

    final recent = <InstalledAppEntry>[];
    final seenPackages = <String>{};
    for (final entry in sortedEntries) {
      final pkg = entry.key;
      if (syntheticSamplePackages.contains(pkg)) continue;
      final installedMatch = installedByPkg[pkg];
      if (installedMatch == null) continue;
      if (seenPackages.add(pkg)) {
        recent.add(installedMatch);
        if (recent.length >= maxCount) break;
      }
    }
    return List<InstalledAppEntry>.unmodifiable(recent);
  }

  /// Applies [filter] (`all`, `downloaded`, `system`) and case-insensitive
  /// substring matching against both display name and full package identifier.
  static List<InstalledAppEntry> filterApps({
    required List<InstalledAppEntry> installedApps,
    required InstalledAppFilter filter,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return installedApps
        .where((app) {
          switch (filter) {
            case InstalledAppFilter.all:
              break;
            case InstalledAppFilter.downloaded:
              if (app.isSystemApp) return false;
            case InstalledAppFilter.system:
              if (!app.isSystemApp) return false;
          }
          if (normalizedQuery.isEmpty) return true;
          return app.appName.toLowerCase().contains(normalizedQuery) ||
              app.packageName.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  /// Maps local installed apps into pure D5.3-B [AppIdentityCandidate] records
  /// strictly on-device for downstream peer-name collision detection.
  static List<AppIdentityCandidate> toIdentityCandidates(
    List<InstalledAppEntry> installedApps,
  ) {
    return installedApps
        .where((app) => app.packageName.trim().isNotEmpty)
        .map(
          (app) => AppIdentityCandidate(
            packageName: app.packageName,
            appName: app.appName,
          ),
        )
        .toList(growable: false);
  }
}

/// Material 3 Expressive Installed App Picker Sheet.
///
/// Queries Android `PackageManager` once per open strictly on-device
/// (`listLaunchableApps` and `inspectSelectedApp`). Installed app lists and
/// saved receipt statuses stay local and never leave the phone.
class InstalledAppPickerSheet extends StatefulWidget {
  final HybridAiBridge bridge;
  final String eduTrackPolicyText;
  final String calmMathPolicyText;
  final List<PolicyReviewReceipt> savedReceipts;
  final ReceiptRepository? receiptRepository;
  final ScrollController? scrollController;
  final String? titleOverride;
  final String? subtitleOverride;
  final String? selectedPackageName;

  const InstalledAppPickerSheet({
    super.key,
    required this.bridge,
    required this.eduTrackPolicyText,
    required this.calmMathPolicyText,
    this.savedReceipts = const [],
    this.receiptRepository,
    this.scrollController,
    this.titleOverride,
    this.subtitleOverride,
    this.selectedPackageName,
  });

  static Future<SelectedAppInspectionChoice?> show(
    BuildContext context, {
    required HybridAiBridge bridge,
    required String eduTrackPolicyText,
    required String calmMathPolicyText,
    List<PolicyReviewReceipt> savedReceipts = const [],
    ReceiptRepository? receiptRepository,
    String? titleOverride,
    String? subtitleOverride,
    String? selectedPackageName,
  }) {
    return showModalBottomSheet<SelectedAppInspectionChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.84,
        minChildSize: 0.55,
        maxChildSize: 0.94,
        builder: (context, scrollController) => InstalledAppPickerSheet(
          bridge: bridge,
          eduTrackPolicyText: eduTrackPolicyText,
          calmMathPolicyText: calmMathPolicyText,
          savedReceipts: savedReceipts,
          receiptRepository: receiptRepository,
          scrollController: scrollController,
          titleOverride: titleOverride,
          subtitleOverride: subtitleOverride,
          selectedPackageName: selectedPackageName,
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
  List<PolicyReviewReceipt> _effectiveReceipts = const [];
  Map<String, PolicyReviewReceipt> _latestByPackage = const {};
  List<InstalledAppEntry> _recentApps = const [];
  bool _isLoadingApps = true;
  String _searchQuery = '';
  InstalledAppFilter _activeFilter = InstalledAppFilter.all;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _effectiveReceipts = widget.savedReceipts;
    _latestByPackage = InstalledAppPickerModel.latestSavedReceiptByPackage(
      _effectiveReceipts,
    );
    _loadInstalledAppsAndReceipts();
  }

  @override
  void didUpdateWidget(covariant InstalledAppPickerSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.savedReceipts != oldWidget.savedReceipts &&
        (widget.savedReceipts.isNotEmpty || widget.receiptRepository == null)) {
      _effectiveReceipts = widget.savedReceipts;
      _recomputeReceiptDerivedState();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    if (_searchQuery.isNotEmpty) {
      setState(() => _searchQuery = '');
    }
  }

  void _recomputeReceiptDerivedState() {
    _latestByPackage = InstalledAppPickerModel.latestSavedReceiptByPackage(
      _effectiveReceipts,
    );
    _recentApps = InstalledAppPickerModel.recentCheckedApps(
      installedApps: _installedApps,
      latestByPackage: _latestByPackage,
    );
  }

  Future<void> _loadInstalledAppsAndReceipts() async {
    final appsFuture = widget.bridge.listLaunchableApps();
    Future<List<PolicyReviewReceipt>>? repoFuture;
    if (widget.savedReceipts.isEmpty && widget.receiptRepository != null) {
      repoFuture = widget.receiptRepository!.loadReceipts();
    }

    final apps = await appsFuture;
    final loadedReceipts = repoFuture != null
        ? await repoFuture
        : widget.savedReceipts;

    if (!mounted) return;
    setState(() {
      _installedApps = apps;
      _effectiveReceipts = loadedReceipts;
      _recomputeReceiptDerivedState();
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
        peerCandidates: InstalledAppPickerModel.toIdentityCandidates(
          _installedApps,
        ),
        hasSuppliedPolicy: false,
        isSyntheticSample: false,
      ),
    );
  }

  void _selectEmptyStateSampleFixture() {
    final useEduTrack = widget.eduTrackPolicyText.trim().isNotEmpty;
    final policyText = useEduTrack
        ? widget.eduTrackPolicyText
        : widget.calmMathPolicyText;
    final snapshot = useEduTrack
        ? PermissionComparator.demoEduTrackSnapshot
        : PermissionComparator.demoCalmMathSnapshot;
    Navigator.pop(
      context,
      SelectedAppInspectionChoice(
        subjectTitle: snapshot.appName,
        sourceLabel: 'Synthetic Example',
        policyText: policyText,
        permissionSnapshot: snapshot,
        hasSuppliedPolicy: policyText.trim().isNotEmpty,
        isSyntheticSample: true,
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
          final filteredApps = InstalledAppPickerModel.filterApps(
            installedApps: _installedApps,
            filter: _activeFilter,
            query: _searchQuery,
          );
          final showRecentSection =
              !_isLoadingApps &&
              _searchQuery.trim().isEmpty &&
              _activeFilter == InstalledAppFilter.all &&
              _recentApps.isNotEmpty;
          final hasOptionalSampleText =
              widget.eduTrackPolicyText.trim().isNotEmpty ||
              widget.calmMathPolicyText.trim().isNotEmpty;

          return Material(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 600;
                  final horizontalPadding = isCompact ? 16.0 : 24.0;
                  final headerBottomPadding = isCompact ? 10.0 : 12.0;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              12,
                              isCompact ? 12 : 16,
                              headerBottomPadding,
                            ),
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
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.titleOverride ??
                                            l10n.btnCheckApp,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: m3e
                                            .typography
                                            .emphasized
                                            .headlineMedium
                                            .copyWith(color: scheme.onSurface),
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minWidth: EnpriveSpacing.minTouchTarget,
                                        minHeight:
                                            EnpriveSpacing.minTouchTarget,
                                      ),
                                      child: IconButton(
                                        tooltip: l10n.tooltipClose,
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(
                                          LucideIcons.x,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.subtitleOverride ??
                                      l10n.checkAppSheetSubtitle,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: m3e.typeScale.bodyMedium.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                M3ESearchBar(
                                  key: const Key('app_picker_search_bar'),
                                  controller: _searchController,
                                  margin: 0,
                                  focusedMargin: 0,
                                  hintText: l10n.appPickerSearchHint,
                                  leading: Icon(
                                    LucideIcons.search,
                                    size: 19,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  showClearButton: false,
                                  trailing: _searchQuery.isNotEmpty
                                      ? <Widget>[
                                          IconButton(
                                            key: const Key(
                                              'app_picker_clear_search_btn',
                                            ),
                                            tooltip: l10n.tooltipClearSearch,
                                            onPressed: _clearSearch,
                                            constraints: const BoxConstraints(
                                              minWidth:
                                                  EnpriveSpacing.minTouchTarget,
                                              minHeight:
                                                  EnpriveSpacing.minTouchTarget,
                                            ),
                                            icon: Icon(
                                              LucideIcons.x,
                                              size: 19,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ]
                                      : null,
                                  onChanged: (val) =>
                                      setState(() => _searchQuery = val),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 2,
                                  children: [
                                    EnpriveFilterChip(
                                      key: const Key('app_picker_filter_all'),
                                      label: l10n.appPickerFilterAll,
                                      selected:
                                          _activeFilter ==
                                          InstalledAppFilter.all,
                                      onPressed: () => setState(
                                        () => _activeFilter =
                                            InstalledAppFilter.all,
                                      ),
                                    ),
                                    EnpriveFilterChip(
                                      key: const Key(
                                        'app_picker_filter_downloaded',
                                      ),
                                      label: l10n.appPickerFilterDownloaded,
                                      selected:
                                          _activeFilter ==
                                          InstalledAppFilter.downloaded,
                                      onPressed: () => setState(
                                        () => _activeFilter =
                                            InstalledAppFilter.downloaded,
                                      ),
                                    ),
                                    EnpriveFilterChip(
                                      key: const Key(
                                        'app_picker_filter_system',
                                      ),
                                      label: l10n.appPickerFilterSystem,
                                      selected:
                                          _activeFilter ==
                                          InstalledAppFilter.system,
                                      onPressed: () => setState(
                                        () => _activeFilter =
                                            InstalledAppFilter.system,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildScrollableBody(
                              context: context,
                              l10n: l10n,
                              m3e: m3e,
                              scheme: scheme,
                              horizontalPadding: horizontalPadding,
                              filteredApps: filteredApps,
                              showRecentSection: showRecentSection,
                              hasOptionalSampleText: hasOptionalSampleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScrollableBody({
    required BuildContext context,
    required AppLocalizations l10n,
    required M3EThemeData m3e,
    required M3EColorScheme scheme,
    required double horizontalPadding,
    required List<InstalledAppEntry> filteredApps,
    required bool showRecentSection,
    required bool hasOptionalSampleText,
  }) {
    if (_isLoadingApps) {
      return CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: M3ELoadingIndicator(size: 36, color: scheme.primary),
              ),
            ),
          ),
        ],
      );
    }

    if (_installedApps.isEmpty) {
      return CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              4,
              horizontalPadding,
              24,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EnpriveCompanionCard(
                    key: const Key('app_picker_empty_installed_card'),
                    pose: DeniPose.thinking,
                    lodTier: DeniLodTier.compact,
                    mascotSize: 64,
                    title: l10n.appPickerEmptyInstalledTitle,
                    message: l10n.appPickerEmptyInstalledBody,
                  ),
                  if (hasOptionalSampleText) ...[
                    const SizedBox(height: 12),
                    _CompactEmptySampleAction(
                      key: const Key('app_picker_empty_sample_action'),
                      label: l10n.trySampleCheck,
                      badgeText: l10n.sampleSyntheticBadge,
                      onTap: _selectEmptyStateSampleFixture,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (filteredApps.isEmpty) {
      return CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              4,
              horizontalPadding,
              24,
            ),
            sliver: SliverToBoxAdapter(
              child: EnpriveCompanionCard(
                key: const Key('app_picker_no_matches_card'),
                pose: DeniPose.thinking,
                lodTier: DeniLodTier.compact,
                mascotSize: 64,
                title: l10n.appsOnThisPhone,
                message: l10n.noMatchingApps,
              ),
            ),
          ),
        ],
      );
    }

    final selectedPkgLower = widget.selectedPackageName?.trim().toLowerCase();
    bool isSelectedPackage(String packageName) =>
        selectedPkgLower != null &&
        selectedPkgLower.isNotEmpty &&
        packageName.trim().toLowerCase() == selectedPkgLower;

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        if (showRecentSection) ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              4,
              horizontalPadding,
              10,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                key: const Key('app_picker_recent_section'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appPickerRecentlyChecked,
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var idx = 0; idx < _recentApps.length; idx++) ...[
                    if (idx > 0) const SizedBox(height: 4),
                    _InstalledAppRowTile(
                      key: ValueKey(
                        'app_picker_recent_row_${_recentApps[idx].packageName}',
                      ),
                      iconKey: ValueKey(
                        'recent_icon_${_recentApps[idx].packageName}',
                      ),
                      app: _recentApps[idx],
                      bridge: widget.bridge,
                      reviewStatus: InstalledAppPickerModel.statusForPackage(
                        _recentApps[idx].packageName,
                        _latestByPackage,
                      ),
                      isCurrentlyLinked: isSelectedPackage(
                        _recentApps[idx].packageName,
                      ),
                      index: idx,
                      totalCount: _recentApps.length,
                      onTap: () => _inspectRealInstalledApp(_recentApps[idx]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
        ],
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            showRecentSection ? 0 : 4,
            horizontalPadding,
            10,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.appsOnThisPhone,
              style: m3e.typography.emphasized.titleMedium.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            24,
          ),
          sliver: SliverList.builder(
            itemCount: filteredApps.length,
            itemBuilder: (context, idx) {
              final app = filteredApps[idx];
              return Padding(
                padding: EdgeInsets.only(top: idx > 0 ? 4 : 0),
                child: _InstalledAppRowTile(
                  key: ValueKey('app_picker_row_${app.packageName}'),
                  iconKey: ValueKey(app.packageName),
                  app: app,
                  bridge: widget.bridge,
                  reviewStatus: InstalledAppPickerModel.statusForPackage(
                    app.packageName,
                    _latestByPackage,
                  ),
                  isCurrentlyLinked: isSelectedPackage(app.packageName),
                  index: idx,
                  totalCount: filteredApps.length,
                  onTap: () => _inspectRealInstalledApp(app),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InstalledAppRowTile extends StatelessWidget {
  final Key? iconKey;
  final InstalledAppEntry app;
  final HybridAiBridge bridge;
  final InstalledAppReviewStatus reviewStatus;
  final bool isCurrentlyLinked;
  final int index;
  final int totalCount;
  final VoidCallback onTap;

  const _InstalledAppRowTile({
    super.key,
    this.iconKey,
    required this.app,
    required this.bridge,
    required this.reviewStatus,
    this.isCurrentlyLinked = false,
    required this.index,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final statusLabel = switch (reviewStatus) {
      InstalledAppReviewStatus.policyReviewSaved =>
        l10n.appPickerStatusPolicySaved,
      InstalledAppReviewStatus.permissionsInspected =>
        l10n.appPickerStatusPermissionsInspected,
      InstalledAppReviewStatus.notReviewed => l10n.appPickerStatusNotReviewed,
    };

    final curatedSemantics = isCurrentlyLinked
        ? '${app.appName}, ${l10n.appIdPrefix}: ${app.packageName}, $statusLabel, ${l10n.linkedAppCurrentlySelectedBadge}'
        : '${app.appName}, ${l10n.appIdPrefix}: ${app.packageName}, $statusLabel';

    return EnpriveSegmentedCardTile(
      index: index,
      totalCount: totalCount,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      semanticLabel: curatedSemantics,
      onTap: onTap,
      // The curated parent label already announces name, package and status;
      // exclude the visual children so TalkBack reads them exactly once.
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: EnpriveSpacing.minTouchTarget,
          ),
          child: Row(
            children: [
              InstalledAppIcon(
                key: iconKey,
                packageName: app.packageName,
                bridge: bridge,
                initialBytes: app.iconBytes,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      app.appName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: m3e.typography.emphasized.bodyLarge.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${l10n.appIdPrefix}: ${app.packageName}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isRtl ? TextAlign.right : TextAlign.left,
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (isCurrentlyLinked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(
                                EnpriveRadii.chip,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.link,
                                  size: 12,
                                  color: scheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.linkedAppCurrentlySelectedBadge,
                                  style: m3e.typeScale.labelSmall.copyWith(
                                    color: scheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _NeutralStatusIndicator(
                          reviewStatus: reviewStatus,
                          label: statusLabel,
                          isDark: isDark,
                          surfaces: surfaces,
                          scheme: scheme,
                          typeScale: m3e.typeScale,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isRtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
                color: scheme.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeutralStatusIndicator extends StatelessWidget {
  final InstalledAppReviewStatus reviewStatus;
  final String label;
  final bool isDark;
  final EnpriveSurfaceTokens surfaces;
  final M3EColorScheme scheme;
  final M3ETypeScale typeScale;

  const _NeutralStatusIndicator({
    required this.reviewStatus,
    required this.label,
    required this.isDark,
    required this.surfaces,
    required this.scheme,
    required this.typeScale,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewStatus == InstalledAppReviewStatus.notReviewed) {
      return Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: typeScale.labelSmall.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    final isPolicySaved =
        reviewStatus == InstalledAppReviewStatus.policyReviewSaved;
    final bgColor = isPolicySaved
        ? (isDark ? scheme.surfaceContainerHigh : surfaces.cardMuted)
        : surfaces.canvas;
    final fgColor = isPolicySaved ? scheme.onSurface : scheme.onSurfaceVariant;
    final iconData = isPolicySaved
        ? LucideIcons.fileText
        : LucideIcons.slidersHorizontal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: surfaces.strongBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 12, color: fgColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typeScale.labelSmall.copyWith(
                color: fgColor,
                fontWeight: isPolicySaved ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactEmptySampleAction extends StatelessWidget {
  final String label;
  final String badgeText;
  final VoidCallback onTap;

  const _CompactEmptySampleAction({
    super.key,
    required this.label,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.outlined,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      semanticLabel: '$label, $badgeText',
      onPressed: onTap,
      // Curated parent label covers both lines; avoid duplicate announcement.
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: EnpriveSpacing.minTouchTarget,
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.graduationCap,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: m3e.typography.emphasized.labelLarge.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      badgeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: m3e.typeScale.labelSmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isRtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
