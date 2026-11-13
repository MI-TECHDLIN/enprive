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
      'لتحليل هذا النص في السحابة، سيرسل Enprive النص الظاهر أدناه فقط إلى Firebase AI Logic. لن يتم إرسال قائمة تطبيقاتك المثبتة أو أذونات Android أبدًا.';

  @override
  String get permissionLimitationNotice =>
      'يُظهر نظام Android حالة الإذن هذه على هذا الهاتف. ولا يثبت ما إذا كان التطبيق قد وصل إلى البيانات أو نقلها فعليًا.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navReceipts => 'الإيصالات';

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
}
