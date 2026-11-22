import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/enprive_theme.dart';

/// One option of an [EnpriveConnectedButtonGroup].
@immutable
class EnpriveGroupOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Key? key;

  const EnpriveGroupOption({
    required this.value,
    required this.label,
    this.icon,
    this.key,
  });
}

/// Material 3 Expressive connected button group for choosing one option
/// within a screen (theme, explanation depth).
///
/// Items sit side by side with 2dp gaps and small inner corners; the selected
/// item takes the `secondaryContainer` fill, a check icon and full pill
/// corners, so selection never relies on color alone. Each item is a 48dp
/// radio-style target announced with its selected state. When the labels no
/// longer fit (large text), the group stacks vertically.
class EnpriveConnectedButtonGroup<T> extends StatelessWidget {
  final List<EnpriveGroupOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  const EnpriveConnectedButtonGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  static const double _gap = 2;
  static const double _outer = 24;
  static const double _inner = 8;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack =
            textScale > 1.3 || constraints.maxWidth / options.length < 104;
        final children = <Widget>[
          for (var i = 0; i < options.length; i++)
            _GroupItem<T>(
              key: options[i].key,
              option: options[i],
              isSelected: options[i].value == selected,
              radius: _radiusFor(i, stack),
              onTap: () => onSelected(options[i].value),
            ),
        ];
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: _gap),
                children[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }

  BorderRadiusDirectional _radiusFor(int index, bool stack) {
    final first = index == 0;
    final last = index == options.length - 1;
    const outer = Radius.circular(_outer);
    const inner = Radius.circular(_inner);
    if (stack) {
      return BorderRadiusDirectional.only(
        topStart: first ? outer : inner,
        topEnd: first ? outer : inner,
        bottomStart: last ? outer : inner,
        bottomEnd: last ? outer : inner,
      );
    }
    return BorderRadiusDirectional.only(
      topStart: first ? outer : inner,
      bottomStart: first ? outer : inner,
      topEnd: last ? outer : inner,
      bottomEnd: last ? outer : inner,
    );
  }
}

class _GroupItem<T> extends StatelessWidget {
  final EnpriveGroupOption<T> option;
  final bool isSelected;
  final BorderRadiusDirectional radius;
  final VoidCallback onTap;

  const _GroupItem({
    super.key,
    required this.option,
    required this.isSelected,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final resolvedRadius = isSelected
        ? BorderRadius.circular(_GroupItemShape.selected)
        : radius.resolve(Directionality.of(context));
    final ink = isSelected ? scheme.onSecondaryContainer : scheme.onSurface;

    return Semantics(
      container: true,
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: isSelected,
      label: option.label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: resolvedRadius,
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : EnpriveSpringCurve.fastSpatial.duration,
            curve: EnpriveSpringCurve.fastSpatial,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.secondaryContainer
                  : scheme.surfaceContainerHigh,
              borderRadius: resolvedRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? LucideIcons.check : option.icon,
                  size: 18,
                  color: ink,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style:
                        (isSelected
                                ? m3e.typography.emphasized.labelLarge
                                : m3e.typeScale.labelLarge)
                            .copyWith(color: ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class _GroupItemShape {
  static const double selected = 28;
}
