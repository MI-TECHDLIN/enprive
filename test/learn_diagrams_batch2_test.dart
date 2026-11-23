import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as modern;

import 'package:enprive/core/theme/enprive_m3e_theme.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/widgets/learn/diagrams/data_collection_diagram.dart';
import 'package:enprive/widgets/learn/diagrams/policy_fog_diagram.dart';
import 'package:enprive/widgets/learn/diagrams/retention_timeline_diagram.dart';
import 'package:enprive/widgets/learn/diagrams/safe_sharing_diagram.dart';

/// Same root as the app: material_ui MaterialApp with the bridge as builder.
Widget _app({
  required Widget home,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  bool disableAnimations = false,
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
    home: home,
  );
}

DataCollectionDiagramLabels _dataCollectionLabels() =>
    const DataCollectionDiagramLabels(
      youTypeTitle: 'What you type or give',
      youTypeItems: ['Name', 'Email', 'Photos', 'Voice', 'Homework'],
      runsQuietlyTitle: 'What runs quietly in the background',
      runsQuietlyItems: [
        'IP address',
        'Device ID',
        'Ad ID',
        'Crash logs',
        'Usage timing',
      ],
      quietNote:
          'Quiet does not mean bad: these signals help apps run smoothly.',
      semanticDescription:
          'Diagram showing two categories of data collection: what you actively type or give (name, email, photos, voice, homework) versus what runs quietly in the background (IP address, device ID, advertising ID, crash logs, usage timing). Quiet does not mean bad: these signals help apps run smoothly.',
    );

RetentionTimelineDiagramLabels _retentionTimelineLabels() =>
    const RetentionTimelineDiagramLabels(
      collected: 'Data collected during app use',
      stored: 'Stored on company servers',
      uninstall: 'Uninstall app (server copy remains)',
      deleteRequest: 'Request account deletion',
      unknownTail: 'Unknown retention (as long as needed?)',
      semanticDescription:
          'Five-step data lifecycle timeline: data collected during app use, stored on company servers, uninstalling the app removes phone files but uploaded data stays on servers, a deletion request triggers server and backup purge, and a dashed unknown tail for policies that say "as long as needed" without a concrete period.',
    );

PolicyFogDiagramLabels _policyFogLabels() => const PolicyFogDiagramLabels(
  clearTitle: 'Clear policy',
  clearExample:
      'We collect your name and email only to create your account. We never share this with advertisers.',
  foggyTitle: 'Foggy policy',
  foggyExample:
      'We may share your information with trusted partners for business purposes.',
  tipsTitle: 'Fog-spotting tips',
  tips: [
    'Open-ended verbs like "may share" hide who gets your data.',
    '"For business purposes" is vague: ask what that means.',
    'Silence in a policy is not a promise.',
  ],
  silenceNote: 'Silence in a policy is not a promise.',
  semanticDescription:
      'Comparison of a clear policy sentence versus a foggy one. The clear example states exactly what data is collected and promises no ad sharing. The foggy example uses "may share with trusted partners for business purposes". Three fog-spotting tips: open-ended verbs hide who gets data, "for business purposes" is vague, and silence is not a promise.',
);

SafeSharingDiagramLabels _safeSharingLabels() => const SafeSharingDiagramLabels(
  stop: 'Stop',
  think: 'Think',
  connect: 'Connect',
  cafeteriaTest:
      'Would I be happy if everyone at school saw this photo or message? Even disappearing posts can be screenshotted and stay online permanently.',
  semanticDescription:
      'Three-step safe sharing guide: Stop (pause before posting), Think (check if it reveals school, location, or if friends were asked), Connect (share with trusted people, ask an adult if unsure). Plus the Cafeteria Test callout: would you be happy if everyone at school saw this? Even disappearing posts can be screenshotted and stay online permanently.',
);

/// Returns true when two rects genuinely overlap by more than half a logical px.
bool _rectsOverlap(Rect a, Rect b) {
  final inter = a.intersect(b);
  return inter.width > 0.5 && inter.height > 0.5;
}

/// Finds the [RenderParagraph] produced by a [Text] element.
RenderParagraph? _findRenderParagraph(Element element) {
  RenderParagraph? found;
  void visit(Element current) {
    if (found != null) return;
    final ro = current.renderObject;
    if (ro is RenderParagraph) {
      found = ro;
      return;
    }
    current.visitChildren(visit);
  }

  visit(element);
  return found;
}

/// Verifies every geometric and clipping invariant for a rendered diagram:
/// - Zero Flutter layout/overflow exceptions.
/// - Every expected keyed text widget and the keyed mascot exist.
/// - Every rendered [Text] inside the diagram is accounted for, contains no
///   em dash, has `RenderParagraph.didExceedMaxLines == false`, and fits inside
///   the diagram's bounding box.
/// - No two [Text] rects intersect each other.
/// - No [Text] rect intersects the mascot rect.
void _assertCleanDiagramLayout(
  WidgetTester tester, {
  required Finder diagramFinder,
  required Key mascotKey,
  required List<Key> expectedTextKeys,
  required String contextLabel,
}) {
  expect(
    tester.takeException(),
    isNull,
    reason: 'Overflow or layout exception in $contextLabel',
  );
  expect(diagramFinder, findsOneWidget, reason: contextLabel);

  final diagramRect = tester.getRect(diagramFinder);
  final mascotFinder = find.byKey(mascotKey);
  expect(mascotFinder, findsOneWidget, reason: 'Mascot missing in $contextLabel');
  final mascotRect = tester.getRect(mascotFinder);

  expect(
    mascotRect.left >= diagramRect.left - 0.5 &&
        mascotRect.right <= diagramRect.right + 0.5 &&
        mascotRect.top >= diagramRect.top - 0.5 &&
        mascotRect.bottom <= diagramRect.bottom + 0.5,
    isTrue,
    reason:
        'Mascot rect $mascotRect escapes diagram bounds $diagramRect ($contextLabel)',
  );

  // Verify every keyed text widget exists and capture its rect + clipping state.
  final keyedRects = <({String name, Rect rect})>[];
  for (final key in expectedTextKeys) {
    final textFinder = find.byKey(key);
    expect(
      textFinder,
      findsOneWidget,
      reason: 'Missing keyed text $key in $contextLabel',
    );
    final rect = tester.getRect(textFinder);
    expect(
      rect.width > 0 && rect.height > 0,
      isTrue,
      reason: 'Empty text rect for $key in $contextLabel',
    );
    keyedRects.add((name: key.toString(), rect: rect));
  }

  // Also walk EVERY Text descendant inside the diagram so unkeyed text cannot
  // clip, contain em dashes, or overlap undetected.
  final textElements = find
      .descendant(of: diagramFinder, matching: find.byType(Text))
      .evaluate()
      .toList();
  expect(
    textElements.length,
    expectedTextKeys.length,
    reason:
        'Expected all ${textElements.length} Text widgets in $contextLabel to be keyed (${expectedTextKeys.length} keys provided)',
  );

  final allTextRects = <({String label, Rect rect})>[];
  for (final element in textElements) {
    final widget = element.widget as Text;
    final textContent =
        widget.data ?? widget.textSpan?.toPlainText() ?? '<empty>';
    expect(
      textContent,
      isNot(contains('—')),
      reason: 'Em dash found in "$textContent" ($contextLabel)',
    );

    final paragraph = _findRenderParagraph(element);
    expect(
      paragraph,
      isNotNull,
      reason: 'No RenderParagraph for "$textContent" ($contextLabel)',
    );
    expect(
      paragraph!.didExceedMaxLines,
      isFalse,
      reason: 'Clipped text (didExceedMaxLines=true) for "$textContent" ($contextLabel)',
    );

    final box = element.renderObject! as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero);
    final rect = topLeft & box.size;

    expect(
      rect.left >= diagramRect.left - 0.5 &&
          rect.right <= diagramRect.right + 0.5 &&
          rect.top >= diagramRect.top - 0.5 &&
          rect.bottom <= diagramRect.bottom + 0.5,
      isTrue,
      reason:
          'Text "$textContent" rect $rect escapes diagram bounds $diagramRect ($contextLabel)',
    );
    expect(
      _rectsOverlap(rect, mascotRect),
      isFalse,
      reason:
          'Text "$textContent" rect $rect intersects mascot rect $mascotRect ($contextLabel)',
    );

    allTextRects.add((label: textContent, rect: rect));
  }

  // Pairwise non-intersection across all text widgets.
  for (var i = 0; i < allTextRects.length; i++) {
    for (var j = i + 1; j < allTextRects.length; j++) {
      expect(
        _rectsOverlap(allTextRects[i].rect, allTextRects[j].rect),
        isFalse,
        reason:
            'Text "${allTextRects[i].label}" (${allTextRects[i].rect}) overlaps '
            '"${allTextRects[j].label}" (${allTextRects[j].rect}) in $contextLabel',
      );
    }
  }
}

/// Matrix of conditions covering light, dark, 200% text scale, RTL, narrow
/// 320dp, standard 400dp, and wide 620dp layouts.
const _layoutMatrix = <({
  String name,
  ThemeMode mode,
  double width,
  double textScale,
  Locale locale,
})>[
  (
    name: 'light_400_1x_en',
    mode: ThemeMode.light,
    width: 400,
    textScale: 1.0,
    locale: Locale('en'),
  ),
  (
    name: 'dark_400_1x_en',
    mode: ThemeMode.dark,
    width: 400,
    textScale: 1.0,
    locale: Locale('en'),
  ),
  (
    name: 'light_400_2x_en',
    mode: ThemeMode.light,
    width: 400,
    textScale: 2.0,
    locale: Locale('en'),
  ),
  (
    name: 'dark_320_2x_en',
    mode: ThemeMode.dark,
    width: 320,
    textScale: 2.0,
    locale: Locale('en'),
  ),
  (
    name: 'light_320_1x_en',
    mode: ThemeMode.light,
    width: 320,
    textScale: 1.0,
    locale: Locale('en'),
  ),
  (
    name: 'light_400_1x_ar_rtl',
    mode: ThemeMode.light,
    width: 400,
    textScale: 1.0,
    locale: Locale('ar'),
  ),
  (
    name: 'dark_320_2x_ar_rtl',
    mode: ThemeMode.dark,
    width: 320,
    textScale: 2.0,
    locale: Locale('ar'),
  ),
  (
    name: 'light_620_1x_en_wide',
    mode: ThemeMode.light,
    width: 620,
    textScale: 1.0,
    locale: Locale('en'),
  ),
  (
    name: 'dark_620_1x_ar_wide_rtl',
    mode: ThemeMode.dark,
    width: 620,
    textScale: 1.0,
    locale: Locale('ar'),
  ),
];

void main() {
  final l10nEn = lookupAppLocalizations(const Locale('en'));

  group('DataCollectionDiagram', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('builds in ${mode.name} with semantics label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _app(
            mode: mode,
            disableAnimations: true,
            home: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: DataCollectionDiagram(labels: _dataCollectionLabels()),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel(_dataCollectionLabels().semanticDescription),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('builds at 200% text scale without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          textScale: 2.0,
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: DataCollectionDiagram(labels: _dataCollectionLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_dataCollectionLabels().semanticDescription),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mirrors layout in RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          disableAnimations: true,
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: DataCollectionDiagram(labels: _dataCollectionLabels()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_dataCollectionLabels().semanticDescription),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('exactly one semantics node for the diagram', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: DataCollectionDiagram(labels: _dataCollectionLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final semantics = tester.getSemantics(find.byType(DataCollectionDiagram));
      final data = semantics.getSemanticsData();

      expect(data.label, _dataCollectionLabels().semanticDescription);
      handle.dispose();
    });

    testWidgets('narrow 320dp width without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: DataCollectionDiagram(labels: _dataCollectionLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'no text/mascot overlap, no clipping, and no em dashes across light/dark/200%/RTL/320dp/wide',
      (WidgetTester tester) async {
        final realLabels = DataCollectionDiagramLabels(
          youTypeTitle: l10nEn.learnDataCollectionDiagramYouTypeTitle,
          youTypeItems: [
            l10nEn.learnDataCollectionDiagramYouTypeItem1,
            l10nEn.learnDataCollectionDiagramYouTypeItem2,
            l10nEn.learnDataCollectionDiagramYouTypeItem3,
            l10nEn.learnDataCollectionDiagramYouTypeItem4,
          ],
          runsQuietlyTitle: l10nEn.learnDataCollectionDiagramRunsQuietlyTitle,
          runsQuietlyItems: [
            l10nEn.learnDataCollectionDiagramRunsQuietlyItem1,
            l10nEn.learnDataCollectionDiagramRunsQuietlyItem2,
            l10nEn.learnDataCollectionDiagramRunsQuietlyItem3,
            l10nEn.learnDataCollectionDiagramRunsQuietlyItem4,
          ],
          quietNote: l10nEn.learnDataCollectionDiagramQuietNote,
          semanticDescription:
              l10nEn.learnDataCollectionDiagramSemanticDescription,
        );

        final expectedKeys = <Key>[
          DataCollectionDiagram.youTypeTitleKey,
          for (var i = 0; i < realLabels.youTypeItems.length; i++)
            DataCollectionDiagram.youTypeItemKey(i),
          DataCollectionDiagram.runsQuietlyTitleKey,
          for (var i = 0; i < realLabels.runsQuietlyItems.length; i++)
            DataCollectionDiagram.runsQuietlyItemKey(i),
          DataCollectionDiagram.quietNoteKey,
        ];

        for (final c in _layoutMatrix) {
          tester.view.physicalSize = Size(c.width, 2400);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            _app(
              mode: c.mode,
              textScale: c.textScale,
              locale: c.locale,
              disableAnimations: true,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: c.width,
                    child: DataCollectionDiagram(labels: realLabels),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          _assertCleanDiagramLayout(
            tester,
            diagramFinder: find.byType(DataCollectionDiagram),
            mascotKey: DataCollectionDiagram.mascotKey,
            expectedTextKeys: expectedKeys,
            contextLabel: 'DataCollectionDiagram[${c.name}]',
          );
        }

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });

  group('RetentionTimelineDiagram', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('builds in ${mode.name} with semantics label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _app(
            mode: mode,
            disableAnimations: true,
            home: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: RetentionTimelineDiagram(
                    labels: _retentionTimelineLabels(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel(_retentionTimelineLabels().semanticDescription),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('builds at 200% text scale without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          textScale: 2.0,
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: RetentionTimelineDiagram(
                  labels: _retentionTimelineLabels(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_retentionTimelineLabels().semanticDescription),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mirrors layout in RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          disableAnimations: true,
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: RetentionTimelineDiagram(
                    labels: _retentionTimelineLabels(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_retentionTimelineLabels().semanticDescription),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('exactly one semantics node for the diagram', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: RetentionTimelineDiagram(
                  labels: _retentionTimelineLabels(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final semantics = tester.getSemantics(
        find.byType(RetentionTimelineDiagram),
      );
      final data = semantics.getSemanticsData();

      expect(data.label, _retentionTimelineLabels().semanticDescription);
      handle.dispose();
    });

    testWidgets('narrow 320dp width without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: RetentionTimelineDiagram(
                  labels: _retentionTimelineLabels(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'clean aligned vertical rail, no text/node/mascot overlap, no clipping across light/dark/200%/RTL/320dp/wide',
      (WidgetTester tester) async {
        final realLabels = RetentionTimelineDiagramLabels(
          collected: l10nEn.learnRetentionDiagramCollected,
          stored: l10nEn.learnRetentionDiagramStored,
          uninstall: l10nEn.learnRetentionDiagramUninstall,
          deleteRequest: l10nEn.learnRetentionDiagramDeleteRequest,
          unknownTail: l10nEn.learnRetentionDiagramUnknownTail,
          semanticDescription: l10nEn.learnRetentionDiagramSemanticDescription,
        );

        final expectedKeys = <Key>[
          for (var i = 0; i < 5; i++) RetentionTimelineDiagram.stepBadgeKey(i),
          for (var i = 0; i < 5; i++) RetentionTimelineDiagram.stepLabelKey(i),
        ];

        for (final c in _layoutMatrix) {
          tester.view.physicalSize = Size(c.width, 2400);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            _app(
              mode: c.mode,
              textScale: c.textScale,
              locale: c.locale,
              disableAnimations: true,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: c.width,
                    child: RetentionTimelineDiagram(labels: realLabels),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final ctx = 'RetentionTimelineDiagram[${c.name}]';
          _assertCleanDiagramLayout(
            tester,
            diagramFinder: find.byType(RetentionTimelineDiagram),
            mascotKey: RetentionTimelineDiagram.mascotKey,
            expectedTextKeys: expectedKeys,
            contextLabel: ctx,
          );

          final isRtl = c.locale.languageCode == 'ar';
          final nodeRects = [
            for (var i = 0; i < 5; i++)
              tester.getRect(find.byKey(RetentionTimelineDiagram.stepNodeKey(i))),
          ];
          final labelRects = [
            for (var i = 0; i < 5; i++)
              tester.getRect(find.byKey(RetentionTimelineDiagram.stepLabelKey(i))),
          ];
          final mascotRect = tester.getRect(
            find.byKey(RetentionTimelineDiagram.mascotKey),
          );

          // All 5 rail circles share the same vertical rail X center (no staircase).
          final railCenterX = nodeRects.first.center.dx;
          for (var i = 0; i < 5; i++) {
            expect(
              (nodeRects[i].center.dx - railCenterX).abs(),
              lessThanOrEqualTo(0.5),
              reason: 'Node $i drifted off vertical rail in $ctx',
            );
            expect(
              _rectsOverlap(nodeRects[i], mascotRect),
              isFalse,
              reason: 'Node $i overlaps mascot in $ctx',
            );
            // Step numeral pill stays compact and is never stretched vertically
            // by IntrinsicHeight across multi-line cards.
            final badgeContainerRect = tester.getRect(
              find
                  .ancestor(
                    of: find.byKey(RetentionTimelineDiagram.stepBadgeKey(i)),
                    matching: find.byType(Container),
                  )
                  .first,
            );
            expect(
              badgeContainerRect.height,
              lessThanOrEqualTo(36 * c.textScale),
              reason:
                  'Step $i badge pill stretched vertically ($badgeContainerRect) in $ctx',
            );
            // Labels sit to the right of the rail in LTR and left in RTL.
            if (isRtl) {
              expect(
                labelRects[i].right,
                lessThanOrEqualTo(nodeRects[i].left + 0.5),
                reason: 'RTL label $i overlaps or sits right of node in $ctx',
              );
            } else {
              expect(
                labelRects[i].left,
                greaterThanOrEqualTo(nodeRects[i].right - 0.5),
                reason: 'LTR label $i overlaps or sits left of node in $ctx',
              );
            }
            if (i > 0) {
              expect(
                nodeRects[i].top,
                greaterThan(nodeRects[i - 1].bottom),
                reason: 'Node $i overlaps previous node in $ctx',
              );
              expect(
                labelRects[i].top,
                greaterThan(labelRects[i - 1].bottom),
                reason: 'Label $i overlaps previous label in $ctx',
              );
            }
          }
        }

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });

  group('PolicyFogDiagram', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('builds in ${mode.name} with semantics label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _app(
            mode: mode,
            disableAnimations: true,
            home: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: PolicyFogDiagram(labels: _policyFogLabels()),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel(_policyFogLabels().semanticDescription),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('builds at 200% text scale without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          textScale: 2.0,
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: PolicyFogDiagram(labels: _policyFogLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_policyFogLabels().semanticDescription),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mirrors layout in RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          disableAnimations: true,
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: PolicyFogDiagram(labels: _policyFogLabels()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_policyFogLabels().semanticDescription),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('exactly one semantics node for the diagram', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: PolicyFogDiagram(labels: _policyFogLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final semantics = tester.getSemantics(find.byType(PolicyFogDiagram));
      final data = semantics.getSemanticsData();

      expect(data.label, _policyFogLabels().semanticDescription);
      handle.dispose();
    });

    testWidgets('narrow 320dp width without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: PolicyFogDiagram(labels: _policyFogLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'no card/text/mascot overlap and no clipping across light/dark/200%/RTL/320dp/wide',
      (WidgetTester tester) async {
        final realLabels = PolicyFogDiagramLabels(
          clearTitle: l10nEn.learnUnclearPoliciesDiagramClearTitle,
          clearExample: l10nEn.learnUnclearPoliciesDiagramClearExample,
          foggyTitle: l10nEn.learnUnclearPoliciesDiagramFoggyTitle,
          foggyExample: l10nEn.learnUnclearPoliciesDiagramFoggyExample,
          tipsTitle: l10nEn.learnUnclearPoliciesDiagramTipsTitle,
          tips: [
            l10nEn.learnUnclearPoliciesDiagramTip1,
            l10nEn.learnUnclearPoliciesDiagramTip2,
            l10nEn.learnUnclearPoliciesDiagramTip3,
          ],
          silenceNote: l10nEn.learnUnclearPoliciesDiagramSilenceNote,
          semanticDescription:
              l10nEn.learnUnclearPoliciesDiagramSemanticDescription,
        );

        final expectedKeys = <Key>[
          PolicyFogDiagram.clearTitleKey,
          PolicyFogDiagram.clearExampleKey,
          PolicyFogDiagram.foggyTitleKey,
          PolicyFogDiagram.foggyExampleKey,
          PolicyFogDiagram.tipsTitleKey,
          for (var i = 0; i < realLabels.tips.length; i++)
            PolicyFogDiagram.tipBadgeKey(i),
          for (var i = 0; i < realLabels.tips.length; i++)
            PolicyFogDiagram.tipTextKey(i),
          PolicyFogDiagram.silenceNoteKey,
        ];

        for (final c in _layoutMatrix) {
          tester.view.physicalSize = Size(c.width, 2400);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            _app(
              mode: c.mode,
              textScale: c.textScale,
              locale: c.locale,
              disableAnimations: true,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: c.width,
                    child: PolicyFogDiagram(labels: realLabels),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final ctx = 'PolicyFogDiagram[${c.name}]';
          _assertCleanDiagramLayout(
            tester,
            diagramFinder: find.byType(PolicyFogDiagram),
            mascotKey: PolicyFogDiagram.mascotKey,
            expectedTextKeys: expectedKeys,
            contextLabel: ctx,
          );

          // Silence note sits cleanly below the last tip (never colliding on top of tips).
          final lastTipRect = tester.getRect(
            find.byKey(PolicyFogDiagram.tipTextKey(realLabels.tips.length - 1)),
          );
          final silenceNoteRect = tester.getRect(
            find.byKey(PolicyFogDiagram.silenceNoteKey),
          );
          expect(
            silenceNoteRect.top,
            greaterThan(lastTipRect.bottom),
            reason: 'Silence note must sit cleanly below tips in $ctx',
          );
        }

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });

  group('SafeSharingDiagram', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('builds in ${mode.name} with semantics label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _app(
            mode: mode,
            disableAnimations: true,
            home: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SafeSharingDiagram(labels: _safeSharingLabels()),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel(_safeSharingLabels().semanticDescription),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('builds at 200% text scale without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          textScale: 2.0,
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SafeSharingDiagram(labels: _safeSharingLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_safeSharingLabels().semanticDescription),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mirrors layout in RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          disableAnimations: true,
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SafeSharingDiagram(labels: _safeSharingLabels()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_safeSharingLabels().semanticDescription),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('exactly one semantics node for the diagram', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SafeSharingDiagram(labels: _safeSharingLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final semantics = tester.getSemantics(find.byType(SafeSharingDiagram));
      final data = semantics.getSemanticsData();

      expect(data.label, _safeSharingLabels().semanticDescription);
      handle.dispose();
    });

    testWidgets('narrow 320dp width without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          disableAnimations: true,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: SafeSharingDiagram(labels: _safeSharingLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'no text/mascot overlap, no clipping, and no duplicated Cafeteria Test text across light/dark/200%/RTL/320dp/wide',
      (WidgetTester tester) async {
        final realLabels = SafeSharingDiagramLabels(
          stop: l10nEn.learnSafeSharingDiagramStop,
          think: l10nEn.learnSafeSharingDiagramThink,
          connect: l10nEn.learnSafeSharingDiagramConnect,
          cafeteriaTest: l10nEn.learnSafeSharingDiagramCafeteriaTest,
          semanticDescription:
              l10nEn.learnSafeSharingDiagramSemanticDescription,
        );

        final expectedKeys = <Key>[
          for (var i = 0; i < 3; i++) SafeSharingDiagram.stepBadgeKey(i),
          for (var i = 0; i < 3; i++) SafeSharingDiagram.stepLabelKey(i),
          SafeSharingDiagram.cafeteriaTextKey,
        ];

        for (final c in _layoutMatrix) {
          tester.view.physicalSize = Size(c.width, 2400);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            _app(
              mode: c.mode,
              textScale: c.textScale,
              locale: c.locale,
              disableAnimations: true,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: SizedBox(
                    width: c.width,
                    child: SafeSharingDiagram(labels: realLabels),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final ctx = 'SafeSharingDiagram[${c.name}]';
          _assertCleanDiagramLayout(
            tester,
            diagramFinder: find.byType(SafeSharingDiagram),
            mascotKey: SafeSharingDiagram.mascotKey,
            expectedTextKeys: expectedKeys,
            contextLabel: ctx,
          );

          // Cafeteria test sentence appears exactly once (no duplicated footnote).
          final disappearingMatches = find.textContaining(
            'Even disappearing posts can be screenshotted',
          );
          expect(
            disappearingMatches,
            findsOneWidget,
            reason: 'Cafeteria Test sentence was duplicated in $ctx',
          );
        }

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });

  group('All four diagrams together', () {
    testWidgets('all build in light and dark at 200% text and RTL', (
      WidgetTester tester,
    ) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        for (final textScale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('ar')]) {
            await tester.pumpWidget(
              _app(
                mode: mode,
                textScale: textScale,
                locale: locale,
                disableAnimations: true,
                home: Scaffold(
                  body: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DataCollectionDiagram(
                              labels: _dataCollectionLabels(),
                            ),
                            const SizedBox(height: 24),
                            RetentionTimelineDiagram(
                              labels: _retentionTimelineLabels(),
                            ),
                            const SizedBox(height: 24),
                            PolicyFogDiagram(labels: _policyFogLabels()),
                            const SizedBox(height: 24),
                            SafeSharingDiagram(labels: _safeSharingLabels()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();

            expect(
              tester.takeException(),
              isNull,
              reason:
                  'Failed at mode=${mode.name}, textScale=$textScale, locale=${locale.languageCode}',
            );
          }
        }
      }
    });
  });
}
