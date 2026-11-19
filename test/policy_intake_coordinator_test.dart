import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:enprive/domain/evidence/evidence_validator.dart';
import 'package:enprive/domain/intake/policy_intake_models.dart';
import 'package:enprive/domain/review/app_policy_association.dart';
import 'package:enprive/domain/review/policy_sufficiency.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/services/intake/policy_intake_coordinator.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';

class _FakeDocumentPlatformBridge implements PolicyDocumentPlatformBridge {
  int pickCalls = 0;
  int inspectCalls = 0;
  Future<DocumentExtractionOutcome> Function()? onPick;
  Future<AppPermissionSnapshot?> Function(String packageName)? onInspect;

  @override
  Future<DocumentExtractionOutcome> pickAndExtractDocument() async {
    pickCalls++;
    if (onPick != null) return onPick!();
    return const DocumentExtractionOutcome(
      status: 'cancelled',
      extractedText: '',
      userMessage: 'Cancelled.',
    );
  }

  @override
  Future<AppPermissionSnapshot?> inspectAppSnapshot(String packageName) async {
    inspectCalls++;
    if (onInspect != null) return onInspect!(packageName);
    return null;
  }
}

void main() {
  final fakePublicIp = InternetAddress('93.184.216.34');
  Future<List<InternetAddress>> publicDns(String host) async => [fakePublicIp];
  final fixedClock = DateTime.utc(2026, 11, 19, 10, 30, 0);

  const sampleValidPolicy =
      'Focus Reader collects only account email addresses for classroom backup and never sells personal data to advertisers or third parties. Users may delete account data anytime.';

  group('D5.3-D Phase 1: Text intake (pasted, shared, selected)', () {
    test('captures pasted, shared, and selected text with exact source types, labels, and canonical SHA-256', () {
      final coordinator = PolicyIntakeCoordinator(clock: () => fixedClock);
      final expectedHash = EvidenceValidator.computeSha256SourceHash(
        sampleValidPolicy,
      );

      final pasted = coordinator.capturePastedText(
        rawText: '  $sampleValidPolicy  ',
        userSubjectTitle: 'Focus Notes',
      );
      expect(pasted, isA<PolicyIntakeSuccess>());
      final pastedSuccess = pasted as PolicyIntakeSuccess;
      expect(pastedSuccess.locator.sourceType, PolicySourceType.pastedText);
      expect(pastedSuccess.capturedSnapshot.sourceLabel, 'Pasted policy text');
      expect(pastedSuccess.capturedSnapshot.subjectTitle, 'Focus Notes');
      expect(pastedSuccess.capturedSnapshot.sourceSha256Hash, expectedHash);
      expect(
        pastedSuccess.capturedSnapshot.sourceSnapshot.appIdentityMatchStatus,
        AppIdentityMatchStatus.notApplicable,
      );
      expect(
        pastedSuccess.associationReport.state,
        AppPolicyAssociationState.unlinked,
      );

      final shared = coordinator.captureSharedText(rawText: sampleValidPolicy);
      expect(shared, isA<PolicyIntakeSuccess>());
      final sharedSuccess = shared as PolicyIntakeSuccess;
      expect(sharedSuccess.locator.sourceType, PolicySourceType.sharedText);
      expect(sharedSuccess.capturedSnapshot.sourceLabel, 'Shared text');
      expect(sharedSuccess.capturedSnapshot.subjectTitle, 'Shared Policy');
      expect(sharedSuccess.capturedSnapshot.sourceSha256Hash, expectedHash);
      expect(
        (sharedSuccess.locator as TextPolicyLocator).sourceAction,
        'ACTION_SEND',
      );

      final selected = coordinator.captureSelectedText(
        rawText: sampleValidPolicy,
      );
      expect(selected, isA<PolicyIntakeSuccess>());
      final selectedSuccess = selected as PolicyIntakeSuccess;
      expect(selectedSuccess.locator.sourceType, PolicySourceType.selectedText);
      expect(selectedSuccess.capturedSnapshot.sourceLabel, 'Selected text');
      expect(selectedSuccess.capturedSnapshot.subjectTitle, 'Selected Excerpt');
      expect(selectedSuccess.capturedSnapshot.sourceSha256Hash, expectedHash);
      expect(
        (selectedSuccess.locator as TextPolicyLocator).sourceAction,
        'ACTION_PROCESS_TEXT',
      );
    });

    test('fails closed on empty, placeholder, and non-policy text while preserving original locator verbatim', () {
      final coordinator = PolicyIntakeCoordinator(clock: () => fixedClock);

      final emptyLocator = TextPolicyLocator(
        rawText: '   \n  ',
        sourceType: PolicySourceType.pastedText,
        userSubjectTitle: 'My Draft Title',
      );
      final emptyResult = coordinator.captureText(locator: emptyLocator);
      expect(emptyResult, isA<PolicyIntakeFailure>());
      final emptyFailure = emptyResult as PolicyIntakeFailure;
      expect(emptyFailure.kind, PolicyIntakeFailureKind.emptyInput);
      expect(identical(emptyFailure.locator, emptyLocator), isTrue);
      expect((emptyFailure.locator as TextPolicyLocator).rawText, '   \n  ');
      expect(emptyFailure.locator.userSubjectTitle, 'My Draft Title');
      expect(emptyFailure.canRetrySameLocator, isTrue);

      final placeholderLocator = TextPolicyLocator(
        rawText: 'Privacy policy is currently unavailable.',
        sourceType: PolicySourceType.sharedText,
      );
      final placeholderResult = coordinator.captureText(
        locator: placeholderLocator,
      );
      expect(placeholderResult, isA<PolicyIntakeFailure>());
      final placeholderFailure = placeholderResult as PolicyIntakeFailure;
      expect(
        placeholderFailure.kind,
        PolicyIntakeFailureKind.insufficientPolicy,
      );
      expect(
        (placeholderFailure.locator as TextPolicyLocator).rawText,
        'Privacy policy is currently unavailable.',
      );

      final proseLocator = TextPolicyLocator(
        rawText: 'The quick brown fox jumps over the quiet river by dawn.',
        sourceType: PolicySourceType.selectedText,
      );
      final proseResult = coordinator.captureText(locator: proseLocator);
      expect(proseResult, isA<PolicyIntakeFailure>());
      final proseFailure = proseResult as PolicyIntakeFailure;
      expect(proseFailure.kind, PolicyIntakeFailureKind.insufficientPolicy);
      expect(
        (proseFailure.locator as TextPolicyLocator).rawText,
        'The quick brown fox jumps over the quiet river by dawn.',
      );
    });
  });

  group('D5.3-D Phase 1: URL intake, provenance & cancellation', () {
    test('captures public URL across redirect with SHA-256 and sets identity status per app selection', () async {
      final retriever = PolicyUrlRetriever(
        dnsLookup: publicDns,
        clock: () => fixedClock,
        clientFactory: () => MockClient((request) async {
          if (request.url.toString() == 'https://example.org/privacy') {
            return http.Response(
              '',
              302,
              headers: {'location': 'https://example.org/legal/policy'},
            );
          }
          if (request.url.toString() == 'https://example.org/legal/policy') {
            return http.Response(
              '<html><body><main><h1>Privacy</h1><p>$sampleValidPolicy</p></main></body></html>',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }
          return http.Response('Not Found', 404);
        }),
      );
      final coordinator = PolicyIntakeCoordinator(
        urlRetriever: retriever,
        clock: () => fixedClock,
      );

      const urlLocator = UrlPolicyLocator(
        rawUrl: 'https://example.org/privacy',
      );

      // No selected app -> AppIdentityMatchStatus.notApplicable
      final standalone = await coordinator.captureFromUrl(locator: urlLocator);
      expect(standalone, isA<PolicyIntakeSuccess>());
      final s1 = standalone as PolicyIntakeSuccess;
      expect(
        s1.capturedSnapshot.sourceLabel,
        'https://example.org/legal/policy',
      );
      expect(
        s1.capturedSnapshot.sourceSnapshot.requestedUrl,
        'https://example.org/privacy',
      );
      expect(s1.capturedSnapshot.sourceSnapshot.redirectChain, [
        'https://example.org/privacy',
        'https://example.org/legal/policy',
      ]);
      expect(
        s1.capturedSnapshot.sourceSnapshot.appIdentityMatchStatus,
        AppIdentityMatchStatus.notApplicable,
      );
      expect(
        s1.capturedSnapshot.sourceSha256Hash,
        EvidenceValidator.computeSha256SourceHash(
          s1.capturedSnapshot.normalizedPolicyText,
        ),
      );
      expect(s1.associationReport.state, AppPolicyAssociationState.unlinked);

      // With selected app -> unverifiedUserSupplied (never proves ownership)
      final appRef = SelectedAppReference(
        packageName: 'org.example.focusreader',
        appName: 'Focus Reader',
      );
      final withApp = await coordinator.captureFromUrl(
        locator: urlLocator,
        selectedApp: appRef,
      );
      expect(withApp, isA<PolicyIntakeSuccess>());
      final s2 = withApp as PolicyIntakeSuccess;
      expect(
        s2.capturedSnapshot.sourceSnapshot.appIdentityMatchStatus,
        AppIdentityMatchStatus.unverifiedUserSupplied,
      );
      expect(s2.associationReport.provesDeveloperOwnership, isFalse);
    });

    test('fails closed on unsafe, invalid, 404, timeout, oversized, binary, and challenge URLs while preserving locator', () async {
      final retriever = PolicyUrlRetriever(
        dnsLookup: (host) async {
          if (host == 'private-dns.example.org') {
            return [InternetAddress('10.0.0.5')];
          }
          return [fakePublicIp];
        },
        maxResponseBytes: 128,
        clock: () => fixedClock,
        clientFactory: () => MockClient((request) async {
          switch (request.url.path) {
            case '/notfound':
              return http.Response('Not Found', 404);
            case '/timeout':
              throw TimeoutException('Simulated timeout');
            case '/huge':
              return http.Response(
                'A' * 512,
                200,
                headers: {'content-type': 'text/plain'},
              );
            case '/binary.pdf':
              return http.Response.bytes(
                [0x25, 0x50, 0x44, 0x46, 0x2D],
                200,
                headers: {'content-type': 'application/pdf'},
              );
            case '/challenge':
              return http.Response(
                '<html><head><title>Just a moment...</title></head><body><p>Enable JavaScript and cookies to continue.</p></body></html>',
                200,
                headers: {'content-type': 'text/html'},
              );
            default:
              return http.Response('Error', 500);
          }
        }),
      );
      final coordinator = PolicyIntakeCoordinator(
        urlRetriever: retriever,
        clock: () => fixedClock,
      );

      final cases = <(String, PolicyIntakeFailureKind)>[
        ('http://127.0.0.1/privacy', PolicyIntakeFailureKind.unsafeDestination),
        (
          'http://169.254.169.254/meta',
          PolicyIntakeFailureKind.unsafeDestination,
        ),
        (
          'https://private-dns.example.org/p',
          PolicyIntakeFailureKind.unsafeDestination,
        ),
        ('ftp://example.org/privacy', PolicyIntakeFailureKind.invalidUrl),
        ('not a url', PolicyIntakeFailureKind.invalidUrl),
        ('https://example.org/notfound', PolicyIntakeFailureKind.httpError),
        ('https://example.org/timeout', PolicyIntakeFailureKind.timeout),
        ('https://example.org/huge', PolicyIntakeFailureKind.sizeExceeded),
        (
          'https://example.org/binary.pdf',
          PolicyIntakeFailureKind.unsupportedContentType,
        ),
        (
          'https://example.org/challenge',
          PolicyIntakeFailureKind.emptyOrErrorPage,
        ),
      ];

      for (final (url, expectedKind) in cases) {
        final locator = UrlPolicyLocator(
          rawUrl: url,
          userSubjectTitle: 'Kept Title',
        );
        final outcome = await coordinator.captureFromUrl(locator: locator);
        expect(outcome, isA<PolicyIntakeFailure>(), reason: url);
        final failure = outcome as PolicyIntakeFailure;
        expect(failure.kind, expectedKind, reason: url);
        expect((failure.locator as UrlPolicyLocator).rawUrl, url);
        expect(failure.locator.userSubjectTitle, 'Kept Title');
        expect(failure.failedSourceSnapshot, isNotNull, reason: url);
        expect(failure.canRetrySameLocator, isTrue);
      }
    });

    test('supports cooperative cancellation during active fetch, redirect, and streaming body', () async {
      // 1) Active send cancellation
      final sendStarted = Completer<void>();
      final lateResponse = Completer<http.Response>();
      final coordinator = PolicyIntakeCoordinator(
        urlRetriever: PolicyUrlRetriever(
          dnsLookup: publicDns,
          clock: () => fixedClock,
          clientFactory: () => MockClient((_) async {
            if (!sendStarted.isCompleted) sendStarted.complete();
            return lateResponse.future;
          }),
        ),
        clock: () => fixedClock,
      );

      final token = PolicyUrlCancellationToken();
      const urlLocator = UrlPolicyLocator(
        rawUrl: 'https://slow.example.org/privacy',
        userSubjectTitle: 'Slow Site',
      );
      final pending = coordinator.captureFromUrl(
        locator: urlLocator,
        cancelToken: token,
      );
      await sendStarted.future;
      token.cancel();

      final outcome = await pending;
      expect(outcome, isA<PolicyIntakeFailure>());
      expect(outcome.isCancelled, isTrue);
      expect((outcome.locator as UrlPolicyLocator).rawUrl, urlLocator.rawUrl);
      expect(outcome.locator.userSubjectTitle, 'Slow Site');

      lateResponse.complete(
        http.Response(
          '<html><body><p>$sampleValidPolicy</p></body></html>',
          200,
          headers: {'content-type': 'text/html'},
        ),
      );
      await pumpEventQueue();

      // 2) Redirect cancellation
      final redirectRequestedUrls = <String>[];
      final redirectDnsStarted = Completer<void>();
      final redirectDnsGate = Completer<List<InternetAddress>>();
      final redirectCoordinator = PolicyIntakeCoordinator(
        urlRetriever: PolicyUrlRetriever(
          dnsLookup: (host) async {
            if (host == 'hop2.example.org') {
              if (!redirectDnsStarted.isCompleted) {
                redirectDnsStarted.complete();
              }
              return redirectDnsGate.future;
            }
            return [fakePublicIp];
          },
          clock: () => fixedClock,
          clientFactory: () => MockClient((request) async {
            redirectRequestedUrls.add(request.url.toString());
            if (request.url.host == 'hop1.example.org') {
              return http.Response(
                '',
                302,
                headers: {'location': 'https://hop2.example.org/privacy'},
              );
            }
            fail('Cancelled redirect hop must never execute HTTP send');
          }),
        ),
        clock: () => fixedClock,
      );

      final redirectToken = PolicyUrlCancellationToken();
      const redirectLocator = UrlPolicyLocator(
        rawUrl: 'https://hop1.example.org/start',
        userSubjectTitle: 'Hop Site',
      );
      final redirectPending = redirectCoordinator.captureFromUrl(
        locator: redirectLocator,
        cancelToken: redirectToken,
      );
      await redirectDnsStarted.future;
      redirectToken.cancel();

      final redirectOutcome = await redirectPending;
      expect(redirectOutcome, isA<PolicyIntakeFailure>());
      expect(redirectOutcome.isCancelled, isTrue);
      expect(
        (redirectOutcome.locator as UrlPolicyLocator).rawUrl,
        redirectLocator.rawUrl,
      );
      expect(redirectOutcome.locator.userSubjectTitle, 'Hop Site');
      expect(redirectRequestedUrls, ['https://hop1.example.org/start']);
      redirectDnsGate.complete([fakePublicIp]);
      await pumpEventQueue();

      // 3) Streaming body cancellation
      final streamCtrl = StreamController<List<int>>();
      final chunkSent = Completer<void>();
      final streamCoordinator = PolicyIntakeCoordinator(
        urlRetriever: PolicyUrlRetriever(
          dnsLookup: publicDns,
          clock: () => fixedClock,
          clientFactory: () => MockClient.streaming((_, _) async {
            scheduleMicrotask(() {
              streamCtrl.add(utf8.encode('<html><body><p>$sampleValidPolicy'));
              if (!chunkSent.isCompleted) chunkSent.complete();
            });
            return http.StreamedResponse(
              streamCtrl.stream,
              200,
              headers: {'content-type': 'text/html'},
            );
          }),
        ),
        clock: () => fixedClock,
      );

      final streamToken = PolicyUrlCancellationToken();
      final streamPending = streamCoordinator.captureFromUrl(
        locator: urlLocator,
        cancelToken: streamToken,
      );
      await chunkSent.future;
      await pumpEventQueue();
      streamToken.cancel();

      final streamOutcome = await streamPending;
      expect(streamOutcome, isA<PolicyIntakeFailure>());
      expect(streamOutcome.isCancelled, isTrue);
      await streamCtrl.close();
    });
  });

  group('D5.3-D Phase 1: Document intake (picker & pre-extracted shares)', () {
    test('constructor has zero platform side effects and missing bridge fails closed', () async {
      final fakeBridge = _FakeDocumentPlatformBridge();
      final coordinator = PolicyIntakeCoordinator(
        documentBridge: fakeBridge,
        clock: () => fixedClock,
      );
      expect(coordinator, isNotNull);
      expect(fakeBridge.pickCalls, 0);
      expect(fakeBridge.inspectCalls, 0);

      final headless = PolicyIntakeCoordinator(clock: () => fixedClock);
      final missingBridgeOutcome = await headless.captureFromDocumentPicker();
      expect(missingBridgeOutcome, isA<PolicyIntakeFailure>());
      expect(
        (missingBridgeOutcome as PolicyIntakeFailure).kind,
        PolicyIntakeFailureKind.documentReadError,
      );
    });

    test('captures valid PDF, TXT, and DOCX pre-extracted and picker documents with exact provenance', () async {
      final fakeBridge = _FakeDocumentPlatformBridge()
        ..onPick = () async => const DocumentExtractionOutcome(
          status: 'ok',
          documentType: 'pdf',
          fileName: 'school_policy.pdf',
          mimeType: 'application/pdf',
          byteLength: 4096,
          pageCount: 2,
          extractedText: sampleValidPolicy,
          userMessage: 'Extracted locally.',
        );
      final coordinator = PolicyIntakeCoordinator(
        documentBridge: fakeBridge,
        clock: () => fixedClock,
      );

      final picked = await coordinator.captureFromDocumentPicker(
        userSubjectTitle: 'School App Policy',
      );
      expect(fakeBridge.pickCalls, 1);
      expect(picked, isA<PolicyIntakeSuccess>());
      final pdfSuccess = picked as PolicyIntakeSuccess;
      expect(pdfSuccess.capturedSnapshot.sourceType, PolicySourceType.pdf);
      expect(pdfSuccess.capturedSnapshot.subjectTitle, 'School App Policy');
      expect(
        pdfSuccess.capturedSnapshot.sourceLabel,
        'Document · school_policy.pdf',
      );
      expect(
        pdfSuccess.capturedSnapshot.sourceSnapshot.extractionStatus,
        DocumentExtractionStatus.extracted,
      );
      expect(
        pdfSuccess.capturedSnapshot.sourceSnapshot.originalFilename,
        'school_policy.pdf',
      );
      expect(pdfSuccess.capturedSnapshot.sourceSnapshot.byteLength, 4096);
      expect(
        pdfSuccess.capturedSnapshot.sourceSha256Hash,
        EvidenceValidator.computeSha256SourceHash(sampleValidPolicy),
      );
      expect(
        (pdfSuccess.locator as DocumentPolicyLocator)
            .isPreExtractedIncomingShare,
        isFalse,
      );

      for (final (docType, fileName, mime, expectedType) in [
        ('txt', 'policy.txt', 'text/plain', PolicySourceType.textDocument),
        (
          'docx',
          'policy.docx',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          PolicySourceType.docx,
        ),
      ]) {
        final shareOutcome = coordinator.captureIncomingDocument(
          outcome: DocumentExtractionOutcome(
            status: 'ok',
            documentType: docType,
            fileName: fileName,
            mimeType: mime,
            byteLength: 1024,
            extractedText: sampleValidPolicy,
            userMessage: 'Extracted.',
          ),
        );
        expect(shareOutcome, isA<PolicyIntakeSuccess>(), reason: docType);
        final docSuccess = shareOutcome as PolicyIntakeSuccess;
        expect(docSuccess.capturedSnapshot.sourceType, expectedType);
        expect(
          (docSuccess.locator as DocumentPolicyLocator)
              .isPreExtractedIncomingShare,
          isTrue,
        );
      }
    });

    test('fails closed across all document error & cancellation cases without fabricating text', () async {
      final fakeBridge = _FakeDocumentPlatformBridge();
      final coordinator = PolicyIntakeCoordinator(
        documentBridge: fakeBridge,
        clock: () => fixedClock,
      );

      final failureCases = <(String, String, PolicyIntakeFailureKind)>[
        ('empty', '', PolicyIntakeFailureKind.documentEmpty),
        ('ok', '   ', PolicyIntakeFailureKind.documentEmpty),
        ('corrupt', '', PolicyIntakeFailureKind.documentCorrupt),
        (
          'password_protected',
          '',
          PolicyIntakeFailureKind.documentPasswordProtected,
        ),
        (
          'unsupported_mime',
          '',
          PolicyIntakeFailureKind.documentUnsupportedMime,
        ),
        ('too_large', '', PolicyIntakeFailureKind.documentTooLarge),
        (
          'permission_denied',
          '',
          PolicyIntakeFailureKind.documentPermissionDenied,
        ),
        ('read_error', '', PolicyIntakeFailureKind.documentReadError),
        (
          'ok',
          'Privacy policy unavailable.',
          PolicyIntakeFailureKind.insufficientPolicy,
        ),
        ('cancelled', '', PolicyIntakeFailureKind.cancelled),
      ];

      for (final (status, text, expectedKind) in failureCases) {
        final shareFailure = coordinator.captureIncomingDocument(
          outcome: DocumentExtractionOutcome(
            status: status,
            documentType: 'pdf',
            fileName: 'broken.pdf',
            mimeType: 'application/pdf',
            byteLength: 256,
            extractedText: text,
            userMessage: status == 'cancelled'
                ? 'Cancelled.'
                : 'Extraction failed: $status.',
          ),
        );
        expect(shareFailure, isA<PolicyIntakeFailure>(), reason: status);
        final f = shareFailure as PolicyIntakeFailure;
        expect(f.kind, expectedKind, reason: status);
        expect(f.canRetrySameLocator, isFalse, reason: status);
        expect((f.locator as DocumentPolicyLocator).fileName, 'broken.pdf');
        if (status != 'cancelled' && status != 'ok') {
          expect(f.failedSourceSnapshot, isNotNull);
          expect(f.failedSourceSnapshot!.sourceSha256Hash, isEmpty);
        }

        fakeBridge.onPick = () async => DocumentExtractionOutcome(
          status: status,
          documentType: 'pdf',
          fileName: 'picked_broken.pdf',
          mimeType: 'application/pdf',
          byteLength: 256,
          extractedText: text,
          userMessage: 'Failed: $status',
        );
        final pickerFailure = await coordinator.captureFromDocumentPicker();
        expect(
          pickerFailure,
          isA<PolicyIntakeFailure>(),
          reason: 'pick:$status',
        );
        final pf = pickerFailure as PolicyIntakeFailure;
        expect(pf.kind, expectedKind, reason: 'pick:$status');
        expect(pf.canRetrySameLocator, isTrue, reason: 'pick:$status');
      }
    });
  });

  group('D5.3-D Phase 1: Incoming payload routing & permission hydration', () {
    test('routes ACTION_SEND URL, text, document, and ACTION_PROCESS_TEXT uniformly', () async {
      final fakeBridge = _FakeDocumentPlatformBridge()
        ..onInspect = (pkg) async => AppPermissionSnapshot(
          packageName: pkg,
          appName: 'Hydrated App',
          requestedPermissions: const ['android.permission.CAMERA'],
          grantedPermissions: const [],
        );
      final coordinator = PolicyIntakeCoordinator(
        documentBridge: fakeBridge,
        urlRetriever: PolicyUrlRetriever(
          dnsLookup: publicDns,
          clock: () => fixedClock,
          clientFactory: () => MockClient(
            (_) async => http.Response(
              '<html><body><p>$sampleValidPolicy</p></body></html>',
              200,
              headers: {'content-type': 'text/html'},
            ),
          ),
        ),
        clock: () => fixedClock,
      );

      final urlOutcome = await coordinator.captureIncomingPayload(
        payload: const IncomingIntentPayload(
          kind: 'text_or_url',
          sourceAction: 'ACTION_SEND',
          text: 'Privacy Policy - https://example.org/privacy',
          subject: 'Shared Link Title',
        ),
      );
      expect(urlOutcome, isA<PolicyIntakeSuccess>());
      expect(
        (urlOutcome as PolicyIntakeSuccess).capturedSnapshot.sourceType,
        PolicySourceType.url,
      );
      expect(urlOutcome.capturedSnapshot.subjectTitle, 'Shared Link Title');

      final sharedTextOutcome = await coordinator.captureIncomingPayload(
        payload: const IncomingIntentPayload(
          kind: 'text_or_url',
          sourceAction: 'ACTION_SEND',
          text: sampleValidPolicy,
        ),
      );
      expect(sharedTextOutcome, isA<PolicyIntakeSuccess>());
      expect(
        (sharedTextOutcome as PolicyIntakeSuccess).capturedSnapshot.sourceType,
        PolicySourceType.sharedText,
      );
      expect(sharedTextOutcome.capturedSnapshot.sourceLabel, 'Shared text');

      final processTextOutcome = await coordinator.captureIncomingPayload(
        payload: const IncomingIntentPayload(
          kind: 'text',
          sourceAction: 'ACTION_PROCESS_TEXT',
          text: sampleValidPolicy,
        ),
      );
      expect(processTextOutcome, isA<PolicyIntakeSuccess>());
      expect(
        (processTextOutcome as PolicyIntakeSuccess).capturedSnapshot.sourceType,
        PolicySourceType.selectedText,
      );
      expect(processTextOutcome.capturedSnapshot.sourceLabel, 'Selected text');

      final docOutcome = await coordinator.captureIncomingPayload(
        payload: const IncomingIntentPayload(
          kind: 'document',
          sourceAction: 'ACTION_SEND',
          document: DocumentExtractionOutcome(
            status: 'ok',
            documentType: 'docx',
            fileName: 'terms.docx',
            mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            byteLength: 512,
            extractedText: sampleValidPolicy,
            userMessage: 'OK',
          ),
        ),
      );
      expect(docOutcome, isA<PolicyIntakeSuccess>());
      expect(
        (docOutcome as PolicyIntakeSuccess).capturedSnapshot.sourceType,
        PolicySourceType.docx,
      );

      final unhydrated = SelectedAppReference(
        packageName: 'com.example.hydrated',
        appName: 'Hydrated App',
      );
      final hydrated = await coordinator.hydrateAppPermissions(unhydrated);
      expect(fakeBridge.inspectCalls, 1);
      expect(hydrated.permissionSnapshot, isNotNull);
      expect(hydrated.permissionSnapshot!.requestedPermissions, const [
        'android.permission.CAMERA',
      ]);
    });
  });

  group('D5.3-D Phase 1: D5.3-B association integration & object invariants', () {
    test('evaluates unlinked, packageIdentifierMentioned, unmatched, ambiguousIdentity, and sampleFixture strictly', () {
      final coordinator = PolicyIntakeCoordinator(clock: () => fixedClock);

      // 1) No app selected -> unlinked
      final unlinked = coordinator.capturePastedText(
        rawText: sampleValidPolicy,
      ) as PolicyIntakeSuccess;
      expect(
        unlinked.associationReport.state,
        AppPolicyAssociationState.unlinked,
      );
      expect(unlinked.associationReport.provesDeveloperOwnership, isFalse);

      // 2) Selected app + matching exact package ID -> packageIdentifierMentioned
      final matchingApp = SelectedAppReference(
        packageName: 'org.example.focusreader',
        appName: 'Focus Reader',
      );
      final pkgMatched = coordinator.capturePastedText(
        rawText: 'The org.example.focusreader application collects only local reading lists and never sells personal data to third parties.',
        selectedApp: matchingApp,
      ) as PolicyIntakeSuccess;
      expect(
        pkgMatched.associationReport.state,
        AppPolicyAssociationState.packageIdentifierMentioned,
      );
      expect(
        pkgMatched.associationReport.matchedIdentifiers,
        contains('org.example.focusreader'),
      );
      expect(pkgMatched.associationReport.provesDeveloperOwnership, isFalse);

      // 2b) Selected app + distinctive app name mention -> appNameMentioned
      final nameMatched = coordinator.capturePastedText(
        rawText: sampleValidPolicy,
        selectedApp: matchingApp,
      ) as PolicyIntakeSuccess;
      expect(
        nameMatched.associationReport.state,
        AppPolicyAssociationState.appNameMentioned,
      );
      expect(nameMatched.associationReport.provesDeveloperOwnership, isFalse);

      // 2c) Selected app with no mention or conflict -> userLinkedUnverified
      final userLinked = coordinator.capturePastedText(
        rawText: 'This service collects crash logs solely to maintain stability and does not sell data.',
        selectedApp: matchingApp,
      ) as PolicyIntakeSuccess;
      expect(
        userLinked.associationReport.state,
        AppPolicyAssociationState.userLinkedUnverified,
      );
      expect(userLinked.associationReport.provesDeveloperOwnership, isFalse);

      // 3) Conflicting package ID -> unmatched
      final unmatched = coordinator.capturePastedText(
        rawText: 'Privacy policy for com.other.unrelatedapp. We collect crash logs and never sell personal data.',
        selectedApp: matchingApp,
      ) as PolicyIntakeSuccess;
      expect(
        unmatched.associationReport.state,
        AppPolicyAssociationState.unmatched,
      );
      expect(
        unmatched.associationReport.conflictingPackageIdentifiers,
        contains('com.other.unrelatedapp'),
      );
      expect(unmatched.associationReport.provesDeveloperOwnership, isFalse);

      // 4) Ambiguous peer candidates -> ambiguousIdentity
      final ambiguousApp = SelectedAppReference(
        packageName: 'com.alpha.notes',
        appName: 'Focus Reader',
        peerCandidates: const [
          AppIdentityCandidate(
            packageName: 'com.alpha.notes',
            appName: 'Focus Reader',
          ),
          AppIdentityCandidate(
            packageName: 'com.beta.notes',
            appName: 'Focus Reader Pro',
          ),
        ],
      );
      final ambiguous = coordinator.capturePastedText(
        rawText: 'Focus Reader stores notes locally and collects zero analytics or advertising identifiers.',
        selectedApp: ambiguousApp,
      ) as PolicyIntakeSuccess;
      expect(
        ambiguous.associationReport.state,
        AppPolicyAssociationState.ambiguousIdentity,
      );
      expect(ambiguous.associationReport.provesDeveloperOwnership, isFalse);

      // 5) Trusted sample fixture -> sampleFixture ONLY via explicit locator
      final sampleOutcome = coordinator.captureSampleFixture(
        locator: const SampleFixturePolicyLocator(
          fixture: TrustedSampleFixture.eduTrackDemo,
          policyText: 'EduTrack Classroom collects background location and shares telemetry with analytics partners.',
        ),
        permissionSnapshot: const AppPermissionSnapshot(
          packageName: 'com.edutrack.classroom.demo',
          appName: 'EduTrack Classroom Companion',
          requestedPermissions: ['android.permission.ACCESS_FINE_LOCATION'],
          grantedPermissions: ['android.permission.ACCESS_FINE_LOCATION'],
        ),
      ) as PolicyIntakeSuccess;
      expect(
        sampleOutcome.associationReport.state,
        AppPolicyAssociationState.sampleFixture,
      );
      expect(
        sampleOutcome.associationReport.sampleFixture,
        TrustedSampleFixture.eduTrackDemo,
      );
      expect(sampleOutcome.associationReport.provesDeveloperOwnership, isFalse);

      // 6) Non-fixture text mentioning demo package cannot produce sampleFixture
      final spoofAttempt = coordinator.capturePastedText(
        rawText: 'This policy for com.edutrack.classroom.demo explains data collection and retention controls.',
        selectedApp: SelectedAppReference(
          packageName: 'com.edutrack.classroom.demo',
          appName: 'EduTrack Classroom Companion',
        ),
      ) as PolicyIntakeSuccess;
      expect(
        spoofAttempt.associationReport.state,
        AppPolicyAssociationState.packageIdentifierMentioned,
      );
      expect(spoofAttempt.associationReport.sampleFixture, isNull);
    });

    test('enforces strict separation and immutability of domain objects', () {
      final coordinator = PolicyIntakeCoordinator(clock: () => fixedClock);

      final app = SelectedAppReference(
        packageName: 'com.secret.inventory.app',
        appName: 'Secret App',
        permissionSnapshot: const AppPermissionSnapshot(
          packageName: 'com.secret.inventory.app',
          appName: 'Secret App',
          requestedPermissions: [
            'android.permission.READ_CONTACTS',
            'android.permission.RECORD_AUDIO',
          ],
          grantedPermissions: ['android.permission.READ_CONTACTS'],
        ),
        peerCandidates: const [
          AppIdentityCandidate(
            packageName: 'com.other.installed',
            appName: 'Installed Neighbor',
          ),
        ],
      );

      final success = coordinator.capturePastedText(
        rawText: sampleValidPolicy,
        selectedApp: app,
      ) as PolicyIntakeSuccess;

      // App package / permissions / peer inventory never leak into policy prose
      final policyText = success.capturedSnapshot.normalizedPolicyText;
      expect(policyText, isNot(contains('com.secret.inventory.app')));
      expect(policyText, isNot(contains('READ_CONTACTS')));
      expect(policyText, isNot(contains('RECORD_AUDIO')));
      expect(policyText, isNot(contains('com.other.installed')));

      // Peer list on SelectedAppReference is unmodifiable
      expect(
        () => success.selectedApp!.peerCandidates.add(
          const AppIdentityCandidate(packageName: 'com.x', appName: 'X'),
        ),
        throwsUnsupportedError,
      );

      // TextPolicyLocator rejects non-text PolicySourceType
      expect(
        () => TextPolicyLocator(
          rawText: sampleValidPolicy,
          sourceType: PolicySourceType.url,
        ),
        throwsArgumentError,
      );

      // CapturedPolicySnapshot rejects empty/insufficient/unhashed/failed snapshots
      expect(
        () => SelectedAppReference(packageName: '  ', appName: 'Blank Package'),
        throwsArgumentError,
      );
      expect(
        () => SelectedAppReference(
          packageName: 'com.one.app',
          appName: 'One App',
          permissionSnapshot: const AppPermissionSnapshot(
            packageName: 'com.two.app',
            appName: 'Two App',
            requestedPermissions: [],
            grantedPermissions: [],
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => CapturedPolicySnapshot(
          normalizedPolicyText: '   ',
          subjectTitle: 'Title',
          sourceLabel: 'Label',
          sourceSnapshot: success.capturedSnapshot.sourceSnapshot,
          sufficiency: const PolicySufficiencyResult.sufficient(),
        ),
        throwsArgumentError,
      );
      expect(
        () => CapturedPolicySnapshot(
          normalizedPolicyText: sampleValidPolicy,
          subjectTitle: 'Title',
          sourceLabel: 'Label',
          sourceSnapshot: PolicySourceSnapshot(
            snapshotId: 'empty_hash',
            sourceType: PolicySourceType.pastedText,
            retrievedAt: fixedClock,
            retrievalStatus: PolicyRetrievalStatus.localProvided,
            sourceSha256Hash: '',
          ),
          sufficiency: const PolicySufficiencyResult.sufficient(),
        ),
        throwsArgumentError,
      );
      expect(
        () => CapturedPolicySnapshot(
          normalizedPolicyText: sampleValidPolicy,
          subjectTitle: 'Title',
          sourceLabel: 'Label',
          sourceSnapshot: PolicySourceSnapshot(
            snapshotId: 'corrupt_pdf',
            sourceType: PolicySourceType.pdf,
            retrievedAt: fixedClock,
            retrievalStatus: PolicyRetrievalStatus.localProvided,
            sourceSha256Hash: 'abc123',
            extractionStatus: DocumentExtractionStatus.corrupt,
          ),
          sufficiency: const PolicySufficiencyResult.sufficient(),
        ),
        throwsArgumentError,
      );
      expect(
        () => CapturedPolicySnapshot(
          normalizedPolicyText: sampleValidPolicy,
          subjectTitle: 'Title',
          sourceLabel: 'Label',
          sourceSnapshot: PolicySourceSnapshot(
            snapshotId: 'bad_perm',
            sourceType: PolicySourceType.devicePermissions,
            retrievedAt: fixedClock,
            retrievalStatus: PolicyRetrievalStatus.localProvided,
            sourceSha256Hash: 'abc123',
          ),
          sufficiency: const PolicySufficiencyResult.sufficient(),
        ),
        throwsArgumentError,
      );
      expect(
        () => CapturedPolicySnapshot(
          normalizedPolicyText: sampleValidPolicy,
          subjectTitle: 'Title',
          sourceLabel: 'Label',
          sourceSnapshot: PolicySourceSnapshot(
            snapshotId: 'url_local_invalid',
            sourceType: PolicySourceType.url,
            retrievedAt: fixedClock,
            retrievalStatus: PolicyRetrievalStatus.localProvided,
            sourceSha256Hash: 'abc123',
          ),
          sufficiency: const PolicySufficiencyResult.sufficient(),
        ),
        throwsArgumentError,
      );
      expect(
        () => CapturedPolicySnapshot(
          normalizedPolicyText: sampleValidPolicy,
          subjectTitle: 'Title',
          sourceLabel: 'Label',
          sourceSnapshot: PolicySourceSnapshot(
            snapshotId: 'bad_url',
            sourceType: PolicySourceType.url,
            retrievedAt: fixedClock,
            retrievalStatus: PolicyRetrievalStatus.httpError,
            sourceSha256Hash: 'abc123',
          ),
          sufficiency: const PolicySufficiencyResult.sufficient(),
        ),
        throwsArgumentError,
      );
      expect(
        () => CapturedPolicySnapshot(
          normalizedPolicyText: sampleValidPolicy,
          subjectTitle: 'Title',
          sourceLabel: 'Label',
          sourceSnapshot: success.capturedSnapshot.sourceSnapshot,
          sufficiency: const PolicySufficiencyResult.insufficient(
            reason: PolicyInsufficiencyReason.notAPrivacyPolicy,
            explanation: 'Not a policy',
          ),
        ),
        throwsArgumentError,
      );

      // Non-fixture locator cannot claim sampleFixture state or provenance
      expect(
        () => PolicyIntakeSuccess(
          locator: const UrlPolicyLocator(
            rawUrl: 'https://example.org/privacy',
          ),
          capturedSnapshot: success.capturedSnapshot,
          selectedApp: app,
          associationReport: AppPolicyAssociationReport(
            state: AppPolicyAssociationState.sampleFixture,
            sampleFixture: TrustedSampleFixture.eduTrackDemo,
            explanation: 'Spoof',
            ownershipLimitationNotice:
                AppPolicyAssociationReport.defaultOwnershipLimitationNotice,
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => PolicyIntakeSuccess(
          locator: TextPolicyLocator(
            rawText: sampleValidPolicy,
            sourceType: PolicySourceType.pastedText,
          ),
          capturedSnapshot: CapturedPolicySnapshot(
            normalizedPolicyText: sampleValidPolicy,
            subjectTitle: 'Spoofed',
            sourceLabel: 'Pasted policy text',
            sourceSnapshot: PolicySourceSnapshot(
              snapshotId: 'spoof_snap',
              sourceType: PolicySourceType.sample,
              retrievedAt: fixedClock,
              retrievalStatus: PolicyRetrievalStatus.localProvided,
              appIdentityMatchStatus: AppIdentityMatchStatus.sampleFixture,
              sourceSha256Hash: EvidenceValidator.computeSha256SourceHash(
                sampleValidPolicy,
              ),
            ),
            sufficiency: const PolicySufficiencyResult.sufficient(),
          ),
          selectedApp: app,
          associationReport: success.associationReport,
        ),
        throwsArgumentError,
      );
    });
  });
}
