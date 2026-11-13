import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../l10n/app_localizations.dart';
import '../l10n/enprive_languages.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_duotone_icon.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/language_picker_sheet.dart';

class OnboardingFlowResult {
  final ExplanationDepth explanationDepth;
  final Locale locale;

  const OnboardingFlowResult({
    required this.explanationDepth,
    required this.locale,
  });
}

/// Guided 3-Step First-Run Onboarding Flow (`b02-koji-intro.png` → `b03-question-cards.png` → `b19-permission-prime.png`).
class OnboardingFlowScreen extends StatefulWidget {
  final ExplanationDepth initialDepth;
  final Locale initialLocale;

  const OnboardingFlowScreen({
    super.key,
    required this.initialDepth,
    required this.initialLocale,
  });

  static Future<OnboardingFlowResult?> show(
    BuildContext context, {
    required ExplanationDepth initialDepth,
    required Locale initialLocale,
  }) {
    return Navigator.of(context).push<OnboardingFlowResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OnboardingFlowScreen(
          initialDepth: initialDepth,
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
  late Locale _locale = widget.initialLocale;

  void _handleBack() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex--);
    } else {
      Navigator.of(context).pop(
        OnboardingFlowResult(
          explanationDepth: _selectedDepth,
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
          locale: _locale,
        ),
      );
    }
  }

  Future<void> _pickLanguage(BuildContext localizedContext) async {
    final picked = await EnpriveLanguagePickerSheet.show(
      localizedContext,
      currentLocale: _locale,
    );
    if (picked != null && mounted) {
      setState(() => _locale = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langOption = enpriveLanguageByCode(_locale.languageCode);

    return Localizations.override(
      context: context,
      locale: _locale,
      delegates: AppLocalizations.localizationsDelegates,
      child: Builder(
        builder: (localizedContext) {
          final l10n = AppLocalizations.of(localizedContext)!;

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
                      // Top Bar: back chevron + 12-language picker pill + responsive progress bar
                      Row(
                        children: [
                          IconButton(
                            onPressed: _handleBack,
                            icon: const Icon(
                              LucideIcons.chevronLeft,
                              size: 22,
                              color: EnpriveColors.ink,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => _pickLanguage(localizedContext),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: EnpriveColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.globe,
                                    size: 13.5,
                                    color: EnpriveColors.tealStrong,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    langOption.shortBadge,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: EnpriveColors.ink,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    LucideIcons.chevronDown,
                                    size: 13,
                                    color: EnpriveColors.inkSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 156),
                                child: Row(
                                  children: List.generate(3, (index) {
                                    final active = index <= _stepIndex;
                                    return Expanded(
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        height: 6,
                                        margin: EdgeInsetsDirectional.only(
                                          end: index < 2 ? 6 : 0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? EnpriveColors.teal
                                              : EnpriveColors.ink
                                                  .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(999),
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
                            0 => _buildStep0Intro(localizedContext, l10n),
                            1 =>
                              _buildStep1QuestionCards(localizedContext, l10n),
                            _ => _buildStep2Readiness(localizedContext, l10n),
                          },
                        ),
                      ),

                      // Bottom Tactile Continue / Get Started CTA
                      EnpriveTactileButton(
                        label: _stepIndex < 2
                            ? l10n.btnContinue
                            : l10n.btnGetStarted,
                        onPressed: _handleNext,
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

  /// Step 0: `b02-koji-intro.png` — Deni welcome stage with clear, grounded copy.
  Widget _buildStep0Intro(BuildContext context, AppLocalizations l10n) {
    final paragraphs = l10n.onboardingIntroBody
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList(growable: false);

    return Center(
      key: const ValueKey<int>(0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DeniAnimatedMascot(
              size: 112,
              pose: DeniPose.idle,
            ),
            const SizedBox(height: 18),
            Text(
              l10n.onboardingIntroHeadline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 27,
                    height: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingIntroLead,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: EnpriveColors.tealStrong,
                  ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: EnpriveColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: EnpriveColors.ink.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < paragraphs.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    Text(
                      paragraphs[i],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14.5,
                            height: 1.5,
                            color: i == 0
                                ? EnpriveColors.ink
                                : EnpriveColors.inkSecondary,
                          ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: EnpriveColors.chipOnDeviceBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.shieldCheck,
                          size: 16,
                          color: EnpriveColors.tealStrong,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.onboardingIntroFooter,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: EnpriveColors.tealStrong,
                            ),
                          ),
                        ),
                      ],
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

  /// Step 1: `b03-question-cards.png` — Mascot + Question Header + 2x2 Choice Cards Grid.
  Widget _buildStep1QuestionCards(BuildContext context, AppLocalizations l10n) {
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
                  l10n.onboardingStep1Question,
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
                iconSvg: Ph.sun_duotone,
                badgeBg: EnpriveColors.stateReviewRecommendedBg,
                badgeFg: EnpriveColors.stateReviewRecommendedFg,
                title: l10n.depthQuickMultiline,
                isSelected: _selectedDepth == ExplanationDepth.simple,
                onTap: () =>
                    setState(() => _selectedDepth = ExplanationDepth.simple),
              ),
              _B3GridChoiceCard(
                iconSvg: Ph.scales_duotone,
                badgeBg: EnpriveColors.stateNoConcernBg,
                badgeFg: EnpriveColors.stateNoConcernFg,
                title: l10n.depthBalancedMultiline,
                isSelected: _selectedDepth == ExplanationDepth.balanced,
                onTap: () =>
                    setState(() => _selectedDepth = ExplanationDepth.balanced),
              ),
              _B3GridChoiceCard(
                iconSvg: Ph.book_open_duotone,
                badgeBg: EnpriveColors.chipInCloudBg,
                badgeFg: EnpriveColors.chipInCloudFg,
                title: l10n.depthFullMultiline,
                isSelected: _selectedDepth == ExplanationDepth.detailed,
                onTap: () =>
                    setState(() => _selectedDepth = ExplanationDepth.detailed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Step 2: `b19-permission-prime.png` — Deni peeking over the Private On-Device Readiness Card.
  Widget _buildStep2Readiness(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      key: const ValueKey<int>(2),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            l10n.onboardingReadinessTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 27,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingReadinessSubtitle,
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
                  iconSvg: Ph.cpu_duotone,
                  title: l10n.readinessRow1Title,
                  subtitle: l10n.readinessRow1Desc,
                ),
                const SizedBox(height: 16),
                _ReadinessGuaranteeRow(
                  iconSvg: Ph.device_mobile_duotone,
                  title: l10n.readinessRow2Title,
                  subtitle: l10n.readinessRow2Desc,
                ),
                const SizedBox(height: 16),
                _ReadinessGuaranteeRow(
                  iconSvg: Ph.eraser_duotone,
                  title: l10n.readinessRow3Title,
                  subtitle: l10n.readinessRow3Desc,
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
  final String iconSvg;
  final Color badgeBg;
  final Color badgeFg;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _B3GridChoiceCard({
    required this.iconSvg,
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
                child: EnpriveDuotoneIcon(iconSvg, size: 28, color: badgeFg),
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
  final String iconSvg;
  final String title;
  final String subtitle;

  const _ReadinessGuaranteeRow({
    required this.iconSvg,
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
          child: EnpriveDuotoneIcon(
            iconSvg,
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
