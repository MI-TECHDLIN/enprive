import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/enprive_colors.dart';
import '../core/theme/enprive_tokens.dart';
import 'deni_gesture.dart';

enum DeniPose {
  idle,
  thinking,
  explaining,
  listening,
  support,
  celebrating,

  /// Points at the screen's next step (Check home, "Check an app").
  pointing,

  /// Raises an open palm: "I can explain this" (Ask Deni entry points).
  raiseHand,

  /// Holds the privacy promise shield (onboarding last screen only; never on a
  /// review result, and never with a check mark).
  holdShield,

  /// Carries and places a receipt slip (saving a review, Receipts).
  carryReceipt,

  /// Rises over a card edge with hands on the ledge (Quick Settings card,
  /// empty states).
  peek,
}

extension DeniPoseIntent on DeniPose {
  /// Whether this pose plays a one-shot [DeniGesture] on arrival.
  bool get hasIntentGesture => switch (this) {
    DeniPose.pointing ||
    DeniPose.raiseHand ||
    DeniPose.holdShield ||
    DeniPose.carryReceipt ||
    DeniPose.peek => true,
    _ => false,
  };

  /// Whether the gesture has a direction that mirrors in right-to-left layouts.
  bool get isDirectional => switch (this) {
    DeniPose.pointing || DeniPose.raiseHand || DeniPose.peek => true,
    _ => false,
  };
}

/// Three-tier Level-of-Detail (LOD) system for Deni (Concept C):
/// - [compact] (`48–64dp`): Crisp silhouette, slightly bolder facial features &
///   crown paper tab, suppresses large external floating cards so Deni's face
///   is never obscured at small avatar sizes.
/// - [standard] (`68–112dp`): Balanced companion with connected primary prop
///   positioned strictly outside the facial zone and within safe canvas bounds.
/// - [hero] (`116dp+`): Full multi-prop choreography, secondary callouts, and
///   ambient radial stage lighting.
enum DeniLodTier { compact, standard, hero }

/// Interactive sculpted vector mascot for Deni (Concept C: The Protective Pebble
/// with Paper Tab).
///
/// Built on the `svg-mascot-animator` rigging & physics specification:
/// - Grounded bottom-centre pivot so squash/stretch never drags through the floor
/// - Area-interpolated deformation: `sx = pow(sy, -0.55)` (`squash(sy, preserve=0.55)`)
/// - Damped spring step response (`ζ = 0.32, fₙ = 5.5 Hz`) on tap and pose transitions
/// - 8% phase-lagged secondary follow-through on the folded cream paper slip
/// - Height-coupled contact shadow (`shadowTrack`)
/// - Three-tier responsive LOD (`compact` 48–64dp, `standard` 68–112dp, `hero` 116dp+)
/// - Intent poses ([DeniPose.pointing], [DeniPose.raiseHand],
///   [DeniPose.holdShield], [DeniPose.carryReceipt], [DeniPose.peek]) with long
///   arms and mitten hands; each plays one [DeniGesture] per arrival, then rests
///   on its story pose while only the breathing loop continues. Gaze follows the
///   hand, and directional gestures mirror in right-to-left layouts.
/// - Hand rules: compact shows at most one hand and no props; hands never cover
///   the face; reduced motion and [holdStill] show the still story pose only.
/// - Non-certification trust guardrails: zero checkmarks or thumbs up; the
///   shield is only the onboarding privacy promise, never a review verdict
/// - Decorative for screen readers unless [onTap] is set, in which case it is a
///   button named by [semanticLabel] (Deni addendum placement rules)
class DeniAnimatedMascot extends StatefulWidget {
  final double size;
  final DeniPose pose;
  final VoidCallback? onTap;
  final bool showAmbientGlow;
  final DeniLodTier? lodOverride;

  /// Freezes Deni on the still story pose, for example while the user reads a
  /// long passage or listens to speech.
  final bool holdStill;

  /// Accessible name used only when [onTap] makes Deni a button.
  final String? semanticLabel;

  const DeniAnimatedMascot({
    super.key,
    this.size = 96.0,
    this.pose = DeniPose.idle,
    this.onTap,
    this.showAmbientGlow = true,
    this.lodOverride,
    this.holdStill = false,
    this.semanticLabel,
  });

  /// Resolves the canonical [DeniLodTier] for a given logical [size] in dp:
  /// - `<= 66.0` -> [DeniLodTier.compact] (48–64dp tier)
  /// - `< 116.0` -> [DeniLodTier.standard] (68–112dp tier)
  /// - `>= 116.0` -> [DeniLodTier.hero] (116dp+ tier)
  static DeniLodTier resolveTierForSize(double size) {
    if (size <= 66.0) return DeniLodTier.compact;
    if (size < 116.0) return DeniLodTier.standard;
    return DeniLodTier.hero;
  }

  DeniLodTier get effectiveLodTier => lodOverride ?? resolveTierForSize(size);

  @override
  State<DeniAnimatedMascot> createState() => _DeniAnimatedMascotState();
}

class _DeniAnimatedMascotState extends State<DeniAnimatedMascot>
    with TickerProviderStateMixin {
  late final AnimationController _loopController;
  late final AnimationController _blinkController;
  late final AnimationController _springController;
  late final DeniGesture _gesture;
  final math.Random _random = math.Random();
  Timer? _blinkTimer;
  bool _reduceMotion = false;
  bool _arrivalHandled = false;

  /// Motion runs only when the platform allows animation and the host has not
  /// asked Deni to hold still.
  bool get _motionAllowed => !_reduceMotion && !widget.holdStill;

  @override
  void initState() {
    super.initState();

    // 3.6s master loop (within the 3.0–6.0s optimal window from physics.md).
    // Started and stopped by [_syncMotion] so reduced motion keeps no ticker.
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // 120ms natural blink (within 0.08–0.14s spec from physics.md)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scheduleNextBlink();

    // 450ms damped spring response for tap and pose-change anticipation/settle
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // One-shot intent gesture, separate from the idle loop.
    _gesture = DeniGesture(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _syncMotion();
    if (!_arrivalHandled) {
      // One gesture per screen arrival.
      _arrivalHandled = true;
      _playGestureIfNeeded();
    }
  }

  @override
  void didUpdateWidget(covariant DeniAnimatedMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdStill != widget.holdStill) {
      _syncMotion();
    }
    if (oldWidget.pose != widget.pose && _motionAllowed) {
      _springController.forward(from: 0.0);
      _playGestureIfNeeded();
    }
  }

  void _syncMotion() {
    if (_motionAllowed) {
      if (!_loopController.isAnimating) _loopController.repeat();
    } else {
      _loopController.stop();
      _springController.stop();
      _springController.value = 0.0;
      _gesture.rest();
    }
  }

  void _playGestureIfNeeded() {
    if (_motionAllowed && widget.pose.hasIntentGesture) {
      _gesture.play();
    } else {
      _gesture.rest();
    }
  }

  void _scheduleNextBlink() {
    if (!mounted) return;
    final delay = Duration(milliseconds: 2500 + _random.nextInt(2000));
    _blinkTimer?.cancel();
    _blinkTimer = Timer(delay, () async {
      if (!mounted) return;
      if (_motionAllowed) {
        await _blinkController.forward();
        if (!mounted) return;
        await _blinkController.reverse();
      }
      _scheduleNextBlink();
    });
  }

  void _handleTap() {
    if (_motionAllowed) {
      _springController.forward(from: 0.0);
      _playGestureIfNeeded();
    }
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _loopController.dispose();
    _blinkController.dispose();
    _springController.dispose();
    _gesture.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool still = !_motionAllowed;
    final DeniLodTier lod = widget.effectiveLodTier;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isRtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final semantics = context.semanticColors;

    final (double widthFactor, double heightFactor) = switch (lod) {
      DeniLodTier.compact => (1.18, 1.16),
      DeniLodTier.standard => (1.28, 1.22),
      DeniLodTier.hero => (1.32, 1.24),
    };

    final Widget mascot = GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size * widthFactor,
        height: widget.size * heightFactor,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _loopController,
            _blinkController,
            _springController,
            _gesture.listenable,
          ]),
          builder: (context, _) {
            // When Deni is still, pick the expressive keyframe (0.35) that
            // carries the story clearly (per rigging.md Reduced-motion poses);
            // the gesture rests on its story pose (reach 1.0).
            final double phase = still ? 0.35 : _loopController.value;
            final double blink = still ? 0.0 : _blinkController.value;
            final double springT = still ? 0.0 : _springController.value;

            return CustomPaint(
              painter: _DeniRiggedActionPainter(
                phase: phase,
                blink: blink,
                springT: springT,
                gestureReach: still ? 1.0 : _gesture.reach,
                gestureCrouch: still ? 0.0 : _gesture.crouch,
                gestureProgress: still ? 1.0 : _gesture.progress,
                pose: widget.pose,
                lod: lod,
                isDark: isDark,
                isRtl: isRtl,
                showAmbientGlow: widget.showAmbientGlow,
                primaryGlowColor: semantics.deniPrimaryGlow,
                secondaryGlowColor: semantics.deniSecondaryGlow,
              ),
            );
          },
        ),
      ),
    );

    if (widget.onTap == null) {
      // Decorative: adjacent text already labels the content.
      return ExcludeSemantics(child: mascot);
    }
    return Semantics(
      label: widget.semanticLabel ?? 'Deni, your privacy guide',
      button: true,
      child: mascot,
    );
  }
}

class _DeniRiggedActionPainter extends CustomPainter {
  final double phase;
  final double blink;
  final double springT;
  final double gestureReach;
  final double gestureCrouch;
  final double gestureProgress;
  final DeniPose pose;
  final DeniLodTier lod;
  final bool isDark;
  final bool isRtl;
  final bool showAmbientGlow;
  final Color primaryGlowColor;
  final Color secondaryGlowColor;

  _DeniRiggedActionPainter({
    required this.phase,
    required this.blink,
    required this.springT,
    required this.gestureReach,
    required this.gestureCrouch,
    required this.gestureProgress,
    required this.pose,
    required this.lod,
    required this.isDark,
    required this.isRtl,
    required this.showAmbientGlow,
    required this.primaryGlowColor,
    required this.secondaryGlowColor,
  });

  /// Horizontal sign of directional gestures: `1` reaches toward the right in
  /// left-to-right layouts, `-1` toward the left in right-to-left layouts.
  double get _dir => (isRtl && pose.isDirectional) ? -1.0 : 1.0;

  /// Body-space shoulder height shared by every intent pose arm.
  static const double _shoulderDy = 0.10;

  /// Where the eyes look, in eye-radius units, so gaze follows the hand.
  Offset get _gazeTarget {
    final double r = gestureReach.clamp(0.0, 1.0);
    return switch (pose) {
          DeniPose.pointing => Offset(0.30 * _dir, 0.16),
          DeniPose.raiseHand => Offset(0.24 * _dir, -0.22),
          DeniPose.holdShield => const Offset(0.0, 0.20),
          DeniPose.carryReceipt => const Offset(0.0, 0.24),
          DeniPose.peek => Offset(0.10 * _dir, 0.22),
          _ => Offset.zero,
        } *
        r;
  }

  /// Area-interpolated squash/stretch from `svg-mascot-animator/references/physics.md`:
  /// `preserve = 0.55` keeps the solid ceramic pebble silhouette without melting.
  static double _squashX(double sy, {double preserve = 0.55}) {
    return math.pow(sy.clamp(0.68, 1.25), -preserve).toDouble();
  }

  /// Damped spring step response from `physics.md`:
  /// `ζ = 0.32` (lively), `fₙ = 5.5 Hz` (grounded pebble mass).
  static double _dampedSpringDeviation(double t) {
    if (t <= 0.0 || t >= 1.0) return 0.0;
    const double zeta = 0.32;
    const double fn = 5.5;
    final double wn = 2 * math.pi * fn;
    final double wd = wn * math.sqrt(1.0 - zeta * zeta);
    final double decay = math.exp(-zeta * wn * (t * 0.45));
    return -0.18 * decay * math.sin(wd * (t * 0.45));
  }

  /// Computes ballistic hop + crouch + landing squash for `celebrating`,
  /// or harmonic grounded breathing for other poses.
  (double jumpHeightRatio, double sy, double bodyTiltRad) _computeKinematics() {
    final double springDelta = _dampedSpringDeviation(springT);

    if (pose == DeniPose.celebrating) {
      if (phase < 0.14) {
        final double u = phase / 0.14;
        final double crouch = math.sin(u * math.pi * 0.5);
        return (0.0, (1.0 - 0.15 * crouch) + springDelta, 0.0);
      } else if (phase < 0.54) {
        final double u = (phase - 0.14) / 0.40;
        final double jumpH = 4.0 * 0.12 * u * (1.0 - u);
        final double velMag = (1.0 - 2.0 * u).abs();
        final double stretchY = 1.0 + 0.11 * velMag;
        final double airTilt = math.sin(u * math.pi) * 0.04;
        return (jumpH, stretchY + springDelta, airTilt);
      } else if (phase < 0.66) {
        final double u = (phase - 0.54) / 0.12;
        final double impact = math.sin(u * math.pi);
        return (0.0, (1.0 - 0.16 * impact) + springDelta, 0.0);
      } else {
        final double u = (phase - 0.66) / 0.34;
        final double settle =
            math.exp(-4.5 * u) * math.sin(u * math.pi * 3.0) * 0.06;
        final double happySway = math.sin(u * math.pi * 2.0) * 0.035;
        return (0.0, 1.0 + settle + springDelta, happySway);
      }
    }

    final double breatheSin = math.sin(phase * 2 * math.pi);
    // Intent gestures add a small anticipation crouch on top of breathing.
    final double sy =
        1.0 + (breatheSin * 0.024) + springDelta - gestureCrouch * 0.035;
    final double lift = (breatheSin * 0.5 + 0.5) * 0.022;
    final double reach = gestureReach;

    final double tilt = switch (pose) {
      DeniPose.listening => -0.045 + math.sin(phase * 4 * math.pi) * 0.035,
      DeniPose.support => math.sin(phase * 2 * math.pi) * 0.035,
      DeniPose.thinking => 0.028 + math.sin(phase * 2 * math.pi) * 0.020,
      DeniPose.explaining => 0.020 + math.sin(phase * 2 * math.pi) * 0.016,
      DeniPose.idle => math.sin(phase * 2 * math.pi) * 0.015,
      DeniPose.celebrating => 0.0,
      // Lean into the point; lean slightly away from a raised hand.
      DeniPose.pointing => _dir * 0.035 * reach + breatheSin * 0.010,
      DeniPose.raiseHand => -_dir * 0.020 * reach + breatheSin * 0.012,
      DeniPose.holdShield => breatheSin * 0.008,
      DeniPose.carryReceipt => breatheSin * 0.010,
      DeniPose.peek => _dir * 0.050 * reach + breatheSin * 0.010,
    };

    return (lift, sy, tilt);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final bool isCompact = lod == DeniLodTier.compact;

    // In LOD 1 (compact 48-64dp), Deni is centered and fills a larger proportion
    // of the avatar box so the face and crown paper tab read with maximum clarity.
    // In LOD 2/3, Deni shifts slightly left when right-side props (thinking/explaining)
    // are active so props never overlap the face or clip the right canvas edge.
    // Directional intent poses shift away from the reaching hand (mirrored in RTL).
    final double cx = switch (pose) {
      DeniPose.pointing => w * (0.50 - _dir * (isCompact ? 0.06 : 0.09)),
      DeniPose.raiseHand => w * (0.50 - _dir * (isCompact ? 0.04 : 0.05)),
      DeniPose.holdShield || DeniPose.carryReceipt || DeniPose.peek => w * 0.50,
      _ when isCompact => w * 0.50,
      DeniPose.thinking || DeniPose.explaining => w * 0.41,
      _ => w * 0.48,
    };
    final double groundY = isCompact ? h * 0.90 : h * 0.89;

    final double pw = isCompact
        ? w * 0.65
        : (lod == DeniLodTier.standard ? w * 0.55 : w * 0.57);
    final double ph = isCompact
        ? h * 0.68
        : (lod == DeniLodTier.standard ? h * 0.63 : h * 0.64);

    final (double jumpHeightRatio, double sy, double bodyTilt) =
        _computeKinematics();
    final double sx = _squashX(sy);
    final bool isPeek = pose == DeniPose.peek;
    // Peek sinks the body behind the ledge at [groundY] and rises with reach.
    final double peekSinkPx = isPeek
        ? ph * (0.26 + 0.60 * (1.0 - gestureReach)).clamp(0.0, 1.2)
        : 0.0;
    final double elevationPx = jumpHeightRatio * h - peekSinkPx;

    // Secondary motion with 8% phase lag (`physics.md` Lag and follow-through)
    final double laggedPhase = (phase - 0.08) % 1.0;
    final double laggedSin = math.sin(laggedPhase * 2 * math.pi);
    final double fastSin = math.sin(phase * 4 * math.pi);

    if (isPeek) {
      // Everything behind the ledge is hidden, as if Deni stands behind a card.
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, 0, w, groundY));
    }

    // 1. Subtle Ambient Glow behind Deni (Theme-aware for Light & Dark canvas)
    if (showAmbientGlow) {
      final Offset glowCenter = Offset(cx, groundY - ph * 0.5 - elevationPx);
      final double glowRadius = isCompact ? w * 0.42 : w * 0.46;
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [primaryGlowColor, secondaryGlowColor, Colors.transparent],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: glowRadius));
      canvas.drawCircle(glowCenter, glowRadius, glowPaint);
    }

    // 2. Contact Shadow Coupled Directly to Height (`shadow_track` from physics.md)
    final double heightFactor = (jumpHeightRatio / 0.14).clamp(0.0, 1.0);
    final double shadowScale = (1.0 - 0.42 * heightFactor) * (sx * 0.95);
    final double baseShadowAlpha = isDark ? 0.34 : 0.17;
    final double shadowAlpha = (baseShadowAlpha - 0.09 * heightFactor).clamp(
      0.05,
      0.40,
    );
    // A peeking Deni stands behind the ledge, so it casts no floor shadow.
    if (!isPeek) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, groundY),
          width: pw * 0.84 * shadowScale,
          height: ph * 0.11 * shadowScale,
        ),
        Paint()
          ..color = (isDark ? Colors.black : const Color(0xFF0E4A43))
              .withValues(alpha: shadowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // 3. Celebrating Landing Ripple / Debris Ring
    if (pose == DeniPose.celebrating && phase >= 0.52 && phase <= 0.86) {
      final double ringU = ((phase - 0.52) / 0.34).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, groundY),
          width: pw * (0.65 + 0.58 * ringU),
          height: ph * (0.09 + 0.08 * ringU),
        ),
        Paint()
          ..color = (isDark ? EnpriveColors.tealDarkAccent : EnpriveColors.teal)
              .withValues(alpha: (1.0 - ringU) * 0.38)
          ..strokeWidth = isCompact ? 1.5 : 2.0
          ..style = PaintingStyle.stroke,
      );
    }

    // 4. Rigged Group Hierarchy (`rigging.md`: One concern per transform)
    final double bodyCenterY = groundY - (ph * 0.50);
    canvas.save();
    canvas.translate(0, -elevationPx);
    canvas.translate(cx, groundY);
    canvas.scale(sx, sy);
    canvas.translate(-cx, -groundY);
    canvas.translate(cx, bodyCenterY);
    canvas.rotate(bodyTilt);
    canvas.translate(-cx, -bodyCenterY);

    // 5. Background Flippers
    final bool compactSingleHand =
        isCompact &&
        (pose == DeniPose.pointing ||
            pose == DeniPose.raiseHand ||
            pose == DeniPose.peek);
    if (isCompact) {
      // In LOD 1 (compact), use clean side flippers for idle/thinking/explaining/celebrating
      // so articulated arms never cross over or obscure Deni's face at 48-64dp!
      if (pose == DeniPose.support) {
        _drawSupportShoulders(canvas, cx, bodyCenterY, pw, ph);
      } else if (compactSingleHand) {
        // At most one hand at compact size: keep the flipper on the far side.
        if (_dir > 0) {
          _drawLeftFlipper(canvas, cx, bodyCenterY, pw, ph, laggedSin, fastSin);
        } else {
          _drawRightFlipper(
            canvas,
            cx,
            bodyCenterY,
            pw,
            ph,
            laggedSin,
            fastSin,
          );
        }
      } else {
        _drawLeftFlipper(canvas, cx, bodyCenterY, pw, ph, laggedSin, fastSin);
        _drawRightFlipper(canvas, cx, bodyCenterY, pw, ph, laggedSin, fastSin);
      }
    } else if (pose == DeniPose.idle || pose == DeniPose.celebrating) {
      _drawLeftFlipper(canvas, cx, bodyCenterY, pw, ph, laggedSin, fastSin);
      _drawRightFlipper(canvas, cx, bodyCenterY, pw, ph, laggedSin, fastSin);
    } else if (!pose.hasIntentGesture) {
      _drawSupportShoulders(canvas, cx, bodyCenterY, pw, ph);
    }

    // 6. Sculpted Organic Pebble Body (Concept C)
    final Path pebblePath = _buildPebblePath(cx, bodyCenterY, pw, ph);
    final Rect pebbleBounds = Rect.fromCenter(
      center: Offset(cx, bodyCenterY),
      width: pw,
      height: ph,
    );

    final Paint bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.38, -0.45),
        radius: 1.15,
        colors: [
          Color(0xFF39C4B3),
          Color(0xFF1F9E8F),
          Color(0xFF13756A),
          Color(0xFF0B4F47),
        ],
        stops: [0.0, 0.42, 0.78, 1.0],
      ).createShader(pebbleBounds);
    canvas.drawPath(pebblePath, bodyPaint);

    // Subtle outer rim stroke in Dark Mode so the pebble silhouette pops against dark slate
    if (isDark) {
      canvas.drawPath(
        pebblePath,
        Paint()
          ..color = const Color(0xFF4FD1C5).withValues(alpha: 0.28)
          ..strokeWidth = isCompact ? 1.4 : 1.8
          ..style = PaintingStyle.stroke,
      );
    }

    // Top-left ceramic rim light & bottom-right ambient occlusion crescent
    canvas.save();
    canvas.clipPath(pebblePath);
    canvas.drawPath(
      pebblePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.24),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.42],
        ).createShader(pebbleBounds),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + pw * 0.16, bodyCenterY + ph * 0.36),
        width: pw * 0.75,
        height: ph * 0.36,
      ),
      Paint()
        ..color = const Color(0xFF073832).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.restore();

    // 7. Phase-Lagged Sculpted Paper Slip on Crown (`laggedSin` follow-through)
    _drawSculptedPaperTab(
      canvas,
      cx,
      bodyCenterY,
      pw,
      ph,
      laggedSin,
      jumpHeightRatio,
    );

    // 8. Face with Active Eye Scanning & Multi-Syllable Mouth Articulation
    _drawFace(canvas, cx, bodyCenterY, pw, ph, fastSin);

    // 9. Foreground Articulated Hands & Connected Props per State & LOD Tier
    if (isCompact) {
      // LOD 1 (48-64dp): Never cross the face with floating boards or arms.
      if (pose == DeniPose.support) {
        _drawSupportClaspedHands(canvas, cx, bodyCenterY, pw, ph, laggedSin);
      } else if (pose == DeniPose.listening) {
        _drawCompactListeningCups(canvas, cx, bodyCenterY, pw, ph);
      } else if (pose == DeniPose.pointing) {
        _drawPointingScene(canvas, cx, bodyCenterY, pw, ph, laggedSin);
      } else if (pose == DeniPose.raiseHand) {
        _drawRaiseHandScene(canvas, cx, bodyCenterY, pw, ph, laggedSin);
      }
    } else {
      switch (pose) {
        case DeniPose.pointing:
          _drawPointingScene(canvas, cx, bodyCenterY, pw, ph, laggedSin);
        case DeniPose.raiseHand:
          _drawRaiseHandScene(canvas, cx, bodyCenterY, pw, ph, laggedSin);
        case DeniPose.carryReceipt:
          _drawCarryReceiptScene(canvas, cx, bodyCenterY, pw, ph, laggedSin);
        case DeniPose.holdShield:
        case DeniPose.peek:
          // Drawn in world space below so the props stay still while Deni breathes.
          break;
        case DeniPose.thinking:
          _drawThinkingScene(
            canvas,
            cx,
            bodyCenterY,
            pw,
            ph,
            laggedSin,
            fastSin,
          );
        case DeniPose.explaining:
          _drawExplainingScene(
            canvas,
            cx,
            bodyCenterY,
            pw,
            ph,
            laggedSin,
            fastSin,
          );
        case DeniPose.listening:
          _drawListeningScene(
            canvas,
            cx,
            bodyCenterY,
            pw,
            ph,
            laggedSin,
            fastSin,
          );
        case DeniPose.support:
          _drawSupportClaspedHands(canvas, cx, bodyCenterY, pw, ph, laggedSin);
        case DeniPose.idle:
        case DeniPose.celebrating:
          break;
      }
    }

    canvas.restore();

    // Maps a body-space point through the body rig (tilt, squash, elevation).
    Offset bodyToWorld(Offset p) {
      final Offset d = p - Offset(cx, bodyCenterY);
      final double c = math.cos(bodyTilt);
      final double s = math.sin(bodyTilt);
      final Offset rotated = Offset(
        cx + d.dx * c - d.dy * s,
        bodyCenterY + d.dx * s + d.dy * c,
      );
      return Offset(
        cx + (rotated.dx - cx) * sx,
        groundY + (rotated.dy - groundY) * sy - elevationPx,
      );
    }

    if (isPeek) {
      canvas.restore();
      _drawPeekLedge(canvas, cx, groundY, w, pw, ph);
    } else if (pose == DeniPose.holdShield && !isCompact) {
      _drawHoldShieldScene(canvas, cx, bodyCenterY, pw, ph, bodyToWorld);
    }

    // 10. Additional External Floating Badges / Sparkles (scaled by LOD tier)
    _drawExternalBadges(
      canvas,
      cx,
      bodyCenterY - elevationPx,
      pw,
      ph,
      phase,
      fastSin,
    );
  }

  Path _buildPebblePath(double cx, double cy, double pw, double ph) {
    final double top = cy - ph * 0.48;
    final double bottom = cy + ph * 0.50;
    final double left = cx - pw * 0.50;
    final double right = cx + pw * 0.50;

    return Path()
      ..moveTo(cx, top)
      ..cubicTo(
        cx + pw * 0.34,
        top,
        right,
        cy - ph * 0.32,
        right,
        cy - ph * 0.02,
      )
      ..cubicTo(right, cy + ph * 0.30, cx + pw * 0.32, bottom, cx, bottom)
      ..cubicTo(
        cx - pw * 0.32,
        bottom,
        left,
        cy + ph * 0.30,
        left,
        cy - ph * 0.02,
      )
      ..cubicTo(left, cy - ph * 0.32, cx - pw * 0.34, top, cx, top)
      ..close();
  }

  void _drawLeftFlipper(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
    double fastSin,
  ) {
    canvas.save();
    final double pivotX = cx - pw * 0.45;
    final double pivotY = cy + ph * 0.02;
    canvas.translate(pivotX, pivotY);

    final double angle = pose == DeniPose.celebrating
        ? 0.72 + fastSin * 0.22
        : 0.22 + laggedSin * 0.05;
    canvas.rotate(angle);

    final Rect armRect = Rect.fromCenter(
      center: Offset(
        -pw * 0.05,
        pose == DeniPose.celebrating ? -ph * 0.08 : ph * 0.12,
      ),
      width: pw * 0.19,
      height: ph * 0.32,
    );
    canvas.drawOval(
      armRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF28AA9B), Color(0xFF0E6157)],
        ).createShader(armRect),
    );
    canvas.restore();
  }

  void _drawRightFlipper(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
    double fastSin,
  ) {
    canvas.save();
    final double pivotX = cx + pw * 0.44;
    final double pivotY = cy + ph * 0.02;
    canvas.translate(pivotX, pivotY);

    if (pose == DeniPose.idle || pose == DeniPose.explaining) {
      canvas.rotate(-0.78 + fastSin * 0.18);
      final Rect waveArm = Rect.fromCenter(
        center: Offset(pw * 0.06, -ph * 0.10),
        width: pw * 0.19,
        height: ph * 0.32,
      );
      canvas.drawOval(
        waveArm,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF33B9A9), Color(0xFF116B60)],
          ).createShader(waveArm),
      );
    } else if (pose == DeniPose.celebrating) {
      canvas.rotate(-0.78 - fastSin * 0.22);
      final Rect cheerArm = Rect.fromCenter(
        center: Offset(pw * 0.06, -ph * 0.09),
        width: pw * 0.19,
        height: ph * 0.32,
      );
      canvas.drawOval(
        cheerArm,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF36C0B0), Color(0xFF116B60)],
          ).createShader(cheerArm),
      );
    } else {
      canvas.rotate(-0.24 - laggedSin * 0.05);
      final Rect restArm = Rect.fromCenter(
        center: Offset(pw * 0.05, ph * 0.10),
        width: pw * 0.18,
        height: ph * 0.30,
      );
      canvas.drawOval(
        restArm,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF28AA9B), Color(0xFF0E6157)],
          ).createShader(restArm),
      );
    }
    canvas.restore();
  }

  void _drawCompactListeningCups(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
  ) {
    for (final sign in [-1.0, 1.0]) {
      final Rect cupRect = Rect.fromCenter(
        center: Offset(cx + sign * pw * 0.50, cy - ph * 0.03),
        width: pw * 0.14,
        height: ph * 0.24,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cupRect, Radius.circular(pw * 0.06)),
        Paint()..color = const Color(0xFF152036),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          cupRect.deflate(1.5),
          Radius.circular(pw * 0.05),
        ),
        Paint()..color = const Color(0xFFFFFBF4),
      );
    }
  }

  /// Helper to draw a sculpted 3D-shaded teal arm segment + mitten hand
  /// between [shoulder] and [handCenter].
  ///
  /// The mitten (palm highlight, small thumb) points along the forearm unless
  /// [handAngle] overrides it. [thumbSide] picks which side of the forearm the
  /// thumb sits on (`-1` or `1`, in the hand's own frame).
  void _drawArticulatedArm({
    required Canvas canvas,
    required Offset shoulder,
    required Offset elbowControl,
    required Offset handCenter,
    required double armThickness,
    required double pawRadius,
    _MittenShape hand = _MittenShape.grip,
    double? handAngle,
    double thumbSide = -1.0,
  }) {
    final Path shadowPath = Path()
      ..moveTo(shoulder.dx, shoulder.dy + 2)
      ..quadraticBezierTo(
        elbowControl.dx,
        elbowControl.dy + 3,
        handCenter.dx,
        handCenter.dy + 2,
      );
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = const Color(0xFF073630).withValues(alpha: 0.32)
        ..strokeWidth = armThickness
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final Path armPath = Path()
      ..moveTo(shoulder.dx, shoulder.dy)
      ..quadraticBezierTo(
        elbowControl.dx,
        elbowControl.dy,
        handCenter.dx,
        handCenter.dy,
      );
    canvas.drawPath(
      armPath,
      Paint()
        ..color = const Color(0xFF168376)
        ..strokeWidth = armThickness
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    canvas.drawPath(
      armPath,
      Paint()
        ..color = const Color(0xFF38C4B3)
        ..strokeWidth = armThickness * 0.55
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final Offset forearm = handCenter - elbowControl;
    _drawMitten(
      canvas,
      center: handCenter,
      radius: pawRadius,
      angle: handAngle ?? math.atan2(forearm.dy, forearm.dx),
      shape: hand,
      thumbSide: thumbSide,
    );
  }

  /// Mitten hand in its own frame: `+x` runs from the wrist toward the
  /// fingertips, so one rotation orients the whole hand.
  void _drawMitten(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double angle,
    _MittenShape shape = _MittenShape.grip,
    double thumbSide = -1.0,
  }) {
    final double r = radius;
    final double outlineWidth = math.max(1.0, r * 0.13);
    final Paint fill = Paint()..color = const Color(0xFF2CB5A5);
    final Paint outline = Paint()
      ..color = const Color(0xFF0D5950)
      ..strokeWidth = outlineWidth
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final Rect palm = switch (shape) {
      _MittenShape.openPalm => Rect.fromCenter(
        center: Offset(r * 0.30, 0),
        width: r * 2.45,
        height: r * 2.05,
      ),
      _MittenShape.point => Rect.fromCenter(
        center: Offset(r * 0.05, 0),
        width: r * 1.95,
        height: r * 1.75,
      ),
      _MittenShape.grip => Rect.fromCenter(
        center: Offset(r * 0.12, 0),
        width: r * 2.20,
        height: r * 1.85,
      ),
    };

    if (shape == _MittenShape.point) {
      // Extended index finger, drawn first so the mitten overlaps its root.
      final Offset fingerRoot = Offset(r * 0.70, -thumbSide * r * 0.18);
      final Offset fingerTip = Offset(r * 1.85, -thumbSide * r * 0.10);
      canvas.drawLine(
        fingerRoot,
        fingerTip,
        Paint()
          ..color = const Color(0xFF0D5950)
          ..strokeWidth = r * 0.78 + outlineWidth * 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        fingerRoot,
        fingerTip,
        Paint()
          ..color = const Color(0xFF2CB5A5)
          ..strokeWidth = r * 0.78
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawOval(palm, fill);
    // Palm highlight toward the light (top-left of the pebble's rim light).
    canvas.drawOval(
      Rect.fromCenter(
        center: palm.center + Offset(-r * 0.10, -r * 0.28),
        width: palm.width * 0.46,
        height: palm.height * 0.36,
      ),
      Paint()..color = const Color(0xFF4FD1C5).withValues(alpha: 0.72),
    );
    canvas.drawOval(palm, outline);

    // Small thumb on the chosen side; spread wider on an open palm.
    final bool open = shape == _MittenShape.openPalm;
    canvas.save();
    canvas.translate(
      r * (open ? 0.05 : -0.02),
      thumbSide * r * (open ? 1.00 : 0.82),
    );
    canvas.rotate(thumbSide * (open ? 0.95 : 0.55));
    final Rect thumb = Rect.fromCenter(
      center: Offset.zero,
      width: r * 1.00,
      height: r * 0.64,
    );
    canvas.drawOval(thumb, fill);
    canvas.drawOval(thumb, outline);
    canvas.restore();

    canvas.restore();
  }

  /// Relaxed arm hanging along the body side, used by the far arm of one-hand
  /// intent poses so Deni always reads with two arms at standard and hero sizes.
  void _drawRestingArm(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double side,
    double laggedSin,
  ) {
    final Offset shoulder = Offset(
      cx + side * pw * 0.37,
      cy + ph * _shoulderDy,
    );
    final Offset elbow = Offset(cx + side * pw * 0.56, cy + ph * 0.24);
    final Offset hand = Offset(
      cx + side * pw * 0.50,
      cy + ph * 0.38 + laggedSin * 1.2,
    );
    _drawArticulatedArm(
      canvas: canvas,
      shoulder: shoulder,
      elbowControl: elbow,
      handCenter: hand,
      armThickness: pw * 0.115,
      pawRadius: pw * 0.072,
      thumbSide: side,
    );
  }

  /// Angle between [rest] and [target] at the current gesture reach, with a
  /// 6–10% phase-lagged follow-through on the breathing loop.
  double _armAngle(double rest, double target, double laggedSin) {
    return rest + (target - rest) * gestureReach + laggedSin * 0.02;
  }

  /// POINTING (all tiers): the near arm swings up from the body side about the
  /// shoulder and points with an extended finger toward the next step; the far
  /// arm rests (standard and hero only). Points down-and-out so the eye travels
  /// to the content below Deni.
  void _drawPointingScene(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
  ) {
    final bool isCompact = lod == DeniLodTier.compact;
    final double d = _dir;
    if (!isCompact) {
      _drawRestingArm(canvas, cx, cy, pw, ph, -d, laggedSin);
    }

    final Offset shoulder = Offset(cx + d * pw * 0.36, cy + ph * _shoulderDy);
    final double armLength = pw * (isCompact ? 0.30 : 0.46);
    final double a = _armAngle(1.10, 0.62, laggedSin);
    final Offset hand =
        shoulder + Offset(math.cos(a) * d, math.sin(a)) * armLength;
    final Offset elbow =
        shoulder +
        Offset(math.cos(a + 0.35) * d, math.sin(a + 0.35)) * (armLength * 0.55);
    _drawArticulatedArm(
      canvas: canvas,
      shoulder: shoulder,
      elbowControl: elbow,
      handCenter: hand,
      armThickness: pw * (isCompact ? 0.13 : 0.115),
      pawRadius: pw * (isCompact ? 0.085 : 0.072),
      hand: _MittenShape.point,
      thumbSide: -d,
    );
  }

  /// RAISE HAND (all tiers): the near arm lifts an open palm beside the head,
  /// clear of the face, and the palm waves once as the gesture settles. Small
  /// sparkles mark the AI feature; compact keeps a single sparkle.
  void _drawRaiseHandScene(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
  ) {
    final bool isCompact = lod == DeniLodTier.compact;
    final double d = _dir;
    if (!isCompact) {
      _drawRestingArm(canvas, cx, cy, pw, ph, -d, laggedSin);
    }

    final Offset shoulder = Offset(cx + d * pw * 0.38, cy + ph * 0.06);
    final double armLength = pw * (isCompact ? 0.36 : 0.48);
    final double a = _armAngle(1.10, -1.15, laggedSin);
    final Offset hand =
        shoulder + Offset(math.cos(a) * d, math.sin(a)) * armLength;
    final Offset elbow =
        shoulder +
        Offset(math.cos(a + 0.45) * d, math.sin(a + 0.45)) * (armLength * 0.55);

    // One palm wave during the settle beat (pendulum, decaying to rest).
    final double releaseEnd = DeniGesture.releaseEndFraction;
    double wave = 0.0;
    if (gestureProgress > releaseEnd && gestureProgress < 1.0) {
      final double u = (gestureProgress - releaseEnd) / (1.0 - releaseEnd);
      wave = 0.34 * math.sin(u * 2 * math.pi) * (1.0 - u);
    }
    final double forearmAngle = math.atan2(math.sin(a), math.cos(a) * d);

    _drawArticulatedArm(
      canvas: canvas,
      shoulder: shoulder,
      elbowControl: elbow,
      handCenter: hand,
      armThickness: pw * (isCompact ? 0.13 : 0.115),
      pawRadius: pw * (isCompact ? 0.090 : 0.078),
      hand: _MittenShape.openPalm,
      handAngle: forearmAngle + wave * d,
      thumbSide: -d,
    );

    final double sparkleScale = gestureReach.clamp(0.0, 1.15);
    _drawSparkle(
      canvas,
      hand + Offset(d * pw * 0.20, -ph * 0.12),
      pw * (isCompact ? 0.075 : 0.060) * sparkleScale,
      EnpriveColors.apricot,
    );
    if (!isCompact) {
      _drawSparkle(
        canvas,
        hand + Offset(d * pw * 0.27, ph * 0.04),
        pw * 0.040 * sparkleScale,
        isDark ? EnpriveColors.tealDarkAccent : EnpriveColors.teal,
      );
    }
  }

  /// Receipt slip drawn with the crown paper tab's cream gradient and curl, so
  /// the receipt Deni carries reads as the same paper as Deni's signature tab.
  void _drawReceiptSlip(Canvas canvas, Rect rect) {
    final double toothW = rect.width / 5;
    final double toothH = rect.height * 0.07;
    final double corner = rect.width * 0.12;

    final Path slip = Path()
      ..moveTo(rect.left, rect.top + corner)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + corner, rect.top)
      ..lineTo(rect.right - corner * 1.4, rect.top)
      ..lineTo(rect.right, rect.top + corner * 1.4)
      ..lineTo(rect.right, rect.bottom - toothH);
    for (int i = 0; i < 5; i++) {
      final double x1 = rect.right - toothW * (i + 0.5);
      final double x2 = rect.right - toothW * (i + 1);
      slip
        ..lineTo(x1, rect.bottom)
        ..lineTo(x2, rect.bottom - toothH);
    }
    slip.close();

    canvas.drawPath(
      slip.shift(const Offset(0, 2.5)),
      Paint()
        ..color = const Color(0xFF0E4A43).withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      slip,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF9EC), Color(0xFFF9EBD2), Color(0xFFF0D9B5)],
        ).createShader(rect),
    );
    canvas.drawPath(
      slip,
      Paint()
        ..color = const Color(0xFFE3C598)
        ..strokeWidth = math.max(1.0, rect.width * 0.025)
        ..style = PaintingStyle.stroke,
    );

    // Folded corner, the same curl colour as the crown tab.
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - corner * 1.4, rect.top)
        ..lineTo(rect.right - corner * 1.4, rect.top + corner * 1.4)
        ..lineTo(rect.right, rect.top + corner * 1.4)
        ..close(),
      Paint()..color = const Color(0xFFE3C598),
    );

    final double inset = rect.width * 0.16;
    final double lineWidth = math.max(1.2, rect.height * 0.045);
    canvas.drawLine(
      Offset(rect.left + inset, rect.top + rect.height * 0.22),
      Offset(rect.left + rect.width * 0.58, rect.top + rect.height * 0.22),
      Paint()
        ..color = EnpriveColors.tealStrong
        ..strokeWidth = lineWidth * 1.3
        ..strokeCap = StrokeCap.round,
    );
    for (int i = 0; i < 3; i++) {
      final double ly = rect.top + rect.height * (0.42 + i * 0.16);
      canvas.drawLine(
        Offset(rect.left + inset, ly),
        Offset(rect.right - inset - (i == 1 ? rect.width * 0.14 : 0), ly),
        Paint()
          ..color = EnpriveColors.ink.withValues(alpha: 0.26)
          ..strokeWidth = lineWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// CARRY RECEIPT (standard and hero): both hands hold a receipt slip in front
  /// of the lower body, below the mouth, and set it down with one settle. Hero
  /// adds the small stack of saved slips it lands on.
  void _drawCarryReceiptScene(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
  ) {
    // 1.0 while still carrying, 0.0 once placed; the settle overshoot dips
    // slightly below so the slip lands with a small bounce.
    final double carry = 1.0 - gestureReach;
    final double slipH = ph * 0.34;
    final Rect slipRect = Rect.fromCenter(
      center: Offset(cx, cy + ph * (0.33 - 0.06 * carry) + laggedSin * 0.6),
      width: pw * 0.40,
      height: slipH,
    );

    if (lod == DeniLodTier.hero) {
      for (int i = 0; i < 2; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, cy + ph * (0.505 - i * 0.035)),
              width: pw * (0.50 - i * 0.05),
              height: ph * 0.032,
            ),
            Radius.circular(ph * 0.016),
          ),
          Paint()
            ..color = i == 0
                ? const Color(0xFFE3C598)
                : const Color(0xFFF9EBD2),
        );
      }
    }

    _drawReceiptSlip(canvas, slipRect);

    for (final double side in [-1.0, 1.0]) {
      _drawArticulatedArm(
        canvas: canvas,
        shoulder: Offset(cx + side * pw * 0.37, cy + ph * _shoulderDy),
        elbowControl: Offset(cx + side * pw * 0.47, cy + ph * 0.30),
        handCenter: Offset(
          cx + side * slipRect.width * 0.50,
          slipRect.center.dy + ph * 0.03,
        ),
        armThickness: pw * 0.11,
        pawRadius: pw * 0.068,
        thumbSide: side,
      );
    }
  }

  /// HOLD SHIELD (standard and hero, world space): the privacy promise. The
  /// shield rises once into place and then stays perfectly still while only
  /// Deni breathes; arms reach from the breathing shoulders to its edges. The
  /// emblem is a keyhole, never a check mark, because this is a promise about
  /// data staying on the phone, not a verdict about an app.
  void _drawHoldShieldScene(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    Offset Function(Offset) bodyToWorld,
  ) {
    final double shieldW = pw * 0.46;
    final double shieldH = ph * 0.42;
    final Offset c = Offset(
      cx,
      cy + ph * 0.31 + (1.0 - gestureReach) * ph * 0.10,
    );
    final double top = c.dy - shieldH / 2;
    final double bottom = c.dy + shieldH / 2;
    final double left = c.dx - shieldW / 2;
    final double right = c.dx + shieldW / 2;

    final Path shield = Path()
      ..moveTo(c.dx, top)
      ..quadraticBezierTo(
        c.dx + shieldW * 0.25,
        top + shieldH * 0.10,
        right,
        top + shieldH * 0.08,
      )
      ..lineTo(right, top + shieldH * 0.42)
      ..cubicTo(
        right,
        top + shieldH * 0.72,
        c.dx + shieldW * 0.25,
        bottom - shieldH * 0.08,
        c.dx,
        bottom,
      )
      ..cubicTo(
        c.dx - shieldW * 0.25,
        bottom - shieldH * 0.08,
        left,
        top + shieldH * 0.72,
        left,
        top + shieldH * 0.42,
      )
      ..lineTo(left, top + shieldH * 0.08)
      ..quadraticBezierTo(
        c.dx - shieldW * 0.25,
        top + shieldH * 0.10,
        c.dx,
        top,
      )
      ..close();

    final Rect shieldBounds = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawPath(
      shield.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0xFF0E4A43).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      shield,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC9F7EF), Color(0xFF92F4E4), Color(0xFF6FDCCB)],
        ).createShader(shieldBounds),
    );
    canvas.drawPath(
      shield,
      Paint()
        ..color = const Color(0xFF0D5950)
        ..strokeWidth = math.max(1.4, pw * 0.024)
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // Keyhole emblem: private by default.
    final Paint emblem = Paint()..color = const Color(0xFF0D5950);
    final Offset hole = Offset(c.dx, c.dy - shieldH * 0.07);
    canvas.drawCircle(hole, shieldW * 0.105, emblem);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - shieldW * 0.045, hole.dy)
        ..lineTo(c.dx + shieldW * 0.045, hole.dy)
        ..lineTo(c.dx + shieldW * 0.075, c.dy + shieldH * 0.20)
        ..lineTo(c.dx - shieldW * 0.075, c.dy + shieldH * 0.20)
        ..close(),
      emblem,
    );

    for (final double side in [-1.0, 1.0]) {
      final Offset shoulder = bodyToWorld(
        Offset(cx + side * pw * 0.38, cy + ph * 0.08),
      );
      final Offset hand = Offset(
        c.dx + side * shieldW * 0.47,
        c.dy - shieldH * 0.04,
      );
      _drawArticulatedArm(
        canvas: canvas,
        shoulder: shoulder,
        elbowControl: Offset(cx + side * pw * 0.52, cy + ph * 0.26),
        handCenter: hand,
        armThickness: pw * 0.11,
        pawRadius: pw * 0.070,
        thumbSide: side,
      );
    }
  }

  /// PEEK (all tiers, world space): Deni has risen from behind the ledge at
  /// [ledgeY] and rests mitten hands on it; compact rests one hand only. The
  /// hands emerge from behind the ledge as the body rises.
  void _drawPeekLedge(
    Canvas canvas,
    double cx,
    double ledgeY,
    double w,
    double pw,
    double ph,
  ) {
    final bool isCompact = lod == DeniLodTier.compact;
    canvas.drawLine(
      Offset(w * 0.08, ledgeY),
      Offset(w * 0.92, ledgeY),
      Paint()
        ..color = isDark ? const Color(0xFF4C463E) : const Color(0xFFCFC5BB)
        ..strokeWidth = math.max(1.5, ph * 0.025)
        ..strokeCap = StrokeCap.round,
    );

    final double r = pw * (isCompact ? 0.085 : 0.075);
    final double hidden = (0.60 - gestureReach).clamp(0.0, 0.60) / 0.60;
    final double handY = ledgeY - r * 0.30 + hidden * r * 3.0;
    final List<double> sides = isCompact ? [_dir] : [-1.0, 1.0];

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, ledgeY + r * 0.95));
    for (final double side in sides) {
      _drawMitten(
        canvas,
        center: Offset(cx + side * pw * 0.30, handY),
        radius: r,
        // Fingers curl over the ledge toward the viewer.
        angle: math.pi / 2 - side * 0.35,
        thumbSide: side,
      );
    }
    canvas.restore();
  }

  /// THINKING SCENE (LOD 2 & LOD 3):
  /// - Left hand rests thoughtfully below the lower-left cheek (never covering
  ///   mouth or eyes).
  /// - Policy document + magnifier positioned to the right (`cx + pw * 0.58`)
  ///   strictly outside Deni's facial area and within the right safe margin.
  void _drawThinkingScene(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
    double fastSin,
  ) {
    final double scanProgress = math.sin(phase * 2 * math.pi) * 0.5 + 0.5;
    final double sweepX = math.cos(phase * 2 * math.pi) * (pw * 0.028);

    // A. Left Hand: Thoughtful lower-chin rest (kept below mouth Y so face is 100% clear)
    final Offset leftShoulder = Offset(cx - pw * 0.38, cy + ph * 0.16);
    final Offset leftElbow = Offset(cx - pw * 0.44, cy + ph * 0.28);
    final Offset chinHand = Offset(
      cx - pw * 0.18,
      cy + ph * 0.22 + (fastSin * 1.4),
    );
    _drawArticulatedArm(
      canvas: canvas,
      shoulder: leftShoulder,
      elbowControl: leftElbow,
      handCenter: chinHand,
      armThickness: pw * 0.115,
      pawRadius: pw * 0.068,
    );

    // B. Floating Policy Document on the Right (bounded inside w * 0.92)
    final double docScale = lod == DeniLodTier.standard ? 0.92 : 1.0;
    final Rect docRect = Rect.fromCenter(
      center: Offset(cx + pw * 0.60, cy - ph * 0.04),
      width: pw * 0.36 * docScale,
      height: ph * 0.36 * docScale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        docRect.shift(const Offset(0, 3)),
        const Radius.circular(7),
      ),
      Paint()
        ..color = const Color(0xFF0E4A43).withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(docRect, const Radius.circular(7)),
      Paint()..color = const Color(0xFFFFFBF4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(docRect, const Radius.circular(7)),
      Paint()
        ..color = EnpriveColors.teal.withValues(alpha: 0.45)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          docRect.left + 4,
          docRect.top + 4,
          docRect.width * 0.55,
          3.2,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = EnpriveColors.tealStrong,
    );
    for (int i = 0; i < 4; i++) {
      final double ly = docRect.top + docRect.height * (0.30 + i * 0.17);
      canvas.drawLine(
        Offset(docRect.left + 4, ly),
        Offset(docRect.right - (i == 3 ? 8 : 4), ly),
        Paint()
          ..color = EnpriveColors.ink.withValues(alpha: 0.26)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }

    final double scanLineY =
        docRect.top + docRect.height * (0.24 + 0.58 * scanProgress);
    canvas.drawLine(
      Offset(docRect.left + 2, scanLineY),
      Offset(docRect.right - 2, scanLineY),
      Paint()
        ..color = EnpriveColors.teal
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // C. Magnifying Glass Rig + Connected Right Arm (kept to the right of cheek)
    final Offset lensCenter = Offset(
      cx + pw * 0.48 + sweepX,
      scanLineY - ph * 0.01,
    );
    final double lensR = pw * 0.14 * docScale;

    const double handleAngle = 2.32;
    final Offset dir = Offset(math.cos(handleAngle), math.sin(handleAngle));
    final Offset rimPoint = lensCenter + dir * lensR;
    final Offset gripPoint = lensCenter + dir * (lensR * 1.55);
    final Offset handlePommel = lensCenter + dir * (lensR * 1.98);

    final Offset rightShoulder = Offset(cx + pw * 0.32, cy + ph * 0.16);
    final Offset rightElbow = Offset(
      (rightShoulder.dx + gripPoint.dx) * 0.5,
      math.max(rightShoulder.dy, gripPoint.dy) + ph * 0.07,
    );
    _drawArticulatedArm(
      canvas: canvas,
      shoulder: rightShoulder,
      elbowControl: rightElbow,
      handCenter: gripPoint,
      armThickness: pw * 0.115,
      pawRadius: pw * 0.070,
    );

    canvas.drawLine(
      rimPoint,
      lensCenter + dir * (lensR * 1.24),
      Paint()
        ..color = EnpriveColors.apricot
        ..strokeWidth = pw * 0.062
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      lensCenter + dir * (lensR * 1.20),
      handlePommel,
      Paint()
        ..color = const Color(0xFF152036)
        ..strokeWidth = pw * 0.054
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: gripPoint + Offset(-pw * 0.012, -ph * 0.010),
        width: pw * 0.10,
        height: ph * 0.068,
      ),
      Paint()..color = const Color(0xFF39C4B3),
    );

    final Path lensClip = Path()
      ..addOval(Rect.fromCircle(center: lensCenter, radius: lensR));
    canvas.save();
    canvas.clipPath(lensClip);
    canvas.drawCircle(
      lensCenter,
      lensR,
      Paint()..color = const Color(0xFFE6FAF7).withValues(alpha: 0.90),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: lensCenter,
          width: lensR * 1.4,
          height: lensR * 0.40,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = EnpriveColors.apricot.withValues(alpha: 0.38),
    );
    canvas.drawLine(
      Offset(lensCenter.dx - lensR * 0.65, lensCenter.dy),
      Offset(lensCenter.dx + lensR * 0.65, lensCenter.dy),
      Paint()
        ..color = EnpriveColors.tealStrong
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    canvas.drawCircle(
      lensCenter,
      lensR,
      Paint()
        ..color = const Color(0xFF152036)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );
  }

  /// EXPLAINING SCENE (LOD 2 & LOD 3):
  /// - Uses a non-certification Quote Excerpt Board (quotation bar in teal &
  ///   apricot, no green "verified safe" dot).
  /// - Kept strictly outside Deni's facial area and within safe bounds.
  void _drawExplainingScene(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
    double fastSin,
  ) {
    final Offset leftShoulder = Offset(cx - pw * 0.38, cy + ph * 0.14);
    final Offset leftElbow = Offset(cx - pw * 0.46, cy + ph * 0.20);
    final Offset openHand = Offset(
      cx - pw * 0.48,
      cy + ph * 0.06 - (fastSin * 2.0),
    );
    _drawArticulatedArm(
      canvas: canvas,
      shoulder: leftShoulder,
      elbowControl: leftElbow,
      handCenter: openHand,
      armThickness: pw * 0.115,
      pawRadius: pw * 0.068,
    );

    final double boardScale = lod == DeniLodTier.standard ? 0.90 : 1.0;
    final double cardBob = laggedSin * 1.6;
    final Rect boardRect = Rect.fromCenter(
      center: Offset(cx + pw * 0.61, cy - ph * 0.06 + cardBob),
      width: pw * 0.40 * boardScale,
      height: ph * 0.40 * boardScale,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect.shift(const Offset(0, 3.0)),
        const Radius.circular(8),
      ),
      Paint()
        ..color = const Color(0xFF0E4A43).withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFFFFBF4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(8)),
      Paint()
        ..color = EnpriveColors.teal.withValues(alpha: 0.50)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Non-certification Quote Header Banner (Teal + Apricot citation bar)
    final Rect headerRect = Rect.fromLTWH(
      boardRect.left + 4,
      boardRect.top + 4,
      boardRect.width - 8,
      boardRect.height * 0.20,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headerRect, const Radius.circular(4)),
      Paint()..color = EnpriveColors.teal.withValues(alpha: 0.14),
    );
    canvas.drawCircle(
      Offset(headerRect.left + 5.5, headerRect.center.dy),
      2.2,
      Paint()..color = EnpriveColors.apricot,
    );
    canvas.drawLine(
      Offset(headerRect.left + 11, headerRect.center.dy),
      Offset(headerRect.right - 5, headerRect.center.dy),
      Paint()
        ..color = EnpriveColors.tealStrong
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    final double pointerWave = math.sin(phase * 2 * math.pi) * 0.5 + 0.5;
    final double row1Y = boardRect.top + boardRect.height * 0.45;
    final double row2Y = boardRect.top + boardRect.height * 0.72;
    final double activeRowY = row1Y + (row2Y - row1Y) * pointerWave;

    final Rect highlightRect = Rect.fromCenter(
      center: Offset(boardRect.center.dx, activeRowY),
      width: boardRect.width - 8,
      height: boardRect.height * 0.22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlightRect, const Radius.circular(4)),
      Paint()..color = EnpriveColors.apricot.withValues(alpha: 0.36),
    );

    canvas.drawLine(
      Offset(boardRect.left + 6, row1Y),
      Offset(boardRect.right - 6, row1Y),
      Paint()
        ..color = EnpriveColors.ink.withValues(alpha: 0.80)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(boardRect.left + 6, row2Y),
      Offset(boardRect.right - 9, row2Y),
      Paint()
        ..color = EnpriveColors.tealStrong
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    final Offset pointerTip = Offset(boardRect.left + 5, activeRowY);
    final Offset rightShoulder = Offset(cx + pw * 0.33, cy + ph * 0.14);
    final Offset batonGrip = Offset(cx + pw * 0.37, activeRowY + ph * 0.11);
    final Offset rightElbow = Offset(
      cx + pw * 0.34,
      math.max(rightShoulder.dy, batonGrip.dy) + ph * 0.05,
    );

    _drawArticulatedArm(
      canvas: canvas,
      shoulder: rightShoulder,
      elbowControl: rightElbow,
      handCenter: batonGrip,
      armThickness: pw * 0.115,
      pawRadius: pw * 0.068,
    );

    canvas.drawLine(
      batonGrip,
      pointerTip,
      Paint()
        ..color = const Color(0xFF152036)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(pointerTip, 2.4, Paint()..color = EnpriveColors.apricot);
  }

  /// LISTENING SCENE (LOD 2 & LOD 3)
  void _drawListeningScene(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
    double fastSin,
  ) {
    final Offset leftCup = Offset(cx - pw * 0.50, cy - ph * 0.04);
    final Offset rightCup = Offset(cx + pw * 0.50, cy - ph * 0.04);

    final Path bandPath = Path()
      ..moveTo(leftCup.dx, leftCup.dy)
      ..cubicTo(
        cx - pw * 0.48,
        cy - ph * 0.62,
        cx + pw * 0.48,
        cy - ph * 0.62,
        rightCup.dx,
        rightCup.dy,
      );
    canvas.drawPath(
      bandPath,
      Paint()
        ..color = const Color(0xFF152036)
        ..strokeWidth = pw * 0.046
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    for (final cupCenter in [leftCup, rightCup]) {
      final Rect cupRect = Rect.fromCenter(
        center: cupCenter,
        width: pw * 0.15,
        height: ph * 0.25,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cupRect, Radius.circular(pw * 0.07)),
        Paint()..color = const Color(0xFF152036),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          cupRect.deflate(2.0),
          Radius.circular(pw * 0.06),
        ),
        Paint()..color = const Color(0xFFFFFBF4),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          cupRect.deflate(2.0),
          Radius.circular(pw * 0.06),
        ),
        Paint()
          ..color = EnpriveColors.teal
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }

    final Offset rightShoulder = Offset(cx + pw * 0.34, cy + ph * 0.16);
    final Offset rightElbow = Offset(cx + pw * 0.52, cy + ph * 0.14);
    final Offset cupGrip = Offset(
      rightCup.dx - pw * 0.01,
      rightCup.dy + ph * 0.06,
    );
    _drawArticulatedArm(
      canvas: canvas,
      shoulder: rightShoulder,
      elbowControl: rightElbow,
      handCenter: cupGrip,
      armThickness: pw * 0.115,
      pawRadius: pw * 0.070,
    );

    final Offset leftShoulder = Offset(cx - pw * 0.34, cy + ph * 0.16);
    final Offset leftElbow = Offset(cx - pw * 0.44, cy + ph * 0.24);
    final Offset leftHand = Offset(
      cx - pw * 0.36,
      cy + ph * 0.20 + laggedSin * 1.5,
    );
    _drawArticulatedArm(
      canvas: canvas,
      shoulder: leftShoulder,
      elbowControl: leftElbow,
      handCenter: leftHand,
      armThickness: pw * 0.110,
      pawRadius: pw * 0.066,
    );
  }

  void _drawSupportShoulders(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
  ) {
    final shoulderPaint = Paint()..color = const Color(0xFF14776C);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - pw * 0.47, cy + ph * 0.12),
        width: pw * 0.15,
        height: ph * 0.24,
      ),
      shoulderPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + pw * 0.47, cy + ph * 0.12),
        width: pw * 0.15,
        height: ph * 0.24,
      ),
      shoulderPaint,
    );
  }

  void _drawSupportClaspedHands(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
  ) {
    final double handY = cy + ph * 0.23 + (laggedSin * 1.4);
    final double claspPulse = math.sin(phase * 4 * math.pi) * (pw * 0.012);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, handY + ph * 0.04),
        width: pw * 0.46,
        height: ph * 0.14,
      ),
      Paint()
        ..color = const Color(0xFF083A34).withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.save();
    canvas.translate(cx - pw * 0.11 + claspPulse, handY);
    canvas.rotate(0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: pw * 0.25,
          height: ph * 0.135,
        ),
        Radius.circular(pw * 0.08),
      ),
      Paint()
        ..shader =
            const LinearGradient(colors: [Color(0xFF33B9A9), Color(0xFF167C70)])
                .createShader(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: pw * 0.25,
                    height: ph * 0.135,
                  ),
                ),
    );
    canvas.restore();

    canvas.save();
    canvas.translate(cx + pw * 0.11 - claspPulse, handY);
    canvas.rotate(-0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: pw * 0.25,
          height: ph * 0.135,
        ),
        Radius.circular(pw * 0.08),
      ),
      Paint()
        ..shader =
            const LinearGradient(colors: [Color(0xFF28A798), Color(0xFF126E63)])
                .createShader(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: pw * 0.25,
                    height: ph * 0.135,
                  ),
                ),
    );
    canvas.restore();
  }

  void _drawSculptedPaperTab(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
    double jumpHeightRatio,
  ) {
    final bool isCompact = lod == DeniLodTier.compact;
    final double tabW = pw * (isCompact ? 0.37 : 0.34);
    final double tabH = ph * (isCompact ? 0.26 : 0.24);
    final double crownY = cy - ph * 0.46;

    canvas.save();
    canvas.translate(
      cx - pw * 0.01,
      crownY - (laggedSin * 1.4) - (jumpHeightRatio * 5.0),
    );
    canvas.rotate(-0.04 + (laggedSin * 0.045));

    final Path shadowPath = Path()
      ..moveTo(-tabW * 0.52, tabH * 0.36)
      ..quadraticBezierTo(0, tabH * 0.48, tabW * 0.48, tabH * 0.28)
      ..lineTo(tabW * 0.38, tabH * 0.05)
      ..lineTo(-tabW * 0.42, tabH * 0.12)
      ..close();
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = const Color(0xFF09423B).withValues(alpha: 0.26)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final Path backFlap = Path()
      ..moveTo(tabW * 0.32, -tabH * 0.52)
      ..lineTo(tabW * 0.52, tabH * 0.06)
      ..lineTo(tabW * 0.18, tabH * 0.12)
      ..close();
    canvas.drawPath(backFlap, Paint()..color = const Color(0xFFE5CFAF));

    final Path frontSlip = Path()
      ..moveTo(-tabW * 0.32, -tabH * 0.48)
      ..quadraticBezierTo(
        -tabW * 0.28,
        -tabH * 0.56,
        -tabW * 0.16,
        -tabH * 0.55,
      )
      ..lineTo(tabW * 0.32, -tabH * 0.52)
      ..lineTo(tabW * 0.24, tabH * 0.16)
      ..quadraticBezierTo(tabW * 0.12, tabH * 0.36, -tabW * 0.02, tabH * 0.36)
      ..lineTo(-tabW * 0.44, tabH * 0.34)
      ..quadraticBezierTo(-tabW * 0.50, tabH * 0.32, -tabW * 0.46, tabH * 0.20)
      ..close();

    canvas.drawPath(
      frontSlip,
      Paint()
        ..shader =
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF9EC), Color(0xFFF9EBD2), Color(0xFFF0D9B5)],
            ).createShader(
              Rect.fromCenter(center: Offset.zero, width: tabW, height: tabH),
            ),
    );

    final Path curlFlap = Path()
      ..moveTo(tabW * 0.24, tabH * 0.16)
      ..quadraticBezierTo(tabW * 0.04, tabH * 0.14, 0.0, tabH * 0.36)
      ..quadraticBezierTo(tabW * 0.16, tabH * 0.34, tabW * 0.24, tabH * 0.16)
      ..close();
    canvas.drawPath(curlFlap, Paint()..color = const Color(0xFFE3C598));

    canvas.restore();
  }

  void _drawFace(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double fastSin,
  ) {
    final bool isCompact = lod == DeniLodTier.compact;
    final double eyeY = cy - ph * 0.05;
    final double eyeSpacing = pw * 0.24;
    final double leftEyeX = cx - eyeSpacing;
    final double rightEyeX = cx + eyeSpacing;
    final double eyeRadius = pw * (isCompact ? 0.078 : 0.072);

    // 1. Soft Blurred Apricot Cheeks
    final Paint blushPaint = Paint()
      ..color = EnpriveColors.apricot.withValues(alpha: 0.58)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(leftEyeX - eyeRadius * 0.65, eyeY + eyeRadius * 1.45),
        width: eyeRadius * 2.2,
        height: eyeRadius * 1.30,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rightEyeX + eyeRadius * 0.65, eyeY + eyeRadius * 1.45),
        width: eyeRadius * 2.2,
        height: eyeRadius * 1.30,
      ),
      blushPaint,
    );

    final Paint inkPaint = Paint()
      ..color = const Color(0xFF152036)
      ..style = PaintingStyle.fill;

    // 2. Expressive Eyes with Active Reading / Scanning Saccades
    if (pose == DeniPose.celebrating || blink > 0.82) {
      final Paint arcPaint = Paint()
        ..color = const Color(0xFF152036)
        ..strokeWidth = pw * (isCompact ? 0.040 : 0.034)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (final ex in [leftEyeX, rightEyeX]) {
        final Path happyArc = Path()
          ..moveTo(ex - eyeRadius * 0.85, eyeY + eyeRadius * 0.2)
          ..quadraticBezierTo(
            ex,
            eyeY - eyeRadius * 0.85,
            ex + eyeRadius * 0.85,
            eyeY + eyeRadius * 0.2,
          );
        canvas.drawPath(happyArc, arcPaint);
      }
    } else {
      final double openScaleY = (1.0 - blink).clamp(0.12, 1.0);

      for (final ex in [leftEyeX, rightEyeX]) {
        canvas.save();
        canvas.translate(ex, eyeY);
        canvas.scale(1.0, openScaleY);

        if (pose == DeniPose.thinking) {
          final double scanX =
              eyeRadius * 0.22 +
              math.sin(phase * 4 * math.pi) * (eyeRadius * 0.18);
          final double scanY =
              math.sin(phase * 2 * math.pi) * (eyeRadius * 0.20);
          canvas.drawCircle(
            Offset.zero,
            eyeRadius * 1.06,
            Paint()..color = const Color(0xFFFFFBF4),
          );
          canvas.drawCircle(Offset(scanX, scanY), eyeRadius * 0.76, inkPaint);
          canvas.drawCircle(
            Offset(scanX - eyeRadius * 0.22, scanY - eyeRadius * 0.22),
            eyeRadius * 0.25,
            Paint()..color = Colors.white,
          );
        } else if (pose == DeniPose.listening) {
          final double nodY =
              math.sin(phase * 4 * math.pi) * (eyeRadius * 0.14);
          canvas.drawCircle(
            Offset.zero,
            eyeRadius * 1.05,
            Paint()..color = const Color(0xFFFFFBF4),
          );
          canvas.drawCircle(
            Offset(eyeRadius * 0.16, nodY),
            eyeRadius * 0.80,
            inkPaint,
          );
          canvas.drawCircle(
            Offset(-eyeRadius * 0.05, nodY - eyeRadius * 0.26),
            eyeRadius * 0.26,
            Paint()..color = Colors.white,
          );
        } else {
          // Intent poses look toward what the hand is doing.
          final Offset gaze = _gazeTarget * eyeRadius;
          final double glanceX = pose.hasIntentGesture
              ? gaze.dx
              : pose == DeniPose.explaining
              ? eyeRadius * 0.22
              : math.sin(phase * 2 * math.pi) * (eyeRadius * 0.08);
          final double glanceY = pose.hasIntentGesture ? gaze.dy : 0.0;
          canvas.drawCircle(Offset(glanceX, glanceY), eyeRadius, inkPaint);
          canvas.drawCircle(
            Offset(glanceX - eyeRadius * 0.32, glanceY - eyeRadius * 0.30),
            eyeRadius * 0.32,
            Paint()..color = Colors.white,
          );
        }
        canvas.restore();
      }
    }

    // 3. Pose-Specific Mouth with Multi-Syllable Articulation
    final double mouthY = eyeY + eyeRadius * 1.35;
    final Paint mouthStroke = Paint()
      ..color = const Color(0xFF152036)
      ..strokeWidth = pw * (isCompact ? 0.038 : 0.032)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (pose) {
      case DeniPose.thinking:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx + pw * 0.02, mouthY + ph * 0.015),
            width: pw * 0.062,
            height: ph * 0.045,
          ),
          inkPaint,
        );

      case DeniPose.explaining:
        final double talkOpen = (math.sin(phase * 6 * math.pi) * 0.5 + 0.5)
            .clamp(0.18, 1.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, mouthY + ph * 0.012),
              width: pw * (0.088 + 0.025 * talkOpen),
              height: ph * (0.032 + 0.048 * talkOpen),
            ),
            const Radius.circular(8),
          ),
          inkPaint,
        );

      case DeniPose.listening:
        final Path happyListen = Path()
          ..moveTo(cx - pw * 0.062, mouthY)
          ..quadraticBezierTo(cx, mouthY + ph * 0.048, cx + pw * 0.062, mouthY);
        canvas.drawPath(happyListen, mouthStroke);

      default:
        final Path smile = Path()
          ..moveTo(cx - pw * 0.068, mouthY - ph * 0.005)
          ..quadraticBezierTo(
            cx,
            mouthY + ph * 0.054,
            cx + pw * 0.068,
            mouthY - ph * 0.005,
          );
        canvas.drawPath(smile, mouthStroke);
    }
  }

  /// Story-driven external cues & sparkles scaled by [lod] so small avatars
  /// (`LOD 1: 48–64dp`) remain clean and unobstructed while `LOD 2` & `LOD 3`
  /// gain progressive richness.
  void _drawExternalBadges(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double phase,
    double fastSin,
  ) {
    final bool isCompact = lod == DeniLodTier.compact;
    final bool isHero = lod == DeniLodTier.hero;

    switch (pose) {
      case DeniPose.thinking:
        final List<(double dx, double dy, double r, double offset)> bubbles =
            isCompact
            ? [
                (pw * 0.42, -ph * 0.38, pw * 0.032, 0.0),
                (pw * 0.52, -ph * 0.48, pw * 0.046, 0.35),
              ]
            : [
                (pw * 0.30, -ph * 0.42, pw * 0.024, 0.0),
                (pw * 0.42, -ph * 0.52, pw * 0.034, 0.33),
                (pw * 0.54, -ph * 0.60, pw * 0.045, 0.66),
              ];
        for (final b in bubbles) {
          final double anim = math.sin((phase + b.$4) * 2 * math.pi);
          canvas.drawCircle(
            Offset(cx + b.$1, cy + b.$2 + anim * 2.0),
            b.$3,
            Paint()
              ..color =
                  (isDark ? EnpriveColors.tealDarkAccent : EnpriveColors.teal)
                      .withValues(
                        alpha: (0.65 + 0.30 * anim).clamp(0.30, 0.95),
                      ),
          );
        }

      case DeniPose.explaining:
        // In LOD 1 (compact) and LOD 3 (hero), show a clean top-left speech pill
        // outside the head silhouette; in LOD 2 (standard), the right-side quote
        // board is the single focal prop so the canvas never feels crowded.
        if (isCompact || isHero) {
          final double bubbleBob = fastSin * (isCompact ? 1.2 : 2.0);
          final Rect speechRect = Rect.fromCenter(
            center: Offset(
              cx - pw * (isCompact ? 0.44 : 0.45),
              cy - ph * (isCompact ? 0.38 : 0.36) + bubbleBob,
            ),
            width: pw * (isCompact ? 0.24 : 0.27),
            height: ph * (isCompact ? 0.16 : 0.18),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(speechRect, const Radius.circular(7)),
            Paint()..color = const Color(0xFFFFFBF4),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(speechRect, const Radius.circular(7)),
            Paint()
              ..color = EnpriveColors.teal
              ..strokeWidth = 1.4
              ..style = PaintingStyle.stroke,
          );
          for (int i = 0; i < 2; i++) {
            final double barY =
                speechRect.top + speechRect.height * (0.36 + i * 0.28);
            canvas.drawLine(
              Offset(speechRect.left + 4, barY),
              Offset(speechRect.right - (i == 1 ? 6 : 4), barY),
              Paint()
                ..color = i == 0
                    ? EnpriveColors.tealStrong
                    : EnpriveColors.apricot
                ..strokeWidth = 1.8
                ..strokeCap = StrokeCap.round,
            );
          }
        }

      case DeniPose.listening:
        // In Hero LOD (116dp+), show the full 5-bar voice waveform card on top-left
        if (isHero) {
          final Rect waveCard = Rect.fromCenter(
            center: Offset(cx - pw * 0.42, cy - ph * 0.36 + fastSin * 1.5),
            width: pw * 0.36,
            height: ph * 0.21,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(waveCard, const Radius.circular(9)),
            Paint()..color = const Color(0xFFFFFBF4),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(waveCard, const Radius.circular(9)),
            Paint()
              ..color = EnpriveColors.teal.withValues(alpha: 0.48)
              ..strokeWidth = 1.4
              ..style = PaintingStyle.stroke,
          );
          for (int b = 0; b < 5; b++) {
            final double pulse =
                math.sin((phase * 6 * math.pi) + b * 0.95) * 0.5 + 0.5;
            final double barH = waveCard.height * (0.24 + 0.50 * pulse);
            final double bx =
                waveCard.left + waveCard.width * (0.20 + b * 0.15);
            canvas.drawLine(
              Offset(bx, waveCard.center.dy + barH * 0.5),
              Offset(bx, waveCard.center.dy - barH * 0.5),
              Paint()
                ..color = b.isEven
                    ? EnpriveColors.tealStrong
                    : EnpriveColors.apricot
                ..strokeWidth = 2.2
                ..strokeCap = StrokeCap.round,
            );
          }
        }

        // Acoustic wave arcs radiating near Deni's right earcup (all LODs)
        final int arcCount = isCompact ? 2 : 3;
        for (int i = 0; i < arcCount; i++) {
          final double pulse =
              math.sin((phase * 4 * math.pi) - (i * 0.65)) * 0.5 + 0.5;
          final double radius = pw * (0.13 + i * 0.068);
          canvas.drawArc(
            Rect.fromCircle(
              center: Offset(cx + pw * 0.48, cy - ph * 0.04),
              radius: radius,
            ),
            -0.65,
            1.30,
            false,
            Paint()
              ..color =
                  (isDark ? EnpriveColors.tealDarkAccent : EnpriveColors.teal)
                      .withValues(alpha: 0.28 + 0.55 * pulse)
              ..strokeWidth = isCompact ? 1.8 : 2.2
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke,
          );
        }

      case DeniPose.support:
        final double badgeBob = math.sin(phase * 2 * math.pi) * 2.2;
        final Offset badgeCenter = Offset(
          cx + pw * (isCompact ? 0.46 : 0.50),
          cy - ph * 0.24 + badgeBob,
        );
        final double br = pw * (isCompact ? 0.115 : 0.105);

        canvas.drawCircle(
          badgeCenter,
          br,
          Paint()..color = const Color(0xFFFFFBF4),
        );
        canvas.drawCircle(
          badgeCenter,
          br,
          Paint()
            ..color = EnpriveColors.apricot.withValues(alpha: 0.85)
            ..strokeWidth = 1.6
            ..style = PaintingStyle.stroke,
        );
        final Path qArc = Path()
          ..moveTo(badgeCenter.dx - br * 0.26, badgeCenter.dy - br * 0.20)
          ..quadraticBezierTo(
            badgeCenter.dx,
            badgeCenter.dy - br * 0.58,
            badgeCenter.dx + br * 0.26,
            badgeCenter.dy - br * 0.18,
          )
          ..quadraticBezierTo(
            badgeCenter.dx + br * 0.26,
            badgeCenter.dy,
            badgeCenter.dx,
            badgeCenter.dy + br * 0.12,
          );
        canvas.drawPath(
          qArc,
          Paint()
            ..color = EnpriveColors.ink
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
        canvas.drawCircle(
          Offset(badgeCenter.dx, badgeCenter.dy + br * 0.40),
          1.3,
          Paint()..color = EnpriveColors.ink,
        );

      case DeniPose.celebrating:
        _drawSparkle(
          canvas,
          Offset(cx + pw * 0.46, cy - ph * 0.34),
          pw * 0.076 * (0.75 + 0.25 * fastSin),
          const Color(0xFFE6B450),
        );
        if (!isCompact) {
          _drawSparkle(
            canvas,
            Offset(cx + pw * 0.55, cy - ph * 0.18),
            pw * 0.048 * (0.75 - 0.25 * fastSin),
            EnpriveColors.apricot,
          );
        }
        _drawSparkle(
          canvas,
          Offset(cx - pw * 0.46, cy - ph * 0.28),
          pw * 0.056 * (0.75 - 0.25 * fastSin),
          isDark ? EnpriveColors.tealDarkAccent : EnpriveColors.teal,
        );

      case DeniPose.idle:
      case DeniPose.pointing:
      case DeniPose.raiseHand:
      case DeniPose.holdShield:
      case DeniPose.carryReceipt:
      case DeniPose.peek:
        break;
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final Path path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _DeniRiggedActionPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.blink != blink ||
        oldDelegate.springT != springT ||
        oldDelegate.gestureReach != gestureReach ||
        oldDelegate.gestureCrouch != gestureCrouch ||
        oldDelegate.gestureProgress != gestureProgress ||
        oldDelegate.pose != pose ||
        oldDelegate.lod != lod ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isRtl != isRtl ||
        oldDelegate.showAmbientGlow != showAmbientGlow;
  }
}

/// Mitten hand shapes for [_DeniRiggedActionPainter._drawMitten].
enum _MittenShape {
  /// Closed mitten holding a prop or resting.
  grip,

  /// Mitten with the index finger extended.
  point,

  /// Open palm with the thumb spread.
  openPalm,
}
