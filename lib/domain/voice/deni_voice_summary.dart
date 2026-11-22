import '../../l10n/app_localizations.dart';
import '../../l10n/enprive_languages.dart';
import '../../widgets/enprive_provenance_chip.dart';
import '../permissions/permission_comparator.dart';
import '../review/app_policy_association.dart';
import '../review/review_models.dart';

/// Semantic category for each spoken & displayed plain-language summary item.
/// Keeps policy quotes strictly distinct from local Android permission
/// observations and association caveats.
enum DeniSummaryPointKind {
  /// Plain-language explanation backed by a verbatim `sourceMatched` policy quote.
  policyFinding,

  /// Strictly local Android permission observation (never presented as a policy disclosure).
  devicePermissionNote,

  /// Illustrative permission observation from a built-in synthetic sample.
  samplePermissionNote,

  /// Non-ownership association caveat when a policy is linked to an app.
  associationNote,
}

/// One evidence-grounded plain-language point in Deni's voice & text summary.
class DeniSummaryPoint {
  final String id;
  final DeniSummaryPointKind kind;
  final String plainText;
  final String? findingId;
  final String? sourceExcerpt;
  final String? sourceLabel;
  final EvidenceStatus? evidenceStatus;

  const DeniSummaryPoint({
    required this.id,
    required this.kind,
    required this.plainText,
    this.findingId,
    this.sourceExcerpt,
    this.sourceLabel,
    this.evidenceStatus,
  });

  bool get hasPolicyExcerpt =>
      kind == DeniSummaryPointKind.policyFinding &&
      sourceExcerpt != null &&
      sourceExcerpt!.trim().isNotEmpty;
}

/// Ephemeral (non-persisted) plain-language summary prepared for Deni to show
/// alongside audio playback. Never alters receipt schema or persisted formats.
class DeniVoiceSummary {
  final String headline;
  final List<DeniSummaryPoint> points;
  final String unknownSummary;
  final String calibrationNotice;
  final InferenceSource summarySource;
  final String languageCode;
  final bool requiresCloudConsent;
  final String? consentReason;
  final String? redactedCloudPayload;
  final String? fallbackNote;

  const DeniVoiceSummary({
    required this.headline,
    required this.points,
    required this.unknownSummary,
    required this.calibrationNotice,
    required this.summarySource,
    this.languageCode = 'en',
    this.requiresCloudConsent = false,
    this.consentReason,
    this.redactedCloudPayload,
    this.fallbackNote,
  });

  /// Policy-quote-backed points (each keeping its verbatim source excerpt).
  List<DeniSummaryPoint> get policyPoints => points
      .where((p) => p.kind == DeniSummaryPointKind.policyFinding)
      .toList(growable: false);

  /// Clean spoken transcript matching the visible text 1:1 (never audio-only).
  String get spokenScript {
    final segments = <String>[];
    final cleanHeadline = headline.trim();
    if (cleanHeadline.isNotEmpty) {
      segments.add(_ensureSentencePunctuation(cleanHeadline));
    }
    for (final point in points) {
      final cleanPoint = point.plainText.trim();
      if (cleanPoint.isNotEmpty) {
        segments.add(_ensureSentencePunctuation(cleanPoint));
      }
    }
    final cleanUnknown = unknownSummary.trim();
    if (cleanUnknown.isNotEmpty) {
      segments.add(_ensureSentencePunctuation(cleanUnknown));
    }
    final cleanCalibration = calibrationNotice.trim();
    if (cleanCalibration.isNotEmpty) {
      segments.add(_ensureSentencePunctuation(cleanCalibration));
    }
    return segments.join(' ');
  }

  static String _ensureSentencePunctuation(String text) {
    if (text.endsWith('.') ||
        text.endsWith('!') ||
        text.endsWith('?') ||
        text.endsWith('。') ||
        text.endsWith('؟')) {
      return text;
    }
    return '$text.';
  }
}

/// Pure, deterministic builder and safety validator for [DeniVoiceSummary].
///
/// Enforces Enprive's non-negotiable product rules:
/// 1. Only `sourceMatched` policy findings from the current review enter AI prompts.
/// 2. Android package names and permission inventories never enter AI prompts.
/// 3. Permission observations are strictly local and never presented as disclosures.
/// 4. Association notes explicitly state linking does not prove ownership.
/// 5. Prohibited safety/compliance certifications are rejected deterministically.
/// 6. Every policy point preserves its exact verbatim `sourceExcerpt` and `findingId`.
class DeniVoiceSummaryBuilder {
  static const int maxSummarizedPolicyFindings = 6;
  static const String defaultNonCertificationNotice =
      'This summary is based only on the reviewed evidence and is not a safety certification.';

  /// Detects affirmative safety/compliance certification claims that Deni must
  /// never speak or display, while permitting honest negative statements such
  /// as "this is not a safety certification" or "cannot say this app is safe".
  static final RegExp _prohibitedCertificationPattern = RegExp(
    r'\b(?:'
    r'(?:this\s+app|the\s+app|it)\s+is\s+(?:100%\s+|completely\s+|totally\s+|fully\s+|definitely\s+|certified\s+)?safe'
    r'|certified\s+safe'
    r'|safe\s+for\s+(?:kids|children)'
    r'|guaranteed\s+(?:safe|private|privacy)'
    r'|(?:fully|100%|legally|coppa|gdpr|ferpa|ccpa)\s+compliant'
    r'|(?:this\s+app|the\s+app|it)\s+is\s+compliant'
    r'|no\s+privacy\s+risks?'
    r'|proved\s+safe'
    r'|100%\s+private'
    r')\b',
    caseSensitive: false,
  );

  static final RegExp _negatedLeadInPattern = RegExp(
    r"(?:^|[.!?;]\s*)(?:[^.!?;]{0,60})\b(?:not|never|cannot|can't|does\s+not|doesn't|do\s+not|don't|will\s+not|won't|no)\b(?:\s+(?:a|an|say|claim|prove|certify|confirm|guarantee|imply|mean|suggest|that|be|is|are)){0,4}\s*$",
    caseSensitive: false,
  );

  /// Returns `true` if [text] contains an affirmative safety or legal compliance
  /// certification claim prohibited by Enprive's calibrated trust contract.
  static bool containsProhibitedCertificationClaim(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return false;
    for (final match in _prohibitedCertificationPattern.allMatches(normalized)) {
      final prefix = normalized.substring(0, match.start);
      if (!_negatedLeadInPattern.hasMatch(prefix)) {
        return true;
      }
    }
    return false;
  }

  /// Selects the current review's verified `sourceMatched` policy findings,
  /// ordered by severity (`high` -> `medium` -> `low`) and capped for concise audio.
  static List<VerifiedFinding> selectSourceMatchedFindings(
    PolicyReviewReceipt receipt,
  ) {
    final matched = receipt.findings
        .where((f) => f.isSourceMatched && f.exactExcerpt.trim().isNotEmpty)
        .toList(growable: false);
    if (matched.isEmpty) return const [];

    int rank(FindingSeverity severity) => switch (severity) {
      FindingSeverity.high => 0,
      FindingSeverity.medium => 1,
      FindingSeverity.low => 2,
    };

    final sorted = List<VerifiedFinding>.from(matched)
      ..sort((a, b) => rank(a.severity).compareTo(rank(b.severity)));
    return sorted
        .take(maxSummarizedPolicyFindings)
        .toList(growable: false);
  }

  /// Builds the policy-only summarization prompt input from the current review's
  /// `sourceMatched` findings.
  ///
  /// Privacy Guardrail: Never includes installed app lists, `packageName`,
  /// `AppPermissionSnapshot`, or `EvidenceStatus.deviceObserved` observations.
  static String buildPromptPayload(PolicyReviewReceipt receipt) {
    final matched = selectSourceMatchedFindings(receipt);
    if (matched.isEmpty) return '';

    final pkg = receipt.permissionReport?.snapshot.packageName.trim();
    String stripPackage(String input) {
      if (pkg == null || pkg.isEmpty) return input;
      return input.replaceAll(pkg, '[APP_ID]');
    }

    final buffer = StringBuffer();
    buffer.writeln('Review subject: ${stripPackage(receipt.subjectTitle.trim())}');
    buffer.writeln('Verified policy findings (${matched.length}):');
    for (final finding in matched) {
      final unknown = finding.unknowns.isNotEmpty
          ? finding.unknowns.first.trim()
          : 'The policy text does not state how often this happens in practice.';
      buffer.writeln('---');
      buffer.writeln('finding_id: ${finding.id}');
      buffer.writeln('category: ${finding.category.name}');
      buffer.writeln('severity: ${finding.severity.name}');
      buffer.writeln('title: ${stripPackage(finding.title.trim())}');
      buffer.writeln('explanation: ${stripPackage(finding.explanation.trim())}');
      buffer.writeln('verbatim_quote: "${stripPackage(finding.exactExcerpt.trim())}"');
      buffer.writeln('unknown: ${stripPackage(unknown)}');
    }
    return buffer.toString().trim();
  }

  /// Builds a deterministic, evidence-grounded plain-language summary without
  /// calling any generative model. Used offline, when on-device AI is unavailable,
  /// when cloud consent is declined, or when cloud inference fails/times out.
  static DeniVoiceSummary buildDeterministic({
    required PolicyReviewReceipt receipt,
    AppPolicyAssociationReport? associationReport,
    String languageCode = 'en',
    String? fallbackNote,
    bool requiresCloudConsent = false,
    String? consentReason,
    String? redactedCloudPayload,
  }) {
    final isSample = _isSampleReceipt(receipt);
    final calibrationNotice = _calibrationNoticeFor(languageCode);

    // 1. Permission-only inspection (no privacy policy reviewed yet)
    if (receipt.isPermissionOnlyInspection) {
      final report = receipt.permissionReport;
      final requested = report?.snapshot.requestedPermissions.length ?? 0;
      final granted = report?.snapshot.grantedPermissions.length ?? 0;
      final points = <DeniSummaryPoint>[
        DeniSummaryPoint(
          id: 'perm_only_overview',
          kind: DeniSummaryPointKind.devicePermissionNote,
          plainText:
              'On this phone, Android lists $requested declared '
              '${requested == 1 ? 'permission' : 'permissions'}, with $granted '
              'currently granted. These are phone permission settings, not '
              'privacy policy disclosures.',
          sourceLabel: 'Observed on this phone',
          evidenceStatus: EvidenceStatus.deviceObserved,
        ),
        if (report != null && report.items.isNotEmpty)
          DeniSummaryPoint(
            id: 'perm_only_items',
            kind: DeniSummaryPointKind.devicePermissionNote,
            plainText:
                'Notable phone permissions checked locally: '
                '${report.items.take(4).map((i) => '${i.friendlyName} (${i.isGranted ? 'granted' : 'not granted'})').join(', ')}. '
                'Android reports permission state only — it does not prove whether data was accessed or sent.',
            sourceLabel: 'Observed on this phone',
            evidenceStatus: EvidenceStatus.deviceObserved,
          ),
      ];
      return DeniVoiceSummary(
        headline:
            'Only phone permissions for ${receipt.subjectTitle} were checked so far — no privacy policy has been reviewed yet.',
        points: List<DeniSummaryPoint>.unmodifiable(points),
        unknownSummary:
            'Because no privacy policy text was provided yet, Enprive cannot say what the developer claims to collect, keep, or share.',
        calibrationNotice: calibrationNotice,
        summarySource: InferenceSource.offlineDeterministic,
        languageCode: languageCode,
        fallbackNote: fallbackNote,
      );
    }

    final matchedFindings = selectSourceMatchedFindings(receipt);
    final points = <DeniSummaryPoint>[];

    // 2. Policy-backed points (each linked directly to its verbatim quote)
    for (final finding in matchedFindings) {
      points.add(
        DeniSummaryPoint(
          id: 'pt_${finding.id}',
          kind: DeniSummaryPointKind.policyFinding,
          plainText: _plainSentenceForFinding(finding),
          findingId: finding.id,
          sourceExcerpt: finding.exactExcerpt.trim(),
          sourceLabel: finding.title.trim(),
          evidenceStatus: finding.status,
        ),
      );
    }

    // 3. Strictly local Android permission observations (never presented as disclosures)
    points.addAll(_buildLocalPermissionPoints(receipt, isSample: isSample));

    // 4. Non-ownership association caveat when an app is paired with a policy
    final associationPoint = _buildAssociationNotePoint(
      receipt: receipt,
      associationReport: associationReport,
      isSample: isSample,
    );
    if (associationPoint != null) {
      points.add(associationPoint);
    }

    final headline = _buildDeterministicHeadline(
      receipt: receipt,
      matchedCount: matchedFindings.length,
      isSample: isSample,
    );
    final unknownSummary = _buildDeterministicUnknownSummary(
      receipt: receipt,
      matchedFindings: matchedFindings,
    );

    return DeniVoiceSummary(
      headline: headline,
      points: List<DeniSummaryPoint>.unmodifiable(points),
      unknownSummary: unknownSummary,
      calibrationNotice: calibrationNotice,
      summarySource: InferenceSource.offlineDeterministic,
      languageCode: languageCode,
      requiresCloudConsent: requiresCloudConsent,
      consentReason: consentReason,
      redactedCloudPayload: redactedCloudPayload,
      fallbackNote: fallbackNote,
    );
  }

  /// Updates strictly local Android permission and app-policy association
  /// points on [current] after linking, changing, or unlinking an installed
  /// app on the same policy review, without triggering any generative AI call.
  static DeniVoiceSummary withUpdatedDeviceContext({
    required DeniVoiceSummary current,
    required PolicyReviewReceipt receipt,
    AppPolicyAssociationReport? associationReport,
  }) {
    if (receipt.isPermissionOnlyInspection ||
        current.summarySource == InferenceSource.offlineDeterministic) {
      return buildDeterministic(
        receipt: receipt,
        associationReport: associationReport,
        languageCode: current.languageCode,
        fallbackNote: current.fallbackNote,
        requiresCloudConsent: current.requiresCloudConsent,
        consentReason: current.consentReason,
        redactedCloudPayload: current.redactedCloudPayload,
      );
    }

    final isSample = _isSampleReceipt(receipt);
    final updatedPoints = <DeniSummaryPoint>[
      ...current.policyPoints,
      ..._buildLocalPermissionPoints(receipt, isSample: isSample),
    ];
    final associationPoint = _buildAssociationNotePoint(
      receipt: receipt,
      associationReport: associationReport,
      isSample: isSample,
    );
    if (associationPoint != null) {
      updatedPoints.add(associationPoint);
    }

    return DeniVoiceSummary(
      headline: current.headline,
      points: List<DeniSummaryPoint>.unmodifiable(updatedPoints),
      unknownSummary: current.unknownSummary,
      calibrationNotice: _calibrationNoticeFor(current.languageCode),
      summarySource: current.summarySource,
      languageCode: current.languageCode,
      requiresCloudConsent: current.requiresCloudConsent,
      consentReason: current.consentReason,
      redactedCloudPayload: current.redactedCloudPayload,
      fallbackNote: current.fallbackNote,
    );
  }

  /// Validates structured JSON returned by on-device or cloud Gemini against the
  /// current review's verified `sourceMatched` findings, attaching local verbatim
  /// excerpts and rejecting any invented finding IDs or certification claims.
  static DeniVoiceSummary validateAndMergeModelOutput({
    required Map<String, dynamic> structuredOutput,
    required PolicyReviewReceipt receipt,
    AppPolicyAssociationReport? associationReport,
    required InferenceSource inferenceSource,
    String languageCode = 'en',
  }) {
    final matchedFindings = selectSourceMatchedFindings(receipt);
    if (matchedFindings.isEmpty) {
      return buildDeterministic(
        receipt: receipt,
        associationReport: associationReport,
        languageCode: languageCode,
      );
    }

    final matchedById = <String, VerifiedFinding>{
      for (final f in matchedFindings) f.id: f,
    };
    final rawPoints = structuredOutput['points'];
    final acceptedPoints = <DeniSummaryPoint>[];
    final coveredIds = <String>{};

    if (rawPoints is List) {
      for (final entry in rawPoints) {
        if (entry is! Map) continue;
        final map = entry.cast<String, dynamic>();
        final findingId =
            (map['finding_id'] as String? ?? map['findingId'] as String? ?? '')
                .trim();
        final plainText =
            (map['plain_text'] as String? ?? map['plainText'] as String? ?? '')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();
        if (findingId.isEmpty ||
            plainText.isEmpty ||
            coveredIds.contains(findingId)) {
          continue;
        }
        final finding = matchedById[findingId];
        if (finding == null) {
          // Reject any invented ID, unverified finding, or deviceObserved item.
          continue;
        }
        if (containsProhibitedCertificationClaim(plainText)) {
          continue;
        }
        coveredIds.add(findingId);
        acceptedPoints.add(
          DeniSummaryPoint(
            id: 'pt_${finding.id}',
            kind: DeniSummaryPointKind.policyFinding,
            plainText: plainText,
            findingId: finding.id,
            sourceExcerpt: finding.exactExcerpt.trim(),
            sourceLabel: finding.title.trim(),
            evidenceStatus: finding.status,
          ),
        );
      }
    }

    // Fail closed to deterministic plain-language template if zero valid model
    // points survived strict evidence grounding.
    if (acceptedPoints.isEmpty) {
      return buildDeterministic(
        receipt: receipt,
        associationReport: associationReport,
        languageCode: languageCode,
        fallbackNote:
            'Showing Enprive’s offline plain-language summary because the model summary could not be matched to verified evidence.',
      );
    }

    // Backfill any verified finding the model skipped so nothing is silently omitted.
    for (final finding in matchedFindings) {
      if (coveredIds.contains(finding.id)) continue;
      acceptedPoints.add(
        DeniSummaryPoint(
          id: 'pt_${finding.id}',
          kind: DeniSummaryPointKind.policyFinding,
          plainText: _plainSentenceForFinding(finding),
          findingId: finding.id,
          sourceExcerpt: finding.exactExcerpt.trim(),
          sourceLabel: finding.title.trim(),
          evidenceStatus: finding.status,
        ),
      );
    }

    final isSample = _isSampleReceipt(receipt);
    acceptedPoints.addAll(_buildLocalPermissionPoints(receipt, isSample: isSample));
    final assocPoint = _buildAssociationNotePoint(
      receipt: receipt,
      associationReport: associationReport,
      isSample: isSample,
    );
    if (assocPoint != null) {
      acceptedPoints.add(assocPoint);
    }

    final rawHeadline = (structuredOutput['headline'] as String?)
        ?.replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final safeHeadline =
        (rawHeadline != null &&
            rawHeadline.isNotEmpty &&
            !containsProhibitedCertificationClaim(rawHeadline))
        ? rawHeadline
        : _buildDeterministicHeadline(
            receipt: receipt,
            matchedCount: matchedFindings.length,
            isSample: isSample,
          );

    final rawUnknown =
        (structuredOutput['unknown_summary'] as String? ??
                structuredOutput['unknownSummary'] as String?)
            ?.replaceAll(RegExp(r'\s+'), ' ')
            .trim();
    final safeUnknown =
        (rawUnknown != null &&
            rawUnknown.isNotEmpty &&
            !containsProhibitedCertificationClaim(rawUnknown))
        ? rawUnknown
        : _buildDeterministicUnknownSummary(
            receipt: receipt,
            matchedFindings: matchedFindings,
          );

    return DeniVoiceSummary(
      headline: safeHeadline,
      points: List<DeniSummaryPoint>.unmodifiable(acceptedPoints),
      unknownSummary: safeUnknown,
      calibrationNotice: _calibrationNoticeFor(languageCode),
      summarySource: inferenceSource,
      languageCode: languageCode,
    );
  }

  static bool _isSampleReceipt(PolicyReviewReceipt receipt) =>
      receipt.sourceSnapshot?.sourceType == PolicySourceType.sample ||
      receipt.sourceSnapshot?.appIdentityMatchStatus ==
          AppIdentityMatchStatus.sampleFixture;

  static String _calibrationNoticeFor(String languageCode) {
    final option = enpriveLanguageByCode(languageCode);
    if (option.code == 'en') {
      return defaultNonCertificationNotice;
    }
    return lookupAppLocalizations(option.locale).stateNoConcernSubtitle;
  }

  static String _buildDeterministicHeadline({
    required PolicyReviewReceipt receipt,
    required int matchedCount,
    required bool isSample,
  }) {
    final subject = receipt.subjectTitle.trim().isNotEmpty
        ? receipt.subjectTitle.trim()
        : 'this policy';
    final samplePrefix = isSample ? 'In this synthetic sample for ' : 'In ';

    if (receipt.overallState == ReviewOverallState.insufficientEvidence) {
      return 'There was not enough verified policy text for $subject to draw a clear privacy conclusion.';
    }
    if (receipt.overallState == ReviewOverallState.noConcern &&
        matchedCount == 0) {
      return '$samplePrefix$subject, no data sharing, tracking, or long-term recording clauses stood out in the text reviewed.';
    }
    if (matchedCount == 1) {
      return '$samplePrefix$subject, 1 policy clause needs a closer parent or teacher look.';
    }
    if (matchedCount > 1) {
      final totalSourceMatched = receipt.sourceMatchedCount;
      final extraNote = totalSourceMatched > matchedCount
          ? ' Here are the top $matchedCount points.'
          : '';
      return '$samplePrefix$subject, $totalSourceMatched policy clauses need a closer look.$extraNote';
    }
    return 'Here is what Enprive could verify in the current review for $subject.';
  }

  static String _plainSentenceForFinding(VerifiedFinding finding) {
    final titleLower = finding.title.toLowerCase();
    final explLower = finding.explanation.toLowerCase();

    if (titleLower.contains('background') && titleLower.contains('location')) {
      return 'Location in the background: the policy says this app can collect location even when the app is not open on screen.';
    }
    if (titleLower.contains('approximate region') ||
        titleLower.contains('imprecise')) {
      return 'Approximate area from network data: the policy says it estimates a rough area (like city or country) from network details rather than exact GPS.';
    }
    if (titleLower.contains('gps') ||
        (finding.category == FindingCategory.tracking &&
            titleLower.contains('location'))) {
      return 'Precise location: the policy says the app collects exact device location details.';
    }
    if (titleLower.contains('retains voice') ||
        (finding.category == FindingCategory.retention &&
            (titleLower.contains('voice') ||
                explLower.contains('train') ||
                explLower.contains('indefinitely')))) {
      return 'Kept voice or media data: the policy says voice, audio, or biometric recordings may be kept long-term or used to train automated models.';
    }
    if (titleLower.contains('voice, camera') ||
        titleLower.contains('microphone')) {
      return 'Camera, microphone, or biometric access: the policy mentions collecting audio, camera, or biometric inputs — check if a child actually needs that feature.';
    }
    if (titleLower.contains('advertising') || explLower.contains('ad_id')) {
      return 'Advertising IDs: the policy mentions using or sharing advertising identifiers to measure campaigns or personalize promotions.';
    }
    if (titleLower.contains('sell') || titleLower.contains('broker')) {
      return 'Possible data sale or brokering: the policy includes wording that personal or usage information may be sold, rented, or passed to data brokers.';
    }
    if (titleLower.contains('service providers')) {
      return 'Outside service helpers: the policy says hosting or operational service providers receive information needed to run the app.';
    }
    if (finding.category == FindingCategory.sharing) {
      return 'Sharing with outside parties: the policy mentions sharing information with third parties or external partners.';
    }
    if (finding.category == FindingCategory.parentalConsent &&
        titleLower.contains('permissions')) {
      return 'Turning permissions off: the policy notes that turning off phone permissions may stop some parts of the app from working.';
    }
    if (titleLower.contains('technical identifiers') ||
        titleLower.contains('device')) {
      return 'Device details: the policy mentions collecting general device or technical IDs.';
    }

    // Fallback: simplify existing finding title + explanation concisely without jargon.
    final cleanExpl = finding.explanation.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanExpl.isNotEmpty && !containsProhibitedCertificationClaim(cleanExpl)) {
      return '${finding.title.trim()}: $cleanExpl';
    }
    return '${finding.title.trim()}: check the quoted policy passage below for exact wording.';
  }

  static List<DeniSummaryPoint> _buildLocalPermissionPoints(
    PolicyReviewReceipt receipt, {
    required bool isSample,
  }) {
    final report = receipt.permissionReport;
    if (report == null) return const [];

    final undisclosed = report.items
        .where(
          (i) => i.alignmentState == PermissionAlignmentState.undisclosedInPolicy,
        )
        .toList(growable: false);
    if (undisclosed.isEmpty) return const [];

    final names = undisclosed.map((i) => i.friendlyName).join(', ');
    if (isSample) {
      return [
        DeniSummaryPoint(
          id: 'sample_perm_mismatch',
          kind: DeniSummaryPointKind.samplePermissionNote,
          plainText:
              'Synthetic sample comparison (not a policy disclosure or live phone scan): '
              'this example includes $names without a matching line in the sample policy.',
          sourceLabel: 'Synthetic example',
          evidenceStatus: EvidenceStatus.interpretation,
        ),
      ];
    }

    return [
      DeniSummaryPoint(
        id: 'device_perm_mismatch',
        kind: DeniSummaryPointKind.devicePermissionNote,
        plainText:
            'Observed on this phone (not a policy disclosure): Android lists $names '
            'as requested by this app, and no matching explanation was found in the '
            'reviewed policy text. Android reports permission state only — it does not '
            'prove the app actually accessed or sent data.',
        sourceLabel: 'Observed on this phone',
        evidenceStatus: EvidenceStatus.deviceObserved,
      ),
    ];
  }

  static DeniSummaryPoint? _buildAssociationNotePoint({
    required PolicyReviewReceipt receipt,
    required AppPolicyAssociationReport? associationReport,
    required bool isSample,
  }) {
    if (isSample) return null;
    if (associationReport != null &&
        (associationReport.state == AppPolicyAssociationState.unmatched ||
            associationReport.state ==
                AppPolicyAssociationState.ambiguousIdentity)) {
      return DeniSummaryPoint(
        id: 'association_warning',
        kind: DeniSummaryPointKind.associationNote,
        plainText:
            'App-to-policy link note: the reviewed text did not clearly confirm this '
            'specific app, and linking a policy here does not prove the developer owns that page.',
        sourceLabel: 'Association note',
      );
    }
    if (receipt.permissionReport != null && !receipt.isPermissionOnlyInspection) {
      return const DeniSummaryPoint(
        id: 'association_non_ownership',
        kind: DeniSummaryPointKind.associationNote,
        plainText:
            'Linking a privacy policy to this app is for comparison only and does not prove the developer owns that page.',
        sourceLabel: 'Association note',
      );
    }
    return null;
  }

  static String _buildDeterministicUnknownSummary({
    required PolicyReviewReceipt receipt,
    required List<VerifiedFinding> matchedFindings,
  }) {
    if (receipt.overallState == ReviewOverallState.insufficientEvidence) {
      return 'Important details are missing or could not be verified from the provided text, so what the app actually collects or shares remains unknown.';
    }
    if (receipt.unverifiedCount > 0) {
      return '${receipt.unverifiedCount} cited ${receipt.unverifiedCount == 1 ? 'claim' : 'claims'} could not be matched word-for-word to the source text, and policy wording alone never proves what an app sends at runtime.';
    }
    for (final f in matchedFindings) {
      if (f.unknowns.isNotEmpty && f.unknowns.first.trim().isNotEmpty) {
        return 'What remains unknown: ${f.unknowns.first.trim()}';
      }
    }
    return 'What remains unknown: reading a privacy policy alone cannot prove what data an app actually sends while running.';
  }
}
