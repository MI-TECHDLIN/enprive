import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'core/theme/enprive_theme.dart';
import 'domain/permissions/permission_comparator.dart';
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
import 'services/intake/policy_intake_helper.dart';
import 'services/network/policy_url_retriever.dart';
import 'services/platform/companion_bridge.dart';
import 'services/platform/hybrid_ai_bridge.dart';
import 'services/storage/receipt_repository.dart';
import 'widgets/cloud_consent_sheet.dart';
import 'widgets/deni_animated_mascot.dart';
import 'widgets/enprive_tactile_button.dart';
import 'widgets/installed_app_picker_sheet.dart';
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
  final ReceiptRepository? receiptRepository;

  const EnpriveApp({
    super.key,
    this.showSplashOnLaunch = true,
    this.splashDuration = const Duration(milliseconds: 1400),
    this.urlRetriever,
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
    final activeM3EData = EnpriveM3ETheme.resolve(
      mode: _themeMode,
      platformBrightness: platformBrightness,
    );

    return M3EMaterialApp(
      title: 'Enprive',
      debugShowCheckedModeBanner: false,
      data: activeM3EData,
      typeface: EnpriveM3ETheme.typefaceConfig,
      autoTheming: false,
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
        urlRetriever: widget.urlRetriever,
        receiptRepository: widget.receiptRepository,
      ),
    );
  }
}

enum _PasteModalMode { paste, link, document }

class HomeScreen extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChange;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChange;
  final bool showSplashOnLaunch;
  final Duration splashDuration;
  final PolicyUrlRetriever? urlRetriever;
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
  late final ReviewCoordinator _coordinator = ReviewCoordinator(
    bridge: _bridge,
  );
  late final ReceiptRepository _receiptRepo =
      widget.receiptRepository ?? ReceiptRepository();
  final UserPreferencesRepository _prefsRepo = UserPreferencesRepository();
  DeviceCapability? _deviceCapability;
  bool _isRunningReview = false;
  bool _isConsentSheetOpen = false;
  bool _isCancellingReview = false;
  int _activeOperationSequence = 0;
  String? _activeAnalysisRequestId;
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

  Future<void> _handleCompanionInvocation(CompanionInvocation invocation) async {
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

  Future<void> _openCompanionScreen(CompanionInvocation? invocation) async {
    if (!mounted) return;
    // Clear any open secondary/modal routes before opening Quick Settings Companion
    // so warm invocations never stack on top of stale ReviewResult/Settings routes.
    if (_isCompanionRouteOpen || invocation != null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
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
            savedReceipts: List<PolicyReviewReceipt>.unmodifiable(_savedReceipts),
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

  String? _resolveCustomTitle(
    String rawTitle,
    AppLocalizations? l10n, {
    bool ignoreSelectedPlaceholder = true,
  }) {
    final trimmed = rawTitle.trim();
    if (trimmed.isEmpty ||
        trimmed == 'Privacy Policy' ||
        (l10n != null && trimmed == l10n.defaultSubjectTitle) ||
        (ignoreSelectedPlaceholder &&
            l10n != null &&
            trimmed == l10n.selectedExcerptTitle)) {
      return null;
    }
    return trimmed;
  }

  Future<void> _handleIncomingPayload(IncomingIntentPayload payload) async {
    if (!mounted) return;
    if (_isSplashVisible) {
      _pendingIncomingPayload = payload;
      _completeSplash();
      return;
    }

    // Bring incoming shares / text selections cleanly to the foreground Check tab
    // without leaving them buried behind an already pushed secondary route.
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (_selectedTabIndex != 0) {
      setState(() => _selectedTabIndex = 0);
    }

    if (payload.kind == 'document') {
      final doc = payload.document;
      if (doc == null || doc.isCancelled) return;
      await _handleDocumentOutcome(
        doc,
        userSubjectTitle: payload.subject ?? '',
      );
      return;
    }

    final rawText = (payload.text ?? '').trim();
    if (rawText.isEmpty) return;

    final sharedUrl = PolicyUrlRetriever.extractSharedUrl(rawText);
    if (sharedUrl != null) {
      await _executeUrlReview(
        rawUrl: sharedUrl,
        userSubjectTitle: payload.subject ?? '',
      );
      return;
    }

    setState(() {
      _activePose = DeniPose.thinking;
    });

    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      _showPasteModal(
        context,
        l10n,
        initialText: rawText,
        initialSourceType: payload.sourceAction == 'ACTION_SEND'
            ? PolicySourceType.sharedText
            : PolicySourceType.selectedText,
        initialSubject: payload.subject,
      );
    }
  }

  Future<void> _openReviewResult(PolicyReviewReceipt receipt) async {
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
          onSaveReceipt: _saveReceipt,
          onDeleteReceipt: _deleteReceipt,
          receiptRepository: _receiptRepo,
          isReceiptSaved: _isReceiptPersisted,
          isInitiallySaved: _isReceiptPersisted(receipt.id),
        ),
      ),
    );
  }

  void _cancelActiveReview() {
    if (!_isRunningReview) return;
    final reqId = _activeAnalysisRequestId;
    final l10n = AppLocalizations.of(context);
    _activeOperationSequence++;
    setState(() {
      _isCancellingReview = true;
      _isRunningReview = false;
      _isCloudReviewInFlight = false;
      _activeAnalysisRequestId = null;
      _activePose = DeniPose.idle;
      _isCancellingReview = false;
    });
    if (reqId != null) {
      unawaited(_bridge.cancelAnalysis(requestId: reqId));
    } else {
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

  Future<void> _executeUrlReview({
    required String rawUrl,
    String userSubjectTitle = '',
  }) async {
    if (_isRunningReview || _isConsentSheetOpen) return;
    final l10n = AppLocalizations.of(context);
    final customTitle = _resolveCustomTitle(userSubjectTitle, l10n);
    final provisionalTitle =
        customTitle ?? PolicyUrlRetriever.deriveSubjectTitle(rawUrl);
    final opSeq = ++_activeOperationSequence;

    setState(() {
      _isRunningReview = true;
      _isCancellingReview = false;
      _activeAnalysisRequestId = null;
      _activeReviewTitle = provisionalTitle;
      _isCloudReviewInFlight = false;
      _activePose = DeniPose.thinking;
    });

    final PolicyUrlRetrievalResult retrieval;
    try {
      retrieval = await _urlRetriever.fetchPolicy(rawUrl);
    } finally {
      if (mounted && opSeq == _activeOperationSequence) {
        setState(() {
          _isRunningReview = false;
        });
      }
    }
    if (!mounted || opSeq != _activeOperationSequence) return;

    final resolvedSubject =
        customTitle ??
        PolicyUrlRetriever.deriveSubjectTitle(
          retrieval.canonicalUrl ?? retrieval.requestedUrl,
        );

    if (!retrieval.isUsablePolicy) {
      final failureReceipt = PolicyIntakeHelper.buildUrlFailureReceipt(
        subjectTitle: resolvedSubject,
        retrieval: retrieval,
        languageCode: widget.currentLocale.languageCode,
      );
      await _openReviewResult(failureReceipt);
      return;
    }

    await _executePolicyReview(
      subjectTitle: resolvedSubject,
      sourceLabel: retrieval.canonicalUrl ?? retrieval.requestedUrl,
      policyText: retrieval.extractedText!,
      sourceSnapshot: retrieval.sourceSnapshot,
    );
  }

  Future<void> _handleDocumentOutcome(
    DocumentExtractionOutcome doc, {
    String userSubjectTitle = '',
  }) async {
    final l10n = AppLocalizations.of(context);
    final customTitle = _resolveCustomTitle(userSubjectTitle, l10n);
    final subject =
        customTitle ??
        (doc.fileName != null && doc.fileName!.trim().isNotEmpty
            ? doc.fileName!.trim()
            : 'Document Intake');

    if (!doc.isSuccess) {
      final failureReceipt = PolicyIntakeHelper.buildDocumentFailureReceipt(
        subjectTitle: subject,
        doc: doc,
        languageCode: widget.currentLocale.languageCode,
      );
      await _openReviewResult(failureReceipt);
      return;
    }

    final snapshot = PolicyIntakeHelper.snapshotFromDocumentSuccess(doc);
    final sourceLabel =
        doc.fileName != null && doc.fileName!.trim().isNotEmpty
        ? 'Document · ${doc.fileName!.trim()}'
        : 'Document Intake';
    await _executePolicyReview(
      subjectTitle: subject,
      sourceLabel: sourceLabel,
      policyText: doc.extractedText,
      sourceSnapshot: snapshot,
    );
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
            policyText: canonicalPayload,
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
        if (!mounted) return;
        switch (decision) {
          case CloudConsentDecision.useCloudOnce:
            await _executePolicyReview(
              subjectTitle: subjectTitle,
              sourceLabel: sourceLabel,
              policyText: policyText,
              appPermissions: appPermissions,
              sourceSnapshot: sourceSnapshot,
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

    await _openReviewResult(receipt);
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
      sourceLabel: AppLocalizations.of(context)?.sampleSyntheticBadge ??
          'Synthetic example',
      policyText: policyText,
      appPermissions: isEduTrack
          ? PermissionComparator.demoEduTrackSnapshot
          : PermissionComparator.demoCalmMathSnapshot,
      sourceSnapshot: PolicyIntakeHelper.snapshotForManualOrSharedText(
        sourceType: PolicySourceType.sample,
        text: policyText,
        hasAppPermissions: true,
      ),
    );
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
            _buildCheckTab(shellContext, l10n, isCompactLayout),
            ReceiptsScreen(
              receipts: _savedReceipts,
              coordinator: _coordinator,
              urlRetriever: _urlRetriever,
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
          child: IgnorePointer(
            ignoring: _isSplashVisible,
            child: mainShell,
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

  Widget _buildCheckTab(
    BuildContext context,
    AppLocalizations l10n,
    bool isCompactLayout,
  ) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
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
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          if (isCompactLayout)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16.0),
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
                onCancel: _cancelActiveReview,
                isCancelling: _isCancellingReview,
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
              const SizedBox(height: 14),
              EnpriveMaterialCardSurface(
                key: const Key('check_quick_settings_card'),
                variant: EnpriveCardVariant.outlined,
                backgroundColor: surfaces.card,
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                onPressed: () => _openCompanionScreen(null),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: semantics.onDevice.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: semantics.onDevice.border),
                      ),
                      child: Icon(
                        LucideIcons.panelTopOpen,
                        size: 19,
                        color: semantics.onDevice.foreground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Settings Companion',
                            style: m3e.typography.emphasized.titleSmall
                                .copyWith(color: scheme.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ask Deni about the app you\'re using anytime',
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
                    style: m3e.typography.emphasized.titleMedium.copyWith(
                      fontSize: 17,
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
                      style: m3e.typography.emphasized.labelSmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
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

            // 6. Recently Reviewed (Layered Archival Folder Deck)
            if (_savedReceipts.isNotEmpty) ...[
              const SizedBox(height: 28),
              EnpriveStackedFolderDeck(
                frontColor: surfaces.card,
                frontBorderColor: surfaces.hairlineBorder,
                middleLayerColor: semantics.onDevice.background,
                backLayerColor: semantics.reviewRecommended.background,
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
                                  urlRetriever: _urlRetriever,
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
                                      receipt.deviceObservedCount > 0
                                          ? '${l10n.verifiedClausesCount(receipt.sourceMatchedCount)} · ${receipt.deviceObservedCount} ${l10n.statusDeviceObserved}'
                                          : l10n.verifiedClausesCount(
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

    await _executePolicyReview(
      subjectTitle: selected.subjectTitle,
      sourceLabel: selected.sourceLabel,
      policyText: selected.policyText,
      appPermissions: selected.permissionSnapshot,
      sourceSnapshot: PolicyIntakeHelper.snapshotForManualOrSharedText(
        sourceType: PolicySourceType.sample,
        text: selected.policyText,
        hasAppPermissions: true,
      ),
    );
  }

  void _showPasteModal(
    BuildContext context,
    AppLocalizations l10n, {
    String? initialText,
    PolicySourceType? initialSourceType,
    String? initialSubject,
  }) {
    final controller = TextEditingController(text: initialText ?? '');
    final urlController = TextEditingController();
    final trimmedInitialSubject = initialSubject?.trim() ?? '';
    final titleController = TextEditingController(
      text: trimmedInitialSubject.isNotEmpty
          ? trimmedInitialSubject
          : (initialText != null && initialText.isNotEmpty
                ? l10n.selectedExcerptTitle
                : l10n.defaultSubjectTitle),
    );
    var mode = _PasteModalMode.paste;
    String? modalError;
    bool isPickingDocument = false;
    String? loadedSampleText;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return EnpriveM3EBridgeScope.ensure(
          sheetContext,
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              final m3e = EnpriveM3ETheme.of(sheetContext);
              final scheme = m3e.colorScheme;
              final surfaces = sheetContext.enpriveSurfaces;
              final typeExt = sheetContext.enpriveType;

              return Material(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                clipBehavior: Clip.antiAlias,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom:
                          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
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
                                    .copyWith(color: scheme.onSurface),
                              ),
                            ),
                            if (mode == _PasteModalMode.paste)
                              TextButton(
                                onPressed: () async {
                                  final sample = await _loadFixtureText(
                                    'assets/fixtures/synthetic_policy_edutrack.txt',
                                    _fallbackEduTrackFixture,
                                  );
                                  loadedSampleText = sample.trim();
                                  titleController.text =
                                      'EduTrack Classroom Companion';
                                  controller.text = sample;
                                },
                                child: Text(
                                  l10n.trySampleText,
                                  style: m3e.typography.emphasized.labelLarge
                                      .copyWith(color: scheme.primary),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Segmented Source Mode Pills: Paste text vs Policy link vs Document
                        SizedBox(
                          width: double.infinity,
                          child: M3ESegmentedButton<_PasteModalMode>(
                            showSelectedIcon: false,
                            segments: [
                              M3ESegment<_PasteModalMode>(
                                value: _PasteModalMode.paste,
                                icon: const Icon(LucideIcons.fileText, size: 16),
                                label: l10n.modePasteText,
                              ),
                              M3ESegment<_PasteModalMode>(
                                value: _PasteModalMode.link,
                                icon: const Icon(LucideIcons.link2, size: 16),
                                label: l10n.modePolicyLink,
                              ),
                              const M3ESegment<_PasteModalMode>(
                                value: _PasteModalMode.document,
                                icon: Icon(LucideIcons.fileUp, size: 16),
                                label: 'Document',
                              ),
                            ],
                            selected: {mode},
                            onSelectionChanged: (selection) {
                              if (isPickingDocument) return;
                              setSheetState(() {
                                mode = selection.first;
                                modalError = null;
                              });
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
                        const SizedBox(height: 12),

                        if (mode == _PasteModalMode.link) ...[
                          TextField(
                            controller: urlController,
                            keyboardType: TextInputType.url,
                            onChanged: (_) {
                              if (modalError != null) {
                                setSheetState(() => modalError = null);
                              }
                            },
                            style: m3e.typeScale.bodyMedium.copyWith(
                              color: scheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'https://example.com/privacy-policy',
                              prefixIcon: Icon(
                                LucideIcons.link2,
                                size: 18,
                                color: scheme.primary,
                              ),
                              errorText: modalError,
                              errorMaxLines: 4,
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
                          const SizedBox(height: 8),
                          Text(
                            'Fetches the public URL directly. User-supplied links do not prove app ownership.',
                            style: m3e.typeScale.bodySmall.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ] else if (mode == _PasteModalMode.document)
                          EnpriveMaterialCardSurface(
                            variant: EnpriveCardVariant.outlined,
                            backgroundColor: surfaces.card,
                            borderRadius: BorderRadius.circular(18),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Import PDF, TXT, or DOCX policy file',
                                  style: m3e.typeScale.titleSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Text is extracted strictly on this phone with a local SHA-256 snapshot hash. Files never upload directly.',
                                  style: m3e.typeScale.bodySmall.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                if (modalError != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    modalError!,
                                    style: m3e.typeScale.bodySmall.copyWith(
                                      color: scheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        else
                          TextField(
                            controller: controller,
                            maxLines: 5,
                            style: typeExt.policyQuotation.copyWith(
                              color: scheme.onSurface,
                            ),
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
                          label: isPickingDocument
                              ? 'Working…'
                              : (mode == _PasteModalMode.document
                                    ? 'Choose document (PDF, TXT, DOCX)'
                                    : l10n.btnReviewOnPhone),
                          onPressed: isPickingDocument
                              ? null
                              : () async {
                                  if (mode == _PasteModalMode.link) {
                                    final rawUrl = urlController.text.trim();
                                    if (rawUrl.isEmpty) {
                                      setSheetState(() {
                                        modalError =
                                            'Enter a public https:// privacy policy URL.';
                                      });
                                      return;
                                    }
                                    final userTitle = titleController.text.trim();
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                    await _executeUrlReview(
                                      rawUrl: rawUrl,
                                      userSubjectTitle: userTitle,
                                    );
                                    return;
                                  }

                                  if (mode == _PasteModalMode.document) {
                                    setSheetState(() {
                                      isPickingDocument = true;
                                      modalError = null;
                                    });
                                    final doc = await _bridge
                                        .pickAndExtractDocument();
                                    if (!sheetContext.mounted) return;
                                    if (doc.isCancelled) {
                                      setSheetState(
                                        () => isPickingDocument = false,
                                      );
                                      return;
                                    }
                                    final userTitle = titleController.text.trim();
                                    Navigator.pop(sheetContext);
                                    await _handleDocumentOutcome(
                                      doc,
                                      userSubjectTitle: userTitle,
                                    );
                                    return;
                                  }

                                  final rawText = controller.text.trim();
                                  final subject =
                                      titleController.text.trim().isEmpty
                                      ? l10n.defaultSubjectTitle
                                      : titleController.text.trim();
                                  final isLoadedSample =
                                      loadedSampleText != null &&
                                      rawText == loadedSampleText;
                                  final sourceType = isLoadedSample
                                      ? PolicySourceType.sample
                                      : (initialSourceType ??
                                            PolicySourceType.pastedText);
                                  Navigator.pop(sheetContext);
                                  await _executePolicyReview(
                                    subjectTitle: subject,
                                    sourceLabel: isLoadedSample
                                        ? (l10n.sampleSyntheticBadge)
                                        : 'Pasted Snapshot',
                                    policyText: rawText,
                                    sourceSnapshot: PolicyIntakeHelper
                                        .snapshotForManualOrSharedText(
                                          sourceType: sourceType,
                                          text: rawText,
                                        ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return EnpriveFolderTabCard(
      backgroundColor: semanticPair.background,
      borderColor: semanticPair.border.withValues(alpha: 0.7),
      leadingIcon: icon,
      iconBadgeColor: isDark ? scheme.surfaceContainerLowest : scheme.onSurface,
      iconColor: isDark ? semanticPair.foreground : scheme.surface,
      trailingHeader: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: isDark ? 0.25 : 0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: semanticPair.border.withValues(alpha: 0.5)),
        ),
        child: Text(
          trendBadge,
          style: m3e.typography.emphasized.labelSmall.copyWith(
            color: semanticPair.foreground,
            fontSize: 10.5,
          ),
        ),
      ),
      semanticLabel: '$title. $value. $subtitle. $trendBadge.',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: m3e.typography.emphasized.titleLarge.copyWith(
              color: semanticPair.foreground,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: m3e.typography.emphasized.titleSmall.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: m3e.typeScale.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
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

void unawaited(Future<void> future) {}
