// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => '根拠に基づくアプリプライバシー確認';

  @override
  String get homePrivacySubtitle => '確認履歴はこのスマートフォン内に保存されます。';

  @override
  String get stateNoConcern => '懸念事項は見つかりませんでした';

  @override
  String get stateNoConcernSubtitle =>
      '確認した根拠の中に懸念事項はありませんでした。これは安全性の認定ではありません。';

  @override
  String get stateReviewRecommended => '確認をおすすめします';

  @override
  String get stateReviewRecommendedSubtitle =>
      'One or more policy parts or phone permissions need a closer look.';

  @override
  String get stateInsufficientEvidence => '根拠が不足しています';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'We need more privacy policy text before we can check what this app does.';

  @override
  String get chipOnDevice => 'このデバイス上';

  @override
  String get chipInCloud => 'クラウドで分析';

  @override
  String get chipLocationUnavailable => 'Source not available';

  @override
  String get chipOfflineDeterministic => 'Checked offline on this phone';

  @override
  String get chipUnknown => 'Source unknown';

  @override
  String get statusSourceMatched => 'Matched in policy';

  @override
  String get statusDeviceObserved => 'Seen on this phone';

  @override
  String get statusInterpretation => 'Deni\'s explanation';

  @override
  String get statusUnverified => 'Not found in policy';

  @override
  String get statusStale => 'Older check';

  @override
  String get btnCheckApp => 'アプリを調べる';

  @override
  String get btnPasteTerms => '規約またはURLを貼り付け';

  @override
  String get btnWhyThisFinding => 'この項目の理由は？';

  @override
  String get btnSaveToReceipts => 'レシートに保存';

  @override
  String get btnDiscard => '破棄';

  @override
  String get btnAskDeni => 'Deniに聞く';

  @override
  String get btnUseCloud => '今回の確認にクラウドを使う';

  @override
  String get btnReviewManually => '手動で確認する';

  @override
  String get btnGetStarted => 'はじめる';

  @override
  String get btnContinue => '続ける';

  @override
  String get deniIntro =>
      'こんにちは、Deniです。このプライバシーポリシーの内容を分かりやすく整理し、根拠となる原文や確認できなかった点までお伝えします。';

  @override
  String get cloudConsentDisclosure =>
      'To check this in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Your phone shows whether this permission is allowed. It does not prove whether the app actually accessed or sent data.';

  @override
  String get navHome => 'ホーム';

  @override
  String get navCheck => 'チェック';

  @override
  String get navReceipts => 'レシート';

  @override
  String get navLearn => '学ぶ';

  @override
  String get navSettings => '設定';

  @override
  String get languageTitle => '言語';

  @override
  String get chooseLanguage => '言語を選択';

  @override
  String get languageSubtitle => '画面表示・説明・音声読み上げに適用されます';

  @override
  String get homeHeroHeadline => '子どもが使うアプリを\n根拠からわかりやすく';

  @override
  String get trySampleCheck => 'サンプルアプリを試す';

  @override
  String get eduTrackSubtitle => '宿題と出席管理';

  @override
  String get eduTrackValue => '権限3件';

  @override
  String get eduTrackTrend => '要確認';

  @override
  String get calmMathSubtitle => 'オフライン算数練習';

  @override
  String get calmMathValue => '機密0件';

  @override
  String get calmMathTrend => '最小限';

  @override
  String get whatWeCheckTitle => '確認するポイント';

  @override
  String get checkQuoteTitle => '正確なポリシー引用';

  @override
  String get checkQuoteDesc =>
      'Highlights data sharing, voice recording, and how long data is kept using exact quotes.';

  @override
  String get checkPermissionTitle => '端末権限との不一致';

  @override
  String get checkPermissionDesc => 'カメラ・マイク・位置情報の許可状況とポリシーの記述を照合します。';

  @override
  String get checkSelectTitle => 'どこからでもテキスト確認';

  @override
  String get checkSelectDesc =>
      '他のアプリで文章を選択し、AndroidメニューからEnprive Checkをタップできます。';

  @override
  String get recentlyReviewed => '最近確認したレシート';

  @override
  String verifiedClausesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matched quotes',
      one: '1 matched quote',
    );
    return '$_temp0';
  }

  @override
  String get trySampleText => 'サンプル文を入力';

  @override
  String get modePasteText => 'テキストを貼り付け';

  @override
  String get modePolicyLink => 'ポリシーURL';

  @override
  String get hintAppName => 'アプリ名';

  @override
  String get defaultSubjectTitle => 'プライバシーポリシー';

  @override
  String get selectedExcerptTitle => '選択したポリシー抜粋';

  @override
  String get hintPastePolicy => 'プライバシーポリシーの本文をここに貼り付け…';

  @override
  String get btnReviewOnPhone => 'この端末で確認する';

  @override
  String get onboardingIntroHeadline => 'こんにちは、Deniです。👋';

  @override
  String get onboardingIntroLead => 'アプリのプライバシーをもっと分かりやすく。';

  @override
  String get onboardingIntroBody =>
      'アプリのプライバシーポリシーが本当に何を伝えているのかを読み解き、大切な記述を原文とともに示し、この端末が報告する権限状態も分かりやすく説明します。\n\n推測や根拠のない約束はしません。納得して判断できるよう、明確な説明と根拠だけをお届けします。';

  @override
  String get onboardingIntroFooter => '何に同意しているのか、きちんと知ることから。';

  @override
  String get splashQuote => '何に同意しているのか、きちんと知ることから';

  @override
  String get onboardingStep1Question => 'プライバシー規約を\nどのように説明しましょうか？';

  @override
  String get depthQuickMultiline => '要点のみ\n簡潔に';

  @override
  String get depthBalancedMultiline => 'バランス\n表示';

  @override
  String get depthFullMultiline => '詳細まで\nすべて';

  @override
  String get onboardingReadinessTitle => '初期設定から\nこの端末内で保護';

  @override
  String get onboardingReadinessSubtitle =>
      '保護者や先生が端末データを共有せずにアプリを確認できるよう設計されています。';

  @override
  String get readinessRow1Title => 'まずこの端末で確認';

  @override
  String get readinessRow1Desc => '規約は最初にこのスマートフォン内で読み取られます。';

  @override
  String get readinessRow2Title => 'アプリ情報は外に出ません';

  @override
  String get readinessRow2Desc => 'この端末のアプリ一覧とAndroid権限は外部に送信されません。';

  @override
  String get readinessRow3Title => 'Personal details hidden';

  @override
  String get readinessRow3Desc =>
      'If you choose cloud help, names, emails, and phone numbers are hidden before anything is sent.';

  @override
  String get settingsTitle => '設定';

  @override
  String get privateAnalysisTitle => 'この端末でのプライベート分析';

  @override
  String get onDeviceReadyMsg => 'オンデバイスAIが利用可能です。';

  @override
  String get localScannerProtectedMsg =>
      'Ready to check policies offline on this phone.';

  @override
  String get statusChecking => '確認中…';

  @override
  String get btnCheckReadiness => '準備状況を確認';

  @override
  String get howShouldDeniExplain => 'Deniの説明スタイル';

  @override
  String get depthQuick => '簡潔';

  @override
  String get depthBalanced => '標準';

  @override
  String get depthFull => '詳細';

  @override
  String get preferencesSection => '環境設定';

  @override
  String get meetDeniGuide => 'Deniの紹介とセットアップガイド';

  @override
  String clearSavedReceiptsCount(int count) {
    return '保存済みレシートを削除 ($count)';
  }

  @override
  String get btnClear => '削除';

  @override
  String get confirmClearReceiptsTitle => '保存済みレシートを削除しますか？';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'この端末に保存されている$count件のレシートが削除されます。',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'キャンセル';

  @override
  String get receiptsTitle => 'レシート';

  @override
  String get tooltipSearch => '検索';

  @override
  String get hintSearchReceipts => '保存した確認履歴を検索...';

  @override
  String get filterAll => 'すべて';

  @override
  String get filterReview => '要確認';

  @override
  String get filterNoConcern => '懸念なし';

  @override
  String get emptyFilteredTitle => '一致するレシートがありません';

  @override
  String get emptyReceiptsTitle => '保存されたレシートはまだありません';

  @override
  String get emptyFilteredBody => '上の別のフィルターを選択してみてください。';

  @override
  String get emptyReceiptsBody => '確認結果画面でブックマークすると、この端末に非公開で保存できます。';

  @override
  String get btnStartReview => '確認をはじめる';

  @override
  String get btnOpenReceipt => '開く';

  @override
  String get btnDelete => '削除';

  @override
  String get checkingPhoneReadiness => 'この端末のプライベート分析準備状況を確認中…';

  @override
  String get geminiNanoReadyMsg =>
      'On-device AI is ready on this phone. Reviews stay completely on your device.';

  @override
  String get modelDownloadingMsg => 'プライベートモデルをバックグラウンドでダウンロード中です。';

  @override
  String get modelDownloadableMsg => 'Wi-Fi接続時にオンデバイスモデルをダウンロードできます。';

  @override
  String get localScannerDefaultMsg =>
      'This phone checks policies offline on your device by default.';

  @override
  String get preparingPrivateAnalysis => 'プライベート分析を準備中…';

  @override
  String get onDeviceAiReadyTitle => 'オンデバイスAI準備完了';

  @override
  String get localScannerActiveTitle => 'Offline check ready';

  @override
  String get privateAnalysisSheetSubtitle =>
      'インストール済みアプリや権限確認データが端末の外に出ることはありません。';

  @override
  String get btnDone => '完了';

  @override
  String get btnCheckAgain => '再確認';

  @override
  String get reviewingOnPhone => 'この端末で確認中…';

  @override
  String get readingClausesInitial => 'Reading policy text on this phone…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countステップ',
    );
    return '$_temp0';
  }

  @override
  String get thoughtSignaturePrefix => 'Check ID';

  @override
  String get viewStreamedThoughts => 'How Enprive checked this';

  @override
  String get hideStreamedThoughts => 'Hide how Enprive checked this';

  @override
  String get analysisTraceDefaultTitle => 'この確認の検証手順';

  @override
  String get savedToLocalReceiptsSnack => '端末のレシートに保存しました。';

  @override
  String get snapshotSheetTitle => 'Reviewed policy text';

  @override
  String get snapshotSourcePrefix => '取得元';

  @override
  String get snapshotReviewedPrefix => '確認日時';

  @override
  String get snapshotDigestPrefix => 'Document fingerprint';

  @override
  String get statFindings => '検出数';

  @override
  String get statVerified => '検証済み';

  @override
  String get statOsGranted => 'Allowed on phone';

  @override
  String get statUnverified => 'Not found';

  @override
  String get keyFindingsTitle => '主な確認ポイント';

  @override
  String get reviewedExcerptTitle => '確認した抜粋';

  @override
  String get permissionsOnPhoneTitle => 'この端末のアプリ権限';

  @override
  String get viewReviewedSnapshot => 'View reviewed policy text';

  @override
  String get btnSavedToReceipts => 'レシートに保存済み';

  @override
  String get observedOnPhoneLabel => 'Seen on this phone';

  @override
  String get quoteVerifiedLabel => 'Exact quote from policy';

  @override
  String get unverifiedClaimLabel => 'Not found in policy';

  @override
  String get categoryDataCollection => 'データ収集';

  @override
  String get categorySharing => '第三者への共有';

  @override
  String get categoryTracking => '位置情報と追跡';

  @override
  String get categoryRetention => '保管と音声';

  @override
  String get categoryParentalControls => '保護者管理';

  @override
  String get labelInPlainLanguage => 'やさしい説明';

  @override
  String get labelOnThisPhone => 'この端末での状況';

  @override
  String get labelWhatRemainsUnknown => 'What we still don\'t know';

  @override
  String get presetQuestionMeaning => '子どもにどのような影響がありますか？';

  @override
  String get presetQuestionOptOut => 'これをオフにしたり拒否したりできますか？';

  @override
  String get presetQuestionUnknown => 'ここでまだ分からない点は何ですか？';

  @override
  String get readingCitedClause => 'Reading the policy quote…';

  @override
  String get deniAnswerTitle => 'Deniの回答';

  @override
  String get stepsAndReasoning => 'How Deni checked this';

  @override
  String get chooseReviewModeTitle => 'この文章の確認方法を選択';

  @override
  String get cloudNeverSendsAppsNote => 'インストール済みアプリや端末権限は一切送信されません。';

  @override
  String get tooltipClose => '閉じる';

  @override
  String get checkAppSheetSubtitle =>
      'この端末内でローカル確認します。アプリ一覧がアップロードされることはありません。';

  @override
  String get trySampleKidsApp => '子ども向けサンプルアプリを試す';

  @override
  String get sampleEduTrackSubtitle => '位置情報・マイク・カメラ';

  @override
  String get sampleCalmMathSubtitle => 'オフライン算数練習';

  @override
  String get appsOnThisPhone => 'この端末のアプリ';

  @override
  String get hintSearchApps => 'アプリを検索…';

  @override
  String get noMatchingApps => '一致するアプリがこの端末に見つかりませんでした。';

  @override
  String get sampleSyntheticBadge => 'Sample app';

  @override
  String get permissionInspectionTitle => 'Phone permissions checked';

  @override
  String get addAppPrivacyPolicyBtn => 'このアプリのプライバシーポリシーを追加';

  @override
  String get snapshotDigestLabel => 'Document fingerprint';

  @override
  String get snapshotDigestExplanation =>
      'A unique code that helps verify this is the exact text Enprive checked. If even one letter changes, this code changes too.';

  @override
  String get copyDigestBtn => 'Copy fingerprint';

  @override
  String get digestCopiedMsg => 'Document fingerprint copied';

  @override
  String get permissionGrantedBadge => 'Allowed on this phone';

  @override
  String get permissionNotGrantedBadge => 'Not allowed';

  @override
  String get checkingPolicyWithCloudAi => 'クラウド AI でポリシーを確認中。';

  @override
  String get preparingCloudAiStream =>
      'Hiding personal details before cloud check…';

  @override
  String get cancellingAnalysis => 'キャンセル中…';

  @override
  String get analysisCancelledNotice => '確認をキャンセルしました。';

  @override
  String get cloudTimedOutNotice => 'クラウド AI の応答がタイムアウトしました。自動再試行は行っていません。';

  @override
  String get cloudFallbackBannerTitle =>
      'Cloud unavailable — checked on this phone';

  @override
  String get cloudFallbackBannerBody =>
      'Cloud analysis was unavailable, so Enprive checked this policy directly on your phone.';

  @override
  String get appPickerFilterAll => 'All apps';

  @override
  String get appPickerFilterDownloaded => 'Downloaded';

  @override
  String get appPickerFilterSystem => 'System';

  @override
  String get appPickerRecentlyChecked => 'Recently checked';

  @override
  String get appPickerStatusPolicySaved => 'Policy review saved';

  @override
  String get appPickerStatusPermissionsInspected => 'Permissions checked';

  @override
  String get appPickerStatusNotReviewed => 'Not reviewed';

  @override
  String get appPickerSearchHint => 'Search by app name or App ID…';

  @override
  String get appPickerEmptyInstalledTitle => 'No installed apps available';

  @override
  String get appPickerEmptyInstalledBody =>
      'We couldn\'t find any apps to check on this phone.';

  @override
  String get intakeModeDocument => 'Document';

  @override
  String get intakeActionInspectText => 'Check policy text';

  @override
  String get intakeActionFetchUrl => 'Open & check policy';

  @override
  String get intakeActionChooseDocument => 'Choose PDF, TXT, or DOCX';

  @override
  String get intakeActionReplaceDocument => 'Choose replacement document';

  @override
  String get intakeWorkingLabel => 'Working…';

  @override
  String get intakeCancelFetch => 'Cancel fetch';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'Loads this public web page directly. Adding a link here does not prove app ownership.';

  @override
  String get intakePasteLocalNote =>
      'Checked locally on this phone first. Nothing is uploaded without your permission.';

  @override
  String get intakeDocumentCardTitle => 'Import PDF, TXT, or DOCX policy file';

  @override
  String get intakeDocumentCardBody =>
      'We read the text right on your phone (up to 10 MB). Your file is never uploaded.';

  @override
  String get intakeCompareWithAppPrompt =>
      'Compare with an installed app (optional)';

  @override
  String get intakeCompareWithAppHint =>
      'Runs locally on this phone. App lists never leave your device.';

  @override
  String get intakeCompareWithAppChange => 'Change';

  @override
  String get intakeCompareWithAppRemove => 'Remove';

  @override
  String get intakeLockedAppContextLabel => 'Selected app';

  @override
  String get intakeFindPolicyOnPlayStore => 'Find policy link on Play Store';

  @override
  String get intakePlayStoreHelperNote =>
      'Opens the Play Store so you can copy the app\'s privacy policy link. Enprive never copies it automatically or assumes the link is official.';

  @override
  String get intakePlayStoreUnavailable =>
      'Could not open Google Play Store on this device. Paste the policy URL or text manually instead.';

  @override
  String get intakeRecoverySwitchPaste => 'Paste text instead';

  @override
  String get intakeRecoverySwitchDocument => 'Import document';

  @override
  String get intakeRecoveryRetryUrl => 'Retry fetch';

  @override
  String get intakeExpiredDocumentShareNotice =>
      'The originally shared file link can no longer be reopened. Choose a replacement PDF, TXT, or DOCX file or paste the policy text manually.';

  @override
  String get intakeAssociationWarningTitle => 'App-policy identity check';

  @override
  String get intakeAssociationContinueAnyway => 'Continue anyway';

  @override
  String get intakeAssociationChangeApp => 'Change selected app';

  @override
  String get intakeAssociationInspectWithoutApp => 'Check policy without app';

  @override
  String get intakeModeSelectorSemanticLabel => 'Policy input method';

  @override
  String get tooltipClearSearch => 'Clear search';

  @override
  String get intakeRecoveryEditUrl => 'Edit URL';

  @override
  String get voiceSummaryTitle => 'Deni’s plain-language summary';

  @override
  String get voiceSummaryPreparing => 'Preparing plain-language summary…';

  @override
  String get voiceSynthesizingExpressive =>
      'Preparing Deni’s expressive voice…';

  @override
  String get voiceBtnListenOffline => 'Listen';

  @override
  String get voiceBtnStop => 'Stop';

  @override
  String get voiceBtnExpressiveCloud => 'Expressive voice';

  @override
  String get voiceBtnSummarizeCloud => 'Summarize with Cloud AI';

  @override
  String get voiceBadgeExpressive => 'Expressive cloud voice';

  @override
  String get voiceBadgeDeviceOffline => 'Phone voice · Offline';

  @override
  String get voiceViewSourceQuote => 'Source quote';

  @override
  String get voiceHideSourceQuote => 'Hide quote';

  @override
  String get voiceInspectFinding => 'Inspect finding';

  @override
  String get voiceConsentTitle => 'Choose Deni’s voice';

  @override
  String get voiceConsentDisclosure =>
      'To read this summary aloud with Deni’s expressive cloud voice, Enprive will send only the summary text shown above (with personal details hidden) for this one request. Your apps and phone permissions are never sent.';

  @override
  String get voiceConsentPrimaryAction => 'Use expressive voice once';

  @override
  String get voiceConsentSecondaryAction => 'Speak on this phone';

  @override
  String get voiceConsentPayloadLabel => 'Exact spoken script';

  @override
  String get voiceSummaryConsentTitle => 'Summarize findings with Cloud AI';

  @override
  String get voiceSummaryConsentDisclosure =>
      'To summarize these policy quotes in plain language in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions are never sent.';

  @override
  String get voiceFallbackDeviceNotice =>
      'Expressive cloud voice was unavailable — using this phone’s offline voice instead.';

  @override
  String get voiceUnavailableNotice =>
      'Voice playback is unavailable for this language on this phone. You can read Deni’s summary above.';

  @override
  String get voiceTooltipReadSummary =>
      'Listen to Deni’s plain-language summary';

  @override
  String get voiceTooltipStopReading => 'Stop reading aloud';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'findings',
      one: 'finding',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count findings',
      one: '1 finding',
      zero: 'No findings',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quotes verified in policy',
      one: '1 quote verified in policy',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observed on this phone',
      one: '1 observed on this phone',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'Allowed on this phone';

  @override
  String get permissionNotAllowedOnPhone => 'Not allowed';

  @override
  String get permissionAllowedInSample => 'Allowed in sample';

  @override
  String get permissionNotAllowedInSample => 'Not allowed in sample';

  @override
  String get permissionMismatchChip => 'Not in policy';

  @override
  String get howEnpriveCheckedThis => 'How Enprive checked this';

  @override
  String get hideHowEnpriveChecked => 'Hide how Enprive checked this';

  @override
  String get consentWhatWouldBeSent => 'What would be sent';

  @override
  String get consentSentScope =>
      'Only the text in the preview leaves this phone, for this one request.';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personal details are hidden first.',
      one: '1 personal detail is hidden first.',
      zero: 'No personal details were found to hide.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'Your app list and phone permissions stay on this phone.';

  @override
  String receiptDeletedSnack(String title) {
    return 'Deleted $title';
  }

  @override
  String get btnUndo => 'Undo';

  @override
  String get readinessPromiseMaskedTitle => 'Personal details hidden';

  @override
  String get readinessPromiseMaskedLine =>
      'If you choose cloud, names, emails and numbers are hidden first.';

  @override
  String findingDetailTitle(int index, int total) {
    return 'Finding $index of $total';
  }

  @override
  String get findingReviewChip => 'Review';

  @override
  String get askDeniAboutThis => 'Ask Deni about this';

  @override
  String get labelWhatPolicySays => 'What the policy says';

  @override
  String get labelWhatAndroidReports => 'What your phone shows';

  @override
  String get sourceButtonTooltip => 'Reviewed source';

  @override
  String get linkInstalledAppBtn => 'Link an installed app';

  @override
  String get linkInstalledAppCardTitle => 'Compare with an app on this phone';

  @override
  String get linkInstalledAppCardBody =>
      'Pick an installed app to compare its phone permissions with this policy in the same review. Your app list stays on this phone.';

  @override
  String get linkAppPickerTitle => 'Link an installed app';

  @override
  String get changeLinkedAppPickerTitle => 'Change linked app';

  @override
  String get linkAppPickerSubtitle =>
      'Pick an app on this phone to compare its permissions with this policy. Your app list never leaves this phone.';

  @override
  String get linkedAppCurrentlySelectedBadge => 'Linked';

  @override
  String get linkedAppSectionLabel => 'Linked app on this phone';

  @override
  String get btnChangeLinkedApp => 'Change app';

  @override
  String get btnUnlinkApp => 'Unlink app';

  @override
  String get btnUpdatePrivacyPolicy => 'Attach updated privacy policy';

  @override
  String linkedAppSnack(String appName) {
    return 'Linked $appName. Permissions compared on this phone.';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return 'Linked $appName. Check the app-policy match note below.';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName is already linked with the same permissions.';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return 'Unlinked $appName. Showing the policy review only.';
  }

  @override
  String get associationStatusPackageTitle => 'App ID found in this policy';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'This policy mentions $packageName. That suggests it may describe $appName, though text alone does not prove who owns this policy.';
  }

  @override
  String get associationStatusNameTitle => 'App name found in this policy';

  @override
  String associationStatusNameBody(String appName) {
    return 'This policy mentions $appName. That suggests it may describe this app, though a name match does not prove who owns this policy.';
  }

  @override
  String get associationStatusUnverifiedTitle => 'Linked by you for comparison';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'This policy does not name $appName or its app ID. Double-check that it is the right policy — linking it here does not prove ownership.';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'The web address includes words from $appName, but the policy text itself does not name this app. Double-check that it is the right policy — linking it here does not prove ownership.';
  }

  @override
  String get associationStatusUnmatchedTitle =>
      'This policy may be for a different app';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'This policy does not mention $appName. Instead, it names $otherApps. Check that you linked the right app or opened the right policy.';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'This policy mentions more than one app';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'This policy mentions $appName alongside $otherApps. It may cover several apps or a shared company policy, so check that it applies here.';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      'More than one app on this phone has a similar name';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'This policy mentions $appName without listing one exact app ID, and other apps on your phone ($otherApps) have a similar name. Make sure you linked the right one.';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'This policy could refer to more than one app. Double-check that it applies to $appName.';
  }

  @override
  String get associationOwnershipLimitation =>
      'Text and web links never prove who published or owns a policy.';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count permissions on this phone are not clearly mentioned in this policy. A mismatch is a prompt to look closer, not proof of wrongdoing.',
      one: '1 permission on this phone is not clearly mentioned in this policy. A mismatch is a prompt to look closer, not proof of wrongdoing.',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'None of the checked permissions on this phone contradict this policy. Permissions alone cannot show what an app actually sends.';

  @override
  String get permissionComparisonLimitationNote =>
      'Your phone shows permission settings on this phone only. This comparison is a prompt to look closer, never proof of wrongdoing or that data was sent.';

  @override
  String get permissionNotRequestedOnPhone => 'Not requested by app';

  @override
  String get permissionNotRequestedInSample => 'Not requested in sample';

  @override
  String get permissionsEmptyComparisonTitle =>
      'No sensitive permissions matched in this check';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'Your phone lists $requestedCount permissions ($grantedCount allowed) for $appName, with none in the sensitive categories checked here (location, camera, microphone, contacts, photos, or ad ID).';
  }

  @override
  String get sourceDeviceInspection => 'Checked on this phone';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => 'Advanced details';

  @override
  String get advancedDetailsSubtitle =>
      'Technical details that verify when and where this policy text was checked.';

  @override
  String get sourceSectionTitle => 'Where this policy came from';

  @override
  String get cloudPayloadLabel => 'Exact text to be sent';

  @override
  String get cloudPayloadNoPiiLabel => 'No personal details found';

  @override
  String cloudPayloadHiddenCount(int count) {
    return 'Hidden ($count)';
  }

  @override
  String get summarySourceOnDevice => 'Summarized on this phone';

  @override
  String get summarySourceInCloud => 'Summarized in the cloud';

  @override
  String get summarySourceOffline => 'Summarized offline on this phone';

  @override
  String get summarySourceUnknown => 'Summary source unknown';

  @override
  String get notFromPolicySuffix => 'From your phone settings, not the policy';

  @override
  String get sampleNotFromPolicySuffix => 'Example only, not from the policy';
}
