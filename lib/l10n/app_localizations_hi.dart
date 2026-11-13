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
      'एक या अधिक अंश या अनुमति असंगतियाँ मानवीय जांच की माँग करती हैं।';

  @override
  String get stateInsufficientEvidence => 'अपर्याप्त साक्ष्य';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'साक्ष्य अनुपस्थित हैं, उपलब्ध नहीं हैं, या इस डिवाइस पर सत्यापित नहीं हो सके।';

  @override
  String get chipOnDevice => 'इस डिवाइस पर';

  @override
  String get chipInCloud => 'क्लाउड में';

  @override
  String get chipLocationUnavailable => 'प्रोसेसिंग स्थान उपलब्ध नहीं';

  @override
  String get statusSourceMatched => 'मूल पाठ से मेल';

  @override
  String get statusDeviceObserved => 'डिवाइस पर देखा गया';

  @override
  String get statusInterpretation => 'व्याख्या';

  @override
  String get statusUnverified => 'असत्यापित';

  @override
  String get statusStale => 'पुराना / अप्रचलित';

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
      'क्लाउड में इस पाठ का विश्लेषण करने के लिए, Enprive केवल नीचे दिखाया गया पाठ Firebase AI Logic को भेजेगा। आपके इंस्टॉल किए गए ऐप्स की सूची और Android अनुमतियाँ कभी नहीं भेजी जाएँगी।';

  @override
  String get permissionLimitationNotice =>
      'Android इस फ़ोन पर यह अनुमति स्थिति दिखाता है। यह साबित नहीं करता कि ऐप ने वास्तव में डेटा एक्सेस या प्रेषित किया है।';

  @override
  String get navHome => 'होम';

  @override
  String get navReceipts => 'रसीदें';

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
      'डेटा साझा करने, वॉइस रिकॉर्डिंग और संग्रहण शर्तों को मूल शब्दों के साथ दिखाता है।';

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
      other: '$count सत्यापित धाराएँ',
      one: '1 सत्यापित धारा',
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
  String get readinessRow3Title => 'व्यक्तिगत विवरण स्वत: छिपाए जाते हैं';

  @override
  String get readinessRow3Desc =>
      'यदि ऑन-डिवाइस AI उपलब्ध न हो या नीति लंबी हो, तो App Check सत्यापन से पहले नाम, ईमेल और फ़ोन नंबर हटा दिए जाते हैं।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get privateAnalysisTitle => 'इस फ़ोन पर निजी विश्लेषण';

  @override
  String get onDeviceReadyMsg => 'ऑन-डिवाइस AI सक्रिय और तैयार है।';

  @override
  String get localScannerProtectedMsg =>
      'अंतर्निहित स्थानीय शर्त स्कैनर द्वारा सुरक्षित।';

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
      'इस फ़ोन पर Gemini Nano तैयार है। समीक्षाएँ पूरी तरह आपके डिवाइस पर रहती हैं।';

  @override
  String get modelDownloadingMsg =>
      'पृष्ठभूमि में निजी ऑन-डिवाइस मॉडल डाउनलोड हो रहा है।';

  @override
  String get modelDownloadableMsg =>
      'Wi-Fi पर ऑन-डिवाइस मॉडल डाउनलोड किया जा सकता है।';

  @override
  String get localScannerDefaultMsg =>
      'यह फ़ोन डिफ़ॉल्ट रूप से Enprive के अंतर्निहित स्थानीय स्कैनर का उपयोग करता है।';

  @override
  String get preparingPrivateAnalysis => 'निजी विश्लेषण तैयार किया जा रहा है…';

  @override
  String get onDeviceAiReadyTitle => 'ऑन-डिवाइस AI तैयार';

  @override
  String get localScannerActiveTitle => 'स्थानीय स्कैनर सक्रिय';

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
  String get readingClausesInitial => 'इस फ़ोन पर नीति शर्तें पढ़ी जा रही हैं…';

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
  String get thoughtSignaturePrefix => 'विचार हस्ताक्षर';

  @override
  String get viewStreamedThoughts => 'तर्क प्रक्रिया देखें';

  @override
  String get hideStreamedThoughts => 'तर्क प्रक्रिया छिपाएँ';

  @override
  String get analysisTraceDefaultTitle => 'इस समीक्षा की जांच कैसे हुई';

  @override
  String get savedToLocalReceiptsSnack => 'आपकी स्थानीय रसीदों में सहेजा गया।';

  @override
  String get snapshotSheetTitle => 'समीक्षित नीति स्नैपशॉट';

  @override
  String get snapshotSourcePrefix => 'स्रोत';

  @override
  String get snapshotReviewedPrefix => 'समीक्षित';

  @override
  String get snapshotDigestPrefix => 'सारांश कोड';

  @override
  String get statFindings => 'निष्कर्ष';

  @override
  String get statVerified => 'सत्यापित';

  @override
  String get statOsGranted => 'OS द्वारा स्वीकृत';

  @override
  String get statUnverified => 'असत्यापित';

  @override
  String get keyFindingsTitle => 'मुख्य निष्कर्ष';

  @override
  String get reviewedExcerptTitle => 'समीक्षित अंश';

  @override
  String get permissionsOnPhoneTitle => 'इस फ़ोन पर अनुमतियाँ';

  @override
  String get viewReviewedSnapshot => 'समीक्षित नीति स्नैपशॉट देखें';

  @override
  String get btnSavedToReceipts => 'रसीदों में सहेजा गया';

  @override
  String get observedOnPhoneLabel => 'इस फ़ोन पर देखा गया';

  @override
  String get quoteVerifiedLabel => 'नीति में उद्धरण सत्यापित';

  @override
  String get unverifiedClaimLabel => 'असत्यापित दावा';

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
  String get labelWhatRemainsUnknown => 'क्या अभी भी अज्ञात है';

  @override
  String get presetQuestionMeaning => 'मेरे बच्चे के लिए इसका क्या अर्थ है?';

  @override
  String get presetQuestionOptOut => 'क्या हम इसे बंद या अस्वीकार कर सकते हैं?';

  @override
  String get presetQuestionUnknown => 'यहाँ अभी भी क्या स्पष्ट नहीं है?';

  @override
  String get readingCitedClause => 'उद्धृत नीति धारा पढ़ी जा रही है…';

  @override
  String get deniAnswerTitle => 'Deni का उत्तर';

  @override
  String get stepsAndReasoning => 'चरण और मॉडल तर्क';

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
}
