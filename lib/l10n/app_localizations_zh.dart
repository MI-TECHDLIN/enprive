// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => '基于原文证据的应用隐私审查';

  @override
  String get homePrivacySubtitle => '您的审查记录仅保留在此手机本地。';

  @override
  String get stateNoConcern => '未发现值得担忧的条款';

  @override
  String get stateNoConcernSubtitle => '在已审查的证据中未发现令人担忧的内容。这并非安全认证。';

  @override
  String get stateReviewRecommended => '建议人工复查';

  @override
  String get stateReviewRecommendedSubtitle =>
      'One or more policy parts or phone permissions need a closer look.';

  @override
  String get stateInsufficientEvidence => '证据不足';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'We need more privacy policy text before we can check what this app does.';

  @override
  String get chipOnDevice => '在此设备上';

  @override
  String get chipInCloud => '云端分析';

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
  String get btnCheckApp => '检查应用';

  @override
  String get btnPasteTerms => '粘贴条款或网址';

  @override
  String get btnWhyThisFinding => '为何有此发现？';

  @override
  String get btnSaveToReceipts => '保存到收据记录';

  @override
  String get btnDiscard => '丢弃';

  @override
  String get btnAskDeni => '询问 Deni';

  @override
  String get btnUseCloud => '本次使用云端分析';

  @override
  String get btnReviewManually => '手动审查';

  @override
  String get btnGetStarted => '开始使用';

  @override
  String get btnContinue => '继续';

  @override
  String get deniIntro =>
      '你好，我是 Deni。我可以帮你看懂隐私政策中的表述，指出每项结论对应的原文证据，并说明哪些内容 Enprive 无法验证。';

  @override
  String get cloudConsentDisclosure =>
      'To check this in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Your phone shows whether this permission is allowed. It does not prove whether the app actually accessed or sent data.';

  @override
  String get navHome => '首页';

  @override
  String get navCheck => '检查';

  @override
  String get navReceipts => '收据';

  @override
  String get navLearn => '学习';

  @override
  String get navSettings => '设置';

  @override
  String get languageTitle => '语言';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get languageSubtitle => '应用于界面文字、分析说明及语音朗读';

  @override
  String get homeHeroHeadline => '更清晰地了解\n孩子使用的应用';

  @override
  String get trySampleCheck => '体验示例应用检查';

  @override
  String get eduTrackSubtitle => '作业与考勤';

  @override
  String get eduTrackValue => '3 项请求';

  @override
  String get eduTrackTrend => '建议复查';

  @override
  String get calmMathSubtitle => '离线数学练习';

  @override
  String get calmMathValue => '0 项敏感';

  @override
  String get calmMathTrend => '精简';

  @override
  String get whatWeCheckTitle => '重点检查内容';

  @override
  String get checkQuoteTitle => '精确原文引用';

  @override
  String get checkQuoteDesc =>
      'Highlights data sharing, voice recording, and how long data is kept using exact quotes.';

  @override
  String get checkPermissionTitle => '手机权限不一致';

  @override
  String get checkPermissionDesc => '将相机、麦克风和位置权限的实际状态与隐私政策声明直接比对。';

  @override
  String get checkSelectTitle => '随处选中文本即可查';

  @override
  String get checkSelectDesc => '在任意应用中选中条款文本，然后点击 Android 菜单中的 Enprive Check。';

  @override
  String get recentlyReviewed => '最近审查记录';

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
  String get trySampleText => '填入示例文本';

  @override
  String get modePasteText => '粘贴文本';

  @override
  String get modePolicyLink => '政策链接';

  @override
  String get hintAppName => '应用名称';

  @override
  String get defaultSubjectTitle => '隐私政策';

  @override
  String get selectedExcerptTitle => '选中的政策摘录';

  @override
  String get hintPastePolicy => '在此处粘贴隐私政策或服务条款…';

  @override
  String get btnReviewOnPhone => '在此手机上审查';

  @override
  String get onboardingIntroHeadline => '你好，我是 Deni。👋';

  @override
  String get onboardingIntroLead => '让我们把应用隐私变得更容易理解。';

  @override
  String get onboardingIntroBody =>
      '我会帮你看清应用隐私政策真正写了什么，标出关键的原文段落，并解释你的设备报告了哪些权限信息。\n\n不猜测，不作虚假承诺。只有清晰的解释与确凿的证据，帮助你做出知情决定。';

  @override
  String get onboardingIntroFooter => '清楚了解你正在同意的内容。';

  @override
  String get splashQuote => '清楚了解你正在同意的内容';

  @override
  String get onboardingStep1Question => '你希望我如何解释\n隐私条款？';

  @override
  String get depthQuickMultiline => '简明\n扼要';

  @override
  String get depthBalancedMultiline => '摘要与\n原文兼顾';

  @override
  String get depthFullMultiline => '逐条\n详尽解析';

  @override
  String get onboardingReadinessTitle => '默认保护此手机\n本地隐私';

  @override
  String get onboardingReadinessSubtitle => '专为家长和老师打造，无需上传设备数据即可审查应用隐私。';

  @override
  String get readinessRow1Title => '优先在本机检查';

  @override
  String get readinessRow1Desc => '隐私条款会先在你自己的手机上完成阅读和匹配。';

  @override
  String get readinessRow2Title => '你的应用信息不离机';

  @override
  String get readinessRow2Desc => '此手机上的已安装应用及 Android 权限状态绝不上传。';

  @override
  String get readinessRow3Title => 'Personal details hidden';

  @override
  String get readinessRow3Desc =>
      'If you choose cloud help, names, emails, and phone numbers are hidden before anything is sent.';

  @override
  String get settingsTitle => '设置';

  @override
  String get privateAnalysisTitle => '此手机上的私密分析';

  @override
  String get onDeviceReadyMsg => '端侧 AI 已激活并准备就绪。';

  @override
  String get localScannerProtectedMsg =>
      'Ready to check policies offline on this phone.';

  @override
  String get statusChecking => '正在检查…';

  @override
  String get btnCheckReadiness => '检查就绪状态';

  @override
  String get howShouldDeniExplain => 'Deni 应该如何讲解？';

  @override
  String get depthQuick => '简明';

  @override
  String get depthBalanced => '均衡';

  @override
  String get depthFull => '详尽';

  @override
  String get preferencesSection => '偏好设置';

  @override
  String get meetDeniGuide => '认识 Deni 与引导说明';

  @override
  String clearSavedReceiptsCount(int count) {
    return '清除已保存的收据 ($count)';
  }

  @override
  String get btnClear => '清除';

  @override
  String get confirmClearReceiptsTitle => '要清除所有已保存的收据吗？';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '这将从此手机中移除 $count 条已保存的审查记录。',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => '取消';

  @override
  String get receiptsTitle => '收据';

  @override
  String get tooltipSearch => '搜索';

  @override
  String get hintSearchReceipts => '搜索已保存的审查记录...';

  @override
  String get filterAll => '全部';

  @override
  String get filterReview => '待复查';

  @override
  String get filterNoConcern => '无担忧';

  @override
  String get emptyFilteredTitle => '没有匹配的收据';

  @override
  String get emptyReceiptsTitle => '尚无已保存的收据';

  @override
  String get emptyFilteredBody => '请尝试选择上方的其他筛选条件。';

  @override
  String get emptyReceiptsBody => '在任何审查结果页点击书签图标，即可将隐私副本保存在本机。';

  @override
  String get btnStartReview => '开始一次审查';

  @override
  String get btnOpenReceipt => '打开收据';

  @override
  String get btnDelete => '删除';

  @override
  String get checkingPhoneReadiness => '正在检查此手机的私密分析就绪状态…';

  @override
  String get geminiNanoReadyMsg =>
      'On-device AI is ready on this phone. Reviews stay completely on your device.';

  @override
  String get modelDownloadingMsg => '正在后台下载端侧私密模型。';

  @override
  String get modelDownloadableMsg => '可在连接 Wi-Fi 时下载端侧模型。';

  @override
  String get localScannerDefaultMsg =>
      'This phone checks policies offline on your device by default.';

  @override
  String get preparingPrivateAnalysis => '正在准备私密分析…';

  @override
  String get onDeviceAiReadyTitle => '端侧 AI 已就绪';

  @override
  String get localScannerActiveTitle => 'Offline check ready';

  @override
  String get privateAnalysisSheetSubtitle => '你的已安装应用列表和权限检查绝不会离开手机。';

  @override
  String get btnDone => '完成';

  @override
  String get btnCheckAgain => '重新检查';

  @override
  String get reviewingOnPhone => '正在此手机上审查…';

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
      other: '$count 个步骤',
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
  String get analysisTraceDefaultTitle => '本次审查的验证过程';

  @override
  String get savedToLocalReceiptsSnack => '已保存到本机收据记录。';

  @override
  String get snapshotSheetTitle => 'Reviewed policy text';

  @override
  String get snapshotSourcePrefix => '来源';

  @override
  String get snapshotReviewedPrefix => '审查时间';

  @override
  String get snapshotDigestPrefix => 'Document fingerprint';

  @override
  String get statFindings => '发现条目';

  @override
  String get statVerified => '已验证';

  @override
  String get statOsGranted => 'Allowed on phone';

  @override
  String get statUnverified => 'Not found';

  @override
  String get keyFindingsTitle => '核心发现';

  @override
  String get reviewedExcerptTitle => '已审查原文摘要';

  @override
  String get permissionsOnPhoneTitle => '此手机上的应用权限';

  @override
  String get viewReviewedSnapshot => 'View reviewed policy text';

  @override
  String get btnSavedToReceipts => '已保存至收据';

  @override
  String get observedOnPhoneLabel => 'Seen on this phone';

  @override
  String get quoteVerifiedLabel => 'Exact quote from policy';

  @override
  String get unverifiedClaimLabel => 'Not found in policy';

  @override
  String get categoryDataCollection => '数据收集';

  @override
  String get categorySharing => '第三方共享';

  @override
  String get categoryTracking => '定位与追踪';

  @override
  String get categoryRetention => '数据保留与语音';

  @override
  String get categoryParentalControls => '家长控制';

  @override
  String get labelInPlainLanguage => '通俗说明';

  @override
  String get labelOnThisPhone => '本机权限情况';

  @override
  String get labelWhatRemainsUnknown => 'What we still don\'t know';

  @override
  String get presetQuestionMeaning => '这对我的孩子意味着什么？';

  @override
  String get presetQuestionOptOut => '可以关闭或选择退出吗？';

  @override
  String get presetQuestionUnknown => '这里还有哪些未明确的信息？';

  @override
  String get readingCitedClause => 'Reading the policy quote…';

  @override
  String get deniAnswerTitle => 'Deni 的回答';

  @override
  String get stepsAndReasoning => 'How Deni checked this';

  @override
  String get chooseReviewModeTitle => '选择如何审查此文本';

  @override
  String get cloudNeverSendsAppsNote => '绝不会发送已安装的应用或手机权限信息。';

  @override
  String get tooltipClose => '关闭';

  @override
  String get checkAppSheetSubtitle => '仅在此手机本地核查，应用列表绝不会上传。';

  @override
  String get trySampleKidsApp => '试用示例儿童应用';

  @override
  String get sampleEduTrackSubtitle => '定位、麦克风和相机';

  @override
  String get sampleCalmMathSubtitle => '离线数学练习';

  @override
  String get appsOnThisPhone => '此手机上的应用';

  @override
  String get hintSearchApps => '搜索应用…';

  @override
  String get noMatchingApps => '在此手机上未找到匹配的应用。';

  @override
  String get sampleSyntheticBadge => 'Sample app';

  @override
  String get permissionInspectionTitle => 'Phone permissions checked';

  @override
  String get addAppPrivacyPolicyBtn => '添加此应用的隐私政策';

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
  String get checkingPolicyWithCloudAi => '正在使用云端 AI 检查政策。';

  @override
  String get preparingCloudAiStream =>
      'Hiding personal details before cloud check…';

  @override
  String get cancellingAnalysis => '正在取消…';

  @override
  String get analysisCancelledNotice => '已取消审查。';

  @override
  String get cloudTimedOutNotice => '云端 AI 响应超时。未发送任何自动重试。';

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

  @override
  String get learnHeaderSubtitle => 'Offline privacy guides & diagrams';

  @override
  String get learnFilterAll => 'All topics';

  @override
  String get learnFilterPolicies => 'Policies';

  @override
  String get learnFilterPermissions => 'Permissions';

  @override
  String get learnFilterSharing => 'Sharing';

  @override
  String get learnFilterEvidence => 'Evidence';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle => 'Practice privacy habits locally';

  @override
  String get learnDeckBody =>
      '100% offline lessons with diagrams. Your installed apps and receipts never enter Learn.';

  @override
  String get learnDeckCheckBtn => 'Apply it · Check an app';

  @override
  String get learnCheckAppBridgeBtn => 'Check an app on this phone';

  @override
  String get learnSectionDiagram => 'How it works';

  @override
  String get learnSectionSteps => 'Key steps';

  @override
  String get learnSectionQuickCheck => 'Quick check';

  @override
  String get learnTooltipListenLesson => 'Read this lesson aloud offline';

  @override
  String get learnTooltipStopLesson => 'Stop reading lesson aloud';

  @override
  String get learnVoiceUnavailableNotice =>
      'Offline voice playback is not available for this language on this phone. You can read the lesson below.';

  @override
  String get learnQuickCheckCorrectBadge => 'Right answer';

  @override
  String get learnQuickCheckTryAgainBadge => 'Try another choice';

  @override
  String learnLessonProgress(int current, int total) {
    return 'Lesson $current of $total';
  }

  @override
  String get learnBackTooltip => 'Back to Learn';

  @override
  String get learnPreviousLesson => 'Previous';

  @override
  String get learnNextLesson => 'Next';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return 'Previous lesson: $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return 'Next lesson: $title';
  }

  @override
  String get learnPolicyFolderTitle => 'Privacy policies';

  @override
  String get learnPolicyTitle =>
      'What a privacy policy is (and what it can\'t prove)';

  @override
  String get learnPolicySubtitle =>
      'What developers promise vs. what stays unknown';

  @override
  String get learnPolicyIntro =>
      'A privacy policy is a developer\'s public statement explaining what data an app says it collects, why it uses it, who may receive it, and what choices families have.';

  @override
  String get learnPolicyStep1 =>
      'Look for four basics: what data is collected, why the app needs it, who else may get it, and how you can ask for deletion.';

  @override
  String get learnPolicyStep2 =>
      'Confusing wording is common. A 2026 study of children\'s learning apps found that very few policies were easy to read, and most apps did not fully match what their policies stated.';

  @override
  String get learnPolicyStep3 =>
      'A privacy policy only shows what a developer says on paper. Reading it cannot prove what the app actually sends over the internet.';

  @override
  String get learnPolicyStep4 =>
      'Comparing a policy with your phone\'s permission settings gives a clearer view — while remembering that Enprive cannot see live internet traffic.';

  @override
  String get learnPolicyQuickQuestion =>
      'What does reading an app\'s privacy policy prove?';

  @override
  String get learnPolicyQuickOption1 =>
      'That the app never sends data to anyone';

  @override
  String get learnPolicyQuickOption2 =>
      'What the developer says — not what the app actually sends';

  @override
  String get learnPolicyQuickOption3 =>
      'That the phone\'s camera and mic are switched off';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'That\'s right. A policy is the developer\'s public statement, not proof of what the app actually sends over the internet.';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      'Not quite. Reading a policy only tells you what the developer says — it cannot prove internet activity or turn off phone permissions.';

  @override
  String get learnDiagramPolicySaysTitle => 'Policy says';

  @override
  String get learnDiagramPolicySaysBody => 'Developer\'s written promise';

  @override
  String get learnDiagramPolicyQuoteSample =>
      '\"We may share data with partners…\"';

  @override
  String get learnDiagramPhoneShowsTitle => 'Phone shows';

  @override
  String get learnDiagramPhoneShowsBody => 'Permissions allowed here';

  @override
  String get learnDiagramUnknownTitle => 'Still unknown';

  @override
  String get learnDiagramUnknownBody =>
      'Live internet traffic Enprive can\'t see';

  @override
  String get learnDiagramPolicyCaption =>
      'A policy is a promise, not proof of behavior';

  @override
  String get learnDiagramPolicySemantic =>
      'Diagram comparing three parts of app privacy. First, Policy says: the developer\'s written promise. Second, Phone shows: the permissions allowed on this phone. Third, inside a dashed boundary, Still unknown: live internet traffic that Enprive cannot see. A privacy policy is a promise, not proof of behavior.';

  @override
  String get learnPermissionsFolderTitle => 'Phone permissions';

  @override
  String get learnPermissionsTitle => 'Android permissions explained';

  @override
  String get learnPermissionsSubtitle =>
      'The four Android choices & where to review them';

  @override
  String get learnPermissionsIntro =>
      'Permissions are gates that control whether an app can reach sensors and data on your phone, such as the camera, microphone, location, photos, contacts, or notifications.';

  @override
  String get learnPermissionsStep1 =>
      'Ask whether the permission fits the feature: a math quiz or reading app rarely needs your location, contacts, or camera.';

  @override
  String get learnPermissionsStep2 =>
      'Android offers up to four choices: Don\'t allow, Ask every time, Allow only while using the app, and All the time (for background location).';

  @override
  String get learnPermissionsStep3 =>
      'Start with the narrowest choice that lets the feature work — such as Ask every time or While using the app.';

  @override
  String get learnPermissionsStep4 =>
      'Open Android Settings and check Privacy Dashboard to see which apps recently accessed Camera, Microphone, or Location.';

  @override
  String get learnPermissionsStep5 =>
      'Turn permissions off anytime in App Settings, or keep Pause app activity if unused on so Android removes old permissions automatically. An allowed permission shows capability, not proof that data was sent.';

  @override
  String get learnPermissionsQuickQuestion =>
      'A math practice app asks for your camera and you aren\'t sure why. What is the best first step?';

  @override
  String get learnPermissionsQuickOption1 =>
      'Tap Don\'t allow and see if the math exercises still work';

  @override
  String get learnPermissionsQuickOption2 =>
      'Choose All the time so the popup doesn\'t come back';

  @override
  String get learnPermissionsQuickOption3 =>
      'Assume the app has already uploaded photos';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      'Right. Tapping Don\'t allow lets you check if the app works without the camera — and you can change permissions anytime in Android Settings.';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'Try a narrower choice first. Tap Don\'t allow to test if the feature still works, and remember an allowed permission shows capability, not proof of an upload.';

  @override
  String get learnDiagramPermLadderTitle => 'From narrowest to broadest access';

  @override
  String get learnDiagramPermDenyTitle => 'Don\'t allow';

  @override
  String get learnDiagramPermDenyDetail =>
      'Blocked — app cannot use this sensor';

  @override
  String get learnDiagramPermAskTitle => 'Ask every time';

  @override
  String get learnDiagramPermAskDetail => 'One-time access when you tap allow';

  @override
  String get learnDiagramPermWhileUsingTitle => 'While using the app';

  @override
  String get learnDiagramPermWhileUsingDetail =>
      'Only while the app is open on screen';

  @override
  String get learnDiagramPermAllTimeTitle => 'All the time';

  @override
  String get learnDiagramPermAllTimeDetail =>
      'Background access even when closed';

  @override
  String get learnDiagramPermFitNote =>
      'Does it fit? Math quiz + Camera = ask why';

  @override
  String get learnDiagramPermSemantic =>
      'Four-step Android permission ladder from narrowest to broadest access. Step 1, Don\'t allow: blocked, the app cannot use this sensor. Step 2, Ask every time: one-time access when you tap allow. Step 3, While using the app: access only while the app is open on screen. Step 4, All the time: background access even when closed, marked with a dashed border for extra caution. Bottom tip: Does it fit? A math quiz asking for the camera is a reason to ask why.';

  @override
  String get learnSharingFolderTitle => 'Ads & third parties';

  @override
  String get learnSharingTitle =>
      'Who else gets data: ads, analytics & third parties';

  @override
  String get learnSharingSubtitle =>
      'App maker vs. helpers, analytics & ad networks';

  @override
  String get learnSharingIntro =>
      'Many free apps connect to other companies behind the scenes. Knowing who receives information helps families tell the difference between running the app and tracking kids across apps.';

  @override
  String get learnSharingStep1 =>
      'First party means the app maker itself — for example, saving homework progress or quiz scores so the app works.';

  @override
  String get learnSharingStep2 =>
      'Helper companies are third parties that handle behind-the-scenes jobs like cloud storage or crash reports so bugs get fixed.';

  @override
  String get learnSharingStep3 =>
      'Analytics tools measure how screens are used, while ad networks and data brokers may use an advertising ID to show targeted ads or profile activity across apps.';

  @override
  String get learnSharingStep4 =>
      'Watch for broad phrases like \'trusted partners\' or \'business purposes,\' and check whether a policy explains how to opt out of personalized ads.';

  @override
  String get learnSharingQuickQuestion =>
      'A policy says the app shares information with \'third-party partners.\' What is the best next question to ask?';

  @override
  String get learnSharingQuickOption1 => 'Assume that means the app has no ads';

  @override
  String get learnSharingQuickOption2 =>
      'Assume every partner does the exact same job';

  @override
  String get learnSharingQuickOption3 =>
      'Check whether those partners are helpers (like hosting) or ad networks that track across apps';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'Spot on. Helper services keep the app running, while ad networks and data brokers may track activity across apps.';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      'Look closer at what each partner does. Not all third parties are the same — some host data or fix crashes, while others run ads or tracking.';

  @override
  String get learnDiagramThirdPartyYou => 'You';

  @override
  String get learnDiagramThirdPartyApp => 'Learning app';

  @override
  String get learnDiagramThirdPartyHosting => 'Helpers & crashes';

  @override
  String get learnDiagramThirdPartyAnalytics => 'Analytics';

  @override
  String get learnDiagramThirdPartyAds => 'Ad networks';

  @override
  String get learnDiagramThirdPartyFirstParty => 'First party';

  @override
  String get learnDiagramThirdPartyThirdParty => 'Third parties';

  @override
  String get learnDiagramThirdPartySemantic =>
      'Flow diagram showing where data from a child\'s learning app can go. You connect to the learning app, which connects with a solid line to the app maker (first party) and with dashed lines to third parties: helper and crash tools, analytics tools, and ad networks marked for extra attention.';

  @override
  String get learnEvidenceFolderTitle => 'Reading Enprive';

  @override
  String get learnEvidenceTitle => 'How to read Enprive\'s evidence';

  @override
  String get learnEvidenceSubtitle =>
      'Evidence layers, categories & honest limits';

  @override
  String get learnEvidenceIntro =>
      'Enprive separates what a privacy policy says, what your phone shows, and what stays unknown — and groups findings by topic, never as a safety grade.';

  @override
  String get learnEvidenceStep1 =>
      'Five topic categories group every finding with the same icon and color as the Review screen. Color marks the topic, never a safety score.';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '$sourceMatched means Enprive found an exact quote word for word in the policy text you checked.';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '$deviceObserved means your phone reported a permission setting on this device — not proof that data was sent.';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '$interpretation is Deni\'s plain-language explanation, while $unverified marks details Enprive could not find. Silence in a policy is never a promise.';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return 'Reviews end with one of three calm outcomes: $reviewRecommended, $noConcern (which is never a safety certification), or $insufficientEvidence.';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return 'On a Review screen, what does \'$deviceObserved\' mean?';
  }

  @override
  String get learnEvidenceQuickOption1 =>
      'The app is certified safe for children';

  @override
  String get learnEvidenceQuickOption2 =>
      'Your phone shows this permission setting on this device — not proof that data was uploaded';

  @override
  String get learnEvidenceQuickOption3 =>
      'The app has definitely uploaded your child\'s data';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'That\'s right. That label reflects Android\'s permission state on this device; it cannot prove uploads or certify safety.';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      'Not quite. That label only shows what your phone reports about a permission setting — it never proves uploads and is never a safety certification.';

  @override
  String get learnDiagramEvidencePolicyDetail =>
      'Exact quote matched in the policy text';

  @override
  String get learnDiagramEvidencePhoneDetail =>
      'Phone permissions on this device';

  @override
  String get learnDiagramEvidenceDeniDetail =>
      'Plain-language explanation by Deni';

  @override
  String get learnDiagramEvidenceUnknownDetail =>
      'Silence in a policy is not a promise';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Four evidence layers used on Enprive\'s Review screen: 1, $sourceMatched, an exact quote matched in the privacy policy; 2, $deviceObserved, phone permissions on this device; 3, $interpretation, Deni\'s plain-language explanation; and 4, separated by a dashed line, $unverified, because silence in a policy is not a promise.';
  }

  @override
  String get learnDiagramCategoriesTitle =>
      'Five topic categories on the Review screen';

  @override
  String get learnDiagramCategoriesNote =>
      'Color and icon mark the topic, never a safety score.';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Five evidence categories shown on Enprive\'s Review screen, each with its own icon and color: $dataCollection, $sharing, $tracking, $retention, and $parentalControls. Color and icon mark the topic, never a safety score.';
  }
}
