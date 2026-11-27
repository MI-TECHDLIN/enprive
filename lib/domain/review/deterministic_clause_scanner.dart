import '../evidence/evidence_validator.dart';
import '../permissions/permission_comparator.dart';
import 'review_models.dart';

/// Conservative, clause-aware deterministic scanner used strictly for offline local
/// scans and unavailable-cloud fallbacks. Never fabricates quotes or converts
/// explicit denials or coarse IP-region mentions into high-severity claims.
class DeterministicClauseScanner {
  static final RegExp _sentenceSplitPattern = RegExp(r'(?<=[.!?])\s+');
  static final RegExp _subClauseSplitPattern = RegExp(
    r'\s*(?:;|\n+|,\s*(?:but|however|although|though|whereas|while)\s+)\s*',
    caseSensitive: false,
  );

  static final RegExp _verbNegationPattern = RegExp(
    r"\b(?:do\s+not|does\s+not|did\s+not|don't|doesn't|didn't|will\s+not|won't|shall\s+not|would\s+not|cannot|can't|never|neither|nor|not)\s+(?:\w+\s+){0,6}?(?:collect|gather|obtain|access|track|record|capture|retain|store|keep|save|sell|lease|rent|trade|share|disclose|transfer|transmit|provide|send|use|utilize|include|contain|integrate|embed|serve|display|run|show|allow|permit|enable|monetize|profile)\b",
    caseSensitive: false,
  );

  static final RegExp _passiveNegationPattern = RegExp(
    r'\b(?:is|are|will\s+be)\s+(?:never|not)\s+(?:sold|rented|leased|shared|collected|tracked|used|stored|retained|disclosed)\b',
    caseSensitive: false,
  );

  static final RegExp _nounNegationPattern = RegExp(
    r'\b(?:no|without(?:\s+any)?|free\s+of|zero)\s+(?:third[- ]party\s+)?(?:advertising|advertisements?|ads\b|ad\s+networks?|ad\s+sdks?|behavioral\s+(?:advertising|promotions?)|targeted\s+(?:advertising|ads?)|sale|selling|location\s+tracking|gps\s+tracking|precise\s+location|background\s+location|voice\s+recording|biometrics?)\b',
    caseSensitive: false,
  );

  static final RegExp _noneSoldSharedPattern = RegExp(
    r"\bnone\s+of\s+(?:[a-z']+\s+){0,6}?(?:data|information|records|details|content)\b[^.]{0,35}?\b(?:is|are|will\s+be)\s+(?:ever\s+)?(?:sold|rented|leased|shared|collected|disclosed|transferred|used)\b",
    caseSensitive: false,
  );

  static final RegExp _userRequestOrControlPattern = RegExp(
    r'\b(?:you\s+can\s+(?:request|contact|email|opt\s+out|delete|review)|how\s+to\s+(?:disable|opt\s+out|delete)|to\s+request\s+deletion)\b',
    caseSensitive: false,
  );

  static final RegExp _affirmativeVerbPattern = RegExp(
    r'\b(?:collect(?:s|ed|ing)?|gather(?:s|ed|ing)?|obtain(?:s|ed|ing)?|access(?:es|ed|ing)?|track(?:s|ed|ing)?|record(?:s|ed|ing)?|capture(?:s|ed|ing)?|retain(?:s|ed|ing)?|store(?:s|d|ing)?|keep(?:s|ing)?|sell(?:s|ing)?|lease(?:s|d|ing)?|rent(?:s|ed|ing)?|share(?:s|d|ing)?|disclose(?:s|d|ing)?|transfer(?:s|red|ring)?|transmit(?:s|ted|ting)?|send(?:s|ing)?|use(?:s|d|ing)?|infer(?:s|red|ring)?|derive(?:s|d|ing)?|enable(?:s|d|ing)?)\b',
    caseSensitive: false,
  );

  static final RegExp _locationWord = RegExp(r'\blocation\b', caseSensitive: false);
  static final RegExp _preciseGpsWord = RegExp(
    r'\b(?:gps|precise\s+(?:geo)?location|exact\s+(?:geo)?location|geolocation\s+coordinates|latitude\s+and\s+longitude)\b',
    caseSensitive: false,
  );
  static final RegExp _backgroundLocationWord = RegExp(
    r'\b(?:in\s+the\s+background|background\s+location|background\s+gps|even\s+when\s+(?:the\s+|you\s+are\s+)?(?:app\s+)?(?:is|isn.?t|are|aren.?t)\s+(?:closed|open|in\s+use|not\s+in\s+use|not\s+(?:being\s+)?used|not\s+using\s+(?:the\s+)?app)|not\s+actively\s+using\s+the\s+app|when\s+closed)\b',
    caseSensitive: false,
  );

  /// App-state qualifiers ("not in use") contain negation words that are not
  /// denials of the data practice; they are blanked before negation checks.
  static final RegExp _appStateQualifier = RegExp(
    r'\b(?:even\s+)?when\s+(?:the\s+)?app\s+(?:is|isn.?t)\s+(?:not\s+(?:being\s+)?(?:in\s+use|used|open)|closed)\b|\bnot\s+actively\s+using\s+the\s+app\b',
    caseSensitive: false,
  );
  static final RegExp _coarseIpLocationWord = RegExp(
    r'\b(?:imprecise\s+location|approximate\s+location|coarse\s+location|general\s+(?:geographic\s+)?(?:location|region|area)|masked\s+ip(?:\s+address)?|infer\s+(?:an?\s+)?(?:imprecise|approximate|coarse|general)\s+location|ip\s+address\b[^.]{0,45}\b(?:city|country|region|geography|approximate|imprecise|location))\b',
    caseSensitive: false,
  );

  static final RegExp _voiceOrMediaWord = RegExp(
    r'\b(?:voice\s+recordings?|audio\s+recordings?|microphone|speech[- ]fluency|biometric\s+(?:data|identifiers?|templates?)|faceprints?|voiceprints?|camera\s+(?:input|photos?|video))\b',
    caseSensitive: false,
  );
  static final RegExp _retentionTrainingWord = RegExp(
    r'\b(?:retain(?:s|ed|ing)?|indefinitely|permanent(?:ly)?|train(?:s|ed|ing)?|speech\s+recognition\s+models?|machine\s+learning)\b',
    caseSensitive: false,
  );

  static final RegExp _adIdOrNetworkWord = RegExp(
    r'\b(?:android\s+advertising\s+ids?|advertising\s+ids?|ad_id|idfa|behavioral\s+promotions?|targeted\s+advertising|personalized\s+ads?|ad(?:vertising)?\s+(?:partners?|networks?|sdks?|attribution|campaigns?)|appsflyer|facebook\s+pixel|admob)\b',
    caseSensitive: false,
  );
  static final RegExp _dataSaleWord = RegExp(
    r'\b(?:sell(?:s|ing)?|rent(?:s|ed|ing)?|lease(?:s|d|ing)?|monetiz(?:e|es|ing)|data\s+brokers?)\b',
    caseSensitive: false,
  );
  static final RegExp _externalSharingVerb = RegExp(
    r'\b(?:share(?:s|d|ing)?|disclose(?:s|d|ing)?|transfer(?:s|red|ring)?|transmit(?:s|ted|ting)?|send(?:s|ing)?)\b',
    caseSensitive: false,
  );
  static final RegExp _externalPartyWord = RegExp(
    r'\b(?:third[- ]part(?:y|ies)|external\s+partners?|affiliates?|advertisers?|marketing\s+partners?|social\s+media\s+partners?)\b',
    caseSensitive: false,
  );
  static final RegExp _serviceProviderScopeWord = RegExp(
    r'\b(?:service\s+providers?|payment\s+process(?:or|ors|ing)|hosting|cloud\s+infrastructure|solely\s+to\s+provide\s+the\s+service)\b',
    caseSensitive: false,
  );
  static final RegExp _deviceIdentifierWord = RegExp(
    r'\b(?:device\s+identifiers?|device\s+ids?|unique\s+player\s*id|persistent\s+identifiers?|operating\s+system\s+telemetry|ip\s+address)\b',
    caseSensitive: false,
  );
  static final RegExp _permissionBreakWord = RegExp(
    r'\b(?:disabl(?:e|ing)|revok(?:e|ing)|turning\s+off)\b[^.]{0,50}\bpermissions?\b',
    caseSensitive: false,
  );

  /// Scans [policyText] into conservative, source-verified [VerifiedFinding] items.
  static List<VerifiedFinding> scan(String policyText) {
    final segments = _extractCandidateUnits(policyText);
    final findings = <VerifiedFinding>[];
    final seenSignatures = <String>{};
    var idx = 1;

    for (final unit in segments) {
      final subClauses = _splitSubClauses(unit);
      for (final subClause in subClauses) {
        final normalizedSub = subClause.trim();
        if (normalizedSub.length < 18) continue;
        if (_userRequestOrControlPattern.hasMatch(normalizedSub) &&
            !_dataSaleWord.hasMatch(normalizedSub) &&
            !_adIdOrNetworkWord.hasMatch(normalizedSub)) {
          continue;
        }

        final candidate = _classifySubClause(
          subClause: normalizedSub,
          fullUnit: unit,
          snapshotText: policyText,
          nextId: 'local_$idx',
        );
        if (candidate == null) continue;

        final dedupKey = '${candidate.title}::${candidate.exactExcerpt}';
        if (!seenSignatures.add(dedupKey)) continue;

        findings.add(candidate);
        idx++;
      }
    }

    return findings;
  }

  static List<String> _extractCandidateUnits(String policyText) {
    final trimmed = policyText.trim();
    if (trimmed.isEmpty) return const [];

    final splitSentences = trimmed
        .split(_sentenceSplitPattern)
        .map((s) => s.trim())
        .where((s) => s.length >= 25)
        .toList();

    return splitSentences.isNotEmpty ? splitSentences : [trimmed];
  }

  static List<String> _splitSubClauses(String sentence) {
    final parts = sentence
        .split(_subClauseSplitPattern)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts : [sentence.trim()];
  }

  static bool isNegatedClause(String clause) {
    clause = clause.replaceAll(_appStateQualifier, ' ');
    return _verbNegationPattern.hasMatch(clause) ||
        _passiveNegationPattern.hasMatch(clause) ||
        _nounNegationPattern.hasMatch(clause) ||
        _noneSoldSharedPattern.hasMatch(clause);
  }

  /// Resolves the verbatim quote to verify in [snapshotText]—preferring the focused
  /// sub-clause when present cleanly inside [snapshotText] so mixed-polarity
  /// sentences highlight only the affirmative clause rather than adjacent denials.
  static String _pickVerifiableQuote({
    required String subClause,
    required String fullUnit,
    required String snapshotText,
  }) {
    if (EvidenceValidator.verifyQuoteAlignment(
      quote: subClause,
      snapshotText: snapshotText,
    )) {
      return subClause;
    }
    return fullUnit;
  }

  static VerifiedFinding? _classifySubClause({
    required String subClause,
    required String fullUnit,
    required String snapshotText,
    required String nextId,
  }) {
    final isNegated = isNegatedClause(subClause);
    final hasAffirmativeVerb = _affirmativeVerbPattern.hasMatch(subClause);
    final quote = _pickVerifiableQuote(
      subClause: subClause,
      fullUnit: fullUnit,
      snapshotText: snapshotText,
    );

    // 1. Coarse / IP-derived location disclosure must remain distinct from GPS
    // and background tracking so masked IP wording never escalates severity.
    if (_coarseIpLocationWord.hasMatch(subClause) && !isNegated) {
      return _buildVerifiedFinding(
        id: nextId,
        title: 'Infers approximate region from IP or network data',
        category: FindingCategory.dataCollection,
        severity: FindingSeverity.low,
        excerpt: quote,
        explanation:
            'The quoted text describes estimating an approximate or imprecise region (for example from a masked IP address), rather than precise device coordinates.',
        unknown:
            'The excerpt does not confirm whether Android location permissions are requested or how long derived region logs are kept.',
        snapshotText: snapshotText,
      );
    }

    // 2. Background location tracking (requires both location AND background proof).
    if (_locationWord.hasMatch(subClause) &&
        _backgroundLocationWord.hasMatch(subClause) &&
        !isNegated &&
        hasAffirmativeVerb) {
      final hasGps = _preciseGpsWord.hasMatch(subClause);
      return _buildVerifiedFinding(
        id: nextId,
        title: 'Tracks location in the background',
        category: FindingCategory.tracking,
        severity: FindingSeverity.high,
        excerpt: quote,
        explanation: hasGps
            ? 'The policy states the app collects precise GPS location information even when it is running in the background.'
            : 'The policy describes collecting location data even while the app is running in the background or closed.',
        unknown:
            'The text alone does not show whether background location is currently granted on this phone.',
        snapshotText: snapshotText,
      );
    }

    // 3. Foreground / general precise GPS location (not imprecise/IP).
    if (_preciseGpsWord.hasMatch(subClause) &&
        !_coarseIpLocationWord.hasMatch(subClause) &&
        !isNegated &&
        hasAffirmativeVerb) {
      return _buildVerifiedFinding(
        id: nextId,
        title: 'Collects precise GPS location',
        category: FindingCategory.tracking,
        severity: FindingSeverity.medium,
        excerpt: quote,
        explanation:
            'The quoted clause states the app collects precise or GPS location data; inspect whether that feature is active while using the app.',
        unknown:
            'The policy excerpt does not state whether precise location stays optional or how long coordinates are retained.',
        snapshotText: snapshotText,
      );
    }

    // 4. Voice, audio, camera, or biometric retention / AI training.
    if (_voiceOrMediaWord.hasMatch(subClause) &&
        !isNegated &&
        (hasAffirmativeVerb || _retentionTrainingWord.hasMatch(subClause))) {
      final hasRetentionOrTraining = _retentionTrainingWord.hasMatch(subClause);
      return _buildVerifiedFinding(
        id: nextId,
        title: hasRetentionOrTraining
            ? 'Retains voice, audio, or biometric data'
            : 'Accesses voice, camera, or biometric inputs',
        category: hasRetentionOrTraining
            ? FindingCategory.retention
            : FindingCategory.dataCollection,
        severity: hasRetentionOrTraining
            ? FindingSeverity.high
            : FindingSeverity.medium,
        excerpt: quote,
        explanation: hasRetentionOrTraining
            ? 'The quoted passage describes retaining voice, audio, or biometric data long-term or using it to train automated models.'
            : 'The policy notes collection or use of microphone, camera, or biometric inputs; verify whether a child actually needs that feature.',
        unknown:
            'The excerpt may not specify how parents can delete saved recordings directly.',
        snapshotText: snapshotText,
      );
    }

    // 5. Advertising identifiers, ad attribution, or targeted ads (strictly gated against negations).
    if (_adIdOrNetworkWord.hasMatch(subClause) &&
        !isNegated &&
        hasAffirmativeVerb) {
      return _buildVerifiedFinding(
        id: nextId,
        title: 'Uses or shares advertising identifiers',
        category: FindingCategory.sharing,
        severity: FindingSeverity.medium,
        excerpt: quote,
        explanation:
            'The quoted passage describes collecting or sharing an advertising identifier (such as AD_ID or attribution SDK signals) to measure campaigns or personalize promotions.',
        unknown:
            'Verify whether child-directed or restricted attribution mode disables cross-app profiling.',
        snapshotText: snapshotText,
      );
    }

    // 6. Explicit sale, rental, or data-broker sharing (only non-negated affirmative claims).
    if (_dataSaleWord.hasMatch(subClause) &&
        !isNegated &&
        hasAffirmativeVerb &&
        (_externalPartyWord.hasMatch(subClause) ||
            RegExp(r'\b(?:personal|student|child|user)\b', caseSensitive: false)
                .hasMatch(subClause))) {
      return _buildVerifiedFinding(
        id: nextId,
        title: 'May sell, rent, or broker personal data',
        category: FindingCategory.sharing,
        severity: FindingSeverity.high,
        excerpt: quote,
        explanation:
            'The policy includes language indicating personal or usage information may be sold, rented, or shared with data brokers.',
        unknown:
            'Check opt-out controls and account settings to verify how to block third-party sharing.',
        snapshotText: snapshotText,
      );
    }

    // 7. General external / third-party sharing (distinguishes service providers from ad sharing).
    if (_externalSharingVerb.hasMatch(subClause) &&
        _externalPartyWord.hasMatch(subClause) &&
        !isNegated) {
      final isServiceOnly = _serviceProviderScopeWord.hasMatch(subClause);
      return _buildVerifiedFinding(
        id: nextId,
        title: isServiceOnly
            ? 'Uses third-party service providers'
            : 'Shares data with external parties',
        category: FindingCategory.sharing,
        severity: isServiceOnly
            ? FindingSeverity.low
            : FindingSeverity.medium,
        excerpt: quote,
        explanation: isServiceOnly
            ? 'The policy states operational providers (such as hosting or payment processors) receive data needed to run the service.'
            : 'The policy discloses sharing information with external partners or third parties; review which data categories are included.',
        unknown:
            'The clause does not list every downstream subprocessor or retention limit.',
        snapshotText: snapshotText,
      );
    }

    // 8. Permission dependency notice.
    if (_permissionBreakWord.hasMatch(subClause) && !isNegated) {
      return _buildVerifiedFinding(
        id: nextId,
        title: 'Features may stop working if permissions are off',
        category: FindingCategory.parentalConsent,
        severity: FindingSeverity.low,
        excerpt: quote,
        explanation:
            'Turning off device permissions in Android Settings may limit certain app features.',
        unknown:
            'The excerpt does not enumerate which offline activities remain available.',
        snapshotText: snapshotText,
      );
    }

    // 9. General device / technical identifiers kept conservative & separate from AD_ID.
    if (_deviceIdentifierWord.hasMatch(subClause) &&
        !isNegated &&
        hasAffirmativeVerb) {
      return _buildVerifiedFinding(
        id: nextId,
        title: 'Collects device or technical identifiers',
        category: FindingCategory.dataCollection,
        severity: FindingSeverity.low,
        excerpt: quote,
        explanation:
            'The policy states the app collects general device or technical identifiers (such as OS telemetry or IP/device IDs) rather than confirming cross-app advertising profiling.',
        unknown:
            'The quoted text does not specify whether those identifiers stay strictly internal or are linked to marketing profiles.',
        snapshotText: snapshotText,
      );
    }

    return null;
  }

  static VerifiedFinding _buildVerifiedFinding({
    required String id,
    required String title,
    required FindingCategory category,
    required FindingSeverity severity,
    required String excerpt,
    required String explanation,
    required String unknown,
    required String snapshotText,
  }) {
    final validated = EvidenceValidator.validateFinding(
      rawFinding: {'id': id, 'exact_excerpt': excerpt},
      snapshotText: snapshotText,
      validEvidenceIds: {id},
    );
    final isMatched = validated['status'] == 'SOURCE_MATCHED';
    return VerifiedFinding(
      id: id,
      title: title,
      category: category,
      severity: severity,
      exactExcerpt: EvidenceValidator.normalize(excerpt),
      explanation: explanation,
      whatPolicySays:
          'Exact match found in this policy (${EvidenceValidator.normalize(excerpt).length} chars).',
      whatAndroidReports: PermissionComparator.standaloneAndroidReportText,
      unknowns: [unknown],
      status: isMatched
          ? EvidenceStatus.sourceMatched
          : EvidenceStatus.unverified,
      contextWindow: EvidenceValidator.extractContextWindow(
        quote: excerpt,
        snapshotText: snapshotText,
      ),
    );
  }
}

/// Ensures fallback summary explicitly states when deterministic scanning ran
/// after unavailable or failed cloud inference without dropping legitimate findings.
String formatDeterministicSummary({
  required ReviewOverallState overallState,
  required int findingCount,
  required ReviewDiagnosticKind? fallbackDiagnosticKind,
  String? failureDetail,
}) {
  if (fallbackDiagnosticKind ==
      ReviewDiagnosticKind.cloudUnavailableLocalFallback) {
    if (findingCount == 0) {
      return 'The cloud check could not finish, so this is the on-device result from your phone. It matched no common risk phrases, though the full cloud check did not run.';
    }
    return 'The cloud check could not finish, so this is the on-device result from your phone. $findingCount ${findingCount == 1 ? 'part of this policy needs' : 'parts of this policy need'} a closer look before a child uses this app.';
  }

  if (fallbackDiagnosticKind == ReviewDiagnosticKind.failedModelInference) {
    final detail = (failureDetail ?? '').trim();
    if (findingCount == 0) {
      return 'Model inference failed${detail.isNotEmpty ? ' ($detail)' : ''}. Enprive’s local deterministic scanner matched no common risk phrases, so a full review could not be completed.';
    }
    return 'Model inference failed${detail.isNotEmpty ? ' ($detail)' : ''}, so this result came from Enprive’s local deterministic scanner. $findingCount ${findingCount == 1 ? 'part needs' : 'parts need'} a closer look.';
  }

  return switch (overallState) {
    ReviewOverallState.reviewRecommended =>
      '$findingCount ${findingCount == 1 ? 'part of this policy needs' : 'parts of this policy need'} a closer look before a child uses this app.',
    ReviewOverallState.noConcern =>
      'No data sharing, tracking, or long-term retention clauses stood out in the text we reviewed.',
    ReviewOverallState.insufficientEvidence =>
      'There wasn’t enough clear policy text here to verify what the app collects.',
  };
}
