import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';

/// Accessible, high-contrast Material 3 Expressive filter chip built on [M3EChip].
///
/// Addresses visual distinguishability, `48dp` minimum touch targets, and
/// Android TalkBack semantics while strictly preserving Enprive's Light
/// ("Warm Archival Paper") and Dark ("Obsidian Ceramic Slate") design tokens.
class EnpriveFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final Widget? leading;
  final String? semanticLabel;
  final FocusNode? focusNode;

  const EnpriveFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.leading,
    this.semanticLabel,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final surfaces = context.enpriveSurfaces;

    // Derive selected/unselected roles from Enprive's semantic surface tokens
    // so active filters read clearly in both Warm Archival Paper & Obsidian Slate
    // without hardcoding colors or mutating global NavigationBar indicator roles.
    final scopedScheme = m3e.colorScheme.copyWith(
      secondaryContainer: surfaces.tactilePrimaryBg,
      onSecondaryContainer: surfaces.tactilePrimaryFg,
      outlineVariant: surfaces.strongBorder,
    );
    final scopedTheme = m3e.copyWith(
      colorScheme: scopedScheme,
      chipTheme: m3e.chipTheme.copyWith(
        height: 36,
        cornerRadius: 12,
        outlineWidth: 1.2,
      ),
    );

    final isEnabled = onPressed != null;

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      enabled: isEnabled,
      label: semanticLabel ?? label,
      onTap: onPressed,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: EnpriveSpacing.minTouchTarget,
            minHeight: EnpriveSpacing.minTouchTarget,
          ),
          child: Center(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: M3ETheme(
              data: scopedTheme,
              child: M3EChip(
                label: label,
                type: M3EChipType.filter,
                selected: selected,
                leading: selected
                    ? const Icon(LucideIcons.check, size: 16)
                    : leading,
                onPressed: onPressed,
                focusNode: focusNode,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
