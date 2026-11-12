import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../core/theme/enprive_theme.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_provenance_chip.dart';
import '../widgets/enprive_tactile_button.dart';
import 'review_result_screen.dart';

enum _ReceiptFilter {
  all,
  reviewRecommended,
  noConcern,
  insufficient,
}

/// Receipts Archive Screen (*MyNote inspiration pattern*).
/// Displays locally stored [PolicyReviewReceipt] records with filter chips,
/// search bar, cryptographic snapshot digest badges, and Open / Delete actions.
class ReceiptsScreen extends StatefulWidget {
  final List<PolicyReviewReceipt> receipts;
  final ReviewCoordinator coordinator;
  final bool showDeni;
  final bool isKorean;
  final ValueChanged<String> onDeleteReceipt;
  final VoidCallback onStartReviewRequested;

  const ReceiptsScreen({
    super.key,
    required this.receipts,
    required this.coordinator,
    required this.showDeni,
    required this.isKorean,
    required this.onDeleteReceipt,
    required this.onStartReviewRequested,
  });

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final TextEditingController _searchController = TextEditingController();
  _ReceiptFilter _activeFilter = _ReceiptFilter.all;
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
        _ReceiptFilter.insufficient =>
          r.overallState == ReviewOverallState.insufficientEvidence,
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      return r.subjectTitle.toLowerCase().contains(query) ||
          r.sourceLabel.toLowerCase().contains(query) ||
          r.snapshotDigest.toLowerCase().contains(query) ||
          r.summary.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  String _filterLabel(_ReceiptFilter filter) {
    final ko = widget.isKorean;
    return switch (filter) {
      _ReceiptFilter.all => ko ? '전체 (${widget.receipts.length})' : 'All (${widget.receipts.length})',
      _ReceiptFilter.reviewRecommended => ko ? '검토 권장' : 'Review recommended',
      _ReceiptFilter.noConcern => ko ? '우려 사항 없음' : 'No concern',
      _ReceiptFilter.insufficient => ko ? '근거 부족' : 'Insufficient',
    };
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReceipts;
    final ko = widget.isKorean;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              ko ? '저장된 근거 영수증' : 'Evidence Receipts',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 6),
            Text(
              ko
                  ? '이 기기에 로컬로 보관된 약관 스냅샷 해시와 원문 인용 기록입니다.'
                  : 'Local snapshots stored strictly on this phone with cryptographic digests and verified clauses.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EnpriveColors.inkSecondary,
                  ),
            ),
            const SizedBox(height: 16),

            // Search Bar (B20 thick 2dp focus border style)
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: ko
                    ? '앱 이름, 해시(#), 또는 키워드 검색...'
                    : 'Search by app name, digest (#), or clause...',
                prefixIcon: const Icon(Symbols.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Symbols.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: EnpriveColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: EnpriveColors.ink.withValues(alpha: 0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: EnpriveColors.teal,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter Chips Row (MyNote inspiration pattern)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _ReceiptFilter.values.map((filter) {
                  final isSelected = _activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => setState(() => _activeFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? EnpriveColors.ctaInk
                              : EnpriveColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected
                                ? EnpriveColors.ctaInk
                                : EnpriveColors.ink.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          _filterLabel(filter),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : EnpriveColors.inkSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Receipts List or Empty State
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(context, ko)
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final receipt = filtered[index];
                        return _ReceiptArchiveCard(
                          receipt: receipt,
                          isKorean: ko,
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
                          onDelete: () => widget.onDeleteReceipt(receipt.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool ko) {
    final isFilteredEmpty = widget.receipts.isNotEmpty;
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: EnpriveColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: EnpriveColors.ink.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDeni) ...[
                const DeniAnimatedMascot(
                  size: 84,
                  pose: DeniPose.idle,
                ),
                const SizedBox(height: 14),
              ] else ...[
                const Icon(
                  Symbols.receipt_long_rounded,
                  size: 44,
                  color: EnpriveColors.tealStrong,
                ),
                const SizedBox(height: 12),
              ],
              Text(
                isFilteredEmpty
                    ? (ko ? '조건에 맞는 영수증이 없습니다.' : 'No matching receipts found.')
                    : (ko ? '아직 저장된 영수증이 없습니다.' : 'No saved receipts yet.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: EnpriveTheme.primaryDisplayFontFamily,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: EnpriveColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isFilteredEmpty
                    ? (ko
                        ? '다른 필터를 선택하거나 검색어를 지워보세요.'
                        : 'Try switching filter chips or clearing your search query.')
                    : (ko
                        ? '앱 권한이나 약관을 검토한 뒤 [영수증에 저장]을 누르면 스냅샷 해시와 함께 이곳에 보관됩니다.'
                        : 'After checking an app or privacy policy, tap "Save to Receipts" to keep a timestamped local record here.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: EnpriveColors.inkSecondary,
                ),
              ),
              if (!isFilteredEmpty) ...[
                const SizedBox(height: 20),
                EnpriveTactileButton(
                  label: ko ? '첫 약관 검토 시작하기' : 'Start Your First Review',
                  leading: const Icon(
                    Symbols.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
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

class _ReceiptArchiveCard extends StatelessWidget {
  final PolicyReviewReceipt receipt;
  final bool isKorean;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _ReceiptArchiveCard({
    required this.receipt,
    required this.isKorean,
    required this.onOpen,
    required this.onDelete,
  });

  ({
    Color bg,
    Color fg,
    IconData icon,
    String label,
  }) _stateStyle() {
    return switch (receipt.overallState) {
      ReviewOverallState.reviewRecommended => (
          bg: EnpriveColors.stateReviewRecommendedBg,
          fg: EnpriveColors.stateReviewRecommendedFg,
          icon: Symbols.warning_amber_rounded,
          label: isKorean ? '검토 권장' : 'Review recommended',
        ),
      ReviewOverallState.noConcern => (
          bg: EnpriveColors.stateNoConcernBg,
          fg: EnpriveColors.stateNoConcernFg,
          icon: Symbols.verified_rounded,
          label: isKorean ? '우려 사항 없음' : 'No concern identified',
        ),
      ReviewOverallState.insufficientEvidence => (
          bg: EnpriveColors.stateInsufficientEvidenceBg,
          fg: EnpriveColors.stateInsufficientEvidenceFg,
          icon: Symbols.help_outline_rounded,
          label: isKorean ? '근거 부족' : 'Insufficient evidence',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _stateStyle();
    final formattedDate =
        DateFormat('MMM d, HH:mm').format(receipt.createdAt);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EnpriveColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EnpriveColors.ink.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: State badge + Provenance chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(style.icon, size: 15, color: style.fg),
                    const SizedBox(width: 5),
                    Text(
                      style.label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: style.fg,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              EnpriveProvenanceChip(source: receipt.inferenceSource),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Source
          Text(
            receipt.subjectTitle,
            style: const TextStyle(
              fontFamily: EnpriveTheme.primaryDisplayFontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: EnpriveColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${receipt.sourceLabel} · Last checked $formattedDate · #${receipt.snapshotDigest}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: EnpriveColors.inkSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // Summary preview
          Text(
            receipt.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: EnpriveColors.ink,
            ),
          ),
          const SizedBox(height: 12),

          // Stat pills + Actions row (MyNote pattern)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: EnpriveColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${receipt.sourceMatchedCount} verified · ${receipt.findings.length} total',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: EnpriveColors.inkSecondary,
                  ),
                ),
              ),
              if (receipt.permissionReport != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: receipt.permissionReport!.mismatchCount > 0
                        ? EnpriveColors.stateReviewRecommendedBg
                        : EnpriveColors.chipOnDeviceBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    receipt.permissionReport!.mismatchCount > 0
                        ? '${receipt.permissionReport!.mismatchCount} OS mismatch'
                        : 'OS aligned',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: receipt.permissionReport!.mismatchCount > 0
                          ? EnpriveColors.stateReviewRecommendedFg
                          : EnpriveColors.chipOnDeviceFg,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                tooltip: isKorean ? '영수증 삭제' : 'Delete receipt',
                onPressed: onDelete,
                icon: const Icon(
                  Symbols.delete_outline_rounded,
                  size: 20,
                  color: EnpriveColors.inkSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(
                  Symbols.open_in_new_rounded,
                  size: 16,
                  color: EnpriveColors.tealStrong,
                ),
                label: Text(
                  isKorean ? '열기' : 'Open',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: EnpriveColors.tealStrong,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
