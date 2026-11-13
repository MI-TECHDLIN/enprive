import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../core/theme/enprive_colors.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/private_readiness_sheet.dart';

/// Settings & Private Analysis Readiness Screen crafted from Brilliant B19
/// (`b19-permission-prime.png` — Deni peeking over a mock status card) and
/// Brilliant B3 (`b03-question-cards.png` — soft grey choice cards).
class SettingsScreen extends StatefulWidget {
  final HybridAiBridge bridge;
  final DeviceCapability? capability;
  final bool showDeni;
  final ExplanationDepth explanationDepth;
  final Locale currentLocale;
  final int savedReceiptsCount;
  final ValueChanged<bool> onShowDeniChanged;
  final ValueChanged<ExplanationDepth> onExplanationDepthChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onRefreshCapability;
  final VoidCallback onClearAllReceipts;
  final VoidCallback? onReplayOnboarding;

  const SettingsScreen({
    super.key,
    required this.bridge,
    required this.capability,
    required this.showDeni,
    required this.explanationDepth,
    required this.currentLocale,
    required this.savedReceiptsCount,
    required this.onShowDeniChanged,
    required this.onExplanationDepthChanged,
    required this.onLocaleChanged,
    required this.onRefreshCapability,
    required this.onClearAllReceipts,
    this.onReplayOnboarding,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isCheckingModel = false;
  String? _modelActionFeedback;

  Future<void> _handleCheckOrPrepareModel() async {
    if (_isCheckingModel) return;
    final ko = widget.currentLocale.languageCode == 'ko';
    setState(() => _isCheckingModel = true);
    final updated = await PrivateReadinessSheet.show(
      context,
      bridge: widget.bridge,
      initialCapability: widget.capability,
      isKorean: ko,
    );
    widget.onRefreshCapability();
    if (!mounted) return;
    setState(() {
      _isCheckingModel = false;
      if (updated != null) {
        _modelActionFeedback =
            updated.isSupported &&
                updated.modelStatus == ModelDownloadStatus.available
            ? (ko ? '온디바이스 모델이 준비되었습니다.' : 'On-device AI is active and ready.')
            : (ko
                  ? '내장된 로컬 약관 스캐너로 안전하게 작동 중입니다.'
                  : 'Protected by built-in local clause scanning.');
      }
    });
  }

  Future<void> _confirmClearReceipts(BuildContext context, bool ko) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: EnpriveColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          ko ? '저장된 영수증을 모두 지울까요?' : 'Clear saved receipts?',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          ko
              ? '이 기기에 저장된 ${widget.savedReceiptsCount}개의 영수증이 삭제됩니다.'
              : 'This removes ${widget.savedReceiptsCount} saved reviews from your phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(ko ? '취소' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: EnpriveColors.ctaInk,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(ko ? '삭제' : 'Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onClearAllReceipts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ko = widget.currentLocale.languageCode == 'ko';
    final cap = widget.capability;
    final isReady =
        cap?.isSupported == true &&
        cap?.modelStatus == ModelDownloadStatus.available;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ko ? '설정' : 'Settings',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),

            // 1. Brilliant B19 Pattern: Deni peeking over a clean status card
            Center(
              child: Column(
                children: [
                  if (widget.showDeni)
                    Transform.translate(
                      offset: const Offset(0, 10),
                      child: DeniAnimatedMascot(
                        size: 72,
                        pose: _isCheckingModel
                            ? DeniPose.thinking
                            : (isReady ? DeniPose.celebrating : DeniPose.idle),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: EnpriveColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: EnpriveColors.ink.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: EnpriveColors.chipOnDeviceBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Symbols.shield_lock_rounded,
                                color: EnpriveColors.tealStrong,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ko
                                        ? '이 휴대폰에서 비공개 분석'
                                        : 'Private analysis on this phone',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: EnpriveColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _modelActionFeedback ??
                                        (isReady
                                            ? (ko
                                                  ? '온디바이스 모델이 준비되었습니다.'
                                                  : 'On-device AI is active and ready.')
                                            : (ko
                                                  ? '내장된 로컬 약관 스캐너로 안전하게 작동 중입니다.'
                                                  : 'Protected by built-in local clause scanning.')),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: EnpriveColors.inkSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        EnpriveTactileButton(
                          label: _isCheckingModel
                              ? (ko ? '확인 중…' : 'Checking…')
                              : (ko ? '기기 상태 확인하기' : 'Check readiness'),
                          isSecondary: true,
                          onPressed: _isCheckingModel
                              ? null
                              : _handleCheckOrPrepareModel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 2. Brilliant B3 Pattern: Soft Choice Cards for Explanation Style
            Text(
              ko ? '어떻게 설명해 드릴까요?' : 'How should Deni explain things?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: EnpriveColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ExplanationDepth.values.map((depth) {
                final isSelected = widget.explanationDepth == depth;
                final (icon, label) = switch (depth) {
                  ExplanationDepth.simple => (
                    Symbols.auto_awesome_rounded,
                    ko ? '핵심만' : 'Quick',
                  ),
                  ExplanationDepth.balanced => (
                    Symbols.balance_rounded,
                    ko ? '요약+원문' : 'Balanced',
                  ),
                  ExplanationDepth.detailed => (
                    Symbols.menu_book_rounded,
                    ko ? '자세히' : 'Full detail',
                  ),
                };
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: depth != ExplanationDepth.detailed ? 10.0 : 0,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => widget.onExplanationDepthChanged(depth),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? EnpriveColors.surface
                              : EnpriveColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? EnpriveColors.teal
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? EnpriveColors.chipOnDeviceBg
                                    : EnpriveColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                icon,
                                size: 20,
                                color: isSelected
                                    ? EnpriveColors.tealStrong
                                    : EnpriveColors.inkSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? EnpriveColors.ink
                                    : EnpriveColors.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // 3. Clean Minimal Preferences Group
            Text(
              ko ? '환경 설정' : 'Preferences',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: EnpriveColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: EnpriveColors.surface,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: widget.showDeni,
                    activeTrackColor: EnpriveColors.teal,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    onChanged: widget.onShowDeniChanged,
                    title: Text(
                      ko ? 'Deni 캐릭터 표시' : 'Show Deni companion',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: EnpriveColors.ink,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: EnpriveColors.ink.withValues(alpha: 0.06),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    title: Text(
                      ko ? '언어' : 'Language',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: EnpriveColors.ink,
                      ),
                    ),
                    trailing: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('EN')),
                        ButtonSegment(value: 'ko', label: Text('한국어')),
                      ],
                      selected: {ko ? 'ko' : 'en'},
                      onSelectionChanged: (selection) {
                        widget.onLocaleChanged(Locale(selection.first));
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: EnpriveColors.ink.withValues(alpha: 0.06),
                  ),
                  if (widget.onReplayOnboarding != null) ...[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      onTap: widget.onReplayOnboarding,
                      title: Text(
                        ko ? '데니 소개 및 시작 가이드' : 'Meet Deni & setup guide',
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
                    Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      color: EnpriveColors.ink.withValues(alpha: 0.06),
                    ),
                  ],
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    title: Text(
                      ko
                          ? '저장된 영수증 지우기 (${widget.savedReceiptsCount})'
                          : 'Clear saved receipts (${widget.savedReceiptsCount})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: EnpriveColors.ink,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: widget.savedReceiptsCount == 0
                          ? null
                          : () => _confirmClearReceipts(context, ko),
                      child: Text(
                        ko ? '지우기' : 'Clear',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: widget.savedReceiptsCount == 0
                              ? EnpriveColors.inkDisabled
                              : EnpriveColors.stateReviewRecommendedFg,
                        ),
                      ),
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
