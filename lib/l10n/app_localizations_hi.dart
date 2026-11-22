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
      'One or more policy parts or phone permissions need a closer look.';

  @override
  String get stateInsufficientEvidence => 'अपर्याप्त साक्ष्य';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'We need more privacy policy text before we can check what this app does.';

  @override
  String get chipOnDevice => 'इस डिवाइस पर';

  @override
  String get chipInCloud => 'क्लाउड में';

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
      'To check this in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Your phone shows whether this permission is allowed. It does not prove whether the app actually accessed or sent data.';

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
      'Highlights data sharing, voice recording, and how long data is kept using exact quotes.';

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
      other: '$count matched quotes',
      one: '1 matched quote',
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
  String get readinessRow3Title => 'Personal details hidden';

  @override
  String get readinessRow3Desc =>
      'If you choose cloud help, names, emails, and phone numbers are hidden before anything is sent.';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get privateAnalysisTitle => 'इस फ़ोन पर निजी विश्लेषण';

  @override
  String get onDeviceReadyMsg => 'ऑन-डिवाइस AI सक्रिय और तैयार है।';

  @override
  String get localScannerProtectedMsg =>
      'Ready to check policies offline on this phone.';

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
      'On-device AI is ready on this phone. Reviews stay completely on your device.';

  @override
  String get modelDownloadingMsg =>
      'पृष्ठभूमि में निजी ऑन-डिवाइस मॉडल डाउनलोड हो रहा है।';

  @override
  String get modelDownloadableMsg =>
      'Wi-Fi पर ऑन-डिवाइस मॉडल डाउनलोड किया जा सकता है।';

  @override
  String get localScannerDefaultMsg =>
      'This phone checks policies offline on your device by default.';

  @override
  String get preparingPrivateAnalysis => 'निजी विश्लेषण तैयार किया जा रहा है…';

  @override
  String get onDeviceAiReadyTitle => 'ऑन-डिवाइस AI तैयार';

  @override
  String get localScannerActiveTitle => 'Offline check ready';

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
      other: '$count चरण',
      one: '1 चरण',
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
  String get analysisTraceDefaultTitle => 'इस समीक्षा की जांच कैसे हुई';

  @override
  String get savedToLocalReceiptsSnack => 'आपकी स्थानीय रसीदों में सहेजा गया।';

  @override
  String get snapshotSheetTitle => 'Reviewed policy text';

  @override
  String get snapshotSourcePrefix => 'स्रोत';

  @override
  String get snapshotReviewedPrefix => 'समीक्षित';

  @override
  String get snapshotDigestPrefix => 'Document fingerprint';

  @override
  String get statFindings => 'निष्कर्ष';

  @override
  String get statVerified => 'सत्यापित';

  @override
  String get statOsGranted => 'Allowed on phone';

  @override
  String get statUnverified => 'Not found';

  @override
  String get keyFindingsTitle => 'मुख्य निष्कर्ष';

  @override
  String get reviewedExcerptTitle => 'समीक्षित अंश';

  @override
  String get permissionsOnPhoneTitle => 'इस फ़ोन पर अनुमतियाँ';

  @override
  String get viewReviewedSnapshot => 'View reviewed policy text';

  @override
  String get btnSavedToReceipts => 'रसीदों में सहेजा गया';

  @override
  String get observedOnPhoneLabel => 'Seen on this phone';

  @override
  String get quoteVerifiedLabel => 'Exact quote from policy';

  @override
  String get unverifiedClaimLabel => 'Not found in policy';

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
  String get labelWhatRemainsUnknown => 'What we still don\'t know';

  @override
  String get presetQuestionMeaning => 'मेरे बच्चे के लिए इसका क्या अर्थ है?';

  @override
  String get presetQuestionOptOut => 'क्या हम इसे बंद या अस्वीकार कर सकते हैं?';

  @override
  String get presetQuestionUnknown => 'यहाँ अभी भी क्या स्पष्ट नहीं है?';

  @override
  String get readingCitedClause => 'Reading the policy quote…';

  @override
  String get deniAnswerTitle => 'Deni का उत्तर';

  @override
  String get stepsAndReasoning => 'How Deni checked this';

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
  String get sampleSyntheticBadge => 'Sample app';

  @override
  String get permissionInspectionTitle => 'Phone permissions checked';

  @override
  String get addAppPrivacyPolicyBtn => 'इस ऐप की गोपनीयता नीति जोड़ें';

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
  String get checkingPolicyWithCloudAi =>
      'क्लाउड AI से नीति की जाँच हो रही है।';

  @override
  String get preparingCloudAiStream =>
      'Hiding personal details before cloud check…';

  @override
  String get cancellingAnalysis => 'रद्द किया जा रहा है…';

  @override
  String get analysisCancelledNotice => 'समीक्षा रद्द कर दी गई।';

  @override
  String get cloudTimedOutNotice =>
      'क्लाउड AI ने उत्तर देने में समय समाप्त कर दिया। कोई स्वचालित पुनः प्रयास नहीं किया गया।';

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
}
