import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'analysis_process_trace.dart';
import 'enprive_duotone_icon.dart';

/// Live 4-stage milestone progress card shown while a policy or app review runs.
///
/// Combines a calm paper-white header, overlapping source icon badges, a dark
/// capsule milestone track with animated rounded connectors, and a live
/// streaming reasoning + step-counter footer.
class ReviewProgressCard extends StatefulWidget {
  final String subjectTitle;
  final bool isCloudCheck;
  final Stream<AnalysisStreamEvent>? processStream;

  const ReviewProgressCard({
    super.key,
    required this.subjectTitle,
    this.isCloudCheck = false,
    this.processStream,
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
      final isCloudEvent = event.inferenceSource == 'IN_CLOUD' ||
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
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final displayStep = (_activeStepIndex + 1).clamp(1, _totalSteps);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EnpriveColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: EnpriveColors.teal.withValues(alpha: 0.16),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: EnpriveColors.tealStrong.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Stage headline + Subject subtitle on left, Source cluster + Mode badge on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reviewingOnPhone,
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        color: EnpriveColors.ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subjectTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: EnpriveColors.inkSecondary,
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
                      color: _isInCloudActive
                          ? EnpriveColors.chipInCloudBg
                          : EnpriveColors.chipOnDeviceBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _isInCloudActive ? 'App Check' : 'LIVE',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: _isInCloudActive
                            ? EnpriveColors.chipInCloudFg
                            : EnpriveColors.tealStrong,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Signature Dark Capsule Milestone Track (4-stage pipeline)
          _DarkCapsuleMilestoneTrack(
            activeStepIndex: _activeStepIndex,
            isCompleted: _isCompleted,
            disableAnimations: disableAnimations,
          ),

          const SizedBox(height: 14),

          // Footer: Live animated ticker on left + Tabular "X of 4" counter on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AnalysisLiveProcessView(
                  stream: widget.processStream,
                  initialLabel: l10n.readingClausesInitial,
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
                  color: EnpriveColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.progressStepCounter(displayStep, _totalSteps),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: EnpriveColors.inkSecondary,
                    fontFeatures: [FontFeature.tabularFigures()],
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

class _OverlappingSourceBadges extends StatelessWidget {
  final bool isCloudCheck;

  const _OverlappingSourceBadges({required this.isCloudCheck});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            end: 40,
            child: _miniBadge(
              bg: EnpriveColors.surfaceMuted,
              iconSvg: Ph.file_text_duotone,
              color: EnpriveColors.ink,
            ),
          ),
          PositionedDirectional(
            end: 20,
            child: _miniBadge(
              bg: EnpriveColors.chipOnDeviceBg,
              iconSvg: Ph.device_mobile_duotone,
              color: EnpriveColors.tealStrong,
            ),
          ),
          PositionedDirectional(
            end: 0,
            child: _miniBadge(
              bg: isCloudCheck
                  ? EnpriveColors.chipInCloudBg
                  : EnpriveColors.stateNoConcernBg,
              iconSvg:
                  isCloudCheck ? Ph.cloud_check_duotone : Ph.shield_check_duotone,
              color: isCloudCheck
                  ? EnpriveColors.chipInCloudFg
                  : EnpriveColors.stateNoConcernFg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadge({
    required Color bg,
    required String iconSvg,
    required Color color,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: EnpriveColors.surface, width: 2),
      ),
      child: Center(
        child: EnpriveDuotoneIcon(
          iconSvg,
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

  static const Color _trackDark = EnpriveColors.ctaInk;
  static const Color _inactiveNodeFill = Color(0xFF333B3F);
  static const Color _inactiveRing = Color(0xFF535F65);
  static const Color _inactiveIcon = Color(0xFF97A4AA);
  static const Color _accentMint = Color(0xFF2ED3B7);

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
