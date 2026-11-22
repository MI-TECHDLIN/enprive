import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart' as modern;

import 'core/theme/enprive_theme.dart';
import 'domain/intake/policy_intake_models.dart';
import 'domain/permissions/permission_comparator.dart';
import 'domain/review/app_policy_association.dart';
import 'domain/review/review_coordinator.dart';
import 'domain/review/review_models.dart';
import 'l10n/app_localizations.dart';
import 'l10n/enprive_languages.dart';
import 'screens/companion_screen.dart';
import 'screens/learn_home_screen.dart';
import 'screens/onboarding_flow_screen.dart';
import 'screens/receipts_screen.dart';
import 'screens/review_result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/intake/policy_intake_coordinator.dart';
import 'services/network/policy_url_retriever.dart';
import 'services/platform/companion_bridge.dart';
import 'services/platform/hybrid_ai_bridge.dart';
import 'services/storage/receipt_repository.dart';
import 'widgets/cloud_consent_sheet.dart';
import 'widgets/deni_animated_mascot.dart';
import 'widgets/enprive_tactile_button.dart';
import 'widgets/home/enprive_home_hero.dart';
import 'widgets/installed_app_picker_sheet.dart';
import 'widgets/intake/unified_policy_intake_sheet.dart';
import 'widgets/m3e/enprive_m3e_components.dart';
import 'widgets/navigation/enprive_navigation_shell.dart';
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
  final PolicyUrlRetriever? urlRetriever;
  final PolicyIntakeCoordinator? intakeCoordinator;
  final ReceiptRepository? receiptRepository;

  const EnpriveApp({
    super.key,
    this.showSplashOnLaunch = true,
    this.splashDuration = const Duration(milliseconds: 1400),
    this.urlRetriever,
    this.intakeCoordinator,
    this.receiptRepository,
  });

  @override
  State<EnpriveApp> createState() => _EnpriveAppState();
}

class _EnpriveAppState extends State<EnpriveApp> with WidgetsBindingObserver {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {});
    }
  }

  void _setLocale(Locale newLocale) {
    setState(() => _locale = newLocale);
  }

  void _setThemeMode(ThemeMode newThemeMode) {
    setState(() => _themeMode = newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness =
        MediaQuery.maybePlatformBrightnessOf(context) ??
        View.maybeOf(context)?.platformDispatcher.platformBrightness ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final activeBrightness = EnpriveM3ETheme.brightnessFor(
      mode: _themeMode,
      platformBrightness: platformBrightness,
    );

    // A plain material_ui MaterialApp (the one M3EMaterialApp wraps) with
    // EnpriveM3EBridgeScope as its builder. M3EMaterialApp's adaptive scope
    // re-derives the dark scheme from a generic seed beneath the builder, so
    // the generated Enprive dark palette never reached the screens.
    return modern.MaterialApp(
      title: 'Enprive',
      debugShowCheckedModeBanner: false,
      theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
      darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
      themeMode: activeBrightness == Brightness.dark
          ? modern.ThemeMode.dark
          : modern.ThemeMode.light,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
      builder: (context, child) {
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
        urlRetriever: widget.urlRetriever,
        intakeCoordinator: widget.intakeCoordinator,
        receiptRepository: widget.receiptRepository,
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
  final PolicyUrlRetriever? urlRetriever;
  final PolicyIntakeCoordinator? intakeCoordinator;
  final ReceiptRepository? receiptRepository;

  const HomeScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChange,
    this.currentThemeMode = ThemeMode.system,
    this.onThemeModeChange,
    this.showSplashOnLaunch = true,
    this.splashDuration = const Duration(milliseconds: 1400),
    this.urlRetriever,
    this.intakeCoordinator,
    this.receiptRepository,
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
  final CompanionBridge _companionBridge = CompanionBridge();
  late final PolicyUrlRetriever _urlRetriever =
      widget.urlRetriever ?? PolicyUrlRetriever();
  late final PolicyIntakeCoordinator _intakeCoordinator =
      widget.intakeCoordinator ??
      PolicyIntakeCoordinator(
        urlRetriever: _urlRetriever,
        hybridBridge: _bridge,
      );
  late final ReviewCoordinator _coordinator = ReviewCoordinator(
    bridge: _bridge,
  );
  late final ReceiptRepository _receiptRepo =
      widget.receiptRepository ?? ReceiptRepository();
  final UserPreferencesRepository _prefsRepo = UserPreferencesRepository();
  final ReviewExitGuardController _reviewExitGuard =
      ReviewExitGuardController();
  DeviceCapability? _deviceCapability;
  bool _isRunningReview = false;
  bool _isConsentSheetOpen = false;
  bool _isOpeningIntakeSheet = false;
  bool _isCancellingReview = false;
  int _activeOperationSequence = 0;
  int _intakeSheetGeneration = 0;
  int _warmNavigationSequence = 0;
  String? _activeAnalysisRequestId;
  PolicyUrlCancellationToken? _activeUrlCancelToken;
  String _activeReviewTitle = 'Privacy Policy';
  bool _isCloudReviewInFlight = false;
  DeniPose _activePose = DeniPose.idle;
  int _selectedTabIndex = 0;
  ExplanationDepth _explanationDepth = ExplanationDepth.balanced;
  final List<PolicyReviewReceipt> _savedReceipts = [];
  late bool _isSplashVisible = widget.showSplashOnLaunch;
  bool _pendingFirstRunOnboarding = false;
  IncomingIntentPayload? _pendingIncomingPayload;
  StreamSubscription<IncomingIntentPayload>? _incomingPayloadSub;
  CompanionInvocation? _pendingCompanionInvocation;
  StreamSubscription<CompanionInvocation>? _companionInvocationSub;
  final Set<String> _handledCompanionIds = <String>{};
  bool _isCompanionRouteOpen = false;
  final ScrollController _checkScrollController = ScrollController();
  final ScrollController _receiptsScrollController = ScrollController();
  final ScrollController _learnScrollController = ScrollController();
  final ValueNotifier<int> _settingsRouteRevision = ValueNotifier<int>(0);

  void _notifySettingsRoute() {
    _settingsRouteRevision.value++;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _incomingPayloadSub = _bridge.incomingPayloads.listen(
      _handleIncomingPayload,
    );
    _companionInvocationSub = _companionBridge.invocations.listen(
      _handleCompanionInvocation,
    );
    _initializeDeviceAndIntent();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocale != widget.currentLocale ||
        oldWidget.currentThemeMode != widget.currentThemeMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notifySettingsRoute();
      });
    }
  }

  @override
  void dispose() {
    _cancelActiveHomeOperationSilently(notifyState: false);
    final sub = _incomingPayloadSub;
    if (sub != null) {
      unawaited(sub.cancel());
    }
    final companionSub = _companionInvocationSub;
    if (companionSub != null) {
      unawaited(companionSub.cancel());
    }
    _checkScrollController.dispose();
    _receiptsScrollController.dispose();
    _learnScrollController.dispose();
    _settingsRouteRevision.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIncomingTextIntent();
      unawaited(_checkCompanionInvocation());
    }
  }

  void _completeSplash() {
    if (!_isSplashVisible || !mounted) return;
    setState(() => _isSplashVisible = false);

    if (_pendingCompanionInvocation != null) {
      final inv = _pendingCompanionInvocation!;
      _pendingCompanionInvocation = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_handleCompanionInvocation(inv));
      });
      return;
    }

    if (_pendingIncomingPayload != null) {
      final pending = _pendingIncomingPayload!;
      _pendingIncomingPayload = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_handleIncomingPayload(pending));
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
    }

    // Prioritize Quick Settings companion invocation immediately before device model polling.
    await _checkCompanionInvocation();
    await _checkIncomingTextIntent();

    final cap = await _bridge.getDeviceCapability();
    if (mounted) {
      setState(() {
        _deviceCapability = cap;
      });
    }
    if (cap.isSupported && cap.modelStatus == ModelDownloadStatus.available) {
      unawaited(_bridge.warmUpModel());
    }

    if (mounted &&
        !prefs.hasCompletedOnboarding &&
        !_isCompanionRouteOpen &&
        _pendingCompanionInvocation == null &&
        _pendingIncomingPayload == null) {
      if (_isSplashVisible) {
        _pendingFirstRunOnboarding = true;
      } else {
        unawaited(_openOnboardingFlow());
      }
    }
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
    _notifySettingsRoute();
  }

  bool _isReceiptPersisted(String id) =>
      _savedReceipts.any((r) => r.id == id) ||
      _receiptRepo.containsReceiptSync(id);

  Future<void> _saveReceipt(PolicyReviewReceipt saved) async {
    await _receiptRepo.saveReceipt(saved);
    if (!mounted) return;
    setState(() {
      _savedReceipts.removeWhere((r) => r.id == saved.id);
      _savedReceipts.insert(0, saved);
    });
    _notifySettingsRoute();
  }

  Future<void> _deleteReceipt(String id) async {
    await _receiptRepo.deleteReceipt(id);
    if (!mounted) return;
    setState(() {
      _savedReceipts.removeWhere((r) => r.id == id);
    });
    _notifySettingsRoute();
  }

  Future<void> _clearAllReceipts() async {
    await _receiptRepo.clearAllReceipts();
    if (!mounted) return;
    setState(() {
      _savedReceipts.clear();
    });
    _notifySettingsRoute();
  }

  void _scrollActiveDestinationToTop(int index) {
    final controller = switch (index) {
      0 => _checkScrollController,
      1 => _receiptsScrollController,
      2 => _learnScrollController,
      _ => null,
    };
    if (controller == null || !controller.hasClients) return;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      controller.jumpTo(0);
    } else {
      unawaited(
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  Future<void> _openSettingsScreen() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'enprive_settings'),
        builder: (_) => ValueListenableBuilder<int>(
          valueListenable: _settingsRouteRevision,
          builder: (routeContext, _, _) {
            return SettingsScreen(
              showAppBar: true,
              bridge: _bridge,
              companionBridge: _companionBridge,
              capability: _deviceCapability,
              explanationDepth: _explanationDepth,
              currentLocale: widget.currentLocale,
              currentThemeMode: widget.currentThemeMode,
              savedReceiptsCount: _savedReceipts.length,
              onExplanationDepthChanged: (depth) {
                setState(() => _explanationDepth = depth);
                _notifySettingsRoute();
                unawaited(_prefsRepo.update(explanationDepth: depth));
              },
              onLocaleChanged: (locale) {
                widget.onLocaleChange(locale);
                _notifySettingsRoute();
                unawaited(_prefsRepo.update(languageCode: locale.languageCode));
              },
              onThemeModeChanged: (mode) {
                widget.onThemeModeChange?.call(mode);
                _notifySettingsRoute();
                unawaited(_prefsRepo.update(themeMode: mode));
              },
              onRefreshCapability: _refreshCapability,
              onClearAllReceipts: _clearAllReceipts,
              onReplayOnboarding: _openOnboardingFlow,
              onOpenCompanion: () => _openCompanionScreen(null),
            );
          },
        ),
      ),
    );
  }

  Future<void> _checkCompanionInvocation() async {
    final invocation = await _companionBridge.getInitialCompanionInvocation();
    if (!mounted || invocation == null) return;
    await _handleCompanionInvocation(invocation);
  }

  Future<void> _handleCompanionInvocation(
    CompanionInvocation invocation,
  ) async {
    if (!mounted) return;
    final id = invocation.invocationId.trim();
    if (id.isNotEmpty && _handledCompanionIds.contains(id)) {
      return;
    }

    if (_isSplashVisible) {
      if (_pendingCompanionInvocation?.invocationId.trim() == id &&
          id.isNotEmpty) {
        return;
      }
      _pendingCompanionInvocation = invocation;
      _completeSplash();
      return;
    }

    if (id.isNotEmpty) {
      if (_handledCompanionIds.length >= 64) {
        _handledCompanionIds.remove(_handledCompanionIds.first);
      }
      _handledCompanionIds.add(id);
    }

    await _openCompanionScreen(invocation);
  }

  void _cancelActiveHomeOperationSilently({bool notifyState = true}) {
    final reqId = _activeAnalysisRequestId;
    final wasCloud = _isCloudReviewInFlight;
    final urlToken = _activeUrlCancelToken;
    _activeUrlCancelToken = null;
    _activeOperationSequence++;
    if (urlToken != null) {
      urlToken.cancel();
    }
    if (notifyState && mounted) {
      setState(() {
        _isCancellingReview = false;
        _isRunningReview = false;
        _isCloudReviewInFlight = false;
        _isConsentSheetOpen = false;
        _activeAnalysisRequestId = null;
        _activePose = DeniPose.idle;
      });
    } else {
      _isCancellingReview = false;
      _isRunningReview = false;
      _isCloudReviewInFlight = false;
      _isConsentSheetOpen = false;
      _activeAnalysisRequestId = null;
    }
    if (reqId != null) {
      final cancelId = wasCloud ? '${reqId}_appcheck' : reqId;
      unawaited(_bridge.cancelAnalysis(requestId: cancelId));
    }
  }

  /// Coordinates warm OS intents and Quick Settings invocations with any open
  /// [ReviewResultScreen] unsaved draft, active inference, or open sheet.
  ///
  /// Returns `true` when navigation may proceed cleanly on the root route, or
  /// `false` when the user chose to stay on an unsaved review draft or a newer
  /// warm navigation superseded this call.
  Future<bool> _prepareForWarmNavigation() async {
    if (!mounted) return false;
    final navSeq = ++_warmNavigationSequence;

    if (_reviewExitGuard.hasActiveScreen) {
      final exited = await _reviewExitGuard.requestExit();
      if (!mounted || !exited || navSeq != _warmNavigationSequence) {
        return false;
      }
    }

    _cancelActiveHomeOperationSilently();
    _intakeSheetGeneration++;
    _isOpeningIntakeSheet = false;
    Navigator.of(context).popUntil((route) => route.isFirst);
    return mounted && navSeq == _warmNavigationSequence;
  }

  Future<void> _openCompanionScreen(CompanionInvocation? invocation) async {
    if (!mounted) return;
    // Clear any open secondary/modal routes before opening Quick Settings
    // Companion while honoring ReviewResultScreen's unsaved-draft exit guard.
    if (_isCompanionRouteOpen || invocation != null) {
      final canProceed = await _prepareForWarmNavigation();
      if (!canProceed || !mounted) return;
    }
    _isCompanionRouteOpen = true;
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'enprive_companion'),
          builder: (_) => CompanionScreen(
            invocation: invocation,
            hybridBridge: _bridge,
            companionBridge: _companionBridge,
            coordinator: _coordinator,
            urlRetriever: _urlRetriever,
            intakeCoordinator: _intakeCoordinator,
            savedReceipts: List<PolicyReviewReceipt>.unmodifiable(
              _savedReceipts,
            ),
            onSaveReceipt: _saveReceipt,
            receiptRepository: _receiptRepo,
            languageCode: widget.currentLocale.languageCode,
          ),
        ),
      );
    } finally {
      _isCompanionRouteOpen = false;
    }
  }

  Future<void> _checkIncomingTextIntent() async {
    final payload = await _bridge.getInitialIncomingPayload();
    if (!mounted || payload == null) return;
    await _handleIncomingPayload(payload);
  }

  Future<void> _handleIncomingPayload(IncomingIntentPayload payload) async {
    if (!mounted) return;
    if (_isSplashVisible) {
      _pendingIncomingPayload = payload;
      _completeSplash();
      return;
    }

    final locator = _intakeCoordinator.classifyIncomingPayloadLocator(payload);
    if (locator == null) return;

    // Honor ReviewResultScreen's unsaved-draft guard and cancel stale sheets /
    // in-flight operations before foregrounding the incoming share or selection.
    final canProceed = await _prepareForWarmNavigation();
    if (!canProceed || !mounted) return;

    if (_selectedTabIndex != 0) {
      setState(() => _selectedTabIndex = 0);
    }

    switch (locator) {
      case TextPolicyLocator():
        setState(() {
          _activePose = DeniPose.thinking;
        });
        await _openPolicyIntakeSheet(initialLocator: locator);
      case UrlPolicyLocator():
        final provisionalTitle =
            locator.userSubjectTitle != null &&
                locator.userSubjectTitle!.trim().isNotEmpty
            ? locator.userSubjectTitle!.trim()
            : locator.rawUrl;
        await _executeHeadlessIncomingIntake(
          payload: payload,
          provisionalTitle: provisionalTitle,
        );
      case DocumentPolicyLocator():
        final doc = payload.document;
        if (doc != null && doc.isCancelled) return;
        final provisionalTitle =
            locator.userSubjectTitle != null &&
                locator.userSubjectTitle!.trim().isNotEmpty
            ? locator.userSubjectTitle!.trim()
            : (locator.fileName?.trim().isNotEmpty == true
                  ? locator.fileName!.trim()
                  : 'Document Intake');
        await _executeHeadlessIncomingIntake(
          payload: payload,
          provisionalTitle: provisionalTitle,
        );
      case SampleFixturePolicyLocator():
        break;
    }
  }

  Future<void> _executeHeadlessIncomingIntake({
    required IncomingIntentPayload payload,
    required String provisionalTitle,
  }) async {
    if (!mounted || _isRunningReview || _isConsentSheetOpen) return;
    final opSeq = ++_activeOperationSequence;
    final cancelToken = PolicyUrlCancellationToken();
    _activeUrlCancelToken = cancelToken;

    setState(() {
      _isRunningReview = true;
      _isCancellingReview = false;
      _activeAnalysisRequestId = null;
      _activeReviewTitle = provisionalTitle;
      _isCloudReviewInFlight = false;
      _activePose = DeniPose.thinking;
    });

    final PolicyIntakeOutcome outcome;
    try {
      outcome = await _intakeCoordinator.captureIncomingPayload(
        payload: payload,
        cancelToken: cancelToken,
      );
    } finally {
      if (identical(_activeUrlCancelToken, cancelToken)) {
        _activeUrlCancelToken = null;
      }
      if (mounted && opSeq == _activeOperationSequence) {
        setState(() {
          _isRunningReview = false;
        });
      }
    }

    if (!mounted ||
        opSeq != _activeOperationSequence ||
        cancelToken.isCancelled) {
      return;
    }

    switch (outcome) {
      case final PolicyIntakeSuccess success:
        await _runReviewForIntakeSuccess(success);
      case final PolicyIntakeFailure failure:
        if (failure.isCancelled) {
          setState(() {
            _activePose = DeniPose.idle;
          });
          return;
        }
        // Fail-closed recovery: keep locator & error details and open the
        // unified sheet prefilled instead of presenting a failed fetch or
        // failed document extraction as a captured review receipt.
        await _openPolicyIntakeSheet(initialFailure: failure);
    }
  }

  Future<SelectedAppReference?> _selectOptionalInstalledAppForIntake(
    BuildContext sheetContext,
  ) async {
    final choice = await InstalledAppPickerSheet.show(
      sheetContext,
      bridge: _bridge,
      eduTrackPolicyText: '',
      calmMathPolicyText: '',
      savedReceipts: List<PolicyReviewReceipt>.unmodifiable(_savedReceipts),
      receiptRepository: _receiptRepo,
    );
    if (choice == null || choice.isSyntheticSample) return null;
    final snap = choice.permissionSnapshot;
    if (snap.packageName.trim().isEmpty) return null;
    return SelectedAppReference(
      packageName: snap.packageName,
      appName: choice.subjectTitle,
      permissionSnapshot: snap,
      peerCandidates: choice.peerCandidates,
      isLocked: false,
    );
  }

  Future<void> _openPolicyIntakeSheet({
    PolicyLocator? initialLocator,
    PolicyIntakeFailure? initialFailure,
    PolicyIntakeMode? initialMode,
  }) async {
    if (!mounted ||
        _isRunningReview ||
        _isConsentSheetOpen ||
        _isOpeningIntakeSheet) {
      return;
    }
    final sheetGen = ++_intakeSheetGeneration;
    _isOpeningIntakeSheet = true;
    PolicyIntakeSuccess? intake;
    try {
      intake = await UnifiedPolicyIntakeSheet.show(
        context,
        config: PolicyIntakeSheetConfig(
          coordinator: _intakeCoordinator,
          initialMode: initialMode,
          initialLocator: initialLocator,
          initialFailure: initialFailure,
          onSelectInstalledApp: _selectOptionalInstalledAppForIntake,
          companionBridge: _companionBridge,
        ),
      );
    } finally {
      if (sheetGen == _intakeSheetGeneration) {
        _isOpeningIntakeSheet = false;
      }
    }

    if (!mounted || sheetGen != _intakeSheetGeneration) return;
    if (intake == null) {
      setState(() {
        _activePose = DeniPose.idle;
      });
      return;
    }

    await _runReviewForIntakeSuccess(intake);
  }

  Future<void> _runReviewForIntakeSuccess(PolicyIntakeSuccess intake) async {
    if (!mounted || _isRunningReview || _isConsentSheetOpen) return;
    final captured = intake.capturedSnapshot;
    var appPermissions = intake.selectedApp?.permissionSnapshot;

    if (intake.selectedApp != null &&
        appPermissions == null &&
        intake.selectedApp!.trustedSampleFixture == null) {
      final hydrateSeq = _activeOperationSequence;
      final hydrated = await _intakeCoordinator.hydrateAppPermissions(
        intake.selectedApp!,
      );
      if (!mounted || hydrateSeq != _activeOperationSequence) return;
      appPermissions = hydrated.permissionSnapshot;
    }

    await _executePolicyReview(
      subjectTitle: captured.subjectTitle,
      sourceLabel: captured.sourceLabel,
      policyText: captured.normalizedPolicyText,
      appPermissions: appPermissions,
      sourceSnapshot: captured.sourceSnapshot,
      associationReport: intake.associationReport,
    );
  }

  Future<void> _openReviewResult(
    PolicyReviewReceipt receipt, {
    AppPolicyAssociationReport? associationReport,
  }) async {
    if (!mounted) return;
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
          urlRetriever: _urlRetriever,
          intakeCoordinator: _intakeCoordinator,
          companionBridge: _companionBridge,
          initialAssociationReport: associationReport,
          exitGuardController: _reviewExitGuard,
          onSaveReceipt: _saveReceipt,
          onDeleteReceipt: _deleteReceipt,
          savedReceipts: List<PolicyReviewReceipt>.unmodifiable(_savedReceipts),
          receiptRepository: _receiptRepo,
          isReceiptSaved: _isReceiptPersisted,
          isInitiallySaved: _isReceiptPersisted(receipt.id),
        ),
      ),
    );
  }

  void _cancelActiveReview() {
    if (!_isRunningReview) return;
    final l10n = AppLocalizations.of(context);
    final hadAnalysis = _activeAnalysisRequestId != null;
    _cancelActiveHomeOperationSilently();
    if (!hadAnalysis) {
      unawaited(_bridge.cancelAnalysis());
    }
    if (l10n != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.analysisCancelledNotice),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
    PolicySourceSnapshot? sourceSnapshot,
    AppPolicyAssociationReport? associationReport,
    String? canonicalRedactedPayload,
    bool cloudConsent = false,
    bool forceLocalManualScan = false,
  }) async {
    if (_isRunningReview || _isConsentSheetOpen) return;
    final opSeq = ++_activeOperationSequence;
    final reqId = 'rev_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _isRunningReview = true;
      _isCancellingReview = false;
      _activeAnalysisRequestId = reqId;
      _activeReviewTitle = subjectTitle;
      _isCloudReviewInFlight = cloudConsent;
      _activePose = DeniPose.thinking;
    });

    final ReviewExecutionResult outcome;
    try {
      outcome = await _coordinator.runPolicyReview(
        requestId: reqId,
        subjectTitle: subjectTitle,
        sourceLabel: sourceLabel,
        policyText: policyText,
        appPermissions: appPermissions,
        sourceSnapshot: sourceSnapshot,
        canonicalRedactedPayload: canonicalRedactedPayload,
        cloudConsent: cloudConsent,
        forceLocalManualScan: forceLocalManualScan,
        languageCode: widget.currentLocale.languageCode,
      );
    } on HybridOperationCancelledException catch (e) {
      if (mounted && opSeq == _activeOperationSequence) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _isRunningReview = false;
          _isCloudReviewInFlight = false;
          _isCancellingReview = false;
          _activeAnalysisRequestId = null;
          _activePose = DeniPose.idle;
        });
        if (e.isTimeout && l10n != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.cloudTimedOutNotice),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      }
      return;
    }

    if (!mounted || opSeq != _activeOperationSequence) return;
    setState(() {
      _isRunningReview = false;
      _isCloudReviewInFlight = false;
      _isCancellingReview = false;
      _activeAnalysisRequestId = null;
    });

    final receipt = outcome.receipt;
    if (receipt == null) {
      if (outcome.needsCloudConsentOrManual) {
        final canonicalPayload =
            outcome.redactedPreview ??
            ReviewCoordinator.canonicalCloudPayload(policyText);
        setState(() {
          _isConsentSheetOpen = true;
          _activePose = DeniPose.support;
        });
        final CloudConsentDecision decision;
        try {
          decision = await CloudConsentSheet.show(
            context,
            subjectTitle: subjectTitle,
            policyText: policyText,
            canonicalRedactedPreview: canonicalPayload,
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
        if (!mounted || opSeq != _activeOperationSequence) return;
        switch (decision) {
          case CloudConsentDecision.useCloudOnce:
            await _executePolicyReview(
              subjectTitle: subjectTitle,
              sourceLabel: sourceLabel,
              policyText: policyText,
              appPermissions: appPermissions,
              sourceSnapshot: sourceSnapshot,
              associationReport: associationReport,
              canonicalRedactedPayload: canonicalPayload,
              cloudConsent: true,
            );
            return;
          case CloudConsentDecision.reviewLocally:
            await _executePolicyReview(
              subjectTitle: subjectTitle,
              sourceLabel: sourceLabel,
              policyText: policyText,
              appPermissions: appPermissions,
              sourceSnapshot: sourceSnapshot,
              associationReport: associationReport,
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

    await _openReviewResult(receipt, associationReport: associationReport);
  }

  Future<void> _runQuickSampleReview({required bool isEduTrack}) async {
    if (_isRunningReview || _isConsentSheetOpen || _isOpeningIntakeSheet) {
      return;
    }
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
    final fixture = isEduTrack
        ? TrustedSampleFixture.eduTrackDemo
        : TrustedSampleFixture.calmMathDemo;
    final permSnapshot = isEduTrack
        ? PermissionComparator.demoEduTrackSnapshot
        : PermissionComparator.demoCalmMathSnapshot;
    final outcome = _intakeCoordinator.captureSampleFixture(
      locator: SampleFixturePolicyLocator(
        fixture: fixture,
        policyText: policyText,
      ),
      permissionSnapshot: permSnapshot,
      sourceLabel:
          AppLocalizations.of(context)?.sampleSyntheticBadge ??
          'Synthetic example',
    );
    if (outcome is PolicyIntakeSuccess) {
      await _runReviewForIntakeSuccess(outcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final mainShell = EnpriveNavigationShell(
      selectedIndex: _selectedTabIndex,
      receiptsCount: _savedReceipts.length,
      onSelectDestination: (index) => setState(() => _selectedTabIndex = index),
      onReselectDestination: _scrollActiveDestinationToTop,
      onOpenSettings: _openSettingsScreen,
      bodyBuilder: (shellContext, isCompactLayout) {
        return IndexedStack(
          index: _selectedTabIndex,
          children: [
            // Only the visible tab runs its tickers (hero drift, Deni idle).
            TickerMode(
              enabled: _selectedTabIndex == 0,
              child: _buildCheckTab(shellContext, l10n, isCompactLayout),
            ),
            ReceiptsScreen(
              receipts: _savedReceipts,
              coordinator: _coordinator,
              urlRetriever: _urlRetriever,
              intakeCoordinator: _intakeCoordinator,
              companionBridge: _companionBridge,
              reviewExitGuard: _reviewExitGuard,
              scrollController: _receiptsScrollController,
              onDeleteReceipt: _deleteReceipt,
              onSaveReceipt: _saveReceipt,
              receiptRepository: _receiptRepo,
              isReceiptSaved: _isReceiptPersisted,
              onOpenSettings: isCompactLayout ? _openSettingsScreen : null,
              isActiveTab: _selectedTabIndex == 1,
              onStartReviewRequested: () {
                setState(() => _selectedTabIndex = 0);
              },
            ),
            LearnHomeScreen(
              scrollController: _learnScrollController,
              onOpenSettings: isCompactLayout ? _openSettingsScreen : null,
              isActiveTab: _selectedTabIndex == 2,
              onCheckAppRequested: () {
                setState(() => _selectedTabIndex = 0);
              },
            ),
          ],
        );
      },
    );

    return Stack(
      children: [
        ExcludeSemantics(
          excluding: _isSplashVisible,
          child: IgnorePointer(ignoring: _isSplashVisible, child: mainShell),
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

  Widget _buildCheckTab(
    BuildContext context,
    AppLocalizations l10n,
    bool isCompactLayout,
  ) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/enprive_logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.appTitle,
              style: m3e.typeScale.titleLarge.copyWith(color: scheme.onSurface),
            ),
          ],
        ),
        actions: [
          if (isCompactLayout)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 4.0),
              child: EnpriveSettingsAppBarButton(
                key: _selectedTabIndex == 0
                    ? const Key('nav_settings_btn')
                    : null,
                tooltip: l10n.navSettings,
                onPressed: _openSettingsScreen,
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              controller: _checkScrollController,
              padding: EdgeInsets.fromLTRB(
                EnpriveSpacing.marginFor(MediaQuery.sizeOf(context).width),
                8,
                EnpriveSpacing.marginFor(MediaQuery.sizeOf(context).width),
                32,
              ),
              child: Column(
                children: [
                  // 1. The one lead block: gradient hero with Deni, the
                  // headline and the only filled action on the screen.
                  EnpriveHomeHero(
                    deniPose: _isRunningReview
                        ? DeniPose.thinking
                        : (_activePose == DeniPose.idle
                              // At rest Deni points toward the next step.
                              ? DeniPose.pointing
                              : _activePose),
                    headline: l10n.homeHeroHeadline,
                    subtitle: l10n.homePrivacySubtitle,
                    actions: _isRunningReview
                        ? ReviewProgressCard(
                            subjectTitle: _activeReviewTitle,
                            isCloudCheck: _isCloudReviewInFlight,
                            processStream: _coordinator.analysisEvents,
                            onCancel: _cancelActiveReview,
                            isCancelling: _isCancellingReview,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              EnpriveTactileButton(
                                label: l10n.btnCheckApp,
                                onPressed: () {
                                  setState(
                                    () => _activePose = DeniPose.explaining,
                                  );
                                  _showCheckAppModal(context, l10n);
                                },
                              ),
                              const SizedBox(height: 8),
                              EnpriveTactileButton(
                                label: l10n.btnPasteTerms,
                                variant: EnpriveButtonVariant.tonal,
                                onPressed: () {
                                  setState(
                                    () => _activePose = DeniPose.thinking,
                                  );
                                  unawaited(_openPolicyIntakeSheet());
                                },
                              ),
                            ],
                          ),
                  ),
                  if (!_isRunningReview) ...[
                    const SizedBox(height: 12),
                    EnpriveMaterialCardSurface(
                      key: const Key('check_quick_settings_card'),
                      borderRadius: BorderRadius.circular(EnpriveRadii.card),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      onPressed: () => _openCompanionScreen(null),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              LucideIcons.panelTopOpen,
                              size: 20,
                              color: scheme.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Settings Companion',
                                  style: m3e.typeScale.titleMedium.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ask Deni about the app you\'re using anytime',
                                  style: m3e.typeScale.bodyMedium.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // 4. Quick Sample App Checks (Sculpted Archival Folder Cards)
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.trySampleCheck,
                          style: m3e.typeScale.titleLarge.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            l10n.sampleSyntheticBadge,
                            style: m3e.typography.emphasized.labelSmall
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale = MediaQuery.textScalerOf(context)
                          .scale(1.0);
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
                      style: m3e.typeScale.titleLarge.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WhatWeCheckSegmentedGroup(l10n: l10n),

                  // 6. Recently reviewed: heading plus the same rich cards
                  // as Receipts, each opening its receipt.
                  if (_savedReceipts.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.recentlyReviewed,
                            style: m3e.typeScale.titleLarge.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _selectedTabIndex = 1),
                          child: Text(l10n.navReceipts),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._savedReceipts.take(2).toList().asMap().entries.map((
                      e,
                    ) {
                      final idx = e.key;
                      final receipt = e.value;
                      final count = _savedReceipts.take(2).length;
                      return Padding(
                        padding: EdgeInsets.only(top: idx > 0 ? 2 : 0),
                        child: EnpriveReceiptCard(
                          receipt: receipt,
                          stateBadgeLabel: switch (receipt.overallState) {
                            ReviewOverallState.reviewRecommended =>
                              l10n.stateReviewRecommended,
                            ReviewOverallState.noConcern =>
                              l10n.stateNoConcern,
                            ReviewOverallState.insufficientEvidence =>
                              l10n.stateInsufficientEvidence,
                          },
                          metaLine: receipt.sourceLabel,
                          openLabel: l10n.btnOpenReceipt,
                          deleteTooltip: l10n.btnDelete,
                          onDelete: null,
                          borderRadius: EnpriveRadii.groupedCardRadius(
                            index: idx,
                            count: count,
                            outer: 24,
                            inner: 8,
                          ),
                          onOpen: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ReviewResultScreen(
                                  receipt: receipt,
                                  coordinator: _coordinator,
                                  urlRetriever: _urlRetriever,
                                  intakeCoordinator: _intakeCoordinator,
                                  companionBridge: _companionBridge,
                                  exitGuardController: _reviewExitGuard,
                                  onSaveReceipt: _saveReceipt,
                                  onDeleteReceipt: _deleteReceipt,
                                  receiptRepository: _receiptRepo,
                                  isReceiptSaved: _isReceiptPersisted,
                                  isInitiallySaved: _isReceiptPersisted(
                                    receipt.id,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
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
      savedReceipts: List<PolicyReviewReceipt>.unmodifiable(_savedReceipts),
    );
    if (selected == null || !mounted) return;

    if (!selected.hasSuppliedPolicy) {
      final langCode = widget.currentLocale.languageCode;
      final permReceipt = _coordinator.buildDevicePermissionInspectionReceipt(
        subjectTitle: selected.subjectTitle,
        sourceLabel: selected.sourceLabel,
        appPermissions: selected.permissionSnapshot,
        languageCode: langCode,
      );
      if (!mounted) return;
      setState(() {
        _activePose = DeniPose.idle;
      });
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReviewResultScreen(
            receipt: permReceipt,
            coordinator: _coordinator,
            cloudConsentGrantedForSession: false,
            urlRetriever: _urlRetriever,
            intakeCoordinator: _intakeCoordinator,
            companionBridge: _companionBridge,
            exitGuardController: _reviewExitGuard,
            onSaveReceipt: _saveReceipt,
            onDeleteReceipt: _deleteReceipt,
            receiptRepository: _receiptRepo,
            isReceiptSaved: _isReceiptPersisted,
            isInitiallySaved: _isReceiptPersisted(permReceipt.id),
          ),
        ),
      );
      return;
    }

    if (selected.isSyntheticSample) {
      final isEduTrack =
          selected.permissionSnapshot.packageName.toLowerCase() ==
          TrustedSampleFixture.eduTrackDemo.packageName.toLowerCase();
      final fixture = isEduTrack
          ? TrustedSampleFixture.eduTrackDemo
          : TrustedSampleFixture.calmMathDemo;
      final outcome = _intakeCoordinator.captureSampleFixture(
        locator: SampleFixturePolicyLocator(
          fixture: fixture,
          policyText: selected.policyText,
        ),
        permissionSnapshot: selected.permissionSnapshot,
        sourceLabel: l10n.sampleSyntheticBadge,
      );
      if (outcome is PolicyIntakeSuccess) {
        await _runReviewForIntakeSuccess(outcome);
      }
      return;
    }
  }
}

/// Sculpted Material 3 Expressive archival folder-tab sample card combining
/// Enprive's brand-locked HCT semantic fills with a high-contrast icon medallion.
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
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return EnpriveMaterialCardSurface(
      borderRadius: BorderRadius.circular(EnpriveRadii.card),
      padding: const EdgeInsets.all(16),
      semanticLabel: '$title. $value. $subtitle. $trendBadge.',
      onPressed: onTap,
      enabled: onTap != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: semanticPair.background,
                  borderRadius: BorderRadius.circular(EnpriveRadii.chip),
                ),
                child: Text(
                  trendBadge,
                  style: m3e.typeScale.labelMedium.copyWith(
                    color: semanticPair.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: m3e.typography.emphasized.titleLarge.copyWith(
              color: scheme.onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: m3e.typeScale.titleMedium.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: m3e.typeScale.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
                                  .copyWith(color: scheme.onSurface),
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

void unawaited(Future<void> future) {}
