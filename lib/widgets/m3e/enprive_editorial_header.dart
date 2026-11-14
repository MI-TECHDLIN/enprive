import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

/// Two-tone Material 3 Expressive editorial header inspired by the
/// "Music OS" and M3E Polygon reference boards.
///
/// Pairs an emphasized primary headline in `onSurface` with a secondary
/// tonal line in `onSurfaceVariant`, plus an optional overline badge and
/// trailing action widget.
class EnpriveEditorialHeader extends StatelessWidget {
  final String primaryLine;
  final String? secondaryLine;
  final String? overline;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const EnpriveEditorialHeader({
    super.key,
    required this.primaryLine,
    this.secondaryLine,
    this.overline,
    this.trailing,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (overline != null && overline!.isNotEmpty) ...[
                  Text(
                    overline!.toUpperCase(),
                    style: m3e.typography.emphasized.labelSmall.copyWith(
                      color: scheme.primary,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                RichText(
                  text: TextSpan(
                    style: m3e.typography.emphasized.headlineMedium.copyWith(
                      color: scheme.onSurface,
                      height: 1.15,
                    ),
                    children: [
                      TextSpan(text: primaryLine),
                      if (secondaryLine != null && secondaryLine!.isNotEmpty)
                        TextSpan(
                          text: '\n$secondaryLine',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
