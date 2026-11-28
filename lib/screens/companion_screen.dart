import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/companion/companion_policy_resolver.dart';
import '../domain/intake/policy_intake_models.dart';
import '../domain/review/app_policy_association.dart' show AppIdentityCandidate;
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../services/intake/policy_intake_coordinator.dart';
import '../services/network/policy_url_retriever.dart';
import '../services/platform/companion_bridge.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import '../services/storage/receipt_repository.dart';
import '../widgets/cloud_consent_sheet.dart';
import '../widgets/deni_animated_mascot.dart';
import '../widgets/enprive_provenance_chip.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/installed_app_icon.dart';
import '../widgets/installed_app_picker_sheet.dart';
import '../widgets/intake/unified_policy_intake_sheet.dart';
import '../widgets/m3e/enprive_m3e_components.dart';
import '../widgets/review_progress_sheet.dart';

/// Contextual "Deni — Enprive Companion" screen entered either from the Android
/// Quick Settings tile (`OPEN_COMPANION`) or directly inside Enprive.
///
/// Reuses existing Deni assets, M3 Expressive tokens, `InstalledAppPickerSheet`,
/// `UnifiedPolicyIntakeSheet`, `PolicyIntakeCoordinator`, `CloudConsentSheet`,
/// and `ReviewCoordinator`.
class CompanionScreen extends StatefulWidget {
  final CompanionInvocation? invocation;
  final HybridAiBridge hybridBridge;
  final CompanionBridge companionBridge;
  final ReviewCoordinator coordinator;
  final PolicyUrlRetriever urlRetriever;
  final PolicyIntakeCoordinator? intakeCoordinator;
  final List<PolicyReviewReceipt> savedReceipts;
  final Future<void> Function(PolicyReviewReceipt receipt)? onSaveReceipt;
  final ReceiptRepository? receiptRepository;
  final String languageCode;

  const CompanionScreen({
    super.key,
    this.invocation,
    required this.hybridBridge,
    required this.companionBridge,
    required this.coordinator,
    required this.urlRetriever,
    this.intakeCoordinator,
    required this.savedReceipts,
    this.onSaveReceipt,
    this.receiptRepository,
    this.languageCode = 'en',
  });

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen>
    with WidgetsBindingObserver {
  late final PolicyIntakeCoordinator _intakeCoordinator;

  bool _isResolvingForeground = false;
  bool _isDeviceLocked = false;
  UsageAccessState _usageAccessState = UsageAccessState.denied;
  QuickSettingsTileStatus? _tileStatus;
  bool _awaitingUsageAccessReturn = false;

  ForegroundAppResolution? _resolution;
  bool _isAppConfirmed = false;
  bool _continuedWithoutAppContext = false;
  String? _confirmedPackageName;
  String? _confirmedAppLabel;
  String? _confirmedVersionLabel;
  bool _isLoadingPermissions = false;
  AppSensitivePermissionsResult? _permissionsResult;
  int _appContextSequence = 0;

  DeclaredSensitivePermission? _selectedPermission;
  GuidedPermissionOption? _selectedGuidedOption;
  bool _showUnsureGuide = false;
  bool _showCompanionAdvancedDetails = false;

  final List<PolicyReviewReceipt> _sessionReceipts = [];
  final Set<String> _persistedReceiptIds = <String>{};
  int _draftCounter = 0;
  bool _isSavingSessionReceipt = false;
  String? _companionSaveError;
  bool _isOpeningIntakeSheet = false;
  bool _isAttachingPolicy = false;
  bool _isCloudPolicyInFlight = false;
  bool _isCancellingPolicy = false;
  String? _activePolicyReqId;
  int _policyOpSequence = 0;

  bool _isAskingDeni = false;
  bool _isAskingCloud = false;
  bool _isCancellingAsk = false;
  bool _isFinishingCompanion = false;
  String? _activeAskReqId;
  int _askOpSequence = 0;
  DeniExplanation? _deniAnswer;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _featureContextController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _intakeCoordinator =
        widget.intakeCoordinator ??
        PolicyIntakeCoordinator(
          urlRetriever: widget.urlRetriever,
          hybridBridge: widget.hybridBridge,
        );
    _sessionReceipts.addAll(widget.savedReceipts);
    _persistedReceiptIds.addAll(widget.savedReceipts.map((r) => r.id));
    _isDeviceLocked = widget.invocation?.deviceLocked ?? false;
    unawaited(_bootstrapCompanionContext());
  }

  @override
  void dispose() {
    _appContextSequence++;
    _policyOpSequence++;
    _askOpSequence++;
    if (_activePolicyReqId != null) {
      unawaited(
        widget.hybridBridge.cancelAnalysis(requestId: _activePolicyReqId),
      );
    }
    if (_activeAskReqId != null) {
      unawaited(widget.hybridBridge.cancelAnalysis(requestId: _activeAskReqId));
    }
    WidgetsBinding.instance.removeObserver(this);
    _questionController.dispose();
    _featureContextController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_handleResumeLifecycle());
    }
  }

  Future<void> _handleResumeLifecycle() async {
    final accessInfo = await widget.companionBridge.checkUsageAccess();
    final tileStatus = await widget.companionBridge
        .getQuickSettingsTileStatus();
    if (!mounted) return;

    final wasLocked = _isDeviceLocked;
    final unlockedNow = wasLocked && !accessInfo.deviceLocked;
    final returningFromSettings = _awaitingUsageAccessReturn;
    _awaitingUsageAccessReturn = false;

    setState(() {
      _usageAccessState = accessInfo.status;
      _isDeviceLocked = accessInfo.deviceLocked;
      _tileStatus = tileStatus;
    });

    if (unlockedNow ||
        (returningFromSettings &&
            accessInfo.status == UsageAccessState.granted)) {
      await _runOneTimeForegroundLookup();
    }
  }

  Future<void> _bootstrapCompanionContext() async {
    final accessInfo = await widget.companionBridge.checkUsageAccess();
    final tileStatus = await widget.companionBridge
        .getQuickSettingsTileStatus();
    if (!mounted) return;
    setState(() {
      _usageAccessState = accessInfo.status;
      _isDeviceLocked =
          accessInfo.deviceLocked || (widget.invocation?.deviceLocked ?? false);
      _tileStatus = tileStatus;
    });

    if (_isDeviceLocked) return;

    if (accessInfo.status == UsageAccessState.granted) {
      await _runOneTimeForegroundLookup();
    } else if (widget.invocation != null) {
      // Capture explicit usageAccessDenied resolution state when launched from tile.
      await _runOneTimeForegroundLookup();
    } else {
      setState(() {
        _resolution = const ForegroundAppResolution(
          status: ForegroundResolutionStatus.usageAccessDenied,
          fallbackReason: 'Usage Access is optional. You can choose an app manually or allow Usage Access for one-tap identification.',
        );
      });
    }
  }

  Future<void> _runOneTimeForegroundLookup() async {
    if (_isResolvingForeground) return;
    setState(() => _isResolvingForeground = true);
    final res = await widget.companionBridge.resolveForegroundApp(
      invocationTimestampMs: widget.invocation?.timestampMs,
    );
    if (!mounted) return;
    setState(() {
      _isResolvingForeground = false;
      _isDeviceLocked = res.status == ForegroundResolutionStatus.deviceLocked;
      _resolution = res;
    });
  }

  Future<void> _confirmCandidateApp({
    required String packageName,
    required String applicationLabel,
  }) async {
    final appSeq = ++_appContextSequence;
    _cancelActivePolicyAndAskForContextChange();
    setState(() {
      _isAppConfirmed = true;
      _continuedWithoutAppContext = false;
      _confirmedPackageName = packageName;
      _confirmedAppLabel = applicationLabel;
      _confirmedVersionLabel = null;
      _isLoadingPermissions = true;
      _permissionsResult = null;
      _selectedPermission = null;
      _selectedGuidedOption = null;
      _showUnsureGuide = false;
      _deniAnswer = null;
      _companionSaveError = null;
    });

    final inspected = await widget.companionBridge
        .getDeclaredSensitivePermissions(packageName);
    if (!mounted || appSeq != _appContextSequence) return;
    if (inspected.status == AppPermissionsLookupStatus.deviceLocked) {
      setState(() {
        _isDeviceLocked = true;
        _isLoadingPermissions = false;
      });
      return;
    }

    setState(() {
      _isLoadingPermissions = false;
      _permissionsResult = inspected;
      if (inspected.applicationLabel?.trim().isNotEmpty == true) {
        _confirmedAppLabel = inspected.applicationLabel!.trim();
      }
      if (inspected.versionName?.trim().isNotEmpty == true) {
        _confirmedVersionLabel = 'v${inspected.versionName!.trim()}';
      }
    });
  }

  void _cancelActivePolicyAndAskForContextChange() {
    final policyReqId = _activePolicyReqId;
    final askReqId = _activeAskReqId;
    _policyOpSequence++;
    _askOpSequence++;
    _isAttachingPolicy = false;
    _isCloudPolicyInFlight = false;
    _isCancellingPolicy = false;
    _activePolicyReqId = null;
    _isAskingDeni = false;
    _isAskingCloud = false;
    _isCancellingAsk = false;
    _activeAskReqId = null;
    if (policyReqId != null) {
      unawaited(widget.hybridBridge.cancelAnalysis(requestId: policyReqId));
    }
    if (askReqId != null) {
      unawaited(widget.hybridBridge.cancelAnalysis(requestId: askReqId));
    }
  }

  Future<void> _openManualAppPicker() async {
    final choice = await InstalledAppPickerSheet.show(
      context,
      bridge: widget.hybridBridge,
      savedReceipts: _persistedReceiptsForPicker(),
    );
    if (!mounted || choice == null) return;

    await _confirmCandidateApp(
      packageName: choice.permissionSnapshot.packageName,
      applicationLabel: choice.subjectTitle,
    );
  }

  AppLocalizations _l10n(BuildContext context) {
    return AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? Locale(widget.languageCode),
        );
  }

  static String _localizeFallbackReason(String raw, AppLocalizations l10n) {
    final trimmed = raw.trim();
    return switch (trimmed) {
      'Usage Access is optional. You can choose an app manually or allow Usage Access for one-tap identification.' =>
        l10n.companionUsageOptionalReason,
      'Usage Access has not been enabled in Android Settings.' =>
        l10n.companionFallbackUsageNotEnabled,
      'Android UsageStatsManager is unavailable.' =>
        l10n.companionFallbackUsageUnavailable,
      'Only Android system or permission prompt UI appeared in recent usage events; choose the app manually.' =>
        l10n.companionFallbackTransientUi,
      'The most recently active app cannot be inspected under Android package visibility restrictions. Please choose an app from the list or paste its policy.' =>
        l10n.companionFallbackVisibilityRestricted,
      'Unlock your device before viewing app context.' =>
        l10n.companionFallbackUnlockRequired,
      _ => raw,
    };
  }

  static String _localizeGuidedTitle(
    GuidedPermissionOption opt,
    AppLocalizations l10n,
  ) {
    return switch (opt.categoryId) {
      'location' => l10n.guidedCatLocation,
      'camera' => l10n.companionPermCamera,
      'microphone' => l10n.companionPermMicrophone,
      'contacts' => l10n.guidedCatContacts,
      'photos_media' => l10n.guidedCatPhotosMedia,
      'notifications' => l10n.guidedCatNotifications,
      'nearby_devices' => l10n.guidedCatNearbyDevices,
      'calendar' => l10n.guidedCatCalendar,
      'phone' => l10n.guidedCatPhone,
      'sms' => l10n.guidedCatSms,
      _ => opt.title,
    };
  }

  void _continueWithoutAppContext() {
    _appContextSequence++;
    _cancelActivePolicyAndAskForContextChange();
    setState(() {
      _isAppConfirmed = false;
      _continuedWithoutAppContext = true;
      _confirmedPackageName = null;
      _confirmedAppLabel = null;
      _confirmedVersionLabel = null;
      _permissionsResult = null;
      _selectedPermission = null;
      _selectedGuidedOption = CompanionPolicyResolver.guidedOptions.first;
      _showUnsureGuide = true;
      _deniAnswer = null;
      _companionSaveError = null;
    });
  }

  Future<void> _openUsageAccessSettings() async {
    _awaitingUsageAccessReturn = true;
    final opened = await widget.companionBridge.openUsageAccessSettings();
    if (!mounted) return;
    if (!opened) {
      final l10n = _l10n(context);
      _awaitingUsageAccessReturn = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.usageAccessOpenFailedSnack),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _requestQuickSettingsTile() async {
    final outcome = await widget.companionBridge.requestQuickSettingsTile();
    final updated = await widget.companionBridge.getQuickSettingsTileStatus();
    if (!mounted) return;
    final l10n = _l10n(context);
    setState(() => _tileStatus = updated);

    final message = switch (outcome) {
      TileAddOutcome.tileAdded => l10n.companionTileAddedSnack,
      TileAddOutcome.alreadyAdded => l10n.companionTileAlreadyAddedSnack,
      TileAddOutcome.declined => l10n.companionTileDeclinedSnack,
      TileAddOutcome.manualRequired => l10n.companionTileManualSnack,
      TileAddOutcome.failed ||
      TileAddOutcome.unavailable => l10n.companionTileUnavailableSnack,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Saved receipts for the picker: the caller-supplied history merged with
  /// receipts explicitly saved during this Companion session (deduplicated by
  /// receipt ID). Unsaved session drafts are never included.
  List<PolicyReviewReceipt> _persistedReceiptsForPicker() {
    final byId = <String, PolicyReviewReceipt>{
      for (final receipt in widget.savedReceipts) receipt.id: receipt,
    };
    for (final receipt in _sessionReceipts) {
      if (_isSessionReceiptPersisted(receipt.id)) {
        byId[receipt.id] = receipt;
      }
    }
    return List<PolicyReviewReceipt>.unmodifiable(byId.values);
  }

  bool _isSessionReceiptPersisted(String receiptId) =>
      _persistedReceiptIds.contains(receiptId) ||
      (widget.receiptRepository?.containsReceiptSync(receiptId) ?? false);

  bool get _canPersistSessionReceipts =>
      widget.onSaveReceipt != null || widget.receiptRepository != null;

  Future<void> _saveCompanionSessionReceipt(PolicyReviewReceipt receipt) async {
    if (_isSavingSessionReceipt ||
        _isSessionReceiptPersisted(receipt.id) ||
        !_canPersistSessionReceipts) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isSavingSessionReceipt = true;
      _companionSaveError = null;
    });

    try {
      if (widget.onSaveReceipt != null) {
        await widget.onSaveReceipt!(receipt);
      } else if (widget.receiptRepository != null) {
        await widget.receiptRepository!.saveReceipt(receipt);
      }
      if (!mounted) return;
      setState(() {
        _isSavingSessionReceipt = false;
        _persistedReceiptIds.add(receipt.id);
        _companionSaveError = null;
      });
      final l10n = _l10n(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.companionSavedLocalReceiptsSnack),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!mounted) return;
      final err = _l10n(context).companionSaveReceiptFailed;
      setState(() {
        _isSavingSessionReceipt = false;
        _companionSaveError = err;
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(err),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  PolicyReviewReceipt? _activeMatchedReceipt() {
    return CompanionPolicyResolver.findVerifiedReceiptForPackage(
      _confirmedPackageName,
      _sessionReceipts,
    );
  }

  CompanionPermissionExplanation? _buildActiveExplanation() {
    if (_selectedPermission == null && _selectedGuidedOption == null) {
      return null;
    }
    return CompanionPolicyResolver.buildExplanation(
      permission: _selectedPermission,
      guidedCategory: _selectedGuidedOption,
      confirmedAppLabel: _confirmedAppLabel,
      confirmedPackageName: _confirmedPackageName,
      verifiedReceipt: _activeMatchedReceipt(),
    );
  }

  /// Returns a genuine on-device [AppPermissionSnapshot] for [packageName] when
  /// Companion already holds a valid observation (`_permissionsResult.isOk`).
  /// Returns `null` when metadata is unavailable so Enprive never fabricates a
  /// false empty permission snapshot.
  AppPermissionSnapshot? _existingConfirmedAppSnapshot(
    String packageName,
    String appLabel,
  ) {
    final result = _permissionsResult;
    if (result != null && result.isOk && result.packageName == packageName) {
      final declared = result.permissions;
      return AppPermissionSnapshot(
        packageName: packageName,
        appName: appLabel,
        requestedPermissions: declared
            .map((p) => p.permission)
            .toList(growable: false),
        grantedPermissions: declared
            .where(
              (p) => p.grantStatus == DeclaredPermissionGrantStatus.granted,
            )
            .map((p) => p.permission)
            .toList(growable: false),
      );
    }

    return null;
  }

  Future<void> _openAttachPolicyModal() async {
    if (_isAttachingPolicy ||
        _isOpeningIntakeSheet ||
        _confirmedPackageName == null) {
      return;
    }
    final pkg = _confirmedPackageName!;
    final appSeq = _appContextSequence;
    final appDisplay = _confirmedAppLabel ?? pkg;
    final existingSnapshot = _existingConfirmedAppSnapshot(pkg, appDisplay);
    final peerCandidates = (_resolution?.candidates ?? const [])
        .where((c) => c.packageName.trim().isNotEmpty)
        .map(
          (c) => AppIdentityCandidate(
            packageName: c.packageName,
            appName: c.applicationLabel,
          ),
        )
        .toList(growable: false);
    final lockedApp = SelectedAppReference(
      packageName: pkg,
      appName: appDisplay,
      permissionSnapshot: existingSnapshot,
      peerCandidates: peerCandidates,
      isLocked: true,
    );

    _isOpeningIntakeSheet = true;
    PolicyIntakeSuccess? intake;
    try {
      intake = await UnifiedPolicyIntakeSheet.show(
        context,
        config: PolicyIntakeSheetConfig(
          coordinator: _intakeCoordinator,
          titleOverride: _l10n(context).companionVerifyPolicyTitle(appDisplay),
          initialMode: PolicyIntakeMode.url,
          initialSelectedApp: lockedApp,
          companionBridge: widget.companionBridge,
        ),
      );
    } finally {
      _isOpeningIntakeSheet = false;
    }

    if (!mounted ||
        intake == null ||
        appSeq != _appContextSequence ||
        _confirmedPackageName != pkg) {
      return;
    }

    await _runPolicyReviewForIntake(intake, expectedAppSeq: appSeq);
  }

  Future<void> _runPolicyReviewForIntake(
    PolicyIntakeSuccess intake, {
    required int expectedAppSeq,
  }) async {
    final pkg = intake.selectedApp?.packageName ?? _confirmedPackageName;
    if (pkg == null ||
        expectedAppSeq != _appContextSequence ||
        _confirmedPackageName != pkg) {
      return;
    }
    final label = _confirmedAppLabel ?? intake.selectedApp?.appName ?? pkg;

    final captured = intake.capturedSnapshot;
    final policyText = captured.normalizedPolicyText;
    final sourceLabel = captured.sourceLabel;
    final snapshot = captured.sourceSnapshot;

    final opSeq = ++_policyOpSequence;
    setState(() {
      _isAttachingPolicy = true;
      _isCloudPolicyInFlight = false;
      _isCancellingPolicy = false;
      _activePolicyReqId = null;
    });

    try {
      // Refresh on-device PackageManager permissions through the intake
      // coordinator's local hydration boundary; fall back only to a previously
      // confirmed valid device observation, never fabricating a false snapshot.
      final hydrated = await _intakeCoordinator.hydrateAppPermissions(
        SelectedAppReference(packageName: pkg, appName: label, isLocked: true),
      );
      if (!mounted ||
          opSeq != _policyOpSequence ||
          expectedAppSeq != _appContextSequence ||
          _confirmedPackageName != pkg) {
        return;
      }

      final hydratedSnapshot = hydrated.permissionSnapshot;
      final AppPermissionSnapshot? appSnap =
          (hydratedSnapshot != null && hydratedSnapshot.packageName == pkg)
          ? hydratedSnapshot
          : (intake.selectedApp?.permissionSnapshot ??
                _existingConfirmedAppSnapshot(pkg, label));

      final reqId = 'comp_rev_${DateTime.now().millisecondsSinceEpoch}';
      setState(() => _activePolicyReqId = reqId);

      var outcome = await widget.coordinator.runPolicyReview(
        requestId: reqId,
        subjectTitle: label,
        sourceLabel: sourceLabel,
        policyText: policyText,
        appPermissions: appSnap,
        sourceSnapshot: snapshot,
        languageCode: widget.languageCode,
      );
      if (!mounted ||
          opSeq != _policyOpSequence ||
          expectedAppSeq != _appContextSequence ||
          _confirmedPackageName != pkg) {
        return;
      }

      if (outcome.needsCloudConsentOrManual) {
        setState(() => _isAttachingPolicy = false);
        final canonicalPayload =
            outcome.redactedPreview ??
            ReviewCoordinator.canonicalCloudPayload(policyText);
        final decision = await CloudConsentSheet.show(
          context,
          subjectTitle: label,
          policyText: policyText,
          canonicalRedactedPreview: canonicalPayload,
          deviceReason: outcome.errorReason,
        );
        if (!mounted ||
            opSeq != _policyOpSequence ||
            expectedAppSeq != _appContextSequence ||
            _confirmedPackageName != pkg) {
          return;
        }
        if (decision == CloudConsentDecision.cancelled) return;

        final retryId = 'comp_rev_c_${DateTime.now().millisecondsSinceEpoch}';
        setState(() {
          _isAttachingPolicy = true;
          _isCloudPolicyInFlight =
              decision == CloudConsentDecision.useCloudOnce;
          _activePolicyReqId = retryId;
        });

        outcome = await widget.coordinator.runPolicyReview(
          requestId: retryId,
          subjectTitle: label,
          sourceLabel: sourceLabel,
          policyText: policyText,
          appPermissions: appSnap,
          sourceSnapshot: snapshot,
          canonicalRedactedPayload:
              decision == CloudConsentDecision.useCloudOnce
              ? canonicalPayload
              : null,
          cloudConsent: decision == CloudConsentDecision.useCloudOnce,
          forceLocalManualScan: decision == CloudConsentDecision.reviewLocally,
          languageCode: widget.languageCode,
        );
        if (!mounted ||
            opSeq != _policyOpSequence ||
            expectedAppSeq != _appContextSequence ||
            _confirmedPackageName != pkg) {
          return;
        }
      }

      if (outcome.receipt != null) {
        final rawDraft = outcome.receipt!;
        final baseline = CompanionPolicyResolver.findVerifiedReceiptForPackage(
          pkg,
          _persistedReceiptsForPicker(),
        );
        final activeBefore = _activeMatchedReceipt();
        final existingIds = <String>{
          ..._persistedReceiptIds,
          ..._sessionReceipts.map((r) => r.id),
          if (baseline != null) baseline.id,
        };
        final distinctId =
            (rawDraft.id.isEmpty ||
                existingIds.contains(rawDraft.id) ||
                _isSessionReceiptPersisted(rawDraft.id))
            ? 'comp_draft_${DateTime.now().microsecondsSinceEpoch}_${++_draftCounter}'
            : rawDraft.id;
        var createdAt = rawDraft.createdAt;
        if (baseline != null && !createdAt.isAfter(baseline.createdAt)) {
          createdAt = baseline.createdAt.add(const Duration(milliseconds: 1));
        }
        if (activeBefore != null &&
            !createdAt.isAfter(activeBefore.createdAt)) {
          createdAt = activeBefore.createdAt.add(
            const Duration(milliseconds: 1),
          );
        }
        final draft = rawDraft.copyWith(
          id: distinctId,
          createdAt: createdAt,
          supersedesReceiptId: baseline?.id,
        );
        // Privacy Guardrail: Never auto-save Companion policy reviews to SQLite.
        // Hold the draft in session memory until the user explicitly taps
        // "Save receipt to Enprive".
        _sessionReceipts.removeWhere((r) => r.id == draft.id);
        _sessionReceipts.insert(0, draft);
        if (mounted) {
          setState(() {
            _deniAnswer = null;
            _companionSaveError = null;
          });
        }
      }
    } on HybridOperationCancelledException catch (e) {
      if (mounted && opSeq == _policyOpSequence) {
        final l10n = _l10n(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.isTimeout
                  ? l10n.companionCloudTimeoutSnack
                  : l10n.companionAnalysisCancelledSnack,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted && opSeq == _policyOpSequence) {
        setState(() {
          _isAttachingPolicy = false;
          _isCloudPolicyInFlight = false;
          _isCancellingPolicy = false;
          _activePolicyReqId = null;
        });
      }
    }
  }

  void _cancelPolicyAttach() {
    if (!_isAttachingPolicy) return;
    final reqId = _activePolicyReqId;
    _policyOpSequence++;
    setState(() {
      _isCancellingPolicy = true;
      _isAttachingPolicy = false;
      _isCloudPolicyInFlight = false;
      _activePolicyReqId = null;
    });
    if (reqId != null) {
      unawaited(widget.hybridBridge.cancelAnalysis(requestId: reqId));
    } else {
      unawaited(widget.hybridBridge.cancelAnalysis());
    }
  }

  void _cancelAskDeni() {
    if (!_isAskingDeni) return;
    final reqId = _activeAskReqId;
    _askOpSequence++;
    setState(() {
      _isCancellingAsk = true;
      _isAskingDeni = false;
      _isAskingCloud = false;
      _activeAskReqId = null;
    });
    if (reqId != null) {
      unawaited(widget.hybridBridge.cancelAnalysis(requestId: reqId));
    } else {
      unawaited(widget.hybridBridge.cancelAnalysis());
    }
  }

  Future<void> _askDeni(String question) async {
    final trimmed = question.trim();
    final explanation = _buildActiveExplanation();
    if (trimmed.isEmpty || explanation == null || _isAskingDeni) return;

    final seq = ++_askOpSequence;
    var reqId = 'comp_ask_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _questionController.text = trimmed;
      _isAskingDeni = true;
      _isAskingCloud = false;
      _isCancellingAsk = false;
      _activeAskReqId = reqId;
    });

    try {
      var answer = await widget.coordinator.askDeniAboutPermission(
        explanation: explanation,
        question: trimmed,
        userFeatureContext: _featureContextController.text,
        confirmedPackageName: _confirmedPackageName,
        cloudConsent: false,
        languageCode: widget.languageCode,
        requestId: reqId,
      );
      if (!mounted || seq != _askOpSequence) return;

      if (answer.requiresCloudConsent) {
        setState(() => _isAskingDeni = false);
        final decision = await CloudConsentSheet.show(
          context,
          subjectTitle: explanation.title,
          policyText:
              answer.redactedPreview ??
              (explanation.verbatimExcerpts.isNotEmpty
                  ? explanation.verbatimExcerpts.join('\n')
                  : ''),
          canonicalRedactedPreview: answer.redactedPreview,
          deviceReason: answer.consentReason,
        );
        if (!mounted || seq != _askOpSequence) return;
        if (decision == CloudConsentDecision.cancelled) return;

        reqId = 'comp_ask_c_${DateTime.now().millisecondsSinceEpoch}';
        setState(() {
          _isAskingDeni = true;
          _isAskingCloud = decision == CloudConsentDecision.useCloudOnce;
          _activeAskReqId = reqId;
        });

        answer = await widget.coordinator.askDeniAboutPermission(
          explanation: explanation,
          question: trimmed,
          userFeatureContext: _featureContextController.text,
          confirmedPackageName: _confirmedPackageName,
          cloudConsent: decision == CloudConsentDecision.useCloudOnce,
          forceLocalManualFallback:
              decision == CloudConsentDecision.reviewLocally,
          languageCode: widget.languageCode,
          requestId: reqId,
        );
        if (!mounted || seq != _askOpSequence) return;
      }

      setState(() => _deniAnswer = answer);
    } on HybridOperationCancelledException catch (e) {
      if (mounted && seq == _askOpSequence) {
        final l10n = _l10n(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.isTimeout
                  ? l10n.companionCloudAnswerTimeoutSnack
                  : l10n.companionQuestionCancelledSnack,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted && seq == _askOpSequence) {
        setState(() {
          _isAskingDeni = false;
          _isAskingCloud = false;
          _isCancellingAsk = false;
          _activeAskReqId = null;
        });
      }
    }
  }

  Future<void> _finishCompanion({bool returnToCallerApp = true}) async {
    if (_isFinishingCompanion) return;
    _isFinishingCompanion = true;
    _appContextSequence++;
    _cancelActivePolicyAndAskForContextChange();
    try {
      if (returnToCallerApp && widget.invocation != null) {
        await widget.companionBridge.returnToPreviousApp();
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      _isFinishingCompanion = false;
    }
  }

  List<DeclaredSensitivePermission> _effectiveDeclaredPermissions() {
    return _permissionsResult?.permissions ??
        const <DeclaredSensitivePermission>[];
  }

  DeniPose _currentDeniPose() {
    if (_isResolvingForeground || _isAttachingPolicy || _isAskingDeni) {
      return DeniPose.thinking;
    }
    if (_selectedPermission != null || _selectedGuidedOption != null) {
      return DeniPose.explaining;
    }
    if (_isAppConfirmed) {
      return DeniPose.listening;
    }
    return DeniPose.support;
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (context) {
          final l10n = _l10n(context);
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final surfaces = context.enpriveSurfaces;
          final semantics = context.enpriveSemantics;

          final launchedFromQuickSettings = widget.invocation != null;

          return PopScope(
            canPop: !launchedFromQuickSettings,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop && launchedFromQuickSettings) {
                unawaited(_finishCompanion(returnToCallerApp: true));
              }
            },
            child: Scaffold(
              backgroundColor: scheme.surface,
              appBar: AppBar(
                leading: IconButton(
                  key: const Key('companion_appbar_back_btn'),
                  icon: Icon(
                    launchedFromQuickSettings
                        ? LucideIcons.x
                        : LucideIcons.arrowLeft,
                    color: scheme.onSurface,
                  ),
                  tooltip: launchedFromQuickSettings
                      ? l10n.companionTooltipReturnToPrev
                      : l10n.companionTooltipBack,
                  onPressed: launchedFromQuickSettings
                      ? () => _finishCompanion(returnToCallerApp: true)
                      : () => Navigator.of(context).maybePop(),
                ),
                title: Text(
                  l10n.companionTitle,
                  style: m3e.typography.emphasized.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              body: SafeArea(
                child: _isDeviceLocked
                    ? _buildLockedGuard(
                        context,
                        m3e,
                        scheme,
                        surfaces,
                        semantics,
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeaderCompanionBanner(
                              context,
                              m3e,
                              scheme,
                              surfaces,
                              semantics,
                            ),
                            const SizedBox(height: 16),
                            if (!_isAppConfirmed &&
                                !_continuedWithoutAppContext)
                              _buildAppConfirmationSection(
                                context,
                                m3e,
                                scheme,
                                surfaces,
                                semantics,
                              )
                            else ...[
                              _buildConfirmedContextSummary(
                                context,
                                m3e,
                                scheme,
                                surfaces,
                                semantics,
                              ),
                              if (_buildActiveExplanation() == null &&
                                  _activeMatchedReceipt() != null) ...[
                                const SizedBox(height: 12),
                                _buildCompanionReceiptPersistenceCard(
                                  context,
                                  _activeMatchedReceipt()!,
                                  m3e,
                                  scheme,
                                  surfaces,
                                  semantics,
                                ),
                              ],
                              const SizedBox(height: 16),
                              _buildPermissionSelectorSection(
                                context,
                                m3e,
                                scheme,
                                surfaces,
                                semantics,
                              ),
                              if (_showUnsureGuide) ...[
                                const SizedBox(height: 14),
                                _buildGuidedUnsureSection(
                                  context,
                                  m3e,
                                  scheme,
                                  surfaces,
                                  semantics,
                                ),
                              ],
                              if (_buildActiveExplanation() != null) ...[
                                const SizedBox(height: 18),
                                _buildPermissionExplanationSection(
                                  context,
                                  _buildActiveExplanation()!,
                                  m3e,
                                  scheme,
                                  surfaces,
                                  semantics,
                                ),
                              ],
                            ],
                            const SizedBox(height: 22),
                            EnpriveTactileButton(
                              key: const Key('companion_return_btn'),
                              label:
                                  widget.invocation != null &&
                                      _confirmedAppLabel != null
                                  ? l10n.companionDoneReturnToApp(
                                      _confirmedAppLabel!,
                                    )
                                  : (widget.invocation != null
                                        ? l10n.companionDoneReturnToPrev
                                        : l10n.btnDone),
                              isSecondary: true,
                              onPressed: () =>
                                  _finishCompanion(returnToCallerApp: true),
                            ),
                            if (launchedFromQuickSettings) ...[
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  key: const Key('companion_open_enprive_btn'),
                                  onPressed: () => _finishCompanion(
                                    returnToCallerApp: false,
                                  ),
                                  child: Text(
                                    l10n.companionOpenFullAppBtn,
                                    style: m3e.typeScale.labelLarge.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildLockedGuard(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
  ) {
    final l10n = _l10n(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EnpriveCompanionCard(
            pose: DeniPose.peek,
            layout: EnpriveCompanionLayout.peeking,
            badgeText: l10n.companionLockedBadge,
            badgeIcon: LucideIcons.lock,
            title: l10n.companionLockedTitle,
            message: l10n.companionLockedBody,
            accentColor: semantics.onDevice.foreground,
            accentBackground: semantics.onDevice.background,
            backgroundColor: surfaces.card,
            action: EnpriveTactileButton(
              label: l10n.companionCheckUnlockBtn,
              onPressed: _handleResumeLifecycle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCompanionBanner(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
  ) {
    final l10n = _l10n(context);
    final String headline;
    final String subtitle;

    if (_isResolvingForeground) {
      headline = l10n.companionCheckingAppHeadline;
      subtitle = l10n.companionCheckingAppSubtitle;
    } else if (_continuedWithoutAppContext) {
      headline = l10n.companionGeneralGuideHeadline;
      subtitle = l10n.companionGeneralGuideSubtitle;
    } else if (_isAppConfirmed) {
      headline = l10n.companionLookingAtHeadline(
        _confirmedAppLabel ?? l10n.companionThisAppFallback,
      );
      subtitle = l10n.companionLookingAtSubtitle;
    } else {
      headline = l10n.companionTitle;
      subtitle = l10n.companionSubtitle;
    }

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.elevated,
      backgroundColor: surfaces.card,
      borderRadius: BorderRadius.circular(24),
      lipHeight: 2.5,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DeniAnimatedMascot(
            size: 56,
            pose: _currentDeniPose(),
            lodOverride: DeniLodTier.compact,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: m3e.typography.emphasized.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: m3e.typeScale.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppConfirmationSection(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
  ) {
    final l10n = _l10n(context);
    final res = _resolution;
    if (_isResolvingForeground || res == null) {
      return EnpriveMaterialCardSurface(
        variant: EnpriveCardVariant.outlined,
        backgroundColor: surfaces.cardMuted,
        borderRadius: BorderRadius.circular(22),
        lipHeight: 2.0,
        padding: const EdgeInsets.all(20),
        child: const Center(child: M3ELoadingIndicator(size: 32)),
      );
    }

    final status = res.status;
    final hasSingleCandidate =
        (status == ForegroundResolutionStatus.identified ||
            status == ForegroundResolutionStatus.stale) &&
        res.hasCandidatePackage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasSingleCandidate) ...[
          EnpriveMaterialCardSurface(
            variant: EnpriveCardVariant.elevated,
            backgroundColor: surfaces.card,
            borderRadius: BorderRadius.circular(24),
            lipHeight: 3.0,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InstalledAppIcon(
                      packageName: res.packageName!,
                      bridge: widget.hybridBridge,
                      size: 46,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == ForegroundResolutionStatus.stale
                                ? l10n.companionSawAppAgo(
                                    res.displayLabel,
                                    ((res.eventAgeMillis ?? 0) / 1000).round(),
                                  )
                                : l10n.companionThinkUsingApp(res.displayLabel),
                            style: m3e.typography.emphasized.titleMedium
                                .copyWith(color: scheme.onSurface),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l10n.companionAppIdLine(res.packageName!),
                            style: m3e.typeScale.labelSmall.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (res.fallbackReason != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _localizeFallbackReason(res.fallbackReason!, l10n),
                    style: m3e.typeScale.bodySmall.copyWith(
                      color: semantics.reviewRecommended.foreground,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                EnpriveTactileButton(
                  key: const Key('companion_confirm_app_btn'),
                  label: l10n.companionConfirmAppBtn(res.displayLabel),
                  onPressed: () => _confirmCandidateApp(
                    packageName: res.packageName!,
                    applicationLabel: res.displayLabel,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onPressed: _openManualAppPicker,
                      child: Text(l10n.companionChooseAnotherAppBtn),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      onPressed: _continueWithoutAppContext,
                      child: Text(l10n.companionWithoutAppContextBtn),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else if (status == ForegroundResolutionStatus.ambiguous &&
            res.candidates.isNotEmpty) ...[
          EnpriveMaterialCardSurface(
            variant: EnpriveCardVariant.elevated,
            backgroundColor: surfaces.card,
            borderRadius: BorderRadius.circular(24),
            lipHeight: 2.5,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.companionMultipleAppsTitle,
                  style: m3e.typography.emphasized.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  res.fallbackReason != null
                      ? _localizeFallbackReason(res.fallbackReason!, l10n)
                      : l10n.companionMultipleAppsPrompt,
                  style: m3e.typeScale.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                for (final candidate in res.candidates) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _confirmCandidateApp(
                      packageName: candidate.packageName,
                      applicationLabel: candidate.applicationLabel,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaces.cardMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: surfaces.hairlineBorder),
                      ),
                      child: Row(
                        children: [
                          InstalledAppIcon(
                            packageName: candidate.packageName,
                            bridge: widget.hybridBridge,
                            size: 36,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidate.applicationLabel,
                                  style: m3e.typeScale.titleSmall.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  l10n.companionSecondsAgo(
                                    (candidate.eventAgeMillis / 1000).round(),
                                  ),
                                  style: m3e.typeScale.labelSmall.copyWith(
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
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onPressed: _openManualAppPicker,
                      child: Text(l10n.companionChooseAnotherAppBtn),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      onPressed: _continueWithoutAppContext,
                      child: Text(l10n.companionWithoutAppContextBtn),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          EnpriveMaterialCardSurface(
            variant: EnpriveCardVariant.elevated,
            backgroundColor: surfaces.card,
            borderRadius: BorderRadius.circular(24),
            lipHeight: 2.5,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status == ForegroundResolutionStatus.usageAccessDenied
                      ? l10n.usageAccessTitle
                      : l10n.companionSelectAppTitle,
                  style: m3e.typography.emphasized.titleMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status == ForegroundResolutionStatus.usageAccessDenied
                      ? l10n.usageAccessExplanation
                      : (res.fallbackReason != null
                            ? _localizeFallbackReason(res.fallbackReason!, l10n)
                            : l10n.companionSelectAppBody),
                  style: m3e.typeScale.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                EnpriveTactileButton(
                  key: const Key('companion_choose_app_manual_btn'),
                  label: l10n.companionChooseAppManuallyBtn,
                  onPressed: _openManualAppPicker,
                ),
                const SizedBox(height: 10),
                if (status == ForegroundResolutionStatus.usageAccessDenied)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('companion_usage_access_btn'),
                      onPressed: _openUsageAccessSettings,
                      icon: const Icon(LucideIcons.settings, size: 16),
                      label: Text(l10n.companionOpenUsageAccessBtn),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('companion_without_app_btn'),
                    onPressed: _continueWithoutAppContext,
                    child: Text(l10n.companionContinueWithoutAppBtn),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_tileStatus != null &&
            !_tileStatus!.isTileAdded &&
            !_tileStatus!.hasDeclinedBefore) ...[
          const SizedBox(height: 14),
          _buildQuickSettingsInstallCard(
            context,
            m3e,
            scheme,
            surfaces,
            semantics,
          ),
        ],
      ],
    );
  }

  Widget _buildQuickSettingsInstallCard(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
  ) {
    final l10n = _l10n(context);
    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.outlined,
      backgroundColor: surfaces.cardMuted,
      borderRadius: BorderRadius.circular(20),
      lipHeight: 2.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickSettingsSectionTitle,
            style: m3e.typeScale.titleSmall.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.quickSettingsTileSubtitle,
            style: m3e.typeScale.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _requestQuickSettingsTile,
            icon: const Icon(LucideIcons.layoutGrid, size: 16),
            label: Text(l10n.companionAddTileBtn),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedContextSummary(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
  ) {
    final l10n = _l10n(context);
    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.outlined,
      backgroundColor: surfaces.cardMuted,
      borderRadius: BorderRadius.circular(20),
      lipHeight: 2.0,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_confirmedPackageName != null) ...[
                InstalledAppIcon(
                  packageName: _confirmedPackageName!,
                  bridge: widget.hybridBridge,
                  size: 38,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _continuedWithoutAppContext
                          ? l10n.companionContinuingWithoutApp
                          : '${_confirmedAppLabel ?? _confirmedPackageName}${_confirmedVersionLabel != null ? ' · $_confirmedVersionLabel' : ''}',
                      style: m3e.typeScale.titleSmall.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_confirmedPackageName != null)
                      Text(
                        l10n.companionAppIdLine(_confirmedPackageName!),
                        style: m3e.typeScale.labelSmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _openManualAppPicker,
                child: Text(l10n.companionSwitchAppBtn),
              ),
            ],
          ),
          if (_usageAccessState != UsageAccessState.granted &&
              widget.invocation == null &&
              !_continuedWithoutAppContext) ...[
            const SizedBox(height: 6),
            Text(
              l10n.companionPermissionsReadLocally,
              style: m3e.typeScale.labelSmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionSelectorSection(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
  ) {
    final l10n = _l10n(context);
    if (_continuedWithoutAppContext) {
      return Row(
        children: [
          Expanded(
            child: Text(
              l10n.companionPickPermissionType,
              style: m3e.typography.emphasized.titleMedium.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: _openManualAppPicker,
            child: Text(l10n.companionPickAppBtn),
          ),
        ],
      );
    }

    if (_isLoadingPermissions) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: M3ELoadingIndicator(size: 32)),
      );
    }

    if (_permissionsResult != null && !_permissionsResult!.isOk) {
      return EnpriveMaterialCardSurface(
        variant: EnpriveCardVariant.outlined,
        backgroundColor: surfaces.card,
        borderRadius: BorderRadius.circular(20),
        lipHeight: 2.0,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.companionCouldNotReadPermsTitle,
              style: m3e.typeScale.titleSmall.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _permissionsResult!.errorMessage ??
                  l10n.companionCouldNotReadPermsBody,
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () =>
                  setState(() => _showUnsureGuide = !_showUnsureGuide),
              child: Text(l10n.companionUnsurePermBtn),
            ),
          ],
        ),
      );
    }

    final perms = _effectiveDeclaredPermissions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.companionWhichPermissionPrompt,
          style: m3e.typography.emphasized.titleMedium.copyWith(
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.companionPermissionsListDisclaimer,
          style: m3e.typeScale.bodySmall.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        if (perms.isEmpty)
          EnpriveMaterialCardSurface(
            variant: EnpriveCardVariant.outlined,
            backgroundColor: surfaces.cardMuted,
            borderRadius: BorderRadius.circular(18),
            lipHeight: 2.0,
            padding: const EdgeInsets.all(14),
            child: Text(
              l10n.companionNoSensitivePermsMsg,
              style: m3e.typeScale.bodyMedium.copyWith(color: scheme.onSurface),
            ),
          )
        else
          Column(
            children: perms.asMap().entries.map((entry) {
              final perm = entry.value;
              final isSelected =
                  _selectedPermission?.permission == perm.permission;
              final SemanticColorPair statusPair = switch (perm.grantStatus) {
                DeclaredPermissionGrantStatus.granted =>
                  semantics.reviewRecommended,
                DeclaredPermissionGrantStatus.denied => semantics.noConcern,
                DeclaredPermissionGrantStatus.manifestDeclaredOnly =>
                  semantics.inCloud,
                DeclaredPermissionGrantStatus.unavailable => semantics.onDevice,
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  key: Key('companion_perm_${perm.permission}'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() {
                    _selectedPermission = perm;
                    _selectedGuidedOption = null;
                    _showUnsureGuide = false;
                    _deniAnswer = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? statusPair.background : surfaces.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? statusPair.border
                            : surfaces.hairlineBorder,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                perm.title,
                                style: m3e.typeScale.titleSmall.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                perm.shortStatusLabel,
                                style: m3e.typeScale.labelMedium.copyWith(
                                  color: statusPair.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? LucideIcons.circleCheck
                              : LucideIcons.chevronRight,
                          size: 18,
                          color: isSelected
                              ? statusPair.foreground
                              : scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          key: const Key('companion_unsure_perm_btn'),
          onPressed: () => setState(() => _showUnsureGuide = !_showUnsureGuide),
          icon: const Icon(LucideIcons.circleHelp, size: 16),
          label: Text(l10n.companionUnsurePermBtn),
        ),
      ],
    );
  }

  Widget _buildGuidedUnsureSection(
    BuildContext context,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
  ) {
    final l10n = _l10n(context);
    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.outlined,
      backgroundColor: surfaces.card,
      borderRadius: BorderRadius.circular(20),
      lipHeight: 2.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.companionGuidedMatchTitle,
            style: m3e.typeScale.titleSmall.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.companionGuidedMatchSubtitle,
            style: m3e.typeScale.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CompanionPolicyResolver.guidedOptions.map((opt) {
              final selected =
                  _selectedGuidedOption?.categoryId == opt.categoryId;
              return ChoiceChip(
                key: Key('companion_guided_${opt.categoryId}'),
                label: Text(_localizeGuidedTitle(opt, l10n)),
                selected: selected,
                onSelected: (_) {
                  // Select matching declared app permission first if the confirmed app declares it.
                  final matchingDeclared = _effectiveDeclaredPermissions()
                      .where((p) => p.categoryId == opt.categoryId)
                      .cast<DeclaredSensitivePermission?>()
                      .firstWhere((_) => true, orElse: () => null);
                  setState(() {
                    if (matchingDeclared != null) {
                      _selectedPermission = matchingDeclared;
                      _selectedGuidedOption = null;
                    } else {
                      _selectedPermission = null;
                      _selectedGuidedOption = opt;
                    }
                    _deniAnswer = null;
                  });
                },
              );
            }).toList(),
          ),
          if (_selectedGuidedOption != null) ...[
            const SizedBox(height: 10),
            Text(
              _selectedGuidedOption!.androidPromptHint,
              style: m3e.typeScale.labelMedium.copyWith(
                color: semantics.onDevice.foreground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionExplanationSection(
    BuildContext context,
    CompanionPermissionExplanation explanation,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
  ) {
    final l10n = _l10n(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EnpriveMaterialCardSurface(
          variant: EnpriveCardVariant.elevated,
          backgroundColor: surfaces.card,
          borderRadius: BorderRadius.circular(24),
          lipHeight: 2.5,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      explanation.title,
                      style: m3e.typography.emphasized.titleLarge.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  EnpriveProvenanceChip(
                    source: explanation.hasVerifiedPolicy
                        ? explanation.matchedReceipt!.inferenceSource
                        : InferenceSource.offlineDeterministic,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSectionBlock(
                m3e,
                scheme,
                label: l10n.companionSection1Title,
                body: explanation.whatPermissionMeans,
              ),
              const SizedBox(height: 10),
              _buildSectionBlock(
                m3e,
                scheme,
                label: l10n.companionSection2Title,
                body:
                    '${explanation.whatAppDeclared}\n${explanation.grantStatusSummary}',
              ),
              const SizedBox(height: 10),
              _buildSectionBlock(
                m3e,
                scheme,
                label: l10n.companionSection3Title,
                headline: explanation.policyStatusHeadline,
                body: explanation.whatPolicySays,
              ),
              if (explanation.verbatimExcerpts.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final quote in explanation.verbatimExcerpts) ...[
                  EnpriveQuoteCard(
                    quote: quote,
                    statusLabel: l10n.quoteVerifiedLabel,
                  ),
                  const SizedBox(height: 8),
                ],
                if ((explanation.matchedReceipt?.snapshotDigest.isNotEmpty ??
                        false) ||
                    _formatSha256Footer(
                          explanation
                              .matchedReceipt
                              ?.sourceSnapshot
                              ?.sourceSha256Hash,
                        ) !=
                        null) ...[
                  InkWell(
                    key: const Key('companion_advanced_details_toggle'),
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(
                      () => _showCompanionAdvancedDetails =
                          !_showCompanionAdvancedDetails,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showCompanionAdvancedDetails
                                ? LucideIcons.chevronUp
                                : LucideIcons.chevronDown,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l10n.advancedDetailsTitle,
                              style: m3e.typography.emphasized.labelMedium
                                  .copyWith(color: scheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showCompanionAdvancedDetails) ...[
                    const SizedBox(height: 4),
                    if (explanation.matchedReceipt?.snapshotDigest.isNotEmpty ??
                        false)
                      Text(
                        '${l10n.snapshotDigestLabel} · ${explanation.matchedReceipt!.snapshotDigest}',
                        style: m3e.typeScale.labelSmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    if (_formatSha256Footer(
                          explanation
                              .matchedReceipt
                              ?.sourceSnapshot
                              ?.sourceSha256Hash,
                        ) !=
                        null)
                      Text(
                        _formatSha256Footer(
                          explanation
                              .matchedReceipt
                              ?.sourceSnapshot
                              ?.sourceSha256Hash,
                        )!,
                        style: m3e.typeScale.labelSmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ],
              ],
              if (explanation.hasVerifiedPolicy &&
                  explanation.matchedReceipt != null) ...[
                const SizedBox(height: 12),
                _buildCompanionReceiptPersistenceCard(
                  context,
                  explanation.matchedReceipt!,
                  m3e,
                  scheme,
                  surfaces,
                  semantics,
                ),
              ],
              if (_confirmedPackageName != null) ...[
                const SizedBox(height: 10),
                if (_isAttachingPolicy)
                  ReviewProgressCard(
                    subjectTitle: _confirmedAppLabel ?? _confirmedPackageName!,
                    isCloudCheck: _isCloudPolicyInFlight,
                    processStream: widget.coordinator.analysisEvents,
                    onCancel: _cancelPolicyAttach,
                    isCancelling: _isCancellingPolicy,
                  )
                else if (!explanation.hasVerifiedPolicy)
                  OutlinedButton.icon(
                    key: const Key('companion_attach_policy_btn'),
                    onPressed: _openAttachPolicyModal,
                    icon: const Icon(LucideIcons.fileText, size: 16),
                    label: Text(l10n.companionAddPolicyBtn),
                  )
                else
                  OutlinedButton.icon(
                    key: const Key('companion_update_policy_btn'),
                    onPressed: _openAttachPolicyModal,
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: Text(l10n.companionCheckUpdatedPolicyBtn),
                  ),
              ],
              const SizedBox(height: 10),
              _buildSectionBlock(
                m3e,
                scheme,
                label: l10n.companionSection4Title,
                body:
                    explanation.documentedFeatureReason ??
                    l10n.companionSection4Fallback,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.companionSection5Title,
                style: m3e.typeScale.labelLarge.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              for (final unknown in explanation.unknowns)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '• $unknown',
                    style: m3e.typeScale.bodySmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // 6. Conversational Questions with Deni
        EnpriveMaterialCardSurface(
          variant: EnpriveCardVariant.elevated,
          backgroundColor: surfaces.card,
          borderRadius: BorderRadius.circular(24),
          lipHeight: 2.5,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.companionSection6Title,
                style: m3e.typography.emphasized.titleMedium.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: explanation.suggestedQuestions.map((q) {
                  return ActionChip(
                    label: Text(q),
                    onPressed: _isAskingDeni ? null : () => _askDeni(q),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _featureContextController,
                decoration: InputDecoration(
                  labelText: l10n.companionFeatureFieldLabel,
                  hintText: l10n.companionFeatureFieldHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: l10n.companionQuestionFieldLabel,
                  hintText: l10n.companionQuestionFieldHint,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: _isAskingDeni ? null : _askDeni,
              ),
              const SizedBox(height: 12),
              if (_isAskingDeni)
                ReviewProgressCard(
                  subjectTitle: explanation.title,
                  isCloudCheck: _isAskingCloud,
                  processStream: widget.coordinator.analysisEvents,
                  onCancel: _cancelAskDeni,
                  isCancelling: _isCancellingAsk,
                )
              else
                EnpriveTactileButton(
                  key: const Key('companion_ask_deni_btn'),
                  label: l10n.btnAskDeni,
                  onPressed: () => _askDeni(_questionController.text),
                ),
              if (_deniAnswer != null) ...[
                const SizedBox(height: 14),
                Container(
                  key: const Key('companion_deni_answer_card'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surfaces.cardMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: surfaces.hairlineBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _deniAnswer!.question,
                              style: m3e.typeScale.labelLarge.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          EnpriveProvenanceChip(
                            source: _deniAnswer!.inferenceSource,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _deniAnswer!.answer,
                        style: m3e.typeScale.bodyMedium.copyWith(
                          color: scheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _deniAnswer!.unknownBoundary,
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanionReceiptPersistenceCard(
    BuildContext context,
    PolicyReviewReceipt receipt,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
  ) {
    final l10n = _l10n(context);
    final isSaved = _isSessionReceiptPersisted(receipt.id);

    return Container(
      key: const Key('companion_receipt_persistence_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSaved
            ? semantics.noConcern.background.withValues(alpha: 0.45)
            : surfaces.cardMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSaved ? semantics.noConcern.border : surfaces.hairlineBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSaved ? LucideIcons.bookmarkCheck : LucideIcons.bookmarkPlus,
                size: 18,
                color: isSaved
                    ? semantics.noConcern.foreground
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSaved
                          ? l10n.companionReceiptSavedTitle
                          : l10n.companionReceiptUnsavedTitle,
                      key: isSaved
                          ? const Key('companion_receipt_saved_badge')
                          : const Key('companion_receipt_unsaved_label'),
                      style: m3e.typeScale.labelLarge.copyWith(
                        color: isSaved
                            ? semantics.noConcern.foreground
                            : scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSaved
                          ? l10n.companionReceiptSavedBody
                          : (receipt.supersedesReceiptId != null
                                ? l10n.companionReceiptUpdatedUnsavedBody
                                : l10n.companionReceiptUnsavedBody),
                      style: m3e.typeScale.bodySmall.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_companionSaveError != null && !isSaved) ...[
            const SizedBox(height: 8),
            Text(
              _companionSaveError!,
              style: m3e.typeScale.bodySmall.copyWith(
                color: semantics.reviewRecommended.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (!isSaved && _canPersistSessionReceipts) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('companion_save_receipt_btn'),
              onPressed: _isSavingSessionReceipt
                  ? null
                  : () => unawaited(_saveCompanionSessionReceipt(receipt)),
              icon: _isSavingSessionReceipt
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.bookmarkPlus, size: 16),
              label: Text(l10n.companionSaveReceiptBtn),
            ),
          ],
        ],
      ),
    );
  }

  static String? _formatSha256Footer(String? hash) {
    final trimmed = hash?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final prefix = trimmed.length <= 12 ? trimmed : trimmed.substring(0, 12);
    return 'SHA-256 · $prefix';
  }

  Widget _buildSectionBlock(
    M3EThemeData m3e,
    M3EColorScheme scheme, {
    required String label,
    String? headline,
    required String body,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: m3e.typeScale.labelLarge.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (headline != null && headline.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            headline,
            style: m3e.typeScale.titleSmall.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 3),
        Text(
          body,
          style: m3e.typeScale.bodySmall.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
