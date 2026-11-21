import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/evidence/evidence_validator.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/services/intake/policy_intake_coordinator.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';
import 'package:enprive/services/platform/companion_bridge.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/intake/unified_policy_intake_sheet.dart';
import 'package:enprive/widgets/m3e/enprive_m3e_components.dart';
import 'package:enprive/widgets/review/unsaved_review_exit_sheet.dart';
import 'package:enprive/widgets/review_progress_sheet.dart';

Future<void> _pumpAndFlush(WidgetTester tester, {int steps = 6}) async {
  await tester.pump();
  for (var i = 0; i < steps; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<List<InternetAddress>> _fakePublicDns(String host) async => [
  InternetAddress('93.184.216.34'),
];

Widget _wrapM3E({
  required Widget home,
  double textScale = 1.0,
}) {
  final lightM3E = EnpriveM3ETheme.resolve(
    mode: ThemeMode.light,
    platformBrightness: Brightness.light,
  );
  return M3EMaterialApp(
    title: 'Enprive Test',
    debugShowCheckedModeBanner: false,
    data: lightM3E,
    typeface: EnpriveM3ETheme.typefaceConfig,
    autoTheming: false,
    dynamicColoring: false,
    initialTheme: Brightness.light,
    theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
    darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
    locale: const Locale('en'),
    localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    appBuilder: (context, child) {
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(textScaler: TextScaler.linear(textScale)),
        child: EnpriveM3EBridgeScope(
          themeMode: ThemeMode.light,
          child: child ?? const SizedBox.shrink(),
        ),
      );
    },
    home: home,
  );
}

const _focusSnapshot = AppPermissionSnapshot(
  packageName: 'com.focus.reader',
  appName: 'Focus Reader',
  requestedPermissions: [
    'android.permission.CAMERA',
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.RECORD_AUDIO',
  ],
  grantedPermissions: [
    'android.permission.CAMERA',
  ],
);

PolicyReviewReceipt _buildPermissionOnlyReceipt(ReviewCoordinator coordinator) {
  return coordinator.buildDevicePermissionInspectionReceipt(
    subjectTitle: 'Focus Reader',
    sourceLabel: 'Installed App',
    appPermissions: _focusSnapshot,
  );
}

PolicyReviewReceipt _buildSavedAppPolicyReceipt({
  String id = 'rcpt_saved_focus_v1',
  String policyText =
      'Focus Reader v1 stores reading progress locally on your phone and uses camera scanning only for book barcodes.',
  String url = 'https://focus.example.com/privacy-v1',
}) {
  final permReport = PermissionComparator.compare(
    snapshot: _focusSnapshot,
    policyText: policyText,
  );
  return PolicyReviewReceipt(
    id: id,
    subjectTitle: 'Focus Reader',
    sourceLabel: 'Focus Reader · $url',
    snapshotText: policyText,
    snapshotDigest: EvidenceValidator.computeSnapshotDigest(policyText),
    createdAt: DateTime(2026, 11, 18, 12, 0),
    overallState: ReviewOverallState.noConcern,
    inferenceSource: InferenceSource.onDevice,
    summary: 'Focus Reader v1 reviewed cleanly.',
    calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
    findings: const [],
    permissionReport: permReport,
    sourceSnapshot: PolicySourceSnapshot(
      snapshotId: 'snap_$id',
      sourceType: PolicySourceType.url,
      requestedUrl: url,
      canonicalUrl: url,
      retrievedAt: DateTime.utc(2026, 11, 18, 12, 0),
      retrievalStatus: PolicyRetrievalStatus.retrieved,
      appIdentityMatchStatus: AppIdentityMatchStatus.unverifiedUserSupplied,
      sourceSha256Hash: EvidenceValidator.computeSha256SourceHash(policyText),
    ),
  );
}

final class _FakeDocumentBridge implements PolicyDocumentPlatformBridge {
  final List<DocumentExtractionOutcome> _queue;
  int pickCount = 0;

  _FakeDocumentBridge(List<DocumentExtractionOutcome> queue)
      : _queue = List<DocumentExtractionOutcome>.from(queue);

  @override
  Future<DocumentExtractionOutcome> pickAndExtractDocument() async {
    pickCount++;
    if (_queue.isEmpty) {
      return const DocumentExtractionOutcome(
        status: 'cancelled',
        extractedText: '',
        userMessage: 'Selection cancelled.',
      );
    }
    return _queue.removeAt(0);
  }

  @override
  Future<AppPermissionSnapshot?> inspectAppSnapshot(String packageName) async =>
      null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hybridChannel = MethodChannel('com.enprive/hybrid_ai');
  const companionChannel = MethodChannel('com.enprive/companion');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(companionChannel, null);
  });

  group('D5.3-D Phase 3b — ReviewResultScreen UnifiedPolicyIntakeSheet', () {
    testWidgets(
      '1. Initial attachment supports Paste, redirected Public URL (with 404 retry & Play Store helper), and PDF/TXT/DOCX documents with exact provenance & SHA-256 while locking app context',
      (WidgetTester tester) async {
        final analyseCalls = <Map<String, dynamic>>[];
        final playStorePackages = <String>[];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                analyseCalls.add(args);
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'ON_DEVICE',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary': 'On-device review completed cleanly.',
                    'concerns': [],
                  },
                };
              }
              return null;
            });

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(companionChannel, (call) async {
              if (call.method == 'openPlayStoreListing') {
                final pkg = (call.arguments as Map)['packageName'] as String;
                playStorePackages.add(pkg);
                return {
                  'status': 'opened_store',
                  'packageName': pkg,
                };
              }
              return null;
            });

        var urlAttempt = 0;
        const redirectedUrlPolicy =
            'Focus Reader Privacy Policy (com.focus.reader): Reading notes stay strictly on your device and camera scanning is never uploaded or shared with advertisers.';
        final urlRetriever = PolicyUrlRetriever(
          dnsLookup: _fakePublicDns,
          clientFactory: () => MockClient((request) async {
            if (request.url.toString() == 'https://focus.example.com/404') {
              urlAttempt++;
              if (urlAttempt == 1) {
                return http.Response('Not found', 404);
              }
              return http.Response(
                '',
                302,
                headers: {'location': 'https://legal.focus.example.com/privacy'},
              );
            }
            if (request.url.toString() ==
                'https://legal.focus.example.com/privacy') {
              return http.Response(
                '<html><body><main><h1>Privacy Policy</h1><p>$redirectedUrlPolicy</p></main></body></html>',
                200,
                headers: {'content-type': 'text/html; charset=utf-8'},
              );
            }
            return http.Response('Unexpected', 500);
          }),
        );

        const pdfPolicy =
            'Focus Reader PDF Notice (com.focus.reader): Your camera scans book ISBNs offline and no personal data is sold or transmitted.';
        const txtPolicy =
            'Focus Reader TXT Notice (com.focus.reader): Local bookmarks stay inside private phone storage with zero ad trackers.';
        const docxPolicy =
            'Focus Reader DOCX Notice (com.focus.reader): Classroom lists remain on device and microphone access is never used for telemetry.';
        final fakeDocBridge = _FakeDocumentBridge([
          // Cancelled pick first -> calm idle, no error banner
          const DocumentExtractionOutcome(
            status: 'cancelled',
            extractedText: '',
            userMessage: 'Cancelled',
          ),
          // Failure pick -> inline error, replacement succeeds
          const DocumentExtractionOutcome(
            status: 'password_protected',
            documentType: 'pdf',
            fileName: 'locked.pdf',
            mimeType: 'application/pdf',
            byteLength: 4096,
            extractedText: '',
            userMessage: 'This PDF is password-protected.',
          ),
          // PDF success
          const DocumentExtractionOutcome(
            status: 'ok',
            documentType: 'pdf',
            fileName: 'focus-policy.pdf',
            mimeType: 'application/pdf',
            byteLength: 10240,
            extractedText: pdfPolicy,
            userMessage: 'Extracted PDF locally.',
          ),
          // TXT success
          const DocumentExtractionOutcome(
            status: 'ok',
            documentType: 'txt',
            fileName: 'focus-policy.txt',
            mimeType: 'text/plain',
            byteLength: 2048,
            extractedText: txtPolicy,
            userMessage: 'Extracted TXT locally.',
          ),
          // DOCX success
          const DocumentExtractionOutcome(
            status: 'ok',
            documentType: 'docx',
            fileName: 'focus-policy.docx',
            mimeType:
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            byteLength: 6144,
            extractedText: docxPolicy,
            userMessage: 'Extracted DOCX locally.',
          ),
        ]);

        final coordinator = ReviewCoordinator();
        final intakeCoordinator = PolicyIntakeCoordinator(
          urlRetriever: urlRetriever,
          documentBridge: fakeDocBridge,
        );
        final repo = ReceiptRepository(useInMemoryOnly: true);
        final permOnly = _buildPermissionOnlyReceipt(coordinator);

        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: permOnly,
              coordinator: coordinator,
              intakeCoordinator: intakeCoordinator,
              companionBridge: CompanionBridge(),
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        // A. Dismissing sheet via Hero source attachment chip does not trigger any review
        await tester.tap(find.byTooltip("Add this app's privacy policy"));
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(find.byKey(const Key('intake_locked_app_header')), findsOneWidget);
        expect(find.text('Focus Reader'), findsWidgets);
        expect(find.text('com.focus.reader'), findsWidgets);
        expect(find.byKey(const Key('intake_select_app_btn')), findsNothing);
        expect(find.byKey(const Key('intake_change_app_btn')), findsNothing);
        expect(find.byKey(const Key('intake_remove_app_btn')), findsNothing);
        expect(find.byKey(const Key('intake_title_field')), findsNothing);

        await tester.tap(find.byKey(const Key('intake_close_btn')));
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        expect(analyseCalls, isEmpty);

        // A2. Initial attachment via Paste mode on a fresh permission-only screen
        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              key: const ValueKey<String>('initial_paste_screen'),
              receipt: _buildPermissionOnlyReceipt(coordinator),
              coordinator: coordinator,
              intakeCoordinator: intakeCoordinator,
              companionBridge: CompanionBridge(),
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpAndFlush(tester);
        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Focus Reader Privacy Policy (com.focus.reader): Reading notes stay strictly on your phone without third-party trackers.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        expect(analyseCalls, hasLength(1));
        expect(await repo.loadReceipts(), isEmpty);

        // A3. Initial attachment via Document mode (PDF) on a fresh permission-only screen
        final initialPdfBridge = _FakeDocumentBridge([
          const DocumentExtractionOutcome(
            status: 'ok',
            documentType: 'pdf',
            fileName: 'initial-focus.pdf',
            mimeType: 'application/pdf',
            byteLength: 8192,
            extractedText: pdfPolicy,
            userMessage: 'Extracted PDF locally.',
          ),
        ]);
        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              key: const ValueKey<String>('initial_doc_screen'),
              receipt: _buildPermissionOnlyReceipt(coordinator),
              coordinator: coordinator,
              intakeCoordinator: PolicyIntakeCoordinator(
                urlRetriever: urlRetriever,
                documentBridge: initialPdfBridge,
              ),
              companionBridge: CompanionBridge(),
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpAndFlush(tester);
        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Document'));
        await _pumpAndFlush(tester);
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);
        expect(analyseCalls, hasLength(2));
        await tester.scrollUntilVisible(
          find.textContaining('File: initial-focus.pdf'),
          240,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('Local PDF document'), findsOneWidget);
        expect(await repo.loadReceipts(), isEmpty);

        // Re-mount permission-only screen for URL 404 retry + Play Store helper + redirect provenance + Document updates
        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              key: const ValueKey<String>('initial_url_and_doc_updates'),
              receipt: _buildPermissionOnlyReceipt(coordinator),
              coordinator: coordinator,
              intakeCoordinator: intakeCoordinator,
              companionBridge: CompanionBridge(),
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        // B. Open via empty-findings card CTA -> URL 404 failure -> retains input -> Play Store helper -> retry succeeds with redirect provenance + SHA-256
        final emptyCardCta = find.text("Add this app's privacy policy").last;
        await tester.ensureVisible(emptyCardCta);
        await tester.pump();
        await tester.tap(emptyCardCta);
        await _pumpAndFlush(tester);

        await tester.tap(find.text('Policy link'));
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://focus.example.com/404',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester);

        // Failure stays inline and preserves typed URL
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        final urlField = tester.widget<TextField>(
          find.byKey(const Key('intake_url_field')),
        );
        expect(urlField.controller?.text, equals('https://focus.example.com/404'));

        // Play Store helper invokes native bridge and preserves URL text
        await tester.tap(find.byKey(const Key('intake_play_store_btn')));
        await _pumpAndFlush(tester);
        expect(playStorePackages, equals(['com.focus.reader']));
        expect(urlField.controller?.text, equals('https://focus.example.com/404'));

        // Retry succeeds with 302 redirect -> canonical URL + redirect provenance + SHA-256
        final retryUrlBtn = find.byKey(const Key('intake_recovery_retry_btn'));
        await tester.ensureVisible(retryUrlBtn);
        await tester.pump();
        await tester.tap(retryUrlBtn);
        await _pumpAndFlush(tester, steps: 8);

        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        expect(analyseCalls, hasLength(3));
        expect(await repo.loadReceipts(), isEmpty); // First review stays unsaved draft!

        await tester.scrollUntilVisible(
          find.textContaining('Redirected from:'),
          240,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.textContaining('Canonical URL: https://legal.focus.example.com/privacy'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Redirected from: https://focus.example.com/404'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Source provenance · Public URL'),
          findsOneWidget,
        );
        expect(
          find.textContaining('SHA-256 source hash:'),
          findsOneWidget,
        );

        // C. Attach updated policy via Document mode: cancel (no error), password-protected failure recovery, then PDF, TXT, and DOCX!
        Future<void> openUpdateDocumentMode() async {
          final btn = find.byKey(const Key('review_result_attach_new_policy_btn'));
          await tester.ensureVisible(btn);
          await tester.pump();
          await tester.tap(btn);
          await _pumpAndFlush(tester);
          expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
          expect(
            find.text('Update privacy policy for Focus Reader'),
            findsOneWidget,
          );
          await tester.tap(find.text('Document'));
          await _pumpAndFlush(tester);
        }

        // C1: Cancel picker -> stays calm without error banner; then locked PDF -> inline failure -> replacement PDF succeeds!
        await openUpdateDocumentMode();
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
        expect(find.byKey(const Key('intake_error_banner')), findsNothing);

        // Next pick returns password_protected failure
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester);
        expect(find.byKey(const Key('intake_error_banner')), findsOneWidget);
        expect(find.textContaining('password-protected'), findsOneWidget);

        // Replacement pick returns valid PDF
        final replaceDocSubmitBtn = find.byKey(
          const Key('intake_primary_submit_btn'),
        );
        await tester.ensureVisible(replaceDocSubmitBtn);
        await tester.pump();
        await tester.tap(replaceDocSubmitBtn);
        await _pumpAndFlush(tester, steps: 8);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        await tester.scrollUntilVisible(
          find.textContaining('File: focus-policy.pdf'),
          240,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('Local PDF document'), findsOneWidget);
        expect(
          find.textContaining(
            EvidenceValidator.computeSha256SourceHash(pdfPolicy).substring(0, 12),
          ),
          findsWidgets,
        );

        // C2: TXT update
        await openUpdateDocumentMode();
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);
        await tester.scrollUntilVisible(
          find.textContaining('File: focus-policy.txt'),
          240,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('Local text document'), findsOneWidget);
        expect(
          find.textContaining(
            EvidenceValidator.computeSha256SourceHash(txtPolicy).substring(0, 12),
          ),
          findsWidgets,
        );

        // C3: DOCX update
        await openUpdateDocumentMode();
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);
        await tester.scrollUntilVisible(
          find.textContaining('File: focus-policy.docx'),
          240,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('Local DOCX document'), findsOneWidget);
        expect(
          find.textContaining(
            EvidenceValidator.computeSha256SourceHash(docxPolicy).substring(0, 12),
          ),
          findsWidgets,
        );
        expect(fakeDocBridge.pickCount, equals(5));
      },
    );

    testWidgets(
      '2. Updated saved receipt lifecycle: Paste/URL/Document updates create distinct drafts with supersedesReceiptId, preserve historical immutability, support Discard and Save',
      (WidgetTester tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'ON_DEVICE',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary': 'Updated policy verified on device.',
                    'concerns': [],
                  },
                };
              }
              return null;
            });

        const urlV2Policy =
            'Focus Reader 2026 URL Policy (com.focus.reader): Bookmarks sync over encrypted classroom connections and camera scans remain local.';
        final urlRetriever = PolicyUrlRetriever(
          dnsLookup: _fakePublicDns,
          clientFactory: () => MockClient((request) async {
            return http.Response(
              '<html><body><p>$urlV2Policy</p></body></html>',
              200,
              headers: {'content-type': 'text/html; charset=utf-8'},
            );
          }),
        );

        final repo = ReceiptRepository(useInMemoryOnly: true);
        final historical = _buildSavedAppPolicyReceipt();
        await repo.saveReceipt(historical);

        Widget buildHost() => _wrapM3E(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReviewResultScreen(
                          receipt: historical,
                          coordinator: ReviewCoordinator(),
                          intakeCoordinator: PolicyIntakeCoordinator(
                            urlRetriever: urlRetriever,
                          ),
                          receiptRepository: repo,
                          onSaveReceipt: repo.saveReceipt,
                          onDeleteReceipt: repo.deleteReceipt,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Saved Review'),
                ),
              ),
            ),
          ),
        );

        await tester.pumpWidget(buildHost());
        await _pumpAndFlush(tester);

        // Flow A: Update via Public URL (checking prefilled existing URL) then DISCARD -> historical untouched
        await tester.tap(find.text('Open Saved Review'));
        await _pumpAndFlush(tester);
        expect(find.byTooltip('Saved to Receipts'), findsOneWidget);

        final attachBtn = find.byKey(
          const Key('review_result_attach_new_policy_btn'),
        );
        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpAndFlush(tester);

        await tester.tap(find.text('Policy link'));
        await _pumpAndFlush(tester);
        final prefilledUrlField = tester.widget<TextField>(
          find.byKey(const Key('intake_url_field')),
        );
        expect(
          prefilledUrlField.controller?.text,
          equals('https://focus.example.com/privacy-v1'),
        );
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://focus.example.com/privacy-v2',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);

        expect(
          find.byKey(const Key('review_result_modified_draft_banner')),
          findsOneWidget,
        );
        expect(await repo.loadReceipts(), hasLength(1));

        // Close -> UnsavedReviewExitSheet -> Discard
        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        expect(find.byType(UnsavedReviewExitSheet), findsOneWidget);
        await tester.tap(find.byKey(const Key('unsaved_exit_discard_btn')));
        await _pumpAndFlush(tester);

        expect(find.byType(ReviewResultScreen), findsNothing);
        var stored = await repo.loadReceipts();
        expect(stored, hasLength(1));
        expect(stored.single.id, equals(historical.id));
        expect(stored.single.snapshotText, equals(historical.snapshotText));
        expect(
          stored.single.sourceSnapshot?.sourceSha256Hash,
          equals(historical.sourceSnapshot?.sourceSha256Hash),
        );

        // Flow B: Re-open saved receipt -> sequential update #1 (Paste) then update #2 (URL) -> explicit Save
        // verifies supersedesReceiptId still targets historical.id and both records persist cleanly
        await tester.tap(find.text('Open Saved Review'));
        await _pumpAndFlush(tester);

        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Focus Reader intermediate draft policy text without third-party trackers or advertising.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);

        // Second unsaved update via URL before saving
        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpAndFlush(tester);
        await tester.tap(find.text('Policy link'));
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_url_field')),
          'https://focus.example.com/privacy-v2',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);

        // Explicit Save
        await tester.tap(find.byKey(const Key('review_result_save_btn')));
        await _pumpAndFlush(tester);

        stored = await repo.loadReceipts();
        expect(stored, hasLength(2));
        final keptOriginal = stored.firstWhere((r) => r.id == historical.id);
        final savedUpdate = stored.firstWhere((r) => r.id != historical.id);
        expect(keptOriginal.snapshotText, equals(historical.snapshotText));
        expect(
          keptOriginal.sourceSnapshot?.canonicalUrl,
          equals('https://focus.example.com/privacy-v1'),
        );
        expect(savedUpdate.supersedesReceiptId, equals(historical.id));
        expect(savedUpdate.snapshotText, equals(urlV2Policy));
        expect(
          savedUpdate.sourceSnapshot?.sourceSha256Hash,
          equals(EvidenceValidator.computeSha256SourceHash(urlV2Policy)),
        );
        expect(savedUpdate.sourceSnapshot?.sourceType, equals(PolicySourceType.url));
        expect(savedUpdate.permissionReport?.snapshot.packageName, equals('com.focus.reader'));
      },
    );

    testWidgets(
      '3. D5.3-B unmatched and ambiguous association warnings appear inside locked sheet with non-ownership disclaimers and never persist to receipt JSON',
      (WidgetTester tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'ON_DEVICE',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary': 'Reviewed supplied policy text.',
                    'concerns': [],
                  },
                };
              }
              return null;
            });

        final coordinator = ReviewCoordinator();
        final repo = ReceiptRepository(useInMemoryOnly: true);
        final permOnly = _buildPermissionOnlyReceipt(coordinator);

        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: permOnly,
              coordinator: coordinator,
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        // A. Unmatched policy mentioning a different package identifier
        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'This privacy policy applies strictly to com.other.unrelatedapp and explains how com.other.unrelatedapp collects usage logs and device tokens.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester);

        expect(
          find.byKey(const Key('intake_association_warning_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('intake_association_continue_btn')),
          findsOneWidget,
        );
        // Locked app: Change / Inspect without app buttons MUST NOT appear
        expect(
          find.byKey(const Key('intake_association_change_app_btn')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('intake_association_without_app_btn')),
          findsNothing,
        );
        expect(
          find.textContaining('do not verify developer ownership'),
          findsOneWidget,
        );
        expect(find.textContaining('officially owned'), findsNothing);
        expect(find.textContaining('verified owner'), findsNothing);

        final unmatchedContinue = find.byKey(
          const Key('intake_association_continue_btn'),
        );
        await tester.ensureVisible(unmatchedContinue);
        await tester.pump();
        await tester.tap(unmatchedContinue);
        await _pumpAndFlush(tester, steps: 8);

        expect(
          find.byKey(const Key('review_result_association_notice')),
          findsOneWidget,
        );

        // B. Ambiguous identity policy referencing BOTH com.focus.reader AND com.other.tracker
        final updateBtn = find.byKey(
          const Key('review_result_attach_new_policy_btn'),
        );
        await tester.ensureVisible(updateBtn);
        await tester.pump();
        await tester.tap(updateBtn);
        await _pumpAndFlush(tester);

        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Shared publisher notice covering both com.focus.reader and com.other.tracker applications, detailing analytics retention and account deletion rights.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester);

        expect(
          find.byKey(const Key('intake_association_warning_card')),
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

        final ambiguousContinue = find.byKey(
          const Key('intake_association_continue_btn'),
        );
        await tester.ensureVisible(ambiguousContinue);
        await tester.pump();
        await tester.tap(ambiguousContinue);
        await _pumpAndFlush(tester, steps: 8);

        expect(
          find.byKey(const Key('review_result_association_notice')),
          findsOneWidget,
        );

        // Explicitly save and verify the in-memory association report is NOT persisted in JSON
        await tester.tap(find.byKey(const Key('review_result_save_btn')));
        await _pumpAndFlush(tester);
        final saved = (await repo.loadReceipts()).single;
        final jsonMap = saved.toJson();
        expect(jsonMap.containsKey('associationReport'), isFalse);
        expect(
          saved.sourceSnapshot?.appIdentityMatchStatus,
          equals(AppIdentityMatchStatus.unverifiedUserSupplied),
        );
      },
    );

    testWidgets(
      '4. CloudConsentSheet byte-for-byte parity on updated policy, consent denial = 0 cloud calls, local review = 0 cloud calls, cloud 429 fallback, and zero permission leakage',
      (WidgetTester tester) async {
        final analyseCalls = <Map<String, dynamic>>[];
        var cloudFail429 = false;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'analyseText') {
                final args = Map<String, dynamic>.from(call.arguments as Map);
                analyseCalls.add(args);
                if (args['requestedMode'] == 'ONLY_ON_DEVICE') {
                  return {
                    'schemaVersion': 1,
                    'requestId': args['requestId'],
                    'status': 'unavailable',
                    'inferenceSource': 'UNKNOWN',
                    'message': 'On-device AI unavailable.',
                  };
                }
                if (cloudFail429) {
                  return {
                    'schemaVersion': 1,
                    'requestId': args['requestId'],
                    'status': 'failed',
                    'inferenceSource': 'UNKNOWN',
                    'errorCode': 'QuotaExceededException',
                    'message': 'HTTP 429 quota exceeded',
                  };
                }
                return {
                  'schemaVersion': 1,
                  'requestId': args['requestId'],
                  'status': 'success',
                  'inferenceSource': 'IN_CLOUD',
                  'structuredOutput': {
                    'overall_state': 'NO_CONCERN',
                    'summary': 'Cloud review finished cleanly.',
                    'concerns': [],
                  },
                };
              }
              return null;
            });

        const policyWithPii =
            'Focus Reader Privacy Policy (com.focus.reader): Contact guardian@example.com or Student ID: STU_77123. '
            'We store reading progress locally and never share data with ad brokers or third-party trackers.';

        final repo = ReceiptRepository(useInMemoryOnly: true);
        final saved = _buildSavedAppPolicyReceipt();
        await repo.saveReceipt(saved);

        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: saved,
              coordinator: ReviewCoordinator(),
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        Future<void> submitUpdateText() async {
          final btn = find.byKey(
            const Key('review_result_attach_new_policy_btn'),
          );
          await tester.ensureVisible(btn);
          await tester.pump();
          await tester.tap(btn);
          await _pumpAndFlush(tester);
          await tester.enterText(
            find.byKey(const Key('intake_paste_field')),
            policyWithPii,
          );
          await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
          await _pumpAndFlush(tester, steps: 8);
        }

        // A. Consent denied -> 0 cloud calls, receipt stays Saved
        await submitUpdateText();
        expect(find.byType(CloudConsentSheet), findsOneWidget);
        expect(find.textContaining('guardian@example.com'), findsNothing);
        expect(find.textContaining('STU_77123'), findsNothing);
        expect(find.textContaining('[EMAIL]'), findsWidgets);
        expect(find.textContaining('[ID]'), findsWidgets);

        await tester.tap(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.byTooltip('Close'),
          ),
        );
        await _pumpAndFlush(tester);
        expect(analyseCalls.where((c) => c['cloudConsent'] == true), isEmpty);
        expect(find.byTooltip('Saved to Receipts'), findsOneWidget);

        // B. Local review -> deterministic scan with 0 cloud calls
        await submitUpdateText();
        expect(find.byType(CloudConsentSheet), findsOneWidget);
        await tester.tap(find.text('Review on this phone'));
        await _pumpAndFlush(tester, steps: 8);
        expect(analyseCalls.where((c) => c['cloudConsent'] == true), isEmpty);
        expect(
          find.byKey(const Key('review_result_modified_draft_banner')),
          findsOneWidget,
        );

        // C. Consented cloud review -> exact byte-for-byte parity & zero permission leakage
        await submitUpdateText();
        expect(find.byType(CloudConsentSheet), findsOneWidget);
        final quoteCard = tester.widget<EnpriveQuoteCard>(
          find.descendant(
            of: find.byType(CloudConsentSheet),
            matching: find.byType(EnpriveQuoteCard),
          ),
        );
        final displayedPreview = quoteCard.quote;
        await tester.tap(find.text('Use cloud for this check'));
        await _pumpAndFlush(tester, steps: 8);

        final cloudCalls = analyseCalls
            .where((c) => c['cloudConsent'] == true)
            .toList();
        expect(cloudCalls, hasLength(1));
        expect(cloudCalls.single['text'], equals(displayedPreview));
        final serialized = cloudCalls.single.toString();
        expect(serialized, isNot(contains('ACCESS_FINE_LOCATION')));
        expect(serialized, isNot(contains('RECORD_AUDIO')));
        expect(serialized, isNot(contains('CAMERA')));
        expect(serialized, isNot(contains('guardian@example.com')));
        expect(serialized, isNot(contains('STU_77123')));

        // D. Cloud 429 unavailable -> explicit local fallback notice card
        cloudFail429 = true;
        await submitUpdateText();
        await tester.tap(find.text('Use cloud for this check'));
        await _pumpAndFlush(tester, steps: 8);
        expect(
          find.byKey(const ValueKey<String>('cloud_fallback_notice_card')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '5. Cancellation, stale async completion, disposal cleanup, no double submission/pop, invalid snapshot non-fabrication, and 360dp/200% TalkBack accessibility',
      (WidgetTester tester) async {
        final pendingCompleters = <Completer<Map<String, dynamic>>>[];
        final cancelledRequestIds = <String?>[];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'analyseText') {
                final completer = Completer<Map<String, dynamic>>();
                pendingCompleters.add(completer);
                return completer.future;
              }
              if (call.method == 'cancelAnalysis') {
                cancelledRequestIds.add(
                  (call.arguments as Map?)?['requestId'] as String?,
                );
                return true;
              }
              return null;
            });

        // A. Invalid / missing AppPermissionSnapshot (empty packageName) never fabricates or crashes
        final invalidPermReceipt = PolicyReviewReceipt(
          id: 'rcpt_invalid_perm',
          subjectTitle: 'Malformed App',
          sourceLabel: 'Installed App',
          snapshotText: '',
          snapshotDigest: '',
          createdAt: DateTime(2026, 11, 18, 12, 0),
          overallState: ReviewOverallState.insufficientEvidence,
          inferenceSource: InferenceSource.offlineDeterministic,
          summary: 'Missing package metadata.',
          calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
          findings: const [],
          diagnosticKind: ReviewDiagnosticKind.devicePermissionInspection,
          permissionReport: const AppPermissionComparisonReport(
            snapshot: AppPermissionSnapshot(
              packageName: '   ',
              appName: 'Malformed App',
              requestedPermissions: [],
              grantedPermissions: [],
            ),
            items: [],
            limitationNotice: 'Missing observation.',
          ),
        );

        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: invalidPermReceipt,
              coordinator: ReviewCoordinator(),
            ),
          ),
        );
        await _pumpAndFlush(tester);

        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
        expect(tester.takeException(), isNull);

        // B. Pending review cancellation + stale async completion ignored + double-tap safety + disposal cleanup
        final coordinator = ReviewCoordinator();
        final permOnly = _buildPermissionOnlyReceipt(coordinator);
        var hostPopCount = 0;

        await tester.pumpWidget(
          _wrapM3E(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(ctx).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReviewResultScreen(
                            receipt: permOnly,
                            coordinator: coordinator,
                          ),
                        ),
                      );
                      hostPopCount++;
                    },
                    child: const Text('Push Result'),
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpAndFlush(tester);

        await tester.tap(find.text('Push Result'));
        await _pumpAndFlush(tester);

        // Rapid double-tap on Hero CTA opens only ONE UnifiedPolicyIntakeSheet
        final heroCta = find.text("Add this app's privacy policy").first;
        await tester.tap(heroCta);
        await tester.tap(heroCta, warnIfMissed: false);
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Focus Reader stores notes locally on device and never shares student data with advertising networks.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // ReviewProgressCard is active and pending
        expect(find.byType(ReviewProgressCard), findsOneWidget);
        expect(pendingCompleters, hasLength(1));

        // Cancel in-flight review
        final cancelReviewBtn = find.descendant(
          of: find.byType(ReviewProgressCard),
          matching: find.text('Cancel'),
        );
        await tester.ensureVisible(cancelReviewBtn);
        await tester.pump();
        await tester.tap(cancelReviewBtn);
        await _pumpAndFlush(tester);
        expect(cancelledRequestIds, isNotEmpty);
        expect(find.byType(ReviewProgressCard), findsNothing);

        // Complete the stale future late -> MUST NOT mutate _activeReceipt
        pendingCompleters.first.complete({
          'schemaVersion': 1,
          'requestId': 'stale',
          'status': 'success',
          'inferenceSource': 'ON_DEVICE',
          'structuredOutput': {
            'overall_state': 'NO_CONCERN',
            'summary': 'STALE RESULT MUST NEVER APPEAR',
            'concerns': [],
          },
        });
        await _pumpAndFlush(tester);
        expect(find.textContaining('STALE RESULT MUST NEVER APPEAR'), findsNothing);
        expect(find.text('Device Permission Inspection'), findsWidgets);

        // Start a second pending review, then dispose via Close button (rapid double-tap) -> cancels cleanly, pops ONCE
        final secondOpenCta = find.text("Add this app's privacy policy").first;
        await tester.ensureVisible(secondOpenCta);
        await tester.pump();
        await tester.tap(secondOpenCta);
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Focus Reader stores notes locally on device and never sells user profiles or personal data.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(pendingCompleters, hasLength(2));

        final cancelCountBeforePop = cancelledRequestIds.length;
        final closeBtn = find.descendant(
          of: find.byType(ReviewResultScreen),
          matching: find.byTooltip('Close'),
        );
        await tester.tap(closeBtn);
        await tester.tap(closeBtn, warnIfMissed: false);
        await _pumpAndFlush(tester);

        expect(hostPopCount, equals(1));
        expect(find.text('Push Result'), findsOneWidget);
        expect(cancelledRequestIds.length, greaterThan(cancelCountBeforePop));

        // Complete second pending future after disposal -> zero exceptions
        pendingCompleters[1].complete({
          'schemaVersion': 1,
          'requestId': 'after_dispose',
          'status': 'success',
          'inferenceSource': 'ON_DEVICE',
          'structuredOutput': {
            'overall_state': 'NO_CONCERN',
            'summary': 'AFTER DISPOSE',
            'concerns': [],
          },
        });
        await _pumpAndFlush(tester);
        expect(tester.takeException(), isNull);

        // C. Compact 360dp + 200% text scaling + TalkBack semantics check on ReviewResultScreen -> UnifiedPolicyIntakeSheet
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final semanticsHandle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            _wrapM3E(
              textScale: 2.0,
              home: ReviewResultScreen(
                receipt: _buildSavedAppPolicyReceipt(),
                coordinator: ReviewCoordinator(),
              ),
            ),
          );
          await _pumpAndFlush(tester);
          expect(tester.takeException(), isNull);

          final updateBtn = find.byKey(
            const Key('review_result_attach_new_policy_btn'),
          );
          await tester.ensureVisible(updateBtn);
          await tester.pump();
          await tester.tap(updateBtn);
          await _pumpAndFlush(tester);

          expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);
          final closeBtnFinder = find.byKey(const Key('intake_close_btn'));
          final closeData = tester
              .getSemantics(closeBtnFinder)
              .getSemanticsData();
          expect(closeData.tooltip, equals('Close'));
          expect(closeData.flagsCollection.isButton, isTrue);
          expect(closeData.hasAction(SemanticsAction.tap), isTrue);
          final closeSize = tester.getSize(closeBtnFinder);
          expect(closeSize.width, greaterThanOrEqualTo(48));
          expect(closeSize.height, greaterThanOrEqualTo(48));
          expect(tester.takeException(), isNull);
        } finally {
          semanticsHandle.dispose();
        }
      },
    );

    testWidgets(
      '6. Cloud-inference cancellation cancels exact _appcheck requestId and ignores late cloud response; receipt replacement while intake is active drops stale submission',
      (WidgetTester tester) async {
        final cloudCompleters = <Completer<Map<String, dynamic>>>[];
        final cloudRequestIds = <String>[];
        final cancelledRequestIds = <String?>[];
        var analyseCallCount = 0;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(hybridChannel, (call) async {
              if (call.method == 'analyseText') {
                analyseCallCount++;
                final args = Map<String, dynamic>.from(call.arguments as Map);
                if (args['requestedMode'] == 'ONLY_ON_DEVICE') {
                  return {
                    'schemaVersion': 1,
                    'requestId': args['requestId'],
                    'status': 'unavailable',
                    'inferenceSource': 'UNKNOWN',
                    'message': 'On-device AI unavailable.',
                  };
                }
                cloudRequestIds.add(args['requestId'] as String);
                final completer = Completer<Map<String, dynamic>>();
                cloudCompleters.add(completer);
                return completer.future;
              }
              if (call.method == 'cancelAnalysis') {
                cancelledRequestIds.add(
                  (call.arguments as Map?)?['requestId'] as String?,
                );
                return true;
              }
              return null;
            });

        final coordinator = ReviewCoordinator();
        final receiptA = _buildPermissionOnlyReceipt(coordinator);
        final receiptB = _buildSavedAppPolicyReceipt(
          id: 'rcpt_replacement_b',
          policyText:
              'Replacement Receipt B Policy: Distinct saved record that must never be overwritten by stale Receipt A intake.',
        );

        // A. Cancellation during active cloud inference sends exact `${reqId}_appcheck` ID and ignores late cloud response
        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: receiptA,
              coordinator: coordinator,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Focus Reader Privacy Policy (com.focus.reader): Cloud analysis cancellation test policy without ad brokers.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 6);

        expect(find.byType(CloudConsentSheet), findsOneWidget);
        await tester.tap(find.text('Use cloud for this check'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(cloudRequestIds, hasLength(1));
        expect(cloudRequestIds.single, endsWith('_appcheck'));
        expect(find.byType(ReviewProgressCard), findsOneWidget);

        final cancelCloudBtn = find.descendant(
          of: find.byType(ReviewProgressCard),
          matching: find.text('Cancel'),
        );
        await tester.ensureVisible(cancelCloudBtn);
        await tester.pump();
        await tester.tap(cancelCloudBtn);
        await _pumpAndFlush(tester);

        expect(cancelledRequestIds, contains(cloudRequestIds.single));
        expect(find.byType(ReviewProgressCard), findsNothing);

        // Late cloud response after cancellation MUST NOT overwrite receiptA
        cloudCompleters.single.complete({
          'schemaVersion': 1,
          'requestId': cloudRequestIds.single,
          'status': 'success',
          'inferenceSource': 'IN_CLOUD',
          'structuredOutput': {
            'overall_state': 'NO_CONCERN',
            'summary': 'LATE CLOUD RESULT MUST NEVER APPLY',
            'concerns': [],
          },
        });
        await _pumpAndFlush(tester);
        expect(
          find.textContaining('LATE CLOUD RESULT MUST NEVER APPLY'),
          findsNothing,
        );
        expect(find.text('Device Permission Inspection'), findsWidgets);

        // B. Receipt replacement via didUpdateWidget while UnifiedPolicyIntakeSheet is open drops stale intake
        final activeReceiptNotifier = ValueNotifier<PolicyReviewReceipt>(
          receiptA,
        );
        addTearDown(activeReceiptNotifier.dispose);

        await tester.pumpWidget(
          _wrapM3E(
            home: ValueListenableBuilder<PolicyReviewReceipt>(
              valueListenable: activeReceiptNotifier,
              builder: (_, currentReceipt, _) => ReviewResultScreen(
                receipt: currentReceipt,
                coordinator: coordinator,
              ),
            ),
          ),
        );
        await _pumpAndFlush(tester);

        final analyseCountBeforeSwap = analyseCallCount;
        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);

        // Swap underlying widget.receipt to receiptB while sheet for receiptA is still open
        activeReceiptNotifier.value = receiptB;
        await tester.pump();

        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Focus Reader stale intake text submitted after parent swapped receipts.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 6);

        // Stale intake for receiptA must NOT invoke analyseText or overwrite receiptB
        expect(analyseCallCount, equals(analyseCountBeforeSwap));
        expect(
          find.textContaining('Focus Reader v1 reviewed cleanly.'),
          findsOneWidget,
        );
      },
    );
  });
}
