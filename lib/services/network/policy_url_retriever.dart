import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../domain/evidence/evidence_validator.dart';
import '../../domain/review/policy_sufficiency.dart';
import '../../domain/review/review_models.dart';

typedef DnsLookupFn = Future<List<InternetAddress>> Function(String host);

/// Outcome from attempting genuine public HTTP(S) privacy-policy retrieval.
class PolicyUrlRetrievalResult {
  final PolicyRetrievalStatus status;
  final String requestedUrl;
  final String? canonicalUrl;
  final List<String> redirectChain;
  final int? httpStatusCode;
  final String? mimeType;
  final DateTime retrievedAt;
  final String? extractedText;
  final PolicySourceSnapshot? sourceSnapshot;
  final PolicySufficiencyResult? sufficiencyResult;
  final String userMessage;

  const PolicyUrlRetrievalResult({
    required this.status,
    required this.requestedUrl,
    this.canonicalUrl,
    this.redirectChain = const [],
    this.httpStatusCode,
    this.mimeType,
    required this.retrievedAt,
    this.extractedText,
    this.sourceSnapshot,
    this.sufficiencyResult,
    required this.userMessage,
  });

  bool get isUsablePolicy =>
      status == PolicyRetrievalStatus.retrieved &&
      extractedText != null &&
      extractedText!.trim().isNotEmpty &&
      (sufficiencyResult?.isSufficient ?? false);
}

/// Retrieves genuine public HTTP(S) privacy policies on-device with strict
/// scheme, SSRF destination, redirect, timeout, byte-limit, content-type,
/// HTML boilerplate removal, and sufficiency protections.
class PolicyUrlRetriever {
  PolicyUrlRetriever({
    http.Client Function()? clientFactory,
    DnsLookupFn? dnsLookup,
    DateTime Function()? clock,
    this.requestTimeout = const Duration(seconds: 12),
    this.totalTimeout = const Duration(seconds: 20),
    this.maxRedirects = 5,
    this.maxResponseBytes = 2 * 1024 * 1024,
  }) : _clientFactory = clientFactory ?? http.Client.new,
       _dnsLookup = dnsLookup ?? InternetAddress.lookup,
       _clock = clock ?? DateTime.now;

  final http.Client Function() _clientFactory;
  final DnsLookupFn _dnsLookup;
  final DateTime Function() _clock;
  final Duration requestTimeout;
  final Duration totalTimeout;
  final int maxRedirects;
  final int maxResponseBytes;

  static final RegExp _httpUrlInSharePattern = RegExp(
    r'https?://[^\s<>"]+',
    caseSensitive: false,
  );

  /// Extracts a shared HTTP(S) URL when [sharedText] looks like a browser
  /// link share (bare URL or short title + URL), rather than full policy prose
  /// that merely cites a footnote link.
  static String? extractSharedUrl(String sharedText) {
    final trimmed = sharedText.trim();
    if (trimmed.isEmpty) return null;

    final matches = _httpUrlInSharePattern.allMatches(trimmed).toList();
    if (matches.length != 1) return null;

    var candidate = matches.first.group(0)!;
    while (candidate.isNotEmpty &&
        ('.,;:!?)]}\'"'.contains(candidate[candidate.length - 1]))) {
      candidate = candidate.substring(0, candidate.length - 1);
    }

    final parsed = Uri.tryParse(candidate);
    if (parsed == null ||
        (parsed.scheme != 'http' && parsed.scheme != 'https') ||
        parsed.host.trim().isEmpty) {
      return null;
    }

    final withoutUrl = trimmed
        .replaceFirst(matches.first.group(0)!, '')
        .trim();
    if (withoutUrl.isEmpty) {
      return candidate;
    }

    // Android browsers frequently share "App Privacy Policy - https://..."
    final extraWords = withoutUrl
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    if (withoutUrl.length <= 140 && extraWords <= 14) {
      return candidate;
    }
    return null;
  }

  /// Derives a clean subject title from a policy URL without falsely claiming
  /// verified ownership by an app.
  static String deriveSubjectTitle(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.host.isEmpty) return 'Policy URL';
    return uri.host.toLowerCase();
  }

  /// Validates URI syntax, public HTTP(S) scheme, unsafe hosts/IPs, and DNS
  /// resolution before any socket connection is attempted.
  Future<({Uri? uri, PolicyRetrievalStatus? errorStatus, String? message})>
  validateDestination(String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty || RegExp(r'[\r\n\t\x00-\x1f]').hasMatch(trimmed)) {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.invalidUrl,
        message: 'Enter a valid public https:// privacy policy URL.',
      );
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.invalidUrl,
        message:
            'Unsupported or malformed URL. Only public http:// or https:// privacy policy links can be inspected.',
      );
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.invalidUrl,
        message:
            'Unsupported URL scheme "$scheme:". Only public http:// and https:// URLs are allowed.',
      );
    }

    if (uri.userInfo.isNotEmpty) {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.unsafeDestination,
        message:
            'URLs containing embedded usernames or credentials are blocked for safety.',
      );
    }

    final host = uri.host.trim().toLowerCase();
    if (host.isEmpty || uri.hasPort && (uri.port <= 0 || uri.port > 65535)) {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.invalidUrl,
        message: 'URL is missing a valid public domain name.',
      );
    }

    if (_isUnsafeHostName(host)) {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.unsafeDestination,
        message:
            'Local, loopback, metadata, and private-network destinations are blocked.',
      );
    }

    final literalIp = InternetAddress.tryParse(host);
    if (literalIp != null) {
      if (_isUnsafeIpAddress(literalIp)) {
        return (
          uri: null,
          errorStatus: PolicyRetrievalStatus.unsafeDestination,
          message:
              'Private, loopback, and link-local IP addresses are blocked.',
        );
      }
      return (uri: uri, errorStatus: null, message: null);
    }

    if (_isObfuscatedNumericHost(host)) {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.unsafeDestination,
        message: 'Numeric host representations are blocked for safety.',
      );
    }

    if (!host.contains('.')) {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.unsafeDestination,
        message:
            'Single-label internal hostnames cannot be verified as public privacy policy URLs.',
      );
    }

    try {
      final resolved = await _dnsLookup(host).timeout(const Duration(seconds: 5));
      if (resolved.isEmpty) {
        return (
          uri: null,
          errorStatus: PolicyRetrievalStatus.networkError,
          message: 'Could not resolve host "$host".',
        );
      }
      for (final addr in resolved) {
        if (_isUnsafeIpAddress(addr)) {
          return (
            uri: null,
            errorStatus: PolicyRetrievalStatus.unsafeDestination,
            message:
                'Destination "$host" resolved to a non-public IP address and was blocked.',
          );
        }
      }
    } on TimeoutException {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.timeout,
        message: 'DNS lookup timed out for "$host".',
      );
    } on SocketException {
      return (
        uri: null,
        errorStatus: PolicyRetrievalStatus.networkError,
        message:
            'Network lookup failed for "$host". Check connectivity or paste the policy text manually.',
      );
    }

    return (uri: uri, errorStatus: null, message: null);
  }

  /// Fetches and extracts a public privacy-policy URL, recording redirects,
  /// canonical URL, retrieval timestamp, SHA-256 snapshot hash, and explicit
  /// app-identity limitation notes.
  Future<PolicyUrlRetrievalResult> fetchPolicy(String rawUrl) async {
    final retrievedAt = _clock().toUtc();
    final trimmedInput = rawUrl.trim();
    final initialCheck = await validateDestination(trimmedInput);
    if (initialCheck.uri == null) {
      return _failureResult(
        status: initialCheck.errorStatus ?? PolicyRetrievalStatus.invalidUrl,
        requestedUrl: trimmedInput,
        canonicalUrl: null,
        redirectChain: const [],
        retrievedAt: retrievedAt,
        message:
            initialCheck.message ??
            'Could not validate the supplied privacy policy URL.',
      );
    }

    final client = _clientFactory();
    final redirectChain = <String>[initialCheck.uri.toString()];
    var currentUri = initialCheck.uri!;
    final overallStopwatch = Stopwatch()..start();

    try {
      for (var hop = 0; hop <= maxRedirects; hop++) {
        final remaining = totalTimeout - overallStopwatch.elapsed;
        if (remaining <= Duration.zero) {
          return _failureResult(
            status: PolicyRetrievalStatus.timeout,
            requestedUrl: trimmedInput,
            canonicalUrl: currentUri.toString(),
            redirectChain: redirectChain,
            retrievedAt: retrievedAt,
            message:
                'Privacy policy retrieval timed out before the page finished loading.',
          );
        }

        final request = http.Request('GET', currentUri)
          ..followRedirects = false
          ..maxRedirects = 0
          ..headers['User-Agent'] =
              'EnprivePrivacyInspector/1.0 (On-Device Policy Verification)'
          ..headers['Accept'] =
              'text/html,application/xhtml+xml,text/plain,text/markdown;q=0.9,*/*;q=0.1'
          ..headers['Accept-Language'] = 'en-US,en;q=0.9';

        final perHopTimeout = remaining < requestTimeout
            ? remaining
            : requestTimeout;
        final streamed = await client.send(request).timeout(perHopTimeout);
        final statusCode = streamed.statusCode;

        if (_isRedirectStatus(statusCode)) {
          await streamed.stream.drain<void>().catchError((_) {});
          final location = streamed.headers['location']?.trim();
          if (location == null || location.isEmpty) {
            return _failureResult(
              status: PolicyRetrievalStatus.httpError,
              requestedUrl: trimmedInput,
              canonicalUrl: currentUri.toString(),
              redirectChain: redirectChain,
              httpStatusCode: statusCode,
              retrievedAt: retrievedAt,
              message:
                  'Server returned a redirect ($statusCode) without a destination URL.',
            );
          }
          if (hop == maxRedirects) {
            return _failureResult(
              status: PolicyRetrievalStatus.httpError,
              requestedUrl: trimmedInput,
              canonicalUrl: currentUri.toString(),
              redirectChain: redirectChain,
              httpStatusCode: statusCode,
              retrievedAt: retrievedAt,
              message:
                  'Too many redirects occurred while retrieving the privacy policy.',
            );
          }

          final nextUri = currentUri.resolve(location);
          final nextCheck = await validateDestination(nextUri.toString());
          if (nextCheck.uri == null) {
            redirectChain.add(nextUri.toString());
            return _failureResult(
              status:
                  nextCheck.errorStatus ??
                  PolicyRetrievalStatus.unsafeDestination,
              requestedUrl: trimmedInput,
              canonicalUrl: currentUri.toString(),
              redirectChain: redirectChain,
              httpStatusCode: statusCode,
              retrievedAt: retrievedAt,
              message:
                  'Redirect destination was blocked: ${nextCheck.message ?? "unsafe URL"}.',
            );
          }
          currentUri = nextCheck.uri!;
          redirectChain.add(currentUri.toString());
          continue;
        }

        if (statusCode < 200 || statusCode >= 300) {
          await streamed.stream.drain<void>().catchError((_) {});
          return _failureResult(
            status: PolicyRetrievalStatus.httpError,
            requestedUrl: trimmedInput,
            canonicalUrl: currentUri.toString(),
            redirectChain: redirectChain,
            httpStatusCode: statusCode,
            mimeType: _parseMimeType(streamed.headers['content-type']),
            retrievedAt: retrievedAt,
            message:
                'The server returned HTTP $statusCode while loading the policy page. Paste the policy text manually or import a downloaded document instead.',
          );
        }

        final contentLength = streamed.contentLength;
        if (contentLength != null && contentLength > maxResponseBytes) {
          return _failureResult(
            status: PolicyRetrievalStatus.sizeExceeded,
            requestedUrl: trimmedInput,
            canonicalUrl: currentUri.toString(),
            redirectChain: redirectChain,
            httpStatusCode: statusCode,
            mimeType: _parseMimeType(streamed.headers['content-type']),
            retrievedAt: retrievedAt,
            message:
                'The linked page exceeds the ${(maxResponseBytes / (1024 * 1024)).toStringAsFixed(1)} MB download limit.',
          );
        }

        final rawContentType = streamed.headers['content-type'];
        final mimeType = _parseMimeType(rawContentType);
        if (mimeType != null && !_isSupportedWebContentType(mimeType)) {
          await streamed.stream.drain<void>().catchError((_) {});
          return _failureResult(
            status: PolicyRetrievalStatus.unsupportedContentType,
            requestedUrl: trimmedInput,
            canonicalUrl: currentUri.toString(),
            redirectChain: redirectChain,
            httpStatusCode: statusCode,
            mimeType: mimeType,
            retrievedAt: retrievedAt,
            message: mimeType == 'application/pdf'
                ? 'This URL points directly to a PDF file ($mimeType). Save it locally and open it with "Import document" instead.'
                : 'Unsupported content type "$mimeType". Only public HTML or plain-text privacy policy pages can be fetched directly.',
          );
        }

        final bytes = await _readBoundedBytes(
          streamed.stream,
          remainingTime: totalTimeout - overallStopwatch.elapsed,
        );
        if (bytes == null) {
          return _failureResult(
            status: PolicyRetrievalStatus.sizeExceeded,
            requestedUrl: trimmedInput,
            canonicalUrl: currentUri.toString(),
            redirectChain: redirectChain,
            httpStatusCode: statusCode,
            mimeType: mimeType,
            retrievedAt: retrievedAt,
            message:
                'The policy response exceeded the ${(maxResponseBytes / (1024 * 1024)).toStringAsFixed(1)} MB safety limit.',
          );
        }

        if (_looksLikeBinaryPayload(bytes)) {
          return _failureResult(
            status: PolicyRetrievalStatus.unsupportedContentType,
            requestedUrl: trimmedInput,
            canonicalUrl: currentUri.toString(),
            redirectChain: redirectChain,
            httpStatusCode: statusCode,
            mimeType: mimeType ?? 'application/octet-stream',
            retrievedAt: retrievedAt,
            message:
                'The downloaded response appears to be binary rather than readable HTML or plain-text privacy policy content.',
          );
        }

        final decodedBody = _decodeBody(bytes, rawContentType);
        final isHtml = _shouldParseAsHtml(mimeType, decodedBody);
        final extracted = isHtml
            ? extractPolicyTextFromHtml(decodedBody)
            : _normalizePlainText(decodedBody);

        final canonicalUrl = currentUri.toString();
        final snapshotHash = EvidenceValidator.computeSha256SourceHash(
          extracted.isNotEmpty ? extracted : decodedBody,
        );
        final identityNote = _buildIdentityNote(
          requestedUrl: trimmedInput,
          canonicalUrl: canonicalUrl,
          redirectChain: redirectChain,
        );

        if (extracted.isEmpty ||
            (isHtml && _looksLikeErrorOrChallengePage(decodedBody, extracted))) {
          final snapshot = PolicySourceSnapshot(
            snapshotId: 'snap_${retrievedAt.millisecondsSinceEpoch}',
            sourceType: PolicySourceType.url,
            requestedUrl: trimmedInput,
            canonicalUrl: canonicalUrl,
            redirectChain: List<String>.unmodifiable(redirectChain),
            retrievedAt: retrievedAt,
            retrievalStatus: PolicyRetrievalStatus.emptyOrErrorPage,
            appIdentityMatchStatus: AppIdentityMatchStatus.unverifiedUserSupplied,
            sourceSha256Hash: snapshotHash,
            mimeType: mimeType ?? (isHtml ? 'text/html' : 'text/plain'),
            byteLength: bytes.length,
            limitationNote:
                'Retrieved page contained navigation, login/interstitial boilerplate, or an error screen rather than readable policy disclosures. $identityNote',
          );
          return PolicyUrlRetrievalResult(
            status: PolicyRetrievalStatus.emptyOrErrorPage,
            requestedUrl: trimmedInput,
            canonicalUrl: canonicalUrl,
            redirectChain: List<String>.unmodifiable(redirectChain),
            httpStatusCode: statusCode,
            mimeType: snapshot.mimeType,
            retrievedAt: retrievedAt,
            extractedText: extracted,
            sourceSnapshot: snapshot,
            sufficiencyResult: const PolicySufficiencyResult.insufficient(
              reason: PolicyInsufficiencyReason.placeholderOrUnavailable,
              explanation:
                  'Retrieved web page appeared to be an error, challenge, or login screen rather than readable privacy policy disclosures.',
            ),
            userMessage:
                'The page loaded, but only error, verification, or navigation content could be extracted. Paste the privacy policy text directly or import a saved PDF/TXT/DOCX document instead.',
          );
        }

        final sufficiency = PolicySufficiencyValidator.assess(extracted);
        final status = sufficiency.isSufficient
            ? PolicyRetrievalStatus.retrieved
            : PolicyRetrievalStatus.insufficientPolicy;

        final snapshot = PolicySourceSnapshot(
          snapshotId: 'snap_${retrievedAt.millisecondsSinceEpoch}',
          sourceType: PolicySourceType.url,
          requestedUrl: trimmedInput,
          canonicalUrl: canonicalUrl,
          redirectChain: List<String>.unmodifiable(redirectChain),
          retrievedAt: retrievedAt,
          retrievalStatus: status,
          appIdentityMatchStatus: AppIdentityMatchStatus.unverifiedUserSupplied,
          sourceSha256Hash: snapshotHash,
          mimeType: mimeType ?? (isHtml ? 'text/html' : 'text/plain'),
          byteLength: bytes.length,
          limitationNote: sufficiency.isSufficient
              ? identityNote
              : '${sufficiency.explanation} $identityNote',
        );

        return PolicyUrlRetrievalResult(
          status: status,
          requestedUrl: trimmedInput,
          canonicalUrl: canonicalUrl,
          redirectChain: List<String>.unmodifiable(redirectChain),
          httpStatusCode: statusCode,
          mimeType: snapshot.mimeType,
          retrievedAt: retrievedAt,
          extractedText: extracted,
          sourceSnapshot: snapshot,
          sufficiencyResult: sufficiency,
          userMessage: sufficiency.isSufficient
              ? 'Retrieved policy snapshot from $canonicalUrl'
              : sufficiency.explanation,
        );
      }
    } on TimeoutException {
      return _failureResult(
        status: PolicyRetrievalStatus.timeout,
        requestedUrl: trimmedInput,
        canonicalUrl: currentUri.toString(),
        redirectChain: redirectChain,
        retrievedAt: retrievedAt,
        message:
            'Timed out while loading "$currentUri". Check connectivity or paste the policy text manually.',
      );
    } on SocketException {
      return _failureResult(
        status: PolicyRetrievalStatus.networkError,
        requestedUrl: trimmedInput,
        canonicalUrl: currentUri.toString(),
        redirectChain: redirectChain,
        retrievedAt: retrievedAt,
        message:
            'Network connection failed while contacting "${currentUri.host}". Paste the policy text manually or import a downloaded document.',
      );
    } on http.ClientException {
      return _failureResult(
        status: PolicyRetrievalStatus.networkError,
        requestedUrl: trimmedInput,
        canonicalUrl: currentUri.toString(),
        redirectChain: redirectChain,
        retrievedAt: retrievedAt,
        message:
            'Could not complete the HTTP request to "${currentUri.host}". Paste the policy text manually instead.',
      );
    } finally {
      client.close();
    }

    return _failureResult(
      status: PolicyRetrievalStatus.networkError,
      requestedUrl: trimmedInput,
      canonicalUrl: currentUri.toString(),
      redirectChain: redirectChain,
      retrievedAt: retrievedAt,
      message: 'Could not retrieve the requested privacy policy URL.',
    );
  }

  /// Extracts readable privacy-policy text from raw HTML while stripping
  /// scripts, styles, SVGs, navigation bars, headers, footers, and asides.
  static String extractPolicyTextFromHtml(String html) {
    if (html.trim().isEmpty) return '';

    var cleaned = _stripRawTextElements(
      html,
      const ['script', 'style', 'noscript', 'template', 'svg', 'iframe'],
    );

    // Prefer <main> or largest <article> section when it holds real policy prose.
    final mainSection = _extractFirstTagContent(cleaned, 'main') ??
        _extractLargestTagContent(cleaned, 'article') ??
        _extractFirstTagContent(cleaned, 'body');

    var target = (mainSection != null && mainSection.trim().isNotEmpty)
        ? mainSection
        : cleaned;

    target = _stripTagsWithContent(
      target,
      const {'nav', 'header', 'footer', 'aside'},
    );

    final readable = _htmlFragmentToPlainText(target);
    if (readable.isNotEmpty) return readable;

    // Fallback: if all content lived inside a semantic container that was stripped,
    // fall back to non-script body without removing header/footer, only nav.
    final fallbackTarget = _stripTagsWithContent(cleaned, const {'nav'});
    return _htmlFragmentToPlainText(fallbackTarget);
  }

  PolicyUrlRetrievalResult _failureResult({
    required PolicyRetrievalStatus status,
    required String requestedUrl,
    required String? canonicalUrl,
    required List<String> redirectChain,
    required DateTime retrievedAt,
    required String message,
    int? httpStatusCode,
    String? mimeType,
  }) {
    final snapshot = PolicySourceSnapshot(
      snapshotId: 'snap_${retrievedAt.millisecondsSinceEpoch}',
      sourceType: PolicySourceType.url,
      requestedUrl: requestedUrl,
      canonicalUrl: canonicalUrl,
      redirectChain: List<String>.unmodifiable(redirectChain),
      retrievedAt: retrievedAt,
      retrievalStatus: status,
      appIdentityMatchStatus: AppIdentityMatchStatus.unverifiedUserSupplied,
      sourceSha256Hash: '',
      mimeType: mimeType,
      limitationNote:
          '$message Source link was user-supplied and does not establish verified app ownership.',
    );
    return PolicyUrlRetrievalResult(
      status: status,
      requestedUrl: requestedUrl,
      canonicalUrl: canonicalUrl,
      redirectChain: List<String>.unmodifiable(redirectChain),
      httpStatusCode: httpStatusCode,
      mimeType: mimeType,
      retrievedAt: retrievedAt,
      extractedText: null,
      sourceSnapshot: snapshot,
      sufficiencyResult: null,
      userMessage: message,
    );
  }

  static String _buildIdentityNote({
    required String requestedUrl,
    required String canonicalUrl,
    required List<String> redirectChain,
  }) {
    final redirectNote = redirectChain.length > 1 || canonicalUrl != requestedUrl
        ? 'Redirected (${redirectChain.length - 1} hop${redirectChain.length - 1 == 1 ? '' : 's'}) to $canonicalUrl. '
        : '';
    return '${redirectNote}Retrieved from user-supplied URL; this does not prove app ownership of the page.';
  }

  Future<List<int>?> _readBoundedBytes(
    http.ByteStream stream, {
    required Duration remainingTime,
  }) async {
    final builder = BytesBuilder(copy: false);
    final timeout = remainingTime > Duration.zero
        ? remainingTime
        : const Duration(milliseconds: 100);
    await for (final chunk in stream.timeout(timeout)) {
      if (builder.length + chunk.length > maxResponseBytes) {
        return null;
      }
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  static bool _isRedirectStatus(int code) =>
      code == 301 || code == 302 || code == 303 || code == 307 || code == 308;

  static String? _parseMimeType(String? header) {
    if (header == null || header.trim().isEmpty) return null;
    return header.split(';').first.trim().toLowerCase();
  }

  static bool _isSupportedWebContentType(String mime) {
    return mime == 'text/html' ||
        mime == 'application/xhtml+xml' ||
        mime == 'text/plain' ||
        mime == 'text/markdown' ||
        mime == 'text/x-markdown';
  }

  static bool _looksLikeBinaryPayload(List<int> bytes) {
    if (bytes.isEmpty) return false;
    // PDF header (%PDF-), ZIP/DOCX/APK header (PK\x03\x04), PNG header
    if (bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return true;
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        bytes[2] == 0x03 &&
        bytes[3] == 0x04) {
      return true;
    }
    final sampleLen = bytes.length < 512 ? bytes.length : 512;
    var nulCount = 0;
    for (var i = 0; i < sampleLen; i++) {
      if (bytes[i] == 0) nulCount++;
    }
    return nulCount > 2;
  }

  static String _decodeBody(List<int> bytes, String? contentTypeHeader) {
    final lower = (contentTypeHeader ?? '').toLowerCase();
    final charsetMatch = RegExp(r'charset=([a-z0-9._-]+)').firstMatch(lower);
    final charset = charsetMatch?.group(1);
    if (charset == 'iso-8859-1' || charset == 'latin1') {
      return latin1.decode(bytes);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  static bool _shouldParseAsHtml(String? mimeType, String body) {
    if (mimeType == 'text/html' || mimeType == 'application/xhtml+xml') {
      return true;
    }
    if (mimeType == 'text/plain' ||
        mimeType == 'text/markdown' ||
        mimeType == 'text/x-markdown') {
      return false;
    }
    final sample = body.trimLeft().toLowerCase();
    return sample.startsWith('<!doctype html') ||
        sample.startsWith('<html') ||
        sample.contains('<body') ||
        sample.contains('<p>');
  }

  static bool _looksLikeErrorOrChallengePage(String rawHtml, String extracted) {
    final titleMatch = RegExp(
      r'<title[^>]*>(.*?)</title>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(rawHtml);
    final title = (titleMatch?.group(1) ?? '').toLowerCase();
    final lowerExtracted = extracted.toLowerCase();
    final challengeIndicators = [
      '404 not found',
      'page not found',
      'access denied',
      'just a moment',
      'enable javascript and cookies',
      'verify you are human',
      'attention required! | cloudflare',
      'sign in to continue',
      'log in to view',
    ];
    for (final indicator in challengeIndicators) {
      if (title.contains(indicator) || lowerExtracted.contains(indicator)) {
        // Only treat as error/challenge page if substantial policy terms are absent
        final policyWords = RegExp(
          r'\b(privacy\s+policy|personal\s+(data|information)|collect|third\s+part|retention|delete|cookies|gdpr|ccpa|coppa|ferpa)\b',
        ).allMatches(lowerExtracted).length;
        if (policyWords < 3) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _isUnsafeHostName(String host) {
    if (host == 'localhost' ||
        host.endsWith('.localhost') ||
        host.endsWith('.local') ||
        host.endsWith('.internal') ||
        host.endsWith('.localdomain') ||
        host.endsWith('.lan') ||
        host.endsWith('.home.arpa')) {
      return true;
    }
    return false;
  }

  static bool _isObfuscatedNumericHost(String host) {
    if (RegExp(r'^\d+$').hasMatch(host)) return true;
    if (RegExp(r'^0x[0-9a-f]+$').hasMatch(host)) return true;
    final parts = host.split('.');
    if (parts.length == 4 &&
        parts.every((p) => RegExp(r'^0[0-7]+$|^0x[0-9a-f]+$').hasMatch(p))) {
      return true;
    }
    return false;
  }

  static bool _isUnsafeIpAddress(InternetAddress address) {
    if (address.isLoopback || address.isLinkLocal || address.isMulticast) {
      return true;
    }

    final raw = address.rawAddress;
    if (address.type == InternetAddressType.IPv4 && raw.length == 4) {
      return _isUnsafeIpv4Bytes(raw[0], raw[1], raw[2], raw[3]);
    }

    if (address.type == InternetAddressType.IPv6 && raw.length == 16) {
      // Unspecified ::
      final allZero = raw.every((b) => b == 0);
      if (allZero) return true;
      // Unique local fc00::/7
      if ((raw[0] & 0xfe) == 0xfc) return true;
      // Link-local fe80::/10
      if (raw[0] == 0xfe && (raw[1] & 0xc0) == 0x80) return true;
      // Multicast ff00::/8
      if (raw[0] == 0xff) return true;
      // IPv4-mapped ::ffff:a.b.c.d
      final isV4Mapped = raw.sublist(0, 10).every((b) => b == 0) &&
          raw[10] == 0xff &&
          raw[11] == 0xff;
      if (isV4Mapped) {
        return _isUnsafeIpv4Bytes(raw[12], raw[13], raw[14], raw[15]);
      }
      // IPv4-compatible ::a.b.c.d
      final isV4Compatible = raw.sublist(0, 12).every((b) => b == 0);
      if (isV4Compatible) {
        return _isUnsafeIpv4Bytes(raw[12], raw[13], raw[14], raw[15]);
      }
    }
    return false;
  }

  static bool _isUnsafeIpv4Bytes(int a, int b, int c, int d) {
    if (a == 0) return true; // 0.0.0.0/8
    if (a == 10) return true; // 10.0.0.0/8
    if (a == 100 && b >= 64 && b <= 127) return true; // 100.64.0.0/10 CGNAT
    if (a == 127) return true; // 127.0.0.0/8 loopback
    if (a == 169 && b == 254) return true; // 169.254.0.0/16 link-local / metadata
    if (a == 172 && b >= 16 && b <= 31) return true; // 172.16.0.0/12
    if (a == 192 && b == 168) return true; // 192.168.0.0/16
    if (a == 192 && b == 0 && c == 0) return true; // 192.0.0.0/24 IETF
    if (a == 192 && b == 0 && c == 2) return true; // TEST-NET-1
    if (a == 198 && (b == 18 || b == 19)) return true; // Benchmark
    if (a == 198 && b == 51 && c == 100) return true; // TEST-NET-2
    if (a == 203 && b == 0 && c == 113) return true; // TEST-NET-3
    if (a >= 224) return true; // Multicast & reserved
    return false;
  }

  static final RegExp _tagTokenPattern = RegExp(r'<(/?)([a-zA-Z0-9:-]+)\b[^>]*>');

  static String _stripRawTextElements(String html, List<String> tagNames) {
    var out = html;
    for (final tag in tagNames) {
      final openPattern = RegExp('<$tag\\b[^>]*>', caseSensitive: false);
      final closePattern = RegExp('</$tag\\s*>', caseSensitive: false);
      final buffer = StringBuffer();
      var cursor = 0;
      while (cursor < out.length) {
        final openMatch = openPattern.firstMatch(out.substring(cursor));
        if (openMatch == null) {
          buffer.write(out.substring(cursor));
          break;
        }
        buffer.write(out.substring(cursor, cursor + openMatch.start));
        final openEnd = cursor + openMatch.end;
        if (openMatch.group(0)!.endsWith('/>')) {
          cursor = openEnd;
          continue;
        }
        final closeMatch = closePattern.firstMatch(out.substring(openEnd));
        if (closeMatch == null) {
          cursor = openEnd;
          continue;
        }
        cursor = openEnd + closeMatch.end;
      }
      out = buffer.toString();
    }
    return out;
  }

  /// Linear-time balanced tag stripper so nested tags (e.g. <nav><div>...</div></nav>)
  /// do not leak navigation links or trigger catastrophic regex backtracking.
  static String _stripTagsWithContent(String html, Set<String> targetTags) {
    final buffer = StringBuffer();
    var cursor = 0;
    String? activeTag;
    var depth = 0;

    for (final match in _tagTokenPattern.allMatches(html)) {
      final isClosing = match.group(1) == '/';
      final tagName = match.group(2)!.toLowerCase();
      final fullTag = match.group(0)!;
      final isSelfClosing = fullTag.endsWith('/>');

      if (activeTag == null) {
        buffer.write(html.substring(cursor, match.start));
        cursor = match.end;
        if (!isClosing && !isSelfClosing && targetTags.contains(tagName)) {
          activeTag = tagName;
          depth = 1;
        } else {
          buffer.write(fullTag);
        }
      } else {
        cursor = match.end;
        if (tagName == activeTag) {
          if (isClosing) {
            depth--;
            if (depth <= 0) {
              activeTag = null;
              depth = 0;
            }
          } else if (!isSelfClosing) {
            depth++;
          }
        }
      }
    }

    if (activeTag == null && cursor < html.length) {
      buffer.write(html.substring(cursor));
    }
    return buffer.toString();
  }

  static String? _extractFirstTagContent(String html, String targetTag) {
    final all = _extractAllTagContents(html, targetTag);
    return all.isEmpty ? null : all.first;
  }

  static String? _extractLargestTagContent(String html, String targetTag) {
    final all = _extractAllTagContents(html, targetTag);
    if (all.isEmpty) return null;
    all.sort((a, b) => b.length.compareTo(a.length));
    return all.first;
  }

  static List<String> _extractAllTagContents(String html, String targetTag) {
    final results = <String>[];
    var depth = 0;
    int? innerStart;

    for (final match in _tagTokenPattern.allMatches(html)) {
      final isClosing = match.group(1) == '/';
      final tagName = match.group(2)!.toLowerCase();
      if (tagName != targetTag) continue;
      final isSelfClosing = match.group(0)!.endsWith('/>');

      if (!isClosing && !isSelfClosing) {
        if (depth == 0) {
          innerStart = match.end;
        }
        depth++;
      } else if (isClosing && depth > 0) {
        depth--;
        if (depth == 0 && innerStart != null) {
          results.add(html.substring(innerStart, match.start));
          innerStart = null;
        }
      }
    }
    return results;
  }

  static String _htmlFragmentToPlainText(String html) {
    // Strip HTML comments first
    var text = html.replaceAll(RegExp(r'<!--[\s\S]*?-->'), ' ');

    // Insert structural newlines around headings, paragraphs, list items, and breaks
    text = text.replaceAll(
      RegExp(
        r'</?(?:p|div|section|article|h[1-6]|li|tr|blockquote|br|hr|dt|dd)\b[^>]*>',
        caseSensitive: false,
      ),
      '\n',
    );
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
    text = _decodeHtmlEntities(text);
    return _normalizePlainText(text);
  }

  static String _normalizePlainText(String text) {
    final normalizedLineEndings = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final lines = normalizedLineEndings
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'[ \t\u00A0]+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    return lines.join('\n').trim();
  }

  static String _decodeHtmlEntities(String input) {
    const named = <String, String>{
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&apos;': "'",
      '&nbsp;': ' ',
      '&ndash;': '-',
      '&mdash;': '—',
      '&rsquo;': "'",
      '&lsquo;': "'",
      '&rdquo;': '"',
      '&ldquo;': '"',
      '&hellip;': '…',
      '&copy;': '©',
    };
    var out = input;
    named.forEach((entity, char) {
      out = out.replaceAll(entity, char);
    });
    out = out.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      final code = int.tryParse(m.group(1)!);
      if (code == null || code <= 0 || code > 0x10FFFF) return m.group(0)!;
      return String.fromCharCode(code);
    });
    out = out.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) {
      final code = int.tryParse(m.group(1)!, radix: 16);
      if (code == null || code <= 0 || code > 0x10FFFF) return m.group(0)!;
      return String.fromCharCode(code);
    });
    return out;
  }
}
