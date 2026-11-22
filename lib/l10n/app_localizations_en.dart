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
      'No concern identified in the reviewed evidence. This is not a safety certification.';

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
  String get chipOfflineDeterministic => 'Offline local scan';

  @override
  String get chipUnknown => 'Processing source unknown';

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
      'To analyse this text in the cloud, Enprive will send only the redacted text shown above to Firebase AI Logic. Your installed-app list and Android permission observations will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Android reports this permission state on this phone. It does not prove whether the app actually accessed or transmitted data.';

  @override
  String get navHome => 'Home';

  @override
  String get navCheck => 'Check';

  @override
  String get navReceipts => 'Receipts';

  @override
  String get navLearn => 'Learn';

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
  String get splashQuote => 'Know what you\'re agreeing to';

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
  String get reviewingOnPhone => 'Reviewing on this phone.';

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

  @override
  String get sampleSyntheticBadge => 'Synthetic example';

  @override
  String get permissionInspectionTitle => 'Device Permission Inspection';

  @override
  String get addAppPrivacyPolicyBtn => 'Add this app\'s privacy policy';

  @override
  String get snapshotDigestLabel => 'Snapshot digest · FNV-1a 64-bit';

  @override
  String get snapshotDigestExplanation =>
      'A fast 64-bit local fingerprint of this text (not cryptographic SHA-256). Changing any character produces a different digest.';

  @override
  String get copyDigestBtn => 'Copy digest';

  @override
  String get digestCopiedMsg => 'Snapshot digest copied';

  @override
  String get permissionGrantedBadge => 'Granted';

  @override
  String get permissionNotGrantedBadge => 'Not granted';

  @override
  String get checkingPolicyWithCloudAi => 'Checking policy with cloud AI.';

  @override
  String get preparingCloudAiStream => 'Preparing redacted cloud verification…';

  @override
  String get cancellingAnalysis => 'Cancelling…';

  @override
  String get analysisCancelledNotice => 'Review cancelled.';

  @override
  String get cloudTimedOutNotice =>
      'Cloud AI timed out before responding. No automatic retry was sent.';

  @override
  String get cloudFallbackBannerTitle =>
      'Cloud AI unavailable — local scan shown';

  @override
  String get cloudFallbackBannerBody =>
      'Cloud analysis was unavailable, so this result came from Enprive’s local deterministic scanner.';

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
  String receiptDeletedSnack(String title) {
    return 'Deleted $title';
  }

  @override
  String get btnUndo => 'Undo';

  @override
  String get readinessPromiseMaskedTitle => 'Personal details hidden';

  @override
  String get readinessPromiseMaskedLine =>
      'If you choose cloud, names, emails and numbers are masked first.';

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

  @override
  String get linkInstalledAppBtn => 'Link an installed app';

  @override
  String get linkInstalledAppCardTitle => 'Compare with an app on this phone';

  @override
  String get linkInstalledAppCardBody =>
      'Pick an installed app to compare its Android permissions with this policy in the same review. Your app list stays on this phone.';

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
      'Android shows permission settings on this phone only. This comparison is a prompt to look closer, never proof of wrongdoing or that data was sent.';

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
    return 'Android lists $requestedCount permissions ($grantedCount allowed) for $appName, with none in the sensitive categories checked here (location, camera, microphone, contacts, photos, or ad ID).';
  }
}
