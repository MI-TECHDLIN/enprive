import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/privacy/pii_redactor.dart';
import '../l10n/app_localizations.dart';
import 'deni_animated_mascot.dart';
import 'enprive_tactile_button.dart';
import 'm3e/enprive_m3e_components.dart';

enum CloudConsentDecision {
  reviewLocally,
  useCloudOnce,
  cancelled,
}

/// Consent dialog shown before any policy snippet can leave the device.
///
/// Features pinned top navigation & bottom action bars, `useSafeArea: true`,
/// reactive Material 3 Expressive surface styling across light & dark themes,
/// accurate upward directional copy ("shown above"), and a full selectable
/// scrubbed preview matching the exact cloud payload with M3E styling on
/// masked placeholder tokens.
class CloudConsentSheet extends StatelessWidget {
  final String subjectTitle;
  final String policyText;
  final String? deviceReason;

  const CloudConsentSheet({
    super.key,
    required this.subjectTitle,
    required this.policyText,
    this.deviceReason,
  });

  static Future<CloudConsentDecision> show(
    BuildContext context, {
    required String subjectTitle,
    required String policyText,
    String? deviceReason,
  }) async {
    final decision = await showModalBottomSheet<CloudConsentDecision>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CloudConsentSheet(
        subjectTitle: subjectTitle,
        policyText: policyText,
        deviceReason: deviceReason,
      ),
    );
    return decision ?? CloudConsentDecision.cancelled;
  }

  static final RegExp _tokenPattern = RegExp(
    r'\[(?:EMAIL|PHONE|IP_ADDRESS|ADDRESS|PERSON|ID|REDACTED_[A-Z0-9_]+)\]',
  );

  @override
  Widget build(BuildContext context) {
    return EnpriveM3EBridgeScope.ensure(
      context,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context) ??
              lookupAppLocalizations(const Locale('en'));
          final m3e = EnpriveM3ETheme.of(context);
          final scheme = m3e.colorScheme;
          final semantics = context.enpriveSemantics;
          final surfaces = context.enpriveSurfaces;

          final redaction = PiiRedactor.redact(policyText);
          final scrubbedPreview = redaction.redactedText.trim();
          final trimmedReason = deviceReason?.trim();
          final detectedTokens = _tokenPattern
              .allMatches(scrubbedPreview)
              .map((m) => m.group(0)!)
              .toSet()
              .toList(growable: false);

          final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.92;

          return SafeArea(
            top: true,
            bottom: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
              child: Material(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pinned header bar (never scrolls off or collides with status bar)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: scheme.outlineVariant,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const DeniAnimatedMascot(
                                size: 42,
                                pose: DeniPose.explaining,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.chooseReviewModeTitle,
                                      style: m3e.typography.emphasized.titleMedium
                                          .copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: scheme.onSurface,
                                          ),
                                    ),
                                    if (subjectTitle.trim().isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        subjectTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: m3e.typeScale.labelMedium
                                            .copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.tooltipClose,
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                onPressed: () => Navigator.pop(
                                  context,
                                  CloudConsentDecision.cancelled,
                                ),
                                icon: Icon(
                                  LucideIcons.x,
                                  size: 20,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: surfaces.hairlineBorder),

                    // Scrollable scrubbed cloud payload preview & disclosure
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (trimmedReason != null &&
                                trimmedReason.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: semantics.unknown.background,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: semantics.unknown.border,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      LucideIcons.info,
                                      size: 18,
                                      color: semantics.unknown.foreground,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        trimmedReason,
                                        style: m3e.typeScale.bodySmall.copyWith(
                                          color: semantics.unknown.foreground,
                                          height: 1.4,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            if (detectedTokens.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final token in detectedTokens)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: semantics.inCloud.background,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: semantics.inCloud.border,
                                        ),
                                      ),
                                      child: Text(
                                        token,
                                        style: m3e.typeScale.labelSmall
                                            .copyWith(
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  semantics.inCloud.foreground,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            EnpriveQuoteCard(
                              quote: scrubbedPreview,
                              selectable: true,
                              statusLabel: detectedTokens.isEmpty
                                  ? 'No PII found'
                                  : 'Masked (${redaction.replacementCount})',
                              categoryLabel: 'Exact cloud payload',
                              spineColor: semantics.inCloud.foreground,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.cloudConsentDisclosure,
                              style: m3e.typeScale.bodySmall.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(height: 1, color: surfaces.hairlineBorder),
                    // Pinned consent action bar
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            EnpriveTactileButton(
                              label: l10n.btnUseCloud,
                              onPressed: () => Navigator.pop(
                                context,
                                CloudConsentDecision.useCloudOnce,
                              ),
                            ),
                            const SizedBox(height: 10),
                            EnpriveTactileButton(
                              label: l10n.btnReviewOnPhone,
                              isSecondary: true,
                              onPressed: () => Navigator.pop(
                                context,
                                CloudConsentDecision.reviewLocally,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
