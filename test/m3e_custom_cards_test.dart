import 'package:enprive/core/theme/enprive_m3e_theme.dart';
import 'package:enprive/core/theme/enprive_tokens.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/deni_animated_mascot.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/m3e/enprive_m3e_components.dart';
import 'package:enprive/widgets/why_this_finding_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

Widget _wrapInM3EApp({
  required Widget child,
  ThemeMode mode = ThemeMode.light,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  bool disableAnimations = false,
}) {
  final activeData = EnpriveM3ETheme.resolve(
    mode: mode,
    platformBrightness: mode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light,
  );
  return MediaQuery(
    data: MediaQueryData(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: disableAnimations,
    ),
    child: M3EMaterialApp(
      data: activeData,
      typeface: EnpriveM3ETheme.typefaceConfig,
      autoTheming: false,
      dynamicColoring: false,
      initialTheme: activeData.brightness,
      theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
      darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
      locale: locale,
      localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      appBuilder: (context, innerChild) => EnpriveM3EBridgeScope(
        themeMode: mode,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: innerChild ?? const SizedBox.shrink(),
        ),
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  const sampleFinding = VerifiedFinding(
    id: 'finding_1',
    title: 'Precision Location Collected',
    category: FindingCategory.tracking,
    severity: FindingSeverity.medium,
    exactExcerpt: 'We collect GPS telemetry in the background to personalize local offers.',
    explanation:
        'Tracks location even when you are not actively using the app.',
    whatPolicySays: 'Discloses background GPS telemetry collection.',
    whatAndroidReports: 'ACCESS_BACKGROUND_LOCATION granted.',
    unknowns: ['Exact retention window not specified'],
    status: EvidenceStatus.sourceMatched,
    contextWindow: (
      before: 'Section 3 · Telemetry. ',
      matched: 'We collect GPS telemetry in the background to personalize local offers.',
      after: ' Opt out in system settings.',
    ),
  );

  group('Custom Tactile Material 3 Expressive Card Family', () {
    testWidgets(
      'EnpriveMaterialCardSurface applies grounded lip, depresses on tap, and respects disableAnimations',
      (WidgetTester tester) async {
        var tapCount = 0;

        await tester.pumpWidget(
          _wrapInM3EApp(
            child: EnpriveMaterialCardSurface(
              key: const Key('tactile_surface'),
              lipHeight: 4.0,
              borderRadius: BorderRadius.circular(24),
              onPressed: () => tapCount++,
              child: const Text('Interactive Card Body'),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(M3ECard), findsOneWidget);
        final shellFinder = find
            .descendant(
              of: find.byKey(const Key('tactile_surface')),
              matching: find.byType(AnimatedContainer),
            )
            .first;
        final shellRest = tester.widget<AnimatedContainer>(shellFinder);
        final restDecoration = shellRest.decoration! as BoxDecoration;
        expect(restDecoration.boxShadow, isNotEmpty);
        expect(restDecoration.boxShadow!.first.offset, const Offset(0, 4.0));
        expect(shellRest.margin, const EdgeInsets.only(top: 0, bottom: 4.0));

        // Pointer down compresses lip to 0 and shifts top margin to 4.0
        final center = tester.getCenter(find.text('Interactive Card Body'));
        final gesture = await tester.startGesture(center);
        await tester.pump(const Duration(milliseconds: 120));

        final pressedShell = tester.widget<AnimatedContainer>(shellFinder);
        final pressedDecoration = pressedShell.decoration! as BoxDecoration;
        expect(pressedDecoration.boxShadow, isNull);
        expect(
          pressedShell.margin,
          const EdgeInsets.only(top: 4.0, bottom: 0.0),
        );
        expect(pressedDecoration.borderRadius, BorderRadius.circular(19));

        await gesture.up();
        await tester.pumpAndSettle();
        expect(tapCount, 1);

        // Reduced motion disables press displacement
        await tester.pumpWidget(
          _wrapInM3EApp(
            disableAnimations: true,
            child: EnpriveMaterialCardSurface(
              key: const Key('reduced_surface'),
              lipHeight: 4.0,
              borderRadius: BorderRadius.circular(24),
              onPressed: () {},
              child: const Text('Reduced Motion Card'),
            ),
          ),
        );
        await tester.pump();

        final g2 = await tester.startGesture(
          tester.getCenter(find.text('Reduced Motion Card')),
        );
        await tester.pump();
        final reducedShell = tester.widget<AnimatedContainer>(
          find
              .descendant(
                of: find.byKey(const Key('reduced_surface')),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        expect(reducedShell.margin, const EdgeInsets.only(top: 0, bottom: 4.0));
        await g2.up();
        await tester.pump();
      },
    );

    testWidgets(
      'EnpriveBentoChoiceCard and compactOption show dual-cue selection across Light & Dark modes',
      (WidgetTester tester) async {
        var selectedMode = ThemeMode.light;

        await tester.pumpWidget(
          _wrapInM3EApp(
            mode: selectedMode,
            child: Column(
              children: [
                EnpriveBentoChoiceCard(
                  title: 'EduTrack Classroom',
                  metricHighlight: '04',
                  subtitle: 'Background GPS & Ad ID',
                  footerTag: 'REVIEW',
                  icon: LucideIcons.graduationCap,
                  selected: true,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: EnpriveBentoChoiceCard.compactOption(
                        title: 'Quick',
                        subtitle: '1 min',
                        icon: LucideIcons.sparkles,
                        selected: true,
                        onPressed: () => selectedMode = ThemeMode.dark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: EnpriveBentoChoiceCard.compactOption(
                        title: 'Full',
                        subtitle: 'Deep',
                        icon: LucideIcons.bookOpen,
                        selected: false,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        expect(find.text('EduTrack Classroom'), findsOneWidget);
        expect(find.text('04'), findsOneWidget);
        expect(find.text('REVIEW'), findsOneWidget);
        expect(find.byIcon(LucideIcons.check), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'EnpriveMetricTileCard, EnpriveQuoteCard (highlighted & selectable), EnpriveCompanionCard (peeking & inline), and EnpriveReceiptCard render cleanly in Dark Mode + 200% Scale + RTL',
      (WidgetTester tester) async {
        var opened = false;
        var deleted = false;
        var cardTapped = false;

        final receipt = PolicyReviewReceipt(
          id: 'rcpt_card_test',
          subjectTitle: 'StudyBuddy Reader',
          sourceLabel: 'Installed App',
          createdAt: DateTime(2026, 11, 14, 15, 20),
          overallState: ReviewOverallState.reviewRecommended,
          inferenceSource: InferenceSource.onDevice,
          summary: 'Shares analytics ID with embedded measurement SDK.',
          calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
          snapshotText: sampleFinding.exactExcerpt,
          snapshotDigest: 'a1b2c3d4e5f6',
          findings: const [sampleFinding],
        );

        await tester.pumpWidget(
          _wrapInM3EApp(
            mode: ThemeMode.dark,
            locale: const Locale('ar'),
            textScale: 2.0,
            disableAnimations: true,
            child: Column(
              children: [
                const EnpriveMetricTileCard(
                  value: '03',
                  label: 'Matched Clauses',
                  sublabel: '100% aligned',
                  icon: LucideIcons.quote,
                  meterFraction: 0.75,
                ),
                const SizedBox(height: 12),
                EnpriveQuoteCard(
                  statusLabel: 'Source matched',
                  categoryLabel: 'Location',
                  contextWindow: sampleFinding.contextWindow,
                  sha256Digest: 'a1b2c3d4e5f6',
                ),
                const SizedBox(height: 12),
                const EnpriveQuoteCard(
                  statusLabel: 'Scrubbed preview',
                  quote:
                      'Scrubbed snippet [EMAIL] protected prior to transfer.',
                  selectable: true,
                ),
                const SizedBox(height: 12),
                const EnpriveCompanionCard(
                  pose: DeniPose.celebrating,
                  layout: EnpriveCompanionLayout.peeking,
                  badgeText: 'ON THIS PHONE',
                  title: 'Private by default',
                  message: 'Device inspection never leaves your handset.',
                ),
                const SizedBox(height: 12),
                EnpriveReceiptCard(
                  receipt: receipt,
                  stateBadgeLabel: 'Review recommended',
                  metaLine: 'Installed App · Nov 14',
                  openLabel: 'Open receipt',
                  deleteTooltip: 'Delete receipt',
                  onOpen: () => opened = true,
                  onDelete: () => deleted = true,
                ),
                const SizedBox(height: 12),
                EnpriveFindingM3ECard(
                  finding: sampleFinding,
                  index: 0,
                  totalCount: 2,
                  categoryLabel: 'Tracking',
                  verificationLabel: 'Quote verified',
                  onTapCard: () => cardTapped = true,
                ),
                const SizedBox(height: 4),
                EnpriveSegmentedCardTile(
                  index: 1,
                  totalCount: 2,
                  onTap: () {},
                  child: const Text('Segmented Tile 2'),
                ),
              ],
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        expect(find.byType(SelectableText), findsOneWidget);
        expect(find.byType(DeniAnimatedMascot), findsOneWidget);

        await tester.ensureVisible(find.text('Open receipt'));
        await tester.tap(find.text('Open receipt'));
        await tester.pump();
        expect(opened, isTrue);

        await tester.ensureVisible(find.byTooltip('Delete receipt'));
        await tester.tap(find.byTooltip('Delete receipt'));
        await tester.pump();
        expect(deleted, isTrue);

        await tester.ensureVisible(find.text('Precision Location Collected'));
        await tester.tap(find.text('Precision Location Collected'));
        await tester.pump();
        expect(cardTapped, isTrue);
      },
    );

    testWidgets(
      'EnpriveReceiptCard renders compact verdict/metrics dock without SHA-256 clutter in Dark Mode + 200% Scale + RTL',
      (WidgetTester tester) async {
        const unverifiedFinding = VerifiedFinding(
          id: 'finding_2',
          title: 'Retention Duration Missing',
          category: FindingCategory.retention,
          severity: FindingSeverity.low,
          exactExcerpt: '',
          explanation: 'No specific deletion timeframe stated.',
          whatPolicySays: 'Vague retention wording.',
          whatAndroidReports: 'No permission mismatch.',
          unknowns: ['Exact retention window'],
          status: EvidenceStatus.unverified,
        );
        final receipt = PolicyReviewReceipt(
          id: 'rcpt_bento_test',
          subjectTitle: 'EduTrack Classroom',
          sourceLabel: 'Installed App',
          createdAt: DateTime(2026, 11, 14, 15, 20),
          overallState: ReviewOverallState.reviewRecommended,
          inferenceSource: InferenceSource.onDevice,
          summary: 'Shares analytics ID and GPS telemetry with embedded SDKs.',
          calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
          snapshotText: sampleFinding.exactExcerpt,
          snapshotDigest: 'a1b2c3d4e5f6',
          findings: const [sampleFinding, unverifiedFinding],
        );

        var opened = false;
        var deleted = false;

        await tester.pumpWidget(
          _wrapInM3EApp(
            mode: ThemeMode.dark,
            locale: const Locale('ar'),
            textScale: 2.0,
            disableAnimations: true,
            child: EnpriveReceiptCard(
              receipt: receipt,
              stateBadgeLabel: 'Review recommended',
              metaLine: 'Installed App · Nov 14, 15:20',
              openLabel: 'Open receipt',
              deleteTooltip: 'Delete receipt',
              findingsLabel: 'Findings',
              verifiedLabel: 'Verified',
              onOpen: () => opened = true,
              onDelete: () => deleted = true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('EduTrack Classroom'), findsOneWidget);
        expect(find.text('Review recommended'), findsOneWidget);
        expect(find.text('2 Findings · 1 Verified'), findsOneWidget);
        expect(find.textContaining('SHA-256'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text('Open receipt'));
        await tester.tap(find.text('Open receipt'));
        await tester.pump();
        expect(opened, isTrue);

        await tester.ensureVisible(find.byTooltip('Delete receipt'));
        await tester.tap(find.byTooltip('Delete receipt'));
        await tester.pump();
        expect(deleted, isTrue);
      },
    );

    test('EnpriveFindingM3ECard enforces single-action rule (onTapCard XOR onAskDeni)', () {
      expect(
        () => EnpriveFindingM3ECard(
          finding: sampleFinding,
          index: 0,
          totalCount: 1,
          onTapCard: () {},
          onAskDeni: () {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets(
      'EnpriveSegmentedCardTile applies 22dp outer cap and 6dp inner seam radii',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapInM3EApp(
            child: Column(
              children: const [
                EnpriveSegmentedCardTile(
                  key: Key('seg_0'),
                  index: 0,
                  totalCount: 3,
                  child: Text('First'),
                ),
                EnpriveSegmentedCardTile(
                  key: Key('seg_1'),
                  index: 1,
                  totalCount: 3,
                  child: Text('Middle'),
                ),
                EnpriveSegmentedCardTile(
                  key: Key('seg_2'),
                  index: 2,
                  totalCount: 3,
                  child: Text('Last'),
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        final first = tester.widget<EnpriveMaterialCardSurface>(
          find.descendant(
            of: find.byKey(const Key('seg_0')),
            matching: find.byType(EnpriveMaterialCardSurface),
          ),
        );
        final middle = tester.widget<EnpriveMaterialCardSurface>(
          find.descendant(
            of: find.byKey(const Key('seg_1')),
            matching: find.byType(EnpriveMaterialCardSurface),
          ),
        );
        final last = tester.widget<EnpriveMaterialCardSurface>(
          find.descendant(
            of: find.byKey(const Key('seg_2')),
            matching: find.byType(EnpriveMaterialCardSurface),
          ),
        );

        expect(first.borderRadius.topLeft.x, 22.0);
        expect(first.borderRadius.bottomLeft.x, 6.0);
        expect(middle.borderRadius.topLeft.x, 6.0);
        expect(middle.borderRadius.bottomLeft.x, 6.0);
        expect(last.borderRadius.topLeft.x, 6.0);
        expect(last.borderRadius.bottomLeft.x, 22.0);
        expect(EnpriveRadii.lg, 20.0);
      },
    );

    testWidgets(
      'EnpriveReviewHeroCard renders Light/Dark editorial hero banner, borderless metrics, and interactive arrow CTA cleanly including 200% Arabic RTL',
      (WidgetTester tester) async {
        var sourceTapped = false;
        var voiceTapped = false;
        var ctaTapped = false;
        var mascotTapped = false;

        await tester.pumpWidget(
          _wrapInM3EApp(
            mode: ThemeMode.light,
            child: EnpriveReviewHeroCard(
              subjectTitle: 'EduTrack Classroom',
              subtitle: 'Classroom Sample · Nov 14',
              overallState: ReviewOverallState.reviewRecommended,
              stateBadgeLabel: 'Review recommended',
              findingsCountValue: '2',
              findingsLabel: 'Findings',
              verifiedCountValue: '2',
              verifiedLabel: 'Verified',
              secondaryMetricValue: '1',
              secondaryMetricLabel: 'OS Granted',
              hasPermissionReport: true,
              mascotPose: DeniPose.explaining,
              sourceActionLabel: 'Source',
              sourceActionTooltip: 'View reviewed policy snapshot',
              onSourceAction: () => sourceTapped = true,
              isSpeaking: false,
              voiceTooltip: 'Read summary aloud',
              onVoiceAction: () => voiceTapped = true,
              primaryCtaLabel: 'Ask Deni',
              onPrimaryCta: () => ctaTapped = true,
              onMascotTap: () => mascotTapped = true,
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(EnpriveReviewHeroCard), findsOneWidget);
        expect(find.byType(DeniAnimatedMascot), findsOneWidget);
        expect(find.text('EduTrack Classroom'), findsOneWidget);
        expect(find.text('Review recommended'), findsOneWidget);
        expect(find.text('Findings'), findsOneWidget);
        expect(find.text('Verified'), findsOneWidget);
        expect(find.text('OS Granted'), findsOneWidget);

        await tester.tap(find.text('Source'));
        await tester.pump();
        expect(sourceTapped, isTrue);

        await tester.tap(find.byTooltip('Read summary aloud'));
        await tester.pump();
        expect(voiceTapped, isTrue);

        await tester.tap(find.byType(DeniAnimatedMascot));
        await tester.pump();
        expect(mascotTapped, isTrue);

        await tester.tap(find.text('Ask Deni'));
        await tester.pump();
        expect(ctaTapped, isTrue);
        expect(tester.takeException(), isNull);

        // Dark mode + Arabic RTL + 200% text scaling + reduced motion
        await tester.pumpWidget(
          _wrapInM3EApp(
            mode: ThemeMode.dark,
            locale: const Locale('ar'),
            textScale: 2.0,
            disableAnimations: true,
            child: EnpriveReviewHeroCard(
              subjectTitle: 'تطبيق EduTrack المدرسي التعليمي',
              subtitle: 'عينة الفصل الدراسي · ١٤ نوفمبر',
              overallState: ReviewOverallState.noConcern,
              stateBadgeLabel: 'لا توجد مخاوف محددة',
              findingsCountValue: '0',
              findingsLabel: 'النتائج',
              verifiedCountValue: '0',
              verifiedLabel: 'موثقة',
              secondaryMetricValue: '0',
              secondaryMetricLabel: 'أذونات النظام',
              hasPermissionReport: false,
              mascotPose: DeniPose.celebrating,
              sourceActionLabel: 'المصدر',
              sourceActionTooltip: 'عرض نسخة السياسة',
              onSourceAction: () {},
              isSpeaking: true,
              voiceTooltip: 'إيقاف القراءة',
              onVoiceAction: () {},
              primaryCtaLabel: 'حفظ في الإيصالات',
              onPrimaryCta: () {},
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(EnpriveReviewHeroCard), findsOneWidget);
        expect(find.byType(DeniAnimatedMascot), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'P0-E & Section 7: Digest labels use FNV-1a 64-bit with copy action and neutral document icons without green safety seals',
      (WidgetTester tester) async {
        String? copiedDigestText;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedDigestText =
                (call.arguments as Map<dynamic, dynamic>)['text'] as String?;
          }
          return null;
        });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null);
        });

        await tester.pumpWidget(
          _wrapInM3EApp(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const EnpriveQuoteCard(
                    quote: 'We do not sell student records.',
                    sha256Digest: '1234abcd5678ef90',
                  ),
                  const SizedBox(height: 16),
                  const EnpriveCollapsibleQuoteBox(
                    headerLabel: 'Reviewed Excerpt',
                    quote: 'Progress stays strictly on device.',
                    sha256Digest: 'fedcba9876543210',
                    initiallyExpanded: true,
                  ),
                  const SizedBox(height: 16),
                  const EnpriveProvenanceChip(
                    source: InferenceSource.offlineDeterministic,
                  ),
                  const SizedBox(height: 16),
                  EnpriveReviewHeroCard(
                    subjectTitle: 'CalmMath Kids',
                    subtitle: 'Synthetic example · Nov 15',
                    overallState: ReviewOverallState.noConcern,
                    stateBadgeLabel: 'No concern identified',
                    findingsCountValue: '0',
                    findingsLabel: 'Findings',
                    verifiedCountValue: '0',
                    verifiedLabel: 'Verified',
                    secondaryMetricValue: '0',
                    secondaryMetricLabel: 'OS Granted',
                    hasPermissionReport: false,
                    mascotPose: DeniPose.celebrating,
                    sourceActionLabel: 'Source',
                    sourceActionTooltip: 'View snapshot',
                    onSourceAction: () {},
                    isSpeaking: false,
                    voiceTooltip: 'Read aloud',
                    onVoiceAction: () {},
                    primaryCtaLabel: 'Save',
                    onPrimaryCta: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.textContaining('SHA-256'), findsNothing);
        expect(
          find.text('Snapshot digest · FNV-1a 64-bit · 1234abcd5678ef90'),
          findsOneWidget,
        );
        expect(
          find.text('Snapshot digest · FNV-1a 64-bit · fedcba9876543210'),
          findsOneWidget,
        );
        expect(find.byIcon(LucideIcons.shieldCheck), findsNothing);
        expect(find.byIcon(LucideIcons.fileText), findsWidgets);

        final copyButton = find.byIcon(LucideIcons.copy).first;
        await tester.ensureVisible(copyButton);
        await tester.tap(copyButton);
        await tester.pump();
        expect(copiedDigestText, equals('1234abcd5678ef90'));
      },
    );

    test(
      'VerifiedFinding predicates and PolicyReviewReceipt metrics count policy matches independently from DEVICE_OBSERVED findings',
      () {
        const policyMatched = sampleFinding;
        const deviceCam = VerifiedFinding(
          id: 'perm_camera',
          title: 'Undisclosed Android Permission: Camera',
          category: FindingCategory.dataCollection,
          severity: FindingSeverity.medium,
          exactExcerpt:
              'Android Manifest Observation: android.permission.CAMERA (REQUESTED) — no matching disclosure found in policy snapshot.',
          explanation: 'Camera permission declared without matching policy clause.',
          whatPolicySays:
              'No clause in the provided policy snapshot mentions camera.',
          whatAndroidReports: 'Declared · Currently denied',
          unknowns: ['Not a safety certification.'],
          status: EvidenceStatus.deviceObserved,
        );
        const deviceMic = VerifiedFinding(
          id: 'perm_mic',
          title: 'Undisclosed Android Permission: Microphone',
          category: FindingCategory.retention,
          severity: FindingSeverity.high,
          exactExcerpt:
              'Android Manifest Observation: android.permission.RECORD_AUDIO (GRANTED) — no matching disclosure found in policy snapshot.',
          explanation: 'Microphone granted without matching policy clause.',
          whatPolicySays:
              'No clause in the provided policy snapshot mentions microphone.',
          whatAndroidReports: 'Declared · Currently granted',
          unknowns: ['Not a safety certification.'],
          status: EvidenceStatus.deviceObserved,
        );
        const unverifiedClaim = VerifiedFinding(
          id: 'f_unverified',
          title: 'Retained Logs',
          category: FindingCategory.retention,
          severity: FindingSeverity.low,
          exactExcerpt: 'Server logs may persist.',
          explanation: 'Unmatched claim.',
          whatPolicySays: 'No verbatim clause found.',
          whatAndroidReports: 'None',
          unknowns: ['Duration unknown'],
          status: EvidenceStatus.unverified,
        );

        expect(policyMatched.isSourceMatched, isTrue);
        expect(policyMatched.isDeviceObserved, isFalse);
        expect(policyMatched.isVerified, isTrue);

        expect(deviceCam.isSourceMatched, isFalse);
        expect(deviceCam.isDeviceObserved, isTrue);
        expect(deviceCam.isVerified, isTrue);

        expect(unverifiedClaim.isSourceMatched, isFalse);
        expect(unverifiedClaim.isDeviceObserved, isFalse);
        expect(unverifiedClaim.isVerified, isFalse);

        final mixedReceipt = PolicyReviewReceipt(
          id: 'rcpt_mixed_metrics',
          subjectTitle: 'Mixed Evidence App',
          sourceLabel: 'https://mixed.example/privacy',
          snapshotText: sampleFinding.exactExcerpt,
          snapshotDigest: 'fnv_mixed',
          createdAt: DateTime(2026, 11, 18),
          overallState: ReviewOverallState.reviewRecommended,
          inferenceSource: InferenceSource.offlineDeterministic,
          summary: 'Mixed evidence summary.',
          calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
          findings: const [
            policyMatched,
            deviceCam,
            deviceMic,
            unverifiedClaim,
          ],
        );

        expect(mixedReceipt.sourceMatchedCount, 1);
        expect(mixedReceipt.deviceObservedCount, 2);
        expect(mixedReceipt.unverifiedCount, 1);
        expect(mixedReceipt.verifiedEvidenceCount, 3);
      },
    );

    testWidgets(
      'EnpriveFindingM3ECard, WhyThisFindingSheet, EnpriveReceiptCard, and ReviewResultScreen separate DEVICE_OBSERVED from verified policy quotes',
      (WidgetTester tester) async {
        const observationText =
            'Android Manifest Observation: android.permission.CAMERA (REQUESTED) — no matching disclosure found in policy snapshot.';
        const deviceFinding = VerifiedFinding(
          id: 'perm_camera',
          title: 'Undisclosed Android Permission: Camera',
          category: FindingCategory.dataCollection,
          severity: FindingSeverity.medium,
          exactExcerpt: observationText,
          explanation: 'App declares CAMERA in APK manifest.',
          whatPolicySays:
              'No clause in the provided policy snapshot mentions camera.',
          whatAndroidReports: 'Camera: Denied on this device',
          unknowns: ['Actual camera usage cannot be seen statically.'],
          status: EvidenceStatus.deviceObserved,
        );

        final mixedReceipt = PolicyReviewReceipt(
          id: 'rcpt_ui_sep',
          subjectTitle: 'Math Makers',
          sourceLabel: 'https://ululab.com/privacy-policy/',
          snapshotText: sampleFinding.exactExcerpt,
          snapshotDigest: '1234abcd5678ef90',
          createdAt: DateTime(2026, 11, 18, 12, 0),
          overallState: ReviewOverallState.reviewRecommended,
          inferenceSource: InferenceSource.offlineDeterministic,
          summary: '1 policy match and 1 Android observation.',
          calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
          findings: const [sampleFinding, deviceFinding],
          permissionReport: const AppPermissionComparisonReport(
            snapshot: AppPermissionSnapshot(
              packageName: 'com.ululab.numbers',
              appName: 'Math Makers',
              requestedPermissions: ['android.permission.CAMERA'],
              grantedPermissions: [],
            ),
            items: [],
            limitationNotice: 'Permission list comes from APK manifest.',
          ),
        );

        // 1. Default EnpriveFindingM3ECard without manual verificationLabel override
        await tester.pumpWidget(
          _wrapInM3EApp(
            disableAnimations: true,
            child: Column(
              children: [
                EnpriveFindingM3ECard(
                  finding: deviceFinding,
                  index: 0,
                  totalCount: 2,
                  sha256Preview: '1234abcd5678ef90',
                  onTapCard: () {},
                ),
                const SizedBox(height: 12),
                EnpriveReceiptCard(
                  receipt: mixedReceipt,
                  stateBadgeLabel: 'Review recommended',
                  metaLine: 'ululab.com · Nov 18',
                  openLabel: 'Open',
                  deleteTooltip: 'Delete',
                  findingsLabel: 'Findings',
                  verifiedLabel: 'Verified',
                  deviceObservedLabel: 'Device observed',
                  onOpen: () {},
                  onDelete: () {},
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        expect(find.text('DEVICE OBSERVED'), findsOneWidget);
        expect(find.text('QUOTE MATCHED'), findsNothing);
        expect(find.text('“$observationText”'), findsNothing);
        expect(find.text(observationText), findsOneWidget);
        expect(
          find.text('No clause in the provided policy snapshot mentions camera.'),
          findsOneWidget,
        );
        expect(find.textContaining('Snapshot digest'), findsNothing);
        expect(
          find.text('2 Findings · 1 Verified · 1 Device observed'),
          findsOneWidget,
        );

        // 2. WhyThisFindingSheet on a DEVICE_OBSERVED finding never quotes manifest note in curly quotes
        final coordinator = ReviewCoordinator();
        await tester.pumpWidget(
          _wrapInM3EApp(
            disableAnimations: true,
            child: SizedBox(
              height: 760,
              child: WhyThisFindingSheet(
                finding: deviceFinding,
                snapshotText: sampleFinding.exactExcerpt,
                snapshotDigest: '1234abcd5678ef90',
                coordinator: coordinator,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Device observed'), findsOneWidget);
        expect(find.text('Source matched'), findsNothing);
        expect(find.text('“$observationText”'), findsNothing);
        expect(find.text(observationText), findsOneWidget);

        // 3. ReviewResultScreen hero count reflects ONLY sourceMatchedCount (1) vs Findings (2)
        final activeData = EnpriveM3ETheme.resolve(
          mode: ThemeMode.light,
          platformBrightness: Brightness.light,
        );
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: M3EMaterialApp(
              data: activeData,
              typeface: EnpriveM3ETheme.typefaceConfig,
              autoTheming: false,
              dynamicColoring: false,
              initialTheme: activeData.brightness,
              theme: EnpriveM3ETheme.lightThemeData.toThemeData(),
              darkTheme: EnpriveM3ETheme.darkThemeData.toThemeData(),
              locale: const Locale('en'),
              localizationsDelegates: EnpriveM3ETheme.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: ReviewResultScreen(
                receipt: mixedReceipt,
                coordinator: coordinator,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Quote verified in policy'), findsOneWidget);
        expect(find.text('Observed on this phone'), findsOneWidget);
        expect(
          find.text('1 Quote verified in policy · 1 Observed on this phone'),
          findsOneWidget,
        );
      },
    );
  });
}
