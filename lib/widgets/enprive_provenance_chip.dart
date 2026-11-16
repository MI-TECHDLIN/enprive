import 'package:flutter/material.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';
import 'enprive_duotone_icon.dart';

enum InferenceSource {
  onDevice,
  inCloud,
  offlineDeterministic,
  unknown,
  locationUnavailable,
}

/// Normalizes native bridge provenance strings and persisted enum names into
/// [InferenceSource], defaulting any missing, `'UNKNOWN'`, or unrecognized
/// value to [InferenceSource.unknown].
InferenceSource parseInferenceSource(String? raw) {
  final normalized = raw?.trim().toUpperCase();
  return switch (normalized) {
    'ON_DEVICE' || 'ONDEVICE' => InferenceSource.onDevice,
    'IN_CLOUD' || 'INCLOUD' => InferenceSource.inCloud,
    'OFFLINE_DETERMINISTIC' ||
    'OFFLINEDETERMINISTIC' =>
      InferenceSource.offlineDeterministic,
    'LOCATION_UNAVAILABLE' ||
    'LOCATIONUNAVAILABLE' =>
      InferenceSource.locationUnavailable,
    _ => InferenceSource.unknown,
  };
}

class EnpriveProvenanceChip extends StatelessWidget {
  final InferenceSource source;
  final String? customLabel;

  const EnpriveProvenanceChip({
    super.key,
    required this.source,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final semantics = context.semanticColors;

    final (
      SemanticColorPair pair,
      String duotoneIcon,
      String defaultLabel,
    ) = switch (source) {
      InferenceSource.onDevice => (
          semantics.onDevice,
          Ph.device_mobile_duotone,
          l10n.chipOnDevice,
        ),
      InferenceSource.inCloud => (
          semantics.inCloud,
          Ph.cloud_check_duotone,
          l10n.chipInCloud,
        ),
      InferenceSource.offlineDeterministic => (
          semantics.offlineFallback,
          Ph.file_text_duotone,
          l10n.chipOfflineDeterministic,
        ),
      InferenceSource.unknown => (
          semantics.unknown,
          Ph.question_duotone,
          l10n.chipUnknown,
        ),
      InferenceSource.locationUnavailable => (
          semantics.unknown,
          Ph.question_duotone,
          l10n.chipLocationUnavailable,
        ),
    };

    final label = customLabel ?? defaultLabel;

    return Semantics(
      label: 'Processing location: $label',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: pair.background,
          borderRadius: BorderRadius.circular(EnpriveRadii.pill),
          border: Border.all(color: pair.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EnpriveDuotoneIcon(duotoneIcon, size: 16, color: pair.icon),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.enpriveType.evidenceBadge.copyWith(
                color: pair.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
