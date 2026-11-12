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
    final excerpt = copy['exact_excerpt'] as String? ?? '';
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
}
