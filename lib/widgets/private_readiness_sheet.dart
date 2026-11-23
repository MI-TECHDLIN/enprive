import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'deni_animated_mascot.dart';
import 'enprive_tactile_button.dart';
import 'm3e/enprive_m3e_components.dart';

/// Material 3 Expressive Private Analysis Readiness Sheet pairing Deni at
/// `LOD 2 · 84dp` (`DeniLodTier.standard`) with an M3E status card and
/// morphing [M3ELoadingIndicator].
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
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => EnpriveM3EBridgeScope.ensure(
        sheetContext,
        child: PrivateReadinessSheet(
          bridge: bridge,
          initialCapability: initialCapability,
        ),
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
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final surfaces = context.enpriveSurfaces;
    final reducedMotion = EnpriveMotionTokens.isReducedMotion(context);

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
    final isReady =
        _capability?.isSupported == true &&
        _capability?.modelStatus == ModelDownloadStatus.available;

    final badgePair = isReady ? semantics.noConcern : semantics.onDevice;

    return Material(
      color: scheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    onPressed: () => Navigator.pop(context, _capability),
                    icon: Icon(
                      LucideIcons.x,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              Transform.translate(
                offset: const Offset(0, 8),
                child: DeniAnimatedMascot(
                  size: 84,
                  lodOverride: DeniLodTier.standard,
                  pose: _isPreparing
                      ? DeniPose.thinking
                      : (isReady ? DeniPose.idle : DeniPose.support),
                ),
              ),

              EnpriveMaterialCardSurface(
                variant: EnpriveCardVariant.elevated,
                backgroundColor: surfaces.card,
                borderRadius: BorderRadius.circular(24),
                lipHeight: 3.0,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgePair.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _isPreparing && !reducedMotion
                          ? SizedBox(
                              width: 28,
                              height: 28,
                              child: M3ELoadingIndicator(
                                size: 28,
                                color: badgePair.foreground,
                              ),
                            )
                          : Icon(
                              isReady
                                  ? LucideIcons.circleCheck
                                  : LucideIcons.shieldCheck,
                              color: badgePair.foreground,
                              size: 22,
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
                            style: m3e.typography.emphasized.titleMedium
                                .copyWith(
                                  color: scheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusMessage,
                            style: m3e.typeScale.bodySmall.copyWith(
                              height: 1.4,
                              color: scheme.onSurfaceVariant,
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
                style: m3e.typography.emphasized.headlineSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.privateAnalysisSheetSubtitle,
                textAlign: TextAlign.center,
                style: m3e.typeScale.bodyMedium.copyWith(
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
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
