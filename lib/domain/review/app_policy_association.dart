/// Pure Dart application-to-policy association models and deterministic
/// evaluator for Enprive.
///
/// This module helps explain whether a supplied privacy policy text or URL
/// mentions the selected Android application or package identifier, or instead
/// references a different package. Textual or URL mentions never prove
/// developer ownership or verify publisher authenticity.
library;

/// Evidence-calibrated association states between a selected app and a
/// privacy policy reference.
///
/// None of these states certifies safety or proves publisher ownership.
enum AppPolicyAssociationState {
  /// No meaningful app-policy association can be evaluated because either no
  /// application identity is selected (standalone policy review) or no policy
  /// reference is attached yet (permission-only inspection / review coverage).
  ///
  /// D5.3-C/D callers must distinguish review coverage from policy
  /// association and must not present permission-only inspection as a
  /// standalone policy review.
  unlinked,

  /// The user linked an app and policy reference, and no textual identifier
  /// or contradicting package identifier was detected.
  userLinkedUnverified,

  /// The exact selected Android package identifier was mentioned in the
  /// supplied policy text or a store/policy URL query parameter.
  packageIdentifierMentioned,

  /// The selected application's distinctive name appears in the supplied
  /// policy prose.
  appNameMentioned,

  /// The supplied policy reference does not mention the selected app or
  /// package and instead references one or more different package identifiers.
  unmatched,

  /// The supplied policy references both the selected app/package and one or
  /// more other package identifiers, creating conflicting identity signals.
  ambiguousIdentity,

  /// The association comes from an explicit built-in Enprive sample fixture.
  sampleFixture,
}

/// Source where an identifier or name mention was observed.
enum AssociationMatchSource {
  /// Observed in the supplied policy text body (excluding URLs and emails).
  policyText,

  /// Observed in the supplied policy URL (host or `?id=` query parameter).
  policyUrl,

  /// Supplied through explicit trusted built-in sample fixture metadata.
  sampleFixture,
}

/// Built-in demonstration sample fixtures recognized strictly through explicit
/// structured metadata rather than policy text heuristics.
enum TrustedSampleFixture {
  eduTrackDemo(
    id: 'edutrack_demo',
    packageName: 'com.edutrack.classroom.demo',
    appName: 'EduTrack Classroom Companion',
  ),
  calmMathDemo(
    id: 'calmmath_demo',
    packageName: 'com.calmmath.abacus.demo',
    appName: 'CalmMath Abacus',
  );

  const TrustedSampleFixture({
    required this.id,
    required this.packageName,
    required this.appName,
  });

  /// Stable serialized identifier for the fixture.
  final String id;

  /// Canonical demonstration package name paired with this fixture.
  final String packageName;

  /// Canonical demonstration app display name paired with this fixture.
  final String appName;

  /// Resolves a fixture from its serialized [id], or `null` if unknown.
  static TrustedSampleFixture? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final fixture in values) {
      if (fixture.id == id) return fixture;
    }
    return null;
  }
}

/// Minimal on-device candidate identity metadata used only to detect when two
/// installed applications share similar display names.
class AppIdentityCandidate {
  const AppIdentityCandidate({
    required this.packageName,
    required this.appName,
  });

  /// Candidate app's Android package identifier (on-device metadata only).
  final String packageName;

  /// Candidate app's display label (on-device metadata only).
  final String appName;
}

/// Immutable input bundle evaluated by [AppPolicyAssociationEvaluator].
class AppPolicyAssociationInput {
  const AppPolicyAssociationInput({
    this.packageName,
    this.appName,
    this.policyText,
    this.policyUrl,
    this.sampleFixture,
    this.candidateApps = const <AppIdentityCandidate>[],
    this.evaluatedAt,
  });

  /// Selected app's Android package identifier (on-device metadata only).
  final String? packageName;

  /// Selected app's display name (on-device metadata only).
  final String? appName;

  /// Supplied privacy policy excerpt or document text.
  final String? policyText;

  /// Supplied privacy policy URL, if any.
  final String? policyUrl;

  /// Explicit trusted metadata when evaluating a built-in Enprive demo flow.
  final TrustedSampleFixture? sampleFixture;

  /// Optional peer application candidates evaluated locally to detect display-name collisions.
  final List<AppIdentityCandidate> candidateApps;

  /// Optional caller-supplied evaluation timestamp (never defaulted via `DateTime.now()`
  /// so repeated evaluations remain strictly deterministic).
  final DateTime? evaluatedAt;
}

/// Immutable, serializable report describing textual/URL association signals
/// without embedding raw policy text or Android permission snapshots.
class AppPolicyAssociationReport {
  AppPolicyAssociationReport({
    required this.state,
    required this.explanation,
    required this.ownershipLimitationNotice,
    this.selectedPackageName,
    this.selectedAppName,
    List<AssociationMatchSource> matchSources = const <AssociationMatchSource>[],
    List<String> matchedIdentifiers = const <String>[],
    List<String> conflictingPackageIdentifiers = const <String>[],
    List<String> ambiguousCandidatePackages = const <String>[],
    this.urlHostMatched = false,
    this.sampleFixture,
    this.evaluatedAt,
  }) : matchSources = List<AssociationMatchSource>.unmodifiable(matchSources),
       matchedIdentifiers = List<String>.unmodifiable(matchedIdentifiers),
       conflictingPackageIdentifiers = List<String>.unmodifiable(
         conflictingPackageIdentifiers,
       ),
       ambiguousCandidatePackages = List<String>.unmodifiable(
         ambiguousCandidatePackages,
       );

  /// Standard non-ownership limitation message included with every report.
  static const String defaultOwnershipLimitationNotice =
      'Textual and URL references can suggest which app a policy describes, '
      'but they do not verify developer ownership or policy authenticity.';

  /// Deserializes a previously persisted [AppPolicyAssociationReport].
  ///
  /// Enforces strict sample-fixture integrity: a serialized `sampleFixture`
  /// state is accepted only when `sampleFixtureId` matches a registered
  /// [TrustedSampleFixture] whose package identifier matches the serialized
  /// selected package; invalid, unknown, or mismatched fixture records degrade
  /// safely to [AppPolicyAssociationState.userLinkedUnverified] without throwing.
  factory AppPolicyAssociationReport.fromJson(Map<String, dynamic> json) {
    final rawState = json['state']?.toString();
    var state = AppPolicyAssociationState.values.firstWhere(
      (value) => value.name == rawState,
      orElse: () => AppPolicyAssociationState.userLinkedUnverified,
    );

    final rawSources = json['matchSources'];
    final sources = <AssociationMatchSource>[];
    if (rawSources is List) {
      for (final item in rawSources) {
        if (item == null) continue;
        final name = item.toString();
        for (final source in AssociationMatchSource.values) {
          if (source.name == name && !sources.contains(source)) {
            sources.add(source);
          }
        }
      }
    }

    final rawMatched = json['matchedIdentifiers'];
    var matched = rawMatched is List
        ? rawMatched
              .where((item) => item != null)
              .map((item) => item.toString())
              .where((s) => s.isNotEmpty)
              .toList()
        : const <String>[];

    final rawConflicting = json['conflictingPackageIdentifiers'];
    final conflicting = rawConflicting is List
        ? rawConflicting
              .where((item) => item != null)
              .map((item) => item.toString())
              .where((s) => s.isNotEmpty)
              .toList()
        : const <String>[];

    final rawAmbiguous = json['ambiguousCandidatePackages'];
    final ambiguousCandidates = rawAmbiguous is List
        ? rawAmbiguous
              .where((item) => item != null)
              .map((item) => item.toString())
              .where((s) => s.isNotEmpty)
              .toList()
        : const <String>[];

    final rawEvaluatedAt = json['evaluatedAt']?.toString();
    final evaluatedAt = (rawEvaluatedAt == null || rawEvaluatedAt.isEmpty)
        ? null
        : DateTime.tryParse(rawEvaluatedAt)?.toUtc();

    final selectedPackageName = _nullIfBlank(
      json['selectedPackageName']?.toString(),
    );
    final normalizedSelectedPkg =
        AppPolicyAssociationEvaluator._normalizePackageName(selectedPackageName);
    final parsedFixture = TrustedSampleFixture.fromId(
      json['sampleFixtureId']?.toString(),
    );

    var explanation = json['explanation']?.toString().trim();
    final limitation = json['ownershipLimitationNotice']?.toString().trim();

    TrustedSampleFixture? effectiveFixture;
    if (state == AppPolicyAssociationState.sampleFixture) {
      final isValidRegisteredFixture =
          parsedFixture != null &&
          normalizedSelectedPkg != null &&
          normalizedSelectedPkg == parsedFixture.packageName.toLowerCase();
      if (isValidRegisteredFixture) {
        effectiveFixture = parsedFixture;
      } else {
        state = AppPolicyAssociationState.userLinkedUnverified;
        effectiveFixture = null;
        sources.removeWhere(
          (source) => source == AssociationMatchSource.sampleFixture,
        );
        matched = const <String>[];
        explanation =
            'Serialized sample fixture metadata was missing, unrecognized, or '
            'mismatched; degraded to an unverified user-linked association.';
      }
    } else {
      effectiveFixture = null;
      sources.removeWhere(
        (source) => source == AssociationMatchSource.sampleFixture,
      );
    }

    return AppPolicyAssociationReport(
      state: state,
      selectedPackageName: selectedPackageName,
      selectedAppName: _nullIfBlank(json['selectedAppName']?.toString()),
      matchSources: sources,
      matchedIdentifiers: matched,
      conflictingPackageIdentifiers: conflicting,
      ambiguousCandidatePackages: ambiguousCandidates,
      urlHostMatched: json['urlHostMatched'] == true,
      sampleFixture: effectiveFixture,
      evaluatedAt: evaluatedAt,
      explanation: (explanation == null || explanation.isEmpty)
          ? defaultOwnershipLimitationNotice
          : explanation,
      ownershipLimitationNotice: (limitation == null || limitation.isEmpty)
          ? defaultOwnershipLimitationNotice
          : limitation,
    );
  }

  /// Evaluated association state.
  final AppPolicyAssociationState state;

  /// Normalized Android package identifier evaluated, if one was supplied.
  final String? selectedPackageName;

  /// Selected application display label, if one was supplied.
  final String? selectedAppName;

  /// Sources that contributed positive identifier/name signals.
  final List<AssociationMatchSource> matchSources;

  /// Bounded identifiers/tokens matched against the selected app.
  final List<String> matchedIdentifiers;

  /// Competing Android package identifiers found in the supplied policy/URL.
  final List<String> conflictingPackageIdentifiers;

  /// Peer installed package identifiers sharing similar display names when the
  /// policy prose does not disambiguate by exact package identifier.
  final List<String> ambiguousCandidatePackages;

  /// Whether the supplied policy URL hostname matched the app's distinctive
  /// name tokens (recorded separately from policy prose mentions).
  final bool urlHostMatched;

  /// Sample fixture identifier if `state == AppPolicyAssociationState.sampleFixture`.
  final TrustedSampleFixture? sampleFixture;

  /// Optional caller-supplied evaluation timestamp (UTC when serialized).
  final DateTime? evaluatedAt;

  /// Calibrated, non-promissory explanation of the observed signals.
  final String explanation;

  /// Explicit disclaimer stating that textual/URL association never verifies ownership.
  final String ownershipLimitationNotice;

  /// Structural invariant: deterministic policy text/URL association never
  /// proves developer or publisher ownership.
  bool get provesDeveloperOwnership => false;

  /// Whether textual/fixture evidence referenced the selected app/package.
  bool get hasPositiveReference =>
      state == AppPolicyAssociationState.packageIdentifierMentioned ||
      state == AppPolicyAssociationState.appNameMentioned ||
      state == AppPolicyAssociationState.sampleFixture;

  /// Serializes this report cleanly without raw policy prose or permissions.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'state': state.name,
      if (selectedPackageName != null)
        'selectedPackageName': selectedPackageName,
      if (selectedAppName != null) 'selectedAppName': selectedAppName,
      'matchSources': matchSources.map((source) => source.name).toList(),
      'matchedIdentifiers': matchedIdentifiers,
      'conflictingPackageIdentifiers': conflictingPackageIdentifiers,
      'ambiguousCandidatePackages': ambiguousCandidatePackages,
      'urlHostMatched': urlHostMatched,
      if (sampleFixture != null) 'sampleFixtureId': sampleFixture!.id,
      if (evaluatedAt != null) 'evaluatedAt': evaluatedAt!.toUtc().toIso8601String(),
      'explanation': explanation,
      'ownershipLimitationNotice': ownershipLimitationNotice,
      'provesDeveloperOwnership': provesDeveloperOwnership,
    };
  }
}

/// Pure, deterministic evaluator that analyzes textual and URL references
/// between a selected Android app and a supplied privacy policy.
class AppPolicyAssociationEvaluator {
  AppPolicyAssociationEvaluator._();

  static final RegExp _strictPackageRegex = RegExp(
    r'^[a-zA-Z0-9_]+(\.[a-zA-Z0-9_]+)+$',
  );

  static final RegExp _urlPattern = RegExp(
    r'''(?:https?|market)://[^\s<>"'\)\]]+''',
    caseSensitive: false,
  );

  static final RegExp _emailPattern = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );

  static final RegExp _reverseDnsCandidatePattern = RegExp(
    r'(?<![a-zA-Z0-9_.-])([a-zA-Z][a-zA-Z0-9_]*(?:\.[a-zA-Z][a-zA-Z0-9_]*){1,})(?![a-zA-Z0-9_-]|\.[a-zA-Z0-9_])',
  );

  static final RegExp _unicodeWordPattern = RegExp(
    r'[\p{L}\p{N}]+',
    unicode: true,
  );

  static final RegExp _asciiAlnumOnly = RegExp(r'^[a-z0-9]+$');

  static final RegExp _cjkKanaHangulOnly = RegExp(
    r'^[\u3040-\u30FF\u3400-\u4DBF\u4E00-\u9FFF\uAC00-\uD7AF]+$',
  );

  static final RegExp _camelBoundary = RegExp(r'(?<=[a-z0-9])(?=[A-Z])');

  static const Set<String> _stopwords = <String>{
    'app',
    'apps',
    'application',
    'applications',
    'mobile',
    'free',
    'pro',
    'plus',
    'lite',
    'hd',
    'beta',
    'game',
    'games',
    'kids',
    'kid',
    'child',
    'children',
    'school',
    'student',
    'students',
    'learning',
    'study',
    'education',
    'edu',
    'tool',
    'tools',
    'helper',
    'manager',
    'companion',
    'official',
    'new',
    'best',
    'my',
    'the',
    'for',
    'and',
    'with',
    'by',
    'of',
    'to',
    'in',
    'on',
    'a',
    'an',
    'privacy',
    'policy',
    'terms',
    'service',
    'services',
    'data',
    'online',
    'smart',
    'easy',
    'simple',
    'quick',
    'fast',
    'super',
    'mini',
    'max',
    'studio',
    'studios',
    'labs',
    'lab',
    'inc',
    'llc',
    'ltd',
    'co',
    'top',
    'hub',
    'box',
    'cam',
    'map',
    'fun',
    'run',
    'fit',
    'pay',
    'web',
    'net',
    'all',
    'one',
    'now',
  };

  static const Set<String> _reverseDnsRoots = <String>{
    'com',
    'org',
    'net',
    'io',
    'app',
    'dev',
    'edu',
    'gov',
    'co',
    'me',
    'de',
    'fr',
    'uk',
    'jp',
    'kr',
    'in',
    'au',
    'ca',
    'br',
    'nl',
    'ch',
    'es',
    'it',
    'pl',
    'se',
    'no',
    'fi',
    'dk',
    'at',
    'be',
    'pt',
    'tw',
    'hk',
    'sg',
    'my',
    'id',
    'ph',
    'th',
    'vn',
    'za',
    'il',
    'ae',
    'sa',
    'tr',
    'ru',
    'ua',
    'mx',
    'ar',
    'cl',
    'nz',
    'ie',
    'ai',
    'gg',
    'tv',
    'cc',
    'so',
    'studio',
    'labs',
    'tech',
  };

  static const Set<String> _nonPackageTailLabels = <String>{
    'com',
    'org',
    'net',
    'edu',
    'gov',
    'info',
    'biz',
    'html',
    'htm',
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'gif',
    'svg',
    'webp',
    'json',
    'xml',
    'txt',
    'md',
    'csv',
    'yaml',
    'yml',
    'js',
    'css',
    'apk',
    'aab',
    'zip',
    'php',
    'asp',
    'jsp',
  };

  static const Set<String> _urlTldSkipLabels = <String>{
    'www',
    'com',
    'org',
    'net',
    'io',
    'co',
    'app',
    'dev',
    'edu',
    'gov',
    'uk',
    'de',
    'fr',
    'jp',
    'kr',
    'in',
    'au',
    'ca',
  };

  /// Evaluates the supplied [input] deterministically on-device.
  ///
  /// Boundary for D5.3-C/D callers:
  /// - Standalone policy review: policy exists without a selected app -> [AppPolicyAssociationState.unlinked].
  /// - Permission-only inspection: app selected without an attached policy -> separate review-coverage condition (`missingPolicyPermissionOnly`); this evaluator returns [AppPolicyAssociationState.unlinked] because no app-policy association can be checked yet, and callers must not label permission-only reviews as standalone policy reviews.
  static AppPolicyAssociationReport evaluate(AppPolicyAssociationInput input) {
    final rawPackageInput = _nullIfBlank(input.packageName);
    final normalizedPackage = _normalizePackageName(rawPackageInput);
    final selectedAppName = _nullIfBlank(input.appName);
    final policyText = _nullIfBlank(input.policyText);
    final policyUrl = _nullIfBlank(input.policyUrl);

    // Trusted demo fixtures are strictly anchored on structured metadata,
    // never inferred from policy prose strings or mismatched/invalid packages.
    final fixture = input.sampleFixture;
    if (fixture != null &&
        (rawPackageInput == null ||
            normalizedPackage == fixture.packageName.toLowerCase())) {
      return AppPolicyAssociationReport(
        state: AppPolicyAssociationState.sampleFixture,
        selectedPackageName: fixture.packageName,
        selectedAppName: selectedAppName ?? fixture.appName,
        matchSources: const <AssociationMatchSource>[
          AssociationMatchSource.sampleFixture,
        ],
        matchedIdentifiers: <String>[fixture.packageName],
        explanation:
            'Built-in sample fixture (${fixture.appName}) used for '
            'demonstration without verifying publisher ownership.',
        ownershipLimitationNotice:
            AppPolicyAssociationReport.defaultOwnershipLimitationNotice,
        sampleFixture: fixture,
        evaluatedAt: input.evaluatedAt,
      );
    }

    final hasAppIdentity =
        normalizedPackage != null || selectedAppName != null;
    final hasPolicyReference = policyText != null || policyUrl != null;

    if (!hasAppIdentity || !hasPolicyReference) {
      return AppPolicyAssociationReport(
        state: AppPolicyAssociationState.unlinked,
        selectedPackageName: normalizedPackage,
        selectedAppName: selectedAppName,
        explanation: !hasAppIdentity
            ? 'No application is selected to compare against this policy.'
            : 'No policy text or policy URL is attached for the selected application.',
        ownershipLimitationNotice:
            AppPolicyAssociationReport.defaultOwnershipLimitationNotice,
        evaluatedAt: input.evaluatedAt,
      );
    }

    final embeddedUrls = policyText == null
        ? const <String>[]
        : _urlPattern
              .allMatches(policyText)
              .map(
                (match) => _trimTrailingEmbeddedUrlPunctuation(match.group(0)!),
              )
              .where((url) => url.isNotEmpty)
              .toList(growable: false);

    final proseWithoutUrlsOrEmails = policyText == null
        ? ''
        : policyText
              .replaceAll(_urlPattern, ' ')
              .replaceAll(_emailPattern, ' ');

    // 1. Package identifier matching across prose & URL query parameters.
    var packageInProse =
        normalizedPackage != null &&
        _containsStrictPackageMatch(
          proseWithoutUrlsOrEmails,
          normalizedPackage,
        );

    var packageInUrl = false;
    final conflictingPackages = <String>{};

    void inspectUrlForPackageIds(String url, {required bool isPolicyUrlInput}) {
      final queryPackage = _extractPackageFromUrlQuery(url);
      if (queryPackage != null) {
        if (normalizedPackage != null && queryPackage == normalizedPackage) {
          if (isPolicyUrlInput) {
            packageInUrl = true;
          } else {
            // Embedded URLs inside captured policy text count toward policy
            // text provenance, never as an independently supplied canonical URL.
            packageInProse = true;
          }
        } else if (normalizedPackage == null ||
            queryPackage != normalizedPackage) {
          conflictingPackages.add(queryPackage);
        }
      }
      if (!isPolicyUrlInput && queryPackage == null) {
        // Embedded prose URL without ?id= intentionally does not promote a
        // hostname to a package identifier.
      }
    }

    if (policyUrl != null) {
      inspectUrlForPackageIds(policyUrl, isPolicyUrlInput: true);
    }
    for (final embedded in embeddedUrls) {
      inspectUrlForPackageIds(embedded, isPolicyUrlInput: false);
    }

    for (final candidate in _extractProsePackageCandidates(
      proseWithoutUrlsOrEmails,
    )) {
      if (normalizedPackage == null || candidate != normalizedPackage) {
        conflictingPackages.add(candidate);
      }
    }

    // 2. App name distinctive tokenization & prose matching.
    final distinctiveTokens = _extractDistinctiveNameTokens(selectedAppName);
    final alternateCamelTokens = _extractCamelExpandedTokens(selectedAppName);

    final appNameInProse =
        distinctiveTokens.isNotEmpty &&
        _containsAppNameInProse(
          proseWithoutUrlsOrEmails,
          distinctiveTokens,
          alternateCamelTokens,
        );

    // 3. Separate URL host inspection (does not elevate to appNameMentioned).
    final urlHostMatched =
        policyUrl != null &&
        distinctiveTokens.isNotEmpty &&
        _matchesUrlHost(policyUrl, distinctiveTokens);

    final conflictingList = conflictingPackages.toList()..sort();
    final hasConflict = conflictingList.isNotEmpty;
    final packageMatched = packageInProse || packageInUrl;

    // Detect peer installed apps sharing similar display names when policy
    // prose matches the app name without uniquely identifying the package ID.
    final ambiguousCandidates = <String>{};
    if (appNameInProse && !packageMatched && input.candidateApps.isNotEmpty) {
      for (final candidate in input.candidateApps) {
        final candidatePackage = _normalizePackageName(candidate.packageName);
        if (candidatePackage == null || candidatePackage == normalizedPackage) {
          continue;
        }
        final candidateTokens = _extractDistinctiveNameTokens(
          candidate.appName,
        );
        if (candidateTokens.isEmpty) continue;
        final candidateCamel = _extractCamelExpandedTokens(candidate.appName);
        final sameDistinctiveTokens = _tokenListsEqual(
          candidateTokens,
          distinctiveTokens,
        );
        final candidateAlsoMentioned = _containsAppNameInProse(
          proseWithoutUrlsOrEmails,
          candidateTokens,
          candidateCamel,
        );
        if (sameDistinctiveTokens || candidateAlsoMentioned) {
          ambiguousCandidates.add(candidatePackage);
        }
      }
    }
    final ambiguousCandidateList = ambiguousCandidates.toList()..sort();

    // 4. Resolve final calibrated state.
    if ((packageMatched || appNameInProse) && hasConflict) {
      final sources = <AssociationMatchSource>[
        if (packageInProse || appNameInProse) AssociationMatchSource.policyText,
        if (packageInUrl) AssociationMatchSource.policyUrl,
      ];
      final matchedIds = <String>[
        if (packageMatched && normalizedPackage != null) normalizedPackage,
        if (appNameInProse && selectedAppName != null) selectedAppName,
      ];
      return AppPolicyAssociationReport(
        state: AppPolicyAssociationState.ambiguousIdentity,
        selectedPackageName: normalizedPackage,
        selectedAppName: selectedAppName,
        matchSources: sources,
        matchedIdentifiers: matchedIds,
        conflictingPackageIdentifiers: conflictingList,
        ambiguousCandidatePackages: ambiguousCandidateList,
        urlHostMatched: urlHostMatched,
        evaluatedAt: input.evaluatedAt,
        explanation:
            'The supplied policy references both the selected app and other '
            'package identifiers (${conflictingList.join(', ')}), so the '
            'identity signal is ambiguous.',
        ownershipLimitationNotice:
            AppPolicyAssociationReport.defaultOwnershipLimitationNotice,
      );
    }

    if (packageMatched) {
      final sources = <AssociationMatchSource>[
        if (packageInProse) AssociationMatchSource.policyText,
        if (packageInUrl) AssociationMatchSource.policyUrl,
      ];
      return AppPolicyAssociationReport(
        state: AppPolicyAssociationState.packageIdentifierMentioned,
        selectedPackageName: normalizedPackage,
        selectedAppName: selectedAppName,
        matchSources: sources,
        matchedIdentifiers: <String>[normalizedPackage!],
        urlHostMatched: urlHostMatched,
        evaluatedAt: input.evaluatedAt,
        explanation: packageInProse
            ? 'The supplied policy text mentions package identifier '
                  '$normalizedPackage.'
            : 'The supplied URL references package identifier '
                  '$normalizedPackage in its query parameters.',
        ownershipLimitationNotice:
            AppPolicyAssociationReport.defaultOwnershipLimitationNotice,
      );
    }

    if (appNameInProse && ambiguousCandidateList.isNotEmpty) {
      return AppPolicyAssociationReport(
        state: AppPolicyAssociationState.ambiguousIdentity,
        selectedPackageName: normalizedPackage,
        selectedAppName: selectedAppName,
        matchSources: const <AssociationMatchSource>[
          AssociationMatchSource.policyText,
        ],
        matchedIdentifiers: <String>[selectedAppName!],
        ambiguousCandidatePackages: ambiguousCandidateList,
        urlHostMatched: urlHostMatched,
        evaluatedAt: input.evaluatedAt,
        explanation:
            'The supplied policy text mentions "$selectedAppName", which '
            'shares a similar display name with other candidate apps '
            '(${ambiguousCandidateList.join(', ')}) without naming the exact '
            'package identifier.',
        ownershipLimitationNotice:
            AppPolicyAssociationReport.defaultOwnershipLimitationNotice,
      );
    }

    if (appNameInProse) {
      return AppPolicyAssociationReport(
        state: AppPolicyAssociationState.appNameMentioned,
        selectedPackageName: normalizedPackage,
        selectedAppName: selectedAppName,
        matchSources: const <AssociationMatchSource>[
          AssociationMatchSource.policyText,
        ],
        matchedIdentifiers: <String>[selectedAppName!],
        urlHostMatched: urlHostMatched,
        evaluatedAt: input.evaluatedAt,
        explanation:
            'The supplied policy text mentions the app name '
            '"$selectedAppName".',
        ownershipLimitationNotice:
            AppPolicyAssociationReport.defaultOwnershipLimitationNotice,
      );
    }

    if (hasConflict) {
      return AppPolicyAssociationReport(
        state: AppPolicyAssociationState.unmatched,
        selectedPackageName: normalizedPackage,
        selectedAppName: selectedAppName,
        conflictingPackageIdentifiers: conflictingList,
        urlHostMatched: urlHostMatched,
        evaluatedAt: input.evaluatedAt,
        explanation:
            'The supplied policy does not mention this app or package and '
            'instead references ${conflictingList.join(', ')}.',
        ownershipLimitationNotice:
            AppPolicyAssociationReport.defaultOwnershipLimitationNotice,
      );
    }

    return AppPolicyAssociationReport(
      state: AppPolicyAssociationState.userLinkedUnverified,
      selectedPackageName: normalizedPackage,
      selectedAppName: selectedAppName,
      urlHostMatched: urlHostMatched,
      evaluatedAt: input.evaluatedAt,
      explanation: urlHostMatched
          ? 'This policy was linked by you; the policy URL hostname includes '
                'app terms, while the policy text itself does not mention the '
                'app name or package identifier.'
          : 'This policy was linked by you without an explicit mention of the '
                'selected app name or package identifier in the supplied text.',
      ownershipLimitationNotice:
          AppPolicyAssociationReport.defaultOwnershipLimitationNotice,
    );
  }

  static bool _tokenListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static String? _normalizePackageName(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed.length > 255) {
      return null;
    }
    if (!_strictPackageRegex.hasMatch(trimmed)) return null;
    return trimmed.toLowerCase();
  }

  static bool _containsStrictPackageMatch(String text, String packageLower) {
    if (text.isEmpty) return false;
    final escaped = RegExp.escape(packageLower);
    final pattern = RegExp(
      '(?<![a-zA-Z0-9_.-])$escaped(?![a-zA-Z0-9_-]|\\.[a-zA-Z0-9_])',
      caseSensitive: false,
    );
    return pattern.hasMatch(text);
  }

  static String? _extractPackageFromUrlQuery(String rawUrl) {
    final uri = _parseWebOrMarketUri(rawUrl);
    if (uri == null) return null;
    final candidateId = uri.queryParameters['id']?.trim();
    if (candidateId == null || candidateId.isEmpty) return null;
    return _normalizePackageName(candidateId);
  }

  static Set<String> _extractProsePackageCandidates(String prose) {
    if (prose.trim().isEmpty) return const <String>{};
    final results = <String>{};
    for (final match in _reverseDnsCandidatePattern.allMatches(prose)) {
      final candidate = match.group(1);
      if (candidate == null) continue;
      final lower = candidate.toLowerCase();
      final segments = lower.split('.');
      if (segments.length < 2) continue;
      final first = segments.first;
      final last = segments.last;
      if (!_reverseDnsRoots.contains(first)) continue;
      if (_nonPackageTailLabels.contains(last)) continue;
      if (segments.length == 2 && last.length < 3) continue;
      if (lower.length > 255) continue;
      results.add(lower);
    }
    return results;
  }

  static List<String> _extractDistinctiveNameTokens(String? appName) {
    if (appName == null || appName.trim().isEmpty) return const <String>[];
    final folded = _foldDiacritics(appName.toLowerCase());
    final tokens = <String>[];
    for (final match in _unicodeWordPattern.allMatches(folded)) {
      final token = match.group(0)!;
      if (_stopwords.contains(token)) continue;
      final minLen = _asciiAlnumOnly.hasMatch(token) ? 3 : 2;
      if (token.length < minLen) continue;
      tokens.add(token);
    }
    return tokens;
  }

  static List<String> _extractCamelExpandedTokens(String? appName) {
    if (appName == null || appName.trim().isEmpty) return const <String>[];
    final expanded = appName.replaceAll(_camelBoundary, ' ');
    if (expanded == appName) return const <String>[];
    return _extractDistinctiveNameTokens(expanded);
  }

  static bool _containsAppNameInProse(
    String prose,
    List<String> distinctiveTokens,
    List<String> alternateCamelTokens,
  ) {
    if (prose.trim().isEmpty || distinctiveTokens.isEmpty) return false;
    final foldedProse = _foldDiacritics(prose.toLowerCase());
    final proseTokens = _unicodeWordPattern
        .allMatches(foldedProse)
        .map((match) => match.group(0)!)
        .toList(growable: false);
    if (proseTokens.isEmpty) return false;

    if (_containsContiguousTokens(proseTokens, distinctiveTokens)) {
      return true;
    }

    if (distinctiveTokens.length >= 2) {
      final joined = distinctiveTokens.join();
      if (proseTokens.contains(joined)) {
        return true;
      }
    }

    if (alternateCamelTokens.length >= 2 &&
        _containsContiguousTokens(proseTokens, alternateCamelTokens)) {
      return true;
    }

    // Non-space-delimited scripts (CJK, Japanese Kana, Korean Hangul particles)
    // frequently attach affixes directly to app nouns without whitespace.
    if (distinctiveTokens.every(_cjkKanaHangulOnly.hasMatch)) {
      final compactAppPhrase = distinctiveTokens.join();
      if (compactAppPhrase.length >= 2 &&
          foldedProse.contains(compactAppPhrase)) {
        return true;
      }
    }

    return false;
  }

  static bool _containsContiguousTokens(
    List<String> haystack,
    List<String> needle,
  ) {
    if (needle.isEmpty || needle.length > haystack.length) return false;
    final limit = haystack.length - needle.length;
    for (var i = 0; i <= limit; i++) {
      var allMatch = true;
      for (var j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) {
          allMatch = false;
          break;
        }
      }
      if (allMatch) return true;
    }
    return false;
  }

  static bool _matchesUrlHost(String rawUrl, List<String> distinctiveTokens) {
    final uri = _parseWebOrMarketUri(rawUrl);
    if (uri == null || uri.scheme == 'market') return false;
    final host = _foldDiacritics(uri.host.toLowerCase());
    if (host.isEmpty) return false;

    final rawSegments = host
        .split(RegExp(r'[.-]+'))
        .where((s) => s.isNotEmpty)
        .where((s) => !_urlTldSkipLabels.contains(s))
        .toList(growable: false);
    if (rawSegments.isEmpty) return false;

    if (_containsContiguousTokens(rawSegments, distinctiveTokens)) {
      return true;
    }
    if (distinctiveTokens.length >= 2) {
      final joined = distinctiveTokens.join();
      if (rawSegments.contains(joined)) {
        return true;
      }
    }
    return false;
  }

  static String _trimTrailingEmbeddedUrlPunctuation(String rawUrl) {
    var trimmed = rawUrl.trim();
    const unconditionalPunctuation = <String>[',', ';', ':', '!', '?'];
    var changed = true;
    while (changed && trimmed.isNotEmpty) {
      changed = false;
      for (final ch in unconditionalPunctuation) {
        if (trimmed.endsWith(ch)) {
          trimmed = trimmed.substring(0, trimmed.length - 1);
          changed = true;
          break;
        }
      }
      if (!changed && trimmed.endsWith('.')) {
        // Strip a single sentence-ending period while keeping repeated '..' intact
        // so malformed package values such as `?id=com.example.app..` stay rejected.
        if (trimmed.length >= 2 && trimmed[trimmed.length - 2] != '.') {
          trimmed = trimmed.substring(0, trimmed.length - 1);
          changed = true;
        }
      }
    }
    return trimmed;
  }

  static Uri? _parseWebOrMarketUri(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;
    final direct = Uri.tryParse(trimmed);
    if (direct != null && direct.hasScheme) {
      final scheme = direct.scheme.toLowerCase();
      if ((scheme == 'http' || scheme == 'https' || scheme == 'market') &&
          direct.host.isNotEmpty) {
        return direct;
      }
      return null;
    }
    if (!trimmed.contains('://') && !trimmed.contains(':')) {
      final assumedHttps = Uri.tryParse('https://$trimmed');
      if (assumedHttps != null && assumedHttps.host.isNotEmpty) {
        return assumedHttps;
      }
    }
    return null;
  }

  static String _foldDiacritics(String input) {
    const map = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'å': 'a',
      'ā': 'a',
      'ă': 'a',
      'ą': 'a',
      'ç': 'c',
      'ć': 'c',
      'ĉ': 'c',
      'ċ': 'c',
      'č': 'c',
      'ď': 'd',
      'đ': 'd',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'ē': 'e',
      'ĕ': 'e',
      'ė': 'e',
      'ę': 'e',
      'ě': 'e',
      'ğ': 'g',
      'ĝ': 'g',
      'ġ': 'g',
      'ģ': 'g',
      'ĥ': 'h',
      'ħ': 'h',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ĩ': 'i',
      'ī': 'i',
      'ĭ': 'i',
      'į': 'i',
      'ı': 'i',
      'ĵ': 'j',
      'ķ': 'k',
      'ĺ': 'l',
      'ļ': 'l',
      'ľ': 'l',
      'ŀ': 'l',
      'ł': 'l',
      'ñ': 'n',
      'ń': 'n',
      'ņ': 'n',
      'ň': 'n',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ø': 'o',
      'ō': 'o',
      'ŏ': 'o',
      'ő': 'o',
      'ŕ': 'r',
      'ŗ': 'r',
      'ř': 'r',
      'ś': 's',
      'ŝ': 's',
      'ş': 's',
      'š': 's',
      'ß': 'ss',
      'ţ': 't',
      'ť': 't',
      'ŧ': 't',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ũ': 'u',
      'ū': 'u',
      'ŭ': 'u',
      'ů': 'u',
      'ű': 'u',
      'ų': 'u',
      'ŵ': 'w',
      'ý': 'y',
      'ÿ': 'y',
      'ŷ': 'y',
      'ź': 'z',
      'ż': 'z',
      'ž': 'z',
    };
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      // Strip Unicode combining diacritical marks if decomposed (U+0300..U+036F).
      final code = ch.codeUnitAt(0);
      if (code >= 0x0300 && code <= 0x036F) continue;
      buffer.write(map[ch] ?? ch);
    }
    return buffer.toString();
  }
}

String? _nullIfBlank(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
