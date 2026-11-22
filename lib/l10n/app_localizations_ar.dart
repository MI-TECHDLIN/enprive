// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => 'مراجعات خصوصية للتطبيقات قائمة على الأدلة';

  @override
  String get homePrivacySubtitle => 'تبقى مراجعاتك على هذا الهاتف.';

  @override
  String get stateNoConcern => 'لم يُرصد ما يثير القلق';

  @override
  String get stateNoConcernSubtitle =>
      'لا يوجد ما يثير القلق في الأدلة التي تمت مراجعتها. هذه ليست شهادة أمان.';

  @override
  String get stateReviewRecommended => 'يُوصى بالمراجعة';

  @override
  String get stateReviewRecommendedSubtitle =>
      'يستحق نص أو أكثر أو تعارض في الأذونات نظرة بشرية فاحصة.';

  @override
  String get stateInsufficientEvidence => 'أدلة غير كافية';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'الأدلة مفقودة أو غير متوفرة أو تعذّر التحقق منها على هذا الجهاز.';

  @override
  String get chipOnDevice => 'على هذا الجهاز';

  @override
  String get chipInCloud => 'في السحابة';

  @override
  String get chipLocationUnavailable => 'موقع المعالجة غير متاح';

  @override
  String get chipOfflineDeterministic => 'فحص محلي دون اتصال';

  @override
  String get chipUnknown => 'مصدر المعالجة غير معروف';

  @override
  String get statusSourceMatched => 'مطابق للنص الأصلي';

  @override
  String get statusDeviceObserved => 'مرصود على الجهاز';

  @override
  String get statusInterpretation => 'توضيح';

  @override
  String get statusUnverified => 'غير متحقق منه';

  @override
  String get statusStale => 'قديم / غير محدّث';

  @override
  String get btnCheckApp => 'فحص تطبيق';

  @override
  String get btnPasteTerms => 'لصق الشروط أو الرابط';

  @override
  String get btnWhyThisFinding => 'لماذا هذه النتيجة؟';

  @override
  String get btnSaveToReceipts => 'حفظ في الإيصالات';

  @override
  String get btnDiscard => 'تجاهل';

  @override
  String get btnAskDeni => 'اسأل ديني';

  @override
  String get btnUseCloud => 'استخدام السحابة لهذا الفحص';

  @override
  String get btnReviewManually => 'مراجعة يدوية';

  @override
  String get btnGetStarted => 'ابدأ الآن';

  @override
  String get btnContinue => 'متابعة';

  @override
  String get deniIntro =>
      'مرحبًا، أنا ديني. أساعدك على فهم ما تقوله سياسة الخصوصية هذه، وأعرض لك الدليل النصي الدقيق، وأوضح ما تعذّر على Enprive التحقق منه.';

  @override
  String get cloudConsentDisclosure =>
      'لتحليل هذا النص في السحابة، سيرسل Enprive النص المنقّح الظاهر أعلاه فقط إلى Firebase AI Logic. لن يتم إرسال قائمة تطبيقاتك المثبتة أو أذونات Android أبدًا.';

  @override
  String get permissionLimitationNotice =>
      'يُظهر نظام Android حالة الإذن هذه على هذا الهاتف. ولا يثبت ما إذا كان التطبيق قد وصل إلى البيانات أو نقلها فعليًا.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCheck => 'فحص';

  @override
  String get navReceipts => 'الإيصالات';

  @override
  String get navLearn => 'تعلّم';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get languageSubtitle =>
      'ينطبق على واجهة التطبيق والشروحات والقراءة الصوتية';

  @override
  String get homeHeroHeadline =>
      'نظرة أوضح على\nالتطبيقات التي يستخدمها الأطفال';

  @override
  String get trySampleCheck => 'جرّب فحص تطبيق نموذجي';

  @override
  String get eduTrackSubtitle => 'الواجبات والحضور';

  @override
  String get eduTrackValue => '3 طلبات';

  @override
  String get eduTrackTrend => 'مراجعة';

  @override
  String get calmMathSubtitle => 'تدريب رياضيات دون اتصال';

  @override
  String get calmMathValue => '0 حساسة';

  @override
  String get calmMathTrend => 'محدود';

  @override
  String get whatWeCheckTitle => 'ما الذي نفحصه';

  @override
  String get checkQuoteTitle => 'اقتباسات دقيقة من السياسة';

  @override
  String get checkQuoteDesc =>
      'يبرز بنود المشاركة والتسجيل الصوتي والاحتفاظ بالبيانات مع النص الحرفي.';

  @override
  String get checkPermissionTitle => 'تعارض أذونات الهاتف';

  @override
  String get checkPermissionDesc =>
      'يقارن صلاحيات الكاميرا والميكروفون والموقع بما تنص عليه السياسة.';

  @override
  String get checkSelectTitle => 'تحديد النص في أي مكان';

  @override
  String get checkSelectDesc =>
      'ظلّل البنود في أي تطبيق واضغط Enprive Check من قائمة Android.';

  @override
  String get recentlyReviewed => 'المراجعات الأخيرة';

  @override
  String verifiedClausesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بند موثّق',
      many: '$count بندًا موثّقًا',
      few: '$count بنود موثّقة',
      two: 'بندان موثّقان',
      one: 'بند موثّق واحد',
      zero: 'لا توجد بنود موثّقة',
    );
    return '$_temp0';
  }

  @override
  String get trySampleText => 'تجربة نص نموذجي';

  @override
  String get modePasteText => 'لصق نص';

  @override
  String get modePolicyLink => 'رابط السياسة';

  @override
  String get hintAppName => 'اسم التطبيق';

  @override
  String get defaultSubjectTitle => 'سياسة الخصوصية';

  @override
  String get selectedExcerptTitle => 'مقتطف السياسة المحدد';

  @override
  String get hintPastePolicy => 'الصق نص سياسة الخصوصية هنا…';

  @override
  String get btnReviewOnPhone => 'المراجعة على هذا الهاتف';

  @override
  String get onboardingIntroHeadline => 'مرحبًا، أنا ديني. 👋';

  @override
  String get onboardingIntroLead => 'لنجعل فهم خصوصية التطبيقات أسهل.';

  @override
  String get onboardingIntroBody =>
      'سأساعدك على كشف ما تقوله سياسة خصوصية التطبيق حقًا، وإبراز المقاطع المهمة بدقة، وشرح ما يرصدُه جهازك.\n\nلا تخمين ولا وعود زائفة. فقط شروحات واضحة وأدلة تساعدك على اتخاذ قرارات واعية.';

  @override
  String get onboardingIntroFooter => 'اعرف تمامًا ما توافق عليه.';

  @override
  String get splashQuote => 'اعرف تمامًا ما توافق عليه';

  @override
  String get onboardingStep1Question => 'كيف تفضل أن أشرح\nشروط الخصوصية؟';

  @override
  String get depthQuickMultiline => 'موجز\nوبسيط';

  @override
  String get depthBalancedMultiline => 'عرض\nمتوازن';

  @override
  String get depthFullMultiline => 'تفاصيل\nكاملة';

  @override
  String get onboardingReadinessTitle => 'خصوصية افتراضية\nعلى هذا الهاتف';

  @override
  String get onboardingReadinessSubtitle =>
      'صُمم لتمكين الآباء والمعلمين من فحص التطبيقات دون مشاركة بيانات الجهاز.';

  @override
  String get readinessRow1Title => 'يُفحص هنا أولًا';

  @override
  String get readinessRow1Desc => 'تُقرأ السياسات على هاتفك قبل أي إجراء آخر.';

  @override
  String get readinessRow2Title => 'تطبيقاتك تبقى لك وحدك';

  @override
  String get readinessRow2Desc =>
      'التطبيقات المثبتة على هذا الهاتف وأذوناتها لا تغادره أبدًا.';

  @override
  String get readinessRow3Title => 'طمس التفاصيل الشخصية تلقائيًا';

  @override
  String get readinessRow3Desc =>
      'إذا لم يتوفر الذكاء الاصطناعي المحلي أو كانت السياسة طويلة، تُستبدل الأسماء والبريد الإلكتروني والأرقام برموز بديلة قبل فحص App Check.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get privateAnalysisTitle => 'تحليل خاص على هذا الهاتف';

  @override
  String get onDeviceReadyMsg => 'الذكاء الاصطناعي على الجهاز نشط وجاهز.';

  @override
  String get localScannerProtectedMsg => 'محمي بماسح البنود المحلي المدمج.';

  @override
  String get statusChecking => 'جارٍ التحقق…';

  @override
  String get btnCheckReadiness => 'التحقق من الجاهزية';

  @override
  String get howShouldDeniExplain => 'كيف ينبغي أن يشرح ديني؟';

  @override
  String get depthQuick => 'سريع';

  @override
  String get depthBalanced => 'متوازن';

  @override
  String get depthFull => 'تفصيلي';

  @override
  String get preferencesSection => 'التفضيلات';

  @override
  String get meetDeniGuide => 'التعرّف على ديني ودليل الإعداد';

  @override
  String clearSavedReceiptsCount(int count) {
    return 'مسح الإيصالات المحفوظة ($count)';
  }

  @override
  String get btnClear => 'مسح';

  @override
  String get confirmClearReceiptsTitle => 'هل تريد مسح الإيصالات المحفوظة؟';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيؤدي هذا إلى إزالة $count مراجعة محفوظة من هاتفك.',
      many: 'سيؤدي هذا إلى إزالة $count مراجعة محفوظة من هاتفك.',
      few: 'سيؤدي هذا إلى إزالة $count مراجعات محفوظة من هاتفك.',
      two: 'سيؤدي هذا إلى إزالة مراجعتين محفوظتين من هاتفك.',
      one: 'سيؤدي هذا إلى إزالة مراجعة واحدة محفوظة من هاتفك.',
      zero: 'لن يتم حذف أي مراجعة.',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'إلغاء';

  @override
  String get receiptsTitle => 'الإيصالات';

  @override
  String get tooltipSearch => 'بحث';

  @override
  String get hintSearchReceipts => 'ابحث في المراجعات المحفوظة...';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterReview => 'مراجعة';

  @override
  String get filterNoConcern => 'لا قلق';

  @override
  String get emptyFilteredTitle => 'لا توجد إيصالات مطابقة';

  @override
  String get emptyReceiptsTitle => 'لا توجد إيصالات محفوظة بعد';

  @override
  String get emptyFilteredBody => 'جرّب اختيار عامل تصفية آخر أعلاه.';

  @override
  String get emptyReceiptsBody =>
      'احفظ أي مراجعة لتطبيق بالضغط على الإشارة المرجعية للاحتفاظ بنسخة خاصة على هاتفك.';

  @override
  String get btnStartReview => 'بدء مراجعة';

  @override
  String get btnOpenReceipt => 'فتح الإيصال';

  @override
  String get btnDelete => 'حذف';

  @override
  String get checkingPhoneReadiness =>
      'جارٍ التحقق من جاهزية التحليل الخاص على هذا الهاتف…';

  @override
  String get geminiNanoReadyMsg =>
      'Gemini Nano جاهز على هذا الهاتف. تبقى المراجعات بالكامل على جهازك.';

  @override
  String get modelDownloadingMsg => 'جارٍ تنزيل النموذج الخاص في الخلفية.';

  @override
  String get modelDownloadableMsg =>
      'يمكن تنزيل النموذج على الجهاز عبر شبكة Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'يستخدم هذا الهاتف افتراضيًا ماسح البنود المحلي المدمج في Enprive.';

  @override
  String get preparingPrivateAnalysis => 'جارٍ تجهيز التحليل الخاص…';

  @override
  String get onDeviceAiReadyTitle => 'الذكاء الاصطناعي المحلي جاهز';

  @override
  String get localScannerActiveTitle => 'الماسح المحلي نشط';

  @override
  String get privateAnalysisSheetSubtitle =>
      'تطبيقاتك المثبتة وفحوصات الأذونات لا تغادر هاتفك أبدًا.';

  @override
  String get btnDone => 'تم';

  @override
  String get btnCheckAgain => 'التحقق مجددًا';

  @override
  String get reviewingOnPhone => 'جارٍ المراجعة على هذا الهاتف…';

  @override
  String get readingClausesInitial => 'جارٍ قراءة بنود السياسة على هذا الهاتف…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current من $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطوة',
      many: '$count خطوة',
      few: '$count خطوات',
      two: 'خطوتان',
      one: 'خطوة واحدة',
      zero: '0 خطوات',
    );
    return '$_temp0';
  }

  @override
  String get thoughtSignaturePrefix => 'توقيع التفكير';

  @override
  String get viewStreamedThoughts => 'عرض خطوات الاستدلال';

  @override
  String get hideStreamedThoughts => 'إخفاء الاستدلال';

  @override
  String get analysisTraceDefaultTitle => 'كيف تم التحقق من هذه المراجعة';

  @override
  String get savedToLocalReceiptsSnack => 'تم الحفظ في إيصالاتك المحلية.';

  @override
  String get snapshotSheetTitle => 'نسخة السياسة التي تمت مراجعتها';

  @override
  String get snapshotSourcePrefix => 'المصدر';

  @override
  String get snapshotReviewedPrefix => 'تاريخ المراجعة';

  @override
  String get snapshotDigestPrefix => 'البصمة';

  @override
  String get statFindings => 'النتائج';

  @override
  String get statVerified => 'موثّقة';

  @override
  String get statOsGranted => 'ممنوحة من النظام';

  @override
  String get statUnverified => 'غير موثّقة';

  @override
  String get keyFindingsTitle => 'أبرز النتائج';

  @override
  String get reviewedExcerptTitle => 'المقتطف الذي تمت مراجعته';

  @override
  String get permissionsOnPhoneTitle => 'الأذونات على هذا الهاتف';

  @override
  String get viewReviewedSnapshot => 'عرض نسخة السياسة الكاملة';

  @override
  String get btnSavedToReceipts => 'محفوظ في الإيصالات';

  @override
  String get observedOnPhoneLabel => 'مرصود على هذا الهاتف';

  @override
  String get quoteVerifiedLabel => 'اقتباس موثّق في السياسة';

  @override
  String get unverifiedClaimLabel => 'ادعاء غير موثّق';

  @override
  String get categoryDataCollection => 'جمع البيانات';

  @override
  String get categorySharing => 'المشاركة مع أطراف ثالثة';

  @override
  String get categoryTracking => 'الموقع والتتبع';

  @override
  String get categoryRetention => 'الاحتفاظ والصوت';

  @override
  String get categoryParentalControls => 'رقابة الوالدين';

  @override
  String get labelInPlainLanguage => 'بلغة واضحة';

  @override
  String get labelOnThisPhone => 'على هذا الهاتف';

  @override
  String get labelWhatRemainsUnknown => 'ما لا يزال غير معروف';

  @override
  String get presetQuestionMeaning => 'ماذا يعني هذا لطفلي؟';

  @override
  String get presetQuestionOptOut => 'هل يمكننا إيقاف هذا أو رفضه؟';

  @override
  String get presetQuestionUnknown => 'ما الذي لا يزال غير واضح هنا؟';

  @override
  String get readingCitedClause => 'جارٍ قراءة البند المقتبس…';

  @override
  String get deniAnswerTitle => 'إجابة ديني';

  @override
  String get stepsAndReasoning => 'الخطوات ومنطق النموذج';

  @override
  String get chooseReviewModeTitle => 'اختر طريقة مراجعة هذا النص';

  @override
  String get cloudNeverSendsAppsNote =>
      'لا يتم إرسال التطبيقات المثبتة وأذونات الهاتف أبدًا.';

  @override
  String get tooltipClose => 'إغلاق';

  @override
  String get checkAppSheetSubtitle =>
      'يتم الفحص محليًا على هاتفك. لا يتم رفع قائمة تطبيقاتك أبدًا.';

  @override
  String get trySampleKidsApp => 'جرّب تطبيق أطفال نموذجيًا';

  @override
  String get sampleEduTrackSubtitle => 'الموقع والميكروفون والكاميرا';

  @override
  String get sampleCalmMathSubtitle => 'رياضيات دون إنترنت';

  @override
  String get appsOnThisPhone => 'التطبيقات على هذا الهاتف';

  @override
  String get hintSearchApps => 'ابحث عن التطبيقات…';

  @override
  String get noMatchingApps =>
      'لم يتم العثور على تطبيقات مطابقة على هذا الهاتف.';

  @override
  String get sampleSyntheticBadge => 'مثال تجريبي';

  @override
  String get permissionInspectionTitle => 'فحص أذونات الجهاز';

  @override
  String get addAppPrivacyPolicyBtn => 'إضافة سياسة خصوصية هذا التطبيق';

  @override
  String get snapshotDigestLabel => 'بصمة اللقطة · FNV-1a 64-بت';

  @override
  String get snapshotDigestExplanation =>
      'بصمة محلية سريعة بـ 64 بت لهذا النص (وليست تشفير SHA-256). تتغير إذا تغير حرف واحد من النص.';

  @override
  String get copyDigestBtn => 'نسخ البصمة';

  @override
  String get digestCopiedMsg => 'تم نسخ بصمة اللقطة';

  @override
  String get permissionGrantedBadge => 'ممنوح';

  @override
  String get permissionNotGrantedBadge => 'غير ممنوح';

  @override
  String get checkingPolicyWithCloudAi =>
      'جارٍ فحص السياسة باستخدام الذكاء الاصطناعي السحابي.';

  @override
  String get preparingCloudAiStream => 'جارٍ تجهيز التحقق السحابي المنقح…';

  @override
  String get cancellingAnalysis => 'جارٍ الإلغاء…';

  @override
  String get analysisCancelledNotice => 'تم إلغاء المراجعة.';

  @override
  String get cloudTimedOutNotice =>
      'انتهت مهلة الذكاء الاصطناعي السحابي قبل الاستجابة. لم يتم إرسال أي محاولة إعادة تلقائية.';

  @override
  String get cloudFallbackBannerTitle =>
      'تعذّر استخدام السحابة — عُرض الفحص المحلي';

  @override
  String get cloudFallbackBannerBody =>
      'تعذّر التحليل السحابي، لذا جاءت هذه النتيجة من الماسح الحتمي المحلي في Enprive.';

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
  String get appPickerStatusPermissionsInspected => 'Permissions inspected';

  @override
  String get appPickerStatusNotReviewed => 'Not reviewed';

  @override
  String get appPickerSearchHint => 'Search by app or package name…';

  @override
  String get appPickerEmptyInstalledTitle => 'No installed apps available';

  @override
  String get appPickerEmptyInstalledBody =>
      'No launchable apps were reported on this device.';

  @override
  String get intakeModeDocument => 'Document';

  @override
  String get intakeActionInspectText => 'Inspect policy text';

  @override
  String get intakeActionFetchUrl => 'Fetch & inspect policy';

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
      'Fetches the public web page directly. A user-supplied link does not prove app ownership.';

  @override
  String get intakePasteLocalNote =>
      'Checked locally on this phone first. Nothing is uploaded without your permission.';

  @override
  String get intakeDocumentCardTitle => 'Import PDF, TXT, or DOCX policy file';

  @override
  String get intakeDocumentCardBody =>
      'Text is extracted strictly on this phone (up to 10 MB) with a local SHA-256 snapshot hash. Files are never uploaded.';

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
      'Opens the app\'s Play Store listing so you can copy its privacy policy link. Enprive never scrapes Play Store or assumes link ownership.';

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
  String get intakeAssociationInspectWithoutApp => 'Inspect policy without app';

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
  String get voiceBadgeExpressive => 'Expressive voice · Puck';

  @override
  String get voiceBadgeDeviceOffline => 'Device voice · Offline';

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
      'To speak this summary with Deni’s expressive Gemini voice (Puck), Enprive will send only the redacted summary text shown above to Firebase AI Logic for this single request. Your installed apps and Android permissions are never sent.';

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
      'To rewrite these verified policy findings in plain language in the cloud, Enprive will send only the redacted excerpts shown above to Firebase AI Logic once. Your installed apps and Android permissions are never sent.';

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
      other: '$count personal details are masked first.',
      one: '1 personal detail is masked first.',
      zero: 'No personal details were found to mask.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'Your app list and phone permissions stay on this phone.';

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
  String get labelWhatAndroidReports => 'What Android reports';

  @override
  String get sourceButtonTooltip => 'Reviewed source';
}
