import 'dart:async';
import 'package:flutter/services.dart';

/// Special Android Usage Access status checked via AppOps on-device.
enum UsageAccessState {
  granted,
  denied,
  unavailable,
}

/// Resolution states returned by `ForegroundAppResolver` in Kotlin.
enum ForegroundResolutionStatus {
  identified,
  ambiguous,
  stale,
  usageAccessDenied,
  noRecentApplication,
  packageNotVisible,
  resolutionFailed,
  deviceLocked,
}

enum DeclaredPermissionGrantStatus {
  granted,
  denied,
  unavailable,
  manifestDeclaredOnly,
}

enum AppPermissionsLookupStatus {
  ok,
  invalidPackage,
  packageNotVisible,
  metadataUnavailable,
  deviceLocked,
  error,
}

enum TileAddOutcome {
  tileAdded,
  alreadyAdded,
  declined,
  failed,
  manualRequired,
  unavailable,
}

enum ExternalAppNavigationStatus {
  openedStore,
  openedWebFallback,
  openedSettings,
  activityNotFound,
  invalidPackage,
  failed,
  unavailable,
}

class ExternalAppNavigationResult {
  const ExternalAppNavigationResult({
    required this.status,
    required this.packageName,
    this.launchedUri,
    this.guidanceTip,
  });

  factory ExternalAppNavigationResult.fromMap(
    Map<dynamic, dynamic> map, {
    required String fallbackPackageName,
  }) {
    final rawStatus = map['status']?.toString();
    final status = switch (rawStatus) {
      'opened_store' => ExternalAppNavigationStatus.openedStore,
      'opened_web_fallback' => ExternalAppNavigationStatus.openedWebFallback,
      'opened_settings' => ExternalAppNavigationStatus.openedSettings,
      'activity_not_found' => ExternalAppNavigationStatus.activityNotFound,
      'invalid_package' => ExternalAppNavigationStatus.invalidPackage,
      'unavailable' => ExternalAppNavigationStatus.unavailable,
      _ => ExternalAppNavigationStatus.failed,
    };
    return ExternalAppNavigationResult(
      status: status,
      packageName: map['packageName']?.toString() ?? fallbackPackageName,
      launchedUri: map['launchedUri']?.toString(),
      guidanceTip: map['guidanceTip']?.toString(),
    );
  }

  final ExternalAppNavigationStatus status;
  final String packageName;
  final String? launchedUri;
  final String? guidanceTip;

  bool get isSuccess =>
      status == ExternalAppNavigationStatus.openedStore ||
      status == ExternalAppNavigationStatus.openedWebFallback ||
      status == ExternalAppNavigationStatus.openedSettings;
}

class CompanionInvocation {
  final String invocationId;
  final String source;
  final int timestampMs;
  final bool deviceLocked;

  const CompanionInvocation({
    required this.invocationId,
    required this.source,
    required this.timestampMs,
    this.deviceLocked = false,
  });

  factory CompanionInvocation.fromMap(Map<dynamic, dynamic> map) {
    return CompanionInvocation(
      invocationId: map['invocationId'] as String? ?? '',
      source: map['source'] as String? ?? 'quick_settings',
      timestampMs: (map['timestampMs'] as num?)?.toInt() ?? 0,
      deviceLocked: map['deviceLocked'] as bool? ?? false,
    );
  }
}

class ForegroundAppCandidate {
  final String packageName;
  final String applicationLabel;
  final int eventTimestampMs;
  final int eventAgeMillis;
  final bool permissionMetadataAvailable;

  const ForegroundAppCandidate({
    required this.packageName,
    required this.applicationLabel,
    required this.eventTimestampMs,
    required this.eventAgeMillis,
    this.permissionMetadataAvailable = true,
  });

  factory ForegroundAppCandidate.fromMap(Map<dynamic, dynamic> map) {
    final pkg = map['packageName'] as String? ?? '';
    return ForegroundAppCandidate(
      packageName: pkg,
      applicationLabel: (map['applicationLabel'] as String?)?.trim().isNotEmpty == true
          ? (map['applicationLabel'] as String).trim()
          : pkg,
      eventTimestampMs: (map['eventTimestamp'] as num?)?.toInt() ?? 0,
      eventAgeMillis: (map['eventAgeMillis'] as num?)?.toInt() ?? 0,
      permissionMetadataAvailable:
          map['permissionMetadataAvailable'] as bool? ?? false,
    );
  }
}

class ForegroundAppResolution {
  final ForegroundResolutionStatus status;
  final String? packageName;
  final String? applicationLabel;
  final int? eventTimestampMs;
  final int? eventAgeMillis;
  final String confidence;
  final String? fallbackReason;
  final List<ForegroundAppCandidate> candidates;
  final bool permissionMetadataAvailable;
  final bool sawTransientSystemUiEvent;

  const ForegroundAppResolution({
    required this.status,
    this.packageName,
    this.applicationLabel,
    this.eventTimestampMs,
    this.eventAgeMillis,
    this.confidence = 'none',
    this.fallbackReason,
    this.candidates = const [],
    this.permissionMetadataAvailable = false,
    this.sawTransientSystemUiEvent = false,
  });

  bool get hasCandidatePackage =>
      packageName != null && packageName!.trim().isNotEmpty;

  String get displayLabel {
    final label = applicationLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    return packageName?.trim() ?? 'Recent app';
  }

  factory ForegroundAppResolution.fromMap(Map<dynamic, dynamic> map) {
    final rawCandidates = map['candidates'] as List?;
    final parsedCandidates = rawCandidates
            ?.whereType<Map>()
            .map(ForegroundAppCandidate.fromMap)
            .where((c) => c.packageName.isNotEmpty)
            .toList(growable: false) ??
        const <ForegroundAppCandidate>[];

    return ForegroundAppResolution(
      status: _parseStatus(map['resolutionStatus'] as String?),
      packageName: map['packageName'] as String?,
      applicationLabel: map['applicationLabel'] as String?,
      eventTimestampMs: (map['eventTimestamp'] as num?)?.toInt(),
      eventAgeMillis: (map['eventAgeMillis'] as num?)?.toInt(),
      confidence: map['confidence'] as String? ?? 'none',
      fallbackReason: map['fallbackReason'] as String?,
      candidates: parsedCandidates,
      permissionMetadataAvailable:
          map['permissionMetadataAvailable'] as bool? ?? false,
      sawTransientSystemUiEvent:
          map['sawTransientSystemUiEvent'] as bool? ?? false,
    );
  }

  static ForegroundResolutionStatus _parseStatus(String? raw) {
    return switch (raw) {
      'identified' => ForegroundResolutionStatus.identified,
      'ambiguous' => ForegroundResolutionStatus.ambiguous,
      'stale' => ForegroundResolutionStatus.stale,
      'usageAccessDenied' => ForegroundResolutionStatus.usageAccessDenied,
      'noRecentApplication' => ForegroundResolutionStatus.noRecentApplication,
      'packageNotVisible' => ForegroundResolutionStatus.packageNotVisible,
      'deviceLocked' => ForegroundResolutionStatus.deviceLocked,
      _ => ForegroundResolutionStatus.resolutionFailed,
    };
  }
}

class DeclaredSensitivePermission {
  final String permission;
  final String categoryId;
  final String title;
  final String whatPermissionMeans;
  final DeclaredPermissionGrantStatus grantStatus;
  final bool isRuntimePermission;
  final String statusNote;

  const DeclaredSensitivePermission({
    required this.permission,
    required this.categoryId,
    required this.title,
    required this.whatPermissionMeans,
    required this.grantStatus,
    this.isRuntimePermission = true,
    required this.statusNote,
  });

  String get shortStatusLabel => switch (grantStatus) {
        DeclaredPermissionGrantStatus.granted => 'Declared · Currently granted',
        DeclaredPermissionGrantStatus.denied => 'Declared · Currently denied',
        DeclaredPermissionGrantStatus.unavailable =>
          'Declared · Status unavailable',
        DeclaredPermissionGrantStatus.manifestDeclaredOnly =>
          'Declared in manifest · Platform ID',
      };

  factory DeclaredSensitivePermission.fromMap(Map<dynamic, dynamic> map) {
    return DeclaredSensitivePermission(
      permission: map['permission'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? 'other',
      title: map['title'] as String? ?? 'Permission',
      whatPermissionMeans: map['whatPermissionMeans'] as String? ?? '',
      grantStatus: _parseGrantStatus(map['grantStatus'] as String?),
      isRuntimePermission: map['isRuntimePermission'] as bool? ?? true,
      statusNote:
          map['statusNote'] as String? ?? 'Declared in Android manifest',
    );
  }

  static DeclaredPermissionGrantStatus _parseGrantStatus(String? raw) {
    return switch (raw) {
      'granted' => DeclaredPermissionGrantStatus.granted,
      'denied' => DeclaredPermissionGrantStatus.denied,
      'manifestDeclaredOnly' =>
        DeclaredPermissionGrantStatus.manifestDeclaredOnly,
      _ => DeclaredPermissionGrantStatus.unavailable,
    };
  }
}

class AppSensitivePermissionsResult {
  final AppPermissionsLookupStatus status;
  final String packageName;
  final String? applicationLabel;
  final String? versionName;
  final int? versionCode;
  final List<DeclaredSensitivePermission> permissions;
  final String? errorMessage;

  const AppSensitivePermissionsResult({
    required this.status,
    required this.packageName,
    this.applicationLabel,
    this.versionName,
    this.versionCode,
    this.permissions = const [],
    this.errorMessage,
  });

  bool get isOk => status == AppPermissionsLookupStatus.ok;

  factory AppSensitivePermissionsResult.fromMap(Map<dynamic, dynamic> map) {
    final rawPerms = map['permissions'] as List?;
    final parsed = rawPerms
            ?.whereType<Map>()
            .map(DeclaredSensitivePermission.fromMap)
            .where((p) => p.permission.isNotEmpty)
            .toList(growable: false) ??
        const <DeclaredSensitivePermission>[];

    return AppSensitivePermissionsResult(
      status: _parseLookupStatus(map['status'] as String?),
      packageName: map['packageName'] as String? ?? '',
      applicationLabel: map['applicationLabel'] as String?,
      versionName: map['versionName'] as String?,
      versionCode: (map['versionCode'] as num?)?.toInt(),
      permissions: parsed,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  static AppPermissionsLookupStatus _parseLookupStatus(String? raw) {
    return switch (raw) {
      'ok' => AppPermissionsLookupStatus.ok,
      'invalid_package' => AppPermissionsLookupStatus.invalidPackage,
      'package_not_visible' => AppPermissionsLookupStatus.packageNotVisible,
      'metadata_unavailable' => AppPermissionsLookupStatus.metadataUnavailable,
      'device_locked' => AppPermissionsLookupStatus.deviceLocked,
      _ => AppPermissionsLookupStatus.error,
    };
  }
}

class QuickSettingsTileStatus {
  final bool canRequestDirectAdd;
  final bool isTileAdded;
  final bool hasDeclinedBefore;
  final int apiLevel;

  const QuickSettingsTileStatus({
    required this.canRequestDirectAdd,
    required this.isTileAdded,
    required this.hasDeclinedBefore,
    required this.apiLevel,
  });

  factory QuickSettingsTileStatus.fromMap(Map<dynamic, dynamic> map) {
    return QuickSettingsTileStatus(
      canRequestDirectAdd: map['canRequestDirectAdd'] as bool? ?? false,
      isTileAdded: map['isTileAdded'] as bool? ?? false,
      hasDeclinedBefore: map['hasDeclinedBefore'] as bool? ?? false,
      apiLevel: (map['apiLevel'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Typed Flutter boundary for Android Quick Settings tile setup, Usage Access,
/// one-time foreground application resolution, and PackageManager permissions.
class CompanionBridge {
  static const MethodChannel _channel = MethodChannel('com.enprive/companion');

  static final CompanionBridge _instance = CompanionBridge._internal();
  factory CompanionBridge() => _instance;

  final StreamController<CompanionInvocation> _invocationController =
      StreamController<CompanionInvocation>.broadcast();
  final Set<String> _processedInvocationIds = <String>{};

  CompanionBridge._internal() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Stream<CompanionInvocation> get invocations => _invocationController.stream;

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'onCompanionInvocation') {
      final args = call.arguments;
      if (args is Map) {
        final invocation = CompanionInvocation.fromMap(args);
        if (_markInvocationSeen(invocation.invocationId)) {
          _invocationController.add(invocation);
        }
      }
    }
    return null;
  }

  bool _markInvocationSeen(String invocationId) {
    if (invocationId.trim().isEmpty) return true;
    if (_processedInvocationIds.contains(invocationId)) return false;
    if (_processedInvocationIds.length >= 64) {
      _processedInvocationIds.remove(_processedInvocationIds.first);
    }
    _processedInvocationIds.add(invocationId);
    return true;
  }

  Future<CompanionInvocation?> getInitialCompanionInvocation() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getInitialCompanionInvocation',
      );
      if (raw == null || raw.isEmpty) return null;
      final invocation = CompanionInvocation.fromMap(raw);
      if (!_markInvocationSeen(invocation.invocationId)) return null;
      return invocation;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<({UsageAccessState status, bool deviceLocked})> checkUsageAccess() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'checkUsageAccess',
      );
      final statusStr = raw?['status'] as String?;
      final status = switch (statusStr) {
        'granted' => UsageAccessState.granted,
        'denied' => UsageAccessState.denied,
        _ => UsageAccessState.unavailable,
      };
      final locked = raw?['deviceLocked'] as bool? ?? false;
      return (status: status, deviceLocked: locked);
    } on PlatformException {
      return (status: UsageAccessState.unavailable, deviceLocked: false);
    } on MissingPluginException {
      return (status: UsageAccessState.unavailable, deviceLocked: false);
    }
  }

  Future<bool> openUsageAccessSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openUsageAccessSettings') ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<ForegroundAppResolution> resolveForegroundApp({
    int? invocationTimestampMs,
    int? windowMs,
  }) async {
    try {
      final args = <String, dynamic>{};
      if (invocationTimestampMs != null && invocationTimestampMs > 0) {
        args['invocationTimestampMs'] = invocationTimestampMs;
      }
      if (windowMs != null && windowMs > 0) {
        args['windowMs'] = windowMs;
      }
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'resolveForegroundApp',
        args,
      );
      if (raw == null) {
        return const ForegroundAppResolution(
          status: ForegroundResolutionStatus.resolutionFailed,
          fallbackReason: 'Foreground resolver returned no response.',
        );
      }
      return ForegroundAppResolution.fromMap(raw);
    } on PlatformException catch (e) {
      return ForegroundAppResolution(
        status: ForegroundResolutionStatus.resolutionFailed,
        fallbackReason: e.message ?? 'Foreground resolver unavailable.',
      );
    } on MissingPluginException {
      return const ForegroundAppResolution(
        status: ForegroundResolutionStatus.resolutionFailed,
        fallbackReason: 'Native foreground resolver unavailable on this build.',
      );
    }
  }

  Future<AppSensitivePermissionsResult> getDeclaredSensitivePermissions(
    String packageName,
  ) async {
    final trimmed = packageName.trim();
    if (trimmed.isEmpty) {
      return const AppSensitivePermissionsResult(
        status: AppPermissionsLookupStatus.invalidPackage,
        packageName: '',
        errorMessage: 'Package name cannot be empty.',
      );
    }
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getDeclaredSensitivePermissions',
        {'packageName': trimmed},
      );
      if (raw == null) {
        return AppSensitivePermissionsResult(
          status: AppPermissionsLookupStatus.metadataUnavailable,
          packageName: trimmed,
          errorMessage: 'Application permission metadata is unavailable.',
        );
      }
      return AppSensitivePermissionsResult.fromMap(raw);
    } on PlatformException catch (e) {
      return AppSensitivePermissionsResult(
        status: AppPermissionsLookupStatus.error,
        packageName: trimmed,
        errorMessage: e.message ?? 'Could not inspect package permissions.',
      );
    } on MissingPluginException {
      return AppSensitivePermissionsResult(
        status: AppPermissionsLookupStatus.error,
        packageName: trimmed,
        errorMessage: 'Native package inspector unavailable.',
      );
    }
  }

  Future<QuickSettingsTileStatus> getQuickSettingsTileStatus() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getQuickSettingsTileStatus',
      );
      if (raw == null) {
        return const QuickSettingsTileStatus(
          canRequestDirectAdd: false,
          isTileAdded: false,
          hasDeclinedBefore: false,
          apiLevel: 0,
        );
      }
      return QuickSettingsTileStatus.fromMap(raw);
    } on PlatformException {
      return const QuickSettingsTileStatus(
        canRequestDirectAdd: false,
        isTileAdded: false,
        hasDeclinedBefore: false,
        apiLevel: 0,
      );
    } on MissingPluginException {
      return const QuickSettingsTileStatus(
        canRequestDirectAdd: false,
        isTileAdded: false,
        hasDeclinedBefore: false,
        apiLevel: 0,
      );
    }
  }

  Future<TileAddOutcome> requestQuickSettingsTile() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'requestQuickSettingsTile',
      );
      final outcome = raw?['outcome'] as String?;
      return switch (outcome) {
        'tile_added' => TileAddOutcome.tileAdded,
        'already_added' => TileAddOutcome.alreadyAdded,
        'declined' => TileAddOutcome.declined,
        'manual_required' => TileAddOutcome.manualRequired,
        'unavailable' => TileAddOutcome.unavailable,
        _ => TileAddOutcome.failed,
      };
    } on PlatformException {
      return TileAddOutcome.failed;
    } on MissingPluginException {
      return TileAddOutcome.unavailable;
    }
  }

  static final RegExp _strictPackageNamePattern = RegExp(
    r'^[a-zA-Z0-9_]+(\.[a-zA-Z0-9_]+)+$',
  );

  static bool _isValidAndroidPackageName(String packageName) {
    final trimmed = packageName.trim();
    if (trimmed.isEmpty || trimmed.length > 255) return false;
    return _strictPackageNamePattern.hasMatch(trimmed);
  }

  /// Opens the user-selected Android app's Google Play Store listing via
  /// `market://details?id=...`, falling back to the Play Store web URL if no
  /// store client is installed. Never executes background scraping or network lookups.
  Future<ExternalAppNavigationResult> openPlayStoreListing(
    String packageName,
  ) async {
    final trimmed = packageName.trim();
    if (!_isValidAndroidPackageName(trimmed)) {
      return ExternalAppNavigationResult(
        status: ExternalAppNavigationStatus.invalidPackage,
        packageName: trimmed,
        guidanceTip:
            'Select a valid Android package identifier before opening its store listing.',
      );
    }
    return _invokeExternalNavigation('openPlayStoreListing', trimmed);
  }

  /// Opens Android's App info settings screen (`ACTION_APPLICATION_DETAILS_SETTINGS`)
  /// for the user-selected package identifier.
  Future<ExternalAppNavigationResult> openAppSystemSettings(
    String packageName,
  ) async {
    final trimmed = packageName.trim();
    if (!_isValidAndroidPackageName(trimmed)) {
      return ExternalAppNavigationResult(
        status: ExternalAppNavigationStatus.invalidPackage,
        packageName: trimmed,
        guidanceTip:
            'Select a valid Android package identifier before opening Android App info.',
      );
    }
    return _invokeExternalNavigation('openAppSystemSettings', trimmed);
  }

  Future<ExternalAppNavigationResult> _invokeExternalNavigation(
    String method,
    String packageName,
  ) async {
    try {
      final raw = await _channel.invokeMapMethod<dynamic, dynamic>(
        method,
        <String, Object?>{'packageName': packageName},
      );
      if (raw == null) {
        return ExternalAppNavigationResult(
          status: ExternalAppNavigationStatus.failed,
          packageName: packageName,
        );
      }
      return ExternalAppNavigationResult.fromMap(
        raw,
        fallbackPackageName: packageName,
      );
    } on PlatformException {
      return ExternalAppNavigationResult(
        status: ExternalAppNavigationStatus.failed,
        packageName: packageName,
      );
    } on MissingPluginException {
      return ExternalAppNavigationResult(
        status: ExternalAppNavigationStatus.unavailable,
        packageName: packageName,
      );
    }
  }

  Future<bool> returnToPreviousApp() async {
    try {
      return await _channel.invokeMethod<bool>('returnToPreviousApp') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
