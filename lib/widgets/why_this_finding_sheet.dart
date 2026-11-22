import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/privacy/pii_redactor.dart';
import '../domain/review/review_coordinator.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'analysis_process_trace.dart';
import 'cloud_consent_sheet.dart';
import 'deni_animated_mascot.dart';
import 'enprive_duotone_icon.dart';
import 'enprive_provenance_chip.dart';
import 'm3e/enprive_m3e_components.dart';

/// Material 3 Expressive Evidence Work Card + Docked "Ask Deni" Sheet:
/// - M3E wavy progress indicator in top bar
/// - Unified `M3ECard` evidence work card with collapsible `SourceSerif4` quote stage
/// - Interactive preset question pills + Deni Compact LOD (`56dp`) docked bar
class WhyThisFindingSheet extends StatefulWidget {
  final VerifiedFinding finding;
  final String snapshotText;
  final String snapshotDigest;
  final ReviewCoordinator coordinator;
  final bool cloudConsentGrantedForSession;

  const WhyThisFindingSheet({
    super.key,
    required this.finding,
    required this.snapshotText,
    required this.snapshotDigest,
    required this.coordinator,
    this.cloudConsentGrantedForSession = false,
  });

  static Future<void> show(
    BuildContext context, {
    required VerifiedFinding finding,
    required String snapshotText,
    required String snapshotDigest,
    required ReviewCoordinator coordinator,
    bool cloudConsentGrantedForSession = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.55,
        maxChildSize: 0.94,
        builder: (context, _) => WhyThisFindingSheet(
          finding: finding,
          snapshotText: snapshotText,
          snapshotDigest: snapshotDigest,
          coordinator: coordinator,
          cloudConsentGrantedForSession: cloudConsentGrantedForSession,
        ),
      ),
    );
  }

  @override
  State<WhyThisFindingSheet> createState() => _WhyThisFindingSheetState();
}

class _WhyThisFindingSheetState extends State<WhyThisFindingSheet> {
  // Before the first answer Deni raises a hand: "I can explain this".
  DeniPose _deniPose = DeniPose.raiseHand;
  bool _isAskingDeni = false;
  bool _isConsentSheetOpen = false;
  bool _isQuoteCollapsed = false;
  DeniExplanation? _deniExplanation;
  int _selectedQuestionIndex = 0;
  int _deniSequence = 0;
  String? _activeDeniRequestId;

  String _intentHintForIndex(int questionIndex) {
    return switch (questionIndex) {
      1 => 'opt_out',
      2 => 'unknown',
      _ => 'meaning',
    };
  }

  void _cancelAskDeni() {
    if (!_isAskingDeni) return;
    final reqId = _activeDeniRequestId;
    _deniSequence++;
    setState(() {
      _isAskingDeni = false;
      _activeDeniRequestId = null;
      _deniPose = _deniExplanation == null
          ? DeniPose.raiseHand
          : DeniPose.explaining;
    });
    if (reqId != null) {
      unawaited(widget.coordinator.bridge.cancelAnalysis(requestId: reqId));
    } else {
      unawaited(widget.coordinator.bridge.cancelAnalysis());
    }
  }

  Future<void> _askDeni(
    int questionIndex,
    String question,
    String languageCode,
  ) async {
    if (_isAskingDeni || _isConsentSheetOpen) return;
    final hint = _intentHintForIndex(questionIndex);
    final seq = ++_deniSequence;
    var reqId = 'deni_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _selectedQuestionIndex = questionIndex;
      _isAskingDeni = true;
      _activeDeniRequestId = reqId;
      _isQuoteCollapsed = true;
      _deniPose = DeniPose.thinking;
    });

    final DeniExplanation explanation;
    try {
      explanation = await widget.coordinator.askDeniAboutFinding(
        requestId: reqId,
        finding: widget.finding,
        question: question,
        snapshotText: widget.snapshotText,
        cloudConsent: widget.cloudConsentGrantedForSession,
        languageCode: languageCode,
        intentHint: hint,
      );
    } on HybridOperationCancelledException {
      if (mounted && seq == _deniSequence) {
        setState(() {
          _isAskingDeni = false;
          _activeDeniRequestId = null;
          _deniPose = DeniPose.explaining;
        });
      }
      return;
    }

    if (!mounted || seq != _deniSequence) return;
    if (!explanation.requiresCloudConsent) {
      setState(() {
        _isAskingDeni = false;
        _activeDeniRequestId = null;
        _deniExplanation = explanation;
        _deniPose = DeniPose.explaining;
      });
      return;
    }

    setState(() {
      _isAskingDeni = false;
      _activeDeniRequestId = null;
      _isConsentSheetOpen = true;
      _deniPose = DeniPose.support;
    });

    final CloudConsentDecision decision;
    try {
      decision = await CloudConsentSheet.show(
        context,
        subjectTitle: widget.finding.title,
        policyText:
            explanation.redactedPreview ??
            PiiRedactor.redact(widget.snapshotText).redactedText,
        deviceReason: explanation.consentReason,
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
    if (!mounted || seq != _deniSequence) return;

    if (decision == CloudConsentDecision.cancelled) {
      setState(() {
        _deniPose = DeniPose.explaining;
      });
      return;
    }

    reqId = 'deni_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _isAskingDeni = true;
      _activeDeniRequestId = reqId;
      _deniPose = DeniPose.thinking;
    });

    final DeniExplanation resolved;
    try {
      resolved = await widget.coordinator.askDeniAboutFinding(
        requestId: reqId,
        finding: widget.finding,
        question: question,
        snapshotText: widget.snapshotText,
        cloudConsent: decision == CloudConsentDecision.useCloudOnce,
        forceLocalManualFallback:
            decision == CloudConsentDecision.reviewLocally,
        languageCode: languageCode,
        intentHint: hint,
      );
    } on HybridOperationCancelledException {
      if (mounted && seq == _deniSequence) {
        setState(() {
          _isAskingDeni = false;
          _activeDeniRequestId = null;
          _deniPose = DeniPose.explaining;
        });
      }
      return;
    }
    if (!mounted || seq != _deniSequence) return;
    setState(() {
      _isAskingDeni = false;
      _activeDeniRequestId = null;
      _deniExplanation = resolved;
      _deniPose = DeniPose.explaining;
    });
  }

  String _categoryLabel(AppLocalizations l10n, FindingCategory category) {
    return switch (category) {
      FindingCategory.dataCollection => l10n.categoryDataCollection,
      FindingCategory.sharing => l10n.categorySharing,
      FindingCategory.tracking => l10n.categoryTracking,
      FindingCategory.retention => l10n.categoryRetention,
      FindingCategory.parentalConsent => l10n.categoryParentalControls,
    };
  }

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (context) {
          final l10n =
              AppLocalizations.of(context) ??
              lookupAppLocalizations(
                Localizations.maybeLocaleOf(context) ?? const Locale('en'),
              );
          final languageCode =
              Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
          final presetQuestions = [
            l10n.presetQuestionMeaning,
            l10n.presetQuestionOptOut,
            l10n.presetQuestionUnknown,
          ];
          final activeQuestion = presetQuestions[_selectedQuestionIndex];
          final finding = widget.finding;
          final isSourceMatched = finding.isSourceMatched;
          final isDeviceObserved = finding.isDeviceObserved;

          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final surfaces = context.enpriveSurfaces;
          final semantics = context.enpriveSemantics;
          final typeExt = context.enpriveType;
          final reducedMotion = EnpriveMotionTokens.isReducedMotion(context);

          return Material(
            color: surfaces.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              child: Column(
                children: [
                  // Top Bar: Close + M3E Wavy Progress Indicator
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: l10n.tooltipClose,
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            LucideIcons.x,
                            size: 22,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 168),
                              child: reducedMotion
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: _deniExplanation != null
                                            ? 1.0
                                            : 0.65,
                                        minHeight: 7,
                                        backgroundColor: surfaces.cardMuted,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              scheme.primary,
                                            ),
                                      ),
                                    )
                                  : M3EProgressIndicator.linearWavy(
                                      value: _deniExplanation != null
                                          ? 1.0
                                          : 0.65,
                                      color: scheme.primary,
                                      trackColor: surfaces.cardMuted,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      children: [
                        Text(
                          finding.title,
                          style: m3e.typography.emphasized.headlineSmall
                              .copyWith(color: scheme.onSurface),
                        ),
                        const SizedBox(height: 16),

                        // Unified Tactile M3E Evidence Work Card
                        EnpriveMaterialCardSurface(
                          variant: EnpriveCardVariant.elevated,
                          backgroundColor: surfaces.card,
                          borderRadius: BorderRadius.circular(EnpriveRadii.xl),
                          lipHeight: 3.0,
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Header Row
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: isSourceMatched
                                                  ? semantics.onDevice.icon
                                                  : (isDeviceObserved
                                                        ? semantics.inCloud.icon
                                                        : scheme.onSurfaceVariant),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              isDeviceObserved
                                                  ? l10n.statusDeviceObserved
                                                  : (isSourceMatched
                                                        ? l10n.statusSourceMatched
                                                        : l10n.statusUnverified),
                                              style: m3e.typeScale.labelLarge
                                                  .copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: scheme.onSurface,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: surfaces.cardMuted,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          _categoryLabel(
                                            l10n,
                                            finding.category,
                                          ),
                                          style: m3e.typeScale.labelSmall
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: scheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Collapsible Highlighted Policy Excerpt Stage with left archival spine
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isQuoteCollapsed = !_isQuoteCollapsed;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: surfaces.quoteSurface,
                                    border: Border.symmetric(
                                      horizontal: BorderSide(
                                        color: surfaces.hairlineBorder,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      PositionedDirectional(
                                        top: 0,
                                        bottom: 0,
                                        start: 0,
                                        width: 4,
                                        child: ColoredBox(
                                          color: isSourceMatched
                                              ? semantics.onDevice.icon
                                              : (isDeviceObserved
                                                    ? semantics.inCloud.icon
                                                    : surfaces.strongBorder),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                              24,
                                              20,
                                              20,
                                              20,
                                            ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (isDeviceObserved) ...[
                                              Text(
                                                finding.exactExcerpt.trim().isNotEmpty
                                                    ? finding.exactExcerpt
                                                    : finding.whatAndroidReports,
                                                maxLines: _isQuoteCollapsed
                                                    ? 2
                                                    : null,
                                                overflow: _isQuoteCollapsed
                                                    ? TextOverflow.ellipsis
                                                    : TextOverflow.visible,
                                                style: m3e.typeScale.bodyMedium
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: scheme.onSurface,
                                                      height: 1.4,
                                                    ),
                                              ),
                                              if (finding.whatPolicySays
                                                  .trim()
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Text(
                                                  finding.whatPolicySays,
                                                  style: m3e.typeScale.bodySmall
                                                      .copyWith(
                                                        color: scheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ] else if (finding.contextWindow !=
                                                    null &&
                                                !_isQuoteCollapsed)
                                              RichText(
                                                text: TextSpan(
                                                  style: typeExt.policyQuotation
                                                      .copyWith(
                                                        color: scheme
                                                            .onSurfaceVariant,
                                                      ),
                                                  children: [
                                                    TextSpan(
                                                      text: finding
                                                          .contextWindow!
                                                          .before,
                                                    ),
                                                    TextSpan(
                                                      text: finding
                                                          .contextWindow!
                                                          .matched,
                                                      style: TextStyle(
                                                        color: scheme.onSurface,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        backgroundColor: semantics
                                                            .reviewRecommended
                                                            .background,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: finding
                                                          .contextWindow!
                                                          .after,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              Text(
                                                '“${finding.exactExcerpt}”',
                                                maxLines: _isQuoteCollapsed
                                                    ? 1
                                                    : null,
                                                overflow: _isQuoteCollapsed
                                                    ? TextOverflow.ellipsis
                                                    : TextOverflow.visible,
                                                style: typeExt.policyQuotation
                                                    .copyWith(
                                                      color: scheme.onSurface,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Clean 3-Row Segmented Breakdown inside the card
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  children: [
                                    _CompactEvidenceRow(
                                      iconSvg: Ph.lightbulb_duotone,
                                      iconColor: semantics.onDevice.icon,
                                      label: l10n.labelInPlainLanguage,
                                      body: finding.explanation,
                                    ),
                                    const SizedBox(height: 14),
                                    _CompactEvidenceRow(
                                      iconSvg: Ph.device_mobile_duotone,
                                      iconColor: semantics.inCloud.icon,
                                      label: l10n.labelOnThisPhone,
                                      body: finding.whatAndroidReports,
                                    ),
                                    if (finding.unknowns.isNotEmpty) ...[
                                      const SizedBox(height: 14),
                                      _CompactEvidenceRow(
                                        iconSvg: Ph.question_duotone,
                                        iconColor:
                                            semantics.reviewRecommended.icon,
                                        label: l10n.labelWhatRemainsUnknown,
                                        body: finding.unknowns.first,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Preset Question Pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: presetQuestions.asMap().entries.map((
                            entry,
                          ) {
                            final idx = entry.key;
                            final q = entry.value;
                            final isSelected =
                                idx == _selectedQuestionIndex &&
                                _deniExplanation != null;
                            return EnpriveMaterialCardSurface(
                              variant: isSelected
                                  ? EnpriveCardVariant.selected
                                  : EnpriveCardVariant.elevated,
                              selected: isSelected,
                              backgroundColor: isSelected
                                  ? semantics.onDevice.background
                                  : surfaces.card,
                              accentColor: scheme.primary,
                              borderRadius: BorderRadius.circular(14),
                              lipHeight: 2.5,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              onPressed: (_isAskingDeni || _isConsentSheetOpen)
                                  ? null
                                  : () => _askDeni(idx, q, languageCode),
                              child: Text(
                                q,
                                style: m3e.typeScale.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? semantics.onDevice.foreground
                                      : scheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        if (_isAskingDeni) ...[
                          const SizedBox(height: 16),
                          EnpriveMaterialCardSurface(
                            variant: EnpriveCardVariant.tonal,
                            backgroundColor: surfaces.canvas,
                            borderRadius: BorderRadius.circular(
                              EnpriveRadii.md,
                            ),
                            lipHeight: 2.0,
                            padding: const EdgeInsets.all(14),
                            child: AnalysisLiveProcessView(
                              stream: widget.coordinator.analysisEvents,
                              initialLabel: l10n.readingCitedClause,
                              compact: true,
                            ),
                          ),
                        ] else if (_deniExplanation != null) ...[
                          const SizedBox(height: 16),
                          EnpriveMaterialCardSurface(
                            variant: EnpriveCardVariant.elevated,
                            backgroundColor: surfaces.canvas,
                            borderRadius: BorderRadius.circular(
                              EnpriveRadii.lg,
                            ),
                            lipHeight: 3.0,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Text(
                                        l10n.deniAnswerTitle,
                                        style: m3e.typeScale.labelLarge
                                            .copyWith(
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  semantics.onDevice.foreground,
                                            ),
                                      ),
                                      EnpriveProvenanceChip(
                                        source:
                                            _deniExplanation!.inferenceSource,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _deniExplanation!.answer,
                                  style: m3e.typeScale.bodyMedium.copyWith(
                                    height: 1.48,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                if (_deniExplanation!.processSteps.isNotEmpty ||
                                    _deniExplanation!.thoughtSummary != null ||
                                    _deniExplanation!.thoughtSignature !=
                                        null) ...[
                                  const SizedBox(height: 12),
                                  AnalysisSavedTraceCard(
                                    processSteps:
                                        _deniExplanation!.processSteps,
                                    thoughtSummary:
                                        _deniExplanation!.thoughtSummary,
                                    thoughtSignature:
                                        _deniExplanation!.thoughtSignature,
                                    title: l10n.stepsAndReasoning,
                                    compact: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Docked Bottom Bar: Deni Compact LOD (56dp) + Tactile Pill CTA
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                    decoration: BoxDecoration(
                      color: surfaces.card,
                      border: Border(
                        top: BorderSide(color: surfaces.hairlineBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        DeniAnimatedMascot(
                          size: 56,
                          pose: _deniPose,
                          semanticLabel: l10n.btnAskDeni,
                          onTap: (_isAskingDeni || _isConsentSheetOpen)
                              ? null
                              : () => _askDeni(
                                  _selectedQuestionIndex,
                                  activeQuestion,
                                  languageCode,
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: surfaces.tactilePrimaryBg,
                                foregroundColor: surfaces.tactilePrimaryFg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: _isAskingDeni
                                  ? _cancelAskDeni
                                  : () {
                                      if (_deniExplanation == null) {
                                        _askDeni(
                                          _selectedQuestionIndex,
                                          activeQuestion,
                                          languageCode,
                                        );
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                              child: Text(
                                _isAskingDeni
                                    ? l10n.btnCancel
                                    : (_deniExplanation == null
                                          ? l10n.btnAskDeni
                                          : l10n.btnDone),
                                style: m3e.typeScale.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: surfaces.tactilePrimaryFg,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactEvidenceRow extends StatelessWidget {
  final String iconSvg;
  final Color iconColor;
  final String label;
  final String body;

  const _CompactEvidenceRow({
    required this.iconSvg,
    required this.iconColor,
    required this.label,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: EnpriveDuotoneIcon(iconSvg, size: 17, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: m3e.typeScale.labelMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: m3e.typeScale.bodyMedium.copyWith(
                  height: 1.45,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
