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
  final String? canonicalRedactedPreview;
  final String? deviceReason;
  final String? titleOverride;
  final String? disclosureOverride;
  final String? primaryActionLabelOverride;
  final String? secondaryActionLabelOverride;
  final String? payloadCategoryLabelOverride;

  const CloudConsentSheet({
    super.key,
    required this.subjectTitle,
    required this.policyText,
    this.canonicalRedactedPreview,
    this.deviceReason,
    this.titleOverride,
    this.disclosureOverride,
    this.primaryActionLabelOverride,
    this.secondaryActionLabelOverride,
    this.payloadCategoryLabelOverride,
  });

  static Future<CloudConsentDecision> show(
    BuildContext context, {
    required String subjectTitle,
    required String policyText,
    String? canonicalRedactedPreview,
    String? deviceReason,
    String? titleOverride,
    String? disclosureOverride,
    String? primaryActionLabelOverride,
    String? secondaryActionLabelOverride,
    String? payloadCategoryLabelOverride,
  }) async {
    final decision = await showModalBottomSheet<CloudConsentDecision>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CloudConsentSheet(
        subjectTitle: subjectTitle,
        policyText: policyText,
        canonicalRedactedPreview: canonicalRedactedPreview,
        deviceReason: deviceReason,
        titleOverride: titleOverride,
        disclosureOverride: disclosureOverride,
        primaryActionLabelOverride: primaryActionLabelOverride,
        secondaryActionLabelOverride: secondaryActionLabelOverride,
        payloadCategoryLabelOverride: payloadCategoryLabelOverride,
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

          // Use the single canonical redacted payload unchanged when provided
          // so preview and cloud bridge payloads stay byte-for-byte identical.
          final redaction = PiiRedactor.redact(policyText.trim());
          final scrubbedPreview =
              canonicalRedactedPreview ?? redaction.redactedText;
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
                              const ExcludeSemantics(
                                child: DeniAnimatedMascot(
                                  size: 42,
                                  pose: DeniPose.explaining,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titleOverride ?? l10n.chooseReviewModeTitle,
                                      style: m3e.typeScale.titleLarge.copyWith(
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
                            _WhatWouldBeSent(
                              maskedCount: detectedTokens.isEmpty
                                  ? 0
                                  : (redaction.replacementCount > 0
                                        ? redaction.replacementCount
                                        : detectedTokens.length),
                            ),
                            const SizedBox(height: 14),
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
                                  ? l10n.cloudPayloadNoPiiLabel
                                  : l10n.cloudPayloadHiddenCount(
                                      redaction.replacementCount > 0
                                          ? redaction.replacementCount
                                          : detectedTokens.length,
                                    ),
                              categoryLabel:
                                  payloadCategoryLabelOverride ??
                                  l10n.cloudPayloadLabel,
                              spineColor: semantics.inCloud.foreground,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              disclosureOverride ?? l10n.cloudConsentDisclosure,
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
                        child: _ConsentActionPair(
                          onDeviceLabel:
                              secondaryActionLabelOverride ??
                              l10n.btnReviewOnPhone,
                          cloudLabel:
                              primaryActionLabelOverride ?? l10n.btnUseCloud,
                          onDevice: () => Navigator.pop(
                            context,
                            CloudConsentDecision.reviewLocally,
                          ),
                          onCloud: () => Navigator.pop(
                            context,
                            CloudConsentDecision.useCloudOnce,
                          ),
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

/// Summary at the top of the consent sheet: what leaves the phone, how much
/// is masked first, and what never leaves.
class _WhatWouldBeSent extends StatelessWidget {
  final int maskedCount;

  const _WhatWouldBeSent({required this.maskedCount});

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    Widget line(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: m3e.typeScale.bodyMedium.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      key: const Key('cloud_consent_summary'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(EnpriveRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.consentWhatWouldBeSent,
              style: m3e.typeScale.titleMedium.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
          line(LucideIcons.fileText, l10n.consentSentScope),
          line(LucideIcons.eyeOff, l10n.consentMaskedCount(maskedCount)),
          line(LucideIcons.smartphone, l10n.consentStaysOnPhone),
        ],
      ),
    );
  }
}

/// Split action pair. The on-device review (the product default) comes
/// first and carries the filled emphasis; cloud is the tonal alternative.
/// The pair sits side by side when both labels fit on one line, otherwise
/// it stacks with the on-device action on top.
class _ConsentActionPair extends StatelessWidget {
  final String onDeviceLabel;
  final String cloudLabel;
  final VoidCallback onDevice;
  final VoidCallback onCloud;

  const _ConsentActionPair({
    required this.onDeviceLabel,
    required this.cloudLabel,
    required this.onDevice,
    required this.onCloud,
  });

  @override
  Widget build(BuildContext context) {
    final onDeviceButton = EnpriveTactileButton(
      key: const Key('cloud_consent_on_device_btn'),
      label: onDeviceLabel,
      onPressed: onDevice,
    );
    final cloudButton = EnpriveTactileButton(
      key: const Key('cloud_consent_cloud_btn'),
      label: cloudLabel,
      variant: EnpriveButtonVariant.tonal,
      onPressed: onCloud,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final halfWidth = (constraints.maxWidth - gap) / 2;
        final style = EnpriveM3ETheme.of(
          context,
        ).typography.emphasized.titleMedium;
        final textScaler = MediaQuery.textScalerOf(context);
        bool fits(String label) {
          final painter = TextPainter(
            text: TextSpan(text: label, style: style),
            textDirection: Directionality.of(context),
            textScaler: textScaler,
            maxLines: 1,
          )..layout();
          final fitsHalf = painter.width + 48 <= halfWidth;
          painter.dispose();
          return fitsHalf;
        }

        if (fits(onDeviceLabel) && fits(cloudLabel)) {
          return Row(
            children: [
              Expanded(child: onDeviceButton),
              const SizedBox(width: gap),
              Expanded(child: cloudButton),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            onDeviceButton,
            const SizedBox(height: gap),
            cloudButton,
          ],
        );
      },
    );
  }
}
