import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'analysis_process_trace.dart';
import 'm3e/enprive_m3e_components.dart';

/// Live 4-stage Material 3 Expressive milestone progress card shown while a
/// policy or app review runs.
class ReviewProgressCard extends StatefulWidget {
  final String subjectTitle;
  final bool isCloudCheck;
  final Stream<AnalysisStreamEvent>? processStream;
  final VoidCallback? onCancel;
  final bool isCancelling;

  const ReviewProgressCard({
    super.key,
    required this.subjectTitle,
    this.isCloudCheck = false,
    this.processStream,
    this.onCancel,
    this.isCancelling = false,
  });

  @override
  State<ReviewProgressCard> createState() => _ReviewProgressCardState();
}

class _ReviewProgressCardState extends State<ReviewProgressCard> {
  static const int _totalSteps = 4;

  StreamSubscription<AnalysisStreamEvent>? _sub;
  int _activeStepIndex = 0; // 0-indexed (0..3 -> "1 of 4".."4 of 4")
  bool _isCompleted = false;
  bool _isInCloudActive = false;

  @override
  void initState() {
    super.initState();
    _isInCloudActive = widget.isCloudCheck;
    _listen();
  }

  @override
  void didUpdateWidget(covariant ReviewProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.processStream != widget.processStream) {
      _sub?.cancel();
      _listen();
    }
    if (widget.isCloudCheck && !_isInCloudActive) {
      _isInCloudActive = true;
    }
  }

  void _listen() {
    final stream = widget.processStream;
    if (stream == null) return;
    _sub = stream.listen((event) {
      if (!mounted) return;
      final nextIndex = _stepIndexForStage(
        event.stage,
        isCompleted: event.isCompleted,
      );
      final isCloudEvent =
          event.inferenceSource == 'IN_CLOUD' ||
          event.stage == 'sending_appcheck';
      setState(() {
        if (nextIndex > _activeStepIndex) {
          _activeStepIndex = nextIndex;
        }
        if (event.isCompleted) {
          _isCompleted = true;
          _activeStepIndex = _totalSteps - 1;
        }
        if (isCloudEvent) {
          _isInCloudActive = true;
        }
      });
    });
  }

  int _stepIndexForStage(String stage, {required bool isCompleted}) {
    if (isCompleted || stage == 'verifying_evidence' || stage == 'completed') {
      return 3;
    }
    return switch (stage) {
      'sending_appcheck' ||
      'model_stream_started' ||
      'streaming_thoughts' ||
      'thought_signature_received' ||
      'structured_output_received' ||
      'offline_fallback' =>
        2,
      'redacting_pii' ||
      'on_device_unavailable' ||
      'routing_comprehensive' =>
        1,
      _ => 0,
    };
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = EnpriveMotionTokens.isReducedMotion(context);
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;

    final displayStep = (_activeStepIndex + 1).clamp(1, _totalSteps);
    final modePair =
        _isInCloudActive ? semantics.inCloud : semantics.onDevice;

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.elevated,
      backgroundColor: surfaces.card,
      borderRadius: BorderRadius.circular(28),
      lipHeight: 3.0,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isInCloudActive
                          ? l10n.checkingPolicyWithCloudAi
                          : l10n.reviewingOnPhone,
                      style: m3e.typography.emphasized.titleMedium.copyWith(
                        color: scheme.onSurface,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subjectTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: m3e.typeScale.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _OverlappingSourceBadges(isCloudCheck: _isInCloudActive),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: modePair.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _isInCloudActive ? 'App Check' : 'LIVE',
                      style: m3e.typography.emphasized.labelSmall.copyWith(
                        fontSize: 10.5,
                        letterSpacing: 0.4,
                        color: modePair.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          _DarkCapsuleMilestoneTrack(
            activeStepIndex: _activeStepIndex,
            isCompleted: _isCompleted,
            disableAnimations: disableAnimations,
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AnalysisLiveProcessView(
                  stream: widget.processStream,
                  initialLabel: _isInCloudActive
                      ? l10n.preparingCloudAiStream
                      : l10n.readingClausesInitial,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.progressStepCounter(displayStep, _totalSteps),
                  style: m3e.typography.emphasized.labelSmall.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          if (widget.onCancel != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton.icon(
                key: const ValueKey<String>('review_progress_cancel_btn'),
                onPressed: widget.isCancelling ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(88, 48),
                  foregroundColor: scheme.onSurfaceVariant,
                  side: BorderSide(color: surfaces.hairlineBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(LucideIcons.x, size: 16),
                label: Text(
                  widget.isCancelling ? l10n.cancellingAnalysis : l10n.btnCancel,
                  style: m3e.typography.emphasized.labelLarge,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverlappingSourceBadges extends StatelessWidget {
  final bool isCloudCheck;

  const _OverlappingSourceBadges({required this.isCloudCheck});

  @override
  Widget build(BuildContext context) {
    final scheme = M3ETheme.of(context).colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;

    return SizedBox(
      width: 68,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            end: 40,
            child: _miniBadge(
              bg: scheme.surfaceContainerHigh,
              borderColor: surfaces.card,
              icon: LucideIcons.fileText,
              color: scheme.onSurface,
            ),
          ),
          PositionedDirectional(
            end: 20,
            child: _miniBadge(
              bg: semantics.onDevice.background,
              borderColor: surfaces.card,
              icon: LucideIcons.smartphone,
              color: semantics.onDevice.foreground,
            ),
          ),
          PositionedDirectional(
            end: 0,
            child: _miniBadge(
              bg: isCloudCheck
                  ? semantics.inCloud.background
                  : semantics.noConcern.background,
              borderColor: surfaces.card,
              icon: isCloudCheck
                  ? LucideIcons.cloudCheck
                  : LucideIcons.fileText,
              color: isCloudCheck
                  ? semantics.inCloud.foreground
                  : semantics.noConcern.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadge({
    required Color bg,
    required Color borderColor,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 14,
          color: color,
        ),
      ),
    );
  }
}

class _DarkCapsuleMilestoneTrack extends StatelessWidget {
  final int activeStepIndex;
  final bool isCompleted;
  final bool disableAnimations;

  const _DarkCapsuleMilestoneTrack({
    required this.activeStepIndex,
    required this.isCompleted,
    required this.disableAnimations,
  });

  static const _nodeIcons = <IconData>[
    LucideIcons.fileText,
    LucideIcons.eraser,
    LucideIcons.sparkles,
    LucideIcons.badgeCheck,
  ];

  static const Color _trackDark = Color(0xFF162133);
  static const Color _inactiveNodeFill = Color(0xFF283446);
  static const Color _inactiveRing = Color(0xFF475569);
  static const Color _inactiveIcon = Color(0xFF94A3B8);
  static const Color _accentMint = Color(0xFF3BD4B7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _trackDark,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _nodeIcons.length; i++) ...[
            _buildNode(i),
            if (i < _nodeIcons.length - 1) Expanded(child: _buildConnector(i)),
          ],
        ],
      ),
    );
  }

  Widget _buildNode(int index) {
    final isDone = isCompleted || index < activeStepIndex;
    final isCurrent = !isCompleted && index == activeStepIndex;
    final isLit = isDone || isCurrent;

    return AnimatedContainer(
      duration: disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isLit ? _accentMint : _inactiveNodeFill,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrent
              ? Colors.white.withValues(alpha: 0.72)
              : (isDone ? _accentMint : _inactiveRing),
          width: isCurrent ? 2 : 1.5,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: _accentMint.withValues(alpha: 0.42),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Icon(
        isDone ? LucideIcons.check : _nodeIcons[index],
        size: 17,
        color: isLit ? _trackDark : _inactiveIcon,
      ),
    );
  }

  Widget _buildConnector(int leftIndex) {
    final targetFraction = isCompleted || leftIndex < activeStepIndex
        ? 1.0
        : (leftIndex == activeStepIndex ? 0.58 : 0.0);

    return Container(
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: _inactiveNodeFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: targetFraction),
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: _accentMint,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
