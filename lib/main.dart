import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'core/theme/enprive_colors.dart';
import 'core/theme/enprive_theme.dart';
import 'l10n/app_localizations.dart';
import 'services/platform/hybrid_ai_bridge.dart';
import 'widgets/deni_animated_mascot.dart';
import 'widgets/enprive_provenance_chip.dart';
import 'widgets/enprive_tactile_button.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EnpriveApp());
}

class EnpriveApp extends StatefulWidget {
  const EnpriveApp({super.key});

  @override
  State<EnpriveApp> createState() => _EnpriveAppState();
}

class _EnpriveAppState extends State<EnpriveApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale newLocale) {
    setState(() => _locale = newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enprive',
      debugShowCheckedModeBanner: false,
      theme: EnpriveTheme.lightTheme,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomeScreen(
        currentLocale: _locale,
        onLocaleChange: _setLocale,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChange;

  const HomeScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChange,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HybridAiBridge _bridge = HybridAiBridge();
  DeviceCapability? _deviceCapability;
  bool _isLoadingCapability = true;

  @override
  void initState() {
    super.initState();
    _checkDevice();
  }

  Future<void> _checkDevice() async {
    final cap = await _bridge.getDeviceCapability();
    if (mounted) {
      setState(() {
        _deviceCapability = cap;
        _isLoadingCapability = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKorean = widget.currentLocale.languageCode == 'ko';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: EnpriveColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: EnpriveColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'NANO 4',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: EnpriveColors.tealStrong,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Locale toggle button (EN / 한국어)
          TextButton(
            onPressed: () {
              widget.onLocaleChange(
                isKorean ? const Locale('en') : const Locale('ko'),
              );
            },
            child: Row(
              children: [
                const Icon(Symbols.translate_rounded, size: 18),
                const SizedBox(width: 4),
                Text(
                  isKorean ? 'English' : '한국어',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Provenance / Private status banner
              Row(
                children: [
                  const EnpriveProvenanceChip(
                    source: InferenceSource.onDevice,
                    customLabel: 'Private by default',
                  ),
                  const Spacer(),
                  if (_isLoadingCapability)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      _deviceCapability?.isSupported == true
                          ? 'Device Ready'
                          : 'Hardware Scout',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: EnpriveColors.inkSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Hero headline
              Text(
                isKorean
                    ? '아이들이 사용하는 앱의\n개인정보를 더 명확하게.'
                    : 'A clearer look at the\napps children use.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),

              // Reassurance subtitle
              Text(
                l10n.homePrivacySubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: EnpriveColors.inkSecondary,
                    ),
              ),

              const SizedBox(height: 32),

              // Deni Guide Card (Inspiration from Brilliant & Mascot Brief)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: EnpriveColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEAE7E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animated Deni Mascot (Concept C: The Protective Pebble)
                    const DeniAnimatedMascot(
                      size: 54,
                      pose: DeniPose.idle,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deni (데니)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: EnpriveColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.deniIntro,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: EnpriveColors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary Thumb-Zone Actions (8-point grid, Brilliant tactile feel)
              EnpriveTactileButton(
                label: l10n.btnCheckApp,
                leading: const Icon(Symbols.apps_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  _showCheckAppModal(context, l10n);
                },
              ),
              const SizedBox(height: 12),
              EnpriveTactileButton(
                label: l10n.btnPasteTerms,
                isSecondary: true,
                leading: const Icon(Symbols.content_paste_rounded, size: 20),
                onPressed: () {
                  _showPasteModal(context, l10n);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckAppModal(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.btnCheckApp,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.permissionLimitationNotice,
                style: const TextStyle(color: EnpriveColors.inkSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              EnpriveTactileButton(
                label: 'Inspect Demo App (EduTrack)',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPasteModal(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.btnPasteTerms,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Paste terms text or policy URL...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              EnpriveTactileButton(
                label: l10n.btnContinue,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
