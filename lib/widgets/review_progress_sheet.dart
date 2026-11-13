import 'package:animated_status_card/animated_status_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/enprive_colors.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'analysis_process_trace.dart';

/// Live progress card shown while "Review on this phone" runs.
/// Uses `AnimatedMiniStatusCard`, shimmer polish, and a Claude-style
/// single-line streaming thought ticker.
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
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EnpriveColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: EnpriveColors.teal.withValues(alpha: 0.14),
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
          AnimatedMiniStatusCard(
            title: isKorean
                ? '이 휴대폰에서 검토하는 중…'
                : 'Reviewing on this phone…',
            value: subjectTitle,
            icon: LucideIcons.shieldCheck,
            trendValue: isCloudCheck
                ? (isKorean ? 'App Check' : 'App Check')
                : (isKorean ? 'LIVE' : 'LIVE'),
            trendDirection: TrendDirection.up,
            statusType: CardStatusType.info,
          ),
          const SizedBox(height: 14),
          disableAnimations
              ? Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: EnpriveColors.teal.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                )
              : Shimmer.fromColors(
                  baseColor: EnpriveColors.chipOnDeviceBg,
                  highlightColor: EnpriveColors.teal.withValues(alpha: 0.55),
                  period: const Duration(milliseconds: 1400),
                  child: Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: EnpriveColors.chipOnDeviceBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
          const SizedBox(height: 14),
          AnalysisLiveProcessView(
            stream: processStream,
            initialLabel: isKorean
                ? '이 휴대폰에서 약관 조항을 읽는 중…'
                : 'Reading policy clauses on this phone…',
          ),
        ],
      ),
    );
  }
}
