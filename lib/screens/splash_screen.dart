import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/enprive_theme.dart';
import '../l10n/app_localizations.dart';

/// Minimal editorial Material 3 Expressive brand splash screen displaying the
/// bold `enprive` wordmark above a subtle localized quote (`Know what you're
/// agreeing to`) in both Light ("Warm Archival Paper") and Dark ("Obsidian
/// Ceramic Slate") modes.
class EnpriveSplashScreen extends StatefulWidget {
  final VoidCallback onCompleted;
  final Duration displayDuration;

  const EnpriveSplashScreen({
    super.key,
    required this.onCompleted,
    this.displayDuration = const Duration(milliseconds: 1400),
  });

  @override
  State<EnpriveSplashScreen> createState() => _EnpriveSplashScreenState();
}

class _EnpriveSplashScreenState extends State<EnpriveSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _holdTimer;
  bool _scheduled = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _opacity = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;

    final disableAnimations = EnpriveMotionTokens.isReducedMotion(context);
    final effectiveDelay = disableAnimations
        ? (widget.displayDuration < const Duration(milliseconds: 500)
              ? widget.displayDuration
              : const Duration(milliseconds: 500))
        : widget.displayDuration;

    if (disableAnimations) {
      _introController.value = 1.0;
    } else {
      _introController.forward();
    }

    _holdTimer = Timer(effectiveDelay, _finishNow);
  }

  void _finishNow() {
    if (_completed || !mounted) return;
    _completed = true;
    _holdTimer?.cancel();
    widget.onCompleted();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(
          Localizations.maybeLocaleOf(context) ?? const Locale('en'),
        );
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final typeExt = context.enpriveType;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'enprive',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: m3e.typography.emphasized.displayMedium.copyWith(
              fontSize: 48,
              height: 1.05,
              letterSpacing: -1.4,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            l10n.splashQuote,
            textAlign: TextAlign.center,
            style: typeExt.policyQuotation.copyWith(
              fontSize: 15,
              height: 1.4,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finishNow,
        child: Semantics(
          container: true,
          label: 'enprive. ${l10n.splashQuote}',
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Center(
                child: FadeTransition(
                  opacity: _opacity,
                  child: SlideTransition(position: _slide, child: content),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
