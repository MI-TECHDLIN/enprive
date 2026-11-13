/// Deterministic on-device PII redactor that replaces personal details
/// with placeholders before any text can leave the device for Firebase AI Logic
/// (protected by App Check) when on-device inference is unavailable or a policy
/// contains comprehensive details.
class PiiRedactionResult {
  final String redactedText;
  final String originalText;
  final int replacementCount;
  final Set<String> categories;

  const PiiRedactionResult({
    required this.redactedText,
    required this.originalText,
    required this.replacementCount,
    required this.categories,
  });

  bool get hadPersonalDetails => replacementCount > 0;
}

class PiiRedactor {
  static const int comprehensiveCharThreshold = 1400;
  static const int comprehensiveWordThreshold = 220;

  static final RegExp _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
  );

  static final RegExp _phonePattern = RegExp(
    r'(?:(?:\+|00)[1-9]\d{0,2}[\s.-]?)?(?:\(?\d{2,4}\)?[\s.-]?)\d{3,4}[\s.-]?\d{4}\b',
  );

  static final RegExp _ipv4Pattern = RegExp(
    r'\b(?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\b',
  );

  static final RegExp _addressPattern = RegExp(
    r'\b\d{1,5}[ \t]+[A-Z0-9][A-Za-z0-9 \t.-]{1,36}[ \t]+(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Drive|Dr|Lane|Ln|Way|Court|Ct|Terrace|Ter|Place|Pl)\.?(?:,[ \t]*[A-Za-z \t]+(?:,[ \t]*[A-Z]{2})?(?:[ \t]+\d{5}(?:-\d{4})?)?)?',
    caseSensitive: false,
  );

  static final RegExp _labeledPersonPattern = RegExp(
    r'\b((?:Child|Student|Parent|Guardian|Name|User|Account Holder|Contact)[ \t]*:[ \t]*)([A-Z][a-z]+(?:[ \t]+[A-Z][a-z]+){0,2})',
  );

  static final RegExp _labeledIdPattern = RegExp(
    r'\b((?:Student|User|Account|Device|Membership|Serial)[ \t]*(?:ID|No\.?|Number|#)[ \t]*[:#-]?[ \t]*)([A-Za-z0-9-]{4,})\b',
    caseSensitive: false,
  );

  static final RegExp _ssnPattern = RegExp(
    r'\b\d{3}-\d{2}-\d{4}\b',
  );

  /// Returns true when a policy is long or comprehensive enough to exceed
  /// typical concise on-device context windows.
  static bool isComprehensivePolicy(String text) {
    final trimmed = text.trim();
    if (trimmed.length > comprehensiveCharThreshold) return true;
    final wordCount =
        trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return wordCount > comprehensiveWordThreshold;
  }

  /// Replaces personal details deterministically with bracketed placeholders.
  static PiiRedactionResult redact(String input) {
    if (input.isEmpty) {
      return PiiRedactionResult(
        redactedText: input,
        originalText: input,
        replacementCount: 0,
        categories: const {},
      );
    }

    var text = input;
    var count = 0;
    final categories = <String>{};

    text = text.replaceAllMapped(_emailPattern, (m) {
      count++;
      categories.add('email');
      return '[EMAIL]';
    });

    text = text.replaceAllMapped(_ssnPattern, (m) {
      count++;
      categories.add('id');
      return '[ID]';
    });

    text = text.replaceAllMapped(_labeledIdPattern, (m) {
      count++;
      categories.add('id');
      return '${m.group(1)}[ID]';
    });

    text = text.replaceAllMapped(_phonePattern, (m) {
      count++;
      categories.add('phone');
      return '[PHONE]';
    });

    text = text.replaceAllMapped(_ipv4Pattern, (m) {
      count++;
      categories.add('ip_address');
      return '[IP_ADDRESS]';
    });

    text = text.replaceAllMapped(_addressPattern, (m) {
      count++;
      categories.add('address');
      return '[ADDRESS]';
    });

    text = text.replaceAllMapped(_labeledPersonPattern, (m) {
      count++;
      categories.add('person');
      return '${m.group(1)}[PERSON]';
    });

    return PiiRedactionResult(
      redactedText: text,
      originalText: input,
      replacementCount: count,
      categories: Set<String>.unmodifiable(categories),
    );
  }
}
