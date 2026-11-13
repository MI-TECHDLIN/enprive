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
      '1つ以上の条項または権限の不一致について、保護者による確認をおすすめします。';

  @override
  String get stateInsufficientEvidence => '根拠が不足しています';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      '根拠が不足しているか、利用できないか、この端末上で検証できませんでした。';

  @override
  String get chipOnDevice => 'このデバイス上';

  @override
  String get chipInCloud => 'クラウドで分析';

  @override
  String get chipLocationUnavailable => '処理場所を確認できません';

  @override
  String get statusSourceMatched => '原文一致を確認';

  @override
  String get statusDeviceObserved => '端末上で確認';

  @override
  String get statusInterpretation => 'わかりやすい説明';

  @override
  String get statusUnverified => '未検証';

  @override
  String get statusStale => '古い情報';

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
      'この文章をクラウドで分析するため、Enpriveは下に表示されたテキストのみをFirebase AI Logicに送信します。インストール済みアプリ一覧やAndroidの権限情報は送信されません。';

  @override
  String get permissionLimitationNotice =>
      'Androidがこの端末上で報告している権限状態です。アプリが実際にデータへアクセスまたは送信したかを証明するものではありません。';

  @override
  String get navHome => 'ホーム';

  @override
  String get navReceipts => 'レシート';

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
  String get checkQuoteDesc => '第三者提供・音声録音・保存期間などの記述を原文の引用付きで示します。';

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
      other: '確認済み条項 $count件',
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
  String get readinessRow3Title => '個人情報を自動でマスク';

  @override
  String get readinessRow3Desc =>
      '端末内AIが使えない場合や長文の規約では、氏名・メール・電話番号を伏せ字に置き換えてApp Checkで検証します。';

  @override
  String get settingsTitle => '設定';

  @override
  String get privateAnalysisTitle => 'この端末でのプライベート分析';

  @override
  String get onDeviceReadyMsg => 'オンデバイスAIが利用可能です。';

  @override
  String get localScannerProtectedMsg => '内蔵ローカル条項スキャナーで保護されています。';

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
      'この端末でGemini Nanoの準備ができています。分析はすべてデバイス上で完結します。';

  @override
  String get modelDownloadingMsg => 'プライベートモデルをバックグラウンドでダウンロード中です。';

  @override
  String get modelDownloadableMsg => 'Wi-Fi接続時にオンデバイスモデルをダウンロードできます。';

  @override
  String get localScannerDefaultMsg => 'この端末では既定でEnprive内蔵のローカル条項スキャナーを使用します。';

  @override
  String get preparingPrivateAnalysis => 'プライベート分析を準備中…';

  @override
  String get onDeviceAiReadyTitle => 'オンデバイスAI準備完了';

  @override
  String get localScannerActiveTitle => 'ローカルスキャナー稼働中';

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
  String get readingClausesInitial => 'この端末でポリシー条項を読み取り中…';

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
  String get thoughtSignaturePrefix => '思考署名';

  @override
  String get viewStreamedThoughts => '推論プロセスを表示';

  @override
  String get hideStreamedThoughts => '推論プロセスを非表示';

  @override
  String get analysisTraceDefaultTitle => 'この確認の検証手順';

  @override
  String get savedToLocalReceiptsSnack => '端末のレシートに保存しました。';

  @override
  String get snapshotSheetTitle => '確認済みポリシーの全文';

  @override
  String get snapshotSourcePrefix => '取得元';

  @override
  String get snapshotReviewedPrefix => '確認日時';

  @override
  String get snapshotDigestPrefix => 'ダイジェスト';

  @override
  String get statFindings => '検出数';

  @override
  String get statVerified => '検証済み';

  @override
  String get statOsGranted => 'OS許可済み';

  @override
  String get statUnverified => '未検証';

  @override
  String get keyFindingsTitle => '主な確認ポイント';

  @override
  String get reviewedExcerptTitle => '確認した抜粋';

  @override
  String get permissionsOnPhoneTitle => 'この端末のアプリ権限';

  @override
  String get viewReviewedSnapshot => '確認済みポリシースナップショットを表示';

  @override
  String get btnSavedToReceipts => 'レシートに保存済み';

  @override
  String get observedOnPhoneLabel => 'この端末で確認';

  @override
  String get quoteVerifiedLabel => 'ポリシー原文と一致';

  @override
  String get unverifiedClaimLabel => '未検証の記述';

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
  String get labelWhatRemainsUnknown => 'まだ不明な点';

  @override
  String get presetQuestionMeaning => '子どもにどのような影響がありますか？';

  @override
  String get presetQuestionOptOut => 'これをオフにしたり拒否したりできますか？';

  @override
  String get presetQuestionUnknown => 'ここでまだ分からない点は何ですか？';

  @override
  String get readingCitedClause => '引用された条項を読み込み中…';

  @override
  String get deniAnswerTitle => 'Deniの回答';

  @override
  String get stepsAndReasoning => '確認ステップとモデル推論';

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
}
