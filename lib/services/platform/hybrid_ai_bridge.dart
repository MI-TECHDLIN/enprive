import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';

/// Raised when an AI generation or platform call is cancelled (user action,
/// parent/child cancellation, or first-response / total-operation timeout).
/// Propagates cleanly without retrying or silently replacing cancellation with a
/// misleading deterministic fallback receipt.
class HybridOperationCancelledException implements Exception {
  final String requestId;
  final String message;
  final bool isTimeout;

  const HybridOperationCancelledException({
    required this.requestId,
    this.message = 'Operation cancelled.',
    this.isTimeout = false,
  });

  @override
  String toString() =>
      'HybridOperationCancelledException($requestId, timeout=$isTimeout): $message';
}

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

class AnalysisStreamEvent {
  final String requestId;
  final String stage;
  final String label;
  final String? detail;
  final String? thoughtSummary;
  final String? thoughtSignature;
  final String? inferenceSource;
  final bool isCompleted;
  final DateTime timestamp;

  AnalysisStreamEvent({
    required this.requestId,
    required this.stage,
    required this.label,
    this.detail,
    this.thoughtSummary,
    this.thoughtSignature,
    this.inferenceSource,
    this.isCompleted = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AnalysisStreamEvent.fromMap(Map<dynamic, dynamic> map) {
    final rawThought = (map['thoughtSummary'] as String?)?.trim();
    final rawSignature = (map['thoughtSignature'] as String?)?.trim();
    final rawDetail = (map['detail'] as String?)?.trim();
    return AnalysisStreamEvent(
      requestId: map['requestId'] as String? ?? '',
      stage: map['stage'] as String? ?? 'processing',
      label: map['label'] as String? ?? 'Processing request',
      detail: rawDetail?.isNotEmpty == true ? rawDetail : null,
      thoughtSummary: rawThought?.isNotEmpty == true ? rawThought : null,
      thoughtSignature: rawSignature?.isNotEmpty == true ? rawSignature : null,
      inferenceSource: map['inferenceSource'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

class HybridAnalysisResult {
  final int schemaVersion;
  final String requestId;
  final HybridStatus status;
  final String inferenceSource; // "ON_DEVICE" | "IN_CLOUD" | "UNKNOWN"
  final Map<String, dynamic>? structuredOutput;
  final String? thoughtSummary;
  final String? thoughtSignature;
  final List<String> thoughtSignatures;
  final String? errorCode;
  final String? message;

  const HybridAnalysisResult({
    required this.schemaVersion,
    required this.requestId,
    required this.status,
    required this.inferenceSource,
    this.structuredOutput,
    this.thoughtSummary,
    this.thoughtSignature,
    this.thoughtSignatures = const [],
    this.errorCode,
    this.message,
  });

  factory HybridAnalysisResult.fromMap(Map<dynamic, dynamic> map) {
    final rawThought = (map['thoughtSummary'] as String?)?.trim();
    final rawSignature = (map['thoughtSignature'] as String?)?.trim();
    return HybridAnalysisResult(
      schemaVersion: map['schemaVersion'] as int? ?? 1,
      requestId: map['requestId'] as String? ?? '',
      status: _parseStatus(map['status'] as String?),
      inferenceSource: map['inferenceSource'] as String? ?? 'UNKNOWN',
      structuredOutput: (map['structuredOutput'] as Map?)?.cast<String, dynamic>(),
      thoughtSummary: rawThought?.isNotEmpty == true ? rawThought : null,
      thoughtSignature: rawSignature?.isNotEmpty == true ? rawSignature : null,
      thoughtSignatures: (map['thoughtSignatures'] as List?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList(growable: false) ??
          const [],
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
  static const int _maxCachedAppIcons = 200;
  static final Set<StreamController<AnalysisStreamEvent>> _nativeListeners = {};
  static final Set<StreamController<IncomingIntentPayload>>
  _incomingIntentListeners = {};
  static bool _handlerBound = false;

  final LinkedHashMap<String, Uint8List?> _appIconCache =
      LinkedHashMap<String, Uint8List?>();
  final Map<String, Future<Uint8List?>> _pendingAppIconFetches = {};

  final StreamController<AnalysisStreamEvent> _analysisEventsController =
      StreamController<AnalysisStreamEvent>.broadcast();
  final StreamController<IncomingIntentPayload> _incomingPayloadController =
      StreamController<IncomingIntentPayload>.broadcast();

  Stream<AnalysisStreamEvent> get analysisEvents {
    _nativeListeners.add(_analysisEventsController);
    _ensureHandlerBound();
    return _analysisEventsController.stream;
  }

  Stream<IncomingIntentPayload> get incomingPayloads {
    _incomingIntentListeners.add(_incomingPayloadController);
    _ensureHandlerBound();
    return _incomingPayloadController.stream;
  }

  void emitProcessEvent(AnalysisStreamEvent event) {
    if (!_analysisEventsController.isClosed) {
      _analysisEventsController.add(event);
    }
  }

  static void _ensureHandlerBound() {
    if (_handlerBound) return;
    try {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onAnalysisStreamEvent') {
          final args = call.arguments;
          if (args is Map) {
            final event = AnalysisStreamEvent.fromMap(args);
            for (final controller in List.of(_nativeListeners)) {
              if (!controller.isClosed) {
                controller.add(event);
              }
            }
          }
        } else if (call.method == 'onIncomingPayload') {
          final args = call.arguments;
          if (args is Map) {
            final payload = IncomingIntentPayload.fromMap(args);
            for (final controller in List.of(_incomingIntentListeners)) {
              if (!controller.isClosed) {
                controller.add(payload);
              }
            }
          }
        }
      });
      _handlerBound = true;
    } catch (_) {
      // Pure Dart unit tests without ServicesBinding initialized skip MethodChannel registration.
    }
  }

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

  /// Retrieves any structured Android launch payload (`ACTION_PROCESS_TEXT`,
  /// `ACTION_SEND` text/URL, or `ACTION_SEND` document URI), falling back to
  /// [getInitialSelectedText] when only legacy text handlers are registered.
  Future<IncomingIntentPayload?> getInitialIncomingPayload() async {
    _ensureHandlerBound();
    try {
      final res = await _channel.invokeMethod<dynamic>(
        'getInitialIncomingPayload',
      );
      if (res is Map) {
        return IncomingIntentPayload.fromMap(res);
      }
    } on PlatformException {
      return null;
    } on MissingPluginException {
      // Fall through to legacy handler for older platform mocks
    }

    final selected = await getInitialSelectedText();
    if (selected == null || selected.isEmpty) return null;
    return IncomingIntentPayload(
      kind: 'text_or_url',
      sourceAction: 'ACTION_PROCESS_TEXT',
      text: selected,
    );
  }

  /// Launches Android's Storage Access Framework document picker filtered to
  /// supported privacy-policy formats (PDF, TXT, DOCX) and extracts text locally.
  Future<DocumentExtractionOutcome> pickAndExtractDocument() async {
    try {
      final res = await _channel.invokeMethod<dynamic>(
        'pickAndExtractDocument',
      );
      if (res is Map) {
        return DocumentExtractionOutcome.fromMap(res);
      }
      return const DocumentExtractionOutcome(
        status: 'cancelled',
        extractedText: '',
        userMessage: 'No document was selected.',
      );
    } on PlatformException catch (e) {
      return DocumentExtractionOutcome(
        status: 'read_error',
        extractedText: '',
        userMessage:
            e.message ?? 'Could not open the selected document on this phone.',
      );
    } on MissingPluginException {
      return const DocumentExtractionOutcome(
        status: 'read_error',
        extractedText: '',
        userMessage: 'Document picker is only available on Android devices.',
      );
    }
  }

  /// Speaks [text] aloud using the local Android TextToSpeech engine.
  Future<bool> speakText(
    String text, {
    String languageCode = 'en',
  }) async {
    try {
      final res = await _channel.invokeMethod<bool>('speakText', {
        'text': text,
        'languageCode': languageCode,
      });
      return res ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Stops any active Android TextToSpeech playback.
  Future<bool> stopSpeaking() async {
    try {
      final res = await _channel.invokeMethod<bool>('stopSpeaking');
      return res ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Sends text for hybrid evaluation.
  /// If [cloudConsent] is false, non-local modes are rejected immediately and
  /// native code strictly enforces ONLY_ON_DEVICE.
  Future<HybridAnalysisResult> analyseText({
    required String requestId,
    required String task,
    required String text,
    required bool cloudConsent,
    String? requestedMode,
    String? sourceSnapshotId,
    String languageCode = 'en',
  }) async {
    if (!cloudConsent &&
        requestedMode != null &&
        requestedMode != 'ONLY_ON_DEVICE') {
      return HybridAnalysisResult(
        schemaVersion: 1,
        requestId: requestId,
        status: HybridStatus.unavailable,
        inferenceSource: 'UNKNOWN',
        errorCode: 'CLOUD_CONSENT_REQUIRED',
        message: 'Cloud consent not granted. Analysis restricted to on-device.',
      );
    }

    try {
      final effectiveMode =
          requestedMode ?? (cloudConsent ? 'ONLY_IN_CLOUD' : 'ONLY_ON_DEVICE');
      final res = await _channel.invokeMethod<Map>('analyseText', {
        'schemaVersion': 1,
        'requestId': requestId,
        'task': task,
        'text': text,
        'requestedMode': cloudConsent ? effectiveMode : 'ONLY_ON_DEVICE',
        'cloudConsent': cloudConsent,
        'sourceSnapshotId': sourceSnapshotId,
        'languageCode': languageCode,
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
      final rawStatus = (res['status'] as String?)?.trim().toLowerCase();
      final rawErrorCode = res['errorCode'] as String?;
      if (rawStatus == 'cancelled' ||
          rawStatus == 'canceled' ||
          _isCancellationCode(rawErrorCode)) {
        throw HybridOperationCancelledException(
          requestId: requestId,
          message: (res['message'] as String?) ?? 'Analysis cancelled.',
          isTimeout: _isTimeoutCancellationCode(rawErrorCode),
        );
      }
      return HybridAnalysisResult.fromMap(res);
    } on PlatformException catch (e) {
      if (_isCancellationCode(e.code)) {
        final reason = e.details is Map ? (e.details as Map)['reason'] : null;
        throw HybridOperationCancelledException(
          requestId: requestId,
          message: e.message ?? 'Analysis cancelled.',
          isTimeout: _isTimeoutCancellationCode(e.code) || reason == 'timeout',
        );
      }
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

  /// Requests native cancellation of an in-flight analysis coroutine job.
  Future<bool> cancelAnalysis({String? requestId}) async {
    try {
      final res = await _channel.invokeMethod<bool>('cancelAnalysis', {
        if (requestId != null && requestId.trim().isNotEmpty)
          'requestId': requestId.trim(),
      });
      return res ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static bool _isCancellationCode(String? code) {
    if (code == null) return false;
    return switch (code.trim().toUpperCase()) {
      'CANCELLED' ||
      'CANCELED' ||
      'TIMED_OUT' ||
      'TIMEOUT_CANCELLED' ||
      'CANCELLATIONEXCEPTION' ||
      'TIMEOUTCANCELLATIONEXCEPTION' ||
      'JOBCANCELLATIONEXCEPTION' => true,
      _ => false,
    };
  }

  static bool _isTimeoutCancellationCode(String? code) {
    if (code == null) return false;
    return switch (code.trim().toUpperCase()) {
      'TIMED_OUT' ||
      'TIMEOUT_CANCELLED' ||
      'TIMEOUTCANCELLATIONEXCEPTION' => true,
      _ => false,
    };
  }

  /// Queries launchable apps installed on this Android device via local
  /// PackageManager `<queries>` MAIN/LAUNCHER resolution.
  /// Privacy guardrail: This list is strictly local and never sent to cloud/AI.
  Future<List<InstalledAppEntry>> listLaunchableApps() async {
    try {
      final res = await _channel.invokeMethod<List>('listLaunchableApps');
      if (res == null) return const [];
      final entries = res
          .whereType<Map>()
          .map(InstalledAppEntry.fromMap)
          .toList(growable: false);
      for (final entry in entries) {
        if (entry.iconBytes != null && entry.iconBytes!.isNotEmpty) {
          _rememberAppIcon(entry.packageName, entry.iconBytes);
        }
      }
      return entries;
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  /// Returns a cached local PNG icon for [packageName] if already loaded on
  /// this bridge instance, or `null` otherwise.
  Uint8List? cachedAppIcon(String packageName) => _appIconCache[packageName];

  /// Whether an icon lookup for [packageName] has already resolved in this
  /// bridge instance's cache.
  bool hasCachedAppIcon(String packageName) =>
      _appIconCache.containsKey(packageName);

  /// Loads the launcher icon PNG bytes for [packageName] strictly on-device.
  /// Results are cached in volatile memory on this bridge instance and
  /// deduplicated across concurrent callers so Binder IPC stays lightweight.
  Future<Uint8List?> getAppIcon(String packageName, {int sizePx = 112}) {
    if (packageName.trim().isEmpty) return Future<Uint8List?>.value(null);
    if (_appIconCache.containsKey(packageName)) {
      return Future<Uint8List?>.value(_appIconCache[packageName]);
    }
    final existing = _pendingAppIconFetches[packageName];
    if (existing != null) return existing;

    final fetchFuture = _fetchAppIconFromPlatform(packageName, sizePx: sizePx);
    _pendingAppIconFetches[packageName] = fetchFuture;
    return fetchFuture;
  }

  Future<Uint8List?> _fetchAppIconFromPlatform(
    String packageName, {
    required int sizePx,
  }) async {
    try {
      final bytes = await _channel.invokeMethod<Uint8List>('getAppIcon', {
        'packageName': packageName,
        'sizePx': sizePx,
      });
      final normalized = (bytes != null && bytes.isNotEmpty) ? bytes : null;
      _rememberAppIcon(packageName, normalized);
      return normalized;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    } finally {
      _pendingAppIconFetches.remove(packageName);
    }
  }

  void _rememberAppIcon(String packageName, Uint8List? bytes) {
    if (_appIconCache.length >= _maxCachedAppIcons) {
      _appIconCache.remove(_appIconCache.keys.first);
    }
    _appIconCache[packageName] = bytes;
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
  final Uint8List? iconBytes;

  const InstalledAppEntry({
    required this.packageName,
    required this.appName,
    this.isSystemApp = false,
    this.iconBytes,
  });

  factory InstalledAppEntry.fromMap(Map<dynamic, dynamic> map) {
    final rawIcon = map['iconBytes'];
    return InstalledAppEntry(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      isSystemApp: map['isSystemApp'] as bool? ?? false,
      iconBytes: rawIcon is Uint8List ? rawIcon : null,
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

class DocumentExtractionOutcome {
  final String status;
  final String? documentType;
  final String? fileName;
  final String? mimeType;
  final int byteLength;
  final int? pageCount;
  final String extractedText;
  final String userMessage;

  const DocumentExtractionOutcome({
    required this.status,
    this.documentType,
    this.fileName,
    this.mimeType,
    this.byteLength = 0,
    this.pageCount,
    required this.extractedText,
    required this.userMessage,
  });

  bool get isSuccess => status == 'ok' && extractedText.trim().isNotEmpty;
  bool get isCancelled => status == 'cancelled';

  factory DocumentExtractionOutcome.fromMap(Map<dynamic, dynamic> map) {
    return DocumentExtractionOutcome(
      status: map['status'] as String? ?? 'read_error',
      documentType: map['documentType'] as String?,
      fileName: map['fileName'] as String?,
      mimeType: map['mimeType'] as String?,
      byteLength: (map['byteLength'] as num?)?.toInt() ?? 0,
      pageCount: (map['pageCount'] as num?)?.toInt(),
      extractedText: map['extractedText'] as String? ?? '',
      userMessage: map['userMessage'] as String? ?? '',
    );
  }
}

class IncomingIntentPayload {
  final String kind; // text | text_or_url | document
  final String sourceAction;
  final String? text;
  final String? subject;
  final DocumentExtractionOutcome? document;

  const IncomingIntentPayload({
    required this.kind,
    required this.sourceAction,
    this.text,
    this.subject,
    this.document,
  });

  factory IncomingIntentPayload.fromMap(Map<dynamic, dynamic> map) {
    final kind = map['kind'] as String? ?? 'text';
    return IncomingIntentPayload(
      kind: kind,
      sourceAction: map['sourceAction'] as String? ?? 'ACTION_SEND',
      text: map['text'] as String?,
      subject: map['subject'] as String?,
      document: kind == 'document'
          ? DocumentExtractionOutcome.fromMap(map)
          : null,
    );
  }
}
