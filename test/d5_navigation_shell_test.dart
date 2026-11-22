import 'dart:ui' as ui;

import 'package:enprive/main.dart';
import 'package:enprive/screens/companion_screen.dart';
import 'package:enprive/widgets/enprive_tactile_button.dart';
import 'package:enprive/widgets/m3e/enprive_m3e_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpFrames(WidgetTester tester, {int count = 8}) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 25)),
  );
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 90));
  }
}

void main() {
  const hybridChannel = MethodChannel('com.enprive/hybrid_ai');
  const companionChannel = MethodChannel('com.enprive/companion');

  void setupDefaultPlatformMocks({
    VoidCallback? onReturnToPreviousApp,
    Map<String, dynamic>? initialCompanionInvocation,
  }) {
    SharedPreferences.setMockInitialValues({
      'enprive_pref_completed_onboarding': true,
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, (call) async {
          if (call.method == 'getDeviceCapability') {
            return {
              'isSupported': true,
              'modelStatus': 'AVAILABLE',
              'modelCategory': 'PREVIEW',
              'apiLevel': 35,
              'userMessage': 'Ready',
            };
          }
          if (call.method == 'getInitialIncomingPayload' ||
              call.method == 'getInitialSelectedText') {
            return null;
          }
          return null;
        });

    var deliveredInitial = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(companionChannel, (call) async {
          switch (call.method) {
            case 'getInitialCompanionInvocation':
              if (initialCompanionInvocation != null && !deliveredInitial) {
                deliveredInitial = true;
                return initialCompanionInvocation;
              }
              return null;
            case 'checkUsageAccess':
              return {'status': 'denied', 'deviceLocked': false};
            case 'getQuickSettingsTileStatus':
              return {
                'isTileAdded': false,
                'canRequestDirectAdd': true,
                'hasDeclinedBefore': false,
              };
            case 'resolveForegroundApp':
              return {
                'resolutionStatus': 'usageAccessDenied',
                'confidence': 'none',
                'usageAccessStatus': 'denied',
                'userMessage': 'Usage Access is optional.',
                'candidates': <Map<String, dynamic>>[],
              };
            case 'returnToPreviousApp':
              onReturnToPreviousApp?.call();
              return true;
          }
          return null;
        });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hybridChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(companionChannel, null);
  });

  group('D5.2 Adaptive Navigation Shell & Restoration Tests', () {
    testWidgets(
      'Compact (<600dp) renders docked M3ENavigationBar (Check · Receipts · Learn), single headers, AppBar Settings, and PopScope back-to-Check',
      (WidgetTester tester) async {
        setupDefaultPlatformMocks();
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const EnpriveApp(showSplashOnLaunch: false));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byKey(const Key('enprive_m3e_nav_bar')), findsOneWidget);
        expect(find.byKey(const Key('enprive_m3e_nav_rail')), findsNothing);
        expect(find.text('Check'), findsOneWidget);
        expect(find.text('Receipts'), findsWidgets);
        expect(find.text('Learn'), findsOneWidget);
        expect(find.byKey(const Key('nav_settings_btn')), findsOneWidget);

        // Switch to Learn tab -> single header, sculpted 2x2 folder cards, interactive guide sheet
        await tester.tap(find.text('Learn'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(
          find.byKey(const Key('learn_folder_privacy_policy')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('learn_folder_android_permissions')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('learn_folder_third_parties')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('learn_folder_evidence')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const Key('learn_folder_android_permissions')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(
          find.byKey(const Key('learn_lesson_screen_android_permissions')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('learn_lesson_listen_btn')), findsOneWidget);

        // Return from full-screen lesson via Back button, then verify PopScope returns Learn -> Check
        await tester.tap(find.byKey(const Key('learn_lesson_back_btn')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 350));
        expect(
          find.byKey(const Key('learn_lesson_screen_android_permissions')),
          findsNothing,
        );

        await tester.binding.handlePopRoute();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Back on Check tab
        expect(
          find.byKey(const Key('check_quick_settings_card')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Medium (720dp) and Large (1280dp) windows switch cleanly to M3ENavigationRail with footer Settings and zero M3ENavigationBar',
      (WidgetTester tester) async {
        setupDefaultPlatformMocks();
        tester.view.physicalSize = const Size(720, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const EnpriveApp(showSplashOnLaunch: false));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byKey(const Key('enprive_m3e_nav_rail')), findsOneWidget);
        expect(find.byKey(const Key('enprive_m3e_nav_bar')), findsNothing);
        expect(find.byKey(const Key('nav_settings_btn')), findsOneWidget);

        final mediumRail = tester.widget<M3ENavigationRail>(
          find.byKey(const Key('enprive_m3e_nav_rail')),
        );
        expect(mediumRail.type, M3ENavigationRailType.collapsed);

        // Resize to Large (1280dp) -> expanded rail
        tester.view.physicalSize = const Size(1280, 900);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 450));

        final largeRail = tester.widget<M3ENavigationRail>(
          find.byKey(const Key('enprive_m3e_nav_rail')),
        );
        expect(largeRail.type, M3ENavigationRailType.expanded);
        expect(find.byKey(const Key('nav_settings_btn')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Quick Settings Companion system Back & AppBar close return to caller app, while Open full Enprive stays in app',
      (WidgetTester tester) async {
        var returnCalls = 0;
        setupDefaultPlatformMocks(
          onReturnToPreviousApp: () => returnCalls++,
          initialCompanionInvocation: {
            'invocationId': 'qs_back_test_1',
            'source': 'quick_settings',
            'timestampMs': DateTime.now().millisecondsSinceEpoch,
            'deviceLocked': false,
          },
        );

        await tester.pumpWidget(const EnpriveApp(showSplashOnLaunch: true));
        await _pumpFrames(tester);

        expect(find.byType(CompanionScreen), findsOneWidget);
        expect(
          find.byKey(const Key('companion_open_enprive_btn')),
          findsOneWidget,
        );

        // Tapping AppBar Close (X) on a Quick Settings launch triggers returnToPreviousApp
        await tester.tap(find.byKey(const Key('companion_appbar_back_btn')));
        await _pumpFrames(tester);

        expect(returnCalls, 1);
        expect(find.byType(CompanionScreen), findsNothing);

        // Warm Quick Settings launch + Android system Back (PopScope) -> triggers returnToPreviousApp
        final codec = const StandardMethodCodec();
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              'com.enprive/companion',
              codec.encodeMethodCall(
                MethodCall('onCompanionInvocation', {
                  'invocationId': 'qs_sys_back_2',
                  'source': 'quick_settings',
                  'timestampMs': DateTime.now().millisecondsSinceEpoch,
                  'deviceLocked': false,
                }),
              ),
              (_) {},
            );
        await _pumpFrames(tester);
        expect(find.byType(CompanionScreen), findsOneWidget);

        await tester.binding.handlePopRoute();
        await _pumpFrames(tester);
        expect(returnCalls, 2);
        expect(find.byType(CompanionScreen), findsNothing);

        // Now send a warm Quick Settings invocation while Settings is open ->
        // clears Settings cleanly, opens Companion, and "Open full Enprive app" stays in Enprive.
        await tester.tap(find.byKey(const Key('nav_settings_btn')));
        await _pumpFrames(tester);
        expect(find.byKey(const Key('settings_back_btn')), findsOneWidget);

        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              'com.enprive/companion',
              codec.encodeMethodCall(
                MethodCall('onCompanionInvocation', {
                  'invocationId': 'qs_warm_over_settings_3',
                  'source': 'quick_settings',
                  'timestampMs': DateTime.now().millisecondsSinceEpoch,
                  'deviceLocked': false,
                }),
              ),
              (_) {},
            );
        await _pumpFrames(tester);

        expect(find.byType(CompanionScreen), findsOneWidget);

        final openFullBtn = find.byKey(const Key('companion_open_enprive_btn'));
        await tester.ensureVisible(openFullBtn);
        await tester.pump();
        await tester.tap(openFullBtn);
        await _pumpFrames(tester);

        // Stayed inside Enprive without invoking returnToPreviousApp again
        expect(returnCalls, 2);
        expect(find.byKey(const Key('check_quick_settings_card')), findsOneWidget);
        expect(find.byKey(const Key('settings_back_btn')), findsNothing);
      },
    );

    testWidgets(
      'Check & Learn sculpted archival folder cards render cleanly in Arabic RTL + Dark Mode + 200% text scale',
      (WidgetTester tester) async {
        setupDefaultPlatformMocks();
        SharedPreferences.setMockInitialValues({
          'enprive_pref_completed_onboarding': true,
          'enprive_pref_language_code': 'ar',
          'enprive_pref_theme_mode': 'dark',
        });

        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MediaQuery(
            data: MediaQueryData(
              size: Size(360, 800),
              textScaler: TextScaler.linear(2.0),
              disableAnimations: true,
            ),
            child: EnpriveApp(showSplashOnLaunch: false),
          ),
        );
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.text('فحص'), findsOneWidget);
        expect(find.text('تعلّم'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('تعلّم'));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(
          find.byKey(const Key('learn_folder_android_permissions')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'P1/P2 Fix Verification: Learn header stays top-anchored on 900dp and single-category filter; EnpriveFilterChip has >=48dp target, checkmark & selected semantics; cards & tactile buttons have zero duplicate semantics',
      (WidgetTester tester) async {
        setupDefaultPlatformMocks();
        tester.view.physicalSize = const Size(900, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const EnpriveApp(showSplashOnLaunch: false));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Switch to Learn on 900x1200dp viewport
        await tester.tap(find.text('Learn'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        final learnHeadingFinder = find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.text('Learn'),
        );
        final allTopicsTopY = tester.getTopLeft(learnHeadingFinder).dy;
        // Must sit near top-of-viewport (not vertically centered at ~580px)
        expect(allTopicsTopY, lessThan(80.0));

        // Verify EnpriveFilterChip uses M3EChip, meets >=48dp height, and reports
        // selected + button + tap semantics cleanly.
        final permissionsChipFinder = find.widgetWithText(
          EnpriveFilterChip,
          'Permissions',
        );
        expect(permissionsChipFinder, findsOneWidget);
        expect(
          find.descendant(
            of: permissionsChipFinder,
            matching: find.byType(M3EChip),
          ),
          findsOneWidget,
        );
        final chipSize = tester.getSize(permissionsChipFinder);
        expect(chipSize.height, greaterThanOrEqualTo(48.0));

        final semHandle = tester.ensureSemantics();
        try {
          final allChipNode = tester.getSemantics(
            find.widgetWithText(EnpriveFilterChip, 'All topics'),
          );
          final permChipBefore = tester.getSemantics(permissionsChipFinder);
          expect(allChipNode.label, 'All topics');
          expect(allChipNode.flagsCollection.isButton, isTrue);
          expect(allChipNode.flagsCollection.isSelected, ui.Tristate.isTrue);
          expect(
            permChipBefore.flagsCollection.isSelected,
            ui.Tristate.isFalse,
          );
          expect(
            permChipBefore.getSemanticsData().hasAction(ui.SemanticsAction.tap),
            isTrue,
          );

          // Tap Permissions -> single card rendered AND Learn header top Y stays identical
          await tester.tap(permissionsChipFinder);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 250));

          expect(
            find.byKey(const Key('learn_folder_android_permissions')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('learn_folder_privacy_policy')),
            findsNothing,
          );
          final filteredTopY = tester.getTopLeft(learnHeadingFinder).dy;
          expect(filteredTopY, equals(allTopicsTopY));

          final permChipAfter = tester.getSemantics(permissionsChipFinder);
          expect(permChipAfter.flagsCollection.isSelected, ui.Tristate.isTrue);

          // Verify EnpriveFolderTabCard exposes single clean label without inner text duplication
          final folderSemantics = tester.getSemantics(
            find.byKey(const Key('learn_folder_android_permissions')),
          );
          expect(
            folderSemantics.label,
            'Phone permissions. 5 steps. The four Android choices & where to review them',
          );
          expect(folderSemantics.label.contains('\n'), isFalse);
          expect(folderSemantics.flagsCollection.isButton, isTrue);

          // Verify nested interactive CTA inside EnpriveStackedFolderDeck remains semantic
          // and EnpriveTactileButton has zero duplicate child text concatenation.
          final ctaFinder = find.byKey(const Key('learn_check_app_bridge_btn'));
          expect(ctaFinder, findsOneWidget);
          final ctaSemantics = tester.getSemantics(ctaFinder);
          expect(ctaSemantics.label, 'Apply it · Check an app');
          expect(ctaSemantics.label.contains('\n'), isFalse);
          expect(ctaSemantics.flagsCollection.isButton, isTrue);
          expect(
            ctaSemantics.getSemanticsData().hasAction(ui.SemanticsAction.tap),
            isTrue,
          );

          // Check tab EnpriveTactileButton also has single non-duplicated label
          await tester.tap(find.text('Check'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          final checkAppBtn = find.widgetWithText(
            EnpriveTactileButton,
            'Check an app',
          );
          final checkAppSem = tester.getSemantics(checkAppBtn);
          expect(checkAppSem.label, 'Check an app');
          expect(checkAppSem.label.contains('\n'), isFalse);
          expect(checkAppSem.flagsCollection.isButton, isTrue);
          expect(tester.takeException(), isNull);
        } finally {
          semHandle.dispose();
        }
      },
    );
  });
}
