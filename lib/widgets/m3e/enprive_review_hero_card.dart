import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/review/review_models.dart';
import '../deni_animated_mascot.dart';
import '../enprive_duotone_icon.dart';
import 'enprive_material_card_surface.dart';

/// Material 3 Expressive Review Result hero posture summary card.
///
/// Pairs an inset organic emerald-teal mesh header banner and overlapping Deni
/// portrait medallion with crisp identity typography, quick utility actions,
/// a delicate hairline divider, a borderless 3-column tabular metric row, and
/// a full-width dark-ink / ceramic-teal pill CTA with leading circular arrow.
class EnpriveReviewHeroCard extends StatelessWidget {
  final String subjectTitle;
  final String subtitle;
  final ReviewOverallState overallState;
  final String stateBadgeLabel;
  final String findingsCountValue;
  final String findingsLabel;
  final String verifiedCountValue;
  final String verifiedLabel;
  final String secondaryMetricValue;
  final String secondaryMetricLabel;
  final bool hasPermissionReport;
  final DeniPose mascotPose;
  final String sourceActionLabel;
  final String sourceActionTooltip;
  final VoidCallback onSourceAction;
  final bool isSpeaking;
  final String voiceTooltip;
  final VoidCallback onVoiceAction;
  final String primaryCtaLabel;
  final VoidCallback onPrimaryCta;
  final VoidCallback? onMascotTap;

  const EnpriveReviewHeroCard({
    super.key,
    required this.subjectTitle,
    required this.subtitle,
    required this.overallState,
    required this.stateBadgeLabel,
    required this.findingsCountValue,
    required this.findingsLabel,
    required this.verifiedCountValue,
    required this.verifiedLabel,
    required this.secondaryMetricValue,
    required this.secondaryMetricLabel,
    required this.hasPermissionReport,
    required this.mascotPose,
    required this.sourceActionLabel,
    required this.sourceActionTooltip,
    required this.onSourceAction,
    required this.isSpeaking,
    required this.voiceTooltip,
    required this.onVoiceAction,
    required this.primaryCtaLabel,
    required this.onPrimaryCta,
    this.onMascotTap,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;
    final typeExt = context.enpriveType;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final bool isLargeScale = textScale > 1.28;

    final (
      SemanticColorPair statePair,
      IconData stateIcon,
    ) = switch (overallState) {
      ReviewOverallState.reviewRecommended => (
        semantics.reviewRecommended,
        LucideIcons.shieldAlert,
      ),
      ReviewOverallState.noConcern => (
        semantics.noConcern,
        LucideIcons.shieldCheck,
      ),
      ReviewOverallState.insufficientEvidence => (
        semantics.insufficientEvidence,
        LucideIcons.circleHelp,
      ),
    };

    const double bannerHeight = 112.0;
    const double medallionDiameter = 84.0;
    const double medallionOverlap = 34.0;

    final Color medallionInnerBg = isDark
        ? Color.lerp(
            surfaces.cardElevated,
            semantics.onDevice.background,
            0.45,
          )!
        : Color.lerp(surfaces.card, semantics.onDevice.background, 0.35)!;

    final Color meshBase = isDark
        ? Color.lerp(surfaces.canvas, semantics.onDevice.background, 0.72)!
        : semantics.onDevice.icon;
    final Color meshMid = isDark
        ? semantics.onDevice.background
        : Color.lerp(
            semantics.onDevice.icon,
            semantics.onDevice.background,
            0.32,
          )!;
    final Color meshGlow = isDark
        ? Color.lerp(semantics.onDevice.background, scheme.primary, 0.60)!
        : Color.lerp(
            semantics.onDevice.icon,
            semantics.onDevice.background,
            0.58,
          )!;
    final Color meshHighlight = isDark
        ? Color.lerp(
            semantics.onDevice.background,
            scheme.primary,
            0.48,
          )!.withValues(alpha: 0.45)
        : semantics.onDevice.background;

    final Widget sourcePill = Tooltip(
      message: sourceActionTooltip,
      child: M3EButton(
        onPressed: onSourceAction,
        style: M3EButtonStyle.filled,
        size: M3EButtonSize.sm.copyWith(height: 36, hPadding: 13),
        shape: M3EButtonShape.round,
        decoration: M3EButtonDecoration(
          backgroundColor: WidgetStatePropertyAll<Color?>(
            isDark ? surfaces.cardElevated : surfaces.tactilePrimaryBg,
          ),
          foregroundColor: WidgetStatePropertyAll<Color?>(
            isDark ? scheme.onSurface : surfaces.tactilePrimaryFg,
          ),
          side: isDark
              ? WidgetStatePropertyAll<BorderSide?>(
                  BorderSide(color: surfaces.strongBorder, width: 1.2),
                )
              : null,
          textStyle: m3e.typography.emphasized.labelLarge,
          motion: M3EButtonMotion.expressiveSpatialPress,
          haptic: M3EHapticFeedback.light,
          borderRadius: 999,
          pressedRadius: 12,
        ),
        label: Text(sourceActionLabel),
      ),
    );

    final Widget voiceButton = Material(
      color: isSpeaking ? scheme.primary : surfaces.card,
      shape: CircleBorder(
        side: BorderSide(
          color: isSpeaking ? scheme.primary : surfaces.hairlineBorder,
          width: 1.2,
        ),
      ),
      child: IconButton(
        tooltip: voiceTooltip,
        onPressed: onVoiceAction,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        icon: Icon(
          isSpeaking ? LucideIcons.square : LucideIcons.volume2,
          size: 17,
          color: isSpeaking ? scheme.onPrimary : scheme.onSurface,
        ),
      ),
    );

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.elevated,
      backgroundColor: surfaces.card,
      borderRadius: BorderRadius.circular(28),
      lipHeight: 3.5,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Inset Organic Emerald-Teal Mesh Header + Overlapping Portrait
          SizedBox(
            height: bannerHeight + medallionOverlap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  bottom: medallionOverlap,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _OrganicTealMeshPainter(
                            baseColor: meshBase,
                            midColor: meshMid,
                            glowColor: meshGlow,
                            highlightColor: meshHighlight,
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 224),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaces.card.withValues(
                                    alpha: isDark ? 0.88 : 0.94,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: statePair.border.withValues(
                                      alpha: 0.72,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      stateIcon,
                                      size: 13.5,
                                      color: statePair.icon,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        stateBadgeLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: m3e.typeScale.labelSmall
                                            .copyWith(
                                              color: statePair.foreground,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                PositionedDirectional(
                  start: 14,
                  bottom: 0,
                  child: Container(
                    width: medallionDiameter,
                    height: medallionDiameter,
                    padding: const EdgeInsets.all(4.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surfaces.card,
                      boxShadow: [
                        BoxShadow(
                          color: surfaces.ambientShadowColor,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: medallionInnerBg,
                        border: Border.all(
                          color: surfaces.hairlineBorder.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                      child: Center(
                        child: DeniAnimatedMascot(
                          size: 70,
                          pose: mascotPose,
                          onTap: onMascotTap,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Identity Title/Subtitle + Quick Action Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool stackVertically =
                    isLargeScale || constraints.maxWidth < 250;

                final Widget identityColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      subjectTitle,
                      maxLines: isLargeScale ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: m3e.typography.emphasized.titleLarge.copyWith(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                        height: 1.18,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: isLargeScale ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: m3e.typeScale.bodySmall.copyWith(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        height: 1.28,
                      ),
                    ),
                  ],
                );

                final Widget actionsRow = Wrap(
                  spacing: 6,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [sourcePill, voiceButton],
                );

                if (stackVertically) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      identityColumn,
                      const SizedBox(height: 12),
                      actionsRow,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: identityColumn),
                    const SizedBox(width: 10),
                    actionsRow,
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Delicate Inset Hairline Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: 1,
            color: surfaces.hairlineBorder.withValues(alpha: 0.78),
          ),

          const SizedBox(height: 14),

          // Borderless 3-Column Tabular Metric Row Directly on Canvas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final List<Widget> metricColumns = [
                  _HeroMetricColumn(
                    iconSvg: Ph.file_text_duotone,
                    value: findingsCountValue,
                    label: findingsLabel,
                    iconColor: scheme.onSurface,
                    valueStyle: typeExt.tabularMetricMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                    labelStyle: m3e.typeScale.labelMedium.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLabelLines: isLargeScale ? 2 : 1,
                  ),
                  _HeroMetricColumn(
                    iconSvg: Ph.quotes_duotone,
                    value: verifiedCountValue,
                    label: verifiedLabel,
                    iconColor: scheme.onSurface,
                    valueStyle: typeExt.tabularMetricMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                    labelStyle: m3e.typeScale.labelMedium.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLabelLines: isLargeScale ? 2 : 1,
                  ),
                  _HeroMetricColumn(
                    iconSvg: hasPermissionReport
                        ? Ph.device_mobile_duotone
                        : Ph.question_duotone,
                    value: secondaryMetricValue,
                    label: secondaryMetricLabel,
                    iconColor: scheme.onSurface,
                    valueStyle: typeExt.tabularMetricMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                    labelStyle: m3e.typeScale.labelMedium.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLabelLines: isLargeScale ? 2 : 1,
                  ),
                ];

                if (isLargeScale || constraints.maxWidth < 260) {
                  return Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 20,
                    runSpacing: 12,
                    children: metricColumns,
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: metricColumns[0]),
                    const SizedBox(width: 8),
                    Expanded(child: metricColumns[1]),
                    const SizedBox(width: 8),
                    Expanded(child: metricColumns[2]),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // Full-Width Dark-Ink / Ceramic-Teal Pill CTA with Leading Circle Arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _HeroArrowPillButton(
              label: primaryCtaLabel,
              onPressed: onPrimaryCta,
              isDark: isDark,
              isLargeScale: isLargeScale,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricColumn extends StatelessWidget {
  final String iconSvg;
  final String value;
  final String label;
  final Color iconColor;
  final TextStyle valueStyle;
  final TextStyle labelStyle;
  final int maxLabelLines;

  const _HeroMetricColumn({
    required this.iconSvg,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.valueStyle,
    required this.labelStyle,
    required this.maxLabelLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: EnpriveDuotoneIcon(iconSvg, size: 17, color: iconColor),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: maxLabelLines,
          overflow: TextOverflow.ellipsis,
          style: labelStyle,
        ),
      ],
    );
  }
}

class _HeroArrowPillButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isLargeScale;

  const _HeroArrowPillButton({
    required this.label,
    required this.onPressed,
    required this.isDark,
    required this.isLargeScale,
  });

  @override
  State<_HeroArrowPillButton> createState() => _HeroArrowPillButtonState();
}

class _HeroArrowPillButtonState extends State<_HeroArrowPillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final Color bgBase = surfaces.tactilePrimaryBg;
    final Color bgHighlight = widget.isDark
        ? Color.lerp(bgBase, semantics.onDevice.background, 0.14)!
        : Color.lerp(bgBase, surfaces.cardMuted, 0.16)!;
    final Color fgColor = surfaces.tactilePrimaryFg;
    final Color badgeCircleBg = widget.isDark
        ? surfaces.tactilePrimaryFg
        : surfaces.card;
    final Color badgeArrowColor = surfaces.tactilePrimaryBg;

    const double lipHeight = 3.0;
    final double topMargin = _isPressed && !reduceMotion ? lipHeight : 0.0;
    final double currentLip = _isPressed && !reduceMotion ? 0.0 : lipHeight;
    final double radius = _isPressed && !reduceMotion ? 16.0 : 999.0;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.only(top: topMargin),
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 16, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [bgBase, bgHighlight, bgBase],
              stops: const [0.0, 0.56, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: surfaces.tactilePrimaryLip,
                offset: Offset(0, currentLip),
                blurRadius: 0,
              ),
              if (!widget.isDark)
                BoxShadow(
                  color: surfaces.ambientShadowColor,
                  offset: const Offset(0, 6),
                  blurRadius: 14,
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeCircleBg,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: badgeArrowColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: widget.isLargeScale ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: m3e.typography.emphasized.titleSmall.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
              ),
              if (!widget.isLargeScale) const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints an organic emerald-teal mesh gradient from semantic theme colors.
class _OrganicTealMeshPainter extends CustomPainter {
  final Color baseColor;
  final Color midColor;
  final Color glowColor;
  final Color highlightColor;

  const _OrganicTealMeshPainter({
    required this.baseColor,
    required this.midColor,
    required this.glowColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;

    // 1. Directional emerald-teal foundation sweep
    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseColor, midColor, glowColor],
        stops: const [0.0, 0.52, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, basePaint);

    // 2. Soft diagonal light ribbon sweeping across center-top
    final Rect ribbonRect = Rect.fromCircle(
      center: Offset(size.width * 0.56, size.height * 0.18),
      radius: size.width * 0.48,
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          colors: [
            highlightColor.withValues(alpha: 0.72),
            highlightColor.withValues(alpha: 0.18),
            highlightColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(ribbonRect),
    );

    // 3. Lower-right sunlit sage organic bloom
    final Rect lowerRightBloom = Rect.fromCircle(
      center: Offset(size.width * 0.84, size.height * 0.92),
      radius: size.width * 0.44,
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          colors: [
            highlightColor.withValues(alpha: 0.65),
            glowColor.withValues(alpha: 0.25),
            glowColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(lowerRightBloom),
    );

    // 4. Lower-left deep emerald anchor behind mascot overlap
    final Rect depthAnchor = Rect.fromCircle(
      center: Offset(size.width * 0.14, size.height * 0.82),
      radius: size.width * 0.42,
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          colors: [
            baseColor.withValues(alpha: 0.65),
            baseColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(depthAnchor),
    );
  }

  @override
  bool shouldRepaint(covariant _OrganicTealMeshPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.midColor != midColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.highlightColor != highlightColor;
  }
}
