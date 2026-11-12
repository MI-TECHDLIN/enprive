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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final HybridAiBridge _bridge = HybridAiBridge();
  DeviceCapability? _deviceCapability;
  bool _isLoadingCapability = true;
  DeniPose _activePose = DeniPose.idle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDeviceAndIntent();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIncomingTextIntent();
    }
  }

  Future<void> _initializeDeviceAndIntent() async {
    final cap = await _bridge.getDeviceCapability();
    if (mounted) {
      setState(() {
        _deviceCapability = cap;
        _isLoadingCapability = false;
      });
    }
    await _checkIncomingTextIntent();
  }

  Future<void> _checkIncomingTextIntent() async {
    final incomingText = await _bridge.getInitialSelectedText();
    if (!mounted || incomingText == null || incomingText.isEmpty) return;

    setState(() {
      _activePose = DeniPose.thinking;
    });

    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      _showPasteModal(context, l10n, initialText: incomingText);
    }
  }

  void _cyclePose() {
    const poses = DeniPose.values;
    final nextIndex = (poses.indexOf(_activePose) + 1) % poses.length;
    setState(() {
      _activePose = poses[nextIndex];
    });
  }

  String _poseLabel(DeniPose pose, bool isKorean) {
    return switch (pose) {
      DeniPose.idle => isKorean ? '환영' : 'Welcome',
      DeniPose.thinking => isKorean ? '분석 중' : 'Thinking',
      DeniPose.explaining => isKorean ? '근거 설명' : 'Explaining',
      DeniPose.listening => isKorean ? '음성 안내' : 'Listening',
      DeniPose.support => isKorean ? '확인 필요' : 'Support',
      DeniPose.celebrating => isKorean ? '검토 완료' : 'Complete',
    };
  }

  String _poseDialogue(DeniPose pose, AppLocalizations l10n, bool isKorean) {
    return switch (pose) {
      DeniPose.idle => l10n.deniIntro,
      DeniPose.thinking => isKorean
          ? '기기 내 Gemini Nano로 약관 문장을 대조하고 있어요. 외부로 전송되지 않습니다.'
          : 'Matching policy clauses on-device with Gemini Nano. Nothing leaves your phone.',
      DeniPose.explaining => isKorean
          ? '발견된 모든 항목은 원문 약관의 정확한 인용구와 함께 표시됩니다.'
          : 'Every finding is anchored to a verbatim quote from the captured policy snapshot.',
      DeniPose.listening => isKorean
          ? '결과 요약을 한국어 또는 영어로 차분하게 읽어드릴 수 있어요.'
          : 'I can read the evidence summary aloud in English or Korean whenever you are ready.',
      DeniPose.support => isKorean
          ? '원문에서 확인할 수 없는 내용은 추측하지 않고 미확인으로 투명하게 안내해 드려요.'
          : 'If a claim cannot be matched to the source text, I mark it unverified rather than guessing.',
      DeniPose.celebrating => l10n.stateNoConcernSubtitle,
    };
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: EnpriveColors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: EnpriveColors.teal.withValues(alpha: 0.24),
                ),
              ),
              child: const Text(
                'NANO 4',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: EnpriveColors.tealStrong,
                ),
              ),
            ),
          ],
        ),
        actions: [
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Provenance / Hardware Readiness Bar
                      Row(
                        children: [
                          const EnpriveProvenanceChip(
                            source: InferenceSource.onDevice,
                            customLabel: 'Private by default',
                          ),
                          const Spacer(),
                          if (_isLoadingCapability)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: EnpriveColors.teal.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _deviceCapability?.isSupported == true
                                    ? 'Device Ready'
                                    : 'Hardware Scout',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: EnpriveColors.inkSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // F-Pattern Hero Headline (100% Ink Hierarchy)
                      Text(
                        isKorean
                            ? '아이들이 사용하는 앱의\n개인정보를 더 명확하게.'
                            : 'A clearer look at the\napps children use.',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),

                      // Reassurance Subtitle (70% Ink Secondary Hierarchy)
                      Text(
                        l10n.homePrivacySubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: EnpriveColors.inkSecondary,
                            ),
                      ),

                      const SizedBox(height: 24),

                      // Elevated Deni Character Stage Card (mobile-app-ui-design:
                      // 24dp card padding, 5% primary border, tinted soft shadow, interactive feedback)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: EnpriveColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: EnpriveColors.teal.withValues(alpha: 0.14),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0E4A43)
                                  .withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Sculpted Concept C Animated Mascot with Ambient Glow
                                DeniAnimatedMascot(
                                  size: 88,
                                  pose: _activePose,
                                  onTap: _cyclePose,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Deni (데니)',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: EnpriveColors.ink,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: EnpriveColors.teal
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              _poseLabel(
                                                  _activePose, isKorean),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: EnpriveColors.tealStrong,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        child: Text(
                                          _poseDialogue(
                                              _activePose, l10n, isKorean),
                                          key: ValueKey<String>(
                                            '${_activePose.name}_$isKorean',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            height: 1.45,
                                            color: EnpriveColors.inkSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Interactive 6-Pose Expression Selector Pills
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: DeniPose.values.map((pose) {
                                  final isSelected = pose == _activePose;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: () {
                                        setState(() => _activePose = pose);
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? EnpriveColors.teal
                                                  .withValues(alpha: 0.12)
                                              : EnpriveColors.paper,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: isSelected
                                                ? EnpriveColors.teal
                                                : EnpriveColors.ink.withValues(
                                                    alpha: 0.10,
                                                  ),
                                          ),
                                        ),
                                        child: Text(
                                          _poseLabel(pose, isKorean),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? EnpriveColors.tealStrong
                                                : EnpriveColors.inkSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),

                      // Primary Thumb-Zone Actions (bottom 1/3 of screen, 8-point grid)
                      EnpriveTactileButton(
                        label: l10n.btnCheckApp,
                        leading: const Icon(
                          Symbols.apps_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _activePose = DeniPose.explaining);
                          _showCheckAppModal(context, l10n);
                        },
                      ),
                      const SizedBox(height: 12),
                      EnpriveTactileButton(
                        label: l10n.btnPasteTerms,
                        isSecondary: true,
                        leading:
                            const Icon(Symbols.content_paste_rounded, size: 20),
                        onPressed: () {
                          setState(() => _activePose = DeniPose.thinking);
                          _showPasteModal(context, l10n);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
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
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.permissionLimitationNotice,
                style: const TextStyle(
                  color: EnpriveColors.inkSecondary,
                  fontSize: 13,
                ),
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

  void _showPasteModal(
    BuildContext context,
    AppLocalizations l10n, {
    String? initialText,
  }) {
    final controller = TextEditingController(text: initialText ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.btnPasteTerms,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
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
