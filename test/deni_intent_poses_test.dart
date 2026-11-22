import 'package:enprive/core/theme/enprive_m3e_theme.dart';
import 'package:enprive/widgets/deni_animated_mascot.dart';
import 'package:enprive/widgets/deni_gesture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<DeniPose> _intentPoses = [
  DeniPose.pointing,
  DeniPose.raiseHand,
  DeniPose.holdShield,
  DeniPose.carryReceipt,
  DeniPose.peek,
];

/// Size tiers rendered by the goldens: compact (Ask Deni button), standard
/// (Home, Receipts, onboarding) and hero (onboarding welcome).
const Map<DeniLodTier, double> _tierSizes = {
  DeniLodTier.compact: 56,
  DeniLodTier.standard: 92,
  DeniLodTier.hero: 144,
};

Widget _stage({
  required Widget child,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
  bool disableAnimations = true,
}) {
  final bool isDark = brightness == Brightness.dark;
  // The painter reads only brightness and the semantic glow fallback; the stage
  // uses the app's real surface color for each theme.
  final Color surface =
      (isDark ? EnpriveM3ETheme.darkThemeData : EnpriveM3ETheme.lightThemeData)
          .colorScheme
          .surface;
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: textDirection,
      child: Theme(
        data: ThemeData(brightness: brightness),
        child: Center(
          child: RepaintBoundary(
            key: const Key('deni_stage'),
            child: ColoredBox(
              color: surface,
              child: Padding(padding: const EdgeInsets.all(8), child: child),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('DeniGesture timeline', () {
    test(
      'starts at rest, anticipates, overshoots once and settles exactly',
      () {
        expect(DeniGesture.reachAt(0.0), 0.0);

        final double anticipationEnd =
            DeniGesture.anticipation.inMicroseconds /
            DeniGesture.total.inMicroseconds;
        expect(DeniGesture.reachAt(anticipationEnd * 0.99), lessThan(-0.1));
        expect(DeniGesture.crouchAt(anticipationEnd * 0.99), greaterThan(0.9));

        final double releaseEnd = DeniGesture.releaseEndFraction;
        expect(DeniGesture.reachAt(releaseEnd), closeTo(1.0, 0.01));
        expect(DeniGesture.crouchAt(releaseEnd), 0.0);

        double peak = 0.0;
        for (double p = releaseEnd; p < 1.0; p += 0.005) {
          final double r = DeniGesture.reachAt(p);
          if (r > peak) peak = r;
        }
        expect(peak, inInclusiveRange(1.10, 1.20));

        expect(DeniGesture.reachAt(0.98), closeTo(1.0, 0.01));
        expect(DeniGesture.reachAt(1.0), 1.0);
        expect(DeniGesture.crouchAt(1.0), 0.0);
      },
    );

    test('anticipation, release and settle follow the physics.md budget', () {
      expect(
        DeniGesture.anticipation.inMilliseconds,
        inInclusiveRange(250, 450),
      );
      expect(DeniGesture.release.inMilliseconds, inInclusiveRange(40, 80));
      expect(
        DeniGesture.anticipation + DeniGesture.release + DeniGesture.settle,
        DeniGesture.total,
      );
    });

    test('only the priority intent poses play a gesture', () {
      for (final pose in DeniPose.values) {
        expect(
          pose.hasIntentGesture,
          _intentPoses.contains(pose),
          reason: '$pose',
        );
      }
    });
  });

  group('DeniAnimatedMascot intent poses', () {
    testWidgets(
      'reduced motion holds the still story pose with no running ticker',
      (tester) async {
        for (final pose in _intentPoses) {
          await tester.pumpWidget(
            _stage(child: DeniAnimatedMascot(size: 92, pose: pose)),
          );
          await tester.pump();
          expect(
            tester.binding.hasScheduledFrame,
            isFalse,
            reason: '$pose must not animate under reduced motion',
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets('holdStill freezes the gesture and idle loop while reading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _stage(
          disableAnimations: false,
          child: const DeniAnimatedMascot(
            size: 92,
            pose: DeniPose.pointing,
            holdStill: true,
          ),
        ),
      );
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('plays one gesture on arrival, then only breathes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _stage(
          disableAnimations: false,
          child: const DeniAnimatedMascot(size: 92, pose: DeniPose.raiseHand),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pump(DeniGesture.total);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('stays decorative for TalkBack unless it opens an assistant', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _stage(
          child: const DeniAnimatedMascot(size: 92, pose: DeniPose.pointing),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Deni')), findsNothing);

      var taps = 0;
      await tester.pumpWidget(
        _stage(
          child: DeniAnimatedMascot(
            size: 56,
            pose: DeniPose.raiseHand,
            semanticLabel: 'Ask Deni',
            onTap: () => taps++,
          ),
        ),
      );
      final data = tester
          .getSemantics(find.bySemanticsLabel('Ask Deni'))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      await tester.tap(find.byType(DeniAnimatedMascot));
      expect(taps, 1);
      handle.dispose();
    });

    for (final brightness in Brightness.values) {
      for (final tier in _tierSizes.keys) {
        for (final pose in _intentPoses) {
          testWidgets('golden ${pose.name} ${tier.name} ${brightness.name}', (
            tester,
          ) async {
            await tester.pumpWidget(
              _stage(
                brightness: brightness,
                child: DeniAnimatedMascot(size: _tierSizes[tier]!, pose: pose),
              ),
            );
            expect(
              tester
                  .widget<DeniAnimatedMascot>(find.byType(DeniAnimatedMascot))
                  .effectiveLodTier,
              tier,
            );
            await expectLater(
              find.byKey(const Key('deni_stage')),
              matchesGoldenFile(
                'goldens/deni_${pose.name}_${tier.name}_${brightness.name}.png',
              ),
            );
          });
        }
      }
    }

    for (final pose in _intentPoses.where((p) => p.isDirectional)) {
      testWidgets('golden ${pose.name} standard light mirrors in RTL', (
        tester,
      ) async {
        await tester.pumpWidget(
          _stage(
            textDirection: TextDirection.rtl,
            child: DeniAnimatedMascot(size: 92, pose: pose),
          ),
        );
        await expectLater(
          find.byKey(const Key('deni_stage')),
          matchesGoldenFile('goldens/deni_${pose.name}_standard_light_rtl.png'),
        );
      });
    }
  });
}
