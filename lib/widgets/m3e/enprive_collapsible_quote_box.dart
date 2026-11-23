import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/enprive_theme.dart';
import '../../l10n/app_localizations.dart';
import 'enprive_material_card_surface.dart';

/// Collapsible verbatim quotation & FNV-1a 64-bit snapshot digest container designed for
/// `WhyThisFindingSheet` and detailed policy clause inspection.
///
/// Automatically collapses to a compact 1-line bar when [autoCollapseTrigger]
/// transitions from `false` to `true` (keeping the answer in view without
/// losing access to the exact cited evidence).
class EnpriveCollapsibleQuoteBox extends StatefulWidget {
  final String quote;
  final String badgeLabel;
  final String? headerLabel;
  final String? sha256Digest;
  final bool initiallyExpanded;
  final bool autoCollapseTrigger;

  const EnpriveCollapsibleQuoteBox({
    super.key,
    required this.quote,
    this.badgeLabel = 'Q1',
    this.headerLabel,
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
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final typeExt = context.enpriveType;
    final motion = context.enpriveMotion;

    return EnpriveMaterialCardSurface(
      variant: EnpriveCardVariant.archival,
      backgroundColor: surfaces.quoteSurface,
      borderRadius: BorderRadius.circular(20),
      lipHeight: 2.5,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: 0,
            width: 4,
            child: ColoredBox(color: scheme.primary),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _toggleExpanded,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.badgeLabel,
                            style: m3e.typography.emphasized.labelSmall
                                .copyWith(
                                  color: scheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.headerLabel ??
                                l10n.quoteCollapsibleDefaultHeader,
                            style: m3e.typography.emphasized.titleSmall
                                .copyWith(color: scheme.onSurface),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0.0,
                          duration: motion.effectiveDuration(
                            context,
                            motion.spatialFast,
                          ),
                          curve: motion.effectiveCurve(
                            context,
                            motion.emphasizedCurve,
                          ),
                          child: Icon(
                            LucideIcons.chevronDown,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: motion.effectiveDuration(
                    context,
                    motion.effectsDefault,
                  ),
                  curve: motion.effectiveCurve(context, motion.emphasizedCurve),
                  child: _isExpanded
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '“${widget.quote}”',
                                style: typeExt.policyQuotation.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                              if (widget.sha256Digest != null &&
                                  widget.sha256Digest!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surfaces.card.withValues(
                                      alpha: 0.72,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: surfaces.hairlineBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${l10n.snapshotDigestLabel} · ${widget.sha256Digest}',
                                          style: typeExt.sha256Hash.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(6),
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: widget.sha256Digest!,
                                            ),
                                          );
                                          ScaffoldMessenger.maybeOf(context)
                                            ?..hideCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.digestCopiedMsg,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
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
                                ),
                              ],
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
