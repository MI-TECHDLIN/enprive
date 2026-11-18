import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/app_policy_association.dart';
import 'package:enprive/services/platform/companion_bridge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPolicyAssociationEvaluator', () {
    test('1. returns unlinked when no app identity is provided', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          policyText: 'Privacy policy for Focus Reader (com.example.focusreader).',
          policyUrl: 'https://example.com/privacy',
        ),
      );

      expect(report.state, AppPolicyAssociationState.unlinked);
      expect(report.provesDeveloperOwnership, isFalse);
      expect(report.hasPositiveReference, isFalse);
    });

    test('2. returns unlinked when app is selected without policy text or URL', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText: '   ',
          policyUrl: '',
        ),
      );

      expect(report.state, AppPolicyAssociationState.unlinked);
      expect(report.provesDeveloperOwnership, isFalse);
      expect(report.selectedPackageName, 'com.example.focusreader');
    });

    test('3. returns userLinkedUnverified for URL-only generic link', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyUrl: 'https://acmecorp.com/privacy',
        ),
      );

      expect(report.state, AppPolicyAssociationState.userLinkedUnverified);
      expect(report.urlHostMatched, isFalse);
      expect(report.matchSources, isEmpty);
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('4. returns userLinkedUnverified for generic studio policy prose', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Acorn Labs Privacy Policy. We collect crash diagnostics and '
              'device metrics across our mobile services. Visit acmelabs.org.',
        ),
      );

      expect(report.state, AppPolicyAssociationState.userLinkedUnverified);
      expect(report.conflictingPackageIdentifiers, isEmpty);
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('5. returns packageIdentifierMentioned when exact package appears in prose', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'This privacy notice applies to COM.EXAMPLE.FOCUSREADER.',
        ),
      );

      expect(report.state, AppPolicyAssociationState.packageIdentifierMentioned);
      expect(report.matchSources, <AssociationMatchSource>[
        AssociationMatchSource.policyText,
      ]);
      expect(report.matchedIdentifiers, <String>['com.example.focusreader']);
      expect(report.hasPositiveReference, isTrue);
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('6. detects package identifier in ?id= query param without claiming prose match', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyUrl:
              'https://play.google.com/store/apps/details?id=com.example.focusreader&hl=en',
        ),
      );

      expect(report.state, AppPolicyAssociationState.packageIdentifierMentioned);
      expect(report.matchSources, <AssociationMatchSource>[
        AssociationMatchSource.policyUrl,
      ]);
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('7. rejects substring package variants strictly', () {
      final proVariant = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.app',
          appName: 'Sample Tool',
          policyText: 'Privacy Policy covering com.example.app.pro only.',
        ),
      );
      expect(proVariant.state, isNot(AppPolicyAssociationState.packageIdentifierMentioned));
      expect(proVariant.state, AppPolicyAssociationState.unmatched);
      expect(proVariant.conflictingPackageIdentifiers, <String>['com.example.app.pro']);

      final numericSuffix = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.app',
          appName: 'Sample Tool',
          policyText: 'Privacy Policy covering com.example.app2.',
        ),
      );
      expect(numericSuffix.state, AppPolicyAssociationState.unmatched);
      expect(numericSuffix.conflictingPackageIdentifiers, <String>['com.example.app2']);

      final prefixedVariant = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.app',
          appName: 'Sample Tool',
          policyText: 'Privacy Policy covering mycom.example.app.',
        ),
      );
      expect(prefixedVariant.state, AppPolicyAssociationState.userLinkedUnverified);

      final hyphenatedVariant = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.app',
          appName: 'Sample Tool',
          policyText: 'Privacy Policy covering com.example.app-beta.',
        ),
      );
      expect(hyphenatedVariant.state, AppPolicyAssociationState.userLinkedUnverified);
    });

    test('8. returns appNameMentioned for distinctive name prose mentions', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              "Focus Reader's offline reading mode stores bookmarks locally.",
        ),
      );

      expect(report.state, AppPolicyAssociationState.appNameMentioned);
      expect(report.matchSources, <AssociationMatchSource>[
        AssociationMatchSource.policyText,
      ]);
      expect(report.matchedIdentifiers, <String>['Focus Reader']);
      expect(report.provesDeveloperOwnership, isFalse);

      final camelReport = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText: 'FocusReader does not sell user data.',
        ),
      );
      expect(camelReport.state, AppPolicyAssociationState.appNameMentioned);

      for (final variant in const <String>[
        'FOCUS-READER! Privacy Notice.',
        'Official notice for Focus: Reader (2026 edition).',
      ]) {
        final normalizedReport = AppPolicyAssociationEvaluator.evaluate(
          AppPolicyAssociationInput(
            packageName: 'com.example.focusreader',
            appName: 'Focus Reader',
            policyText: variant,
          ),
        );
        expect(
          normalizedReport.state,
          AppPolicyAssociationState.appNameMentioned,
          reason: 'Expected case/punctuation match for "$variant"',
        );
      }
    });

    test('9. folds Latin diacritics and supports CJK/Hangul short tokens', () {
      final cafeReport = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.cafenotes',
          appName: 'Café Notes',
          policyText: 'Cafe Notes stores your recipes locally on your device.',
        ),
      );
      expect(cafeReport.state, AppPolicyAssociationState.appNameMentioned);

      final hangulReport = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'kr.example.study',
          appName: '학습노트',
          policyText: '학습노트 개인정보처리방침 안내입니다.',
        ),
      );
      expect(hangulReport.state, AppPolicyAssociationState.appNameMentioned);

      final cjkReport = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'jp.example.kanji',
          appName: '学習',
          policyText: '学習アプリのプライバシーポリシーです。',
        ),
      );
      expect(cjkReport.state, AppPolicyAssociationState.appNameMentioned);
    });

    test('10. ignores stopword-only generic app names unless a conflicting package appears', () {
      for (final genericName in const <String>[
        'Free Mobile App',
        'My Games',
        'Kids Study App',
      ]) {
        final neutral = AppPolicyAssociationEvaluator.evaluate(
          AppPolicyAssociationInput(
            packageName: 'com.example.generic',
            appName: genericName,
            policyText:
                '$genericName collects crash logs to keep your app working.',
          ),
        );
        expect(
          neutral.state,
          AppPolicyAssociationState.userLinkedUnverified,
          reason: '$genericName must not elevate on generic stopwords alone',
        );

        final conflicting = AppPolicyAssociationEvaluator.evaluate(
          AppPolicyAssociationInput(
            packageName: 'com.example.generic',
            appName: genericName,
            policyText:
                '$genericName policy also applies to com.other.unrelated.',
          ),
        );
        expect(
          conflicting.state,
          AppPolicyAssociationState.unmatched,
          reason: 'Conflicting package ID still produces unmatched',
        );
      }
    });

    test('11. separates URL host hints from policy text and rejects unrelated hostnames', () {
      final unrelatedA = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyUrl: 'https://focusreading.example.com/privacy',
          policyText:
              'Email support@focus.example.com or visit https://docs.example.com. '
              'We collect telemetry.',
        ),
      );
      expect(unrelatedA.state, AppPolicyAssociationState.userLinkedUnverified);
      expect(unrelatedA.urlHostMatched, isFalse);
      expect(unrelatedA.conflictingPackageIdentifiers, isEmpty);

      final unrelatedB = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyUrl: 'https://myfocusreader-review.net/privacy',
          policyText: 'We collect anonymous usage metrics.',
        ),
      );
      expect(unrelatedB.state, AppPolicyAssociationState.userLinkedUnverified);
      expect(unrelatedB.urlHostMatched, isFalse);

      final matchingHostWithoutProseMention =
          AppPolicyAssociationEvaluator.evaluate(
            const AppPolicyAssociationInput(
              packageName: 'com.example.focusreader',
              appName: 'Focus Reader',
              policyUrl: 'https://focusreader.example.com/privacy',
              policyText: 'We do not sell user information.',
            ),
          );
      expect(
        matchingHostWithoutProseMention.state,
        AppPolicyAssociationState.userLinkedUnverified,
      );
      expect(matchingHostWithoutProseMention.urlHostMatched, isTrue);
    });

    test('12. returns unmatched when competing package ID appears without selected match', () {
      final fromProse = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Privacy Policy for NightTracker (org.nighttracker.monitor).',
        ),
      );
      expect(fromProse.state, AppPolicyAssociationState.unmatched);
      expect(
        fromProse.conflictingPackageIdentifiers,
        <String>['org.nighttracker.monitor'],
      );

      final fromQuery = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyUrl:
              'https://play.google.com/store/apps/details?id=com.other.game',
        ),
      );
      expect(fromQuery.state, AppPolicyAssociationState.unmatched);
      expect(
        fromQuery.conflictingPackageIdentifiers,
        <String>['com.other.game'],
      );
    });

    test('13. returns ambiguousIdentity when selected package and another package both appear', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Shared policy covering com.example.focusreader and com.other.addon.',
        ),
      );

      expect(report.state, AppPolicyAssociationState.ambiguousIdentity);
      expect(report.matchedIdentifiers, contains('com.example.focusreader'));
      expect(
        report.conflictingPackageIdentifiers,
        <String>['com.other.addon'],
      );
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('14. returns ambiguousIdentity when app name matches alongside a competing package ID', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Focus Reader Privacy Notice. Package ID: com.rival.focusreader.',
        ),
      );

      expect(report.state, AppPolicyAssociationState.ambiguousIdentity);
      expect(report.matchedIdentifiers, contains('Focus Reader'));
      expect(
        report.conflictingPackageIdentifiers,
        <String>['com.rival.focusreader'],
      );
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('15. recognizes sample fixtures strictly via trusted metadata and rejects forged text', () {
      final eduDemoReport = AppPolicyAssociationEvaluator.evaluate(
        AppPolicyAssociationInput(
          packageName: PermissionComparator.demoEduTrackSnapshot.packageName,
          appName: PermissionComparator.demoEduTrackSnapshot.appName,
          policyText: 'Built-in EduTrack demo text.',
          sampleFixture: TrustedSampleFixture.eduTrackDemo,
        ),
      );
      expect(eduDemoReport.state, AppPolicyAssociationState.sampleFixture);
      expect(eduDemoReport.sampleFixture, TrustedSampleFixture.eduTrackDemo);
      expect(eduDemoReport.matchSources, <AssociationMatchSource>[
        AssociationMatchSource.sampleFixture,
      ]);
      expect(eduDemoReport.provesDeveloperOwnership, isFalse);

      // Untrusted policy text claiming a demo package ID must NOT become sampleFixture.
      final forgedReport = AppPolicyAssociationEvaluator.evaluate(
        AppPolicyAssociationInput(
          packageName: PermissionComparator.demoCalmMathSnapshot.packageName,
          appName: PermissionComparator.demoCalmMathSnapshot.appName,
          policyText:
              'Official sample fixture: ${PermissionComparator.demoCalmMathSnapshot.packageName}',
        ),
      );
      expect(forgedReport.state, isNot(AppPolicyAssociationState.sampleFixture));
      expect(
        forgedReport.state,
        AppPolicyAssociationState.packageIdentifierMentioned,
      );

      // Mismatched fixture metadata paired with another package does not emit sampleFixture.
      final mismatchedFixture = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.unrelated.realapp',
          appName: 'Real App',
          policyText: 'Real App privacy notice.',
          sampleFixture: TrustedSampleFixture.eduTrackDemo,
        ),
      );
      expect(
        mismatchedFixture.state,
        isNot(AppPolicyAssociationState.sampleFixture),
      );
      expect(
        mismatchedFixture.state,
        AppPolicyAssociationState.appNameMentioned,
      );
    });

    test('16. enforces non-ownership invariant, omits raw text, and round-trips JSON deterministically', () {
      final inputs = <AppPolicyAssociationInput>[
        const AppPolicyAssociationInput(),
        const AppPolicyAssociationInput(
          packageName: 'com.example.a',
          appName: 'Alpha Notes',
          policyUrl: 'https://example.org/privacy',
        ),
        const AppPolicyAssociationInput(
          packageName: 'com.example.a',
          appName: 'Alpha Notes',
          policyText: 'Notice for com.example.a.',
        ),
        const AppPolicyAssociationInput(
          packageName: 'com.example.a',
          appName: 'Alpha Notes',
          policyText: 'Alpha Notes collects minimal crash logs.',
        ),
        const AppPolicyAssociationInput(
          packageName: 'com.example.a',
          appName: 'Alpha Notes',
          policyText: 'Applies strictly to com.other.beta.',
        ),
        const AppPolicyAssociationInput(
          packageName: 'com.example.a',
          appName: 'Alpha Notes',
          policyText: 'Alpha Notes and com.other.beta.',
        ),
        AppPolicyAssociationInput(
          packageName: PermissionComparator.demoEduTrackSnapshot.packageName,
          appName: PermissionComparator.demoEduTrackSnapshot.appName,
          sampleFixture: TrustedSampleFixture.eduTrackDemo,
        ),
      ];

      final reports = inputs.map(AppPolicyAssociationEvaluator.evaluate).toList();
      expect(
        reports.map((r) => r.state).toSet(),
        AppPolicyAssociationState.values.toSet(),
      );

      for (final report in reports) {
        expect(report.provesDeveloperOwnership, isFalse);
        expect(report.ownershipLimitationNotice, isNotEmpty);
        expect(
          () => report.matchedIdentifiers.add('tamper'),
          throwsUnsupportedError,
        );
        expect(
          () => report.conflictingPackageIdentifiers.add('tamper'),
          throwsUnsupportedError,
        );

        final encoded = report.toJson();
        expect(encoded.containsKey('policyText'), isFalse);
        expect(encoded.containsKey('permissions'), isFalse);
        expect(encoded['provesDeveloperOwnership'], isFalse);

        final decoded = AppPolicyAssociationReport.fromJson(encoded);
        expect(decoded.state, report.state);
        expect(decoded.selectedPackageName, report.selectedPackageName);
        expect(decoded.selectedAppName, report.selectedAppName);
        expect(decoded.matchSources, report.matchSources);
        expect(decoded.matchedIdentifiers, report.matchedIdentifiers);
        expect(
          decoded.conflictingPackageIdentifiers,
          report.conflictingPackageIdentifiers,
        );
        expect(decoded.urlHostMatched, report.urlHostMatched);
        expect(decoded.sampleFixture, report.sampleFixture);
        expect(decoded.provesDeveloperOwnership, isFalse);
      }

      // Deterministic across repeated identical evaluations (evaluatedAt omitted -> null).
      final first = AppPolicyAssociationEvaluator.evaluate(inputs[3]);
      final second = AppPolicyAssociationEvaluator.evaluate(inputs[3]);
      expect(first.evaluatedAt, isNull);
      expect(first.toJson(), second.toJson());

      // Caller-supplied timestamp round-trips deterministically in UTC.
      final stampedAt = DateTime.utc(2026, 11, 18, 21, 30, 0);
      final stampedReport = AppPolicyAssociationEvaluator.evaluate(
        AppPolicyAssociationInput(
          packageName: 'com.example.a',
          appName: 'Alpha Notes',
          policyText: 'Alpha Notes stores notes locally.',
          evaluatedAt: stampedAt,
        ),
      );
      final stampedDecoded = AppPolicyAssociationReport.fromJson(
        stampedReport.toJson(),
      );
      expect(stampedDecoded.evaluatedAt, stampedAt);
      expect(stampedDecoded.provesDeveloperOwnership, isFalse);
    });

    test('17. flags ambiguousIdentity when two installed apps share similar display names unless package ID disambiguates', () {
      const candidates = <AppIdentityCandidate>[
        AppIdentityCandidate(
          packageName: 'com.alpha.focusreader',
          appName: 'Focus Reader',
        ),
        AppIdentityCandidate(
          packageName: 'com.beta.focusreader',
          appName: 'Focus Reader Pro',
        ),
      ];

      final nameOnlyAmbiguous = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.alpha.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Focus Reader Privacy Notice. We collect anonymous diagnostics.',
          candidateApps: candidates,
        ),
      );

      expect(
        nameOnlyAmbiguous.state,
        AppPolicyAssociationState.ambiguousIdentity,
      );
      expect(
        nameOnlyAmbiguous.ambiguousCandidatePackages,
        <String>['com.beta.focusreader'],
      );
      expect(nameOnlyAmbiguous.provesDeveloperOwnership, isFalse);

      final roundTripped = AppPolicyAssociationReport.fromJson(
        nameOnlyAmbiguous.toJson(),
      );
      expect(
        roundTripped.ambiguousCandidatePackages,
        <String>['com.beta.focusreader'],
      );

      final packageDisambiguated = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.alpha.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Focus Reader (com.alpha.focusreader) Privacy Notice.',
          candidateApps: candidates,
        ),
      );

      expect(
        packageDisambiguated.state,
        AppPolicyAssociationState.packageIdentifierMentioned,
      );
      expect(packageDisambiguated.ambiguousCandidatePackages, isEmpty);
      expect(packageDisambiguated.provesDeveloperOwnership, isFalse);
    });
  });

  group('P2-1 Trusted fixture deserialization hardening', () {
    test('18. valid registered fixture round-trips cleanly', () {
      for (final entry in <(String, String, TrustedSampleFixture)>[
        (
          PermissionComparator.demoEduTrackSnapshot.packageName,
          PermissionComparator.demoEduTrackSnapshot.appName,
          TrustedSampleFixture.eduTrackDemo,
        ),
        (
          PermissionComparator.demoCalmMathSnapshot.packageName,
          PermissionComparator.demoCalmMathSnapshot.appName,
          TrustedSampleFixture.calmMathDemo,
        ),
      ]) {
        final report = AppPolicyAssociationEvaluator.evaluate(
          AppPolicyAssociationInput(
            packageName: entry.$1,
            appName: entry.$2,
            sampleFixture: entry.$3,
          ),
        );
        final decoded = AppPolicyAssociationReport.fromJson(report.toJson());
        expect(decoded.state, AppPolicyAssociationState.sampleFixture);
        expect(decoded.sampleFixture, entry.$3);
        expect(decoded.selectedPackageName, entry.$1);
        expect(decoded.matchSources, <AssociationMatchSource>[
          AssociationMatchSource.sampleFixture,
        ]);
        expect(decoded.provesDeveloperOwnership, isFalse);
      }
    });

    test('19. missing sampleFixtureId degrades sampleFixture without throwing', () {
      final decoded = AppPolicyAssociationReport.fromJson(<String, dynamic>{
        'state': 'sampleFixture',
        'selectedPackageName': 'com.edutrack.classroom.demo',
        'matchSources': <String>['sampleFixture'],
        'matchedIdentifiers': <String>['com.edutrack.classroom.demo'],
        'provesDeveloperOwnership': true,
      });

      expect(decoded.state, AppPolicyAssociationState.userLinkedUnverified);
      expect(decoded.sampleFixture, isNull);
      expect(decoded.matchSources, isEmpty);
      expect(decoded.matchedIdentifiers, isEmpty);
      expect(decoded.provesDeveloperOwnership, isFalse);
    });

    test('20. unknown sampleFixtureId degrades sampleFixture to userLinkedUnverified', () {
      final decoded = AppPolicyAssociationReport.fromJson(<String, dynamic>{
        'state': 'sampleFixture',
        'sampleFixtureId': 'forged_external_demo',
        'selectedPackageName': 'com.edutrack.classroom.demo',
        'matchSources': <String>['sampleFixture'],
      });

      expect(decoded.state, AppPolicyAssociationState.userLinkedUnverified);
      expect(decoded.sampleFixture, isNull);
      expect(decoded.matchSources, isEmpty);
      expect(decoded.provesDeveloperOwnership, isFalse);
    });

    test('21. package mismatch against registered fixture degrades safely', () {
      final mismatchedPkg = AppPolicyAssociationReport.fromJson(<String, dynamic>{
        'state': 'sampleFixture',
        'sampleFixtureId': 'edutrack_demo',
        'selectedPackageName': 'com.other.unrelated',
        'matchSources': <String>['sampleFixture'],
      });
      expect(
        mismatchedPkg.state,
        AppPolicyAssociationState.userLinkedUnverified,
      );
      expect(mismatchedPkg.sampleFixture, isNull);
      expect(mismatchedPkg.provesDeveloperOwnership, isFalse);

      final missingPkg = AppPolicyAssociationReport.fromJson(<String, dynamic>{
        'state': 'sampleFixture',
        'sampleFixtureId': 'calmmath_demo',
      });
      expect(missingPkg.state, AppPolicyAssociationState.userLinkedUnverified);
      expect(missingPkg.sampleFixture, isNull);
      expect(missingPkg.provesDeveloperOwnership, isFalse);
    });

    test('22. malformed fixture JSON degrades without throwing', () {
      final decoded = AppPolicyAssociationReport.fromJson(<String, dynamic>{
        'state': 123,
        'sampleFixtureId': 42,
        'selectedPackageName': <String>['bad'],
        'matchSources': 'sampleFixture',
        'matchedIdentifiers': <Object?>[null, ''],
        'conflictingPackageIdentifiers': 'invalid',
        'ambiguousCandidatePackages': 99,
        'provesDeveloperOwnership': true,
      });

      expect(decoded.state, AppPolicyAssociationState.userLinkedUnverified);
      expect(decoded.sampleFixture, isNull);
      expect(decoded.matchSources, isEmpty);
      expect(decoded.matchedIdentifiers, isEmpty);
      expect(decoded.provesDeveloperOwnership, isFalse);
    });

    test('23. non-fixture states preserve serialization and strip stray fixture claims', () {
      for (final state in AppPolicyAssociationState.values) {
        if (state == AppPolicyAssociationState.sampleFixture) continue;
        final decoded = AppPolicyAssociationReport.fromJson(<String, dynamic>{
          'state': state.name,
          'selectedPackageName': 'com.example.focusreader',
          'selectedAppName': 'Focus Reader',
          'sampleFixtureId': 'edutrack_demo',
          'matchSources': <String>['policyText', 'sampleFixture'],
          'matchedIdentifiers': <String>['com.example.focusreader'],
          'conflictingPackageIdentifiers':
              state == AppPolicyAssociationState.unmatched ||
                  state == AppPolicyAssociationState.ambiguousIdentity
              ? <String>['com.other.app']
              : <String>[],
          'explanation': 'Preserved explanation for ${state.name}.',
        });

        expect(decoded.state, state);
        expect(decoded.sampleFixture, isNull);
        expect(
          decoded.matchSources.contains(AssociationMatchSource.sampleFixture),
          isFalse,
        );
        expect(decoded.matchSources, <AssociationMatchSource>[
          AssociationMatchSource.policyText,
        ]);
        expect(decoded.explanation, 'Preserved explanation for ${state.name}.');
        expect(decoded.provesDeveloperOwnership, isFalse);
      }
    });
  });

  group('P2-2 Embedded policy URLs & provenance hardening', () {
    test('24. embedded Play Store URL with exact selected package records policyText only', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Store page: https://play.google.com/store/apps/details?id=com.example.focusreader',
        ),
      );

      expect(report.state, AppPolicyAssociationState.packageIdentifierMentioned);
      expect(report.matchSources, <AssociationMatchSource>[
        AssociationMatchSource.policyText,
      ]);
      expect(
        report.matchSources.contains(AssociationMatchSource.policyUrl),
        isFalse,
      );
      expect(report.matchedIdentifiers, <String>['com.example.focusreader']);
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('25. embedded URL followed by a period strips trailing period cleanly', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Details live at https://play.google.com/store/apps/details?id=com.example.focusreader.',
        ),
      );

      expect(report.state, AppPolicyAssociationState.packageIdentifierMentioned);
      expect(report.matchSources, <AssociationMatchSource>[
        AssociationMatchSource.policyText,
      ]);
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('26. embedded URL followed by a comma strips trailing comma cleanly', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'See https://play.google.com/store/apps/details?id=com.example.focusreader, for listing terms.',
        ),
      );

      expect(report.state, AppPolicyAssociationState.packageIdentifierMentioned);
      expect(report.matchSources, <AssociationMatchSource>[
        AssociationMatchSource.policyText,
      ]);
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('27. canonical policyUrl match stays distinct from embedded prose URL match', () {
      final canonicalOnly = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyUrl:
              'https://play.google.com/store/apps/details?id=com.example.focusreader',
        ),
      );
      expect(
        canonicalOnly.state,
        AppPolicyAssociationState.packageIdentifierMentioned,
      );
      expect(canonicalOnly.matchSources, <AssociationMatchSource>[
        AssociationMatchSource.policyUrl,
      ]);

      final embeddedAndCanonical = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Listing: https://play.google.com/store/apps/details?id=com.example.focusreader.',
          policyUrl:
              'https://play.google.com/store/apps/details?id=com.example.focusreader',
        ),
      );
      expect(
        embeddedAndCanonical.matchSources,
        <AssociationMatchSource>[
          AssociationMatchSource.policyText,
          AssociationMatchSource.policyUrl,
        ],
      );
    });

    test('28. embedded URL with another app package remains conflicting reference', () {
      final report = AppPolicyAssociationEvaluator.evaluate(
        const AppPolicyAssociationInput(
          packageName: 'com.example.focusreader',
          appName: 'Focus Reader',
          policyText:
              'Applies to https://play.google.com/store/apps/details?id=com.other.app.',
        ),
      );

      expect(report.state, AppPolicyAssociationState.unmatched);
      expect(
        report.conflictingPackageIdentifiers,
        <String>['com.other.app'],
      );
      expect(report.provesDeveloperOwnership, isFalse);
    });

    test('29. rejects partial and malformed package identifiers inside embedded URLs', () {
      for (final malformedText in const <String>[
        'Link: https://play.google.com/store/apps/details?id=com.example.focusreader.pro.',
        'Link: https://play.google.com/store/apps/details?id=com.example.focusreader-beta.',
        'Link: https://play.google.com/store/apps/details?id=com.example.focusreader..',
        'Malformed: https://?id=com.example.focusreader',
        'Malformed: http://[bad/details?id=com.example.focusreader',
      ]) {
        final report = AppPolicyAssociationEvaluator.evaluate(
          AppPolicyAssociationInput(
            packageName: 'com.example.focusreader',
            appName: 'Focus Reader',
            policyText: malformedText,
          ),
        );
        expect(
          report.state,
          isNot(AppPolicyAssociationState.packageIdentifierMentioned),
          reason: 'Should reject "$malformedText"',
        );
        expect(report.provesDeveloperOwnership, isFalse);
      }
    });
  });

  group('CompanionBridge external app helpers', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    const channel = MethodChannel('com.enprive/companion');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    late CompanionBridge bridge;
    final recordedCalls = <MethodCall>[];

    setUp(() {
      bridge = CompanionBridge();
      recordedCalls.clear();
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
    });

    test('openPlayStoreListing handles openedStore, openedWebFallback, and activityNotFound', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        recordedCalls.add(call);
        final pkg = (call.arguments as Map<dynamic, dynamic>)['packageName'];
        if (pkg == 'com.example.store') {
          return <String, Object?>{
            'status': 'opened_store',
            'packageName': pkg,
            'launchedUri': 'market://details?id=$pkg',
            'isSuccess': true,
          };
        }
        if (pkg == 'com.example.web') {
          return <String, Object?>{
            'status': 'opened_web_fallback',
            'packageName': pkg,
            'launchedUri':
                'https://play.google.com/store/apps/details?id=$pkg',
            'isSuccess': true,
          };
        }
        return <String, Object?>{
          'status': 'activity_not_found',
          'packageName': pkg,
          'guidanceTip': 'No Play Store app or web browser found.',
          'isSuccess': false,
        };
      });

      final storeResult = await bridge.openPlayStoreListing(' com.example.store ');
      expect(storeResult.status, ExternalAppNavigationStatus.openedStore);
      expect(storeResult.isSuccess, isTrue);
      expect(storeResult.launchedUri, 'market://details?id=com.example.store');

      final webResult = await bridge.openPlayStoreListing('com.example.web');
      expect(webResult.status, ExternalAppNavigationStatus.openedWebFallback);
      expect(webResult.isSuccess, isTrue);

      final missingResult = await bridge.openPlayStoreListing('com.example.missing');
      expect(
        missingResult.status,
        ExternalAppNavigationStatus.activityNotFound,
      );
      expect(missingResult.isSuccess, isFalse);
      expect(missingResult.guidanceTip, isNotEmpty);

      expect(recordedCalls.length, 3);
      expect(recordedCalls.first.method, 'openPlayStoreListing');
    });

    test('openPlayStoreListing & openAppSystemSettings reject invalid packages before platform call', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        recordedCalls.add(call);
        return <String, Object?>{'status': 'opened_store'};
      });

      final invalidStore = await bridge.openPlayStoreListing('not a package!');
      expect(invalidStore.status, ExternalAppNavigationStatus.invalidPackage);
      expect(invalidStore.isSuccess, isFalse);

      final invalidSettings = await bridge.openAppSystemSettings('singleword');
      expect(
        invalidSettings.status,
        ExternalAppNavigationStatus.invalidPackage,
      );
      expect(invalidSettings.isSuccess, isFalse);

      expect(recordedCalls, isEmpty);
    });

    test('openAppSystemSettings handles openedSettings and platform/missing errors gracefully', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        recordedCalls.add(call);
        final pkg = (call.arguments as Map<dynamic, dynamic>)['packageName'];
        if (pkg == 'com.example.ok') {
          return <String, Object?>{
            'status': 'opened_settings',
            'packageName': pkg,
            'launchedUri': 'package:$pkg',
            'isSuccess': true,
          };
        }
        throw PlatformException(code: 'LAUNCH_ERROR');
      });

      final ok = await bridge.openAppSystemSettings('com.example.ok');
      expect(ok.status, ExternalAppNavigationStatus.openedSettings);
      expect(ok.isSuccess, isTrue);
      expect(ok.launchedUri, 'package:com.example.ok');

      final platformErr = await bridge.openAppSystemSettings('com.example.err');
      expect(platformErr.status, ExternalAppNavigationStatus.failed);
      expect(platformErr.isSuccess, isFalse);

      messenger.setMockMethodCallHandler(channel, null);
      final missingPlugin = await bridge.openPlayStoreListing('com.example.ok');
      expect(missingPlugin.status, ExternalAppNavigationStatus.unavailable);
      expect(missingPlugin.isSuccess, isFalse);
    });
  });
}
