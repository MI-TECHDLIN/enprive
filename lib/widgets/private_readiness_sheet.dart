import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/enprive_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'deni_animated_mascot.dart';
import 'enprive_duotone_icon.dart';
import 'enprive_tactile_button.dart';

/// Private Analysis Readiness Sheet crafted from Brilliant B19
/// (`b19-permission-prime.png` — Deni peeking over a status card) and
/// Welcome Gradient (`x-welcome-gradient.jpeg` — soft paper→teal bottom wash).
class PrivateReadinessSheet extends StatefulWidget {
  final HybridAiBridge bridge;
  final DeviceCapability? initialCapability;

  const PrivateReadinessSheet({
    super.key,
    required this.bridge,
    required this.initialCapability,
  });

  static Future<DeviceCapability?> show(
    BuildContext context, {
    required HybridAiBridge bridge,
    required DeviceCapability? initialCapability,
  }) {
    return showModalBottomSheet<DeviceCapability>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrivateReadinessSheet(
        bridge: bridge,
        initialCapability: initialCapability,
      ),
    );
  }

  @override
  State<PrivateReadinessSheet> createState() => _PrivateReadinessSheetState();
}

class _PrivateReadinessSheetState extends State<PrivateReadinessSheet> {
  DeviceCapability? _capability;
  bool _isPreparing = false;
  ModelDownloadStatus? _resolvedStatus;

  @override
  void initState() {
    super.initState();
    _capability = widget.initialCapability;
    _runReadinessCheck();
  }

  Future<void> _runReadinessCheck() async {
    setState(() {
      _isPreparing = true;
    });

    final status = await widget.bridge.downloadOrCheckModel();
    if (status == ModelDownloadStatus.available) {
      await widget.bridge.warmUpModel();
    }
    final updatedCap = await widget.bridge.getDeviceCapability();

    if (!mounted) return;
    setState(() {
      _capability = updatedCap;
      _resolvedStatus = status;
      _isPreparing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final statusMessage = _isPreparing
        ? l10n.checkingPhoneReadiness
        : switch (_resolvedStatus) {
            ModelDownloadStatus.available => l10n.geminiNanoReadyMsg,
            ModelDownloadStatus.downloading => l10n.modelDownloadingMsg,
            ModelDownloadStatus.downloadable => l10n.modelDownloadableMsg,
            ModelDownloadStatus.unavailable ||
            ModelDownloadStatus.failed ||
            null =>
              l10n.localScannerDefaultMsg,
          };
    final isReady = _capability?.isSupported == true &&
        _capability?.modelStatus == ModelDownloadStatus.available;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            EnpriveColors.surface,
            EnpriveColors.surface,
            EnpriveColors.chipOnDeviceBg.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
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
                    onPressed: () => Navigator.pop(context, _capability),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),

              // Brilliant B19 Peeking Deni
              Transform.translate(
                offset: const Offset(0, 10),
                child: DeniAnimatedMascot(
                  size: 84,
                  pose: _isPreparing
                      ? DeniPose.thinking
                      : (isReady ? DeniPose.celebrating : DeniPose.idle),
                ),
              ),

              // Status Card (B19 notification card layout)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: EnpriveColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: EnpriveColors.ink.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isReady
                            ? EnpriveColors.stateNoConcernBg
                            : EnpriveColors.chipOnDeviceBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _isPreparing
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : EnpriveDuotoneIcon(
                              isReady
                                  ? Ph.check_circle_duotone
                                  : Ph.shield_check_duotone,
                              color: isReady
                                  ? EnpriveColors.stateNoConcernFg
                                  : EnpriveColors.tealStrong,
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPreparing
                                ? l10n.preparingPrivateAnalysis
                                : (isReady
                                    ? l10n.onDeviceAiReadyTitle
                                    : l10n.localScannerActiveTitle),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: EnpriveColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusMessage,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              color: EnpriveColors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.privateAnalysisTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.privateAnalysisSheetSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: EnpriveColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 28),

              EnpriveTactileButton(
                label: l10n.btnDone,
                onPressed: () => Navigator.pop(context, _capability),
              ),
              const SizedBox(height: 10),
              EnpriveTactileButton(
                label: l10n.btnCheckAgain,
                isSecondary: true,
                onPressed: _isPreparing ? null : _runReadinessCheck,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
