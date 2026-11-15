import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../services/platform/hybrid_ai_bridge.dart';

/// Displays an installed Android application's original launcher icon loaded
/// strictly on-device via [HybridAiBridge.getAppIcon], falling back cleanly to
/// a tonal Enprive tile when running headless or when no icon is available.
class InstalledAppIcon extends StatefulWidget {
  final String packageName;
  final HybridAiBridge bridge;
  final Uint8List? initialBytes;
  final double size;
  final double borderRadius;

  const InstalledAppIcon({
    super.key,
    required this.packageName,
    required this.bridge,
    this.initialBytes,
    this.size = 42,
    this.borderRadius = 12,
  });

  @override
  State<InstalledAppIcon> createState() => _InstalledAppIconState();
}

class _InstalledAppIconState extends State<InstalledAppIcon> {
  Uint8List? _iconBytes;
  bool _decodeFailed = false;

  @override
  void initState() {
    super.initState();
    _syncOrFetchIcon();
  }

  @override
  void didUpdateWidget(covariant InstalledAppIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName ||
        oldWidget.bridge != widget.bridge ||
        oldWidget.initialBytes != widget.initialBytes) {
      _decodeFailed = false;
      _syncOrFetchIcon();
    }
  }

  void _syncOrFetchIcon() {
    final immediate =
        widget.initialBytes ?? widget.bridge.cachedAppIcon(widget.packageName);
    _iconBytes = immediate;
    if (immediate != null ||
        widget.bridge.hasCachedAppIcon(widget.packageName)) {
      return;
    }
    _fetchIcon();
  }

  Future<void> _fetchIcon() async {
    final targetPackage = widget.packageName;
    final targetSizePx = (widget.size * 3).round().clamp(48, 192);
    final bytes = await widget.bridge.getAppIcon(
      targetPackage,
      sizePx: targetSizePx,
    );
    if (!mounted || widget.packageName != targetPackage) return;
    if (bytes != null && bytes.isNotEmpty) {
      setState(() {
        _iconBytes = bytes;
        _decodeFailed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = EnpriveM3ETheme.of(context).colorScheme;
    final semantics = context.enpriveSemantics;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final radius = BorderRadius.circular(widget.borderRadius);

    final bytes = _iconBytes;
    final showNativeIcon =
        bytes != null && bytes.isNotEmpty && !_decodeFailed;

    final Widget content = showNativeIcon
        ? Container(
            key: ValueKey('icon_${widget.packageName}'),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLowest,
              borderRadius: radius,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: scheme.outlineVariant.withValues(
                  alpha: isDark ? 0.35 : 0.45,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Image.memory(
                bytes,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) {
                  if (mounted && !_decodeFailed) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _decodeFailed = true);
                      }
                    });
                  }
                  return _FallbackIconTile(
                    size: widget.size,
                    radius: radius,
                    semantics: semantics,
                  );
                },
              ),
            ),
          )
        : _FallbackIconTile(
            key: ValueKey('fallback_${widget.packageName}'),
            size: widget.size,
            radius: radius,
            semantics: semantics,
          );

    return Semantics(
      excludeSemantics: true,
      child: reduceMotion
          ? content
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              switchInCurve: Curves.easeOutCubic,
              child: content,
            ),
    );
  }
}

class _FallbackIconTile extends StatelessWidget {
  final double size;
  final BorderRadius radius;
  final EnpriveSemanticColors semantics;

  const _FallbackIconTile({
    super.key,
    required this.size,
    required this.radius,
    required this.semantics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: semantics.onDevice.background,
        borderRadius: radius,
      ),
      child: Icon(
        LucideIcons.layoutGrid,
        color: semantics.onDevice.foreground,
        size: size * 0.48,
      ),
    );
  }
}
