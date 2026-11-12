import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../core/theme/enprive_theme.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_tactile_button.dart';

/// Settings & Private Analysis Readiness Screen (*B19 + B3 Choice Cards*).
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
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isCheckingModel = false;
  String? _modelActionFeedback;

  Future<void> _handleCheckOrPrepareModel() async {
    if (_isCheckingModel) return;
    setState(() {
      _isCheckingModel = true;
      _modelActionFeedback = null;
    });

    final status = await widget.bridge.downloadOrCheckModel();
    bool warmed = false;
    if (status == ModelDownloadStatus.available) {
      warmed = await widget.bridge.warmUpModel();
    }
    widget.onRefreshCapability();

    if (!mounted) return;
    setState(() {
      _isCheckingModel = false;
      _modelActionFeedback = switch (status) {
        ModelDownloadStatus.available => warmed
            ? 'Gemini Nano 4 is available and warmed up in AICore on this device.'
            : 'Gemini Nano 4 is available on this device.',
        ModelDownloadStatus.downloading =>
          'AICore is downloading Gemini Nano 4 in the background.',
        ModelDownloadStatus.downloadable =>
          'Model is downloadable via AICore. Keep Wi-Fi connected.',
        ModelDownloadStatus.unavailable =>
          'On-device AICore model is unavailable on this hardware/emulator. Enprive will use deterministic local clause scanning or ask before using cloud.',
        ModelDownloadStatus.failed =>
          'Could not reach AICore model service on this device.',
      };
    });
  }

  Future<void> _confirmClearReceipts(BuildContext context, bool ko) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: EnpriveColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          ko ? '모든 로컬 영수증 삭제' : 'Clear All Local Receipts?',
          style: const TextStyle(
            fontFamily: EnpriveTheme.primaryDisplayFontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          ko
              ? '이 기기에 저장된 ${widget.savedReceiptsCount}개의 영수증이 영구적으로 삭제됩니다.'
              : 'This will permanently delete all ${widget.savedReceiptsCount} saved evidence receipts from this phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(ko ? '취소' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: EnpriveColors.stateReviewRecommendedFg,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(ko ? '삭제' : 'Delete All'),
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
        cap?.isSupported == true && cap?.modelStatus == ModelDownloadStatus.available;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ko ? '설정 및 기기 준비 상태' : 'Settings & Readiness',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 6),
            Text(
              ko
                  ? '계정이나 외부 추적기 없이 모든 설정과 기록은 이 기기에만 저장됩니다.'
                  : 'No user accounts and no analytics trackers. Preferences stay strictly on this phone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EnpriveColors.inkSecondary,
                  ),
            ),
            const SizedBox(height: 20),

            // 1. Private Analysis on This Phone (B19 Permission Priming Card)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: EnpriveColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: EnpriveColors.teal.withValues(alpha: 0.22),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.showDeni) ...[
                        DeniAnimatedMascot(
                          size: 60,
                          pose: _isCheckingModel
                              ? DeniPose.thinking
                              : (isReady ? DeniPose.celebrating : DeniPose.support),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isReady
                                    ? EnpriveColors.stateNoConcernBg
                                    : EnpriveColors.stateInsufficientEvidenceBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isReady
                                    ? (ko ? '온디바이스 준비 완료' : 'ON-DEVICE READY')
                                    : (ko
                                        ? '하드웨어 상태 확인'
                                        : 'HARDWARE / AICORE STATUS'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: isReady
                                      ? EnpriveColors.stateNoConcernFg
                                      : EnpriveColors.stateInsufficientEvidenceFg,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ko
                                  ? '이 휴대폰의 비공개 AI 분석'
                                  : 'Private Analysis on This Phone',
                              style: const TextStyle(
                                fontFamily:
                                    EnpriveTheme.primaryDisplayFontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: EnpriveColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: EnpriveColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Model target: Gemini Nano 4 (OnDeviceModelOption.PREVIEW)',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: EnpriveColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Android API ${cap?.apiLevel ?? 0} · Status: ${cap?.modelStatus.name.toUpperCase() ?? "CHECKING"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: EnpriveColors.tealStrong,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _modelActionFeedback ??
                              cap?.userMessage ??
                              'Checking AICore status...',
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: EnpriveColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  EnpriveTactileButton(
                    label: _isCheckingModel
                        ? (ko ? 'AICore 모델 확인 중...' : 'Checking AICore Model...')
                        : (ko
                            ? '온디바이스 모델 상태 확인 / 워밍업'
                            : 'Check & Warm Up On-Device Model'),
                    isSecondary: true,
                    leading: const Icon(Symbols.memory_rounded, size: 18),
                    onPressed:
                        _isCheckingModel ? null : _handleCheckOrPrepareModel,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Explanation Depth (B3 Choice Cards)
            Text(
              ko ? '설명 깊이 설정 (Deni)' : 'EXPLANATION DEPTH',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: EnpriveColors.inkSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: ExplanationDepth.values.map((depth) {
                final isSelected = widget.explanationDepth == depth;
                final label = switch (depth) {
                  ExplanationDepth.simple => ko ? '간단히' : 'Simple',
                  ExplanationDepth.balanced => ko ? '균형 있게' : 'Balanced',
                  ExplanationDepth.detailed => ko ? '자세히' : 'Detailed',
                };
                final subtitle = switch (depth) {
                  ExplanationDepth.simple => ko ? '핵심 요약' : 'Quick summary',
                  ExplanationDepth.balanced => ko ? '인용구 + 해설' : 'Quotes + guide',
                  ExplanationDepth.detailed => ko ? '전체 4단계 분석' : 'Full breakdown',
                };
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: depth != ExplanationDepth.detailed ? 8.0 : 0,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onExplanationDepthChanged(depth),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? EnpriveColors.teal.withValues(alpha: 0.12)
                              : EnpriveColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? EnpriveColors.teal
                                : EnpriveColors.ink.withValues(alpha: 0.10),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? EnpriveColors.tealStrong
                                    : EnpriveColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                color: EnpriveColors.inkSecondary,
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

            const SizedBox(height: 24),

            // 3. Companion & Language Controls
            Text(
              ko ? '화면 및 언어 설정' : 'COMPANION & LANGUAGE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: EnpriveColors.inkSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Material(
              color: EnpriveColors.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: EnpriveColors.ink.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: widget.showDeni,
                    activeTrackColor: EnpriveColors.teal,
                    onChanged: widget.onShowDeniChanged,
                    title: Text(
                      ko ? 'Deni 캐릭터 표시' : 'Show Deni Companion',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: EnpriveColors.ink,
                      ),
                    ),
                    subtitle: Text(
                      ko
                          ? '홈 화면과 검토 결과에서 Deni 애니메이션을 표시합니다.'
                          : 'Display Deni on the Home stage and review sheets.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: EnpriveColors.inkSecondary,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: EnpriveColors.ink.withValues(alpha: 0.08),
                  ),
                  ListTile(
                    leading: const Icon(
                      Symbols.translate_rounded,
                      color: EnpriveColors.tealStrong,
                    ),
                    title: Text(
                      ko ? '앱 표시 언어' : 'App Language',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: EnpriveColors.ink,
                      ),
                    ),
                    subtitle: Text(
                      ko ? '한국어 (Korean)' : 'English (US)',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: EnpriveColors.inkSecondary,
                      ),
                    ),
                    trailing: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('EN')),
                        ButtonSegment(value: 'ko', label: Text('한국어')),
                      ],
                      selected: {ko ? 'ko' : 'en'},
                      onSelectionChanged: (selection) {
                        final code = selection.first;
                        widget.onLocaleChanged(Locale(code));
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Local Data & Privacy Controls
            Text(
              ko ? '로컬 데이터 관리' : 'LOCAL STORAGE & PRIVACY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: EnpriveColors.inkSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: EnpriveColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: EnpriveColors.ink.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Symbols.database_rounded,
                        color: EnpriveColors.inkSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ko
                                  ? '저장된 로컬 영수증: ${widget.savedReceiptsCount}개'
                                  : 'Saved Local Receipts: ${widget.savedReceiptsCount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: EnpriveColors.ink,
                              ),
                            ),
                            Text(
                              ko
                                  ? 'SQLite 데이터베이스 (enprive_receipts.db)에 암호화 해시와 함께 보관됨'
                                  : 'Stored in local SQLite (enprive_receipts.db) on this phone.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: EnpriveColors.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: widget.savedReceiptsCount == 0
                            ? null
                            : () => _confirmClearReceipts(context, ko),
                        child: Text(
                          ko ? '전체 삭제' : 'Clear All',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: widget.savedReceiptsCount == 0
                                ? EnpriveColors.inkSecondary
                                : EnpriveColors.stateReviewRecommendedFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EnpriveColors.quoteSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ko
                          ? '개인정보 보호 원칙: 설치된 앱 목록과 기기 권한 정보는 절대 클라우드나 AI 프롬프트로 전송되지 않습니다.'
                          : 'Privacy Invariant: Installed app lists and Android OS permission states never leave this device or enter cloud AI prompts.',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: EnpriveColors.ink,
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
