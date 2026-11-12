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
    }
  }

  /// Initiates or verifies on-device model download (returns stream/status).
  Future<ModelDownloadStatus> downloadOrCheckModel() async {
    try {
      final res = await _channel.invokeMethod<String>('downloadOrCheckModel');
      return DeviceCapability._parseDownloadStatus(res);
    } on PlatformException {
      return ModelDownloadStatus.failed;
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
    }
  }
}
