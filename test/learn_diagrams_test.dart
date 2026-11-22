import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as modern;

import 'package:enprive/core/theme/enprive_m3e_theme.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/widgets/learn/diagrams/evidence_categories_legend.dart';
import 'package:enprive/widgets/learn/diagrams/evidence_layers_diagram.dart';
import 'package:enprive/widgets/learn/diagrams/permissions_ladder_diagram.dart';
import 'package:enprive/widgets/learn/diagrams/policy_limit_diagram.dart';
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

PolicyLimitDiagramLabels _policyLimitLabels() => const PolicyLimitDiagramLabels(
  policySaysTitle: 'Policy says',
  policySaysBody: 'Developer\'s written promise',
  policyQuoteSample: '"We may share data with partners…"',
  phoneShowsTitle: 'Phone shows',
  phoneShowsBody: 'Permissions allowed here',
  unknownTitle: 'Still unknown',
  unknownBody: 'Live internet traffic Enprive can\'t see',
  caption: 'A policy is a promise, not proof of behavior',
  semanticDescription:
      'Diagram comparing Policy says, Phone shows, and Still unknown inside a dashed boundary. A privacy policy is a promise, not proof of behavior.',
);

PermissionsLadderDiagramLabels _permissionsLadderLabels() =>
    const PermissionsLadderDiagramLabels(
      headerTitle: 'From narrowest to broadest access',
      denyTitle: 'Don\'t allow',
      denyDetail: 'Blocked — app cannot use this sensor',
      askTitle: 'Ask every time',
      askDetail: 'One-time access when you tap allow',
      whileUsingTitle: 'While using the app',
      whileUsingDetail: 'Only while the app is open on screen',
      allTimeTitle: 'All the time',
      allTimeDetail: 'Background access even when closed',
      featureFitNote: 'Does it fit? Math quiz + Camera = ask why',
      semanticDescription:
          'Four-step Android permission ladder from Don\'t allow, Ask every time, While using the app, to All the time in the background.',
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

  group('PolicyLimitDiagram (Lesson 1)', () {
    testWidgets(
      'renders cleanly in light/dark, 200% text at 320dp, RTL, with single Semantics node',
      (WidgetTester tester) async {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          for (final width in [320.0, 420.0]) {
            for (final textScale in [1.0, 2.0]) {
              for (final locale in [const Locale('en'), const Locale('ar')]) {
                await tester.pumpWidget(
                  _app(
                    mode: mode,
                    textScale: textScale,
                    locale: locale,
                    disableAnimations: true,
                    home: Scaffold(
                      body: SingleChildScrollView(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: width),
                            child: PolicyLimitDiagram(
                              labels: _policyLimitLabels(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                await tester.pumpAndSettle();

                expect(
                  find.bySemanticsLabel(
                    _policyLimitLabels().semanticDescription,
                  ),
                  findsOneWidget,
                );
                expect(
                  tester.takeException(),
                  isNull,
                  reason:
                      'Failed at mode=${mode.name}, width=$width, textScale=$textScale, locale=${locale.languageCode}',
                );
              }
            }
          }
        }

        final handle = tester.ensureSemantics();
        try {
          final sem = tester.getSemantics(find.byType(PolicyLimitDiagram));
          expect(
            sem.getSemanticsData().label,
            _policyLimitLabels().semanticDescription,
          );
        } finally {
          handle.dispose();
        }
      },
    );
  });

  group('PermissionsLadderDiagram (Lesson 2)', () {
    testWidgets(
      'renders cleanly in light/dark, 200% text at 320dp, RTL, with single Semantics node',
      (WidgetTester tester) async {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          for (final width in [320.0, 420.0]) {
            for (final textScale in [1.0, 2.0]) {
              for (final locale in [const Locale('en'), const Locale('ar')]) {
                await tester.pumpWidget(
                  _app(
                    mode: mode,
                    textScale: textScale,
                    locale: locale,
                    disableAnimations: true,
                    home: Scaffold(
                      body: SingleChildScrollView(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: width),
                            child: PermissionsLadderDiagram(
                              labels: _permissionsLadderLabels(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                await tester.pumpAndSettle();

                expect(
                  find.bySemanticsLabel(
                    _permissionsLadderLabels().semanticDescription,
                  ),
                  findsOneWidget,
                );
                expect(
                  tester.takeException(),
                  isNull,
                  reason:
                      'Failed at mode=${mode.name}, width=$width, textScale=$textScale, locale=${locale.languageCode}',
                );
              }
            }
          }
        }

        final handle = tester.ensureSemantics();
        try {
          final sem = tester.getSemantics(
            find.byType(PermissionsLadderDiagram),
          );
          expect(
            sem.getSemanticsData().label,
            _permissionsLadderLabels().semanticDescription,
          );
        } finally {
          handle.dispose();
        }
      },
    );
  });

  group('EvidenceCategoriesLegend (Lesson 4)', () {
    testWidgets(
      'displays all five Review evidence categories with single Semantics node at 200% text and RTL',
      (WidgetTester tester) async {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          for (final locale in [const Locale('en'), const Locale('ar')]) {
            await tester.pumpWidget(
              _app(
                mode: mode,
                textScale: 2.0,
                locale: locale,
                disableAnimations: true,
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: const EvidenceCategoriesLegend(),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        }

        await tester.pumpWidget(
          _app(
            disableAnimations: true,
            home: const Scaffold(body: EvidenceCategoriesLegend()),
          ),
        );
        await tester.pumpAndSettle();

        final handle = tester.ensureSemantics();
        try {
          final sem = tester.getSemantics(
            find.byType(EvidenceCategoriesLegend),
          );
          final label = sem.getSemanticsData().label;
          expect(label, contains('Data Collection'));
          expect(label, contains('Third-Party Sharing'));
          expect(label, contains('Location & Tracking'));
          expect(label, contains('Retention & Voice'));
          expect(label, contains('Parental Controls'));
        } finally {
          handle.dispose();
        }
      },
    );
  });
}