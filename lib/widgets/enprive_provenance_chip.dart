import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/theme/enprive_colors.dart';

enum InferenceSource {
  onDevice,
  inCloud,
  locationUnavailable,
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
    final (Color bg, Color fg, IconData icon, String defaultLabel) = switch (source) {
      InferenceSource.onDevice => (
          EnpriveColors.chipOnDeviceBg,
          EnpriveColors.chipOnDeviceFg,
          Symbols.smartphone_rounded,
          'On this device',
        ),
      InferenceSource.inCloud => (
          EnpriveColors.chipInCloudBg,
          EnpriveColors.chipInCloudFg,
          Symbols.cloud_done_rounded,
          'In the cloud',
        ),
      InferenceSource.locationUnavailable => (
          EnpriveColors.chipUnknownBg,
          EnpriveColors.chipUnknownFg,
          Symbols.help_outline_rounded,
          'Location unavailable',
        ),
    };

    final label = customLabel ?? defaultLabel;

    return Semantics(
      label: 'Processing location: $label',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fg.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
