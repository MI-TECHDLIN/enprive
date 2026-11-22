import 'package:enprive/core/theme/enprive_theme.dart';
import 'package:enprive/domain/permissions/permission_comparator.dart';
import 'package:enprive/domain/review/review_coordinator.dart';
import 'package:enprive/domain/review/review_models.dart';
import 'package:enprive/domain/voice/deni_voice_summary.dart';
import 'package:enprive/l10n/app_localizations.dart';
import 'package:enprive/screens/review_result_screen.dart';
import 'package:enprive/services/platform/hybrid_ai_bridge.dart';
import 'package:enprive/widgets/cloud_consent_sheet.dart';
import 'package:enprive/widgets/deni_voice_summary_card.dart';
import 'package:enprive/widgets/enprive_provenance_chip.dart';
import 'package:enprive/widgets/why_this_finding_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

class _RecordingVoiceBridge extends HybridAiBridge {
  final List<Map<String, Object?>> analyseCalls = [];
  final List<Map<String, Object?>> speakTextCalls = [];
  final List<Map<String, Object?>> geminiTtsCalls = [];
  int stopCalls = 0;

  bool localSpeakReturns = true;
  final HybridAnalysisResult Function(
    String task,
    bool cloudConsent,
    String text,
  )?
  analyseHandler;
  _RecordingVoiceBridge({
    this.analyseHandler,
  });

  final VoiceSpeakResult geminiTtsResult = const VoiceSpeakResult(
    status: 'fallback_local',
    route: VoicePlaybackRoute.androidLocalTts,
    modelName: 'gemini-3.8-flash-tts',
    fallbackReason: 'timeout',
    errorCode: 'TIMED_OUT',
    message:
        'Expressive cloud voice timed out. Using this phone’s offline voice instead.',
  );

  @override
  Future<HybridAnalysisResult> analyseText({
    required String requestId,
    required String task,
    required String text,
    required bool cloudConsent,
    String? requestedMode,
    String? sourceSnapshotId,
    String languageCode = 'en',
  }) async {
    analyseCalls.add({
      'requestId': requestId,
      'task': task,
      'text': text,
      'cloudConsent': cloudConsent,
      'requestedMode': requestedMode,
    });
    if (analyseHandler != null) {
      return analyseHandler!(task, cloudConsent, text);
    }
    return HybridAnalysisResult(
      schemaVersion: 1,
      requestId: requestId,
      status: HybridStatus.unavailable,
      inferenceSource: 'UNKNOWN',
      message: 'On-device AI unavailable on this device.',
    );
  }

  @override
  Future<bool> speakText(
    String text, {
    String languageCode = 'en',
    String? requestId,
    double? speechRate,
  }) async {
    speakTextCalls.add({
      'text': text,
      'languageCode': languageCode,
      'requestId': requestId,
    });
    return localSpeakReturns;
  }

  @override
  Future<VoiceSpeakResult> speakWithGeminiTts({
    required String requestId,
    required String text,
    required bool cloudConsent,
    String languageCode = 'en',
    bool fallbackToLocalOnFailure = true,
  }) async {
    if (!cloudConsent) {
      return const VoiceSpeakResult(
        status: 'blocked',
        route: VoicePlaybackRoute.none,
        errorCode: 'CLOUD_CONSENT_REQUIRED',
      );
    }
    geminiTtsCalls.add({
      'requestId': requestId,
      'text': text,
      'cloudConsent': cloudConsent,
      'languageCode': languageCode,
    });
    return geminiTtsResult;
  }

  @override
  Future<bool> stopSpeaking() async {
    stopCalls++;
    emitVoicePlaybackEvent(
      const VoicePlaybackEvent(
        requestId: 'stop',
        state: VoicePlaybackState.stopped,
        route: VoicePlaybackRoute.none,
      ),
    );
    return true;
  }
}

PolicyReviewReceipt _buildUiReceipt() {
  const snapshot =
      'EduTrack collects precise GPS location in the background even when the app is closed. '
      'Voice recordings are retained indefinitely to train speech models. '
      'Email privacy@edutrack.example for help.';

  return PolicyReviewReceipt(
    id: 'rcpt_ui_voice_1',
    subjectTitle: 'EduTrack Classroom',
    sourceLabel: 'Public URL',
    snapshotText: snapshot,
    snapshotDigest: 'abcdef1234567890',
    createdAt: DateTime.utc(2026, 11, 21, 18, 0),
    overallState: ReviewOverallState.reviewRecommended,
    inferenceSource: InferenceSource.offlineDeterministic,
    summary: '2 parts of this policy need a closer look.',
    calibratedDisclaimer: ReviewCoordinator.calibratedDefaultDisclaimer,
    findings: const [
      VerifiedFinding(
        id: 'f_gps',
        title: 'Tracks location in the background',
        category: FindingCategory.tracking,
        severity: FindingSeverity.high,
        exactExcerpt:
            'EduTrack collects precise GPS location in the background even when the app is closed.',
        explanation:
            'The policy says precise GPS location is collected in the background.',
        whatPolicySays: 'Exact match found.',
        whatAndroidReports: 'Checked locally.',
        unknowns: [
          'Contact privacy@edutrack.example for retention timelines.',
        ],
        status: EvidenceStatus.sourceMatched,
      ),
      VerifiedFinding(
        id: 'f_voice',
        title: 'Retains voice, audio, or biometric data',
        category: FindingCategory.retention,
        severity: FindingSeverity.high,
        exactExcerpt:
            'Voice recordings are retained indefinitely to train speech models.',
        explanation:
            'Voice recordings may be kept indefinitely to train speech models.',
        whatPolicySays: 'Exact match found.',
        whatAndroidReports: 'Checked locally.',
        unknowns: ['Deletion process is not specified.'],
        status: EvidenceStatus.sourceMatched,
      ),
    ],
    permissionReport: PermissionComparator.compare(
      snapshot: const AppPermissionSnapshot(
        packageName: 'edu.example.track',
        appName: 'EduTrack Classroom',
        requestedPermissions: ['android.permission.CAMERA'],
        grantedPermissions: ['android.permission.CAMERA'],
      ),
      policyText: snapshot,
    ),
  );
}

Widget _wrapScreen({
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
  return M3EMaterialApp(
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
    home: child,
  );
}

Future<void> _pumpFrames(WidgetTester tester, {int count = 6}) async {
  await tester.pump();
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

void main() {
  testWidgets(
    'ReviewResultScreen shows plain-language summary alongside audio, links verbatim quotes, enforces expressive cloud voice consent + offline fallback, and respects stop/completion',
    (WidgetTester tester) async {
      final bridge = _RecordingVoiceBridge();
      final coordinator = ReviewCoordinator(bridge: bridge);
      final receipt = _buildUiReceipt();

      await tester.pumpWidget(
        _wrapScreen(
          child: ReviewResultScreen(
            receipt: receipt,
            coordinator: coordinator,
            isInitiallySaved: true,
          ),
        ),
      );
      await _pumpFrames(tester);

      // 1. Plain-language summary text is visibly rendered alongside audio controls
      expect(find.byKey(const Key('deni_voice_summary_card')), findsOneWidget);
      expect(find.text('Deni’s plain-language summary'), findsOneWidget);
      expect(
        find.byKey(const Key('deni_voice_summary_headline')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('deni_voice_summary_unknowns')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('deni_voice_summary_calibration')),
        findsOneWidget,
      );

      // Device permission note clearly separated from policy disclosures
      expect(
        find.textContaining('From your phone settings, not the policy'),
        findsOneWidget,
      );

      // 2. On-device was tried first (0 cloud calls automatically)
      expect(bridge.analyseCalls, hasLength(1));
      expect(bridge.analyseCalls.first['cloudConsent'], isFalse);
      expect(bridge.geminiTtsCalls, isEmpty);

      // 3. Expanding a summary point shows the linked verbatim quote & opens WhyThisFindingSheet
      final quoteToggle = find.byKey(
        const Key('deni_summary_quote_toggle_pt_f_gps'),
      );
      await tester.ensureVisible(quoteToggle);
      await tester.tap(quoteToggle);
      await _pumpFrames(tester);

      expect(
        find.byKey(const Key('deni_summary_quote_box_pt_f_gps')),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'EduTrack collects precise GPS location in the background',
        ),
        findsWidgets,
      );

      final inspectBtn = find.byKey(const Key('deni_summary_inspect_pt_f_gps'));
      await tester.ensureVisible(inspectBtn);
      await tester.tap(inspectBtn);
      await _pumpFrames(tester);
      expect(find.byType(WhyThisFindingSheet), findsOneWidget);
      Navigator.of(tester.element(find.byType(WhyThisFindingSheet))).pop();
      await _pumpFrames(tester);

      // 4. Offline Listen speaks locally without cloud consent sheet or cloud TTS calls
      final listenBtn = find.byKey(const Key('deni_voice_play_stop_btn'));
      await tester.ensureVisible(listenBtn);
      await tester.tap(listenBtn);
      await tester.pump();

      expect(bridge.speakTextCalls, hasLength(1));
      expect(bridge.geminiTtsCalls, isEmpty);
      expect(find.text('Stop'), findsOneWidget);

      // Native completion event returns button to Listen cleanly
      bridge.emitVoicePlaybackEvent(
        const VoicePlaybackEvent(
          requestId: 'local_done',
          state: VoicePlaybackState.completed,
          route: VoicePlaybackRoute.androidLocalTts,
        ),
      );
      await tester.pump();
      expect(find.text('Listen'), findsOneWidget);

      // 5. Expressive voice opens CloudConsentSheet with redacted spoken script
      final expressiveBtn = find.byKey(const Key('deni_voice_expressive_btn'));
      await tester.ensureVisible(expressiveBtn);
      await tester.tap(expressiveBtn);
      await _pumpFrames(tester);

      expect(find.byType(CloudConsentSheet), findsOneWidget);
      expect(find.text('Choose Deni’s voice'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.text('[EMAIL]'),
        ),
        findsWidgets,
      );
      expect(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.textContaining('privacy@edutrack.example'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.textContaining('edu.example.track'),
        ),
        findsNothing,
      );

      // Denying via Close makes 0 cloud TTS calls
      await tester.tap(
        find.descendant(
          of: find.byType(CloudConsentSheet),
          matching: find.byIcon(LucideIcons.x),
        ),
      );
      await _pumpFrames(tester);
      expect(bridge.geminiTtsCalls, isEmpty);

      // Re-open and choose "Use expressive voice once" -> calls Gemini TTS, falls back honestly to local voice on timeout
      await tester.ensureVisible(expressiveBtn);
      await tester.tap(expressiveBtn);
      await _pumpFrames(tester);

      final approveVoiceBtn = find.text('Use expressive voice once');
      await tester.ensureVisible(approveVoiceBtn);
      await tester.tap(approveVoiceBtn);
      await _pumpFrames(tester);

      expect(bridge.geminiTtsCalls, hasLength(1));
      expect(bridge.geminiTtsCalls.first['cloudConsent'], isTrue);
      expect(
        bridge.geminiTtsCalls.first['text'] as String,
        contains('[EMAIL]'),
      );
      expect(
        bridge.geminiTtsCalls.first['text'] as String,
        isNot(contains('privacy@edutrack.example')),
      );
      expect(find.byKey(const Key('deni_voice_fallback_notice')), findsOneWidget);
      expect(find.textContaining('offline voice instead'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);

      // Stopping calls stopSpeaking and resets button to Listen
      await tester.tap(find.byKey(const Key('deni_voice_play_stop_btn')));
      await tester.pump();
      expect(bridge.stopCalls, greaterThanOrEqualTo(1));
      expect(find.text('Listen'), findsOneWidget);
    },
  );

  testWidgets(
    'Summarize with Cloud AI routes through CloudConsentSheet with redacted findings payload and updates summary',
    (WidgetTester tester) async {
      final bridge = _RecordingVoiceBridge(
        analyseHandler: (task, cloudConsent, text) {
          if (!cloudConsent) {
            return const HybridAnalysisResult(
              schemaVersion: 1,
              requestId: 'local',
              status: HybridStatus.unavailable,
              inferenceSource: 'UNKNOWN',
              message: 'On-device unavailable.',
            );
          }
          return const HybridAnalysisResult(
            schemaVersion: 1,
            requestId: 'cloud',
            status: HybridStatus.success,
            inferenceSource: 'IN_CLOUD',
            structuredOutput: {
              'headline': 'Cloud plain summary for EduTrack.',
              'points': [
                {
                  'finding_id': 'f_gps',
                  'plain_text':
                      'It can keep checking exact GPS location in the background.',
                },
                {
                  'finding_id': 'f_voice',
                  'plain_text':
                      'Voice recordings may be saved indefinitely to train AI.',
                },
              ],
              'unknown_summary': 'It is unclear when saved recordings are erased.',
            },
          );
        },
      );
      final coordinator = ReviewCoordinator(bridge: bridge);

      await tester.pumpWidget(
        _wrapScreen(
          child: ReviewResultScreen(
            receipt: _buildUiReceipt(),
            coordinator: coordinator,
            isInitiallySaved: true,
          ),
        ),
      );
      await _pumpFrames(tester);

      final cloudSummaryBtn = find.byKey(const Key('deni_summary_cloud_btn'));
      expect(cloudSummaryBtn, findsOneWidget);
      await tester.ensureVisible(cloudSummaryBtn);
      await tester.tap(cloudSummaryBtn);
      await _pumpFrames(tester);

      expect(find.byType(CloudConsentSheet), findsOneWidget);
      expect(find.text('Summarize findings with Cloud AI'), findsOneWidget);
      expect(find.text('[EMAIL]'), findsWidgets);

      await tester.tap(find.text('Use cloud for this check'));
      await _pumpFrames(tester);

      expect(find.text('Cloud plain summary for EduTrack.'), findsOneWidget);
      expect(find.text('Summarized in the cloud'), findsOneWidget);
      expect(
        bridge.analyseCalls.where((c) => c['cloudConsent'] == true),
        hasLength(1),
      );
    },
  );

  testWidgets(
    'DeniVoiceSummaryCard meets 48dp touch targets, single TalkBack semantics, reduced-motion, Dark Mode, 200% text scale, and Arabic RTL with zero overflow',
    (WidgetTester tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        final summary = DeniVoiceSummaryBuilder.buildDeterministic(
          receipt: _buildUiReceipt(),
          requiresCloudConsent: true,
          redactedCloudPayload: 'Redacted payload',
        );

        // 1. Light mode, reduced motion, synthesizing banner (static icon, no spinner)
        await tester.pumpWidget(
          _wrapScreen(
            mode: ThemeMode.light,
            disableAnimations: true,
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: DeniVoiceSummaryCard(
                  summary: summary,
                  isGeneratingSummary: true,
                  playbackState: VoicePlaybackState.idle,
                  onPlayOffline: () {},
                  onPlayExpressiveCloud: () {},
                  onStop: () {},
                  onEnhanceSummaryWithCloud: () {},
                  onOpenFinding: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byKey(const Key('deni_voice_status_banner')), findsOneWidget);

        // Verify >= 48x48dp touch targets AND actionable TalkBack button semantics (clickable + focusable + single label)
        for (final key in const [
          Key('deni_voice_play_stop_btn'),
          Key('deni_voice_expressive_btn'),
          Key('deni_summary_quote_toggle_pt_f_gps'),
          Key('deni_summary_inspect_pt_f_gps'),
        ]) {
          final size = tester.getSize(find.byKey(key));
          expect(size.height, greaterThanOrEqualTo(48.0), reason: '$key height');
          expect(size.width, greaterThanOrEqualTo(48.0), reason: '$key width');
          final node = tester.getSemantics(find.byKey(key));
          final data = node.getSemanticsData();
          expect(
            data.hasAction(SemanticsAction.tap),
            isTrue,
            reason: '$key must expose SemanticsAction.tap to TalkBack',
          );
          expect(
            node.label,
            isNotEmpty,
            reason: '$key must expose a non-empty TalkBack label',
          );
          expect(
            node.label,
            isNot(contains('\n')),
            reason: '$key must expose a single non-duplicated TalkBack label',
          );
        }

        // Verify exact TalkBack label on Play button
        final playNode = tester.getSemantics(
          find.byKey(const Key('deni_voice_play_stop_btn')),
        );
        expect(playNode.label, 'Listen to Deni’s plain-language summary');

        // 2. Narrow 360dp + Dark Mode + Arabic RTL + 200% text scale + reduced motion
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrapScreen(
            mode: ThemeMode.dark,
            locale: const Locale('ar'),
            textScale: 2.0,
            disableAnimations: true,
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: DeniVoiceSummaryCard(
                  summary: summary,
                  playbackState: VoicePlaybackState.playing,
                  activeRoute: VoicePlaybackRoute.geminiCloudTts,
                  statusNotice: 'Notice text',
                  onPlayOffline: () {},
                  onPlayExpressiveCloud: () {},
                  onStop: () {},
                  onOpenFinding: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byKey(const Key('deni_voice_summary_card')), findsOneWidget);
        expect(find.byKey(const Key('deni_voice_route_badge')), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );
}
