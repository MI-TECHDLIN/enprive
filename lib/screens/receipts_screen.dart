import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../core/theme/enprive_theme.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_tactile_button.dart';
import 'review_result_screen.dart';

enum _ReceiptFilter {
  all,
  reviewRecommended,
  noConcern,
}

/// Receipts Archive Screen crafted from the MyNote (`x-mynote.jpeg`) pattern:
/// - Clean header with toggleable search bar
/// - Soft flat filter pills (`All · Review · No concern`)
/// - Quiet, tactile paper-note receipt cards without hash/badge clutter
class ReceiptsScreen extends StatefulWidget {
  final List<PolicyReviewReceipt> receipts;
  final ReviewCoordinator coordinator;
  final bool isKorean;
  final ValueChanged<String> onDeleteReceipt;
  final VoidCallback onStartReviewRequested;

  const ReceiptsScreen({
    super.key,
    required this.receipts,
    required this.coordinator,
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

  String _filterLabel(_ReceiptFilter filter) {
    final ko = widget.isKorean;
    return switch (filter) {
      _ReceiptFilter.all => ko ? '전체' : 'All',
      _ReceiptFilter.reviewRecommended => ko ? '검토 권장' : 'Review',
      _ReceiptFilter.noConcern => ko ? '우려 없음' : 'No concern',
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

            // MyNote Top Header Row: Title on left, Search icon on right
            Row(
              children: [
                Text(
                  ko ? '영수증 보관함' : 'Receipts',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const Spacer(),
                IconButton(
                  tooltip: ko ? '검색' : 'Search',
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
                    _isSearching
                        ? Symbols.close_rounded
                        : Symbols.search_rounded,
                    color: EnpriveColors.ink,
                  ),
                ),
              ],
            ),

            if (_isSearching) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: ko ? '앱 이름 또는 내용 검색...' : 'Search saved reviews...',
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
            ],
            const SizedBox(height: 12),

            // MyNote Soft Filter Pills Row (Date / Time / Title style)
            Row(
              children: _ReceiptFilter.values.map((filter) {
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _activeFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? EnpriveColors.ink.withValues(alpha: 0.12)
                            : EnpriveColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _filterLabel(filter),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? EnpriveColors.ink
                              : EnpriveColors.inkSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(context, ko)
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final receipt = filtered[index];
                        return _MyNoteReceiptCard(
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
                    ? (ko ? '일치하는 영수증이 없어요' : 'No matching receipts')
                    : (ko ? '아직 저장된 영수증이 없어요' : 'No saved receipts yet'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                isFilteredEmpty
                    ? (ko
                        ? '다른 필터를 선택해 보세요.'
                        : 'Try selecting another filter above.')
                    : (ko
                        ? '앱이나 약관을 검토한 뒤 북마크 아이콘을 누르면 이곳에 보관됩니다.'
                        : 'Bookmark any app review to keep a private copy on your phone.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: EnpriveColors.inkSecondary,
                ),
              ),
              if (!isFilteredEmpty) ...[
                const SizedBox(height: 24),
                EnpriveTactileButton(
                  label: ko ? '첫 검토 시작하기' : 'Start a review',
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

class _MyNoteReceiptCard extends StatelessWidget {
  final PolicyReviewReceipt receipt;
  final bool isKorean;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _MyNoteReceiptCard({
    required this.receipt,
    required this.isKorean,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isConcern =
        receipt.overallState == ReviewOverallState.reviewRecommended;
    final stateColor = isConcern
        ? EnpriveColors.stateReviewRecommendedFg
        : EnpriveColors.stateNoConcernFg;
    final stateLabel = isConcern
        ? (isKorean ? '검토 권장' : 'Review recommended')
        : (isKorean ? '우려 사항 없음' : 'No concern identified');
    final formattedDate = DateFormat('MMM d, h:mm a').format(receipt.createdAt);

    return Column(
      children: [
        // Main Note Card (x-mynote.jpeg clean elevated paper card)
        Material(
          color: EnpriveColors.surface,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: stateColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stateLabel,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: stateColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: EnpriveColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    receipt.subjectTitle,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: EnpriveColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    receipt.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: EnpriveTheme.secondaryFontBaseFamily,
                      fontSize: 14,
                      height: 1.45,
                      color: EnpriveColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Soft Pastel Action Strip below note (x-mynote.jpeg Edit / Delete pill bars)
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onOpen,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isKorean ? '열기' : 'Open receipt',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: EnpriveColors.chipInCloudFg,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Symbols.open_in_new_rounded,
                        size: 15,
                        color: EnpriveColors.chipInCloudFg,
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
                  color: const Color(0xFFFCEEEE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(
                      isKorean ? '삭제' : 'Delete',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9E2A2B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Symbols.delete_outline_rounded,
                      size: 16,
                      color: Color(0xFF9E2A2B),
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
