import 'package:flutter_test/flutter_test.dart';
import 'package:enprive/domain/evidence/evidence_validator.dart';

void main() {
  group('EvidenceValidator Quote Alignment Tests', () {
    const policySnapshot = '''
      EduTrack Privacy Notice.
      We do not sell your personal information to third parties.
      However, we may share precise location data with advertising partners for targeted advertising purposes.
      Users may request deletion of their account data at any time by contacting privacy@edutrack.fake.
    ''';

    test('verifies exact quote matches in snapshot', () {
      const quote = 'share precise location data with advertising partners';
      final result = EvidenceValidator.verifyQuoteAlignment(
        quote: quote,
        snapshotText: policySnapshot,
      );
      expect(result, isTrue);
    });

    test('verifies quote matches across normalized whitespaces and smart quotes', () {
      const quote = '“share precise   location data with advertising partners”';
      final result = EvidenceValidator.verifyQuoteAlignment(
        quote: quote,
        snapshotText: policySnapshot,
      );
      expect(result, isTrue);
    });

    test('rejects fabricated or hallucinated quote', () {
      const quote = 'We will always sell your data to whoever pays the most.';
      final result = EvidenceValidator.verifyQuoteAlignment(
        quote: quote,
        snapshotText: policySnapshot,
      );
      expect(result, isFalse);
    });

    test('marks finding as SOURCE_MATCHED when excerpt aligns', () {
      final rawFinding = {
        'finding_id': 'f-01',
        'claim': 'App shares precise location with advertisers',
        'exact_excerpt': 'share precise location data with advertising partners',
        'evidence_refs': ['ev-01'],
      };

      final validated = EvidenceValidator.validateFinding(
        rawFinding: rawFinding,
        snapshotText: policySnapshot,
        validEvidenceIds: {'ev-01'},
      );

      expect(validated['status'], 'SOURCE_MATCHED');
    });

    test('marks finding as UNVERIFIED when excerpt fails to align', () {
      final rawFinding = {
        'finding_id': 'f-02',
        'claim': 'App steals passwords and credit cards',
        'exact_excerpt': 'We secretly harvest your bank passwords',
        'evidence_refs': ['ev-02'],
      };

      final validated = EvidenceValidator.validateFinding(
        rawFinding: rawFinding,
        snapshotText: policySnapshot,
        validEvidenceIds: {'ev-02'},
      );

      expect(validated['status'], 'UNVERIFIED');
      expect((validated['unknowns'] as List).first, contains('could not be matched'));
    });
  });
}
