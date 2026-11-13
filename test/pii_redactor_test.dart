import 'package:flutter_test/flutter_test.dart';
import 'package:enprive/domain/privacy/pii_redactor.dart';

void main() {
  group('PiiRedactor Tests', () {
    test('replaces emails, phones, IPs, addresses, IDs, and labeled names with placeholders', () {
      const sample = '''
Parent: Sarah Kim
Student ID: STU-90421
Contact support@edutrack.edu or call (415) 555-0142.
Server log from 192.168.1.45 at 742 Evergreen Terrace.
''';

      final result = PiiRedactor.redact(sample);
      expect(result.hadPersonalDetails, isTrue);
      expect(result.replacementCount, greaterThanOrEqualTo(5));

      expect(result.redactedText, contains('Parent: [PERSON]'));
      expect(result.redactedText, contains('Student ID: [ID]'));
      expect(result.redactedText, contains('[EMAIL]'));
      expect(result.redactedText, contains('[PHONE]'));
      expect(result.redactedText, contains('[IP_ADDRESS]'));
      expect(result.redactedText, contains('[ADDRESS]'));

      expect(result.redactedText, isNot(contains('Sarah Kim')));
      expect(result.redactedText, isNot(contains('STU-90421')));
      expect(result.redactedText, isNot(contains('support@edutrack.edu')));
      expect(result.redactedText, isNot(contains('555-0142')));
      expect(result.redactedText, isNot(contains('192.168.1.45')));
      expect(result.redactedText, isNot(contains('742 Evergreen Terrace')));
    });

    test('identifies comprehensive policies above concise on-device threshold', () {
      const shortPolicy = 'We do not collect student location data or ads.';
      final comprehensivePolicy =
          'This comprehensive children privacy policy covers every regional district. ' *
              30;

      expect(PiiRedactor.isComprehensivePolicy(shortPolicy), isFalse);
      expect(PiiRedactor.isComprehensivePolicy(comprehensivePolicy), isTrue);
    });
  });
}
