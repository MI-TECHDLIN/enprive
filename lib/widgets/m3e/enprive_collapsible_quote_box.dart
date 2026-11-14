import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';

/// Collapsible verbatim quotation & SHA-256 evidence container designed for
/// `WhyThisFindingSheet` and detailed policy clause views.
///
/// Automatically collapses to a compact 1-line bar when [autoCollapseTrigger]
/// switches to `true` (e.g., when Deni starts streaming an answer), keeping
/// the user's streamed explanation above the fold while still allowing manual
/// expand/collapse at any time.
class EnpriveCollapsibleQuoteBox extends StatefulWidget {
  final String quote;
  final String badgeLabel;
  final String headerLabel;
  final String? sha256Digest;
  final bool initiallyExpanded;
  final bool autoCollapseTrigger;

  const EnpriveCollapsibleQuoteBox({
    super.key,
    required this.quote,
    this.badgeLabel = 'Q1',
    this.headerLabel = 'Exact Policy Excerpt',
    this.sha256Digest,
    this.initiallyExpanded = true,
    this.autoCollapseTrigger = false,
  });

  @override
  State<EnpriveCollapsibleQuoteBox> createState() =>
      _EnpriveCollapsibleQuoteBoxState();
}

class _EnpriveCollapsibleQuoteBoxState
    extends State<EnpriveCollapsibleQuoteBox> {
  late bool _isExpanded = widget.initiallyExpanded;

  @override
  void didUpdateWidget(covariant EnpriveCollapsibleQuoteBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.autoCollapseTrigger &&
        widget.autoCollapseTrigger &&
        _isExpanded) {
      setState(() => _isExpanded = false);
    }
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final m3e = M3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final typeExt = context.enpriveType;
    final motion = context.enpriveMotion;

    return M3ECard(
      color: surfaces.quoteCallout,
      borderRadius: BorderRadius.circular(20),
      border: BorderSide(color: surfaces.hairlineBorder),
      padding: const EdgeInsets.all(14),
      onPressed: _toggleExpanded,
      child: AnimatedSize(
        duration: motion.effectiveDuration(context, motion.standardDuration),
        curve: motion.effectiveCurve(context, motion.emphasizedCurve),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.badgeLabel,
                    style: m3e.typography.emphasized.labelSmall.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.headerLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: m3e.typography.emphasized.labelLarge.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isExpanded) ...[
              Text(
                '“${widget.quote.trim()}”',
                style: typeExt.policyQuotation,
              ),
              if (widget.sha256Digest != null &&
                  widget.sha256Digest!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'SHA-256 · ${widget.sha256Digest}',
                  style: typeExt.sha256Hash,
                ),
              ],
            ] else
              Text(
                '“${widget.quote.trim()}”',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typeExt.policyQuotation.copyWith(fontSize: 13.5),
              ),
          ],
        ),
      ),
    );
  }
}
