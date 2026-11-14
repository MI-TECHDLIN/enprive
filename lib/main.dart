import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'core/theme/enprive_theme.dart';
import 'domain/permissions/permission_comparator.dart';
import 'domain/privacy/pii_redactor.dart';
import 'domain/review/review_coordinator.dart';
import 'domain/review/review_models.dart';
import 'l10n/app_localizations.dart';
import 'l10n/enprive_languages.dart';
import 'screens/onboarding_flow_screen.dart';
import 'screens/receipts_screen.dart';
import 'screens/review_result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/platform/hybrid_ai_bridge.dart';
import 'services/storage/receipt_repository.dart';
import 'widgets/cloud_consent_sheet.dart';
import 'widgets/deni_animated_mascot.dart';
import 'widgets/enprive_tactile_button.dart';
import 'widgets/installed_app_picker_sheet.dart';
import 'widgets/language_picker_sheet.dart';
import 'widgets/m3e/enprive_m3e_components.dart';
import 'widgets/review_progress_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Enforce 100% offline bundled font rendering (Nunito + FontBase Inter + Source Serif 4)
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const EnpriveApp());
}

class EnpriveApp extends StatefulWidget {
  final bool showSplashOnLaunch;
  final Duration splashDuration;

  const EnpriveApp({
    super.key,
    this.showSplashOnLaunch = true,
    this.splashDuration = const Duration(milliseconds: 1400),
  });

  @override
  State<EnpriveApp> createState() => _EnpriveAppState();
}

class _EnpriveAppState extends State<EnpriveApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  void _setLocale(Locale newLocale) {
    setState(() => _locale = newLocale);
  }

  void _setThemeMode(ThemeMode newThemeMode) {
    setState(() => _themeMode = newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness =
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    final activeM3EData = EnpriveM3ETheme.resolve(
      mode: _themeMode,
      platformBrightness: platformBrightness,
    );

    return M3EMaterialApp(
      title: 'Enprive',
      debugShowCheckedModeBanner: false,
      data: activeM3EData,
      typeface: EnpriveM3ETheme.typefaceConfig,
      autoTheming: _themeMode == ThemeMode.system,
      dynamicColoring: false,
      initialTheme: activeM3EData.brightness,
      theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
      darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
      appBuilder: (context, child) {
        return EnpriveM3EBridgeScope(
          themeMode: _themeMode,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: HomeScreen(
        currentLocale: _locale,
        onLocaleChange: _setLocale,
        currentThemeMode: _themeMode,
        onThemeModeChange: _setThemeMode,
        showSplashOnLaunch: widget.showSplashOnLaunch,
        splashDuration: widget.splashDuration,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChange;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChange;
  final bool showSplashOnLaunch;
  final Duration splashDuration;

  const HomeScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChange,
    this.currentThemeMode = ThemeMode.system,
    this.onThemeModeChange,
    this.showSplashOnLaunch = true,
    this.splashDuration = const Duration(milliseconds: 1400),
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
  bool _isConsentSheetOpen = false;
  String _activeReviewTitle = 'Privacy Policy';
  bool _isCloudReviewInFlight = false;
  DeniPose _activePose = DeniPose.idle;
  int _selectedTabIndex = 0;
  ExplanationDepth _explanationDepth = ExplanationDepth.balanced;
  final List<PolicyReviewReceipt> _savedReceipts = [];
  late bool _isSplashVisible = widget.showSplashOnLaunch;
  bool _pendingFirstRunOnboarding = false;
  String? _pendingIncomingText;

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

  void _completeSplash() {
    if (!_isSplashVisible || !mounted) return;
    setState(() => _isSplashVisible = false);

    if (_pendingIncomingText != null) {
      final text = _pendingIncomingText!;
      _pendingIncomingText = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _activePose = DeniPose.thinking);
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          _showPasteModal(context, l10n, initialText: text);
        }
      });
      return;
    }

    if (_pendingFirstRunOnboarding) {
      _pendingFirstRunOnboarding = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_openOnboardingFlow());
        }
      });
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
      final savedLocale = enpriveLanguageByCode(prefs.languageCode).locale;
      if (savedLocale.languageCode != widget.currentLocale.languageCode) {
        widget.onLocaleChange(savedLocale);
      }
      if (prefs.themeMode != widget.currentThemeMode) {
        widget.onThemeModeChange?.call(prefs.themeMode);
      }
      if (!prefs.hasCompletedOnboarding) {
        if (_isSplashVisible) {
          _pendingFirstRunOnboarding = true;
        } else {
          unawaited(_openOnboardingFlow());
        }
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

    if (_isSplashVisible) {
      _pendingIncomingText = incomingText;
      _completeSplash();
      return;
    }

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
    if (_isRunningReview || _isConsentSheetOpen) return;
    setState(() {
      _isRunningReview = true;
      _activeReviewTitle = subjectTitle;
      _isCloudReviewInFlight = cloudConsent;
      _activePose = DeniPose.thinking;
    });

    final ReviewExecutionResult outcome;
    try {
      outcome = await _coordinator.runPolicyReview(
        subjectTitle: subjectTitle,
        sourceLabel: sourceLabel,
        policyText: policyText,
        appPermissions: appPermissions,
        cloudConsent: cloudConsent,
        forceLocalManualScan: forceLocalManualScan,
        languageCode: widget.currentLocale.languageCode,
      );
    } on HybridOperationCancelledException {
      if (mounted) {
        setState(() {
          _isRunningReview = false;
          _isCloudReviewInFlight = false;
          _activePose = DeniPose.idle;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isRunningReview = false;
      _isCloudReviewInFlight = false;
    });

    final receipt = outcome.receipt;
    if (receipt == null) {
      if (outcome.needsCloudConsentOrManual) {
        setState(() {
          _isConsentSheetOpen = true;
          _activePose = DeniPose.support;
        });
        final CloudConsentDecision decision;
        try {
          decision = await CloudConsentSheet.show(
            context,
            subjectTitle: subjectTitle,
            policyText: outcome.redactedPreview ??
                PiiRedactor.redact(policyText).redactedText,
            deviceReason: outcome.errorReason,
          );
        } finally {
          if (mounted) {
            setState(() {
              _isConsentSheetOpen = false;
            });
          } else {
            _isConsentSheetOpen = false;
          }
        }
        if (!mounted) return;
        switch (decision) {
          case CloudConsentDecision.useCloudOnce:
            await _executePolicyReview(
              subjectTitle: subjectTitle,
              sourceLabel: sourceLabel,
              policyText: policyText,
              appPermissions: appPermissions,
              cloudConsent: true,
            );
            return;
          case CloudConsentDecision.reviewLocally:
            await _executePolicyReview(
              subjectTitle: subjectTitle,
              sourceLabel: sourceLabel,
              policyText: policyText,
              appPermissions: appPermissions,
              forceLocalManualScan: true,
            );
            return;
          case CloudConsentDecision.cancelled:
            setState(() {
              _activePose = DeniPose.idle;
            });
            return;
        }
      }
      setState(() {
        _activePose = DeniPose.idle;
      });
      return;
    }

    setState(() {
      _activePose = switch (receipt.overallState) {
        ReviewOverallState.reviewRecommended => DeniPose.explaining,
        ReviewOverallState.noConcern => DeniPose.idle,
        ReviewOverallState.insufficientEvidence => DeniPose.support,
      };
    });

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewResultScreen(
          receipt: receipt,
          coordinator: _coordinator,
          cloudConsentGrantedForSession: false,
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
    final activeLang = enpriveLanguageByCode(widget.currentLocale.languageCode);
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final surfaces = context.surfaceTokens;
    final colorScheme = context.colorScheme;

    final mainScaffold = Scaffold(
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: surfaces.hairlineBorder,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'assets/images/enprive_logo.png',
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 20.0),
            child: Tooltip(
              message: l10n.chooseLanguage,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () async {
                  final picked = await EnpriveLanguagePickerSheet.show(
                    context,
                    currentLocale: widget.currentLocale,
                  );
                  if (picked == null) return;
                  widget.onLocaleChange(picked);
                  unawaited(
                    _prefsRepo.update(languageCode: picked.languageCode),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: surfaces.cardMuted,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: surfaces.hairlineBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.globe,
                        size: 14,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        activeLang.shortBadge,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
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
          _buildHomeTab(context, l10n),
          ReceiptsScreen(
            receipts: _savedReceipts,
            coordinator: _coordinator,
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
            currentThemeMode: widget.currentThemeMode,
            savedReceiptsCount: _savedReceipts.length,
            onExplanationDepthChanged: (depth) {
              setState(() => _explanationDepth = depth);
              unawaited(_prefsRepo.update(explanationDepth: depth));
            },
            onLocaleChanged: (locale) {
              widget.onLocaleChange(locale);
              unawaited(_prefsRepo.update(languageCode: locale.languageCode));
            },
            onThemeModeChanged: (mode) {
              widget.onThemeModeChange?.call(mode);
              unawaited(_prefsRepo.update(themeMode: mode));
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
        l10n: l10n,
        onSelect: (index) => setState(() => _selectedTabIndex = index),
      ),
    );

    return Stack(
      children: [
        ExcludeSemantics(
          excluding: _isSplashVisible,
          child: IgnorePointer(
            ignoring: _isSplashVisible,
            child: mainScaffold,
          ),
        ),
        AnimatedSwitcher(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 320),
          switchOutCurve: Curves.easeOutCubic,
          child: _isSplashVisible
              ? EnpriveSplashScreen(
                  key: const ValueKey<String>('enprive_splash'),
                  displayDuration: widget.splashDuration,
                  onCompleted: _completeSplash,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildHomeTab(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          children: [
            // 1. Editorial Hero Stage with Deni (LOD 2 · 88dp)
            Center(
              child: DeniAnimatedMascot(
                size: 88,
                pose: _isRunningReview ? DeniPose.thinking : _activePose,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Centered Editorial Headline & Subtitle
            Text(
              l10n.homeHeroHeadline,
              textAlign: TextAlign.center,
              style: m3e.typography.emphasized.displaySmall.copyWith(
                fontSize: 30,
                height: 1.15,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                l10n.homePrivacySubtitle,
                textAlign: TextAlign.center,
                style: m3e.typeScale.bodyLarge.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 3. Two Tactile Pill CTAs (or Live 4-Stage M3E ReviewProgressCard)
            if (_isRunningReview)
              ReviewProgressCard(
                subjectTitle: _activeReviewTitle,
                isCloudCheck: _isCloudReviewInFlight,
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

            // 4. Quick Sample App Checks (M3E Bento Cards inspired by Music OS & colo.jpeg)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.trySampleCheck,
                style: m3e.typography.emphasized.titleMedium.copyWith(
                  fontSize: 17,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                final stackVertically =
                    constraints.maxWidth < 340 || textScale > 1.35;

                final eduCard = _SampleAppM3EBentoCard(
                  title: 'EduTrack Classroom',
                  value: l10n.eduTrackValue,
                  subtitle: l10n.eduTrackSubtitle,
                  trendBadge: l10n.eduTrackTrend,
                  icon: LucideIcons.graduationCap,
                  semanticPair: semantics.reviewRecommended,
                  onTap: _isRunningReview
                      ? null
                      : () => _runQuickSampleReview(isEduTrack: true),
                );

                final calmCard = _SampleAppM3EBentoCard(
                  title: 'CalmMath Kids',
                  value: l10n.calmMathValue,
                  subtitle: l10n.calmMathSubtitle,
                  trendBadge: l10n.calmMathTrend,
                  icon: LucideIcons.calculator,
                  semanticPair: semantics.noConcern,
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

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: eduCard),
                      const SizedBox(width: 12),
                      Expanded(child: calmCard),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 5. What We Check For (M3E Expressive Segmented Containment)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.whatWeCheckTitle,
                style: m3e.typography.emphasized.titleMedium.copyWith(
                  fontSize: 17,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _WhatWeCheckSegmentedGroup(l10n: l10n),

            // 6. Recently Reviewed (Tactile Segmented M3E Cards)
            if (_savedReceipts.isNotEmpty) ...[
              const SizedBox(height: 28),
              EnpriveMaterialCardSurface(
                variant: EnpriveCardVariant.elevated,
                backgroundColor: surfaces.card,
                borderRadius: BorderRadius.circular(28),
                lipHeight: 3.0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.recentlyReviewed,
                            style: m3e.typography.emphasized.titleMedium
                                .copyWith(
                                  fontSize: 17,
                                  color: scheme.onSurface,
                                ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHigh,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.arrowRight,
                              size: 16,
                              color: scheme.onSurface,
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
                      final badgePair = isConcern
                          ? semantics.reviewRecommended
                          : semantics.noConcern;
                      final count = _savedReceipts.take(2).length;

                      return Padding(
                        padding: EdgeInsets.only(top: idx > 0 ? 4 : 0),
                        child: EnpriveSegmentedCardTile(
                          index: idx,
                          totalCount: count,
                          backgroundColor: scheme.surfaceContainerLow,
                          lipHeight: 2.0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
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
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: badgePair.background,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  isConcern
                                      ? LucideIcons.triangleAlert
                                      : LucideIcons.circleCheck,
                                  color: badgePair.foreground,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      receipt.subjectTitle,
                                      style: m3e.typography.emphasized.titleSmall
                                          .copyWith(
                                            fontSize: 15,
                                            color: scheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.verifiedClausesCount(
                                        receipt.sourceMatchedCount,
                                      ),
                                      style: m3e.typeScale.bodySmall.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                LucideIcons.chevronRight,
                                size: 18,
                                color: scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
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
          ? l10n.selectedExcerptTitle
          : l10n.defaultSubjectTitle,
    );
    bool isLinkMode = false;
    final rootScheme = EnpriveM3ETheme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: rootScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final m3e = EnpriveM3ETheme.of(sheetContext);
            final scheme = m3e.colorScheme;
            final surfaces = sheetContext.enpriveSurfaces;
            final typeExt = sheetContext.enpriveType;

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
                        color: scheme.outlineVariant,
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
                          style: m3e.typography.emphasized.headlineMedium
                              .copyWith(
                                color: scheme.onSurface,
                              ),
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
                        child: Text(
                          l10n.trySampleText,
                          style: m3e.typography.emphasized.labelLarge.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Segmented Source Mode Pills: Paste text vs Policy link
                  SizedBox(
                    width: double.infinity,
                    child: M3ESegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        M3ESegment<bool>(
                          value: false,
                          icon: const Icon(LucideIcons.fileText, size: 16),
                          label: l10n.modePasteText,
                        ),
                        M3ESegment<bool>(
                          value: true,
                          icon: const Icon(LucideIcons.link2, size: 16),
                          label: l10n.modePolicyLink,
                        ),
                      ],
                      selected: {isLinkMode},
                      onSelectionChanged: (selection) {
                        setSheetState(() => isLinkMode = selection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: titleController,
                    style: m3e.typeScale.bodyLarge.copyWith(
                      color: scheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.hintAppName,
                      filled: true,
                      fillColor: surfaces.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: surfaces.hairlineBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: surfaces.hairlineBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (isLinkMode) ...[
                    TextField(
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      style: m3e.typeScale.bodyMedium.copyWith(
                        color: scheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'https://app.example.com/privacy',
                        prefixIcon: Icon(
                          LucideIcons.link2,
                          size: 18,
                          color: scheme.primary,
                        ),
                        filled: true,
                        fillColor: surfaces.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: surfaces.hairlineBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: surfaces.hairlineBorder,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        M3EChip(
                          label: 'edutrack.example.edu/privacy',
                          type: M3EChipType.assist,
                          onPressed: () {
                            titleController.text =
                                'EduTrack Classroom Companion';
                            urlController.text =
                                'https://edutrack.example.edu/privacy';
                          },
                        ),
                        M3EChip(
                          label: 'calmmath.example.org/privacy',
                          type: M3EChipType.assist,
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
                      style: typeExt.policyQuotation,
                      decoration: InputDecoration(
                        hintText: l10n.hintPastePolicy,
                        filled: true,
                        fillColor: surfaces.quoteSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: surfaces.hairlineBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: surfaces.hairlineBorder,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  EnpriveTactileButton(
                    label: l10n.btnReviewOnPhone,
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
                        final trimmedTitle = titleController.text.trim();
                        final subject =
                            trimmedTitle.isEmpty ||
                                trimmedTitle == l10n.defaultSubjectTitle ||
                                trimmedTitle == 'Privacy Policy'
                            ? (isCalm
                                  ? 'CalmMath Abacus'
                                  : 'EduTrack Classroom Companion')
                            : trimmedTitle;
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
                          ? l10n.defaultSubjectTitle
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

/// Expressive Bento Sample App Card inspired by the "Music OS" and Dark Bento
/// Grid reference boards.
class _SampleAppM3EBentoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String trendBadge;
  final IconData icon;
  final SemanticColorPair semanticPair;
  final VoidCallback? onTap;

  const _SampleAppM3EBentoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trendBadge,
    required this.icon,
    required this.semanticPair,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EnpriveBentoChoiceCard(
      title: title,
      metricHighlight: value,
      metricHighlightColor: semanticPair.foreground,
      subtitle: subtitle,
      footerTag: trendBadge,
      icon: icon,
      accentColor: semanticPair.foreground,
      accentBackground: semanticPair.background,
      accentBorder: semanticPair.border.withValues(alpha: 0.45),
      onPressed: onTap,
    );
  }
}

/// Expressive Segmented Containment group for "What we check for" (`22dp` outer
/// corners, `4dp` inner seam corners, circular tabular `01`/`02`/`03` badges).
class _WhatWeCheckSegmentedGroup extends StatelessWidget {
  final AppLocalizations l10n;

  const _WhatWeCheckSegmentedGroup({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;

    final checks = [
      (
        index: '01',
        icon: LucideIcons.quote,
        pair: semantics.onDevice,
        title: l10n.checkQuoteTitle,
        desc: l10n.checkQuoteDesc,
      ),
      (
        index: '02',
        icon: LucideIcons.shieldAlert,
        pair: semantics.reviewRecommended,
        title: l10n.checkPermissionTitle,
        desc: l10n.checkPermissionDesc,
      ),
      (
        index: '03',
        icon: LucideIcons.mousePointerClick,
        pair: semantics.inCloud,
        title: l10n.checkSelectTitle,
        desc: l10n.checkSelectDesc,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < checks.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          EnpriveSegmentedCardTile(
            index: i,
            totalCount: checks.length,
            backgroundColor: surfaces.card,
            lipHeight: 1.5,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: checks[i].pair.background,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    checks[i].icon,
                    size: 19,
                    color: checks[i].pair.foreground,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            checks[i].index,
                            style: m3e.typography.emphasized.labelSmall
                                .copyWith(
                                  color: scheme.primary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              checks[i].title,
                              style: m3e.typography.emphasized.titleSmall
                                  .copyWith(
                                    color: scheme.onSurface,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        checks[i].desc,
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Material 3 Expressive Floating Pill Bottom Navigation Dock inspired by
/// `plan check up.jpeg` and `x-monday-home.jpeg`.
class _FloatingBottomNavDock extends StatelessWidget {
  final int selectedIndex;
  final int receiptsCount;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelect;

  const _FloatingBottomNavDock({
    required this.selectedIndex,
    required this.receiptsCount,
    required this.l10n,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;

    final items = [
      (icon: LucideIcons500.house, label: l10n.navHome),
      (icon: LucideIcons500.receiptText, label: l10n.navReceipts),
      (icon: LucideIcons500.slidersHorizontal, label: l10n.navSettings),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: surfaces.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: surfaces.hairlineBorder),
            boxShadow: [
              BoxShadow(
                color: surfaces.ambientShadowColor,
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
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? scheme.secondaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Badge(
                          isLabelVisible: showBadge,
                          label: Text('$receiptsCount'),
                          backgroundColor: scheme.primary,
                          textColor: scheme.onPrimary,
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: isSelected
                                ? scheme.onSecondaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: m3e.typeScale.labelSmall.copyWith(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
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
