import 'dart:ui' as ui;

import 'package:enprive/core/theme/enprive_m3e_theme.dart';
import 'package:enprive/domain/learn/learn_lesson.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/screens/learn_home_screen.dart';
import 'package:enprive/screens/learn_lesson_screen.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/learn/diagrams/evidence_categories_legend.dart';
import 'package:enprive/widgets/learn/diagrams/evidence_layers_diagram.dart';
import 'package:enprive/widgets/learn/diagrams/permissions_ladder_diagram.dart';
import 'package:enprive/widgets/learn/diagrams/policy_limit_diagram.dart';
import 'package:enprive/widgets/learn/diagrams/third_party_diagram.dart';
import 'package:enprive/widgets/m3e/enprive_m3e_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as modern;

class _FakeLearnTtsBridge extends HybridAiBridge {
  bool speakResult = true;
  final List<Map<String, Object?>> speakTextCalls = [];
  int stopSpeakingCalls = 0;
  int cloudTtsCalls = 0;

  @override
  Future<bool> speakText(
    String text, {
    String languageCode = 'en',
    String? requestId,
    double? speechRate,
  }) async {
    speakTextCalls.add({
      'text': text,
      'languageCode': languageCode,
      'requestId': requestId,
    });
    return speakResult;
  }

  @override
  Future<bool> stopSpeaking() async {
    stopSpeakingCalls++;
    return true;
  }

  @override
  Future<VoiceSpeakResult> speakWithGeminiTts({
    required String requestId,
    required String text,
    required bool cloudConsent,
    String languageCode = 'en',
    bool fallbackToLocalOnFailure = true,
  }) async {
    cloudTtsCalls++;
    return const VoiceSpeakResult(
      status: 'blocked',
      route: VoicePlaybackRoute.none,
    );
  }
}

Widget _wrapLearnApp({
  required Widget home,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  bool disableAnimations = true,
  Locale locale = const Locale('en'),
}) {
  return modern.MaterialApp(
    theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
    darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
    themeMode: mode == ThemeMode.dark
        ? modern.ThemeMode.dark
        : modern.ThemeMode.light,
    localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: disableAnimations,
      ),
      child: EnpriveM3EBridgeScope(
        themeMode: mode,
        child: child ?? const SizedBox.shrink(),
      ),
    ),
    home: Scaffold(body: home),
  );
}

void main() {
  final l10nEn = lookupAppLocalizations(const Locale('en'));
  final lessons = buildLearnLessons(l10nEn);

  group('Learn lessons domain model guardrails', () {
    test(
      'builds all four lessons as data-driven entries with 4-5 steps, plain spoken text, and zero safety-certification claims',
      () {
        expect(lessons, hasLength(4));
        expect(
          lessons.map((l) => l.id).toList(),
          [
            LearnLessonIds.privacyPolicy,
            LearnLessonIds.androidPermissions,
            LearnLessonIds.thirdParties,
            LearnLessonIds.evidence,
          ],
        );

        for (final lesson in lessons) {
          expect(lesson.intro.trim().isNotEmpty, isTrue);
          expect(lesson.steps.length, inInclusiveRange(3, 5));
          expect(lesson.quickCheck.options, hasLength(3));
          expect(
            lesson.quickCheck.correctIndex,
            inInclusiveRange(0, lesson.quickCheck.options.length - 1),
          );

          final spoken = lesson.spokenText(l10nEn);
          expect(spoken, contains(lesson.title));
          expect(spoken, contains(lesson.intro));
          for (final step in lesson.steps) {
            expect(spoken, contains(step));
          }
          expect(spoken, contains(lesson.quickCheck.question));
          // Spoken script stays comfortably inside DeniVoicePolicy's 3,200 char budget
          expect(spoken.length, lessThan(2200));
          // Never includes Flutter/widget code tokens
          expect(spoken, isNot(contains('CustomPainter')));
          expect(spoken, isNot(contains('Widget')));
          // Never claims a binary safety certification
          expect(spoken.toLowerCase(), isNot(contains('certified safe')));
        }
      },
    );
  });

  group('Full-screen illustrated Learn lessons widget tests (L1–L4)', () {
    final lessonSpecs = [
      (
        id: LearnLessonIds.privacyPolicy,
        number: 1,
        diagramType: PolicyLimitDiagram,
        diagramSemantic: l10nEn.learnDiagramPolicySemantic,
        correctOptionIndex: 1,
        wrongOptionIndex: 0,
      ),
      (
        id: LearnLessonIds.androidPermissions,
        number: 2,
        diagramType: PermissionsLadderDiagram,
        diagramSemantic: l10nEn.learnDiagramPermSemantic,
        correctOptionIndex: 0,
        wrongOptionIndex: 1,
      ),
      (
        id: LearnLessonIds.thirdParties,
        number: 3,
        diagramType: ThirdPartyDiagram,
        diagramSemantic: l10nEn.learnDiagramThirdPartySemantic,
        correctOptionIndex: 2,
        wrongOptionIndex: 0,
      ),
      (
        id: LearnLessonIds.evidence,
        number: 4,
        diagramType: EvidenceLayersDiagram,
        diagramSemantic: l10nEn.learnDiagramEvidenceSemantic(
          l10nEn.statusSourceMatched,
          l10nEn.statusDeviceObserved,
          l10nEn.statusInterpretation,
          l10nEn.statusUnverified,
        ),
        correctOptionIndex: 1,
        wrongOptionIndex: 0,
      ),
    ];

    for (final spec in lessonSpecs) {
      testWidgets(
        '${spec.id}: pushes full-screen LearnLessonScreen, renders progress + diagram + Semantics, Listen/Stop toggles offline, quick check works, Check bridge works',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(412, 915);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final fakeBridge = _FakeLearnTtsBridge();
          var checkBridgeCalls = 0;

          await tester.pumpWidget(
            _wrapLearnApp(
              home: LearnHomeScreen(
                hybridBridge: fakeBridge,
                onCheckAppRequested: () => checkBridgeCalls++,
              ),
            ),
          );
          await tester.pumpAndSettle();

          final folderFinder = find.byKey(Key('learn_folder_${spec.id}'));
          expect(folderFinder, findsOneWidget);
          await tester.ensureVisible(folderFinder);
          await tester.tap(folderFinder);
          await tester.pumpAndSettle();

          // Pushed full-screen route (NOT a modal bottom sheet)
          expect(find.byType(LearnLessonScreen), findsOneWidget);
          expect(
            find.byKey(Key('learn_lesson_screen_${spec.id}')),
            findsOneWidget,
          );
          expect(find.byType(BottomSheet), findsNothing);

          // Progress hint "Lesson X of 4", collapsing app bar & back button (>=48dp)
          expect(
            find.text(l10nEn.learnLessonProgress(spec.number, 4)),
            findsOneWidget,
          );
          final backBtn = find.byKey(const Key('learn_lesson_back_btn'));
          expect(backBtn, findsOneWidget);
          expect(tester.getSize(backBtn).width, greaterThanOrEqualTo(48.0));
          expect(tester.getSize(backBtn).height, greaterThanOrEqualTo(48.0));

          // Diagram rendered with single TalkBack description
          expect(find.byType(spec.diagramType), findsOneWidget);
          expect(find.bySemanticsLabel(spec.diagramSemantic), findsOneWidget);

          if (spec.id == LearnLessonIds.evidence) {
            expect(find.byType(EvidenceCategoriesLegend), findsOneWidget);
            expect(find.text(l10nEn.statusSourceMatched), findsWidgets);
            expect(find.text(l10nEn.statusDeviceObserved), findsWidgets);
            expect(find.text(l10nEn.statusInterpretation), findsWidgets);
            expect(find.text(l10nEn.statusUnverified), findsWidgets);
          }

          // Pinned offline Listen button: >= 48dp, toggles to Stop, calls local speakText only (0 cloud)
          final listenBtn = find.byKey(const Key('learn_lesson_listen_btn'));
          expect(listenBtn, findsOneWidget);
          final listenSize = tester.getSize(listenBtn);
          expect(listenSize.width, greaterThanOrEqualTo(48.0));
          expect(listenSize.height, greaterThanOrEqualTo(48.0));

          final semHandle = tester.ensureSemantics();
          try {
            final beforeSem = tester.getSemantics(listenBtn);
            expect(beforeSem.label, l10nEn.learnTooltipListenLesson);
            expect(
              beforeSem.getSemanticsData().hasAction(ui.SemanticsAction.tap),
              isTrue,
            );

            await tester.tap(listenBtn);
            await tester.pumpAndSettle();

            expect(fakeBridge.speakTextCalls, hasLength(1));
            expect(fakeBridge.cloudTtsCalls, 0);
            expect(
              find.byKey(const Key('learn_lesson_voice_offline_badge')),
              findsOneWidget,
            );
            expect(
              tester.getSemantics(listenBtn).label,
              l10nEn.learnTooltipStopLesson,
            );

            // Tap Stop -> calls stopSpeaking and resets button
            await tester.tap(listenBtn);
            await tester.pumpAndSettle();

            expect(fakeBridge.stopSpeakingCalls, 1);
            expect(
              find.byKey(const Key('learn_lesson_voice_offline_badge')),
              findsNothing,
            );
            expect(
              tester.getSemantics(listenBtn).label,
              l10nEn.learnTooltipListenLesson,
            );
          } finally {
            semHandle.dispose();
          }

          // Scroll to interactive Quick Check (Listen button stays reachable!)
          final scrollView = find.byKey(const Key('learn_lesson_scroll_view'));
          final wrongOption = find.byKey(
            Key('learn_quick_check_option_${spec.wrongOptionIndex}'),
          );
          await tester.dragUntilVisible(
            wrongOption,
            scrollView,
            const Offset(0, -260),
          );
          await tester.pumpAndSettle();

          // Pinned Listen button remains visible after scrolling
          expect(listenBtn, findsOneWidget);

          expect(
            tester.getSize(wrongOption).height,
            greaterThanOrEqualTo(48.0),
          );
          await tester.tap(wrongOption);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('learn_quick_check_feedback')),
            findsOneWidget,
          );
          expect(find.text(l10nEn.learnQuickCheckTryAgainBadge), findsOneWidget);

          final correctOption = find.byKey(
            Key('learn_quick_check_option_${spec.correctOptionIndex}'),
          );
          await tester.ensureVisible(correctOption);
          await tester.tap(correctOption);
          await tester.pumpAndSettle();

          expect(find.text(l10nEn.learnQuickCheckCorrectBadge), findsOneWidget);

          // Scroll to Check bridge CTA and verify it pops route & triggers callback
          final checkBridgeBtn = find.byKey(
            const Key('learn_lesson_check_app_btn'),
          );
          await tester.dragUntilVisible(
            checkBridgeBtn,
            scrollView,
            const Offset(0, -260),
          );
          await tester.pumpAndSettle();

          await tester.tap(checkBridgeBtn);
          await tester.pumpAndSettle();

          expect(checkBridgeCalls, 1);
          expect(find.byType(LearnLessonScreen), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        '${spec.id}: renders full-screen cleanly in dark mode, 200% text scale (360dp), and Arabic RTL with zero overflow',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          for (final locale in [const Locale('en'), const Locale('ar')]) {
            final fakeBridge = _FakeLearnTtsBridge();
            await tester.pumpWidget(
              _wrapLearnApp(
                mode: ThemeMode.dark,
                textScale: 2.0,
                disableAnimations: true,
                locale: locale,
                home: LearnHomeScreen(
                  hybridBridge: fakeBridge,
                  onCheckAppRequested: () {},
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: 'Home failed for ${spec.id} (${locale.languageCode})',
            );

            final folderFinder = find.byKey(Key('learn_folder_${spec.id}'));
            await tester.ensureVisible(folderFinder);
            await tester.pumpAndSettle();
            await tester.tap(folderFinder);
            await tester.pumpAndSettle();

            expect(
              find.byKey(Key('learn_lesson_screen_${spec.id}')),
              findsOneWidget,
            );
            expect(find.byType(spec.diagramType), findsOneWidget);
            expect(
              tester.takeException(),
              isNull,
              reason:
                  'Screen open failed for ${spec.id} (${locale.languageCode})',
            );

            // Scroll all the way down to bottom CTA at 200% text scale
            final scrollView = find.byKey(
              const Key('learn_lesson_scroll_view'),
            );
            final checkBridgeBtn = find.byKey(
              const Key('learn_lesson_check_app_btn'),
            );
            await tester.dragUntilVisible(
              checkBridgeBtn,
              scrollView,
              const Offset(0, -250),
            );
            await tester.pumpAndSettle();

            expect(checkBridgeBtn, findsOneWidget);
            expect(
              tester.takeException(),
              isNull,
              reason:
                  'Screen scroll failed for ${spec.id} (${locale.languageCode})',
            );

            // Navigate back via AppBar Back button
            await tester.tap(find.byKey(const Key('learn_lesson_back_btn')));
            await tester.pumpAndSettle();
            expect(find.byType(LearnLessonScreen), findsNothing);
          }
        },
      );
    }

    testWidgets(
      'full-screen navigation supports Android system back, Previous/Next lesson traversal, and stops TTS on switch/exit',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final fakeBridge = _FakeLearnTtsBridge();
        Future<void> pumpRouteTransition() async {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
          await tester.pump(const Duration(milliseconds: 350));
        }

        await tester.pumpWidget(
          _wrapLearnApp(
            disableAnimations: false,
            home: LearnHomeScreen(
              hybridBridge: fakeBridge,
              onCheckAppRequested: () {},
            ),
          ),
        );
        await pumpRouteTransition();

        // Enter Lesson 1 -> Lesson 1 of 4, Next only (no Previous)
        await tester.tap(find.byKey(const Key('learn_folder_privacy_policy')));
        await pumpRouteTransition();
        expect(find.text('Lesson 1 of 4'), findsOneWidget);

        // Start Listen, then scroll to Next -> switches to Lesson 2 and stops TTS
        await tester.tap(find.byKey(const Key('learn_lesson_listen_btn')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(fakeBridge.speakTextCalls, hasLength(1));

        final scrollView = find.byKey(const Key('learn_lesson_scroll_view'));
        final nextBtn = find.byKey(const Key('learn_next_lesson_btn'));
        await tester.dragUntilVisible(nextBtn, scrollView, const Offset(0, -300));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byKey(const Key('learn_prev_lesson_btn')), findsNothing);
        expect(nextBtn, findsOneWidget);

        await tester.tap(nextBtn);
        await pumpRouteTransition();
        expect(fakeBridge.stopSpeakingCalls, greaterThanOrEqualTo(1));
        expect(
          find.byKey(const Key('learn_lesson_screen_android_permissions')),
          findsOneWidget,
        );
        expect(find.text('Lesson 2 of 4'), findsOneWidget);

        // Scroll to bottom of Lesson 2 -> both Previous and Next visible
        final prevBtn = find.byKey(const Key('learn_prev_lesson_btn'));
        await tester.dragUntilVisible(prevBtn, scrollView, const Offset(0, -300));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(prevBtn, findsOneWidget);
        expect(find.byKey(const Key('learn_next_lesson_btn')), findsOneWidget);

        // Tap Previous -> back to Lesson 1
        await tester.tap(prevBtn);
        await pumpRouteTransition();
        expect(
          find.byKey(const Key('learn_lesson_screen_privacy_policy')),
          findsOneWidget,
        );
        expect(find.text('Lesson 1 of 4'), findsOneWidget);

        // Android system Back pops cleanly back to LearnHomeScreen
        await tester.binding.handlePopRoute();
        await pumpRouteTransition();
        expect(find.byType(LearnLessonScreen), findsNothing);
        expect(
          find.byKey(const Key('learn_folder_privacy_policy')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'offline voice completion event, unavailable notice, and stop-on-back all work cleanly',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final fakeBridge = _FakeLearnTtsBridge()..speakResult = false;
        await tester.pumpWidget(
          _wrapLearnApp(
            home: LearnHomeScreen(
              hybridBridge: fakeBridge,
              onCheckAppRequested: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('learn_folder_privacy_policy')));
        await tester.pumpAndSettle();

        // Unavailable local TTS -> calm inline notice
        final listenBtn = find.byKey(const Key('learn_lesson_listen_btn'));
        await tester.tap(listenBtn);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('learn_lesson_voice_notice')),
          findsOneWidget,
        );

        // Now succeed -> playback starts, then native completion resets to Listen
        fakeBridge.speakResult = true;
        await tester.tap(listenBtn);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('learn_lesson_voice_offline_badge')),
          findsOneWidget,
        );

        final reqId = fakeBridge.speakTextCalls.last['requestId'] as String?;
        fakeBridge.emitVoicePlaybackEvent(
          VoicePlaybackEvent(
            requestId: reqId ?? '',
            state: VoicePlaybackState.completed,
            route: VoicePlaybackRoute.androidLocalTts,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('learn_lesson_voice_offline_badge')),
          findsNothing,
        );

        // Start speaking again and press Back -> stops TTS automatically
        await tester.tap(listenBtn);
        await tester.pumpAndSettle();
        expect(fakeBridge.stopSpeakingCalls, 0);

        await tester.tap(find.byKey(const Key('learn_lesson_back_btn')));
        await tester.pumpAndSettle();
        expect(fakeBridge.stopSpeakingCalls, greaterThanOrEqualTo(1));
      },
    );

    testWidgets('filter chips filter all four lesson categories accurately', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapLearnApp(
          home: LearnHomeScreen(
            hybridBridge: _FakeLearnTtsBridge(),
            onCheckAppRequested: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> tapFilter(String label, String expectedId) async {
        await tester.tap(find.widgetWithText(EnpriveFilterChip, label));
        await tester.pumpAndSettle();
        for (final id in [
          LearnLessonIds.privacyPolicy,
          LearnLessonIds.androidPermissions,
          LearnLessonIds.thirdParties,
          LearnLessonIds.evidence,
        ]) {
          expect(
            find.byKey(Key('learn_folder_$id')),
            id == expectedId ? findsOneWidget : findsNothing,
          );
        }
      }

      await tapFilter(l10nEn.learnFilterPolicies, LearnLessonIds.privacyPolicy);
      await tapFilter(
        l10nEn.learnFilterPermissions,
        LearnLessonIds.androidPermissions,
      );
      await tapFilter(l10nEn.learnFilterSharing, LearnLessonIds.thirdParties);
      await tapFilter(l10nEn.learnFilterEvidence, LearnLessonIds.evidence);

      await tester.tap(
        find.widgetWithText(EnpriveFilterChip, l10nEn.learnFilterAll),
      );
      await tester.pumpAndSettle();
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
      expect(find.byKey(const Key('learn_folder_evidence')), findsOneWidget);
    });
  });
}
