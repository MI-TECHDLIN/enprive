import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/enprive_languages.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/m3e/enprive_m3e_components.dart';

class OnboardingFlowResult {
  final ExplanationDepth explanationDepth;
  final Locale locale;

  const OnboardingFlowResult({
    required this.explanationDepth,
    required this.locale,
  });
}

/// Guided 3-Step Material 3 Expressive First-Run Onboarding Flow:
/// - **Step 0 (Hero Intro)**: Deni at `LOD 3 · 136dp` (`DeniPose.idle`) with
///   editorial display typography.
/// - **Step 1 (Explanation Depth)**: Deni at `LOD 1 · 56dp` (`DeniPose.explaining`)
///   with a 2x2 Bento grid of `M3ECard` choice squircles.
/// - **Step 2 (Private Readiness)**: Deni at `LOD 2 · 92dp` (`DeniPose.celebrating`)
///   peeking over a segmented M3E local-privacy guarantee card.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Localizations.override(
      context: context,
      locale: _locale,
      delegates: EnpriveM3ETheme.localizationsDelegates,
      child: EnpriveM3EBridgeScope(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        child: Builder(
          builder: (localizedContext) {
            final l10n = AppLocalizations.of(localizedContext)!;
            final m3e = EnpriveM3ETheme.of(localizedContext);
            final scheme = m3e.colorScheme;
            final surfaces = localizedContext.enpriveSurfaces;
            final disableAnimations =
                EnpriveMotionTokens.isReducedMotion(localizedContext);

            return Scaffold(
              backgroundColor: scheme.surface,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    children: [
                      // Top Bar: back chevron + 12-language M3E pill + capsule progress track
                      Row(
                        children: [
                          IconButton(
                            onPressed: _handleBack,
                            icon: Icon(
                              LucideIcons.chevronLeft,
                              size: 22,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => _pickLanguage(localizedContext),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: surfaces.cardMuted,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: surfaces.hairlineBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.globe,
                                    size: 14,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    langOption.shortBadge,
                                    style: m3e.typography.emphasized.labelSmall
                                        .copyWith(
                                          color: scheme.onSurface,
                                        ),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                    LucideIcons.chevronDown,
                                    size: 13,
                                    color: scheme.onSurfaceVariant,
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
                                        duration: disableAnimations
                                            ? Duration.zero
                                            : const Duration(milliseconds: 220),
                                        height: 6,
                                        margin: EdgeInsetsDirectional.only(
                                          end: index < 2 ? 6 : 0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? scheme.primary
                                              : scheme.surfaceContainerHighest,
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
                          duration: disableAnimations
                              ? Duration.zero
                              : const Duration(milliseconds: 240),
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
            );
          },
        ),
      ),
    );
  }

  /// Step 0: Hero Deni (`LOD 3 · 136dp`) & editorial headline.
  Widget _buildStep0Intro(BuildContext context, AppLocalizations l10n) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return Center(
      key: const ValueKey<int>(0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DeniAnimatedMascot(
              size: 136,
              pose: DeniPose.idle,
            ),
            const SizedBox(height: 22),
            Text(
              l10n.onboardingIntroHeadline,
              textAlign: TextAlign.center,
              style: m3e.typography.emphasized.headlineLarge.copyWith(
                fontSize: 28,
                height: 1.2,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.onboardingIntroLead,
              textAlign: TextAlign.center,
              style: m3e.typography.emphasized.titleMedium.copyWith(
                fontSize: 16.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 1: Compact Deni (`LOD 1 · 56dp`) + 2x2 M3E Bento Choice Grid.
  Widget _buildStep1QuestionCards(BuildContext context, AppLocalizations l10n) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;

    return SingleChildScrollView(
      key: const ValueKey<int>(1),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DeniAnimatedMascot(
                size: 56,
                pose: DeniPose.explaining,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.onboardingStep1Question,
                  style: m3e.typography.emphasized.headlineMedium.copyWith(
                    fontSize: 23,
                    height: 1.22,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _M3EGridChoiceCard(
                    icon: LucideIcons.sun,
                    badgePair: semantics.reviewRecommended,
                    title: l10n.depthQuickMultiline,
                    isSelected: _selectedDepth == ExplanationDepth.simple,
                    onTap: () =>
                        setState(() => _selectedDepth = ExplanationDepth.simple),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _M3EGridChoiceCard(
                    icon: LucideIcons.scale,
                    badgePair: semantics.noConcern,
                    title: l10n.depthBalancedMultiline,
                    isSelected: _selectedDepth == ExplanationDepth.balanced,
                    onTap: () => setState(
                      () => _selectedDepth = ExplanationDepth.balanced,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _M3EGridChoiceCard(
              icon: LucideIcons.bookOpen,
              badgePair: semantics.inCloud,
              title: l10n.depthFull,
              isSelected: _selectedDepth == ExplanationDepth.detailed,
              onTap: () =>
                  setState(() => _selectedDepth = ExplanationDepth.detailed),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 2: Standard Deni (`LOD 2 · 92dp`, `celebrating`) peeking over the
  /// Private On-Device Readiness Card.
  Widget _buildStep2Readiness(BuildContext context, AppLocalizations l10n) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;

    return SingleChildScrollView(
      key: const ValueKey<int>(2),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            l10n.onboardingReadinessTitle,
            textAlign: TextAlign.center,
            style: m3e.typography.emphasized.headlineLarge.copyWith(
              fontSize: 27,
              height: 1.2,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingReadinessSubtitle,
            textAlign: TextAlign.center,
            style: m3e.typeScale.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Transform.translate(
            offset: const Offset(0, 10),
            child: const DeniAnimatedMascot(
              size: 92,
              pose: DeniPose.celebrating,
            ),
          ),
          EnpriveMaterialCardSurface(
            variant: EnpriveCardVariant.elevated,
            backgroundColor: surfaces.card,
            borderRadius: BorderRadius.circular(28),
            lipHeight: 3.0,
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                _ReadinessGuaranteeRow(
                  icon: LucideIcons.cpu,
                  title: l10n.readinessRow1Title,
                  subtitle: l10n.readinessRow1Desc,
                ),
                const SizedBox(height: 16),
                _ReadinessGuaranteeRow(
                  icon: LucideIcons.smartphone,
                  title: l10n.readinessRow2Title,
                  subtitle: l10n.readinessRow2Desc,
                ),
                const SizedBox(height: 16),
                _ReadinessGuaranteeRow(
                  icon: LucideIcons.eraser,
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

class _M3EGridChoiceCard extends StatelessWidget {
  final IconData icon;
  final SemanticColorPair badgePair;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _M3EGridChoiceCard({
    required this.icon,
    required this.badgePair,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = EnpriveM3ETheme.of(context).colorScheme;
    final semantics = context.enpriveSemantics;

    return EnpriveBentoChoiceCard(
      title: title,
      icon: icon,
      accentColor: isSelected ? scheme.primary : badgePair.foreground,
      accentBackground:
          isSelected ? semantics.onDevice.background : badgePair.background,
      accentBorder: badgePair.border.withValues(alpha: 0.45),
      selected: isSelected,
      onPressed: onTap,
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
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: semantics.onDevice.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: semantics.onDevice.foreground,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: m3e.typography.emphasized.titleSmall.copyWith(
                  fontSize: 15,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: m3e.typeScale.bodySmall.copyWith(
                  fontSize: 13,
                  height: 1.38,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
