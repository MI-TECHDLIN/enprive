import 'package:enprive/core/theme/enprive_colors.dart';
import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/main.dart';
import 'package:enprive/screens/design_system_preview_screen.dart';
import 'package:enprive/screens/receipts_screen.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/services/storage/receipt_repository.dart';
import 'package:enprive/widgets/analysis_process_trace.dart';
import 'package:enprive/widgets/deni_animated_mascot.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/installed_app_picker_sheet.dart';
import 'package:enprive/widgets/m3e/enprive_m3e_components.dart';
import 'package:enprive/widgets/review_progress_sheet.dart';
import 'package:enprive/widgets/why_this_finding_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Stage 0 — M3E ColorScheme, WCAG 2.1 Contrast & HCT Palette Verification', () {
    test(
      'All Light Mode text, semantic, provenance, interactive, and disabled pairs meet WCAG AA/AAA',
      () {
        final light = EnpriveTheme.lightTheme;
        final cs = light.colorScheme;
        final surfaces = light.extension<EnpriveSurfaceTokens>()!;
        final semantics = light.extension<EnpriveSemanticColors>()!;
        final m3eLight = EnpriveM3ETheme.lightColorScheme;

        expect(m3eLight.brightness, Brightness.light);
        expect(
          EnpriveContrast.contrastRatio(m3eLight.onPrimary, m3eLight.primary),
          greaterThanOrEqualTo(7.0),
          reason: 'M3E Light onPrimary on primary must exceed AAA (7:1)',
        );
        expect(
          EnpriveContrast.contrastRatio(cs.onSurface, surfaces.canvas),
          greaterThanOrEqualTo(14.0),
          reason: 'Light primary ink on warm paper must exceed AAA (7:1)',
        );
        expect(
          EnpriveContrast.contrastRatio(cs.onSurface, surfaces.card),
          greaterThanOrEqualTo(15.0),
        );
        expect(
          EnpriveContrast.contrastRatio(cs.onSurfaceVariant, surfaces.canvas),
          greaterThanOrEqualTo(6.5),
          reason: 'Light secondary ink on warm paper must exceed AA (4.5:1)',
        );
        expect(
          EnpriveContrast.contrastRatio(cs.outline, surfaces.canvas),
          greaterThanOrEqualTo(4.5),
          reason: 'Light muted/caption ink on warm paper must meet AA (4.5:1)',
        );

        final pairs = <String, SemanticColorPair>{
          'noConcern': semantics.noConcern,
          'reviewRecommended': semantics.reviewRecommended,
          'highConcern': semantics.highConcern,
          'insufficientEvidence': semantics.insufficientEvidence,
          'onDevice': semantics.onDevice,
          'inCloud': semantics.inCloud,
          'offlineFallback': semantics.offlineFallback,
          'unknown': semantics.unknown,
        };

        for (final entry in pairs.entries) {
          expect(
            entry.value.contrastRatio,
            greaterThanOrEqualTo(7.0),
            reason:
                'Light semantic pair ${entry.key} (${entry.value.contrastRatio.toStringAsFixed(2)}:1) must meet AAA (>= 7.0:1)',
          );
        }

        expect(
          EnpriveContrast.contrastRatio(
            surfaces.tactilePrimaryFg,
            surfaces.tactilePrimaryBg,
          ),
          greaterThanOrEqualTo(12.0),
        );
        expect(
          EnpriveContrast.contrastRatio(
            surfaces.tactileSecondaryFg,
            surfaces.tactileSecondaryBg,
          ),
          greaterThanOrEqualTo(14.0),
        );
        expect(
          EnpriveContrast.contrastRatio(
            surfaces.disabledFg,
            surfaces.disabledBg,
          ),
          greaterThanOrEqualTo(4.5),
          reason: 'Light disabled button text must remain legible (>= 4.5:1)',
        );
      },
    );

    test(
      'All Dark Mode text, semantic, provenance, interactive, and disabled pairs meet WCAG AA/AAA',
      () {
        final dark = EnpriveTheme.darkTheme;
        final cs = dark.colorScheme;
        final surfaces = dark.extension<EnpriveSurfaceTokens>()!;
        final semantics = dark.extension<EnpriveSemanticColors>()!;
        final m3eDark = EnpriveM3ETheme.darkColorScheme;

        expect(m3eDark.brightness, Brightness.dark);
        expect(
          EnpriveContrast.contrastRatio(m3eDark.onPrimary, m3eDark.primary),
          greaterThanOrEqualTo(8.5),
          reason: 'M3E Dark onPrimary on primary (#2DD4BF) must exceed AAA',
        );
        expect(
          EnpriveContrast.contrastRatio(cs.onSurface, surfaces.canvas),
          greaterThanOrEqualTo(15.0),
          reason: 'Dark primary cream ink on obsidian canvas must exceed AAA',
        );
        expect(
          EnpriveContrast.contrastRatio(cs.onSurface, surfaces.card),
          greaterThanOrEqualTo(13.0),
        );
        expect(
          EnpriveContrast.contrastRatio(cs.onSurfaceVariant, surfaces.card),
          greaterThanOrEqualTo(7.0),
          reason: 'Dark secondary ink on card surface must exceed AAA (7:1)',
        );
        expect(
          EnpriveContrast.contrastRatio(cs.outline, surfaces.card),
          greaterThanOrEqualTo(4.5),
          reason: 'Dark muted/caption ink on card surface must meet AA (4.5:1)',
        );

        final pairs = <String, SemanticColorPair>{
          'noConcern': semantics.noConcern,
          'reviewRecommended': semantics.reviewRecommended,
          'highConcern': semantics.highConcern,
          'insufficientEvidence': semantics.insufficientEvidence,
          'onDevice': semantics.onDevice,
          'inCloud': semantics.inCloud,
          'offlineFallback': semantics.offlineFallback,
          'unknown': semantics.unknown,
        };

        for (final entry in pairs.entries) {
          expect(
            entry.value.contrastRatio,
            greaterThanOrEqualTo(7.0),
            reason:
                'Dark semantic pair ${entry.key} (${entry.value.contrastRatio.toStringAsFixed(2)}:1) must meet AAA (>= 7.0:1)',
          );
        }

        expect(
          EnpriveContrast.contrastRatio(
            surfaces.tactilePrimaryFg,
            surfaces.tactilePrimaryBg,
          ),
          greaterThanOrEqualTo(8.5),
        );
        expect(
          EnpriveContrast.contrastRatio(
            surfaces.tactileSecondaryFg,
            surfaces.tactileSecondaryBg,
          ),
          greaterThanOrEqualTo(11.0),
        );
        expect(
          EnpriveContrast.contrastRatio(
            surfaces.disabledFg,
            surfaces.disabledBg,
          ),
          greaterThanOrEqualTo(4.5),
          reason: 'Dark disabled button text must remain legible (>= 4.5:1)',
        );
      },
    );

    test(
      'EnpriveHctPalette harmonizes semantic seeds toward Brand Teal and resolves contrast-safe tones',
      () {
        const rawCrimson = Color(0xFFDC2626);
        final harmonized = EnpriveHctPalette.harmonizeToBrand(rawCrimson);
        expect(harmonized, isNot(equals(rawCrimson)));

        final lightSafeTone = EnpriveHctPalette.contrastSafeTone(
          seed: rawCrimson,
          background: const Color(0xFFFDE8E9),
          initialTone: 35,
          darkerForContrast: true,
          minContrastRatio: 7.0,
        );
        expect(
          EnpriveContrast.contrastRatio(lightSafeTone, const Color(0xFFFDE8E9)),
          greaterThanOrEqualTo(7.0),
        );

        final darkSafeTone = EnpriveHctPalette.contrastSafeTone(
          seed: rawCrimson,
          background: const Color(0xFF321619),
          initialTone: 75,
          darkerForContrast: false,
          minContrastRatio: 7.0,
        );
        expect(
          EnpriveContrast.contrastRatio(darkSafeTone, const Color(0xFF321619)),
          greaterThanOrEqualTo(7.0),
        );
      },
    );

    test(
      'M3ETypography dual scales, ThemeExtensions, TypographyExtension tabular features, and grouped radii work cleanly',
      () {
        final m3eTypo = EnpriveM3ETheme.typography;
        expect(m3eTypo.baseline.displayLarge.fontFamily, 'Nunito');
        expect(m3eTypo.baseline.bodyLarge.fontFamily, 'Inter');
        expect(m3eTypo.emphasized.displayLarge.fontWeight, FontWeight.w900);
        expect(m3eTypo.emphasized.titleLarge.fontWeight, FontWeight.w800);

        final light = EnpriveTheme.lightTheme;
        final dark = EnpriveTheme.darkTheme;

        final typeExt = light.extension<EnpriveTypographyExtension>()!;
        expect(typeExt.policyQuotation.fontFamily, 'SourceSerif4');
        expect(
          typeExt.sha256Hash.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
        expect(
          typeExt.tabularMetricLarge.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );

        final firstRadius = EnpriveRadii.groupedCardRadius(index: 0, count: 3);
        final middleRadius = EnpriveRadii.groupedCardRadius(index: 1, count: 3);
        final lastRadius = EnpriveRadii.groupedCardRadius(index: 2, count: 3);
        expect(firstRadius.topLeft.x, 20.0);
        expect(firstRadius.bottomLeft.x, 6.0);
        expect(middleRadius.topLeft.x, 6.0);
        expect(lastRadius.topLeft.x, 6.0);
        expect(lastRadius.bottomLeft.x, 20.0);

        final midTheme = ThemeData.lerp(light, dark, 0.5);
        expect(midTheme.extension<EnpriveSemanticColors>(), isNotNull);
        expect(midTheme.extension<EnpriveSurfaceTokens>(), isNotNull);
        expect(midTheme.extension<EnpriveMotionTokens>(), isNotNull);
        expect(midTheme.extension<EnpriveTypographyExtension>(), isNotNull);
      },
    );
  });

  group('Stage 0 — M3EMaterialApp, M3E Component Catalog & Deni 3-Tier LOD', () {
    test('DeniAnimatedMascot.resolveTierForSize maps 52dp, 84dp, and 144dp accurately', () {
      expect(DeniAnimatedMascot.resolveTierForSize(48), DeniLodTier.compact);
      expect(DeniAnimatedMascot.resolveTierForSize(52), DeniLodTier.compact);
      expect(DeniAnimatedMascot.resolveTierForSize(64), DeniLodTier.compact);
      expect(DeniAnimatedMascot.resolveTierForSize(68), DeniLodTier.standard);
      expect(DeniAnimatedMascot.resolveTierForSize(84), DeniLodTier.standard);
      expect(DeniAnimatedMascot.resolveTierForSize(112), DeniLodTier.standard);
      expect(DeniAnimatedMascot.resolveTierForSize(116), DeniLodTier.hero);
      expect(DeniAnimatedMascot.resolveTierForSize(144), DeniLodTier.hero);
    });

    testWidgets(
      'EnpriveM3EStage0App boots M3EMaterialApp, renders M3E component catalog and Deni 3-tier LODs across Light, Dark, and RTL',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const EnpriveM3EStage0App(
            initialThemeMode: ThemeMode.light,
          ),
        );
        await tester.pump();

        // Verify M3EMaterialApp and M3E components are present
        expect(find.byType(M3EMaterialApp), findsOneWidget);
        expect(find.byType(M3EAppBar), findsOneWidget);
        expect(find.byKey(const Key('m3e_stage0_search_bar')), findsOneWidget);
        expect(find.byKey(const Key('m3e_stage0_wavy_progress')), findsOneWidget);
        expect(find.byType(M3ELoadingIndicator), findsOneWidget);
        expect(find.byKey(const Key('m3e_stage0_segmented_list')), findsOneWidget);
        expect(find.byType(M3EListItem), findsNWidgets(3));
        expect(find.byKey(const Key('m3e_stage0_nav_bar')), findsOneWidget);

        expect(find.text('LOD 1 · 52dp'), findsOneWidget);
        expect(find.text('LOD 2 · 84dp'), findsOneWidget);
        expect(find.text('LOD 3 · 144dp'), findsOneWidget);

        // Verify all 3 DeniAnimatedMascot instances resolve to compact, standard, and hero
        final mascots = tester
            .widgetList<DeniAnimatedMascot>(find.byType(DeniAnimatedMascot))
            .toList();
        expect(mascots.length, 3);
        expect(mascots[0].effectiveLodTier, DeniLodTier.compact);
        expect(mascots[1].effectiveLodTier, DeniLodTier.standard);
        expect(mascots[2].effectiveLodTier, DeniLodTier.hero);

        // Cycle through all 6 poses via M3EChip filter chips
        for (final pose in DeniPose.values) {
          final chipFinder = find.byKey(Key('lod_pose_chip_${pose.name}'));
          await tester.ensureVisible(chipFinder);
          await tester.tap(chipFinder);
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
        }

        // Toggle Dark Mode via M3ESegmentedButton
        await tester.tap(find.text('Dark'));
        await tester.pump(const Duration(milliseconds: 150));
        expect(tester.takeException(), isNull);

        // Scroll to M3EButtonGroup and M3EBottomSheet trigger
        final openSheetBtn = find.byKey(const Key('m3e_stage0_open_sheet_btn'));
        await tester.ensureVisible(openSheetBtn);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(openSheetBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('Why This Clause Matters'), findsOneWidget);
        final closeBtn = find.text('Got It · Close Sheet');
        await tester.ensureVisible(closeBtn);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(closeBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        // Verify Arabic RTL compatibility with MaterialUiCompatibilityBridge
        await tester.pumpWidget(
          const EnpriveM3EStage0App(
            initialThemeMode: ThemeMode.dark,
            locale: Locale('ar'),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'SettingsScreen switches between System, Light, and Dark ThemeMode inside M3EMaterialApp and persists preference',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({
          'enprive_pref_completed_onboarding': true,
        });
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('com.enprive/hybrid_ai'),
              (call) async {
                if (call.method == 'getDeviceCapability') {
                  return {
                    'isSupported': true,
                    'modelStatus': 'AVAILABLE',
                    'modelCategory': 'PREVIEW',
                    'apiLevel': 34,
                    'userMessage': 'Ready',
                  };
                }
                return null;
              },
            );

        await tester.pumpWidget(
          const EnpriveApp(showSplashOnLaunch: false),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Appearance'), findsOneWidget);
        final darkOption = find.byKey(const Key('theme_mode_option_dark'));
        expect(darkOption, findsOneWidget);
        await tester.ensureVisible(darkOption);
        await tester.pump(const Duration(milliseconds: 200));

        // Switch to Dark Mode
        await tester.tap(darkOption);
        await tester.pump(const Duration(milliseconds: 250));

        final m3eAppDark = tester.widget<M3EMaterialApp>(
          find.byType(M3EMaterialApp),
        );
        expect(m3eAppDark.initialTheme, Brightness.dark);

        final repo = UserPreferencesRepository();
        final loaded = await repo.load();
        expect(loaded.themeMode, ThemeMode.dark);

        // Switch to Light Mode
        await tester.tap(find.byKey(const Key('theme_mode_option_light')));
        await tester.pump(const Duration(milliseconds: 250));

        final m3eAppLight = tester.widget<M3EMaterialApp>(
          find.byType(M3EMaterialApp),
        );
        expect(m3eAppLight.initialTheme, Brightness.light);
      },
    );
  });

  group('Stage 1 — Reusable Enprive M3E Domain Components & Shared System Widgets', () {
    testWidgets(
      'EnpriveEditorialHeader, EnpriveBentoPostureCard, EnpriveFindingM3ECard, EnpriveCollapsibleQuoteBox, EnpriveSegmentedM3EGroup, EnpriveDeniStageCard, and ReviewProgressCard render cleanly in Light & Dark modes',
      (WidgetTester tester) async {
        var askDeniTapped = false;
        const sampleFinding = VerifiedFinding(
          id: 'f_1',
          title: 'Advertising ID Shared with Third Parties',
          category: FindingCategory.sharing,
          severity: FindingSeverity.high,
          exactExcerpt:
              'We may share persistent advertising identifiers with ad partners.',
          explanation:
              'Allows cross-app behavioral profiling unless restricted.',
          whatPolicySays: 'Discloses ad partner sharing.',
          whatAndroidReports: 'AD_ID permission declared.',
          unknowns: ['Partner list not enumerated'],
          status: EvidenceStatus.sourceMatched,
        );

        Widget buildStage1Harness({
          required ThemeMode mode,
          required bool autoCollapseQuote,
        }) {
          final activeData = EnpriveM3ETheme.resolve(
            mode: mode,
            platformBrightness: Brightness.light,
          );
          return M3EMaterialApp(
            data: activeData,
            typeface: EnpriveM3ETheme.typefaceConfig,
            autoTheming: false,
            dynamicColoring: false,
            initialTheme: activeData.brightness,
            theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
            darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
            localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
            appBuilder: (context, child) => EnpriveM3EBridgeScope(
              themeMode: mode,
              child: child ?? const SizedBox.shrink(),
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const EnpriveEditorialHeader(
                      overline: 'STAGE 1 SYSTEM',
                      primaryLine: 'Privacy Posture',
                      secondaryLine: 'Evidence-First M3E Components',
                    ),
                    const SizedBox(height: 12),
                    const EnpriveBentoPostureCard(
                      source: InferenceSource.onDevice,
                      primaryMetricValue: '04',
                      primaryMetricTitle: 'Verified Clauses',
                      primaryMetricSubtitle: '100% Quote Aligned',
                      topTileTitle: 'Nano 4',
                      topTileSubtitle: 'Local inference active',
                      isTopTileLoading: true,
                      bottomTileTitle: '01 Flag',
                      bottomTileSubtitle: 'Review recommended',
                      flagCount: 1,
                    ),
                    const SizedBox(height: 12),
                    EnpriveFindingM3ECard(
                      finding: sampleFinding,
                      index: 0,
                      totalCount: 2,
                      sha256Preview: '8f4b2e9c10a7',
                      onAskDeni: () => askDeniTapped = true,
                    ),
                    const SizedBox(height: 12),
                    EnpriveCollapsibleQuoteBox(
                      key: const Key('stage1_collapsible_quote'),
                      quote: sampleFinding.exactExcerpt,
                      sha256Digest: '8f4b2e9c10a74d3b',
                      autoCollapseTrigger: autoCollapseQuote,
                    ),
                    const SizedBox(height: 12),
                    const EnpriveSegmentedM3EGroup(
                      sectionTitle: 'Segmented Guardrails',
                      items: [
                        EnpriveSegmentedM3EItem(
                          overline: 'LOCAL ONLY',
                          title: 'Package inspection stays on phone',
                          supportingText: 'Never transmitted to cloud',
                          trailingMeta: 'ON-DEVICE',
                        ),
                        EnpriveSegmentedM3EItem(
                          overline: 'EVIDENCE',
                          title: 'Deterministic quote verification',
                          supportingText: 'Backed by EvidenceValidator',
                          trailingMeta: 'SHA-256',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const EnpriveDeniStageCard(
                      pose: DeniPose.support,
                      lodTier: DeniLodTier.standard,
                      badgeText: 'CALIBRATED GUIDANCE',
                      title: 'Deni Companion Stage',
                      message:
                          'No concern identified in the reviewed evidence. This is not a safety certification.',
                    ),
                    const SizedBox(height: 12),
                    const ReviewProgressCard(
                      subjectTitle: 'CalmMath Policy Snapshot',
                    ),
                    const SizedBox(height: 12),
                    const AnalysisSavedTraceCard(
                      processSteps: [
                        'Extracted local policy clauses',
                        'Verified quote alignment against SHA-256 snapshot',
                      ],
                      thoughtSummary:
                          'Checked ad identifier disclosure against manifest permissions.',
                      thoughtSignature: 'sig_98ab76cd54ef321098ab',
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        await tester.pumpWidget(
          buildStage1Harness(mode: ThemeMode.light, autoCollapseQuote: false),
        );
        await tester.pump();

        expect(find.text('STAGE 1 SYSTEM'), findsOneWidget);
        expect(find.text('Advertising ID Shared with Third Parties'), findsOneWidget);
        expect(find.text('QUOTE MATCHED'), findsOneWidget);
        expect(find.text('SHA-256 · 8f4b2e9c10a74d3b'), findsOneWidget);

        // Tap Ask Deni button on EnpriveFindingM3ECard
        final askDeniBtn = find.text('Ask Deni · Why this matters');
        await tester.ensureVisible(askDeniBtn);
        await tester.tap(askDeniBtn);
        await tester.pump();
        expect(askDeniTapped, isTrue);

        // Trigger auto-collapse on EnpriveCollapsibleQuoteBox and switch to Dark Mode
        await tester.pumpWidget(
          buildStage1Harness(mode: ThemeMode.dark, autoCollapseQuote: true),
        );
        await tester.pump(const Duration(milliseconds: 350));

        // When collapsed, the SHA-256 line inside EnpriveCollapsibleQuoteBox is hidden
        expect(find.text('SHA-256 · 8f4b2e9c10a74d3b'), findsNothing);

        // Expand AnalysisSavedTraceCard thoughts in Dark Mode
        final viewThoughtsToggle = find.text('View streamed thoughts & steps');
        if (viewThoughtsToggle.evaluate().isNotEmpty) {
          await tester.ensureVisible(viewThoughtsToggle);
          await tester.tap(viewThoughtsToggle);
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Stage 2 — Core Entry, Home & Input Flows M3E Migration', () {
    testWidgets(
      'InstalledAppPickerSheet renders M3ECard sample profiles, M3ESearchBar filtering, and Deni empty state',
      (WidgetTester tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('com.enprive/hybrid_ai'),
              (call) async {
                if (call.method == 'listLaunchableApps') {
                  return [
                    {
                      'appName': 'StudyBuddy Reader',
                      'packageName': 'org.example.studybuddy',
                      'versionName': '2.4.0',
                      'targetSdk': 34,
                      'isSystemApp': false,
                    },
                  ];
                }
                return null;
              },
            );

        final activeData = EnpriveM3ETheme.darkThemeData;
        await tester.pumpWidget(
          M3EMaterialApp(
            data: activeData,
            typeface: EnpriveM3ETheme.typefaceConfig,
            autoTheming: false,
            dynamicColoring: false,
            initialTheme: activeData.brightness,
            theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
            darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
            localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
            appBuilder: (context, child) => EnpriveM3EBridgeScope(
              themeMode: ThemeMode.dark,
              child: child ?? const SizedBox.shrink(),
            ),
            home: Scaffold(
              body: InstalledAppPickerSheet(
                bridge: HybridAiBridge(),
                eduTrackPolicyText: 'EduTrack sample policy text',
                calmMathPolicyText: 'CalmMath sample policy text',
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(M3ESearchBar), findsOneWidget);
        expect(find.text('EduTrack'), findsOneWidget);
        expect(find.text('CalmMath'), findsOneWidget);
        expect(find.text('StudyBuddy Reader'), findsOneWidget);

        // Filter to non-existent app to trigger DeniAnimatedMascot empty state
        await tester.enterText(find.byType(EditableText), 'NonExistentAppXYZ');
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(DeniAnimatedMascot), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Stage 3 — Review Result, Ask Deni, Receipts & Settings M3E Migration', () {
    testWidgets(
      'ReviewResultScreen, WhyThisFindingSheet, and ReceiptsScreen render M3E cards, M3EChip filters, and M3ESearchBar cleanly in Dark Mode',
      (WidgetTester tester) async {
        final coordinator = ReviewCoordinator();
        const finding = VerifiedFinding(
          id: 'f_stage3',
          title: 'Microphone Recording Disclosed',
          category: FindingCategory.dataCollection,
          severity: FindingSeverity.medium,
          exactExcerpt:
              'Voice fluency exercises record audio clips for teacher review.',
          explanation: 'Audio clips are recorded during reading fluency tasks.',
          whatPolicySays: 'Discloses audio recording for teacher review.',
          whatAndroidReports: 'RECORD_AUDIO requested.',
          unknowns: ['Retention duration after grading is not specified.'],
          status: EvidenceStatus.sourceMatched,
        );

        final receipt = PolicyReviewReceipt(
          id: 'rcpt_stage3',
          subjectTitle: 'EduTrack Classroom',
          sourceLabel: 'Sample Profile',
          createdAt: DateTime(2026, 11, 14, 15, 30),
          overallState: ReviewOverallState.reviewRecommended,
          inferenceSource: InferenceSource.onDevice,
          summary:
              'Review recommended: audio recording and sharing clauses identified.',
          calibratedDisclaimer:
              ReviewCoordinator.calibratedDefaultDisclaimer,
          snapshotText:
              'Voice fluency exercises record audio clips for teacher review.',
          snapshotDigest: 'a1b2c3d4e5f6',
          findings: const [finding],
        );

        final activeData = EnpriveM3ETheme.darkThemeData;
        await tester.pumpWidget(
          M3EMaterialApp(
            data: activeData,
            typeface: EnpriveM3ETheme.typefaceConfig,
            autoTheming: false,
            dynamicColoring: false,
            initialTheme: activeData.brightness,
            theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
            darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
            localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
            appBuilder: (context, child) => EnpriveM3EBridgeScope(
              themeMode: ThemeMode.dark,
              child: child ?? const SizedBox.shrink(),
            ),
            home: ReviewResultScreen(
              receipt: receipt,
              coordinator: coordinator,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('EduTrack Classroom'), findsOneWidget);
        expect(find.text('Microphone Recording Disclosed'), findsOneWidget);
        expect(find.byType(M3ECard), findsWidgets);

        // Open WhyThisFindingSheet by tapping the finding card
        final findingCardFinder = find.text('Microphone Recording Disclosed');
        await tester.ensureVisible(findingCardFinder);
        await tester.tap(findingCardFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(WhyThisFindingSheet), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -250));
        await tester.pump();
        expect(find.text('What does this mean for my child?'), findsOneWidget);

        // Close WhyThisFindingSheet modal route before pumping ReceiptsScreen
        Navigator.of(tester.element(find.byType(WhyThisFindingSheet))).pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // Now pump ReceiptsScreen in Dark Mode and test M3EChip filter + M3ESearchBar
        await tester.pumpWidget(
          M3EMaterialApp(
            data: activeData,
            typeface: EnpriveM3ETheme.typefaceConfig,
            autoTheming: false,
            dynamicColoring: false,
            initialTheme: activeData.brightness,
            theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
            darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
            localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
            appBuilder: (context, child) => EnpriveM3EBridgeScope(
              themeMode: ThemeMode.dark,
              child: child ?? const SizedBox.shrink(),
            ),
            home: Scaffold(
              body: ReceiptsScreen(
                receipts: [receipt],
                coordinator: coordinator,
                onDeleteReceipt: (_) {},
                onStartReviewRequested: () {},
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(M3EChip), findsNWidgets(3));
        expect(find.text('EduTrack Classroom'), findsOneWidget);

        // Toggle M3ESearchBar open
        await tester.tap(find.byTooltip('Search'));
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(M3ESearchBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
