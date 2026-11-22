import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../services/intake/policy_intake_coordinator.dart';
import '../services/network/policy_url_retriever.dart';
import '../services/platform/companion_bridge.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/m3e/enprive_m3e_components.dart';
import '../widgets/navigation/enprive_navigation_shell.dart';
import 'review_result_screen.dart';

enum _ReceiptFilter {
  all,
  reviewRecommended,
  noConcern,
}

String _formatReceiptTimestamp(BuildContext context, DateTime dt) {
  final localeTag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
  try {
    return DateFormat.MMMd(localeTag).add_jm().format(dt);
  } catch (_) {
    return DateFormat('MMM d, h:mm a').format(dt);
  }
}

/// Material 3 Expressive Receipts Archive Screen:
/// - Editorial header with toggleable `M3ESearchBar`
/// - `M3EChip` filter pills (`All · Review · No concern`)
/// - `M3ECard` archival receipt cards with `SourceSerif4` summary and AAA action strip
class ReceiptsScreen extends StatefulWidget {
  final List<PolicyReviewReceipt> receipts;
  final ReviewCoordinator coordinator;
  final FutureOr<void> Function(String) onDeleteReceipt;
  final FutureOr<void> Function(PolicyReviewReceipt)? onSaveReceipt;
  final ReceiptRepository? receiptRepository;
  final bool Function(String receiptId)? isReceiptSaved;
  final VoidCallback onStartReviewRequested;
  final ScrollController? scrollController;
  final VoidCallback? onOpenSettings;
  final bool isActiveTab;
  final PolicyUrlRetriever? urlRetriever;
  final PolicyIntakeCoordinator? intakeCoordinator;
  final CompanionBridge? companionBridge;
  final ReviewExitGuardController? reviewExitGuard;

  const ReceiptsScreen({
    super.key,
    required this.receipts,
    required this.coordinator,
    required this.onDeleteReceipt,
    this.onSaveReceipt,
    this.receiptRepository,
    this.isReceiptSaved,
    required this.onStartReviewRequested,
    this.scrollController,
    this.onOpenSettings,
    this.isActiveTab = false,
    this.urlRetriever,
    this.intakeCoordinator,
    this.companionBridge,
    this.reviewExitGuard,
  });

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final TextEditingController _searchController = TextEditingController();
  _ReceiptFilter _activeFilter = _ReceiptFilter.all;
  bool _isSearching = false;
  String _searchQuery = '';

  /// Receipts removed from view while their Undo snackbar is showing. The
  /// stored receipt is deleted through [ReceiptsScreen.onDeleteReceipt] only
  /// once the snackbar closes without Undo.
  final Set<String> _pendingDeleteIds = <String>{};

  void _requestDelete(PolicyReviewReceipt receipt, AppLocalizations l10n) {
    if (!_pendingDeleteIds.add(receipt.id)) return;
    setState(() {});
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.receiptDeletedSnack(receipt.subjectTitle)),
        action: SnackBarAction(label: l10n.btnUndo, onPressed: () {}),
      ),
    );
    unawaited(
      controller.closed.then((reason) async {
        if (reason == SnackBarClosedReason.action) {
          if (mounted) setState(() => _pendingDeleteIds.remove(receipt.id));
          return;
        }
        await widget.onDeleteReceipt(receipt.id);
        if (mounted) setState(() => _pendingDeleteIds.remove(receipt.id));
      }),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PolicyReviewReceipt> get _filteredReceipts {
    final query = _searchQuery.trim().toLowerCase();
    return widget.receipts.where((r) {
      if (_pendingDeleteIds.contains(r.id)) return false;
      final matchesFilter = switch (_activeFilter) {
        _ReceiptFilter.all => true,
        _ReceiptFilter.reviewRecommended =>
          r.overallState == ReviewOverallState.reviewRecommended,
        _ReceiptFilter.noConcern =>
          r.overallState == ReviewOverallState.noConcern,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      return r.subjectTitle.toLowerCase().contains(query) ||
          r.summary.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  String _filterLabel(AppLocalizations l10n, _ReceiptFilter filter) {
    return switch (filter) {
      _ReceiptFilter.all => l10n.filterAll,
      _ReceiptFilter.reviewRecommended => l10n.filterReview,
      _ReceiptFilter.noConcern => l10n.filterNoConcern,
    };
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final filtered = _filteredReceipts;
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;

          return SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: EnpriveSpacing.marginFor(
                      MediaQuery.sizeOf(context).width,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Single clean top header row: Title on start, Search + optional Settings on end
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.receiptsTitle,
                              style: m3e.typography.emphasized.headlineMedium
                                  .copyWith(color: scheme.onSurface),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.tooltipSearch,
                            onPressed: () {
                              setState(() {
                                _isSearching = !_isSearching;
                                if (!_isSearching) {
                                  _searchController.clear();
                                  _searchQuery = '';
                                }
                              });
                            },
                            isSelected: _isSearching,
                            style: IconButton.styleFrom(
                              backgroundColor: _isSearching
                                  ? scheme.secondaryContainer
                                  : null,
                              foregroundColor: _isSearching
                                  ? scheme.onSecondaryContainer
                                  : scheme.onSurfaceVariant,
                              minimumSize: const Size(48, 48),
                              tapTargetSize: MaterialTapTargetSize.padded,
                            ),
                            icon: Icon(
                              _isSearching ? LucideIcons.x : LucideIcons.search,
                              size: 22,
                            ),
                          ),
                          if (widget.onOpenSettings != null) ...[
                            EnpriveSettingsAppBarButton(
                              key: widget.isActiveTab
                                  ? const Key('nav_settings_btn')
                                  : null,
                              tooltip: l10n.navSettings,
                              onPressed: widget.onOpenSettings!,
                            ),
                          ],
                        ],
                      ),

                      if (_isSearching) ...[
                        const SizedBox(height: 8),
                        M3ESearchBar(
                          controller: _searchController,
                          hintText: l10n.hintSearchReceipts,
                          leading: Icon(
                            LucideIcons.search,
                            size: 19,
                            color: scheme.onSurfaceVariant,
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // M3E Filter Chips Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children: _ReceiptFilter.values.map((filter) {
                          final isSelected = _activeFilter == filter;
                          return EnpriveFilterChip(
                            selected: isSelected,
                            label: _filterLabel(l10n, filter),
                            onPressed: () =>
                                setState(() => _activeFilter = filter),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState(context, l10n, m3e)
                            : ListView.separated(
                                controller: widget.scrollController,
                                padding: const EdgeInsets.only(bottom: 28),
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final receipt = filtered[index];
                                  return Dismissible(
                                    key: ValueKey<String>(
                                      'receipt_dismissible_${receipt.id}',
                                    ),
                                    direction: DismissDirection.endToStart,
                                    background: _DeleteSwipeBackground(
                                      label: l10n.btnDelete,
                                    ),
                                    onDismissed: (_) =>
                                        _requestDelete(receipt, l10n),
                                    child: _M3EReceiptCard(
                                    receipt: receipt,
                                    l10n: l10n,
                                    onOpen: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => ReviewResultScreen(
                                            receipt: receipt,
                                            coordinator: widget.coordinator,
                                            urlRetriever: widget.urlRetriever,
                                            intakeCoordinator:
                                                widget.intakeCoordinator,
                                            companionBridge:
                                                widget.companionBridge,
                                            exitGuardController:
                                                widget.reviewExitGuard,
                                            onSaveReceipt: widget.onSaveReceipt,
                                            onDeleteReceipt:
                                                widget.onDeleteReceipt,
                                            savedReceipts:
                                                List<
                                                  PolicyReviewReceipt
                                                >.unmodifiable(widget.receipts),
                                            receiptRepository:
                                                widget.receiptRepository,
                                            isReceiptSaved:
                                                widget.isReceiptSaved ??
                                                (id) => widget.receipts.any(
                                                  (r) => r.id == id,
                                                ),
                                            isInitiallySaved: true,
                                          ),
                                        ),
                                      );
                                    },
                                    onDelete: () =>
                                        _requestDelete(receipt, l10n),
                                  ),
                                  );
                                },
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

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    M3EThemeData m3e,
  ) {
    final isFilteredEmpty = widget.receipts.isNotEmpty;
    final scheme = m3e.colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DeniAnimatedMascot(
                size: 96,
                pose: DeniPose.carryReceipt,
              ),
              const SizedBox(height: 20),
              Text(
                isFilteredEmpty
                    ? l10n.emptyFilteredTitle
                    : l10n.emptyReceiptsTitle,
                textAlign: TextAlign.center,
                style: m3e.typography.emphasized.headlineSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isFilteredEmpty
                    ? l10n.emptyFilteredBody
                    : l10n.emptyReceiptsBody,
                textAlign: TextAlign.center,
                style: m3e.typeScale.bodyMedium.copyWith(
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (!isFilteredEmpty) ...[
                const SizedBox(height: 24),
                EnpriveTactileButton(
                  label: l10n.btnStartReview,
                  onPressed: widget.onStartReviewRequested,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _M3EReceiptCard extends StatelessWidget {
  final PolicyReviewReceipt receipt;
  final AppLocalizations l10n;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _M3EReceiptCard({
    required this.receipt,
    required this.l10n,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isConcern =
        receipt.overallState == ReviewOverallState.reviewRecommended;
    final stateLabel = receipt.isPermissionOnlyInspection
        ? l10n.permissionInspectionTitle
        : (isConcern
              ? l10n.stateReviewRecommended
              : (receipt.overallState == ReviewOverallState.insufficientEvidence
                    ? l10n.statusUnverified
                    : l10n.stateNoConcern));
    final formattedDate = _formatReceiptTimestamp(context, receipt.createdAt);

    return EnpriveReceiptCard(
      receipt: receipt,
      stateBadgeLabel: stateLabel,
      metaLine: '${receipt.sourceLabel} · $formattedDate',
      openLabel: l10n.btnOpenReceipt,
      deleteTooltip: l10n.btnDelete,
      findingsLabel: l10n.statFindings,
      verifiedLabel: l10n.statVerified,
      deviceObservedLabel: l10n.statusDeviceObserved,
      onOpen: onOpen,
      onDelete: onDelete,
    );
  }
}

/// Revealed behind a receipt while it is swiped toward delete.
class _DeleteSwipeBackground extends StatelessWidget {
  final String label;

  const _DeleteSwipeBackground({required this.label});

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.trash2, size: 20, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Text(
            label,
            style: m3e.typeScale.labelLarge.copyWith(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
