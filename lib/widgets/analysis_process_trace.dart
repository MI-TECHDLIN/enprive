import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/enprive_colors.dart';
import '../services/platform/hybrid_ai_bridge.dart';

String formatThoughtSignaturePreview(String signature) {
  final trimmed = signature.trim();
  if (trimmed.length <= 18) return trimmed;
  return '${trimmed.substring(0, 8)}…${trimmed.substring(trimmed.length - 6)}';
}

/// Claude-style single-line streaming ticker displaying the active review step,
/// one-at-a-time streaming thoughts (`thoughtSummary`), and `thoughtSignature`
/// tokens without stacking a noisy vertical todo checklist.
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

          if (newSentences.length == 1 && _lineTicker == null && _thoughtQueue.isEmpty) {
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
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final activeLine = _currentThoughtLine ?? _activeLabel;
    final showTopMeta = _currentThoughtLine != null || _thoughtSignature != null;

    final lineText = Text(
      activeLine,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: widget.compact ? 12.5 : 13.5,
        fontWeight: FontWeight.w600,
        color: EnpriveColors.ink,
      ),
    );

    final tickerChild = disableAnimations
        ? lineText
        : Shimmer.fromColors(
            baseColor: EnpriveColors.ink,
            highlightColor: EnpriveColors.tealStrong,
            period: const Duration(milliseconds: 1800),
            child: lineText,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EnpriveColors.surfaceMuted.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EnpriveColors.teal.withValues(alpha: 0.14),
        ),
      ),
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
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: EnpriveColors.tealStrong,
                    ),
                  ),
                ),
                if (_thoughtSignature != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: EnpriveColors.chipInCloudBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 12,
                          color: EnpriveColors.chipInCloudFg,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Thought signature ${formatThoughtSignaturePreview(_thoughtSignature!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: EnpriveColors.chipInCloudFg,
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
              disableAnimations
                  ? const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: EnpriveColors.tealStrong,
                    )
                  : LoadingAnimationWidget.staggeredDotsWave(
                      color: EnpriveColors.tealStrong,
                      size: 18,
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
                      alignment: Alignment.centerLeft,
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
/// for finished receipts and Deni's explanations.
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
    this.title = 'Review process & reasoning',
    this.compact = false,
  });

  @override
  State<AnalysisSavedTraceCard> createState() => _AnalysisSavedTraceCardState();
}

class _AnalysisSavedTraceCardState extends State<AnalysisSavedTraceCard> {
  bool _showThoughts = false;

  @override
  Widget build(BuildContext context) {
    final hasThoughts =
        widget.thoughtSummary != null && widget.thoughtSummary!.isNotEmpty;
    final hasSignature =
        widget.thoughtSignature != null && widget.thoughtSignature!.isNotEmpty;
    if (widget.processSteps.isEmpty && !hasThoughts && !hasSignature) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.compact ? 12 : 16),
      decoration: BoxDecoration(
        color: widget.compact
            ? EnpriveColors.surfaceMuted.withValues(alpha: 0.75)
            : EnpriveColors.surface,
        borderRadius: BorderRadius.circular(widget.compact ? 14 : 20),
        border: Border.all(
          color: EnpriveColors.ink.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                size: 16,
                color: EnpriveColors.tealStrong,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: widget.compact ? 12.5 : 13.5,
                    fontWeight: FontWeight.w800,
                    color: EnpriveColors.ink,
                  ),
                ),
              ),
              if (widget.processSteps.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: EnpriveColors.chipOnDeviceBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${widget.processSteps.length} ${widget.processSteps.length == 1 ? 'step' : 'steps'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: EnpriveColors.chipOnDeviceFg,
                    ),
                  ),
                ),
            ],
          ),
          if (widget.processSteps.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: EnpriveColors.tealStrong,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.processSteps.last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.compact ? 12 : 12.5,
                      height: 1.35,
                      color: EnpriveColors.inkSecondary,
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
                color: EnpriveColors.chipInCloudBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 13,
                    color: EnpriveColors.chipInCloudFg,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Thought signature: ${formatThoughtSignaturePreview(widget.thoughtSignature!)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: EnpriveColors.chipInCloudFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasThoughts) ...[
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
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                      color: EnpriveColors.tealStrong,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showThoughts
                          ? 'Hide streamed thoughts'
                          : 'View streamed thoughts',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: EnpriveColors.tealStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showThoughts) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EnpriveColors.paper,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.thoughtSummary!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: EnpriveColors.inkSecondary,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
