import '../../services/platform/hybrid_ai_bridge.dart';
import '../review/deterministic_clause_scanner.dart';
import '../review/review_models.dart';

enum PermissionAlignmentState {
  undisclosedInPolicy,
  grantedAndDisclosed,
  disclosedNotGranted,
  observedWithoutPolicy,
  notRequested,
}

class ComparedPermissionItem {
  final String androidPermission;
  final String friendlyName;
  final FindingCategory category;
  final FindingSeverity severity;
  final bool isRequested;
  final bool isGranted;
  final bool isMentionedInPolicy;
  final bool isExplicitlyDisclaimedInPolicy;
  final PermissionAlignmentState alignmentState;
  final String osStatusSummary;
  final String parentExplanation;

  const ComparedPermissionItem({
    required this.androidPermission,
    required this.friendlyName,
    required this.category,
    required this.severity,
    required this.isRequested,
    required this.isGranted,
    required this.isMentionedInPolicy,
    required this.isExplicitlyDisclaimedInPolicy,
    required this.alignmentState,
    required this.osStatusSummary,
    required this.parentExplanation,
  });

  Map<String, dynamic> toJson() => {
        'androidPermission': androidPermission,
        'friendlyName': friendlyName,
        'category': category.name,
        'severity': severity.name,
        'isRequested': isRequested,
        'isGranted': isGranted,
        'isMentionedInPolicy': isMentionedInPolicy,
        'isExplicitlyDisclaimedInPolicy': isExplicitlyDisclaimedInPolicy,
        'alignmentState': alignmentState.name,
        'osStatusSummary': osStatusSummary,
        'parentExplanation': parentExplanation,
      };

  factory ComparedPermissionItem.fromJson(Map<String, dynamic> json) {
    return ComparedPermissionItem(
      androidPermission: json['androidPermission'] as String? ?? '',
      friendlyName: json['friendlyName'] as String? ?? '',
      category: FindingCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => FindingCategory.dataCollection,
      ),
      severity: FindingSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => FindingSeverity.medium,
      ),
      isRequested: json['isRequested'] as bool? ?? false,
      isGranted: json['isGranted'] as bool? ?? false,
      isMentionedInPolicy: json['isMentionedInPolicy'] as bool? ?? false,
      isExplicitlyDisclaimedInPolicy:
          json['isExplicitlyDisclaimedInPolicy'] as bool? ?? false,
      alignmentState: PermissionAlignmentState.values.firstWhere(
        (a) => a.name == json['alignmentState'],
        orElse: () => PermissionAlignmentState.notRequested,
      ),
      osStatusSummary: json['osStatusSummary'] as String? ?? '',
      parentExplanation: json['parentExplanation'] as String? ?? '',
    );
  }
}

class AppPermissionComparisonReport {
  final AppPermissionSnapshot snapshot;
  final List<ComparedPermissionItem> items;
  final String limitationNotice;

  const AppPermissionComparisonReport({
    required this.snapshot,
    required this.items,
    required this.limitationNotice,
  });

  int get mismatchCount => items
      .where(
        (i) => i.alignmentState == PermissionAlignmentState.undisclosedInPolicy,
      )
      .length;

  int get grantedSensitiveCount => items.where((i) => i.isGranted).length;

  int get requestedSensitiveCount => items.where((i) => i.isRequested).length;

  Map<String, dynamic> toJson() => {
        'snapshot': snapshot.toJson(),
        'items': items.map((i) => i.toJson()).toList(),
        'limitationNotice': limitationNotice,
      };

  factory AppPermissionComparisonReport.fromJson(Map<String, dynamic> json) {
    final snapshotMap =
        (json['snapshot'] as Map?)?.cast<String, dynamic>() ?? const {};
    final itemsList = (json['items'] as List?) ?? const [];
    return AppPermissionComparisonReport(
      snapshot: AppPermissionSnapshot.fromMap(snapshotMap),
      items: itemsList
          .whereType<Map>()
          .map((m) => ComparedPermissionItem.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      limitationNotice: json['limitationNotice'] as String? ??
          PermissionComparator.calibratedLimitationNotice,
    );
  }
}

class _SensitivePermissionSpec {
  final String permission;
  final String friendlyName;
  final FindingCategory category;
  final FindingSeverity severity;
  final List<String> policyKeywords;
  final List<String> disclaimPhrases;
  final String capabilityDescription;

  const _SensitivePermissionSpec({
    required this.permission,
    required this.friendlyName,
    required this.category,
    required this.severity,
    required this.policyKeywords,
    required this.disclaimPhrases,
    required this.capabilityDescription,
  });
}

/// Deterministic on-device comparator matching Android PackageManager
/// permission states against captured policy claims.
/// Privacy Guardrail: Never invokes cloud or generative AI models.
class PermissionComparator {
  static const String standaloneAndroidReportText =
      'No app is linked yet. Link an installed app on this review to compare with phone permissions.';

  static const String calibratedLimitationNotice =
      'Android reports this permission setting on this phone. It does not prove whether the app actually used or sent data.';

  static const String permissionOnlyLimitationNotice =
      'Phone permissions only: these permissions are read directly from your phone. Enprive has not checked a privacy policy for this app yet and cannot say what the developer collects or keeps.';

  static const List<_SensitivePermissionSpec> _catalog = [
    _SensitivePermissionSpec(
      permission: 'android.permission.ACCESS_FINE_LOCATION',
      friendlyName: 'Precise GPS Location',
      category: FindingCategory.tracking,
      severity: FindingSeverity.high,
      policyKeywords: [
        'gps',
        'precise location',
        'exact location',
        'geolocation coordinates',
        'location data',
        'location',
      ],
      disclaimPhrases: [
        'do not collect personal identifiers, precise location',
        'do not collect precise location',
        'do not collect location',
        'never collect location',
        'never track location',
      ],
      capabilityDescription:
          'Allows reading street-level GPS coordinates while the app is open.',
    ),
    _SensitivePermissionSpec(
      permission: 'android.permission.ACCESS_BACKGROUND_LOCATION',
      friendlyName: 'Background Location Access',
      category: FindingCategory.tracking,
      severity: FindingSeverity.high,
      policyKeywords: [
        'background location',
        'background gps',
        'even when the app is running in the background',
        'even when the application is running in the background',
        'when the app is running in the background',
        'when running in the background',
        'bus zone',
      ],
      disclaimPhrases: [
        'do not collect personal identifiers, precise location',
        'do not collect precise location',
        'do not collect location',
      ],
      capabilityDescription:
          'Allows tracking device location even when the child closes the app.',
    ),
    _SensitivePermissionSpec(
      permission: 'android.permission.RECORD_AUDIO',
      friendlyName: 'Microphone & Voice Recording',
      category: FindingCategory.retention,
      severity: FindingSeverity.high,
      policyKeywords: ['microphone', 'voice recording', 'audio recording', 'speech'],
      disclaimPhrases: [
        'do not collect microphone',
        'never collect microphone',
        'do not record audio',
      ],
      capabilityDescription:
          'Allows capturing audio from the phone microphone.',
    ),
    _SensitivePermissionSpec(
      permission: 'android.permission.CAMERA',
      friendlyName: 'Camera & Photo Capture',
      category: FindingCategory.dataCollection,
      severity: FindingSeverity.high,
      policyKeywords: ['camera input', 'camera', 'photo capture', 'video capture', 'selfie'],
      disclaimPhrases: [
        'do not collect camera',
        'never collect camera',
        'do not access the camera',
        'never access the camera',
      ],
      capabilityDescription:
          'Allows taking photos or recording video through the device cameras.',
    ),
    _SensitivePermissionSpec(
      permission: 'android.permission.READ_CONTACTS',
      friendlyName: 'Address Book & Contacts',
      category: FindingCategory.sharing,
      severity: FindingSeverity.high,
      policyKeywords: ['contacts', 'address book', 'phonebook'],
      disclaimPhrases: ['do not collect contacts', 'do not access contacts'],
      capabilityDescription:
          'Allows reading family and friend contact entries saved on this phone.',
    ),
    _SensitivePermissionSpec(
      permission: 'com.google.android.gms.permission.AD_ID',
      friendlyName: 'Google Advertising ID (AD_ID)',
      category: FindingCategory.sharing,
      severity: FindingSeverity.medium,
      policyKeywords: [
        'advertising id',
        'advertising identifier',
        'advertising identifiers',
        'android advertising id',
        'ad_id',
        'behavioral promotions',
        'third-party advertising partners',
        'advertising partner',
        'advertising partners',
        'ad networks',
        'personalized ads',
      ],
      disclaimPhrases: [
        'do not integrate third-party advertising',
        'do not include any third party advertising',
        'no third-party advertising',
        'no third party advertising',
        'never sell, rent, or transmit',
      ],
      capabilityDescription:
          'Allows reading a cross-app advertising identifier for ad attribution or profiling.',
    ),
    _SensitivePermissionSpec(
      permission: 'android.permission.READ_MEDIA_IMAGES',
      friendlyName: 'Photo Library Access',
      category: FindingCategory.dataCollection,
      severity: FindingSeverity.medium,
      policyKeywords: ['photo library', 'gallery', 'media files'],
      disclaimPhrases: ['do not access your photos'],
      capabilityDescription:
          'Allows reading saved photos and images stored on the device.',
    ),
  ];

  /// Inspects Android OS permissions locally without fabricating or comparing
  /// against a privacy policy.
  static AppPermissionComparisonReport inspectPermissionsOnly({
    required AppPermissionSnapshot snapshot,
  }) {
    final items = <ComparedPermissionItem>[];
    final knownPermissions = <String>{};

    for (final spec in _catalog) {
      knownPermissions.add(spec.permission);
      final isRequested = snapshot.isRequested(spec.permission);
      final isGranted = snapshot.isGranted(spec.permission);
      if (!isRequested && !isGranted) {
        continue;
      }

      final state = PermissionAlignmentState.observedWithoutPolicy;
      final osSummary = isGranted
          ? 'Allowed on this phone (${spec.permission})'
          : 'Asked for by app · Currently NOT allowed (${spec.permission})';
      final statusNote = isGranted
          ? 'Currently allowed on this phone.'
          : 'Listed by the app, not currently allowed on this phone.';

      items.add(
        ComparedPermissionItem(
          androidPermission: spec.permission,
          friendlyName: spec.friendlyName,
          category: spec.category,
          severity: spec.severity,
          isRequested: isRequested,
          isGranted: isGranted,
          isMentionedInPolicy: false,
          isExplicitlyDisclaimedInPolicy: false,
          alignmentState: state,
          osStatusSummary: osSummary,
          parentExplanation: '${spec.capabilityDescription} $statusNote',
        ),
      );
    }

    final extraPermissions = <String>{
      ...snapshot.requestedPermissions,
      ...snapshot.grantedPermissions,
    }..removeAll(knownPermissions);

    for (final perm in extraPermissions.toList()..sort()) {
      final isRequested = snapshot.isRequested(perm);
      final isGranted = snapshot.isGranted(perm);
      final osSummary = isGranted
          ? 'Allowed on this phone ($perm)'
          : 'Asked for by app · Currently NOT allowed ($perm)';
      items.add(
        ComparedPermissionItem(
          androidPermission: perm,
          friendlyName: _humanizeAndroidPermission(perm),
          category: FindingCategory.dataCollection,
          severity: FindingSeverity.low,
          isRequested: isRequested,
          isGranted: isGranted,
          isMentionedInPolicy: false,
          isExplicitlyDisclaimedInPolicy: false,
          alignmentState: PermissionAlignmentState.observedWithoutPolicy,
          osStatusSummary: osSummary,
          parentExplanation: isGranted
              ? 'Allowed on this phone. Add this app\'s privacy policy to check why the developer asks for it.'
              : 'Listed by the app (not currently allowed). Add this app\'s privacy policy to review developer explanations.',
        ),
      );
    }

    return AppPermissionComparisonReport(
      snapshot: snapshot,
      items: items,
      limitationNotice: permissionOnlyLimitationNotice,
    );
  }

  static String _humanizeAndroidPermission(String permission) {
    final short = permission.contains('.')
        ? permission.split('.').last
        : permission;
    final words = short
        .toLowerCase()
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}');
    return words.isEmpty ? permission : words.join(' ');
  }

  /// Compares [snapshot] from Android PackageManager against genuine
  /// [policyText].
  static AppPermissionComparisonReport compare({
    required AppPermissionSnapshot snapshot,
    required String policyText,
  }) {
    if (policyText.trim().isEmpty) {
      return inspectPermissionsOnly(snapshot: snapshot);
    }
    final lowerPolicy = policyText.toLowerCase();
    final items = <ComparedPermissionItem>[];

    for (final spec in _catalog) {
      final isRequested = snapshot.isRequested(spec.permission);
      final isGranted = snapshot.isGranted(spec.permission);

      final clauseMatch = _assessKeywordDisclosure(
        policyText: policyText,
        lowerPolicy: lowerPolicy,
        spec: spec,
      );
      final isDisclaimed = clauseMatch.isDisclaimed;
      final isMentioned = clauseMatch.isMentioned;

      // Include in report if requested by the app OR affirmatively mentioned in the policy
      if (!isRequested && !isMentioned) continue;

      final PermissionAlignmentState state;
      final String explanation;

      if (isRequested && (!isMentioned || isDisclaimed)) {
        state = PermissionAlignmentState.undisclosedInPolicy;
        explanation = isDisclaimed
            ? 'Policy explicitly states this data is not collected, yet the Android app manifest requests ${spec.friendlyName} (${isGranted ? "allowed" : "not allowed"}).'
            : '${spec.friendlyName} is ${isGranted ? "allowed" : "requested"} on this phone, but the reviewed policy text makes no mention of ${spec.policyKeywords.first} use.';
      } else if (isRequested && isGranted) {
        state = PermissionAlignmentState.grantedAndDisclosed;
        explanation =
            'Disclosed in policy and currently allowed in Android Settings. ${spec.capabilityDescription}';
      } else if (isRequested && !isGranted) {
        state = PermissionAlignmentState.disclosedNotGranted;
        explanation =
            'Disclosed in policy and requested in manifest, but currently not allowed on this phone.';
      } else {
        state = PermissionAlignmentState.notRequested;
        explanation =
            'Mentioned in the policy text, but this installed APK does not request ${spec.permission} on Android.';
      }

      final osSummary = !isRequested
          ? 'Not requested in APK manifest (${spec.permission})'
          : (isGranted
                ? 'Allowed on this phone (${spec.permission})'
                : 'Requested in manifest · Currently NOT granted (${spec.permission})');

      items.add(
        ComparedPermissionItem(
          androidPermission: spec.permission,
          friendlyName: spec.friendlyName,
          category: spec.category,
          severity: spec.severity,
          isRequested: isRequested,
          isGranted: isGranted,
          isMentionedInPolicy: isMentioned,
          isExplicitlyDisclaimedInPolicy: isDisclaimed,
          alignmentState: state,
          osStatusSummary: osSummary,
          parentExplanation: explanation,
        ),
      );
    }

    return AppPermissionComparisonReport(
      snapshot: snapshot,
      items: items,
      limitationNotice: calibratedLimitationNotice,
    );
  }

  static final RegExp _sentenceSplit = RegExp(r'(?<=[.!?])\s+|\n+');
  static final RegExp _coarseIpPhrase = RegExp(
    r'\b(?:imprecise|approximate|coarse|masked\s+ip)\b[^.]{0,40}\blocation\b|\blocation\b[^.]{0,25}\b(?:imprecise|approximate|coarse)\b',
    caseSensitive: false,
  );

  static ({bool isDisclaimed, bool isMentioned}) _assessKeywordDisclosure({
    required String policyText,
    required String lowerPolicy,
    required _SensitivePermissionSpec spec,
  }) {
    final sentences = policyText
        .split(_sentenceSplit)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    var hasExplicitDisclaimer =
        spec.disclaimPhrases.any((phrase) => lowerPolicy.contains(phrase));
    var hasAffirmativeMention = false;

    for (final sentence in sentences) {
      final sentenceLower = sentence.toLowerCase();

      // Masked-IP / imprecise regional estimation is distinct from GPS/location tracking
      final isCoarseLocationOnly =
          (spec.permission == 'android.permission.ACCESS_FINE_LOCATION' ||
              spec.permission ==
                  'android.permission.ACCESS_BACKGROUND_LOCATION') &&
          _coarseIpPhrase.hasMatch(sentenceLower) &&
          !RegExp(r'\b(?:gps|precise\s+location|exact\s+location|background\s+location)\b', caseSensitive: false)
              .hasMatch(sentenceLower);
      if (isCoarseLocationOnly) {
        continue;
      }

      final matchesKeyword = spec.policyKeywords.any((kw) {
        final escaped = RegExp.escape(kw);
        return RegExp('(?:^|[^a-z0-9_])$escaped(?:\$|[^a-z0-9_])')
            .hasMatch(sentenceLower);
      });
      final matchesDisclaimerPhrase = spec.disclaimPhrases.any(
        (phrase) => sentenceLower.contains(phrase),
      );
      if (!matchesKeyword && !matchesDisclaimerPhrase) continue;

      if (matchesDisclaimerPhrase ||
          DeterministicClauseScanner.isNegatedClause(sentence)) {
        hasExplicitDisclaimer = true;
      } else {
        hasAffirmativeMention = true;
      }
    }

    return (
      isDisclaimed: hasExplicitDisclaimer && !hasAffirmativeMention,
      isMentioned: hasAffirmativeMention,
    );
  }

  /// Enriches policy findings with live Android OS observations and appends
  /// `DEVICE_OBSERVED` findings for undisclosed OS permission mismatches.
  static List<VerifiedFinding> enrichFindingsWithDeviceReport({
    required List<VerifiedFinding> policyFindings,
    required AppPermissionComparisonReport report,
  }) {
    final updated = <VerifiedFinding>[];

    for (final f in policyFindings) {
      final matchingPerms = report.items
          .where((item) => item.category == f.category)
          .toList();

      final String androidReportText;
      if (matchingPerms.isNotEmpty) {
        androidReportText = matchingPerms
            .map((m) => '${m.friendlyName}: ${m.osStatusSummary}')
            .join(' · ');
      } else {
        androidReportText =
            'Inspected ${report.snapshot.appName} (${report.snapshot.packageName}): ${report.grantedSensitiveCount} sensitive permissions currently granted on this phone.';
      }

      updated.add(
        VerifiedFinding(
          id: f.id,
          title: f.title,
          category: f.category,
          severity: f.severity,
          exactExcerpt: f.exactExcerpt,
          explanation: f.explanation,
          whatPolicySays: f.whatPolicySays,
          whatAndroidReports: androidReportText,
          unknowns: f.unknowns,
          status: f.status,
          contextWindow: f.contextWindow,
        ),
      );
    }

    // Add dedicated DEVICE_OBSERVED findings for any undisclosed permissions.
    for (final mismatch in report.items.where(
      (i) => i.alignmentState == PermissionAlignmentState.undisclosedInPolicy,
    )) {
      updated.add(
        VerifiedFinding(
          id: 'perm_${mismatch.androidPermission.split('.').last.toLowerCase()}',
          title: 'Undisclosed Android Permission: ${mismatch.friendlyName}',
          category: mismatch.category,
          severity: mismatch.severity,
          exactExcerpt:
              'Android Manifest Observation: ${mismatch.androidPermission} (${mismatch.isGranted ? "allowed" : "requested"}) — no matching disclosure found in policy snapshot.',
          explanation: mismatch.parentExplanation,
          whatPolicySays: mismatch.isExplicitlyDisclaimedInPolicy
              ? 'Policy disclaims collection of this capability, creating a contradiction with the APK manifest.'
              : 'No clause in the provided policy snapshot mentions ${mismatch.friendlyName.toLowerCase()}.',
          whatAndroidReports: mismatch.osStatusSummary,
          unknowns: const [calibratedLimitationNotice],
          status: EvidenceStatus.deviceObserved,
        ),
      );
    }

    return updated;
  }

  /// Strips previously attached on-device permission findings and resets
  /// policy findings' `whatAndroidReports` to standalone copy so changing or
  /// unlinking an installed app on an open review is clean and idempotent.
  static List<VerifiedFinding> stripDeviceReportFromFindings(
    List<VerifiedFinding> findings,
  ) {
    final cleaned = <VerifiedFinding>[];
    for (final f in findings) {
      if (f.isDeviceObserved) continue;
      cleaned.add(
        VerifiedFinding(
          id: f.id,
          title: f.title,
          category: f.category,
          severity: f.severity,
          exactExcerpt: f.exactExcerpt,
          explanation: f.explanation,
          whatPolicySays: f.whatPolicySays,
          whatAndroidReports: standaloneAndroidReportText,
          unknowns: f.unknowns,
          status: f.status,
          contextWindow: f.contextWindow,
        ),
      );
    }
    return List<VerifiedFinding>.unmodifiable(cleaned);
  }

  static const Map<String, List<String>> _companionCategoryKeywords = {
    'location': [
      'gps',
      'precise location',
      'exact location',
      'geolocation coordinates',
      'background location',
      'background gps',
      'location data',
      'location',
    ],
    'camera': ['camera input', 'camera', 'photo capture', 'video capture', 'selfie'],
    'microphone': ['microphone', 'voice recording', 'audio recording', 'speech'],
    'contacts': ['contacts', 'address book', 'phonebook'],
    'calendar': ['calendar', 'calendar events', 'schedule'],
    'phone': ['phone number', 'phone numbers', 'call log', 'call history', 'device phone'],
    'sms': ['sms', 'text message', 'text messages', 'verification code'],
    'photos_media': ['photo library', 'photos', 'videos', 'media files', 'gallery', 'storage'],
    'nearby_devices': ['bluetooth', 'nearby devices', 'wi-fi direct', 'beacons'],
    'notifications': ['notifications', 'push notification', 'push notifications', 'alerts'],
    'advertising_id': [
      'advertising id',
      'advertising identifier',
      'advertising identifiers',
      'android advertising id',
      'ad_id',
      'behavioral promotions',
      'third-party advertising partners',
      'advertising partner',
      'advertising partners',
      'ad networks',
      'personalized ads',
    ],
  };

  /// Reuses [PermissionComparator]'s negation-aware & coarse-IP-aware matching
  /// for a single declared permission or companion category against [policyText].
  static ({
    bool isMentioned,
    bool isDisclaimed,
    List<String> matchingExcerpts,
  }) inspectPermissionMentionInPolicy({
    required String androidPermission,
    required String policyText,
    String? categoryId,
  }) {
    if (policyText.trim().isEmpty) {
      return (isMentioned: false, isDisclaimed: false, matchingExcerpts: const []);
    }

    final lowerPolicy = policyText.toLowerCase();
    final catalogMatch = _catalog
        .where((s) => s.permission == androidPermission)
        .cast<_SensitivePermissionSpec?>()
        .firstWhere((_) => true, orElse: () => null);

    final keywords = catalogMatch?.policyKeywords ??
        _companionCategoryKeywords[categoryId] ??
        const <String>[];
    final disclaimPhrases = catalogMatch?.disclaimPhrases ?? const <String>[];

    final spec = catalogMatch ??
        _SensitivePermissionSpec(
          permission: androidPermission,
          friendlyName: categoryId ?? androidPermission,
          category: FindingCategory.dataCollection,
          severity: FindingSeverity.medium,
          policyKeywords: keywords,
          disclaimPhrases: disclaimPhrases,
          capabilityDescription: '',
        );

    final clauseMatch = _assessKeywordDisclosure(
      policyText: policyText,
      lowerPolicy: lowerPolicy,
      spec: spec,
    );

    final matchingExcerpts = <String>[];
    final sentences = policyText
        .split(_sentenceSplit)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    for (final sentence in sentences) {
      final sentenceLower = sentence.toLowerCase();
      final matchesKw = keywords.any((kw) {
        final escaped = RegExp.escape(kw);
        return RegExp('(?:^|[^a-z0-9_])$escaped(?:\$|[^a-z0-9_])')
            .hasMatch(sentenceLower);
      });
      final matchesDisclaim =
          disclaimPhrases.any((phrase) => sentenceLower.contains(phrase));
      if (matchesKw || matchesDisclaim) {
        matchingExcerpts.add(sentence);
      }
      if (matchingExcerpts.length >= 3) break;
    }

    return (
      isMentioned: clauseMatch.isMentioned,
      isDisclaimed: clauseMatch.isDisclaimed,
      matchingExcerpts: List<String>.unmodifiable(matchingExcerpts),
    );
  }
}
