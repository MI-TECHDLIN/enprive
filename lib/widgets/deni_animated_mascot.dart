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

/// Interactive animated mascot for Deni (Concept C: The Protective Pebble).
/// Includes breathing idle loop, realistic blinking, interactive tap-squish,
/// and support for multiple state poses.
/// Automatically freezes if reduced motion is requested.
class DeniAnimatedMascot extends StatefulWidget {
  final double size;
  final DeniPose pose;
  final VoidCallback? onTap;

  const DeniAnimatedMascot({
    super.key,
    this.size = 80.0,
    this.pose = DeniPose.idle,
    this.onTap,
  });

  @override
  State<DeniAnimatedMascot> createState() => _DeniAnimatedMascotState();
}

class _DeniAnimatedMascotState extends State<DeniAnimatedMascot>
    with TickerProviderStateMixin {
  late final AnimationController _breatheController;
  late final AnimationController _blinkController;
  late final AnimationController _squishController;
  final math.Random _random = math.Random();
  // Cancelable timer for blinking
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    // Subtle gentle breathing / bobbing animation (2.4s cycle)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Realistic blinking controller (blinks every ~3.5s)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scheduleNextBlink();

    // Interactive squish on tap (250ms spring)
    _squishController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  void _scheduleNextBlink() {
    if (!mounted) return;
    final delay = Duration(milliseconds: 2600 + _random.nextInt(2000));
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
    _breatheController.dispose();
    _blinkController.dispose();
    _squishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: 'Deni, your privacy guide',
      image: true,
      child: GestureDetector(
        onTap: _handleTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size * 1.1,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _breatheController,
              _blinkController,
              _squishController,
            ]),
            builder: (context, _) {
              final double breatheVal = reduceMotion ? 0.0 : _breatheController.value;
              final double blinkVal = reduceMotion ? 0.0 : _blinkController.value;
              final double squishVal = reduceMotion ? 0.0 : _squishController.value;

              // Compute squish curve (spring out)
              final double squishFactor = math.sin(squishVal * math.pi) * 0.12;

              return CustomPaint(
                painter: _DeniPebblePainter(
                  breathe: breatheVal,
                  blink: blinkVal,
                  squish: squishFactor,
                  pose: widget.pose,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeniPebblePainter extends CustomPainter {
  final double breathe;
  final double blink;
  final double squish;
  final DeniPose pose;

  _DeniPebblePainter({
    required this.breathe,
    required this.blink,
    required this.squish,
    required this.pose,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Center coordinates
    final double cx = w / 2;
    // Breathing vertical offset
    final double cy = (h / 2 + 6) - (breathe * 3.0);

    // Apply squish/stretch transform
    final double scaleX = 1.0 + (squish * 0.8) - (breathe * 0.02);
    final double scaleY = 1.0 - squish + (breathe * 0.03);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scaleX, scaleY);
    canvas.translate(-cx, -cy);

    // 1. Shadow underneath pebble
    final shadowRect = Rect.fromCenter(
      center: Offset(cx, cy + h * 0.38 + (breathe * 2.0)),
      width: w * 0.65 - (breathe * 4.0),
      height: h * 0.12,
    );
    canvas.drawOval(
      shadowRect,
      Paint()
        ..color = const Color(0xFF1F2A44).withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 2. Draw Pebble Body (Concept C)
    final bodyRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: w * 0.76,
        height: h * 0.72,
      ),
      topLeft: Radius.circular(w * 0.36),
      topRight: Radius.circular(w * 0.36),
      bottomLeft: Radius.circular(w * 0.34),
      bottomRight: Radius.circular(w * 0.34),
    );

    // Rich teal gradient (calm, trustworthy, 3D curved feel)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF26B2A2), // Highlight teal
          EnpriveColors.teal, // Base teal
          Color(0xFF137A6F), // Deep protective teal
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(bodyRect.outerRect);

    canvas.drawRRect(bodyRect, bodyPaint);

    // 3. Folded Paper Tab on Top (Concept C Paper Tab "Cap")
    final tabPath = Path();
    final double tabW = w * 0.22;
    final double tabH = h * 0.16;
    final double tabTop = cy - (h * 0.36) - (tabH * 0.45);
    final double tabLeft = cx - (tabW / 2);

    tabPath.moveTo(tabLeft, tabTop + tabH);
    tabPath.lineTo(tabLeft + 2, tabTop + 4);
    tabPath.quadraticBezierTo(tabLeft + 3, tabTop, tabLeft + 7, tabTop);
    tabPath.lineTo(tabLeft + tabW - 7, tabTop);
    tabPath.quadraticBezierTo(tabLeft + tabW - 3, tabTop, tabLeft + tabW - 2, tabTop + 4);
    tabPath.lineTo(tabLeft + tabW, tabTop + tabH);
    tabPath.close();

    // Tab gradient (paper cream)
    final tabPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFBF4),
          Color(0xFFF6ECE0),
        ],
      ).createShader(Rect.fromLTWH(tabLeft, tabTop, tabW, tabH));

    canvas.drawPath(tabPath, tabPaint);

    // Tab folded crease line
    final foldPaint = Paint()
      ..color = const Color(0xFFDECFC0)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(tabLeft + 3, tabTop + tabH * 0.65),
      Offset(tabLeft + tabW - 3, tabTop + tabH * 0.65),
      foldPaint,
    );

    // 4. Little Stubby Arms / Fins on sides (tucked in)
    final armPaint = Paint()..color = const Color(0xFF178C7F);
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.42, cy - h * 0.08, w * 0.08, h * 0.22),
        const Radius.circular(8),
      ),
      armPaint,
    );
    // Right arm (may wave if celebrating/welcome)
    final double rightArmY = (pose == DeniPose.celebrating || pose == DeniPose.idle)
        ? cy - h * 0.08 - (breathe * 2)
        : cy - h * 0.08;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + w * 0.34, rightArmY, w * 0.08, h * 0.22),
        const Radius.circular(8),
      ),
      armPaint,
    );

    // 5. Apricot Blush Circles
    final blushPaint = Paint()
      ..color = const Color(0xFFF4A261).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final double eyeY = cy - h * 0.02;
    final double eyeSpacing = w * 0.24;

    canvas.drawCircle(Offset(cx - eyeSpacing - 4, eyeY + 12), w * 0.05, blushPaint);
    canvas.drawCircle(Offset(cx + eyeSpacing + 4, eyeY + 12), w * 0.05, blushPaint);

    // 6. Two Expressive Ink Navy Eyes (#1F2A44)
    final eyePaint = Paint()
      ..color = const Color(0xFF1A2338)
      ..style = PaintingStyle.fill;

    // Eye blink squash factor (1.0 = open, 0.05 = closed)
    final double openFactor = math.max(0.08, 1.0 - blink);

    final double eyeRadius = w * 0.045;
    final double leftEyeX = cx - (eyeSpacing / 2);
    final double rightEyeX = cx + (eyeSpacing / 2);

    // Left eye
    canvas.save();
    canvas.translate(leftEyeX, eyeY);
    canvas.scale(1.0, openFactor);
    canvas.drawCircle(Offset.zero, eyeRadius, eyePaint);
    // Specular highlight in eyes when open
    if (openFactor > 0.4) {
      canvas.drawCircle(
        Offset(-eyeRadius * 0.3, -eyeRadius * 0.3),
        eyeRadius * 0.35,
        Paint()..color = Colors.white,
      );
    }
    canvas.restore();

    // Right eye
    canvas.save();
    canvas.translate(rightEyeX, eyeY);
    canvas.scale(1.0, openFactor);
    canvas.drawCircle(Offset.zero, eyeRadius, eyePaint);
    if (openFactor > 0.4) {
      canvas.drawCircle(
        Offset(-eyeRadius * 0.3, -eyeRadius * 0.3),
        eyeRadius * 0.35,
        Paint()..color = Colors.white,
      );
    }
    canvas.restore();

    // 7. Calm, Friendly Smile
    final mouthPaint = Paint()
      ..color = const Color(0xFF1A2338)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mouthPath = Path();
    final double mouthY = eyeY + 12;
    mouthPath.moveTo(cx - 7, mouthY);
    mouthPath.quadraticBezierTo(cx, mouthY + 5.5, cx + 7, mouthY);
    canvas.drawPath(mouthPath, mouthPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeniPebblePainter oldDelegate) {
    return oldDelegate.breathe != breathe ||
        oldDelegate.blink != blink ||
        oldDelegate.squish != squish ||
        oldDelegate.pose != pose;
  }
}
