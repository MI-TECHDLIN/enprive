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

    test('P0-C: preserves ordinary "device identifiers" prose while redacting labeled IDs', () {
      const ordinary =
          'We collect device identifiers, account settings, and a device ID that stays local.';
      final ordinaryResult = PiiRedactor.redact(ordinary);
      expect(ordinaryResult.redactedText, equals(ordinary));
      expect(ordinaryResult.redactedText, isNot(contains('[ID]')));
      expect(ordinaryResult.hadPersonalDetails, isFalse);

      const labeled =
          'Device ID: 12345, session id: abc123, Student ID: STU-90421, User ID: 987654.';
      final labeledResult = PiiRedactor.redact(labeled);
      expect(labeledResult.hadPersonalDetails, isTrue);
      expect(labeledResult.redactedText, contains('Device ID: [ID]'));
      expect(labeledResult.redactedText, contains('session id: [ID]'));
      expect(labeledResult.redactedText, contains('Student ID: [ID]'));
      expect(labeledResult.redactedText, contains('User ID: [ID]'));
      expect(labeledResult.redactedText, isNot(contains('12345')));
      expect(labeledResult.redactedText, isNot(contains('abc123')));
      expect(labeledResult.redactedText, isNot(contains('STU-90421')));
      expect(labeledResult.redactedText, isNot(contains('987654')));
    });
  });
}
