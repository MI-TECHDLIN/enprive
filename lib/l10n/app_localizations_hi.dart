// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => 'साक्ष्य-आधारित ऐप गोपनीयता समीक्षा';

  @override
  String get homePrivacySubtitle => 'आपकी समीक्षाएँ केवल इसी फ़ोन पर रहती हैं।';

  @override
  String get stateNoConcern => 'कोई चिंताजनक बात नहीं मिली';

  @override
  String get stateNoConcernSubtitle =>
      'समीक्षित साक्ष्यों में कोई चिंताजनक बात नहीं मिली। यह कोई सुरक्षा प्रमाणपत्र नहीं है।';

  @override
  String get stateReviewRecommended => 'समीक्षा की अनुशंसा की जाती है';

  @override
  String get stateReviewRecommendedSubtitle =>
      'नीति के एक या अधिक हिस्सों या फ़ोन की अनुमतियों पर करीब से ध्यान देने की ज़रूरत है।';

  @override
  String get stateInsufficientEvidence => 'अपर्याप्त साक्ष्य';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'यह जाँचने से पहले कि यह ऐप क्या करता है, हमें गोपनीयता नीति का और टेक्स्ट चाहिए।';

  @override
  String get chipOnDevice => 'इस डिवाइस पर';

  @override
  String get chipInCloud => 'क्लाउड में';

  @override
  String get chipLocationUnavailable => 'स्रोत उपलब्ध नहीं';

  @override
  String get chipOfflineDeterministic => 'इस फ़ोन पर ऑफ़लाइन जाँचा गया';

  @override
  String get chipUnknown => 'स्रोत अज्ञात';

  @override
  String get statusSourceMatched => 'नीति में मिला';

  @override
  String get statusDeviceObserved => 'इस फ़ोन पर दिखा';

  @override
  String get statusInterpretation => 'Deni की व्याख्या';

  @override
  String get statusUnverified => 'नीति में नहीं मिला';

  @override
  String get statusStale => 'पुरानी जाँच';

  @override
  String get btnCheckApp => 'ऐप जांचें';

  @override
  String get btnPasteTerms => 'शर्तें या लिंक पेस्ट करें';

  @override
  String get btnWhyThisFinding => 'यह निष्कर्ष क्यों?';

  @override
  String get btnSaveToReceipts => 'रसीदों में सहेजें';

  @override
  String get btnDiscard => 'हटाएँ';

  @override
  String get btnAskDeni => 'Deni से पूछें';

  @override
  String get btnUseCloud => 'इस जांच के लिए क्लाउड चुनें';

  @override
  String get btnReviewManually => 'स्वयं समीक्षा करें';

  @override
  String get btnGetStarted => 'शुरू करें';

  @override
  String get btnContinue => 'आगे बढ़ें';

  @override
  String get deniIntro =>
      'नमस्ते, मैं Deni हूँ। मैं आपको यह समझने में मदद कर सकता हूँ कि गोपनीयता नीति क्या कहती है, साक्ष्य दिखा सकता हूँ, और वह बता सकता हूँ जिसे Enprive सत्यापित नहीं कर सका।';

  @override
  String get cloudConsentDisclosure =>
      'इसे क्लाउड में जाँचने के लिए, Enprive केवल इस एक अनुरोध के लिए ऊपर दिखाया गया टेक्स्ट (व्यक्तिगत विवरण छिपाकर) भेजेगा। आपके ऐप्स और फ़ोन की अनुमतियाँ कभी नहीं भेजी जाएँगी।';

  @override
  String get permissionLimitationNotice =>
      'आपका फ़ोन दिखाता है कि यह अनुमति दी गई है या नहीं। यह साबित नहीं करता कि ऐप ने वास्तव में डेटा पढ़ा या भेजा।';

  @override
  String get navHome => 'होम';

  @override
  String get navCheck => 'जाँचें';

  @override
  String get navReceipts => 'रसीदें';

  @override
  String get navLearn => 'सीखें';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get languageTitle => 'भाषा';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get languageSubtitle =>
      'ऐप इंटरफ़ेस, व्याख्या और वॉइस रीड-अलाउड पर लागू होती है';

  @override
  String get homeHeroHeadline =>
      'बच्चों के उपयोग वाले ऐप्स पर\nअधिक स्पष्ट नज़र';

  @override
  String get trySampleCheck => 'एक सैंपल ऐप जांच आज़माएँ';

  @override
  String get eduTrackSubtitle => 'होमवर्क और उपस्थिति';

  @override
  String get eduTrackValue => '3 अनुरोध';

  @override
  String get eduTrackTrend => 'समीक्षा';

  @override
  String get calmMathSubtitle => 'ऑफ़लाइन गणित अभ्यास';

  @override
  String get calmMathValue => '0 संवेदनशील';

  @override
  String get calmMathTrend => 'न्यूनतम';

  @override
  String get whatWeCheckTitle => 'हम क्या जांचते हैं';

  @override
  String get checkQuoteTitle => 'नीति के सटीक उद्धरण';

  @override
  String get checkQuoteDesc =>
      'सटीक उद्धरणों के साथ डेटा साझाकरण, वॉइस रिकॉर्डिंग और डेटा रखने की अवधि को उजागर करता है।';

  @override
  String get checkPermissionTitle => 'फ़ोन अनुमति असंगतियाँ';

  @override
  String get checkPermissionDesc =>
      'कैमरा, माइक और लोकेशन एक्सेस की तुलना नीति में किए गए दावों से करता है।';

  @override
  String get checkSelectTitle => 'कहीं भी टेक्स्ट चुनें';

  @override
  String get checkSelectDesc =>
      'किसी भी ऐप में शर्तें चुनें और Android मेनू से Enprive Check पर टैप करें।';

  @override
  String get recentlyReviewed => 'हाल ही में समीक्षित';

  @override
  String verifiedClausesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिलते उद्धरण',
      one: '1 मिलता उद्धरण',
    );
    return '$_temp0';
  }

  @override
  String get trySampleText => 'सैंपल टेक्स्ट आज़माएँ';

  @override
  String get modePasteText => 'टेक्स्ट पेस्ट करें';

  @override
  String get modePolicyLink => 'नीति लिंक';

  @override
  String get hintAppName => 'ऐप का नाम';

  @override
  String get defaultSubjectTitle => 'गोपनीयता नीति';

  @override
  String get selectedExcerptTitle => 'चयनित नीति अंश';

  @override
  String get hintPastePolicy => 'गोपनीयता नीति का टेक्स्ट यहाँ पेस्ट करें…';

  @override
  String get btnReviewOnPhone => 'इसी फ़ोन पर समीक्षा करें';

  @override
  String get onboardingIntroHeadline => 'नमस्ते, मैं Deni हूँ। 👋';

  @override
  String get onboardingIntroLead => 'आइए ऐप गोपनीयता को समझना आसान बनाएँ।';

  @override
  String get onboardingIntroBody =>
      'मैं आपको यह जानने में मदद करूँगा कि किसी ऐप की गोपनीयता नीति वास्तव में क्या कहती है, महत्वपूर्ण अंशों को उजागर करूँगा, और यह समझाऊँगा कि आपका डिवाइस क्या रिपोर्ट करता है।\n\nकोई अनुमान नहीं। कोई झूठे वादे नहीं। सूचित निर्णय लेने में मदद के लिए बस स्पष्ट व्याख्या और साक्ष्य।';

  @override
  String get onboardingIntroFooter =>
      'जानिए कि आप किस बात की सहमति दे रहे हैं।';

  @override
  String get splashQuote => 'जानिए कि आप किस बात की सहमति दे रहे हैं';

  @override
  String get onboardingStep1Question => 'मैं गोपनीयता शर्तों को\nकैसे समझाऊँ?';

  @override
  String get depthQuickMultiline => 'त्वरित व\nसरल';

  @override
  String get depthBalancedMultiline => 'संतुलित\nदृश्य';

  @override
  String get depthFullMultiline => 'पूर्ण\nविवरण';

  @override
  String get onboardingReadinessTitle => 'इस फ़ोन पर\nडिफ़ॉल्ट रूप से निजी';

  @override
  String get onboardingReadinessSubtitle =>
      'माता-पिता और शिक्षकों के लिए डिज़ाइन किया गया ताकि डिवाइस डेटा साझा किए बिना ऐप्स की जांच हो सके।';

  @override
  String get readinessRow1Title => 'पहले यहीं जांच';

  @override
  String get readinessRow1Desc =>
      'किसी भी अन्य कदम से पहले नीतियाँ आपके फ़ोन पर पढ़ी जाती हैं।';

  @override
  String get readinessRow2Title => 'आपके ऐप्स आपके पास रहते हैं';

  @override
  String get readinessRow2Desc =>
      'इस फ़ोन के ऐप्स और उनकी अनुमतियाँ कभी बाहर नहीं भेजी जातीं।';

  @override
  String get readinessRow3Title => 'व्यक्तिगत विवरण छिपे हुए';

  @override
  String get readinessRow3Desc =>
      'यदि आप क्लाउड सहायता चुनते हैं, तो कुछ भी भेजने से पहले नाम, ईमेल और फ़ोन नंबर छिपा दिए जाते हैं।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get privateAnalysisTitle => 'इस फ़ोन पर निजी विश्लेषण';

  @override
  String get onDeviceReadyMsg => 'ऑन-डिवाइस AI सक्रिय और तैयार है।';

  @override
  String get localScannerProtectedMsg =>
      'इस फ़ोन पर ऑफ़लाइन नीतियाँ जाँचने के लिए तैयार।';

  @override
  String get statusChecking => 'जांच हो रही है…';

  @override
  String get btnCheckReadiness => 'तैयारी जांचें';

  @override
  String get howShouldDeniExplain => 'Deni को बातें कैसे समझानी चाहिए?';

  @override
  String get depthQuick => 'संक्षिप्त';

  @override
  String get depthBalanced => 'संतुलित';

  @override
  String get depthFull => 'विस्तृत';

  @override
  String get preferencesSection => 'प्राथमिकताएँ';

  @override
  String get meetDeniGuide => 'Deni से मिलें और सेटअप गाइड';

  @override
  String clearSavedReceiptsCount(int count) {
    return 'सहेजी गई रसीदें हटाएँ ($count)';
  }

  @override
  String get btnClear => 'साफ़ करें';

  @override
  String get confirmClearReceiptsTitle => 'सहेजी गई रसीदें हटाएँ?';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'यह आपके फ़ोन से $count सहेजी गई समीक्षाएँ हटा देगा।',
      one: 'यह आपके फ़ोन से 1 सहेजी गई समीक्षा हटा देगा।',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'रद्द करें';

  @override
  String get receiptsTitle => 'रसीदें';

  @override
  String get tooltipSearch => 'खोजें';

  @override
  String get hintSearchReceipts => 'सहेजी गई समीक्षाएँ खोजें...';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterReview => 'समीक्षा';

  @override
  String get filterNoConcern => 'कोई चिंता नहीं';

  @override
  String get emptyFilteredTitle => 'कोई मिलती-जुलती रसीद नहीं';

  @override
  String get emptyReceiptsTitle => 'अभी कोई रसीद सहेजी नहीं गई';

  @override
  String get emptyFilteredBody => 'कृपया ऊपर कोई अन्य फ़िल्टर चुनें।';

  @override
  String get emptyReceiptsBody =>
      'अपने फ़ोन पर निजी प्रति रखने के लिए किसी भी ऐप समीक्षा को बुकमार्क करें।';

  @override
  String get btnStartReview => 'समीक्षा शुरू करें';

  @override
  String get btnOpenReceipt => 'रसीद खोलें';

  @override
  String get btnDelete => 'हटाएँ';

  @override
  String get checkingPhoneReadiness =>
      'इस फ़ोन पर निजी विश्लेषण की तैयारी जांची जा रही है…';

  @override
  String get geminiNanoReadyMsg =>
      'इस फ़ोन पर ऑन-डिवाइस AI तैयार है। समीक्षाएँ पूरी तरह आपके डिवाइस पर रहती हैं।';

  @override
  String get modelDownloadingMsg =>
      'पृष्ठभूमि में निजी ऑन-डिवाइस मॉडल डाउनलोड हो रहा है।';

  @override
  String get modelDownloadableMsg =>
      'Wi-Fi पर ऑन-डिवाइस मॉडल डाउनलोड किया जा सकता है।';

  @override
  String get localScannerDefaultMsg =>
      'यह फ़ोन डिफ़ॉल्ट रूप से आपके डिवाइस पर ऑफ़लाइन नीतियाँ जाँचता है।';

  @override
  String get preparingPrivateAnalysis => 'निजी विश्लेषण तैयार किया जा रहा है…';

  @override
  String get onDeviceAiReadyTitle => 'ऑन-डिवाइस AI तैयार';

  @override
  String get localScannerActiveTitle => 'ऑफ़लाइन जाँच तैयार';

  @override
  String get privateAnalysisSheetSubtitle =>
      'आपके इंस्टॉल किए गए ऐप्स और अनुमति जांच कभी फ़ोन से बाहर नहीं जाते।';

  @override
  String get btnDone => 'हो गया';

  @override
  String get btnCheckAgain => 'फिर से जांचें';

  @override
  String get reviewingOnPhone => 'इसी फ़ोन पर समीक्षा जारी…';

  @override
  String get readingClausesInitial =>
      'इस फ़ोन पर नीति का टेक्स्ट पढ़ा जा रहा है…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चरण',
      one: '1 चरण',
    );
    return '$_temp0';
  }

  @override
  String get thoughtSignaturePrefix => 'जाँच ID';

  @override
  String get viewStreamedThoughts => 'Enprive ने इसे कैसे जाँचा';

  @override
  String get hideStreamedThoughts => 'Enprive की जाँच प्रक्रिया छिपाएँ';

  @override
  String get analysisTraceDefaultTitle => 'इस समीक्षा की जांच कैसे हुई';

  @override
  String get savedToLocalReceiptsSnack => 'आपकी स्थानीय रसीदों में सहेजा गया।';

  @override
  String get snapshotSheetTitle => 'समीक्षित नीति का टेक्स्ट';

  @override
  String get snapshotSourcePrefix => 'स्रोत';

  @override
  String get snapshotReviewedPrefix => 'समीक्षित';

  @override
  String get snapshotDigestPrefix => 'दस्तावेज़ फ़िंगरप्रिंट';

  @override
  String get statFindings => 'निष्कर्ष';

  @override
  String get statVerified => 'सत्यापित';

  @override
  String get statOsGranted => 'फ़ोन पर अनुमत';

  @override
  String get statUnverified => 'नहीं मिला';

  @override
  String get keyFindingsTitle => 'मुख्य निष्कर्ष';

  @override
  String get reviewedExcerptTitle => 'समीक्षित अंश';

  @override
  String get permissionsOnPhoneTitle => 'इस फ़ोन पर अनुमतियाँ';

  @override
  String get viewReviewedSnapshot => 'समीक्षित नीति का टेक्स्ट देखें';

  @override
  String get btnSavedToReceipts => 'रसीदों में सहेजा गया';

  @override
  String get observedOnPhoneLabel => 'इस फ़ोन पर दिखा';

  @override
  String get quoteVerifiedLabel => 'नीति से सटीक उद्धरण';

  @override
  String get unverifiedClaimLabel => 'नीति में नहीं मिला';

  @override
  String get categoryDataCollection => 'डेटा संग्रहण';

  @override
  String get categorySharing => 'तृतीय-पक्ष साझाकरण';

  @override
  String get categoryTracking => 'स्थान और ट्रैकिंग';

  @override
  String get categoryRetention => 'संग्रहण और वॉइस';

  @override
  String get categoryParentalControls => 'अभिभावक नियंत्रण';

  @override
  String get labelInPlainLanguage => 'सरल भाषा में';

  @override
  String get labelOnThisPhone => 'इस फ़ोन पर';

  @override
  String get labelWhatRemainsUnknown => 'हम अभी भी क्या नहीं जानते';

  @override
  String get presetQuestionMeaning => 'मेरे बच्चे के लिए इसका क्या अर्थ है?';

  @override
  String get presetQuestionOptOut => 'क्या हम इसे बंद या अस्वीकार कर सकते हैं?';

  @override
  String get presetQuestionUnknown => 'यहाँ अभी भी क्या स्पष्ट नहीं है?';

  @override
  String get readingCitedClause => 'नीति का उद्धरण पढ़ा जा रहा है…';

  @override
  String get deniAnswerTitle => 'Deni का उत्तर';

  @override
  String get stepsAndReasoning => 'Deni ने इसे कैसे जाँचा';

  @override
  String get chooseReviewModeTitle => 'इस टेक्स्ट की समीक्षा का तरीका चुनें';

  @override
  String get cloudNeverSendsAppsNote =>
      'इंस्टॉल किए गए ऐप्स और फ़ोन अनुमतियाँ कभी नहीं भेजी जातीं।';

  @override
  String get tooltipClose => 'बंद करें';

  @override
  String get checkAppSheetSubtitle =>
      'आपके फ़ोन पर स्थानीय रूप से जांचा जाता है। ऐप सूची कभी अपलोड नहीं होती।';

  @override
  String get trySampleKidsApp => 'बच्चों के सैंपल ऐप आज़माएँ';

  @override
  String get sampleEduTrackSubtitle => 'लोकेशन, माइक और कैमरा';

  @override
  String get sampleCalmMathSubtitle => 'ऑफ़लाइन गणित अभ्यास';

  @override
  String get appsOnThisPhone => 'इस फ़ोन पर मौजूद ऐप्स';

  @override
  String get hintSearchApps => 'ऐप्स खोजें…';

  @override
  String get noMatchingApps => 'इस फ़ोन पर कोई मेल खाने वाला ऐप नहीं मिला।';

  @override
  String get sampleSyntheticBadge => 'सैंपल ऐप';

  @override
  String get permissionInspectionTitle => 'फ़ोन की अनुमतियाँ जाँची गईं';

  @override
  String get addAppPrivacyPolicyBtn => 'इस ऐप की गोपनीयता नीति जोड़ें';

  @override
  String get snapshotDigestLabel => 'दस्तावेज़ फ़िंगरप्रिंट';

  @override
  String get snapshotDigestExplanation =>
      'एक अनूठा कोड जो यह सत्यापित करने में मदद करता है कि Enprive ने यही सटीक टेक्स्ट जाँचा था। यदि एक अक्षर भी बदलता है, तो यह कोड भी बदल जाता है।';

  @override
  String get copyDigestBtn => 'फ़िंगरप्रिंट कॉपी करें';

  @override
  String get digestCopiedMsg => 'दस्तावेज़ फ़िंगरप्रिंट कॉपी किया गया';

  @override
  String get permissionGrantedBadge => 'इस फ़ोन पर अनुमत';

  @override
  String get permissionNotGrantedBadge => 'अनुमत नहीं';

  @override
  String get checkingPolicyWithCloudAi =>
      'क्लाउड AI से नीति की जाँच हो रही है।';

  @override
  String get preparingCloudAiStream =>
      'क्लाउड जाँच से पहले व्यक्तिगत विवरण छिपाए जा रहे हैं…';

  @override
  String get cancellingAnalysis => 'रद्द किया जा रहा है…';

  @override
  String get analysisCancelledNotice => 'समीक्षा रद्द कर दी गई।';

  @override
  String get cloudTimedOutNotice =>
      'क्लाउड AI ने उत्तर देने में समय समाप्त कर दिया। कोई स्वचालित पुनः प्रयास नहीं किया गया।';

  @override
  String get cloudFallbackBannerTitle => 'क्लाउड जाँच पूरी नहीं हो सकी';

  @override
  String get cloudFallbackBannerBody =>
      'यह आपके फ़ोन पर मिला नतीजा है, और कुछ भी दोबारा नहीं भेजा गया। आपकी गोपनीयता नीति का पाठ सुरक्षित है। जब तक आप सहेजें पर नहीं टैप करते, कुछ भी सहेजा नहीं जाता।';

  @override
  String get cloudFallbackRetryAction => 'क्लाउड जाँच फिर से आज़माएँ';

  @override
  String get appPickerFilterAll => 'सभी ऐप्स';

  @override
  String get appPickerFilterDownloaded => 'डाउनलोड किए गए';

  @override
  String get appPickerFilterSystem => 'सिस्टम';

  @override
  String get appPickerRecentlyChecked => 'हाल में जाँचे गए';

  @override
  String get appPickerStatusPolicySaved => 'नीति समीक्षा सहेजी गई';

  @override
  String get appPickerStatusPermissionsInspected => 'अनुमतियाँ जाँची गईं';

  @override
  String get appPickerStatusNotReviewed => 'समीक्षा नहीं हुई';

  @override
  String get appPickerSearchHint => 'ऐप के नाम या App ID से खोजें…';

  @override
  String get appPickerEmptyInstalledTitle =>
      'कोई इंस्टॉल किया गया ऐप उपलब्ध नहीं';

  @override
  String get appPickerEmptyInstalledBody =>
      'हमें इस फ़ोन पर जाँचने के लिए कोई ऐप नहीं मिला।';

  @override
  String get intakeModeDocument => 'दस्तावेज़';

  @override
  String get intakeActionInspectText => 'नीति टेक्स्ट जाँचें';

  @override
  String get intakeActionFetchUrl => 'नीति खोलें और जाँचें';

  @override
  String get intakeActionChooseDocument => 'PDF, TXT या DOCX चुनें';

  @override
  String get intakeActionReplaceDocument => 'बदली हुई फ़ाइल चुनें';

  @override
  String get intakeWorkingLabel => 'काम जारी है…';

  @override
  String get intakeCancelFetch => 'लोड करना रद्द करें';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'यह सार्वजनिक वेब पेज सीधे लोड होता है। यहाँ लिंक जोड़ने से ऐप का स्वामित्व साबित नहीं होता।';

  @override
  String get intakePasteLocalNote =>
      'पहले इस फ़ोन पर स्थानीय रूप से जाँचा जाता है। आपकी अनुमति के बिना कुछ भी अपलोड नहीं होता।';

  @override
  String get intakeDocumentCardTitle => 'PDF, TXT या DOCX नीति फ़ाइल आयात करें';

  @override
  String get intakeDocumentCardBody =>
      'हम टेक्स्ट सीधे आपके फ़ोन पर पढ़ते हैं (10 MB तक)। आपकी फ़ाइल कभी अपलोड नहीं होती।';

  @override
  String get intakeCompareWithAppPrompt =>
      'इंस्टॉल किए गए ऐप से तुलना करें (वैकल्पिक)';

  @override
  String get intakeCompareWithAppHint =>
      'यह इसी फ़ोन पर स्थानीय रूप से चलता है। आपकी ऐप सूची कभी डिवाइस से बाहर नहीं जाती।';

  @override
  String get intakeCompareWithAppChange => 'बदलें';

  @override
  String get intakeCompareWithAppRemove => 'हटाएँ';

  @override
  String get intakeLockedAppContextLabel => 'चयनित ऐप';

  @override
  String get intakeFindPolicyOnPlayStore => 'Play Store पर नीति लिंक खोजें';

  @override
  String get intakePlayStoreHelperNote =>
      'Play Store खोलता है ताकि आप ऐप की गोपनीयता नीति का लिंक कॉपी कर सकें। Enprive इसे अपने आप कॉपी नहीं करता और न ही इसे आधिकारिक मानता है।';

  @override
  String get intakePlayStoreUnavailable =>
      'इस डिवाइस पर Google Play Store नहीं खुल सका। इसके बजाय नीति का URL या टेक्स्ट स्वयं पेस्ट करें।';

  @override
  String get intakeRecoverySwitchPaste => 'इसके बजाय टेक्स्ट पेस्ट करें';

  @override
  String get intakeRecoverySwitchDocument => 'दस्तावेज़ आयात करें';

  @override
  String get intakeRecoveryRetryUrl => 'फिर से लोड करें';

  @override
  String get intakeExpiredDocumentShareNotice =>
      'मूल रूप से साझा की गई फ़ाइल का लिंक अब दोबारा नहीं खुल सकता। कृपया दूसरी PDF, TXT या DOCX फ़ाइल चुनें या नीति का टेक्स्ट स्वयं पेस्ट करें।';

  @override
  String get intakeAssociationWarningTitle => 'ऐप और नीति मिलान जाँच';

  @override
  String get intakeAssociationContinueAnyway => 'फिर भी जारी रखें';

  @override
  String get intakeAssociationChangeApp => 'चयनित ऐप बदलें';

  @override
  String get intakeAssociationInspectWithoutApp => 'बिना ऐप के नीति जाँचें';

  @override
  String get intakeModeSelectorSemanticLabel => 'नीति डालने का तरीका';

  @override
  String get tooltipClearSearch => 'खोज साफ़ करें';

  @override
  String get intakeRecoveryEditUrl => 'URL संपादित करें';

  @override
  String get voiceSummaryTitle => 'Deni का सरल भाषा में सारांश';

  @override
  String get voiceSummaryPreparing => 'सरल भाषा में सारांश तैयार हो रहा है…';

  @override
  String get voiceSynthesizingExpressive =>
      'Deni की एक्सप्रेसिव आवाज़ तैयार हो रही है…';

  @override
  String get voiceBtnListenOffline => 'सुनें';

  @override
  String get voiceBtnStop => 'रोकें';

  @override
  String get voiceBtnExpressiveCloud => 'एक्सप्रेसिव आवाज़';

  @override
  String get voiceBtnSummarizeCloud => 'क्लाउड AI से सारांश बनाएँ';

  @override
  String get voiceBadgeExpressive => 'एक्सप्रेसिव क्लाउड आवाज़';

  @override
  String get voiceBadgeDeviceOffline => 'फ़ोन की आवाज़ · ऑफ़लाइन';

  @override
  String get voiceViewSourceQuote => 'स्रोत उद्धरण';

  @override
  String get voiceHideSourceQuote => 'उद्धरण छिपाएँ';

  @override
  String get voiceInspectFinding => 'निष्कर्ष देखें';

  @override
  String get voiceConsentTitle => 'Deni की आवाज़ चुनें';

  @override
  String get voiceConsentDisclosure =>
      'Deni की एक्सप्रेसिव क्लाउड आवाज़ में यह सारांश सुनने के लिए, Enprive केवल इस एक अनुरोध के लिए ऊपर दिखाया गया सारांश टेक्स्ट (व्यक्तिगत विवरण छिपाकर) भेजेगा। आपके ऐप्स और फ़ोन की अनुमतियाँ कभी नहीं भेजी जातीं।';

  @override
  String get voiceConsentPrimaryAction => 'एक बार एक्सप्रेसिव आवाज़ चुनें';

  @override
  String get voiceConsentSecondaryAction => 'इस फ़ोन पर सुनें';

  @override
  String get voiceConsentPayloadLabel => 'सटीक बोला जाने वाला टेक्स्ट';

  @override
  String get voiceSummaryConsentTitle =>
      'क्लाउड AI से निष्कर्षों का सारांश बनाएँ';

  @override
  String get voiceSummaryConsentDisclosure =>
      'क्लाउड में इन नीति उद्धरणों का सरल भाषा में सारांश बनाने के लिए, Enprive केवल इस एक अनुरोध के लिए ऊपर दिखाया गया टेक्स्ट (व्यक्तिगत विवरण छिपाकर) भेजेगा। आपके ऐप्स और फ़ोन की अनुमतियाँ कभी नहीं भेजी जातीं।';

  @override
  String get voiceFallbackDeviceNotice =>
      'एक्सप्रेसिव क्लाउड आवाज़ उपलब्ध नहीं थी: इसके बजाय इस फ़ोन की ऑफ़लाइन आवाज़ का उपयोग किया जा रहा है।';

  @override
  String get voiceUnavailableNotice =>
      'इस फ़ोन पर इस भाषा के लिए वॉइस प्लेबैक उपलब्ध नहीं है। आप ऊपर Deni का सारांश पढ़ सकते हैं।';

  @override
  String get voiceTooltipReadSummary => 'Deni का सरल भाषा सारांश सुनें';

  @override
  String get voiceTooltipStopReading => 'पढ़कर सुनाना रोकें';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'निष्कर्ष',
      one: 'निष्कर्ष',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निष्कर्ष',
      one: '1 निष्कर्ष',
      zero: 'कोई निष्कर्ष नहीं',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'नीति में $count सत्यापित उद्धरण',
      one: 'नीति में 1 सत्यापित उद्धरण',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इस फ़ोन पर $count देखे गए',
      one: 'इस फ़ोन पर 1 देखा गया',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'इस फ़ोन पर अनुमत';

  @override
  String get permissionNotAllowedOnPhone => 'अनुमत नहीं';

  @override
  String get permissionAllowedInSample => 'सैंपल में अनुमत';

  @override
  String get permissionNotAllowedInSample => 'सैंपल में अनुमत नहीं';

  @override
  String get permissionMismatchChip => 'नीति में नहीं';

  @override
  String get howEnpriveCheckedThis => 'Enprive ने इसे कैसे जाँचा';

  @override
  String get hideHowEnpriveChecked => 'Enprive की जाँच प्रक्रिया छिपाएँ';

  @override
  String get consentWhatWouldBeSent => 'क्या भेजा जाएगा';

  @override
  String get consentSentScope =>
      'केवल पूर्वावलोकन में दिखने वाला टेक्स्ट इस एक अनुरोध के लिए इस फ़ोन से बाहर जाता है।';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count व्यक्तिगत विवरण पहले छिपाए गए हैं।',
      one: '1 व्यक्तिगत विवरण पहले छिपाया गया है।',
      zero: 'छिपाने के लिए कोई व्यक्तिगत विवरण नहीं मिला।',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'आपकी ऐप सूची और फ़ोन की अनुमतियाँ इसी फ़ोन पर रहती हैं।';

  @override
  String receiptDeletedSnack(String title) {
    return '$title हटाया गया';
  }

  @override
  String get btnUndo => 'पूर्ववत करें';

  @override
  String get readinessPromiseMaskedTitle => 'व्यक्तिगत विवरण छिपे हुए';

  @override
  String get readinessPromiseMaskedLine =>
      'यदि आप क्लाउड चुनते हैं, तो नाम, ईमेल और नंबर पहले छिपाए जाते हैं।';

  @override
  String findingDetailTitle(int index, int total) {
    return 'निष्कर्ष $index / $total';
  }

  @override
  String get findingReviewChip => 'समीक्षा';

  @override
  String get askDeniAboutThis => 'इस बारे में Deni से पूछें';

  @override
  String get labelWhatPolicySays => 'नीति क्या कहती है';

  @override
  String get labelWhatAndroidReports => 'आपका फ़ोन क्या दिखाता है';

  @override
  String get sourceButtonTooltip => 'समीक्षित स्रोत';

  @override
  String get linkInstalledAppBtn => 'इंस्टॉल किया गया ऐप जोड़ें';

  @override
  String get linkInstalledAppCardTitle => 'इस फ़ोन के किसी ऐप से तुलना करें';

  @override
  String get linkInstalledAppCardBody =>
      'एक ही समीक्षा में इस नीति के साथ फ़ोन की अनुमतियों की तुलना करने के लिए इंस्टॉल किया गया ऐप चुनें। आपकी ऐप सूची इसी फ़ोन पर रहती है।';

  @override
  String get linkAppPickerTitle => 'इंस्टॉल किया गया ऐप जोड़ें';

  @override
  String get changeLinkedAppPickerTitle => 'जुड़ा हुआ ऐप बदलें';

  @override
  String get linkAppPickerSubtitle =>
      'इस नीति के साथ अनुमतियों की तुलना करने के लिए इस फ़ोन पर कोई ऐप चुनें। आपकी ऐप सूची कभी इस फ़ोन से बाहर नहीं जाती।';

  @override
  String get linkedAppCurrentlySelectedBadge => 'जुड़ा हुआ';

  @override
  String get linkedAppSectionLabel => 'इस फ़ोन पर जुड़ा हुआ ऐप';

  @override
  String get btnChangeLinkedApp => 'ऐप बदलें';

  @override
  String get btnUnlinkApp => 'ऐप लिंक हटाएँ';

  @override
  String get btnUpdatePrivacyPolicy => 'नई गोपनीयता नीति जोड़ें';

  @override
  String linkedAppSnack(String appName) {
    return '$appName जोड़ा गया। इस फ़ोन पर अनुमतियों की तुलना की गई।';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return '$appName जोड़ा गया। नीचे ऐप और नीति मिलान नोट देखें।';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName पहले से उन्हीं अनुमतियों के साथ जुड़ा है।';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return '$appName का लिंक हटाया गया। अब केवल नीति समीक्षा दिखाई जा रही है।';
  }

  @override
  String get associationStatusPackageTitle => 'इस नीति में App ID मिला';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'इस नीति में $packageName का उल्लेख है। इससे लगता है कि यह $appName के बारे में हो सकती है, हालांकि केवल टेक्स्ट यह साबित नहीं करता कि इस नीति का मालिक कौन है।';
  }

  @override
  String get associationStatusNameTitle => 'इस नीति में ऐप का नाम मिला';

  @override
  String associationStatusNameBody(String appName) {
    return 'इस नीति में $appName का उल्लेख है। इससे लगता है कि यह इस ऐप के बारे में हो सकती है, हालांकि केवल नाम मिलने से यह साबित नहीं होता कि इस नीति का मालिक कौन है।';
  }

  @override
  String get associationStatusUnverifiedTitle =>
      'तुलना के लिए आपके द्वारा जोड़ा गया';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'इस नीति में $appName या इसके App ID का नाम नहीं है। दोबारा जाँच लें कि यह सही नीति है: इसे यहाँ जोड़ने से स्वामित्व साबित नहीं होता।';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'वेब पते में $appName से जुड़े शब्द हैं, लेकिन नीति के टेक्स्ट में इस ऐप का नाम नहीं है। दोबारा जाँच लें कि यह सही नीति है: इसे यहाँ जोड़ने से स्वामित्व साबित नहीं होता।';
  }

  @override
  String get associationStatusUnmatchedTitle =>
      'यह नीति किसी दूसरे ऐप की हो सकती है';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'इस नीति में $appName का उल्लेख नहीं है। इसके बजाय इसमें $otherApps का नाम है। जाँचें कि आपने सही ऐप जोड़ा है या सही नीति खोली है।';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'इस नीति में एक से अधिक ऐप्स का उल्लेख है';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'इस नीति में $appName के साथ $otherApps का भी उल्लेख है। यह कई ऐप्स या साझा कंपनी नीति के लिए हो सकती है, इसलिए जाँचें कि यह यहाँ लागू होती है या नहीं।';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      'इस फ़ोन पर एक से अधिक ऐप्स का नाम मिलता-जुलता है';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'इस नीति में बिना किसी सटीक App ID के $appName का नाम है, और आपके फ़ोन पर अन्य ऐप्स ($otherApps) का नाम भी मिलता-जुलता है। सुनिश्चित करें कि आपने सही ऐप जोड़ा है।';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'यह नीति एक से अधिक ऐप्स के लिए हो सकती है। दोबारा जाँचें कि यह $appName पर लागू होती है।';
  }

  @override
  String get associationOwnershipLimitation =>
      'टेक्स्ट और वेब लिंक कभी यह साबित नहीं करते कि नीति किसने प्रकाशित की या उसका मालिक कौन है।';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'इस फ़ोन पर $count अनुमतियाँ इस नीति में स्पष्ट रूप से नहीं बताई गई हैं। यह अंतर करीब से देखने का संकेत है, किसी गलत काम का सबूत नहीं।',
      one: 'इस फ़ोन पर 1 अनुमति इस नीति में स्पष्ट रूप से नहीं बताई गई है। यह अंतर करीब से देखने का संकेत है, किसी गलत काम का सबूत नहीं।',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'इस फ़ोन पर जाँची गई कोई भी अनुमति इस नीति से विरोधाभास नहीं रखती। केवल अनुमतियाँ यह नहीं बता सकतीं कि ऐप वास्तव में क्या भेजता है।';

  @override
  String get permissionComparisonLimitationNote =>
      'आपका फ़ोन केवल इस फ़ोन की अनुमति सेटिंग्स दिखाता है। यह तुलना करीब से देखने का संकेत है, कभी गलत काम या डेटा भेजे जाने का सबूत नहीं।';

  @override
  String get permissionNotRequestedOnPhone => 'ऐप द्वारा नहीं माँगी गई';

  @override
  String get permissionNotRequestedInSample => 'सैंपल में नहीं माँगी गई';

  @override
  String get permissionsEmptyComparisonTitle =>
      'इस जाँच में कोई संवेदनशील अनुमति नहीं मिली';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'आपका फ़ोन $appName के लिए $requestedCount अनुमतियाँ ($grantedCount अनुमत) दिखाता है, जिनमें यहाँ जाँची गई संवेदनशील श्रेणियों (लोकेशन, कैमरा, माइक्रोफ़ोन, संपर्क, फ़ोटो या विज्ञापन ID) की कोई अनुमति नहीं है।';
  }

  @override
  String get sourceDeviceInspection => 'इस फ़ोन पर जाँचा गया';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => 'उन्नत विवरण';

  @override
  String get advancedDetailsSubtitle =>
      'तकनीकी विवरण जो सत्यापित करते हैं कि यह नीति टेक्स्ट कब और कहाँ जाँचा गया।';

  @override
  String get sourceSectionTitle => 'यह नीति कहाँ से आई';

  @override
  String get cloudPayloadLabel => 'भेजा जाने वाला सटीक टेक्स्ट';

  @override
  String get cloudPayloadNoPiiLabel => 'कोई व्यक्तिगत विवरण नहीं मिला';

  @override
  String cloudPayloadHiddenCount(int count) {
    return 'छिपाए गए ($count)';
  }

  @override
  String get summarySourceOnDevice => 'इस फ़ोन पर सारांशित';

  @override
  String get summarySourceInCloud => 'क्लाउड में सारांशित';

  @override
  String get summarySourceOffline => 'इस फ़ोन पर ऑफ़लाइन सारांशित';

  @override
  String get summarySourceUnknown => 'सारांश का स्रोत अज्ञात';

  @override
  String get notFromPolicySuffix => 'आपके फ़ोन की सेटिंग्स से, नीति से नहीं';

  @override
  String get sampleNotFromPolicySuffix => 'केवल उदाहरण, नीति से नहीं';

  @override
  String get learnHeaderSubtitle => 'ऑफ़लाइन गोपनीयता गाइड और आरेख';

  @override
  String get learnFilterAll => 'सभी विषय';

  @override
  String get learnFilterPolicies => 'नीतियाँ';

  @override
  String get learnFilterPermissions => 'अनुमतियाँ';

  @override
  String get learnFilterSharing => 'साझाकरण';

  @override
  String get learnFilterEvidence => 'साक्ष्य';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चरण',
      one: '1 चरण',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle => 'स्थानीय रूप से गोपनीयता की आदतें सीखें';

  @override
  String get learnDeckBody =>
      'आरेखों के साथ 100% ऑफ़लाइन पाठ। आपके इंस्टॉल किए गए ऐप्स और रसीदें कभी सीखें अनुभाग में नहीं जाते।';

  @override
  String get learnDeckCheckBtn => 'अभ्यास करें · ऐप जाँचें';

  @override
  String get learnCheckAppBridgeBtn => 'इस फ़ोन पर कोई ऐप जाँचें';

  @override
  String get learnSectionDiagram => 'यह कैसे काम करता है';

  @override
  String get learnSectionSteps => 'मुख्य चरण';

  @override
  String get learnSectionQuickCheck => 'त्वरित जाँच';

  @override
  String get learnTooltipListenLesson => 'यह पाठ ऑफ़लाइन पढ़कर सुनें';

  @override
  String get learnTooltipStopLesson => 'पाठ पढ़ना रोकें';

  @override
  String get learnVoiceUnavailableNotice =>
      'इस फ़ोन पर इस भाषा के लिए ऑफ़लाइन वॉइस प्लेबैक उपलब्ध नहीं है। आप नीचे पाठ पढ़ सकते हैं।';

  @override
  String get learnQuickCheckCorrectBadge => 'सही उत्तर';

  @override
  String get learnQuickCheckTryAgainBadge => 'दूसरा विकल्प आज़माएँ';

  @override
  String learnLessonProgress(int current, int total) {
    return 'पाठ $current / $total';
  }

  @override
  String get learnBackTooltip => 'सीखें पर लौटें';

  @override
  String get learnPreviousLesson => 'पिछला';

  @override
  String get learnNextLesson => 'अगला';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return 'पिछला पाठ: $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return 'अगला पाठ: $title';
  }

  @override
  String get learnPolicyFolderTitle => 'गोपनीयता नीतियाँ';

  @override
  String get learnPolicyTitle =>
      'गोपनीयता नीति क्या है (और यह क्या साबित नहीं कर सकती)';

  @override
  String get learnPolicySubtitle =>
      'डेवलपर क्या वादा करते हैं बनाम क्या अज्ञात रहता है';

  @override
  String get learnPolicyIntro =>
      'गोपनीयता नीति डेवलपर का सार्वजनिक बयान है जो बताता है कि ऐप कौन सा डेटा एकत्र करने की बात करता है, इसका उपयोग क्यों करता है, इसे और कौन पा सकता है और परिवारों के पास क्या विकल्प हैं।';

  @override
  String get learnPolicyStep1 =>
      'चार बुनियादी बातें देखें: कौन सा डेटा एकत्र होता है, ऐप को इसकी ज़रूरत क्यों है, इसे और कौन पा सकता है, और आप इसे हटाने का अनुरोध कैसे कर सकते हैं।';

  @override
  String get learnPolicyStep2 =>
      'उलझाने वाली भाषा आम है। बच्चों के लर्निंग ऐप्स पर 2026 के एक अध्ययन में पाया गया कि बहुत कम नीतियाँ पढ़ने में आसान थीं, और अधिकांश ऐप्स अपनी नीतियों में कही गई बातों से पूरी तरह मेल नहीं खाते थे।';

  @override
  String get learnPolicyStep3 =>
      'गोपनीयता नीति केवल वही दिखाती है जो डेवलपर कागज़ पर कहता है। इसे पढ़ने से यह साबित नहीं होता कि ऐप वास्तव में इंटरनेट पर क्या भेजता है।';

  @override
  String get learnPolicyStep4 =>
      'नीति की तुलना अपने फ़ोन की अनुमति सेटिंग्स से करने पर स्पष्ट तस्वीर मिलती है, लेकिन याद रखें कि Enprive लाइव इंटरनेट ट्रैफ़िक नहीं देख सकता।';

  @override
  String get learnPolicyQuickQuestion =>
      'किसी ऐप की गोपनीयता नीति पढ़ने से क्या साबित होता है?';

  @override
  String get learnPolicyQuickOption1 => 'कि ऐप कभी किसी को डेटा नहीं भेजता';

  @override
  String get learnPolicyQuickOption2 =>
      'डेवलपर क्या कहता है: यह नहीं कि ऐप वास्तव में क्या भेजता है';

  @override
  String get learnPolicyQuickOption3 => 'कि फ़ोन का कैमरा और माइक बंद हैं';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'बिल्कुल सही। नीति डेवलपर का सार्वजनिक बयान है, इस बात का सबूत नहीं कि ऐप वास्तव में इंटरनेट पर क्या भेजता है।';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      'पूरी तरह सही नहीं। नीति पढ़ने से केवल यह पता चलता है कि डेवलपर क्या कहता है: इससे इंटरनेट गतिविधि साबित नहीं होती और न ही फ़ोन की अनुमतियाँ बंद होती हैं।';

  @override
  String get learnDiagramPolicySaysTitle => 'नीति कहती है';

  @override
  String get learnDiagramPolicySaysBody => 'डेवलपर का लिखित वादा';

  @override
  String get learnDiagramPolicyQuoteSample =>
      '\"हम भागीदारों के साथ डेटा साझा कर सकते हैं…\"';

  @override
  String get learnDiagramPhoneShowsTitle => 'फ़ोन दिखाता है';

  @override
  String get learnDiagramPhoneShowsBody => 'यहाँ दी गई अनुमतियाँ';

  @override
  String get learnDiagramUnknownTitle => 'अभी भी अज्ञात';

  @override
  String get learnDiagramUnknownBody =>
      'लाइव इंटरनेट ट्रैफ़िक जिसे Enprive नहीं देख सकता';

  @override
  String get learnDiagramPolicyCaption =>
      'नीति एक वादा है, व्यवहार का सबूत नहीं';

  @override
  String get learnDiagramPolicySemantic =>
      'ऐप गोपनीयता के तीन हिस्सों की तुलना करने वाला आरेख। पहला, नीति कहती है: डेवलपर का लिखित वादा। दूसरा, फ़ोन दिखाता है: इस फ़ोन पर दी गई अनुमतियाँ। तीसरा, खंडित सीमा के भीतर, अभी भी अज्ञात: लाइव इंटरनेट ट्रैफ़िक जिसे Enprive नहीं देख सकता। गोपनीयता नीति एक वादा है, व्यवहार का सबूत नहीं।';

  @override
  String get learnPermissionsFolderTitle => 'फ़ोन अनुमतियाँ';

  @override
  String get learnPermissionsTitle => 'Android अनुमतियाँ सरल शब्दों में';

  @override
  String get learnPermissionsSubtitle =>
      'चार Android विकल्प और उन्हें कहाँ देखें';

  @override
  String get learnPermissionsIntro =>
      'अनुमतियाँ वे द्वार हैं जो तय करते हैं कि कोई ऐप आपके फ़ोन के सेंसर और डेटा तक पहुँच सकता है या नहीं, जैसे कैमरा, माइक्रोफ़ोन, लोकेशन, फ़ोटो, संपर्क या सूचनाएँ।';

  @override
  String get learnPermissionsStep1 =>
      'पूछें कि क्या अनुमति उस सुविधा के लिए ज़रूरी है: किसी गणित क्विज़ या पढ़ने वाले ऐप को शायद ही कभी आपकी लोकेशन, संपर्क या कैमरे की ज़रूरत हो।';

  @override
  String get learnPermissionsStep2 =>
      'Android चार तक विकल्प देता है: अनुमति न दें, हर बार पूछें, केवल ऐप का उपयोग करते समय अनुमति दें, और हर समय (बैकग्राउंड लोकेशन के लिए)।';

  @override
  String get learnPermissionsStep3 =>
      'सबसे सीमित विकल्प से शुरुआत करें जिससे सुविधा चल सके, जैसे हर बार पूछें या ऐप का उपयोग करते समय।';

  @override
  String get learnPermissionsStep4 =>
      'Android सेटिंग्स खोलें और गोपनीयता डैशबोर्ड देखें कि किन ऐप्स ने हाल में कैमरा, माइक्रोफ़ोन या लोकेशन का उपयोग किया।';

  @override
  String get learnPermissionsStep5 =>
      'ऐप सेटिंग्स में कभी भी अनुमतियाँ बंद करें, या उपयोग न होने पर ऐप गतिविधि रोकने का विकल्प चालू रखें ताकि Android पुरानी अनुमतियाँ अपने आप हटा दे। अनुमत अनुमति केवल क्षमता दिखाती है, डेटा भेजे जाने का सबूत नहीं।';

  @override
  String get learnPermissionsQuickQuestion =>
      'एक गणित अभ्यास ऐप आपका कैमरा माँगता है और आपको कारण नहीं पता। सबसे अच्छा पहला कदम क्या है?';

  @override
  String get learnPermissionsQuickOption1 =>
      'अनुमति न दें पर टैप करें और देखें कि गणित के अभ्यास फिर भी चलते हैं या नहीं';

  @override
  String get learnPermissionsQuickOption2 =>
      'हर समय चुनें ताकि पॉपअप दोबारा न आए';

  @override
  String get learnPermissionsQuickOption3 =>
      'मान लें कि ऐप पहले ही फ़ोटो अपलोड कर चुका है';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      'सही। अनुमति न दें पर टैप करके आप देख सकते हैं कि ऐप बिना कैमरे के चलता है या नहीं, और Android सेटिंग्स में आप कभी भी अनुमतियाँ बदल सकते हैं।';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'पहले अधिक सीमित विकल्प आज़माएँ। अनुमति न दें पर टैप करके जाँचें कि सुविधा काम करती है या नहीं, और याद रखें कि अनुमत अनुमति केवल क्षमता दिखाती है, अपलोड का सबूत नहीं।';

  @override
  String get learnDiagramPermLadderTitle =>
      'सबसे सीमित से सबसे व्यापक पहुँच तक';

  @override
  String get learnDiagramPermDenyTitle => 'अनुमति न दें';

  @override
  String get learnDiagramPermDenyDetail =>
      'अवरुद्ध: ऐप इस सेंसर का उपयोग नहीं कर सकता';

  @override
  String get learnDiagramPermAskTitle => 'हर बार पूछें';

  @override
  String get learnDiagramPermAskDetail => 'अनुमति देने पर एक बार की पहुँच';

  @override
  String get learnDiagramPermWhileUsingTitle => 'ऐप उपयोग करते समय';

  @override
  String get learnDiagramPermWhileUsingDetail =>
      'केवल तब जब ऐप स्क्रीन पर खुला हो';

  @override
  String get learnDiagramPermAllTimeTitle => 'हर समय';

  @override
  String get learnDiagramPermAllTimeDetail =>
      'बंद होने पर भी बैकग्राउंड में पहुँच';

  @override
  String get learnDiagramPermFitNote =>
      'क्या यह मेल खाता है? गणित क्विज़ + कैमरा = कारण पूछें';

  @override
  String get learnDiagramPermSemantic =>
      'सबसे सीमित से सबसे व्यापक पहुँच तक चार चरणों वाली Android अनुमति सीढ़ी। चरण 1, अनुमति न दें: अवरुद्ध, ऐप इस सेंसर का उपयोग नहीं कर सकता। चरण 2, हर बार पूछें: अनुमति देने पर एक बार की पहुँच। चरण 3, ऐप उपयोग करते समय: केवल तब पहुँच जब ऐप स्क्रीन पर खुला हो। चरण 4, हर समय: बंद होने पर भी बैकग्राउंड में पहुँच, अतिरिक्त सावधानी के लिए खंडित बॉर्डर के साथ। निचला सुझाव: क्या यह मेल खाता है? गणित क्विज़ का कैमरा माँगना कारण पूछने की वजह है।';

  @override
  String get learnSharingFolderTitle => 'विज्ञापन और तृतीय पक्ष';

  @override
  String get learnSharingTitle =>
      'डेटा और किसे मिलता है: विज्ञापन, एनालिटिक्स और तृतीय पक्ष';

  @override
  String get learnSharingSubtitle =>
      'ऐप निर्माता बनाम सहायक सेवाएँ, एनालिटिक्स और विज्ञापन नेटवर्क';

  @override
  String get learnSharingIntro =>
      'कई मुफ़्त ऐप्स पर्दे के पीछे दूसरी कंपनियों से जुड़ते हैं। यह जानना कि जानकारी किसे मिलती है, परिवारों को ऐप चलाने और अलग-अलग ऐप्स में बच्चों की ट्रैकिंग के बीच अंतर समझने में मदद करता है।';

  @override
  String get learnSharingStep1 =>
      'प्रथम पक्ष का अर्थ ऐप निर्माता स्वयं है: जैसे होमवर्क की प्रगति या क्विज़ के अंक सहेजना ताकि ऐप चल सके।';

  @override
  String get learnSharingStep2 =>
      'सहायक कंपनियाँ वे तृतीय पक्ष हैं जो पर्दे के पीछे क्लाउड स्टोरेज या क्रैश रिपोर्ट जैसे काम संभालती हैं ताकि खामियाँ ठीक हों।';

  @override
  String get learnSharingStep3 =>
      'एनालिटिक्स टूल मापते हैं कि स्क्रीन कैसे उपयोग होती है, जबकि विज्ञापन नेटवर्क और डेटा ब्रोकर लक्षित विज्ञापन दिखाने या ऐप्स के बीच गतिविधि ट्रैक करने के लिए विज्ञापन ID का उपयोग कर सकते हैं।';

  @override
  String get learnSharingStep4 =>
      '\'विश्वसनीय भागीदार\' या \'व्यावसायिक उद्देश्य\' जैसे व्यापक शब्दों पर ध्यान दें, और देखें कि क्या नीति बताती है कि वैयक्तिकृत विज्ञापनों से बाहर कैसे निकलें।';

  @override
  String get learnSharingQuickQuestion =>
      'एक नीति कहती है कि ऐप \'तृतीय-पक्ष भागीदारों\' के साथ जानकारी साझा करता है। अगला सबसे अच्छा सवाल क्या है?';

  @override
  String get learnSharingQuickOption1 =>
      'मान लेना कि ऐप में कोई विज्ञापन नहीं हैं';

  @override
  String get learnSharingQuickOption2 =>
      'मान लेना कि हर भागीदार बिल्कुल एक ही काम करता है';

  @override
  String get learnSharingQuickOption3 =>
      'जाँचना कि वे भागीदार सहायक सेवाएँ (जैसे होस्टिंग) हैं या ऐप्स के बीच ट्रैक करने वाले विज्ञापन नेटवर्क';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'बिल्कुल ठीक। सहायक सेवाएँ ऐप को चलाती हैं, जबकि विज्ञापन नेटवर्क और डेटा ब्रोकर ऐप्स के बीच गतिविधि ट्रैक कर सकते हैं।';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      'हर भागीदार का काम करीब से देखें। सभी तृतीय पक्ष एक जैसे नहीं होते: कुछ डेटा होस्ट करते हैं या क्रैश ठीक करते हैं, जबकि कुछ विज्ञापन या ट्रैकिंग चलाते हैं।';

  @override
  String get learnDiagramThirdPartyYou => 'आप';

  @override
  String get learnDiagramThirdPartyApp => 'लर्निंग ऐप';

  @override
  String get learnDiagramThirdPartyHosting => 'सहायक और क्रैश';

  @override
  String get learnDiagramThirdPartyAnalytics => 'एनालिटिक्स';

  @override
  String get learnDiagramThirdPartyAds => 'विज्ञापन नेटवर्क';

  @override
  String get learnDiagramThirdPartyFirstParty => 'प्रथम पक्ष';

  @override
  String get learnDiagramThirdPartyThirdParty => 'तृतीय पक्ष';

  @override
  String get learnDiagramThirdPartySemantic =>
      'प्रवाह आरेख दिखाता है कि बच्चों के लर्निंग ऐप से डेटा कहाँ जा सकता है। आप लर्निंग ऐप से जुड़ते हैं, जो ठोस रेखा से ऐप निर्माता (प्रथम पक्ष) से और खंडित रेखाओं से तृतीय पक्षों से जुड़ता है: सहायक और क्रैश टूल, एनालिटिक्स टूल और अतिरिक्त ध्यान के लिए चिह्नित विज्ञापन नेटवर्क।';

  @override
  String get learnEvidenceFolderTitle => 'Enprive पढ़ना';

  @override
  String get learnEvidenceTitle => 'Enprive के साक्ष्य कैसे पढ़ें';

  @override
  String get learnEvidenceSubtitle =>
      'साक्ष्य के स्तर, श्रेणियाँ और स्पष्ट सीमाएँ';

  @override
  String get learnEvidenceIntro =>
      'Enprive यह अलग रखता है कि गोपनीयता नीति क्या कहती है, आपका फ़ोन क्या दिखाता है और क्या अज्ञात रहता है, और निष्कर्षों को विषय के अनुसार समूहित करता है, कभी सुरक्षा ग्रेड के रूप में नहीं।';

  @override
  String get learnEvidenceStep1 =>
      'पाँच विषय श्रेणियाँ समीक्षा स्क्रीन के समान आइकन और रंग के साथ हर निष्कर्ष को समूहित करती हैं। रंग विषय दर्शाता है, कभी सुरक्षा स्कोर नहीं।';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '$sourceMatched का अर्थ है कि Enprive को आपके द्वारा जाँची गई नीति के टेक्स्ट में शब्दशः सटीक उद्धरण मिला।';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '$deviceObserved का अर्थ है कि आपके फ़ोन ने इस डिवाइस पर एक अनुमति सेटिंग बताई: यह डेटा भेजे जाने का सबूत नहीं है।';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '$interpretation सरल भाषा में Deni की व्याख्या है, जबकि $unverified उन विवरणों को चिह्नित करता है जो Enprive को नहीं मिले। नीति में चुप्पी कभी वादा नहीं होती।';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return 'समीक्षाएँ तीन शांत परिणामों में से एक पर समाप्त होती हैं: $reviewRecommended, $noConcern (जो कभी सुरक्षा प्रमाणपत्र नहीं है), या $insufficientEvidence।';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return 'समीक्षा स्क्रीन पर \'$deviceObserved\' का क्या अर्थ है?';
  }

  @override
  String get learnEvidenceQuickOption1 =>
      'कि ऐप बच्चों के लिए प्रमाणित रूप से सुरक्षित है';

  @override
  String get learnEvidenceQuickOption2 =>
      'कि आपका फ़ोन इस डिवाइस पर यह अनुमति सेटिंग दिखाता है: यह डेटा अपलोड होने का सबूत नहीं है';

  @override
  String get learnEvidenceQuickOption3 =>
      'कि ऐप ने निश्चित रूप से आपके बच्चे का डेटा अपलोड किया है';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'बिल्कुल सही। यह लेबल इस डिवाइस पर Android की अनुमति स्थिति दिखाता है; यह अपलोड साबित नहीं कर सकता और न ही सुरक्षा प्रमाणित करता है।';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      'पूरी तरह सही नहीं। यह लेबल केवल वही दिखाता है जो आपका फ़ोन किसी अनुमति सेटिंग के बारे में बताता है: यह कभी अपलोड साबित नहीं करता और कभी सुरक्षा प्रमाणपत्र नहीं होता।';

  @override
  String get learnDiagramEvidencePolicyDetail =>
      'नीति के टेक्स्ट में मिला सटीक उद्धरण';

  @override
  String get learnDiagramEvidencePhoneDetail =>
      'इस डिवाइस पर फ़ोन की अनुमतियाँ';

  @override
  String get learnDiagramEvidenceDeniDetail =>
      'Deni द्वारा सरल भाषा में व्याख्या';

  @override
  String get learnDiagramEvidenceUnknownDetail =>
      'नीति में चुप्पी कोई वादा नहीं है';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Enprive की समीक्षा स्क्रीन पर उपयोग किए जाने वाले चार साक्ष्य स्तर: 1, $sourceMatched, गोपनीयता नीति में मिला सटीक उद्धरण; 2, $deviceObserved, इस डिवाइस पर फ़ोन की अनुमतियाँ; 3, $interpretation, सरल भाषा में Deni की व्याख्या; और 4, खंडित रेखा से अलग, $unverified, क्योंकि नीति में चुप्पी कोई वादा नहीं है।';
  }

  @override
  String get learnDiagramCategoriesTitle =>
      'समीक्षा स्क्रीन पर पाँच विषय श्रेणियाँ';

  @override
  String get learnDiagramCategoriesNote =>
      'रंग और आइकन विषय दर्शाते हैं, कभी सुरक्षा स्कोर नहीं।';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Enprive की समीक्षा स्क्रीन पर दिखने वाली पाँच साक्ष्य श्रेणियाँ, हर एक अपने आइकन और रंग के साथ: $dataCollection, $sharing, $tracking, $retention, और $parentalControls। रंग और आइकन विषय दर्शाते हैं, कभी सुरक्षा स्कोर नहीं।';
  }

  @override
  String get learnDataCollectionFolderTitle => 'ऐप्स कौन सा डेटा लेते हैं';

  @override
  String get learnDataCollectionTitle => 'ऐप्स कौन सा डेटा एकत्र करते हैं';

  @override
  String get learnDataCollectionSubtitle =>
      'जो आप टाइप करते हैं और जो चुपचाप चलता है, उसके बीच का अंतर';

  @override
  String get learnDataCollectionIntro1 =>
      'ऐप्स दो तरीकों से जानकारी एकत्र करते हैं। कुछ डेटा वह है जो आप स्वयं डालते हैं: आपका नाम, ईमेल, फ़ोटो, वॉइस रिकॉर्डिंग या होमवर्क के उत्तर। अन्य डेटा बैकग्राउंड में अपने आप एकत्र होता है, जैसे आपका IP पता (इंटरनेट पर आपके फ़ोन का पता), डिवाइस पहचानकर्ता, विज्ञापन ID (एक कोड जिससे विज्ञापन आपके फ़ोन को पहचानते हैं), क्रैश लॉग और ऐप खोलने का समय।';

  @override
  String get learnDataCollectionStep1 =>
      'जो आप टाइप करते हैं: आपका नाम, स्कूल, ईमेल, फ़ोटो, वॉइस क्लिप और होमवर्क उत्तर वह डेटा हैं जो आप अपनी मर्ज़ी से देते हैं।';

  @override
  String get learnDataCollectionStep2 =>
      'जो चुपचाप चलता है: ऐप बिना कोई बटन दबाए विज्ञापन ID, डिवाइस पहचानकर्ता, IP पता, क्रैश रिपोर्ट और उपयोग समय एकत्र कर सकता है। चुपचाप संग्रह अपने आप बुरा नहीं है: ये संकेत ऐप्स को सुचारु रूप से चलाने में मदद करते हैं।';

  @override
  String get learnDataCollectionStep3 =>
      'बच्चों का संवेदनशील डेटा: लोकेशन, माइक्रोफ़ोन रिकॉर्डिंग, कैमरा फ़ोटो और वॉइसप्रिंट जैसे बायोमेट्रिक डेटा (आपके शरीर या आवाज़ से जुड़ा डेटा) बच्चों के लिए अधिक गोपनीयता जोखिम रखते हैं।';

  @override
  String get learnDataCollectionStep4 =>
      'Play Store नोट: Google Play का डेटा सुरक्षा अनुभाग डेवलपर का अपना विवरण है। यह एक संकेत है, सबूत नहीं, और इसमें वह डेटा शामिल नहीं है जो केवल आपके डिवाइस पर प्रोसेस होता है या थोड़ी देर मेमोरी में रहता है।';

  @override
  String get learnDataCollectionQuizQuestion =>
      'इनमें से कौन सा डेटा बैकग्राउंड में चुपचाप एकत्र होने का उदाहरण है?';

  @override
  String get learnDataCollectionQuizChoiceA =>
      'एक फ़ोटो जो आप अपनी प्रोफ़ाइल के लिए अपलोड करते हैं';

  @override
  String get learnDataCollectionQuizChoiceB =>
      'आपकी विज्ञापन ID और डिवाइस पहचानकर्ता';

  @override
  String get learnDataCollectionQuizChoiceC =>
      'एक होमवर्क उत्तर जो आप ऐप में टाइप करते हैं';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      'सही: विज्ञापन ID और डिवाइस पहचानकर्ता आपके टाइप किए बिना अपने आप एकत्र होते हैं।';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      'पूरी तरह सही नहीं: वह डेटा आप स्वयं दर्ज करते हैं। चुपचाप एकत्र होने वाले डेटा में विज्ञापन ID, डिवाइस पहचानकर्ता, IP पता और उपयोग समय शामिल हैं।';

  @override
  String get learnDataCollectionDiagramYouTypeTitle =>
      'जो आप टाइप करते या देते हैं';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => 'नाम, ईमेल, स्कूल';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => 'फ़ोटो और वीडियो';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => 'वॉइस रिकॉर्डिंग';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => 'होमवर्क के उत्तर';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle => 'जो चुपचाप चलता है';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => 'विज्ञापन ID';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 => 'डिवाइस पहचानकर्ता';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'IP पता';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 =>
      'क्रैश लॉग और उपयोग समय';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      'चुपचाप का अर्थ बुरा नहीं है: ये संकेत ऐप्स को ठीक से चलाने में मदद करते हैं।';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      'डेटा संग्रहण की दो श्रेणियाँ दिखाने वाला विभाजित आरेख। ऊपरी कार्ड \"जो आप टाइप करते या देते हैं\" में चार चिप्स हैं: नाम ईमेल स्कूल, फ़ोटो और वीडियो, वॉइस रिकॉर्डिंग, होमवर्क के उत्तर। निचले कार्ड \"जो चुपचाप चलता है\" में चार चिप्स हैं: विज्ञापन ID, डिवाइस पहचानकर्ता, IP पता, क्रैश लॉग और उपयोग समय। एक छोटा नोट कहता है \"चुपचाप का अर्थ बुरा नहीं है: ये संकेत ऐप्स को ठीक से चलाने में मदद करते हैं।\" Deni नीचे सोचते हुए मुद्रा में बैठा है।';

  @override
  String get learnDataCollectionCheckBridge =>
      'यह देखने के लिए इस फ़ोन पर कोई ऐप जाँचें कि वह कौन सा डेटा एकत्र करता है।';

  @override
  String get learnDataCollectionHonestyNote =>
      'यह पाठ सामान्य डेटा प्रकार समझाता है। यह साबित नहीं करता कि कोई विशिष्ट ऐप क्या एकत्र करता या भेजता है। केवल ऐप की सटीक नीति और आपके फ़ोन की अनुमति सेटिंग्स यह दिखा सकती हैं।';

  @override
  String get learnRetentionFolderTitle => 'डेटा रखना और हटाना';

  @override
  String get learnRetentionTitle => 'डेटा संग्रहण अवधि और हटाना';

  @override
  String get learnRetentionSubtitle =>
      'ऐप अनइंस्टॉल करने से कंपनी के सर्वर पर मौजूद डेटा नहीं मिटता';

  @override
  String get learnRetentionIntro1 =>
      'जब आप अपने फ़ोन से कोई ऐप हटाते हैं, तो आपके डिवाइस से ऐप की फ़ाइलें हट जाती हैं, लेकिन कंपनी के सर्वर पर पहले से अपलोड किया गया डेटा वहीं रहता है। गोपनीयता नीतियों को बताना चाहिए कि वे आपका डेटा कितने समय रखती हैं, हटाने का अनुरोध कैसे करें और बैकअप का क्या होता है, लेकिन कई नीतियाँ \"जितने समय तक उचित रूप से आवश्यक हो\" जैसे अस्पष्ट वाक्य लिखती हैं।';

  @override
  String get learnRetentionStep1 =>
      'डेटा संग्रहण: ऐप उपयोग करते समय आपकी जानकारी कंपनी के सर्वर पर भेजी और सहेजी जाती है।';

  @override
  String get learnRetentionStep2 =>
      'सर्वर पर सहेजा गया: ऐप उपयोग करना बंद करने के बाद भी आपका डेटा कंपनी के सिस्टम पर रह सकता है।';

  @override
  String get learnRetentionStep3 =>
      'अनइंस्टॉल करने से सर्वर का डेटा नहीं मिटता: फ़ोन से ऐप हटाने पर केवल स्थानीय फ़ाइलें मिटती हैं, कंपनी के सर्वर की प्रतियाँ नहीं।';

  @override
  String get learnRetentionStep4 =>
      'हटाने का अनुरोध: आप कंपनी से अपना खाता और डेटा हटाने को कह सकते हैं; नीतियों को बताना चाहिए कि इसमें कितना समय लगता है।';

  @override
  String get learnRetentionStep5 =>
      'अज्ञात अवधि: \"आवश्यकतानुसार\" या \"व्यावसायिक उद्देश्यों के लिए\" लिखने वाली नीतियाँ वास्तविक हटाने की समय-सीमा अस्पष्ट छोड़ देती हैं।';

  @override
  String get learnRetentionQuizQuestion =>
      'जब आप अपने फ़ोन से कोई ऐप अनइंस्टॉल करते हैं तो कंपनी के सर्वर पर आपके डेटा का क्या होता है?';

  @override
  String get learnRetentionQuizChoiceA => 'यह अपने आप हट जाता है';

  @override
  String get learnRetentionQuizChoiceB =>
      'यह सर्वर पर रह सकता है: ऐप अनइंस्टॉल करने से यह नहीं हटता';

  @override
  String get learnRetentionQuizChoiceC => 'इसे तुरंत गुमनाम कर दिया जाता है';

  @override
  String get learnRetentionQuizFeedbackRight =>
      'सही: अनइंस्टॉल करने से केवल आपके फ़ोन से ऐप हटता है। कंपनी के सर्वर पर डेटा तब तक रह सकता है जब तक आप हटाने का अनुरोध न करें।';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      'पूरी तरह सही नहीं: ऐप अनइंस्टॉल करने से कंपनी के सर्वर पर पहले से अपलोड डेटा नहीं मिटता। आपको खाता हटाने का अनुरोध करना होता है।';

  @override
  String get learnRetentionDiagramCollected =>
      'उपयोग के दौरान डेटा एकत्र होता है';

  @override
  String get learnRetentionDiagramStored => 'कंपनी के सर्वर पर सहेजा जाता है';

  @override
  String get learnRetentionDiagramUninstall =>
      'आप ऐप अनइंस्टॉल करते हैं: फ़ोन फ़ाइलें हटती हैं, सर्वर डेटा रहता है';

  @override
  String get learnRetentionDiagramDeleteRequest =>
      'आप खाता हटाने का अनुरोध करते हैं';

  @override
  String get learnRetentionDiagramUnknownTail =>
      'अज्ञात अवधि: नीति कहती है \"आवश्यकतानुसार\"';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      'डेटा जीवनचक्र दिखाने वाली पाँच चरणों की समय-रेखा। चरण 1: उपयोग के दौरान डेटा एकत्र होता है, डेटाबेस आइकन के साथ। चरण 2: कंपनी के सर्वर पर सहेजा जाता है, सर्वर आइकन के साथ। चरण 3: आप ऐप अनइंस्टॉल करते हैं: फ़ोन फ़ाइलें हटती हैं, सर्वर डेटा रहता है, स्मार्टफ़ोन आइकन के साथ। चरण 4: आप खाता हटाने का अनुरोध करते हैं, कचरा आइकन के साथ। चरण 5: अज्ञात अवधि: नीति कहती है \"आवश्यकतानुसार\", खंडित तीर और सहायता आइकन के साथ। Deni नीचे रसीद पकड़े खड़ा है।';

  @override
  String get learnRetentionCheckBridge =>
      'डेटा रखने के बारे में नीति क्या कहती है, यह देखने के लिए इस फ़ोन पर कोई ऐप जाँचें।';

  @override
  String get learnRetentionHonestyNote =>
      'यह पाठ डेटा रखने के सामान्य पैटर्न बताता है। यह साबित नहीं करता कि कोई विशिष्ट कंपनी वास्तव में आपके डेटा के साथ क्या करती है। केवल सटीक नीति टेक्स्ट और हटाने का अनुरोध यह दिखा सकते हैं।';

  @override
  String get learnUnclearPoliciesFolderTitle => 'अस्पष्ट नीतियाँ';

  @override
  String get learnUnclearPoliciesTitle =>
      'अस्पष्ट नीतियों और चालाक बटनों की पहचान';

  @override
  String get learnUnclearPoliciesSubtitle =>
      'अस्पष्ट भाषा और दबाव डालने वाली सहमति स्क्रीन कैसे पहचानें';

  @override
  String get learnUnclearPoliciesIntro1 =>
      'कुछ गोपनीयता नीतियाँ अस्पष्ट शब्दों का उपयोग करती हैं जिससे जानना कठिन हो जाता है कि आपके डेटा के साथ वास्तव में क्या होता है। सहमति स्क्रीन भी डिज़ाइन तरकीबें अपना सकती हैं, जैसे छोटे से \"सेटिंग्स प्रबंधित करें\" लिंक के बगल में बड़ा चमकदार \"सभी स्वीकार करें\" बटन, ताकि आप बिना पढ़े सहमत हो जाएँ।';

  @override
  String get learnUnclearPoliciesStep1 =>
      'अस्पष्ट नीति के संकेत: \"विश्वसनीय भागीदारों के साथ साझा कर सकते हैं\", \"व्यावसायिक उद्देश्यों के लिए\" या \"आवश्यकतानुसार रख सकते हैं\" जैसे खुले वाक्यों पर ध्यान दें: ये असली विवरण अधूरे छोड़ते हैं।';

  @override
  String get learnUnclearPoliciesStep2 =>
      'चुप्पी कोई वादा नहीं है: यदि कोई नीति माइक्रोफ़ोन, विज्ञापन या लोकेशन का ज़िक्र नहीं करती, तो इससे यह गारंटी नहीं मिलती कि ऐप उनसे बचता है।';

  @override
  String get learnUnclearPoliciesStep3 =>
      'गायब बुनियादी बातें: एक स्पष्ट नीति में प्रभावी तिथि, संपर्क ईमेल और एक ही पूरा दस्तावेज़ होता है, न कि बच्चों के लिए छिपा हुआ अलग हिस्सा।';

  @override
  String get learnUnclearPoliciesStep4 =>
      'दबाव वाली सहमति (डार्क पैटर्न): विशाल \"सभी स्वीकार करें\" बटन, पहले से टिक किए मार्केटिंग बॉक्स, बार-बार परेशान करने वाले पॉपअप और छिपे हुए रद्द करने के रास्ते आपकी पसंद को प्रभावित करने के लिए बनाए जाते हैं।';

  @override
  String get learnUnclearPoliciesStep5 =>
      'संतुलित विकल्प: एक निष्पक्ष स्क्रीन में \"अनुमति दें\" और \"अनुमति न दें\" के बराबर बटन होते हैं, और वैकल्पिक टॉगल डिफ़ॉल्ट रूप से बंद रहते हैं।';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      'गोपनीयता नीति में कौन सा वाक्य एक \"अस्पष्ट\" संकेत है कि विवरण गायब हैं?';

  @override
  String get learnUnclearPoliciesQuizChoiceA =>
      'हम आपकी व्यक्तिगत जानकारी तृतीय पक्षों को नहीं बेचते';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      'हम व्यावसायिक उद्देश्यों के लिए विश्वसनीय भागीदारों के साथ डेटा साझा कर सकते हैं';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'आप privacy@example.com पर ईमेल करके डेटा हटाने का अनुरोध कर सकते हैं';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      'सही: \"व्यावसायिक उद्देश्यों के लिए विश्वसनीय भागीदारों के साथ साझा कर सकते हैं\" अस्पष्ट है और नहीं बताता कि भागीदार कौन हैं या कौन सा डेटा साझा होता है।';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      'पूरी तरह सही नहीं: वह वाक्य स्पष्ट और उपयोगी है। अस्पष्ट वाक्यों में बिना विवरण के \"साझा कर सकते हैं\" या \"आवश्यकतानुसार\" जैसे खुले शब्द होते हैं।';

  @override
  String get learnUnclearPoliciesDiagramClearTitle => 'स्पष्ट नीति वाक्य';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      'हम आपका खाता बनाने के लिए आपका नाम और ईमेल एकत्र करते हैं। हम इसे विज्ञापनदाताओं से साझा नहीं करते।';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle => 'अस्पष्ट नीति वाक्य';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      'हम आवश्यकतानुसार व्यावसायिक उद्देश्यों के लिए विश्वसनीय भागीदारों के साथ आपकी जानकारी साझा कर सकते हैं।';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle => 'अस्पष्टता कैसे पहचानें';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      '\"सकते हैं\", \"संभव है\" या \"आवश्यकतानुसार\" देखें: ये रास्ता खुला छोड़ते हैं।';

  @override
  String get learnUnclearPoliciesDiagramTip2 =>
      'जाँचें कि क्या नीति उन विशिष्ट कंपनियों के नाम बताती है जिन्हें डेटा जाता है।';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      'विज्ञापन या माइक्रोफ़ोन पर चुप्पी इस बात का वादा नहीं है कि ऐप उनसे बचता है।';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote =>
      'नीति में चुप्पी कोई वादा नहीं है।';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      'एक स्पष्ट और एक अस्पष्ट नीति वाक्य की साथ-साथ तुलना। बाएँ कार्ड \"स्पष्ट\" पर लिखा है: \"हम आपका खाता बनाने के लिए आपका नाम और ईमेल एकत्र करते हैं। हम इसे विज्ञापनदाताओं से साझा नहीं करते।\" दाएँ कार्ड \"अस्पष्ट\" पर लिखा है: \"हम आवश्यकतानुसार व्यावसायिक उद्देश्यों के लिए विश्वसनीय भागीदारों के साथ आपकी जानकारी साझा कर सकते हैं।\" नीचे \"अस्पष्टता कैसे पहचानें\" कार्ड में तीन सुझाव हैं: \"सकते हैं\", \"संभव है\" या \"आवश्यकतानुसार\" देखें; जाँचें कि नीति विशिष्ट कंपनियों के नाम बताती है या नहीं; विज्ञापन या माइक्रोफ़ोन पर चुप्पी कोई वादा नहीं है। अस्पष्ट कार्ड पर नोट लिखा है \"नीति में चुप्पी कोई वादा नहीं है।\" Deni कार्डों के ऊपर से झाँक रहा है।';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      'सहमति स्क्रीन और नीति की स्पष्टता जाँचने के लिए इस फ़ोन पर कोई ऐप जाँचें।';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      'यह पाठ सामान्य अस्पष्ट पैटर्न बताता है। यह साबित नहीं करता कि कोई विशिष्ट ऐप डार्क पैटर्न अपनाता है या डेटा अभ्यास छिपाता है। केवल सटीक नीति पढ़कर और वास्तविक सहमति स्क्रीन देखकर ही यह पता चल सकता है।';

  @override
  String get learnSafeSharingFolderTitle => 'सुरक्षित साझाकरण आदतें';

  @override
  String get learnSafeSharingTitle => 'बच्चों के लिए सुरक्षित साझाकरण की आदतें';

  @override
  String get learnSafeSharingSubtitle =>
      'रुकें, सोचें, जुड़ें: ऑनलाइन साझा करने के उम्र के अनुसार कदम';

  @override
  String get learnSafeSharingIntro1 =>
      'कोई फ़ोटो, वीडियो, अपना नाम या लोकेशन पोस्ट करने से पहले रुकें और तीन कदम अपनाएँ: रुकें, सोचें, जुड़ें। यह पाठ किसी विश्वसनीय वयस्क के साथ पढ़ने के लिए है। छोटे बच्चे (5-7 वर्ष) टैप करने से पहले पूछते हैं। बड़े बच्चे (8-11 वर्ष) उपनाम और मज़बूत पासवर्ड उपयोग करते हैं। किशोर (12-17 वर्ष) अपने डिजिटल फुटप्रिंट (आप जो पोस्ट करते हैं उसका निशान) और दो-चरण सत्यापन (साइन इन करते समय कोड जैसी दूसरी जाँच) को संभालते हैं।';

  @override
  String get learnSafeSharingStep1 =>
      'रुकें: कोई फ़ोटो, वीडियो, नाम, स्कूल या लोकेशन पोस्ट करने से पहले ठहरें। यदि संदेह हो तो किसी विश्वसनीय वयस्क से पूछें।';

  @override
  String get learnSafeSharingStep2 =>
      'सोचें: क्या इससे मेरा स्कूल, घर या मेरी मौजूदा जगह पता चलती है? क्या मैंने दोस्तों की फ़ोटो साझा करने या उन्हें टैग करने से पहले उनसे पूछा?';

  @override
  String get learnSafeSharingStep3 =>
      'जुड़ें: केवल उन लोगों के साथ साझा करें जिन पर आपको भरोसा है। पूरा नाम, जन्मदिन, पता और फ़ोन नंबर जैसे व्यक्तिगत विवरण निजी रखें।';

  @override
  String get learnSafeSharingStep4 =>
      'कैंटीन टेस्ट: क्या मुझे ठीक लगेगा यदि स्कूल में हर कोई (या मेरी पूरी कक्षा) यह फ़ोटो या संदेश देख ले? गायब होने वाली पोस्ट का भी स्क्रीनशॉट लिया जा सकता है और वे हमेशा ऑनलाइन रह सकती हैं।';

  @override
  String get learnSafeSharingStep5 =>
      'उम्र 5-7: अपना नाम लिखने या पॉपअप पर टैप करने से पहले किसी विश्वसनीय वयस्क से पूछें। उम्र 8-11: उपनाम (असली नाम, जन्मदिन और स्कूल नहीं) और मज़बूत पासवर्ड उपयोग करें, और SMS या OTP कोड (संदेश से आने वाले एक-बार के कोड: इन्हें कभी साझा न करें) कभी न बताएँ। उम्र 12-17: गोपनीयता सेटिंग्स जाँचें, दो-चरण सत्यापन चालू करें और समस्या की रिपोर्ट करना जानें।';

  @override
  String get learnSafeSharingQuizQuestion =>
      'ऑनलाइन साझा करने के लिए \"कैंटीन टेस्ट\" क्या है?';

  @override
  String get learnSafeSharingQuizChoiceA =>
      'केवल वही चीज़ें साझा करना जो आप कैंटीन में खाएँ';

  @override
  String get learnSafeSharingQuizChoiceB =>
      'खुद से पूछना: क्या मुझे ठीक लगेगा यदि स्कूल में हर कोई यह फ़ोटो या संदेश देख ले?';

  @override
  String get learnSafeSharingQuizChoiceC => 'केवल लंच ब्रेक के दौरान साझा करना';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      'सही: कैंटीन टेस्ट का अर्थ खुद से पूछना है कि क्या आप सहज होंगे यदि हर कोई आपकी पोस्ट देख ले।';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      'पूरी तरह सही नहीं: कैंटीन टेस्ट एक मानसिक जाँच है: क्या आपको ठीक लगेगा यदि कोई आपकी पोस्ट पूरी कैंटीन को दिखा दे?';

  @override
  String get learnSafeSharingDiagramStop => 'रुकें: पोस्ट करने से पहले ठहरें';

  @override
  String get learnSafeSharingDiagramThink =>
      'सोचें: क्या इससे पता चलता है कि मैं कहाँ या किसके साथ हूँ?';

  @override
  String get learnSafeSharingDiagramConnect =>
      'जुड़ें: भरोसेमंद लोगों से साझा करें, संदेह में वयस्क से पूछें';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      'कैंटीन टेस्ट: क्या मुझे ठीक लगेगा यदि स्कूल में हर कोई इसे देखे? गायब होने वाली पोस्ट का भी स्क्रीनशॉट लिया जा सकता है और वे हमेशा ऑनलाइन रह सकती हैं।';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      'सुरक्षित साझाकरण की आदतें सिखाने वाला चार भागों का आरेख। चरण 1: रुकें: पोस्ट करने से पहले ठहरें, हाथ के आइकन के साथ। चरण 2: सोचें: क्या इससे पता चलता है कि मैं कहाँ या किसके साथ हूँ?, मस्तिष्क आइकन के साथ। चरण 3: जुड़ें: भरोसेमंद लोगों से साझा करें, संदेह में वयस्क से पूछें, लोगों के आइकन के साथ। चरण 4: कैंटीन टेस्ट बॉक्स पूछता है \"क्या मुझे ठीक लगेगा यदि स्कूल में हर कोई इसे देखे? गायब होने वाली पोस्ट का भी स्क्रीनशॉट लिया जा सकता है और वे हमेशा ऑनलाइन रह सकती हैं।\" Deni हाथ उठाए बॉक्स के पास खड़ा है।';

  @override
  String get learnSafeSharingCheckBridge =>
      'यह देखने के लिए किसी अभिभावक के साथ ऐप जाँचें कि वह साझाकरण कैसे संभालता है।';

  @override
  String get learnSafeSharingHonestyNote =>
      'यह पाठ सुरक्षित साझाकरण की सामान्य आदतें बताता है। यह गारंटी नहीं देता कि कोई ऐप आपके द्वारा साझा की गई चीज़ों की रक्षा करेगा। हमेशा ऐप की नीति पढ़ें और अपने फ़ोन की गोपनीयता सेटिंग्स उपयोग करें।';

  @override
  String get translationDraftNotice =>
      'कुछ अनुवाद AI द्वारा बनाए गए मसौदे हैं और इनमें गलतियाँ हो सकती हैं। मूल भाषी इनकी समीक्षा कर रहे हैं।';

  @override
  String get homeQuickSettingsTitle => 'त्वरित सेटिंग्स साथी';

  @override
  String get homeQuickSettingsSubtitle =>
      'आप जो ऐप उपयोग कर रहे हैं उसके बारे में Deni से कभी भी पूछें';

  @override
  String get appearanceSectionTitle => 'दिखावट';

  @override
  String get themeModeSystem => 'सिस्टम';

  @override
  String get themeModeLight => 'लाइट';

  @override
  String get themeModeDark => 'डार्क';

  @override
  String get quickSettingsSectionTitle =>
      'Enprive को त्वरित सेटिंग्स से जोड़ें';

  @override
  String get quickSettingsSectionSubtitle =>
      'अपने Android त्वरित सेटिंग्स पैनल में Enprive Check जोड़ें ताकि आप अपना काम छोड़े बिना Deni से ऐप्स के बारे में पूछ सकें।';

  @override
  String get quickSettingsTileTitle => 'Enprive Check टाइल';

  @override
  String get quickSettingsTileSubtitle =>
      'त्वरित सेटिंग्स में Enprive Check जोड़ें ताकि Enprive को पहले खोजे बिना मौजूदा ऐप के बारे में Deni से पूछ सकें।';

  @override
  String get quickSettingsStatusAdded => 'जोड़ा गया';

  @override
  String get quickSettingsStatusManual => 'मैनुअल';

  @override
  String get quickSettingsStatusNotAdded => 'नहीं जोड़ा गया';

  @override
  String get usageAccessStatusGranted => 'अनुमत';

  @override
  String get usageAccessStatusNotGranted => 'अनुमत नहीं';

  @override
  String get usageAccessTitle => 'उपयोग एक्सेस की अनुमति दें (वैकल्पिक)';

  @override
  String get usageAccessExplanation =>
      'Enprive उपयोग एक्सेस का इस्तेमाल केवल तब करता है जब आप Enprive Check पर टैप करते हैं, ताकि पता चले कि आप अभी कौन-सा ऐप उपयोग कर रहे थे। इससे Deni को सही ऐप और उसकी गोपनीयता जानकारी खोजने में मदद मिलती है। Enprive लगातार आपकी स्क्रीन पर नज़र नहीं रखता।';

  @override
  String get usageAccessManageLink => 'प्रबंधित या बंद कैसे करें';

  @override
  String get usageAccessManageTitle => 'उपयोग एक्सेस प्रबंधित या बंद करें';

  @override
  String get usageAccessManageBody =>
      'उपयोग एक्सेस Android सेटिंग्स का एक विशेष टॉगल है (कोई अपने-आप आने वाला पॉपअप नहीं)। आप इसे कभी भी Android सेटिंग्स -> ऐप्स -> विशेष ऐप एक्सेस -> उपयोग एक्सेस -> enprive में बंद कर सकते हैं। इसके बिना भी आप ऐप को मैनुअल चुनकर Deni का उपयोग कर सकते हैं।';

  @override
  String get openDeniCompanionTitle => 'Deni साथी खोलें';

  @override
  String get openDeniCompanionSubtitle =>
      'त्वरित सेटिंग्स के बिना हाल के या चुने हुए ऐप की अनुमतियाँ जाँचें।';

  @override
  String get btnGotIt => 'समझ गया';

  @override
  String get quickSettingsReadyDialogTitle =>
      'Enprive Check त्वरित सेटिंग्स में तैयार है';

  @override
  String get quickSettingsReadyDialogBody =>
      'अपनी स्क्रीन के ऊपर से दो बार नीचे स्वाइप करें और जब भी आप चाहें कि Deni किसी ऐप की अनुमतियाँ समझाए, \"Enprive Check\" पर टैप करें।';

  @override
  String get quickSettingsManualDialogTitle =>
      'Enprive Check मैनुअल रूप से जोड़ें';

  @override
  String get quickSettingsManualDialogBody =>
      '1. त्वरित सेटिंग्स खोलने के लिए Android स्क्रीन के ऊपर से दो बार नीचे स्वाइप करें।\n2. संपादन (पेंसिल) बटन पर टैप करें।\n3. \"Enprive Check\" खोजें और इसे अपनी सक्रिय त्वरित सेटिंग्स टाइल्स में खींचकर रखें।';

  @override
  String get quickSettingsSnackAdded =>
      'Enprive Check आपकी त्वरित सेटिंग्स ट्रे में जुड़ गया है।';

  @override
  String get quickSettingsSnackAlreadyAdded =>
      'Enprive Check पहले से आपकी त्वरित सेटिंग्स ट्रे में है।';

  @override
  String get quickSettingsSnackDeclined =>
      'अनुरोध खारिज किया गया। जब तक आप त्वरित सेटिंग्स में संपादन नहीं चुनते, Enprive दोबारा नहीं पूछेगा।';

  @override
  String get quickSettingsSnackManual =>
      'त्वरित सेटिंग्स नीचे खींचें, संपादन पर टैप करें और Enprive Check को अपनी टाइल्स में जोड़ें।';

  @override
  String get quickSettingsSnackUnavailable =>
      'सिस्टम संकेत यहाँ उपलब्ध नहीं है; आप त्वरित सेटिंग्स संपादन से Enprive Check को मैनुअल रूप से जोड़ सकते हैं।';

  @override
  String get usageAccessOpenFailedSnack =>
      'इस डिवाइस पर उपयोग एक्सेस सेटिंग्स नहीं खोली जा सकीं।';

  @override
  String get companionTitle => 'Deni: Enprive साथी';

  @override
  String get companionSubtitle =>
      'किसी ऐप की अनुमतियों और उसकी गोपनीयता नीति में क्या लिखा है, इस बारे में Deni से पूछें।';

  @override
  String get companionTooltipReturnToPrev => 'पिछले ऐप पर लौटें';

  @override
  String get companionTooltipBack => 'वापस';

  @override
  String get companionLockedBadge => 'लॉक स्क्रीन से सुरक्षित';

  @override
  String get companionLockedTitle => 'जारी रखने के लिए अपना फ़ोन अनलॉक करें';

  @override
  String get companionLockedBody =>
      'डिवाइस लॉक रहने पर Enprive ऐप के नाम, घोषित अनुमतियाँ और समीक्षा प्रमाण छिपाकर रखता है।';

  @override
  String get companionCheckUnlockBtn => 'अनलॉक स्थिति जाँचें';

  @override
  String get companionCheckingAppHeadline =>
      'जाँचा जा रहा है कि आप कौन-सा ऐप उपयोग कर रहे थे…';

  @override
  String get companionCheckingAppSubtitle =>
      'आपकी स्क्रीन देखे बिना इस फ़ोन पर केवल एक बार जाँचा जा रहा है।';

  @override
  String get companionGeneralGuideHeadline =>
      'सामान्य Android अनुमति मार्गदर्शिका';

  @override
  String get companionGeneralGuideSubtitle =>
      'कोई ऐप नहीं चुना गया। Enprive केवल स्थानीय मार्गदर्शन से Android अनुमतियाँ समझाता है।';

  @override
  String companionLookingAtHeadline(String appName) {
    return 'आप $appName देख रहे हैं।';
  }

  @override
  String get companionLookingAtSubtitle =>
      'नीचे दी गई अनुमतियाँ आपके फ़ोन के ऐप से आती हैं: स्क्रीन पर कौन-सा पॉपअप दिखता है, इसका नियंत्रण अभी भी Android के पास है।';

  @override
  String get companionThisAppFallback => 'यह ऐप';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return 'हमने $seconds सेकंड पहले $appName देखा था। क्या यह सही है?';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return 'हमें लगता है आप $appName उपयोग कर रहे हैं। क्या यह सही है?';
  }

  @override
  String companionAppIdLine(String packageName) {
    return 'App ID: $packageName';
  }

  @override
  String companionConfirmAppBtn(String appName) {
    return 'पुष्टि करें · $appName';
  }

  @override
  String get companionChooseAnotherAppBtn => 'कोई अन्य ऐप चुनें';

  @override
  String get companionWithoutAppContextBtn => 'बिना ऐप चुने';

  @override
  String get companionMultipleAppsTitle => 'अभी कई ऐप सक्रिय थे';

  @override
  String get companionMultipleAppsPrompt =>
      'पुष्टि करें कि आप किस ऐप की जाँच करना चाहते हैं:';

  @override
  String companionSecondsAgo(int seconds) {
    return '$seconds सेकंड पहले';
  }

  @override
  String get companionSelectAppTitle => 'वह ऐप चुनें जिसे आप जाँचना चाहते हैं';

  @override
  String get companionSelectAppBody =>
      'इंस्टॉल किए गए ऐप्स में से मैनुअल रूप से ऐप चुनें, या बिना ऐप संदर्भ के जारी रखें।';

  @override
  String get companionChooseAppManuallyBtn => 'ऐप मैनुअल रूप से चुनें';

  @override
  String get companionOpenUsageAccessBtn => 'उपयोग एक्सेस सेटिंग्स खोलें';

  @override
  String get companionContinueWithoutAppBtn => 'बिना ऐप संदर्भ के जारी रखें';

  @override
  String get companionAddTileBtn => 'Enprive Check टाइल जोड़ें';

  @override
  String get companionContinuingWithoutApp => 'बिना ऐप संदर्भ के जारी';

  @override
  String get companionSwitchAppBtn => 'ऐप बदलें';

  @override
  String get companionPermissionsReadLocally =>
      'नीचे दिखाई गई अनुमतियाँ सीधे आपके फ़ोन से पढ़ी गई हैं।';

  @override
  String get companionPickPermissionType =>
      'समझने के लिए अनुमति का प्रकार चुनें';

  @override
  String get companionPickAppBtn => 'ऐप चुनें';

  @override
  String get companionCouldNotReadPermsTitle =>
      'ऐप की अनुमतियाँ नहीं पढ़ी जा सकीं';

  @override
  String get companionCouldNotReadPermsBody =>
      'Android ने इस ऐप की अनुमतियों की जाँच को रोक दिया।';

  @override
  String get companionUnsurePermBtn => 'मुझे पक्का नहीं है कौन-सी अनुमति';

  @override
  String get companionWhichPermissionPrompt =>
      'आप किस अनुमति को समझना चाहते हैं?';

  @override
  String get companionPermissionsListDisclaimer =>
      'ये वे अनुमतियाँ हैं जो ऐप आपके फ़ोन पर सूचीबद्ध करता है, ज़रूरी नहीं कि अभी आपकी स्क्रीन पर यही पॉपअप दिख रहा हो।';

  @override
  String get companionNoSensitivePermsMsg =>
      'यह ऐप आपके फ़ोन पर कोई संवेदनशील अनुमति नहीं माँगता।';

  @override
  String get companionGuidedMatchTitle =>
      'स्क्रीन के पॉपअप में जो पूछा गया उससे मिलान करें';

  @override
  String get companionGuidedMatchSubtitle =>
      'Enprive आपके मौजूदा Android संकेत को सीधे नहीं पढ़ सकता। स्क्रीन पर जो दिखा उसके सबसे क़रीब वाला विकल्प चुनें:';

  @override
  String get companionSection1Title => '1. इस अनुमति का क्या अर्थ है';

  @override
  String get companionSection2Title => '2. ऐप आपके फ़ोन पर क्या माँगता है';

  @override
  String get companionSection3Title => '3. इसकी गोपनीयता नीति क्या कहती है';

  @override
  String get companionSection4Title =>
      '4. यह किसी सुविधा से क्यों जुड़ा हो सकता है';

  @override
  String get companionSection4Fallback =>
      'डेवलपर की ओर से सुविधा की कोई सत्यापित व्याख्या नहीं मिली। यदि आप चाहते हैं कि Deni प्रासंगिकता जाँचे, तो नीचे बताएँ कि आप कौन-सी सुविधा उपयोग कर रहे थे।';

  @override
  String get companionSection5Title => '5. क्या अभी अज्ञात है';

  @override
  String get companionSection6Title =>
      '6. वे प्रश्न जो आप Deni से पूछ सकते हैं';

  @override
  String get companionAddPolicyBtn => 'गोपनीयता नीति जोड़ें';

  @override
  String get companionCheckUpdatedPolicyBtn => 'अपडेटेड गोपनीयता नीति जाँचें';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return '$appName की नीति सत्यापित करें';
  }

  @override
  String get companionFeatureFieldLabel =>
      'आप कौन-सी सुविधा उपयोग कर रहे थे (वैकल्पिक)';

  @override
  String get companionFeatureFieldHint =>
      'जैसे: QR कोड स्कैन करना, वॉइस अभ्यास रिकॉर्ड करना';

  @override
  String get companionQuestionFieldLabel => 'Deni से प्रश्न पूछें';

  @override
  String get companionQuestionFieldHint =>
      'यदि मैं यह अनुमति अस्वीकार कर दूँ तो क्या होगा?';

  @override
  String get companionReceiptSavedTitle => 'Enprive रसीदों में सहेजा गया';

  @override
  String get companionReceiptUnsavedTitle =>
      'समीक्षा अभी Enprive में सहेजी नहीं गई';

  @override
  String get companionReceiptSavedBody =>
      'आपके Enprive रसीद संग्रह में स्थानीय रूप से सहेजा गया।';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      'अपडेट की गई नीति समीक्षा केवल इस सत्र में रखी गई है। साथी छोड़ने पर यह ड्राफ़्ट हट जाएगा और आपकी सहेजी गई रसीद वैसी ही रहेगी।';

  @override
  String get companionReceiptUnsavedBody =>
      'केवल इस सत्र में रखी गई है। जब तक आप इसे सहेजते नहीं, साथी छोड़ने पर यह हट जाएगी।';

  @override
  String get companionSaveReceiptBtn => 'रसीद Enprive में सहेजें';

  @override
  String get companionSaveReceiptFailed =>
      'रसीद सहेजी नहीं जा सकी। इस सत्र में रखी गई है: फिर प्रयास करें।';

  @override
  String get companionSavedLocalReceiptsSnack =>
      'स्थानीय रसीदों में सहेजा गया।';

  @override
  String companionDoneReturnToApp(String appName) {
    return 'पूर्ण · $appName पर लौटें';
  }

  @override
  String get companionDoneReturnToPrev => 'पूर्ण · पिछले ऐप पर लौटें';

  @override
  String get companionOpenFullAppBtn => 'पूरा Enprive ऐप खोलें';

  @override
  String get companionCloudTimeoutSnack =>
      'क्लाउड विश्लेषण में बहुत समय लगा और पूरा होने से पहले रोक दिया गया।';

  @override
  String get companionAnalysisCancelledSnack => 'विश्लेषण रद्द किया गया।';

  @override
  String get companionCloudAnswerTimeoutSnack =>
      'क्लाउड उत्तर का समय सुरक्षित रूप से समाप्त हो गया।';

  @override
  String get companionQuestionCancelledSnack => 'प्रश्न रद्द किया गया।';

  @override
  String get companionTileAddedSnack =>
      'Enprive Check Android त्वरित सेटिंग्स में जुड़ गया है।';

  @override
  String get companionTileAlreadyAddedSnack =>
      'Enprive Check पहले से आपकी त्वरित सेटिंग्स में है।';

  @override
  String get companionTileDeclinedSnack =>
      'टाइल अनुरोध खारिज किया गया। आप इसे कभी भी सेटिंग्स या त्वरित सेटिंग्स संपादन से जोड़ सकते हैं।';

  @override
  String get companionTileManualSnack =>
      'त्वरित सेटिंग्स को दो बार नीचे स्वाइप करें, संपादन पर टैप करें और Enprive Check को अपनी टाइल्स में खींचें।';

  @override
  String get companionTileUnavailableSnack =>
      'Android इस डिवाइस पर त्वरित सेटिंग्स संकेत नहीं दिखा सका। आप त्वरित सेटिंग्स संपादन से Enprive Check मैनुअल रूप से जोड़ सकते हैं।';

  @override
  String get companionUsageOptionalReason =>
      'उपयोग एक्सेस वैकल्पिक है। आप ऐप को मैनुअल चुन सकते हैं या एक-टैप पहचान के लिए उपयोग एक्सेस की अनुमति दे सकते हैं।';

  @override
  String get companionPermPreciseLocation => 'सटीक स्थान';

  @override
  String get companionPermBackgroundLocation => 'बैकग्राउंड स्थान';

  @override
  String get companionPermCamera => 'कैमरा';

  @override
  String get companionPermMicrophone => 'माइक्रोफ़ोन';

  @override
  String get companionPermAdId => 'Google विज्ञापन ID';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return '$appName द्वारा घोषित Android अनुमति ($permission)।';
  }

  @override
  String get companionPermStatusAdId => 'ऐप में सूचीबद्ध · विज्ञापन ID';

  @override
  String get companionPermStatusAllowed => 'ऐप में सूचीबद्ध · अनुमत';

  @override
  String get companionPermStatusNotAllowed => 'ऐप में सूचीबद्ध · अनुमत नहीं';

  @override
  String get guidedCatLocation => 'स्थान';

  @override
  String get guidedCatContacts => 'संपर्क';

  @override
  String get guidedCatPhotosMedia => 'फ़ोटो और मीडिया';

  @override
  String get guidedCatNotifications => 'सूचनाएँ';

  @override
  String get guidedCatNearbyDevices => 'आस-पास के डिवाइस';

  @override
  String get guidedCatCalendar => 'कैलेंडर';

  @override
  String get guidedCatPhone => 'फ़ोन';

  @override
  String get guidedCatSms => 'SMS';

  @override
  String get companionFallbackUsageNotEnabled =>
      'Android सेटिंग्स में उपयोग एक्सेस चालू नहीं किया गया है।';

  @override
  String get companionFallbackUsageUnavailable =>
      'Android UsageStatsManager उपलब्ध नहीं है।';

  @override
  String get companionFallbackTransientUi =>
      'हाल की उपयोग गतिविधि में केवल Android सिस्टम या अनुमति पॉपअप दिखा; ऐप मैनुअल रूप से चुनें।';

  @override
  String get companionFallbackVisibilityRestricted =>
      'Android पैकेज दृश्यता प्रतिबंधों के कारण हालिया सक्रिय ऐप की जाँच नहीं हो सकी। कृपया सूची से ऐप चुनें या उसकी नीति पेस्ट करें।';

  @override
  String get companionFallbackUnlockRequired =>
      'ऐप संदर्भ देखने से पहले अपना डिवाइस अनलॉक करें।';

  @override
  String get consentReasonPolicyTooDetailed =>
      'ऑन-डिवाइस AI प्रसंस्करण के लिए यह नीति बहुत लंबी है।';

  @override
  String get consentReasonExcerptTooDetailed =>
      'ऑन-डिवाइस AI प्रसंस्करण के लिए यह अंश बहुत लंबा है।';

  @override
  String get consentReasonOnDeviceUnavailable =>
      'इस फ़ोन पर अभी ऑन-डिवाइस AI उपलब्ध नहीं है।';

  @override
  String get consentReasonOnDeviceCannotAnswer =>
      'ऑन-डिवाइस AI अभी इस डिवाइस से उत्तर नहीं दे सका।';

  @override
  String get consentReasonVoiceTooLong =>
      'ये सत्यापित निष्कर्ष ऑन-डिवाइस सारांश की सीमा से अधिक हैं। आप अभी ऑफ़लाइन सारांश उपयोग कर सकते हैं या एक बार के लिए संपादित निष्कर्ष क्लाउड AI को भेज सकते हैं।';

  @override
  String get consentReasonVoiceUnavailable =>
      'इस फ़ोन पर अभी ऑन-डिवाइस AI उपलब्ध नहीं है। Enprive का ऑफ़लाइन सरल सारांश दिखाया जा रहा है।';

  @override
  String get consentReasonVoiceTimedOut =>
      'ऑन-डिवाइस सारांश का समय समाप्त हो गया। Enprive का ऑफ़लाइन सरल सारांश दिखाया जा रहा है।';

  @override
  String get unsavedExitTitle => 'क्या यह गोपनीयता समीक्षा सहेजें?';

  @override
  String get unsavedExitModifiedBody =>
      'यह स्क्रीन बंद करने पर बिना सहेजी गई समीक्षाएँ हट जाती हैं, इसलिए आपकी मर्ज़ी के बिना फ़ोन पर कुछ नहीं सहेजा जाता। आपकी मूल सहेजी गई रसीद वैसी ही रहेगी।';

  @override
  String get unsavedExitDraftBody =>
      'यह स्क्रीन बंद करने पर बिना सहेजी गई समीक्षाएँ हट जाती हैं, इसलिए आपकी मर्ज़ी के बिना फ़ोन पर कुछ नहीं सहेजा जाता।';

  @override
  String get unsavedExitDiscardBtn => 'बिना सहेजे हटाएँ';

  @override
  String get unsavedExitContinueBtn => 'समीक्षा जारी रखें';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return '$title की गोपनीयता नीति अपडेट करें';
  }

  @override
  String get reviewSaveFailedError =>
      'रसीद सहेजी नहीं जा सकी। आपका समीक्षा ड्राफ़्ट अभी भी खुला है।';

  @override
  String get reviewRemovedFromReceiptsSnack => 'सहेजी गई रसीदों से हटाया गया।';

  @override
  String get reviewRemoveFailedSnack => 'सहेजी गई रसीद हटाई नहीं जा सकी।';

  @override
  String get reviewModifiedDraftTitle => 'सहेजी गई रसीद से नया ड्राफ़्ट';

  @override
  String get reviewModifiedDraftBody =>
      'इस अपडेटेड समीक्षा को रखने के लिए रसीदों में सहेजें: आपकी मूल सहेजी गई रसीद वैसी ही रहेगी।';

  @override
  String get btnRetrySave => 'फिर से सहेजें';

  @override
  String samplePermissionsHeader(String badge) {
    return 'नमूना अनुमतियाँ ($badge)';
  }

  @override
  String get sourceKindUrl => 'सार्वजनिक वेब लिंक';

  @override
  String get sourceKindPdf => 'स्थानीय PDF फ़ाइल';

  @override
  String get sourceKindDocx => 'स्थानीय Word (DOCX) फ़ाइल';

  @override
  String get sourceKindTextFile => 'स्थानीय टेक्स्ट फ़ाइल';

  @override
  String get sourceKindSharedText => 'साझा किया गया टेक्स्ट';

  @override
  String get sourceKindSelectedText => 'चुना गया टेक्स्ट';

  @override
  String get sourceKindSampleApp => 'नमूना ऐप';

  @override
  String get sourceKindPhonePermissions => 'फ़ोन की अनुमतियाँ';

  @override
  String get sourceKindPastedText => 'पेस्ट किया गया टेक्स्ट';

  @override
  String get extractionStatusExtracted => 'इस फ़ोन पर पढ़ा गया';

  @override
  String get extractionStatusNone => 'इस फ़ोन पर दिया गया';

  @override
  String get extractionStatusUnsupported => 'असमर्थित फ़ाइल प्रकार';

  @override
  String get extractionStatusTooLarge => 'फ़ाइल बहुत बड़ी है';

  @override
  String get extractionStatusEmpty => 'पढ़ने योग्य टेक्स्ट नहीं मिला';

  @override
  String get extractionStatusReadError => 'फ़ाइल पढ़ी नहीं जा सकी';

  @override
  String get extractionStatusPasswordProtected => 'पासवर्ड से सुरक्षित';

  @override
  String get extractionStatusPermissionDenied => 'अनुमति अस्वीकृत';

  @override
  String get extractionStatusCancelled => 'रद्द किया गया';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return 'जाँच का समय: $timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return 'मुख्य URL: $url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return 'यहाँ से रीडायरेक्ट हुआ: $url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return 'फ़ाइल: $filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return 'स्थिति: $status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return 'SHA-256 स्रोत हैश: $hash';
  }

  @override
  String get semanticsPrimaryNavigation => 'मुख्य नेविगेशन';

  @override
  String semanticsProcessingLocation(String label) {
    return 'प्रसंस्करण स्थान: $label';
  }

  @override
  String get semanticsDeniMascot => 'Deni, आपका गोपनीयता मार्गदर्शक';

  @override
  String get quoteCollapsibleDefaultHeader => 'नीति का सटीक अंश';
}
