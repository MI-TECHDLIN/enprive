import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/privacy/pii_redactor.dart';
import '../l10n/app_localizations.dart';
import 'deni_animated_mascot.dart';
import 'enprive_tactile_button.dart';

enum CloudConsentDecision {
  useCloudOnce,
  reviewLocally,
  cancelled,
}

/// Material 3 Expressive Per-Check Cloud Consent Modal:
/// - Deni (`LOD 2 · 84dp`, `DeniPose.support`) peeking above a clean PII-scrubbed
///   policy excerpt card (`SourceSerif4` quotation typography).
/// - Optional device-capability reason pill.
/// - Centered bold headline & calm disclosure subtitle.
/// - Two tactile action pills at the bottom (`Review on this phone` primary +
///   `Use cloud for this check` secondary).
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
    final scheme = EnpriveM3ETheme.of(context).colorScheme;
    final decision = await showModalBottomSheet<CloudConsentDecision>(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => CloudConsentSheet(
        subjectTitle: subjectTitle,
        policyText: policyText,
        deviceReason: deviceReason,
      ),
    );
    return decision ?? CloudConsentDecision.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;
    final typeExt = context.enpriveType;

    final scrubbedPreview = PiiRedactor.redact(policyText).redactedText.trim();
    final trimmedReason = deviceReason?.trim();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle + close
            Row(
              children: [
                const SizedBox(width: 40),
                const Spacer(),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.tooltipClose,
                  onPressed: () =>
                      Navigator.pop(context, CloudConsentDecision.cancelled),
                  icon: Icon(
                    LucideIcons.x,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Deni (LOD 2 · 84dp) peeking over the Excerpt Card
            Transform.translate(
              offset: const Offset(0, 10),
              child: const DeniAnimatedMascot(
                size: 84,
                pose: DeniPose.support,
              ),
            ),
            M3ECard(
              color: surfaces.quoteSurface,
              borderRadius: BorderRadius.circular(24),
              border: BorderSide(color: surfaces.hairlineBorder),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: semantics.inCloud.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.cloudCheck,
                          size: 19,
                          color: semantics.inCloud.foreground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subjectTitle,
                          style: m3e.typography.emphasized.titleSmall.copyWith(
                            fontSize: 15,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: SelectableText(
                          scrubbedPreview,
                          style: typeExt.policyQuotation.copyWith(
                            fontSize: 13.5,
                            height: 1.45,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (trimmedReason != null && trimmedReason.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: semantics.unknown.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: semantics.unknown.border.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 16,
                      color: semantics.unknown.foreground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trimmedReason,
                        style: m3e.typeScale.bodySmall.copyWith(
                          fontSize: 13,
                          height: 1.35,
                          color: semantics.unknown.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),

            // Centered Headline & Subtitle
            Text(
              l10n.chooseReviewModeTitle,
              textAlign: TextAlign.center,
              style: m3e.typography.emphasized.headlineMedium.copyWith(
                fontSize: 24,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${l10n.cloudConsentDisclosure} ${l10n.cloudNeverSendsAppsNote}',
                textAlign: TextAlign.center,
                style: m3e.typeScale.bodyMedium.copyWith(
                  fontSize: 14.5,
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Two Tactile Pill Buttons
            EnpriveTactileButton(
              label: l10n.btnReviewOnPhone,
              onPressed: () =>
                  Navigator.pop(context, CloudConsentDecision.reviewLocally),
            ),
            const SizedBox(height: 12),
            EnpriveTactileButton(
              label: l10n.btnUseCloud,
              isSecondary: true,
              onPressed: () =>
                  Navigator.pop(context, CloudConsentDecision.useCloudOnce),
            ),
          ],
        ),
      ),
    );
  }
}
