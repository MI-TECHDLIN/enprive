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
      'Mindestens eine Textstelle oder Berechtigungsabweichung sollte genauer geprüft werden.';

  @override
  String get stateInsufficientEvidence => 'Unzureichende Belege';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Belege fehlen, sind nicht verfügbar oder konnten auf diesem Gerät nicht verifiziert werden.';

  @override
  String get chipOnDevice => 'Auf diesem Gerät';

  @override
  String get chipInCloud => 'In der Cloud';

  @override
  String get chipLocationUnavailable => 'Verarbeitungsort nicht verfügbar';

  @override
  String get chipOfflineDeterministic => 'Lokaler Offline-Scan';

  @override
  String get chipUnknown => 'Verarbeitungsquelle unbekannt';

  @override
  String get statusSourceMatched => 'Zitat bestätigt';

  @override
  String get statusDeviceObserved => 'Auf dem Gerät erkannt';

  @override
  String get statusInterpretation => 'Einordnung';

  @override
  String get statusUnverified => 'Nicht verifiziert';

  @override
  String get statusStale => 'Veraltet';

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
      'Für die Analyse in der Cloud sendet Enprive ausschließlich den oben gezeigten bereinigten Text an Firebase AI Logic. Ihre Liste installierter Apps und Android-Berechtigungen werden niemals gesendet.';

  @override
  String get permissionLimitationNotice =>
      'Android meldet diesen Berechtigungsstatus auf diesem Telefon. Das beweist nicht, ob die App tatsächlich auf Daten zugegriffen oder diese übertragen hat.';

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
      'Markiert Weitergabe, Sprachaufnahmen und Speicherdauer mit wörtlichen Zitaten.';

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
      other: '$count verifizierte Klauseln',
      one: '1 verifizierte Klausel',
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
  String get readinessRow3Title => 'Persönliche Daten geschwärzt';

  @override
  String get readinessRow3Desc =>
      'Falls lokale KI fehlt oder der Text lang ist, werden Namen, E-Mails und Telefonnummern vor der App-Check-Prüfung ersetzt.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get privateAnalysisTitle => 'Private Analyse auf diesem Gerät';

  @override
  String get onDeviceReadyMsg => 'Geräte-KI ist aktiv und bereit.';

  @override
  String get localScannerProtectedMsg =>
      'Geschützt durch integrierten lokalen Klausel-Scanner.';

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
      'Gemini Nano ist auf diesem Gerät bereit. Prüfungen bleiben komplett lokal.';

  @override
  String get modelDownloadingMsg =>
      'Privates Gerätemodell wird im Hintergrund heruntergeladen.';

  @override
  String get modelDownloadableMsg =>
      'Das Gerätemodell kann über WLAN heruntergeladen werden.';

  @override
  String get localScannerDefaultMsg =>
      'Dieses Telefon nutzt standardmäßig den integrierten lokalen Klausel-Scanner von Enprive.';

  @override
  String get preparingPrivateAnalysis => 'Private Analyse wird vorbereitet…';

  @override
  String get onDeviceAiReadyTitle => 'Geräte-KI bereit';

  @override
  String get localScannerActiveTitle => 'Lokaler Scanner aktiv';

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
  String get readingClausesInitial =>
      'Klauseln werden auf diesem Gerät gelesen…';

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
  String get thoughtSignaturePrefix => 'Denk-Signatur';

  @override
  String get viewStreamedThoughts => 'Gedankengang anzeigen';

  @override
  String get hideStreamedThoughts => 'Gedankengang ausblenden';

  @override
  String get analysisTraceDefaultTitle => 'Wie diese Prüfung verifiziert wurde';

  @override
  String get savedToLocalReceiptsSnack => 'In lokalen Belegen gespeichert.';

  @override
  String get snapshotSheetTitle => 'Geprüfte Datenschutzerklärung';

  @override
  String get snapshotSourcePrefix => 'Quelle';

  @override
  String get snapshotReviewedPrefix => 'Geprüft';

  @override
  String get snapshotDigestPrefix => 'Prüfsumme';

  @override
  String get statFindings => 'Hinweise';

  @override
  String get statVerified => 'Verifiziert';

  @override
  String get statOsGranted => 'OS gewährt';

  @override
  String get statUnverified => 'Ungeprüft';

  @override
  String get keyFindingsTitle => 'Wichtige Hinweise';

  @override
  String get reviewedExcerptTitle => 'Geprüfter Auszug';

  @override
  String get permissionsOnPhoneTitle => 'Berechtigungen auf diesem Gerät';

  @override
  String get viewReviewedSnapshot => 'Geprüften Originaltext ansehen';

  @override
  String get btnSavedToReceipts => 'In Belegen gespeichert';

  @override
  String get observedOnPhoneLabel => 'Auf diesem Telefon erkannt';

  @override
  String get quoteVerifiedLabel => 'Zitat im Text bestätigt';

  @override
  String get unverifiedClaimLabel => 'Unbestätigte Angabe';

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
  String get labelWhatRemainsUnknown => 'Was offen bleibt';

  @override
  String get presetQuestionMeaning => 'Was bedeutet das für mein Kind?';

  @override
  String get presetQuestionOptOut =>
      'Lässt sich das abschalten oder widersprechen?';

  @override
  String get presetQuestionUnknown => 'Was bleibt hierbei unklar?';

  @override
  String get readingCitedClause => 'Zitierte Klausel wird gelesen…';

  @override
  String get deniAnswerTitle => 'Denis Antwort';

  @override
  String get stepsAndReasoning => 'Schritte & Modellbegründung';

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
  String get sampleSyntheticBadge => 'Synthetisches Beispiel';

  @override
  String get permissionInspectionTitle => 'Geräteberechtigungs-Prüfung';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Datenschutzerklärung dieser App hinzufügen';

  @override
  String get snapshotDigestLabel => 'Snapshot-Prüfwert · FNV-1a 64-Bit';

  @override
  String get snapshotDigestExplanation =>
      'Ein schneller lokaler 64-Bit-Fingerabdruck dieses Textes (kein kryptografisches SHA-256). Ändert sich bei jeder Zeichenänderung.';

  @override
  String get copyDigestBtn => 'Prüfwert kopieren';

  @override
  String get digestCopiedMsg => 'Snapshot-Prüfwert kopiert';

  @override
  String get permissionGrantedBadge => 'Erteilt';

  @override
  String get permissionNotGrantedBadge => 'Nicht erteilt';

  @override
  String get checkingPolicyWithCloudAi =>
      'Richtlinie wird mit Cloud-KI geprüft.';

  @override
  String get preparingCloudAiStream =>
      'Bereinigte Cloud-Prüfung wird vorbereitet…';

  @override
  String get cancellingAnalysis => 'Wird abgebrochen…';

  @override
  String get analysisCancelledNotice => 'Prüfung abgebrochen.';

  @override
  String get cloudTimedOutNotice =>
      'Cloud-KI hat nicht rechtzeitig geantwortet. Es wurde kein automatischer Neuversuch gestartet.';

  @override
  String get cloudFallbackBannerTitle =>
      'Cloud-KI nicht verfügbar — lokaler Scan angezeigt';

  @override
  String get cloudFallbackBannerBody =>
      'Die Cloud-Analyse war nicht verfügbar, daher stammt dieses Ergebnis vom lokalen deterministischen Scanner von Enprive.';

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
}
