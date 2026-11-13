/// Deterministic Evidence Validator.
/// Enforces 100% quotation alignment against raw policy snapshots,
/// validates evidence IDs, and rejects ungrounded or fabricated claims.
class EvidenceValidator {
  /// Normalizes whitespace and basic unicode punctuation for fair substring comparison.
  static String normalize(String input) {
    var s = input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .trim();
    // Strip wrapping quotes if user or AI wrapped the excerpt
    if (s.length >= 2 &&
        ((s.startsWith('"') && s.endsWith('"')) ||
            (s.startsWith("'") && s.endsWith("'")))) {
      s = s.substring(1, s.length - 1).trim();
    }
    return s;
  }

  /// Verifies if [quote] exists verbatim (after whitespace normalization)
  /// in the captured [snapshotText].
  static bool verifyQuoteAlignment({
    required String quote,
    required String snapshotText,
  }) {
    if (quote.trim().isEmpty) return false;
    final normalizedQuote = normalize(quote);
    final normalizedSnapshot = normalize(snapshotText);
    return normalizedSnapshot.contains(normalizedQuote);
  }

  /// Validates a raw finding map from AI against local snapshot text.
  /// If the quote cannot be matched to the snapshot, the finding is marked unverified
  /// or suppressed to prevent hallucinated citations.
  static Map<String, dynamic> validateFinding({
    required Map<String, dynamic> rawFinding,
    required String? snapshotText,
    required Set<String> validEvidenceIds,
  }) {
    final copy = Map<String, dynamic>.from(rawFinding);
    final excerpt =
        (copy['exact_excerpt'] as String?) ?? (copy['quote'] as String?) ?? '';
    final evidenceRefs = (copy['evidence_refs'] as List?)?.cast<String>() ?? [];

    // Check evidence ID existence
    final hasValidEvidenceId = evidenceRefs.any(validEvidenceIds.contains);

    // If there is an excerpt and a snapshot, verify alignment
    if (snapshotText != null && excerpt.isNotEmpty) {
      final isAligned = verifyQuoteAlignment(
        quote: excerpt,
        snapshotText: snapshotText,
      );

      if (isAligned) {
        copy['status'] = 'SOURCE_MATCHED';
      } else {
        copy['status'] = 'UNVERIFIED';
        copy['unknowns'] = [
          ...?copy['unknowns'] as List?,
          'Quoted excerpt could not be matched to the captured policy snapshot.',
        ];
      }
    } else if (hasValidEvidenceId) {
      copy['status'] = copy['status'] ?? 'INTERPRETATION';
    } else {
      copy['status'] = 'UNVERIFIED';
    }

    return copy;
  }

  /// Extracts a surrounding context window (`before`, `matched`, `after`) from
  /// the normalized [snapshotText] so the UI can highlight the verbatim quote
  /// inside its surrounding paragraph.
  static ({String before, String matched, String after})? extractContextWindow({
    required String quote,
    required String snapshotText,
    int radius = 85,
  }) {
    if (quote.trim().isEmpty || snapshotText.trim().isEmpty) return null;
    final normQuote = normalize(quote);
    final normSnapshot = normalize(snapshotText);
    final idx = normSnapshot.indexOf(normQuote);
    if (idx < 0) return null;

    final start = (idx - radius).clamp(0, idx);
    final end = (idx + normQuote.length + radius).clamp(
      idx + normQuote.length,
      normSnapshot.length,
    );

    final prefix = start > 0 ? '…' : '';
    final suffix = end < normSnapshot.length ? '…' : '';

    return (
      before: '$prefix${normSnapshot.substring(start, idx)}',
      matched: normSnapshot.substring(idx, idx + normQuote.length),
      after: '${normSnapshot.substring(idx + normQuote.length, end)}$suffix',
    );
  }

  /// Computes a deterministic 64-bit FNV-1a hex digest of the normalized policy
  /// snapshot so receipts and findings can verify whether the policy changed.
  static String computeSnapshotDigest(String snapshotText) {
    final normalized = normalize(snapshotText);
    int hash1 = 0x811c9dc5;
    int hash2 = 0x811c9dc5;
    for (int i = 0; i < normalized.length; i++) {
      final code = normalized.codeUnitAt(i);
      if (i.isEven) {
        hash1 ^= code;
        hash1 = (hash1 * 0x01000193) & 0xFFFFFFFF;
      } else {
        hash2 ^= code;
        hash2 = (hash2 * 0x01000193) & 0xFFFFFFFF;
      }
    }
    return '${hash1.toRadixString(16).padLeft(8, '0')}'
        '${hash2.toRadixString(16).padLeft(8, '0')}';
  }
}
