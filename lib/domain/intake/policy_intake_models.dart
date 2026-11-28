import '../../services/network/policy_url_retriever.dart';
import '../../services/platform/hybrid_ai_bridge.dart';
import '../../services/intake/policy_intake_helper.dart';
import '../review/app_policy_association.dart';
import '../review/policy_sufficiency.dart';
import '../review/review_models.dart';

/// Selected Android application reference and on-device inspection context.
///
/// Privacy & ownership boundary:
/// - Stays strictly on-device (never serialized into cloud prompts).
/// - Selecting an app never asserts developer ownership of an attached policy.
final class SelectedAppReference {
  final String packageName;
  final String appName;
  final AppPermissionSnapshot? permissionSnapshot;
  final List<AppIdentityCandidate> peerCandidates;
  final bool isLocked;

  const SelectedAppReference._({
    required this.packageName,
    required this.appName,
    required this.permissionSnapshot,
    required this.peerCandidates,
    required this.isLocked,
  });

  factory SelectedAppReference({
    required String packageName,
    required String appName,
    AppPermissionSnapshot? permissionSnapshot,
    List<AppIdentityCandidate> peerCandidates = const <AppIdentityCandidate>[],
    bool isLocked = false,
  }) {
    final cleanPackage = packageName.trim();
    if (cleanPackage.isEmpty) {
      throw ArgumentError.value(
        packageName,
        'packageName',
        'SelectedAppReference requires a non-empty Android package identifier.',
      );
    }
    if (permissionSnapshot != null &&
        permissionSnapshot.packageName.trim().isNotEmpty &&
        permissionSnapshot.packageName.trim().toLowerCase() !=
            cleanPackage.toLowerCase()) {
      throw ArgumentError.value(
        permissionSnapshot.packageName,
        'permissionSnapshot',
        'Permission snapshot package does not match SelectedAppReference packageName.',
      );
    }
    final cleanName = appName.trim().isEmpty ? cleanPackage : appName.trim();
    return SelectedAppReference._(
      packageName: cleanPackage,
      appName: cleanName,
      permissionSnapshot: permissionSnapshot,
      peerCandidates: List<AppIdentityCandidate>.unmodifiable(peerCandidates),
      isLocked: isLocked,
    );
  }

  AppIdentityCandidate toIdentityCandidate() =>
      AppIdentityCandidate(packageName: packageName, appName: appName);

  SelectedAppReference withPermissionSnapshot(AppPermissionSnapshot snapshot) {
    final snapPkg = snapshot.packageName.trim();
    if (snapPkg.isNotEmpty &&
        snapPkg.toLowerCase() != packageName.toLowerCase()) {
      throw ArgumentError.value(
        snapshot.packageName,
        'snapshot',
        'Permission snapshot package does not match SelectedAppReference packageName.',
      );
    }
    return SelectedAppReference._(
      packageName: packageName,
      appName: appName,
      permissionSnapshot: snapshot,
      peerCandidates: peerCandidates,
      isLocked: isLocked,
    );
  }
}

/// Source locator supplied by the user or Android OS prior to acquisition.
///
/// Distinct from [CapturedPolicySnapshot]: locators survive validation, network,
/// or extraction failures intact so interactive recovery preserves user input.
sealed class PolicyLocator {
  const PolicyLocator();

  String? get userSubjectTitle;
  PolicySourceType get sourceType;
}

/// Locator for direct paste, `ACTION_SEND` shared text, or `ACTION_PROCESS_TEXT`.
final class TextPolicyLocator extends PolicyLocator {
  final String rawText;
  @override
  final PolicySourceType sourceType;
  @override
  final String? userSubjectTitle;
  final String? sourceAction;

  const TextPolicyLocator._({
    required this.rawText,
    required this.sourceType,
    this.userSubjectTitle,
    this.sourceAction,
  });

  factory TextPolicyLocator({
    required String rawText,
    PolicySourceType sourceType = PolicySourceType.pastedText,
    String? userSubjectTitle,
    String? sourceAction,
  }) {
    if (sourceType != PolicySourceType.pastedText &&
        sourceType != PolicySourceType.sharedText &&
        sourceType != PolicySourceType.selectedText) {
      throw ArgumentError.value(
        sourceType,
        'sourceType',
        'TextPolicyLocator only supports pastedText, sharedText, or selectedText.',
      );
    }
    return TextPolicyLocator._(
      rawText: rawText,
      sourceType: sourceType,
      userSubjectTitle: userSubjectTitle,
      sourceAction: sourceAction,
    );
  }
}

/// Locator for a user-supplied or OS-shared public `http://` / `https://` URL.
final class UrlPolicyLocator extends PolicyLocator {
  final String rawUrl;
  @override
  final String? userSubjectTitle;
  final String? sourceAction;

  const UrlPolicyLocator({
    required this.rawUrl,
    this.userSubjectTitle,
    this.sourceAction,
  });

  @override
  PolicySourceType get sourceType => PolicySourceType.url;
}

/// Locator metadata for a local PDF, TXT, or DOCX document.
///
/// Binary document bytes remain inside native Android extraction and are never
/// stored in this locator.
final class DocumentPolicyLocator extends PolicyLocator {
  @override
  final String? userSubjectTitle;
  final String? fileName;
  final String? mimeType;
  final int? byteLength;
  final String? documentType;
  final String? sourceAction;

  /// `true` when dispatched from an incoming Android `ACTION_SEND` content URI
  /// that cannot be deterministically reopened after failure.
  final bool isPreExtractedIncomingShare;

  const DocumentPolicyLocator({
    this.userSubjectTitle,
    this.fileName,
    this.mimeType,
    this.byteLength,
    this.documentType,
    this.sourceAction,
    this.isPreExtractedIncomingShare = false,
  });

  @override
  PolicySourceType get sourceType =>
      PolicyIntakeHelper.sourceTypeForDocument(documentType, mime: mimeType);
}

/// Actual retrieved or extracted privacy-policy content plus provenance.
///
/// Structural invariant: this class can only represent sufficient, successfully
/// captured policy evidence backed by [PolicySourceSnapshot] and a non-empty
/// SHA-256 hash. Failed fetches, empty files, placeholders, or permission-only
/// inspections cannot construct a [CapturedPolicySnapshot].
final class CapturedPolicySnapshot {
  final String normalizedPolicyText;
  final String subjectTitle;
  final String sourceLabel;
  final PolicySourceSnapshot sourceSnapshot;
  final PolicySufficiencyResult sufficiency;

  const CapturedPolicySnapshot._({
    required this.normalizedPolicyText,
    required this.subjectTitle,
    required this.sourceLabel,
    required this.sourceSnapshot,
    required this.sufficiency,
  });

  factory CapturedPolicySnapshot({
    required String normalizedPolicyText,
    required String subjectTitle,
    required String sourceLabel,
    required PolicySourceSnapshot sourceSnapshot,
    required PolicySufficiencyResult sufficiency,
  }) {
    if (normalizedPolicyText.trim().isEmpty) {
      throw ArgumentError.value(
        normalizedPolicyText,
        'normalizedPolicyText',
        'CapturedPolicySnapshot requires non-empty policy text.',
      );
    }
    if (subjectTitle.trim().isEmpty) {
      throw ArgumentError.value(
        subjectTitle,
        'subjectTitle',
        'CapturedPolicySnapshot requires a non-empty subject title.',
      );
    }
    if (sourceLabel.trim().isEmpty) {
      throw ArgumentError.value(
        sourceLabel,
        'sourceLabel',
        'CapturedPolicySnapshot requires a non-empty source label.',
      );
    }
    if (!sufficiency.isSufficient) {
      throw ArgumentError.value(
        sufficiency,
        'sufficiency',
        'CapturedPolicySnapshot cannot represent insufficient policy material.',
      );
    }
    if (sourceSnapshot.sourceSha256Hash.trim().isEmpty) {
      throw ArgumentError.value(
        sourceSnapshot.sourceSha256Hash,
        'sourceSnapshot',
        'CapturedPolicySnapshot requires a non-empty SHA-256 source hash.',
      );
    }
    if (sourceSnapshot.sourceType == PolicySourceType.devicePermissions) {
      throw ArgumentError.value(
        sourceSnapshot.sourceType,
        'sourceSnapshot',
        'Device permission observations cannot form a CapturedPolicySnapshot.',
      );
    }
    if (sourceSnapshot.retrievalStatus != PolicyRetrievalStatus.retrieved &&
        sourceSnapshot.retrievalStatus != PolicyRetrievalStatus.localProvided) {
      throw ArgumentError.value(
        sourceSnapshot.retrievalStatus,
        'sourceSnapshot',
        'CapturedPolicySnapshot cannot hold a failed retrieval status.',
      );
    }
    if (sourceSnapshot.sourceType == PolicySourceType.url &&
        sourceSnapshot.retrievalStatus != PolicyRetrievalStatus.retrieved) {
      throw ArgumentError.value(
        sourceSnapshot.retrievalStatus,
        'sourceSnapshot',
        'URL snapshots in CapturedPolicySnapshot must carry retrieved status.',
      );
    }
    final isDocumentSource =
        sourceSnapshot.sourceType == PolicySourceType.pdf ||
        sourceSnapshot.sourceType == PolicySourceType.docx ||
        sourceSnapshot.sourceType == PolicySourceType.textDocument;
    if (isDocumentSource &&
        sourceSnapshot.extractionStatus != DocumentExtractionStatus.extracted) {
      throw ArgumentError.value(
        sourceSnapshot.extractionStatus,
        'sourceSnapshot',
        'CapturedPolicySnapshot cannot hold a failed document extraction status.',
      );
    }

    return CapturedPolicySnapshot._(
      normalizedPolicyText: normalizedPolicyText,
      subjectTitle: subjectTitle.trim(),
      sourceLabel: sourceLabel.trim(),
      sourceSnapshot: sourceSnapshot,
      sufficiency: sufficiency,
    );
  }

  String get sourceSha256Hash => sourceSnapshot.sourceSha256Hash;
  PolicySourceType get sourceType => sourceSnapshot.sourceType;
}

/// Typed classification for why policy acquisition or validation did not yield
/// usable evidence.
enum PolicyIntakeFailureKind {
  emptyInput,
  insufficientPolicy,
  invalidUrl,
  unsafeDestination,
  networkError,
  timeout,
  sizeExceeded,
  unsupportedContentType,
  httpError,
  emptyOrErrorPage,
  documentUnsupportedMime,
  documentTooLarge,
  documentEmpty,
  documentCorrupt,
  documentPasswordProtected,
  documentPermissionDenied,
  documentReadError,
  cancelled,
}

/// Typed outcome returned by [PolicyIntakeCoordinator].
sealed class PolicyIntakeOutcome {
  const PolicyIntakeOutcome();

  PolicyLocator get locator;
  SelectedAppReference? get selectedApp;

  bool get isSuccess => this is PolicyIntakeSuccess;
  bool get isFailure => this is PolicyIntakeFailure;
  bool get isCancelled;
}

/// Successful, sufficient policy acquisition paired with an in-memory D5.3-B
/// association evaluation while preserving distinct domain objects.
final class PolicyIntakeSuccess extends PolicyIntakeOutcome {
  @override
  final PolicyLocator locator;
  final CapturedPolicySnapshot capturedSnapshot;
  @override
  final SelectedAppReference? selectedApp;
  final AppPolicyAssociationReport associationReport;

  const PolicyIntakeSuccess._({
    required this.locator,
    required this.capturedSnapshot,
    required this.selectedApp,
    required this.associationReport,
  });

  factory PolicyIntakeSuccess({
    required PolicyLocator locator,
    required CapturedPolicySnapshot capturedSnapshot,
    required SelectedAppReference? selectedApp,
    required AppPolicyAssociationReport associationReport,
  }) {
    return PolicyIntakeSuccess._(
      locator: locator,
      capturedSnapshot: capturedSnapshot,
      selectedApp: selectedApp,
      associationReport: associationReport,
    );
  }

  @override
  bool get isCancelled => false;
}

/// Fail-closed intake outcome preserving [locator] and diagnostic details so
/// callers can offer recovery without fabricating policy evidence.
final class PolicyIntakeFailure extends PolicyIntakeOutcome {
  final PolicyIntakeFailureKind kind;
  @override
  final PolicyLocator locator;
  @override
  final SelectedAppReference? selectedApp;
  final String userMessage;
  final String recoveryHint;
  final bool canRetrySameLocator;
  final PolicySourceSnapshot? failedSourceSnapshot;
  final PolicyUrlRetrievalResult? urlRetrievalResult;
  final DocumentExtractionOutcome? documentOutcome;
  final PolicySufficiencyResult? sufficiencyResult;

  const PolicyIntakeFailure({
    required this.kind,
    required this.locator,
    this.selectedApp,
    required this.userMessage,
    required this.recoveryHint,
    this.canRetrySameLocator = true,
    this.failedSourceSnapshot,
    this.urlRetrievalResult,
    this.documentOutcome,
    this.sufficiencyResult,
  });

  @override
  bool get isCancelled => kind == PolicyIntakeFailureKind.cancelled;
}
