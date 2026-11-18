import 'package:flutter/material.dart';

import '../../core/theme/enprive_theme.dart';

/// Builds an RTL-aware archival folder-tab [Path] with a raised top-start tab
/// transitioning via a smooth S-curve shoulder into a rounded card body.
Path _buildFolderTabPath(
  Size size, {
  required double cornerRadius,
  required double tabHeight,
  required double tabWidthFraction,
  required bool isRtl,
}) {
  final w = size.width;
  final h = size.height;
  final r = cornerRadius.clamp(10.0, (h - tabHeight) * 0.45).clamp(10.0, w * 0.25);
  final th = tabHeight.clamp(12.0, h * 0.35);
  final tabEnd = (w * tabWidthFraction.clamp(0.28, 0.56)).clamp(r + 24.0, w - r - 28.0);
  final shoulderSpan = (th * 1.45).clamp(22.0, (w - tabEnd - r).clamp(22.0, 44.0));
  final shoulderEnd = (tabEnd + shoulderSpan).clamp(tabEnd + 16.0, w - r);

  final path = Path()
    // Start below top-left corner of the raised tab
    ..moveTo(0, r)
    ..quadraticBezierTo(0, 0, r, 0)
    // Top edge of raised tab
    ..lineTo(tabEnd - r * 0.45, 0)
    // Smooth S-curve shoulder descending from tab top to main body top
    ..cubicTo(
      tabEnd + shoulderSpan * 0.22,
      0,
      tabEnd + shoulderSpan * 0.42,
      th,
      shoulderEnd,
      th,
    )
    // Top edge of main body to top-right corner
    ..lineTo(w - r, th)
    ..quadraticBezierTo(w, th, w, th + r)
    // Right edge to bottom-right corner
    ..lineTo(w, h - r)
    ..quadraticBezierTo(w, h, w - r, h)
    // Bottom edge to bottom-left corner
    ..lineTo(r, h)
    ..quadraticBezierTo(0, h, 0, h - r)
    ..close();

  if (!isRtl) return path;

  // Mirror horizontally for RTL so the raised tab sits cleanly at top-start.
  final mirror = Matrix4.identity()
    ..translateByDouble(w, 0.0, 0.0, 1.0)
    ..scaleByDouble(-1.0, 1.0, 1.0, 1.0);
  return path.transform(mirror.storage);
}

class _FolderTabClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double tabHeight;
  final double tabWidthFraction;
  final bool isRtl;

  const _FolderTabClipper({
    required this.cornerRadius,
    required this.tabHeight,
    required this.tabWidthFraction,
    required this.isRtl,
  });

  @override
  Path getClip(Size size) => _buildFolderTabPath(
    size,
    cornerRadius: cornerRadius,
    tabHeight: tabHeight,
    tabWidthFraction: tabWidthFraction,
    isRtl: isRtl,
  );

  @override
  bool shouldReclip(covariant _FolderTabClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.tabHeight != tabHeight ||
        oldClipper.tabWidthFraction != tabWidthFraction ||
        oldClipper.isRtl != isRtl;
  }
}

class _FolderTabBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final double tabHeight;
  final double tabWidthFraction;
  final bool isRtl;

  const _FolderTabBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.cornerRadius,
    required this.tabHeight,
    required this.tabWidthFraction,
    required this.isRtl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildFolderTabPath(
      size,
      cornerRadius: cornerRadius,
      tabHeight: tabHeight,
      tabWidthFraction: tabWidthFraction,
      isRtl: isRtl,
    );
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FolderTabBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.tabHeight != tabHeight ||
        oldDelegate.tabWidthFraction != tabWidthFraction ||
        oldDelegate.isRtl != isRtl;
  }
}

/// Material 3 Expressive Archival Folder-Tab Card inspired by Enprive's
/// tactile paper-tab identity and muted editorial tonal containers.
///
/// Uses strictly `EnpriveM3ETheme` (`M3EColorScheme`, `EnpriveSurfaceTokens`,
/// `EnpriveSemanticColors`) with automatic RTL tab mirroring, `MediaQuery`
/// reduced-motion compliance, and high-contrast circular icon medallions.
class EnpriveFolderTabCard extends StatefulWidget {
  final Color backgroundColor;
  final Color? borderColor;
  final IconData? leadingIcon;
  final Color? iconBadgeColor;
  final Color? iconColor;
  final Widget? trailingHeader;
  final Widget child;
  final VoidCallback? onTap;
  final double cornerRadius;
  final double tabHeight;
  final double tabWidthFraction;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  const EnpriveFolderTabCard({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.borderColor,
    this.leadingIcon,
    this.iconBadgeColor,
    this.iconColor,
    this.trailingHeader,
    this.onTap,
    this.cornerRadius = 24,
    this.tabHeight = 20,
    this.tabWidthFraction = 0.44,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
    this.semanticLabel,
  });

  @override
  State<EnpriveFolderTabCard> createState() => _EnpriveFolderTabCardState();
}

class _EnpriveFolderTabCardState extends State<EnpriveFolderTabCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final reduceMotion = EnpriveMotionTokens.isReducedMotion(context);

    final resolvedBorder = widget.borderColor ?? surfaces.hairlineBorder;
    final resolvedBadgeBg =
        widget.iconBadgeColor ??
        (isDark ? scheme.surfaceContainerLowest : scheme.onSurface);
    final resolvedIconFg =
        widget.iconColor ?? (isDark ? scheme.primary : scheme.surface);

    final cardContent = Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leadingIcon != null || widget.trailingHeader != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.leadingIcon != null)
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: resolvedBadgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.leadingIcon,
                      size: 19,
                      color: resolvedIconFg,
                    ),
                  ),
                const Spacer(),
                if (widget.trailingHeader != null)
                  Padding(
                    padding: EdgeInsets.only(top: widget.tabHeight * 0.72),
                    child: widget.trailingHeader!,
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ] else
            SizedBox(height: widget.tabHeight * 0.55),
          widget.child,
        ],
      ),
    );

    final clippedCard = CustomPaint(
      foregroundPainter: _FolderTabBorderPainter(
        borderColor: resolvedBorder,
        borderWidth: 1.0,
        cornerRadius: widget.cornerRadius,
        tabHeight: widget.tabHeight,
        tabWidthFraction: widget.tabWidthFraction,
        isRtl: isRtl,
      ),
      child: ClipPath(
        clipper: _FolderTabClipper(
          cornerRadius: widget.cornerRadius,
          tabHeight: widget.tabHeight,
          tabWidthFraction: widget.tabWidthFraction,
          isRtl: isRtl,
        ),
        child: Material(
          color: widget.backgroundColor,
          child: widget.onTap != null
              ? InkWell(
                  onTap: widget.onTap,
                  onHighlightChanged: (v) {
                    if (mounted) setState(() => _pressed = v);
                  },
                  splashColor: scheme.primary.withValues(alpha: 0.10),
                  highlightColor: scheme.primary.withValues(alpha: 0.05),
                  child: cardContent,
                )
              : cardContent,
        ),
      ),
    );

    final body = reduceMotion
        ? clippedCard
        : AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: context.enpriveMotion.spatialFast,
            curve: Curves.easeOutCubic,
            child: clippedCard,
          );

    if (widget.semanticLabel != null && widget.semanticLabel!.isNotEmpty) {
      return Semantics(
        container: true,
        button: widget.onTap != null,
        enabled: widget.onTap != null ? true : null,
        label: widget.semanticLabel,
        onTap: widget.onTap,
        excludeSemantics: widget.onTap != null,
        child: body,
      );
    }
    return body;
  }
}

/// Layered archival folder deck displaying 2 subtle peeking folder-tab sheets
/// behind a front [EnpriveFolderTabCard] surface.
class EnpriveStackedFolderDeck extends StatelessWidget {
  final Widget child;
  final Color? frontColor;
  final Color? frontBorderColor;
  final Color? middleLayerColor;
  final Color? backLayerColor;
  final double cornerRadius;
  final EdgeInsetsGeometry padding;

  const EnpriveStackedFolderDeck({
    super.key,
    required this.child,
    this.frontColor,
    this.frontBorderColor,
    this.middleLayerColor,
    this.backLayerColor,
    this.cornerRadius = 26,
    this.padding = const EdgeInsets.fromLTRB(18, 22, 18, 18),
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final resolvedBack = backLayerColor ?? semantics.reviewRecommended.background;
    final resolvedMiddle = middleLayerColor ?? semantics.onDevice.background;
    final resolvedFront = frontColor ?? surfaces.card;
    final resolvedFrontBorder = frontBorderColor ?? surfaces.hairlineBorder;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 14,
          right: 14,
          height: 54,
          child: IgnorePointer(
            child: CustomPaint(
              foregroundPainter: _FolderTabBorderPainter(
                borderColor: scheme.outlineVariant.withValues(alpha: 0.55),
                borderWidth: 1.0,
                cornerRadius: cornerRadius - 4,
                tabHeight: 16,
                tabWidthFraction: 0.42,
                isRtl: isRtl,
              ),
              child: ClipPath(
                clipper: _FolderTabClipper(
                  cornerRadius: cornerRadius - 4,
                  tabHeight: 16,
                  tabWidthFraction: 0.42,
                  isRtl: isRtl,
                ),
                child: ColoredBox(color: resolvedBack),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 7,
          right: 7,
          height: 54,
          child: IgnorePointer(
            child: CustomPaint(
              foregroundPainter: _FolderTabBorderPainter(
                borderColor: scheme.outlineVariant.withValues(alpha: 0.65),
                borderWidth: 1.0,
                cornerRadius: cornerRadius - 2,
                tabHeight: 16,
                tabWidthFraction: 0.44,
                isRtl: isRtl,
              ),
              child: ClipPath(
                clipper: _FolderTabClipper(
                  cornerRadius: cornerRadius - 2,
                  tabHeight: 16,
                  tabWidthFraction: 0.44,
                  isRtl: isRtl,
                ),
                child: ColoredBox(color: resolvedMiddle),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: EnpriveFolderTabCard(
            backgroundColor: resolvedFront,
            borderColor: resolvedFrontBorder,
            cornerRadius: cornerRadius,
            tabHeight: 18,
            tabWidthFraction: 0.44,
            padding: padding,
            child: child,
          ),
        ),
      ],
    );
  }
}
