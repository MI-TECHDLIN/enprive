import 'package:flutter_test/flutter_test.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/deterministic_clause_scanner.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';

void main() {
  group('D3 DeterministicClauseScanner Semantic & Negation Regression Tests', () {
    test('Case 1: explicit non-advertising statement never claims advertising', () {
      const policy =
          'Our services do not include any third party advertising. All student worksheets stay local inside this device.';
      final findings = DeterministicClauseScanner.scan(policy);
      expect(
        findings.where((f) => f.title.toLowerCase().contains('advertis') || f.category == FindingCategory.sharing),
        isEmpty,
      );
    });

    test('Case 2: explicit non-sale / non-sharing statement never creates a positive claim', () {
      const policy =
          'We do not sell or share personal information. None of your student learning data is rented or shared with advertisers.';
      final findings = DeterministicClauseScanner.scan(policy);
      expect(findings, isEmpty);
    });

    test('Case 3: masked IP / imprecise location never becomes exact GPS or background tracking', () {
      const policy =
          'A masked IP address (with the fourth part hidden) is collected to infer an imprecise location. Accounts only store grade level.';
      final findings = DeterministicClauseScanner.scan(policy);
      expect(
        findings.where(
          (f) =>
              f.severity == FindingSeverity.high ||
              f.title.toLowerCase().contains('background') ||
              f.title.toLowerCase().contains('gps') ||
              f.explanation.toLowerCase().contains('exact gps'),
        ),
        isEmpty,
      );
      expect(findings.length, 1);
      expect(findings.first.severity, FindingSeverity.low);
      expect(findings.first.status, EvidenceStatus.sourceMatched);
      expect(findings.first.title, contains('approximate region'));
    });

    test('Case 4: explicit background GPS statement still produces high-severity background location finding', () {
      const policy =
          'Our mobile application collects precise GPS location coordinates even when the application is running in the background to route buses.';
      final findings = DeterministicClauseScanner.scan(policy);
      expect(findings.length, 1);
      expect(findings.first.category, FindingCategory.tracking);
      expect(findings.first.severity, FindingSeverity.high);
      expect(findings.first.status, EvidenceStatus.sourceMatched);
      expect(findings.first.title, contains('background'));
    });

    test('Case 5: explicit advertising ID sharing produces scoped ad-ID finding', () {
      const policy =
          'A third party attribution platform called AppsFlyer collects the Android Advertising ID in order to understand which ads shown to parents led to registered users.';
      final findings = DeterministicClauseScanner.scan(policy);
      expect(findings, isNotEmpty);
      expect(findings.first.category, FindingCategory.sharing);
      expect(findings.first.severity, FindingSeverity.medium);
      expect(findings.first.status, EvidenceStatus.sourceMatched);
      expect(findings.first.title.toLowerCase(), contains('advertising'));
    });

    test('Case 5b: device QA paste reports background location, ad ID, and voice retention', () {
      const policy =
          'We collect your location even when the app is not in use. We share your email and advertising ID with third party advertisers. We keep voice recordings indefinitely.';
      final findings = DeterministicClauseScanner.scan(policy);
      expect(findings.map((f) => f.title), [
        'Tracks location in the background',
        'Uses or shares advertising identifiers',
        'Retains voice, audio, or biometric data',
      ]);
      for (final f in findings) {
        expect(f.status, EvidenceStatus.sourceMatched);
        expect(policy, contains(f.exactExcerpt));
      }
    });

    test('Case 5c: denied background location with "not in use" wording stays silent', () {
      const policy =
          'We do not collect your location when the app is not in use. We never track location even when the app is closed.';
      expect(DeterministicClauseScanner.scan(policy), isEmpty);
    });

    test('Case 6: ambiguous third-party / operational wording never inflates into high-severity accusation', () {
      const policy =
          'We work with trusted third-party service providers solely to provide the service, host accounts, and process payments securely.';
      final findings = DeterministicClauseScanner.scan(policy);
      expect(findings.where((f) => f.severity == FindingSeverity.high), isEmpty);
      expect(
        findings.where(
          (f) => f.title.toLowerCase().contains('ad id') || f.title.toLowerCase().contains('sell'),
        ),
        isEmpty,
      );
    });

    test('Adversarial mixed-clause sentence suppresses negated sale while catching affirmative ad sharing', () {
      const mixedPolicy =
          'We do not sell personal information to data brokers, though we share Android Advertising IDs with advertising partners to measure campaigns.';
      final findings = DeterministicClauseScanner.scan(mixedPolicy);

      expect(
        findings.where((f) => f.title.toLowerCase().contains('sell')),
        isEmpty,
      );
      expect(
        findings.any(
          (f) =>
              f.category == FindingCategory.sharing &&
              f.status == EvidenceStatus.sourceMatched &&
              f.exactExcerpt.contains('Android Advertising IDs'),
        ),
        isTrue,
      );
    });

    test('Combined Ululab-style policy eliminates RMX5303 false positives while preserving true attribution finding', () {
      const ululabLikePolicy = '''
Our services do not include any third party advertising.
A masked IP address (with the fourth part hidden) is collected to infer an imprecise location.
Ululab will not sell or lease any student data for any advertising, marketing, or other purposes.
A third party attribution platform called AppsFlyer collects the Android Advertising ID in order to understand which ads shown to parents led to registered users.
''';
      final findings = DeterministicClauseScanner.scan(ululabLikePolicy);

      // Negated advertising lines must never appear in quoted findings
      expect(
        findings.any((f) => f.exactExcerpt.contains('Our services do not include')),
        isFalse,
      );
      expect(
        findings.any((f) => f.exactExcerpt.contains('will not sell or lease')),
        isFalse,
      );

      // Coarse IP disclosure must remain low severity, never HIGH background GPS
      expect(
        findings.any((f) => f.severity == FindingSeverity.high || f.title.contains('background')),
        isFalse,
      );

      // Genuine AppsFlyer advertising attribution finding must be preserved
      expect(
        findings.any(
          (f) =>
              f.category == FindingCategory.sharing &&
              f.exactExcerpt.contains('AppsFlyer collects the Android Advertising ID'),
        ),
        isTrue,
      );
    });

    test('Case 7: device identifiers and coarse IP remain distinct from AD_ID and precise GPS in PermissionComparator', () {
      const snapshot = AppPermissionSnapshot(
        packageName: 'com.example.learning',
        appName: 'Learning App',
        requestedPermissions: [
          'android.permission.ACCESS_FINE_LOCATION',
          'com.google.android.gms.permission.AD_ID',
        ],
        grantedPermissions: [
          'com.google.android.gms.permission.AD_ID',
        ],
      );

      const policy =
          'We collect device identifiers for crash diagnostics. A masked IP address is collected to infer an imprecise location. Our services do not include any third party advertising.';

      final report = PermissionComparator.compare(
        snapshot: snapshot,
        policyText: policy,
      );

      // Masked IP imprecise location must NOT falsely count as precise GPS disclosure
      final gps = report.items.firstWhere(
        (i) => i.androidPermission == 'android.permission.ACCESS_FINE_LOCATION',
      );
      expect(gps.isMentionedInPolicy, isFalse);
      expect(gps.alignmentState, PermissionAlignmentState.undisclosedInPolicy);

      // Negated third-party advertising against requested AD_ID flags explicit contradiction/undisclosed mismatch
      final adId = report.items.firstWhere(
        (i) => i.androidPermission == 'com.google.android.gms.permission.AD_ID',
      );
      expect(adId.isExplicitlyDisclaimedInPolicy, isTrue);
      expect(adId.alignmentState, PermissionAlignmentState.undisclosedInPolicy);
    });

    test('Cloud unavailable fallback summary explicitly explains fallback even when findings exist', () async {
      final coordinator = ReviewCoordinator();
      // Deterministic receipt directly verifies both empty and non-empty fallback summary messaging
      final nonEmptyFallback = coordinator.buildDeterministicLocalReceipt(
        subjectTitle: 'AppsFlyer App',
        sourceLabel: 'https://example.com/privacy',
        policyText:
            'We collect Android Advertising IDs for attribution analytics. A masked IP address infers imprecise location.',
        source: InferenceSource.offlineDeterministic,
        fallbackDiagnosticKind: ReviewDiagnosticKind.cloudUnavailableLocalFallback,
      );

      expect(nonEmptyFallback.overallState, ReviewOverallState.reviewRecommended);
      expect(
        nonEmptyFallback.diagnosticKind,
        ReviewDiagnosticKind.cloudUnavailableLocalFallback,
      );
      expect(nonEmptyFallback.summary, contains('The cloud check could not finish'));
      expect(
        nonEmptyFallback.summary,
        contains('on-device result'),
      );
    });
  });
}
