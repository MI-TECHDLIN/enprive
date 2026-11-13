import 'package:animated_status_card/animated_status_card.dart';
import 'package:beautiful_timeline/beautiful_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'core/theme/enprive_colors.dart';
import 'core/theme/enprive_theme.dart';
import 'domain/permissions/permission_comparator.dart';
import 'domain/review/review_coordinator.dart';
import 'domain/review/review_models.dart';
import 'l10n/app_localizations.dart';
import 'screens/onboarding_flow_screen.dart';
import 'screens/receipts_screen.dart';
import 'screens/review_result_screen.dart';
import 'screens/settings_screen.dart';
import 'services/platform/hybrid_ai_bridge.dart';
import 'services/storage/receipt_repository.dart';
import 'widgets/deni_animated_mascot.dart';
import 'widgets/enprive_provenance_chip.dart';
import 'widgets/enprive_tactile_button.dart';
import 'widgets/installed_app_picker_sheet.dart';
import 'widgets/review_progress_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Enforce 100% offline bundled font rendering (Nunito + FontBase Inter + Source Serif 4)
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const EnpriveApp());
}

class EnpriveApp extends StatefulWidget {
  const EnpriveApp({super.key});

  @override
  State<EnpriveApp> createState() => _EnpriveAppState();
}

class _EnpriveAppState extends State<EnpriveApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale newLocale) {
    setState(() => _locale = newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enprive',
      debugShowCheckedModeBanner: false,
      theme: EnpriveTheme.lightTheme,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ko')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomeScreen(currentLocale: _locale, onLocaleChange: _setLocale),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChange;

  const HomeScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChange,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const String _fallbackEduTrackFixture = '''
EDUTRACK KIDS & CLASSROOM COMPANION — PRIVACY POLICY
When a student uses EduTrack on a mobile device, we collect device identifiers, operating system telemetry, and session duration logs. In addition, our mobile application collects precise GPS location coordinates even when the application is running in the background to verify school bus zone attendance and regional classroom routing.
For reading-aloud exercises, EduTrack records student voice audio through the device microphone. Student voice recordings and derived speech-fluency transcripts are retained indefinitely on our cloud servers to train and improve our automated speech recognition models unless a verified school administrator submits a written deletion ticket.
We may share persistent advertising identifiers and app usage events with third-party advertising partners to measure campaign performance and deliver contextual or behavioral promotions across partner educational services.
''';

  static const String _fallbackCalmMathFixture = '''
CALMMATH ABACUS — PRIVACY & DATA HANDLING NOTICE
CalmMath Abacus is designed for early elementary arithmetic practice. All math problem sets, practice scores, and learning progress are stored exclusively on this device inside local application storage.
We do not collect personal identifiers, precise location data, microphone audio, or camera input. We do not integrate third-party advertising SDKs, and we never sell, rent, or transmit student usage data to external analytics brokers.
''';

  final HybridAiBridge _bridge = HybridAiBridge();
  late final ReviewCoordinator _coordinator = ReviewCoordinator(
    bridge: _bridge,
  );
  final ReceiptRepository _receiptRepo = ReceiptRepository();
  final UserPreferencesRepository _prefsRepo = UserPreferencesRepository();
  DeviceCapability? _deviceCapability;
  bool _isRunningReview = false;
  String _activeReviewTitle = 'Privacy Policy';
  bool _isCloudReviewInFlight = false;
  DeniPose _activePose = DeniPose.idle;
  int _selectedTabIndex = 0;
  ExplanationDepth _explanationDepth = ExplanationDepth.balanced;
  final List<PolicyReviewReceipt> _savedReceipts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDeviceAndIntent();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIncomingTextIntent();
    }
  }

  Future<void> _initializeDeviceAndIntent() async {
    final storedReceipts = await _receiptRepo.loadReceipts();
    final prefs = await _prefsRepo.load();
    if (mounted) {
      setState(() {
        _savedReceipts
          ..clear()
          ..addAll(storedReceipts);
        _explanationDepth = prefs.explanationDepth;
      });
      if (prefs.languageCode != widget.currentLocale.languageCode) {
        widget.onLocaleChange(Locale(prefs.languageCode));
      }
      if (!prefs.hasCompletedOnboarding) {
        unawaited(_openOnboardingFlow());
      }
    }

    final cap = await _bridge.getDeviceCapability();
    if (mounted) {
      setState(() {
        _deviceCapability = cap;
      });
    }
    if (cap.isSupported && cap.modelStatus == ModelDownloadStatus.available) {
      unawaited(_bridge.warmUpModel());
    }
    await _checkIncomingTextIntent();
  }

  Future<void> _openOnboardingFlow() async {
    if (!mounted) return;
    final result = await OnboardingFlowScreen.show(
      context,
      initialDepth: _explanationDepth,
      initialLocale: widget.currentLocale,
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _explanationDepth = result.explanationDepth;
      });
      if (result.locale.languageCode != widget.currentLocale.languageCode) {
        widget.onLocaleChange(result.locale);
      }
      await _prefsRepo.update(
        explanationDepth: result.explanationDepth,
        languageCode: result.locale.languageCode,
        hasCompletedOnboarding: true,
      );
    } else {
      await _prefsRepo.update(hasCompletedOnboarding: true);
    }
  }

  Future<void> _refreshCapability() async {
    final cap = await _bridge.getDeviceCapability();
    if (!mounted) return;
    setState(() {
      _deviceCapability = cap;
    });
  }

  Future<void> _saveReceipt(PolicyReviewReceipt saved) async {
    await _receiptRepo.saveReceipt(saved);
    if (!mounted) return;
    setState(() {
      _savedReceipts.removeWhere((r) => r.id == saved.id);
      _savedReceipts.insert(0, saved);
    });
  }

  Future<void> _deleteReceipt(String id) async {
    await _receiptRepo.deleteReceipt(id);
    if (!mounted) return;
    setState(() {
      _savedReceipts.removeWhere((r) => r.id == id);
    });
  }

  Future<void> _clearAllReceipts() async {
    await _receiptRepo.clearAllReceipts();
    if (!mounted) return;
    setState(() {
      _savedReceipts.clear();
    });
  }

  Future<void> _checkIncomingTextIntent() async {
    final incomingText = await _bridge.getInitialSelectedText();
    if (!mounted || incomingText == null || incomingText.isEmpty) return;

    setState(() {
      _activePose = DeniPose.thinking;
    });

    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      _showPasteModal(context, l10n, initialText: incomingText);
    }
  }

  Future<String> _loadFixtureText(String assetPath, String fallback) async {
    try {
      final loaded = await rootBundle.loadString(assetPath);
      if (loaded.trim().isNotEmpty) return loaded;
    } catch (_) {
      // Fallback to embedded string during unit tests if asset bundle unavailable
    }
    return fallback;
  }

  Future<void> _executePolicyReview({
    required String subjectTitle,
    required String sourceLabel,
    required String policyText,
    AppPermissionSnapshot? appPermissions,
    bool cloudConsent = false,
    bool forceLocalManualScan = false,
  }) async {
    if (_isRunningReview) return;
    setState(() {
      _isRunningReview = true;
      _activeReviewTitle = subjectTitle;
      _isCloudReviewInFlight = cloudConsent;
      _activePose = DeniPose.thinking;
    });

    final outcome = await _coordinator.runPolicyReview(
      subjectTitle: subjectTitle,
      sourceLabel: sourceLabel,
      policyText: policyText,
      appPermissions: appPermissions,
      cloudConsent: cloudConsent,
      forceLocalManualScan: forceLocalManualScan,
    );

    if (!mounted) return;
    setState(() {
      _isRunningReview = false;
    });

    final receipt = outcome.receipt;
    if (receipt == null) return;

    setState(() {
      _activePose = switch (receipt.overallState) {
        ReviewOverallState.reviewRecommended => DeniPose.explaining,
        ReviewOverallState.noConcern => DeniPose.celebrating,
        ReviewOverallState.insufficientEvidence => DeniPose.support,
      };
    });

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewResultScreen(
          receipt: receipt,
          coordinator: _coordinator,
          cloudConsentGrantedForSession:
              receipt.inferenceSource == InferenceSource.inCloud,
          onSaveReceipt: _saveReceipt,
        ),
      ),
    );
  }

  Future<void> _runQuickSampleReview({required bool isEduTrack}) async {
    final policyText = isEduTrack
        ? await _loadFixtureText(
            'assets/fixtures/synthetic_policy_edutrack.txt',
            _fallbackEduTrackFixture,
          )
        : await _loadFixtureText(
            'assets/fixtures/synthetic_policy_calmmath.txt',
            _fallbackCalmMathFixture,
          );
    if (!mounted) return;
    await _executePolicyReview(
      subjectTitle: isEduTrack ? 'EduTrack Classroom' : 'CalmMath Kids',
      sourceLabel: 'Classroom Sample',
      policyText: policyText,
      appPermissions: isEduTrack
          ? PermissionComparator.demoEduTrackSnapshot
          : PermissionComparator.demoCalmMathSnapshot,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKorean = widget.currentLocale.languageCode == 'ko';

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: EnpriveColors.teal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Symbols.shield_moon_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: EnpriveColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                final nextLocale = isKorean
                    ? const Locale('en')
                    : const Locale('ko');
                widget.onLocaleChange(nextLocale);
                unawaited(
                  _prefsRepo.update(languageCode: nextLocale.languageCode),
                );
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
                  isKorean ? 'EN' : '한국어',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: EnpriveColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildHomeTab(context, l10n, isKorean),
          ReceiptsScreen(
            receipts: _savedReceipts,
            coordinator: _coordinator,
            isKorean: isKorean,
            onDeleteReceipt: _deleteReceipt,
            onStartReviewRequested: () {
              setState(() => _selectedTabIndex = 0);
            },
          ),
          SettingsScreen(
            bridge: _bridge,
            capability: _deviceCapability,
            explanationDepth: _explanationDepth,
            currentLocale: widget.currentLocale,
            savedReceiptsCount: _savedReceipts.length,
            onExplanationDepthChanged: (depth) {
              setState(() => _explanationDepth = depth);
              unawaited(_prefsRepo.update(explanationDepth: depth));
            },
            onLocaleChanged: (locale) {
              widget.onLocaleChange(locale);
              unawaited(_prefsRepo.update(languageCode: locale.languageCode));
            },
            onRefreshCapability: _refreshCapability,
            onClearAllReceipts: _clearAllReceipts,
            onReplayOnboarding: _openOnboardingFlow,
          ),
        ],
      ),
      bottomNavigationBar: _FloatingBottomNavDock(
        selectedIndex: _selectedTabIndex,
        receiptsCount: _savedReceipts.length,
        isKorean: isKorean,
        onSelect: (index) => setState(() => _selectedTabIndex = index),
      ),
    );
  }

  Widget _buildHomeTab(
    BuildContext context,
    AppLocalizations l10n,
    bool isKorean,
  ) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          children: [
            // 1. Editorial Hero Header with Deni (no state card or debug buttons)
            Center(
              child: DeniAnimatedMascot(
                size: 88,
                pose: _isRunningReview ? DeniPose.thinking : _activePose,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Centered Editorial Headline & Subtitle
            Text(
              isKorean
                  ? '아이들이 쓰는 앱,\n약관과 권한을 한눈에'
                  : 'A clearer look at the\napps children use',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge
                  ?.copyWith(fontSize: 30),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                l10n.homePrivacySubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: EnpriveColors.inkSecondary),
              ),
            ),
            const SizedBox(height: 28),

            // 3. Two Tactile Pill CTAs
            if (_isRunningReview)
              ReviewProgressCard(
                subjectTitle: _activeReviewTitle,
                isCloudCheck: _isCloudReviewInFlight,
                isKorean: isKorean,
                processStream: _coordinator.analysisEvents,
              )
            else ...[
              EnpriveTactileButton(
                label: l10n.btnCheckApp,
                onPressed: () {
                  setState(() => _activePose = DeniPose.explaining);
                  _showCheckAppModal(context, l10n);
                },
              ),
              const SizedBox(height: 12),
              EnpriveTactileButton(
                label: l10n.btnPasteTerms,
                isSecondary: true,
                onPressed: () {
                  setState(() => _activePose = DeniPose.thinking);
                  _showPasteModal(context, l10n);
                },
              ),
            ],

            const SizedBox(height: 28),

            // 4. Quick Sample App Checks
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isKorean ? '샘플 앱 바로 검토하기' : 'Try a sample app check',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: EnpriveColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                final disableAnimations =
                    MediaQuery.maybeDisableAnimationsOf(context) ?? false;
                final stackVertically =
                    constraints.maxWidth < 340 || textScale > 1.35;
                final cardHeight = stackVertically
                    ? (220 * textScale).clamp(220.0, 420.0)
                    : 208.0;
                final entryAnim = disableAnimations
                    ? EntryAnimationType.none
                    : EntryAnimationType.slideUp;

                final eduCard = AnimatedStatusCard(
                  title: 'EduTrack Classroom',
                  value: isKorean ? '권한 3건' : '3 requests',
                  subtitle: isKorean
                      ? '숙제·출결 샘플'
                      : 'Homework & attendance',
                  icon: Symbols.school_rounded,
                  trendValue: isKorean ? '확인 권장' : 'Review',
                  trendDirection: TrendDirection.up,
                  styleType: CardStyleType.outlined,
                  statusType: CardStatusType.warning,
                  animationType: entryAnim,
                  height: cardHeight,
                  borderRadius: 24,
                  accentColor: EnpriveColors.stateReviewRecommendedFg,
                  backgroundColor: EnpriveColors.surface,
                  foregroundColor: EnpriveColors.ink,
                  onTap: _isRunningReview
                      ? null
                      : () => _runQuickSampleReview(isEduTrack: true),
                );

                final calmCard = AnimatedStatusCard(
                  title: 'CalmMath Kids',
                  value: isKorean ? '민감 0건' : '0 sensitive',
                  subtitle: isKorean
                      ? '오프라인 수학 샘플'
                      : 'Offline math practice',
                  icon: Symbols.calculate_rounded,
                  trendValue: isKorean ? '단순함' : 'Minimal',
                  trendDirection: TrendDirection.neutral,
                  styleType: CardStyleType.outlined,
                  statusType: CardStatusType.success,
                  animationType: entryAnim,
                  height: cardHeight,
                  borderRadius: 24,
                  accentColor: EnpriveColors.tealStrong,
                  backgroundColor: EnpriveColors.surface,
                  foregroundColor: EnpriveColors.ink,
                  onTap: _isRunningReview
                      ? null
                      : () => _runQuickSampleReview(isEduTrack: false),
                );

                if (stackVertically) {
                  return Column(
                    children: [
                      eduCard,
                      const SizedBox(height: 12),
                      calmCard,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: eduCard),
                    const SizedBox(width: 12),
                    Expanded(child: calmCard),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // 5. What We Check For
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              decoration: BoxDecoration(
                color: EnpriveColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isKorean ? '중점 확인 항목' : 'What we check for',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: EnpriveColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final disableAnimations =
                          MediaQuery.maybeDisableAnimationsOf(context) ?? false;
                      return BeautifulTimeline(
                        axis: TimelineAxis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        showAnimation: !disableAnimations,
                        theme: TimelineThemeData(
                          indicatorStyle: IndicatorStyle.icon,
                          lineStyle: LineStyle.gradient,
                          lineGradientStart: EnpriveColors.tealStrong,
                          lineGradientEnd: EnpriveColors.chipInCloudFg,
                          lineWidth: 2.5,
                          backgroundColor: EnpriveColors.surface,
                          cardBackground: EnpriveColors.paper,
                          cardElevation: 0,
                          cardPadding: const EdgeInsets.all(14),
                          cardBorderRadius: BorderRadius.circular(18),
                          padding: EdgeInsets.zero,
                          indicatorSize: 34,
                          spacingBetweenEvents: 10,
                          titleStyle: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: EnpriveColors.ink,
                          ),
                          descriptionStyle: const TextStyle(
                            fontSize: 13,
                            height: 1.38,
                            color: EnpriveColors.inkSecondary,
                          ),
                          dateStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: EnpriveColors.tealStrong,
                          ),
                        ),
                        events: [
                          TimelineEvent(
                            date: '01',
                            icon: Symbols.format_quote_rounded,
                            indicatorColor: EnpriveColors.tealStrong,
                            title: isKorean
                                ? '정확한 약관 원문'
                                : 'Exact policy quotes',
                            description: isKorean
                                ? '공유·음성 녹음·보관 기간 조항을 원문과 함께 짚어줍니다.'
                                : 'Flags sharing, voice recording, and retention with verbatim quotes.',
                          ),
                          TimelineEvent(
                            date: '02',
                            icon: Symbols.shield_lock_rounded,
                            indicatorColor:
                                EnpriveColors.stateReviewRecommendedFg,
                            title: isKorean
                                ? '휴대폰 권한 불일치'
                                : 'Phone permission mismatches',
                            description: isKorean
                                ? '카메라·마이크·위치 권한을 약관 설명과 직접 대조합니다.'
                                : 'Compares Camera, Mic, and Location access against what the policy claims.',
                          ),
                          TimelineEvent(
                            date: '03',
                            icon: Symbols.touch_app_rounded,
                            indicatorColor: EnpriveColors.chipInCloudFg,
                            title: isKorean
                                ? '어디서나 텍스트 선택'
                                : 'Select text anywhere',
                            description: isKorean
                                ? '다른 앱에서 문장을 선택하고 Android 메뉴의 Enprive Check를 누르세요.'
                                : 'Highlight terms in any app and tap Enprive Check from Android’s menu.',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // 4. Monday Home "Recently visited →" Card Group (x-monday-home.jpeg)
            if (_savedReceipts.isNotEmpty) ...[
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: EnpriveColors.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isKorean ? '최근 검토한 영수증' : 'Recently reviewed',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: EnpriveColors.ink,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: EnpriveColors.surfaceMuted,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Symbols.arrow_forward_rounded,
                              size: 16,
                              color: EnpriveColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._savedReceipts.take(2).toList().asMap().entries.map((e) {
                      final idx = e.key;
                      final receipt = e.value;
                      final isConcern =
                          receipt.overallState ==
                          ReviewOverallState.reviewRecommended;
                      return Column(
                        children: [
                          if (idx > 0)
                            Divider(
                              height: 20,
                              color: EnpriveColors.ink.withValues(alpha: 0.06),
                            ),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ReviewResultScreen(
                                    receipt: receipt,
                                    coordinator: _coordinator,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isConcern
                                          ? EnpriveColors
                                                .stateReviewRecommendedBg
                                          : EnpriveColors.stateNoConcernBg,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      isConcern
                                          ? Symbols.warning_amber_rounded
                                          : Symbols.check_circle_rounded,
                                      color: isConcern
                                          ? EnpriveColors
                                                .stateReviewRecommendedFg
                                          : EnpriveColors.stateNoConcernFg,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          receipt.subjectTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: EnpriveColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${receipt.sourceMatchedCount} verified clauses',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: EnpriveColors.inkSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Symbols.chevron_right_rounded,
                                    color: EnpriveColors.inkSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showCheckAppModal(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final eduText = await _loadFixtureText(
      'assets/fixtures/synthetic_policy_edutrack.txt',
      _fallbackEduTrackFixture,
    );
    final calmText = await _loadFixtureText(
      'assets/fixtures/synthetic_policy_calmmath.txt',
      _fallbackCalmMathFixture,
    );
    if (!context.mounted) return;

    final selected = await InstalledAppPickerSheet.show(
      context,
      bridge: _bridge,
      eduTrackPolicyText: eduText,
      calmMathPolicyText: calmText,
    );
    if (selected == null || !mounted) return;

    await _executePolicyReview(
      subjectTitle: selected.subjectTitle,
      sourceLabel: selected.sourceLabel,
      policyText: selected.policyText,
      appPermissions: selected.permissionSnapshot,
    );
  }

  void _showPasteModal(
    BuildContext context,
    AppLocalizations l10n, {
    String? initialText,
  }) {
    final controller = TextEditingController(text: initialText ?? '');
    final urlController = TextEditingController(
      text: 'https://edutrack.example.edu/privacy',
    );
    final titleController = TextEditingController(
      text: initialText != null && initialText.isNotEmpty
          ? 'Selected Policy Excerpt'
          : 'Privacy Policy',
    );
    bool isLinkMode = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: EnpriveColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: EnpriveColors.ink.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.btnPasteTerms,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final sample = await _loadFixtureText(
                            'assets/fixtures/synthetic_policy_edutrack.txt',
                            _fallbackEduTrackFixture,
                          );
                          titleController.text = 'EduTrack Classroom Companion';
                          controller.text = sample;
                          urlController.text =
                              'https://edutrack.example.edu/privacy';
                        },
                        child: const Text(
                          'Try sample text',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: EnpriveColors.tealStrong,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Segmented Source Mode Pills: Paste text vs Policy link
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: EnpriveColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () =>
                                setSheetState(() => isLinkMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !isLinkMode
                                    ? EnpriveColors.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Paste text',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: !isLinkMode
                                      ? EnpriveColors.ink
                                      : EnpriveColors.inkSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => setSheetState(() => isLinkMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isLinkMode
                                    ? EnpriveColors.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Policy link',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isLinkMode
                                      ? EnpriveColors.ink
                                      : EnpriveColors.inkSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'App name',
                      filled: true,
                      fillColor: EnpriveColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (isLinkMode) ...[
                    TextField(
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        hintText: 'https://app.example.com/privacy',
                        prefixIcon: const Icon(
                          Symbols.link_rounded,
                          size: 18,
                          color: EnpriveColors.tealStrong,
                        ),
                        filled: true,
                        fillColor: EnpriveColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          backgroundColor: EnpriveColors.surfaceMuted,
                          side: BorderSide.none,
                          label: const Text(
                            'edutrack.example.edu/privacy',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            titleController.text =
                                'EduTrack Classroom Companion';
                            urlController.text =
                                'https://edutrack.example.edu/privacy';
                          },
                        ),
                        ActionChip(
                          backgroundColor: EnpriveColors.surfaceMuted,
                          side: BorderSide.none,
                          label: const Text(
                            'calmmath.example.org/privacy',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            titleController.text = 'CalmMath Abacus';
                            urlController.text =
                                'https://calmmath.example.org/privacy';
                          },
                        ),
                      ],
                    ),
                  ] else
                    TextField(
                      controller: controller,
                      maxLines: 5,
                      style: const TextStyle(
                        fontFamily: EnpriveTheme.quoteFontFamily,
                        fontSize: 14.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Paste privacy policy text here…',
                        filled: true,
                        fillColor: EnpriveColors.quoteSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  EnpriveTactileButton(
                    label: widget.currentLocale.languageCode == 'ko'
                        ? '이 휴대폰에서 검토하기'
                        : 'Review on this phone',
                    onPressed: () async {
                      if (isLinkMode) {
                        final rawUrl = urlController.text.trim();
                        if (rawUrl.isEmpty) return;
                        final isCalm = rawUrl.toLowerCase().contains(
                          'calmmath',
                        );
                        final resolvedText = await _loadFixtureText(
                          isCalm
                              ? 'assets/fixtures/synthetic_policy_calmmath.txt'
                              : 'assets/fixtures/synthetic_policy_edutrack.txt',
                          isCalm
                              ? _fallbackCalmMathFixture
                              : _fallbackEduTrackFixture,
                        );
                        final subject =
                            titleController.text.trim().isEmpty ||
                                titleController.text.trim() == 'Privacy Policy'
                            ? (isCalm
                                  ? 'CalmMath Abacus'
                                  : 'EduTrack Classroom Companion')
                            : titleController.text.trim();
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                        await _executePolicyReview(
                          subjectTitle: subject,
                          sourceLabel: rawUrl,
                          policyText: resolvedText,
                        );
                        return;
                      }

                      final rawText = controller.text.trim();
                      final subject = titleController.text.trim().isEmpty
                          ? 'Privacy Policy'
                          : titleController.text.trim();
                      Navigator.pop(sheetContext);
                      if (rawText.isEmpty) return;
                      await _executePolicyReview(
                        subjectTitle: subject,
                        sourceLabel: 'Pasted Snapshot',
                        policyText: rawText,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Floating Pill Bottom Navigation Dock (`x-monday-home.jpeg` pattern).
class _FloatingBottomNavDock extends StatelessWidget {
  final int selectedIndex;
  final int receiptsCount;
  final bool isKorean;
  final ValueChanged<int> onSelect;

  const _FloatingBottomNavDock({
    required this.selectedIndex,
    required this.receiptsCount,
    required this.isKorean,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Symbols.home_rounded, label: isKorean ? '홈' : 'Home'),
      (
        icon: Symbols.receipt_long_rounded,
        label: isKorean ? '영수증' : 'Receipts',
      ),
      (icon: Symbols.tune_rounded, label: isKorean ? '설정' : 'Settings'),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: EnpriveColors.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: EnpriveColors.ink.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = selectedIndex == index;
              final showBadge = index == 1 && receiptsCount > 0;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onSelect(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Badge(
                        isLabelVisible: showBadge,
                        label: Text('$receiptsCount'),
                        backgroundColor: EnpriveColors.tealStrong,
                        child: Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? EnpriveColors.tealStrong
                              : EnpriveColors.inkSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? EnpriveColors.tealStrong
                              : EnpriveColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

void unawaited(Future<void> future) {}
