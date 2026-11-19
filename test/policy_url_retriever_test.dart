import 'dart:async';
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

  group('PolicyUrlRetriever cancellation & app-selection provenance (D5.3-D Phase 1)', () {
    test('distinguishes hasSelectedApp false vs true while preserving omitted default', () async {
      const html =
          '<html><body><main><p>We collect email addresses solely for sign-in and never sell personal data to third parties. Users may delete data anytime.</p></main></body></html>';
      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => MockClient(
          (_) async => http.Response(
            html,
            200,
            headers: {'content-type': 'text/html; charset=utf-8'},
          ),
        ),
      );

      final omitted = await retriever.fetchPolicy('https://example.org/privacy');
      expect(omitted.isUsablePolicy, isTrue);
      expect(
        omitted.sourceSnapshot!.appIdentityMatchStatus,
        AppIdentityMatchStatus.unverifiedUserSupplied,
      );

      final standalone = await retriever.fetchPolicy(
        'https://example.org/privacy',
        hasSelectedApp: false,
      );
      expect(standalone.isUsablePolicy, isTrue);
      expect(
        standalone.sourceSnapshot!.appIdentityMatchStatus,
        AppIdentityMatchStatus.notApplicable,
      );

      final linked = await retriever.fetchPolicy(
        'https://example.org/privacy',
        hasSelectedApp: true,
      );
      expect(linked.isUsablePolicy, isTrue);
      expect(
        linked.sourceSnapshot!.appIdentityMatchStatus,
        AppIdentityMatchStatus.unverifiedUserSupplied,
      );
    });

    test('pre-cancelled token skips DNS lookup and HTTP client creation and is idempotent', () async {
      var dnsCalls = 0;
      var clientCreated = false;
      final token = PolicyUrlCancellationToken();
      token.cancel();
      token.cancel(); // Repeated cancel must be a safe no-op.
      expect(token.isCancelled, isTrue);

      final retriever = PolicyUrlRetriever(
        dnsLookup: (host) async {
          dnsCalls++;
          return [fakePublicIp];
        },
        clientFactory: () {
          clientCreated = true;
          return MockClient((_) async => http.Response('', 200));
        },
      );

      final result = await retriever.fetchPolicy(
        'https://example.org/privacy',
        cancelToken: token,
        hasSelectedApp: false,
      );
      expect(result.isUsablePolicy, isFalse);
      expect(result.status, PolicyRetrievalStatus.cancelled);
      expect(dnsCalls, 0);
      expect(clientCreated, isFalse);
      expect(
        result.sourceSnapshot!.appIdentityMatchStatus,
        AppIdentityMatchStatus.notApplicable,
      );
    });

    test('closes active HTTP client immediately when cancelled in-flight and ignores late response', () async {
      final sendStarted = Completer<void>();
      final lateSendCompleter = Completer<http.Response>();
      var closeCount = 0;

      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => _SpyHttpClient(
          MockClient((_) async {
            if (!sendStarted.isCompleted) sendStarted.complete();
            return lateSendCompleter.future;
          }),
          () => closeCount++,
        ),
      );

      final token = PolicyUrlCancellationToken();
      final future = retriever.fetchPolicy(
        'https://example.org/privacy',
        cancelToken: token,
      );

      await sendStarted.future;
      token.cancel();
      token.cancel(); // Repeated cancel remains safe.

      final result = await future;
      expect(result.status, PolicyRetrievalStatus.cancelled);
      expect(result.isUsablePolicy, isFalse);
      expect(result.extractedText, isNull);
      expect(closeCount, 1);
      expect(token.hasActiveListeners, isFalse);

      // Late completion after cancellation must not throw or flip outcome.
      lateSendCompleter.complete(
        http.Response(
          '<html><body><p>We collect personal data and share analytics with third parties.</p></body></html>',
          200,
          headers: {'content-type': 'text/html'},
        ),
      );
      await pumpEventQueue();
    });

    test('cancelling during redirect prevents follow-up hop request', () async {
      final requestedUrls = <String>[];
      final redirectDnsStarted = Completer<void>();
      final redirectDnsGate = Completer<List<InternetAddress>>();
      final token = PolicyUrlCancellationToken();

      final retriever = PolicyUrlRetriever(
        dnsLookup: (host) async {
          if (host == 'hop2.example.org') {
            if (!redirectDnsStarted.isCompleted) redirectDnsStarted.complete();
            return redirectDnsGate.future;
          }
          return [fakePublicIp];
        },
        clientFactory: () => MockClient((request) async {
          requestedUrls.add(request.url.toString());
          if (request.url.host == 'hop1.example.org') {
            return http.Response(
              '',
              302,
              headers: {'location': 'https://hop2.example.org/privacy'},
            );
          }
          fail('Cancelled redirect hop must never execute HTTP send');
        }),
      );

      final future = retriever.fetchPolicy(
        'https://hop1.example.org/start',
        cancelToken: token,
      );

      await redirectDnsStarted.future;
      token.cancel();

      final result = await future;
      expect(result.status, PolicyRetrievalStatus.cancelled);
      expect(result.isUsablePolicy, isFalse);
      expect(requestedUrls, ['https://hop1.example.org/start']);
      expect(token.hasActiveListeners, isFalse);

      redirectDnsGate.complete([fakePublicIp]);
      await pumpEventQueue();
    });

    test('cancelling during response-body streaming aborts stream and returns cancelled', () async {
      final streamController = StreamController<List<int>>();
      final firstChunkDelivered = Completer<void>();
      var closeCount = 0;
      var streamCancelled = false;

      streamController.onCancel = () {
        streamCancelled = true;
      };

      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => _SpyHttpClient.streaming(
          onStream: (request, _) async {
            scheduleMicrotask(() {
              streamController.add(
                utf8.encode(
                  '<html><body><main><p>We collect personal data only to ',
                ),
              );
              if (!firstChunkDelivered.isCompleted) {
                firstChunkDelivered.complete();
              }
            });
            return http.StreamedResponse(
              streamController.stream,
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          },
          onClose: () => closeCount++,
        ),
      );

      final token = PolicyUrlCancellationToken();
      final future = retriever.fetchPolicy(
        'https://stream.example.org/privacy',
        cancelToken: token,
      );

      await firstChunkDelivered.future;
      await pumpEventQueue();
      token.cancel();

      final result = await future;
      expect(result.status, PolicyRetrievalStatus.cancelled);
      expect(result.isUsablePolicy, isFalse);
      expect(result.extractedText, isNull);
      expect(closeCount, 1);
      expect(streamCancelled, isTrue);
      expect(token.hasActiveListeners, isFalse);
    });

    test('closes HTTP client once, removes listeners, and handles initial DNS cancel and sync streams', () async {
      // 1) Normal success with non-cancelled token
      var closeCount = 0;
      final okToken = PolicyUrlCancellationToken();
      final okRetriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => _SpyHttpClient(
          MockClient(
            (_) async => http.Response(
              '<html><body><main><p>We collect email addresses solely to deliver alerts and never sell personal data to third parties.</p></main></body></html>',
              200,
              headers: {'content-type': 'text/html'},
            ),
          ),
          () => closeCount++,
        ),
      );
      final okResult = await okRetriever.fetchPolicy(
        'https://ok.example.org/privacy',
        cancelToken: okToken,
      );
      expect(okResult.isUsablePolicy, isTrue);
      expect(closeCount, 1);
      expect(okToken.hasActiveListeners, isFalse);

      // 2) HTTP error (404) with non-cancelled token
      var errorCloseCount = 0;
      final errToken = PolicyUrlCancellationToken();
      final errRetriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => _SpyHttpClient(
          MockClient((_) async => http.Response('Missing', 404)),
          () => errorCloseCount++,
        ),
      );
      final errResult = await errRetriever.fetchPolicy(
        'https://missing.example.org/privacy',
        cancelToken: errToken,
      );
      expect(errResult.status, PolicyRetrievalStatus.httpError);
      expect(errorCloseCount, 1);
      expect(errToken.hasActiveListeners, isFalse);

      // 3) Cancellation during initial DNS lookup skips client creation
      final dnsStarted = Completer<void>();
      final dnsGate = Completer<List<InternetAddress>>();
      var clientCreated = false;
      final dnsToken = PolicyUrlCancellationToken();
      final dnsRetriever = PolicyUrlRetriever(
        dnsLookup: (_) async {
          if (!dnsStarted.isCompleted) dnsStarted.complete();
          return dnsGate.future;
        },
        clientFactory: () {
          clientCreated = true;
          return MockClient((_) async => http.Response('', 200));
        },
      );
      final dnsFuture = dnsRetriever.fetchPolicy(
        'https://dns-slow.example.org/privacy',
        cancelToken: dnsToken,
      );
      await dnsStarted.future;
      dnsToken.cancel();
      final dnsResult = await dnsFuture;
      expect(dnsResult.status, PolicyRetrievalStatus.cancelled);
      expect(clientCreated, isFalse);
      expect(dnsToken.hasActiveListeners, isFalse);
      dnsGate.complete([fakePublicIp]);
      await pumpEventQueue();

      // 4) Synchronous StreamController delivery does not throw LateInitializationError
      var syncCloseCount = 0;
      final syncToken = PolicyUrlCancellationToken();
      final syncController = StreamController<List<int>>(sync: true);
      final syncRetriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clientFactory: () => _SpyHttpClient.streaming(
          onStream: (request, _) async {
            scheduleMicrotask(() {
              syncController.add(
                utf8.encode(
                  '<html><body><p>We collect analytics only with explicit consent and retain logs for 30 days without selling personal data.</p></body></html>',
                ),
              );
              syncController.close();
            });
            return http.StreamedResponse(
              syncController.stream,
              200,
              headers: {'content-type': 'text/html'},
            );
          },
          onClose: () => syncCloseCount++,
        ),
      );
      final syncResult = await syncRetriever.fetchPolicy(
        'https://sync.example.org/privacy',
        cancelToken: syncToken,
      );
      expect(syncResult.isUsablePolicy, isTrue);
      expect(syncCloseCount, 1);
      expect(syncToken.hasActiveListeners, isFalse);
    });
  });
}

class _SpyHttpClient extends http.BaseClient {
  final http.Client _inner;
  final void Function() _onClose;

  _SpyHttpClient(this._inner, this._onClose);

  factory _SpyHttpClient.streaming({
    required Future<http.StreamedResponse> Function(
      http.BaseRequest request,
      http.ByteStream bodyStream,
    )
    onStream,
    required void Function() onClose,
  }) {
    return _SpyHttpClient(MockClient.streaming(onStream), onClose);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request);

  @override
  void close() {
    _onClose();
    _inner.close();
  }
}
