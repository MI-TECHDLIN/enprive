import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart'
    show M3EShapeContainer, M3EShapeKind;

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
                        // Fade through: the old step fades out completely
                        // before the new one fades in, so steps never overlap.
                        child: AnimatedSwitcher(
                          duration: disableAnimations
                              ? Duration.zero
                              : const Duration(milliseconds: 240),
                          switchInCurve: const Interval(
                            0.5,
                            1,
                            curve: Curves.easeOut,
                          ),
                          switchOutCurve: const Interval(
                            0.5,
                            1,
                            curve: Curves.easeIn,
                          ),
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.center,
                            children: [...previous, ?current],
                          ),
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
          const SizedBox(height: 20),
          _PromiseCard(
            rows: [
              (
                kind: M3EShapeKind.cookie9Sided,
                icon: LucideIcons.cpu,
                title: l10n.readinessRow1Title,
                line: l10n.readinessRow1Desc,
              ),
              (
                kind: M3EShapeKind.clover4Leaf,
                icon: LucideIcons.smartphone,
                title: l10n.readinessRow2Title,
                line: l10n.readinessRow2Desc,
              ),
              (
                kind: M3EShapeKind.sunny,
                icon: LucideIcons.eyeOff,
                title: l10n.readinessPromiseMaskedTitle,
                line: l10n.readinessPromiseMaskedLine,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Last onboarding screen card (Option 1, "today's layout, richer card"): a
/// teal-to-paper gradient with Deni seated on its top edge, three tonal
/// promise tiles with distinct shape-library wells and one plain line each,
/// and a faint oversized shield bleeding off the corner as quiet artwork.
class _PromiseCard extends StatelessWidget {
  final List<({M3EShapeKind kind, IconData icon, String title, String line})>
  rows;

  const _PromiseCard({required this.rows});

  static const double _deniSize = 88;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    final card = Container(
      margin: const EdgeInsets.only(top: _deniSize * 0.78),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(EnpriveRadii.hero),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.primaryContainer, scheme.surfaceContainerLow],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -36,
            bottom: -28,
            child: ExcludeSemantics(
              child: Icon(
                LucideIcons.shield,
                size: 180,
                color: scheme.onPrimaryContainer.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, _deniSize * 0.42, 16, 16),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _PromiseTile(
                    kind: rows[i].kind,
                    icon: rows[i].icon,
                    title: rows[i].title,
                    line: rows[i].line,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        card,
        const ExcludeSemantics(
          child: DeniAnimatedMascot(
            size: _deniSize,
            pose: DeniPose.celebrating,
          ),
        ),
      ],
    );
  }
}

class _PromiseTile extends StatelessWidget {
  final M3EShapeKind kind;
  final IconData icon;
  final String title;
  final String line;

  const _PromiseTile({
    required this.kind,
    required this.icon,
    required this.title,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceBright,
        borderRadius: BorderRadius.circular(EnpriveRadii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: M3EShapeContainer(
              kind: kind,
              width: 44,
              height: 44,
              color: scheme.primaryContainer,
              child: Center(
                child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: m3e.typeScale.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line,
                  style: m3e.typeScale.bodyMedium.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
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
