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
      'プライバシーポリシーの一部または端末の権限について、詳しく確認する必要があります。';

  @override
  String get stateInsufficientEvidence => '根拠が不足しています';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'このアプリの動作を確認するには、プライバシーポリシーの本文がさらに必要です。';

  @override
  String get chipOnDevice => 'このデバイス上';

  @override
  String get chipInCloud => 'クラウドで分析';

  @override
  String get chipLocationUnavailable => '処理元が利用不可';

  @override
  String get chipOfflineDeterministic => 'この端末でオフライン確認済み';

  @override
  String get chipUnknown => '処理元不明';

  @override
  String get statusSourceMatched => 'ポリシーと一致';

  @override
  String get statusDeviceObserved => 'この端末で確認';

  @override
  String get statusInterpretation => 'Deniの説明';

  @override
  String get statusUnverified => 'ポリシーに記載なし';

  @override
  String get statusStale => '以前の確認';

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
      'クラウドで確認するため、Enpriveは今回の1回に限り、上に表示された文章のみ（個人情報を伏せた状態）を送信します。インストール済みアプリや端末の権限は一切送信されません。';

  @override
  String get permissionLimitationNotice =>
      'この端末では権限が許可されているかを確認できます。アプリが実際にデータへアクセスしたり送信したりした証明にはなりません。';

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
  String get checkQuoteDesc => 'データ共有、音声録音、保管期間について、原文の引用を使って分かりやすく示します。';

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
      other: '一致した引用 $count件',
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
  String get readinessRow3Title => '個人情報を自動で伏せる';

  @override
  String get readinessRow3Desc => 'クラウド支援を使う場合、送信前に氏名・メールアドレス・電話番号を伏せます。';

  @override
  String get settingsTitle => '設定';

  @override
  String get privateAnalysisTitle => 'この端末でのプライベート分析';

  @override
  String get onDeviceReadyMsg => 'オンデバイスAIが利用可能です。';

  @override
  String get localScannerProtectedMsg => 'この端末でオフライン確認を行う準備ができています。';

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
  String get geminiNanoReadyMsg => 'この端末のオンデバイスAIが利用可能です。確認内容は端末内にのみ留まります。';

  @override
  String get modelDownloadingMsg => 'プライベートモデルをバックグラウンドでダウンロード中です。';

  @override
  String get modelDownloadableMsg => 'Wi-Fi接続時にオンデバイスモデルをダウンロードできます。';

  @override
  String get localScannerDefaultMsg => 'この端末では初期設定でオフライン確認を行います。';

  @override
  String get preparingPrivateAnalysis => 'プライベート分析を準備中…';

  @override
  String get onDeviceAiReadyTitle => 'オンデバイスAI準備完了';

  @override
  String get localScannerActiveTitle => 'オフライン確認の準備完了';

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
  String get readingClausesInitial => 'この端末でプライバシーポリシーを読み取っています…';

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
  String get thoughtSignaturePrefix => '確認ID';

  @override
  String get viewStreamedThoughts => 'Enpriveの確認手順';

  @override
  String get hideStreamedThoughts => 'Enpriveの確認手順を隠す';

  @override
  String get analysisTraceDefaultTitle => 'この確認の検証手順';

  @override
  String get savedToLocalReceiptsSnack => '端末のレシートに保存しました。';

  @override
  String get snapshotSheetTitle => '確認したポリシー本文';

  @override
  String get snapshotSourcePrefix => '取得元';

  @override
  String get snapshotReviewedPrefix => '確認日時';

  @override
  String get snapshotDigestPrefix => '文書の指紋コード';

  @override
  String get statFindings => '検出数';

  @override
  String get statVerified => '検証済み';

  @override
  String get statOsGranted => '端末で許可済み';

  @override
  String get statUnverified => '記載なし';

  @override
  String get keyFindingsTitle => '主な確認ポイント';

  @override
  String get reviewedExcerptTitle => '確認した抜粋';

  @override
  String get permissionsOnPhoneTitle => 'この端末のアプリ権限';

  @override
  String get viewReviewedSnapshot => '確認したポリシー本文を見る';

  @override
  String get btnSavedToReceipts => 'レシートに保存済み';

  @override
  String get observedOnPhoneLabel => 'この端末で確認';

  @override
  String get quoteVerifiedLabel => 'ポリシーの正確な引用';

  @override
  String get unverifiedClaimLabel => 'ポリシーに記載なし';

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
  String get labelWhatRemainsUnknown => 'まだ分からないこと';

  @override
  String get presetQuestionMeaning => '子どもにどのような影響がありますか？';

  @override
  String get presetQuestionOptOut => 'これをオフにしたり拒否したりできますか？';

  @override
  String get presetQuestionUnknown => 'ここでまだ分からない点は何ですか？';

  @override
  String get readingCitedClause => 'ポリシーの引用を読み取っています…';

  @override
  String get deniAnswerTitle => 'Deniの回答';

  @override
  String get stepsAndReasoning => 'Deniの確認手順';

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
  String get sampleSyntheticBadge => 'サンプルアプリ';

  @override
  String get permissionInspectionTitle => '端末の権限を確認済み';

  @override
  String get addAppPrivacyPolicyBtn => 'このアプリのプライバシーポリシーを追加';

  @override
  String get snapshotDigestLabel => '文書の指紋コード';

  @override
  String get snapshotDigestExplanation =>
      'Enpriveが確認した文章と完全に同一であることを確かめる固有コードです。1文字でも変わるとコードも変わります。';

  @override
  String get copyDigestBtn => 'コードをコピー';

  @override
  String get digestCopiedMsg => '文書の指紋コードをコピーしました';

  @override
  String get permissionGrantedBadge => 'この端末で許可済み';

  @override
  String get permissionNotGrantedBadge => '未許可';

  @override
  String get checkingPolicyWithCloudAi => 'クラウド AI でポリシーを確認中。';

  @override
  String get preparingCloudAiStream => 'クラウド確認の前に個人情報を伏せています…';

  @override
  String get cancellingAnalysis => 'キャンセル中…';

  @override
  String get analysisCancelledNotice => '確認をキャンセルしました。';

  @override
  String get cloudTimedOutNotice => 'クラウド AI の応答がタイムアウトしました。自動再試行は行っていません。';

  @override
  String get cloudFallbackBannerTitle => 'クラウドチェックを完了できませんでした';

  @override
  String get cloudFallbackBannerBody =>
      'これはお使いの端末で行った結果で、データは再送信されていません。ポリシーの文章はそのまま残っています。「保存」をタップするまで、何も保存されません。';

  @override
  String get cloudFallbackRetryAction => 'クラウドチェックをもう一度試す';

  @override
  String get appPickerFilterAll => 'すべてのアプリ';

  @override
  String get appPickerFilterDownloaded => 'ダウンロード済み';

  @override
  String get appPickerFilterSystem => 'システム';

  @override
  String get appPickerRecentlyChecked => '最近確認したアプリ';

  @override
  String get appPickerStatusPolicySaved => 'ポリシー確認を保存済み';

  @override
  String get appPickerStatusPermissionsInspected => '権限を確認済み';

  @override
  String get appPickerStatusNotReviewed => '未確認';

  @override
  String get appPickerSearchHint => 'アプリ名またはApp IDで検索…';

  @override
  String get appPickerEmptyInstalledTitle => '利用可能なアプリがありません';

  @override
  String get appPickerEmptyInstalledBody => 'この端末で確認できるアプリが見つかりませんでした。';

  @override
  String get intakeModeDocument => '文書';

  @override
  String get intakeActionInspectText => 'ポリシー本文を確認';

  @override
  String get intakeActionFetchUrl => 'URLを開いて確認';

  @override
  String get intakeActionChooseDocument => 'PDF・TXT・DOCXを選択';

  @override
  String get intakeActionReplaceDocument => '代わりの文書を選択';

  @override
  String get intakeWorkingLabel => '処理中…';

  @override
  String get intakeCancelFetch => '取得をキャンセル';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'この公開ウェブページを直接読み込みます。リンクを追加してもアプリの所有者である証明にはなりません。';

  @override
  String get intakePasteLocalNote => 'まずこの端末内で確認します。あなたの許可なく外部へ送信されることはありません。';

  @override
  String get intakeDocumentCardTitle => 'PDF・TXT・DOCXのポリシーを読み込む';

  @override
  String get intakeDocumentCardBody =>
      '最大10 MBの文書を端末内で直接読み取ります。ファイルが外部へ送信されることはありません。';

  @override
  String get intakeCompareWithAppPrompt => 'インストール済みアプリと比較（任意）';

  @override
  String get intakeCompareWithAppHint => 'この端末内で処理します。アプリ一覧が端末の外に出ることはありません。';

  @override
  String get intakeCompareWithAppChange => '変更';

  @override
  String get intakeCompareWithAppRemove => '解除';

  @override
  String get intakeLockedAppContextLabel => '選択中のアプリ';

  @override
  String get intakeFindPolicyOnPlayStore => 'Play StoreでポリシーURLを探す';

  @override
  String get intakePlayStoreHelperNote =>
      'アプリのプライバシーポリシーURLをコピーできるようPlay Storeを開きます。Enpriveが自動でコピーしたり公式と判断したりすることはありません。';

  @override
  String get intakePlayStoreUnavailable =>
      'この端末でGoogle Play Storeを開けませんでした。代わりにポリシーのURLまたは本文を手動で貼り付けてください。';

  @override
  String get intakeRecoverySwitchPaste => '代わりにテキストを貼り付ける';

  @override
  String get intakeRecoverySwitchDocument => '文書を読み込む';

  @override
  String get intakeRecoveryRetryUrl => '再取得する';

  @override
  String get intakeExpiredDocumentShareNotice =>
      '最初に共有されたファイルリンクは再度開けません。別のPDF・TXT・DOCXファイルを選ぶか、本文を手動で貼り付けてください。';

  @override
  String get intakeAssociationWarningTitle => 'アプリとポリシーの一致確認';

  @override
  String get intakeAssociationContinueAnyway => 'このまま続ける';

  @override
  String get intakeAssociationChangeApp => '選択中のアプリを変更';

  @override
  String get intakeAssociationInspectWithoutApp => 'アプリなしでポリシーを確認';

  @override
  String get intakeModeSelectorSemanticLabel => 'ポリシーの入力方法';

  @override
  String get tooltipClearSearch => '検索をクリア';

  @override
  String get intakeRecoveryEditUrl => 'URLを編集';

  @override
  String get voiceSummaryTitle => 'Deniのやさしいまとめ';

  @override
  String get voiceSummaryPreparing => 'やさしいまとめを準備しています…';

  @override
  String get voiceSynthesizingExpressive => 'Deniの表現豊かな音声を準備しています…';

  @override
  String get voiceBtnListenOffline => '聴く';

  @override
  String get voiceBtnStop => '停止';

  @override
  String get voiceBtnExpressiveCloud => '表現豊かな音声';

  @override
  String get voiceBtnSummarizeCloud => 'クラウドAIで要約';

  @override
  String get voiceBadgeExpressive => 'クラウドの表現音声';

  @override
  String get voiceBadgeDeviceOffline => '端末の音声 · オフライン';

  @override
  String get voiceViewSourceQuote => '原文を見る';

  @override
  String get voiceHideSourceQuote => '原文を隠す';

  @override
  String get voiceInspectFinding => '詳細を見る';

  @override
  String get voiceConsentTitle => 'Deniの音声を選択';

  @override
  String get voiceConsentDisclosure =>
      'Deniの表現豊かなクラウド音声で読み上げるため、Enpriveは今回の1回に限り、上に表示された要約文のみ（個人情報を伏せた状態）を送信します。アプリ一覧や端末の権限は一切送信されません。';

  @override
  String get voiceConsentPrimaryAction => '今回だけ表現音声を使う';

  @override
  String get voiceConsentSecondaryAction => 'この端末で読み上げる';

  @override
  String get voiceConsentPayloadLabel => '読み上げる正確な文章';

  @override
  String get voiceSummaryConsentTitle => 'クラウドAIで検出内容を要約';

  @override
  String get voiceSummaryConsentDisclosure =>
      'これらのポリシー引用をクラウドで分かりやすく要約するため、Enpriveは今回の1回に限り、上に表示された文章のみ（個人情報を伏せた状態）を送信します。アプリ一覧や端末の権限は一切送信されません。';

  @override
  String get voiceFallbackDeviceNotice =>
      'クラウド音声を利用できなかったため、この端末のオフライン音声で読み上げます。';

  @override
  String get voiceUnavailableNotice =>
      'この端末ではこの言語の音声再生を利用できません。上のDeniのまとめをお読みください。';

  @override
  String get voiceTooltipReadSummary => 'Deniのやさしいまとめを聴く';

  @override
  String get voiceTooltipStopReading => '読み上げを停止';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '件',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '検出項目 $count件',
      zero: '検出項目なし',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ポリシーで確認された引用 $count件',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'この端末で確認された項目 $count件',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'この端末で許可済み';

  @override
  String get permissionNotAllowedOnPhone => '未許可';

  @override
  String get permissionAllowedInSample => 'サンプルで許可済み';

  @override
  String get permissionNotAllowedInSample => 'サンプルで未許可';

  @override
  String get permissionMismatchChip => 'ポリシーに記載なし';

  @override
  String get howEnpriveCheckedThis => 'Enpriveの確認手順';

  @override
  String get hideHowEnpriveChecked => 'Enpriveの確認手順を隠す';

  @override
  String get consentWhatWouldBeSent => '送信される内容';

  @override
  String get consentSentScope => '今回の1回に限り、プレビューに表示された文章だけがこの端末から送信されます。';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '送信前に個人情報を$count件伏せます。',
      zero: '伏せる必要がある個人情報は見つかりませんでした。',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone => 'アプリ一覧と端末の権限はこの端末内に留まります。';

  @override
  String receiptDeletedSnack(String title) {
    return '「$title」を削除しました';
  }

  @override
  String get btnUndo => '元に戻す';

  @override
  String get readinessPromiseMaskedTitle => '個人情報を自動で伏せる';

  @override
  String get readinessPromiseMaskedLine => 'クラウドを使う場合、氏名・メール・電話番号は送信前に伏せます。';

  @override
  String findingDetailTitle(int index, int total) {
    return '検出項目 $index / $total';
  }

  @override
  String get findingReviewChip => '要確認';

  @override
  String get askDeniAboutThis => 'これについてDeniに聞く';

  @override
  String get labelWhatPolicySays => 'ポリシーの記載';

  @override
  String get labelWhatAndroidReports => 'この端末の表示';

  @override
  String get sourceButtonTooltip => '確認した原文';

  @override
  String get linkInstalledAppBtn => 'インストール済みアプリを紐づける';

  @override
  String get linkInstalledAppCardTitle => 'この端末のアプリと比較する';

  @override
  String get linkInstalledAppCardBody =>
      'インストール済みアプリを選ぶと、同じ確認画面で端末の権限とこのポリシーを比較できます。アプリ一覧はこの端末内に留まります。';

  @override
  String get linkAppPickerTitle => 'インストール済みアプリを紐づける';

  @override
  String get changeLinkedAppPickerTitle => '紐づけたアプリを変更';

  @override
  String get linkAppPickerSubtitle =>
      'このポリシーと権限を比較するアプリを選んでください。アプリ一覧が端末の外に出ることはありません。';

  @override
  String get linkedAppCurrentlySelectedBadge => '紐づけ済み';

  @override
  String get linkedAppSectionLabel => 'この端末で紐づけたアプリ';

  @override
  String get btnChangeLinkedApp => 'アプリを変更';

  @override
  String get btnUnlinkApp => '紐づけを解除';

  @override
  String get btnUpdatePrivacyPolicy => '新しいプライバシーポリシーを添付';

  @override
  String linkedAppSnack(String appName) {
    return '「$appName」を紐づけました。端末内で権限を比較しました。';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return '「$appName」を紐づけました。下の一致確認メモをご確認ください。';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '「$appName」は同じ権限のまま既に紐づけられています。';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return '「$appName」の紐づけを解除しました。ポリシー確認のみ表示します。';
  }

  @override
  String get associationStatusPackageTitle => 'このポリシー内でApp IDが見つかりました';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'このポリシーには$packageNameが記載されています。$appNameに関する説明である可能性を示しますが、文章だけではポリシーの所有者は証明できません。';
  }

  @override
  String get associationStatusNameTitle => 'このポリシー内でアプリ名が見つかりました';

  @override
  String associationStatusNameBody(String appName) {
    return 'このポリシーには$appNameが記載されています。このアプリに関する説明である可能性を示しますが、名前の一致だけでは所有者は証明できません。';
  }

  @override
  String get associationStatusUnverifiedTitle => '比較のため手動で紐づけ済み';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'このポリシーには$appNameやそのApp IDの記載がありません。正しいポリシーかご確認ください。紐づけだけでは所有者は証明できません。';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'URLに$appNameの語句が含まれていますが、ポリシー本文にはこのアプリ名が記載されていません。正しいポリシーかご確認ください。紐づけだけでは所有者は証明できません。';
  }

  @override
  String get associationStatusUnmatchedTitle => '別のアプリのポリシーである可能性があります';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'このポリシーには$appNameの記載がなく、代わりに$otherAppsが記載されています。正しいアプリを紐づけたか、正しいポリシーを開いたかご確認ください。';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'このポリシーには複数のアプリが記載されています';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'このポリシーには$appNameとあわせて$otherAppsも記載されています。複数アプリ向けや企業共通のポリシーの可能性があるため、このアプリに該当するかご確認ください。';
  }

  @override
  String get associationStatusAmbiguousPeerTitle => '似た名前のアプリがこの端末に複数あります';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'このポリシーは正確なApp IDなしで$appNameと記載しており、端末内にも似た名前のアプリ（$otherApps）があります。正しいアプリを紐づけたかご確認ください。';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'このポリシーは複数のアプリを指している可能性があります。$appNameに該当するかご確認ください。';
  }

  @override
  String get associationOwnershipLimitation =>
      '文章やウェブリンクだけでは、誰がポリシーを公開・所有しているかは証明できません。';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'この端末の$count件の権限が、このポリシーに明確には記載されていません。不一致は詳しく確認するきっかけであり、不正の証明ではありません。',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'この端末で確認した権限のうち、このポリシーと矛盾するものはありません。権限だけではアプリが実際に何を送信しているかは分かりません。';

  @override
  String get permissionComparisonLimitationNote =>
      '端末に表示されるのはこの端末上の権限設定のみです。この比較は詳しく確認するきっかけであり、不正やデータ送信の証明にはなりません。';

  @override
  String get permissionNotRequestedOnPhone => 'アプリから要求なし';

  @override
  String get permissionNotRequestedInSample => 'サンプルで要求なし';

  @override
  String get permissionsEmptyComparisonTitle => '今回の確認で対象となる機密権限はありません';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'この端末では$appNameに$requestedCount件の権限（うち許可済み$grantedCount件）がありますが、今回の確認対象である機密カテゴリ（位置情報・カメラ・マイク・連絡先・写真・広告ID）には該当しません。';
  }

  @override
  String get sourceDeviceInspection => 'この端末で確認';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => '詳細情報';

  @override
  String get advancedDetailsSubtitle => 'このポリシー本文をいつ・どこで確認したかを確かめる技術情報です。';

  @override
  String get sourceSectionTitle => 'このポリシーの取得元';

  @override
  String get cloudPayloadLabel => '送信される正確な文章';

  @override
  String get cloudPayloadNoPiiLabel => '個人情報は見つかりませんでした';

  @override
  String cloudPayloadHiddenCount(int count) {
    return '伏せた項目（$count）';
  }

  @override
  String get summarySourceOnDevice => 'この端末で要約';

  @override
  String get summarySourceInCloud => 'クラウドで要約';

  @override
  String get summarySourceOffline => 'この端末でオフライン要約';

  @override
  String get summarySourceUnknown => '要約元不明';

  @override
  String get notFromPolicySuffix => 'ポリシーではなく端末の設定から取得';

  @override
  String get sampleNotFromPolicySuffix => 'ポリシーではなくサンプルの例';

  @override
  String get learnHeaderSubtitle => 'オフラインで学べるプライバシーガイドと図解';

  @override
  String get learnFilterAll => 'すべて';

  @override
  String get learnFilterPolicies => 'ポリシー';

  @override
  String get learnFilterPermissions => '権限';

  @override
  String get learnFilterSharing => '共有';

  @override
  String get learnFilterEvidence => '根拠';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countステップ',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle => '端末内でプライバシー習慣を学ぶ';

  @override
  String get learnDeckBody =>
      '図解付きの完全オフラインレッスンです。インストール済みアプリやレシートが「学ぶ」に読み込まれることはありません。';

  @override
  String get learnDeckCheckBtn => '試してみる · アプリを確認';

  @override
  String get learnCheckAppBridgeBtn => 'この端末のアプリを確認する';

  @override
  String get learnSectionDiagram => 'しくみ';

  @override
  String get learnSectionSteps => '大切なポイント';

  @override
  String get learnSectionQuickCheck => 'クイックチェック';

  @override
  String get learnTooltipListenLesson => 'このレッスンをオフラインで聴く';

  @override
  String get learnTooltipStopLesson => 'レッスンの読み上げを停止';

  @override
  String get learnVoiceUnavailableNotice =>
      'この端末ではこの言語のオフライン音声再生を利用できません。下のレッスンをお読みください。';

  @override
  String get learnQuickCheckCorrectBadge => '正解';

  @override
  String get learnQuickCheckTryAgainBadge => '別の選択肢を試す';

  @override
  String learnLessonProgress(int current, int total) {
    return 'レッスン $current / $total';
  }

  @override
  String get learnBackTooltip => '学ぶに戻る';

  @override
  String get learnPreviousLesson => '前へ';

  @override
  String get learnNextLesson => '次へ';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return '前のレッスン：$title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return '次のレッスン：$title';
  }

  @override
  String get learnPolicyFolderTitle => 'プライバシーポリシー';

  @override
  String get learnPolicyTitle => 'プライバシーポリシーとは（そして証明できないこと）';

  @override
  String get learnPolicySubtitle => '開発者の説明と、まだ分からないこと';

  @override
  String get learnPolicyIntro =>
      'プライバシーポリシーは、アプリがどのデータを集めると説明しているか、何のために使うか、誰に共有され得るか、家族にどんな選択肢があるかを示す開発者の公開文書です。';

  @override
  String get learnPolicyStep1 =>
      '基本の4点を確認しましょう。何を集めるか、なぜ必要か、他に誰が受け取るか、削除をどう依頼できるかです。';

  @override
  String get learnPolicyStep2 =>
      '分かりにくい表現は珍しくありません。2026年の子ども向け学習アプリ調査では、読みやすいポリシーはごくわずかで、多くのアプリは記載内容と完全には一致していませんでした。';

  @override
  String get learnPolicyStep3 =>
      'プライバシーポリシーが示すのは開発者の書面上の説明だけです。読むだけでは、アプリが実際にインターネットへ何を送信しているかは証明できません。';

  @override
  String get learnPolicyStep4 =>
      'ポリシーと端末の権限設定を比べると全体像がつかみやすくなります。ただし、Enpriveは実際の通信内容を見ることはできません。';

  @override
  String get learnPolicyQuickQuestion => 'アプリのプライバシーポリシーを読むことで証明できるのはどれですか？';

  @override
  String get learnPolicyQuickOption1 => 'アプリが誰にもデータを送っていないこと';

  @override
  String get learnPolicyQuickOption2 => '開発者が何と言っているか（実際に送っている内容ではない）';

  @override
  String get learnPolicyQuickOption3 => '端末のカメラとマイクがオフになっていること';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'その通りです。ポリシーは開発者の公開説明であり、アプリが実際にインターネットへ送っている内容の証明ではありません。';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      '惜しいです。ポリシーを読んで分かるのは開発者の説明だけで、通信の証明や端末権限のオフにはなりません。';

  @override
  String get learnDiagramPolicySaysTitle => 'ポリシーの記載';

  @override
  String get learnDiagramPolicySaysBody => '開発者が書面で示した約束';

  @override
  String get learnDiagramPolicyQuoteSample => '「パートナーとデータを共有する場合があります…」';

  @override
  String get learnDiagramPhoneShowsTitle => '端末の表示';

  @override
  String get learnDiagramPhoneShowsBody => 'この端末で許可された権限';

  @override
  String get learnDiagramUnknownTitle => 'まだ分からないこと';

  @override
  String get learnDiagramUnknownBody => 'Enpriveには見えない実際の通信';

  @override
  String get learnDiagramPolicyCaption => 'ポリシーは説明であり、実際の動作の証明ではありません';

  @override
  String get learnDiagramPolicySemantic =>
      'アプリのプライバシーに関する3つの要素を比較する図。1つ目、ポリシーの記載：開発者が書面で示した約束。2つ目、端末の表示：この端末で許可された権限。3つ目、破線枠の中のまだ分からないこと：Enpriveには見えない実際のインターネット通信。プライバシーポリシーは説明であり、実際の動作の証明ではありません。';

  @override
  String get learnPermissionsFolderTitle => '端末の権限';

  @override
  String get learnPermissionsTitle => 'Androidの権限のしくみ';

  @override
  String get learnPermissionsSubtitle => 'Androidの4つの選択肢と確認する場所';

  @override
  String get learnPermissionsIntro =>
      '権限は、アプリがカメラ、マイク、位置情報、写真、連絡先、通知など端末のセンサーやデータにアクセスできるかを管理する扉です。';

  @override
  String get learnPermissionsStep1 =>
      '機能に合うか考えてみましょう。計算ドリルや読書アプリに位置情報・連絡先・カメラが必要なことはほとんどありません。';

  @override
  String get learnPermissionsStep2 =>
      'Androidには最大4つの選択肢があります。「許可しない」「毎回確認する」「アプリの使用中のみ許可」「常に許可」（バックグラウンドの位置情報）です。';

  @override
  String get learnPermissionsStep3 =>
      'まずは「毎回確認する」や「アプリの使用中のみ」など、機能が動く範囲で最も狭い設定から始めましょう。';

  @override
  String get learnPermissionsStep4 =>
      'Androidの「設定」から「プライバシーダッシュボード」を開くと、最近カメラ・マイク・位置情報を使ったアプリを確認できます。';

  @override
  String get learnPermissionsStep5 =>
      '権限はアプリ設定からいつでもオフにできます。使っていないアプリの一時停止をオンにしておくと、Androidが古い権限を自動で外します。権限が許可されていても、データ送信の証明にはなりません。';

  @override
  String get learnPermissionsQuickQuestion =>
      '算数アプリがカメラ権限を求めてきて、理由が分かりません。最初の対応として最もよいのはどれですか？';

  @override
  String get learnPermissionsQuickOption1 => '「許可しない」をタップし、問題がそのまま解けるか試す';

  @override
  String get learnPermissionsQuickOption2 => '画面が二度と出ないよう「常に許可」を選ぶ';

  @override
  String get learnPermissionsQuickOption3 => 'アプリがすでに写真を送信したと決めつける';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      '正解です。「許可しない」を選べばカメラなしで動くか試せますし、必要になればAndroidの設定からいつでも変更できます。';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'まずは狭い設定から試しましょう。「許可しない」で動作を確かめ、許可されていること自体は送信の証明ではないことも覚えておきましょう。';

  @override
  String get learnDiagramPermLadderTitle => '狭い許可から広い許可まで';

  @override
  String get learnDiagramPermDenyTitle => '許可しない';

  @override
  String get learnDiagramPermDenyDetail => 'ブロック：アプリはこのセンサーを使えません';

  @override
  String get learnDiagramPermAskTitle => '毎回確認する';

  @override
  String get learnDiagramPermAskDetail => '許可をタップしたときだけ1回アクセス';

  @override
  String get learnDiagramPermWhileUsingTitle => 'アプリの使用中のみ';

  @override
  String get learnDiagramPermWhileUsingDetail => '画面にアプリが開いている間だけ';

  @override
  String get learnDiagramPermAllTimeTitle => '常に許可';

  @override
  String get learnDiagramPermAllTimeDetail => '閉じていてもバックグラウンドでアクセス';

  @override
  String get learnDiagramPermFitNote => '機能に合う？ 算数クイズ＋カメラ＝理由を確認';

  @override
  String get learnDiagramPermSemantic =>
      '狭い許可から広い許可までの4段階のAndroid権限図。ステップ1、許可しない：ブロックされ、センサーは使えません。ステップ2、毎回確認する：許可をタップしたときだけ1回アクセス。ステップ3、アプリの使用中のみ：画面に開いている間だけアクセス。ステップ4、常に許可：閉じていてもバックグラウンドでアクセス、注意喚起の破線枠付き。下部のヒント：機能に合う？ 算数クイズがカメラを求めたら理由を確かめましょう。';

  @override
  String get learnSharingFolderTitle => '広告と第三者';

  @override
  String get learnSharingTitle => 'データは他に誰へ？ 広告・分析・第三者';

  @override
  String get learnSharingSubtitle => 'アプリ提供元と、支援サービス・分析・広告ネットワークの違い';

  @override
  String get learnSharingIntro =>
      '無料アプリの多くは裏側で別の企業とつながっています。誰が情報を受け取るかを知ると、アプリを動かすための処理と、アプリをまたいだ子どもの追跡を見分けやすくなります。';

  @override
  String get learnSharingStep1 =>
      'ファーストパーティとはアプリ提供元自身のことです。たとえば、学習の進み具合やクイズの点数を保存してアプリを動かす仕組みです。';

  @override
  String get learnSharingStep2 =>
      '支援企業は、クラウド保存や不具合修正のためのクラッシュ報告など、裏側の作業を担う第三者です。';

  @override
  String get learnSharingStep3 =>
      '分析ツールは画面の使われ方を測ります。一方、広告ネットワークやデータ仲介業者は広告IDを使い、ターゲティング広告の表示やアプリ横断の行動分析を行うことがあります。';

  @override
  String get learnSharingStep4 =>
      '「信頼できるパートナー」「業務上の目的」といった広い表現に注意し、パーソナライズ広告をオフにする方法の記載があるか確認しましょう。';

  @override
  String get learnSharingQuickQuestion =>
      'ポリシーに「第三者パートナーと情報を共有する」と書かれています。次に確認すべき最善の問いはどれですか？';

  @override
  String get learnSharingQuickOption1 => '広告はないという意味だと考える';

  @override
  String get learnSharingQuickOption2 => 'すべてのパートナーがまったく同じ役割だと考える';

  @override
  String get learnSharingQuickOption3 =>
      'ホスティング等の支援サービスなのか、アプリ横断で追跡する広告ネットワークなのかを確認する';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'その通りです。支援サービスはアプリの動作を支え、広告ネットワークやデータ仲介業者はアプリをまたいだ追跡を行う場合があります。';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      '各パートナーの役割を区別して見ましょう。第三者といっても、データ保管や不具合修正を担う会社もあれば、広告や追跡を行う会社もあります。';

  @override
  String get learnDiagramThirdPartyYou => 'あなた';

  @override
  String get learnDiagramThirdPartyApp => '学習アプリ';

  @override
  String get learnDiagramThirdPartyHosting => '支援・不具合対応';

  @override
  String get learnDiagramThirdPartyAnalytics => '分析ツール';

  @override
  String get learnDiagramThirdPartyAds => '広告ネットワーク';

  @override
  String get learnDiagramThirdPartyFirstParty => '提供元（第一者）';

  @override
  String get learnDiagramThirdPartyThirdParty => '第三者';

  @override
  String get learnDiagramThirdPartySemantic =>
      '子ども向け学習アプリからデータがどこへ渡り得るかを示す流れ図。あなたから学習アプリへつながり、アプリ提供元（第一者）へは実線で、第三者である支援・不具合対応ツール、分析ツール、注意印付きの広告ネットワークへは破線でつながっています。';

  @override
  String get learnEvidenceFolderTitle => 'Enpriveの見方';

  @override
  String get learnEvidenceTitle => 'Enpriveの根拠の読み方';

  @override
  String get learnEvidenceSubtitle => '根拠の層・カテゴリ・誠実な限界';

  @override
  String get learnEvidenceIntro =>
      'Enpriveはポリシーの記載、端末の表示、まだ分からないことを分けて整理し、安全スコアではなくトピック別にまとめます。';

  @override
  String get learnEvidenceStep1 =>
      '5つのトピックカテゴリは確認画面と同じアイコンと色で表示されます。色は分類を示すもので、安全スコアではありません。';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '「$sourceMatched」は、確認したポリシー本文の中に一言一句同じ引用が見つかったことを意味します。';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '「$deviceObserved」は、この端末で権限設定が確認されたことを意味します。データ送信の証明ではありません。';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '「$interpretation」はDeniによるやさしい説明、「$unverified」はEnpriveが見つけられなかった内容です。ポリシーに書かれていないことは、しないという約束ではありません。';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return '確認結果は次の3つのいずれかで終わります。$reviewRecommended、$noConcern（安全性の認定ではありません）、または$insufficientEvidenceです。';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return '確認画面で「$deviceObserved」は何を意味しますか？';
  }

  @override
  String get learnEvidenceQuickOption1 => '子ども向けに安全認定されたアプリであること';

  @override
  String get learnEvidenceQuickOption2 => 'この端末でこの権限設定が表示されていること（送信の証明ではない）';

  @override
  String get learnEvidenceQuickOption3 => '子どものデータが確実に送信されたこと';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'その通りです。この表示はこの端末でのAndroid権限状態を示すだけで、データ送信の証明や安全認定ではありません。';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      '惜しいです。この表示は端末が報告する権限設定を示すのみで、送信の証明や安全性の認定ではありません。';

  @override
  String get learnDiagramEvidencePolicyDetail => 'ポリシー本文で一致した正確な引用';

  @override
  String get learnDiagramEvidencePhoneDetail => 'この端末でのアプリ権限';

  @override
  String get learnDiagramEvidenceDeniDetail => 'Deniによるやさしい説明';

  @override
  String get learnDiagramEvidenceUnknownDetail => 'ポリシーの沈黙は約束ではありません';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Enpriveの確認画面で使う4つの根拠の層。1、$sourceMatched：プライバシーポリシーで一致した正確な引用。2、$deviceObserved：この端末のアプリ権限。3、$interpretation：Deniのやさしい説明。4、破線で区切られた$unverified：ポリシーに書かれていないことは約束ではないため。';
  }

  @override
  String get learnDiagramCategoriesTitle => '確認画面の5つのトピックカテゴリ';

  @override
  String get learnDiagramCategoriesNote => '色とアイコンはトピックを示し、安全スコアではありません。';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Enpriveの確認画面に表示される5つの根拠カテゴリ（それぞれ固有のアイコンと色）：$dataCollection、$sharing、$tracking、$retention、$parentalControls。色とアイコンはトピックを示し、安全スコアではありません。';
  }

  @override
  String get learnDataCollectionFolderTitle => '集められるデータ';

  @override
  String get learnDataCollectionTitle => 'アプリが収集するデータとは';

  @override
  String get learnDataCollectionSubtitle => '自分で入力する情報と、裏側で自動収集される情報の違い';

  @override
  String get learnDataCollectionIntro1 =>
      'アプリは2つの方法で情報を集めます。1つは名前・メール・写真・音声録音・宿題の回答など、自分で入力する情報です。もう1つはIPアドレス（インターネット上の端末の住所）、端末識別子、広告ID（広告が端末を識別するコード）、クラッシュログ、アプリを開いた時刻など、裏側で自動的に集まる情報です。';

  @override
  String get learnDataCollectionStep1 =>
      '自分で入力する情報：名前、学校、メール、写真、音声、宿題の回答は、自分で選んで渡す情報です。';

  @override
  String get learnDataCollectionStep2 =>
      '裏側で集まる情報：ボタンを押さなくても、広告ID・端末識別子・IPアドレス・クラッシュ報告・利用時刻などが収集されることがあります。自動収集が必ず悪いわけではなく、安定した動作に役立つ場合もあります。';

  @override
  String get learnDataCollectionStep3 =>
      '子どもにとって敏感なデータ：位置情報、マイク録音、カメラ写真、声紋などの生体データ（体や声に関するデータ）は、子どものプライバシー上のリスクが高くなります。';

  @override
  String get learnDataCollectionStep4 =>
      'Play Storeの注意点：Google Playの「データセーフティ」欄は開発者の自己申告です。手がかりにはなりますが証明ではなく、端末内だけで処理されるデータや一時的なメモリ上のデータは含まれません。';

  @override
  String get learnDataCollectionQuizQuestion => '裏側で自動的に収集されるデータの例はどれですか？';

  @override
  String get learnDataCollectionQuizChoiceA => 'プロフィール用に自分でアップロードした写真';

  @override
  String get learnDataCollectionQuizChoiceB => '広告IDと端末識別子';

  @override
  String get learnDataCollectionQuizChoiceC => 'アプリ内で入力した宿題の答え';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      '正解です。広告IDと端末識別子は、自分で入力しなくても自動的に収集されます。';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      '惜しいです。それは自分で入力する情報です。裏側で集まる情報には、広告ID・端末識別子・IPアドレス・利用時刻などが含まれます。';

  @override
  String get learnDataCollectionDiagramYouTypeTitle => '自分で入力・提供するもの';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => '名前・メール・学校';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => '写真と動画';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => '音声録音';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => '宿題の回答';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle => '裏側で静かに集まるもの';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => '広告ID';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 => '端末識別子';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'IPアドレス';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 => 'クラッシュログと利用時刻';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      '自動収集が必ず悪いわけではありません。安定した動作に役立つ情報もあります。';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      'データ収集の2つの分類を示す図。上のカード「自分で入力・提供するもの」には名前・メール・学校、写真と動画、音声録音、宿題の回答の4つ。下のカード「裏側で静かに集まるもの」には広告ID、端末識別子、IPアドレス、クラッシュログと利用時刻の4つ。注釈に「自動収集が必ず悪いわけではありません。安定した動作に役立つ情報もあります。」とあり、下にDeniが考え込む姿で座っています。';

  @override
  String get learnDataCollectionCheckBridge =>
      'この端末のアプリを確認して、どんなデータを集めているか見てみましょう。';

  @override
  String get learnDataCollectionHonestyNote =>
      'このレッスンは一般的なデータの種類を説明しています。特定のアプリが何を集めて送信しているかを証明するものではありません。正確なポリシー本文と端末の権限設定でご確認ください。';

  @override
  String get learnRetentionFolderTitle => '保管と削除';

  @override
  String get learnRetentionTitle => 'データの保管と削除';

  @override
  String get learnRetentionSubtitle => 'アプリを削除しても、企業のサーバーにあるデータは消えません';

  @override
  String get learnRetentionIntro1 =>
      '端末からアプリを削除すると端末内のファイルは消えますが、すでに企業のサーバーへ送られたデータは残ります。プライバシーポリシーには保管期間、削除の依頼方法、バックアップの扱いが書かれているべきですが、「合理的に必要な期間」といった曖昧な表現も少なくありません。';

  @override
  String get learnRetentionStep1 => 'データ収集：アプリを使う間、情報は企業のサーバーへ送信され保存されます。';

  @override
  String get learnRetentionStep2 =>
      'サーバーに保存：アプリを使わなくなった後も、企業のシステム上にデータが残ることがあります。';

  @override
  String get learnRetentionStep3 =>
      'アンインストールしてもサーバーのデータは消えない：アプリを消しても端末内のファイルが消えるだけで、サーバー上のコピーは残ります。';

  @override
  String get learnRetentionStep4 =>
      '削除リクエスト：アカウントとデータの削除を企業へ依頼できます。対応にかかる日数がポリシーに記載されているか確認しましょう。';

  @override
  String get learnRetentionStep5 =>
      '保管期間が不明：「必要な期間」「業務上の目的のため」といった表現だけでは、いつ削除されるのか分かりません。';

  @override
  String get learnRetentionQuizQuestion =>
      '端末からアプリをアンインストールすると、企業サーバー上のデータはどうなりますか？';

  @override
  String get learnRetentionQuizChoiceA => '自動的に削除される';

  @override
  String get learnRetentionQuizChoiceB => 'サーバーに残ることがある（アンインストールだけでは消えない）';

  @override
  String get learnRetentionQuizChoiceC => 'すぐに匿名化される';

  @override
  String get learnRetentionQuizFeedbackRight =>
      '正解です。アンインストールで消えるのは端末内のアプリだけです。削除を依頼するまで、企業サーバーにデータが残る場合があります。';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      '惜しいです。アプリをアンインストールしても、すでにサーバーへ送られたデータは消えません。アカウント削除の依頼が必要です。';

  @override
  String get learnRetentionDiagramCollected => '利用中にデータが収集される';

  @override
  String get learnRetentionDiagramStored => '企業のサーバーに保存される';

  @override
  String get learnRetentionDiagramUninstall => 'アプリを削除：端末のファイルは消えてもサーバーのデータは残る';

  @override
  String get learnRetentionDiagramDeleteRequest => 'アカウント削除を依頼する';

  @override
  String get learnRetentionDiagramUnknownTail => '保管期間が不明：ポリシーに「必要な期間」と記載';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      'データの流れを示す5段階のタイムライン。ステップ1：利用中にデータが収集される（データベースアイコン）。ステップ2：企業のサーバーに保存される（サーバーアイコン）。ステップ3：アプリを削除すると端末ファイルは消えてもサーバーのデータは残る（スマホアイコン）。ステップ4：アカウント削除を依頼する（ゴミ箱アイコン）。ステップ5：保管期間が不明、ポリシーに「必要な期間」と記載（破線矢印とはてなアイコン）。下にレシートを持ったDeniが立っています。';

  @override
  String get learnRetentionCheckBridge =>
      'この端末のアプリを確認して、保管期間についてポリシーに何が書かれているか見てみましょう。';

  @override
  String get learnRetentionHonestyNote =>
      'このレッスンは一般的な保管の仕組みを説明しています。特定の企業がデータをどう扱っているかを証明するものではありません。正確なポリシー本文と削除依頼の結果でご確認ください。';

  @override
  String get learnUnclearPoliciesFolderTitle => '分かりにくいポリシー';

  @override
  String get learnUnclearPoliciesTitle => '曖昧なポリシーと誘導ボタンの見分け方';

  @override
  String get learnUnclearPoliciesSubtitle => 'ぼかした表現や同意を急かす画面に気づくコツ';

  @override
  String get learnUnclearPoliciesIntro1 =>
      'プライバシーポリシーの中には、曖昧な言葉を使ってデータの扱いが分かりにくいものがあります。また同意画面では、大きな「すべて同意」ボタンの横に小さな「設定を管理」リンクを置くなど、読まずに同意させる工夫が使われることもあります。';

  @override
  String get learnUnclearPoliciesStep1 =>
      '曖昧さのサイン：「信頼できるパートナーと共有する場合があります」「業務上の目的」「必要に応じて保管」といった広い表現は、具体的な内容をぼかしています。';

  @override
  String get learnUnclearPoliciesStep2 =>
      '書いていないことは約束ではない：ポリシーにマイク・広告・位置情報の記載がなくても、それらを使わない保証にはなりません。';

  @override
  String get learnUnclearPoliciesStep3 =>
      '基本情報の不足：分かりやすいポリシーには明確な発効日、連絡先メール、まとまった1つの文書があり、子ども向けの別紙が隠れていたりしません。';

  @override
  String get learnUnclearPoliciesStep4 =>
      '同意を急かす工夫（ダークパターン）：巨大な「すべて同意」ボタン、最初からオンの宣伝チェック、繰り返しの催促、分かりにくい解約手順は選択を誘導します。';

  @override
  String get learnUnclearPoliciesStep5 =>
      '公平な選択肢：分かりやすい画面では「許可」と「許可しない」が同じ目立ち方で並び、任意の項目は初期状態でオフになっています。';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      'プライバシーポリシーの中で、詳細が欠けている「曖昧な」表現はどれですか？';

  @override
  String get learnUnclearPoliciesQuizChoiceA => '個人情報を第三者へ販売することはありません';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      '業務上の目的のため信頼できるパートナーとデータを共有する場合があります';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'privacy@example.com へのメールで削除を依頼できます';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      '正解です。「業務上の目的のため信頼できるパートナーと共有する場合があります」は曖昧で、相手先も共有内容も分かりません。';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      '惜しいです。その文は具体的で行動につながります。曖昧な表現は詳細を示さず「共有する場合があります」「必要に応じて」といった言い回しを使います。';

  @override
  String get learnUnclearPoliciesDiagramClearTitle => '明確なポリシーの文';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      'アカウント作成のため氏名とメールを収集します。広告主とは共有しません。';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle => '曖昧なポリシーの文';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      '必要に応じて業務上の目的のため、信頼できるパートナーと情報を共有する場合があります。';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle => '曖昧さを見抜くコツ';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      '「〜の場合がある」「必要に応じて」などの表現は余地を残します。';

  @override
  String get learnUnclearPoliciesDiagramTip2 => 'データを渡す具体的な会社名が書かれているか確認しましょう。';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      '広告やマイクの記載がないことは、使わない約束ではありません。';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote => 'ポリシーの沈黙は約束ではありません。';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      '明確なポリシーの文と曖昧な文の比較図。左のカード「明確」には「アカウント作成のため氏名とメールを収集します。広告主とは共有しません。」、右のカード「曖昧」には「必要に応じて業務上の目的のため、信頼できるパートナーと情報を共有する場合があります。」と表示。下のカード「曖昧さを見抜くコツ」には3つのヒントがあり、曖昧カードには「ポリシーの沈黙は約束ではありません。」の注釈。カードの上からDeniがのぞいています。';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      'この端末のアプリを確認して、同意画面とポリシーの分かりやすさを確かめましょう。';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      'このレッスンはよくある曖昧な傾向を説明しています。特定のアプリがダークパターンを使ったり実態を隠したりしている証明にはなりません。実際のポリシー本文と同意画面をご確認ください。';

  @override
  String get learnSafeSharingFolderTitle => '安心な共有習慣';

  @override
  String get learnSafeSharingTitle => '子どものための安全な共有習慣';

  @override
  String get learnSafeSharingSubtitle => '止まる・考える・つなぐ：年齢に合わせたオンライン共有のステップ';

  @override
  String get learnSafeSharingIntro1 =>
      '写真・動画・名前・居場所を投稿する前に、一度止まって「止まる・考える・つなぐ」の3ステップを確認しましょう。このレッスンは信頼できる大人と一緒に読むためのものです。小さい子ども（5〜7歳）はタップする前に確認します。8〜11歳はニックネームと強いパスワードを使います。12〜17歳はデジタルフットプリント（投稿の足跡）や二段階認証（ログイン時の確認コードなど）を管理します。';

  @override
  String get learnSafeSharingStep1 =>
      '止まる：写真・動画・名前・学校・居場所を投稿する前に一呼吸おきましょう。迷ったら信頼できる大人に相談します。';

  @override
  String get learnSafeSharingStep2 =>
      '考える：学校や家、今いる場所が分かりませんか？ 友だちの写真やタグ付けの前に本人に聞きましたか？';

  @override
  String get learnSafeSharingStep3 =>
      'つなぐ：信頼できる人とだけ共有しましょう。本名・誕生日・住所・電話番号などの個人情報は秘密にします。';

  @override
  String get learnSafeSharingStep4 =>
      '学校の食堂テスト：学校のみんな（またはクラス全員）がこの写真やメッセージを見ても大丈夫ですか？ すぐ消える投稿でもスクリーンショットを撮られるとネットに残り続けます。';

  @override
  String get learnSafeSharingStep5 =>
      '5〜7歳：名前を入力したりポップアップを押したりする前に信頼できる大人に聞く。8〜11歳：ニックネーム（本名・誕生日・学校は使わない）と強いパスワードを使い、SMSやOTPコード（メッセージで届く一回限りの確認コード）は絶対に教えない。12〜17歳：プライバシー設定を確認し、二段階認証をオンにし、困ったときの通報方法を知る。';

  @override
  String get learnSafeSharingQuizQuestion => 'オンラインで共有するときの「学校の食堂テスト」とは何ですか？';

  @override
  String get learnSafeSharingQuizChoiceA => '食堂で食べるものだけを共有すること';

  @override
  String get learnSafeSharingQuizChoiceB =>
      '「学校のみんながこの写真やメッセージを見ても大丈夫か」と自分に問いかけること';

  @override
  String get learnSafeSharingQuizChoiceC => '昼休み中だけ共有すること';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      '正解です。食堂テストとは、投稿内容をみんなに見られても安心かどうかを自分に確かめることです。';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      '惜しいです。食堂テストは「自分の投稿を食堂にいる全員に見せられても大丈夫か」と考える心のチェックです。';

  @override
  String get learnSafeSharingDiagramStop => '止まる：投稿する前に一呼吸おく';

  @override
  String get learnSafeSharingDiagramThink => '考える：今いる場所や一緒の人が分からないか';

  @override
  String get learnSafeSharingDiagramConnect => 'つなぐ：信頼できる人だけ、迷ったら大人に聞く';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      '学校の食堂テスト：学校のみんなが見ても大丈夫？ 消える投稿でもスクリーンショットでずっと残ることがあります。';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      '安全な共有習慣を学ぶ4部構成の図。ステップ1：止まる：投稿する前に一呼吸おく（手のアイコン）。ステップ2：考える：今いる場所や一緒の人が分からないか（脳のアイコン）。ステップ3：つなぐ：信頼できる人だけ、迷ったら大人に聞く（人のアイコン）。ステップ4：学校の食堂テストの枠に「学校のみんなが見ても大丈夫？ 消える投稿でもスクリーンショットでずっと残ることがあります。」とあり、横に手を挙げたDeniが立っています。';

  @override
  String get learnSafeSharingCheckBridge => '保護者と一緒にアプリを確認して、共有のしくみを見てみましょう。';

  @override
  String get learnSafeSharingHonestyNote =>
      'このレッスンは一般的な共有習慣を紹介しています。特定のアプリが投稿内容を保護する保証にはなりません。必ずアプリのポリシーを読み、端末のプライバシー設定も活用してください。';

  @override
  String get translationDraftNotice =>
      '一部の翻訳はAIが作成した下書きであり、誤りが含まれる場合があります。現在、ネイティブ話者による確認を進めています。';

  @override
  String get homeQuickSettingsTitle => 'クイック設定コンパニオン';

  @override
  String get homeQuickSettingsSubtitle => '使っているアプリについて、いつでもDeniに聞けます';

  @override
  String get appearanceSectionTitle => '外観';

  @override
  String get themeModeSystem => 'システム';

  @override
  String get themeModeLight => 'ライト';

  @override
  String get themeModeDark => 'ダーク';

  @override
  String get quickSettingsSectionTitle => 'Enpriveをクイック設定に追加';

  @override
  String get quickSettingsSectionSubtitle =>
      'Enprive CheckをAndroidのクイック設定パネルに追加すると、操作を中断せずにアプリについてDeniに聞けます。';

  @override
  String get quickSettingsTileTitle => 'Enprive Checkタイル';

  @override
  String get quickSettingsTileSubtitle =>
      'Enprive Checkをクイック設定に追加すると、先にEnpriveを探さなくても、使っているアプリについてDeniに聞けます。';

  @override
  String get quickSettingsStatusAdded => '追加済み';

  @override
  String get quickSettingsStatusManual => '手動';

  @override
  String get quickSettingsStatusNotAdded => '未追加';

  @override
  String get usageAccessStatusGranted => '許可済み';

  @override
  String get usageAccessStatusNotGranted => '未許可';

  @override
  String get usageAccessTitle => '使用状況へのアクセスを許可 (任意)';

  @override
  String get usageAccessExplanation =>
      'Enpriveが使用状況へのアクセスを使うのは、Enprive Checkをタップして、直前に使っていたアプリを調べるときだけです。これによりDeniが正しいアプリとそのプライバシー情報を見つけられます。Enpriveが画面を常に監視することはありません。';

  @override
  String get usageAccessManageLink => '管理・取り消し方法';

  @override
  String get usageAccessManageTitle => '使用状況へのアクセスの管理と取り消し';

  @override
  String get usageAccessManageBody =>
      '使用状況へのアクセスは、Androidの設定にある特別なスイッチです (自動で表示されるポップアップではありません)。Androidの設定 → アプリ → 特別なアプリアクセス → 使用状況へのアクセス → enprive から、いつでもオフにできます。オフでも、アプリを手動で選べばDeniは使えます。';

  @override
  String get openDeniCompanionTitle => 'Deniコンパニオンを開く';

  @override
  String get openDeniCompanionSubtitle =>
      'クイック設定を使わずに、最近使ったアプリや選んだアプリの権限を確認します。';

  @override
  String get btnGotIt => 'わかりました';

  @override
  String get quickSettingsReadyDialogTitle => 'Enprive Checkがクイック設定で使えます';

  @override
  String get quickSettingsReadyDialogBody =>
      '画面の上から2回下にスワイプして、Deniにアプリの権限を説明してほしいときに「Enprive Check」をタップしてください。';

  @override
  String get quickSettingsManualDialogTitle => 'Enprive Checkを手動で追加';

  @override
  String get quickSettingsManualDialogBody =>
      '1. Android画面の上から2回下にスワイプして、クイック設定を開きます。\n2. 編集 (鉛筆) ボタンをタップします。\n3. 「Enprive Check」を見つけて、使用中のタイルにドラッグします。';

  @override
  String get quickSettingsSnackAdded => 'Enprive Checkをクイック設定に追加しました。';

  @override
  String get quickSettingsSnackAlreadyAdded => 'Enprive Checkはすでにクイック設定にあります。';

  @override
  String get quickSettingsSnackDeclined =>
      'リクエストを閉じました。クイック設定で「編集」を選ばない限り、Enpriveは再度お願いしません。';

  @override
  String get quickSettingsSnackManual =>
      'クイック設定を下にスワイプして「編集」をタップし、Enprive Checkをタイルにドラッグしてください。';

  @override
  String get quickSettingsSnackUnavailable =>
      'ここではシステムの確認画面を表示できません。クイック設定の「編集」からEnprive Checkを手動でドラッグできます。';

  @override
  String get usageAccessOpenFailedSnack => 'この端末で使用状況へのアクセスの設定を開けませんでした。';

  @override
  String get companionTitle => 'Deni: Enpriveコンパニオン';

  @override
  String get companionSubtitle => 'アプリの権限と、そのプライバシーポリシーの内容についてDeniに聞けます。';

  @override
  String get companionTooltipReturnToPrev => '前のアプリに戻る';

  @override
  String get companionTooltipBack => '戻る';

  @override
  String get companionLockedBadge => 'ロック画面で保護中';

  @override
  String get companionLockedTitle => '続けるには電話のロックを解除してください';

  @override
  String get companionLockedBody =>
      '端末がロックされている間、Enpriveはアプリ名、申告された権限、確認の根拠を表示しません。';

  @override
  String get companionCheckUnlockBtn => 'ロック状態を確認';

  @override
  String get companionCheckingAppHeadline => '使っていたアプリを確認しています…';

  @override
  String get companionCheckingAppSubtitle => '画面を見張ることなく、この端末で1回だけ確認します。';

  @override
  String get companionGeneralGuideHeadline => 'Androidの権限の一般ガイド';

  @override
  String get companionGeneralGuideSubtitle =>
      'アプリが選ばれていません。Enpriveは端末内のガイドだけでAndroidの権限を説明します。';

  @override
  String companionLookingAtHeadline(String appName) {
    return '$appNameを表示しています。';
  }

  @override
  String get companionLookingAtSubtitle =>
      '以下の権限は、お使いの端末のアプリから取得したものです。画面に出ているポップアップはAndroidが管理しています。';

  @override
  String get companionThisAppFallback => 'このアプリ';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return '$seconds秒前に$appNameを確認しました。合っていますか？';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return '$appNameを使っているようです。合っていますか？';
  }

  @override
  String companionAppIdLine(String packageName) {
    return 'App ID: $packageName';
  }

  @override
  String companionConfirmAppBtn(String appName) {
    return '確定 · $appName';
  }

  @override
  String get companionChooseAnotherAppBtn => '別のアプリを選ぶ';

  @override
  String get companionWithoutAppContextBtn => 'アプリを指定しない';

  @override
  String get companionMultipleAppsTitle => 'さきほど複数のアプリが動いていました';

  @override
  String get companionMultipleAppsPrompt => '調べたいアプリを確認してください:';

  @override
  String companionSecondsAgo(int seconds) {
    return '$seconds秒前';
  }

  @override
  String get companionSelectAppTitle => '確認したいアプリを選んでください';

  @override
  String get companionSelectAppBody => 'インストール済みのアプリから手動で選ぶか、アプリを指定せずに続けられます。';

  @override
  String get companionChooseAppManuallyBtn => 'アプリを手動で選ぶ';

  @override
  String get companionOpenUsageAccessBtn => '使用状況へのアクセスの設定を開く';

  @override
  String get companionContinueWithoutAppBtn => 'アプリを指定せずに続ける';

  @override
  String get companionAddTileBtn => 'Enprive Checkタイルを追加';

  @override
  String get companionContinuingWithoutApp => 'アプリを指定せずに続けています';

  @override
  String get companionSwitchAppBtn => 'アプリを切り替える';

  @override
  String get companionPermissionsReadLocally => '以下の権限は、お使いの端末から直接読み取ったものです。';

  @override
  String get companionPickPermissionType => '確認したい権限の種類を選んでください';

  @override
  String get companionPickAppBtn => 'アプリを選ぶ';

  @override
  String get companionCouldNotReadPermsTitle => 'アプリの権限を読み取れませんでした';

  @override
  String get companionCouldNotReadPermsBody => 'Androidがこのアプリの権限の確認を止めました。';

  @override
  String get companionUnsurePermBtn => 'どの権限かわからない';

  @override
  String get companionWhichPermissionPrompt => 'どの権限について知りたいですか？';

  @override
  String get companionPermissionsListDisclaimer =>
      'これはアプリが端末上で一覧にしている権限で、今画面に出ているポップアップとは限りません。';

  @override
  String get companionNoSensitivePermsMsg => 'このアプリは、端末上で重要な権限を求めていません。';

  @override
  String get companionGuidedMatchTitle => '画面のポップアップが求めた内容を選んでください';

  @override
  String get companionGuidedMatchSubtitle =>
      'Enpriveは今のAndroidの確認画面を直接読み取れません。画面に出た文言にいちばん近いものを選んでください:';

  @override
  String get companionSection1Title => '1. この権限の意味';

  @override
  String get companionSection2Title => '2. アプリが端末上で求めている内容';

  @override
  String get companionSection3Title => '3. プライバシーポリシーの内容';

  @override
  String get companionSection4Title => '4. 機能との関係があるかもしれない理由';

  @override
  String get companionSection4Fallback =>
      '開発者が確認できる機能の説明は見つかりませんでした。Deniに関連性を調べてほしい場合は、使おうとしていた機能を下に書いてください。';

  @override
  String get companionSection5Title => '5. まだわからないこと';

  @override
  String get companionSection6Title => '6. Deniに聞ける質問';

  @override
  String get companionAddPolicyBtn => 'プライバシーポリシーを追加';

  @override
  String get companionCheckUpdatedPolicyBtn => '更新されたプライバシーポリシーを確認';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return '$appNameのポリシーを確認';
  }

  @override
  String get companionFeatureFieldLabel => '使っていた機能 (任意)';

  @override
  String get companionFeatureFieldHint => '例: QRコードの読み取り、音声の練習の録音';

  @override
  String get companionQuestionFieldLabel => 'Deniに質問する';

  @override
  String get companionQuestionFieldHint => 'この権限を許可しないとどうなりますか？';

  @override
  String get companionReceiptSavedTitle => 'Enpriveのレシートに保存しました';

  @override
  String get companionReceiptUnsavedTitle => '確認はまだEnpriveに保存されていません';

  @override
  String get companionReceiptSavedBody => 'Enpriveのレシート保管庫に、端末内だけで保存されています。';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      '更新したポリシーの確認は、このセッションの中だけに残ります。コンパニオンを閉じるとこの下書きは破棄され、保存済みのレシートは変わりません。';

  @override
  String get companionReceiptUnsavedBody =>
      'このセッションの中だけに残ります。保存しないままコンパニオンを閉じると破棄されます。';

  @override
  String get companionSaveReceiptBtn => 'レシートをEnpriveに保存';

  @override
  String get companionSaveReceiptFailed =>
      'レシートを保存できませんでした。このセッションには残っています。もう一度お試しください。';

  @override
  String get companionSavedLocalReceiptsSnack => '端末内のレシートに保存しました。';

  @override
  String companionDoneReturnToApp(String appName) {
    return '完了 · $appNameに戻る';
  }

  @override
  String get companionDoneReturnToPrev => '完了 · 前のアプリに戻る';

  @override
  String get companionOpenFullAppBtn => 'Enpriveアプリ全体を開く';

  @override
  String get companionCloudTimeoutSnack => 'クラウド分析に時間がかかりすぎたため、完了前に停止しました。';

  @override
  String get companionAnalysisCancelledSnack => '分析をキャンセルしました。';

  @override
  String get companionCloudAnswerTimeoutSnack =>
      'クラウドの回答がタイムアウトしました。問題なく終了しています。';

  @override
  String get companionQuestionCancelledSnack => '質問をキャンセルしました。';

  @override
  String get companionTileAddedSnack => 'Enprive CheckをAndroidのクイック設定に追加しました。';

  @override
  String get companionTileAlreadyAddedSnack => 'Enprive Checkはすでにクイック設定にあります。';

  @override
  String get companionTileDeclinedSnack =>
      'タイルのリクエストを閉じました。設定、またはクイック設定の「編集」からいつでも追加できます。';

  @override
  String get companionTileManualSnack =>
      'クイック設定を2回下にスワイプして「編集」をタップし、Enprive Checkをタイルにドラッグしてください。';

  @override
  String get companionTileUnavailableSnack =>
      'この端末では、Androidがクイック設定の確認画面を表示できませんでした。クイック設定の「編集」からEnprive Checkを手動でドラッグできます。';

  @override
  String get companionUsageOptionalReason =>
      '使用状況へのアクセスは任意です。アプリを手動で選ぶか、使用状況へのアクセスを許可するとワンタップで特定できます。';

  @override
  String get companionPermPreciseLocation => '正確な位置情報';

  @override
  String get companionPermBackgroundLocation => 'バックグラウンドの位置情報';

  @override
  String get companionPermCamera => 'カメラ';

  @override
  String get companionPermMicrophone => 'マイク';

  @override
  String get companionPermAdId => 'Google広告ID';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return '$appNameが申告したAndroidの権限 ($permission)。';
  }

  @override
  String get companionPermStatusAdId => 'アプリが一覧に記載 · 広告ID';

  @override
  String get companionPermStatusAllowed => 'アプリが一覧に記載 · 許可';

  @override
  String get companionPermStatusNotAllowed => 'アプリが一覧に記載 · 不許可';

  @override
  String get guidedCatLocation => '位置情報';

  @override
  String get guidedCatContacts => '連絡先';

  @override
  String get guidedCatPhotosMedia => '写真とメディア';

  @override
  String get guidedCatNotifications => '通知';

  @override
  String get guidedCatNearbyDevices => '付近のデバイス';

  @override
  String get guidedCatCalendar => 'カレンダー';

  @override
  String get guidedCatPhone => '電話';

  @override
  String get guidedCatSms => 'SMS';

  @override
  String get companionFallbackUsageNotEnabled =>
      'Androidの設定で使用状況へのアクセスがオンになっていません。';

  @override
  String get companionFallbackUsageUnavailable =>
      'AndroidのUsageStatsManagerを利用できません。';

  @override
  String get companionFallbackTransientUi =>
      '最近の使用状況にはAndroidのシステム画面や権限の確認画面しか出ていません。アプリを手動で選んでください。';

  @override
  String get companionFallbackVisibilityRestricted =>
      'Androidのパッケージ可視性の制限により、直前に使っていたアプリは確認できません。一覧からアプリを選ぶか、ポリシーを貼り付けてください。';

  @override
  String get companionFallbackUnlockRequired => 'アプリの情報を見る前に、端末のロックを解除してください。';

  @override
  String get consentReasonPolicyTooDetailed =>
      'このポリシーは詳しすぎて、オンデバイスAIでは処理できません。';

  @override
  String get consentReasonExcerptTooDetailed => 'この抜粋は詳しすぎて、オンデバイスAIでは処理できません。';

  @override
  String get consentReasonOnDeviceUnavailable => 'この端末では今、オンデバイスAIを利用できません。';

  @override
  String get consentReasonOnDeviceCannotAnswer =>
      '今は、この端末のオンデバイスAIが回答できませんでした。';

  @override
  String get consentReasonVoiceTooLong =>
      '確認済みのこれらの内容は、オンデバイスの要約の上限を超えています。オフラインの要約を今すぐ使うか、個人情報を隠した内容を1回だけクラウドAIに送れます。';

  @override
  String get consentReasonVoiceUnavailable =>
      'この端末では今、オンデバイスAIを利用できません。Enpriveのオフラインのやさしい要約を表示しています。';

  @override
  String get consentReasonVoiceTimedOut =>
      'オンデバイスの要約がタイムアウトしました。Enpriveのオフラインのやさしい要約を表示しています。';

  @override
  String get unsavedExitTitle => 'このプライバシー確認を保存しますか？';

  @override
  String get unsavedExitModifiedBody =>
      '保存していない確認は、この画面を閉じると破棄されます。あなたが選ばない限り、端末には何も保存されません。元の保存済みレシートは変わりません。';

  @override
  String get unsavedExitDraftBody =>
      '保存していない確認は、この画面を閉じると破棄されます。あなたが選ばない限り、端末には何も保存されません。';

  @override
  String get unsavedExitDiscardBtn => '保存せずに破棄';

  @override
  String get unsavedExitContinueBtn => '確認を続ける';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return '$titleのプライバシーポリシーを更新';
  }

  @override
  String get reviewSaveFailedError => 'レシートを保存できませんでした。確認の下書きはまだ開いています。';

  @override
  String get reviewRemovedFromReceiptsSnack => '保存済みのレシートから削除しました。';

  @override
  String get reviewRemoveFailedSnack => '保存済みのレシートを削除できませんでした。';

  @override
  String get reviewModifiedDraftTitle => '保存済みレシートからの新しい下書き';

  @override
  String get reviewModifiedDraftBody =>
      'この更新した確認を残すには、レシートに保存してください。元の保存済みレシートは変わりません。';

  @override
  String get btnRetrySave => '保存を再試行';

  @override
  String samplePermissionsHeader(String badge) {
    return 'サンプルの権限 ($badge)';
  }

  @override
  String get sourceKindUrl => '公開Webリンク';

  @override
  String get sourceKindPdf => '端末内のPDFファイル';

  @override
  String get sourceKindDocx => '端末内のWord (DOCX) ファイル';

  @override
  String get sourceKindTextFile => '端末内のテキストファイル';

  @override
  String get sourceKindSharedText => '共有されたテキスト';

  @override
  String get sourceKindSelectedText => '選択したテキスト';

  @override
  String get sourceKindSampleApp => 'サンプルアプリ';

  @override
  String get sourceKindPhonePermissions => '端末の権限';

  @override
  String get sourceKindPastedText => '貼り付けたテキスト';

  @override
  String get extractionStatusExtracted => 'この端末で読み取り済み';

  @override
  String get extractionStatusNone => 'この端末で入力済み';

  @override
  String get extractionStatusUnsupported => '未対応のファイル形式';

  @override
  String get extractionStatusTooLarge => 'ファイルが大きすぎます';

  @override
  String get extractionStatusEmpty => '読み取れるテキストがありません';

  @override
  String get extractionStatusReadError => 'ファイルを読み取れませんでした';

  @override
  String get extractionStatusPasswordProtected => 'パスワードで保護されています';

  @override
  String get extractionStatusPermissionDenied => '権限がありません';

  @override
  String get extractionStatusCancelled => 'キャンセルしました';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return '確認日時: $timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return '正規URL: $url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return 'リダイレクト元: $url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return 'ファイル: $filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return '状態: $status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return 'ソースのSHA-256ハッシュ: $hash';
  }

  @override
  String get semanticsPrimaryNavigation => 'メインナビゲーション';

  @override
  String semanticsProcessingLocation(String label) {
    return '処理場所: $label';
  }

  @override
  String get semanticsDeniMascot => 'Deni、あなたのプライバシーガイド';

  @override
  String get quoteCollapsibleDefaultHeader => 'ポリシーの原文の抜粋';
}
