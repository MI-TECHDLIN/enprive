// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => 'Evidence-first app privacy reviews';

  @override
  String get homePrivacySubtitle => 'Your reviews stay on this phone.';

  @override
  String get stateNoConcern => 'No concern identified';

  @override
  String get stateNoConcernSubtitle =>
      'Nothing concerning in the reviewed evidence. This is not a safety certification.';

  @override
  String get stateReviewRecommended => 'Review recommended';

  @override
  String get stateReviewRecommendedSubtitle =>
      'One or more passages or permission mismatches deserve a human look.';

  @override
  String get stateInsufficientEvidence => 'Insufficient evidence';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Evidence is missing, unavailable, or could not be verified on this device.';

  @override
  String get chipOnDevice => 'On this device';

  @override
  String get chipInCloud => 'In the cloud';

  @override
  String get chipLocationUnavailable => 'Processing location unavailable';

  @override
  String get statusSourceMatched => 'Source matched';

  @override
  String get statusDeviceObserved => 'Device observed';

  @override
  String get statusInterpretation => 'Interpretation';

  @override
  String get statusUnverified => 'Unverified';

  @override
  String get statusStale => 'Outdated / Stale';

  @override
  String get btnCheckApp => 'Check an app';

  @override
  String get btnPasteTerms => 'Paste terms or URL';

  @override
  String get btnWhyThisFinding => 'Why this finding?';

  @override
  String get btnSaveToReceipts => 'Save to Receipts';

  @override
  String get btnDiscard => 'Discard';

  @override
  String get btnAskDeni => 'Ask Deni';

  @override
  String get btnUseCloud => 'Use cloud for this check';

  @override
  String get btnReviewManually => 'Review manually';

  @override
  String get btnGetStarted => 'Get started';

  @override
  String get btnContinue => 'Continue';

  @override
  String get deniIntro =>
      'Hi, I\'m Deni. I can help you understand what this policy says, show you the evidence behind a concern, and explain what Enprive could not verify.';

  @override
  String get cloudConsentDisclosure =>
      'To analyse this text in the cloud, Enprive will send only the text shown below to Firebase AI Logic. Your installed-app list and Android permission observations will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Android reports this permission state on this phone. It does not prove whether the app actually accessed or transmitted data.';

  @override
  String get navHome => 'Home';

  @override
  String get navReceipts => 'Receipts';

  @override
  String get navSettings => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get languageSubtitle =>
      'Applies to app interface, explanations, and voice read-aloud';

  @override
  String get homeHeroHeadline => 'A clearer look at the\napps children use';

  @override
  String get trySampleCheck => 'Try a sample app check';

  @override
  String get eduTrackSubtitle => 'Homework & attendance';

  @override
  String get eduTrackValue => '3 requests';

  @override
  String get eduTrackTrend => 'Review';

  @override
  String get calmMathSubtitle => 'Offline math practice';

  @override
  String get calmMathValue => '0 sensitive';

  @override
  String get calmMathTrend => 'Minimal';

  @override
  String get whatWeCheckTitle => 'What we check for';

  @override
  String get checkQuoteTitle => 'Exact policy quotes';

  @override
  String get checkQuoteDesc =>
      'Flags sharing, voice recording, and retention with verbatim quotes.';

  @override
  String get checkPermissionTitle => 'Phone permission mismatches';

  @override
  String get checkPermissionDesc =>
      'Compares Camera, Mic, and Location access against what the policy claims.';

  @override
  String get checkSelectTitle => 'Select text anywhere';

  @override
  String get checkSelectDesc =>
      'Highlight terms in any app and tap Enprive Check from Android’s menu.';

  @override
  String get recentlyReviewed => 'Recently reviewed';

  @override
  String verifiedClausesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verified clauses',
      one: '1 verified clause',
    );
    return '$_temp0';
  }

  @override
  String get trySampleText => 'Try sample text';

  @override
  String get modePasteText => 'Paste text';

  @override
  String get modePolicyLink => 'Policy link';

  @override
  String get hintAppName => 'App name';

  @override
  String get defaultSubjectTitle => 'Privacy Policy';

  @override
  String get selectedExcerptTitle => 'Selected Policy Excerpt';

  @override
  String get hintPastePolicy => 'Paste privacy policy text here…';

  @override
  String get btnReviewOnPhone => 'Review on this phone';

  @override
  String get onboardingIntroHeadline => 'Hi, I\'m Deni. 👋';

  @override
  String get onboardingIntroLead =>
      'Let\'s make app privacy easier to understand.';

  @override
  String get onboardingIntroBody =>
      'I\'ll help you uncover what an app\'s privacy policy really says, highlight the exact passages that matter, and explain what your device reports.\n\nNo guessing. No false promises. Just clear explanations and evidence to help you make informed decisions.';

  @override
  String get onboardingIntroFooter => 'Know what you\'re agreeing to.';

  @override
  String get onboardingStep1Question => 'How should I explain\nprivacy terms?';

  @override
  String get depthQuickMultiline => 'Quick &\nplain';

  @override
  String get depthBalancedMultiline => 'Balanced\nview';

  @override
  String get depthFullMultiline => 'Full\ndetail';

  @override
  String get onboardingReadinessTitle => 'Private by default\non this phone';

  @override
  String get onboardingReadinessSubtitle =>
      'Designed so parents and teachers can inspect apps without sharing device data.';

  @override
  String get readinessRow1Title => 'Checked here first';

  @override
  String get readinessRow1Desc =>
      'Policies are read on your phone before anything else.';

  @override
  String get readinessRow2Title => 'Your apps stay yours';

  @override
  String get readinessRow2Desc =>
      'The apps on this phone and their permissions never leave it.';

  @override
  String get readinessRow3Title => 'Personal details scrubbed';

  @override
  String get readinessRow3Desc =>
      'If on-device AI isn’t available or a policy is long, names, emails, and phone numbers become placeholders before App Check verification.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get privateAnalysisTitle => 'Private analysis on this phone';

  @override
  String get onDeviceReadyMsg => 'On-device AI is active and ready.';

  @override
  String get localScannerProtectedMsg =>
      'Protected by built-in local clause scanning.';

  @override
  String get statusChecking => 'Checking…';

  @override
  String get btnCheckReadiness => 'Check readiness';

  @override
  String get howShouldDeniExplain => 'How should Deni explain things?';

  @override
  String get depthQuick => 'Quick';

  @override
  String get depthBalanced => 'Balanced';

  @override
  String get depthFull => 'Full detail';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get meetDeniGuide => 'Meet Deni & setup guide';

  @override
  String clearSavedReceiptsCount(int count) {
    return 'Clear saved receipts ($count)';
  }

  @override
  String get btnClear => 'Clear';

  @override
  String get confirmClearReceiptsTitle => 'Clear saved receipts?';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This removes $count saved reviews from your phone.',
      one: 'This removes 1 saved review from your phone.',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'Cancel';

  @override
  String get receiptsTitle => 'Receipts';

  @override
  String get tooltipSearch => 'Search';

  @override
  String get hintSearchReceipts => 'Search saved reviews...';

  @override
  String get filterAll => 'All';

  @override
  String get filterReview => 'Review';

  @override
  String get filterNoConcern => 'No concern';

  @override
  String get emptyFilteredTitle => 'No matching receipts';

  @override
  String get emptyReceiptsTitle => 'No saved receipts yet';

  @override
  String get emptyFilteredBody => 'Try selecting another filter above.';

  @override
  String get emptyReceiptsBody =>
      'Bookmark any app review to keep a private copy on your phone.';

  @override
  String get btnStartReview => 'Start a review';

  @override
  String get btnOpenReceipt => 'Open receipt';

  @override
  String get btnDelete => 'Delete';

  @override
  String get checkingPhoneReadiness =>
      'Checking private analysis readiness on this phone…';

  @override
  String get geminiNanoReadyMsg =>
      'Gemini Nano is ready on this phone. Reviews stay completely on your device.';

  @override
  String get modelDownloadingMsg =>
      'Downloading private on-device model in the background.';

  @override
  String get modelDownloadableMsg =>
      'On-device model can be downloaded over Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'This phone uses Enprive’s built-in local clause scanner by default.';

  @override
  String get preparingPrivateAnalysis => 'Preparing private analysis…';

  @override
  String get onDeviceAiReadyTitle => 'On-device AI ready';

  @override
  String get localScannerActiveTitle => 'Local scanner active';

  @override
  String get privateAnalysisSheetSubtitle =>
      'Your installed apps and permission checks never leave your phone.';

  @override
  String get btnDone => 'Done';

  @override
  String get btnCheckAgain => 'Check again';

  @override
  String get reviewingOnPhone => 'Reviewing on this phone…';

  @override
  String get readingClausesInitial => 'Reading policy clauses on this phone…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current of $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get thoughtSignaturePrefix => 'Thought signature';

  @override
  String get viewStreamedThoughts => 'View streamed thoughts';

  @override
  String get hideStreamedThoughts => 'Hide streamed thoughts';

  @override
  String get analysisTraceDefaultTitle => 'How this review was checked';

  @override
  String get savedToLocalReceiptsSnack => 'Saved to your local receipts.';

  @override
  String get snapshotSheetTitle => 'Reviewed policy snapshot';

  @override
  String get snapshotSourcePrefix => 'Source';

  @override
  String get snapshotReviewedPrefix => 'Reviewed';

  @override
  String get snapshotDigestPrefix => 'Digest';

  @override
  String get statFindings => 'Findings';

  @override
  String get statVerified => 'Verified';

  @override
  String get statOsGranted => 'OS Granted';

  @override
  String get statUnverified => 'Unverified';

  @override
  String get keyFindingsTitle => 'Key Findings';

  @override
  String get reviewedExcerptTitle => 'Reviewed Excerpt';

  @override
  String get permissionsOnPhoneTitle => 'Permissions on this phone';

  @override
  String get viewReviewedSnapshot => 'View reviewed policy snapshot';

  @override
  String get btnSavedToReceipts => 'Saved to Receipts';

  @override
  String get observedOnPhoneLabel => 'Observed on this phone';

  @override
  String get quoteVerifiedLabel => 'Quote verified in policy';

  @override
  String get unverifiedClaimLabel => 'Unverified claim';

  @override
  String get categoryDataCollection => 'Data Collection';

  @override
  String get categorySharing => 'Third-Party Sharing';

  @override
  String get categoryTracking => 'Location & Tracking';

  @override
  String get categoryRetention => 'Retention & Voice';

  @override
  String get categoryParentalControls => 'Parental Controls';

  @override
  String get labelInPlainLanguage => 'In plain language';

  @override
  String get labelOnThisPhone => 'On this phone';

  @override
  String get labelWhatRemainsUnknown => 'What remains unknown';

  @override
  String get presetQuestionMeaning => 'What does this mean for my child?';

  @override
  String get presetQuestionOptOut => 'Can we turn this off or opt out?';

  @override
  String get presetQuestionUnknown => 'What is still unknown here?';

  @override
  String get readingCitedClause => 'Reading cited policy clause…';

  @override
  String get deniAnswerTitle => 'Deni’s Answer';

  @override
  String get stepsAndReasoning => 'Steps & model reasoning';

  @override
  String get chooseReviewModeTitle => 'Choose how to review this text';

  @override
  String get cloudNeverSendsAppsNote =>
      'Installed apps and phone permissions are never sent.';

  @override
  String get tooltipClose => 'Close';

  @override
  String get checkAppSheetSubtitle =>
      'Checked locally on your phone. Your app list is never uploaded.';

  @override
  String get trySampleKidsApp => 'Try a sample kids app';

  @override
  String get sampleEduTrackSubtitle => 'Location, mic & camera';

  @override
  String get sampleCalmMathSubtitle => 'Offline math practice';

  @override
  String get appsOnThisPhone => 'Apps on this phone';

  @override
  String get hintSearchApps => 'Search apps…';

  @override
  String get noMatchingApps => 'No matching apps found on this phone.';
}
