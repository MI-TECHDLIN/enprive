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

/// Brilliant B19-inspired Per-Check Cloud Consent Modal.
/// Never infers global consent; discloses the exact text to be sent and
/// confirms local app lists and Android permissions never leave the phone.
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
      backgroundColor: EnpriveColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
    final previewSnippet = policyText.length > 220
        ? '${policyText.substring(0, 220).trim()}…'
        : policyText.trim();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: EnpriveColors.ink.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top row: B19 Mascot stage + Close button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const DeniAnimatedMascot(
                  size: 72,
                  pose: DeniPose.support,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: EnpriveColors.chipInCloudBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'PER-CHECK CONSENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: EnpriveColors.chipInCloudFg,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reviewing "$subjectTitle"',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () =>
                      Navigator.pop(context, CloudConsentDecision.cancelled),
                  icon: const Icon(Symbols.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Disclosure explanation
            Text(
              l10n.cloudConsentDisclosure,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: EnpriveColors.inkSecondary,
                  ),
            ),
            if (deviceReason != null && deviceReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Note: $deviceReason',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: EnpriveColors.inkSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Exact payload preview card (quoteSurface + Source Serif 4)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: EnpriveColors.quoteSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: EnpriveColors.ink.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Symbols.description_rounded,
                        size: 16,
                        color: EnpriveColors.tealStrong,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'EXACT TEXT TO SEND (${policyText.length} chars)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: EnpriveColors.tealStrong,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    previewSnippet,
                    style: const TextStyle(
                      fontFamily: EnpriveTheme.primaryDisplayFontFamily,
                      fontSize: 14,
                      height: 1.45,
                      color: EnpriveColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // What is NEVER sent reassurance pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: EnpriveColors.stateNoConcernBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Symbols.verified_user_rounded,
                    size: 18,
                    color: EnpriveColors.stateNoConcernFg,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Installed apps and Android permission states stay 100% on this phone.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: EnpriveColors.stateNoConcernFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thumb-zone actions
            EnpriveTactileButton(
              label: l10n.btnUseCloud,
              leading: const Icon(
                Symbols.cloud_done_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () =>
                  Navigator.pop(context, CloudConsentDecision.useCloudOnce),
            ),
            const SizedBox(height: 12),
            EnpriveTactileButton(
              label: '${l10n.btnReviewManually} (On-Device Clause Scan)',
              isSecondary: true,
              leading: const Icon(
                Symbols.smartphone_rounded,
                size: 20,
                color: EnpriveColors.ink,
              ),
              onPressed: () =>
                  Navigator.pop(context, CloudConsentDecision.reviewLocally),
            ),
          ],
        ),
      ),
    );
  }
}
