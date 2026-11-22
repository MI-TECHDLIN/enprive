import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as modern;

import 'package:enprive/core/theme/enprive_m3e_theme.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/widgets/learn/diagrams/evidence_layers_diagram.dart';
import 'package:enprive/widgets/learn/diagrams/third_party_diagram.dart';

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

ThirdPartyDiagramLabels _thirdPartyLabels() => ThirdPartyDiagramLabels(
  app: 'Learning App',
  you: 'You',
  hosting: 'Hosting & Crashes',
  analytics: 'Analytics',
  ads: 'Ad Networks',
  firstParty: 'First party',
  thirdParty: 'Third parties',
  semanticDescription:
      'Diagram showing how data flows from a child\'s learning app to the app maker (first party) and to third parties including hosting services, analytics, and ad networks. The app maker gets a solid direct connection. Third parties get dashed connections to show indirect sharing.',
);

EvidenceLayersDiagramLabels _evidenceLayersLabels() => EvidenceLayersDiagramLabels(
  policySays: 'Policy says',
  phoneShows: 'Phone shows',
  deniExplains: 'Deni explains',
  notFound: 'Not found',
  semanticDescription:
      'Four stacked evidence layers: what the privacy policy says, what your phone\'s permissions show, Deni\'s plain-language explanation, and a dashed boundary for what is not found or unknown. Silence in a policy is not a promise.',
);

void main() {
  group('ThirdPartyDiagram', () {
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
                    child: ThirdPartyDiagram(labels: _thirdPartyLabels()),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Semantics container exists
          expect(
            find.bySemanticsLabel(
              _thirdPartyLabels().semanticDescription,
            ),
            findsOneWidget,
          );

          // No overflow
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
                child: ThirdPartyDiagram(labels: _thirdPartyLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_thirdPartyLabels().semanticDescription),
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
                  child: ThirdPartyDiagram(labels: _thirdPartyLabels()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_thirdPartyLabels().semanticDescription),
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
                child: ThirdPartyDiagram(labels: _thirdPartyLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final semantics = tester.getSemantics(find.byType(ThirdPartyDiagram));
      final data = semantics.getSemanticsData();

      expect(data.label, _thirdPartyLabels().semanticDescription);
      handle.dispose();
    });
  });

  group('EvidenceLayersDiagram', () {
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
                    child: EvidenceLayersDiagram(labels: _evidenceLayersLabels()),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Semantics container exists
          expect(
            find.bySemanticsLabel(_evidenceLayersLabels().semanticDescription),
            findsOneWidget,
          );

          // No overflow
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
                child: EvidenceLayersDiagram(labels: _evidenceLayersLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_evidenceLayersLabels().semanticDescription),
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
                  child: EvidenceLayersDiagram(labels: _evidenceLayersLabels()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(_evidenceLayersLabels().semanticDescription),
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
                child: EvidenceLayersDiagram(labels: _evidenceLayersLabels()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final semantics = tester.getSemantics(find.byType(EvidenceLayersDiagram));
      final data = semantics.getSemanticsData();

      expect(data.label, _evidenceLayersLabels().semanticDescription);
      handle.dispose();
    });
  });

  group('Both diagrams together', () {
    testWidgets(
      'both build in light and dark at 200% text and RTL',
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
                              ThirdPartyDiagram(labels: _thirdPartyLabels()),
                              const SizedBox(height: 24),
                              EvidenceLayersDiagram(labels: _evidenceLayersLabels()),
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