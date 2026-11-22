import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/learn/learn_lesson.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/m3e/enprive_m3e_components.dart';

/// Shared Direction A tonal accent roles for a [LearnTopicCategory].
({Color container, Color onContainer, Color accent}) learnPaletteForCategory(
  BuildContext context,
  LearnTopicCategory category,
) {
  final scheme = EnpriveM3ETheme.of(context).colorScheme;
  final categoryColors = context.categoryColors;
  return switch (category) {
    LearnTopicCategory.policies => (
      container: categoryColors.dataCollection.container,
      onContainer: categoryColors.dataCollection.onContainer,
      accent: categoryColors.dataCollection.color,
    ),
    LearnTopicCategory.permissions => (
      container: scheme.secondaryContainer,
      onContainer: scheme.onSecondaryContainer,
      accent: scheme.secondary,
    ),
    LearnTopicCategory.sharing => (
      container: categoryColors.sharing.container,
      onContainer: categoryColors.sharing.onContainer,
      accent: categoryColors.sharing.color,
    ),
    LearnTopicCategory.evidence => (
      container: categoryColors.parentalConsent.container,
      onContainer: categoryColors.parentalConsent.onContainer,
      accent: categoryColors.parentalConsent.color,
    ),
    LearnTopicCategory.all => (
      container: scheme.secondaryContainer,
      onContainer: scheme.onSecondaryContainer,
      accent: scheme.secondary,
    ),
  };
}

/// Dedicated full-screen page for an offline illustrated Learn lesson.
///
/// Features:
/// - Collapsing Material 3 Expressive `SliverAppBar` showing the back button
///   and revealing the lesson title on scroll (`surfaceContainer` tonal fill).
/// - Generous scrollable body with lesson progress (`Lesson X of N`), intro,
///   full-width vector diagram, numbered steps, interactive quick check, Check
///   bridge CTA, and Previous/Next lesson navigation.
/// - Always-reachable pinned bottom offline Listen/Stop control using local
///   Android TTS only (zero cloud, zero consent sheet).
/// - Respects reduced motion for route transitions, 200% text scaling, Arabic
///   RTL mirroring, `>=48dp` touch targets, and TalkBack reading order.
class LearnLessonScreen extends StatefulWidget {
  final List<LearnLesson> lessons;
  final int initialIndex;
  final HybridAiBridge hybridBridge;
  final VoidCallback onCheckAppRequested;

  const LearnLessonScreen({
    super.key,
    required this.lessons,
    required this.initialIndex,
    required this.hybridBridge,
    required this.onCheckAppRequested,
  });

  /// Builds a route to [LearnLessonScreen], honoring platform reduced motion.
  static Route<void> route(
    BuildContext context, {
    required List<LearnLesson> lessons,
    required int initialIndex,
    required HybridAiBridge hybridBridge,
    required VoidCallback onCheckAppRequested,
  }) {
    final safeIndex = initialIndex.clamp(0, lessons.length - 1);
    final settings = RouteSettings(
      name: 'learn_lesson/${lessons[safeIndex].id}',
    );
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    Widget buildPage(BuildContext routeContext) {
      return EnpriveM3EBridgeScope.ensure(
        routeContext,
        child: LearnLessonScreen(
          lessons: lessons,
          initialIndex: safeIndex,
          hybridBridge: hybridBridge,
          onCheckAppRequested: onCheckAppRequested,
        ),
      );
    }

    if (reduceMotion) {
      return PageRouteBuilder<void>(
        settings: settings,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (routeContext, _, _) => buildPage(routeContext),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: buildPage,
    );
  }

  /// Pushes [LearnLessonScreen] as a full-screen route.
  static Future<void> open(
    BuildContext context, {
    required List<LearnLesson> lessons,
    required int initialIndex,
    required HybridAiBridge hybridBridge,
    required VoidCallback onCheckAppRequested,
  }) {
    return Navigator.of(context).push<void>(
      route(
        context,
        lessons: lessons,
        initialIndex: initialIndex,
        hybridBridge: hybridBridge,
        onCheckAppRequested: onCheckAppRequested,
      ),
    );
  }

  @override
  State<LearnLessonScreen> createState() => _LearnLessonScreenState();
}

class _LearnLessonScreenState extends State<LearnLessonScreen> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<VoicePlaybackEvent>? _voiceEventsSub;

  late int _currentIndex;
  bool _isScrolledPastHero = false;
  bool _isSpeaking = false;
  int _voiceSequence = 0;
  String? _activeRequestId;
  String? _voiceNotice;
  int? _selectedQuickCheckOption;

  LearnLesson get _currentLesson => widget.lessons[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.lessons.length - 1);
    _scrollController.addListener(_handleScroll);
    _voiceEventsSub = widget.hybridBridge.voicePlaybackEvents.listen((event) {
      if (!mounted) return;
      final activeId = _activeRequestId;
      if (activeId != null &&
          event.requestId.isNotEmpty &&
          event.requestId != activeId) {
        return;
      }
      switch (event.state) {
        case VoicePlaybackState.playing:
          setState(() {
            _isSpeaking = true;
            _voiceNotice = null;
          });
          break;
        case VoicePlaybackState.completed:
        case VoicePlaybackState.stopped:
        case VoicePlaybackState.idle:
          setState(() {
            _isSpeaking = false;
            _activeRequestId = null;
          });
          break;
        case VoicePlaybackState.error:
          setState(() {
            _isSpeaking = false;
            _activeRequestId = null;
            if (event.message != null && event.message!.isNotEmpty) {
              _voiceNotice = event.message;
            }
          });
          break;
        case VoicePlaybackState.synthesizing:
          break;
      }
    });
  }

  void _handleScroll() {
    final scrolled = _scrollController.hasClients && _scrollController.offset > 72;
    if (scrolled != _isScrolledPastHero && mounted) {
      setState(() {
        _isScrolledPastHero = scrolled;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _voiceEventsSub?.cancel();
    _voiceEventsSub = null;
    if (_isSpeaking) {
      unawaited(widget.hybridBridge.stopSpeaking());
    }
    super.dispose();
  }

  Future<void> _toggleListen(AppLocalizations l10n) async {
    if (_isSpeaking) {
      await _stopSpeaking();
      return;
    }

    final script = _currentLesson.spokenText(l10n);
    if (script.trim().isEmpty) return;

    final lang = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    final seq = ++_voiceSequence;
    final reqId =
        'learn_tts_${_currentLesson.id}_${DateTime.now().microsecondsSinceEpoch}';

    setState(() {
      _isSpeaking = true;
      _activeRequestId = reqId;
      _voiceNotice = null;
    });

    final spoke = await widget.hybridBridge.speakText(
      script,
      languageCode: lang,
      requestId: reqId,
    );
    if (!mounted || seq != _voiceSequence) return;
    if (!spoke) {
      setState(() {
        _isSpeaking = false;
        _activeRequestId = null;
        _voiceNotice = l10n.learnVoiceUnavailableNotice;
      });
    }
  }

  Future<void> _stopSpeaking() async {
    _voiceSequence++;
    _activeRequestId = null;
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
    await widget.hybridBridge.stopSpeaking();
  }

  void _goToLesson(int nextIndex) {
    if (nextIndex < 0 || nextIndex >= widget.lessons.length) return;
    if (_isSpeaking) {
      unawaited(_stopSpeaking());
    }
    setState(() {
      _currentIndex = nextIndex;
      _selectedQuickCheckOption = null;
      _voiceNotice = null;
      _isScrolledPastHero = false;
    });
    if (_scrollController.hasClients) {
      final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (reduceMotion) {
        _scrollController.jumpTo(0);
      } else {
        unawaited(
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final windowWidth = MediaQuery.sizeOf(context).width;
    final horizontalMargin = EnpriveSpacing.marginFor(windowWidth);

    final lesson = _currentLesson;
    final palette = learnPaletteForCategory(context, lesson.category);
    final quickCheck = lesson.quickCheck;
    final selectedOption = _selectedQuickCheckOption;
    final isQuickCheckCorrect =
        selectedOption != null && selectedOption == quickCheck.correctIndex;

    final hasPrevious = _currentIndex > 0;
    final hasNext = _currentIndex < widget.lessons.length - 1;
    final previousLesson = hasPrevious ? widget.lessons[_currentIndex - 1] : null;
    final nextLesson = hasNext ? widget.lessons[_currentIndex + 1] : null;
    final progressLabel = l10n.learnLessonProgress(
      _currentIndex + 1,
      widget.lessons.length,
    );

    return Scaffold(
      key: Key('learn_lesson_screen_${lesson.id}'),
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        key: const Key('learn_lesson_scroll_view'),
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            key: const Key('learn_lesson_app_bar'),
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: _isScrolledPastHero
                ? scheme.surfaceContainer
                : scheme.surface,
            leading: IconButton(
              key: const Key('learn_lesson_back_btn'),
              constraints: const BoxConstraints(
                minWidth: EnpriveSpacing.minTouchTarget,
                minHeight: EnpriveSpacing.minTouchTarget,
              ),
              tooltip: l10n.learnBackTooltip,
              onPressed: () {
                if (_isSpeaking) {
                  unawaited(_stopSpeaking());
                }
                Navigator.of(context).maybePop();
              },
              icon: Icon(
                isRtl ? LucideIcons.arrowRight : LucideIcons.arrowLeft,
                size: 22,
                color: scheme.onSurface,
              ),
            ),
            titleSpacing: 4,
            // ExcludeSemantics when collapsed title isn't showing so TalkBack
            // reads the full expanded hero title once without duplication.
            title: ExcludeSemantics(
              excluding: !_isScrolledPastHero,
              child: AnimatedOpacity(
                opacity: _isScrolledPastHero ? 1.0 : 0.0,
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                child: Text(
                  lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: m3e.typography.emphasized.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalMargin,
                    4,
                    horizontalMargin,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Collapsing editorial hero header (Direction A tonal well)
                      Container(
                        key: const Key('learn_lesson_hero_header'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(EnpriveRadii.xl),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: palette.container,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ExcludeSemantics(
                                    child: Icon(
                                      lesson.icon,
                                      size: 20,
                                      color: palette.onContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        progressLabel,
                                        key: const Key('learn_lesson_progress'),
                                        style: m3e
                                            .typography
                                            .emphasized
                                            .labelMedium
                                            .copyWith(color: scheme.primary),
                                      ),
                                      const SizedBox(height: 6),
                                      ExcludeSemantics(
                                        child: _LessonProgressSegments(
                                          currentIndex: _currentIndex,
                                          totalCount: widget.lessons.length,
                                          activeColor: scheme.primary,
                                          trackColor:
                                              scheme.surfaceContainerHighest,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Semantics(
                              header: true,
                              child: Text(
                                lesson.title,
                                key: const Key('learn_lesson_title'),
                                style: m3e.typography.emphasized.headlineSmall
                                    .copyWith(
                                      color: scheme.onSurface,
                                      height: 1.22,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              lesson.subtitle,
                              style: m3e.typeScale.bodyMedium.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.38,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Plain-language intro
                      Text(
                        lesson.intro,
                        key: const Key('learn_lesson_intro'),
                        style: m3e.typeScale.bodyLarge.copyWith(
                          color: scheme.onSurface,
                          height: 1.52,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Generous full-width vector diagram
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.learnSectionDiagram,
                          style: m3e.typography.emphasized.titleMedium.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      lesson.diagramBuilder(context, l10n),

                      const SizedBox(height: 24),

                      // Numbered steps (Direction A tonal segmented cards, no borders)
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.learnSectionSteps,
                          style: m3e.typography.emphasized.titleMedium.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final (idx, stepText) in lesson.steps.indexed)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: idx < lesson.steps.length - 1 ? 4 : 0,
                          ),
                          child: EnpriveSegmentedCardTile(
                            index: idx,
                            totalCount: lesson.steps.length,
                            backgroundColor: surfaces.card,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: palette.container,
                                    borderRadius: BorderRadius.circular(
                                      EnpriveRadii.chip,
                                    ),
                                  ),
                                  child: Text(
                                    '${idx + 1}',
                                    style: m3e.typography.emphasized.labelSmall
                                        .copyWith(color: palette.onContainer),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    stepText,
                                    style: m3e.typeScale.bodyMedium.copyWith(
                                      color: scheme.onSurface,
                                      height: 1.48,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Interactive one-question quick check (Direction A tonal well)
                      Container(
                        key: const Key('learn_quick_check_card'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(EnpriveRadii.card),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                DeniAnimatedMascot(
                                  size: 48,
                                  pose: selectedOption == null
                                      ? DeniPose.raiseHand
                                      : (isQuickCheckCorrect
                                            ? DeniPose.celebrating
                                            : DeniPose.explaining),
                                  holdStill: true,
                                  showAmbientGlow: false,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.learnSectionQuickCheck,
                                        style: m3e
                                            .typography
                                            .emphasized
                                            .labelLarge
                                            .copyWith(color: scheme.primary),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        quickCheck.question,
                                        style: m3e
                                            .typography
                                            .emphasized
                                            .titleSmall
                                            .copyWith(
                                              color: scheme.onSurface,
                                              height: 1.35,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            for (final (optIdx, optionText)
                                in quickCheck.options.indexed)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: optIdx == 0 ? 0 : 8,
                                ),
                                child: _QuickCheckOptionButton(
                                  key: Key('learn_quick_check_option_$optIdx'),
                                  text: optionText,
                                  isSelected: selectedOption == optIdx,
                                  isCorrectChoice:
                                      selectedOption == optIdx &&
                                      optIdx == quickCheck.correctIndex,
                                  isIncorrectChoice:
                                      selectedOption == optIdx &&
                                      optIdx != quickCheck.correctIndex,
                                  onPressed: () {
                                    setState(() {
                                      _selectedQuickCheckOption = optIdx;
                                    });
                                  },
                                ),
                              ),
                            if (selectedOption != null) ...[
                              const SizedBox(height: 12),
                              Semantics(
                                liveRegion: true,
                                child: Container(
                                  key: const Key('learn_quick_check_feedback'),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isQuickCheckCorrect
                                        ? scheme.secondaryContainer
                                        : semantics
                                              .reviewRecommended
                                              .background,
                                    borderRadius: BorderRadius.circular(
                                      EnpriveRadii.md,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ExcludeSemantics(
                                        child: Icon(
                                          isQuickCheckCorrect
                                              ? LucideIcons.checkCircle2
                                              : LucideIcons.rotateCcw,
                                          size: 18,
                                          color: isQuickCheckCorrect
                                              ? scheme.onSecondaryContainer
                                              : semantics
                                                    .reviewRecommended
                                                    .foreground,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isQuickCheckCorrect
                                                  ? l10n
                                                        .learnQuickCheckCorrectBadge
                                                  : l10n
                                                        .learnQuickCheckTryAgainBadge,
                                              style: m3e
                                                  .typography
                                                  .emphasized
                                                  .labelMedium
                                                  .copyWith(
                                                    color: isQuickCheckCorrect
                                                        ? scheme
                                                              .onSecondaryContainer
                                                        : semantics
                                                              .reviewRecommended
                                                              .foreground,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isQuickCheckCorrect
                                                  ? quickCheck.correctFeedback
                                                  : quickCheck.tryAgainFeedback,
                                              style: m3e.typeScale.bodySmall
                                                  .copyWith(
                                                    color: isQuickCheckCorrect
                                                        ? scheme
                                                              .onSecondaryContainer
                                                        : semantics
                                                              .reviewRecommended
                                                              .foreground,
                                                    height: 1.4,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Bridge into the real Check flow
                      EnpriveTactileButton(
                        key: const Key('learn_lesson_check_app_btn'),
                        label: l10n.learnCheckAppBridgeBtn,
                        variant: EnpriveButtonVariant.filled,
                        onPressed: () {
                          if (_isSpeaking) {
                            unawaited(_stopSpeaking());
                          }
                          Navigator.of(context).pop();
                          widget.onCheckAppRequested();
                        },
                      ),

                      if (previousLesson != null || nextLesson != null) ...[
                        const SizedBox(height: 16),
                        _LessonPrevNextBar(
                          previousLesson: previousLesson,
                          nextLesson: nextLesson,
                          isRtl: isRtl,
                          onPrevious: previousLesson == null
                              ? null
                              : () => _goToLesson(_currentIndex - 1),
                          onNext: nextLesson == null
                              ? null
                              : () => _goToLesson(_currentIndex + 1),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Pinned bottom action bar keeps offline Listen/Stop reachable at all scroll depths
      bottomNavigationBar: Material(
        key: const Key('learn_lesson_audio_bar'),
        color: scheme.surfaceContainer,
        elevation: 0,
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalMargin,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilledButton(
                          key: const Key('learn_lesson_listen_btn'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(
                              EnpriveSpacing.minTouchTarget,
                              EnpriveSpacing.minTouchTarget,
                            ),
                            tapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: _isSpeaking
                                ? semantics.reviewRecommended.foreground
                                : scheme.secondaryContainer,
                            foregroundColor: _isSpeaking
                                ? scheme.surface
                                : scheme.onSecondaryContainer,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                EnpriveRadii.pill,
                              ),
                            ),
                          ),
                          onPressed: () => _toggleListen(l10n),
                          child: Semantics(
                            label: _isSpeaking
                                ? l10n.learnTooltipStopLesson
                                : l10n.learnTooltipListenLesson,
                            excludeSemantics: true,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isSpeaking
                                      ? LucideIcons.square
                                      : LucideIcons.volume2,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _isSpeaking
                                        ? l10n.voiceBtnStop
                                        : l10n.voiceBtnListenOffline,
                                    style: m3e.typography.emphasized.labelLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isSpeaking)
                          Container(
                            key: const Key('learn_lesson_voice_offline_badge'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(
                                EnpriveRadii.pill,
                              ),
                            ),
                            child: Text(
                              l10n.voiceBadgeDeviceOffline,
                              style: m3e.typeScale.labelSmall.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_voiceNotice != null) ...[
                      const SizedBox(height: 8),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          key: const Key('learn_lesson_voice_notice'),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(
                              EnpriveRadii.sm,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExcludeSemantics(
                                child: Icon(
                                  LucideIcons.info,
                                  size: 15,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _voiceNotice!,
                                  style: m3e.typeScale.bodySmall.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonProgressSegments extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final Color activeColor;
  final Color trackColor;

  const _LessonProgressSegments({
    required this.currentIndex,
    required this.totalCount,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < totalCount; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: i <= currentIndex ? activeColor : trackColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LessonPrevNextBar extends StatelessWidget {
  final LearnLesson? previousLesson;
  final LearnLesson? nextLesson;
  final bool isRtl;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _LessonPrevNextBar({
    required this.previousLesson,
    required this.nextLesson,
    required this.isRtl,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final stackVertically = constraints.maxWidth < 360 || textScale > 1.35;

        final prevCard = previousLesson == null
            ? null
            : _LessonNavTile(
                key: const Key('learn_prev_lesson_btn'),
                directionLabel: l10n.learnPreviousLesson,
                lessonTitle: previousLesson!.folderTitle,
                semanticLabel: l10n.learnLessonNavPreviousSemantic(
                  previousLesson!.folderTitle,
                ),
                leadingIcon: isRtl
                    ? LucideIcons.chevronRight
                    : LucideIcons.chevronLeft,
                alignEnd: false,
                onPressed: onPrevious!,
              );

        final nextCard = nextLesson == null
            ? null
            : _LessonNavTile(
                key: const Key('learn_next_lesson_btn'),
                directionLabel: l10n.learnNextLesson,
                lessonTitle: nextLesson!.folderTitle,
                semanticLabel: l10n.learnLessonNavNextSemantic(
                  nextLesson!.folderTitle,
                ),
                trailingIcon: isRtl
                    ? LucideIcons.chevronLeft
                    : LucideIcons.chevronRight,
                alignEnd: true,
                onPressed: onNext!,
              );

        if (stackVertically) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?prevCard,
              if (prevCard != null && nextCard != null)
                const SizedBox(height: 8),
              ?nextCard,
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (prevCard != null) Expanded(child: prevCard),
              if (prevCard != null && nextCard != null)
                const SizedBox(width: 10),
              if (nextCard != null) Expanded(child: nextCard),
            ],
          ),
        );
      },
    );
  }
}

class _LessonNavTile extends StatelessWidget {
  final String directionLabel;
  final String lessonTitle;
  final String semanticLabel;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool alignEnd;
  final VoidCallback onPressed;

  const _LessonNavTile({
    super.key,
    required this.directionLabel,
    required this.lessonTitle,
    required this.semanticLabel,
    this.leadingIcon,
    this.trailingIcon,
    required this.alignEnd,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: EnpriveSpacing.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: alignEnd
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          directionLabel,
                          style: m3e.typeScale.labelSmall.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lessonTitle,
                          textAlign: alignEnd
                              ? TextAlign.end
                              : TextAlign.start,
                          style: m3e.typography.emphasized.titleSmall.copyWith(
                            color: scheme.onSurface,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 18, color: scheme.primary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickCheckOptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrectChoice;
  final bool isIncorrectChoice;
  final VoidCallback onPressed;

  const _QuickCheckOptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrectChoice,
    required this.isIncorrectChoice,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;

    final Color bg;
    final Color fg;
    final IconData indicator;

    if (isCorrectChoice) {
      bg = scheme.secondaryContainer;
      fg = scheme.onSecondaryContainer;
      indicator = LucideIcons.checkCircle2;
    } else if (isIncorrectChoice) {
      bg = semantics.reviewRecommended.background;
      fg = semantics.reviewRecommended.foreground;
      indicator = LucideIcons.info;
    } else {
      bg = scheme.surfaceContainer;
      fg = scheme.onSurface;
      indicator = LucideIcons.circle;
    }

    return Semantics(
      container: true,
      button: true,
      selected: isSelected,
      label: text,
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(EnpriveRadii.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: EnpriveSpacing.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(indicator, size: 18, color: fg),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: m3e.typeScale.bodyMedium.copyWith(
                        color: fg,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        height: 1.38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
