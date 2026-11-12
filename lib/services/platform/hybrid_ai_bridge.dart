import 'dart:async';
import 'package:flutter/services.dart';

enum HybridStatus {
  success,
  unavailable,
  unsupported,
  busy,
  failed,
}

enum ModelDownloadStatus {
  unavailable,
  downloadable,
  downloading,
  available,
  failed,
}

class DeviceCapability {
  final bool isSupported;
  final ModelDownloadStatus modelStatus;
  final String? modelCategory;
  final int apiLevel;
  final String userMessage;

  const DeviceCapability({
    required this.isSupported,
    required this.modelStatus,
    this.modelCategory,
    required this.apiLevel,
    required this.userMessage,
  });

  factory DeviceCapability.fromMap(Map<dynamic, dynamic> map) {
    return DeviceCapability(
      isSupported: map['isSupported'] as bool? ?? false,
      modelStatus: _parseDownloadStatus(map['modelStatus'] as String?),
      modelCategory: map['modelCategory'] as String?,
      apiLevel: map['apiLevel'] as int? ?? 0,
      userMessage: map['userMessage'] as String? ?? 'Status unknown',
    );
  }

  static ModelDownloadStatus _parseDownloadStatus(String? status) {
    return switch (status?.toUpperCase()) {
      'AVAILABLE' => ModelDownloadStatus.available,
      'DOWNLOADING' => ModelDownloadStatus.downloading,
      'DOWNLOADABLE' => ModelDownloadStatus.downloadable,
      'UNAVAILABLE' => ModelDownloadStatus.unavailable,
      _ => ModelDownloadStatus.failed,
    };
  }
}

class HybridAnalysisResult {
  final int schemaVersion;
  final String requestId;
  final HybridStatus status;
  final String inferenceSource; // "ON_DEVICE" | "IN_CLOUD" | "UNKNOWN"
  final Map<String, dynamic>? structuredOutput;
  final String? errorCode;
  final String? message;

  const HybridAnalysisResult({
    required this.schemaVersion,
    required this.requestId,
    required this.status,
    required this.inferenceSource,
    this.structuredOutput,
    this.errorCode,
    this.message,
  });

  factory HybridAnalysisResult.fromMap(Map<dynamic, dynamic> map) {
    return HybridAnalysisResult(
      schemaVersion: map['schemaVersion'] as int? ?? 1,
      requestId: map['requestId'] as String? ?? '',
      status: _parseStatus(map['status'] as String?),
      inferenceSource: map['inferenceSource'] as String? ?? 'UNKNOWN',
      structuredOutput: (map['structuredOutput'] as Map?)?.cast<String, dynamic>(),
      errorCode: map['errorCode'] as String?,
      message: map['message'] as String?,
    );
  }

  static HybridStatus _parseStatus(String? s) {
    return switch (s?.toLowerCase()) {
      'success' => HybridStatus.success,
      'unavailable' => HybridStatus.unavailable,
      'unsupported' => HybridStatus.unsupported,
      'busy' => HybridStatus.busy,
      _ => HybridStatus.failed,
    };
  }
}

class HybridAiBridge {
  static const MethodChannel _channel = MethodChannel('com.enprive/hybrid_ai');

  /// Queries the Android device for Gemini Nano 4 readiness.
  Future<DeviceCapability> getDeviceCapability() async {
    try {
      final res = await _channel.invokeMethod<Map>('getDeviceCapability');
      if (res == null) {
        return const DeviceCapability(
          isSupported: false,
          modelStatus: ModelDownloadStatus.unavailable,
          apiLevel: 0,
          userMessage: 'Platform channel returned empty capability response.',
        );
      }
      return DeviceCapability.fromMap(res);
    } on PlatformException catch (e) {
      return DeviceCapability(
        isSupported: false,
        modelStatus: ModelDownloadStatus.failed,
        apiLevel: 0,
        userMessage: 'Capability check error: ${e.message}',
      );
    } on MissingPluginException {
      return const DeviceCapability(
        isSupported: false,
        modelStatus: ModelDownloadStatus.unavailable,
        apiLevel: 0,
        userMessage: 'Native Android bridge not attached.',
      );
    }
  }

  /// Initiates or verifies on-device model download (returns stream/status).
  Future<ModelDownloadStatus> downloadOrCheckModel() async {
    try {
      final res = await _channel.invokeMethod<String>('downloadOrCheckModel');
      return DeviceCapability._parseDownloadStatus(res);
    } on PlatformException {
      return ModelDownloadStatus.failed;
    } on MissingPluginException {
      return ModelDownloadStatus.unavailable;
    }
  }

  /// Warms up the on-device Gemini Nano 4 model in AICore before inference.
  Future<bool> warmUpModel() async {
    try {
      final res = await _channel.invokeMethod<bool>('warmUpModel');
      return res ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Retrieves any text passed into the app via Android ACTION_PROCESS_TEXT
  /// or ACTION_SEND (system text selection or share sheet).
  Future<String?> getInitialSelectedText() async {
    try {
      final res = await _channel.invokeMethod<String>('getInitialSelectedText');
      if (res == null || res.trim().isEmpty) return null;
      return res.trim();
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Sends text for hybrid evaluation.
  /// If [cloudConsent] is false, native code strictly enforces ONLY_ON_DEVICE.
  Future<HybridAnalysisResult> analyseText({
    required String requestId,
    required String task,
    required String text,
    required bool cloudConsent,
    String? sourceSnapshotId,
  }) async {
    try {
      final res = await _channel.invokeMethod<Map>('analyseText', {
        'schemaVersion': 1,
        'requestId': requestId,
        'task': task,
        'text': text,
        'requestedMode': cloudConsent ? 'ONLY_IN_CLOUD' : 'ONLY_ON_DEVICE',
        'cloudConsent': cloudConsent,
        'sourceSnapshotId': sourceSnapshotId,
      });

      if (res == null) {
        return HybridAnalysisResult(
          schemaVersion: 1,
          requestId: requestId,
          status: HybridStatus.failed,
          inferenceSource: 'UNKNOWN',
          message: 'Empty response from analysis engine.',
        );
      }
      return HybridAnalysisResult.fromMap(res);
    } on PlatformException catch (e) {
      return HybridAnalysisResult(
        schemaVersion: 1,
        requestId: requestId,
        status: HybridStatus.failed,
        inferenceSource: 'UNKNOWN',
        errorCode: e.code,
        message: e.message,
      );
    } on MissingPluginException {
      return HybridAnalysisResult(
        schemaVersion: 1,
        requestId: requestId,
        status: HybridStatus.unavailable,
        inferenceSource: 'UNKNOWN',
        errorCode: 'MISSING_PLUGIN',
        message: 'On-device AI bridge unavailable in this environment.',
      );
    }
  }

  /// Queries launchable apps installed on this Android device via local
  /// PackageManager `<queries>` MAIN/LAUNCHER resolution.
  /// Privacy guardrail: This list is strictly local and never sent to cloud/AI.
  Future<List<InstalledAppEntry>> listLaunchableApps() async {
    try {
      final res = await _channel.invokeMethod<List>('listLaunchableApps');
      if (res == null) return const [];
      return res
          .whereType<Map>()
          .map(InstalledAppEntry.fromMap)
          .toList(growable: false);
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  /// Queries requested and granted permissions for a selected installed package.
  Future<Map<String, dynamic>> inspectSelectedApp(String packageName) async {
    try {
      final res = await _channel.invokeMethod<Map>('inspectSelectedApp', {
        'packageName': packageName,
      });
      return res?.cast<String, dynamic>() ?? {};
    } on PlatformException catch (e) {
      return {'error': e.message};
    } on MissingPluginException {
      return {'error': 'Native package inspector unavailable.'};
    }
  }

  /// Typed wrapper around [inspectSelectedApp] returning [AppPermissionSnapshot].
  Future<AppPermissionSnapshot?> inspectAppSnapshot(String packageName) async {
    final map = await inspectSelectedApp(packageName);
    if (map.isEmpty || map.containsKey('error')) return null;
    return AppPermissionSnapshot.fromMap(map);
  }
}

class InstalledAppEntry {
  final String packageName;
  final String appName;
  final bool isSystemApp;

  const InstalledAppEntry({
    required this.packageName,
    required this.appName,
    this.isSystemApp = false,
  });

  factory InstalledAppEntry.fromMap(Map<dynamic, dynamic> map) {
    return InstalledAppEntry(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      isSystemApp: map['isSystemApp'] as bool? ?? false,
    );
  }
}

class AppPermissionSnapshot {
  final String packageName;
  final String appName;
  final List<String> requestedPermissions;
  final List<String> grantedPermissions;

  const AppPermissionSnapshot({
    required this.packageName,
    required this.appName,
    required this.requestedPermissions,
    required this.grantedPermissions,
  });

  factory AppPermissionSnapshot.fromMap(Map<dynamic, dynamic> map) {
    return AppPermissionSnapshot(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      requestedPermissions: (map['requestedPermissions'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
      grantedPermissions: (map['grantedPermissions'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
    );
  }

  bool isGranted(String permission) => grantedPermissions.contains(permission);
  bool isRequested(String permission) =>
      requestedPermissions.contains(permission);

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'requestedPermissions': requestedPermissions,
        'grantedPermissions': grantedPermissions,
      };
}
