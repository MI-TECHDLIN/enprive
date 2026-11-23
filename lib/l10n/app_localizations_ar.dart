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
      'يحتاج جزء أو أكثر من السياسة أو أذونات الهاتف إلى نظرة أدق.';

  @override
  String get stateInsufficientEvidence => 'أدلة غير كافية';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'نحتاج إلى مزيد من نص سياسة الخصوصية قبل أن نتمكن من فحص ما يفعله هذا التطبيق.';

  @override
  String get chipOnDevice => 'على هذا الجهاز';

  @override
  String get chipInCloud => 'في السحابة';

  @override
  String get chipLocationUnavailable => 'المصدر غير متاح';

  @override
  String get chipOfflineDeterministic => 'تم الفحص دون إنترنت على هذا الهاتف';

  @override
  String get chipUnknown => 'المصدر غير معروف';

  @override
  String get statusSourceMatched => 'مطابق في السياسة';

  @override
  String get statusDeviceObserved => 'مرصود على هذا الهاتف';

  @override
  String get statusInterpretation => 'شرح Deni';

  @override
  String get statusUnverified => 'غير موجود في السياسة';

  @override
  String get statusStale => 'فحص قديم';

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
      'لفحص هذا النص في السحابة، سيرسل Enprive النص المعروض أعلاه فقط (بعد إخفاء التفاصيل الشخصية) لهذا الطلب الواحد. لن تُرسل تطبيقاتك ولا أذونات هاتفك أبدًا.';

  @override
  String get permissionLimitationNotice =>
      'يعرض هاتفك ما إذا كان هذا الإذن مسموحًا به أم لا. ولا يثبت ذلك ما إذا كان التطبيق قد وصل إلى البيانات أو أرسلها فعلًا.';

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
      'يبرز مشاركة البيانات والتسجيل الصوتي ومدة الاحتفاظ بالبيانات باستخدام اقتباسات دقيقة.';

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
      other: '$count اقتباس مطابق',
      many: '$count اقتباسًا مطابقًا',
      few: '$count اقتباسات مطابقة',
      two: 'اقتباسان مطابقان',
      one: 'اقتباس واحد مطابق',
      zero: '0 اقتباسات مطابقة',
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
  String get readinessRow3Title => 'إخفاء التفاصيل الشخصية';

  @override
  String get readinessRow3Desc =>
      'إذا اخترت المساعدة السحابية، تُخفى الأسماء وعناوين البريد الإلكتروني وأرقام الهاتف قبل إرسال أي شيء.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get privateAnalysisTitle => 'تحليل خاص على هذا الهاتف';

  @override
  String get onDeviceReadyMsg => 'الذكاء الاصطناعي على الجهاز نشط وجاهز.';

  @override
  String get localScannerProtectedMsg =>
      'جاهز لفحص السياسات دون إنترنت على هذا الهاتف.';

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
      'الذكاء الاصطناعي على الجهاز جاهز على هذا الهاتف. تبقى المراجعات بالكامل على جهازك.';

  @override
  String get modelDownloadingMsg => 'جارٍ تنزيل النموذج الخاص في الخلفية.';

  @override
  String get modelDownloadableMsg =>
      'يمكن تنزيل النموذج على الجهاز عبر شبكة Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'يفحص هذا الهاتف السياسات دون إنترنت على جهازك افتراضيًا.';

  @override
  String get preparingPrivateAnalysis => 'جارٍ تجهيز التحليل الخاص…';

  @override
  String get onDeviceAiReadyTitle => 'الذكاء الاصطناعي المحلي جاهز';

  @override
  String get localScannerActiveTitle => 'الفحص دون إنترنت جاهز';

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
  String get readingClausesInitial => 'جارٍ قراءة نص السياسة على هذا الهاتف…';

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
  String get thoughtSignaturePrefix => 'معرّف الفحص';

  @override
  String get viewStreamedThoughts => 'كيف فحص Enprive هذا';

  @override
  String get hideStreamedThoughts => 'إخفاء طريقة فحص Enprive';

  @override
  String get analysisTraceDefaultTitle => 'كيف تم التحقق من هذه المراجعة';

  @override
  String get savedToLocalReceiptsSnack => 'تم الحفظ في إيصالاتك المحلية.';

  @override
  String get snapshotSheetTitle => 'نص السياسة الذي تمت مراجعته';

  @override
  String get snapshotSourcePrefix => 'المصدر';

  @override
  String get snapshotReviewedPrefix => 'تاريخ المراجعة';

  @override
  String get snapshotDigestPrefix => 'بصمة المستند';

  @override
  String get statFindings => 'النتائج';

  @override
  String get statVerified => 'موثّقة';

  @override
  String get statOsGranted => 'مسموح على الهاتف';

  @override
  String get statUnverified => 'غير موجود';

  @override
  String get keyFindingsTitle => 'أبرز النتائج';

  @override
  String get reviewedExcerptTitle => 'المقتطف الذي تمت مراجعته';

  @override
  String get permissionsOnPhoneTitle => 'الأذونات على هذا الهاتف';

  @override
  String get viewReviewedSnapshot => 'عرض نص السياسة الذي تمت مراجعته';

  @override
  String get btnSavedToReceipts => 'محفوظ في الإيصالات';

  @override
  String get observedOnPhoneLabel => 'مرصود على هذا الهاتف';

  @override
  String get quoteVerifiedLabel => 'اقتباس دقيق من السياسة';

  @override
  String get unverifiedClaimLabel => 'غير موجود في السياسة';

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
  String get labelWhatRemainsUnknown => 'ما الذي ما زلنا لا نعرفه';

  @override
  String get presetQuestionMeaning => 'ماذا يعني هذا لطفلي؟';

  @override
  String get presetQuestionOptOut => 'هل يمكننا إيقاف هذا أو رفضه؟';

  @override
  String get presetQuestionUnknown => 'ما الذي لا يزال غير واضح هنا؟';

  @override
  String get readingCitedClause => 'جارٍ قراءة اقتباس السياسة…';

  @override
  String get deniAnswerTitle => 'إجابة ديني';

  @override
  String get stepsAndReasoning => 'كيف فحص Deni هذا';

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
  String get sampleSyntheticBadge => 'تطبيق نموذجي';

  @override
  String get permissionInspectionTitle => 'تم فحص أذونات الهاتف';

  @override
  String get addAppPrivacyPolicyBtn => 'إضافة سياسة خصوصية هذا التطبيق';

  @override
  String get snapshotDigestLabel => 'بصمة المستند';

  @override
  String get snapshotDigestExplanation =>
      'رمز فريد يساعد على التحقق من أن هذا هو النص نفسه الذي فحصه Enprive. إذا تغيّر حرف واحد فقط، يتغيّر هذا الرمز أيضًا.';

  @override
  String get copyDigestBtn => 'نسخ البصمة';

  @override
  String get digestCopiedMsg => 'تم نسخ بصمة المستند';

  @override
  String get permissionGrantedBadge => 'مسموح على هذا الهاتف';

  @override
  String get permissionNotGrantedBadge => 'غير مسموح';

  @override
  String get checkingPolicyWithCloudAi =>
      'جارٍ فحص السياسة باستخدام الذكاء الاصطناعي السحابي.';

  @override
  String get preparingCloudAiStream =>
      'جارٍ إخفاء التفاصيل الشخصية قبل الفحص السحابي…';

  @override
  String get cancellingAnalysis => 'جارٍ الإلغاء…';

  @override
  String get analysisCancelledNotice => 'تم إلغاء المراجعة.';

  @override
  String get cloudTimedOutNotice =>
      'انتهت مهلة الذكاء الاصطناعي السحابي قبل الاستجابة. لم يتم إرسال أي محاولة إعادة تلقائية.';

  @override
  String get cloudFallbackBannerTitle =>
      'السحابة غير متاحة: تم الفحص على هذا الهاتف';

  @override
  String get cloudFallbackBannerBody =>
      'لم يكن التحليل السحابي متاحًا، لذلك فحص Enprive هذه السياسة مباشرة على هاتفك.';

  @override
  String get appPickerFilterAll => 'كل التطبيقات';

  @override
  String get appPickerFilterDownloaded => 'المُنزَّلة';

  @override
  String get appPickerFilterSystem => 'النظام';

  @override
  String get appPickerRecentlyChecked => 'فُحصت مؤخرًا';

  @override
  String get appPickerStatusPolicySaved => 'تم حفظ مراجعة السياسة';

  @override
  String get appPickerStatusPermissionsInspected => 'تم فحص الأذونات';

  @override
  String get appPickerStatusNotReviewed => 'لم تُراجع';

  @override
  String get appPickerSearchHint => 'ابحث باسم التطبيق أو App ID…';

  @override
  String get appPickerEmptyInstalledTitle => 'لا توجد تطبيقات مثبتة متاحة';

  @override
  String get appPickerEmptyInstalledBody =>
      'لم نتمكن من العثور على أي تطبيقات لفحصها على هذا الهاتف.';

  @override
  String get intakeModeDocument => 'مستند';

  @override
  String get intakeActionInspectText => 'فحص نص السياسة';

  @override
  String get intakeActionFetchUrl => 'فتح السياسة وفحصها';

  @override
  String get intakeActionChooseDocument => 'اختر ملف PDF أو TXT أو DOCX';

  @override
  String get intakeActionReplaceDocument => 'اختر مستندًا بديلًا';

  @override
  String get intakeWorkingLabel => 'جارٍ العمل…';

  @override
  String get intakeCancelFetch => 'إلغاء الجلب';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'يفتح صفحة الويب العامة هذه مباشرة. إضافة رابط هنا لا تثبت ملكية التطبيق.';

  @override
  String get intakePasteLocalNote =>
      'يُفحص محليًا على هذا الهاتف أولًا. لا يُرفع أي شيء دون إذنك.';

  @override
  String get intakeDocumentCardTitle => 'استيراد ملف سياسة PDF أو TXT أو DOCX';

  @override
  String get intakeDocumentCardBody =>
      'نقرأ النص مباشرة على هاتفك (حتى 10 MB). لا يُرفع ملفك أبدًا.';

  @override
  String get intakeCompareWithAppPrompt => 'المقارنة مع تطبيق مثبت (اختياري)';

  @override
  String get intakeCompareWithAppHint =>
      'يعمل محليًا على هذا الهاتف. قائمة تطبيقاتك لا تغادر جهازك أبدًا.';

  @override
  String get intakeCompareWithAppChange => 'تغيير';

  @override
  String get intakeCompareWithAppRemove => 'إزالة';

  @override
  String get intakeLockedAppContextLabel => 'التطبيق المحدد';

  @override
  String get intakeFindPolicyOnPlayStore =>
      'البحث عن رابط السياسة في Play Store';

  @override
  String get intakePlayStoreHelperNote =>
      'يفتح Play Store حتى تتمكن من نسخ رابط سياسة خصوصية التطبيق. لا ينسخه Enprive تلقائيًا ولا يفترض أن الرابط رسمي.';

  @override
  String get intakePlayStoreUnavailable =>
      'تعذّر فتح Google Play Store على هذا الجهاز. الصق رابط السياسة أو نصها يدويًا بدلًا من ذلك.';

  @override
  String get intakeRecoverySwitchPaste => 'لصق النص بدلًا من ذلك';

  @override
  String get intakeRecoverySwitchDocument => 'استيراد مستند';

  @override
  String get intakeRecoveryRetryUrl => 'إعادة محاولة الجلب';

  @override
  String get intakeExpiredDocumentShareNotice =>
      'لم يعد بالإمكان إعادة فتح رابط الملف المُشارك أصلًا. اختر ملف PDF أو TXT أو DOCX بديلًا أو الصق نص السياسة يدويًا.';

  @override
  String get intakeAssociationWarningTitle => 'فحص تطابق التطبيق والسياسة';

  @override
  String get intakeAssociationContinueAnyway => 'المتابعة على أي حال';

  @override
  String get intakeAssociationChangeApp => 'تغيير التطبيق المحدد';

  @override
  String get intakeAssociationInspectWithoutApp => 'فحص السياسة دون تطبيق';

  @override
  String get intakeModeSelectorSemanticLabel => 'طريقة إدخال السياسة';

  @override
  String get tooltipClearSearch => 'مسح البحث';

  @override
  String get intakeRecoveryEditUrl => 'تعديل الرابط';

  @override
  String get voiceSummaryTitle => 'ملخص Deni بلغة واضحة';

  @override
  String get voiceSummaryPreparing => 'جارٍ إعداد الملخص بلغة واضحة…';

  @override
  String get voiceSynthesizingExpressive => 'جارٍ تجهيز صوت Deni التعبيري…';

  @override
  String get voiceBtnListenOffline => 'استمع';

  @override
  String get voiceBtnStop => 'إيقاف';

  @override
  String get voiceBtnExpressiveCloud => 'صوت تعبيري';

  @override
  String get voiceBtnSummarizeCloud => 'التلخيص بالذكاء الاصطناعي السحابي';

  @override
  String get voiceBadgeExpressive => 'صوت سحابي تعبيري';

  @override
  String get voiceBadgeDeviceOffline => 'صوت الهاتف · دون إنترنت';

  @override
  String get voiceViewSourceQuote => 'اقتباس المصدر';

  @override
  String get voiceHideSourceQuote => 'إخفاء الاقتباس';

  @override
  String get voiceInspectFinding => 'فحص النتيجة';

  @override
  String get voiceConsentTitle => 'اختر صوت Deni';

  @override
  String get voiceConsentDisclosure =>
      'لقراءة هذا الملخص بصوت عالٍ باستخدام صوت Deni السحابي التعبيري، سيرسل Enprive نص الملخص المعروض أعلاه فقط (بعد إخفاء التفاصيل الشخصية) لهذا الطلب الواحد. لن تُرسل تطبيقاتك ولا أذونات هاتفك أبدًا.';

  @override
  String get voiceConsentPrimaryAction => 'استخدام الصوت التعبيري مرة واحدة';

  @override
  String get voiceConsentSecondaryAction => 'القراءة على هذا الهاتف';

  @override
  String get voiceConsentPayloadLabel => 'النص المنطوق بدقة';

  @override
  String get voiceSummaryConsentTitle =>
      'تلخيص النتائج بالذكاء الاصطناعي السحابي';

  @override
  String get voiceSummaryConsentDisclosure =>
      'لتلخيص اقتباسات السياسة هذه بلغة واضحة في السحابة، سيرسل Enprive النص المعروض أعلاه فقط (بعد إخفاء التفاصيل الشخصية) لهذا الطلب الواحد. لن تُرسل تطبيقاتك ولا أذونات هاتفك أبدًا.';

  @override
  String get voiceFallbackDeviceNotice =>
      'الصوت السحابي التعبيري غير متاح: يتم استخدام صوت هذا الهاتف دون إنترنت بدلًا منه.';

  @override
  String get voiceUnavailableNotice =>
      'التشغيل الصوتي غير متاح لهذه اللغة على هذا الهاتف. يمكنك قراءة ملخص Deni أعلاه.';

  @override
  String get voiceTooltipReadSummary => 'الاستماع إلى ملخص Deni بلغة واضحة';

  @override
  String get voiceTooltipStopReading => 'إيقاف القراءة الصوتية';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نتيجة',
      many: 'نتيجة',
      few: 'نتائج',
      two: 'نتيجتان',
      one: 'نتيجة',
      zero: 'نتائج',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اقتباس موثّق في السياسة',
      many: '$count اقتباسًا موثّقًا في السياسة',
      few: '$count اقتباسات موثّقة في السياسة',
      two: 'اقتباسان موثّقان في السياسة',
      one: 'اقتباس واحد موثّق في السياسة',
      zero: '0 اقتباسات موثّقة في السياسة',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر مرصود على هذا الهاتف',
      many: '$count عنصرًا مرصودًا على هذا الهاتف',
      few: '$count عناصر مرصودة على هذا الهاتف',
      two: 'عنصران مرصودان على هذا الهاتف',
      one: 'عنصر واحد مرصود على هذا الهاتف',
      zero: '0 مرصود على هذا الهاتف',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'مسموح على هذا الهاتف';

  @override
  String get permissionNotAllowedOnPhone => 'غير مسموح';

  @override
  String get permissionAllowedInSample => 'مسموح في النموذج';

  @override
  String get permissionNotAllowedInSample => 'غير مسموح في النموذج';

  @override
  String get permissionMismatchChip => 'غير مذكور في السياسة';

  @override
  String get howEnpriveCheckedThis => 'كيف فحص Enprive هذا';

  @override
  String get hideHowEnpriveChecked => 'إخفاء طريقة فحص Enprive';

  @override
  String get consentWhatWouldBeSent => 'ما الذي سيُرسل';

  @override
  String get consentSentScope =>
      'يغادر هذا الهاتف النص المعروض في المعاينة فقط، لهذا الطلب الواحد.';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم إخفاء $count تفصيل شخصي أولًا.',
      many: 'تم إخفاء $count تفصيلًا شخصيًا أولًا.',
      few: 'تم إخفاء $count تفاصيل شخصية أولًا.',
      two: 'تم إخفاء تفصيلين شخصيين أولًا.',
      one: 'تم إخفاء تفصيل شخصي واحد أولًا.',
      zero: 'لم يُعثر على تفاصيل شخصية لإخفائها.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'قائمة تطبيقاتك وأذونات هاتفك تبقى على هذا الهاتف.';

  @override
  String receiptDeletedSnack(String title) {
    return 'تم حذف $title';
  }

  @override
  String get btnUndo => 'تراجع';

  @override
  String get readinessPromiseMaskedTitle => 'إخفاء التفاصيل الشخصية';

  @override
  String get readinessPromiseMaskedLine =>
      'إذا اخترت السحابة، تُخفى الأسماء وعناوين البريد والأرقام أولًا.';

  @override
  String findingDetailTitle(int index, int total) {
    return 'النتيجة $index من $total';
  }

  @override
  String get findingReviewChip => 'مراجعة';

  @override
  String get askDeniAboutThis => 'اسأل Deni عن هذا';

  @override
  String get labelWhatPolicySays => 'ما تقوله السياسة';

  @override
  String get labelWhatAndroidReports => 'ما يعرضه هاتفك';

  @override
  String get sourceButtonTooltip => 'المصدر الذي تمت مراجعته';

  @override
  String get linkInstalledAppBtn => 'ربط تطبيق مثبت';

  @override
  String get linkInstalledAppCardTitle => 'المقارنة مع تطبيق على هذا الهاتف';

  @override
  String get linkInstalledAppCardBody =>
      'اختر تطبيقًا مثبتًا لمقارنة أذوناته على الهاتف مع هذه السياسة في المراجعة نفسها. قائمة تطبيقاتك تبقى على هذا الهاتف.';

  @override
  String get linkAppPickerTitle => 'ربط تطبيق مثبت';

  @override
  String get changeLinkedAppPickerTitle => 'تغيير التطبيق المرتبط';

  @override
  String get linkAppPickerSubtitle =>
      'اختر تطبيقًا على هذا الهاتف لمقارنة أذوناته مع هذه السياسة. قائمة تطبيقاتك لا تغادر هذا الهاتف أبدًا.';

  @override
  String get linkedAppCurrentlySelectedBadge => 'مرتبط';

  @override
  String get linkedAppSectionLabel => 'التطبيق المرتبط على هذا الهاتف';

  @override
  String get btnChangeLinkedApp => 'تغيير التطبيق';

  @override
  String get btnUnlinkApp => 'إلغاء الربط';

  @override
  String get btnUpdatePrivacyPolicy => 'إرفاق سياسة خصوصية محدّثة';

  @override
  String linkedAppSnack(String appName) {
    return 'تم ربط $appName. تمت مقارنة الأذونات على هذا الهاتف.';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return 'تم ربط $appName. راجع ملاحظة تطابق التطبيق والسياسة أدناه.';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return 'التطبيق $appName مرتبط بالفعل بالأذونات نفسها.';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return 'تم إلغاء ربط $appName. يتم عرض مراجعة السياسة فقط.';
  }

  @override
  String get associationStatusPackageTitle =>
      'تم العثور على App ID في هذه السياسة';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'تذكر هذه السياسة $packageName. يشير ذلك إلى أنها قد تصف $appName، لكن النص وحده لا يثبت من يملك هذه السياسة.';
  }

  @override
  String get associationStatusNameTitle =>
      'تم العثور على اسم التطبيق في هذه السياسة';

  @override
  String associationStatusNameBody(String appName) {
    return 'تذكر هذه السياسة $appName. يشير ذلك إلى أنها قد تصف هذا التطبيق، لكن تطابق الاسم لا يثبت من يملك هذه السياسة.';
  }

  @override
  String get associationStatusUnverifiedTitle => 'ربطته أنت للمقارنة';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'لا تذكر هذه السياسة اسم $appName ولا App ID الخاص به. تحقق جيدًا من أنها السياسة الصحيحة: ربطها هنا لا يثبت الملكية.';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'يتضمن عنوان الويب كلمات من $appName، لكن نص السياسة نفسه لا يذكر هذا التطبيق. تحقق جيدًا من أنها السياسة الصحيحة: ربطها هنا لا يثبت الملكية.';
  }

  @override
  String get associationStatusUnmatchedTitle =>
      'قد تكون هذه السياسة لتطبيق مختلف';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'لا تذكر هذه السياسة $appName. بل تذكر بدلًا منه $otherApps. تحقق من أنك ربطت التطبيق الصحيح أو فتحت السياسة الصحيحة.';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'تذكر هذه السياسة أكثر من تطبيق';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'تذكر هذه السياسة $appName إلى جانب $otherApps. قد تغطي عدة تطبيقات أو تكون سياسة مشتركة للشركة، لذا تحقق من أنها تنطبق هنا.';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      'أكثر من تطبيق على هذا الهاتف له اسم مشابه';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'تذكر هذه السياسة $appName دون إدراج App ID واحد دقيق، وتوجد تطبيقات أخرى على هاتفك ($otherApps) تحمل اسمًا مشابهًا. تأكد من أنك ربطت التطبيق الصحيح.';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'قد تشير هذه السياسة إلى أكثر من تطبيق. تحقق جيدًا من أنها تنطبق على $appName.';
  }

  @override
  String get associationOwnershipLimitation =>
      'لا تثبت النصوص ولا روابط الويب أبدًا من نشر السياسة أو من يملكها.';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count إذن على هذا الهاتف غير مذكور بوضوح في هذه السياسة. هذا التعارض دعوة للنظر عن قرب، وليس دليلًا على مخالفة.',
      many:
          '$count إذنًا على هذا الهاتف غير مذكور بوضوح في هذه السياسة. هذا التعارض دعوة للنظر عن قرب، وليس دليلًا على مخالفة.',
      few:
          '$count أذونات على هذا الهاتف غير مذكورة بوضوح في هذه السياسة. هذا التعارض دعوة للنظر عن قرب، وليس دليلًا على مخالفة.',
      two: 'إذنان على هذا الهاتف غير مذكورين بوضوح في هذه السياسة. هذا التعارض دعوة للنظر عن قرب، وليس دليلًا على مخالفة.',
      one: 'إذن واحد على هذا الهاتف غير مذكور بوضوح في هذه السياسة. هذا التعارض دعوة للنظر عن قرب، وليس دليلًا على مخالفة.',
      zero: 'لا توجد أذونات غير مذكورة في هذه السياسة.',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'لا يتعارض أي من الأذونات المفحوصة على هذا الهاتف مع هذه السياسة. ولا يمكن للأذونات وحدها أن تُظهر ما يرسله التطبيق فعلًا.';

  @override
  String get permissionComparisonLimitationNote =>
      'يعرض هاتفك إعدادات الأذونات على هذا الهاتف فقط. هذه المقارنة دعوة للنظر عن قرب، وليست أبدًا دليلًا على مخالفة أو على إرسال بيانات.';

  @override
  String get permissionNotRequestedOnPhone => 'لم يطلبه التطبيق';

  @override
  String get permissionNotRequestedInSample => 'غير مطلوب في النموذج';

  @override
  String get permissionsEmptyComparisonTitle =>
      'لم تُطابق أي أذونات حساسة في هذا الفحص';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'يعرض هاتفك $requestedCount أذونات ($grantedCount مسموح بها) للتطبيق $appName، دون أي إذن ضمن الفئات الحساسة المفحوصة هنا (الموقع أو الكاميرا أو الميكروفون أو جهات الاتصال أو الصور أو معرّف الإعلانات).';
  }

  @override
  String get sourceDeviceInspection => 'تم الفحص على هذا الهاتف';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => 'تفاصيل متقدمة';

  @override
  String get advancedDetailsSubtitle =>
      'تفاصيل تقنية تتحقق من وقت ومكان فحص نص هذه السياسة.';

  @override
  String get sourceSectionTitle => 'من أين جاءت هذه السياسة';

  @override
  String get cloudPayloadLabel => 'النص الدقيق الذي سيُرسل';

  @override
  String get cloudPayloadNoPiiLabel => 'لم يُعثر على تفاصيل شخصية';

  @override
  String cloudPayloadHiddenCount(int count) {
    return 'مخفي ($count)';
  }

  @override
  String get summarySourceOnDevice => 'ملخّص على هذا الهاتف';

  @override
  String get summarySourceInCloud => 'ملخّص في السحابة';

  @override
  String get summarySourceOffline => 'ملخّص دون إنترنت على هذا الهاتف';

  @override
  String get summarySourceUnknown => 'مصدر الملخص غير معروف';

  @override
  String get notFromPolicySuffix => 'من إعدادات هاتفك، وليس من السياسة';

  @override
  String get sampleNotFromPolicySuffix => 'مثال فقط، وليس من السياسة';

  @override
  String get learnHeaderSubtitle => 'أدلة خصوصية ورسوم توضيحية دون إنترنت';

  @override
  String get learnFilterAll => 'كل المواضيع';

  @override
  String get learnFilterPolicies => 'السياسات';

  @override
  String get learnFilterPermissions => 'الأذونات';

  @override
  String get learnFilterSharing => 'المشاركة';

  @override
  String get learnFilterEvidence => 'الأدلة';

  @override
  String learnLessonStepCount(int count) {
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
  String get learnDeckTitle => 'تدرّب على عادات الخصوصية محليًا';

  @override
  String get learnDeckBody =>
      'دروس دون إنترنت بالكامل مع رسوم توضيحية. لا تدخل تطبيقاتك المثبتة ولا إيصالاتك أبدًا إلى قسم تعلّم.';

  @override
  String get learnDeckCheckBtn => 'طبّق ذلك · فحص تطبيق';

  @override
  String get learnCheckAppBridgeBtn => 'فحص تطبيق على هذا الهاتف';

  @override
  String get learnSectionDiagram => 'كيف يعمل ذلك';

  @override
  String get learnSectionSteps => 'الخطوات الأساسية';

  @override
  String get learnSectionQuickCheck => 'اختبار سريع';

  @override
  String get learnTooltipListenLesson => 'قراءة هذا الدرس بصوت عالٍ دون إنترنت';

  @override
  String get learnTooltipStopLesson => 'إيقاف القراءة الصوتية للدرس';

  @override
  String get learnVoiceUnavailableNotice =>
      'التشغيل الصوتي دون إنترنت غير متاح لهذه اللغة على هذا الهاتف. يمكنك قراءة الدرس أدناه.';

  @override
  String get learnQuickCheckCorrectBadge => 'إجابة صحيحة';

  @override
  String get learnQuickCheckTryAgainBadge => 'جرّب خيارًا آخر';

  @override
  String learnLessonProgress(int current, int total) {
    return 'الدرس $current من $total';
  }

  @override
  String get learnBackTooltip => 'العودة إلى تعلّم';

  @override
  String get learnPreviousLesson => 'السابق';

  @override
  String get learnNextLesson => 'التالي';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return 'الدرس السابق: $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return 'الدرس التالي: $title';
  }

  @override
  String get learnPolicyFolderTitle => 'سياسات الخصوصية';

  @override
  String get learnPolicyTitle => 'ما هي سياسة الخصوصية (وما لا يمكنها إثباته)';

  @override
  String get learnPolicySubtitle =>
      'ما يعد به المطورون مقابل ما يبقى غير معروف';

  @override
  String get learnPolicyIntro =>
      'سياسة الخصوصية هي بيان عام من المطور يوضح البيانات التي يقول التطبيق إنه يجمعها، ولماذا يستخدمها، ومن قد يتلقاها، وما الخيارات المتاحة للعائلات.';

  @override
  String get learnPolicyStep1 =>
      'ابحث عن أربعة أساسيات: ما البيانات التي تُجمع، ولماذا يحتاجها التطبيق، ومن غيره قد يحصل عليها، وكيف يمكنك طلب الحذف.';

  @override
  String get learnPolicyStep2 =>
      'الصياغة المربكة شائعة. وجدت دراسة أُجريت عام 2026 حول تطبيقات تعلم الأطفال أن قلة قليلة من السياسات كانت سهلة القراءة، وأن معظم التطبيقات لم تتطابق بالكامل مع ما ذكرته سياساتها.';

  @override
  String get learnPolicyStep3 =>
      'تُظهر سياسة الخصوصية فقط ما يقوله المطور على الورق. قراءتها لا تثبت ما يرسله التطبيق فعلًا عبر الإنترنت.';

  @override
  String get learnPolicyStep4 =>
      'مقارنة السياسة بإعدادات أذونات هاتفك تمنحك صورة أوضح، مع تذكر أن Enprive لا يستطيع رؤية حركة الإنترنت المباشرة.';

  @override
  String get learnPolicyQuickQuestion =>
      'ما الذي تثبته قراءة سياسة خصوصية تطبيق ما؟';

  @override
  String get learnPolicyQuickOption1 =>
      'أن التطبيق لا يرسل البيانات إلى أي جهة أبدًا';

  @override
  String get learnPolicyQuickOption2 =>
      'ما يقوله المطور: وليس ما يرسله التطبيق فعلًا';

  @override
  String get learnPolicyQuickOption3 => 'أن كاميرا الهاتف وميكروفونه مغلقان';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'صحيح. السياسة هي بيان عام من المطور، وليست دليلًا على ما يرسله التطبيق فعلًا عبر الإنترنت.';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      'ليس تمامًا. قراءة السياسة تخبرك فقط بما يقوله المطور: لا يمكنها إثبات نشاط الإنترنت ولا إيقاف أذونات الهاتف.';

  @override
  String get learnDiagramPolicySaysTitle => 'السياسة تقول';

  @override
  String get learnDiagramPolicySaysBody => 'وعد المطور المكتوب';

  @override
  String get learnDiagramPolicyQuoteSample => '\"قد نشارك البيانات مع شركاء…\"';

  @override
  String get learnDiagramPhoneShowsTitle => 'الهاتف يعرض';

  @override
  String get learnDiagramPhoneShowsBody => 'الأذونات المسموح بها هنا';

  @override
  String get learnDiagramUnknownTitle => 'لا يزال غير معروف';

  @override
  String get learnDiagramUnknownBody =>
      'حركة الإنترنت المباشرة التي لا يراها Enprive';

  @override
  String get learnDiagramPolicyCaption =>
      'السياسة وعد مكتوب، وليست دليلًا على السلوك';

  @override
  String get learnDiagramPolicySemantic =>
      'رسم توضيحي يقارن بين ثلاثة أجزاء من خصوصية التطبيقات. أولًا، السياسة تقول: وعد المطور المكتوب. ثانيًا، الهاتف يعرض: الأذونات المسموح بها على هذا الهاتف. ثالثًا، داخل حدود متقطعة، لا يزال غير معروف: حركة الإنترنت المباشرة التي لا يستطيع Enprive رؤيتها. سياسة الخصوصية وعد، وليست دليلًا على السلوك.';

  @override
  String get learnPermissionsFolderTitle => 'أذونات الهاتف';

  @override
  String get learnPermissionsTitle => 'شرح أذونات Android';

  @override
  String get learnPermissionsSubtitle => 'خيارات Android الأربعة وأين تراجعها';

  @override
  String get learnPermissionsIntro =>
      'الأذونات هي بوابات تتحكم في ما إذا كان بإمكان التطبيق الوصول إلى الحساسات والبيانات على هاتفك، مثل الكاميرا والميكروفون والموقع والصور وجهات الاتصال والإشعارات.';

  @override
  String get learnPermissionsStep1 =>
      'اسأل هل يتناسب الإذن مع الميزة: نادرًا ما يحتاج تطبيق اختبارات رياضيات أو قراءة إلى موقعك أو جهات اتصالك أو الكاميرا.';

  @override
  String get learnPermissionsStep2 =>
      'يوفر Android ما يصل إلى أربعة خيارات: عدم السماح، السؤال كل مرة، السماح فقط أثناء استخدام التطبيق، والسماح طوال الوقت (للموقع في الخلفية).';

  @override
  String get learnPermissionsStep3 =>
      'ابدأ بالخيار الأضيق الذي يسمح للميزة بالعمل، مثل السؤال كل مرة أو أثناء استخدام التطبيق.';

  @override
  String get learnPermissionsStep4 =>
      'افتح إعدادات Android وتفقد لوحة بيانات الخصوصية لمعرفة التطبيقات التي وصلت مؤخرًا إلى الكاميرا أو الميكروفون أو الموقع.';

  @override
  String get learnPermissionsStep5 =>
      'أوقف الأذونات في أي وقت من إعدادات التطبيق، أو أبقِ خيار إيقاف نشاط التطبيق مؤقتًا إذا لم يُستخدم مُفعّلًا ليزيل Android الأذونات القديمة تلقائيًا. الإذن المسموح يُظهر القدرة، وليس دليلًا على إرسال بيانات.';

  @override
  String get learnPermissionsQuickQuestion =>
      'طلب تطبيق لتدريب الرياضيات إذن الكاميرا ولم تعرف السبب. ما أفضل خطوة أولى؟';

  @override
  String get learnPermissionsQuickOption1 =>
      'اضغط عدم السماح وتأكد هل ما زالت تمارين الرياضيات تعمل';

  @override
  String get learnPermissionsQuickOption2 =>
      'اختر طوال الوقت حتى لا تظهر النافذة مرة أخرى';

  @override
  String get learnPermissionsQuickOption3 =>
      'افترض أن التطبيق رفع صورًا بالفعل';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      'صحيح. الضغط على عدم السماح يتيح لك التأكد مما إذا كان التطبيق يعمل دون الكاميرا، ويمكنك تغيير الأذونات في أي وقت من إعدادات Android.';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'جرّب خيارًا أضيق أولًا. اضغط عدم السماح لتجربة ما إذا كانت الميزة لا تزال تعمل، وتذكر أن الإذن المسموح يُظهر القدرة، وليس دليلًا على رفع البيانات.';

  @override
  String get learnDiagramPermLadderTitle => 'من الأضيق إلى الأوسع وصولًا';

  @override
  String get learnDiagramPermDenyTitle => 'عدم السماح';

  @override
  String get learnDiagramPermDenyDetail =>
      'محظور: لا يمكن للتطبيق استخدام هذا الحساس';

  @override
  String get learnDiagramPermAskTitle => 'السؤال كل مرة';

  @override
  String get learnDiagramPermAskDetail =>
      'وصول لمرة واحدة عند الضغط على السماح';

  @override
  String get learnDiagramPermWhileUsingTitle => 'أثناء استخدام التطبيق';

  @override
  String get learnDiagramPermWhileUsingDetail =>
      'فقط بينما التطبيق مفتوح على الشاشة';

  @override
  String get learnDiagramPermAllTimeTitle => 'طوال الوقت';

  @override
  String get learnDiagramPermAllTimeDetail => 'وصول في الخلفية حتى عند إغلاقه';

  @override
  String get learnDiagramPermFitNote =>
      'هل يناسب الميزة؟ اختبار رياضيات + كاميرا = اسأل لماذا';

  @override
  String get learnDiagramPermSemantic =>
      'سلم أذونات Android من أربع خطوات من الأضيق إلى الأوسع وصولًا. الخطوة 1، عدم السماح: محظور، لا يمكن للتطبيق استخدام هذا الحساس. الخطوة 2، السؤال كل مرة: وصول لمرة واحدة عند الضغط على السماح. الخطوة 3، أثناء استخدام التطبيق: وصول فقط بينما التطبيق مفتوح على الشاشة. الخطوة 4، طوال الوقت: وصول في الخلفية حتى عند إغلاقه، ومميز بإطار متقطع لمزيد من الانتباه. نصيحة أسفل الرسم: هل يناسب الميزة؟ تطبيق رياضيات يطلب الكاميرا سبب وجيه للسؤال عن السبب.';

  @override
  String get learnSharingFolderTitle => 'الإعلانات والأطراف الثالثة';

  @override
  String get learnSharingTitle =>
      'من يحصل أيضًا على البيانات: الإعلانات والتحليلات والأطراف الثالثة';

  @override
  String get learnSharingSubtitle =>
      'صانع التطبيق مقابل المساعدين والتحليلات وشبكات الإعلانات';

  @override
  String get learnSharingIntro =>
      'تتصل كثير من التطبيقات المجانية بشركات أخرى في الخلفية. معرفة من يتلقى المعلومات تساعد العائلات على التمييز بين تشغيل التطبيق وتتبع الأطفال عبر التطبيقات.';

  @override
  String get learnSharingStep1 =>
      'الطرف الأول يعني صانع التطبيق نفسه: مثل حفظ تقدم الواجبات أو درجات الاختبارات حتى يعمل التطبيق.';

  @override
  String get learnSharingStep2 =>
      'الشركات المساعدة هي أطراف ثالثة تؤدي مهامًا خلف الكواليس مثل التخزين السحابي أو تقارير الأعطال لإصلاح الأخطاء.';

  @override
  String get learnSharingStep3 =>
      'تقيس أدوات التحليلات كيفية استخدام الشاشات، بينما قد تستخدم شبكات الإعلانات ووسطاء البيانات معرّف الإعلانات لعرض إعلانات موجهة أو تتبع النشاط عبر التطبيقات.';

  @override
  String get learnSharingStep4 =>
      'انتبه للعبارات الواسعة مثل \'شركاء موثوقين\' أو \'لأغراض تجارية\'، وتحقق مما إذا كانت السياسة تشرح كيفية رفض الإعلانات المخصصة.';

  @override
  String get learnSharingQuickQuestion =>
      'تقول إحدى السياسات إن التطبيق يشارك المعلومات مع \'شركاء من أطراف ثالثة\'. ما أفضل سؤال تطرحه بعد ذلك؟';

  @override
  String get learnSharingQuickOption1 =>
      'الافتراض أن ذلك يعني عدم وجود إعلانات في التطبيق';

  @override
  String get learnSharingQuickOption2 =>
      'الافتراض أن كل شريك يقوم بالدور نفسه تمامًا';

  @override
  String get learnSharingQuickOption3 =>
      'التحقق مما إذا كان هؤلاء الشركاء خدمات مساعدة (مثل الاستضافة) أم شبكات إعلانات تتبع النشاط عبر التطبيقات';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'أصبت. الخدمات المساعدة تحافظ على عمل التطبيق، بينما قد تتبع شبكات الإعلانات ووسطاء البيانات النشاط عبر التطبيقات.';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      'انظر عن قرب إلى دور كل شريك. ليست كل الأطراف الثالثة متشابهة: بعضها يستضيف البيانات أو يصلح الأعطال، بينما يشغّل بعضها الآخر الإعلانات أو التتبع.';

  @override
  String get learnDiagramThirdPartyYou => 'أنت';

  @override
  String get learnDiagramThirdPartyApp => 'تطبيق التعلم';

  @override
  String get learnDiagramThirdPartyHosting => 'مساعدون وأعطال';

  @override
  String get learnDiagramThirdPartyAnalytics => 'التحليلات';

  @override
  String get learnDiagramThirdPartyAds => 'شبكات الإعلانات';

  @override
  String get learnDiagramThirdPartyFirstParty => 'طرف أول';

  @override
  String get learnDiagramThirdPartyThirdParty => 'أطراف ثالثة';

  @override
  String get learnDiagramThirdPartySemantic =>
      'مخطط تدفق يوضح أين يمكن أن تذهب بيانات تطبيق تعلم للأطفال. تتصل أنت بتطبيق التعلم، ويتصل التطبيق بخط متصل بصانع التطبيق (طرف أول) وبخطوط متقطعة بأطراف ثالثة: أدوات المساعدة والأعطال، وأدوات التحليلات، وشبكات الإعلانات المميزة لمزيد من الانتباه.';

  @override
  String get learnEvidenceFolderTitle => 'قراءة نتائج Enprive';

  @override
  String get learnEvidenceTitle => 'كيف تقرأ أدلة Enprive';

  @override
  String get learnEvidenceSubtitle => 'طبقات الأدلة والفئات والحدود الصادقة';

  @override
  String get learnEvidenceIntro =>
      'يفصل Enprive بين ما تقوله سياسة الخصوصية، وما يعرضه هاتفك، وما يبقى غير معروف، ويجمّع النتائج حسب الموضوع لا كدرجة أمان أبدًا.';

  @override
  String get learnEvidenceStep1 =>
      'تجمّع خمس فئات موضوعية كل نتيجة بالأيقونة واللون نفسهما كما في شاشة المراجعة. يشير اللون إلى الموضوع، ولا يمثل درجة أمان أبدًا.';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return 'تعني عبارة $sourceMatched أن Enprive وجد اقتباسًا مطابقًا حرفيًا في نص السياسة الذي فحصته.';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return 'تعني عبارة $deviceObserved أن هاتفك أبلغ عن إعداد إذن على هذا الجهاز: وليس دليلًا على إرسال بيانات.';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return 'تمثل عبارة $interpretation شرح Deni بلغة واضحة، بينما تشير عبارة $unverified إلى تفاصيل لم يعثر عليها Enprive. الصمت في السياسة ليس وعدًا أبدًا.';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return 'تنتهي المراجعات بواحدة من ثلاث نتائج هادئة: $reviewRecommended، أو $noConcern (وهي ليست شهادة أمان أبدًا)، أو $insufficientEvidence.';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return 'في شاشة المراجعة، ماذا تعني عبارة \'$deviceObserved\'؟';
  }

  @override
  String get learnEvidenceQuickOption1 => 'أن التطبيق معتمد كآمن للأطفال';

  @override
  String get learnEvidenceQuickOption2 =>
      'أن هاتفك يعرض إعداد هذا الإذن على هذا الجهاز: وليس دليلًا على رفع البيانات';

  @override
  String get learnEvidenceQuickOption3 => 'أن التطبيق رفع بيانات طفلك بالتأكيد';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'صحيح. تعكس هذه العلامة حالة إذن Android على هذا الجهاز؛ ولا يمكنها إثبات رفع البيانات أو منح شهادة أمان.';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      'ليس تمامًا. تعرض هذه العلامة فقط ما يبلغ عنه هاتفك حول إعداد إذن ما: لا تثبت رفع البيانات أبدًا وليست شهادة أمان أبدًا.';

  @override
  String get learnDiagramEvidencePolicyDetail =>
      'اقتباس دقيق مطابق في نص السياسة';

  @override
  String get learnDiagramEvidencePhoneDetail => 'أذونات الهاتف على هذا الجهاز';

  @override
  String get learnDiagramEvidenceDeniDetail => 'شرح بلغة واضحة من Deni';

  @override
  String get learnDiagramEvidenceUnknownDetail => 'الصمت في السياسة ليس وعدًا';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'أربع طبقات أدلة مستخدمة في شاشة المراجعة في Enprive: 1، $sourceMatched، اقتباس دقيق مطابق في سياسة الخصوصية؛ 2، $deviceObserved، أذونات الهاتف على هذا الجهاز؛ 3، $interpretation، شرح Deni بلغة واضحة؛ و4، مفصولة بخط متقطع، $unverified، لأن الصمت في السياسة ليس وعدًا.';
  }

  @override
  String get learnDiagramCategoriesTitle => 'خمس فئات موضوعية في شاشة المراجعة';

  @override
  String get learnDiagramCategoriesNote =>
      'اللون والأيقونة يحددان الموضوع، وليسا درجة أمان أبدًا.';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'خمس فئات للأدلة تظهر في شاشة المراجعة في Enprive، ولكل منها أيقونتها ولونها: $dataCollection، و$sharing، و$tracking، و$retention، و$parentalControls. اللون والأيقونة يحددان الموضوع، وليسا درجة أمان أبدًا.';
  }

  @override
  String get learnDataCollectionFolderTitle => 'البيانات التي تجمعها التطبيقات';

  @override
  String get learnDataCollectionTitle => 'ما البيانات التي تجمعها التطبيقات';

  @override
  String get learnDataCollectionSubtitle =>
      'الفرق بين ما تكتبه وما يعمل بهدوء في الخلفية';

  @override
  String get learnDataCollectionIntro1 =>
      'تجمع التطبيقات المعلومات بطريقتين. تأتي بعض البيانات مما تدخله بنفسك: اسمك أو بريدك الإلكتروني أو صورك أو تسجيلاتك الصوتية أو إجابات الواجبات. وتُجمع بيانات أخرى تلقائيًا في الخلفية، مثل عنوان IP (العنوان الذي يستخدمه هاتفك على الإنترنت) ومعرّفات الجهاز ومعرّف الإعلانات (رمز تستخدمه الإعلانات للتعرف على هاتفك) وسجلات الأعطال وأوقات فتح التطبيق.';

  @override
  String get learnDataCollectionStep1 =>
      'ما تكتبه: اسمك ومدرستك وبريدك الإلكتروني وصورك ومقاطعك الصوتية وإجابات الواجبات هي بيانات تختار تقديمها.';

  @override
  String get learnDataCollectionStep2 =>
      'ما يعمل بهدوء: يمكن للتطبيق جمع معرّف الإعلانات ومعرّفات الجهاز وعنوان IP وتقارير الأعطال وأوقات الاستخدام دون أن تضغط أي زر. الجمع الهادئ ليس سيئًا تلقائيًا: فهذه الإشارات تساعد التطبيقات على العمل بسلاسة.';

  @override
  String get learnDataCollectionStep3 =>
      'بيانات الأطفال الحساسة: يحمل الموقع وتسجيلات الميكروفون وصور الكاميرا والبيانات الحيوية مثل البصمات الصوتية (بيانات عن جسمك أو صوتك) مخاطر خصوصية أعلى للأطفال.';

  @override
  String get learnDataCollectionStep4 =>
      'ملاحظة حول Play Store: قسم أمان البيانات في Google Play هو وصف المطور نفسه. إنه تلميح وليس دليلًا، ولا يشمل البيانات التي تُعالج على جهازك فقط أو تُحفظ مؤقتًا في الذاكرة.';

  @override
  String get learnDataCollectionQuizQuestion =>
      'أي مما يلي مثال على بيانات تعمل بهدوء في الخلفية؟';

  @override
  String get learnDataCollectionQuizChoiceA => 'صورة ترفعها لملفك الشخصي';

  @override
  String get learnDataCollectionQuizChoiceB => 'معرّف الإعلانات ومعرّفات جهازك';

  @override
  String get learnDataCollectionQuizChoiceC => 'إجابة واجب تكتبها داخل التطبيق';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      'صحيح: تُجمع معرّفات الإعلانات ومعرّفات الجهاز تلقائيًا دون أن تكتبها.';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      'ليس تمامًا: تلك بيانات تدخلها بنفسك. أما البيانات التي تعمل بهدوء فتشمل معرّفات الإعلانات ومعرّفات الجهاز وعنوان IP وأوقات الاستخدام.';

  @override
  String get learnDataCollectionDiagramYouTypeTitle => 'ما تكتبه أو تقدّمه';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => 'الاسم، البريد، المدرسة';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => 'الصور والفيديوهات';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => 'التسجيلات الصوتية';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => 'إجابات الواجبات';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle => 'ما يعمل بهدوء';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => 'معرّف الإعلانات';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 => 'معرّفات الجهاز';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'عنوان IP';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 =>
      'سجلات الأعطال وأوقات الاستخدام';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      'العمل بهدوء لا يعني أنه سيئ: هذه الإشارات تساعد التطبيقات على العمل بسلاسة.';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      'رسم توضيحي مقسّم يعرض فئتين لجمع البيانات. البطاقة العلوية بعنوان \"ما تكتبه أو تقدّمه\" تسرد أربع شرائح: الاسم البريد المدرسة، الصور والفيديوهات، التسجيلات الصوتية، إجابات الواجبات. والبطاقة السفلية بعنوان \"ما يعمل بهدوء\" تسرد أربع شرائح: معرّف الإعلانات، معرّفات الجهاز، عنوان IP، سجلات الأعطال وأوقات الاستخدام. وتقول ملاحظة صغيرة \"العمل بهدوء لا يعني أنه سيئ: هذه الإشارات تساعد التطبيقات على العمل بسلاسة.\" ويجلس Deni أسفلها بوضعية تفكير.';

  @override
  String get learnDataCollectionCheckBridge =>
      'افحص تطبيقًا على هذا الهاتف لمعرفة البيانات التي يجمعها.';

  @override
  String get learnDataCollectionHonestyNote =>
      'يشرح هذا الدرس أنواع البيانات الشائعة. ولا يثبت ما يجمعه أو يرسله أي تطبيق بعينه. وحده نص السياسة الدقيق وإعدادات أذونات هاتفك يمكنهما إظهار ذلك.';

  @override
  String get learnRetentionFolderTitle => 'الاحتفاظ والحذف';

  @override
  String get learnRetentionTitle => 'الاحتفاظ بالبيانات وحذفها';

  @override
  String get learnRetentionSubtitle =>
      'إزالة تثبيت التطبيق لا تمحو البيانات الموجودة بالفعل على خوادم الشركة';

  @override
  String get learnRetentionIntro1 =>
      'عندما تحذف تطبيقًا من هاتفك، تُزال ملفات التطبيق من جهازك، لكن أي بيانات رُفعت بالفعل إلى خوادم الشركة تبقى هناك. ينبغي أن توضح سياسات الخصوصية مدة الاحتفاظ ببياناتك، وكيفية طلب الحذف، وما يحدث للنسخ الاحتياطية، لكن سياسات كثيرة تستخدم عبارات غامضة مثل \"للمدة اللازمة بشكل معقول\".';

  @override
  String get learnRetentionStep1 =>
      'جمع البيانات: أثناء استخدامك التطبيق، تُرسل معلوماتك وتُخزّن على خوادم الشركة.';

  @override
  String get learnRetentionStep2 =>
      'التخزين على الخوادم: يمكن أن تبقى بياناتك على أنظمة الشركة حتى بعد توقفك عن استخدام التطبيق.';

  @override
  String get learnRetentionStep3 =>
      'إزالة التثبيت لا تحذف بيانات الخادم: حذف التطبيق من هاتفك يزيل الملفات المحلية فقط، وليس النسخ الموجودة على خوادم الشركة.';

  @override
  String get learnRetentionStep4 =>
      'طلب الحذف: يمكنك أن تطلب من الشركة حذف حسابك وبياناتك؛ وينبغي أن توضح السياسات المدة التي يستغرقها ذلك.';

  @override
  String get learnRetentionStep5 =>
      'مدة احتفاظ غير معروفة: السياسات التي تقول \"للمدة اللازمة\" أو \"لأغراض تجارية\" تترك موعد الحذف الفعلي غير واضح.';

  @override
  String get learnRetentionQuizQuestion =>
      'ماذا يحدث لبياناتك على خوادم الشركة عندما تزيل تثبيت تطبيق من هاتفك؟';

  @override
  String get learnRetentionQuizChoiceA => 'تُحذف تلقائيًا';

  @override
  String get learnRetentionQuizChoiceB =>
      'قد تبقى على الخوادم: إزالة تثبيت التطبيق لا تحذفها';

  @override
  String get learnRetentionQuizChoiceC => 'تُجهَّل هويتها فورًا';

  @override
  String get learnRetentionQuizFeedbackRight =>
      'صحيح: إزالة التثبيت تزيل التطبيق من هاتفك فقط. وقد تبقى البيانات على خوادم الشركة حتى تطلب حذفها.';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      'ليس تمامًا: إزالة تثبيت التطبيق لا تحذف البيانات المرفوعة بالفعل إلى خوادم الشركة. تحتاج إلى طلب حذف الحساب.';

  @override
  String get learnRetentionDiagramCollected => 'تُجمع البيانات أثناء الاستخدام';

  @override
  String get learnRetentionDiagramStored => 'تُخزّن على خوادم الشركة';

  @override
  String get learnRetentionDiagramUninstall =>
      'تزيل تثبيت التطبيق: تُحذف ملفات الهاتف وتبقى بيانات الخادم';

  @override
  String get learnRetentionDiagramDeleteRequest => 'تطلب حذف الحساب';

  @override
  String get learnRetentionDiagramUnknownTail =>
      'مدة احتفاظ غير معروفة: السياسة تقول \"للمدة اللازمة\"';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      'خط زمني من خمس خطوات يوضح دورة حياة البيانات. الخطوة 1: تُجمع البيانات أثناء الاستخدام، مع أيقونة قاعدة بيانات. الخطوة 2: تُخزّن على خوادم الشركة، مع أيقونة خادم. الخطوة 3: تزيل تثبيت التطبيق: تُحذف ملفات الهاتف وتبقى بيانات الخادم، مع أيقونة هاتف ذكي. الخطوة 4: تطلب حذف الحساب، مع أيقونة سلة مهملات. الخطوة 5: مدة احتفاظ غير معروفة: السياسة تقول \"للمدة اللازمة\"، بسهم متقطع وأيقونة علامة استفهام. ويقف Deni أسفل المخطط حاملًا إيصالًا.';

  @override
  String get learnRetentionCheckBridge =>
      'افحص تطبيقًا على هذا الهاتف لمعرفة ما تقوله سياسته حول الاحتفاظ بالبيانات.';

  @override
  String get learnRetentionHonestyNote =>
      'يصف هذا الدرس أنماط الاحتفاظ الشائعة. ولا يثبت ما تفعله أي شركة بعينها ببياناتك. وحده نص السياسة الدقيق وطلب الحذف يمكنهما إظهار ذلك.';

  @override
  String get learnUnclearPoliciesFolderTitle => 'سياسات غير واضحة';

  @override
  String get learnUnclearPoliciesTitle =>
      'اكتشاف السياسات الغامضة والأزرار الخادعة';

  @override
  String get learnUnclearPoliciesSubtitle =>
      'كيف تميّز الصياغة الغامضة وشاشات الموافقة الضاغطة';

  @override
  String get learnUnclearPoliciesIntro1 =>
      'تستخدم بعض سياسات الخصوصية كلمات فضفاضة تصعّب معرفة ما يحدث لبياناتك فعلًا. كما قد تستخدم شاشات الموافقة حيل تصميم، مثل زر \"قبول الكل\" كبير وساطع بجانب رابط صغير جدًا لـ\"إدارة الإعدادات\"، لدفعك إلى الموافقة دون قراءة.';

  @override
  String get learnUnclearPoliciesStep1 =>
      'علامات ضبابية السياسة: انتبه للعبارات المفتوحة مثل \"قد نشارك مع شركاء موثوقين\" أو \"لأغراض تجارية\" أو \"نحتفظ حسب الحاجة\": فهي تترك التفاصيل الحقيقية غير محددة.';

  @override
  String get learnUnclearPoliciesStep2 =>
      'الصمت ليس وعدًا: إذا لم تذكر السياسة الميكروفون أو الإعلانات أو الموقع أبدًا، فذلك لا يضمن أن التطبيق يتجنبها.';

  @override
  String get learnUnclearPoliciesStep3 =>
      'أساسيات مفقودة: تتضمن السياسة الواضحة تاريخ سريان محددًا وبريدًا للتواصل ومستندًا واحدًا متكاملًا: وليس ملحقًا مخفيًا للأطفال.';

  @override
  String get learnUnclearPoliciesStep4 =>
      'الموافقة تحت الضغط (الأنماط المضللة): أزرار \"قبول الكل\" العملاقة ومربعات التسويق المحددة مسبقًا والطلبات المتكررة المزعجة ومسارات الإلغاء المخفية صُممت للتأثير على اختيارك.';

  @override
  String get learnUnclearPoliciesStep5 =>
      'اختيار متوازن: تعرض الشاشة العادلة زرّي \"السماح\" و\"عدم السماح\" بالتساوي، مع بقاء الخيارات الإضافية غير مفعّلة افتراضيًا.';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      'أي عبارة في سياسة الخصوصية تُعد إشارة \"ضبابية\" تدل على نقص التفاصيل؟';

  @override
  String get learnUnclearPoliciesQuizChoiceA =>
      'لا نبيع معلوماتك الشخصية لأطراف ثالثة';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      'قد نشارك البيانات مع شركاء موثوقين لأغراض تجارية';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'يمكنك طلب الحذف عبر مراسلة privacy@example.com';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      'صحيح: عبارة \"قد نشارك مع شركاء موثوقين لأغراض تجارية\" غامضة ولا توضح من هم الشركاء ولا ما البيانات التي تُشارك.';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      'ليس تمامًا: تلك العبارة محددة وواضحة. أما العبارات الضبابية فتستخدم صياغة مفتوحة مثل \"قد نشارك\" أو \"حسب الحاجة\" دون تفاصيل.';

  @override
  String get learnUnclearPoliciesDiagramClearTitle => 'جملة واضحة في السياسة';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      'نجمع اسمك وبريدك الإلكتروني لإنشاء حسابك. ولا نشارك ذلك مع المعلنين.';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle => 'جملة ضبابية في السياسة';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      'قد نشارك معلوماتك مع شركاء موثوقين لأغراض تجارية حسب الحاجة.';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle => 'كيف تكتشف الغموض';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      'ابحث عن \"قد\" أو \"يمكن\" أو \"حسب الحاجة\": فهي تترك الباب مفتوحًا.';

  @override
  String get learnUnclearPoliciesDiagramTip2 =>
      'تحقق هل تذكر السياسة أسماء الشركات المحددة التي تصلها البيانات.';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      'الصمت حول موضوع مثل الإعلانات أو الميكروفون ليس وعدًا بأن التطبيق يتجنبه.';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote =>
      'الصمت في السياسة ليس وعدًا.';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      'مقارنة جنبًا إلى جنب بين جملة واضحة في السياسة وأخرى ضبابية. البطاقة اليسرى بعنوان \"واضحة\" تعرض: \"نجمع اسمك وبريدك الإلكتروني لإنشاء حسابك. ولا نشارك ذلك مع المعلنين.\" والبطاقة اليمنى بعنوان \"ضبابية\" تعرض: \"قد نشارك معلوماتك مع شركاء موثوقين لأغراض تجارية حسب الحاجة.\" وأسفلها بطاقة نصائح بعنوان \"كيف تكتشف الغموض\" تسرد ثلاث نصائح: ابحث عن \"قد\" أو \"يمكن\" أو \"حسب الحاجة\": فهي تترك الباب مفتوحًا. تحقق هل تذكر السياسة أسماء الشركات المحددة التي تصلها البيانات. الصمت حول موضوع مثل الإعلانات أو الميكروفون ليس وعدًا بأن التطبيق يتجنبه. وتقرأ ملاحظة على البطاقة الضبابية \"الصمت في السياسة ليس وعدًا.\" ويطل Deni من فوق البطاقات.';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      'افحص تطبيقًا على هذا الهاتف للتحقق من شاشة الموافقة ووضوح سياسته.';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      'يصف هذا الدرس أنماطًا غامضة شائعة. ولا يثبت أن أي تطبيق بعينه يستخدم أنماطًا مضللة أو يخفي ممارسات البيانات. وحدها قراءة السياسة الدقيقة ورؤية شاشة الموافقة الفعلية يمكنهما إظهار ذلك.';

  @override
  String get learnSafeSharingFolderTitle => 'عادات المشاركة الآمنة';

  @override
  String get learnSafeSharingTitle => 'عادات المشاركة الواعية للأطفال';

  @override
  String get learnSafeSharingSubtitle =>
      'توقّف، فكّر، شارك بحذر: خطوات مناسبة لكل عمر عند النشر على الإنترنت';

  @override
  String get learnSafeSharingIntro1 =>
      'قبل نشر صورة أو فيديو أو اسمك أو موقعك، توقّف قليلًا واتبع الخطوات الثلاث: توقّف، فكّر، شارك بحذر. هذا الدرس مخصص للقراءة مع بالغ موثوق. الأطفال الأصغر سنًا (5-7 سنوات) يسألون قبل الضغط. والأكبر سنًا (8-11 سنة) يستخدمون أسماء مستعارة وكلمات مرور قوية. والمراهقون (12-17 سنة) يديرون بصمتهم الرقمية (الأثر الذي تتركه منشوراتك) والتحقق بخطوتين (تحقق إضافي مثل رمز عند تسجيل الدخول).';

  @override
  String get learnSafeSharingStep1 =>
      'توقّف: تمهّل قبل نشر صورة أو فيديو أو اسمك أو مدرستك أو موقعك. اسأل بالغًا موثوقًا إذا لم تكن متأكدًا.';

  @override
  String get learnSafeSharingStep2 =>
      'فكّر: هل يكشف هذا مدرستي أو منزلي أو مكاني الآن؟ هل استأذنت أصدقائي قبل مشاركة صورهم أو الإشارة إليهم؟';

  @override
  String get learnSafeSharingStep3 =>
      'شارك بحذر: شارك فقط مع أشخاص تثق بهم. حافظ على خصوصية تفاصيلك الشخصية مثل اسمك الكامل وتاريخ ميلادك وعنوانك ورقم هاتفك.';

  @override
  String get learnSafeSharingStep4 =>
      'اختبار المقصف المدرسي: هل سأشعر بالارتياح لو شاهد الجميع في المدرسة (أو كل صفي) هذه الصورة أو الرسالة؟ حتى المنشورات التي تختفي يمكن التقاط لقطة شاشة لها لتبقى على الإنترنت دائمًا.';

  @override
  String get learnSafeSharingStep5 =>
      'الأعمار 5-7: اسأل بالغًا موثوقًا قبل كتابة اسمك أو الضغط على النوافذ المنبثقة. الأعمار 8-11: استخدم اسمًا مستعارًا (لا الاسم الحقيقي ولا تاريخ الميلاد ولا المدرسة)، وكلمات مرور قوية، ولا تشارك رموز SMS أو OTP أبدًا (رموز لمرة واحدة تُرسل برسالة نصية، لا تشاركها أبدًا). الأعمار 12-17: راجع إعدادات الخصوصية، وفعّل التحقق بخطوتين، واعرف كيف تبلغ عن المشكلات.';

  @override
  String get learnSafeSharingQuizQuestion =>
      'ما هو \"اختبار المقصف المدرسي\" عند المشاركة على الإنترنت؟';

  @override
  String get learnSafeSharingQuizChoiceA =>
      'مشاركة الأشياء التي تأكلها في المقصف فقط';

  @override
  String get learnSafeSharingQuizChoiceB =>
      'أن تسأل نفسك: هل سأرتاح لو رأى الجميع في المدرسة هذه الصورة أو الرسالة؟';

  @override
  String get learnSafeSharingQuizChoiceC => 'المشاركة خلال استراحة الغداء فقط';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      'صحيح: يعني اختبار المقصف المدرسي أن تسأل نفسك هل ستشعر بالارتياح لو رأى الجميع ما تنشره.';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      'ليس تمامًا: اختبار المقصف المدرسي هو فحص ذهني بسيط: هل ستشعر بالارتياح لو عرض شخص ما منشورك على كل من في المقصف؟';

  @override
  String get learnSafeSharingDiagramStop => 'توقّف: تمهّل قبل أن تنشر';

  @override
  String get learnSafeSharingDiagramThink =>
      'فكّر: هل يكشف هذا مكاني أو من معي؟';

  @override
  String get learnSafeSharingDiagramConnect =>
      'شارك بحذر: مع من تثق بهم فقط، واسأل بالغًا عند الشك';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      'اختبار المقصف المدرسي: هل سأرتاح لو رأى الجميع في المدرسة هذا؟ حتى المنشورات التي تختفي يمكن التقاط لقطة شاشة لها لتبقى على الإنترنت دائمًا.';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      'رسم توضيحي من أربعة أجزاء يعلّم عادات المشاركة الواعية. الخطوة 1: توقّف: تمهّل قبل أن تنشر، مع أيقونة يد. الخطوة 2: فكّر: هل يكشف هذا مكاني أو من معي؟ مع أيقونة دماغ. الخطوة 3: شارك بحذر: مع من تثق بهم فقط، واسأل بالغًا عند الشك، مع أيقونة أشخاص. الخطوة 4: بطاقة اختبار المقصف المدرسي تسأل \"هل سأرتاح لو رأى الجميع في المدرسة هذا؟ حتى المنشورات التي تختفي يمكن التقاط لقطة شاشة لها لتبقى على الإنترنت دائمًا.\" ويقف Deni بجانب البطاقة رافعًا يده.';

  @override
  String get learnSafeSharingCheckBridge =>
      'افحص تطبيقًا مع أحد والديك لمعرفة كيف يتعامل مع المشاركة.';

  @override
  String get learnSafeSharingHonestyNote =>
      'يشارك هذا الدرس عادات عامة للمشاركة الواعية. ولا يضمن أن يحمي أي تطبيق ما تشاركه. اقرأ دائمًا سياسة التطبيق واستخدم إعدادات الخصوصية في هاتفك.';

  @override
  String get translationDraftNotice =>
      'بعض الترجمات مسودات مُنشأة بالذكاء الاصطناعي وقد تحتوي على أخطاء. يعمل متحدثون أصليون على مراجعتها.';
}
