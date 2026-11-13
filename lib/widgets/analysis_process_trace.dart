import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/enprive_colors.dart';
import '../services/platform/hybrid_ai_bridge.dart';

String formatThoughtSignaturePreview(String signature) {
  final trimmed = signature.trim();
  if (trimmed.length <= 18) return trimmed;
  return '${trimmed.substring(0, 8)}…${trimmed.substring(trimmed.length - 6)}';
}

class _RecordedStep {
  final String stage;
  final String label;
  bool completed;

  _RecordedStep({
    required this.stage,
    required this.label,
    required this.completed,
  });
}

/// Live process timeline displaying every hybrid step, streaming model
/// thoughts (`thoughtSummary`), and `thoughtSignature` tokens in real time.
class AnalysisLiveProcessView extends StatefulWidget {
  final Stream<AnalysisStreamEvent>? stream;
  final String initialLabel;
  final bool compact;

  const AnalysisLiveProcessView({
    super.key,
    required this.stream,
    this.initialLabel = 'Reviewing on this phone…',
    this.compact = false,
  });

  @override
  State<AnalysisLiveProcessView> createState() =>
      _AnalysisLiveProcessViewState();
}

class _AnalysisLiveProcessViewState extends State<AnalysisLiveProcessView> {
  StreamSubscription<AnalysisStreamEvent>? _subscription;
  final List<_RecordedStep> _steps = [];
  String? _thoughtSummary;
  String? _thoughtSignature;

  @override
  void initState() {
    super.initState();
    _attachStream();
  }

  @override
  void didUpdateWidget(covariant AnalysisLiveProcessView oldWidget) {
    super.didUpdateWidget(oldWidget);
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
        for (final step in _steps) {
          step.completed = true;
        }
        final existingIdx =
            _steps.indexWhere((s) => s.stage == event.stage && s.label == event.label);
        if (existingIdx >= 0) {
          _steps[existingIdx].completed = event.isCompleted;
        } else {
          _steps.add(
            _RecordedStep(
              stage: event.stage,
              label: event.label,
              completed: event.isCompleted,
            ),
          );
        }
        if (event.thoughtSummary != null && event.thoughtSummary!.isNotEmpty) {
          _thoughtSummary = event.thoughtSummary;
        }
        if (event.thoughtSignature != null && event.thoughtSignature!.isNotEmpty) {
          _thoughtSignature = event.thoughtSignature;
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps.isEmpty
        ? [
            _RecordedStep(
              stage: 'starting',
              label: widget.initialLabel,
              completed: false,
            ),
          ]
        : _steps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: steps[i].completed
                    ? const Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: EnpriveColors.tealStrong,
                      )
                    : const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: EnpriveColors.tealStrong,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  steps[i].label,
                  style: TextStyle(
                    fontSize: widget.compact ? 12.5 : 13,
                    fontWeight:
                        steps[i].completed ? FontWeight.w600 : FontWeight.w700,
                    height: 1.35,
                    color: steps[i].completed
                        ? EnpriveColors.inkSecondary
                        : EnpriveColors.ink,
                  ),
                ),
              ),
            ],
          ),
          if (i < steps.length - 1) const SizedBox(height: 6),
        ],
        if (_thoughtSummary != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: EnpriveColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Streaming thoughts',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: EnpriveColors.tealStrong,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _thoughtSummary!,
                  maxLines: widget.compact ? 3 : 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: EnpriveColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_thoughtSignature != null) ...[
          const SizedBox(height: 8),
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
                    'Thought signature ${formatThoughtSignaturePreview(_thoughtSignature!)}',
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
      ],
    );
  }
}

/// Completed process trace + model thoughts + thought signature viewer for
/// finished receipts and Deni's explanations.
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
            const SizedBox(height: 10),
            for (var i = 0; i < widget.processSteps.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: EnpriveColors.tealStrong,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.processSteps[i],
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
              if (i < widget.processSteps.length - 1) const SizedBox(height: 5),
            ],
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
