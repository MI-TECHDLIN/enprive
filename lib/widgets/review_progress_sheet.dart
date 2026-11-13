import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';

/// Calm 4-Segment On-Device Analysis Progress Card (`b30-lesson-check.png` pattern).
/// Always pairs animated progress segments with explicit plain-language status text
/// so progress is never communicated by motion alone.
class ReviewProgressCard extends StatefulWidget {
  final String subjectTitle;
  final bool isCloudCheck;
  final bool isKorean;

  const ReviewProgressCard({
    super.key,
    required this.subjectTitle,
    this.isCloudCheck = false,
    this.isKorean = false,
  });

  @override
  State<ReviewProgressCard> createState() => _ReviewProgressCardState();
}

class _ReviewProgressCardState extends State<ReviewProgressCard> {
  int _activeStep = 1;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _stepTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted) return;
      setState(() {
        _activeStep = (_activeStep % 4) + 1;
      });
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  String _stepDescription() {
    if (widget.isKorean) {
      return switch (_activeStep) {
        1 => '1/4단계 · 약관 스냅샷 지문 생성 중',
        2 => widget.isCloudCheck
            ? '2/4단계 · 클라우드 AI로 약관 문장 분석 중'
            : '2/4단계 · 기기 내 모델로 약관 문장 분석 중',
        3 => '3/4단계 · 원문 인용구 정확도 대조 중',
        _ => '4/4단계 · 기기 권한 및 영수증 정리 중',
      };
    }
    return switch (_activeStep) {
      1 => 'Step 1 of 4 · Fingerprinting policy snapshot',
      2 => widget.isCloudCheck
          ? 'Step 2 of 4 · Analyzing clauses in cloud (consented)'
          : 'Step 2 of 4 · Reading policy clauses on this device',
      3 => 'Step 3 of 4 · Verifying verbatim source quotes',
      _ => 'Step 4 of 4 · Comparing local Android permissions',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EnpriveColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: EnpriveColors.chipOnDeviceBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.isCloudCheck
                      ? Symbols.cloud_rounded
                      : Symbols.memory_rounded,
                  size: 18,
                  color: EnpriveColors.tealStrong,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subjectTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: EnpriveColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _stepDescription(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: EnpriveColors.tealStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4-Segment Progress Bar (`b30-lesson-check.png`)
          Row(
            children: List.generate(4, (index) {
              final filled = index < _activeStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 7,
                  margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: filled
                        ? EnpriveColors.teal
                        : EnpriveColors.ink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
