import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// One-shot gesture timeline for Deni's intent poses, kept separate from the
/// idle breathing loop so a gesture plays once per screen arrival and then
/// rests on the story pose (`svg-mascot-animator` references `physics.md`).
///
/// The timeline has three beats:
/// - Anticipation (`0.34s`): a slow preparatory move against the gesture, with
///   a small body crouch.
/// - Release (`0.06s`): a fast commit toward the story pose.
/// - Settle (`0.70s`): a damped spring (`ζ = 0.32`, `fₙ = 3.2 Hz`) that
///   overshoots the story pose once and comes to rest.
///
/// [reach] is `0.0` at the resting arm position and `1.0` at the story pose. It
/// dips below `0.0` during anticipation and passes `1.0` during the settle
/// overshoot. When the gesture is not playing, [reach] is exactly `1.0`, which is
/// also the still pose used for reduced motion (`rigging.md` Reduced-motion poses).
class DeniGesture {
  DeniGesture({required TickerProvider vsync})
    : _controller = AnimationController(
        vsync: vsync,
        duration: total,
        value: 1.0,
      );

  static const Duration anticipation = Duration(milliseconds: 340);
  static const Duration release = Duration(milliseconds: 60);
  static const Duration settle = Duration(milliseconds: 700);
  static const Duration total = Duration(milliseconds: 1100);

  /// Fraction of [total] at which the release beat ends and the settle begins.
  static double get releaseEndFraction =>
      (anticipation + release).inMicroseconds / total.inMicroseconds;

  static const double _anticipationDepth = 0.14;
  static const double _overshootAmplitude = 0.257;
  static const double _zeta = 0.32;
  static const double _naturalFrequencyHz = 3.2;

  final AnimationController _controller;

  /// Notifies on every gesture frame.
  Listenable get listenable => _controller;

  /// Raw timeline progress in `[0, 1]`.
  double get progress => _controller.value;

  /// Arm and prop reach toward the story pose (see [reachAt]).
  double get reach => reachAt(progress);

  /// Body anticipation crouch in `[0, 1]` (see [crouchAt]).
  double get crouch => crouchAt(progress);

  bool get isPlaying => _controller.isAnimating;

  /// Plays the gesture once from the resting arm position.
  void play() => _controller.forward(from: 0.0);

  /// Stops any running gesture and holds the still story pose.
  void rest() {
    _controller.stop();
    _controller.value = 1.0;
  }

  void dispose() => _controller.dispose();

  /// Reach toward the story pose at timeline [progress] in `[0, 1]`.
  static double reachAt(double progress) {
    if (progress >= 1.0) return 1.0;
    final double t = progress.clamp(0.0, 1.0) * _seconds(total);
    final double ta = _seconds(anticipation);
    final double tr = _seconds(release);

    if (t < ta) {
      // Slow settle into the preparatory move (ease-out quarter sine).
      return -_anticipationDepth * math.sin((t / ta) * math.pi * 0.5);
    }
    if (t < ta + tr) {
      // Explosive, linear release out of the anticipation.
      final double u = (t - ta) / tr;
      return -_anticipationDepth + (1.0 + _anticipationDepth) * u;
    }

    // Damped spring around the story pose, starting at it with release velocity.
    final double ts = t - ta - tr;
    final double wn = 2 * math.pi * _naturalFrequencyHz;
    final double wd = wn * math.sqrt(1.0 - _zeta * _zeta);
    return 1.0 +
        _overshootAmplitude * math.exp(-_zeta * wn * ts) * math.sin(wd * ts);
  }

  /// Body crouch at timeline [progress]: builds during anticipation, springs
  /// back to zero during the release, and stays zero while settling.
  static double crouchAt(double progress) {
    if (progress >= 1.0) return 0.0;
    final double t = progress.clamp(0.0, 1.0) * _seconds(total);
    final double ta = _seconds(anticipation);
    final double tr = _seconds(release);
    if (t < ta) return math.sin((t / ta) * math.pi * 0.5);
    if (t < ta + tr) return 1.0 - (t - ta) / tr;
    return 0.0;
  }

  static double _seconds(Duration d) => d.inMicroseconds / 1e6;
}
