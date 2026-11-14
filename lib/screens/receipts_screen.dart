import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_provenance_chip.dart';
import '../widgets/enprive_tactile_button.dart';
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
  final ValueChanged<String> onDeleteReceipt;
  final VoidCallback onStartReviewRequested;

  const ReceiptsScreen({
    super.key,
    required this.receipts,
    required this.coordinator,
    required this.onDeleteReceipt,
    required this.onStartReviewRequested,
  });

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final TextEditingController _searchController = TextEditingController();
  _ReceiptFilter _activeFilter = _ReceiptFilter.all;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PolicyReviewReceipt> get _filteredReceipts {
    final query = _searchQuery.trim().toLowerCase();
    return widget.receipts.where((r) {
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Top Header Row: Title on left, Search toggle on right
                  Row(
                    children: [
                      Text(
                        l10n.receiptsTitle,
                        style: m3e.typography.emphasized.headlineMedium.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
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
                        icon: Icon(
                          _isSearching ? LucideIcons.x : LucideIcons.search,
                          size: 20,
                          color: scheme.onSurface,
                        ),
                      ),
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
                    runSpacing: 8,
                    children: _ReceiptFilter.values.map((filter) {
                      final isSelected = _activeFilter == filter;
                      return M3EChip(
                        selected: isSelected,
                        label: _filterLabel(l10n, filter),
                        onPressed: () => setState(() => _activeFilter = filter),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmptyState(context, l10n, m3e)
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final receipt = filtered[index];
                              return _M3EReceiptCard(
                                receipt: receipt,
                                l10n: l10n,
                                onOpen: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ReviewResultScreen(
                                        receipt: receipt,
                                        coordinator: widget.coordinator,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () =>
                                    widget.onDeleteReceipt(receipt.id),
                              );
                            },
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
                pose: DeniPose.idle,
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
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;
    final typeExt = context.enpriveType;

    final isConcern =
        receipt.overallState == ReviewOverallState.reviewRecommended;
    final statePair = isConcern
        ? semantics.reviewRecommended
        : semantics.noConcern;
    final stateLabel =
        isConcern ? l10n.stateReviewRecommended : l10n.stateNoConcern;
    final formattedDate = _formatReceiptTimestamp(context, receipt.createdAt);

    return Column(
      children: [
        // Main Archival Receipt M3ECard
        M3ECard(
          color: surfaces.card,
          elevation: 0,
          borderRadius: BorderRadius.circular(EnpriveRadii.xl),
          padding: const EdgeInsets.all(20),
          onPressed: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statePair.background,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: statePair.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statePair.icon,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          stateLabel,
                          style: m3e.typeScale.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: statePair.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: m3e.typeScale.labelSmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                receipt.subjectTitle,
                style: m3e.typography.emphasized.titleLarge.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                receipt.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: typeExt.policyQuotation.copyWith(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              EnpriveProvenanceChip(source: receipt.inferenceSource),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Semantic Action Strip (Open / Delete pill bars)
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onOpen,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: semantics.inCloud.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: semantics.inCloud.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.btnOpenReceipt,
                        style: m3e.typeScale.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: semantics.inCloud.foreground,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        LucideIcons.externalLink,
                        size: 15,
                        color: semantics.inCloud.foreground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: semantics.highConcern.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: semantics.highConcern.border),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.btnDelete,
                      style: m3e.typeScale.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: semantics.highConcern.foreground,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      LucideIcons.trash2,
                      size: 15,
                      color: semantics.highConcern.foreground,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
