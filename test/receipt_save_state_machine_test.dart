import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/main.dart';
import 'package:enprive/screens/companion_screen.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';
import 'package:enprive/services/platform/companion_bridge.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/review/unsaved_review_exit_sheet.dart';

Future<void> _pumpAndFlush(WidgetTester tester, {int steps = 6}) async {
  await tester.pump();
  for (var i = 0; i < steps; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Widget _wrapWithM3EApp({required Widget child}) {
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
    appBuilder: (context, appChild) => EnpriveM3EBridgeScope(
      themeMode: ThemeMode.light,
      child: appChild ?? const SizedBox.shrink(),
    ),
    home: child,
  );
}

PolicyReviewReceipt _buildPolicyReceipt({
  String id = 'rcpt_draft_1',
  String title = 'Focus Reader',
  String sourceLabel = 'https://focus.example.com/privacy',
  String policyText =
      'Focus Reader stores reading lists strictly on your device and uses camera scanning only for book barcodes.',
  bool withPermissions = true,
}) {
  const snapshot = AppPermissionSnapshot(
    packageName: 'com.focus.reader',
    appName: 'Focus Reader',
    requestedPermissions: ['android.permission.CAMERA'],
    grantedPermissions: [],
  );
  final permReport = withPermissions
      ? PermissionComparator.compare(snapshot: snapshot, policyText: policyText)
      : null;

  return PolicyReviewReceipt(
    id: id,
    subjectTitle: title,
    sourceLabel: sourceLabel,
    snapshotText: policyText,
    snapshotDigest: 'digest_$id',
    createdAt: DateTime(2026, 11, 18, 12, 0),
    overallState: ReviewOverallState.noConcern,
    inferenceSource: InferenceSource.onDevice,
    summary: 'Focus Reader processes notes locally.',
    calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
    findings: const [],
    permissionReport: permReport,
    sourceSnapshot: PolicySourceSnapshot(
      snapshotId: 'snap_$id',
      sourceType: PolicySourceType.url,
      requestedUrl: sourceLabel,
      canonicalUrl: sourceLabel,
      retrievedAt: DateTime.utc(2026, 11, 18, 12, 0),
      retrievalStatus: PolicyRetrievalStatus.retrieved,
      appIdentityMatchStatus: withPermissions
          ? AppIdentityMatchStatus.unverifiedUserSupplied
          : AppIdentityMatchStatus.notApplicable,
      sourceSha256Hash: 'sha256_$id',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hybridChannel = MethodChannel('com.enprive/hybrid_ai');
  const companionChannel = MethodChannel('com.enprive/companion');

  void installStandardMocks({
    List<String>? companionReturnedCalls,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, (call) async {
      switch (call.method) {
        case 'getDeviceCapability':
          return {
            'isSupported': true,
            'modelStatus': 'AVAILABLE',
            'modelCategory': 'PREVIEW',
            'apiLevel': 35,
            'userMessage': 'Gemini Nano 4 ready.',
          };
        case 'getInitialIncomingPayload':
        case 'getInitialSelectedText':
          return null;
        case 'inspectSelectedApp':
          final pkg = (call.arguments as Map?)?['packageName'] as String? ??
              'com.focus.reader';
          return {
            'packageName': pkg,
            'appName': 'Focus Reader',
            'requestedPermissions': ['android.permission.CAMERA'],
            'grantedPermissions': [],
          };
        case 'analyseText':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          return {
            'schemaVersion': 1,
            'requestId': args['requestId'],
            'status': 'success',
            'inferenceSource': 'ON_DEVICE',
            'structuredOutput': {
              'overall_state': 'NO_CONCERN',
              'summary': 'Verified cleanly on device.',
              'concerns': [],
            },
          };
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(companionChannel, (call) async {
      switch (call.method) {
        case 'getInitialCompanionInvocation':
          return null;
        case 'checkUsageAccess':
          return {'status': 'granted', 'deviceLocked': false};
        case 'getQuickSettingsTileStatus':
          return {
            'canRequestDirectAdd': true,
            'isTileAdded': true,
            'hasDeclinedBefore': false,
            'apiLevel': 35,
          };
        case 'resolveForegroundApp':
          return {
            'schemaVersion': 1,
            'resolutionStatus': 'identified',
            'packageName': 'com.ululab.numbers',
            'applicationLabel': 'Math Makers',
            'eventTimestamp': 1760000001000,
            'eventAgeMillis': 3000,
            'confidence': 'high',
            'candidates': [
              {
                'packageName': 'com.ululab.numbers',
                'applicationLabel': 'Math Makers',
                'eventTimestamp': 1760000001000,
                'eventAgeMillis': 3000,
                'permissionMetadataAvailable': true,
              },
            ],
            'permissionMetadataAvailable': true,
          };
        case 'getDeclaredSensitivePermissions':
          return {
            'status': 'ok',
            'packageName': 'com.ululab.numbers',
            'applicationLabel': 'Math Makers',
            'versionName': '1.3.0',
            'versionCode': 130,
            'permissions': [
              {
                'permission': 'android.permission.CAMERA',
                'categoryId': 'camera',
                'title': 'Camera',
                'whatPermissionMeans': 'Takes photos and video.',
                'grantStatus': 'denied',
                'isRuntimePermission': true,
                'statusNote': 'Declared · Currently denied',
              },
            ],
          };
        case 'returnToPreviousApp':
          companionReturnedCalls?.add('returned');
          return true;
      }
      return null;
    });
  }

  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues({
      'enprive_pref_completed_onboarding': true,
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(companionChannel, null);
  });

  group('D5.3-A Receipt Persistence & Lifecycle Integrity State Machine', () {
    testWidgets('1. Fresh review is not persisted automatically', (
      WidgetTester tester,
    ) async {
      installStandardMocks();
      final repo = ReceiptRepository(useInMemoryOnly: true);

      await tester.pumpWidget(
        EnpriveApp(
          showSplashOnLaunch: false,
          receiptRepository: repo,
        ),
      );
      await _pumpAndFlush(tester);

      final calmCard = find.text('CalmMath Kids');
      await tester.ensureVisible(calmCard);
      await tester.pump();
      await tester.tap(calmCard);
      await _pumpAndFlush(tester, steps: 8);

      expect(find.byType(ReviewResultScreen), findsOneWidget);
      expect(find.byTooltip('Save to Receipts'), findsOneWidget);
      expect(find.byTooltip('Saved to Receipts'), findsNothing);
      expect(await repo.loadReceipts(), isEmpty);
    });

    testWidgets(
      '2. Explicit Save creates a receipt and prevents duplicate save operations',
      (WidgetTester tester) async {
        final repo = ReceiptRepository(useInMemoryOnly: true);
        final draft = _buildPolicyReceipt(id: 'rcpt_explicit_save');
        var saveCount = 0;

        await tester.pumpWidget(
          _wrapWithM3EApp(
            child: ReviewResultScreen(
              receipt: draft,
              coordinator: ReviewCoordinator(),
              receiptRepository: repo,
              onSaveReceipt: (r) async {
                saveCount++;
                await repo.saveReceipt(r);
              },
            ),
          ),
        );
        await _pumpAndFlush(tester);

        expect(await repo.loadReceipts(), isEmpty);

        await tester.tap(find.byKey(const Key('review_result_save_btn')));
        await _pumpAndFlush(tester);

        expect(saveCount, equals(1));
        expect((await repo.loadReceipts()).map((r) => r.id), [draft.id]);
        expect(find.byTooltip('Saved to Receipts'), findsOneWidget);

        // Second tap on Save does not trigger a duplicate save
        await tester.tap(find.byKey(const Key('review_result_save_btn')));
        await _pumpAndFlush(tester);
        expect(saveCount, equals(1));
      },
    );

    testWidgets('3. Explicit Discard creates no receipt', (
      WidgetTester tester,
    ) async {
      final repo = ReceiptRepository(useInMemoryOnly: true);
      final draft = _buildPolicyReceipt(id: 'rcpt_discard');

      await tester.pumpWidget(
        _wrapWithM3EApp(
          child: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReviewResultScreen(
                          receipt: draft,
                          coordinator: ReviewCoordinator(),
                          receiptRepository: repo,
                          onSaveReceipt: repo.saveReceipt,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Draft'),
                ),
              ),
            ),
          ),
        ),
      );
      await _pumpAndFlush(tester);

      await tester.tap(find.text('Open Draft'));
      await _pumpAndFlush(tester);
      expect(find.byType(ReviewResultScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await _pumpAndFlush(tester);
      expect(find.byType(UnsavedReviewExitSheet), findsOneWidget);

      await tester.tap(find.byKey(const Key('unsaved_exit_discard_btn')));
      await _pumpAndFlush(tester);

      expect(find.byType(ReviewResultScreen), findsNothing);
      expect(await repo.loadReceipts(), isEmpty);
    });

    testWidgets(
      '4. Existing saved receipt opens with correct Saved state even if onSaveReceipt is omitted',
      (WidgetTester tester) async {
        final repo = ReceiptRepository(useInMemoryOnly: true);
        final saved = _buildPolicyReceipt(id: 'rcpt_saved_repo');
        await repo.saveReceipt(saved);

        await tester.pumpWidget(
          _wrapWithM3EApp(
            child: Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReviewResultScreen(
                            receipt: saved,
                            coordinator: ReviewCoordinator(),
                            receiptRepository: repo,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Saved'),
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpAndFlush(tester);

        await tester.tap(find.text('Open Saved'));
        await _pumpAndFlush(tester);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(find.byTooltip('Saved to Receipts'), findsOneWidget);
        expect(find.byTooltip('Save to Receipts'), findsNothing);

        // Closing an unmodified saved receipt exits cleanly with no prompt
        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        expect(find.byType(UnsavedReviewExitSheet), findsNothing);
        expect(find.byType(ReviewResultScreen), findsNothing);
      },
    );

    testWidgets('5. Existing receipts can be explicitly deleted', (
      WidgetTester tester,
    ) async {
      final repo = ReceiptRepository(useInMemoryOnly: true);
      final saved = _buildPolicyReceipt(id: 'rcpt_to_delete');
      await repo.saveReceipt(saved);

      await tester.pumpWidget(
        _wrapWithM3EApp(
          child: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReviewResultScreen(
                          receipt: saved,
                          coordinator: ReviewCoordinator(),
                          receiptRepository: repo,
                          onSaveReceipt: repo.saveReceipt,
                          onDeleteReceipt: repo.deleteReceipt,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Saved'),
                ),
              ),
            ),
          ),
        ),
      );
      await _pumpAndFlush(tester);

      await tester.tap(find.text('Open Saved'));
      await _pumpAndFlush(tester);

      final deleteBtn = find.byKey(const Key('review_result_delete_btn'));
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await _pumpAndFlush(tester);

      expect(await repo.loadReceipts(), isEmpty);
      expect(find.text('Removed from saved receipts.'), findsOneWidget);
      expect(find.byTooltip('Save to Receipts'), findsOneWidget);

      // Closing after explicit deletion pops cleanly without nagging
      await tester.tap(find.byTooltip('Close'));
      await _pumpAndFlush(tester);
      expect(find.byType(UnsavedReviewExitSheet), findsNothing);
      expect(find.byType(ReviewResultScreen), findsNothing);
    });

    testWidgets('6. Attaching a policy does not automatically save', (
      WidgetTester tester,
    ) async {
      installStandardMocks();
      final repo = ReceiptRepository(useInMemoryOnly: true);
      var saveCalls = 0;

      final permOnlyReceipt = ReviewCoordinator().buildDevicePermissionInspectionReceipt(
        subjectTitle: 'Focus Reader',
        sourceLabel: 'Installed App',
        appPermissions: const AppPermissionSnapshot(
          packageName: 'com.focus.reader',
          appName: 'Focus Reader',
          requestedPermissions: ['android.permission.CAMERA'],
          grantedPermissions: [],
        ),
      );

      await tester.pumpWidget(
        _wrapWithM3EApp(
          child: ReviewResultScreen(
            receipt: permOnlyReceipt,
            coordinator: ReviewCoordinator(),
            receiptRepository: repo,
            onSaveReceipt: (r) async {
              saveCalls++;
              await repo.saveReceipt(r);
            },
          ),
        ),
      );
      await _pumpAndFlush(tester);

      await tester.tap(find.text("Add this app's privacy policy").first);
      await _pumpAndFlush(tester);

      await tester.enterText(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(TextField),
        ),
        'Focus Reader processes barcodes locally and never uploads photos or shares data with third parties.',
      );
      await tester.tap(find.text('Review on this phone'));
      await _pumpAndFlush(tester, steps: 8);

      // Policy is attached & reviewed on screen, yet zero writes hit SQLite/repo
      expect(find.textContaining('Verified cleanly on device.'), findsOneWidget);
      expect(saveCalls, equals(0));
      expect(await repo.loadReceipts(), isEmpty);
      expect(find.byTooltip('Save to Receipts'), findsOneWidget);
    });

    testWidgets(
      '7. Opening from Receipts and Recently Reviewed preserves persistence callbacks',
      (WidgetTester tester) async {
        installStandardMocks();
        final repo = ReceiptRepository(useInMemoryOnly: true);
        final savedAppReceipt = _buildPolicyReceipt(
          id: 'rcpt_shared_home_archive',
          title: 'Focus Reader',
        );
        await repo.saveReceipt(savedAppReceipt);

        await tester.pumpWidget(
          EnpriveApp(
            showSplashOnLaunch: false,
            receiptRepository: repo,
          ),
        );
        await _pumpAndFlush(tester);

        // Open from Recently Reviewed on Check tab
        final recentFinder = find.text('Focus Reader');
        await tester.ensureVisible(recentFinder);
        await tester.pump();
        await tester.tap(recentFinder);
        await _pumpAndFlush(tester);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(find.byTooltip('Saved to Receipts'), findsOneWidget);
        expect(
          find.byKey(const Key('review_result_delete_btn')),
          findsOneWidget,
        );

        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        expect(find.byType(ReviewResultScreen), findsNothing);

        // Switch to Receipts tab -> open -> explicitly delete -> list updates
        await tester.tap(find.text('Receipts'));
        await _pumpAndFlush(tester);

        final openReceiptBtn = find.text('Open receipt').first;
        await tester.ensureVisible(openReceiptBtn);
        await tester.pump();
        await tester.tap(openReceiptBtn);
        await _pumpAndFlush(tester);

        expect(find.byType(ReviewResultScreen), findsOneWidget);
        expect(find.byTooltip('Saved to Receipts'), findsOneWidget);
        await tester.tap(find.byKey(const Key('review_result_delete_btn')));
        await _pumpAndFlush(tester);

        expect(await repo.loadReceipts(), isEmpty);

        await tester.tap(find.byTooltip('Close'));
        await _pumpAndFlush(tester);
        expect(find.byType(ReviewResultScreen), findsNothing);
        expect(find.text('No saved receipts yet'), findsOneWidget);
      },
    );

    testWidgets(
      '8. Modifying an existing receipt does not overwrite its historical snapshot',
      (WidgetTester tester) async {
        installStandardMocks();
        final repo = ReceiptRepository(useInMemoryOnly: true);
        const originalPolicy =
            'Original 2025 Policy: Focus Reader keeps reading history strictly offline on this phone.';
        final originalReceipt = _buildPolicyReceipt(
          id: 'rcpt_historical_v1',
          policyText: originalPolicy,
          sourceLabel: 'https://focus.example.com/privacy-v1',
        );
        await repo.saveReceipt(originalReceipt);

        await tester.pumpWidget(
          _wrapWithM3EApp(
            child: ReviewResultScreen(
              receipt: originalReceipt,
              coordinator: ReviewCoordinator(),
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
              onDeleteReceipt: repo.deleteReceipt,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        expect(find.byTooltip('Saved to Receipts'), findsOneWidget);

        // Attach an updated privacy policy to the already-saved receipt
        final attachNewBtn = find.byKey(
          const Key('review_result_attach_new_policy_btn'),
        );
        await tester.ensureVisible(attachNewBtn);
        await tester.pump();
        await tester.tap(attachNewBtn);
        await _pumpAndFlush(tester);

        const updatedPolicy =
            'Updated 2026 Policy: Focus Reader syncs bookmarks to encrypted school storage and never sells data.';
        await tester.enterText(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(TextField),
          ),
          updatedPolicy,
        );
        await tester.tap(find.text('Review on this phone'));
        await _pumpAndFlush(tester, steps: 8);

        // Shows modified-saved-draft banner and preserves original receipt untouched
        expect(
          find.byKey(const Key('review_result_modified_draft_banner')),
          findsOneWidget,
        );
        expect(find.byTooltip('Save to Receipts'), findsOneWidget);

        var stored = await repo.loadReceipts();
        expect(stored, hasLength(1));
        expect(stored.single.id, equals('rcpt_historical_v1'));
        expect(stored.single.snapshotText, equals(originalPolicy));

        // Explicitly saving creates a distinct new record linked via supersedesReceiptId
        await tester.tap(find.byKey(const Key('review_result_save_btn')));
        await _pumpAndFlush(tester);

        stored = await repo.loadReceipts();
        expect(stored, hasLength(2));
        final keptOld = stored.firstWhere((r) => r.id == 'rcpt_historical_v1');
        final newSaved = stored.firstWhere((r) => r.id != 'rcpt_historical_v1');
        expect(keptOld.snapshotText, equals(originalPolicy));
        expect(
          keptOld.sourceSnapshot?.canonicalUrl,
          equals('https://focus.example.com/privacy-v1'),
        );
        expect(newSaved.snapshotText, equals(updatedPolicy));
        expect(newSaved.supersedesReceiptId, equals('rcpt_historical_v1'));
      },
    );

    testWidgets('9. System Back and X invoke the unsaved-exit flow', (
      WidgetTester tester,
    ) async {
      final repo = ReceiptRepository(useInMemoryOnly: true);
      final draft = _buildPolicyReceipt(id: 'rcpt_exit_flow');

      await tester.pumpWidget(
        _wrapWithM3EApp(
          child: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReviewResultScreen(
                          receipt: draft,
                          coordinator: ReviewCoordinator(),
                          receiptRepository: repo,
                          onSaveReceipt: repo.saveReceipt,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Draft'),
                ),
              ),
            ),
          ),
        ),
      );
      await _pumpAndFlush(tester);

      await tester.tap(find.text('Open Draft'));
      await _pumpAndFlush(tester);

      // Android System Back triggers UnsavedReviewExitSheet once
      await tester.binding.handlePopRoute();
      await _pumpAndFlush(tester);

      expect(find.byType(UnsavedReviewExitSheet), findsOneWidget);
      expect(find.text('Save this privacy review?'), findsOneWidget);
      expect(
        find.text(
          'Unsaved reviews are discarded when you close this screen, so nothing is stored on your phone without your choice.',
        ),
        findsOneWidget,
      );

      // Continue reviewing keeps the user on ReviewResultScreen with 0 saves
      await tester.tap(find.byKey(const Key('unsaved_exit_continue_btn')));
      await _pumpAndFlush(tester);

      expect(find.byType(UnsavedReviewExitSheet), findsNothing);
      expect(find.byType(ReviewResultScreen), findsOneWidget);
      expect(await repo.loadReceipts(), isEmpty);

      // Top bar X opens UnsavedReviewExitSheet, and Save persists & pops
      await tester.tap(find.byTooltip('Close'));
      await _pumpAndFlush(tester);
      expect(find.byType(UnsavedReviewExitSheet), findsOneWidget);

      await tester.tap(find.byKey(const Key('unsaved_exit_save_btn')));
      await _pumpAndFlush(tester);

      expect(find.byType(ReviewResultScreen), findsNothing);
      expect((await repo.loadReceipts()).map((r) => r.id), [draft.id]);
    });

    testWidgets("10. Save failure retains the user's draft", (
      WidgetTester tester,
    ) async {
      final repo = ReceiptRepository(useInMemoryOnly: true);
      final draft = _buildPolicyReceipt(id: 'rcpt_save_failure');
      var shouldFail = true;

      await tester.pumpWidget(
        _wrapWithM3EApp(
          child: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReviewResultScreen(
                          receipt: draft,
                          coordinator: ReviewCoordinator(),
                          receiptRepository: repo,
                          onSaveReceipt: (r) async {
                            if (shouldFail) {
                              throw StateError('Simulated SQLite write failure');
                            }
                            await repo.saveReceipt(r);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Draft'),
                ),
              ),
            ),
          ),
        ),
      );
      await _pumpAndFlush(tester);

      await tester.tap(find.text('Open Draft'));
      await _pumpAndFlush(tester);

      // Trigger Save via exit sheet while repository write throws
      await tester.tap(find.byTooltip('Close'));
      await _pumpAndFlush(tester);
      await tester.tap(find.byKey(const Key('unsaved_exit_save_btn')));
      await _pumpAndFlush(tester);

      // Screen stays open in saveFailure with retry banner and draft intact
      expect(find.byType(ReviewResultScreen), findsOneWidget);
      expect(
        find.byKey(const Key('review_result_save_failure_banner')),
        findsOneWidget,
      );
      expect(find.text('Focus Reader'), findsOneWidget);
      expect(await repo.loadReceipts(), isEmpty);

      // Retry succeeds and transitions cleanly to Saved
      shouldFail = false;
      ScaffoldMessenger.of(
        tester.element(find.byType(ReviewResultScreen)),
      ).removeCurrentSnackBar();
      await _pumpAndFlush(tester);
      final retryBtn = find.text('Retry save');
      await tester.ensureVisible(retryBtn);
      await tester.pump();
      await tester.tap(retryBtn);
      await _pumpAndFlush(tester);

      expect(
        find.byKey(const Key('review_result_save_failure_banner')),
        findsNothing,
      );
      expect(find.byTooltip('Saved to Receipts'), findsOneWidget);
      expect((await repo.loadReceipts()).map((r) => r.id), [draft.id]);
    });

    testWidgets(
      '11. Companion policy attachment remains in memory until explicit Save',
      (WidgetTester tester) async {
        installStandardMocks();
        final repo = ReceiptRepository(useInMemoryOnly: true);

        await tester.pumpWidget(
          _wrapWithM3EApp(
            child: CompanionScreen(
              hybridBridge: HybridAiBridge(),
              companionBridge: CompanionBridge(),
              coordinator: ReviewCoordinator(),
              urlRetriever: PolicyUrlRetriever(),
              savedReceipts: const [],
              receiptRepository: repo,
              onSaveReceipt: repo.saveReceipt,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        await tester.tap(find.byKey(const Key('companion_confirm_app_btn')));
        await _pumpAndFlush(tester);

        final cameraTile = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(cameraTile);
        await tester.pump();
        await tester.tap(cameraTile);
        await _pumpAndFlush(tester);

        final attachBtn = find.byKey(const Key('companion_attach_policy_btn'));
        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpAndFlush(tester);

        await tester.tap(find.text('Paste text'));
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(TextField),
          ),
          'Math Makers uses the camera strictly when scanning worksheets on your device and never sells camera photos.',
        );
        await tester.tap(find.text('Inspect pasted policy'));
        await _pumpAndFlush(tester, steps: 8);

        // Policy matched in session memory, NOT persisted automatically
        expect(find.text('Mentioned in verified policy text'), findsOneWidget);
        expect(
          find.byKey(const Key('companion_receipt_unsaved_label')),
          findsOneWidget,
        );
        final saveCompanionBtn = find.byKey(
          const Key('companion_save_receipt_btn'),
        );
        expect(saveCompanionBtn, findsOneWidget);
        expect(await repo.loadReceipts(), isEmpty);

        // Explicit tap persists to ReceiptRepository
        await tester.ensureVisible(saveCompanionBtn);
        await tester.pump();
        await tester.tap(saveCompanionBtn);
        await _pumpAndFlush(tester);

        expect((await repo.loadReceipts()), hasLength(1));
        expect(
          find.byKey(const Key('companion_receipt_saved_badge')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '12. Exiting an unsaved Companion session does not write to SQLite and preserves Quick Settings return',
      (WidgetTester tester) async {
        final returnedCalls = <String>[];
        installStandardMocks(companionReturnedCalls: returnedCalls);
        final repo = ReceiptRepository(useInMemoryOnly: true);

        await tester.pumpWidget(
          _wrapWithM3EApp(
            child: Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CompanionScreen(
                            invocation: const CompanionInvocation(
                              invocationId: 'qs-d53a-exit',
                              source: 'quick_settings',
                              timestampMs: 1760000005000,
                              deviceLocked: false,
                            ),
                            hybridBridge: HybridAiBridge(),
                            companionBridge: CompanionBridge(),
                            coordinator: ReviewCoordinator(),
                            urlRetriever: PolicyUrlRetriever(),
                            savedReceipts: const [],
                            receiptRepository: repo,
                            onSaveReceipt: repo.saveReceipt,
                          ),
                        ),
                      );
                    },
                    child: const Text('Launch Companion'),
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpAndFlush(tester);

        await tester.tap(find.text('Launch Companion'));
        await _pumpAndFlush(tester);

        await tester.tap(find.byKey(const Key('companion_confirm_app_btn')));
        await _pumpAndFlush(tester);

        final cameraTile = find.byKey(
          const Key('companion_perm_android.permission.CAMERA'),
        );
        await tester.ensureVisible(cameraTile);
        await tester.pump();
        await tester.tap(cameraTile);
        await _pumpAndFlush(tester);

        final attachBtn = find.byKey(const Key('companion_attach_policy_btn'));
        await tester.ensureVisible(attachBtn);
        await tester.pump();
        await tester.tap(attachBtn);
        await _pumpAndFlush(tester);

        await tester.tap(find.text('Paste text'));
        await _pumpAndFlush(tester);
        await tester.enterText(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(TextField),
          ),
          'Math Makers processes camera photos strictly on your device to scan math worksheets and never sells or shares personal data.',
        );
        await tester.tap(find.text('Inspect pasted policy'));
        await _pumpAndFlush(tester, steps: 8);

        expect(
          find.byKey(const Key('companion_receipt_unsaved_label')),
          findsOneWidget,
        );
        expect(await repo.loadReceipts(), isEmpty);

        // Exit without tapping Save -> restores previous app and writes 0 receipts
        final returnBtn = find.byKey(const Key('companion_return_btn'));
        await tester.ensureVisible(returnBtn);
        await tester.pump();
        await tester.tap(returnBtn);
        await _pumpAndFlush(tester);

        expect(find.byType(CompanionScreen), findsNothing);
        expect(returnedCalls, ['returned']);
        expect(await repo.loadReceipts(), isEmpty);
      },
    );
  });
}
