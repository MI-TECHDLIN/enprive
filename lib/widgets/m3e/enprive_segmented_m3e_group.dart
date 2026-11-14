import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

/// Descriptor for an individual item inside [EnpriveSegmentedM3EGroup].
class EnpriveSegmentedM3EItem {
  final Widget? leading;
  final String? overline;
  final String title;
  final String? supportingText;
  final String? trailingMeta;
  final Widget? trailing;
  final VoidCallback? onTap;

  const EnpriveSegmentedM3EItem({
    this.leading,
    this.overline,
    required this.title,
    this.supportingText,
    this.trailingMeta,
    this.trailing,
    this.onTap,
  });
}

/// Reusable Material 3 Expressive segmented containment list (`20dp` outer
/// corners, `4dp` inner seam corners) wrapping [M3EList] and [M3EListItem].
class EnpriveSegmentedM3EGroup extends StatelessWidget {
  final String? sectionTitle;
  final String? sectionSubtitle;
  final List<EnpriveSegmentedM3EItem> items;

  const EnpriveSegmentedM3EGroup({
    super.key,
    this.sectionTitle,
    this.sectionSubtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sectionTitle != null && sectionTitle!.isNotEmpty) ...[
          Text(
            sectionTitle!,
            style: m3e.typography.emphasized.titleMedium.copyWith(
              color: scheme.onSurface,
            ),
          ),
          if (sectionSubtitle != null && sectionSubtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              sectionSubtitle!,
              style: m3e.typeScale.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
        ],
        M3EList(
          outerRadius: 20,
          innerRadius: 4,
          gap: 3,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return M3EListItem(
              leading: item.leading,
              overline: item.overline,
              headline: item.title,
              supportingText: item.supportingText,
              trailingText: item.trailingMeta,
              trailing: item.trailing,
              onTap: item.onTap,
            );
          },
        ),
      ],
    );
  }
}
