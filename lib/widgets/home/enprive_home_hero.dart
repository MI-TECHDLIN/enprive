import 'package:flutter/material.dart';

import '../../core/theme/enprive_theme.dart';
import '../deni_animated_mascot.dart';

/// The one lead block on the Check tab: a gradient hero from
/// `primaryContainer` to `tertiaryContainer` holding Deni, the headline and
/// the screen's only filled action. Text uses `onPrimaryContainer`, which
/// keeps at least 6:1 against both ends of the gradient in light and dark.
///
/// The gradient drifts slowly (14s, alternating) while the hero is on
/// screen; it is static under reduced motion and stops with [TickerMode].
class EnpriveHomeHero extends StatefulWidget {
  final DeniPose deniPose;
  final String headline;
  final String subtitle;
  final Widget actions;

  const EnpriveHomeHero({
    super.key,
    required this.deniPose,
    required this.headline,
    required this.subtitle,
    required this.actions,
  });

  static const Duration driftPeriod = Duration(seconds: 14);

  @override
  State<EnpriveHomeHero> createState() => _EnpriveHomeHeroState();
}

class _EnpriveHomeHeroState extends State<EnpriveHomeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: EnpriveHomeHero.driftPeriod,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _drift
        ..stop()
        ..value = 0;
    } else if (!_drift.isAnimating) {
      _drift.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Center(
              child: DeniAnimatedMascot(size: 88, pose: widget.deniPose),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              widget.headline,
              textAlign: TextAlign.center,
              style: m3e.typography.emphasized.headlineMedium.copyWith(
                color: scheme.onPrimaryContainer,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: m3e.typeScale.bodyLarge.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          widget.actions,
        ],
      ),
    );

    return AnimatedBuilder(
      animation: _drift,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_drift.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EnpriveRadii.hero),
            gradient: LinearGradient(
              begin: Alignment.lerp(Alignment.topLeft, Alignment.topRight, t)!,
              end: Alignment.lerp(
                Alignment.bottomRight,
                Alignment.bottomLeft,
                t,
              )!,
              colors: [scheme.primaryContainer, scheme.tertiaryContainer],
            ),
          ),
          child: child,
        );
      },
      child: content,
    );
  }
}
