import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/enprive_theme.dart';
import '../../domain/permissions/permission_comparator.dart';
import '../../domain/review/app_policy_association.dart';
import '../../l10n/app_localizations.dart';
import '../../services/platform/hybrid_ai_bridge.dart';
import '../enprive_tactile_button.dart';
import '../installed_app_icon.dart';

/// Direction A ("Calm evidence") two-way app-policy linking and permission
/// comparison section displayed on [ReviewResultScreen].
///
/// - When [permissionReport] is `null`, renders a calm tonal card inviting the
///   user to link an installed app from this phone without starting over.
/// - When [permissionReport] is present, renders the linked app identity card
///   (launcher icon, app name, LTR package ID), the plain-language D5.3-B
///   association status or mismatch/ambiguity notice (always clarifying that
///   text and links never prove developer ownership), `Change app` / `Unlink
///   app` actions, and the on-device Android permission comparison.
class EnpriveLinkedAppSection extends StatelessWidget {
  final AppPermissionComparisonReport? permissionReport;
  final AppPolicyAssociationReport? associationReport;
  final HybridAiBridge bridge;
  final AppLocalizations l10n;
  final bool isBusy;
  final VoidCallback onLinkApp;
  final VoidCallback onChangeApp;
  final VoidCallback onUnlinkApp;

  const EnpriveLinkedAppSection({
    super.key,
    required this.permissionReport,
    required this.associationReport,
    required this.bridge,
    required this.l10n,
    required this.isBusy,
    required this.onLinkApp,
    required this.onChangeApp,
    required this.onUnlinkApp,
  });

  @override
  Widget build(BuildContext context) {
    final report = permissionReport;
    if (report == null) {
      return _UnlinkedAppCard(
        l10n: l10n,
        isBusy: isBusy,
        onLinkApp: onLinkApp,
      );
    }

    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final snapshot = report.snapshot;
    final displayAppName = snapshot.appName.trim().isNotEmpty
        ? snapshot.appName.trim()
        : snapshot.packageName.trim();
    final displayPackage = snapshot.packageName.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linked app identity + D5.3-B association + Change / Unlink actions
        Container(
          key: const Key('review_result_linked_app_card'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(EnpriveRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.linkedAppSectionLabel,
                style: m3e.typeScale.labelMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InstalledAppIcon(
                    packageName: displayPackage,
                    bridge: bridge,
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayAppName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: m3e.typography.emphasized.titleMedium.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${l10n.appIdPrefix}: $displayPackage',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isRtl ? TextAlign.right : TextAlign.left,
                            style: m3e.typeScale.bodySmall.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (associationReport != null &&
                  associationReport!.state !=
                      AppPolicyAssociationState.unlinked) ...[
                const SizedBox(height: 14),
                _AssociationStatusBlock(
                  report: associationReport!,
                  displayAppName: displayAppName,
                  displayPackageName: displayPackage,
                  l10n: l10n,
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('review_result_change_app_btn'),
                    onPressed: isBusy ? null : onChangeApp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.onSurface,
                      side: BorderSide(color: scheme.outlineVariant),
                      minimumSize: const Size(
                        EnpriveSpacing.minTouchTarget,
                        EnpriveSpacing.minTouchTarget,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    icon: const ExcludeSemantics(
                      child: Icon(LucideIcons.repeat, size: 16),
                    ),
                    label: Text(l10n.btnChangeLinkedApp),
                  ),
                  TextButton.icon(
                    key: const Key('review_result_unlink_app_btn'),
                    onPressed: isBusy ? null : onUnlinkApp,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                      minimumSize: const Size(
                        EnpriveSpacing.minTouchTarget,
                        EnpriveSpacing.minTouchTarget,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    icon: const ExcludeSemantics(
                      child: Icon(LucideIcons.unlink, size: 16),
                    ),
                    label: Text(l10n.btnUnlinkApp),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // On-device Android permission comparison block
        Text(
          l10n.permissionsOnPhoneTitle,
          style: m3e.typeScale.titleLarge.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 6),
        if (report.items.isEmpty) ...[
          const SizedBox(height: 6),
          Container(
            key: const Key('review_result_permissions_empty_card'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(EnpriveRadii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.permissionsEmptyComparisonTitle,
                  style: m3e.typeScale.titleSmall.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.permissionsEmptyComparisonBody(
                    snapshot.requestedPermissions.length,
                    snapshot.grantedPermissions.length,
                    displayAppName,
                  ),
                  style: m3e.typeScale.bodyMedium.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.permissionComparisonLimitationNote,
                  style: m3e.typeScale.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            report.mismatchCount > 0
                ? l10n.permissionComparisonMismatchNote(report.mismatchCount)
                : l10n.permissionComparisonNoMismatchNote,
            style: m3e.typeScale.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          EnprivePermissionComparisonList(
            report: report,
            l10n: l10n,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(EnpriveRadii.lg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    LucideIcons.info,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.permissionComparisonLimitationNote,
                    style: m3e.typeScale.bodySmall.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _UnlinkedAppCard extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isBusy;
  final VoidCallback onLinkApp;

  const _UnlinkedAppCard({
    required this.l10n,
    required this.isBusy,
    required this.onLinkApp,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    return Container(
      key: const Key('review_result_link_app_card'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(EnpriveRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.smartphone,
                    size: 20,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.linkInstalledAppCardTitle,
                      style: m3e.typography.emphasized.titleMedium.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.linkInstalledAppCardBody,
                      style: m3e.typeScale.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          EnpriveTactileButton(
            key: const Key('review_result_link_app_btn'),
            label: l10n.linkInstalledAppBtn,
            isSecondary: true,
            leading: const ExcludeSemantics(
              child: Icon(LucideIcons.link, size: 18),
            ),
            onPressed: isBusy ? null : onLinkApp,
          ),
        ],
      ),
    );
  }
}

class _AssociationStatusBlock extends StatelessWidget {
  final AppPolicyAssociationReport report;
  final String displayAppName;
  final String displayPackageName;
  final AppLocalizations l10n;

  const _AssociationStatusBlock({
    required this.report,
    required this.displayAppName,
    required this.displayPackageName,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;

    final isWarning =
        report.state == AppPolicyAssociationState.unmatched ||
        report.state == AppPolicyAssociationState.ambiguousIdentity;

    final (
      String title,
      String body,
      Color bg,
      Color fg,
      Color bodyFg,
      IconData icon,
    ) = switch (report.state) {
      AppPolicyAssociationState.packageIdentifierMentioned => (
        l10n.associationStatusPackageTitle,
        l10n.associationStatusPackageBody(displayPackageName, displayAppName),
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        scheme.onSecondaryContainer,
        LucideIcons.fileText,
      ),
      AppPolicyAssociationState.appNameMentioned => (
        l10n.associationStatusNameTitle,
        l10n.associationStatusNameBody(displayAppName),
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        scheme.onSecondaryContainer,
        LucideIcons.fileText,
      ),
      AppPolicyAssociationState.userLinkedUnverified => (
        l10n.associationStatusUnverifiedTitle,
        report.urlHostMatched
            ? l10n.associationStatusUnverifiedUrlHostBody(displayAppName)
            : l10n.associationStatusUnverifiedBody(displayAppName),
        scheme.surfaceContainerHigh,
        scheme.onSurface,
        scheme.onSurfaceVariant,
        LucideIcons.info,
      ),
      AppPolicyAssociationState.unmatched => (
        l10n.associationStatusUnmatchedTitle,
        l10n.associationStatusUnmatchedBody(
          displayAppName,
          report.conflictingPackageIdentifiers.join(', '),
        ),
        semantics.reviewRecommended.background,
        semantics.reviewRecommended.foreground,
        semantics.reviewRecommended.foreground,
        LucideIcons.triangleAlert,
      ),
      AppPolicyAssociationState.ambiguousIdentity => () {
        final String heading;
        final String detail;
        if (report.conflictingPackageIdentifiers.isNotEmpty) {
          heading = l10n.associationStatusAmbiguousConflictTitle;
          detail = l10n.associationStatusAmbiguousConflictBody(
            displayAppName,
            report.conflictingPackageIdentifiers.join(', '),
          );
        } else if (report.ambiguousCandidatePackages.isNotEmpty) {
          heading = l10n.associationStatusAmbiguousPeerTitle;
          detail = l10n.associationStatusAmbiguousPeerBody(
            displayAppName,
            report.ambiguousCandidatePackages.join(', '),
          );
        } else {
          heading = l10n.associationStatusAmbiguousConflictTitle;
          detail = l10n.associationStatusAmbiguousGenericBody(displayAppName);
        }
        return (
          heading,
          detail,
          semantics.reviewRecommended.background,
          semantics.reviewRecommended.foreground,
          semantics.reviewRecommended.foreground,
          LucideIcons.triangleAlert,
        );
      }(),
      AppPolicyAssociationState.unlinked => (
        l10n.associationStatusUnverifiedTitle,
        report.explanation,
        scheme.surfaceContainerHigh,
        scheme.onSurface,
        scheme.onSurfaceVariant,
        LucideIcons.info,
      ),
    };

    return Container(
      key: isWarning
          ? const Key('review_result_association_notice')
          : const Key('review_result_association_status'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(EnpriveRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 18, color: fg),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: m3e.typeScale.labelLarge.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: m3e.typeScale.bodySmall.copyWith(
                    color: bodyFg,
                    height: 1.4,
                  ),
                ),
                if (isWarning) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.associationOwnershipLimitation,
                    style: m3e.typeScale.bodySmall.copyWith(
                      color: bodyFg.withValues(alpha: 0.88),
                      height: 1.38,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Direction A segmented tonal list of on-device Android permission comparison
/// rows shared across policy-linked reviews and permission-only inspections.
class EnprivePermissionComparisonList extends StatelessWidget {
  final AppPermissionComparisonReport report;
  final AppLocalizations l10n;

  const EnprivePermissionComparisonList({
    super.key,
    required this.report,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final semantics = context.enpriveSemantics;

    // Facts stay neutral: an allowed permission is not an approval. Only a
    // permission the policy never mentions is marked, in the review amber.
    Widget chip(String label, {required bool mismatch}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: mismatch
              ? semantics.reviewRecommended.background
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(EnpriveRadii.chip),
        ),
        child: Text(
          label,
          style: m3e.typeScale.labelMedium.copyWith(
            color: mismatch
                ? semantics.reviewRecommended.foreground
                : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var idx = 0; idx < report.items.length; idx++) ...[
          if (idx > 0) const SizedBox(height: 2),
          Builder(
            builder: (context) {
              final item = report.items[idx];
              final isMismatch =
                  item.alignmentState ==
                  PermissionAlignmentState.undisclosedInPolicy;
              final statusChipLabel = !item.isRequested
                  ? l10n.permissionNotRequestedOnPhone
                  : (item.isGranted
                        ? l10n.permissionAllowedOnPhone
                        : l10n.permissionNotAllowedOnPhone);

              return Container(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 14, 16, 14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: EnpriveRadii.groupedCardRadius(
                    index: idx,
                    count: report.items.length,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isMismatch
                              ? semantics.reviewRecommended.background
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isMismatch
                              ? LucideIcons.triangleAlert
                              : LucideIcons.smartphone,
                          size: 18,
                          color: isMismatch
                              ? semantics.reviewRecommended.icon
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.friendlyName,
                            style: m3e.typeScale.titleMedium.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              chip(statusChipLabel, mismatch: false),
                              if (isMismatch)
                                chip(
                                  l10n.permissionMismatchChip,
                                  mismatch: true,
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.parentExplanation,
                            style: m3e.typeScale.bodyMedium.copyWith(
                              height: 1.4,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
