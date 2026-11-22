// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => 'Belegbasierte Datenschutzprüfungen für Apps';

  @override
  String get homePrivacySubtitle =>
      'Ihre Prüfungen bleiben auf diesem Smartphone.';

  @override
  String get stateNoConcern => 'Keine Auffälligkeit festgestellt';

  @override
  String get stateNoConcernSubtitle =>
      'Keine Auffälligkeiten in den geprüften Belegen. Dies ist keine Sicherheitszertifizierung.';

  @override
  String get stateReviewRecommended => 'Prüfung empfohlen';

  @override
  String get stateReviewRecommendedSubtitle =>
      'One or more policy parts or phone permissions need a closer look.';

  @override
  String get stateInsufficientEvidence => 'Unzureichende Belege';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'We need more privacy policy text before we can check what this app does.';

  @override
  String get chipOnDevice => 'Auf diesem Gerät';

  @override
  String get chipInCloud => 'In der Cloud';

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
  String get btnCheckApp => 'App prüfen';

  @override
  String get btnPasteTerms => 'Text oder URL einfügen';

  @override
  String get btnWhyThisFinding => 'Warum dieser Hinweis?';

  @override
  String get btnSaveToReceipts => 'In Belegen speichern';

  @override
  String get btnDiscard => 'Verwerfen';

  @override
  String get btnAskDeni => 'Deni fragen';

  @override
  String get btnUseCloud => 'Cloud für diese Prüfung nutzen';

  @override
  String get btnReviewManually => 'Manuell prüfen';

  @override
  String get btnGetStarted => 'Los geht\'s';

  @override
  String get btnContinue => 'Weiter';

  @override
  String get deniIntro =>
      'Hallo, ich bin Deni. Ich helfe Ihnen zu verstehen, was in dieser Datenschutzerklärung steht, zeige die genauen Belegstellen und erkläre, was Enprive nicht überprüfen konnte.';

  @override
  String get cloudConsentDisclosure =>
      'To check this in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Your phone shows whether this permission is allowed. It does not prove whether the app actually accessed or sent data.';

  @override
  String get navHome => 'Start';

  @override
  String get navCheck => 'Prüfen';

  @override
  String get navReceipts => 'Belege';

  @override
  String get navLearn => 'Lernen';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get chooseLanguage => 'Sprache wählen';

  @override
  String get languageSubtitle =>
      'Gilt für Oberfläche, Erklärungen und Sprachausgabe';

  @override
  String get homeHeroHeadline => 'Klarer Blick auf die\nApps für Kinder';

  @override
  String get trySampleCheck => 'Beispielprüfung testen';

  @override
  String get eduTrackSubtitle => 'Hausaufgaben & Anwesenheit';

  @override
  String get eduTrackValue => '3 Zugriffe';

  @override
  String get eduTrackTrend => 'Prüfen';

  @override
  String get calmMathSubtitle => 'Offline-Matheübung';

  @override
  String get calmMathValue => '0 sensibel';

  @override
  String get calmMathTrend => 'Minimal';

  @override
  String get whatWeCheckTitle => 'Worauf wir achten';

  @override
  String get checkQuoteTitle => 'Exakte Richtlinien-Zitate';

  @override
  String get checkQuoteDesc =>
      'Highlights data sharing, voice recording, and how long data is kept using exact quotes.';

  @override
  String get checkPermissionTitle => 'Abweichende App-Berechtigungen';

  @override
  String get checkPermissionDesc =>
      'Vergleicht Kamera-, Mikrofon- und Standortzugriff mit den Angaben in der Erklärung.';

  @override
  String get checkSelectTitle => 'Text überall markieren';

  @override
  String get checkSelectDesc =>
      'Markieren Sie Text in beliebigen Apps und tippen Sie im Android-Menü auf Enprive Check.';

  @override
  String get recentlyReviewed => 'Kürzlich geprüft';

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
  String get trySampleText => 'Beispieltext laden';

  @override
  String get modePasteText => 'Text einfügen';

  @override
  String get modePolicyLink => 'Richtlinien-Link';

  @override
  String get hintAppName => 'App-Name';

  @override
  String get defaultSubjectTitle => 'Datenschutzerklärung';

  @override
  String get selectedExcerptTitle => 'Ausgewählter Richtlinien-Auszug';

  @override
  String get hintPastePolicy => 'Datenschutzerklärung hier einfügen…';

  @override
  String get btnReviewOnPhone => 'Auf diesem Gerät prüfen';

  @override
  String get onboardingIntroHeadline => 'Hallo, ich bin Deni. 👋';

  @override
  String get onboardingIntroLead =>
      'Machen wir App-Datenschutz leichter verständlich.';

  @override
  String get onboardingIntroBody =>
      'Ich helfe Ihnen zu erkennen, was in der Datenschutzerklärung einer App wirklich steht, hebe die wichtigen Textstellen hervor und erkläre, was Ihr Gerät meldet.\n\nKein Raten. Keine falschen Versprechen. Nur klare Erklärungen und Belege für fundierte Entscheidungen.';

  @override
  String get onboardingIntroFooter => 'Wissen, worauf Sie sich einlassen.';

  @override
  String get splashQuote => 'Wissen, worauf Sie sich einlassen';

  @override
  String get onboardingStep1Question =>
      'Wie soll ich Datenschutz-\nhinweise erklären?';

  @override
  String get depthQuickMultiline => 'Kurz &\nverständlich';

  @override
  String get depthBalancedMultiline => 'Ausgewogene\nAnsicht';

  @override
  String get depthFullMultiline => 'Volle\nDetails';

  @override
  String get onboardingReadinessTitle =>
      'Standardmäßig privat\nauf diesem Gerät';

  @override
  String get onboardingReadinessSubtitle =>
      'Entwickelt, damit Eltern und Lehrkräfte Apps prüfen können, ohne Gerätedaten zu teilen.';

  @override
  String get readinessRow1Title => 'Zuerst lokal geprüft';

  @override
  String get readinessRow1Desc =>
      'Richtlinien werden zuerst direkt auf Ihrem Smartphone ausgewertet.';

  @override
  String get readinessRow2Title => 'Ihre Apps bleiben privat';

  @override
  String get readinessRow2Desc =>
      'Installierte Apps und ihre Berechtigungen verlassen dieses Telefon nie.';

  @override
  String get readinessRow3Title => 'Personal details hidden';

  @override
  String get readinessRow3Desc =>
      'If you choose cloud help, names, emails, and phone numbers are hidden before anything is sent.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get privateAnalysisTitle => 'Private Analyse auf diesem Gerät';

  @override
  String get onDeviceReadyMsg => 'Geräte-KI ist aktiv und bereit.';

  @override
  String get localScannerProtectedMsg =>
      'Ready to check policies offline on this phone.';

  @override
  String get statusChecking => 'Wird geprüft…';

  @override
  String get btnCheckReadiness => 'Bereitschaft prüfen';

  @override
  String get howShouldDeniExplain => 'Wie soll Deni Dinge erklären?';

  @override
  String get depthQuick => 'Kurz';

  @override
  String get depthBalanced => 'Ausgewogen';

  @override
  String get depthFull => 'Detailliert';

  @override
  String get preferencesSection => 'Präferenzen';

  @override
  String get meetDeniGuide => 'Deni kennenlernen & Einführung';

  @override
  String clearSavedReceiptsCount(int count) {
    return 'Gespeicherte Belege löschen ($count)';
  }

  @override
  String get btnClear => 'Löschen';

  @override
  String get confirmClearReceiptsTitle => 'Gespeicherte Belege löschen?';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Dadurch werden $count gespeicherte Prüfungen von diesem Telefon entfernt.',
      one: 'Dadurch wird 1 gespeicherte Prüfung von diesem Telefon entfernt.',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'Abbrechen';

  @override
  String get receiptsTitle => 'Belege';

  @override
  String get tooltipSearch => 'Suchen';

  @override
  String get hintSearchReceipts => 'Gespeicherte Prüfungen durchsuchen...';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterReview => 'Prüfen';

  @override
  String get filterNoConcern => 'Unauffällig';

  @override
  String get emptyFilteredTitle => 'Keine passenden Belege';

  @override
  String get emptyReceiptsTitle => 'Noch keine Belege gespeichert';

  @override
  String get emptyFilteredBody => 'Wählen Sie oben einen anderen Filter aus.';

  @override
  String get emptyReceiptsBody =>
      'Setzen Sie ein Lesezeichen bei einer Prüfung, um eine private Kopie lokal zu speichern.';

  @override
  String get btnStartReview => 'Prüfung starten';

  @override
  String get btnOpenReceipt => 'Beleg öffnen';

  @override
  String get btnDelete => 'Löschen';

  @override
  String get checkingPhoneReadiness =>
      'Bereitschaft für private Analyse auf diesem Gerät wird geprüft…';

  @override
  String get geminiNanoReadyMsg =>
      'On-device AI is ready on this phone. Reviews stay completely on your device.';

  @override
  String get modelDownloadingMsg =>
      'Privates Gerätemodell wird im Hintergrund heruntergeladen.';

  @override
  String get modelDownloadableMsg =>
      'Das Gerätemodell kann über WLAN heruntergeladen werden.';

  @override
  String get localScannerDefaultMsg =>
      'This phone checks policies offline on your device by default.';

  @override
  String get preparingPrivateAnalysis => 'Private Analyse wird vorbereitet…';

  @override
  String get onDeviceAiReadyTitle => 'Geräte-KI bereit';

  @override
  String get localScannerActiveTitle => 'Offline check ready';

  @override
  String get privateAnalysisSheetSubtitle =>
      'Ihre installierten Apps und Berechtigungsprüfungen verlassen niemals Ihr Gerät.';

  @override
  String get btnDone => 'Fertig';

  @override
  String get btnCheckAgain => 'Erneut prüfen';

  @override
  String get reviewingOnPhone => 'Wird auf diesem Gerät geprüft…';

  @override
  String get readingClausesInitial => 'Reading policy text on this phone…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current von $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schritte',
      one: '1 Schritt',
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
  String get analysisTraceDefaultTitle => 'Wie diese Prüfung verifiziert wurde';

  @override
  String get savedToLocalReceiptsSnack => 'In lokalen Belegen gespeichert.';

  @override
  String get snapshotSheetTitle => 'Reviewed policy text';

  @override
  String get snapshotSourcePrefix => 'Quelle';

  @override
  String get snapshotReviewedPrefix => 'Geprüft';

  @override
  String get snapshotDigestPrefix => 'Document fingerprint';

  @override
  String get statFindings => 'Hinweise';

  @override
  String get statVerified => 'Verifiziert';

  @override
  String get statOsGranted => 'Allowed on phone';

  @override
  String get statUnverified => 'Not found';

  @override
  String get keyFindingsTitle => 'Wichtige Hinweise';

  @override
  String get reviewedExcerptTitle => 'Geprüfter Auszug';

  @override
  String get permissionsOnPhoneTitle => 'Berechtigungen auf diesem Gerät';

  @override
  String get viewReviewedSnapshot => 'View reviewed policy text';

  @override
  String get btnSavedToReceipts => 'In Belegen gespeichert';

  @override
  String get observedOnPhoneLabel => 'Seen on this phone';

  @override
  String get quoteVerifiedLabel => 'Exact quote from policy';

  @override
  String get unverifiedClaimLabel => 'Not found in policy';

  @override
  String get categoryDataCollection => 'Datenerhebung';

  @override
  String get categorySharing => 'Weitergabe an Dritte';

  @override
  String get categoryTracking => 'Standort & Tracking';

  @override
  String get categoryRetention => 'Speicherung & Sprache';

  @override
  String get categoryParentalControls => 'Kindersicherung';

  @override
  String get labelInPlainLanguage => 'Einfach erklärt';

  @override
  String get labelOnThisPhone => 'Auf diesem Gerät';

  @override
  String get labelWhatRemainsUnknown => 'What we still don\'t know';

  @override
  String get presetQuestionMeaning => 'Was bedeutet das für mein Kind?';

  @override
  String get presetQuestionOptOut =>
      'Lässt sich das abschalten oder widersprechen?';

  @override
  String get presetQuestionUnknown => 'Was bleibt hierbei unklar?';

  @override
  String get readingCitedClause => 'Reading the policy quote…';

  @override
  String get deniAnswerTitle => 'Denis Antwort';

  @override
  String get stepsAndReasoning => 'How Deni checked this';

  @override
  String get chooseReviewModeTitle => 'Prüfmethode für diesen Text wählen';

  @override
  String get cloudNeverSendsAppsNote =>
      'Installierte Apps und Telefonberechtigungen werden niemals gesendet.';

  @override
  String get tooltipClose => 'Schließen';

  @override
  String get checkAppSheetSubtitle =>
      'Lokal auf diesem Telefon geprüft. Ihre App-Liste wird niemals hochgeladen.';

  @override
  String get trySampleKidsApp => 'Beispiel-Kinder-App testen';

  @override
  String get sampleEduTrackSubtitle => 'Standort, Mikrofon & Kamera';

  @override
  String get sampleCalmMathSubtitle => 'Offline-Matheübung';

  @override
  String get appsOnThisPhone => 'Apps auf diesem Gerät';

  @override
  String get hintSearchApps => 'Apps suchen…';

  @override
  String get noMatchingApps =>
      'Keine passenden Apps auf diesem Gerät gefunden.';

  @override
  String get sampleSyntheticBadge => 'Sample app';

  @override
  String get permissionInspectionTitle => 'Phone permissions checked';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Datenschutzerklärung dieser App hinzufügen';

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
      'Richtlinie wird mit Cloud-KI geprüft.';

  @override
  String get preparingCloudAiStream =>
      'Hiding personal details before cloud check…';

  @override
  String get cancellingAnalysis => 'Wird abgebrochen…';

  @override
  String get analysisCancelledNotice => 'Prüfung abgebrochen.';

  @override
  String get cloudTimedOutNotice =>
      'Cloud-KI hat nicht rechtzeitig geantwortet. Es wurde kein automatischer Neuversuch gestartet.';

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
