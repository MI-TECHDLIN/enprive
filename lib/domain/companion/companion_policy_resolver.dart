import '../../services/platform/companion_bridge.dart';
import '../permissions/permission_comparator.dart';
import '../review/deterministic_clause_scanner.dart';
import '../review/policy_sufficiency.dart';
import '../review/review_models.dart';

/// Guided mapping item shown when the user chooses "I'm not sure which
/// permission" so Enprive helps them recognize Android's prompt wording without
/// claiming knowledge of the live dialog.
class GuidedPermissionOption {
  final String categoryId;
  final String title;
  final String androidPromptHint;
  final String shortExplanation;

  const GuidedPermissionOption({
    required this.categoryId,
    required this.title,
    required this.androidPromptHint,
    required this.shortExplanation,
  });
}

/// Distinguishes whether verified policy text confirms, leaves ambiguous,
/// omits, or lacks any reviewed policy for an inspected Android permission.
enum CompanionDisclosureStatus {
  /// No verified privacy policy snapshot has been attached for this app yet.
  unverifiedPolicy,

  /// A verified policy snapshot exists, but no matching clause addresses this capability.
  missingDisclosure,

  /// Verified policy clauses are conditional, conflicting, or disclaimer-mismatched.
  ambiguousDisclosure,

  /// Verified policy text includes a direct affirmative clause addressing this capability.
  verifiedDisclosure,
}

/// Complete evidence-backed explanation model presented by the Quick Settings
/// Companion for a selected declared permission or general category topic.
class CompanionPermissionExplanation {
  final String title;
  final String categoryId;
  final String? androidPermission;
  final String whatPermissionMeans;
  final String whatAppDeclared;
  final String grantStatusSummary;
  final bool hasVerifiedPolicy;
  final CompanionDisclosureStatus disclosureStatus;
  final String policyStatusHeadline;
  final String whatPolicySays;
  final String? documentedFeatureReason;
  final List<String> verbatimExcerpts;
  final List<String> unknowns;
  final PolicyReviewReceipt? matchedReceipt;
  final List<String> suggestedQuestions;

  const CompanionPermissionExplanation({
    required this.title,
    required this.categoryId,
    this.androidPermission,
    required this.whatPermissionMeans,
    required this.whatAppDeclared,
    required this.grantStatusSummary,
    required this.hasVerifiedPolicy,
    required this.disclosureStatus,
    required this.policyStatusHeadline,
    required this.whatPolicySays,
    this.documentedFeatureReason,
    this.verbatimExcerpts = const [],
    this.unknowns = const [],
    this.matchedReceipt,
    this.suggestedQuestions = const [],
  });
}

/// Resolves verified local privacy-policy evidence and Android permission
/// explanations for the contextual Deni companion.
///
/// Guardrails:
/// - Never fabricates privacy-policy URLs from application names.
/// - Only treats a saved [PolicyReviewReceipt] as verified app policy evidence
///   when it explicitly matches the confirmed package name (or was attached
///   directly by the user in this session) and passes
///   [PolicySufficiencyValidator].
/// - Explicitly separates Android permission definitions, manifest observations,
///   verified policy quotes, and unknown gaps.
class CompanionPolicyResolver {
  static const String unverifiedPolicyHeadline =
      "We couldn't verify this application's privacy policy yet.";

  static const List<GuidedPermissionOption> guidedOptions = [
    GuidedPermissionOption(
      categoryId: 'location',
      title: 'Location',
      androidPromptHint:
          'Prompt asks for "device\'s location" (Precise or Approximate).',
      shortExplanation:
          'Lets an app read your GPS coordinates or general neighborhood.',
    ),
    GuidedPermissionOption(
      categoryId: 'camera',
      title: 'Camera',
      androidPromptHint:
          'Prompt asks to "take pictures and record video".',
      shortExplanation:
          'Lets an app open front or rear cameras for photos, scans, or video.',
    ),
    GuidedPermissionOption(
      categoryId: 'microphone',
      title: 'Microphone',
      androidPromptHint: 'Prompt asks to "record audio".',
      shortExplanation:
          'Lets an app listen or record voice and surrounding sound.',
    ),
    GuidedPermissionOption(
      categoryId: 'contacts',
      title: 'Contacts',
      androidPromptHint: 'Prompt asks to "access your contacts".',
      shortExplanation:
          'Lets an app read names, phone numbers, and emails in your address book.',
    ),
    GuidedPermissionOption(
      categoryId: 'photos_media',
      title: 'Photos and media',
      androidPromptHint:
          'Prompt asks to "access photos and videos" on this device.',
      shortExplanation:
          'Lets an app read saved photos, videos, or audio files.',
    ),
    GuidedPermissionOption(
      categoryId: 'notifications',
      title: 'Notifications',
      androidPromptHint: 'Prompt asks to "send you notifications".',
      shortExplanation:
          'Lets an app show banners, sounds, or badges in your notification shade.',
    ),
    GuidedPermissionOption(
      categoryId: 'nearby_devices',
      title: 'Nearby devices',
      androidPromptHint:
          'Prompt asks to "find, connect to, and determine the relative position of nearby devices".',
      shortExplanation:
          'Lets an app discover nearby Bluetooth or Wi-Fi accessories.',
    ),
    GuidedPermissionOption(
      categoryId: 'calendar',
      title: 'Calendar',
      androidPromptHint: 'Prompt asks to "access your calendar".',
      shortExplanation:
          'Lets an app read or create events and attendees on your calendar.',
    ),
    GuidedPermissionOption(
      categoryId: 'phone',
      title: 'Phone',
      androidPromptHint:
          'Prompt asks to "make and manage phone calls" or view SIM state.',
      shortExplanation:
          'Lets an app read phone number/call status or start calls.',
    ),
    GuidedPermissionOption(
      categoryId: 'sms',
      title: 'SMS',
      androidPromptHint: 'Prompt asks to "send and view SMS messages".',
      shortExplanation:
          'Lets an app read verification texts or send SMS messages.',
    ),
  ];

  /// Searches local verified [receipts] matching exact confirmed [packageName].
  /// Never matches heuristically by fuzzy app name alone.
  static PolicyReviewReceipt? findVerifiedReceiptForPackage(
    String? packageName,
    List<PolicyReviewReceipt> receipts,
  ) {
    final pkg = packageName?.trim();
    if (pkg == null || pkg.isEmpty) return null;

    final matches = receipts.where((r) {
      if (r.isPermissionOnlyInspection) return false;
      final receiptPkg = r.permissionReport?.snapshot.packageName;
      if (receiptPkg != pkg) return false;
      return PolicySufficiencyValidator.assess(r.snapshotText).isSufficient;
    }).toList();

    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches.first;
  }

  /// Builds an evidence-separated explanation for either a specific declared
  /// [permission] or a general [guidedCategory] topic when no app/permission
  /// was selected.
  static CompanionPermissionExplanation buildExplanation({
    DeclaredSensitivePermission? permission,
    GuidedPermissionOption? guidedCategory,
    String? confirmedAppLabel,
    String? confirmedPackageName,
    PolicyReviewReceipt? verifiedReceipt,
  }) {
    final title = permission?.title ?? guidedCategory?.title ?? 'Android permissions';
    final categoryId =
        permission?.categoryId ?? guidedCategory?.categoryId ?? 'other';
    final appDisplay = confirmedAppLabel?.trim().isNotEmpty == true
        ? confirmedAppLabel!.trim()
        : (confirmedPackageName ?? 'this app');

    final whatMeans = permission?.whatPermissionMeans.isNotEmpty == true
        ? permission!.whatPermissionMeans
        : (guidedCategory?.shortExplanation ??
            'Android protects sensitive device capabilities behind explicit permission controls.');

    final String whatDeclared;
    final String grantSummary;
    if (permission != null) {
      whatDeclared =
          '$appDisplay declares ${permission.permission} in its Android manifest. Declaring a permission means the app may ask for or use it, not that it is actively requesting it right now.';
      grantSummary = permission.statusNote;
    } else if (confirmedPackageName != null && confirmedPackageName.isNotEmpty) {
      whatDeclared =
          '$appDisplay did not have this specific permission selected from its manifest yet, or you chose general Android permission guidance.';
      grantSummary = 'General Android permission guide';
    } else {
      whatDeclared =
          'No specific app is selected. Enprive is explaining Android\'s general permission behavior without reading any app inventory.';
      grantSummary = 'Without app context';
    }

    final hasValidReceipt = verifiedReceipt != null &&
        !verifiedReceipt.isPermissionOnlyInspection &&
        PolicySufficiencyValidator.assess(verifiedReceipt.snapshotText)
            .isSufficient;

    final CompanionDisclosureStatus disclosureStatus;
    final String policyHeadline;
    final String whatPolicySays;
    String? documentedFeatureReason;
    final List<String> excerpts = [];

    if (!hasValidReceipt) {
      disclosureStatus = CompanionDisclosureStatus.unverifiedPolicy;
      policyHeadline = unverifiedPolicyHeadline;
      whatPolicySays =
          'No verified privacy policy is available for $appDisplay yet. The details above come from Android permission documentation and local package metadata only — this is not a privacy policy review.';
    } else {
      final targetPerm = permission?.permission ?? '';
      final inspection = PermissionComparator.inspectPermissionMentionInPolicy(
        androidPermission: targetPerm,
        categoryId: categoryId,
        policyText: verifiedReceipt.snapshotText,
      );
      excerpts.addAll(inspection.matchingExcerpts);

      // Include only source-matched policy findings that directly mention this
      // permission/category; never treat DEVICE_OBSERVED manifest notes or
      // unrelated category findings as verbatim policy disclosures.
      final mappedCategory = _mapCategoryIdToFindingCategory(categoryId);
      if (mappedCategory != null) {
        for (final f in verifiedReceipt.findings) {
          if (f.status == EvidenceStatus.sourceMatched &&
              f.category == mappedCategory &&
              !excerpts.contains(f.exactExcerpt)) {
            final excerptMatch =
                PermissionComparator.inspectPermissionMentionInPolicy(
              androidPermission: targetPerm,
              categoryId: categoryId,
              policyText: f.exactExcerpt,
            );
            if (excerptMatch.isMentioned || excerptMatch.isDisclaimed) {
              excerpts.add(f.exactExcerpt);
            }
          }
          if (excerpts.length >= 3) break;
        }
      }

      if (inspection.isDisclaimed) {
        disclosureStatus = CompanionDisclosureStatus.ambiguousDisclosure;
        policyHeadline = 'Policy text disclaims this collection';
        whatPolicySays =
            'The verified privacy policy contains language stating this capability or data is not collected, which contrasts with the app manifest.';
      } else if (excerpts.isNotEmpty) {
        documentedFeatureReason = _extractFeatureReason(excerpts);
        final isAmbiguous = _hasAmbiguousCondition(excerpts);
        if (isAmbiguous) {
          disclosureStatus = CompanionDisclosureStatus.ambiguousDisclosure;
          policyHeadline =
              'Conditional or ambiguous mention in verified policy text';
          whatPolicySays =
              'The verified policy text mentions $title conditionally or without confirming specific feature scope (quoted below verbatim from the captured snapshot).';
        } else {
          disclosureStatus = CompanionDisclosureStatus.verifiedDisclosure;
          policyHeadline = 'Mentioned in verified policy text';
          whatPolicySays =
              'The verified policy text includes clauses addressing $title (quoted below verbatim from the captured snapshot).';
        }
      } else {
        disclosureStatus = CompanionDisclosureStatus.missingDisclosure;
        policyHeadline = 'Not clearly explained in verified policy text';
        whatPolicySays =
            'The reviewed privacy policy text for $appDisplay does not explicitly mention $title.';
      }
    }

    final unknowns = <String>[
      if (permission != null)
        'Enprive cannot see which permission prompt Android is currently showing on screen or whether $appDisplay has accessed this data in practice.',
      if (!hasValidReceipt)
        'Whether $appDisplay shares, sells, or retains this data is unknown until its privacy policy is verified.',
      if (hasValidReceipt && documentedFeatureReason == null)
        'The verified policy quotes do not specify an exact in-app feature reason for requesting $title.',
      'You can describe the feature you were trying to use so Deni can tailor its explanation.',
    ];

    return CompanionPermissionExplanation(
      title: title,
      categoryId: categoryId,
      androidPermission: permission?.permission,
      whatPermissionMeans: whatMeans,
      whatAppDeclared: whatDeclared,
      grantStatusSummary: grantSummary,
      hasVerifiedPolicy: hasValidReceipt,
      disclosureStatus: disclosureStatus,
      policyStatusHeadline: policyHeadline,
      whatPolicySays: whatPolicySays,
      documentedFeatureReason: documentedFeatureReason,
      verbatimExcerpts: List<String>.unmodifiable(excerpts),
      unknowns: List<String>.unmodifiable(unknowns),
      matchedReceipt: verifiedReceipt,
      suggestedQuestions: buildSuggestedQuestions(title),
    );
  }

  static bool _hasAmbiguousCondition(List<String> excerpts) {
    final conditionalPattern = RegExp(
      r'\b(?:may|might|could|from\s+time\s+to\s+time|as\s+needed|where\s+applicable|certain\s+features)\b',
      caseSensitive: false,
    );
    var hasConditional = false;
    var hasNegation = false;
    var hasAffirmative = false;
    for (final excerpt in excerpts) {
      if (conditionalPattern.hasMatch(excerpt)) {
        hasConditional = true;
      }
      if (DeterministicClauseScanner.isNegatedClause(excerpt)) {
        hasNegation = true;
      } else {
        hasAffirmative = true;
      }
    }
    return hasConditional || (hasNegation && hasAffirmative);
  }

  static List<String> buildSuggestedQuestions(String permissionTitle) {
    final topic = _shortTopic(permissionTitle);
    return List<String>.unmodifiable([
      'Why does this app need my $topic?',
      'Does it need this for the feature I\'m using?',
      'What happens if I deny it?',
      'Does the policy say this information is shared?',
      'Can I use the app without granting this access?',
    ]);
  }

  static String _shortTopic(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('location')) return 'location';
    if (lower.contains('contact')) return 'contacts';
    if (lower.contains('camera')) return 'camera';
    if (lower.contains('microphone')) return 'microphone';
    if (lower.contains('photo') ||
        lower.contains('video') ||
        lower.contains('audio') ||
        lower.contains('media')) {
      return 'photos and media';
    }
    if (lower.contains('notification')) return 'notifications';
    if (lower.contains('calendar')) return 'calendar';
    if (lower.contains('sms')) return 'SMS messages';
    if (lower.contains('phone') || lower.contains('call')) return 'phone access';
    if (lower.contains('nearby') || lower.contains('bluetooth')) {
      return 'nearby devices access';
    }
    if (lower.contains('advertising')) return 'advertising ID';
    return lower;
  }

  static FindingCategory? _mapCategoryIdToFindingCategory(String categoryId) {
    return switch (categoryId) {
      'location' => FindingCategory.tracking,
      'advertising_id' => FindingCategory.sharing,
      'contacts' => FindingCategory.sharing,
      'microphone' => FindingCategory.retention,
      'camera' ||
      'photos_media' ||
      'calendar' ||
      'phone' ||
      'sms' ||
      'nearby_devices' ||
      'notifications' =>
        FindingCategory.dataCollection,
      _ => null,
    };
  }

  static String? _extractFeatureReason(List<String> excerpts) {
    final purposeRegex = RegExp(
      r'\b(?:in\s+order\s+to|used\s+to|allows?\s+you\s+to|for\s+(?:the\s+)?purpose\s+of|so\s+that)\b',
      caseSensitive: false,
    );
    for (final quote in excerpts) {
      if (purposeRegex.hasMatch(quote)) {
        return 'Quoted policy language states: “$quote”';
      }
    }
    return null;
  }
}
