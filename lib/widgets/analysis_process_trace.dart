import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/enprive_theme.dart';
import '../core/theme/enprive_tokens.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'm3e/enprive_m3e_components.dart';

String formatThoughtSignaturePreview(String signature) {
  final trimmed = signature.trim();
  if (trimmed.length <= 18) return trimmed;
  return '${trimmed.substring(0, 8)}…${trimmed.substring(trimmed.length - 6)}';
}

/// Single-line streaming ticker displaying the active review step,
/// one-at-a-time streaming thoughts (`thoughtSummary`), and `thoughtSignature`
/// tokens with Material 3 Expressive morphing [M3ELoadingIndicator].
class AnalysisLiveProcessView extends StatefulWidget {
  final Stream<AnalysisStreamEvent>? stream;
  final String initialLabel;
  final bool compact;

  const AnalysisLiveProcessView({
    super.key,
    required this.stream,
    this.initialLabel = 'Reading policy clauses on this phone…',
    this.compact = false,
  });

  @override
  State<AnalysisLiveProcessView> createState() =>
      _AnalysisLiveProcessViewState();
}

class _AnalysisLiveProcessViewState extends State<AnalysisLiveProcessView> {
  StreamSubscription<AnalysisStreamEvent>? _subscription;
  late String _activeLabel = widget.initialLabel;
  final List<String> _thoughtQueue = [];
  final Set<String> _seenThoughts = {};
  String? _currentThoughtLine;
  Timer? _lineTicker;
  int _stepCount = 1;
  String? _thoughtSignature;

  @override
  void initState() {
    super.initState();
    _attachStream();
  }

  @override
  void didUpdateWidget(covariant AnalysisLiveProcessView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLabel != widget.initialLabel && _stepCount == 1) {
      _activeLabel = widget.initialLabel;
    }
    if (oldWidget.stream != widget.stream) {
      _subscription?.cancel();
      _attachStream();
    }
  }

  void _attachStream() {
    final stream = widget.stream;
    if (stream == null) return;
    _subscription = stream.listen((event) {
      if (!mounted) return;
      setState(() {
        if (event.label.isNotEmpty && event.label != _activeLabel) {
          _activeLabel = event.label;
          _stepCount++;
        }

        final rawThought = event.thoughtSummary?.trim();
        if (rawThought != null && rawThought.isNotEmpty) {
          final sentences = rawThought
              .split(RegExp(r'(?<=[.!?])\s+|\n+'))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

          final newSentences = <String>[];
          for (final sentence in sentences) {
            if (_seenThoughts.add(sentence)) {
              newSentences.add(sentence);
            }
          }

          if (newSentences.length == 1 &&
              _lineTicker == null &&
              _thoughtQueue.isEmpty) {
            _currentThoughtLine = newSentences.last;
          } else if (newSentences.isNotEmpty) {
            _thoughtQueue.addAll(newSentences);
            _currentThoughtLine ??= _thoughtQueue.removeAt(0);
            if (_thoughtQueue.isNotEmpty) {
              _ensureTickerRunning();
            }
          }
        }

        final rawSig = event.thoughtSignature?.trim();
        if (rawSig != null && rawSig.isNotEmpty) {
          _thoughtSignature = rawSig;
        }
      });
    });
  }

  void _ensureTickerRunning() {
    if (_lineTicker != null) return;
    _lineTicker = Timer.periodic(const Duration(milliseconds: 950), (timer) {
      if (!mounted || _thoughtQueue.isEmpty) {
        timer.cancel();
        _lineTicker = null;
        return;
      }
      setState(() {
        _currentThoughtLine = _thoughtQueue.removeAt(0);
        if (_thoughtQueue.isEmpty) {
          timer.cancel();
          _lineTicker = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _lineTicker?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;
    final disableAnimations = EnpriveMotionTokens.isReducedMotion(context);

    final activeLine = _currentThoughtLine ?? _activeLabel;
    final showTopMeta =
        _currentThoughtLine != null || _thoughtSignature != null;

    final lineText = Text(
      activeLine,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: m3e.typeScale.bodyMedium.copyWith(
        fontSize: widget.compact ? 12.5 : 13.5,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    );

    final tickerChild = disableAnimations
        ? lineText
        : Shimmer.fromColors(
            baseColor: scheme.onSurface,
            highlightColor: scheme.primary,
            period: const Duration(milliseconds: 1800),
            child: lineText,
          );

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.tonal,
      backgroundColor: surfaces.container,
      borderRadius: BorderRadius.circular(18),
      lipHeight: 2.0,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTopMeta) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    _activeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: m3e.typography.emphasized.labelSmall.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
                if (_thoughtSignature != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: semantics.inCloud.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.badgeCheck,
                          size: 12,
                          color: semantics.inCloud.foreground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${l10n.thoughtSignaturePrefix} ${formatThoughtSignaturePreview(_thoughtSignature!)}',
                          style: m3e.typography.emphasized.labelSmall.copyWith(
                            fontSize: 11,
                            color: semantics.inCloud.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              if (disableAnimations)
                Icon(
                  LucideIcons.sparkles,
                  size: 16,
                  color: scheme.primary,
                )
              else
                SizedBox(
                  width: 24,
                  height: 24,
                  child: M3ELoadingIndicator(
                    size: 24,
                    color: scheme.primary,
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRect(
                  child: AnimatedSwitcher(
                    duration: disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.35),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Align(
                      key: ValueKey<String>(activeLine),
                      alignment: AlignmentDirectional.centerStart,
                      child: tickerChild,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact completed process summary + model thoughts + thought signature viewer
/// for finished receipts and Deni's explanations, using M3E segmented step items.
class AnalysisSavedTraceCard extends StatefulWidget {
  final List<String> processSteps;
  final String? thoughtSummary;
  final String? thoughtSignature;
  final String title;
  final bool compact;

  const AnalysisSavedTraceCard({
    super.key,
    required this.processSteps,
    this.thoughtSummary,
    this.thoughtSignature,
    this.title = '',
    this.compact = false,
  });

  @override
  State<AnalysisSavedTraceCard> createState() => _AnalysisSavedTraceCardState();
}

class _AnalysisSavedTraceCardState extends State<AnalysisSavedTraceCard> {
  bool _showThoughts = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;

    final resolvedTitle =
        widget.title.isEmpty ? l10n.analysisTraceDefaultTitle : widget.title;
    final hasThoughts =
        widget.thoughtSummary != null && widget.thoughtSummary!.isNotEmpty;
    final hasSignature =
        widget.thoughtSignature != null && widget.thoughtSignature!.isNotEmpty;
    if (widget.processSteps.isEmpty && !hasThoughts && !hasSignature) {
      return const SizedBox.shrink();
    }

    return EnpriveMaterialCardSurface(
      variant: widget.compact
          ? EnpriveCardVariant.tonal
          : EnpriveCardVariant.elevated,
      backgroundColor: widget.compact ? surfaces.container : surfaces.card,
      borderRadius: BorderRadius.circular(widget.compact ? 18 : 22),
      lipHeight: widget.compact ? 2.0 : 3.0,
      padding: EdgeInsets.all(widget.compact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.route,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  resolvedTitle,
                  style: m3e.typography.emphasized.labelLarge.copyWith(
                    fontSize: widget.compact ? 12.5 : 13.5,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (widget.processSteps.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: semantics.onDevice.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.stepsCountLabel(widget.processSteps.length),
                    style: m3e.typography.emphasized.labelSmall.copyWith(
                      fontSize: 11,
                      color: semantics.onDevice.foreground,
                    ),
                  ),
                ),
            ],
          ),
          if (widget.processSteps.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  LucideIcons.circleCheck,
                  size: 14,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.processSteps.last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: m3e.typeScale.bodySmall.copyWith(
                      fontSize: widget.compact ? 12 : 12.5,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (hasSignature) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: semantics.inCloud.background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.badgeCheck,
                    size: 13,
                    color: semantics.inCloud.foreground,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${l10n.thoughtSignaturePrefix}: ${formatThoughtSignaturePreview(widget.thoughtSignature!)}',
                      overflow: TextOverflow.ellipsis,
                      style: m3e.typography.emphasized.labelSmall.copyWith(
                        fontSize: 11.5,
                        color: semantics.inCloud.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasThoughts || widget.processSteps.length > 1) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _showThoughts = !_showThoughts),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showThoughts
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showThoughts
                          ? l10n.hideStreamedThoughts
                          : l10n.viewStreamedThoughts,
                      style: m3e.typography.emphasized.labelMedium.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showThoughts) ...[
              if (widget.processSteps.isNotEmpty) ...[
                const SizedBox(height: 8),
                Column(
                  children: [
                    for (var i = 0; i < widget.processSteps.length; i++) ...[
                      if (i > 0) const SizedBox(height: 4),
                      EnpriveSegmentedCardTile(
                        index: i,
                        totalCount: widget.processSteps.length,
                        backgroundColor: scheme.surfaceContainerLow,
                        lipHeight: 1.5,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: semantics.onDevice.background,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                (i + 1).toString().padLeft(2, '0'),
                                style: m3e.typography.emphasized.labelSmall
                                    .copyWith(
                                      fontSize: 10.5,
                                      color: semantics.onDevice.foreground,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.processSteps[i],
                                style: m3e.typeScale.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            Icon(
                              LucideIcons.circleCheck,
                              size: 15,
                              color: scheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (hasThoughts) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: surfaces.hairlineBorder),
                  ),
                  child: Text(
                    widget.thoughtSummary!,
                    style: m3e.typeScale.bodySmall.copyWith(
                      height: 1.45,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}
