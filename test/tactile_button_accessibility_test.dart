import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/intake/policy_intake_models.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/services/intake/policy_intake_coordinator.dart';
import 'package:enprive/services/network/policy_url_retriever.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:enprive/widgets/deni_animated_mascot.dart';
import 'package:enprive/widgets/enprive_tactile_button.dart';
import 'package:enprive/widgets/enprive_tactile_pressable.dart';
import 'package:enprive/widgets/intake/unified_policy_intake_sheet.dart';
import 'package:enprive/widgets/m3e/enprive_m3e_components.dart';
import 'package:enprive/widgets/review/unsaved_review_exit_sheet.dart';

import 'support/keyboard_focus.dart';

Widget _wrap({
  required Widget home,
  ThemeMode mode = ThemeMode.light,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  bool disableAnimations = false,
}) {
  final activeData = EnpriveM3ETheme.resolve(
    mode: mode,
    platformBrightness: mode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light,
  );
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
    appBuilder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: disableAnimations,
      ),
      child: EnpriveM3EBridgeScope(
        themeMode: mode,
        child: child ?? const SizedBox.shrink(),
      ),
    ),
    home: home,
  );
}

Widget _buttonColumn(List<Widget> children) {
  return Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in children) ...[child, const SizedBox(height: 12)],
        ],
      ),
    ),
  );
}

EnpriveReviewHeroCard _heroCard({
  required String ctaLabel,
  required VoidCallback onPrimaryCta,
}) {
  return EnpriveReviewHeroCard(
    subjectTitle: 'Focus Reader',
    subtitle: 'Installed App · Nov 21',
    overallState: ReviewOverallState.insufficientEvidence,
    stateBadgeLabel: 'Policy needed',
    findingsCountValue: '0',
    findingsLabel: 'Findings',
    verifiedCountValue: '0',
    verifiedLabel: 'Verified',
    secondaryMetricValue: '3',
    secondaryMetricLabel: 'Declared',
    hasPermissionReport: true,
    mascotPose: DeniPose.explaining,
    sourceActionLabel: 'Source',
    sourceActionTooltip: 'View reviewed policy snapshot',
    onSourceAction: () {},
    isSpeaking: false,
    voiceTooltip: 'Read summary aloud',
    onVoiceAction: () {},
    primaryCtaLabel: ctaLabel,
    onPrimaryCta: onPrimaryCta,
  );
}

Future<void> _performSemanticTap(WidgetTester tester, Finder target) async {
  final node = tester.getSemantics(target);
  tester
      .renderObject(target)
      .owner!
      .semanticsOwner!
      .performAction(node.id, SemanticsAction.tap);
  await tester.pump();
}

double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

Finder _focusRingOf(Finder label) => find.ancestor(
  of: label,
  matching: find.byKey(EnpriveTactilePressable.focusRingKey),
);

bool _focusRingShown(WidgetTester tester, Finder label) =>
    tester.widget<CustomPaint>(_focusRingOf(label)).foregroundPainter != null;

Future<void> _flush(WidgetTester tester, {int steps = 4}) async {
  await tester.pump();
  for (var i = 0; i < steps; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 80));
  }
}

void main() {
  group('Step B: EnpriveTactileButton focus and activation', () {
    testWidgets(
      'fires onPressed exactly once per pointer, semantic, Enter and Space activation',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        var calls = 0;
        await tester.pumpWidget(
          _wrap(
            home: _buttonColumn([
              EnpriveTactileButton(
                label: 'Primary action',
                onPressed: () => calls++,
              ),
            ]),
          ),
        );
        final label = find.text('Primary action');

        await tester.tap(label);
        await tester.pumpAndSettle();
        expect(calls, 1, reason: 'pointer tap fires once');

        await _performSemanticTap(tester, label);
        expect(calls, 2, reason: 'SemanticsAction.tap fires once');

        await tabTo(tester, label);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(calls, 3, reason: 'Enter fires once');

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(calls, 4, reason: 'Space fires once');
        handle.dispose();
      },
    );

    testWidgets('is reachable in Tab order between neighbouring controls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          home: _buttonColumn([
            TextButton(onPressed: () {}, child: const Text('before')),
            EnpriveTactileButton(label: 'Middle', onPressed: () {}),
            TextButton(onPressed: () {}, child: const Text('after')),
          ]),
        ),
      );

      expect(await tabTo(tester, find.text('before')), 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusIsOn(tester, find.text('Middle')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusIsOn(tester, find.text('after')), isTrue);

      // Shift+Tab walks back onto the tactile button.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(focusIsOn(tester, find.text('Middle')), isTrue);
    });

    testWidgets(
      'exposes one button node with a single label, tap and focusability',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _wrap(
            home: _buttonColumn([
              EnpriveTactileButton(
                label: 'Use cloud for this check',
                leading: const Icon(Icons.cloud_outlined),
                onPressed: () {},
              ),
            ]),
          ),
        );

        final node = tester.getSemantics(find.text('Use cloud for this check'));
        final data = node.getSemanticsData();
        expect(data.label, 'Use cloud for this check');
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.flagsCollection.isEnabled, Tristate.isTrue);
        expect(data.flagsCollection.isFocused, isNot(Tristate.none));
        expect(
          find.semantics.byLabel('Use cloud for this check'),
          findsOneWidget,
        );
        handle.dispose();
      },
    );

    testWidgets(
      'disabled button has no actions, is skipped by Tab and ignores keys',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _wrap(
            home: _buttonColumn([
              TextButton(onPressed: () {}, child: const Text('before')),
              const EnpriveTactileButton(label: 'Disabled', onPressed: null),
              TextButton(onPressed: () {}, child: const Text('after')),
            ]),
          ),
        );

        final data = tester
            .getSemantics(find.text('Disabled'))
            .getSemanticsData();
        expect(data.label, 'Disabled');
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.flagsCollection.isEnabled, Tristate.isFalse);
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        expect(data.hasAction(SemanticsAction.focus), isFalse);

        await tabTo(tester, find.text('before'));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(focusIsOn(tester, find.text('after')), isTrue);
        expect(focusIsOn(tester, find.text('Disabled')), isFalse);
        handle.dispose();
      },
    );

    testWidgets(
      'a focused button that becomes disabled drops focus and cannot be activated',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        var calls = 0;
        Widget build({required bool enabled}) => _wrap(
          home: _buttonColumn([
            EnpriveTactileButton(
              label: 'Submit',
              onPressed: enabled ? () => calls++ : null,
            ),
          ]),
        );

        await tester.pumpWidget(build(enabled: true));
        await tabTo(tester, find.text('Submit'));

        await tester.pumpWidget(build(enabled: false));
        await tester.pump();
        expect(focusIsOn(tester, find.text('Submit')), isFalse);
        expect(_focusRingShown(tester, find.text('Submit')), isFalse);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.tap(find.text('Submit'), warnIfMissed: false);
        await tester.pump();
        expect(calls, 0);
        final data = tester
            .getSemantics(find.text('Submit'))
            .getSemanticsData();
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        expect(data.flagsCollection.isFocused, Tristate.none);
        handle.dispose();
      },
    );

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'focus ring shows only for keyboard focus and meets 3:1 contrast (${mode.name})',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            _wrap(
              mode: mode,
              home: _buttonColumn([
                EnpriveTactileButton(label: 'Primary', onPressed: () {}),
                EnpriveTactileButton(
                  label: 'Secondary',
                  isSecondary: true,
                  onPressed: () {},
                ),
              ]),
            ),
          );
          final primary = find.text('Primary');
          final secondary = find.text('Secondary');

          await tester.tap(primary);
          await tester.pumpAndSettle();
          expect(_focusRingShown(tester, primary), isFalse);

          await tabTo(tester, primary);
          expect(_focusRingShown(tester, primary), isTrue);
          expect(_focusRingShown(tester, secondary), isFalse);

          final ringColor = EnpriveTactilePressable.focusRingColorOf(
            tester.element(primary),
          );
          final ringPainter = tester
              .widget<CustomPaint>(_focusRingOf(primary))
              .foregroundPainter!;
          final buttonSize = tester.getSize(_focusRingOf(primary));
          expect(
            (Canvas canvas) => ringPainter.paint(canvas, buttonSize),
            paints..rrect(
              rrect: RRect.fromRectAndRadius(
                (Offset.zero & buttonSize).inflate(3.5),
                Radius.circular(buttonSize.height / 2 + 3.5),
              ),
              color: ringColor,
              style: PaintingStyle.stroke,
              strokeWidth: EnpriveTactilePressable.focusRingWidth,
            ),
          );
          final surfaces = mode == ThemeMode.dark
              ? EnpriveSurfaceTokens.dark
              : EnpriveSurfaceTokens.light;
          for (final background in [
            surfaces.canvas,
            surfaces.card,
            surfaces.cardMuted,
            surfaces.cardElevated,
            surfaces.sheetSurface,
          ]) {
            expect(
              _contrastRatio(ringColor, background),
              greaterThanOrEqualTo(3.0),
              reason: 'focus ring vs $background',
            );
          }

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(_focusRingShown(tester, primary), isFalse);
          expect(_focusRingShown(tester, secondary), isTrue);
        },
      );
    }

    testWidgets(
      'press morphs the pill to 12dp corners and stays still under reduced motion',
      (WidgetTester tester) async {
        Future<BorderRadiusGeometry?> radiusWhilePressed({
          required bool reduceMotion,
        }) async {
          await tester.pumpWidget(
            _wrap(
              disableAnimations: reduceMotion,
              home: _buttonColumn([
                EnpriveTactileButton(label: 'Press me', onPressed: () {}),
              ]),
            ),
          );
          final gesture = await tester.startGesture(
            tester.getCenter(find.text('Press me')),
          );
          await tester.pumpAndSettle();
          final container = tester.widget<AnimatedContainer>(
            find.ancestor(
              of: find.text('Press me'),
              matching: find.byType(AnimatedContainer),
            ),
          );
          final decoration = container.decoration! as BoxDecoration;
          expect(decoration.boxShadow, isNull);
          expect(container.margin, isNull);
          await gesture.up();
          await tester.pumpAndSettle();
          return decoration.borderRadius;
        }

        expect(
          await radiusWhilePressed(reduceMotion: false),
          BorderRadius.circular(EnpriveTactileButton.pressedRadius),
        );
        expect(
          await radiusWhilePressed(reduceMotion: true),
          BorderRadius.circular(28),
        );
      },
    );
  });

  group('Step B: review hero CTA focus, activation and single label', () {
    const ctaLabel = "Add this app's privacy policy";
    final ctaText = find.descendant(
      of: find.byType(EnpriveReviewHeroCard),
      matching: find.text(ctaLabel),
    );

    testWidgets('announces the CTA label exactly once as a button', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          home: _buttonColumn([
            _heroCard(ctaLabel: ctaLabel, onPrimaryCta: () {}),
          ]),
        ),
      );
      await tester.pump();

      final data = tester.getSemantics(ctaText).getSemanticsData();
      expect(data.label, ctaLabel);
      expect(data.label.contains('\n'), isFalse);
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled, Tristate.isTrue);
      expect(data.flagsCollection.isFocused, isNot(Tristate.none));
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets(
      'fires onPrimaryCta exactly once per pointer, semantic, Enter and Space activation',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        var calls = 0;
        await tester.pumpWidget(
          _wrap(
            home: _buttonColumn([
              _heroCard(ctaLabel: ctaLabel, onPrimaryCta: () => calls++),
            ]),
          ),
        );
        await tester.pump();

        await tester.tap(ctaText);
        await tester.pump(const Duration(milliseconds: 200));
        expect(calls, 1);

        await _performSemanticTap(tester, ctaText);
        expect(calls, 2);

        await tabTo(tester, ctaText);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(calls, 3);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(calls, 4);
        handle.dispose();
      },
    );

    testWidgets(
      'keeps one label, focus ring and keyboard activation in dark Arabic RTL at 200%',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        var calls = 0;
        await tester.pumpWidget(
          _wrap(
            mode: ThemeMode.dark,
            locale: const Locale('ar'),
            textScale: 2.0,
            disableAnimations: true,
            home: _buttonColumn([
              _heroCard(ctaLabel: ctaLabel, onPrimaryCta: () => calls++),
            ]),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        final data = tester.getSemantics(ctaText).getSemanticsData();
        expect(data.label, ctaLabel);
        expect(data.textDirection, TextDirection.rtl);

        await tabTo(tester, ctaText);
        expect(_focusRingShown(tester, ctaText), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(calls, 1);
        handle.dispose();
      },
    );
  });

  group('Step B: sheets sharing the tactile button are keyboard operable', () {
    testWidgets(
      'CloudConsentSheet consent and decline buttons are Tab reachable and Enter activates them',
      (WidgetTester tester) async {
        CloudConsentDecision? decision;
        await tester.pumpWidget(
          _wrap(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async {
                      decision = await CloudConsentSheet.show(
                        context,
                        subjectTitle: 'Focus Reader',
                        policyText: 'Focus Reader stores notes on device.',
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );

        Future<CloudConsentDecision?> chooseByKeyboard(String label) async {
          decision = null;
          await tester.tap(find.text('open'));
          await _flush(tester);
          await tabTo(tester, find.text(label));
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await _flush(tester);
          expect(find.byType(CloudConsentSheet), findsNothing);
          return decision;
        }

        expect(
          await chooseByKeyboard('Use cloud for this check'),
          CloudConsentDecision.useCloudOnce,
        );
        expect(
          await chooseByKeyboard('Review on this phone'),
          CloudConsentDecision.reviewLocally,
        );
      },
    );

    testWidgets(
      'UnsavedReviewExitSheet save and discard buttons are Tab reachable and Enter activates them',
      (WidgetTester tester) async {
        UnsavedReviewExitDecision? decision;
        await tester.pumpWidget(
          _wrap(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async {
                      decision = await UnsavedReviewExitSheet.show(context);
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );

        Future<UnsavedReviewExitDecision?> chooseByKeyboard(Key key) async {
          decision = null;
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tabTo(
            tester,
            find.descendant(of: find.byKey(key), matching: find.byType(Text)),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          return decision;
        }

        expect(
          await chooseByKeyboard(const Key('unsaved_exit_save_btn')),
          UnsavedReviewExitDecision.save,
        );
        expect(
          await chooseByKeyboard(const Key('unsaved_exit_discard_btn')),
          UnsavedReviewExitDecision.discard,
        );
      },
    );

    testWidgets(
      'unified intake primary submit is Tab reachable and Enter submits pasted text',
      (WidgetTester tester) async {
        const policyText =
            'Focus Reader collects only account email addresses for cloud backup and never sells personal data to advertisers or third parties. Parents may delete data anytime.';
        final coordinator = PolicyIntakeCoordinator(
          urlRetriever: PolicyUrlRetriever(
            dnsLookup: (_) async => [InternetAddress('93.184.216.34')],
            clientFactory: () =>
                MockClient((_) async => http.Response('Not Found', 404)),
          ),
        );
        PolicyIntakeSuccess? outcome;
        await tester.pumpWidget(
          _wrap(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async {
                      outcome = await UnifiedPolicyIntakeSheet.show(
                        context,
                        config: PolicyIntakeSheetConfig(
                          coordinator: coordinator,
                        ),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await _flush(tester);

        await tester.enterText(
          find.byKey(const Key('intake_title_field')),
          'Focus App',
        );
        await tester.enterText(
          find.byKey(const Key('intake_paste_field')),
          policyText,
        );
        await tester.pump();

        await tabTo(
          tester,
          find.descendant(
            of: find.byKey(const Key('intake_primary_submit_btn')),
            matching: find.byType(Text),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await _flush(tester);

        expect(outcome, isNotNull);
        expect(outcome!.capturedSnapshot.subjectTitle, 'Focus App');
        expect(find.byType(UnifiedPolicyIntakeSheet), findsNothing);
      },
    );
  });
}
