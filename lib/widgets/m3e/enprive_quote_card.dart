import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';
import 'enprive_material_card_surface.dart';

/// Archival Material 3 Expressive policy quotation card inspired by Warm
/// Archival Paper editorial sheets and Enprive's `SourceSerif4` typography.
///
/// Supports:
/// - Plain or selectable ([SelectableText]) verbatim quotation text with **no**
///   internal scroll containers (complies with `android-design` card rules).
/// - Context-window highlighting (`before` + highlighted `matched` + `after`)
///   for [WhyThisFindingSheet].
/// - Left vertical archival spine accent (`3.5dp`), optional verification
///   header strip, and optional `FNV-1a 64-bit` monospace snapshot digest footer.
class EnpriveQuoteCard extends StatelessWidget {
  final String? quote;
  final ({String before, String matched, String after})? contextWindow;
  final String? statusLabel;
  final String? categoryLabel;
  final Color? spineColor;
  final String? sha256Digest;
  final String? footerCaption;
  final bool selectable;
  final int? maxLines;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const EnpriveQuoteCard({
    super.key,
    this.quote,
    this.contextWindow,
    this.statusLabel,
    this.categoryLabel,
    this.spineColor,
    this.sha256Digest,
    this.footerCaption,
    this.selectable = false,
    this.maxLines,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.padding = const EdgeInsets.all(18),
  }) : assert(
         quote != null || contextWindow != null,
         'Either quote or contextWindow must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;
    final typeExt = context.enpriveType;

    final Color effectiveSpine = spineColor ?? scheme.primary;
    final bool hasHeader =
        (statusLabel != null && statusLabel!.trim().isNotEmpty) ||
        (categoryLabel != null && categoryLabel!.trim().isNotEmpty);
    final bool hasFooter =
        (sha256Digest != null && sha256Digest!.trim().isNotEmpty) ||
        (footerCaption != null && footerCaption!.trim().isNotEmpty);

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.archival,
      backgroundColor: surfaces.quoteSurface,
      borderRadius: borderRadius,
      lipHeight: 2.5,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Rounded inset archival bookmark spine without IntrinsicHeight overhead
          PositionedDirectional(
            top: 14,
            bottom: 14,
            start: 12,
            width: 3.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: effectiveSpine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasHeader) ...[
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (statusLabel != null &&
                              statusLabel!.trim().isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.quote,
                                  size: 14,
                                  color: effectiveSpine,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    statusLabel!,
                                    overflow: TextOverflow.ellipsis,
                                    style: m3e.typography.emphasized.labelMedium
                                        .copyWith(
                                          color: scheme.onSurface,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          if (categoryLabel != null &&
                              categoryLabel!.trim().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: surfaces.card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: surfaces.hairlineBorder,
                                ),
                              ),
                              child: Text(
                                categoryLabel!,
                                style: m3e.typeScale.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildQuotationText(
                    context,
                    scheme: scheme,
                    semantics: semantics,
                    typeExt: typeExt,
                  ),
                  if (hasFooter) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: surfaces.card.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: surfaces.hairlineBorder),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (sha256Digest != null &&
                              sha256Digest!.trim().isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.fingerprintPattern,
                                  size: 13,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Snapshot digest · FNV-1a 64-bit · $sha256Digest',
                                    overflow: TextOverflow.ellipsis,
                                    style: typeExt.sha256Hash.copyWith(
                                      fontSize: 11.5,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: sha256Digest!),
                                    );
                                    ScaffoldMessenger.maybeOf(context)
                                      ?..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Snapshot digest copied',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      LucideIcons.copy,
                                      size: 13,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (footerCaption != null &&
                              footerCaption!.trim().isNotEmpty)
                            Text(
                              footerCaption!,
                              style: m3e.typeScale.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationText(
    BuildContext context, {
    required M3EColorScheme scheme,
    required EnpriveSemanticColors semantics,
    required EnpriveTypographyExtension typeExt,
  }) {
    final TextStyle quoteStyle = typeExt.policyQuotation.copyWith(
      fontSize: 14.5,
      height: 1.56,
      color: scheme.onSurface,
    );

    if (contextWindow != null && !selectable) {
      return Text.rich(
        TextSpan(
          style: quoteStyle.copyWith(color: scheme.onSurfaceVariant),
          children: [
            TextSpan(text: contextWindow!.before),
            TextSpan(
              text: contextWindow!.matched,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
                backgroundColor: semantics.reviewRecommended.background,
              ),
            ),
            TextSpan(text: contextWindow!.after),
          ],
        ),
        maxLines: maxLines,
        overflow: maxLines != null
            ? TextOverflow.ellipsis
            : TextOverflow.clip,
      );
    }

    final String rawQuote = quote ?? contextWindow?.matched ?? '';
    if (selectable) {
      final tokenPattern = RegExp(
        r'\[(?:EMAIL|PHONE|IP_ADDRESS|ADDRESS|PERSON|ID|REDACTED_[A-Z0-9_]+)\]',
      );
      final matches = tokenPattern.allMatches(rawQuote).toList();
      if (matches.isEmpty) {
        return SelectableText(
          rawQuote,
          style: quoteStyle,
        );
      }

      final semantics = context.enpriveSemantics;
      final spans = <InlineSpan>[];
      var cursor = 0;
      for (final match in matches) {
        if (match.start > cursor) {
          spans.add(TextSpan(text: rawQuote.substring(cursor, match.start)));
        }
        spans.add(
          TextSpan(
            text: match.group(0),
            style: quoteStyle.copyWith(
              fontFamily: 'Inter',
              fontSize: 13.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.25,
              color: semantics.inCloud.foreground,
              backgroundColor: semantics.inCloud.background,
            ),
          ),
        );
        cursor = match.end;
      }
      if (cursor < rawQuote.length) {
        spans.add(TextSpan(text: rawQuote.substring(cursor)));
      }
      return SelectableText.rich(
        TextSpan(style: quoteStyle, children: spans),
      );
    }

    return Text(
      '“$rawQuote”',
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
      style: quoteStyle,
    );
  }
}
