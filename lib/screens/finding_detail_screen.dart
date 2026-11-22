import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/enprive_theme.dart';
import '../domain/review/review_models.dart';
import '../l10n/app_localizations.dart';
import '../widgets/enprive_tactile_button.dart';
import '../widgets/m3e/enprive_quote_card.dart';
import '../widgets/review/enprive_finding_row.dart';
import '../widgets/review/evidence_category_style.dart';

/// Full page for one finding, opened from its segmented row on the Review
/// result. Keeps the evidence first: a neutral index numeral, the category,
/// the serif quote card (or the phone observation, never quoted as policy
/// text), then the plain-language explanation and what remains unknown.
/// Deni stays out of the way while reading; "Ask Deni about this" opens
/// Deni's explanation sheet.
class FindingDetailScreen extends StatelessWidget {
  final VerifiedFinding finding;
  final int index;
  final int totalCount;
  final String proofLabel;
  final String? reviewChipLabel;
  final String snapshotDigest;
  final VoidCallback onAskDeni;

  const FindingDetailScreen({
    super.key,
    required this.finding,
    required this.index,
    required this.totalCount,
    required this.proofLabel,
    required this.snapshotDigest,
    required this.onAskDeni,
    this.reviewChipLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;
    final category = EvidenceCategoryStyle.of(context, finding.category);
    final margin = EnpriveSpacing.marginFor(MediaQuery.sizeOf(context).width);

    Widget section(String title, Widget body) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: m3e.typeScale.titleMedium.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            body,
          ],
        ),
      );
    }

    Text bodyText(String text) => Text(
      text,
      style: m3e.typeScale.bodyLarge.copyWith(color: scheme.onSurface),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('finding_detail_back_btn'),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          l10n.findingDetailTitle(index + 1, totalCount),
          style: m3e.typeScale.titleLarge.copyWith(color: scheme.onSurface),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: EdgeInsets.fromLTRB(margin, 8, margin, 32),
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: m3e.typography.emphasized.displayMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        8,
                        6,
                        12,
                        6,
                      ),
                      decoration: BoxDecoration(
                        color: category.color.container,
                        borderRadius: BorderRadius.circular(EnpriveRadii.chip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: category.color.onContainer,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              category.label,
                              style: m3e.typeScale.labelLarge.copyWith(
                                color: category.color.onContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  finding.title,
                  style: m3e.typeScale.headlineSmall.copyWith(
                    color: scheme.onSurface,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        evidenceProofIcon(finding),
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        proofLabel,
                        style: m3e.typeScale.bodyMedium.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (reviewChipLabel != null)
                    Container(
                      padding: const EdgeInsetsDirectional.fromSTEB(6, 3, 8, 3),
                      decoration: BoxDecoration(
                        color: semantics.reviewRecommended.background,
                        borderRadius: BorderRadius.circular(EnpriveRadii.chip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.eye,
                            size: 13,
                            color: semantics.reviewRecommended.icon,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reviewChipLabel!,
                            style: m3e.typeScale.labelMedium.copyWith(
                              color: semantics.reviewRecommended.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (finding.isDeviceObserved)
                Container(
                  key: const Key('finding_detail_observation'),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(EnpriveRadii.card),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.smartphone,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          finding.exactExcerpt,
                          style: m3e.typeScale.bodyMedium.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                EnpriveQuoteCard(
                  key: const Key('finding_detail_quote'),
                  quote: finding.contextWindow == null
                      ? finding.exactExcerpt
                      : null,
                  contextWindow: finding.contextWindow,
                  statusLabel: proofLabel,
                  categoryLabel: category.label,
                  spineColor: category.color.color,
                  sha256Digest: snapshotDigest.isEmpty ? null : snapshotDigest,
                  selectable: true,
                ),
              if (finding.explanation.trim().isNotEmpty)
                section(
                  l10n.labelInPlainLanguage,
                  bodyText(finding.explanation),
                ),
              if (finding.whatPolicySays.trim().isNotEmpty)
                section(
                  l10n.labelWhatPolicySays,
                  bodyText(finding.whatPolicySays),
                ),
              if (finding.whatAndroidReports.trim().isNotEmpty)
                section(
                  l10n.labelWhatAndroidReports,
                  bodyText(finding.whatAndroidReports),
                ),
              if (finding.unknowns.isNotEmpty)
                section(
                  l10n.labelWhatRemainsUnknown,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final unknown in finding.unknowns)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Icon(
                                  LucideIcons.circleHelp,
                                  size: 16,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: bodyText(unknown)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(margin, 8, margin, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: EnpriveTactileButton(
                key: const Key('finding_detail_ask_deni_btn'),
                label: l10n.askDeniAboutThis,
                onPressed: onAskDeni,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
