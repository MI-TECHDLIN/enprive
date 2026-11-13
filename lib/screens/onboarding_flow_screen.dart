import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_tactile_button.dart';

class OnboardingFlowResult {
  final ExplanationDepth explanationDepth;
  final bool showDeni;
  final Locale locale;

  const OnboardingFlowResult({
    required this.explanationDepth,
    required this.showDeni,
    required this.locale,
  });
}

/// Guided 3-Step First-Run Onboarding Flow (`b02-koji-intro.png` → `b03-question-cards.png` → `b19-permission-prime.png`).
class OnboardingFlowScreen extends StatefulWidget {
  final ExplanationDepth initialDepth;
  final bool initialShowDeni;
  final Locale initialLocale;

  const OnboardingFlowScreen({
    super.key,
    required this.initialDepth,
    required this.initialShowDeni,
    required this.initialLocale,
  });

  static Future<OnboardingFlowResult?> show(
    BuildContext context, {
    required ExplanationDepth initialDepth,
    required bool initialShowDeni,
    required Locale initialLocale,
  }) {
    return Navigator.of(context).push<OnboardingFlowResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OnboardingFlowScreen(
          initialDepth: initialDepth,
          initialShowDeni: initialShowDeni,
          initialLocale: initialLocale,
        ),
      ),
    );
  }

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _stepIndex = 0;
  late ExplanationDepth _selectedDepth = widget.initialDepth;
  late bool _showDeni = widget.initialShowDeni;
  late Locale _locale = widget.initialLocale;

  bool get _isKorean => _locale.languageCode == 'ko';

  void _handleBack() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex--);
    } else {
      Navigator.of(context).pop(
        OnboardingFlowResult(
          explanationDepth: _selectedDepth,
          showDeni: _showDeni,
          locale: _locale,
        ),
      );
    }
  }

  void _handleNext() {
    if (_stepIndex < 2) {
      setState(() => _stepIndex++);
    } else {
      Navigator.of(context).pop(
        OnboardingFlowResult(
          explanationDepth: _selectedDepth,
          showDeni: _showDeni,
          locale: _locale,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnpriveColors.paper,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.72, 1.0],
            colors: [
              EnpriveColors.paper,
              EnpriveColors.paper,
              EnpriveColors.chipOnDeviceBg.withValues(alpha: 0.55),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                // Top Bar: back chevron + language toggle + responsive right-aligned progress bar
                Row(
                  children: [
                    IconButton(
                      onPressed: _handleBack,
                      icon: const Icon(
                        Symbols.arrow_back_ios_new_rounded,
                        size: 20,
                        color: EnpriveColors.ink,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        setState(() {
                          _locale = _isKorean
                              ? const Locale('en')
                              : const Locale('ko');
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: EnpriveColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _isKorean ? 'EN' : '한국어',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: EnpriveColors.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 156),
                          child: Row(
                            children: List.generate(3, (index) {
                              final active = index <= _stepIndex;
                              return Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  height: 6,
                                  margin: EdgeInsets.only(
                                    right: index < 2 ? 6 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? EnpriveColors.teal
                                        : EnpriveColors.ink.withValues(
                                            alpha: 0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Main Step Stage
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: switch (_stepIndex) {
                      0 => _buildStep0Intro(context),
                      1 => _buildStep1QuestionCards(context),
                      _ => _buildStep2Readiness(context),
                    },
                  ),
                ),

                // Bottom Tactile Continue / Get Started CTA
                EnpriveTactileButton(
                  label: _stepIndex < 2
                      ? (_isKorean ? '계속하기' : 'Continue')
                      : (_isKorean ? '시작하기' : 'Get started'),
                  onPressed: _handleNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Step 0: `b02-koji-intro.png` — Minimalist centered mascot stage & bold headline.
  Widget _buildStep0Intro(BuildContext context) {
    return Column(
      key: const ValueKey<int>(0),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        DeniAnimatedMascot(
          size: 132,
          pose: DeniPose.idle,
        ),
        const SizedBox(height: 28),
        Text(
          _isKorean
              ? '안녕하세요, 데니예요.\n어려운 약관의 핵심만 같이 짚어드릴게요.'
              : "Hi, I'm Deni.\nI read the fine print with you.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 27,
                height: 1.22,
              ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _isKorean
                ? '모든 안내는 약관의 정확한 원문 문장에 근거하며, 근거 없이 앱이 안전하다고 단정하지 않아요.'
                : 'I point to the exact lines in an app’s policy—and I’ll never guess or stamp an app “safe”.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: EnpriveColors.inkSecondary,
                ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  /// Step 1: `b03-question-cards.png` — Mascot + Question Header + 2x2 Choice Cards Grid.
  Widget _buildStep1QuestionCards(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey<int>(1),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DeniAnimatedMascot(
                size: 64,
                pose: DeniPose.explaining,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _isKorean
                      ? '약관을 어떤 방식으로\n설명해 드릴까요?'
                      : 'How should I explain\nprivacy terms?',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 23,
                        height: 1.22,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.94,
            children: [
              _B3GridChoiceCard(
                icon: Symbols.wb_sunny_rounded,
                badgeBg: EnpriveColors.stateReviewRecommendedBg,
                badgeFg: EnpriveColors.stateReviewRecommendedFg,
                title: _isKorean ? '핵심만 간단히' : 'Quick &\nplain',
                isSelected: _selectedDepth == ExplanationDepth.simple,
                onTap: () =>
                    setState(() => _selectedDepth = ExplanationDepth.simple),
              ),
              _B3GridChoiceCard(
                icon: Symbols.balance_rounded,
                badgeBg: EnpriveColors.stateNoConcernBg,
                badgeFg: EnpriveColors.stateNoConcernFg,
                title: _isKorean ? '요약 + 원문' : 'Balanced\nview',
                isSelected: _selectedDepth == ExplanationDepth.balanced,
                onTap: () =>
                    setState(() => _selectedDepth = ExplanationDepth.balanced),
              ),
              _B3GridChoiceCard(
                icon: Symbols.article_rounded,
                badgeBg: EnpriveColors.chipInCloudBg,
                badgeFg: EnpriveColors.chipInCloudFg,
                title: _isKorean ? '조항별 자세히' : 'Full\ndetail',
                isSelected: _selectedDepth == ExplanationDepth.detailed,
                onTap: () =>
                    setState(() => _selectedDepth = ExplanationDepth.detailed),
              ),
              _B3GridChoiceCard(
                icon: _showDeni
                    ? Symbols.sentiment_satisfied_rounded
                    : Symbols.visibility_off_rounded,
                badgeBg: EnpriveColors.surface,
                badgeFg: EnpriveColors.ink,
                title: _showDeni
                    ? (_isKorean ? '데니 캐릭터 표시' : 'Show Deni\ncompanion')
                    : (_isKorean ? '텍스트만 표시' : 'Text-only\nquiet mode'),
                isSelected: !_showDeni,
                onTap: () => setState(() => _showDeni = !_showDeni),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Step 2: `b19-permission-prime.png` — Deni peeking over the Private On-Device Readiness Card.
  Widget _buildStep2Readiness(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey<int>(2),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            _isKorean
                ? '이 기기에서 안전하게\n보호되는 개인정보'
                : 'Private by default\non this phone',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 27,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _isKorean
                ? '부모님과 선생님이 안심하고 앱을 검토할 수 있도록 설계했어요.'
                : 'Designed so parents and teachers can inspect apps without sharing device data.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Transform.translate(
            offset: const Offset(0, 10),
            child: const DeniAnimatedMascot(
              size: 92,
              pose: DeniPose.celebrating,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: EnpriveColors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                _ReadinessGuaranteeRow(
                  icon: Symbols.memory_rounded,
                  title: _isKorean ? '이 기기에서 먼저 확인' : 'Checked here first',
                  subtitle: _isKorean
                      ? '약관은 기기 내 모델과 로컬 스캐너로 먼저 대조합니다.'
                      : 'Policies are read on your phone before anything else.',
                ),
                const SizedBox(height: 16),
                _ReadinessGuaranteeRow(
                  icon: Symbols.phonelink_lock_rounded,
                  title:
                      _isKorean ? '앱 목록·권한은 폰 안에만' : 'Your apps stay yours',
                  subtitle: _isKorean
                      ? '설치된 앱과 Android 권한 정보는 폰 밖으로 나가지 않습니다.'
                      : 'The apps on this phone and their permissions never leave it.',
                ),
                const SizedBox(height: 16),
                _ReadinessGuaranteeRow(
                  icon: Symbols.cloud_off_rounded,
                  title: _isKorean ? '묻지 않고 업로드 안 함' : 'Never uploaded without asking',
                  subtitle: _isKorean
                      ? '클라우드 분석은 직접 허용한 그 검사 1회에만 실행됩니다.'
                      : 'Cloud analysis only runs for the one check you approve.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _B3GridChoiceCard extends StatelessWidget {
  final IconData icon;
  final Color badgeBg;
  final Color badgeFg;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _B3GridChoiceCard({
    required this.icon,
    required this.badgeBg,
    required this.badgeFg,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? EnpriveColors.chipOnDeviceBg
          : EnpriveColors.surfaceMuted,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? EnpriveColors.teal
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 28, color: badgeFg),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.22,
                  color: isSelected
                      ? EnpriveColors.tealStrong
                      : EnpriveColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadinessGuaranteeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReadinessGuaranteeRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: EnpriveColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: EnpriveColors.tealStrong,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: EnpriveColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.38,
                  color: EnpriveColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
