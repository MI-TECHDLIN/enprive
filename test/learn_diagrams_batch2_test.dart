import 'package:flutter/material.dart';
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

DataCollectionDiagramLabels _dataCollectionLabels() => DataCollectionDiagramLabels(
  youTypeTitle: 'What you type or give',
  youTypeItems: const ['Name', 'Email', 'Photos', 'Voice', 'Homework'],
  runsQuietlyTitle: 'What runs quietly in the background',
  runsQuietlyItems: const ['IP address', 'Device ID', 'Ad ID', 'Crash logs', 'Usage timing'],
  semanticDescription:
      'Diagram showing two categories of data collection: what you actively type or give (name, email, photos, voice, homework) versus what runs quietly in the background (IP address, device ID, advertising ID, crash logs, usage timing). Quiet does not mean bad — these signals help apps run smoothly.',
);

RetentionTimelineDiagramLabels _retentionTimelineLabels() => RetentionTimelineDiagramLabels(
  collected: 'Data collected during app use',
  stored: 'Stored on company servers',
  uninstall: 'Uninstall app (server copy remains)',
  deleteRequest: 'Request account deletion',
  unknownTail: 'Unknown retention (as long as needed?)',
  semanticDescription:
      'Four-node data lifecycle timeline: data collected during app use, stored on company servers, uninstalling the app removes phone files but uploaded data stays on servers, a deletion request triggers server and backup purge, and a dashed unknown tail for policies that say "as long as needed" without a concrete period.',
);

PolicyFogDiagramLabels _policyFogLabels() => PolicyFogDiagramLabels(
  clearTitle: 'Clear policy',
  clearExample: 'We collect your name and email only to create your account. We never share this with advertisers.',
  foggyTitle: 'Foggy policy',
  foggyExample: 'We may share your information with trusted partners for business purposes.',
  tipsTitle: 'Fog-spotting tips',
  tips: const [
    'Open-ended verbs like "may share" hide who gets your data.',
    '"For business purposes" is vague — ask what that means.',
    'Silence in a policy is not a promise.',
  ],
  semanticDescription:
      'Side-by-side comparison of a clear policy sentence versus a foggy one. The clear example states exactly what data is collected and promises no ad sharing. The foggy example uses "may share with trusted partners for business purposes". Three fog-spotting tips: open-ended verbs hide who gets data, "for business purposes" is vague, and silence is not a promise.',
);

SafeSharingDiagramLabels _safeSharingLabels() => SafeSharingDiagramLabels(
  stop: 'Stop',
  think: 'Think',
  connect: 'Connect',
  cafeteriaTest: 'Would I be happy if everyone at school saw this photo or message? Even disappearing posts can be screenshotted and stay online permanently.',
  semanticDescription:
      'Three-step safe sharing guide: Stop (pause before posting), Think (check if it reveals school, location, or if friends were asked), Connect (share with trusted people, ask an adult if unsure). Plus the Cafeteria Test callout: would you be happy if everyone at school saw this? Even disappearing posts can be screenshotted and stay online permanently.',
);

void main() {
  group('DataCollectionDiagram', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'builds in ${mode.name} with semantics label',
        (WidgetTester tester) async {
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
        },
      );
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
  });

  group('RetentionTimelineDiagram', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'builds in ${mode.name} with semantics label',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            _app(
              mode: mode,
              disableAnimations: true,
              home: Scaffold(
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: RetentionTimelineDiagram(labels: _retentionTimelineLabels()),
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
        },
      );
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
                child: RetentionTimelineDiagram(labels: _retentionTimelineLabels()),
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
                  child: RetentionTimelineDiagram(labels: _retentionTimelineLabels()),
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
                child: RetentionTimelineDiagram(labels: _retentionTimelineLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final semantics =
          tester.getSemantics(find.byType(RetentionTimelineDiagram));
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
                child: RetentionTimelineDiagram(labels: _retentionTimelineLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('PolicyFogDiagram', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'builds in ${mode.name} with semantics label',
        (WidgetTester tester) async {
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
        },
      );
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
  });

  group('SafeSharingDiagram', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'builds in ${mode.name} with semantics label',
        (WidgetTester tester) async {
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
        },
      );
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
  });

  group('All four diagrams together', () {
    testWidgets(
      'all build in light and dark at 200% text and RTL',
      (WidgetTester tester) async {
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
                              DataCollectionDiagram(labels: _dataCollectionLabels()),
                              const SizedBox(height: 24),
                              RetentionTimelineDiagram(labels: _retentionTimelineLabels()),
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

              expect(tester.takeException(), isNull,
                  reason: 'Failed at mode=${mode.name}, textScale=$textScale, locale=${locale.languageCode}');
            }
          }
        }
      },
    );
  });
}