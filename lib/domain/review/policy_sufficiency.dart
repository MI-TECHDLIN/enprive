/// Reasons why submitted text cannot sustain a valid privacy policy review.
enum PolicyInsufficiencyReason {
  empty,
  placeholderOrUnavailable,
  notAPrivacyPolicy,
}

/// Deterministic validation outcome for submitted privacy-policy text.
class PolicySufficiencyResult {
  final bool isSufficient;
  final PolicyInsufficiencyReason? reason;
  final String explanation;

  const PolicySufficiencyResult.sufficient()
    : isSufficient = true,
      reason = null,
      explanation = '';

  const PolicySufficiencyResult.insufficient({
    required this.reason,
    required this.explanation,
  }) : isSufficient = false;
}

/// Validates whether user- or app-supplied text contains genuine, inspectable
/// privacy-policy disclosures rather than empty text, placeholder notices,
/// error pages, or unrelated prose.
///
/// Deliberately avoids arbitrary high word-count cutoffs so concise genuine
/// disclosures (e.g. "We do not sell personal data.") remain valid.
abstract final class PolicySufficiencyValidator {
  static final RegExp _letterPattern = RegExp(r'\p{L}', unicode: true);
  static final RegExp _cjkOrKanaPattern = RegExp(
    r'[\u3040-\u30ff\u4e00-\u9fff\uac00-\ud7af]',
  );

  static final List<RegExp> _placeholderPhrasePatterns = [
    RegExp(
      r'\b(privacy\s+(policy|notice|terms?)\s+(is\s+)?(currently\s+|temporarily\s+)?(unavailable|not\s+available|missing|pending|coming\s+soon|not\s+found|not\s+provided|tbd|n/a))\b',
    ),
    RegExp(
      r'\b(currently\s+unavailable|temporarily\s+unavailable|notice\s+unavailable|policy\s+unavailable|no\s+privacy\s+(policy|notice)|no\s+policy\s+(provided|available|found)|page\s+not\s+found|error\s+loading|unable\s+to\s+load|under\s+construction|coming\s+soon|to\s+be\s+determined|lorem\s+ipsum)\b',
    ),
    RegExp(
      r'\b(no\s+disponible|indisponible|nicht\s+verfügbar|nicht\s+verfugbar|não\s+disponível|nao\s+disponivel|non\s+disponibile|недоступн)\b',
    ),
  ];

  static const Set<String> _exactStubNormalized = {
    'tbd',
    'na',
    'n/a',
    'none',
    'nil',
    'null',
    'test',
    'testing',
    'quicktest',
    'quick test',
    'placeholder',
    'sample',
    'example',
    'unavailable',
    'not available',
    'coming soon',
    'no policy',
    'no privacy policy',
    'privacy notice unavailable',
    'privacy policy unavailable',
    'todo',
  };

  /// Substantive privacy / data-handling signals across supported languages.
  /// Excludes bare meta-nouns like "privacy" or "notice" alone so
  /// "Privacy notice." without actual data-handling claims cannot pass.
  static const List<String> _substantivePolicySignals = [
    // English
    'data',
    'personal information',
    'personally identifiable',
    'personal info',
    'collect',
    'collection',
    'share',
    'sharing',
    'sell',
    'sold',
    'store',
    'stored',
    'storage',
    'retain',
    'retention',
    'delete',
    'deletion',
    'erase',
    'erasure',
    'process',
    'processing',
    'disclos',
    'third part',
    'third-part',
    'partner',
    'analytics',
    'telemetry',
    'advertis',
    'track',
    'tracking',
    'cookie',
    'identifier',
    'device id',
    'ip address',
    'location',
    'gps',
    'microphone',
    'camera',
    'voice',
    'audio',
    'biometric',
    'child',
    'children',
    'minor',
    'parent',
    'consent',
    'permission',
    'encrypt',
    'usage',
    'account',
    'opt-out',
    'opt out',
    'gdpr',
    'coppa',
    'ccpa',
    'ferpa',
    'sdk',
    'broker',
    'diagnostics',
    // Spanish / French / Portuguese / Italian / German stems
    'datos',
    'recopil',
    'compart',
    'almacen',
    'terceros',
    'ubicación',
    'ubicacion',
    'consentimiento',
    'données',
    'donnees',
    'partag',
    'stock',
    'tiers',
    'localisation',
    'confidentialit',
    'dados',
    'colet',
    'compartilh',
    'armazen',
    'localiza',
    'dati',
    'raccog',
    'condivid',
    'terzi',
    'posizione',
    'daten',
    'erheb',
    'teilen',
    'speicher',
    'dritte',
    'standort',
    'einwilligung',
    // Russian / Arabic / Hindi / CJK stems
    'данных',
    'данные',
    'собира',
    'переда',
    'хран',
    'третьим',
    'местополож',
    'согласи',
    'البيانات',
    'جمع',
    'مشاركة',
    'تخزين',
    'أطراف',
    'الموقع',
    'موافقة',
    'डेटा',
    'एकत्र',
    'साझा',
    'संग्रह',
    'सहमति',
    'जानकारी',
    'データ',
    '個人情報',
    '収集',
    '共有',
    '第三者',
    '位置情報',
    '保存',
    '同意',
    '데이터',
    '개인정보',
    '수집',
    '공유',
    '제3자',
    '보관',
    '동의',
    '数据',
    '个人信息',
    '共享',
    '位置',
    '存储',
    '保留',
  ];

  static PolicySufficiencyResult assess(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const PolicySufficiencyResult.insufficient(
        reason: PolicyInsufficiencyReason.empty,
        explanation: 'No privacy policy text was supplied to inspect.',
      );
    }

    final normalized = trimmed.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final strippedPunctuation = normalized
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s/]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (_exactStubNormalized.contains(strippedPunctuation)) {
      return const PolicySufficiencyResult.insufficient(
        reason: PolicyInsufficiencyReason.placeholderOrUnavailable,
        explanation:
            'The supplied text is an unavailable notice or placeholder rather than an actual privacy policy.',
      );
    }

    final lettersCount = _letterPattern.allMatches(trimmed).length;
    final hasCjk = _cjkOrKanaPattern.hasMatch(trimmed);
    if (lettersCount < (hasCjk ? 8 : 15)) {
      return const PolicySufficiencyResult.insufficient(
        reason: PolicyInsufficiencyReason.placeholderOrUnavailable,
        explanation:
            'There was not enough readable text to form an inspectable privacy policy statement.',
      );
    }

    final signalHits = _countDistinctSignals(normalized);
    final matchesPlaceholder = _placeholderPhrasePatterns.any(
      (pattern) => pattern.hasMatch(normalized),
    );
    if (matchesPlaceholder &&
        (normalized.length <= 160 || signalHits < 2)) {
      return const PolicySufficiencyResult.insufficient(
        reason: PolicyInsufficiencyReason.placeholderOrUnavailable,
        explanation:
            'The text states that privacy terms are unavailable or not yet loaded, so no policy claims could be reviewed.',
      );
    }

    if (!hasCjk) {
      final words = strippedPunctuation
          .split(' ')
          .where((w) => w.isNotEmpty)
          .toList();
      if (words.length < 3) {
        return const PolicySufficiencyResult.insufficient(
          reason: PolicyInsufficiencyReason.notAPrivacyPolicy,
          explanation:
              'A standalone label or fragment cannot be verified as a privacy disclosure.',
        );
      }
    }

    if (signalHits == 0) {
      return const PolicySufficiencyResult.insufficient(
        reason: PolicyInsufficiencyReason.notAPrivacyPolicy,
        explanation:
            'This text does not appear to contain data-collection, sharing, storage, permission, or retention disclosures.',
      );
    }

    return const PolicySufficiencyResult.sufficient();
  }

  static int _countDistinctSignals(String lowerNormalizedText) {
    var count = 0;
    for (final signal in _substantivePolicySignals) {
      final isAsciiWord = RegExp(r'^[a-z][a-z\s-]*$').hasMatch(signal);
      if (isAsciiWord) {
        // Require word boundary at the start (allow inflected suffixes like "collects", "collected", "advertising", "third parties").
        final escaped = RegExp.escape(signal);
        if (RegExp('(?:^|[^a-z])$escaped').hasMatch(lowerNormalizedText)) {
          count++;
        }
      } else if (lowerNormalizedText.contains(signal)) {
        count++;
      }
      if (count >= 3) break;
    }
    return count;
  }
}
