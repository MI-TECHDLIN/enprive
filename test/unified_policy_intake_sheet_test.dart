import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/intake/policy_intake_models.dart';
import 'package:enprive/domain/review/app_policy_association.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/services/intake/policy_intake_coordinator.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';
import 'package:enprive/services/platform/companion_bridge.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/intake/unified_policy_intake_sheet.dart';

class _FakeDocBridge implements PolicyDocumentPlatformBridge {
  int pickCalls = 0;
  Future<DocumentExtractionOutcome> Function()? onPick;

  @override
  Future<DocumentExtractionOutcome> pickAndExtractDocument() async {
    pickCalls++;
    if (onPick != null) return onPick!();
    return const DocumentExtractionOutcome(
      status: 'cancelled',
      extractedText: '',
      userMessage: 'No document was selected.',
    );
  }

  @override
  Future<AppPermissionSnapshot?> inspectAppSnapshot(String packageName) async =>
      null;
}

class _SpyClient extends http.BaseClient {
  final http.Client _inner;
  final void Function() _onClose;

  _SpyClient(this._inner, this._onClose);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request);

  @override
  void close() {
    _onClose();
    _inner.close();
  }
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

Future<void> _flush(WidgetTester tester, {int steps = 4}) async {
  await tester.pump();
  for (var i = 0; i < steps; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 80));
  }
}

double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

List<SemanticsNode> _collectSemantics(WidgetTester tester, Finder rootFinder) {
  final owner = tester.renderObject(rootFinder).owner!.semanticsOwner!;
  final nodes = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    nodes.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(owner.rootSemanticsNode!);
  return nodes;
}

Widget _buildSheetApp({
  required PolicyIntakeSheetConfig config,
  void Function(PolicyIntakeSuccess? result)? onResult,
  bool embedded = false,
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size? screenSize,
}) {
  final activeData = themeMode == ThemeMode.dark
      ? EnpriveM3ETheme.darkThemeData
      : EnpriveM3ETheme.lightThemeData;

  final app = M3EMaterialApp(
    data: activeData,
    typeface: EnpriveM3ETheme.typefaceConfig,
    autoTheming: false,
    dynamicColoring: false,
    initialTheme: activeData.brightness,
    theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
    darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
    locale: locale,
    localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    appBuilder: (context, child) {
      final media = MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale));
      return MediaQuery(
        data: media,
        child: EnpriveM3EBridgeScope(
          themeMode: themeMode,
          child: child ?? const SizedBox.shrink(),
        ),
      );
    },
    home: Builder(
      builder: (context) => Scaffold(
        body: embedded
            ? UnifiedPolicyIntakeSheet(config: config)
            : Center(
                child: ElevatedButton(
                  key: const Key('open_unified_intake_btn'),
                  onPressed: () async {
                    final outcome = await UnifiedPolicyIntakeSheet.show(
                      context,
                      config: config,
                    );
                    onResult?.call(outcome);
                  },
                  child: const Text('Open Intake'),
                ),
              ),
      ),
    ),
  );

  if (screenSize == null) return app;
  return MediaQuery(
    data: MediaQueryData(
      size: screenSize,
      textScaler: TextScaler.linear(textScale),
    ),
    child: app,
  );
}

void main() {
  final fakePublicIp = InternetAddress('93.184.216.34');
  Future<List<InternetAddress>> publicDns(String host) async => [fakePublicIp];
  final fixedClock = DateTime.utc(2026, 11, 19, 15, 0, 0);

  const validPolicyText =
      'Focus Reader collects only account email addresses for cloud backup and never sells personal data to advertisers or third parties. Parents may delete data anytime.';

  PolicyIntakeCoordinator makeCoordinator({
    http.Client Function()? clientFactory,
    PolicyDocumentPlatformBridge? documentBridge,
  }) {
    return PolicyIntakeCoordinator(
      urlRetriever: PolicyUrlRetriever(
        dnsLookup: publicDns,
        clock: () => fixedClock,
        clientFactory:
            clientFactory ??
            () => MockClient((_) async => http.Response('Not Found', 404)),
      ),
      documentBridge: documentBridge,
      clock: () => fixedClock,
    );
  }

  group('D5.3-D Phase 2: Input modes, submission & CTA distinction', () {
    testWidgets(
      '1. supports Paste, URL, and Document acquisition with distinct mode CTAs and zero CloudConsentSheet/sample collision',
      (WidgetTester tester) async {
        final fakeDocs = _FakeDocBridge()
          ..onPick = () async => const DocumentExtractionOutcome(
            status: 'ok',
            documentType: 'pdf',
            fileName: 'policy_terms.pdf',
            mimeType: 'application/pdf',
            byteLength: 2048,
            extractedText: validPolicyText,
            userMessage: 'Extracted cleanly.',
          );
        final coordinator = makeCoordinator(
          documentBridge: fakeDocs,
          clientFactory: () => MockClient(
            (_) async => http.Response(
              '<html><body><main><p>$validPolicyText</p></main></body></html>',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            ),
          ),
        );

        PolicyIntakeSuccess? pasteOutcome;
        PolicyIntakeSuccess? urlOutcome;
        PolicyIntakeSuccess? docOutcome;

        // 1a) Paste text
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(coordinator: coordinator),
            onResult: (r) => pasteOutcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        expect(find.text('Inspect policy text'), findsOneWidget);
        expect(find.text('Review on this phone'), findsNothing);
        expect(find.text('Try sample text'), findsNothing);

        await tester.enterText(
          find.byKey(const Key('intake_title_field')),
          'Focus App',
        );
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          validPolicyText,
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _flush(tester);

        expect(pasteOutcome, isNotNull);
        expect(pasteOutcome!.locator, isA<TextPolicyLocator>());
        expect(
          pasteOutcome!.capturedSnapshot.sourceType,
          PolicySourceType.pastedText,
        );
        expect(pasteOutcome!.capturedSnapshot.subjectTitle, 'Focus App');
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);

        // 1b) URL mode
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(coordinator: coordinator),
            onResult: (r) => urlOutcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        await tester.tap(find.text('Policy link'));
        await _flush(tester);
        expect(find.text('Fetch & inspect policy'), findsOneWidget);
        expect(find.text('Review on this phone'), findsNothing);

        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://example.org/privacy',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _flush(tester);

        expect(urlOutcome, isNotNull);
        expect(urlOutcome!.locator, isA<UrlPolicyLocator>());
        expect(
          urlOutcome!.capturedSnapshot.sourceLabel,
          'https://example.org/privacy',
        );
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);

        // 1c) Document mode
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(coordinator: coordinator),
            onResult: (r) => docOutcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        await tester.tap(find.text('Document'));
        await _flush(tester);
        expect(find.text('Choose PDF, TXT, or DOCX'), findsOneWidget);

        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _flush(tester);

        expect(fakeDocs.pickCalls, 1);
        expect(docOutcome, isNotNull);
        expect(docOutcome!.locator, isA<DocumentPolicyLocator>());
        expect(docOutcome!.capturedSnapshot.sourceType, PolicySourceType.pdf);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
      },
    );
  });

  group('D5.3-D Phase 2: Input preservation, failures & recovery', () {
    testWidgets(
      '2. keeps sheet open and preserves URL, title, and app selection on URL failure',
      (WidgetTester tester) async {
        final coordinator = makeCoordinator(
          clientFactory: () =>
              MockClient((_) async => http.Response('Missing', 404)),
        );
        final selectedApp = SelectedAppReference(
          packageName: 'com.example.focus',
          appName: 'Focus Reader',
        );
        PolicyIntakeSuccess? result;

        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialSelectedApp: selectedApp,
              onSelectInstalledApp: (_) async => selectedApp,
            ),
            onResult: (r) => result = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        await tester.tap(find.text('Policy link'));
        await _flush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_title_field')),
          'Kept App Title',
        );
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://example.org/broken-404',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _flush(tester);

        expect(result, isNull);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(find.textContaining('404'), findsWidgets);
        expect(
          find.byKey(const Key('intake_recovery_retry_btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('intake_recovery_paste_btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('intake_recovery_doc_btn')),
          findsOneWidget,
        );

        // Verify typed URL, title, and selected app remain intact
        final urlField = tester.widget<TextField>(
          find.byKey(const Key('intake_url_field')),
        );
        final titleField = tester.widget<TextField>(
          find.byKey(const Key('intake_title_field')),
        );
        expect(urlField.controller!.text, 'https://example.org/broken-404');
        expect(titleField.controller!.text, 'Kept App Title');
        expect(
          find.byKey(const Key('intake_selected_app_card')),
          findsOneWidget,
        );
        expect(find.text('com.example.focus'), findsOneWidget);
      },
    );

    testWidgets(
      '2b. omits Retry fetch for blocked host, invalid URL, and oversized URL while keeping Retry for transient failures',
      (WidgetTester tester) async {
        var timeoutAttempts = 0;
        var networkAttempts = 0;
        final coordinator = PolicyIntakeCoordinator(
          urlRetriever: PolicyUrlRetriever(
            dnsLookup: publicDns,
            maxResponseBytes: 512,
            clock: () => fixedClock,
            clientFactory: () => MockClient((request) async {
              if (request.url.path == '/huge') {
                return http.Response(
                  'A' * 1024,
                  200,
                  headers: {'content-type': 'text/plain'},
                );
              }
              if (request.url.path == '/network-error') {
                networkAttempts++;
                throw const SocketException('Simulated connection drop');
              }
              if (request.url.path == '/flaky-timeout') {
                timeoutAttempts++;
                if (timeoutAttempts == 1) {
                  throw TimeoutException('Simulated timeout');
                }
                return http.Response(
                  '<html><body><p>$validPolicyText</p></body></html>',
                  200,
                  headers: {'content-type': 'text/html'},
                );
              }
              return http.Response('Not Found', 404);
            }),
          ),
          clock: () => fixedClock,
        );

        PolicyIntakeSuccess? outcome;
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialMode: PolicyIntakeMode.url,
            ),
            onResult: (r) => outcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        final urlFieldFinder = find.byKey(const Key('intake_url_field'));
        final submitBtnFinder = find.byKey(
          const Key('intake_primary_submit_btn'),
        );
        final editUrlBtnFinder = find.byKey(
          const Key('intake_recovery_edit_url_btn'),
        );
        final retryBtnFinder = find.byKey(
          const Key('intake_recovery_retry_btn'),
        );

        // 1) SSRF-blocked loopback host: no Retry fetch; Edit URL / Paste / Document offered
        await tester.enterText(urlFieldFinder, 'http://127.0.0.1/privacy');
        await _tapVisible(tester, submitBtnFinder);
        await _flush(tester);

        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(retryBtnFinder, findsNothing);
        expect(editUrlBtnFinder, findsOneWidget);
        expect(find.byKey(const Key('intake_recovery_paste_btn')), findsOneWidget);
        expect(find.byKey(const Key('intake_recovery_doc_btn')), findsOneWidget);
        expect(
          tester.getSize(editUrlBtnFinder).height,
          greaterThanOrEqualTo(48.0),
        );

        // Tapping Edit URL focuses and selects the URL field so user can replace it
        final urlFieldWidget = tester.widget<TextField>(urlFieldFinder);
        urlFieldWidget.focusNode!.unfocus();
        await tester.pump();
        expect(urlFieldWidget.focusNode!.hasFocus, isFalse);

        await _tapVisible(tester, editUrlBtnFinder);
        await tester.pump();
        expect(urlFieldWidget.focusNode!.hasFocus, isTrue);
        expect(urlFieldWidget.controller!.text, 'http://127.0.0.1/privacy');
        expect(
          urlFieldWidget.controller!.selection,
          const TextSelection(baseOffset: 0, extentOffset: 24),
        );

        // 2) Invalid URL: no Retry fetch; Edit URL / Paste / Document offered
        await tester.enterText(urlFieldFinder, 'ftp://example.org/privacy');
        await _tapVisible(tester, submitBtnFinder);
        await _flush(tester);

        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(retryBtnFinder, findsNothing);
        expect(editUrlBtnFinder, findsOneWidget);
        expect(find.byKey(const Key('intake_recovery_paste_btn')), findsOneWidget);
        expect(find.byKey(const Key('intake_recovery_doc_btn')), findsOneWidget);

        // 3) Oversized URL: no Retry fetch; Edit URL / Paste / Document offered
        await tester.enterText(urlFieldFinder, 'https://example.org/huge');
        await _tapVisible(tester, submitBtnFinder);
        await _flush(tester);

        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(retryBtnFinder, findsNothing);
        expect(editUrlBtnFinder, findsOneWidget);

        // 4) Transient network error: Retry fetch IS offered (no Edit URL replacement)
        await tester.enterText(
          urlFieldFinder,
          'https://example.org/network-error',
        );
        await _tapVisible(tester, submitBtnFinder);
        await _flush(tester);

        expect(networkAttempts, 1);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(retryBtnFinder, findsOneWidget);
        expect(editUrlBtnFinder, findsNothing);

        // 5) Transient timeout: Retry fetch IS offered and succeeds on retry
        await tester.enterText(
          urlFieldFinder,
          'https://example.org/flaky-timeout',
        );
        await _tapVisible(tester, submitBtnFinder);
        await _flush(tester);

        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(retryBtnFinder, findsOneWidget);
        expect(editUrlBtnFinder, findsNothing);

        await _tapVisible(tester, retryBtnFinder);
        await _flush(tester);

        expect(timeoutAttempts, 2);
        expect(outcome, isNotNull);
        expect(
          outcome!.capturedSnapshot.sourceLabel,
          'https://example.org/flaky-timeout',
        );
      },
    );

    testWidgets(
      '3. keeps sheet open and preserves insufficient pasted text with mode-switch recovery',
      (WidgetTester tester) async {
        final coordinator = makeCoordinator();
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(coordinator: coordinator),
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        await tester.enterText(
          find.byKey(const Key('intake_title_field')),
          'Short App',
        );
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Privacy policy unavailable.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _flush(tester);

        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_paste_field')))
              .controller!
              .text,
          'Privacy policy unavailable.',
        );
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_title_field')))
              .controller!
              .text,
          'Short App',
        );

        // Recovery switch to URL keeps sheet interactive
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_recovery_url_btn')),
        );
        await _flush(tester);
        expect(find.byKey(const Key('intake_url_field')), findsOneWidget);
      },
    );

    testWidgets(
      '4. document failure recovers via replacement pick and picker cancel shows no false error',
      (WidgetTester tester) async {
        var pickAttempt = 0;
        final fakeDocs = _FakeDocBridge()
          ..onPick = () async {
            pickAttempt++;
            if (pickAttempt == 1) {
              return const DocumentExtractionOutcome(
                status: 'cancelled',
                extractedText: '',
                userMessage: 'No document was selected.',
              );
            }
            if (pickAttempt == 2) {
              return const DocumentExtractionOutcome(
                status: 'password_protected',
                documentType: 'pdf',
                fileName: 'locked.pdf',
                mimeType: 'application/pdf',
                byteLength: 512,
                extractedText: '',
                userMessage: 'This PDF is password-protected.',
              );
            }
            return const DocumentExtractionOutcome(
              status: 'ok',
              documentType: 'docx',
              fileName: 'replacement.docx',
              mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              byteLength: 1024,
              extractedText: validPolicyText,
              userMessage: 'Extracted cleanly.',
            );
          };
        final coordinator = makeCoordinator(documentBridge: fakeDocs);
        PolicyIntakeSuccess? outcome;

        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialMode: PolicyIntakeMode.document,
            ),
            onResult: (r) => outcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        // Attempt 1: cancelled picker -> no error banner
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _flush(tester);
        expect(find.byKey(const Key('intake_error_banner')), findsNothing);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);

        // Attempt 2: password-protected -> inline error + switch recovery visible
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _flush(tester);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(find.text('This PDF is password-protected.'), findsOneWidget);

        // Attempt 3: replacement document succeeds
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _flush(tester);
        expect(outcome, isNotNull);
        expect(outcome!.capturedSnapshot.sourceType, PolicySourceType.docx);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
      },
    );
  });

  group('D5.3-D Phase 2: Busy guards, cancellation & dismissal', () {
    testWidgets(
      '5. prevents duplicate submissions, locks mode switch while busy, supports Cancel fetch, and cancels on dismiss',
      (WidgetTester tester) async {
        var sendCount = 0;
        var closeCount = 0;
        Completer<http.Response>? firstGate;
        Completer<http.Response>? secondGate;
        Completer<DocumentExtractionOutcome>? docGate;
        final fakeDocs = _FakeDocBridge()
          ..onPick = () {
            docGate = Completer<DocumentExtractionOutcome>();
            return docGate!.future;
          };

        final coordinator = makeCoordinator(
          documentBridge: fakeDocs,
          clientFactory: () => _SpyClient(
            MockClient((request) async {
              sendCount++;
              if (sendCount == 1) {
                firstGate = Completer<http.Response>();
                return firstGate!.future;
              }
              secondGate = Completer<http.Response>();
              return secondGate!.future;
            }),
            () => closeCount++,
          ),
        );

        PolicyIntakeSuccess? result;
        var callbackCount = 0;

        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialMode: PolicyIntakeMode.url,
            ),
            onResult: (r) {
              callbackCount++;
              result = r;
            },
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://slow.example.org/privacy',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.pump();
        await tester.pump();

        // Busy state: Working... and Cancel fetch visible; duplicate tap and mode switch ignored
        expect(find.text('Working…'), findsOneWidget);
        expect(
          find.byKey(const Key('intake_cancel_fetch_btn')),
          findsOneWidget,
        );
        expect(sendCount, 1);

        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.tap(find.text('Paste text'));
        await tester.pump();

        expect(sendCount, 1);
        expect(find.byKey(const Key('intake_url_field')), findsOneWidget);

        // Explicit Cancel fetch cancels HTTP client, keeps URL, ignores late response
        await tester.tap(find.byKey(const Key('intake_cancel_fetch_btn')));
        await _flush(tester);
        expect(closeCount, 1);
        expect(find.byKey(const Key('intake_url_field')), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_url_field')))
              .controller!
              .text,
          'https://slow.example.org/privacy',
        );

        firstGate!.complete(
          http.Response(
            '<html><body><p>$validPolicyText</p></body></html>',
            200,
            headers: {'content-type': 'text/html'},
          ),
        );
        await _flush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(callbackCount, 0);

        // Start second fetch and dismiss sheet via Close while active -> cancels client and returns null
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.pump();
        await tester.pump();
        expect(sendCount, 2);

        await tester.tap(find.byKey(const Key('intake_close_btn')));
        await _flush(tester);
        expect(closeCount, 2);
        expect(callbackCount, 1);
        expect(result, isNull);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);

        secondGate!.complete(
          http.Response(
            '<html><body><p>$validPolicyText</p></body></html>',
            200,
            headers: {'content-type': 'text/html'},
          ),
        );
        await _flush(tester);

        // Start third fetch and dismiss by tapping the modal barrier scrim
        callbackCount = 0;
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://scrim.example.org/privacy',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.pump();
        await tester.pump();
        expect(sendCount, 3);

        await tester.tapAt(const Offset(10, 10));
        await _flush(tester);
        expect(closeCount, 3);
        expect(callbackCount, 1);
        expect(result, isNull);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        secondGate!.complete(http.Response('Late', 200));
        await _flush(tester);

        // Document-mode busy guard locks duplicate picker taps & mode switching,
        // and user dismissal returns calmly to idle without an error banner.
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);
        await tester.tap(find.text('Document'));
        await tester.pump();
        expect(
          find.byKey(const Key('intake_document_info_card')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.pump();
        expect(fakeDocs.pickCalls, 1);
        expect(find.text('Working…'), findsOneWidget);

        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.tap(find.text('Paste text'));
        await tester.pump();
        expect(fakeDocs.pickCalls, 1);
        expect(
          find.byKey(const Key('intake_document_info_card')),
          findsOneWidget,
        );

        docGate!.complete(
          const DocumentExtractionOutcome(
            status: 'cancelled',
            extractedText: '',
            userMessage: 'No document was selected.',
          ),
        );
        await _flush(tester);
        expect(find.text('Working…'), findsNothing);
        expect(find.byKey(const Key('intake_error_banner')), findsNothing);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);

        // System Back during active URL fetch cancels HTTP client & returns null
        await tester.tap(find.text('Policy link'));
        await _flush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://back.example.org/privacy',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.pump();
        await tester.pump();
        expect(sendCount, 4);

        await tester.binding.handlePopRoute();
        await _flush(tester);
        expect(closeCount, 4);
        expect(callbackCount, 2);
        expect(result, isNull);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        secondGate!.complete(
          http.Response(
            '<html><body><p>$validPolicyText</p></body></html>',
            200,
            headers: {'content-type': 'text/html'},
          ),
        );
        await _flush(tester);
        expect(callbackCount, 2);
        expect(
          find.byKey(const Key('open_unified_intake_btn')),
          findsOneWidget,
        );

        // Late Document picker completion after disposal + double-tap close guard
        callbackCount = 0;
        result = null;
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);
        await tester.tap(find.text('Document'));
        await tester.pump();
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.pump();
        expect(fakeDocs.pickCalls, 2);

        // Rapid double-invocation on X pops only the modal once, leaving parent intact
        final closeAction = tester
            .widget<IconButton>(find.byKey(const Key('intake_close_btn')))
            .onPressed!;
        closeAction();
        closeAction();
        await _flush(tester);
        expect(callbackCount, 1);
        expect(result, isNull);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        expect(
          find.byKey(const Key('open_unified_intake_btn')),
          findsOneWidget,
        );

        // Late document completion after route disposal triggers no setState/pop
        docGate!.complete(
          const DocumentExtractionOutcome(
            status: 'ok',
            documentType: 'pdf',
            fileName: 'late.pdf',
            mimeType: 'application/pdf',
            byteLength: 1024,
            extractedText: validPolicyText,
            userMessage: 'OK',
          ),
        );
        await _flush(tester);
        expect(callbackCount, 1);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group(
    'D5.3-D Phase 2: Prefilled OS & failure-recovery entry configurations',
    () {
      testWidgets(
        '6. preserves prefilled ACTION_SEND shared text and ACTION_PROCESS_TEXT selected text',
        (WidgetTester tester) async {
          final coordinator = makeCoordinator();
          PolicyIntakeSuccess? sharedResult;
          PolicyIntakeSuccess? selectedResult;

          await tester.pumpWidget(
            _buildSheetApp(
              config: PolicyIntakeSheetConfig(
                coordinator: coordinator,
                initialLocator: TextPolicyLocator(
                  rawText: validPolicyText,
                  sourceType: PolicySourceType.sharedText,
                  userSubjectTitle: 'Shared App',
                  sourceAction: 'ACTION_SEND',
                ),
              ),
              onResult: (r) => sharedResult = r,
            ),
          );
          await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
          await _flush(tester);
          await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
          await _flush(tester);

          expect(sharedResult, isNotNull);
          expect(
            sharedResult!.capturedSnapshot.sourceType,
            PolicySourceType.sharedText,
          );
          expect(
            (sharedResult!.locator as TextPolicyLocator).sourceAction,
            'ACTION_SEND',
          );

          await tester.pumpWidget(
            _buildSheetApp(
              config: PolicyIntakeSheetConfig(
                coordinator: coordinator,
                initialLocator: TextPolicyLocator(
                  rawText: validPolicyText,
                  sourceType: PolicySourceType.selectedText,
                  sourceAction: 'ACTION_PROCESS_TEXT',
                ),
              ),
              onResult: (r) => selectedResult = r,
            ),
          );
          await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
          await _flush(tester);
          await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
          await _flush(tester);

          expect(selectedResult, isNotNull);
          expect(
            selectedResult!.capturedSnapshot.sourceType,
            PolicySourceType.selectedText,
          );
          expect(
            (selectedResult!.locator as TextPolicyLocator).sourceAction,
            'ACTION_PROCESS_TEXT',
          );
        },
      );

      testWidgets(
        '7. supports initial failed URL edit-and-retry recovery and expired incoming document replacement',
        (WidgetTester tester) async {
          final fakeDocs = _FakeDocBridge()
            ..onPick = () async => const DocumentExtractionOutcome(
              status: 'ok',
              documentType: 'txt',
              fileName: 'fresh.txt',
              mimeType: 'text/plain',
              byteLength: 512,
              extractedText: validPolicyText,
              userMessage: 'OK',
            );
          final coordinator = makeCoordinator(
            documentBridge: fakeDocs,
            clientFactory: () => MockClient((request) async {
              if (request.url.path == '/fixed-privacy') {
                return http.Response(
                  '<html><body><p>$validPolicyText</p></body></html>',
                  200,
                  headers: {'content-type': 'text/html'},
                );
              }
              return http.Response('Not Found', 404);
            }),
          );

          // 7a) Recoverable headless URL failure prefill
          PolicyIntakeSuccess? recoveredUrlOutcome;
          await tester.pumpWidget(
            _buildSheetApp(
              config: PolicyIntakeSheetConfig(
                coordinator: coordinator,
                initialFailure: const PolicyIntakeFailure(
                  kind: PolicyIntakeFailureKind.httpError,
                  locator: UrlPolicyLocator(
                    rawUrl: 'https://example.org/typo',
                    userSubjectTitle: 'Example App',
                    sourceAction: 'ACTION_SEND',
                  ),
                  userMessage: 'The server returned HTTP 404.',
                  recoveryHint: 'Check the web address or paste text instead.',
                  canRetrySameLocator: true,
                ),
              ),
              onResult: (r) => recoveredUrlOutcome = r,
            ),
          );
          await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
          await _flush(tester);

          expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
          expect(find.text('The server returned HTTP 404.'), findsOneWidget);
          expect(
            tester
                .widget<TextField>(find.byKey(const Key('intake_url_field')))
                .controller!
                .text,
            'https://example.org/typo',
          );

          await tester.enterText(
            find.byKey(const Key('intake_url_field')),
            'https://example.org/fixed-privacy',
          );
          await _tapVisible(
            tester,
            find.byKey(const Key('intake_primary_submit_btn')),
          );
          await _flush(tester);

          expect(recoveredUrlOutcome, isNotNull);
          expect(
            recoveredUrlOutcome!.capturedSnapshot.sourceLabel,
            'https://example.org/fixed-privacy',
          );

          // 7b) Expired incoming document URI failure
          PolicyIntakeSuccess? replacementDocOutcome;
          await tester.pumpWidget(
            _buildSheetApp(
              config: PolicyIntakeSheetConfig(
                coordinator: coordinator,
                initialFailure: const PolicyIntakeFailure(
                  kind: PolicyIntakeFailureKind.documentPermissionDenied,
                  locator: DocumentPolicyLocator(
                    fileName: 'shared_old.pdf',
                    mimeType: 'application/pdf',
                    sourceAction: 'ACTION_SEND',
                    isPreExtractedIncomingShare: true,
                  ),
                  userMessage: 'Permission to read shared_old.pdf expired.',
                  recoveryHint: 'Select another file inside Enprive.',
                  canRetrySameLocator: false,
                ),
              ),
              onResult: (r) => replacementDocOutcome = r,
            ),
          );
          await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
          await _flush(tester);

          expect(find.text('Choose replacement document'), findsOneWidget);
          expect(
            find.textContaining(
              'The originally shared file link can no longer be reopened',
            ),
            findsOneWidget,
          );
          await _tapVisible(
            tester,
            find.byKey(const Key('intake_primary_submit_btn')),
          );
          await _flush(tester);

          expect(fakeDocs.pickCalls, 1);
          expect(replacementDocOutcome, isNotNull);
          expect(
            replacementDocOutcome!.capturedSnapshot.sourceType,
            PolicySourceType.textDocument,
          );
          expect(
            (replacementDocOutcome!.locator as DocumentPolicyLocator)
                .isPreExtractedIncomingShare,
            isFalse,
          );
        },
      );
    },
  );

  group('D5.3-D Phase 2: App selection, locked context, association warnings & Play Store', () {
    testWidgets(
      '8. supports policy-first optional app select, change, removal, and unmatched association recovery actions',
      (WidgetTester tester) async {
        final coordinator = makeCoordinator();
        var selectCalls = 0;
        final appOne = SelectedAppReference(
          packageName: 'com.alpha.notes',
          appName: 'Alpha Notes',
        );
        final appTwo = SelectedAppReference(
          packageName: 'org.example.focusreader',
          appName: 'Focus Reader',
        );

        PolicyIntakeSuccess? outcome;
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              onSelectInstalledApp: (_) async {
                selectCalls++;
                return selectCalls == 1 ? appOne : appTwo;
              },
            ),
            onResult: (r) => outcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        // Select appOne -> change -> remove -> select appTwo
        await tester.tap(find.byKey(const Key('intake_select_app_btn')));
        await _flush(tester);
        expect(find.text('Alpha Notes'), findsOneWidget);
        expect(find.text('com.alpha.notes'), findsOneWidget);

        await tester.tap(find.byKey(const Key('intake_change_app_btn')));
        await _flush(tester);
        expect(find.text('Focus Reader'), findsOneWidget);
        expect(find.text('com.alpha.notes'), findsNothing);

        await tester.tap(find.byKey(const Key('intake_remove_app_btn')));
        await _flush(tester);
        expect(find.byKey(const Key('intake_select_app_btn')), findsOneWidget);

        // Submitting after optional app removal produces standalone unlinked result
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          validPolicyText,
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _flush(tester);
        expect(outcome, isNotNull);
        expect(outcome!.selectedApp, isNull);
        expect(
          outcome!.associationReport.state,
          AppPolicyAssociationState.unlinked,
        );
        expect(
          outcome!.capturedSnapshot.sourceSnapshot.appIdentityMatchStatus,
          AppIdentityMatchStatus.notApplicable,
        );

        // Re-open, select appTwo, supply policy mentioning a DIFFERENT package -> unmatched warning
        outcome = null;
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_select_app_btn')),
        );
        await _flush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'This privacy policy for com.different.publisher explains data collection and deletion controls.',
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _flush(tester);

        expect(outcome, isNull);
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );
        expect(
          find.textContaining('do not verify developer ownership'),
          findsOneWidget,
        );
        expect(find.textContaining('Verified developer'), findsNothing);
        expect(find.textContaining('Official policy'), findsNothing);
        expect(find.textContaining('Trusted policy owner'), findsNothing);
        expect(
          find.byKey(const Key('intake_association_continue_btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('intake_association_change_app_btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('intake_association_without_app_btn')),
          findsOneWidget,
        );

        // Choose "Inspect policy without app" -> returns unlinked result
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_association_without_app_btn')),
        );
        await _flush(tester);
        expect(outcome, isNotNull);
        expect(outcome!.selectedApp, isNull);
        expect(
          outcome!.associationReport.state,
          AppPolicyAssociationState.unlinked,
        );
        expect(
          outcome!.capturedSnapshot.sourceSnapshot.appIdentityMatchStatus,
          AppIdentityMatchStatus.notApplicable,
        );

        // URL mode "Inspect policy without app" clears app association and returns unlinked
        final urlCoordinator = makeCoordinator(
          clientFactory: () => MockClient(
            (_) async => http.Response(
              '<html><body><p>This privacy policy for com.different.publisher covers account emails and user deletion controls clearly.</p></body></html>',
              200,
              headers: {'content-type': 'text/html'},
            ),
          ),
        );
        outcome = null;
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: urlCoordinator,
              initialMode: PolicyIntakeMode.url,
              initialSelectedApp: appOne,
              onSelectInstalledApp: (_) async => appTwo,
            ),
            onResult: (r) => outcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://example.org/other-app-privacy',
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _flush(tester);
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_association_without_app_btn')),
        );
        await _flush(tester);
        expect(outcome, isNotNull);
        expect(outcome!.selectedApp, isNull);
        expect(
          outcome!.associationReport.state,
          AppPolicyAssociationState.unlinked,
        );
        expect(
          outcome!.capturedSnapshot.sourceSnapshot.appIdentityMatchStatus,
          AppIdentityMatchStatus.notApplicable,
        );

        // Genuine ambiguousIdentity peer candidates + Continue anyway
        final ambiguousApp = SelectedAppReference(
          packageName: 'com.alpha.reader',
          appName: 'Focus Reader',
          peerCandidates: const [
            AppIdentityCandidate(
              packageName: 'com.alpha.reader',
              appName: 'Focus Reader',
            ),
            AppIdentityCandidate(
              packageName: 'com.beta.reader',
              appName: 'Focus Reader Pro',
            ),
          ],
        );
        outcome = null;
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialSelectedApp: ambiguousApp,
              onSelectInstalledApp: (_) async => appTwo,
            ),
            onResult: (r) => outcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Focus Reader collects only account emails for cloud sync and lets users delete data anytime.',
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _flush(tester);
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );
        expect(
          find.textContaining('do not verify developer ownership'),
          findsOneWidget,
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_association_continue_btn')),
        );
        await _flush(tester);
        expect(outcome, isNotNull);
        expect(
          outcome!.associationReport.state,
          AppPolicyAssociationState.ambiguousIdentity,
        );
        expect(outcome!.associationReport.provesDeveloperOwnership, isFalse);

        // Change selected app triggers fresh association evaluation matching newly picked app
        outcome = null;
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialSelectedApp: appOne,
              onSelectInstalledApp: (_) async => appTwo,
            ),
            onResult: (r) => outcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'This privacy policy for org.example.focusreader explains data collection, retention, and deletion rights clearly.',
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _flush(tester);
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );

        await _tapVisible(
          tester,
          find.byKey(const Key('intake_association_change_app_btn')),
        );
        await _flush(tester);
        expect(find.text('org.example.focusreader'), findsOneWidget);
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsNothing,
        );

        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _flush(tester);
        expect(outcome, isNotNull);
        expect(outcome!.selectedApp?.packageName, 'org.example.focusreader');
        expect(
          outcome!.associationReport.state,
          AppPolicyAssociationState.packageIdentifierMentioned,
        );
        expect(outcome!.associationReport.provesDeveloperOwnership, isFalse);

        // Locked app context with unmatched warning hides Change/Without-app and preserves lock
        outcome = null;
        final lockedUnmatchedApp = SelectedAppReference(
          packageName: 'com.locked.app',
          appName: 'Locked App',
          isLocked: true,
        );
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialSelectedApp: lockedUnmatchedApp,
              onSelectInstalledApp: (_) async => appTwo,
            ),
            onResult: (r) => outcome = r,
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'This privacy policy for com.other.unrelated explains data collection and deletion controls.',
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_primary_submit_btn')),
        );
        await _flush(tester);
        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('intake_association_continue_btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('intake_association_change_app_btn')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('intake_association_without_app_btn')),
          findsNothing,
        );
        await _tapVisible(
          tester,
          find.byKey(const Key('intake_association_continue_btn')),
        );
        await _flush(tester);
        expect(outcome, isNotNull);
        expect(outcome!.selectedApp?.isLocked, isTrue);
        expect(
          outcome!.associationReport.state,
          AppPolicyAssociationState.unmatched,
        );
      },
    );

    testWidgets(
      '9. enforces locked app context and Play Store callback/CompanionBridge paths preserve state without scraping',
      (WidgetTester tester) async {
        var sendCount = 0;
        final coordinator = makeCoordinator(
          clientFactory: () => MockClient((_) async {
            sendCount++;
            return http.Response('Missing', 404);
          }),
        );
        final playStorePackages = <String>[];
        var returnUnavailable = false;

        final lockedApp = SelectedAppReference(
          packageName: 'com.school.classroom',
          appName: 'Classroom Companion',
          permissionSnapshot: const AppPermissionSnapshot(
            packageName: 'com.school.classroom',
            appName: 'Classroom Companion',
            requestedPermissions: ['android.permission.CAMERA'],
            grantedPermissions: ['android.permission.CAMERA'],
          ),
          isLocked: true,
        );

        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialSelectedApp: lockedApp,
              initialMode: PolicyIntakeMode.paste,
              onOpenPlayStoreListing: (pkg) async {
                playStorePackages.add(pkg);
                return ExternalAppNavigationResult(
                  status: returnUnavailable
                      ? ExternalAppNavigationStatus.activityNotFound
                      : ExternalAppNavigationStatus.openedStore,
                  packageName: pkg,
                );
              },
            ),
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        // Locked header shown, title & switcher hidden, Play Store hidden in Paste mode,
        // permission IDs never injected into policy input.
        expect(
          find.byKey(const Key('intake_locked_app_header')),
          findsOneWidget,
        );
        expect(find.text('Classroom Companion'), findsOneWidget);
        expect(find.text('com.school.classroom'), findsOneWidget);
        expect(find.byKey(const Key('intake_title_field')), findsNothing);
        expect(find.byKey(const Key('intake_select_app_btn')), findsNothing);
        expect(find.byKey(const Key('intake_play_store_btn')), findsNothing);
        expect(find.textContaining('CAMERA'), findsNothing);

        // Switch to URL mode -> Play Store convenience button appears
        await tester.tap(find.text('Policy link'));
        await _flush(tester);
        expect(find.byKey(const Key('intake_play_store_btn')), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://draft.example.org/privacy',
        );
        await tester.tap(find.byKey(const Key('intake_play_store_btn')));
        await _flush(tester);

        expect(playStorePackages, ['com.school.classroom']);
        expect(sendCount, 0);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_url_field')))
              .controller!
              .text,
          'https://draft.example.org/privacy',
        );

        // Fallback guidance when Play Store is unavailable
        returnUnavailable = true;
        await tester.tap(find.byKey(const Key('intake_play_store_btn')));
        await _flush(tester);
        expect(
          find.textContaining('Could not open Google Play Store'),
          findsOneWidget,
        );
        expect(sendCount, 0);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_url_field')))
              .controller!
              .text,
          'https://draft.example.org/privacy',
        );

        // Initial failure with locked selectedApp and null initialSelectedApp enforces
        // locked app context AND preserves URL, selected app, URL mode, app label, and error banner on Play Store tap.
        returnUnavailable = false;
        playStorePackages.clear();
        await tester.tap(find.byKey(const Key('intake_close_btn')));
        await _flush(tester);
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialSelectedApp: null,
              onSelectInstalledApp: (_) async => null,
              onOpenPlayStoreListing: (pkg) async {
                playStorePackages.add(pkg);
                return ExternalAppNavigationResult(
                  status: ExternalAppNavigationStatus.openedStore,
                  packageName: pkg,
                );
              },
              initialFailure: PolicyIntakeFailure(
                kind: PolicyIntakeFailureKind.networkError,
                locator: const UrlPolicyLocator(
                  rawUrl: 'https://failed.example.org/privacy',
                ),
                selectedApp: lockedApp,
                userMessage: 'Temporary network failure.',
                recoveryHint: 'Retry the link or switch to Paste text.',
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);
        expect(
          find.byKey(const Key('intake_locked_app_header')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('intake_title_field')), findsNothing);
        expect(find.byKey(const Key('intake_select_app_btn')), findsNothing);

        await _tapVisible(
          tester,
          find.byKey(const Key('intake_play_store_btn')),
        );
        await _flush(tester);
        expect(playStorePackages, ['com.school.classroom']);
        expect(sendCount, 0);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_url_field')))
              .controller!
              .text,
          'https://failed.example.org/privacy',
        );
        expect(find.text('Classroom Companion'), findsOneWidget);
        expect(find.text('com.school.classroom'), findsOneWidget);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(find.text('Temporary network failure.'), findsOneWidget);

        // Native CompanionBridge path preserves typed URL, selected app, URL mode,
        // custom title, and error/recovery state without HTTP scraping.
        const companionChannel = MethodChannel('com.enprive/companion');
        final companionCalls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(companionChannel, (call) async {
              companionCalls.add(call);
              return <String, Object?>{
                'status': 'opened_store',
                'packageName': (call.arguments as Map)['packageName'],
              };
            });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(companionChannel, null);
        });

        final unlockedApp = SelectedAppReference(
          packageName: 'com.unlocked.reader',
          appName: 'Unlocked Reader',
          isLocked: false,
        );
        await tester.tap(find.byKey(const Key('intake_close_btn')));
        await _flush(tester);
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialMode: PolicyIntakeMode.url,
              initialSelectedApp: unlockedApp,
              companionBridge: CompanionBridge(),
              initialFailure: PolicyIntakeFailure(
                kind: PolicyIntakeFailureKind.httpError,
                locator: const UrlPolicyLocator(
                  rawUrl: 'https://broken.unlocked.org/privacy',
                  userSubjectTitle: 'Custom Reader Title',
                ),
                selectedApp: unlockedApp,
                userMessage: 'The link returned HTTP 404.',
                recoveryHint: 'Find the policy link on Play Store.',
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        await _tapVisible(
          tester,
          find.byKey(const Key('intake_play_store_btn')),
        );
        await _flush(tester);

        expect(companionCalls, hasLength(1));
        expect(companionCalls.single.method, 'openPlayStoreListing');
        expect(
          (companionCalls.single.arguments as Map)['packageName'],
          'com.unlocked.reader',
        );
        expect(sendCount, 0);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_url_field')))
              .controller!
              .text,
          'https://broken.unlocked.org/privacy',
        );
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_title_field')))
              .controller!
              .text,
          'Custom Reader Title',
        );
        expect(
          find.byKey(const Key('intake_selected_app_card')),
          findsOneWidget,
        );
        expect(find.text('com.unlocked.reader'), findsOneWidget);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(find.text('The link returned HTTP 404.'), findsOneWidget);
      },
    );
  });

  group('D5.3-D Phase 2: Accessibility, RTL, responsiveness, themes & disposal', () {
    testWidgets(
      '10. TalkBack semantics announce controls once with >= 48dp touch targets and clean controller disposal',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        final coordinator = makeCoordinator();
        final l10n = lookupAppLocalizations(const Locale('en'));

        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              onSelectInstalledApp: (_) async => null,
            ),
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        final nodes = _collectSemantics(
          tester,
          find.byType(UnifiedPolicyIntakeSheet),
        );
        final labels = nodes
            .map((n) => n.getSemanticsData().label)
            .where((l) => l.isNotEmpty)
            .toList();
        int countOccurrences(String needle) => labels.fold<int>(
          0,
          (sum, label) => sum + needle.allMatches(label).length,
        );

        expect(countOccurrences(l10n.intakeCompareWithAppPrompt), 1);
        expect(countOccurrences(l10n.intakeActionInspectText), 1);
        expect(countOccurrences(l10n.modePasteText), 1);
        expect(countOccurrences(l10n.modePolicyLink), 1);
        expect(countOccurrences(l10n.intakeModeDocument), 1);

        expect(
          tester.getSize(find.byKey(const Key('intake_select_app_btn'))).height,
          greaterThanOrEqualTo(48.0),
        );
        expect(
          tester
              .getSize(find.byKey(const Key('intake_primary_submit_btn')))
              .height,
          greaterThanOrEqualTo(48.0),
        );
        expect(
          tester.getSize(find.byKey(const Key('intake_close_btn'))).height,
          greaterThanOrEqualTo(48.0),
        );

        // Disposing sheet disposes controllers cleanly without framework errors
        await tester.tap(find.byKey(const Key('intake_close_btn')));
        await _flush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        expect(tester.takeException(), isNull);

        // Locked-app URL mode exposes single-occurrence Play Store action & >= 48dp target
        await tester.pumpWidget(
          _buildSheetApp(
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialMode: PolicyIntakeMode.url,
              initialSelectedApp: SelectedAppReference(
                packageName: 'com.talkback.locked',
                appName: 'Locked TalkBack App',
                isLocked: true,
              ),
              onOpenPlayStoreListing: (pkg) async =>
                  ExternalAppNavigationResult(
                    status: ExternalAppNavigationStatus.openedStore,
                    packageName: pkg,
                  ),
            ),
          ),
        );
        await tester.tap(find.byKey(const Key('open_unified_intake_btn')));
        await _flush(tester);

        final lockedNodes = _collectSemantics(
          tester,
          find.byType(UnifiedPolicyIntakeSheet),
        );
        final lockedLabels = lockedNodes
            .map((n) => n.getSemanticsData().label)
            .where((l) => l.isNotEmpty)
            .toList();
        final playStoreLabelCount = lockedLabels.fold<int>(
          0,
          (sum, label) =>
              sum + l10n.intakeFindPolicyOnPlayStore.allMatches(label).length,
        );
        expect(playStoreLabelCount, 1);
        expect(
          tester.getSize(find.byKey(const Key('intake_play_store_btn'))).height,
          greaterThanOrEqualTo(48.0),
        );

        handle.dispose();
      },
    );

    testWidgets(
      '11. supports Arabic RTL (with LTR package & URL), 360dp compact, 900dp tablet (<=720dp), 200% scale & WCAG AA Light/Dark contrast',
      (WidgetTester tester) async {
        final coordinator = makeCoordinator();
        final lockedApp = SelectedAppReference(
          packageName: 'com.rtl.sampleapp',
          appName: 'تطبيق الخصوصية',
          isLocked: true,
        );

        // Arabic RTL with locked package + URL field
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          _buildSheetApp(
            locale: const Locale('ar'),
            embedded: true,
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              initialSelectedApp: lockedApp,
              initialMode: PolicyIntakeMode.url,
              onOpenPlayStoreListing: (pkg) async =>
                  ExternalAppNavigationResult(
                    status: ExternalAppNavigationStatus.openedStore,
                    packageName: pkg,
                  ),
            ),
          ),
        );
        await _flush(tester);

        expect(
          Directionality.of(tester.element(find.text('تطبيق الخصوصية'))),
          TextDirection.rtl,
        );
        expect(
          Directionality.of(tester.element(find.text('com.rtl.sampleapp'))),
          TextDirection.ltr,
        );
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('intake_url_field')))
              .textDirection,
          TextDirection.ltr,
        );
        expect(tester.takeException(), isNull);

        // 360dp compact phone at 200% text scale
        tester.view.physicalSize = const Size(360, 760);
        await tester.pumpWidget(
          _buildSheetApp(
            screenSize: const Size(360, 760),
            textScale: 2.0,
            embedded: true,
            config: PolicyIntakeSheetConfig(
              coordinator: coordinator,
              onSelectInstalledApp: (_) async => null,
              initialFailure: const PolicyIntakeFailure(
                kind: PolicyIntakeFailureKind.httpError,
                locator: UrlPolicyLocator(
                  rawUrl: 'https://example.org/privacy',
                ),
                userMessage: 'Could not reach the privacy policy link.',
                recoveryHint: 'Try pasting the policy text instead.',
              ),
            ),
          ),
        );
        await _flush(tester);
        // Uses chip fallback at 200% text scale without clipping/overflow
        expect(
          find.byKey(const ValueKey<String>('intake_mode_chip_url')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        // 900dp tablet width constrained <= 720dp
        tester.view.physicalSize = const Size(900, 1200);
        await tester.pumpWidget(
          _buildSheetApp(
            screenSize: const Size(900, 1200),
            embedded: true,
            config: PolicyIntakeSheetConfig(coordinator: coordinator),
          ),
        );
        await _flush(tester);
        final sheetSize = tester.getSize(find.byType(UnifiedPolicyIntakeSheet));
        expect(sheetSize.width, lessThanOrEqualTo(720.0));
        expect(tester.takeException(), isNull);

        // Light & Dark WCAG AA contrast
        tester.view.physicalSize = const Size(412, 915);
        for (final mode in const <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
          await tester.pumpWidget(
            _buildSheetApp(
              themeMode: mode,
              embedded: true,
              config: PolicyIntakeSheetConfig(
                coordinator: coordinator,
                initialSelectedApp: lockedApp,
                initialFailure: const PolicyIntakeFailure(
                  kind: PolicyIntakeFailureKind.invalidUrl,
                  locator: UrlPolicyLocator(rawUrl: 'bad-url'),
                  userMessage: 'Enter a valid https:// privacy policy link.',
                  recoveryHint: 'Paste the policy text instead.',
                ),
              ),
            ),
          );
          await _flush(tester);

          final ctx = tester.element(find.byType(UnifiedPolicyIntakeSheet));
          final surfaces = ctx.enpriveSurfaces;
          final semantics = ctx.enpriveSemantics;
          final scheme = EnpriveM3ETheme.of(ctx).colorScheme;

          expect(
            _contrastRatio(scheme.onSurface, surfaces.sheetSurface),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            _contrastRatio(scheme.onSurfaceVariant, surfaces.cardMuted),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            _contrastRatio(
              semantics.highConcern.foreground,
              semantics.highConcern.background,
            ),
            greaterThanOrEqualTo(4.5),
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  });
}
