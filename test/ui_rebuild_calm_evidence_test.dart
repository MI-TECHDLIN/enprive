import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as modern;

import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/screens/receipts_screen.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/enprive_tactile_button.dart';
import 'package:enprive/widgets/m3e/enprive_connected_button_group.dart';
import 'package:enprive/widgets/m3e/enprive_receipt_card.dart';

/// Same root as the app: material_ui MaterialApp with the bridge as builder.
Widget _app({
  required Widget home,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  bool disableAnimations = false,
}) {
  return modern.MaterialApp(
    theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
    darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
    themeMode: mode == ThemeMode.dark
        ? modern.ThemeMode.dark
        : modern.ThemeMode.light,
    localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
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

PolicyReviewReceipt _receipt(String id, String title) => PolicyReviewReceipt(
  id: id,
  subjectTitle: title,
  sourceLabel: 'Pasted policy',
  createdAt: DateTime(2026, 11, 20, 9, 30),
  overallState: ReviewOverallState.reviewRecommended,
  inferenceSource: InferenceSource.offlineDeterministic,
  summary: 'One passage deserves a closer look.',
  calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
  snapshotText: 'We collect location.',
  snapshotDigest: 'abc123',
  findings: const [],
);

void main() {
  group('Cloud consent sheet keeps the on-device default first', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'on-device is first and filled, cloud is tonal, and decisions are unchanged (${mode.name})',
        (WidgetTester tester) async {
          CloudConsentDecision? decision;
          await tester.pumpWidget(
            _app(
              mode: mode,
              disableAnimations: true,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () async {
                        decision = await CloudConsentSheet.show(
                          context,
                          subjectTitle: 'EduTrack',
                          policyText: 'Contact guardian@example.com for help.',
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));

          expect(
            find.byKey(const Key('cloud_consent_summary')),
            findsOneWidget,
          );
          expect(find.text('What would be sent'), findsOneWidget);
          expect(
            find.text('1 personal detail is masked first.'),
            findsOneWidget,
          );
          // The summary comes before the payload preview.
          expect(
            tester
                .getTopLeft(find.byKey(const Key('cloud_consent_summary')))
                .dy,
            lessThan(tester.getTopLeft(find.byType(SelectableText)).dy),
          );

          final onDevice = find.byKey(const Key('cloud_consent_on_device_btn'));
          final cloud = find.byKey(const Key('cloud_consent_cloud_btn'));
          final onDeviceTopLeft = tester.getTopLeft(onDevice);
          final cloudTopLeft = tester.getTopLeft(cloud);
          expect(
            onDeviceTopLeft.dy < cloudTopLeft.dy ||
                onDeviceTopLeft.dx < cloudTopLeft.dx,
            isTrue,
            reason: 'On-device must lead the pair',
          );
          expect(
            tester.widget<EnpriveTactileButton>(onDevice).effectiveVariant,
            EnpriveButtonVariant.filled,
          );
          expect(
            tester.widget<EnpriveTactileButton>(cloud).effectiveVariant,
            EnpriveButtonVariant.tonal,
          );

          await tester.tap(onDevice);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
          expect(decision, CloudConsentDecision.reviewLocally);
        },
      );
    }
  });

  group('Receipts swipe delete with Undo', () {
    Future<List<String>> pumpReceipts(
      WidgetTester tester,
      List<String> deleted,
    ) async {
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: ReceiptsScreen(
              receipts: [
                _receipt('r1', 'EduTrack Classroom'),
                _receipt('r2', 'CalmMath Kids'),
              ],
              coordinator: ReviewCoordinator(),
              onDeleteReceipt: deleted.add,
              onStartReviewRequested: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      return deleted;
    }

    testWidgets('Undo restores the receipt without deleting it', (
      WidgetTester tester,
    ) async {
      final deleted = await pumpReceipts(tester, <String>[]);
      await tester.drag(
        find.byKey(const ValueKey<String>('receipt_dismissible_r1')),
        const Offset(-600, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('EduTrack Classroom'), findsNothing);
      expect(find.text('Deleted EduTrack Classroom'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('EduTrack Classroom'), findsOneWidget);
      expect(deleted, isEmpty);
    });

    testWidgets('the receipt is deleted once the snackbar closes', (
      WidgetTester tester,
    ) async {
      final deleted = await pumpReceipts(tester, <String>[]);
      await tester.drag(
        find.byKey(const ValueKey<String>('receipt_dismissible_r2')),
        const Offset(-600, 0),
      );
      await tester.pumpAndSettle();
      expect(deleted, isEmpty);

      ScaffoldMessenger.of(tester.element(find.byType(ReceiptsScreen)))
          .hideCurrentSnackBar();
      await tester.pumpAndSettle();
      expect(deleted, ['r2']);
    });

    testWidgets('delete is also reachable from the overflow menu and as a '
        'TalkBack action', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      final deleted = await pumpReceipts(tester, <String>[]);

      final card = find.byType(EnpriveReceiptCard).first;
      final node = tester.getSemantics(card);
      expect(node.getSemanticsData().customSemanticsActionIds, isNotEmpty);

      await tester.tap(find.byKey(EnpriveReceiptCard.overflowKey).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(find.text('Deleted EduTrack Classroom'), findsOneWidget);
      ScaffoldMessenger.of(tester.element(find.byType(ReceiptsScreen)))
          .hideCurrentSnackBar();
      await tester.pumpAndSettle();
      expect(deleted, ['r1']);
      handle.dispose();
    });
  });

  group('Connected button group', () {
    testWidgets('shows selection with fill and check, announces selected, '
        'and stacks at 200% text', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      var mode = ThemeMode.light;
      Widget group() => StatefulBuilder(
        builder: (context, setState) => Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: EnpriveConnectedButtonGroup<ThemeMode>(
              selected: mode,
              onSelected: (value) => setState(() => mode = value),
              options: const [
                EnpriveGroupOption(
                  key: Key('opt_system'),
                  value: ThemeMode.system,
                  label: 'System',
                  icon: Icons.phone_android,
                ),
                EnpriveGroupOption(
                  key: Key('opt_light'),
                  value: ThemeMode.light,
                  label: 'Light',
                  icon: Icons.light_mode,
                ),
                EnpriveGroupOption(
                  key: Key('opt_dark'),
                  value: ThemeMode.dark,
                  label: 'Dark',
                  icon: Icons.dark_mode,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(_app(home: group()));
      await tester.tap(find.byKey(const Key('opt_dark')));
      await tester.pumpAndSettle();
      expect(mode, ThemeMode.dark);

      final data = tester
          .getSemantics(find.byKey(const Key('opt_dark')))
          .getSemanticsData();
      expect(data.flagsCollection.isSelected, Tristate.isTrue);
      expect(data.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(data.label, 'Dark');
      final row = tester.getTopLeft(find.byKey(const Key('opt_system')));
      final last = tester.getTopLeft(find.byKey(const Key('opt_dark')));
      expect(row.dy, last.dy, reason: 'Side by side at 100% text');

      await tester.pumpWidget(_app(home: group(), textScale: 2.0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(find.byKey(const Key('opt_dark'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const Key('opt_system'))).dy),
        reason: 'Stacks vertically at 200% text',
      );
      handle.dispose();
    });
  });
}
