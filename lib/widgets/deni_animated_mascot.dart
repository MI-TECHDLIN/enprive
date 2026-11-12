import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/enprive_colors.dart';

enum DeniPose {
  idle,
  thinking,
  explaining,
  listening,
  support,
  celebrating,
}

/// Interactive sculpted vector mascot for Deni (Concept C: The Protective Pebble).
/// Built on the `svg-mascot-animator` rigging & physics specification:
/// - Grounded bottom-centre pivot so squash/stretch never drags through the floor
/// - Area-interpolated deformation: `sx = pow(sy, -0.55)` (`squash(sy, preserve=0.55)`)
/// - Damped spring step response (`ζ = 0.32, fₙ = 6.0 Hz`) on tap and pose transitions
/// - 8% phase-lagged secondary follow-through on the folded cream paper slip
/// - Height-coupled contact shadow (`shadowTrack`)
/// - Story-driven action choreography across all 6 product states
class DeniAnimatedMascot extends StatefulWidget {
  final double size;
  final DeniPose pose;
  final VoidCallback? onTap;
  final bool showAmbientGlow;

  const DeniAnimatedMascot({
    super.key,
    this.size = 96.0,
    this.pose = DeniPose.idle,
    this.onTap,
    this.showAmbientGlow = true,
  });

  @override
  State<DeniAnimatedMascot> createState() => _DeniAnimatedMascotState();
}

class _DeniAnimatedMascotState extends State<DeniAnimatedMascot>
    with TickerProviderStateMixin {
  late final AnimationController _loopController;
  late final AnimationController _blinkController;
  late final AnimationController _springController;
  final math.Random _random = math.Random();
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    // 3.6s master loop (within the 3.0–6.0s optimal window from physics.md)
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

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
  }

  @override
  void didUpdateWidget(covariant DeniAnimatedMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pose != widget.pose) {
      // Trigger damped spring settle whenever pose changes (Status Confirmation)
      _springController.forward(from: 0.0);
    }
  }

  void _scheduleNextBlink() {
    if (!mounted) return;
    final delay = Duration(milliseconds: 2500 + _random.nextInt(2000));
    _blinkTimer?.cancel();
    _blinkTimer = Timer(delay, () async {
      if (!mounted) return;
      await _blinkController.forward();
      if (!mounted) return;
      await _blinkController.reverse();
      _scheduleNextBlink();
    });
  }

  void _handleTap() {
    _springController.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _loopController.dispose();
    _blinkController.dispose();
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: 'Deni, your privacy guide (${widget.pose.name} state)',
      button: widget.onTap != null,
      image: true,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: widget.size * 1.28,
          height: widget.size * 1.22,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _loopController,
              _blinkController,
              _springController,
            ]),
            builder: (context, _) {
              // When reduced motion is requested, pick the expressive keyframe (0.35)
              // that carries the story clearly (per rigging.md Reduced-motion poses).
              final double phase = reduceMotion ? 0.35 : _loopController.value;
              final double blink = reduceMotion ? 0.0 : _blinkController.value;
              final double springT =
                  reduceMotion ? 0.0 : _springController.value;

              return CustomPaint(
                painter: _DeniRiggedActionPainter(
                  phase: phase,
                  blink: blink,
                  springT: springT,
                  pose: widget.pose,
                  showAmbientGlow: widget.showAmbientGlow,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeniRiggedActionPainter extends CustomPainter {
  final double phase;
  final double blink;
  final double springT;
  final DeniPose pose;
  final bool showAmbientGlow;

  _DeniRiggedActionPainter({
    required this.phase,
    required this.blink,
    required this.springT,
    required this.pose,
    required this.showAmbientGlow,
  });

  /// Area-interpolated squash/stretch from `svg-mascot-animator/references/physics.md`:
  /// `preserve = 0.55` keeps the solid ceramic pebble silhouette without melting.
  static double _squashX(double sy, {double preserve = 0.55}) {
    return math.pow(sy.clamp(0.68, 1.25), -preserve).toDouble();
  }

  /// Damped spring step response from `physics.md`:
  /// `ζ = 0.32` (lively), `fₙ = 6.0 Hz` (grounded pebble mass).
  static double _dampedSpringDeviation(double t) {
    if (t <= 0.0 || t >= 1.0) return 0.0;
    const double zeta = 0.32;
    const double fn = 5.5;
    final double wn = 2 * math.pi * fn;
    final double wd = wn * math.sqrt(1.0 - zeta * zeta);
    final double decay = math.exp(-zeta * wn * (t * 0.45));
    return -0.18 *
        decay *
        math.sin(wd * (t * 0.45));
  }

  /// Computes ballistic hop + crouch + landing squash for `celebrating`,
  /// or harmonic grounded breathing for other poses.
  (double jumpHeightRatio, double sy, double bodyTiltRad) _computeKinematics() {
    final double springDelta = _dampedSpringDeviation(springT);

    if (pose == DeniPose.celebrating) {
      // Full ballistic hop cycle across phase [0..1]:
      // [0.00..0.14]: Anticipation crouch (sy -> 0.84)
      // [0.14..0.54]: Parabolic flight y = 4*h*u*(1-u), velocity stretch/neutral
      // [0.54..0.66]: Contact landing squash (sy -> 0.80)
      // [0.66..1.00]: Damped settle & happy sway
      if (phase < 0.14) {
        final double u = phase / 0.14;
        final double crouch = math.sin(u * math.pi * 0.5);
        return (0.0, (1.0 - 0.15 * crouch) + springDelta, 0.0);
      } else if (phase < 0.54) {
        final double u = (phase - 0.14) / 0.40;
        // Parabolic gravity curve: apex at u = 0.5
        final double jumpH = 4.0 * 0.13 * u * (1.0 - u);
        // Velocity is derivative: highest at launch (u=0) and impact (u=1), zero at apex (u=0.5)
        final double velMag = (1.0 - 2.0 * u).abs();
        final double stretchY = 1.0 + 0.12 * velMag;
        final double airTilt = math.sin(u * math.pi) * 0.04;
        return (jumpH, stretchY + springDelta, airTilt);
      } else if (phase < 0.66) {
        final double u = (phase - 0.54) / 0.12;
        final double impact = math.sin(u * math.pi);
        return (0.0, (1.0 - 0.18 * impact) + springDelta, 0.0);
      } else {
        final double u = (phase - 0.66) / 0.34;
        final double settle =
            math.exp(-4.5 * u) * math.sin(u * math.pi * 3.0) * 0.06;
        final double happySway = math.sin(u * math.pi * 2.0) * 0.035;
        return (0.0, 1.0 + settle + springDelta, happySway);
      }
    }

    // Harmonic breathing cycle (2.5% amplitude per physics.md)
    final double breatheSin = math.sin(phase * 2 * math.pi);
    final double sy = 1.0 + (breatheSin * 0.024) + springDelta;
    final double lift = (breatheSin * 0.5 + 0.5) * 0.022;

    final double tilt = switch (pose) {
      // Rhythmic listening nod
      DeniPose.listening =>
        -0.055 + math.sin(phase * 4 * math.pi) * 0.030,
      // Empathetic gentle rock
      DeniPose.support =>
        math.sin(phase * 2 * math.pi) * 0.040,
      // Curious scanning tilt
      DeniPose.thinking =>
        0.025 + math.sin(phase * 2 * math.pi) * 0.020,
      // Engaged teacher lean
      DeniPose.explaining =>
        0.020 + math.sin(phase * 2 * math.pi) * 0.015,
      DeniPose.idle =>
        math.sin(phase * 2 * math.pi) * 0.015,
      DeniPose.celebrating => 0.0,
    };

    return (lift, sy, tilt);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w * 0.47; // Slightly left of centre so right-side action props have room
    final double groundY = h * 0.89;

    final double pw = w * 0.60;
    final double ph = h * 0.65;

    final (double jumpHeightRatio, double sy, double bodyTilt) =
        _computeKinematics();
    final double sx = _squashX(sy);
    final double elevationPx = jumpHeightRatio * h;

    // Secondary motion with 8% phase lag (`physics.md` Lag and follow-through)
    final double laggedPhase = (phase - 0.08) % 1.0;
    final double laggedSin = math.sin(laggedPhase * 2 * math.pi);
    final double fastSin = math.sin(phase * 4 * math.pi);

    // 1. Subtle Ambient Glow behind Deni
    if (showAmbientGlow) {
      final Offset glowCenter = Offset(cx, groundY - ph * 0.5 - elevationPx);
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            EnpriveColors.teal.withValues(alpha: 0.15),
            EnpriveColors.apricot.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(
          Rect.fromCircle(center: glowCenter, radius: w * 0.46),
        );
      canvas.drawCircle(glowCenter, w * 0.46, glowPaint);
    }

    // 2. Contact Shadow Coupled Directly to Height (`shadow_track` from physics.md)
    // Shrinks in radius (1.0 -> 0.52) and fades in opacity (0.18 -> 0.07) as height increases
    final double heightFactor = (jumpHeightRatio / 0.14).clamp(0.0, 1.0);
    final double shadowScale = (1.0 - 0.42 * heightFactor) * (sx * 0.95);
    final double shadowAlpha = (0.17 - 0.09 * heightFactor).clamp(0.05, 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, groundY),
        width: pw * 0.84 * shadowScale,
        height: ph * 0.11 * shadowScale,
      ),
      Paint()
        ..color = const Color(0xFF0E4A43).withValues(alpha: shadowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 3. Celebrating Landing Ripple / Debris Ring (`physics.md` Impact debris)
    if (pose == DeniPose.celebrating && phase >= 0.52 && phase <= 0.86) {
      final double ringU = ((phase - 0.52) / 0.34).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, groundY),
          width: pw * (0.65 + 0.65 * ringU),
          height: ph * (0.09 + 0.09 * ringU),
        ),
        Paint()
          ..color =
              EnpriveColors.teal.withValues(alpha: (1.0 - ringU) * 0.35)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
    }

    // 4. Rigged Group Hierarchy (`rigging.md`: One concern per transform)
    // Outer translate to grounded bottom-centre pivot -> elevation -> rotation -> scale(sx, sy)
    final double bodyCenterY = groundY - (ph * 0.50);
    canvas.save();
    // Vertical flight / breathing offset
    canvas.translate(0, -elevationPx);
    // Grounded bottom-centre pivot (`(cx, groundY)`) for squash & stretch
    canvas.translate(cx, groundY);
    canvas.scale(sx, sy);
    canvas.translate(-cx, -groundY);
    // Body centre pivot for rotation
    canvas.translate(cx, bodyCenterY);
    canvas.rotate(bodyTilt);
    canvas.translate(-cx, -bodyCenterY);

    // 5. Back Flipper Arms
    if (pose != DeniPose.support) {
      _drawLeftFlipper(canvas, cx, bodyCenterY, pw, ph, laggedSin, fastSin);
      _drawRightFlipper(canvas, cx, bodyCenterY, pw, ph, laggedSin, fastSin);
    } else {
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

    // 9. Foreground Clasped Hands for `support` or Magnifier Lens for `thinking`
    if (pose == DeniPose.support) {
      _drawSupportClaspedHands(canvas, cx, bodyCenterY, pw, ph, laggedSin);
    } else if (pose == DeniPose.thinking) {
      _drawThinkingMagnifier(canvas, cx, bodyCenterY, pw, ph, laggedSin);
    }

    canvas.restore();

    // 10. Story-Driven External Support Props (visually separate per `SKILL.md` Rule 10)
    _drawActionProps(
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
      ..cubicTo(
        right,
        cy + ph * 0.30,
        cx + pw * 0.32,
        bottom,
        cx,
        bottom,
      )
      ..cubicTo(
        cx - pw * 0.32,
        bottom,
        left,
        cy + ph * 0.30,
        left,
        cy - ph * 0.02,
      )
      ..cubicTo(
        left,
        cy - ph * 0.32,
        cx - pw * 0.34,
        top,
        cx,
        top,
      )
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

    final double angle = switch (pose) {
      DeniPose.celebrating => 0.72 + fastSin * 0.22, // Cheering left flipper raised!
      DeniPose.listening => 0.30 + laggedSin * 0.08,
      _ => 0.22 + laggedSin * 0.05,
    };
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

    switch (pose) {
      case DeniPose.idle:
        // Sinusoidal pendulum wave (`physics.md` Oscillation)
        canvas.rotate(-0.82 + fastSin * 0.20);
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

      case DeniPose.explaining:
        // Active teacher gesture tracking up and down the 2 lines on the evidence card
        final double lineTrack = math.sin(phase * 2 * math.pi) * 0.16;
        canvas.rotate(-0.68 + lineTrack);
        final Rect pointArm = Rect.fromCenter(
          center: Offset(pw * 0.08, -ph * 0.07),
          width: pw * 0.18,
          height: ph * 0.31,
        );
        canvas.drawOval(
          pointArm,
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFF33B9A9), Color(0xFF116B60)],
            ).createShader(pointArm),
        );

      case DeniPose.celebrating:
        // High cheering right flipper
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

      default:
        canvas.rotate(-0.22 - laggedSin * 0.05);
        final Rect restArm = Rect.fromCenter(
          center: Offset(pw * 0.05, ph * 0.12),
          width: pw * 0.19,
          height: ph * 0.32,
        );
        canvas.drawOval(
          restArm,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF219688), Color(0xFF0C5249)],
            ).createShader(restArm),
        );
    }
    canvas.restore();
  }

  /// Draws a cute translucent magnifying glass held by Deni during `thinking`
  /// as Deni inspects policy clauses on-device.
  void _drawThinkingMagnifier(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double laggedSin,
  ) {
    final double lensX = cx + pw * 0.36;
    final double lensY = cy - ph * 0.02 + (laggedSin * 3.0);
    final double lensR = pw * 0.13;

    // Handle
    canvas.drawLine(
      Offset(lensX - lensR * 0.65, lensY + lensR * 0.65),
      Offset(lensX - lensR * 1.35, lensY + lensR * 1.45),
      Paint()
        ..color = const Color(0xFF152036)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
    // Frosted teal lens fill
    canvas.drawCircle(
      Offset(lensX, lensY),
      lensR,
      Paint()..color = const Color(0xFFE3F8F5).withValues(alpha: 0.72),
    );
    // Lens rim
    canvas.drawCircle(
      Offset(lensX, lensY),
      lensR,
      Paint()
        ..color = const Color(0xFF152036)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke,
    );
    // Lens glint
    canvas.drawArc(
      Rect.fromCircle(center: Offset(lensX, lensY), radius: lensR * 0.68),
      -2.4,
      1.1,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
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
        width: pw * 0.16,
        height: ph * 0.26,
      ),
      shoulderPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + pw * 0.47, cy + ph * 0.12),
        width: pw * 0.16,
        height: ph * 0.26,
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
    final double handY = cy + ph * 0.22 + (laggedSin * 1.6);
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
          width: pw * 0.26,
          height: ph * 0.14,
        ),
        Radius.circular(pw * 0.08),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF33B9A9), Color(0xFF167C70)],
        ).createShader(
          Rect.fromCenter(
            center: Offset.zero,
            width: pw * 0.26,
            height: ph * 0.14,
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
          width: pw * 0.26,
          height: ph * 0.14,
        ),
        Radius.circular(pw * 0.08),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF28A798), Color(0xFF126E63)],
        ).createShader(
          Rect.fromCenter(
            center: Offset.zero,
            width: pw * 0.26,
            height: ph * 0.14,
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
    final double tabW = pw * 0.34;
    final double tabH = ph * 0.24;
    final double crownY = cy - ph * 0.46;

    canvas.save();
    // Secondary follow-through: paper tab lags behind vertical motion & flaps slightly in air
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
      ..quadraticBezierTo(
        tabW * 0.12,
        tabH * 0.36,
        -tabW * 0.02,
        tabH * 0.36,
      )
      ..lineTo(-tabW * 0.44, tabH * 0.34)
      ..quadraticBezierTo(
        -tabW * 0.50,
        tabH * 0.32,
        -tabW * 0.46,
        tabH * 0.20,
      )
      ..close();

    canvas.drawPath(
      frontSlip,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF9EC),
            Color(0xFFF9EBD2),
            Color(0xFFF0D9B5),
          ],
        ).createShader(
          Rect.fromCenter(center: Offset.zero, width: tabW, height: tabH),
        ),
    );

    final Path curlFlap = Path()
      ..moveTo(tabW * 0.24, tabH * 0.16)
      ..quadraticBezierTo(tabW * 0.04, tabH * 0.14, 0.0, tabH * 0.36)
      ..quadraticBezierTo(
        tabW * 0.16,
        tabH * 0.34,
        tabW * 0.24,
        tabH * 0.16,
      )
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
    final double eyeY = cy - ph * 0.05;
    final double eyeSpacing = pw * 0.24;
    final double leftEyeX = cx - eyeSpacing;
    final double rightEyeX = cx + eyeSpacing;
    final double eyeRadius = pw * 0.072;

    // 1. Soft Blurred Apricot Cheeks
    final Paint blushPaint = Paint()
      ..color = EnpriveColors.apricot.withValues(alpha: 0.58)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(leftEyeX - eyeRadius * 0.65, eyeY + eyeRadius * 1.45),
        width: eyeRadius * 2.3,
        height: eyeRadius * 1.35,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rightEyeX + eyeRadius * 0.65, eyeY + eyeRadius * 1.45),
        width: eyeRadius * 2.3,
        height: eyeRadius * 1.35,
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
        ..strokeWidth = pw * 0.034
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
          // Active policy reading: pupils sweep horizontally left-to-right across lines!
          final double scanX = math.sin(phase * 4 * math.pi) * (eyeRadius * 0.28);
          final double scanY = math.cos(phase * 2 * math.pi) * (eyeRadius * 0.16) -
              eyeRadius * 0.14;
          canvas.drawCircle(
            Offset.zero,
            eyeRadius * 1.06,
            Paint()..color = const Color(0xFFFFFBF4),
          );
          canvas.drawCircle(
            Offset(scanX, scanY),
            eyeRadius * 0.76,
            inkPaint,
          );
          canvas.drawCircle(
            Offset(scanX - eyeRadius * 0.22, scanY - eyeRadius * 0.22),
            eyeRadius * 0.25,
            Paint()..color = Colors.white,
          );
        } else if (pose == DeniPose.listening) {
          final double nodY = math.sin(phase * 4 * math.pi) * (eyeRadius * 0.10);
          canvas.drawCircle(
            Offset.zero,
            eyeRadius * 1.05,
            Paint()..color = const Color(0xFFFFFBF4),
          );
          canvas.drawCircle(
            Offset(eyeRadius * 0.20, nodY),
            eyeRadius * 0.80,
            inkPaint,
          );
          canvas.drawCircle(
            Offset(-eyeRadius * 0.05, nodY - eyeRadius * 0.26),
            eyeRadius * 0.26,
            Paint()..color = Colors.white,
          );
        } else {
          final double glanceX = pose == DeniPose.explaining
              ? eyeRadius * 0.14
              : math.sin(phase * 2 * math.pi) * (eyeRadius * 0.08);
          canvas.drawCircle(Offset(glanceX, 0), eyeRadius, inkPaint);
          canvas.drawCircle(
            Offset(glanceX - eyeRadius * 0.32, -eyeRadius * 0.30),
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
      ..strokeWidth = pw * 0.032
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (pose) {
      case DeniPose.thinking:
        final double shift = math.sin(phase * 2 * math.pi) * (pw * 0.01);
        final Path pensive = Path()
          ..moveTo(cx - pw * 0.045 + shift, mouthY + ph * 0.015)
          ..quadraticBezierTo(
            cx + shift,
            mouthY - ph * 0.025,
            cx + pw * 0.045 + shift,
            mouthY + ph * 0.015,
          );
        canvas.drawPath(pensive, mouthStroke);

      case DeniPose.explaining:
        // Natural speaking syllable cadence (opens and closes smoothly while explaining)
        final double talkOpen =
            (math.sin(phase * 6 * math.pi) * 0.5 + 0.5).clamp(0.15, 1.0);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, mouthY + ph * 0.010),
            width: pw * (0.065 + 0.025 * talkOpen),
            height: ph * (0.022 + 0.042 * talkOpen),
          ),
          inkPaint,
        );

      case DeniPose.listening:
        final double breatheOpen =
            (math.sin(phase * 4 * math.pi) * 0.5 + 0.5).clamp(0.2, 1.0);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, mouthY + ph * 0.008),
            width: pw * 0.068,
            height: ph * (0.030 + 0.018 * breatheOpen),
          ),
          inkPaint,
        );

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

  /// Story-driven external support props for each of the 6 states.
  void _drawActionProps(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double phase,
    double fastSin,
  ) {
    switch (pose) {
      case DeniPose.thinking:
        // 1. Floating mini policy snippet being scanned by a sweeping teal laser bar
        final Rect docRect = Rect.fromCenter(
          center: Offset(cx + pw * 0.58, cy - ph * 0.08),
          width: pw * 0.28,
          height: ph * 0.26,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(docRect, const Radius.circular(6)),
          Paint()..color = const Color(0xFFFFFBF4),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(docRect, const Radius.circular(6)),
          Paint()
            ..color = EnpriveColors.teal.withValues(alpha: 0.35)
            ..strokeWidth = 1.2
            ..style = PaintingStyle.stroke,
        );
        // 3 policy text lines inside snippet
        for (int i = 0; i < 3; i++) {
          final double ly = docRect.top + docRect.height * (0.28 + i * 0.22);
          canvas.drawLine(
            Offset(docRect.left + 5, ly),
            Offset(docRect.right - (i == 2 ? 9 : 5), ly),
            Paint()
              ..color = EnpriveColors.ink.withValues(alpha: 0.22)
              ..strokeWidth = 1.8
              ..strokeCap = StrokeCap.round,
          );
        }
        // Sweeping horizontal laser scan bar moving top-to-bottom across the document
        final double scanProgress =
            math.sin(phase * 2 * math.pi) * 0.5 + 0.5;
        final double scanLineY = docRect.top +
            4 +
            (docRect.height - 8) * scanProgress;
        canvas.drawLine(
          Offset(docRect.left + 2, scanLineY),
          Offset(docRect.right - 2, scanLineY),
          Paint()
            ..color = EnpriveColors.teal
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round,
        );

        // 2. Rising thought bubbles above crown
        final List<(double dx, double dy, double r, double offset)> bubbles = [
          (pw * 0.34, -ph * 0.38, pw * 0.022, 0.0),
          (pw * 0.44, -ph * 0.48, pw * 0.032, 0.33),
          (pw * 0.55, -ph * 0.59, pw * 0.044, 0.66),
        ];
        for (final b in bubbles) {
          final double anim = math.sin((phase + b.$4) * 2 * math.pi);
          canvas.drawCircle(
            Offset(cx + b.$1, cy + b.$2 + anim * 2.5),
            b.$3,
            Paint()
              ..color = EnpriveColors.teal.withValues(
                alpha: (0.55 + 0.35 * anim).clamp(0.2, 0.95),
              ),
          );
        }

      case DeniPose.explaining:
        // Floating Evidence Card with active quotation highlight pulse
        final double cardBob = fastSin * 2.2;
        final Rect cardRect = Rect.fromCenter(
          center: Offset(cx + pw * 0.58, cy - ph * 0.16 + cardBob),
          width: pw * 0.32,
          height: ph * 0.24,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            cardRect.shift(const Offset(0, 3)),
            const Radius.circular(6),
          ),
          Paint()
            ..color = const Color(0xFF0E4A43).withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cardRect, const Radius.circular(6)),
          Paint()..color = const Color(0xFFFFFBF4),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cardRect, const Radius.circular(6)),
          Paint()
            ..color = EnpriveColors.teal.withValues(alpha: 0.35)
            ..strokeWidth = 1.3
            ..style = PaintingStyle.stroke,
        );

        // Animated highlight box switching between line 1 and line 2
        final bool highlightFirst = math.sin(phase * 2 * math.pi) >= 0;
        final double hlTop = highlightFirst
            ? cardRect.top + cardRect.height * 0.24
            : cardRect.top + cardRect.height * 0.54;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              cardRect.left + 4,
              hlTop,
              cardRect.width - 8,
              cardRect.height * 0.22,
            ),
            const Radius.circular(3),
          ),
          Paint()..color = EnpriveColors.apricot.withValues(alpha: 0.32),
        );

        canvas.drawLine(
          Offset(cardRect.left + 6, cardRect.top + cardRect.height * 0.35),
          Offset(cardRect.right - 6, cardRect.top + cardRect.height * 0.35),
          Paint()
            ..color = EnpriveColors.teal.withValues(alpha: 0.75)
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(cardRect.left + 6, cardRect.top + cardRect.height * 0.65),
          Offset(cardRect.right - 10, cardRect.top + cardRect.height * 0.65),
          Paint()
            ..color = EnpriveColors.apricot.withValues(alpha: 0.90)
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round,
        );

      case DeniPose.listening:
        // 3 Concentric Acoustic Wave Arcs + Animated 3-Bar Audio Equalizer Pill
        for (int i = 0; i < 3; i++) {
          final double pulse =
              math.sin((phase * 2 * math.pi) - (i * 0.65)) * 0.5 + 0.5;
          final double radius = pw * (0.13 + i * 0.072);
          canvas.drawArc(
            Rect.fromCircle(
              center: Offset(cx + pw * 0.38, cy - ph * 0.14),
              radius: radius,
            ),
            -0.65,
            1.15,
            false,
            Paint()
              ..color =
                  EnpriveColors.teal.withValues(alpha: 0.25 + 0.55 * pulse)
              ..strokeWidth = 2.2
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke,
          );
        }

        // Mini 3-bar Equalizer Badge on top-left
        final Offset eqCenter = Offset(cx - pw * 0.52, cy - ph * 0.24);
        for (int b = 0; b < 3; b++) {
          final double barH = ph *
              (0.05 +
                  0.07 *
                      (math.sin((phase * 4 * math.pi) + b * 1.1) * 0.5 + 0.5));
          canvas.drawLine(
            Offset(eqCenter.dx + (b - 1) * 5.0, eqCenter.dy + barH * 0.5),
            Offset(eqCenter.dx + (b - 1) * 5.0, eqCenter.dy - barH * 0.5),
            Paint()
              ..color = EnpriveColors.tealStrong
              ..strokeWidth = 2.4
              ..strokeCap = StrokeCap.round,
          );
        }

      case DeniPose.support:
        // Floating Protective Boundary Badge on top-right (communicates honest uncertainty)
        final double badgeBob = math.sin(phase * 2 * math.pi) * 3.0;
        final Offset badgeCenter =
            Offset(cx + pw * 0.52, cy - ph * 0.24 + badgeBob);
        final double br = pw * 0.11;

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
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke,
        );
        // Subtle question/verification dot & arc inside badge
        final Path qArc = Path()
          ..moveTo(badgeCenter.dx - br * 0.28, badgeCenter.dy - br * 0.22)
          ..quadraticBezierTo(
            badgeCenter.dx,
            badgeCenter.dy - br * 0.62,
            badgeCenter.dx + br * 0.28,
            badgeCenter.dy - br * 0.20,
          )
          ..quadraticBezierTo(
            badgeCenter.dx + br * 0.28,
            badgeCenter.dy,
            badgeCenter.dx,
            badgeCenter.dy + br * 0.12,
          );
        canvas.drawPath(
          qArc,
          Paint()
            ..color = EnpriveColors.ink
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
        canvas.drawCircle(
          Offset(badgeCenter.dx, badgeCenter.dy + br * 0.42),
          1.4,
          Paint()..color = EnpriveColors.ink,
        );

      case DeniPose.celebrating:
        // Twinkling 4-point sparkles on both sides
        _drawSparkle(
          canvas,
          Offset(cx + pw * 0.50, cy - ph * 0.34),
          pw * 0.080 * (0.75 + 0.25 * fastSin),
          const Color(0xFFE6B450),
        );
        _drawSparkle(
          canvas,
          Offset(cx + pw * 0.60, cy - ph * 0.18),
          pw * 0.050 * (0.75 - 0.25 * fastSin),
          EnpriveColors.apricot,
        );
        _drawSparkle(
          canvas,
          Offset(cx - pw * 0.50, cy - ph * 0.28),
          pw * 0.058 * (0.75 - 0.25 * fastSin),
          EnpriveColors.teal,
        );

      case DeniPose.idle:
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
        oldDelegate.pose != pose ||
        oldDelegate.showAmbientGlow != showAmbientGlow;
  }
}
