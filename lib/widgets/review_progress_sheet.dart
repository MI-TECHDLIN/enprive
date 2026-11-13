import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'analysis_process_trace.dart';

/// Live progress card shown while "Review on this phone" runs.
/// Displays every active/completed step, streamed model thoughts, and
/// thought signature verification tokens cleanly in real time.
class ReviewProgressCard extends StatelessWidget {
  final String subjectTitle;
  final bool isCloudCheck;
  final bool isKorean;
  final Stream<AnalysisStreamEvent>? processStream;

  const ReviewProgressCard({
    super.key,
    required this.subjectTitle,
    this.isCloudCheck = false,
    this.isKorean = false,
    this.processStream,
  });

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
                child: const Icon(
                  Symbols.shield_lock_rounded,
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
                      subjectTitle,
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
                      isKorean
                          ? '이 휴대폰에서 검토하는 중…'
                          : 'Reviewing on this phone…',
                      style: const TextStyle(
                        fontSize: 13,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 7,
              backgroundColor: EnpriveColors.ink.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                EnpriveColors.teal,
              ),
            ),
          ),
          const SizedBox(height: 14),
          AnalysisLiveProcessView(
            stream: processStream,
            initialLabel: isKorean
                ? '이 휴대폰에서 로컬 AI 확인 중…'
                : 'Checking on-device Gemini Nano…',
          ),
        ],
      ),
    );
  }
}
