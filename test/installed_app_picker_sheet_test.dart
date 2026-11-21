import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/installed_app_icon.dart';
import 'package:enprive/widgets/installed_app_picker_sheet.dart';
import 'package:enprive/widgets/m3e/enprive_m3e_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

PolicyReviewReceipt _makeSavedReceipt({
  required String id,
  required String subjectTitle,
  required String packageName,
  required String appName,
  required DateTime createdAt,
  bool permissionOnly = false,
}) {
  final snapshot = AppPermissionSnapshot(
    packageName: packageName,
    appName: appName,
    requestedPermissions: const ['android.permission.CAMERA'],
    grantedPermissions: const [],
  );
  return PolicyReviewReceipt(
    id: id,
    subjectTitle: subjectTitle,
    sourceLabel: 'Installed on this phone',
    snapshotText: permissionOnly ? '' : '$appName privacy policy text.',
    snapshotDigest: permissionOnly ? '' : 'digest_$id',
    createdAt: createdAt,
    overallState: permissionOnly
        ? ReviewOverallState.insufficientEvidence
        : ReviewOverallState.reviewRecommended,
    inferenceSource: permissionOnly
        ? InferenceSource.offlineDeterministic
        : InferenceSource.onDevice,
    summary: 'Summary for $subjectTitle',
    calibratedDisclaimer: 'No concern identified in the reviewed evidence. This is not a safety certification.',
    findings: const [],
    permissionReport: PermissionComparator.inspectPermissionsOnly(
      snapshot: snapshot,
    ),
    diagnosticKind: permissionOnly
        ? ReviewDiagnosticKind.devicePermissionInspection
        : ReviewDiagnosticKind.validated,
  );
}

List<Map<String, Object?>> _generateLargeAppMaps(int count) {
  return List<Map<String, Object?>>.generate(count, (index) {
    final number = index + 1;
    final padded = number.toString().padLeft(3, '0');
    final isSystem = number % 4 == 0;
    return <String, Object?>{
      'packageName': 'com.example.app$padded',
      'appName': 'App $padded',
      'isSystemApp': isSystem,
    };
  });
}

Future<void> _flushPickerAsync(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 25)),
  );
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump(const Duration(milliseconds: 120));
}

Widget _buildHarness({
  required HybridAiBridge bridge,
  List<PolicyReviewReceipt> savedReceipts = const [],
  String eduTrackPolicyText = 'EduTrack sample policy text.',
  String calmMathPolicyText = 'CalmMath sample policy text.',
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) {
  final activeData = themeMode == ThemeMode.dark
      ? EnpriveM3ETheme.darkThemeData
      : EnpriveM3ETheme.lightThemeData;

  return M3EMaterialApp(
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
        body: InstalledAppPickerSheet(
          bridge: bridge,
          eduTrackPolicyText: eduTrackPolicyText,
          calmMathPolicyText: calmMathPolicyText,
          savedReceipts: savedReceipts,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hybridChannel = MethodChannel('com.enprive/hybrid_ai');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  double contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  tearDown(() {
    messenger.setMockMethodCallHandler(hybridChannel, null);
  });

  group('D5.3-C InstalledAppPickerSheet', () {
    testWidgets('1. omits duplicate synthetic cards when real apps exist', (
      WidgetTester tester,
    ) async {
      messenger.setMockMethodCallHandler(hybridChannel, (call) async {
        if (call.method == 'listLaunchableApps') {
          return <Map<String, Object?>>[
            {
              'packageName': 'com.example.notebook',
              'appName': 'Field Notebook',
              'isSystemApp': false,
            },
          ];
        }
        return null;
      });

      await tester.pumpWidget(_buildHarness(bridge: HybridAiBridge()));
      await _flushPickerAsync(tester);

      expect(find.text('Field Notebook'), findsOneWidget);
      expect(find.text('com.example.notebook'), findsOneWidget);
      expect(find.text('EduTrack'), findsNothing);
      expect(find.text('CalmMath'), findsNothing);
      expect(find.text('Try a sample kids app'), findsNothing);
      expect(
        find.byKey(const Key('app_picker_empty_sample_action')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '2. shows empty state and compact optional sample action only when no apps exist',
      (WidgetTester tester) async {
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return const <Map<String, Object?>>[];
          }
          return null;
        });

        SelectedAppInspectionChoice? poppedChoice;
        await tester.pumpWidget(
          M3EMaterialApp(
            data: EnpriveM3ETheme.lightThemeData,
            typeface: EnpriveM3ETheme.typefaceConfig,
            autoTheming: false,
            dynamicColoring: false,
            initialTheme: Brightness.light,
            theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
            darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
            localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            appBuilder: (context, child) => EnpriveM3EBridgeScope(
              themeMode: ThemeMode.light,
              child: child ?? const SizedBox.shrink(),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      poppedChoice = await InstalledAppPickerSheet.show(
                        context,
                        bridge: HybridAiBridge(),
                        eduTrackPolicyText: 'EduTrack sample policy',
                        calmMathPolicyText: 'CalmMath sample policy',
                      );
                    },
                    child: const Text('Open Picker'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Picker'));
        await _flushPickerAsync(tester);

        expect(
          find.byKey(const Key('app_picker_empty_installed_card')),
          findsOneWidget,
        );
        expect(find.text('No installed apps available'), findsOneWidget);
        final sampleAction = find.byKey(
          const Key('app_picker_empty_sample_action'),
        );
        expect(sampleAction, findsOneWidget);
        expect(find.text('EduTrack'), findsNothing);
        expect(find.text('CalmMath'), findsNothing);

        await tester.tap(sampleAction);
        await _flushPickerAsync(tester);

        expect(poppedChoice, isNotNull);
        expect(poppedChoice!.isSyntheticSample, isTrue);
        expect(
          poppedChoice!.permissionSnapshot.packageName,
          PermissionComparator.demoEduTrackSnapshot.packageName,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '3. renders 120 apps lazily without 25-item cap or rescanning on filter/search',
      (WidgetTester tester) async {
        var listCalls = 0;
        final largeApps = _generateLargeAppMaps(120);
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            listCalls++;
            return largeApps;
          }
          return null;
        });

        tester.view.physicalSize = const Size(412, 892);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_buildHarness(bridge: HybridAiBridge()));
        await _flushPickerAsync(tester);

        expect(listCalls, 1);
        expect(find.byType(SliverList), findsOneWidget);
        expect(find.text('App 001'), findsOneWidget);
        // Lazy rendering: far-off app 120 is not eagerly materialized at y=0.
        expect(find.text('App 120'), findsNothing);

        final searchBarBeforeScroll = tester.getTopLeft(
          find.byKey(const Key('app_picker_search_bar')),
        );
        final scrollable = find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          find.text('App 120'),
          500,
          scrollable: scrollable,
          maxScrolls: 60,
        );
        await _flushPickerAsync(tester);

        expect(find.text('App 120'), findsOneWidget);
        expect(find.text('com.example.app120'), findsOneWidget);

        // Search bar remains pinned at the same vertical position while scrolling.
        final searchBarAfterScroll = tester.getTopLeft(
          find.byKey(const Key('app_picker_search_bar')),
        );
        expect(searchBarAfterScroll.dy, closeTo(searchBarBeforeScroll.dy, 0.5));

        // Typing & changing filter must never re-invoke listLaunchableApps.
        await tester.enterText(find.byType(EditableText), 'app120');
        await tester.pump(const Duration(milliseconds: 100));
        expect(listCalls, 1);
        expect(find.text('App 120'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '4-7. search by display name or package ID works cleanly with All, Downloaded, and System filters',
      (WidgetTester tester) async {
        var listCalls = 0;
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            listCalls++;
            return <Map<String, Object?>>[
              {
                'packageName': 'org.example.sketchpad',
                'appName': 'Sketch Pad',
                'isSystemApp': false,
              },
              {
                'packageName': 'com.vendor.clockworks',
                'appName': 'World Clock',
                'isSystemApp': true,
              },
              {
                'packageName': 'com.vendor.camera',
                'appName': 'System Camera',
                'isSystemApp': true,
              },
            ];
          }
          return null;
        });

        await tester.pumpWidget(_buildHarness(bridge: HybridAiBridge()));
        await _flushPickerAsync(tester);

        // 4. Search by display name
        await tester.enterText(find.byType(EditableText), 'sketch');
        await tester.pump();
        expect(find.text('Sketch Pad'), findsOneWidget);
        expect(find.text('World Clock'), findsNothing);

        // 5. Search by package identifier
        await tester.enterText(find.byType(EditableText), 'vendor.clock');
        await tester.pump();
        expect(find.text('World Clock'), findsOneWidget);
        expect(find.text('Sketch Pad'), findsNothing);

        // Clear search
        await tester.enterText(find.byType(EditableText), '');
        await tester.pump();

        // 6. Downloaded filter
        await tester.tap(find.byKey(const Key('app_picker_filter_downloaded')));
        await tester.pump();
        expect(find.text('Sketch Pad'), findsOneWidget);
        expect(find.text('World Clock'), findsNothing);
        expect(find.text('System Camera'), findsNothing);

        // 7. System filter + search together
        await tester.tap(find.byKey(const Key('app_picker_filter_system')));
        await tester.pump();
        expect(find.text('World Clock'), findsOneWidget);
        expect(find.text('System Camera'), findsOneWidget);
        expect(find.text('Sketch Pad'), findsNothing);

        await tester.enterText(find.byType(EditableText), 'camera');
        await tester.pump();
        expect(find.text('System Camera'), findsOneWidget);
        expect(find.text('World Clock'), findsNothing);
        expect(listCalls, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '8. Recently checked orders latest unique installed packages and caps at 3',
      (WidgetTester tester) async {
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return <Map<String, Object?>>[
              {
                'packageName': 'com.example.alpha',
                'appName': 'Alpha Reader',
                'isSystemApp': false,
              },
              {
                'packageName': 'com.example.beta',
                'appName': 'Beta Math',
                'isSystemApp': false,
              },
              {
                'packageName': 'com.example.gamma',
                'appName': 'Gamma Notes',
                'isSystemApp': false,
              },
              {
                'packageName': 'com.example.delta',
                'appName': 'Delta Draw',
                'isSystemApp': false,
              },
            ];
          }
          return null;
        });

        final savedReceipts = <PolicyReviewReceipt>[
          // Older & newer receipts for gamma -> deduplicated to 1 entry at t=40
          _makeSavedReceipt(
            id: 'r_gamma_old',
            subjectTitle: 'Gamma Notes',
            packageName: 'com.example.gamma',
            appName: 'Gamma Notes',
            createdAt: DateTime.utc(2026, 11, 10, 9),
          ),
          _makeSavedReceipt(
            id: 'r_gamma_new',
            subjectTitle: 'Gamma Notes',
            packageName: 'com.example.gamma',
            appName: 'Gamma Notes',
            createdAt: DateTime.utc(2026, 11, 18, 12),
          ),
          // Uninstalled app should be skipped
          _makeSavedReceipt(
            id: 'r_uninstalled',
            subjectTitle: 'Ghost App',
            packageName: 'com.example.removed',
            appName: 'Ghost App',
            createdAt: DateTime.utc(2026, 11, 18, 15),
          ),
          // Synthetic fixture package should be excluded from Recent
          _makeSavedReceipt(
            id: 'r_demo',
            subjectTitle: 'EduTrack Classroom Companion',
            packageName: PermissionComparator.demoEduTrackSnapshot.packageName,
            appName: PermissionComparator.demoEduTrackSnapshot.appName,
            createdAt: DateTime.utc(2026, 11, 18, 16),
          ),
          // Standalone policy (no permissionReport) should be skipped
          PolicyReviewReceipt(
            id: 'r_standalone',
            subjectTitle: 'Standalone Website Policy',
            sourceLabel: 'Pasted text',
            snapshotText: 'Policy without app',
            snapshotDigest: 'standalone',
            createdAt: DateTime.utc(2026, 11, 18, 17),
            overallState: ReviewOverallState.reviewRecommended,
            inferenceSource: InferenceSource.onDevice,
            summary: 'Standalone',
            calibratedDisclaimer: 'Not a safety certification.',
            findings: const [],
          ),
          _makeSavedReceipt(
            id: 'r_alpha',
            subjectTitle: 'Alpha Reader',
            packageName: 'com.example.alpha',
            appName: 'Alpha Reader',
            createdAt: DateTime.utc(2026, 11, 18, 10),
            permissionOnly: true,
          ),
          _makeSavedReceipt(
            id: 'r_delta',
            subjectTitle: 'Delta Draw',
            packageName: 'com.example.delta',
            appName: 'Delta Draw',
            createdAt: DateTime.utc(2026, 11, 18, 11),
          ),
          _makeSavedReceipt(
            id: 'r_beta_oldest',
            subjectTitle: 'Beta Math',
            packageName: 'com.example.beta',
            appName: 'Beta Math',
            createdAt: DateTime.utc(2026, 11, 18, 8),
          ),
        ];

        await tester.pumpWidget(
          _buildHarness(bridge: HybridAiBridge(), savedReceipts: savedReceipts),
        );
        await _flushPickerAsync(tester);

        final recentSection = find.byKey(
          const Key('app_picker_recent_section'),
        );
        expect(recentSection, findsOneWidget);
        expect(find.text('Recently checked'), findsOneWidget);

        // Top 3 ordered: gamma (12:00), delta (11:00), alpha (10:00). Beta (08:00) capped out.
        final gammaRow = find.byKey(
          const ValueKey('app_picker_recent_row_com.example.gamma'),
        );
        final deltaRow = find.byKey(
          const ValueKey('app_picker_recent_row_com.example.delta'),
        );
        final alphaRow = find.byKey(
          const ValueKey('app_picker_recent_row_com.example.alpha'),
        );
        final betaRow = find.byKey(
          const ValueKey('app_picker_recent_row_com.example.beta'),
        );

        expect(gammaRow, findsOneWidget);
        expect(deltaRow, findsOneWidget);
        expect(alphaRow, findsOneWidget);
        expect(betaRow, findsNothing);

        expect(
          tester.getTopLeft(gammaRow).dy,
          lessThan(tester.getTopLeft(deltaRow).dy),
        );
        expect(
          tester.getTopLeft(deltaRow).dy,
          lessThan(tester.getTopLeft(alphaRow).dy),
        );

        // Switching to Downloaded or filtering hides Recently checked cleanly.
        await tester.tap(find.byKey(const Key('app_picker_filter_downloaded')));
        await tester.pump();
        expect(recentSection, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '9. displays evidence-neutral receipt statuses and builds AppIdentityCandidates locally',
      (WidgetTester tester) async {
        final apps = <InstalledAppEntry>[
          const InstalledAppEntry(
            packageName: 'com.example.policy',
            appName: 'Policy Saved App',
          ),
          const InstalledAppEntry(
            packageName: 'com.example.perm',
            appName: 'Perm Inspected App',
          ),
          const InstalledAppEntry(
            packageName: 'com.example.fresh',
            appName: 'Fresh App',
          ),
        ];
        final candidates = InstalledAppPickerModel.toIdentityCandidates(apps);
        expect(candidates.length, 3);
        expect(candidates.first.packageName, 'com.example.policy');

        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return apps
                .map(
                  (a) => <String, Object?>{
                    'packageName': a.packageName,
                    'appName': a.appName,
                    'isSystemApp': a.isSystemApp,
                  },
                )
                .toList();
          }
          return null;
        });

        final savedReceipts = <PolicyReviewReceipt>[
          _makeSavedReceipt(
            id: 'r_policy',
            subjectTitle: 'Policy Saved App',
            packageName: 'com.example.policy',
            appName: 'Policy Saved App',
            createdAt: DateTime.utc(2026, 11, 18, 12),
            permissionOnly: false,
          ),
          _makeSavedReceipt(
            id: 'r_perm',
            subjectTitle: 'Perm Inspected App',
            packageName: 'com.example.perm',
            appName: 'Perm Inspected App',
            createdAt: DateTime.utc(2026, 11, 18, 11),
            permissionOnly: true,
          ),
        ];

        await tester.pumpWidget(
          _buildHarness(bridge: HybridAiBridge(), savedReceipts: savedReceipts),
        );
        await _flushPickerAsync(tester);

        final scrollable = find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        );
        final policyRow = find.byKey(
          const ValueKey('app_picker_row_com.example.policy'),
        );
        final permRow = find.byKey(
          const ValueKey('app_picker_row_com.example.perm'),
        );
        final freshRow = find.byKey(
          const ValueKey('app_picker_row_com.example.fresh'),
        );

        await tester.scrollUntilVisible(policyRow, 200, scrollable: scrollable);
        expect(
          find.descendant(
            of: policyRow,
            matching: find.text('Policy review saved'),
          ),
          findsOneWidget,
        );

        await tester.scrollUntilVisible(permRow, 200, scrollable: scrollable);
        expect(
          find.descendant(
            of: permRow,
            matching: find.text('Permissions inspected'),
          ),
          findsOneWidget,
        );

        await tester.scrollUntilVisible(freshRow, 200, scrollable: scrollable);
        expect(
          find.descendant(of: freshRow, matching: find.text('Not reviewed')),
          findsOneWidget,
        );

        // Must never claim safety, trust, or developer verification.
        expect(find.textContaining('Safe'), findsNothing);
        expect(find.textContaining('Verified'), findsNothing);
        expect(find.textContaining('Trusted'), findsNothing);
        expect(find.textContaining('No concern'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '10. keeps similarly named apps distinguishable by package ID and selects the intended package',
      (WidgetTester tester) async {
        final inspectedPackages = <String>[];
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return <Map<String, Object?>>[
              {
                'packageName': 'com.alpha.focusreader',
                'appName': 'Focus Reader',
                'isSystemApp': false,
              },
              {
                'packageName': 'com.beta.focusreader',
                'appName': 'Focus Reader',
                'isSystemApp': false,
              },
            ];
          }
          if (call.method == 'inspectSelectedApp') {
            final pkg = (call.arguments as Map)['packageName'] as String;
            inspectedPackages.add(pkg);
            return <String, Object?>{
              'packageName': pkg,
              'appName': 'Focus Reader',
              'requestedPermissions': <String>[],
              'grantedPermissions': <String>[],
            };
          }
          return null;
        });

        SelectedAppInspectionChoice? choice;
        await tester.pumpWidget(
          M3EMaterialApp(
            data: EnpriveM3ETheme.lightThemeData,
            typeface: EnpriveM3ETheme.typefaceConfig,
            autoTheming: false,
            dynamicColoring: false,
            initialTheme: Brightness.light,
            theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
            darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
            localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            appBuilder: (context, child) => EnpriveM3EBridgeScope(
              themeMode: ThemeMode.light,
              child: child ?? const SizedBox.shrink(),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      choice = await InstalledAppPickerSheet.show(
                        context,
                        bridge: HybridAiBridge(),
                        eduTrackPolicyText: '',
                        calmMathPolicyText: '',
                      );
                    },
                    child: const Text('Pick'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Pick'));
        await _flushPickerAsync(tester);

        expect(find.text('Focus Reader'), findsNWidgets(2));
        expect(find.text('com.alpha.focusreader'), findsOneWidget);
        expect(find.text('com.beta.focusreader'), findsOneWidget);

        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.beta.focusreader')),
        );
        await _flushPickerAsync(tester);

        expect(inspectedPackages, <String>['com.beta.focusreader']);
        expect(choice, isNotNull);
        expect(choice!.permissionSnapshot.packageName, 'com.beta.focusreader');
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '11-12. renders cleanly at 360dp compact, 900dp expanded, and 200% text scaling with >= 48dp touch targets',
      (WidgetTester tester) async {
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return <Map<String, Object?>>[
              {
                'packageName': 'com.example.extremelylong.organization.identifier.application.reader',
                'appName': 'Extremely Long Educational Companion Reader With Extended Title Text',
                'isSystemApp': false,
              },
            ];
          }
          return null;
        });

        // 360dp compact + 200% text scaling
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _buildHarness(
            bridge: HybridAiBridge(),
            textScale: 2.0,
            savedReceipts: <PolicyReviewReceipt>[
              _makeSavedReceipt(
                id: 'r_long',
                subjectTitle: 'Extremely Long Educational Companion Reader With Extended Title Text',
                packageName: 'com.example.extremelylong.organization.identifier.application.reader',
                appName: 'Extremely Long Educational Companion Reader With Extended Title Text',
                createdAt: DateTime.utc(2026, 11, 18, 12),
              ),
            ],
          ),
        );
        await _flushPickerAsync(tester);

        // All interactive controls satisfy 48dp minimum height.
        for (final key in const <Key>[
          Key('app_picker_filter_all'),
          Key('app_picker_filter_downloaded'),
          Key('app_picker_filter_system'),
          ValueKey(
            'app_picker_recent_row_com.example.extremelylong.organization.identifier.application.reader',
          ),
        ]) {
          final size = tester.getSize(find.byKey(key));
          expect(size.height, greaterThanOrEqualTo(48.0));
        }

        final mainLongRow = find.byKey(
          const ValueKey(
            'app_picker_row_com.example.extremelylong.organization.identifier.application.reader',
          ),
        );
        await tester.scrollUntilVisible(
          mainLongRow,
          200,
          scrollable: find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          ),
        );
        expect(tester.getSize(mainLongRow).height, greaterThanOrEqualTo(48.0));
        final closeBtnFinder = find.byTooltip('Close');
        expect(
          tester.getSize(closeBtnFinder).height,
          greaterThanOrEqualTo(48.0),
        );
        expect(
          tester.getSize(closeBtnFinder).width,
          greaterThanOrEqualTo(48.0),
        );
        expect(tester.takeException(), isNull);

        // 900dp expanded width stays constrained cleanly to <= 720dp.
        tester.view.physicalSize = const Size(900, 1200);
        await tester.pumpWidget(
          _buildHarness(bridge: HybridAiBridge(), textScale: 1.0),
        );
        await _flushPickerAsync(tester);

        final searchBoxWidth = tester
            .getSize(find.byKey(const Key('app_picker_search_bar')))
            .width;
        expect(searchBoxWidth, lessThanOrEqualTo(720.0));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '13. supports Arabic RTL cleanly with mirrored chevron and no overflow',
      (WidgetTester tester) async {
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return <Map<String, Object?>>[
              {
                'packageName': 'com.example.arabickids',
                'appName': 'تطبيق القراءة للأطفال',
                'isSystemApp': false,
              },
            ];
          }
          return null;
        });

        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _buildHarness(
            bridge: HybridAiBridge(),
            locale: const Locale('ar'),
            textScale: 1.4,
          ),
        );
        await _flushPickerAsync(tester);

        expect(find.text('تطبيق القراءة للأطفال'), findsOneWidget);
        expect(find.text('com.example.arabickids'), findsOneWidget);
        expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
        expect(find.byIcon(LucideIcons.chevronRight), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '14. satisfies WCAG AA (>= 4.5:1) contrast across Light and Dark themes',
      (WidgetTester tester) async {
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return <Map<String, Object?>>[
              {
                'packageName': 'com.example.contrast',
                'appName': 'Contrast Check App',
                'isSystemApp': false,
              },
            ];
          }
          return null;
        });

        for (final mode in const <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
          await tester.pumpWidget(
            _buildHarness(
              bridge: HybridAiBridge(),
              themeMode: mode,
              savedReceipts: <PolicyReviewReceipt>[
                _makeSavedReceipt(
                  id: 'r_contrast',
                  subjectTitle: 'Contrast Check App',
                  packageName: 'com.example.contrast',
                  appName: 'Contrast Check App',
                  createdAt: DateTime.utc(2026, 11, 18, 12),
                ),
              ],
            ),
          );
          await _flushPickerAsync(tester);

          final rowFinder = find.byKey(
            const ValueKey('app_picker_row_com.example.contrast'),
          );
          final cardSurface = tester.widget<EnpriveMaterialCardSurface>(
            find.descendant(
              of: rowFinder,
              matching: find.byType(EnpriveMaterialCardSurface),
            ),
          );
          final cardCtx = tester.element(find.byType(InstalledAppPickerSheet));
          final surfaces = cardCtx.enpriveSurfaces;
          final bg = cardSurface.backgroundColor ?? surfaces.card;

          final appNameText = tester.widget<Text>(
            find.descendant(
              of: rowFinder,
              matching: find.text('Contrast Check App'),
            ),
          );
          final pkgText = tester.widget<Text>(
            find.descendant(
              of: rowFinder,
              matching: find.text('com.example.contrast'),
            ),
          );
          expect(
            contrastRatio(appNameText.style!.color!, bg),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            contrastRatio(pkgText.style!.color!, bg),
            greaterThanOrEqualTo(4.5),
          );
          expect(find.byType(InstalledAppIcon), findsNWidgets(2));
          expect(tester.takeException(), isNull);
        }
      },
    );

    test('15. does not declare QUERY_ALL_PACKAGES or extra package-visibility permissions in AndroidManifest.xml', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue);
      final xml = manifestFile.readAsStringSync();
      expect(xml.contains('QUERY_ALL_PACKAGES'), isFalse);
      expect(xml.contains('PACKAGE_USAGE_STATS'), isTrue);
      expect(xml.contains('android.intent.category.LAUNCHER'), isTrue);
    });
  });

  group('D5.3-C hardening P2-2 status classification', () {
    PolicyReviewReceipt withKind(
      ReviewDiagnosticKind kind, {
      String id = 'r_kind',
      String? snapshotText,
      DateTime? createdAt,
    }) {
      final base = _makeSavedReceipt(
        id: id,
        subjectTitle: 'Kind App',
        packageName: 'com.example.kind',
        appName: 'Kind App',
        createdAt: createdAt ?? DateTime.utc(2026, 11, 18, 12),
        permissionOnly: kind == ReviewDiagnosticKind.devicePermissionInspection,
      );
      return base.copyWith(diagnosticKind: kind, snapshotText: snapshotText);
    }

    InstalledAppReviewStatus statusOf(List<PolicyReviewReceipt> receipts) =>
        InstalledAppPickerModel.statusForPackage(
          'com.example.kind',
          InstalledAppPickerModel.latestSavedReceiptByPackage(receipts),
        );

    test('18. insufficientPolicyMaterial with policy text reports Permissions inspected', () {
      final receipt = withKind(ReviewDiagnosticKind.insufficientPolicyMaterial);
      expect(receipt.snapshotText.trim(), isNotEmpty);
      expect(receipt.permissionReport, isNotNull);
      expect(receipt.isPermissionOnlyInspection, isFalse);
      expect(
        statusOf([receipt]),
        InstalledAppReviewStatus.permissionsInspected,
      );
    });

    test('19. validated with policy text reports Policy review saved', () {
      expect(
        statusOf([withKind(ReviewDiagnosticKind.validated)]),
        InstalledAppReviewStatus.policyReviewSaved,
      );
    });

    test('20. cloudUnavailableLocalFallback with policy text reports Policy review saved', () {
      expect(
        statusOf([
          withKind(ReviewDiagnosticKind.cloudUnavailableLocalFallback),
        ]),
        InstalledAppReviewStatus.policyReviewSaved,
      );
    });

    test('21. devicePermissionInspection reports Permissions inspected', () {
      expect(
        statusOf([withKind(ReviewDiagnosticKind.devicePermissionInspection)]),
        InstalledAppReviewStatus.permissionsInspected,
      );
    });

    test('22. no receipt reports Not reviewed', () {
      expect(statusOf(const []), InstalledAppReviewStatus.notReviewed);
    });

    test('23. validated receipt with empty policy text never reports Policy review saved', () {
      final receipt = withKind(
        ReviewDiagnosticKind.validated,
        snapshotText: '   ',
      );
      expect(
        statusOf([receipt]),
        InstalledAppReviewStatus.permissionsInspected,
      );
    });

    test('24. equal-timestamp tie-break prefers completed review over insufficient material', () {
      final at = DateTime.utc(2026, 11, 18, 9);
      final insufficient = withKind(
        ReviewDiagnosticKind.insufficientPolicyMaterial,
        id: 'r_insufficient',
        createdAt: at,
      );
      final validated = withKind(
        ReviewDiagnosticKind.validated,
        id: 'r_validated',
        createdAt: at,
      );
      for (final order in [
        [insufficient, validated],
        [validated, insufficient],
      ]) {
        final latest = InstalledAppPickerModel.latestSavedReceiptByPackage(
          order,
        );
        expect(latest['com.example.kind']!.id, 'r_validated');
      }
    });

    testWidgets(
      '25. picker rows render neutral labels for each diagnostic kind',
      (WidgetTester tester) async {
        final apps = <String, ReviewDiagnosticKind?>{
          'com.example.insufficient':
              ReviewDiagnosticKind.insufficientPolicyMaterial,
          'com.example.validated': ReviewDiagnosticKind.validated,
          'com.example.fallback':
              ReviewDiagnosticKind.cloudUnavailableLocalFallback,
          'com.example.permonly':
              ReviewDiagnosticKind.devicePermissionInspection,
          'com.example.none': null,
        };
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return [
              for (final pkg in apps.keys)
                <String, Object?>{
                  'packageName': pkg,
                  'appName': 'App ${pkg.split('.').last}',
                  'isSystemApp': false,
                },
            ];
          }
          return null;
        });

        final receipts = <PolicyReviewReceipt>[
          for (final entry in apps.entries)
            if (entry.value != null)
              _makeSavedReceipt(
                id: 'r_${entry.key}',
                subjectTitle: 'App ${entry.key.split('.').last}',
                packageName: entry.key,
                appName: 'App ${entry.key.split('.').last}',
                createdAt: DateTime.utc(2026, 11, 18, 12),
                permissionOnly:
                    entry.value ==
                    ReviewDiagnosticKind.devicePermissionInspection,
              ).copyWith(diagnosticKind: entry.value),
        ];

        await tester.pumpWidget(
          _buildHarness(bridge: HybridAiBridge(), savedReceipts: receipts),
        );
        await _flushPickerAsync(tester);

        const expected = <String, String>{
          'com.example.insufficient': 'Permissions inspected',
          'com.example.validated': 'Policy review saved',
          'com.example.fallback': 'Policy review saved',
          'com.example.permonly': 'Permissions inspected',
          'com.example.none': 'Not reviewed',
        };
        final scrollable = find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first;
        for (final entry in expected.entries) {
          final row = find.byKey(ValueKey('app_picker_row_${entry.key}'));
          await tester.scrollUntilVisible(row, 120, scrollable: scrollable);
          await tester.pump();
          expect(
            find.descendant(of: row, matching: find.text(entry.value)),
            findsOneWidget,
            reason: '${entry.key} should show ${entry.value}',
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('D5.3-C hardening P2-3 regression coverage', () {
    testWidgets(
      '26. falls back to receiptRepository when savedReceipts is omitted',
      (WidgetTester tester) async {
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return <Map<String, Object?>>[
              {
                'packageName': 'com.example.repo',
                'appName': 'Repo App',
                'isSystemApp': false,
              },
            ];
          }
          return null;
        });
        final repo = ReceiptRepository(useInMemoryOnly: true);
        await repo.saveReceipt(
          _makeSavedReceipt(
            id: 'r_repo',
            subjectTitle: 'Repo App',
            packageName: 'com.example.repo',
            appName: 'Repo App',
            createdAt: DateTime.utc(2026, 11, 18, 12),
          ),
        );

        await tester.pumpWidget(
          M3EMaterialApp(
            data: EnpriveM3ETheme.lightThemeData,
            typeface: EnpriveM3ETheme.typefaceConfig,
            autoTheming: false,
            dynamicColoring: false,
            initialTheme: Brightness.light,
            theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
            darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
            localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            appBuilder: (context, child) => EnpriveM3EBridgeScope(
              themeMode: ThemeMode.light,
              child: child ?? const SizedBox.shrink(),
            ),
            home: Scaffold(
              body: InstalledAppPickerSheet(
                bridge: HybridAiBridge(),
                eduTrackPolicyText: '',
                calmMathPolicyText: '',
                receiptRepository: repo,
              ),
            ),
          ),
        );
        await _flushPickerAsync(tester);

        expect(find.text('Recently checked'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('app_picker_row_com.example.repo')),
            matching: find.text('Policy review saved'),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '27. empty installed list with empty sample policy text hides the sample action',
      (WidgetTester tester) async {
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return const <Map<String, Object?>>[];
          }
          return null;
        });
        await tester.pumpWidget(
          _buildHarness(
            bridge: HybridAiBridge(),
            eduTrackPolicyText: '',
            calmMathPolicyText: '  ',
          ),
        );
        await _flushPickerAsync(tester);

        expect(
          find.byKey(const Key('app_picker_empty_installed_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('app_picker_empty_sample_action')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '28. empty installed list with valid sample policy text shows the sample action',
      (WidgetTester tester) async {
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return const <Map<String, Object?>>[];
          }
          return null;
        });
        await tester.pumpWidget(
          _buildHarness(
            bridge: HybridAiBridge(),
            eduTrackPolicyText: '',
            calmMathPolicyText: 'CalmMath sample policy text.',
          ),
        );
        await _flushPickerAsync(tester);

        expect(
          find.byKey(const Key('app_picker_empty_installed_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('app_picker_empty_sample_action')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('D5.3-C hardening P1-1 TalkBack semantics', () {
    testWidgets(
      '16. TalkBack: installed-app row exposes one coherent button announcement',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return <Map<String, Object?>>[
              {
                'packageName': 'com.example.talkback',
                'appName': 'Talkback Notes',
                'isSystemApp': false,
              },
            ];
          }
          return null;
        });

        await tester.pumpWidget(_buildHarness(bridge: HybridAiBridge()));
        await _flushPickerAsync(tester);

        final l10n = lookupAppLocalizations(const Locale('en'));
        final nodes = _collectSemanticsNodes(tester);
        final labels = nodes
            .map((n) => n.getSemanticsData().label)
            .where((l) => l.isNotEmpty)
            .toList();

        int occurrences(String needle) => labels.fold<int>(
          0,
          (sum, label) => sum + needle.allMatches(label).length,
        );

        expect(
          occurrences('Talkback Notes'),
          1,
          reason: 'App name must be announced once. Labels: $labels',
        );
        expect(
          occurrences('com.example.talkback'),
          1,
          reason: 'Package identifier must be announced once. Labels: $labels',
        );
        expect(
          occurrences(l10n.appPickerStatusNotReviewed),
          1,
          reason: 'Receipt status must be announced once. Labels: $labels',
        );

        final rowNode = nodes.singleWhere(
          (n) => n.getSemanticsData().label.contains('Talkback Notes'),
        );
        final data = rowNode.getSemanticsData();
        expect(
          data.label,
          'Talkback Notes, com.example.talkback, ${l10n.appPickerStatusNotReviewed}',
        );
        expect(data.label.contains('\n'), isFalse);
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue);

        await tester.tap(
          find.byKey(const ValueKey('app_picker_row_com.example.talkback')),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        handle.dispose();
      },
    );

    testWidgets(
      '17. TalkBack: compact empty sample action is announced once and stays actionable',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return const <Map<String, Object?>>[];
          }
          return null;
        });

        await tester.pumpWidget(_buildHarness(bridge: HybridAiBridge()));
        await _flushPickerAsync(tester);

        expect(
          find.byKey(const Key('app_picker_empty_sample_action')),
          findsOneWidget,
        );

        final l10n = lookupAppLocalizations(const Locale('en'));
        final nodes = _collectSemanticsNodes(tester);
        final labels = nodes
            .map((n) => n.getSemanticsData().label)
            .where((l) => l.isNotEmpty)
            .toList();
        final badgeCount = labels.fold<int>(
          0,
          (sum, label) =>
              sum + l10n.sampleSyntheticBadge.allMatches(label).length,
        );
        expect(
          badgeCount,
          1,
          reason: 'Synthetic badge must be announced once. Labels: $labels',
        );

        final sampleNode = nodes.singleWhere(
          (n) => n.getSemanticsData().label.contains(l10n.sampleSyntheticBadge),
        );
        final data = sampleNode.getSemanticsData();
        expect(
          data.label,
          '${l10n.trySampleCheck}, ${l10n.sampleSyntheticBadge}',
        );
        expect(data.label.contains('\n'), isFalse);
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
        expect(tester.takeException(), isNull);
        handle.dispose();
      },
    );
  });

  group('Step C / Defect 4: Picker search clear button accessibility', () {
    testWidgets(
      '29. hides clear control when empty, exposes a labeled actionable clear button without leaking Clear into the search field when non-empty, and clears query while keeping filters intact',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        var listCalls = 0;
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            listCalls++;
            return <Map<String, Object?>>[
              {
                'packageName': 'org.example.sketchpad',
                'appName': 'Sketch Pad',
                'isSystemApp': false,
              },
              {
                'packageName': 'com.vendor.clockworks',
                'appName': 'World Clock',
                'isSystemApp': true,
              },
              {
                'packageName': 'com.vendor.camera',
                'appName': 'System Camera',
                'isSystemApp': true,
              },
            ];
          }
          return null;
        });

        await tester.pumpWidget(_buildHarness(bridge: HybridAiBridge()));
        await _flushPickerAsync(tester);

        final l10n = lookupAppLocalizations(const Locale('en'));
        final searchBarFinder = find.byKey(const Key('app_picker_search_bar'));
        final clearBtnFinder = find.byKey(
          const Key('app_picker_clear_search_btn'),
        );

        // Empty query: no clear button inside the search bar
        expect(clearBtnFinder, findsNothing);
        expect(
          find.descendant(
            of: searchBarFinder,
            matching: find.byType(IconButton),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: searchBarFinder,
            matching: find.byType(M3EIconButton),
          ),
          findsNothing,
        );

        // Enter a search query
        await tester.enterText(find.byType(EditableText), 'sketch');
        await tester.pump();

        expect(find.text('Sketch Pad'), findsOneWidget);
        expect(find.text('World Clock'), findsNothing);

        // Package M3EIconButton must not be used (its semantics split label from action)
        expect(
          find.descendant(
            of: searchBarFinder,
            matching: find.byType(M3EIconButton),
          ),
          findsNothing,
        );
        expect(clearBtnFinder, findsOneWidget);
        expect(
          find.descendant(
            of: searchBarFinder,
            matching: find.byType(IconButton),
          ),
          findsOneWidget,
        );

        // >= 48dp hit target
        final clearSize = tester.getSize(clearBtnFinder);
        expect(clearSize.width, greaterThanOrEqualTo(48.0));
        expect(clearSize.height, greaterThanOrEqualTo(48.0));

        // Inspect semantics across the sheet: search field stays coherent and
        // never leaks "Clear", and no unlabeled button node exists.
        final allNodes = _collectSemanticsNodes(tester);
        final textFieldNodes = allNodes
            .where((n) => n.getSemanticsData().flagsCollection.isTextField)
            .toList();
        expect(textFieldNodes, isNotEmpty);
        for (final fieldNode in textFieldNodes) {
          final fieldData = fieldNode.getSemanticsData();
          expect(
            fieldData.label,
            isNot(contains('Clear')),
            reason:
                'Search field semantics label must not leak Clear. Got: "${fieldData.label}"',
          );
          expect(
            fieldData.tooltip,
            isNot(contains('Clear')),
            reason:
                'Search field tooltip must not leak Clear. Got: "${fieldData.tooltip}"',
          );
        }
        expect(
          textFieldNodes.any(
            (n) => n.getSemanticsData().label == l10n.appPickerSearchHint,
          ),
          isTrue,
          reason:
              'Expected parent search field semantics node to carry exact hint label "${l10n.appPickerSearchHint}".',
        );

        // Every actionable button node in the sheet carries an accessible name.
        for (final node in allNodes) {
          final d = node.getSemanticsData();
          if (d.flagsCollection.isButton &&
              !d.flagsCollection.isTextField &&
              d.hasAction(ui.SemanticsAction.tap)) {
            expect(
              d.label.isNotEmpty || d.tooltip.isNotEmpty,
              isTrue,
              reason: 'Found unlabeled actionable button node: $node',
            );
          }
        }

        // The actionable clear button node itself carries the localized name,
        // button role, tap action, and focusability.
        final clearNode = tester.getSemantics(clearBtnFinder);
        final clearData = clearNode.getSemanticsData();
        expect(clearData.flagsCollection.isButton, isTrue);
        expect(clearData.hasAction(ui.SemanticsAction.tap), isTrue);
        expect(
          clearData.flagsCollection.isFocused,
          isNot(ui.Tristate.none),
          reason: 'Clear button must be focusable.',
        );
        final clearAccessibleName = clearData.label.isNotEmpty
            ? clearData.label
            : clearData.tooltip;
        expect(clearAccessibleName, l10n.tooltipClearSearch);

        // Localized clear label is announced exactly once across the tree.
        final allClearMentions = allNodes.fold<int>(0, (sum, n) {
          final d = n.getSemanticsData();
          return sum +
              l10n.tooltipClearSearch.allMatches(d.label).length +
              l10n.tooltipClearSearch.allMatches(d.tooltip).length;
        });
        expect(
          allClearMentions,
          1,
          reason:
              'Clear label "${l10n.tooltipClearSearch}" must be announced exactly once.',
        );

        // Activate via SemanticsAction.tap and verify controller + list restore
        final semanticsOwner = tester
            .renderObject(searchBarFinder)
            .owner!
            .semanticsOwner!;
        semanticsOwner.performAction(clearNode.id, ui.SemanticsAction.tap);
        await tester.pump();

        final editable = tester.widget<EditableText>(find.byType(EditableText));
        expect(editable.controller.text, isEmpty);
        expect(find.text('Sketch Pad'), findsOneWidget);
        expect(find.text('World Clock'), findsOneWidget);
        expect(find.text('System Camera'), findsOneWidget);
        expect(clearBtnFinder, findsNothing);

        // Filtering stays intact when combining filter chip + search + pointer tap
        await tester.tap(find.byKey(const Key('app_picker_filter_system')));
        await tester.pump();
        expect(find.text('Sketch Pad'), findsNothing);
        expect(find.text('World Clock'), findsOneWidget);
        expect(find.text('System Camera'), findsOneWidget);

        await tester.enterText(find.byType(EditableText), 'camera');
        await tester.pump();
        expect(find.text('System Camera'), findsOneWidget);
        expect(find.text('World Clock'), findsNothing);
        expect(clearBtnFinder, findsOneWidget);

        await tester.tap(clearBtnFinder);
        await tester.pump();
        expect(editable.controller.text, isEmpty);
        expect(clearBtnFinder, findsNothing);
        expect(find.text('System Camera'), findsOneWidget);
        expect(find.text('World Clock'), findsOneWidget);
        expect(find.text('Sketch Pad'), findsNothing);
        expect(listCalls, 1);
        expect(tester.takeException(), isNull);
        handle.dispose();
      },
    );

    testWidgets(
      '30. search clear button remains accessible and >= 48dp under Arabic RTL and 200% text scaling',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        messenger.setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'listLaunchableApps') {
            return <Map<String, Object?>>[
              {
                'packageName': 'com.example.arabickids',
                'appName': 'تطبيق القراءة للأطفال',
                'isSystemApp': false,
              },
              {
                'packageName': 'com.example.mathkids',
                'appName': 'تطبيق الحساب',
                'isSystemApp': false,
              },
            ];
          }
          return null;
        });

        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _buildHarness(
            bridge: HybridAiBridge(),
            locale: const Locale('ar'),
            textScale: 2.0,
          ),
        );
        await _flushPickerAsync(tester);

        final l10nAr = lookupAppLocalizations(const Locale('ar'));
        final searchBarFinder = find.byKey(const Key('app_picker_search_bar'));
        final clearBtnFinder = find.byKey(
          const Key('app_picker_clear_search_btn'),
        );
        expect(clearBtnFinder, findsNothing);

        await tester.enterText(find.byType(EditableText), 'الحساب');
        await tester.pump();

        expect(find.text('تطبيق الحساب'), findsOneWidget);
        expect(find.text('تطبيق القراءة للأطفال'), findsNothing);
        expect(clearBtnFinder, findsOneWidget);

        final clearSize = tester.getSize(clearBtnFinder);
        expect(clearSize.width, greaterThanOrEqualTo(48.0));
        expect(clearSize.height, greaterThanOrEqualTo(48.0));

        // Verify RTL placement: trailing clear button sits on the left half
        final barRect = tester.getRect(searchBarFinder);
        final clearRect = tester.getRect(clearBtnFinder);
        expect(clearRect.center.dx, lessThan(barRect.center.dx));

        final allNodes = _collectSemanticsNodes(tester);
        for (final node in allNodes) {
          final d = node.getSemanticsData();
          if (d.flagsCollection.isTextField) {
            expect(d.label, isNot(contains('Clear')));
          }
        }
        final clearNode = tester.getSemantics(clearBtnFinder);
        final clearData = clearNode.getSemanticsData();
        expect(clearData.flagsCollection.isButton, isTrue);
        expect(clearData.hasAction(ui.SemanticsAction.tap), isTrue);
        expect(clearData.flagsCollection.isFocused, isNot(ui.Tristate.none));
        final clearName = clearData.label.isNotEmpty
            ? clearData.label
            : clearData.tooltip;
        expect(clearName, l10nAr.tooltipClearSearch);

        await tester.tap(clearBtnFinder);
        await tester.pump();

        expect(
          tester.widget<EditableText>(find.byType(EditableText)).controller.text,
          isEmpty,
        );
        expect(clearBtnFinder, findsNothing);
        expect(find.text('تطبيق القراءة للأطفال'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('تطبيق الحساب'),
          200,
          scrollable: find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          ),
        );
        expect(find.text('تطبيق الحساب'), findsOneWidget);
        expect(tester.takeException(), isNull);
        handle.dispose();
      },
    );
  });
}

List<SemanticsNode> _collectSemanticsNodes(WidgetTester tester) {
  final owner = tester
      .renderObject(find.byType(InstalledAppPickerSheet))
      .owner!
      .semanticsOwner!;
  final result = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    result.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(owner.rootSemanticsNode!);
  return result;
}
