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
  String get stateReviewRecommendedSubtitle => '有一项或多项隐私政策内容或手机权限需要进一步查看。';

  @override
  String get stateInsufficientEvidence => '证据不足';

  @override
  String get stateInsufficientEvidenceSubtitle => '我们需要更多隐私政策正文，才能检查此应用的行为。';

  @override
  String get chipOnDevice => '在此设备上';

  @override
  String get chipInCloud => '云端分析';

  @override
  String get chipLocationUnavailable => '来源不可用';

  @override
  String get chipOfflineDeterministic => '已在此手机上离线检查';

  @override
  String get chipUnknown => '来源未知';

  @override
  String get statusSourceMatched => '政策原文匹配';

  @override
  String get statusDeviceObserved => '在此手机上看到';

  @override
  String get statusInterpretation => 'Deni 的说明';

  @override
  String get statusUnverified => '政策中未找到';

  @override
  String get statusStale => '较早的检查';

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
      '为了在云端检查此内容，Enprive 仅在本次请求中发送上方显示的文本（已隐藏个人信息）。绝不会发送您的应用列表和手机权限。';

  @override
  String get permissionLimitationNotice => '您的手机仅显示此权限是否已允许，不能证明该应用实际访问或发送了数据。';

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
  String get checkQuoteDesc => '使用精确原文引用，标出数据共享、语音录制及数据保存时长。';

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
      other: '$count 条匹配引用',
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
  String get readinessRow3Title => '隐藏个人信息';

  @override
  String get readinessRow3Desc => '如果您选择云端协助，发送前会先隐藏姓名、邮箱和电话号码。';

  @override
  String get settingsTitle => '设置';

  @override
  String get privateAnalysisTitle => '此手机上的私密分析';

  @override
  String get onDeviceReadyMsg => '端侧 AI 已激活并准备就绪。';

  @override
  String get localScannerProtectedMsg => '已准备好在此手机上离线检查隐私政策。';

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
  String get geminiNanoReadyMsg => '此手机上的端侧 AI 已就绪。审查记录完全保留在您的设备上。';

  @override
  String get modelDownloadingMsg => '正在后台下载端侧私密模型。';

  @override
  String get modelDownloadableMsg => '可在连接 Wi-Fi 时下载端侧模型。';

  @override
  String get localScannerDefaultMsg => '此手机默认在您的设备上离线检查隐私政策。';

  @override
  String get preparingPrivateAnalysis => '正在准备私密分析…';

  @override
  String get onDeviceAiReadyTitle => '端侧 AI 已就绪';

  @override
  String get localScannerActiveTitle => '离线检查已就绪';

  @override
  String get privateAnalysisSheetSubtitle => '你的已安装应用列表和权限检查绝不会离开手机。';

  @override
  String get btnDone => '完成';

  @override
  String get btnCheckAgain => '重新检查';

  @override
  String get reviewingOnPhone => '正在此手机上审查…';

  @override
  String get readingClausesInitial => '正在此手机上读取隐私政策正文…';

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
  String get thoughtSignaturePrefix => '检查 ID';

  @override
  String get viewStreamedThoughts => 'Enprive 如何检查此内容';

  @override
  String get hideStreamedThoughts => '隐藏 Enprive 的检查过程';

  @override
  String get analysisTraceDefaultTitle => '本次审查的验证过程';

  @override
  String get savedToLocalReceiptsSnack => '已保存到本机收据记录。';

  @override
  String get snapshotSheetTitle => '已审查的政策正文';

  @override
  String get snapshotSourcePrefix => '来源';

  @override
  String get snapshotReviewedPrefix => '审查时间';

  @override
  String get snapshotDigestPrefix => '文档指纹';

  @override
  String get statFindings => '发现条目';

  @override
  String get statVerified => '已验证';

  @override
  String get statOsGranted => '手机已允许';

  @override
  String get statUnverified => '未找到';

  @override
  String get keyFindingsTitle => '核心发现';

  @override
  String get reviewedExcerptTitle => '已审查原文摘要';

  @override
  String get permissionsOnPhoneTitle => '此手机上的应用权限';

  @override
  String get viewReviewedSnapshot => '查看已审查的政策正文';

  @override
  String get btnSavedToReceipts => '已保存至收据';

  @override
  String get observedOnPhoneLabel => '在此手机上看到';

  @override
  String get quoteVerifiedLabel => '政策原文精确引用';

  @override
  String get unverifiedClaimLabel => '政策中未找到';

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
  String get labelWhatRemainsUnknown => '我们仍不知道的内容';

  @override
  String get presetQuestionMeaning => '这对我的孩子意味着什么？';

  @override
  String get presetQuestionOptOut => '可以关闭或选择退出吗？';

  @override
  String get presetQuestionUnknown => '这里还有哪些未明确的信息？';

  @override
  String get readingCitedClause => '正在读取政策引用…';

  @override
  String get deniAnswerTitle => 'Deni 的回答';

  @override
  String get stepsAndReasoning => 'Deni 如何检查此内容';

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
  String get sampleSyntheticBadge => '示例应用';

  @override
  String get permissionInspectionTitle => '已检查手机权限';

  @override
  String get addAppPrivacyPolicyBtn => '添加此应用的隐私政策';

  @override
  String get snapshotDigestLabel => '文档指纹';

  @override
  String get snapshotDigestExplanation =>
      '这是一段唯一代码，用于确认这就是 Enprive 实际检查过的原文。哪怕改动一个字，代码也会随之变化。';

  @override
  String get copyDigestBtn => '复制指纹';

  @override
  String get digestCopiedMsg => '已复制文档指纹';

  @override
  String get permissionGrantedBadge => '在此手机上已允许';

  @override
  String get permissionNotGrantedBadge => '未允许';

  @override
  String get checkingPolicyWithCloudAi => '正在使用云端 AI 检查政策。';

  @override
  String get preparingCloudAiStream => '云端检查前正在隐藏个人信息…';

  @override
  String get cancellingAnalysis => '正在取消…';

  @override
  String get analysisCancelledNotice => '已取消审查。';

  @override
  String get cloudTimedOutNotice => '云端 AI 响应超时。未发送任何自动重试。';

  @override
  String get cloudFallbackBannerTitle => '云端不可用：已在此手机上检查';

  @override
  String get cloudFallbackBannerBody =>
      '云端分析暂时不可用，因此 Enprive 直接在您的手机上检查了这份隐私政策。';

  @override
  String get appPickerFilterAll => '全部应用';

  @override
  String get appPickerFilterDownloaded => '已下载';

  @override
  String get appPickerFilterSystem => '系统';

  @override
  String get appPickerRecentlyChecked => '最近检查';

  @override
  String get appPickerStatusPolicySaved => '已保存政策审查';

  @override
  String get appPickerStatusPermissionsInspected => '已检查权限';

  @override
  String get appPickerStatusNotReviewed => '未审查';

  @override
  String get appPickerSearchHint => '按应用名称或 App ID 搜索…';

  @override
  String get appPickerEmptyInstalledTitle => '没有可用的已安装应用';

  @override
  String get appPickerEmptyInstalledBody => '此手机上未找到可供检查的应用。';

  @override
  String get intakeModeDocument => '文档';

  @override
  String get intakeActionInspectText => '检查政策正文';

  @override
  String get intakeActionFetchUrl => '打开并检查政策';

  @override
  String get intakeActionChooseDocument => '选择 PDF、TXT 或 DOCX';

  @override
  String get intakeActionReplaceDocument => '选择替代文档';

  @override
  String get intakeWorkingLabel => '正在处理…';

  @override
  String get intakeCancelFetch => '取消获取';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure => '将直接加载此公开网页。在此添加链接并不能证明应用归属权。';

  @override
  String get intakePasteLocalNote => '优先在此手机本地检查。未经您的许可，不会上传任何内容。';

  @override
  String get intakeDocumentCardTitle => '导入 PDF、TXT 或 DOCX 政策文件';

  @override
  String get intakeDocumentCardBody => '我们直接在您的手机上读取文本（最大 10 MB）。您的文件绝不会上传。';

  @override
  String get intakeCompareWithAppPrompt => '与已安装应用对比（可选）';

  @override
  String get intakeCompareWithAppHint => '在此手机本地运行。应用列表绝不会离开您的设备。';

  @override
  String get intakeCompareWithAppChange => '更改';

  @override
  String get intakeCompareWithAppRemove => '移除';

  @override
  String get intakeLockedAppContextLabel => '已选应用';

  @override
  String get intakeFindPolicyOnPlayStore => '在 Play Store 查找政策链接';

  @override
  String get intakePlayStoreHelperNote =>
      '打开 Play Store 以便您复制该应用的隐私政策链接。Enprive 绝不会自动复制，也不会默认该链接为官方链接。';

  @override
  String get intakePlayStoreUnavailable =>
      '无法在此设备上打开 Google Play Store。请改为手动粘贴政策网址或正文。';

  @override
  String get intakeRecoverySwitchPaste => '改为粘贴文本';

  @override
  String get intakeRecoverySwitchDocument => '导入文档';

  @override
  String get intakeRecoveryRetryUrl => '重试获取';

  @override
  String get intakeExpiredDocumentShareNotice =>
      '最初分享的文件链接已无法重新打开。请另选一个 PDF、TXT 或 DOCX 文件，或手动粘贴政策正文。';

  @override
  String get intakeAssociationWarningTitle => '应用与政策匹配检查';

  @override
  String get intakeAssociationContinueAnyway => '仍然继续';

  @override
  String get intakeAssociationChangeApp => '更改已选应用';

  @override
  String get intakeAssociationInspectWithoutApp => '不关联应用直接检查';

  @override
  String get intakeModeSelectorSemanticLabel => '政策输入方式';

  @override
  String get tooltipClearSearch => '清除搜索';

  @override
  String get intakeRecoveryEditUrl => '编辑网址';

  @override
  String get voiceSummaryTitle => 'Deni 的通俗摘要';

  @override
  String get voiceSummaryPreparing => '正在准备通俗摘要…';

  @override
  String get voiceSynthesizingExpressive => '正在准备 Deni 的生动语音…';

  @override
  String get voiceBtnListenOffline => '收听';

  @override
  String get voiceBtnStop => '停止';

  @override
  String get voiceBtnExpressiveCloud => '生动语音';

  @override
  String get voiceBtnSummarizeCloud => '用云端 AI 总结';

  @override
  String get voiceBadgeExpressive => '云端生动语音';

  @override
  String get voiceBadgeDeviceOffline => '手机语音 · 离线';

  @override
  String get voiceViewSourceQuote => '原文引用';

  @override
  String get voiceHideSourceQuote => '隐藏引用';

  @override
  String get voiceInspectFinding => '查看发现';

  @override
  String get voiceConsentTitle => '选择 Deni 的语音';

  @override
  String get voiceConsentDisclosure =>
      '为了使用 Deni 的云端生动语音朗读此摘要，Enprive 仅在本次请求中发送上方显示的摘要文本（已隐藏个人信息）。绝不会发送您的应用列表和手机权限。';

  @override
  String get voiceConsentPrimaryAction => '本次使用生动语音';

  @override
  String get voiceConsentSecondaryAction => '在此手机上朗读';

  @override
  String get voiceConsentPayloadLabel => '精确朗读文本';

  @override
  String get voiceSummaryConsentTitle => '用云端 AI 总结发现条目';

  @override
  String get voiceSummaryConsentDisclosure =>
      '为了在云端用通俗语言总结这些政策引用，Enprive 仅在本次请求中发送上方显示的文本（已隐藏个人信息）。绝不会发送您的应用列表和手机权限。';

  @override
  String get voiceFallbackDeviceNotice => '云端生动语音不可用：已改用此手机的离线语音。';

  @override
  String get voiceUnavailableNotice => '此手机暂不支持该语言的语音朗读。您可以直接阅读上方的 Deni 摘要。';

  @override
  String get voiceTooltipReadSummary => '收听 Deni 的通俗摘要';

  @override
  String get voiceTooltipStopReading => '停止朗读';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '项发现',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项发现',
      zero: '无发现条目',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '政策中已验证 $count 条引用',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '在此手机上看到 $count 项',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => '在此手机上已允许';

  @override
  String get permissionNotAllowedOnPhone => '未允许';

  @override
  String get permissionAllowedInSample => '示例中已允许';

  @override
  String get permissionNotAllowedInSample => '示例中未允许';

  @override
  String get permissionMismatchChip => '政策未提及';

  @override
  String get howEnpriveCheckedThis => 'Enprive 如何检查此内容';

  @override
  String get hideHowEnpriveChecked => '隐藏 Enprive 的检查过程';

  @override
  String get consentWhatWouldBeSent => '将发送的内容';

  @override
  String get consentSentScope => '仅预览中的文本会离开此手机，且仅限这一次请求。';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '发送前已先隐藏 $count 条个人信息。',
      zero: '未发现需要隐藏的个人信息。',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone => '您的应用列表和手机权限保留在此手机上。';

  @override
  String receiptDeletedSnack(String title) {
    return '已删除 $title';
  }

  @override
  String get btnUndo => '撤销';

  @override
  String get readinessPromiseMaskedTitle => '隐藏个人信息';

  @override
  String get readinessPromiseMaskedLine => '如果选择云端，姓名、邮箱和号码会先被隐藏。';

  @override
  String findingDetailTitle(int index, int total) {
    return '第 $index 项，共 $total 项';
  }

  @override
  String get findingReviewChip => '复查';

  @override
  String get askDeniAboutThis => '向 Deni 询问此项';

  @override
  String get labelWhatPolicySays => '政策如何表述';

  @override
  String get labelWhatAndroidReports => '手机显示的情况';

  @override
  String get sourceButtonTooltip => '已审查来源';

  @override
  String get linkInstalledAppBtn => '关联已安装应用';

  @override
  String get linkInstalledAppCardTitle => '与此手机上的应用对比';

  @override
  String get linkInstalledAppCardBody =>
      '选择一个已安装应用，在同一次审查中将其手机权限与这份政策对比。您的应用列表留在此手机上。';

  @override
  String get linkAppPickerTitle => '关联已安装应用';

  @override
  String get changeLinkedAppPickerTitle => '更改关联应用';

  @override
  String get linkAppPickerSubtitle => '选择此手机上的一个应用，将其权限与这份政策对比。您的应用列表绝不会离开此手机。';

  @override
  String get linkedAppCurrentlySelectedBadge => '已关联';

  @override
  String get linkedAppSectionLabel => '此手机上已关联的应用';

  @override
  String get btnChangeLinkedApp => '更换应用';

  @override
  String get btnUnlinkApp => '取消关联';

  @override
  String get btnUpdatePrivacyPolicy => '附加更新后的隐私政策';

  @override
  String linkedAppSnack(String appName) {
    return '已关联 $appName。已在此手机上对比权限。';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return '已关联 $appName。请查看下方的应用与政策匹配提示。';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName 已在相同权限下完成关联。';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return '已取消关联 $appName。当前仅显示政策审查。';
  }

  @override
  String get associationStatusPackageTitle => '在此政策中找到了 App ID';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return '此政策提到了 $packageName，说明它可能描述的是 $appName，但仅凭文本无法证明谁拥有这份政策。';
  }

  @override
  String get associationStatusNameTitle => '在此政策中找到了应用名称';

  @override
  String associationStatusNameBody(String appName) {
    return '此政策提到了 $appName，说明它可能描述此应用，但名称一致并不能证明谁拥有这份政策。';
  }

  @override
  String get associationStatusUnverifiedTitle => '由您手动关联以供对比';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return '此政策未提及 $appName 或其 App ID。请再次确认这是正确的政策：在此关联并不能证明归属权。';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return '网址中包含来自 $appName 的字样，但政策正文并未提及此应用。请再次确认这是正确的政策：在此关联并不能证明归属权。';
  }

  @override
  String get associationStatusUnmatchedTitle => '此政策可能属于其他应用';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return '此政策未提及 $appName，而是提到了 $otherApps。请检查是否关联了正确的应用或打开了正确的政策。';
  }

  @override
  String get associationStatusAmbiguousConflictTitle => '此政策提到了多个应用';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return '此政策同时提到了 $appName 和 $otherApps。它可能涵盖多个应用或是公司通用政策，请确认是否适用于此处。';
  }

  @override
  String get associationStatusAmbiguousPeerTitle => '此手机上有多个名称相似的应用';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return '此政策提到了 $appName 但未列出精确的 App ID，而您的手机上还有名称相似的其他应用（$otherApps）。请确认关联无误。';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return '此政策可能指向多个应用。请再次确认它适用于 $appName。';
  }

  @override
  String get associationOwnershipLimitation => '文本和网页链接绝不能证明是谁发布或拥有某份隐私政策。';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '此手机上有 $count 项权限未在此政策中明确提及。不一致是进一步查看的提示，并非违规证据。',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      '此手机上已检查的权限均未与此政策冲突。仅靠权限本身无法说明应用实际发送了什么。';

  @override
  String get permissionComparisonLimitationNote =>
      '手机仅显示本机上的权限设置。此对比是进一步查看的提示，绝不能作为违规或数据已发送的证据。';

  @override
  String get permissionNotRequestedOnPhone => '应用未请求';

  @override
  String get permissionNotRequestedInSample => '示例中未请求';

  @override
  String get permissionsEmptyComparisonTitle => '本次检查未匹配到敏感权限';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return '手机列出 $appName 的 $requestedCount 项权限（已允许 $grantedCount 项），其中不包含本次检查的敏感类别（位置、相机、麦克风、通讯录、照片或广告 ID）。';
  }

  @override
  String get sourceDeviceInspection => '已在此手机上检查';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => '高级详情';

  @override
  String get advancedDetailsSubtitle => '用于核验这份政策正文检查时间与来源的技术详情。';

  @override
  String get sourceSectionTitle => '此政策的来源';

  @override
  String get cloudPayloadLabel => '将发送的精确文本';

  @override
  String get cloudPayloadNoPiiLabel => '未发现个人信息';

  @override
  String cloudPayloadHiddenCount(int count) {
    return '已隐藏（$count）';
  }

  @override
  String get summarySourceOnDevice => '已在此手机上总结';

  @override
  String get summarySourceInCloud => '已在云端总结';

  @override
  String get summarySourceOffline => '已在此手机上离线总结';

  @override
  String get summarySourceUnknown => '摘要来源未知';

  @override
  String get notFromPolicySuffix => '来自您的手机设置，而非隐私政策';

  @override
  String get sampleNotFromPolicySuffix => '仅为示例，并非来自隐私政策';

  @override
  String get learnHeaderSubtitle => '离线隐私指南与图解';

  @override
  String get learnFilterAll => '全部主题';

  @override
  String get learnFilterPolicies => '隐私政策';

  @override
  String get learnFilterPermissions => '手机权限';

  @override
  String get learnFilterSharing => '数据共享';

  @override
  String get learnFilterEvidence => '证据解读';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个步骤',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle => '在本地养成隐私好习惯';

  @override
  String get learnDeckBody => '100% 离线图文课程。您已安装的应用和收据绝不会进入“学习”页面。';

  @override
  String get learnDeckCheckBtn => '学以致用 · 检查应用';

  @override
  String get learnCheckAppBridgeBtn => '检查此手机上的应用';

  @override
  String get learnSectionDiagram => '原理解析';

  @override
  String get learnSectionSteps => '关键步骤';

  @override
  String get learnSectionQuickCheck => '快速自测';

  @override
  String get learnTooltipListenLesson => '离线朗读本课内容';

  @override
  String get learnTooltipStopLesson => '停止朗读课程';

  @override
  String get learnVoiceUnavailableNotice => '此手机暂不支持该语言的离线语音朗读。您可以直接阅读下方课程内容。';

  @override
  String get learnQuickCheckCorrectBadge => '回答正确';

  @override
  String get learnQuickCheckTryAgainBadge => '换一个选项试试';

  @override
  String learnLessonProgress(int current, int total) {
    return '第 $current 课，共 $total 课';
  }

  @override
  String get learnBackTooltip => '返回学习';

  @override
  String get learnPreviousLesson => '上一课';

  @override
  String get learnNextLesson => '下一课';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return '上一课：$title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return '下一课：$title';
  }

  @override
  String get learnPolicyFolderTitle => '隐私政策';

  @override
  String get learnPolicyTitle => '什么是隐私政策（以及它不能证明什么）';

  @override
  String get learnPolicySubtitle => '开发者的承诺与仍然未知的部分';

  @override
  String get learnPolicyIntro =>
      '隐私政策是开发者的公开说明，介绍应用声称收集哪些数据、为何使用、可能共享给谁，以及家长和家庭有哪些选择。';

  @override
  String get learnPolicyStep1 => '重点看四项基础信息：收集什么数据、应用为何需要、还有谁会收到，以及如何申请删除。';

  @override
  String get learnPolicyStep2 =>
      '晦涩难懂的表述很常见。2026 年一项针对儿童学习应用的研究发现，真正易读的政策寥寥无几，且大多数应用与政策所述并不完全一致。';

  @override
  String get learnPolicyStep3 => '隐私政策只体现开发者在纸面上的说法，阅读政策无法证明应用实际通过网络发送了什么。';

  @override
  String get learnPolicyStep4 => '把政策与手机权限设置对照查看会更清楚，但也要记住：Enprive 看不到实时的网络流量。';

  @override
  String get learnPolicyQuickQuestion => '阅读一款应用的隐私政策能证明什么？';

  @override
  String get learnPolicyQuickOption1 => '该应用绝不会向任何人发送数据';

  @override
  String get learnPolicyQuickOption2 => '开发者的书面说法，而非应用实际发送的内容';

  @override
  String get learnPolicyQuickOption3 => '手机的相机和麦克风已经关闭';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      '答对了。隐私政策只是开发者的公开声明，不能证明应用实际在网络上传输了什么。';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      '不太对。阅读政策只能了解开发者的说法，既不能证明网络行为，也不能关闭手机权限。';

  @override
  String get learnDiagramPolicySaysTitle => '政策所述';

  @override
  String get learnDiagramPolicySaysBody => '开发者的书面承诺';

  @override
  String get learnDiagramPolicyQuoteSample => '“我们可能会与合作伙伴共享数据…”';

  @override
  String get learnDiagramPhoneShowsTitle => '手机显示';

  @override
  String get learnDiagramPhoneShowsBody => '本机已允许的权限';

  @override
  String get learnDiagramUnknownTitle => '仍然未知';

  @override
  String get learnDiagramUnknownBody => 'Enprive 看不到的实时网络流量';

  @override
  String get learnDiagramPolicyCaption => '政策只是承诺，不是实际行为的证明';

  @override
  String get learnDiagramPolicySemantic =>
      '对比应用隐私三个部分的图解。第一，政策所述：开发者的书面承诺。第二，手机显示：此手机上已允许的权限。第三，虚线框内为仍然未知：Enprive 看不到的实时网络流量。隐私政策只是承诺，不是实际行为的证明。';

  @override
  String get learnPermissionsFolderTitle => '手机权限';

  @override
  String get learnPermissionsTitle => '读懂 Android 权限';

  @override
  String get learnPermissionsSubtitle => 'Android 的四种选项及查看位置';

  @override
  String get learnPermissionsIntro =>
      '权限就像一道道门，控制应用能否访问手机上的传感器和数据，例如相机、麦克风、位置、照片、通讯录或通知。';

  @override
  String get learnPermissionsStep1 => '先问问权限是否符合功能：数学练习或阅读应用很少需要位置、通讯录或相机。';

  @override
  String get learnPermissionsStep2 =>
      'Android 最多提供四种选项：不允许、每次询问、仅在使用该应用时允许，以及始终允许（用于后台定位）。';

  @override
  String get learnPermissionsStep3 => '从能让功能正常使用的最小范围开始，例如“每次询问”或“仅在使用时允许”。';

  @override
  String get learnPermissionsStep4 =>
      '打开 Android 设置中的“隐私信息中心”，即可查看近期哪些应用访问过相机、麦克风或位置。';

  @override
  String get learnPermissionsStep5 =>
      '您可以随时在应用设置中关闭权限，或开启“暂停未使用的应用活动”，让 Android 自动收回旧权限。允许某项权限代表应用具备能力，并非数据已发送的证明。';

  @override
  String get learnPermissionsQuickQuestion =>
      '一款数学练习应用请求相机权限，但你不知道原因。最好的第一步是什么？';

  @override
  String get learnPermissionsQuickOption1 => '点击“不允许”，看看数学练习是否依然能正常使用';

  @override
  String get learnPermissionsQuickOption2 => '选择“始终允许”，免得弹窗再出现';

  @override
  String get learnPermissionsQuickOption3 => '断定应用已经上传了照片';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      '正确。点击“不允许”可以测试应用在没有相机的情况下能否使用，而且随时可以在 Android 设置里更改。';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      '先尝试更窄的选项。点击“不允许”测试功能是否正常，同时记住：允许权限只代表具备能力，不能证明已上传数据。';

  @override
  String get learnDiagramPermLadderTitle => '从最窄到最宽的访问范围';

  @override
  String get learnDiagramPermDenyTitle => '不允许';

  @override
  String get learnDiagramPermDenyDetail => '已阻止：应用无法使用该传感器';

  @override
  String get learnDiagramPermAskTitle => '每次询问';

  @override
  String get learnDiagramPermAskDetail => '仅在您点击允许时获得一次访问';

  @override
  String get learnDiagramPermWhileUsingTitle => '使用应用期间';

  @override
  String get learnDiagramPermWhileUsingDetail => '仅在应用打开并显示于屏幕时可用';

  @override
  String get learnDiagramPermAllTimeTitle => '始终允许';

  @override
  String get learnDiagramPermAllTimeDetail => '即使应用已关闭也可在后台访问';

  @override
  String get learnDiagramPermFitNote => '合理吗？数学练习 + 相机 = 先问为什么';

  @override
  String get learnDiagramPermSemantic =>
      '从最窄到最宽的四级 Android 权限阶梯图。第 1 级，不允许：已阻止，应用无法使用该传感器。第 2 级，每次询问：仅在您点击允许时获得一次访问。第 3 级，使用应用期间：仅在应用打开并显示于屏幕时可用。第 4 级，始终允许：即使关闭也可后台访问，以虚线框提醒注意。底部提示：数学练习请求相机时应问清原因。';

  @override
  String get learnSharingFolderTitle => '广告与第三方';

  @override
  String get learnSharingTitle => '还有谁会拿到数据：广告、统计与第三方';

  @override
  String get learnSharingSubtitle => '应用开发商与辅助服务、统计工具和广告网络的区别';

  @override
  String get learnSharingIntro =>
      '许多免费应用会在后台连接其他公司。了解谁在接收信息，能帮助家长区分维持应用运行的服务与跨应用追踪儿童的行为。';

  @override
  String get learnSharingStep1 => '第一方指应用开发商本身：例如保存作业进度或测验分数，让应用正常运作。';

  @override
  String get learnSharingStep2 => '辅助公司是处理幕后工作的第三方，例如云存储或崩溃报告，用于修复软件故障。';

  @override
  String get learnSharingStep3 =>
      '统计工具衡量页面使用情况，而广告网络和数据经纪商可能使用广告 ID 投放定向广告或跨应用记录行为。';

  @override
  String get learnSharingStep4 => '留意“可信赖合作伙伴”“业务目的”等宽泛措辞，并检查政策是否说明如何关闭个性化广告。';

  @override
  String get learnSharingQuickQuestion => '政策写着应用会与“第三方合作伙伴”共享信息。接下来最该问什么？';

  @override
  String get learnSharingQuickOption1 => '认为这意味着应用没有广告';

  @override
  String get learnSharingQuickOption2 => '认为每个合作伙伴做的事情完全一样';

  @override
  String get learnSharingQuickOption3 => '查明这些伙伴是托管等辅助服务，还是会跨应用追踪的广告网络';

  @override
  String get learnSharingQuickCorrectFeedback =>
      '说得对。辅助服务帮助应用运行，而广告网络和数据经纪商可能会跨应用追踪活动。';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      '仔细看每个合作伙伴的作用。并非所有第三方都相同：有的负责托管或修复崩溃，有的则做广告或追踪。';

  @override
  String get learnDiagramThirdPartyYou => '你';

  @override
  String get learnDiagramThirdPartyApp => '学习应用';

  @override
  String get learnDiagramThirdPartyHosting => '辅助与崩溃修复';

  @override
  String get learnDiagramThirdPartyAnalytics => '统计分析';

  @override
  String get learnDiagramThirdPartyAds => '广告网络';

  @override
  String get learnDiagramThirdPartyFirstParty => '第一方';

  @override
  String get learnDiagramThirdPartyThirdParty => '第三方';

  @override
  String get learnDiagramThirdPartySemantic =>
      '展示儿童学习应用数据流向的流程图。你连接到学习应用，应用通过实线连接到应用开发商（第一方），并通过虚线连接到第三方：辅助与崩溃工具、统计分析工具，以及重点标注的广告网络。';

  @override
  String get learnEvidenceFolderTitle => '读懂 Enprive';

  @override
  String get learnEvidenceTitle => '如何读懂 Enprive 的证据';

  @override
  String get learnEvidenceSubtitle => '证据层级、主题分类与诚实边界';

  @override
  String get learnEvidenceIntro =>
      'Enprive 将政策表述、手机显示和未知部分分开呈现，并按主题归类发现条目，从不打“安全分”。';

  @override
  String get learnEvidenceStep1 => '五个主题分类使用与审查页相同的图标和颜色。颜色只区分主题，绝不是安全评分。';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '“$sourceMatched”表示 Enprive 在您检查的政策正文中找到了逐字一致的原文引用。';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '“$deviceObserved”表示手机报告了本机的一项权限设置，并非数据已发送的证据。';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '“$interpretation”是 Deni 的通俗说明，而“$unverified”标出 Enprive 未找到的细节。政策里没写，绝不等于承诺不做。';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return '审查会给出三种清晰结论之一：$reviewRecommended、$noConcern（绝不是安全认证）或 $insufficientEvidence。';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return '在审查页面上，“$deviceObserved”是什么意思？';
  }

  @override
  String get learnEvidenceQuickOption1 => '该应用已通过儿童安全认证';

  @override
  String get learnEvidenceQuickOption2 => '您的手机在本机显示了这项权限设置，并非数据已上传的证据';

  @override
  String get learnEvidenceQuickOption3 => '该应用肯定已经上传了孩子的数据';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      '没错。这个标签只反映本机 Android 的权限状态，既不能证明已上传，也不是安全认证。';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      '不太对。这个标签只反映手机报告的权限状态，从不证明数据上传，也不是安全认证。';

  @override
  String get learnDiagramEvidencePolicyDetail => '政策正文中逐字匹配的引用';

  @override
  String get learnDiagramEvidencePhoneDetail => '此设备上的手机权限';

  @override
  String get learnDiagramEvidenceDeniDetail => 'Deni 的通俗说明';

  @override
  String get learnDiagramEvidenceUnknownDetail => '政策未提及不等于承诺不做';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Enprive 审查页使用的四层证据：1，$sourceMatched，政策中逐字匹配的引用；2，$deviceObserved，此设备上的手机权限；3，$interpretation，Deni 的通俗说明；4，虚线分隔的 $unverified，因为政策未提及不等于承诺不做。';
  }

  @override
  String get learnDiagramCategoriesTitle => '审查页上的五个主题分类';

  @override
  String get learnDiagramCategoriesNote => '颜色和图标只标示主题，绝非安全评分。';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Enprive 审查页展示的五个证据分类，各有专属图标和颜色：$dataCollection、$sharing、$tracking、$retention 和 $parentalControls。颜色和图标只标示主题，绝非安全评分。';
  }

  @override
  String get learnDataCollectionFolderTitle => '应用收集的数据';

  @override
  String get learnDataCollectionTitle => '应用会收集哪些数据';

  @override
  String get learnDataCollectionSubtitle => '你主动输入的信息与后台静默收集的区别';

  @override
  String get learnDataCollectionIntro1 =>
      '应用通过两种方式收集信息。一种是你主动输入的内容，如姓名、邮箱、照片、语音或作业答案；另一种在后台自动收集，如 IP 地址（手机联网所用的地址）、设备标识符、广告 ID（广告用来识别手机的代码）、崩溃日志和打开应用的时间。';

  @override
  String get learnDataCollectionStep1 =>
      '你主动输入的：姓名、学校、邮箱、照片、语音片段和作业答案，都是你主动选择提供的信息。';

  @override
  String get learnDataCollectionStep2 =>
      '后台静默运行的：不用你点击按钮，应用也可能收集广告 ID、设备标识符、IP 地址、崩溃报告和使用时长。静默收集不一定就是坏事，这些信号有助于应用稳定运行。';

  @override
  String get learnDataCollectionStep3 =>
      '敏感儿童数据：位置、麦克风录音、相机照片以及声纹等生物识别信息（与身体或声音有关的数据）对儿童的隐私风险更高。';

  @override
  String get learnDataCollectionStep4 =>
      'Play Store 提示：Google Play 的“数据安全”栏由开发者自行填写。它只是参考线索而非证明，且不包含仅在本机处理或短暂存在内存中的数据。';

  @override
  String get learnDataCollectionQuizQuestion => '以下哪一项属于在后台静默收集的数据？';

  @override
  String get learnDataCollectionQuizChoiceA => '你为个人资料主动上传的照片';

  @override
  String get learnDataCollectionQuizChoiceB => '你的广告 ID 和设备标识符';

  @override
  String get learnDataCollectionQuizChoiceC => '你在应用里输入的作业答案';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      '答对了：广告 ID 和设备标识符无需你手动输入，就会自动收集。';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      '不太对：那是你主动输入的数据。后台静默收集的数据包括广告 ID、设备标识符、IP 地址和使用时长。';

  @override
  String get learnDataCollectionDiagramYouTypeTitle => '你输入或提供的内容';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => '姓名、邮箱、学校';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => '照片与视频';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => '语音录音';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => '作业答案';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle => '后台静默运行的内容';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => '广告 ID';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 => '设备标识符';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'IP 地址';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 => '崩溃日志与使用时长';

  @override
  String get learnDataCollectionDiagramQuietNote => '静默并不等于有害：这些信号有助于应用顺畅运行。';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      '展示两类数据收集的对比图。上方卡片“你输入或提供的内容”列出四项：姓名邮箱学校、照片与视频、语音录音、作业答案。下方卡片“后台静默运行的内容”列出四项：广告 ID、设备标识符、IP 地址、崩溃日志与使用时长。附注写着“静默并不等于有害：这些信号有助于应用顺畅运行。”下方 Deni 呈思考姿态。';

  @override
  String get learnDataCollectionCheckBridge => '检查此手机上的应用，看看它收集哪些数据。';

  @override
  String get learnDataCollectionHonestyNote =>
      '本课介绍常见的数据类型，不能证明某款特定应用实际收集或发送了什么。只有准确的政策原文和手机权限设置才能体现。';

  @override
  String get learnRetentionFolderTitle => '数据保留与删除';

  @override
  String get learnRetentionTitle => '数据保留与删除';

  @override
  String get learnRetentionSubtitle => '卸载应用不会清除已经存在公司服务器上的数据';

  @override
  String get learnRetentionIntro1 =>
      '当你从手机上卸载一款应用时，只会删掉本机文件，已经上传到公司服务器的数据仍会留在那里。隐私政策应当说明数据保存多久、如何申请删除以及备份如何处理，但许多政策只写“在合理必要的时间内”等模糊表述。';

  @override
  String get learnRetentionStep1 => '收集数据：使用应用期间，您的信息会被发送并保存到公司的服务器上。';

  @override
  String get learnRetentionStep2 => '存于服务器：即使您不再使用该应用，数据仍可能留在公司系统中。';

  @override
  String get learnRetentionStep3 => '卸载不会删掉服务器数据：从手机移除应用只删除本地文件，不会删除公司服务器上的副本。';

  @override
  String get learnRetentionStep4 => '申请删除：您可以要求公司删除账号与数据；政策应当说明处理需要多久。';

  @override
  String get learnRetentionStep5 => '保留时长不明：只写“按需要保留”或“用于业务目的”的政策，无法明确实际删除时间。';

  @override
  String get learnRetentionQuizQuestion => '当你从手机上卸载一款应用后，公司服务器上的数据会怎样？';

  @override
  String get learnRetentionQuizChoiceA => '会自动删除';

  @override
  String get learnRetentionQuizChoiceB => '可能仍留在服务器上：卸载应用不会删除它们';

  @override
  String get learnRetentionQuizChoiceC => '会立刻匿名化';

  @override
  String get learnRetentionQuizFeedbackRight =>
      '答对了：卸载只移除手机上的应用。在您申请删除前，公司服务器上的数据可能一直保留。';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      '不太对：卸载应用不会删除已上传到公司服务器的数据，需要主动申请删除账号。';

  @override
  String get learnRetentionDiagramCollected => '使用期间收集数据';

  @override
  String get learnRetentionDiagramStored => '保存在公司服务器上';

  @override
  String get learnRetentionDiagramUninstall => '卸载应用：手机文件消失，服务器数据仍在';

  @override
  String get learnRetentionDiagramDeleteRequest => '您提交账号删除申请';

  @override
  String get learnRetentionDiagramUnknownTail => '保留期不明：政策仅写“按需要保留”';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      '展示数据生命周期的五步时间轴。第 1 步：使用期间收集数据（数据库图标）。第 2 步：保存在公司服务器上（服务器图标）。第 3 步：卸载应用，手机文件消失但服务器数据仍在（手机图标）。第 4 步：提交账号删除申请（垃圾桶图标）。第 5 步：保留期不明，政策仅写“按需要保留”（虚线箭头与问号图标）。下方 Deni 手持收据站立。';

  @override
  String get learnRetentionCheckBridge => '检查此手机上的应用，看看其政策对数据保留怎么说。';

  @override
  String get learnRetentionHonestyNote =>
      '本课介绍常见的数据保留模式，不能证明某家特定公司实际如何处理您的数据。只有准确的政策原文和删除申请结果才能体现。';

  @override
  String get learnUnclearPoliciesFolderTitle => '模糊的隐私政策';

  @override
  String get learnUnclearPoliciesTitle => '识别模糊政策与诱导按钮';

  @override
  String get learnUnclearPoliciesSubtitle => '如何看出含糊措辞与施压式的同意界面';

  @override
  String get learnUnclearPoliciesIntro1 =>
      '有些隐私政策使用含糊词句，让人难以判断数据究竟去了哪里。同意弹窗也可能使用设计套路，例如把显眼巨大的“全部接受”按钮放在极小的“管理设置”链接旁，促使您不看就点同意。';

  @override
  String get learnUnclearPoliciesStep1 =>
      '政策迷雾信号：留意“可能与可信伙伴共享”“用于业务目的”“按需保留”等宽泛词句，它们回避了具体细节。';

  @override
  String get learnUnclearPoliciesStep2 =>
      '沉默不是承诺：如果政策从未提到麦克风、广告或位置，并不能保证应用不会使用它们。';

  @override
  String get learnUnclearPoliciesStep3 =>
      '缺少基本信息：清晰的政策应有明确的生效日期、联系邮箱和完整统一的文档，而不是藏起来的儿童补充条款。';

  @override
  String get learnUnclearPoliciesStep4 =>
      '施压式同意（暗黑模式）：巨大的“全部接受”按钮、默认勾选的营销选项、反复弹窗催促和难以找到的取消入口，都是为了影响您的选择。';

  @override
  String get learnUnclearPoliciesStep5 =>
      '平衡的选择：公平的界面会并排提供同等显眼的“允许”和“不允许”按钮，且可选项默认关闭。';

  @override
  String get learnUnclearPoliciesQuizQuestion => '隐私政策中的哪句话属于缺少细节的“模糊”信号？';

  @override
  String get learnUnclearPoliciesQuizChoiceA => '我们不会向第三方出售您的个人信息';

  @override
  String get learnUnclearPoliciesQuizChoiceB => '我们可能出于业务目的与可信合作伙伴共享数据';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      '您可发邮件至 privacy@example.com 申请删除';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      '答对了：“可能出于业务目的与可信合作伙伴共享”非常含糊，没有说明伙伴是谁，也没有说明共享什么数据。';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      '不太对：那句话具体且可执行。模糊表述会用“可能共享”“按需”等宽泛词句而不给细节。';

  @override
  String get learnUnclearPoliciesDiagramClearTitle => '清晰的政策表述';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      '我们收集您的姓名和邮箱以创建账号，不会与广告商共享。';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle => '模糊的政策表述';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      '我们可能根据需要，出于业务目的与可信合作伙伴共享您的信息。';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle => '如何识破迷雾';

  @override
  String get learnUnclearPoliciesDiagramTip1 => '留意“可能”“或许”或“按需”：这些词留了很大余地。';

  @override
  String get learnUnclearPoliciesDiagramTip2 => '查看政策是否点名列出接收数据的具体公司。';

  @override
  String get learnUnclearPoliciesDiagramTip3 => '对广告或麦克风只字不提，并不代表应用不会使用。';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote => '政策未提及不等于承诺不做。';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      '清晰政策句与模糊政策句的并排对比图。左侧“清晰”卡片显示：“我们收集您的姓名和邮箱以创建账号，不会与广告商共享。”右侧“模糊”卡片显示：“我们可能根据需要，出于业务目的与可信合作伙伴共享您的信息。”下方“如何识破迷雾”卡片列出三条提示，模糊卡片附注“政策未提及不等于承诺不做。”Deni 从卡片上方探头张望。';

  @override
  String get learnUnclearPoliciesCheckBridge => '检查此手机上的应用，查看它的同意界面与政策清晰度。';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      '本课介绍常见的模糊写法，不能证明某款特定应用使用了暗黑模式或隐瞒数据处理方式。只有阅读准确政策并查看真实同意界面才能判断。';

  @override
  String get learnSafeSharingFolderTitle => '安全分享习惯';

  @override
  String get learnSafeSharingTitle => '儿童安全上网分享习惯';

  @override
  String get learnSafeSharingSubtitle => '停一停、想一想、再分享：分龄线上分享步骤';

  @override
  String get learnSafeSharingIntro1 =>
      '在发布照片、视频、姓名或位置前，先停下来用好三步：停一停、想一想、再分享。本课适合与信任的大人一起阅读。低龄儿童（5-7 岁）点击前先询问；8-11 岁使用昵称和强密码；青少年（12-17 岁）管理好数字足迹（发布内容留下的痕迹）并开启双重验证（登录时输入验证码等二次确认）。';

  @override
  String get learnSafeSharingStep1 => '停一停：发照片、视频、姓名、学校或位置前先暂停片刻。不确定时先问信任的大人。';

  @override
  String get learnSafeSharingStep2 =>
      '想一想：这会暴露我的学校、家庭住址或当前位置吗？发朋友照片或标记他们前，征得同意了吗？';

  @override
  String get learnSafeSharingStep3 => '再分享：只与信任的人分享。妥善保护真实姓名、生日、住址和电话号码等个人信息。';

  @override
  String get learnSafeSharingStep4 =>
      '学校食堂测试：如果全校师生（或全班同学）都看到这张照片或消息，我会觉得安心吗？即便是阅后即焚的内容也可能被截屏并永久留在网上。';

  @override
  String get learnSafeSharingStep5 =>
      '5-7 岁：输入名字或点击弹窗前先问信任的大人。8-11 岁：使用昵称（不用真实姓名、生日和学校）和强密码，绝不透露短信或 OTP 验证码（短信发来的一次性验证码，绝不分享）。12-17 岁：检查隐私设置、开启双重验证，并了解如何举报问题。';

  @override
  String get learnSafeSharingQuizQuestion => '线上分享中的“学校食堂测试”是指什么？';

  @override
  String get learnSafeSharingQuizChoiceA => '只分享你在食堂里吃的东西';

  @override
  String get learnSafeSharingQuizChoiceB => '问自己：如果全校的人都看到这张照片或消息，我会觉得可以吗？';

  @override
  String get learnSafeSharingQuizChoiceC => '只在午休时间分享内容';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      '答对了：学校食堂测试就是问问自己，如果大家都看到你发的内容，你是否依然安心。';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      '不太对：学校食堂测试是一次心理检查：如果有人把你的帖子展示给整个食堂看，你能接受吗？';

  @override
  String get learnSafeSharingDiagramStop => '停一停：发布前先暂停';

  @override
  String get learnSafeSharingDiagramThink => '想一想：会暴露我的位置或同伴吗？';

  @override
  String get learnSafeSharingDiagramConnect => '再分享：只发给信任的人，拿不准就问大人';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      '学校食堂测试：全校看到也没关系吗？阅后即焚的内容也可能被截屏并永久留在网上。';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      '介绍安全分享习惯的四部分图解。第 1 步：停一停：发布前先暂停（手势图标）。第 2 步：想一想：会暴露我的位置或同伴吗？（大脑图标）。第 3 步：再分享：只发给信任的人，拿不准就问大人（人群图标）。第 4 步：学校食堂测试提示框提问“全校看到也没关系吗？阅后即焚的内容也可能被截屏并永久留在网上。”Deni 举手站在提示框旁。';

  @override
  String get learnSafeSharingCheckBridge => '和家长一起检查一款应用，看看它如何处理分享功能。';

  @override
  String get learnSafeSharingHonestyNote =>
      '本课分享通用的安全分享习惯，不能保证任何应用都会保护你分享的内容。请务必阅读应用政策并使用手机的隐私设置。';

  @override
  String get translationDraftNotice => '部分翻译为 AI 生成的草稿，可能存在误差。母语审校人员正在陆续校对。';

  @override
  String get homeQuickSettingsTitle => '快捷设置助手';

  @override
  String get homeQuickSettingsSubtitle => '随时就你正在使用的应用询问 Deni';

  @override
  String get appearanceSectionTitle => '外观';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get quickSettingsSectionTitle => '将 Enprive 连接到快捷设置';

  @override
  String get quickSettingsSectionSubtitle =>
      '将 Enprive Check 添加到 Android 快捷设置面板，这样你无需中断手头的事，就能向 Deni 询问应用的情况。';

  @override
  String get quickSettingsTileTitle => 'Enprive Check 图块';

  @override
  String get quickSettingsTileSubtitle =>
      '将 Enprive Check 添加到快捷设置，无需先找到 Enprive，就能向 Deni 询问你正在使用的应用。';

  @override
  String get quickSettingsStatusAdded => '已添加';

  @override
  String get quickSettingsStatusManual => '手动';

  @override
  String get quickSettingsStatusNotAdded => '未添加';

  @override
  String get usageAccessStatusGranted => '已授权';

  @override
  String get usageAccessStatusNotGranted => '未授权';

  @override
  String get usageAccessTitle => '允许使用情况访问权限（可选）';

  @override
  String get usageAccessExplanation =>
      '只有当你点按 Enprive Check 来识别刚才使用的应用时，Enprive 才会使用“使用情况访问权限”。这能帮助 Deni 找到正确的应用及其隐私信息。Enprive 不会持续监视你的屏幕。';

  @override
  String get usageAccessManageLink => '如何管理或撤销';

  @override
  String get usageAccessManageTitle => '管理或撤销使用情况访问权限';

  @override
  String get usageAccessManageBody =>
      '“使用情况访问权限”是 Android 设置中的一个特殊开关（不是自动弹出的窗口）。你可以随时在 Android 设置 → 应用 → 特殊应用权限 → 使用情况访问权限 → enprive 中关闭它。关闭后，手动选择应用，Deni 仍然可用。';

  @override
  String get openDeniCompanionTitle => '打开 Deni 助手';

  @override
  String get openDeniCompanionSubtitle => '不使用快捷设置，也能查看最近使用或所选应用的权限。';

  @override
  String get btnGotIt => '知道了';

  @override
  String get quickSettingsReadyDialogTitle => 'Enprive Check 已可在快捷设置中使用';

  @override
  String get quickSettingsReadyDialogBody =>
      '从屏幕顶部向下滑动两次，想让 Deni 解释某个应用的权限时，点按“Enprive Check”。';

  @override
  String get quickSettingsManualDialogTitle => '手动添加 Enprive Check';

  @override
  String get quickSettingsManualDialogBody =>
      '1. 从 Android 屏幕顶部向下滑动两次，打开快捷设置。\n2. 点按“编辑”（铅笔）按钮。\n3. 找到“Enprive Check”，把它拖到正在使用的图块中。';

  @override
  String get quickSettingsSnackAdded => '已将 Enprive Check 添加到快捷设置。';

  @override
  String get quickSettingsSnackAlreadyAdded => 'Enprive Check 已在你的快捷设置中。';

  @override
  String get quickSettingsSnackDeclined =>
      '请求已关闭。除非你在快捷设置中选择“编辑”，否则 Enprive 不会再次询问。';

  @override
  String get quickSettingsSnackManual =>
      '向下滑动快捷设置，点按“编辑”，然后把 Enprive Check 拖到你的图块中。';

  @override
  String get quickSettingsSnackUnavailable =>
      '此处无法显示系统提示。你可以在快捷设置的“编辑”中手动拖入 Enprive Check。';

  @override
  String get usageAccessOpenFailedSnack => '无法在此设备上打开“使用情况访问权限”设置。';

  @override
  String get companionTitle => 'Deni：Enprive 助手';

  @override
  String get companionSubtitle => '向 Deni 询问应用的权限，以及它的隐私政策是怎么说的。';

  @override
  String get companionTooltipReturnToPrev => '返回上一个应用';

  @override
  String get companionTooltipBack => '返回';

  @override
  String get companionLockedBadge => '锁屏保护中';

  @override
  String get companionLockedTitle => '请解锁手机以继续';

  @override
  String get companionLockedBody => '设备锁定期间，Enprive 会隐藏应用名称、应用声明的权限和审查依据。';

  @override
  String get companionCheckUnlockBtn => '检查解锁状态';

  @override
  String get companionCheckingAppHeadline => '正在确认你刚才使用的应用…';

  @override
  String get companionCheckingAppSubtitle => '在此手机上只确认一次，不会监视你的屏幕。';

  @override
  String get companionGeneralGuideHeadline => 'Android 权限通用指南';

  @override
  String get companionGeneralGuideSubtitle =>
      '未选择应用。Enprive 只使用本地指引来解释 Android 权限。';

  @override
  String companionLookingAtHeadline(String appName) {
    return '你正在查看 $appName。';
  }

  @override
  String get companionLookingAtSubtitle =>
      '下面列出的权限来自你手机上的这个应用。屏幕上弹出的窗口仍由 Android 控制。';

  @override
  String get companionThisAppFallback => '这个应用';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return '我们在 $seconds 秒前看到了 $appName。对吗？';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return '我们认为你正在使用 $appName。对吗？';
  }

  @override
  String companionAppIdLine(String packageName) {
    return 'App ID：$packageName';
  }

  @override
  String companionConfirmAppBtn(String appName) {
    return '确认 · $appName';
  }

  @override
  String get companionChooseAnotherAppBtn => '选择其他应用';

  @override
  String get companionWithoutAppContextBtn => '不指定应用';

  @override
  String get companionMultipleAppsTitle => '刚才有多个应用处于活动状态';

  @override
  String get companionMultipleAppsPrompt => '请确认你想查看哪个应用：';

  @override
  String companionSecondsAgo(int seconds) {
    return '$seconds 秒前';
  }

  @override
  String get companionSelectAppTitle => '选择你想检查的应用';

  @override
  String get companionSelectAppBody => '从已安装的应用中手动选择，或者不指定应用继续。';

  @override
  String get companionChooseAppManuallyBtn => '手动选择应用';

  @override
  String get companionOpenUsageAccessBtn => '打开“使用情况访问权限”设置';

  @override
  String get companionContinueWithoutAppBtn => '不指定应用继续';

  @override
  String get companionAddTileBtn => '添加 Enprive Check 图块';

  @override
  String get companionContinuingWithoutApp => '正在不指定应用的情况下继续';

  @override
  String get companionSwitchAppBtn => '切换应用';

  @override
  String get companionPermissionsReadLocally => '下面显示的权限是直接从你的手机读取的。';

  @override
  String get companionPickPermissionType => '选择一种权限来了解';

  @override
  String get companionPickAppBtn => '选择应用';

  @override
  String get companionCouldNotReadPermsTitle => '无法读取应用权限';

  @override
  String get companionCouldNotReadPermsBody => 'Android 阻止了对此应用权限的查看。';

  @override
  String get companionUnsurePermBtn => '我不确定是哪个权限';

  @override
  String get companionWhichPermissionPrompt => '你想了解哪个权限？';

  @override
  String get companionPermissionsListDisclaimer =>
      '这些是应用在你手机上列出的权限，不一定是你屏幕上此刻弹出的窗口。';

  @override
  String get companionNoSensitivePermsMsg => '这个应用没有在你的手机上申请任何敏感权限。';

  @override
  String get companionGuidedMatchTitle => '选择屏幕上的弹窗所请求的内容';

  @override
  String get companionGuidedMatchSubtitle =>
      'Enprive 无法直接读取你当前的 Android 提示。请选择与屏幕上出现的文字最接近的一项：';

  @override
  String get companionSection1Title => '1. 这个权限是什么意思';

  @override
  String get companionSection2Title => '2. 应用在你手机上申请了什么';

  @override
  String get companionSection3Title => '3. 它的隐私政策是怎么说的';

  @override
  String get companionSection4Title => '4. 为什么这可能与某个功能有关';

  @override
  String get companionSection4Fallback =>
      '没有找到经过核实的开发者功能说明。如果想让 Deni 检查相关性，请在下面描述你当时想使用的功能。';

  @override
  String get companionSection5Title => '5. 还有哪些不清楚';

  @override
  String get companionSection6Title => '6. 你可以问 Deni 的问题';

  @override
  String get companionAddPolicyBtn => '添加隐私政策';

  @override
  String get companionCheckUpdatedPolicyBtn => '检查更新后的隐私政策';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return '核对 $appName 的政策';
  }

  @override
  String get companionFeatureFieldLabel => '你当时在使用的功能（可选）';

  @override
  String get companionFeatureFieldHint => '例如：扫描二维码、录制语音练习';

  @override
  String get companionQuestionFieldLabel => '向 Deni 提问';

  @override
  String get companionQuestionFieldHint => '如果我拒绝这个权限会怎样？';

  @override
  String get companionReceiptSavedTitle => '已保存到 Enprive 收据';

  @override
  String get companionReceiptUnsavedTitle => '审查尚未保存到 Enprive';

  @override
  String get companionReceiptSavedBody => '仅存储在你 Enprive 收据存档的本地。';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      '更新后的政策审查只保留在本次会话中。离开助手会丢弃这份草稿，你已保存的收据保持不变。';

  @override
  String get companionReceiptUnsavedBody => '仅保留在本次会话中。如果不保存，离开助手时会被丢弃。';

  @override
  String get companionSaveReceiptBtn => '将收据保存到 Enprive';

  @override
  String get companionSaveReceiptFailed => '无法保存收据。它仍保留在本次会话中，请重试。';

  @override
  String get companionSavedLocalReceiptsSnack => '已保存到本地收据。';

  @override
  String companionDoneReturnToApp(String appName) {
    return '完成 · 返回 $appName';
  }

  @override
  String get companionDoneReturnToPrev => '完成 · 返回上一个应用';

  @override
  String get companionOpenFullAppBtn => '打开完整的 Enprive 应用';

  @override
  String get companionCloudTimeoutSnack => '云端分析耗时过长，已在完成前停止。';

  @override
  String get companionAnalysisCancelledSnack => '分析已取消。';

  @override
  String get companionCloudAnswerTimeoutSnack => '云端回答已超时，已正常结束。';

  @override
  String get companionQuestionCancelledSnack => '提问已取消。';

  @override
  String get companionTileAddedSnack => '已将 Enprive Check 添加到 Android 快捷设置。';

  @override
  String get companionTileAlreadyAddedSnack => 'Enprive Check 已在你的快捷设置中。';

  @override
  String get companionTileDeclinedSnack => '图块请求已关闭。你可以随时在设置或快捷设置的“编辑”中添加。';

  @override
  String get companionTileManualSnack =>
      '向下滑动快捷设置两次，点按“编辑”，然后把 Enprive Check 拖到你的图块中。';

  @override
  String get companionTileUnavailableSnack =>
      'Android 无法在此设备上显示快捷设置提示。你可以在快捷设置的“编辑”中手动拖入 Enprive Check。';

  @override
  String get companionUsageOptionalReason =>
      '“使用情况访问权限”是可选的。你可以手动选择应用，也可以允许该权限，一键识别应用。';

  @override
  String get companionPermPreciseLocation => '精确位置';

  @override
  String get companionPermBackgroundLocation => '后台位置';

  @override
  String get companionPermCamera => '相机';

  @override
  String get companionPermMicrophone => '麦克风';

  @override
  String get companionPermAdId => 'Google 广告 ID';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return '$appName 声明的 Android 权限（$permission）。';
  }

  @override
  String get companionPermStatusAdId => '应用已列出 · 广告 ID';

  @override
  String get companionPermStatusAllowed => '应用已列出 · 允许';

  @override
  String get companionPermStatusNotAllowed => '应用已列出 · 不允许';

  @override
  String get guidedCatLocation => '位置';

  @override
  String get guidedCatContacts => '通讯录';

  @override
  String get guidedCatPhotosMedia => '照片和媒体';

  @override
  String get guidedCatNotifications => '通知';

  @override
  String get guidedCatNearbyDevices => '附近的设备';

  @override
  String get guidedCatCalendar => '日历';

  @override
  String get guidedCatPhone => '电话';

  @override
  String get guidedCatSms => '短信';

  @override
  String get companionFallbackUsageNotEnabled => '尚未在 Android 设置中开启“使用情况访问权限”。';

  @override
  String get companionFallbackUsageUnavailable =>
      'Android UsageStatsManager 不可用。';

  @override
  String get companionFallbackTransientUi =>
      '最近的使用记录中只出现了 Android 系统界面或权限提示，请手动选择应用。';

  @override
  String get companionFallbackVisibilityRestricted =>
      '受 Android 软件包可见性限制，无法查看最近使用的应用。请从列表中选择应用，或粘贴它的政策。';

  @override
  String get companionFallbackUnlockRequired => '请先解锁设备，再查看应用信息。';

  @override
  String get consentReasonPolicyTooDetailed => '这份政策过于详细，端侧 AI 无法处理。';

  @override
  String get consentReasonExcerptTooDetailed => '这段摘录过于详细，端侧 AI 无法处理。';

  @override
  String get consentReasonOnDeviceUnavailable => '此手机上的端侧 AI 目前不可用。';

  @override
  String get consentReasonOnDeviceCannotAnswer => '这台设备上的端侧 AI 目前无法回答。';

  @override
  String get consentReasonVoiceTooLong =>
      '这些已核实的发现超出了端侧摘要的长度限制。你可以现在使用离线摘要，或将隐去个人信息的发现一次性发送给云端 AI。';

  @override
  String get consentReasonVoiceUnavailable =>
      '此手机上的端侧 AI 目前不可用。正在显示 Enprive 的离线通俗摘要。';

  @override
  String get consentReasonVoiceTimedOut => '端侧摘要已超时。正在显示 Enprive 的离线通俗摘要。';

  @override
  String get unsavedExitTitle => '要保存这次隐私审查吗？';

  @override
  String get unsavedExitModifiedBody =>
      '关闭此屏幕时，未保存的审查会被丢弃，所以没有你的选择，手机上不会存储任何内容。你原先保存的收据保持不变。';

  @override
  String get unsavedExitDraftBody => '关闭此屏幕时，未保存的审查会被丢弃，所以没有你的选择，手机上不会存储任何内容。';

  @override
  String get unsavedExitDiscardBtn => '不保存并丢弃';

  @override
  String get unsavedExitContinueBtn => '继续审查';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return '更新 $title 的隐私政策';
  }

  @override
  String get reviewSaveFailedError => '无法保存收据。你的审查草稿仍然开着。';

  @override
  String get reviewRemovedFromReceiptsSnack => '已从已保存的收据中移除。';

  @override
  String get reviewRemoveFailedSnack => '无法移除已保存的收据。';

  @override
  String get reviewModifiedDraftTitle => '来自已保存收据的新草稿';

  @override
  String get reviewModifiedDraftBody => '保存到收据即可保留这次更新后的审查，你原先保存的收据保持不变。';

  @override
  String get btnRetrySave => '重试保存';

  @override
  String samplePermissionsHeader(String badge) {
    return '示例权限（$badge）';
  }

  @override
  String get sourceKindUrl => '公开网页链接';

  @override
  String get sourceKindPdf => '本地 PDF 文件';

  @override
  String get sourceKindDocx => '本地 Word (DOCX) 文件';

  @override
  String get sourceKindTextFile => '本地文本文件';

  @override
  String get sourceKindSharedText => '分享的文本';

  @override
  String get sourceKindSelectedText => '选中的文本';

  @override
  String get sourceKindSampleApp => '示例应用';

  @override
  String get sourceKindPhonePermissions => '手机权限';

  @override
  String get sourceKindPastedText => '粘贴的文本';

  @override
  String get extractionStatusExtracted => '已在此手机上读取';

  @override
  String get extractionStatusNone => '已在此手机上提供';

  @override
  String get extractionStatusUnsupported => '不支持的文件类型';

  @override
  String get extractionStatusTooLarge => '文件太大';

  @override
  String get extractionStatusEmpty => '没有可读取的文本';

  @override
  String get extractionStatusReadError => '无法读取文件';

  @override
  String get extractionStatusPasswordProtected => '受密码保护';

  @override
  String get extractionStatusPermissionDenied => '权限被拒绝';

  @override
  String get extractionStatusCancelled => '已取消';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return '检查时间：$timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return '规范网址：$url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return '重定向自：$url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return '文件：$filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return '状态：$status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return '来源 SHA-256 哈希：$hash';
  }

  @override
  String get semanticsPrimaryNavigation => '主导航';

  @override
  String semanticsProcessingLocation(String label) {
    return '处理位置：$label';
  }

  @override
  String get semanticsDeniMascot => 'Deni，你的隐私向导';

  @override
  String get quoteCollapsibleDefaultHeader => '政策原文摘录';
}
