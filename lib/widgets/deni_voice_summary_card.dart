import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/voice/deni_voice_summary.dart';
import '../l10n/app_localizations.dart';
import '../services/platform/hybrid_ai_bridge.dart';
import 'enprive_provenance_chip.dart';
import 'm3e/enprive_m3e_components.dart';

/// Displays Deni's evidence-grounded plain-language summary alongside accessible
/// audio playback controls (never audio-only).
///
/// Accessibility & Product Guardrails:
/// - Every interactive control meets >= 48x48dp touch targets with clear,
///   non-duplicated TalkBack semantics.
/// - Respects reduced-motion (`EnpriveMotionTokens.isReducedMotion(context)`).
/// - Every policy summary point keeps its linked verbatim source excerpt
///   accessible inline and opens full finding details on demand.
/// - Local device permission observations remain clearly separated from policy
///   disclosures; calibrated non-certification copy is always visible.
class DeniVoiceSummaryCard extends StatefulWidget {
  final DeniVoiceSummary summary;
  final bool isGeneratingSummary;
  final VoicePlaybackState playbackState;
  final VoicePlaybackRoute activeRoute;
  final String? statusNotice;
  final VoidCallback onPlayOffline;
  final VoidCallback onPlayExpressiveCloud;
  final VoidCallback onStop;
  final VoidCallback? onEnhanceSummaryWithCloud;
  final void Function(String findingId)? onOpenFinding;

  const DeniVoiceSummaryCard({
    super.key,
    required this.summary,
    this.isGeneratingSummary = false,
    this.playbackState = VoicePlaybackState.idle,
    this.activeRoute = VoicePlaybackRoute.none,
    this.statusNotice,
    required this.onPlayOffline,
    required this.onPlayExpressiveCloud,
    required this.onStop,
    this.onEnhanceSummaryWithCloud,
    this.onOpenFinding,
  });

  @override
  State<DeniVoiceSummaryCard> createState() => _DeniVoiceSummaryCardState();
}

class _DeniVoiceSummaryCardState extends State<DeniVoiceSummaryCard> {
  final Set<String> _expandedPointIds = <String>{};

  bool get _isActivePlayback =>
      widget.playbackState == VoicePlaybackState.synthesizing ||
      widget.playbackState == VoicePlaybackState.playing;

  bool get _isSynthesizing =>
      widget.playbackState == VoicePlaybackState.synthesizing;

  void _toggleQuote(String pointId) {
    setState(() {
      if (!_expandedPointIds.remove(pointId)) {
        _expandedPointIds.add(pointId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;
    final typeExt = context.enpriveType;
    final reduceMotion = EnpriveMotionTokens.isReducedMotion(context);

    final summary = widget.summary;
    final activeVoiceBadge = switch (widget.activeRoute) {
      VoicePlaybackRoute.geminiCloudTts => l10n.voiceBadgeExpressive,
      VoicePlaybackRoute.androidLocalTts => l10n.voiceBadgeDeviceOffline,
      _ => null,
    };
    final effectiveNotice =
        (widget.statusNotice?.trim().isNotEmpty == true)
        ? widget.statusNotice!.trim()
        : (summary.fallbackNote?.trim().isNotEmpty == true
              ? summary.fallbackNote!.trim()
              : null);

    return EnpriveMaterialCardSurface(
      key: const Key('deni_voice_summary_card'),
      variant: EnpriveCardVariant.elevated,
      backgroundColor: surfaces.card,
      borderRadius: BorderRadius.circular(EnpriveRadii.xl),
      lipHeight: 3.0,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Full-width title row + wrapping provenance & active voice route pills
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: semantics.onDevice.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExcludeSemantics(
                  child: Icon(
                    LucideIcons.audioLines,
                    size: 16,
                    color: semantics.onDevice.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.voiceSummaryTitle,
                  style: m3e.typography.emphasized.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _SummarySourcePill(source: summary.summarySource),
              if (activeVoiceBadge != null)
                Container(
                  key: const Key('deni_voice_route_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.activeRoute == VoicePlaybackRoute.geminiCloudTts
                        ? semantics.inCloud.background
                        : surfaces.cardMuted,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color:
                          widget.activeRoute ==
                              VoicePlaybackRoute.geminiCloudTts
                          ? semantics.inCloud.border
                          : surfaces.hairlineBorder,
                    ),
                  ),
                  child: Text(
                    activeVoiceBadge,
                    style: m3e.typeScale.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          widget.activeRoute ==
                              VoicePlaybackRoute.geminiCloudTts
                          ? semantics.inCloud.foreground
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),

          if (widget.isGeneratingSummary || _isSynthesizing) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Container(
                key: const Key('deni_voice_status_banner'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: surfaces.cardMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: surfaces.hairlineBorder),
                ),
                child: Row(
                  children: [
                    if (reduceMotion)
                      Icon(
                        LucideIcons.sparkles,
                        size: 16,
                        color: scheme.primary,
                      )
                    else
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isSynthesizing
                            ? l10n.voiceSynthesizingExpressive
                            : l10n.voiceSummaryPreparing,
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Plain-language headline (always visible transcript alongside controls)
          Text(
            summary.headline,
            key: const Key('deni_voice_summary_headline'),
            style: m3e.typeScale.bodyLarge.copyWith(
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),

          if (effectiveNotice != null) ...[
            const SizedBox(height: 10),
            Semantics(
              liveRegion: true,
              child: Container(
                key: const Key('deni_voice_fallback_notice'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: semantics.unknown.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: semantics.unknown.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 16,
                      color: semantics.unknown.foreground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        effectiveNotice,
                        style: m3e.typeScale.bodySmall.copyWith(
                          color: semantics.unknown.foreground,
                          fontWeight: FontWeight.w600,
                          height: 1.38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Accessible audio controls right beneath headline (>= 48dp targets, clickable/focusable TalkBack buttons, Wrap for 200% scale)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                key: const Key('deni_voice_play_stop_btn'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: _isActivePlayback
                      ? semantics.reviewRecommended.foreground
                      : surfaces.tactilePrimaryBg,
                  foregroundColor: _isActivePlayback
                      ? scheme.surface
                      : surfaces.tactilePrimaryFg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: _isActivePlayback
                    ? widget.onStop
                    : widget.onPlayOffline,
                child: Semantics(
                  label: _isActivePlayback
                      ? l10n.voiceTooltipStopReading
                      : l10n.voiceTooltipReadSummary,
                  excludeSemantics: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isActivePlayback
                            ? LucideIcons.square
                            : LucideIcons.volume2,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isActivePlayback
                              ? l10n.voiceBtnStop
                              : l10n.voiceBtnListenOffline,
                          style: m3e.typography.emphasized.labelLarge.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_isActivePlayback)
                OutlinedButton(
                  key: const Key('deni_voice_expressive_btn'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    foregroundColor: scheme.onSurface,
                    side: BorderSide(color: surfaces.strongBorder, width: 1.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: widget.onPlayExpressiveCloud,
                  child: Semantics(
                    label:
                        '${l10n.voiceBtnExpressiveCloud}. ${l10n.voiceConsentTitle}',
                    excludeSemantics: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.sparkles,
                          size: 16,
                          color: semantics.inCloud.foreground,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.voiceBtnExpressiveCloud,
                            style: m3e.typography.emphasized.labelLarge
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (summary.requiresCloudConsent &&
                  summary.summarySource ==
                      InferenceSource.offlineDeterministic &&
                  !widget.isGeneratingSummary &&
                  widget.onEnhanceSummaryWithCloud != null)
                TextButton(
                  key: const Key('deni_summary_cloud_btn'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    foregroundColor: semantics.inCloud.foreground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onPressed: widget.onEnhanceSummaryWithCloud,
                  child: Semantics(
                    label: l10n.voiceBtnSummarizeCloud,
                    excludeSemantics: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.cloud, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.voiceBtnSummarizeCloud,
                            style: m3e.typeScale.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          if (summary.points.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (var i = 0; i < summary.points.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _SummaryPointRow(
                point: summary.points[i],
                isExpanded: _expandedPointIds.contains(summary.points[i].id),
                reduceMotion: reduceMotion,
                l10n: l10n,
                typeExt: typeExt,
                onToggleQuote: () => _toggleQuote(summary.points[i].id),
                onOpenFinding:
                    summary.points[i].findingId != null &&
                        widget.onOpenFinding != null
                    ? () => widget.onOpenFinding!(summary.points[i].findingId!)
                    : null,
              ),
            ],
          ],

          // Unknowns & calibrated non-certification boundary (always alongside audio)
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaces.cardMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: surfaces.hairlineBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.unknownSummary,
                  key: const Key('deni_voice_summary_unknowns'),
                  style: m3e.typeScale.bodySmall.copyWith(
                    color: scheme.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary.calibrationNotice,
                  key: const Key('deni_voice_summary_calibration'),
                  style: m3e.typeScale.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPointRow extends StatelessWidget {
  final DeniSummaryPoint point;
  final bool isExpanded;
  final bool reduceMotion;
  final AppLocalizations l10n;
  final EnpriveTypographyExtension typeExt;
  final VoidCallback onToggleQuote;
  final VoidCallback? onOpenFinding;

  const _SummaryPointRow({
    required this.point,
    required this.isExpanded,
    required this.reduceMotion,
    required this.l10n,
    required this.typeExt,
    required this.onToggleQuote,
    this.onOpenFinding,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final semantics = context.enpriveSemantics;

    final (IconData icon, Color iconColor, String? nonPolicyBadge) =
        switch (point.kind) {
          DeniSummaryPointKind.policyFinding => (
            LucideIcons.quote,
            semantics.onDevice.icon,
            null,
          ),
          DeniSummaryPointKind.devicePermissionNote => (
            LucideIcons.smartphone,
            semantics.inCloud.icon,
            '${l10n.observedOnPhoneLabel} · ${l10n.notFromPolicySuffix}',
          ),
          DeniSummaryPointKind.samplePermissionNote => (
            LucideIcons.flaskConical,
            scheme.onSurfaceVariant,
            '${l10n.sampleSyntheticBadge} · ${l10n.sampleNotFromPolicySuffix}',
          ),
          DeniSummaryPointKind.associationNote => (
            LucideIcons.link2,
            semantics.reviewRecommended.icon,
            null,
          ),
        };

    return Container(
      key: Key('deni_summary_point_${point.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaces.canvas.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaces.hairlineBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: ExcludeSemantics(
                  child: Icon(icon, size: 15, color: iconColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (nonPolicyBadge != null) ...[
                      Text(
                        nonPolicyBadge,
                        style: m3e.typeScale.labelSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                    Text(
                      point.plainText,
                      style: m3e.typeScale.bodyMedium.copyWith(
                        height: 1.42,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (point.hasPolicyExcerpt) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  key: Key('deni_summary_quote_toggle_${point.id}'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    foregroundColor: semantics.onDevice.foreground,
                  ),
                  onPressed: onToggleQuote,
                  child: Semantics(
                    label: isExpanded
                        ? '${l10n.voiceHideSourceQuote} for ${point.sourceLabel ?? point.id}'
                        : '${l10n.voiceViewSourceQuote} for ${point.sourceLabel ?? point.id}',
                    excludeSemantics: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isExpanded
                              ? LucideIcons.chevronUp
                              : LucideIcons.fileText,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isExpanded
                                ? l10n.voiceHideSourceQuote
                                : l10n.voiceViewSourceQuote,
                            style: m3e.typeScale.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (onOpenFinding != null)
                  TextButton(
                    key: Key('deni_summary_inspect_${point.id}'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      foregroundColor: scheme.onSurfaceVariant,
                    ),
                    onPressed: onOpenFinding,
                    child: Semantics(
                      label:
                          '${l10n.voiceInspectFinding}: ${point.sourceLabel ?? point.id}',
                      excludeSemantics: true,
                      child: Text(
                        l10n.voiceInspectFinding,
                        style: m3e.typeScale.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (reduceMotion) ...[
              if (isExpanded)
                Container(
                  key: Key('deni_summary_quote_box_${point.id}'),
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: surfaces.quoteSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: surfaces.hairlineBorder),
                  ),
                  child: Stack(
                    children: [
                      PositionedDirectional(
                        top: 8,
                        bottom: 8,
                        start: 0,
                        width: 3.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: semantics.onDevice.icon,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          14,
                          10,
                          12,
                          10,
                        ),
                        child: SelectableText(
                          '“${point.sourceExcerpt!}”',
                          style: typeExt.policyQuotation.copyWith(
                            fontSize: 13.5,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ] else
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: isExpanded
                    ? Container(
                        key: Key('deni_summary_quote_box_${point.id}'),
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: surfaces.quoteSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: surfaces.hairlineBorder),
                        ),
                        child: Stack(
                          children: [
                            PositionedDirectional(
                              top: 8,
                              bottom: 8,
                              start: 0,
                              width: 3.5,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: semantics.onDevice.icon,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                14,
                                10,
                                12,
                                10,
                              ),
                              child: SelectableText(
                                '“${point.sourceExcerpt!}”',
                                style: typeExt.policyQuotation.copyWith(
                                  fontSize: 13.5,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ],
      ),
    );
  }
}

class _SummarySourcePill extends StatelessWidget {
  final InferenceSource source;

  const _SummarySourcePill({required this.source});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final m3e = EnpriveM3ETheme.of(context);
    final semantics = context.enpriveSemantics;

    final (SemanticColorPair pair, IconData icon, String label) = switch (
      source
    ) {
      InferenceSource.onDevice => (
        semantics.onDevice,
        LucideIcons.smartphone,
        l10n.summarySourceOnDevice,
      ),
      InferenceSource.inCloud => (
        semantics.inCloud,
        LucideIcons.cloud,
        l10n.summarySourceInCloud,
      ),
      InferenceSource.offlineDeterministic => (
        semantics.offlineFallback,
        LucideIcons.fileText,
        l10n.summarySourceOffline,
      ),
      InferenceSource.unknown || InferenceSource.locationUnavailable => (
        semantics.unknown,
        LucideIcons.circleHelp,
        l10n.summarySourceUnknown,
      ),
    };

    return Container(
      key: const Key('deni_voice_summary_source_pill'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: pair.border.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: Icon(icon, size: 12.5, color: pair.icon)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: m3e.typeScale.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: pair.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
