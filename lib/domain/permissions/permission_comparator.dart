import '../../services/platform/hybrid_ai_bridge.dart';
import '../review/review_models.dart';

enum PermissionAlignmentState {
  undisclosedInPolicy,
  grantedAndDisclosed,
  disclosedNotGranted,
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
  static const String calibratedLimitationNotice =
      'Android reports this permission state on this phone. It does not prove whether the app actually accessed or transmitted data.';

  static const AppPermissionSnapshot demoEduTrackSnapshot =
      AppPermissionSnapshot(
    packageName: 'com.edutrack.classroom.demo',
    appName: 'EduTrack Classroom Companion',
    requestedPermissions: [
      'android.permission.ACCESS_FINE_LOCATION',
      'android.permission.ACCESS_BACKGROUND_LOCATION',
      'android.permission.RECORD_AUDIO',
      'android.permission.CAMERA',
      'com.google.android.gms.permission.AD_ID',
      'android.permission.INTERNET',
    ],
    grantedPermissions: [
      'android.permission.ACCESS_FINE_LOCATION',
      'android.permission.RECORD_AUDIO',
      'android.permission.CAMERA',
      'com.google.android.gms.permission.AD_ID',
      'android.permission.INTERNET',
    ],
  );

  static const AppPermissionSnapshot demoCalmMathSnapshot =
      AppPermissionSnapshot(
    packageName: 'com.calmmath.abacus.demo',
    appName: 'CalmMath Abacus',
    requestedPermissions: [
      'android.permission.VIBRATE',
    ],
    grantedPermissions: [
      'android.permission.VIBRATE',
    ],
  );

  static const List<_SensitivePermissionSpec> _catalog = [
    _SensitivePermissionSpec(
      permission: 'android.permission.ACCESS_FINE_LOCATION',
      friendlyName: 'Precise GPS Location',
      category: FindingCategory.tracking,
      severity: FindingSeverity.high,
      policyKeywords: ['location', 'gps', 'coordinates'],
      disclaimPhrases: [
        'do not collect personal identifiers, precise location',
        'do not collect location',
        'never collect location',
      ],
      capabilityDescription:
          'Allows reading street-level GPS coordinates while the app is open.',
    ),
    _SensitivePermissionSpec(
      permission: 'android.permission.ACCESS_BACKGROUND_LOCATION',
      friendlyName: 'Background Location Access',
      category: FindingCategory.tracking,
      severity: FindingSeverity.high,
      policyKeywords: ['background', 'location', 'bus zone'],
      disclaimPhrases: [
        'do not collect personal identifiers, precise location',
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
      policyKeywords: ['microphone', 'voice', 'audio', 'speech'],
      disclaimPhrases: [
        'microphone audio, or camera input',
        'do not collect microphone',
      ],
      capabilityDescription:
          'Allows capturing audio from the phone microphone.',
    ),
    _SensitivePermissionSpec(
      permission: 'android.permission.CAMERA',
      friendlyName: 'Camera & Photo Capture',
      category: FindingCategory.dataCollection,
      severity: FindingSeverity.high,
      policyKeywords: ['camera', 'photo', 'video capture', 'selfie'],
      disclaimPhrases: [
        'camera input',
        'do not collect camera',
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
      disclaimPhrases: ['do not collect contacts'],
      capabilityDescription:
          'Allows reading family and friend contact entries saved on this phone.',
    ),
    _SensitivePermissionSpec(
      permission: 'com.google.android.gms.permission.AD_ID',
      friendlyName: 'Google Advertising ID (AD_ID)',
      category: FindingCategory.sharing,
      severity: FindingSeverity.medium,
      policyKeywords: ['advertising', 'ad_id', 'behavioral promotions'],
      disclaimPhrases: [
        'do not integrate third-party advertising',
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

  /// Compares [snapshot] from Android PackageManager against [policyText].
  static AppPermissionComparisonReport compare({
    required AppPermissionSnapshot snapshot,
    required String policyText,
  }) {
    final lowerPolicy = policyText.toLowerCase();
    final items = <ComparedPermissionItem>[];

    for (final spec in _catalog) {
      final isRequested = snapshot.isRequested(spec.permission);
      final isGranted = snapshot.isGranted(spec.permission);

      final isDisclaimed = spec.disclaimPhrases.any(lowerPolicy.contains);
      final isMentioned = !isDisclaimed &&
          spec.policyKeywords.any((kw) => lowerPolicy.contains(kw));

      // Include in report if requested by the app OR mentioned in the policy
      if (!isRequested && !isMentioned) continue;

      final PermissionAlignmentState state;
      final String explanation;

      if (isRequested && (!isMentioned || isDisclaimed)) {
        state = PermissionAlignmentState.undisclosedInPolicy;
        explanation = isDisclaimed
            ? 'Policy explicitly states this data is not collected, yet the Android app manifest requests ${spec.friendlyName} (${isGranted ? "GRANTED" : "not granted"}).'
            : '${spec.friendlyName} is ${isGranted ? "GRANTED" : "requested"} on this phone, but the reviewed policy text makes no mention of ${spec.policyKeywords.first} use.';
      } else if (isRequested && isGranted) {
        state = PermissionAlignmentState.grantedAndDisclosed;
        explanation =
            'Disclosed in policy and currently GRANTED in Android Settings. ${spec.capabilityDescription}';
      } else if (isRequested && !isGranted) {
        state = PermissionAlignmentState.disclosedNotGranted;
        explanation =
            'Disclosed in policy and requested in manifest, but currently DENIED / NOT GRANTED on this phone.';
      } else {
        state = PermissionAlignmentState.notRequested;
        explanation =
            'Mentioned in the policy text, but this installed APK does not request ${spec.permission} on Android.';
      }

      final osSummary = !isRequested
          ? 'Not requested in APK manifest (${spec.permission})'
          : (isGranted
              ? 'GRANTED on this phone (${spec.permission})'
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

  /// Enriches policy findings with live Android OS observations and appends
  /// `DEVICE_OBSERVED` findings for any undisclosed OS permission mismatches.
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

    // Add dedicated DEVICE_OBSERVED findings for any undisclosed permissions!
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
              'Android Manifest Observation: ${mismatch.androidPermission} (${mismatch.isGranted ? "GRANTED" : "REQUESTED"}) — no matching disclosure found in policy snapshot.',
          explanation: mismatch.parentExplanation,
          whatPolicySays: mismatch.isExplicitlyDisclaimedInPolicy
              ? 'Policy disclaims collection of this capability, creating a contradiction with the APK manifest.'
              : 'No clause in the provided policy snapshot mentions ${mismatch.friendlyName.toLowerCase()}.',
          whatAndroidReports: mismatch.osStatusSummary,
          unknowns: const [
            calibratedLimitationNotice,
          ],
          status: EvidenceStatus.deviceObserved,
        ),
      );
    }

    return updated;
  }
}
