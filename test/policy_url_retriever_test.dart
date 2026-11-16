import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:enprive/domain/evidence/evidence_validator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';

void main() {
  final fakePublicIp = InternetAddress('93.184.216.34');
  Future<List<InternetAddress>> publicDns(String host) async => [fakePublicIp];

  group('PolicyUrlRetriever URL validation & SSRF blocking', () {
    test('rejects unsupported schemes (file, javascript, content, data, ftp)', () async {
      final retriever = PolicyUrlRetriever(dnsLookup: publicDns);
      for (final bad in [
        'file:///etc/passwd',
        'content://media/external/file/12',
        'javascript:alert(1)',
        'data:text/html,<h1>Hi</h1>',
        'ftp://example.com/privacy.txt',
      ]) {
        final result = await retriever.fetchPolicy(bad);
        expect(result.isUsablePolicy, isFalse, reason: bad);
        expect(result.status, PolicyRetrievalStatus.invalidUrl, reason: bad);
      }
    });

    test('blocks localhost, private IPs, metadata endpoints, and IPv6 local targets', () async {
      final retriever = PolicyUrlRetriever(dnsLookup: publicDns);
      for (final unsafe in [
        'http://localhost/privacy',
        'https://router.local/privacy',
        'http://metadata.internal/privacy',
        'http://127.0.0.1/privacy',
        'http://10.0.2.2/privacy',
        'http://172.16.5.4/privacy',
        'http://192.168.1.10/privacy',
        'http://169.254.169.254/latest/meta-data',
        'http://[::1]/privacy',
        'http://[fe80::1]/privacy',
        'http://[fc00::1]/privacy',
        'https://user:pass@example.com/privacy',
      ]) {
        final result = await retriever.fetchPolicy(unsafe);
        expect(result.isUsablePolicy, isFalse, reason: unsafe);
        expect(
          result.status,
          PolicyRetrievalStatus.unsafeDestination,
          reason: unsafe,
        );
      }
    });

    test('blocks DNS resolution that points to a private IP', () async {
      final retriever = PolicyUrlRetriever(
        dnsLookup: (host) async => [InternetAddress('10.20.30.40')],
      );
      final result = await retriever.fetchPolicy('https://evil.example.org/privacy');
      expect(result.isUsablePolicy, isFalse);
      expect(result.status, PolicyRetrievalStatus.unsafeDestination);
    });

    test('blocks redirect into loopback or metadata destination', () async {
      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => MockClient((request) async {
          if (request.url.toString() == 'https://example.org/privacy') {
            return http.Response(
              '',
              302,
              headers: {'location': 'http://169.254.169.254/latest/meta-data'},
            );
          }
          fail('Should never request blocked redirect target: ${request.url}');
        }),
      );

      final result = await retriever.fetchPolicy('https://example.org/privacy');
      expect(result.isUsablePolicy, isFalse);
      expect(result.status, PolicyRetrievalStatus.unsafeDestination);
      expect(result.redirectChain, [
        'https://example.org/privacy',
        'http://169.254.169.254/latest/meta-data',
      ]);
    });
  });

  group('PolicyUrlRetriever retrieval, HTML extraction & SHA-256 snapshot', () {
    test('retrieves real HTML policy across redirect, removes boilerplate, records SHA-256 and identity disclaimer', () async {
      const samplePolicyBody =
          'We collect your account email address solely to deliver classroom alerts. '
          'We retain student progress logs for 30 days and never sell personal information to third-party brokers. '
          'Parents may request deletion by emailing privacy@publicschool.example.';

      final fixedTime = DateTime.utc(2026, 11, 15, 12, 30, 0);
      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clock: () => fixedTime,
        clientFactory: () => MockClient((request) async {
          if (request.url.toString() == 'https://calmmath.example.org/privacy') {
            return http.Response(
              '',
              301,
              headers: {'location': '/legal/privacy-policy'},
            );
          }
          if (request.url.toString() ==
              'https://calmmath.example.org/legal/privacy-policy') {
            return http.Response(
              '''
<!doctype html>
<html>
<head>
  <title>Privacy Policy</title>
  <style>body { color: red; }</style>
  <script>var hidden = "<div>do not index</div>";</script>
</head>
<body>
  <header><nav><a href="/">Home</a><a href="/pricing">Pricing</a></nav></header>
  <main>
    <h1>Privacy Policy</h1>
    <p>$samplePolicyBody</p>
  </main>
  <footer>Copyright 2026</footer>
</body>
</html>
''',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }
          return http.Response('Not Found', 404);
        }),
      );

      final result = await retriever.fetchPolicy(
        'https://calmmath.example.org/privacy',
      );

      expect(result.isUsablePolicy, isTrue);
      expect(result.status, PolicyRetrievalStatus.retrieved);
      expect(
        result.canonicalUrl,
        'https://calmmath.example.org/legal/privacy-policy',
      );
      expect(result.redirectChain, [
        'https://calmmath.example.org/privacy',
        'https://calmmath.example.org/legal/privacy-policy',
      ]);
      expect(result.retrievedAt, fixedTime);
      expect(result.extractedText, contains(samplePolicyBody));
      expect(result.extractedText, isNot(contains('Pricing')));
      expect(result.extractedText, isNot(contains('do not index')));
      // Must never substitute bundled CalmMath fixture text
      expect(result.extractedText, isNot(contains('EduTrack')));
      expect(result.extractedText, isNot(contains('CalmMath K-12')));

      final expectedSha256 = sha256
          .convert(utf8.encode(EvidenceValidator.normalize(result.extractedText!)))
          .toString();
      expect(result.sourceSnapshot, isNotNull);
      expect(result.sourceSnapshot!.sourceSha256Hash, expectedSha256);
      expect(
        result.sourceSnapshot!.appIdentityMatchStatus,
        AppIdentityMatchStatus.unverifiedUserSupplied,
      );
      expect(result.sourceSnapshot!.limitationNote, contains('does not prove'));
    });

    test('rejects arbitrary URL when server returns 404 or 500 without substituting bundled fixtures', () async {
      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => MockClient(
          (_) async => http.Response('Page not found', 404),
        ),
      );

      final result = await retriever.fetchPolicy(
        'https://edutrack.example.edu/privacy',
      );
      expect(result.isUsablePolicy, isFalse);
      expect(result.status, PolicyRetrievalStatus.httpError);
      expect(result.httpStatusCode, 404);
      expect(result.extractedText, isNull);
    });

    test('treats navigation-only or challenge HTML as insufficient / error page', () async {
      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => MockClient(
          (_) async => http.Response(
            '<html><head><title>Just a moment...</title></head>'
            '<body><nav><a href="/">Home</a><a href="/login">Sign in</a></nav>'
            '<p>Enable JavaScript and cookies to continue.</p></body></html>',
            200,
            headers: {'content-type': 'text/html'},
          ),
        ),
      );

      final result = await retriever.fetchPolicy('https://example.org/privacy');
      expect(result.isUsablePolicy, isFalse);
      expect(result.status, PolicyRetrievalStatus.emptyOrErrorPage);
      expect(result.sufficiencyResult?.isSufficient, isFalse);
    });

    test('rejects unsupported content types like application/pdf or image/png', () async {
      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => MockClient(
          (_) async => http.Response.bytes(
            Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D]),
            200,
            headers: {'content-type': 'application/pdf'},
          ),
        ),
      );

      final result = await retriever.fetchPolicy('https://example.org/privacy.pdf');
      expect(result.isUsablePolicy, isFalse);
      expect(result.status, PolicyRetrievalStatus.unsupportedContentType);
      expect(result.userMessage, contains('Import document'));
    });

    test('aborts oversized response exceeding maxResponseBytes', () async {
      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        maxResponseBytes: 128,
        clientFactory: () => MockClient(
          (_) async => http.Response('A' * 512, 200, headers: {'content-type': 'text/plain'}),
        ),
      );

      final result = await retriever.fetchPolicy('https://example.org/huge.txt');
      expect(result.isUsablePolicy, isFalse);
      expect(result.status, PolicyRetrievalStatus.sizeExceeded);
    });

    test('extractSharedUrl distinguishes shared policy URLs from long policy prose citing a URL', () {
      expect(
        PolicyUrlRetriever.extractSharedUrl(
          'Privacy Policy - https://example.org/privacy',
        ),
        'https://example.org/privacy',
      );
      expect(
        PolicyUrlRetriever.extractSharedUrl('https://example.org/privacy'),
        'https://example.org/privacy',
      );
      expect(
        PolicyUrlRetriever.extractSharedUrl(
          'We collect device telemetry, usage analytics, advertising identifiers, and location history when the app runs in the background. You may exercise opt-out controls at https://example.org/privacy or contact privacy@example.org for deletion requests.',
        ),
        isNull,
      );
    });
  });
}
