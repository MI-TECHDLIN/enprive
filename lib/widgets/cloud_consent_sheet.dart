import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';
import 'deni_animated_mascot.dart';
import 'enprive_tactile_button.dart';

enum CloudConsentDecision {
  useCloudOnce,
  reviewLocally,
  cancelled,
}

/// Brilliant B19-inspired Per-Check Cloud Consent Modal (`b19-permission-prime.png`):
/// - Deni peeking above a clean excerpt card
/// - Centered bold headline & calm subtitle
/// - Two tactile action pills at the bottom
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
      backgroundColor: EnpriveColors.surface,
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
    final l10n = AppLocalizations.of(context)!;
    final previewSnippet = policyText.length > 180
        ? '${policyText.substring(0, 180).trim()}…'
        : policyText.trim();

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
                    color: EnpriveColors.ink.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () =>
                      Navigator.pop(context, CloudConsentDecision.cancelled),
                  icon: const Icon(Symbols.close_rounded),
                ),
              ],
            ),

            // Brilliant B19 Stage: Deni peeking over the Excerpt Card
            Transform.translate(
              offset: const Offset(0, 10),
              child: const DeniAnimatedMascot(
                size: 80,
                pose: DeniPose.support,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: EnpriveColors.paper,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: EnpriveColors.ink.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: EnpriveColors.chipInCloudBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Symbols.cloud_rounded,
                          size: 18,
                          color: EnpriveColors.chipInCloudFg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subjectTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: EnpriveColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '“$previewSnippet”',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: EnpriveTheme.quoteFontFamily,
                      fontSize: 13.5,
                      height: 1.45,
                      color: EnpriveColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Centered B19 Headline & Subtitle
            Text(
              'Choose how to review this text',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${l10n.cloudConsentDisclosure} Installed apps and phone permissions are never sent.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: EnpriveColors.inkSecondary,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Two Tactile Pill Buttons (b19-permission-prime.png exact bottom stack)
            EnpriveTactileButton(
              label: 'Review on this phone',
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
