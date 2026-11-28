import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/evidence/evidence_validator.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/installed_app_picker_sheet.dart';
import 'package:enprive/widgets/intake/unified_policy_intake_sheet.dart';
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

Future<void> _scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    260,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _pumpAndFlush(tester);
}

Widget _wrapM3E({
  required Widget home,
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  bool disableAnimations = false,
}) {
  final brightness = themeMode == ThemeMode.dark
      ? Brightness.dark
      : Brightness.light;
  final m3eData = EnpriveM3ETheme.resolve(
    mode: themeMode,
    platformBrightness: brightness,
  );
  return M3EMaterialApp(
    title: 'Enprive D5.3-E Test',
    debugShowCheckedModeBanner: false,
    data: m3eData,
    typeface: EnpriveM3ETheme.typefaceConfig,
    autoTheming: false,
    dynamicColoring: false,
    initialTheme: brightness,
    theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
    darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
    locale: locale,
    localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    appBuilder: (context, child) {
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: EnpriveM3EBridgeScope(
          themeMode: themeMode,
          child: child ?? const SizedBox.shrink(),
        ),
      );
    },
    home: home,
  );
}

PolicyReviewReceipt _buildStandalonePolicyReceipt({
  String id = 'rcpt_policy_first_1',
  String title = 'Focus Reader Policy',
  String policyText =
      'Focus Reader (com.focus.reader) stores reading lists locally on your phone '
      'and uses the camera only to scan book barcodes. We never sell personal data '
      'to third-party brokers.',
  String? url,
  AppPermissionSnapshot? linkedSnapshot,
}) {
  final permReport = linkedSnapshot == null
      ? null
      : PermissionComparator.compare(
          snapshot: linkedSnapshot,
          policyText: policyText,
        );
  return PolicyReviewReceipt(
    id: id,
    subjectTitle: title,
    sourceLabel: url ?? 'Pasted text',
    snapshotText: policyText,
    snapshotDigest: EvidenceValidator.computeSnapshotDigest(policyText),
    createdAt: DateTime(2026, 11, 20, 12, 0),
    overallState: ReviewOverallState.noConcern,
    inferenceSource: InferenceSource.offlineDeterministic,
    summary: 'Reviewed policy text locally on this phone.',
    calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
    findings: const [],
    permissionReport: permReport,
    sourceSnapshot: PolicySourceSnapshot(
      snapshotId: 'snap_$id',
      sourceType: url != null ? PolicySourceType.url : PolicySourceType.pastedText,
      requestedUrl: url,
      canonicalUrl: url,
      retrievedAt: DateTime.utc(2026, 11, 20, 12, 0),
      retrievalStatus: url != null
          ? PolicyRetrievalStatus.retrieved
          : PolicyRetrievalStatus.localProvided,
      appIdentityMatchStatus: linkedSnapshot != null
          ? AppIdentityMatchStatus.unverifiedUserSupplied
          : AppIdentityMatchStatus.notApplicable,
      sourceSha256Hash: EvidenceValidator.computeSha256SourceHash(policyText),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hybridChannel = MethodChannel('com.enprive/hybrid_ai');

  late List<Map<String, dynamic>> installedAppsFixture;
  late Map<String, Map<String, dynamic>> inspectedSnapshots;
  late List<Map<String, dynamic>> analyseCalls;

  void installChannelMocks() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, (call) async {
          switch (call.method) {
            case 'getDeviceCapability':
              return {
                'sdkInt': 35,
                'onDeviceStatus': 'AVAILABLE',
                'isEmulator': true,
              };
            case 'listLaunchableApps':
              return installedAppsFixture;
            case 'inspectSelectedApp':
              final args = Map<String, dynamic>.from(call.arguments as Map);
              final pkg = args['packageName'] as String;
              return inspectedSnapshots[pkg] ??
                  {
                    'packageName': pkg,
                    'appName': pkg,
                    'requestedPermissions': <String>[],
                    'grantedPermissions': <String>[],
                  };
            case 'getAppIcon':
              return null;
            case 'analyseText':
              final args = Map<String, dynamic>.from(call.arguments as Map);
              analyseCalls.add(args);
              return {
                'schemaVersion': 1,
                'requestId': args['requestId'] ?? 'req_1',
                'status': 'unavailable',
                'inferenceSource': 'UNKNOWN',
                'message': 'On-device AI unavailable in test.',
              };
            case 'stopSpeaking':
            case 'cancelAnalysis':
              return true;
            default:
              return null;
          }
        });
  }

  setUp(() {
    analyseCalls = <Map<String, dynamic>>[];
    installedAppsFixture = [
      {
        'packageName': 'com.focus.reader',
        'appName': 'Focus Reader',
        'isSystemApp': false,
      },
      {
        'packageName': 'com.calm.timer',
        'appName': 'Calm Timer',
        'isSystemApp': false,
      },
      {
        'packageName': 'com.alpha.notes',
        'appName': 'Study Notes',
        'isSystemApp': false,
      },
      {
        'packageName': 'com.beta.notes',
        'appName': 'Study Notes',
        'isSystemApp': false,
      },
    ];
    inspectedSnapshots = {
      'com.focus.reader': {
        'packageName': 'com.focus.reader',
        'appName': 'Focus Reader',
        'requestedPermissions': [
          'android.permission.CAMERA',
          'android.permission.ACCESS_FINE_LOCATION',
        ],
        'grantedPermissions': [
          'android.permission.CAMERA',
          'android.permission.ACCESS_FINE_LOCATION',
        ],
      },
      'com.calm.timer': {
        'packageName': 'com.calm.timer',
        'appName': 'Calm Timer',
        'requestedPermissions': ['android.permission.INTERNET'],
        'grantedPermissions': ['android.permission.INTERNET'],
      },
      'com.alpha.notes': {
        'packageName': 'com.alpha.notes',
        'appName': 'Study Notes',
        'requestedPermissions': ['android.permission.CAMERA'],
        'grantedPermissions': ['android.permission.CAMERA'],
      },
      'com.beta.notes': {
        'packageName': 'com.beta.notes',
        'appName': 'Study Notes',
        'requestedPermissions': ['android.permission.RECORD_AUDIO'],
        'grantedPermissions': [],
      },
    };
    installChannelMocks();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, null);
  });

  group('D5.3-E Two-Way App-Policy Linking UI', () {
    testWidgets(
      '1. Policy-first -> Link installed app -> Change app (same-app no-op + empty sensitive permissions) -> Unlink app with 0 AI calls and 0 DB writes',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final repo = ReceiptRepository(useInMemoryOnly: true);
        final coordinator = ReviewCoordinator(bridge: HybridAiBridge());
        final standalone = _buildStandalonePolicyReceipt();

        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: standalone,
              coordinator: coordinator,
              receiptRepository: repo,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        // Standalone policy-first shows calm Link an installed app card
        expect(find.byKey(const Key('review_result_link_app_card')), findsOneWidget);
        expect(find.byKey(const Key('review_result_link_app_btn')), findsOneWidget);
        expect(find.byKey(const Key('review_result_linked_app_card')), findsNothing);

        // Tap "Link an installed app" -> InstalledAppPickerSheet opens
        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_link_app_btn')),
        );
        expect(find.byType(InstalledAppPickerSheet), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(InstalledAppPickerSheet),
            matching: find.text('Link an installed app'),
          ),
          findsOneWidget,
        );

        // Pick Focus Reader
        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.focus.reader')),
        );
        await _pumpAndFlush(tester);

        // Linked state: zero AI/cloud calls, zero persistence writes
        expect(analyseCalls, isEmpty);
        expect(await repo.loadReceipts(), isEmpty);
        expect(find.byKey(const Key('review_result_linked_app_card')), findsOneWidget);
        expect(find.byKey(const Key('review_result_association_status')), findsOneWidget);
        expect(find.text('App ID found in this policy'), findsOneWidget);
        expect(find.textContaining('does not prove who owns this policy'), findsOneWidget);
        expect(find.textContaining('not proof of wrongdoing'), findsOneWidget);
        expect(find.byKey(const Key('review_result_attach_new_policy_btn')), findsOneWidget);

        // Change app -> verify "Linked" badge on com.focus.reader and same-app no-op
        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_change_app_btn')),
        );
        expect(find.text('Change linked app'), findsOneWidget);
        expect(find.text('Linked'), findsOneWidget);
        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.focus.reader')),
        );
        await _pumpAndFlush(tester);
        expect(
          find.text('Focus Reader is already linked with the same permissions.'),
          findsOneWidget,
        );

        // Change app -> pick Calm Timer (does not request camera; unmatched policy!)
        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_change_app_btn')),
        );
        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.calm.timer')),
        );
        await _pumpAndFlush(tester);

        // Shows unmatched warning AND "Not requested by app" chip for policy-mentioned camera
        expect(find.byKey(const Key('review_result_association_notice')), findsOneWidget);
        expect(find.text('This policy may be for a different app'), findsOneWidget);
        expect(find.textContaining('com.focus.reader'), findsWidgets);
        expect(
          find.text('Text and web links never prove who published or owns a policy.'),
          findsOneWidget,
        );
        await tester.scrollUntilVisible(
          find.text('Not requested by app'),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Not requested by app'), findsOneWidget);

        // Unlink app -> cleanly returns to standalone policy-only state
        await tester.scrollUntilVisible(
          find.byKey(const Key('review_result_unlink_app_btn')),
          -260,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.byKey(const Key('review_result_unlink_app_btn')));
        await _pumpAndFlush(tester);

        expect(find.byKey(const Key('review_result_link_app_card')), findsOneWidget);
        expect(find.byKey(const Key('review_result_linked_app_card')), findsNothing);
        expect(analyseCalls, isEmpty);
        expect(await repo.loadReceipts(), isEmpty);

        // Also verify empty sensitive permissions card when neither app nor policy involves sensitive categories
        final textOnlyReceipt = _buildStandalonePolicyReceipt(
          id: 'rcpt_text_only_timer',
          title: 'Calm Timer Policy',
          policyText:
              'Calm Timer (com.calm.timer) stores focus timers strictly on your phone '
              'with no accounts and no cross-app tracking. You may clear all timer '
              'records from settings at any time.',
        );
        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: textOnlyReceipt,
              coordinator: coordinator,
              receiptRepository: repo,
            ),
          ),
        );
        await _pumpAndFlush(tester);
        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_link_app_btn')),
        );
        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.calm.timer')),
        );
        await _pumpAndFlush(tester);
        await tester.scrollUntilVisible(
          find.byKey(const Key('review_result_permissions_empty_card')),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.byKey(const Key('review_result_permissions_empty_card')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '2. Peer display-name ambiguity shows plain-language explanation listing peer package and non-ownership disclaimer',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final coordinator = ReviewCoordinator(bridge: HybridAiBridge());
        final notesPolicy = _buildStandalonePolicyReceipt(
          id: 'rcpt_notes_1',
          title: 'Study Notes Policy',
          policyText:
              'Study Notes respects your privacy and keeps class outlines encrypted on your phone. '
              'Camera access is used only to scan worksheets and never shared with ad networks.',
        );

        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: notesPolicy,
              coordinator: coordinator,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_link_app_btn')),
        );
        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.alpha.notes')),
        );
        await _pumpAndFlush(tester);

        expect(
          find.byKey(const Key('review_result_association_notice')),
          findsOneWidget,
        );
        expect(
          find.text('More than one app on this phone has a similar name'),
          findsOneWidget,
        );
        expect(find.textContaining('com.beta.notes'), findsOneWidget);
        expect(
          find.text('Text and web links never prove who published or owns a policy.'),
          findsOneWidget,
        );
        expect(find.textContaining('officially owned'), findsNothing);
      },
    );

    testWidgets(
      '3. D5.3-A saved receipt lifecycle: link creates modifiedSavedDraft, unlink restores saved baseline, save preserves immutable history with supersedesReceiptId, reopen recomputes in-memory association',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final repo = ReceiptRepository(useInMemoryOnly: true);
        final coordinator = ReviewCoordinator(bridge: HybridAiBridge());
        final savedStandalone = _buildStandalonePolicyReceipt(
          id: 'rcpt_saved_standalone',
        );
        await repo.saveReceipt(savedStandalone);

        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: savedStandalone,
              coordinator: coordinator,
              receiptRepository: repo,
              isInitiallySaved: true,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        expect(
          find.byKey(const Key('review_result_modified_draft_banner')),
          findsNothing,
        );

        // Link Focus Reader -> modifiedSavedDraft, original in repo untouched
        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_link_app_btn')),
        );
        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.focus.reader')),
        );
        await _pumpAndFlush(tester);

        expect(
          find.byKey(const Key('review_result_modified_draft_banner')),
          findsOneWidget,
        );
        expect((await repo.loadReceipts()).length, 1);
        expect((await repo.loadReceipts()).single.permissionReport, isNull);

        // Unlink before saving -> cleanly restores saved baseline (no draft banner)
        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_unlink_app_btn')),
        );
        expect(
          find.byKey(const Key('review_result_modified_draft_banner')),
          findsNothing,
        );

        // Re-link Focus Reader and explicitly Save -> 2 immutable receipts in repo
        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_link_app_btn')),
        );
        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.focus.reader')),
        );
        await _pumpAndFlush(tester);

        await tester.tap(find.byKey(const Key('review_result_save_btn')));
        await _pumpAndFlush(tester);

        final allSaved = await repo.loadReceipts();
        expect(allSaved, hasLength(2));
        final original = allSaved.firstWhere(
          (r) => r.id == 'rcpt_saved_standalone',
        );
        final linkedSaved = allSaved.firstWhere(
          (r) => r.id != 'rcpt_saved_standalone',
        );
        expect(original.permissionReport, isNull);
        expect(linkedSaved.permissionReport?.snapshot.packageName, 'com.focus.reader');
        expect(linkedSaved.supersedesReceiptId, original.id);
        expect(linkedSaved.toJson().containsKey('associationReport'), isFalse);

        // Reopen the saved linked receipt WITHOUT initialAssociationReport ->
        // deterministic in-memory association status is restored automatically
        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: linkedSaved,
              coordinator: coordinator,
              receiptRepository: repo,
              isInitiallySaved: true,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        await tester.scrollUntilVisible(
          find.byKey(const Key('review_result_association_status')),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('App ID found in this policy'), findsOneWidget);

        // Unlinking on a saved linked receipt creates a modifiedSavedDraft
        // while keeping the saved linked receipt untouched in history
        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_unlink_app_btn')),
        );
        expect(
          find.byKey(const Key('review_result_modified_draft_banner')),
          findsOneWidget,
        );
        expect((await repo.loadReceipts()).length, 2);
      },
    );

    testWidgets(
      '4. Warm intent via ReviewExitGuardController still guards an unsaved linked draft',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final repo = ReceiptRepository(useInMemoryOnly: true);
        final coordinator = ReviewCoordinator(bridge: HybridAiBridge());
        final guard = ReviewExitGuardController();
        final standalone = _buildStandalonePolicyReceipt();

        await tester.pumpWidget(
          _wrapM3E(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    key: const Key('open_review_btn'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReviewResultScreen(
                            receipt: standalone,
                            coordinator: coordinator,
                            receiptRepository: repo,
                            exitGuardController: guard,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpAndFlush(tester);

        await tester.tap(find.byKey(const Key('open_review_btn')));
        await _pumpAndFlush(tester);

        // Link Focus Reader on the unsaved draft
        await _scrollAndTap(
          tester,
          find.byKey(const Key('review_result_link_app_btn')),
        );
        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.focus.reader')),
        );
        await _pumpAndFlush(tester);

        // Simulate warm incoming OS intent calling exit guard
        final exitFuture = guard.requestExit();
        await _pumpAndFlush(tester);
        expect(find.byType(UnsavedReviewExitSheet), findsOneWidget);

        // Choose Continue reviewing -> stays on linked draft
        await tester.tap(
          find.byKey(const Key('unsaved_exit_continue_btn')),
        );
        await _pumpAndFlush(tester);
        expect(await exitFuture, isFalse);
        expect(
          find.byKey(const Key('review_result_linked_app_card')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '5. Permission-only inspections never show Link/Change/Unlink actions',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final coordinator = ReviewCoordinator(bridge: HybridAiBridge());

        // Permission-only inspection shows Add privacy policy, never Link an installed app
        final permOnly = coordinator.buildDevicePermissionInspectionReceipt(
          subjectTitle: 'Focus Reader',
          sourceLabel: 'Installed on this phone',
          appPermissions: const AppPermissionSnapshot(
            packageName: 'com.focus.reader',
            appName: 'Focus Reader',
            requestedPermissions: ['android.permission.CAMERA'],
            grantedPermissions: [],
          ),
        );
        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: permOnly,
              coordinator: coordinator,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        expect(find.byKey(const Key('review_result_link_app_card')), findsNothing);
        expect(find.byKey(const Key('review_result_linked_app_card')), findsNothing);
        expect(find.byKey(const Key('review_result_change_app_btn')), findsNothing);
        expect(find.byKey(const Key('review_result_unlink_app_btn')), findsNothing);
        expect(
          find.byKey(const Key('review_result_attach_new_policy_btn')),
          findsNothing,
        );
      },
    );

    testWidgets(
      '6. Accessibility & layout safety: 360dp + 200% text scale, Dark mode, Arabic RTL, reduced motion, and >= 48dp touch targets',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final coordinator = ReviewCoordinator(bridge: HybridAiBridge());
        final linkedReceipt = _buildStandalonePolicyReceipt(
          id: 'rcpt_a11y_linked',
          linkedSnapshot: const AppPermissionSnapshot(
            packageName: 'com.focus.reader',
            appName: 'Focus Reader',
            requestedPermissions: [
              'android.permission.CAMERA',
              'android.permission.ACCESS_FINE_LOCATION',
            ],
            grantedPermissions: ['android.permission.CAMERA'],
          ),
        );

        // Light + 200% text scale + reduced motion + 360dp
        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: linkedReceipt,
              coordinator: coordinator,
            ),
            textScale: 2.0,
            disableAnimations: true,
          ),
        );
        await _pumpAndFlush(tester);
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.byKey(const Key('review_result_change_app_btn')),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        final changeSize = tester.getSize(
          find.byKey(const Key('review_result_change_app_btn')),
        );
        final unlinkSize = tester.getSize(
          find.byKey(const Key('review_result_unlink_app_btn')),
        );
        expect(changeSize.height, greaterThanOrEqualTo(48.0));
        expect(unlinkSize.height, greaterThanOrEqualTo(48.0));

        // Dark mode + Arabic RTL + 1.5x text scale
        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: linkedReceipt,
              coordinator: coordinator,
            ),
            themeMode: ThemeMode.dark,
            locale: const Locale('ar'),
            textScale: 1.5,
            disableAnimations: true,
          ),
        );
        await _pumpAndFlush(tester);
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.byKey(const Key('review_result_linked_app_card')),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        final pkgDirectionality = tester.widget<Directionality>(
          find
              .ancestor(
                of: find.text('App ID: com.focus.reader'),
                matching: find.byType(Directionality),
              )
              .first,
        );
        expect(pkgDirectionality.textDirection, TextDirection.ltr);
      },
    );

    testWidgets(
      '7. App-first -> Attach policy produces the same unified two-way linking controls as Policy-first -> Link app',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final coordinator = ReviewCoordinator(bridge: HybridAiBridge());
        final permOnly = coordinator.buildDevicePermissionInspectionReceipt(
          subjectTitle: 'Focus Reader',
          sourceLabel: 'Installed on this phone',
          appPermissions: const AppPermissionSnapshot(
            packageName: 'com.focus.reader',
            appName: 'Focus Reader',
            requestedPermissions: [
              'android.permission.CAMERA',
              'android.permission.ACCESS_FINE_LOCATION',
            ],
            grantedPermissions: ['android.permission.CAMERA'],
          ),
        );

        await tester.pumpWidget(
          _wrapM3E(
            home: ReviewResultScreen(
              receipt: permOnly,
              coordinator: coordinator,
            ),
          ),
        );
        await _pumpAndFlush(tester);

        // App-first permission-only inspection opens UnifiedPolicyIntakeSheet
        await tester.tap(find.text("Add this app's privacy policy").first);
        await _pumpAndFlush(tester);
        expect(find.byType(UnifiedPolicyIntakeSheet), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          'Focus Reader (com.focus.reader) uses your camera strictly for book barcode scanning and never sells personal data to third-party advertisers or brokers.',
        );
        await tester.tap(find.byKey(const Key('intake_primary_submit_btn')));
        await _pumpAndFlush(tester, steps: 8);

        // On-device AI returned unavailable in mock -> pick Review locally
        if (find.text('Review on this phone').evaluate().isNotEmpty) {
          await tester.tap(find.text('Review on this phone'));
          await _pumpAndFlush(tester, steps: 8);
        }

        // Combined screen now shows identical two-way controls
        await tester.scrollUntilVisible(
          find.byKey(const Key('review_result_linked_app_card')),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(const Key('review_result_linked_app_card')), findsOneWidget);
        expect(find.byKey(const Key('review_result_change_app_btn')), findsOneWidget);
        expect(find.byKey(const Key('review_result_unlink_app_btn')), findsOneWidget);
        expect(find.byKey(const Key('review_result_attach_new_policy_btn')), findsOneWidget);
        expect(find.text('App ID found in this policy'), findsOneWidget);
      },
    );
  });
}
