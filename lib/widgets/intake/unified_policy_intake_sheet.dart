import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/intake/policy_intake_models.dart';
import '../../domain/review/app_policy_association.dart'
    show AppPolicyAssociationState;
import '../../domain/review/review_models.dart' show PolicySourceType;
import '../../l10n/app_localizations.dart';
import '../../services/intake/policy_intake_coordinator.dart';
import '../../services/network/policy_url_retriever.dart'
    show PolicyUrlCancellationToken;
import '../../services/platform/companion_bridge.dart';
import '../enprive_tactile_button.dart';
import '../m3e/enprive_m3e_components.dart';

/// Supported acquisition modes inside [UnifiedPolicyIntakeSheet].
enum PolicyIntakeMode { paste, url, document }

/// Optional installed-app selection hook used by policy-first flows.
typedef InstalledAppSelector = Future<SelectedAppReference?> Function(
  BuildContext context,
);

/// Optional Play Store navigation hook used by app-associated URL mode.
typedef PlayStoreListingOpener = Future<ExternalAppNavigationResult> Function(
  String packageName,
);

/// Explicit configuration for [UnifiedPolicyIntakeSheet].
class PolicyIntakeSheetConfig {
  final String? titleOverride;
  final PolicyIntakeMode? initialMode;
  final SelectedAppReference? initialSelectedApp;
  final PolicyLocator? initialLocator;
  final PolicyIntakeFailure? initialFailure;
  final PolicyIntakeCoordinator coordinator;
  final InstalledAppSelector? onSelectInstalledApp;
  final PlayStoreListingOpener? onOpenPlayStoreListing;
  final CompanionBridge? companionBridge;

  const PolicyIntakeSheetConfig({
    this.titleOverride,
    this.initialMode,
    this.initialSelectedApp,
    this.initialLocator,
    this.initialFailure,
    required this.coordinator,
    this.onSelectInstalledApp,
    this.onOpenPlayStoreListing,
    this.companionBridge,
  });

  bool get isAppContextLocked =>
      (initialSelectedApp ?? initialFailure?.selectedApp)?.isLocked == true;

  bool get canSelectInstalledApp =>
      !isAppContextLocked && onSelectInstalledApp != null;

  bool get canOpenPlayStoreListing =>
      onOpenPlayStoreListing != null || companionBridge != null;
}

/// Reusable Material 3 Expressive policy intake bottom sheet supporting
/// pasted/shared/selected text, public HTTP(S) URLs, and local PDF/TXT/DOCX
/// documents via [PolicyIntakeCoordinator].
class UnifiedPolicyIntakeSheet extends StatefulWidget {
  final PolicyIntakeSheetConfig config;

  const UnifiedPolicyIntakeSheet({super.key, required this.config});

  /// Presents [UnifiedPolicyIntakeSheet] and returns a validated
  /// [PolicyIntakeSuccess], or `null` if dismissed without completing intake.
  static Future<PolicyIntakeSuccess?> show(
    BuildContext context, {
    required PolicyIntakeSheetConfig config,
  }) {
    return showModalBottomSheet<PolicyIntakeSuccess>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (_) => UnifiedPolicyIntakeSheet(config: config),
    );
  }

  @override
  State<UnifiedPolicyIntakeSheet> createState() =>
      _UnifiedPolicyIntakeSheetState();
}

class _UnifiedPolicyIntakeSheetState extends State<UnifiedPolicyIntakeSheet> {
  late final PolicyIntakeCoordinator _coordinator;
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  late final TextEditingController _urlController;

  late PolicyIntakeMode _mode;
  late PolicySourceType _textSourceType;
  String? _textSourceAction;
  String? _urlSourceAction;

  SelectedAppReference? _selectedApp;
  PolicyIntakeFailure? _activeFailure;
  PolicyIntakeSuccess? _pendingAssociationSuccess;
  String? _playStoreNotice;

  bool _isBusy = false;
  bool _isSelectingApp = false;
  bool _isOpeningPlayStore = false;
  bool _hasPopped = false;
  int _activeOperationId = 0;
  PolicyUrlCancellationToken? _activeUrlCancelToken;

  @override
  void initState() {
    super.initState();
    _coordinator = widget.config.coordinator;

    final effectiveLocator =
        widget.config.initialLocator ?? widget.config.initialFailure?.locator;
    _mode = widget.config.initialMode ?? _inferMode(effectiveLocator);
    _selectedApp =
        widget.config.initialSelectedApp ??
        widget.config.initialFailure?.selectedApp;
    _activeFailure = widget.config.initialFailure;

    var initialText = '';
    var initialUrl = '';
    final initialTitle = effectiveLocator?.userSubjectTitle ?? '';
    _textSourceType = PolicySourceType.pastedText;

    switch (effectiveLocator) {
      case TextPolicyLocator(
        :final rawText,
        :final sourceType,
        :final sourceAction,
      ):
        initialText = rawText;
        _textSourceType = sourceType;
        _textSourceAction = sourceAction;
      case UrlPolicyLocator(:final rawUrl, :final sourceAction):
        initialUrl = rawUrl;
        _urlSourceAction = sourceAction;
      case DocumentPolicyLocator():
      case SampleFixturePolicyLocator():
      case null:
        break;
    }

    _titleController = TextEditingController(text: initialTitle);
    _textController = TextEditingController(text: initialText);
    _urlController = TextEditingController(text: initialUrl);
  }

  @override
  void dispose() {
    _hasPopped = true;
    _cancelInFlightOperation();
    _titleController.dispose();
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _cancelInFlightOperation() {
    _activeOperationId++;
    final token = _activeUrlCancelToken;
    _activeUrlCancelToken = null;
    token?.cancel();
  }

  void _popOnce(PolicyIntakeSuccess? result) {
    if (_hasPopped || !mounted) return;
    _hasPopped = true;
    if (result == null) {
      _cancelInFlightOperation();
    }
    Navigator.of(context).pop<PolicyIntakeSuccess?>(result);
  }

  static PolicyIntakeMode _inferMode(PolicyLocator? locator) {
    return switch (locator) {
      UrlPolicyLocator() => PolicyIntakeMode.url,
      DocumentPolicyLocator() => PolicyIntakeMode.document,
      TextPolicyLocator() ||
      SampleFixturePolicyLocator() ||
      null => PolicyIntakeMode.paste,
    };
  }

  bool get _isExpiredIncomingDocumentFailure {
    final failure = _activeFailure;
    if (failure == null) return false;
    final locator = failure.locator;
    return locator is DocumentPolicyLocator &&
        locator.isPreExtractedIncomingShare &&
        !failure.canRetrySameLocator;
  }

  String? get _effectiveSubjectTitle {
    if (widget.config.isAppContextLocked) {
      return _selectedApp?.appName;
    }
    final trimmed = _titleController.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _selectMode(PolicyIntakeMode nextMode) {
    if (_isBusy || _isSelectingApp || _hasPopped || _mode == nextMode) return;
    setState(() {
      _mode = nextMode;
      _activeFailure = null;
      _pendingAssociationSuccess = null;
      _playStoreNotice = null;
    });
  }

  void _dismissSheet() {
    _popOnce(null);
  }

  void _cancelActiveUrlFetch() {
    if (!_isBusy || _activeUrlCancelToken == null || _hasPopped) return;
    _cancelInFlightOperation();
    setState(() {
      _isBusy = false;
    });
  }

  Future<void> _pickInstalledApp() async {
    if (_isBusy ||
        _isSelectingApp ||
        _hasPopped ||
        widget.config.isAppContextLocked) {
      return;
    }
    final customSelector = widget.config.onSelectInstalledApp;
    if (customSelector == null) return;

    setState(() {
      _isSelectingApp = true;
    });

    SelectedAppReference? chosen;
    try {
      chosen = await customSelector(context);
    } finally {
      if (!mounted || _hasPopped) {
        _isSelectingApp = false;
      } else {
        setState(() {
          _isSelectingApp = false;
          if (chosen != null && !_isBusy) {
            _selectedApp = chosen;
            _pendingAssociationSuccess = null;
            _activeFailure = null;
            _playStoreNotice = null;
          }
        });
      }
    }
  }

  void _removeSelectedApp() {
    if (_isBusy ||
        _isSelectingApp ||
        _hasPopped ||
        widget.config.isAppContextLocked) {
      return;
    }
    setState(() {
      _selectedApp = null;
      _pendingAssociationSuccess = null;
      _playStoreNotice = null;
    });
  }

  Future<void> _openPlayStoreListing(AppLocalizations l10n) async {
    final pkg = _selectedApp?.packageName;
    if (_isBusy ||
        _isSelectingApp ||
        _isOpeningPlayStore ||
        _hasPopped ||
        pkg == null ||
        pkg.isEmpty) {
      return;
    }

    final opener =
        widget.config.onOpenPlayStoreListing ??
        widget.config.companionBridge?.openPlayStoreListing;
    if (opener == null) return;

    setState(() {
      _isOpeningPlayStore = true;
      _playStoreNotice = null;
    });

    ExternalAppNavigationResult result;
    try {
      result = await opener(pkg);
    } catch (_) {
      result = ExternalAppNavigationResult(
        status: ExternalAppNavigationStatus.failed,
        packageName: pkg,
      );
    }

    if (!mounted || _hasPopped) return;
    setState(() {
      _isOpeningPlayStore = false;
      if (!result.isSuccess) {
        final tip = result.guidanceTip?.trim();
        _playStoreNotice = (tip != null && tip.isNotEmpty)
            ? tip
            : l10n.intakePlayStoreUnavailable;
      }
    });
  }

  Future<void> _handleSubmit(AppLocalizations l10n) async {
    if (_isBusy || _isSelectingApp || _hasPopped) return;
    switch (_mode) {
      case PolicyIntakeMode.paste:
        await _submitText(l10n);
      case PolicyIntakeMode.url:
        await _submitUrl();
      case PolicyIntakeMode.document:
        await _submitDocument();
    }
  }

  Future<void> _submitText(AppLocalizations l10n) async {
    final opId = ++_activeOperationId;
    setState(() {
      _isBusy = true;
      _activeFailure = null;
      _pendingAssociationSuccess = null;
      _playStoreNotice = null;
    });

    final locator = TextPolicyLocator(
      rawText: _textController.text,
      sourceType: _textSourceType,
      userSubjectTitle: _effectiveSubjectTitle,
      sourceAction: _textSourceAction,
    );
    final outcome = _coordinator.captureText(
      locator: locator,
      selectedApp: _selectedApp,
      defaultSubjectTitle: _defaultSubjectTitleForText(l10n),
    );

    if (!mounted || _hasPopped || opId != _activeOperationId) return;
    _handleCoordinatorOutcome(outcome);
  }

  Future<void> _submitUrl() async {
    final opId = ++_activeOperationId;
    final token = PolicyUrlCancellationToken();
    _activeUrlCancelToken = token;

    setState(() {
      _isBusy = true;
      _activeFailure = null;
      _pendingAssociationSuccess = null;
      _playStoreNotice = null;
    });

    final locator = UrlPolicyLocator(
      rawUrl: _urlController.text,
      userSubjectTitle: _effectiveSubjectTitle,
      sourceAction: _urlSourceAction,
    );
    final outcome = await _coordinator.captureFromUrl(
      locator: locator,
      selectedApp: _selectedApp,
      cancelToken: token,
    );

    if (identical(_activeUrlCancelToken, token)) {
      _activeUrlCancelToken = null;
    }
    if (!mounted ||
        _hasPopped ||
        opId != _activeOperationId ||
        token.isCancelled) {
      return;
    }
    _handleCoordinatorOutcome(outcome);
  }

  Future<void> _submitDocument() async {
    final opId = ++_activeOperationId;
    setState(() {
      _isBusy = true;
      _activeFailure = null;
      _pendingAssociationSuccess = null;
      _playStoreNotice = null;
    });

    final outcome = await _coordinator.captureFromDocumentPicker(
      selectedApp: _selectedApp,
      userSubjectTitle: _effectiveSubjectTitle,
    );

    if (!mounted || _hasPopped || opId != _activeOperationId) return;

    // Dismissing the system document picker must return calmly to idle without
    // displaying a false failure banner.
    if (outcome is PolicyIntakeFailure && outcome.isCancelled) {
      setState(() {
        _isBusy = false;
      });
      return;
    }

    _handleCoordinatorOutcome(outcome);
  }

  Future<void> _inspectPendingWithoutApp(AppLocalizations l10n) async {
    final pending = _pendingAssociationSuccess;
    if (_isBusy ||
        _isSelectingApp ||
        _hasPopped ||
        widget.config.isAppContextLocked ||
        pending == null) {
      return;
    }

    switch (pending.locator) {
      case final TextPolicyLocator textLocator:
        final outcome = _coordinator.captureText(
          locator: textLocator,
          selectedApp: null,
          defaultSubjectTitle: _defaultSubjectTitleForText(l10n),
        );
        setState(() {
          _selectedApp = null;
          _pendingAssociationSuccess = null;
          _playStoreNotice = null;
        });
        _handleCoordinatorOutcome(outcome);
      case final UrlPolicyLocator urlLocator:
        final opId = ++_activeOperationId;
        final token = PolicyUrlCancellationToken();
        _activeUrlCancelToken = token;
        setState(() {
          _selectedApp = null;
          _pendingAssociationSuccess = null;
          _playStoreNotice = null;
          _isBusy = true;
          _activeFailure = null;
        });
        final outcome = await _coordinator.captureFromUrl(
          locator: urlLocator,
          selectedApp: null,
          cancelToken: token,
        );
        if (identical(_activeUrlCancelToken, token)) {
          _activeUrlCancelToken = null;
        }
        if (!mounted ||
            _hasPopped ||
            opId != _activeOperationId ||
            token.isCancelled) {
          return;
        }
        _handleCoordinatorOutcome(outcome);
      case DocumentPolicyLocator():
      case SampleFixturePolicyLocator():
        break;
    }
  }

  void _handleCoordinatorOutcome(PolicyIntakeOutcome outcome) {
    if (!mounted || _hasPopped) return;
    switch (outcome) {
      case final PolicyIntakeSuccess success:
        final assocState = success.associationReport.state;
        final needsNotice =
            assocState == AppPolicyAssociationState.unmatched ||
            assocState == AppPolicyAssociationState.ambiguousIdentity;
        if (needsNotice) {
          setState(() {
            _isBusy = false;
            _activeFailure = null;
            _pendingAssociationSuccess = success;
          });
          return;
        }
        _popOnce(success);
      case final PolicyIntakeFailure failure:
        setState(() {
          _isBusy = false;
          _activeFailure = failure;
          _pendingAssociationSuccess = null;
        });
    }
  }

  String _defaultSubjectTitleForText(AppLocalizations l10n) {
    if (_textSourceType == PolicySourceType.selectedText) {
      return l10n.selectedExcerptTitle;
    }
    return l10n.defaultSubjectTitle;
  }

  String _sheetTitle(AppLocalizations l10n) {
    final override = widget.config.titleOverride?.trim();
    if (override != null && override.isNotEmpty) return override;
    if (widget.config.isAppContextLocked) {
      return l10n.addAppPrivacyPolicyBtn;
    }
    return l10n.btnPasteTerms;
  }

  String _primaryActionLabel(AppLocalizations l10n) {
    if (_isBusy) return l10n.intakeWorkingLabel;
    return switch (_mode) {
      PolicyIntakeMode.paste => l10n.intakeActionInspectText,
      PolicyIntakeMode.url => l10n.intakeActionFetchUrl,
      PolicyIntakeMode.document =>
        _isExpiredIncomingDocumentFailure
            ? l10n.intakeActionReplaceDocument
            : l10n.intakeActionChooseDocument,
    };
  }

  String _modeLabel(PolicyIntakeMode mode, AppLocalizations l10n) {
    return switch (mode) {
      PolicyIntakeMode.paste => l10n.modePasteText,
      PolicyIntakeMode.url => l10n.modePolicyLink,
      PolicyIntakeMode.document => l10n.intakeModeDocument,
    };
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (sheetContext) {
          final l10n =
              AppLocalizations.of(sheetContext) ??
              lookupAppLocalizations(const Locale('en'));
          final m3e = EnpriveM3ETheme.of(sheetContext);
          final scheme = m3e.colorScheme;
          final surfaces = sheetContext.enpriveSurfaces;
          final semantics = sheetContext.enpriveSemantics;
          final typeExt = sheetContext.enpriveType;
          final isRtl = Directionality.of(sheetContext) == TextDirection.rtl;
          final viewInsets = MediaQuery.viewInsetsOf(sheetContext);
          final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.92;
          final textScale = MediaQuery.textScalerOf(sheetContext).scale(1.0);

          final interactionLocked = _isBusy || _isSelectingApp;

          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                _hasPopped = true;
                if (result == null) {
                  _cancelInFlightOperation();
                }
              }
            },
            child: SafeArea(
              top: true,
              bottom: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 720,
                    maxHeight: maxHeight,
                  ),
                  child: Material(
                    color: surfaces.sheetSurface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(EnpriveRadii.sheet),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(sheetContext, l10n, m3e, scheme, surfaces),
                        Divider(height: 1, color: surfaces.hairlineBorder),
                        Flexible(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              16,
                              20,
                              24 + viewInsets.bottom,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.config.isAppContextLocked &&
                                    _selectedApp != null) ...[
                                  _buildLockedAppCard(
                                    _selectedApp!,
                                    l10n,
                                    m3e,
                                    scheme,
                                    surfaces,
                                    isRtl,
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                _buildModeSelector(
                                  l10n: l10n,
                                  textScale: textScale,
                                ),
                                const SizedBox(height: 14),
                                if (!widget.config.isAppContextLocked) ...[
                                  TextField(
                                    key: const Key('intake_title_field'),
                                    controller: _titleController,
                                    enabled: !interactionLocked,
                                    onChanged: (_) {
                                      if (_activeFailure != null ||
                                          _pendingAssociationSuccess != null) {
                                        setState(() {
                                          _activeFailure = null;
                                          _pendingAssociationSuccess = null;
                                        });
                                      }
                                    },
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
                                  if (widget.config.canSelectInstalledApp ||
                                      _selectedApp != null) ...[
                                    _buildOptionalAppSection(
                                      l10n,
                                      m3e,
                                      scheme,
                                      surfaces,
                                      semantics,
                                      isRtl,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ],
                                _buildActiveModeBody(
                                  l10n: l10n,
                                  m3e: m3e,
                                  scheme: scheme,
                                  surfaces: surfaces,
                                  typeExt: typeExt,
                                  isRtl: isRtl,
                                ),
                                if (_activeFailure != null) ...[
                                  const SizedBox(height: 12),
                                  _buildInlineFailureCard(
                                    failure: _activeFailure!,
                                    l10n: l10n,
                                    m3e: m3e,
                                    semantics: semantics,
                                    scheme: scheme,
                                  ),
                                ],
                                if (_pendingAssociationSuccess != null) ...[
                                  const SizedBox(height: 12),
                                  _buildAssociationWarningCard(
                                    success: _pendingAssociationSuccess!,
                                    l10n: l10n,
                                    m3e: m3e,
                                    semantics: semantics,
                                    scheme: scheme,
                                  ),
                                ],
                                const SizedBox(height: 18),
                                EnpriveTactileButton(
                                  key: const Key('intake_primary_submit_btn'),
                                  label: _primaryActionLabel(l10n),
                                  onPressed: interactionLocked
                                      ? null
                                      : () => _handleSubmit(l10n),
                                ),
                                if (_isBusy &&
                                    _mode == PolicyIntakeMode.url &&
                                    _activeUrlCancelToken != null) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      key: const Key('intake_cancel_fetch_btn'),
                                      onPressed: _cancelActiveUrlFetch,
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(
                                          64,
                                          EnpriveSpacing.minTouchTarget,
                                        ),
                                      ),
                                      child: Text(l10n.intakeCancelFetch),
                                    ),
                                  ),
                                ],
                              ],
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
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: surfaces.strongBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _sheetTitle(l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: m3e.typography.emphasized.titleLarge.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                key: const Key('intake_close_btn'),
                tooltip: l10n.tooltipClose,
                constraints: const BoxConstraints(
                  minWidth: EnpriveSpacing.minTouchTarget,
                  minHeight: EnpriveSpacing.minTouchTarget,
                ),
                onPressed: _dismissSheet,
                icon: Icon(
                  LucideIcons.x,
                  color: scheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockedAppCard(
    SelectedAppReference app,
    AppLocalizations l10n,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    bool isRtl,
  ) {
    return EnpriveMaterialCardSurface(
      key: const Key('intake_locked_app_header'),
      variant: EnpriveCardVariant.outlined,
      backgroundColor: surfaces.cardMuted,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.intakeLockedAppContextLabel,
            style: m3e.typeScale.labelSmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            app.appName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: m3e.typography.emphasized.titleSmall.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              app.packageName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector({
    required AppLocalizations l10n,
    required double textScale,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useChipFallback = constraints.maxWidth < 340 || textScale > 1.35;
        if (useChipFallback) {
          return Semantics(
            label: l10n.intakeModeSelectorSemanticLabel,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mode in PolicyIntakeMode.values)
                  EnpriveFilterChip(
                    key: ValueKey<String>('intake_mode_chip_${mode.name}'),
                    label: _modeLabel(mode, l10n),
                    selected: _mode == mode,
                    onPressed: (_isBusy || _isSelectingApp)
                        ? null
                        : () => _selectMode(mode),
                  ),
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: M3ESegmentedButton<PolicyIntakeMode>(
            key: const Key('intake_mode_segmented'),
            enabled: !_isBusy && !_isSelectingApp,
            showSelectedIcon: false,
            semanticLabel: l10n.intakeModeSelectorSemanticLabel,
            segments: [
              M3ESegment<PolicyIntakeMode>(
                value: PolicyIntakeMode.paste,
                icon: const Icon(LucideIcons.fileText, size: 16),
                label: l10n.modePasteText,
              ),
              M3ESegment<PolicyIntakeMode>(
                value: PolicyIntakeMode.url,
                icon: const Icon(LucideIcons.link2, size: 16),
                label: l10n.modePolicyLink,
              ),
              M3ESegment<PolicyIntakeMode>(
                value: PolicyIntakeMode.document,
                icon: const Icon(LucideIcons.fileUp, size: 16),
                label: l10n.intakeModeDocument,
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              if (_isBusy || _isSelectingApp || selection.isEmpty) return;
              _selectMode(selection.first);
            },
          ),
        );
      },
    );
  }

  Widget _buildOptionalAppSection(
    AppLocalizations l10n,
    M3EThemeData m3e,
    M3EColorScheme scheme,
    EnpriveSurfaceTokens surfaces,
    EnpriveSemanticColors semantics,
    bool isRtl,
  ) {
    final selected = _selectedApp;
    if (selected == null) {
      return EnpriveMaterialCardSurface(
        key: const Key('intake_select_app_btn'),
        variant: EnpriveCardVariant.outlined,
        backgroundColor: surfaces.card,
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        semanticLabel:
            '${l10n.intakeCompareWithAppPrompt}, ${l10n.intakeCompareWithAppHint}',
        onPressed: (_isBusy || _isSelectingApp) ? null : _pickInstalledApp,
        // Parent card provides the complete curated label; exclude children to
        // prevent duplicate TalkBack announcements.
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: EnpriveSpacing.minTouchTarget,
            ),
            child: Row(
              children: [
                Icon(LucideIcons.smartphone, size: 18, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.intakeCompareWithAppPrompt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: m3e.typography.emphasized.labelLarge.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.intakeCompareWithAppHint,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isRtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return EnpriveMaterialCardSurface(
      key: const Key('intake_selected_app_card'),
      variant: EnpriveCardVariant.outlined,
      backgroundColor: surfaces.card,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.smartphone,
                size: 18,
                color: semantics.onDevice.foreground,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.appName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: m3e.typography.emphasized.titleSmall.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        selected.packageName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isRtl ? TextAlign.right : TextAlign.left,
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (widget.config.canSelectInstalledApp)
                TextButton(
                  key: const Key('intake_change_app_btn'),
                  onPressed: (_isBusy || _isSelectingApp)
                      ? null
                      : _pickInstalledApp,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      EnpriveSpacing.minTouchTarget,
                      EnpriveSpacing.minTouchTarget,
                    ),
                  ),
                  child: Text(l10n.intakeCompareWithAppChange),
                ),
              TextButton(
                key: const Key('intake_remove_app_btn'),
                onPressed: (_isBusy || _isSelectingApp)
                    ? null
                    : _removeSelectedApp,
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    EnpriveSpacing.minTouchTarget,
                    EnpriveSpacing.minTouchTarget,
                  ),
                ),
                child: Text(l10n.intakeCompareWithAppRemove),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveModeBody({
    required AppLocalizations l10n,
    required M3EThemeData m3e,
    required M3EColorScheme scheme,
    required EnpriveSurfaceTokens surfaces,
    required EnpriveTypographyExtension typeExt,
    required bool isRtl,
  }) {
    switch (_mode) {
      case PolicyIntakeMode.paste:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('intake_paste_field'),
              controller: _textController,
              enabled: !_isBusy && !_isSelectingApp,
              maxLines: 6,
              minLines: 4,
              onChanged: (_) {
                if (_activeFailure != null ||
                    _pendingAssociationSuccess != null) {
                  setState(() {
                    _activeFailure = null;
                    _pendingAssociationSuccess = null;
                  });
                }
              },
              style: typeExt.policyQuotation.copyWith(color: scheme.onSurface),
              decoration: InputDecoration(
                hintText: l10n.hintPastePolicy,
                filled: true,
                fillColor: surfaces.quoteSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: surfaces.hairlineBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: surfaces.hairlineBorder),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.intakePasteLocalNote,
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        );

      case PolicyIntakeMode.url:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('intake_url_field'),
              controller: _urlController,
              enabled: !_isBusy && !_isSelectingApp,
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              onChanged: (_) {
                if (_activeFailure != null ||
                    _pendingAssociationSuccess != null) {
                  setState(() {
                    _activeFailure = null;
                    _pendingAssociationSuccess = null;
                  });
                }
              },
              style: m3e.typeScale.bodyMedium.copyWith(color: scheme.onSurface),
              decoration: InputDecoration(
                hintText: l10n.intakeUrlHint,
                hintTextDirection: TextDirection.ltr,
                prefixIcon: Icon(
                  LucideIcons.link2,
                  size: 18,
                  color: scheme.primary,
                ),
                filled: true,
                fillColor: surfaces.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: surfaces.hairlineBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: surfaces.hairlineBorder),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.intakeUrlDisclosure,
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (widget.config.canOpenPlayStoreListing &&
                _selectedApp != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('intake_play_store_btn'),
                  onPressed: (_isBusy || _isSelectingApp || _isOpeningPlayStore)
                      ? null
                      : () => _openPlayStoreListing(l10n),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(64, EnpriveSpacing.minTouchTarget),
                  ),
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: Text(
                    l10n.intakeFindPolicyOnPlayStore,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _playStoreNotice ?? l10n.intakePlayStoreHelperNote,
                style: m3e.typeScale.bodySmall.copyWith(
                  color: _playStoreNotice != null
                      ? scheme.error
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        );

      case PolicyIntakeMode.document:
        return EnpriveMaterialCardSurface(
          key: const Key('intake_document_info_card'),
          variant: EnpriveCardVariant.outlined,
          backgroundColor: surfaces.card,
          borderRadius: BorderRadius.circular(18),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.intakeDocumentCardTitle,
                style: m3e.typography.emphasized.titleSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.intakeDocumentCardBody,
                style: m3e.typeScale.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildInlineFailureCard({
    required PolicyIntakeFailure failure,
    required AppLocalizations l10n,
    required M3EThemeData m3e,
    required EnpriveSemanticColors semantics,
    required M3EColorScheme scheme,
  }) {
    final pair = semantics.highConcern;
    final showExpiredDocNotice = _isExpiredIncomingDocumentFailure;

    return Container(
      key: const Key('intake_error_banner'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pair.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.circleAlert, size: 18, color: pair.foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      failure.userMessage,
                      style: m3e.typeScale.bodyMedium.copyWith(
                        color: pair.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (showExpiredDocNotice) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.intakeExpiredDocumentShareNotice,
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ] else if (failure.recoveryHint.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        failure.recoveryHint,
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (_mode == PolicyIntakeMode.url && failure.canRetrySameLocator)
                TextButton(
                  key: const Key('intake_recovery_retry_btn'),
                  onPressed: (_isBusy || _isSelectingApp)
                      ? null
                      : () => _handleSubmit(l10n),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      EnpriveSpacing.minTouchTarget,
                      EnpriveSpacing.minTouchTarget,
                    ),
                  ),
                  child: Text(l10n.intakeRecoveryRetryUrl),
                ),
              if (_mode != PolicyIntakeMode.paste)
                TextButton(
                  key: const Key('intake_recovery_paste_btn'),
                  onPressed: (_isBusy || _isSelectingApp)
                      ? null
                      : () => _selectMode(PolicyIntakeMode.paste),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      EnpriveSpacing.minTouchTarget,
                      EnpriveSpacing.minTouchTarget,
                    ),
                  ),
                  child: Text(l10n.intakeRecoverySwitchPaste),
                ),
              if (_mode != PolicyIntakeMode.document)
                TextButton(
                  key: const Key('intake_recovery_doc_btn'),
                  onPressed: (_isBusy || _isSelectingApp)
                      ? null
                      : () => _selectMode(PolicyIntakeMode.document),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      EnpriveSpacing.minTouchTarget,
                      EnpriveSpacing.minTouchTarget,
                    ),
                  ),
                  child: Text(l10n.intakeRecoverySwitchDocument),
                ),
              if (_mode == PolicyIntakeMode.paste)
                TextButton(
                  key: const Key('intake_recovery_url_btn'),
                  onPressed: (_isBusy || _isSelectingApp)
                      ? null
                      : () => _selectMode(PolicyIntakeMode.url),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      EnpriveSpacing.minTouchTarget,
                      EnpriveSpacing.minTouchTarget,
                    ),
                  ),
                  child: Text(l10n.modePolicyLink),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssociationWarningCard({
    required PolicyIntakeSuccess success,
    required AppLocalizations l10n,
    required M3EThemeData m3e,
    required EnpriveSemanticColors semantics,
    required M3EColorScheme scheme,
  }) {
    final pair = semantics.reviewRecommended;
    final report = success.associationReport;
    final supportsWithoutApp =
        !widget.config.isAppContextLocked &&
        (success.locator is TextPolicyLocator ||
            success.locator is UrlPolicyLocator);

    return Container(
      key: const Key('intake_association_warning_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pair.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.triangleAlert, size: 18, color: pair.foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.intakeAssociationWarningTitle,
                      style: m3e.typography.emphasized.titleSmall.copyWith(
                        color: pair.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.explanation,
                      style: m3e.typeScale.bodySmall.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.ownershipLimitationNotice,
                      style: m3e.typeScale.bodySmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              FilledButton(
                key: const Key('intake_association_continue_btn'),
                onPressed: (_isBusy || _isSelectingApp)
                    ? null
                    : () => _popOnce(success),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(
                    EnpriveSpacing.minTouchTarget,
                    EnpriveSpacing.minTouchTarget,
                  ),
                ),
                child: Text(l10n.intakeAssociationContinueAnyway),
              ),
              if (widget.config.canSelectInstalledApp)
                OutlinedButton(
                  key: const Key('intake_association_change_app_btn'),
                  onPressed: (_isBusy || _isSelectingApp)
                      ? null
                      : _pickInstalledApp,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(
                      EnpriveSpacing.minTouchTarget,
                      EnpriveSpacing.minTouchTarget,
                    ),
                  ),
                  child: Text(l10n.intakeAssociationChangeApp),
                ),
              if (supportsWithoutApp)
                TextButton(
                  key: const Key('intake_association_without_app_btn'),
                  onPressed: (_isBusy || _isSelectingApp)
                      ? null
                      : () => _inspectPendingWithoutApp(l10n),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      EnpriveSpacing.minTouchTarget,
                      EnpriveSpacing.minTouchTarget,
                    ),
                  ),
                  child: Text(l10n.intakeAssociationInspectWithoutApp),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
