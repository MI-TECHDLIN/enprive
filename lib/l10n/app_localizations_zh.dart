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
  String get stateReviewRecommendedSubtitle => '有一项或多项条款内容或权限不一致，值得家长或老师仔细确认。';

  @override
  String get stateInsufficientEvidence => '证据不足';

  @override
  String get stateInsufficientEvidenceSubtitle => '证据缺失、不可用，或无法在此设备上完成验证。';

  @override
  String get chipOnDevice => '在此设备上';

  @override
  String get chipInCloud => '云端分析';

  @override
  String get chipLocationUnavailable => '处理位置不可用';

  @override
  String get statusSourceMatched => '原文已匹配';

  @override
  String get statusDeviceObserved => '设备端已观察';

  @override
  String get statusInterpretation => '解读说明';

  @override
  String get statusUnverified => '未经验证';

  @override
  String get statusStale => '可能已过时';

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
      '为了在云端分析此文本，Enprive 仅会将下方显示的文本发送给 Firebase AI Logic。你已安装的应用列表和 Android 权限信息绝不会被发送。';

  @override
  String get permissionLimitationNotice =>
      'Android 在此手机上报告了该权限状态，但这不能证明应用是否实际访问或传输过数据。';

  @override
  String get navHome => '首页';

  @override
  String get navReceipts => '收据';

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
  String get checkQuoteDesc => '结合隐私政策逐字原文，标出数据共享、语音录制和保留期限条款。';

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
      other: '$count 项已验证条款',
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
  String get readinessRow3Title => '个人信息自动脱敏';

  @override
  String get readinessRow3Desc =>
      '若本机 AI 不可用或政策文本较长，在通过 App Check 验证前会先将姓名、邮箱和电话替换为占位符。';

  @override
  String get settingsTitle => '设置';

  @override
  String get privateAnalysisTitle => '此手机上的私密分析';

  @override
  String get onDeviceReadyMsg => '端侧 AI 已激活并准备就绪。';

  @override
  String get localScannerProtectedMsg => '正由内置本地条款扫描器提供保护。';

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
  String get geminiNanoReadyMsg => 'Gemini Nano 已在此手机上准备就绪，所有审查完全在本地运行。';

  @override
  String get modelDownloadingMsg => '正在后台下载端侧私密模型。';

  @override
  String get modelDownloadableMsg => '可在连接 Wi-Fi 时下载端侧模型。';

  @override
  String get localScannerDefaultMsg => '此手机默认使用 Enprive 内置的本地条款扫描器。';

  @override
  String get preparingPrivateAnalysis => '正在准备私密分析…';

  @override
  String get onDeviceAiReadyTitle => '端侧 AI 已就绪';

  @override
  String get localScannerActiveTitle => '本地扫描器运行中';

  @override
  String get privateAnalysisSheetSubtitle => '你的已安装应用列表和权限检查绝不会离开手机。';

  @override
  String get btnDone => '完成';

  @override
  String get btnCheckAgain => '重新检查';

  @override
  String get reviewingOnPhone => '正在此手机上审查…';

  @override
  String get readingClausesInitial => '正在此手机上读取隐私条款…';

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
  String get thoughtSignaturePrefix => '推理签名';

  @override
  String get viewStreamedThoughts => '查看模型推理过程';

  @override
  String get hideStreamedThoughts => '收起推理过程';

  @override
  String get analysisTraceDefaultTitle => '本次审查的验证过程';

  @override
  String get savedToLocalReceiptsSnack => '已保存到本机收据记录。';

  @override
  String get snapshotSheetTitle => '已审查的政策原文快照';

  @override
  String get snapshotSourcePrefix => '来源';

  @override
  String get snapshotReviewedPrefix => '审查时间';

  @override
  String get snapshotDigestPrefix => '摘要指纹';

  @override
  String get statFindings => '发现条目';

  @override
  String get statVerified => '已验证';

  @override
  String get statOsGranted => '系统已授权';

  @override
  String get statUnverified => '未验证';

  @override
  String get keyFindingsTitle => '核心发现';

  @override
  String get reviewedExcerptTitle => '已审查原文摘要';

  @override
  String get permissionsOnPhoneTitle => '此手机上的应用权限';

  @override
  String get viewReviewedSnapshot => '查看完整政策原文快照';

  @override
  String get btnSavedToReceipts => '已保存至收据';

  @override
  String get observedOnPhoneLabel => '在本机检测到';

  @override
  String get quoteVerifiedLabel => '已在原文中匹配验证';

  @override
  String get unverifiedClaimLabel => '未经验证的表述';

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
  String get labelWhatRemainsUnknown => '尚不明确之处';

  @override
  String get presetQuestionMeaning => '这对我的孩子意味着什么？';

  @override
  String get presetQuestionOptOut => '可以关闭或选择退出吗？';

  @override
  String get presetQuestionUnknown => '这里还有哪些未明确的信息？';

  @override
  String get readingCitedClause => '正在读取引用的政策条款…';

  @override
  String get deniAnswerTitle => 'Deni 的回答';

  @override
  String get stepsAndReasoning => '步骤与模型推理';

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
}
