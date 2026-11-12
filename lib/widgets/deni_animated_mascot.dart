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
/// Faithfully implements the Concept C artwork and 6-pose expression sheet:
/// - Organic sculpted river-pebble silhouette with 3D spherical lighting & rim light
/// - Signature folded warm-cream paper tab on top with curled dog-ear corner
/// - Articulated flipper arms and authentic props for all 6 product states
/// - Continuous breathing/floating phase, natural eye blinking, and tap-squish physics
/// - Automatically respects MediaQuery.disableAnimations (Reduced Motion)
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
  late final AnimationController _squishController;
  final math.Random _random = math.Random();
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    // Continuous 3.2s phase loop driving breathing, arm wave, thought bubbles,
    // sound arcs, floating evidence card, and sparkle twinkles.
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // Realistic rapid eyelid blink (150ms close + 150ms open)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scheduleNextBlink();

    // Elastic spring squish when tapped
    _squishController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  void _scheduleNextBlink() {
    if (!mounted) return;
    final delay = Duration(milliseconds: 2400 + _random.nextInt(2200));
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
    _squishController.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _loopController.dispose();
    _blinkController.dispose();
    _squishController.dispose();
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
          width: widget.size * 1.22,
          height: widget.size * 1.18,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _loopController,
              _blinkController,
              _squishController,
            ]),
            builder: (context, _) {
              final double phase = reduceMotion ? 0.25 : _loopController.value;
              final double blink = reduceMotion ? 0.0 : _blinkController.value;
              final double squishT =
                  reduceMotion ? 0.0 : _squishController.value;

              // Damped elastic spring for tap squish
              final double squish = squishT == 0.0
                  ? 0.0
                  : math.sin(squishT * math.pi * 2.0) *
                      math.pow(1.0 - squishT, 1.6) *
                      0.16;

              return CustomPaint(
                painter: _DeniSculptedPebblePainter(
                  phase: phase,
                  blink: blink,
                  squish: squish,
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

class _DeniSculptedPebblePainter extends CustomPainter {
  final double phase;
  final double blink;
  final double squish;
  final DeniPose pose;
  final bool showAmbientGlow;

  _DeniSculptedPebblePainter({
    required this.phase,
    required this.blink,
    required this.squish,
    required this.pose,
    required this.showAmbientGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w * 0.5;
    final double baseCy = h * 0.54;

    // Smooth sinusoidal breathing wave (-1.0 to 1.0)
    final double breatheSin = math.sin(phase * 2 * math.pi);
    // Secondary harmonic for props and wave
    final double waveSin = math.sin(phase * 4 * math.pi);

    final double floatY = -breatheSin * (h * 0.022);
    final double cy = baseCy + floatY;

    // 1. Subtle Ambient Glow behind Deni (from mobile-app-ui-design polish rules)
    if (showAmbientGlow) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            EnpriveColors.teal.withValues(alpha: 0.14),
            EnpriveColors.apricot.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.48),
        );
      canvas.drawCircle(Offset(cx, cy), w * 0.48, glowPaint);
    }

    // 2. Tinted Soft Ground Shadow (expands/contracts with breathing height)
    final double shadowScale = 1.0 - (breatheSin * 0.07) + (squish * 0.4);
    final shadowRect = Rect.fromCenter(
      center: Offset(cx, h * 0.90),
      width: w * 0.54 * shadowScale,
      height: h * 0.075 * shadowScale,
    );
    canvas.drawOval(
      shadowRect,
      Paint()
        ..color = const Color(0xFF0E4A43).withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Save canvas for body squash/stretch & pose head-tilt
    canvas.save();
    canvas.translate(cx, cy);

    // Slight empathetic head/body tilt for listening or support poses
    final double bodyTilt = switch (pose) {
      DeniPose.listening => -0.065,
      DeniPose.support => -0.035,
      DeniPose.thinking => 0.025,
      _ => 0.0,
    };
    if (bodyTilt != 0.0) {
      canvas.rotate(bodyTilt);
    }

    final double scaleX = 1.0 + squish - (breatheSin * 0.014);
    final double scaleY = 1.0 - (squish * 0.85) + (breatheSin * 0.018);
    canvas.scale(scaleX, scaleY);
    canvas.translate(-cx, -cy);

    // Pebble dimensions
    final double pw = w * 0.66;
    final double ph = h * 0.68;

    // 3. Draw Back Arms (when not clasped in front for `support`)
    if (pose != DeniPose.support) {
      _drawLeftFlipper(canvas, cx, cy, pw, ph, breatheSin);
      _drawRightFlipper(canvas, cx, cy, pw, ph, breatheSin, waveSin);
    } else {
      // Side shoulders slightly visible behind clasped arms
      _drawSupportSideShoulders(canvas, cx, cy, pw, ph);
    }

    // 4. Sculpted Organic Pebble Body Path (matches Concept C artwork)
    final Path pebblePath = _buildPebblePath(cx, cy, pw, ph);

    // 3D Spherical Studio Shader (Top-Left warm teal highlight -> Mid -> Deep bottom-right shade)
    final Rect pebbleBounds = Rect.fromCenter(
      center: Offset(cx, cy),
      width: pw,
      height: ph,
    );
    final Paint bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.38, -0.45),
        radius: 1.15,
        colors: [
          Color(0xFF39C4B3), // Soft top-left studio highlight
          Color(0xFF1F9E8F), // Signature Enprive calm teal
          Color(0xFF13756A), // Deep mid-shadow teal
          Color(0xFF0B4F47), // Grounded base shade
        ],
        stops: [0.0, 0.42, 0.78, 1.0],
      ).createShader(pebbleBounds);

    canvas.drawPath(pebblePath, bodyPaint);

    // Subtle inner rim highlight along top-left curve for ceramic/clay depth
    canvas.save();
    canvas.clipPath(pebblePath);
    final Paint rimHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.42],
      ).createShader(pebbleBounds);
    canvas.drawPath(pebblePath, rimHighlight);

    // Bottom-right ambient occlusion crescent inside pebble
    final Paint crescentShadow = Paint()
      ..color = const Color(0xFF073832).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + pw * 0.16, cy + ph * 0.36),
        width: pw * 0.75,
        height: ph * 0.36,
      ),
      crescentShadow,
    );
    canvas.restore();

    // 5. Signature Concept C Folded Cream Paper Tab on Top (with curled dog-ear)
    _drawSculptedPaperTab(canvas, cx, cy, pw, ph, breatheSin);

    // 6. Facial Features (Blush, Expressive Eyes, Pose-Specific Mouth)
    _drawFace(canvas, cx, cy, pw, ph);

    // 7. Clasped Front Flippers for `support` pose (drawn over belly)
    if (pose == DeniPose.support) {
      _drawSupportClaspedHands(canvas, cx, cy, pw, ph, breatheSin);
    }

    canvas.restore();

    // 8. Pose-Specific Floating Props (drawn outside body squish for crispness)
    _drawPoseProps(canvas, cx, cy, pw, ph, phase, waveSin);
  }

  /// Builds the organic Concept C pebble silhouette using smooth cubic Beziers:
  /// broad, friendly rounded upper dome with a grounded, weighted pebble base.
  Path _buildPebblePath(double cx, double cy, double pw, double ph) {
    final double top = cy - ph * 0.48;
    final double bottom = cy + ph * 0.50;
    final double left = cx - pw * 0.50;
    final double right = cx + pw * 0.50;

    return Path()
      // Top crown center
      ..moveTo(cx, top)
      // Top-right shoulder curve
      ..cubicTo(
        cx + pw * 0.34,
        top,
        right,
        cy - ph * 0.32,
        right,
        cy - ph * 0.02,
      )
      // Bottom-right rounded pebble belly
      ..cubicTo(
        right,
        cy + ph * 0.30,
        cx + pw * 0.32,
        bottom,
        cx,
        bottom,
      )
      // Bottom-left rounded pebble belly
      ..cubicTo(
        cx - pw * 0.32,
        bottom,
        left,
        cy + ph * 0.30,
        left,
        cy - ph * 0.02,
      )
      // Top-left shoulder curve
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
    double breatheSin,
  ) {
    canvas.save();
    final double pivotX = cx - pw * 0.45;
    final double pivotY = cy + ph * 0.02;
    canvas.translate(pivotX, pivotY);
    canvas.rotate(0.22 + breatheSin * 0.04);

    final Rect armRect = Rect.fromCenter(
      center: Offset(-pw * 0.05, ph * 0.12),
      width: pw * 0.19,
      height: ph * 0.32,
    );
    final Paint armPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF28AA9B), Color(0xFF0E6157)],
      ).createShader(armRect);

    canvas.drawOval(armRect, armPaint);
    canvas.restore();
  }

  void _drawRightFlipper(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double breatheSin,
    double waveSin,
  ) {
    canvas.save();
    final double pivotX = cx + pw * 0.44;
    final double pivotY = cy + ph * 0.02;
    canvas.translate(pivotX, pivotY);

    switch (pose) {
      case DeniPose.idle:
        // Friendly welcoming wave upward (matches Top-Left expression sheet)
        canvas.rotate(-0.85 + waveSin * 0.14);
        final Rect waveArm = Rect.fromCenter(
          center: Offset(pw * 0.06, -ph * 0.10),
          width: pw * 0.19,
          height: ph * 0.32,
        );
        final Paint paint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF33B9A9), Color(0xFF116B60)],
          ).createShader(waveArm);
        canvas.drawOval(waveArm, paint);
      case DeniPose.explaining:
        // Pointing toward the miniature evidence card on the right
        canvas.rotate(-0.62 + breatheSin * 0.05);
        final Rect pointArm = Rect.fromCenter(
          center: Offset(pw * 0.08, -ph * 0.06),
          width: pw * 0.18,
          height: ph * 0.30,
        );
        final Paint paint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF2EB2A2), Color(0xFF116B60)],
          ).createShader(pointArm);
        canvas.drawOval(pointArm, paint);
      default:
        // Relaxed resting flipper
        canvas.rotate(-0.22 - breatheSin * 0.04);
        final Rect restArm = Rect.fromCenter(
          center: Offset(pw * 0.05, ph * 0.12),
          width: pw * 0.19,
          height: ph * 0.32,
        );
        final Paint paint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF219688), Color(0xFF0C5249)],
          ).createShader(restArm);
        canvas.drawOval(restArm, paint);
    }
    canvas.restore();
  }

  void _drawSupportSideShoulders(
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
    double breatheSin,
  ) {
    final double handY = cy + ph * 0.22 + (breatheSin * 1.2);
    // Soft shadow under clasped flippers on belly
    final shadowPaint = Paint()
      ..color = const Color(0xFF083A34).withValues(alpha: 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, handY + ph * 0.04),
        width: pw * 0.46,
        height: ph * 0.14,
      ),
      shadowPaint,
    );

    final leftHandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF33B9A9), Color(0xFF167C70)],
      ).createShader(
        Rect.fromCenter(
          center: Offset(cx - pw * 0.10, handY),
          width: pw * 0.26,
          height: ph * 0.16,
        ),
      );

    final rightHandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF28A798), Color(0xFF126E63)],
      ).createShader(
        Rect.fromCenter(
          center: Offset(cx + pw * 0.10, handY),
          width: pw * 0.26,
          height: ph * 0.16,
        ),
      );

    canvas.save();
    canvas.translate(cx - pw * 0.11, handY);
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
      leftHandPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(cx + pw * 0.11, handY);
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
      rightHandPaint,
    );
    canvas.restore();
  }

  /// Draws the signature Concept C 3D folded cream paper tab resting on top of the pebble
  /// with back tent fold, warm drop shadow, and curled bottom-right corner.
  void _drawSculptedPaperTab(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double breatheSin,
  ) {
    final double tabW = pw * 0.34;
    final double tabH = ph * 0.24;
    final double crownY = cy - ph * 0.46;

    canvas.save();
    canvas.translate(cx - pw * 0.01, crownY);
    canvas.rotate(-0.04 + (breatheSin * 0.018));

    // Soft shadow cast by the paper tab onto the pebble crown
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

    // 1. Back Tent Flap (darker warm sand shade on right)
    final Path backFlap = Path()
      ..moveTo(tabW * 0.32, -tabH * 0.52)
      ..lineTo(tabW * 0.52, tabH * 0.06)
      ..lineTo(tabW * 0.18, tabH * 0.12)
      ..close();
    canvas.drawPath(
      backFlap,
      Paint()..color = const Color(0xFFE5CFAF),
    );

    // 2. Main Front Cream Paper Slip (#FFF6E4 -> #F5E5C9)
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
      // Curled dog-ear cut at bottom right
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

    final Rect slipBounds = Rect.fromCenter(
      center: Offset.zero,
      width: tabW,
      height: tabH,
    );
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
        ).createShader(slipBounds),
    );

    // 3. Curled Corner Flap (matches Concept C image curl)
    final Path curlFlap = Path()
      ..moveTo(tabW * 0.24, tabH * 0.16)
      ..quadraticBezierTo(
        tabW * 0.04,
        tabH * 0.14,
        0.0,
        tabH * 0.36,
      )
      ..quadraticBezierTo(
        tabW * 0.16,
        tabH * 0.34,
        tabW * 0.24,
        tabH * 0.16,
      )
      ..close();
    canvas.drawPath(
      curlFlap,
      Paint()..color = const Color(0xFFE3C598),
    );

    canvas.restore();
  }

  void _drawFace(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
  ) {
    final double eyeY = cy - ph * 0.05;
    final double eyeSpacing = pw * 0.24;
    final double leftEyeX = cx - eyeSpacing;
    final double rightEyeX = cx + eyeSpacing;
    final double eyeRadius = pw * 0.072;

    // 1. Soft Blurred Apricot Cheeks (#F4A261)
    final Paint blushPaint = Paint()
      ..color = const Color(0xFFF4A261).withValues(alpha: 0.58)
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

    // 2. Eyes (Pose-aware + Blink animation)
    final Paint inkPaint = Paint()
      ..color = const Color(0xFF152036)
      ..style = PaintingStyle.fill;

    if (pose == DeniPose.celebrating || blink > 0.82) {
      // Happy closed-arc eyes (^  ^)
      final Paint arcPaint = Paint()
        ..color = const Color(0xFF152036)
        ..strokeWidth = pw * 0.032
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
          // White sclera base with navy pupil looking up-right (matches Thinking expression sheet)
          canvas.drawCircle(
            Offset.zero,
            eyeRadius * 1.05,
            Paint()..color = const Color(0xFFFFFBF4),
          );
          canvas.drawCircle(
            Offset(eyeRadius * 0.22, -eyeRadius * 0.28),
            eyeRadius * 0.76,
            inkPaint,
          );
          canvas.drawCircle(
            Offset(eyeRadius * 0.02, -eyeRadius * 0.50),
            eyeRadius * 0.24,
            Paint()..color = Colors.white,
          );
        } else if (pose == DeniPose.listening) {
          // Attentive eyes with subtle white outer crescent on left
          canvas.drawCircle(
            Offset.zero,
            eyeRadius * 1.05,
            Paint()..color = const Color(0xFFFFFBF4),
          );
          canvas.drawCircle(
            Offset(eyeRadius * 0.20, 0),
            eyeRadius * 0.80,
            inkPaint,
          );
          canvas.drawCircle(
            Offset(-eyeRadius * 0.05, -eyeRadius * 0.26),
            eyeRadius * 0.26,
            Paint()..color = Colors.white,
          );
        } else {
          // Classic Concept C deep navy eyes with crisp top-left specular shine
          canvas.drawCircle(Offset.zero, eyeRadius, inkPaint);
          canvas.drawCircle(
            Offset(-eyeRadius * 0.32, -eyeRadius * 0.30),
            eyeRadius * 0.32,
            Paint()..color = Colors.white,
          );
        }
        canvas.restore();
      }
    }

    // 3. Mouth (Pose-specific expression)
    final double mouthY = eyeY + eyeRadius * 1.35;
    final Paint mouthStroke = Paint()
      ..color = const Color(0xFF152036)
      ..strokeWidth = pw * 0.032
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (pose) {
      case DeniPose.thinking:
        // Pensive upward-curved small arc
        final Path pensive = Path()
          ..moveTo(cx - pw * 0.045, mouthY + ph * 0.015)
          ..quadraticBezierTo(
            cx,
            mouthY - ph * 0.025,
            cx + pw * 0.045,
            mouthY + ph * 0.015,
          );
        canvas.drawPath(pensive, mouthStroke);
      case DeniPose.explaining:
      case DeniPose.listening:
        // Expressive speaking/attentive oval mouth
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, mouthY + ph * 0.008),
            width: pw * 0.075,
            height: ph * 0.048,
          ),
          inkPaint,
        );
      default:
        // Warm, calm reassuring smile
        final Path smile = Path()
          ..moveTo(cx - pw * 0.068, mouthY - ph * 0.005)
          ..quadraticBezierTo(
            cx,
            mouthY + ph * 0.052,
            cx + pw * 0.068,
            mouthY - ph * 0.005,
          );
        canvas.drawPath(smile, mouthStroke);
    }
  }

  /// Draws the floating ambient props from the Concept C 6-state expression sheet.
  void _drawPoseProps(
    Canvas canvas,
    double cx,
    double cy,
    double pw,
    double ph,
    double phase,
    double waveSin,
  ) {
    switch (pose) {
      case DeniPose.thinking:
        // 3 rising teal thought bubbles on top-right
        final List<(double dx, double dy, double r, double offset)> bubbles = [
          (pw * 0.36, -ph * 0.38, pw * 0.024, 0.0),
          (pw * 0.46, -ph * 0.48, pw * 0.034, 0.33),
          (pw * 0.57, -ph * 0.60, pw * 0.046, 0.66),
        ];
        for (final b in bubbles) {
          final double anim = math.sin((phase + b.$4) * 2 * math.pi);
          final double alpha = (0.55 + 0.35 * anim).clamp(0.2, 0.95);
          canvas.drawCircle(
            Offset(cx + b.$1, cy + b.$2 + anim * 2.5),
            b.$3,
            Paint()..color = EnpriveColors.teal.withValues(alpha: alpha),
          );
        }

      case DeniPose.explaining:
        // Floating miniature evidence card on right with tiny quote lines
        final double cardBob = waveSin * 2.5;
        final Rect cardRect = Rect.fromCenter(
          center: Offset(cx + pw * 0.56, cy - ph * 0.18 + cardBob),
          width: pw * 0.30,
          height: ph * 0.22,
        );
        // Card soft shadow
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            cardRect.shift(const Offset(0, 3)),
            const Radius.circular(6),
          ),
          Paint()
            ..color = const Color(0xFF0E4A43).withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        // Card surface
        canvas.drawRRect(
          RRect.fromRectAndRadius(cardRect, const Radius.circular(6)),
          Paint()..color = const Color(0xFFFFFBF4),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cardRect, const Radius.circular(6)),
          Paint()
            ..color = EnpriveColors.teal.withValues(alpha: 0.30)
            ..strokeWidth = 1.2
            ..style = PaintingStyle.stroke,
        );
        // Tiny quote lines inside card
        final linePaint = Paint()
          ..color = EnpriveColors.teal.withValues(alpha: 0.55)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(cardRect.left + 6, cardRect.top + cardRect.height * 0.36),
          Offset(cardRect.right - 6, cardRect.top + cardRect.height * 0.36),
          linePaint,
        );
        canvas.drawLine(
          Offset(cardRect.left + 6, cardRect.top + cardRect.height * 0.66),
          Offset(cardRect.right - 11, cardRect.top + cardRect.height * 0.66),
          linePaint..color = EnpriveColors.apricot.withValues(alpha: 0.75),
        );

      case DeniPose.listening:
        // 3 concentric acoustic wave arcs pulsing on right
        for (int i = 0; i < 3; i++) {
          final double pulse =
              math.sin((phase * 2 * math.pi) - (i * 0.65)) * 0.5 + 0.5;
          final double radius = pw * (0.14 + i * 0.075);
          final Paint wavePaint = Paint()
            ..color =
                EnpriveColors.teal.withValues(alpha: 0.25 + 0.50 * pulse)
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
          canvas.drawArc(
            Rect.fromCircle(
              center: Offset(cx + pw * 0.38, cy - ph * 0.14),
              radius: radius,
            ),
            -0.65,
            1.15,
            false,
            wavePaint,
          );
        }

      case DeniPose.celebrating:
        // Twinkling 4-point golden-apricot sparkles on top-right
        _drawSparkle(
          canvas,
          Offset(cx + pw * 0.48, cy - ph * 0.32),
          pw * 0.075 * (0.75 + 0.25 * waveSin),
          const Color(0xFFE6B450),
        );
        _drawSparkle(
          canvas,
          Offset(cx + pw * 0.58, cy - ph * 0.18),
          pw * 0.045 * (0.75 - 0.25 * waveSin),
          const Color(0xFFF4A261),
        );

      case DeniPose.idle:
      case DeniPose.support:
        break;
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final Path path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx,
        center.dy - radius,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _DeniSculptedPebblePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.blink != blink ||
        oldDelegate.squish != squish ||
        oldDelegate.pose != pose ||
        oldDelegate.showAmbientGlow != showAmbientGlow;
  }
}
