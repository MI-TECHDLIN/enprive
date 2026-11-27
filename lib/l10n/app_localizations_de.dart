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
      'Ein oder mehrere Abschnitte der Datenschutzerklärung oder Telefonberechtigungen sollten genauer geprüft werden.';

  @override
  String get stateInsufficientEvidence => 'Unzureichende Belege';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Wir benötigen mehr Text aus der Datenschutzerklärung, bevor wir prüfen können, was diese App tut.';

  @override
  String get chipOnDevice => 'Auf diesem Gerät';

  @override
  String get chipInCloud => 'In der Cloud';

  @override
  String get chipLocationUnavailable => 'Quelle nicht verfügbar';

  @override
  String get chipOfflineDeterministic => 'Offline auf diesem Gerät geprüft';

  @override
  String get chipUnknown => 'Quelle unbekannt';

  @override
  String get statusSourceMatched => 'In der Erklärung gefunden';

  @override
  String get statusDeviceObserved => 'Auf diesem Gerät gesehen';

  @override
  String get statusInterpretation => 'Erklärung von Deni';

  @override
  String get statusUnverified => 'Nicht in der Erklärung gefunden';

  @override
  String get statusStale => 'Ältere Prüfung';

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
      'Für diese Prüfung in der Cloud sendet Enprive nur den oben gezeigten Text (ohne persönliche Daten) für diese eine Anfrage. Ihre Apps und Telefonberechtigungen werden niemals gesendet.';

  @override
  String get permissionLimitationNotice =>
      'Ihr Telefon zeigt, ob diese Berechtigung erlaubt ist. Das beweist nicht, ob die App tatsächlich Daten abgerufen oder gesendet hat.';

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
      'Hebt Datenweitergabe, Sprachaufnahmen und Speicherdauer mit genauen Zitaten hervor.';

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
      other: '$count passende Zitate',
      one: '1 passendes Zitat',
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
  String get readinessRow3Title => 'Persönliche Daten ausgeblendet';

  @override
  String get readinessRow3Desc =>
      'Wenn Sie Cloud-Hilfe wählen, werden Namen, E-Mail-Adressen und Telefonnummern vor dem Senden ausgeblendet.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get privateAnalysisTitle => 'Private Analyse auf diesem Gerät';

  @override
  String get onDeviceReadyMsg => 'Geräte-KI ist aktiv und bereit.';

  @override
  String get localScannerProtectedMsg =>
      'Bereit, Datenschutzerklärungen offline auf diesem Gerät zu prüfen.';

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
      'On-Device-KI ist auf diesem Gerät bereit. Prüfungen bleiben vollständig auf Ihrem Gerät.';

  @override
  String get modelDownloadingMsg =>
      'Privates Gerätemodell wird im Hintergrund heruntergeladen.';

  @override
  String get modelDownloadableMsg =>
      'Das Gerätemodell kann über WLAN heruntergeladen werden.';

  @override
  String get localScannerDefaultMsg =>
      'Dieses Gerät prüft Datenschutzerklärungen standardmäßig offline auf Ihrem Gerät.';

  @override
  String get preparingPrivateAnalysis => 'Private Analyse wird vorbereitet…';

  @override
  String get onDeviceAiReadyTitle => 'Geräte-KI bereit';

  @override
  String get localScannerActiveTitle => 'Offline-Prüfung bereit';

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
      'Text der Datenschutzerklärung wird auf diesem Gerät gelesen…';

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
  String get thoughtSignaturePrefix => 'Prüf-ID';

  @override
  String get viewStreamedThoughts => 'Wie Enprive das geprüft hat';

  @override
  String get hideStreamedThoughts => 'Prüfschritte von Enprive ausblenden';

  @override
  String get analysisTraceDefaultTitle => 'Wie diese Prüfung verifiziert wurde';

  @override
  String get savedToLocalReceiptsSnack => 'In lokalen Belegen gespeichert.';

  @override
  String get snapshotSheetTitle => 'Geprüfter Text der Datenschutzerklärung';

  @override
  String get snapshotSourcePrefix => 'Quelle';

  @override
  String get snapshotReviewedPrefix => 'Geprüft';

  @override
  String get snapshotDigestPrefix => 'Dokument-Fingerabdruck';

  @override
  String get statFindings => 'Hinweise';

  @override
  String get statVerified => 'Verifiziert';

  @override
  String get statOsGranted => 'Auf dem Gerät erlaubt';

  @override
  String get statUnverified => 'Nicht gefunden';

  @override
  String get keyFindingsTitle => 'Wichtige Hinweise';

  @override
  String get reviewedExcerptTitle => 'Geprüfter Auszug';

  @override
  String get permissionsOnPhoneTitle => 'Berechtigungen auf diesem Gerät';

  @override
  String get viewReviewedSnapshot => 'Geprüften Text ansehen';

  @override
  String get btnSavedToReceipts => 'In Belegen gespeichert';

  @override
  String get observedOnPhoneLabel => 'Auf diesem Gerät gesehen';

  @override
  String get quoteVerifiedLabel => 'Genaues Zitat aus der Erklärung';

  @override
  String get unverifiedClaimLabel => 'Nicht in der Erklärung gefunden';

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
  String get labelWhatRemainsUnknown => 'Was wir noch nicht wissen';

  @override
  String get presetQuestionMeaning => 'Was bedeutet das für mein Kind?';

  @override
  String get presetQuestionOptOut =>
      'Lässt sich das abschalten oder widersprechen?';

  @override
  String get presetQuestionUnknown => 'Was bleibt hierbei unklar?';

  @override
  String get readingCitedClause => 'Zitat aus der Erklärung wird gelesen…';

  @override
  String get deniAnswerTitle => 'Denis Antwort';

  @override
  String get stepsAndReasoning => 'Wie Deni das geprüft hat';

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
  String get sampleSyntheticBadge => 'Beispiel-App';

  @override
  String get permissionInspectionTitle => 'Telefonberechtigungen geprüft';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Datenschutzerklärung dieser App hinzufügen';

  @override
  String get snapshotDigestLabel => 'Dokument-Fingerabdruck';

  @override
  String get snapshotDigestExplanation =>
      'Ein eindeutiger Code, der bestätigt, dass dies genau der von Enprive geprüfte Text ist. Ändert sich auch nur ein Buchstabe, ändert sich auch dieser Code.';

  @override
  String get copyDigestBtn => 'Fingerabdruck kopieren';

  @override
  String get digestCopiedMsg => 'Dokument-Fingerabdruck kopiert';

  @override
  String get permissionGrantedBadge => 'Auf diesem Gerät erlaubt';

  @override
  String get permissionNotGrantedBadge => 'Nicht erlaubt';

  @override
  String get checkingPolicyWithCloudAi =>
      'Richtlinie wird mit Cloud-KI geprüft.';

  @override
  String get preparingCloudAiStream =>
      'Persönliche Daten werden vor der Cloud-Prüfung ausgeblendet…';

  @override
  String get cancellingAnalysis => 'Wird abgebrochen…';

  @override
  String get analysisCancelledNotice => 'Prüfung abgebrochen.';

  @override
  String get cloudTimedOutNotice =>
      'Cloud-KI hat nicht rechtzeitig geantwortet. Es wurde kein automatischer Neuversuch gestartet.';

  @override
  String get cloudFallbackBannerTitle =>
      'Die Cloud-Prüfung konnte nicht abgeschlossen werden';

  @override
  String get cloudFallbackBannerBody =>
      'Dies ist das Ergebnis von Ihrem Gerät, und es wurde nichts erneut gesendet. Der Text der Datenschutzerklärung bleibt erhalten. Es wird nichts gespeichert, bis Sie auf Speichern tippen.';

  @override
  String get cloudFallbackRetryAction => 'Cloud-Prüfung erneut versuchen';

  @override
  String get appPickerFilterAll => 'Alle Apps';

  @override
  String get appPickerFilterDownloaded => 'Heruntergeladen';

  @override
  String get appPickerFilterSystem => 'System';

  @override
  String get appPickerRecentlyChecked => 'Zuletzt geprüft';

  @override
  String get appPickerStatusPolicySaved => 'Erklärungsprüfung gespeichert';

  @override
  String get appPickerStatusPermissionsInspected => 'Berechtigungen geprüft';

  @override
  String get appPickerStatusNotReviewed => 'Nicht geprüft';

  @override
  String get appPickerSearchHint => 'Nach App-Name oder App ID suchen…';

  @override
  String get appPickerEmptyInstalledTitle =>
      'Keine installierten Apps verfügbar';

  @override
  String get appPickerEmptyInstalledBody =>
      'Auf diesem Gerät wurden keine Apps zum Prüfen gefunden.';

  @override
  String get intakeModeDocument => 'Dokument';

  @override
  String get intakeActionInspectText => 'Erklärungstext prüfen';

  @override
  String get intakeActionFetchUrl => 'Erklärung öffnen & prüfen';

  @override
  String get intakeActionChooseDocument => 'PDF, TXT oder DOCX wählen';

  @override
  String get intakeActionReplaceDocument => 'Ersatzdokument wählen';

  @override
  String get intakeWorkingLabel => 'Wird verarbeitet…';

  @override
  String get intakeCancelFetch => 'Abruf abbrechen';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'Lädt diese öffentliche Webseite direkt. Ein Link hier beweist nicht, wem die App gehört.';

  @override
  String get intakePasteLocalNote =>
      'Wird zuerst lokal auf diesem Gerät geprüft. Ohne Ihre Zustimmung wird nichts hochgeladen.';

  @override
  String get intakeDocumentCardTitle =>
      'PDF-, TXT- oder DOCX-Datei importieren';

  @override
  String get intakeDocumentCardBody =>
      'Wir lesen den Text direkt auf Ihrem Gerät (bis 10 MB). Ihre Datei wird niemals hochgeladen.';

  @override
  String get intakeCompareWithAppPrompt =>
      'Mit einer installierten App vergleichen (optional)';

  @override
  String get intakeCompareWithAppHint =>
      'Läuft lokal auf diesem Gerät. Ihre App-Liste verlässt Ihr Gerät niemals.';

  @override
  String get intakeCompareWithAppChange => 'Ändern';

  @override
  String get intakeCompareWithAppRemove => 'Entfernen';

  @override
  String get intakeLockedAppContextLabel => 'Ausgewählte App';

  @override
  String get intakeFindPolicyOnPlayStore =>
      'Link zur Erklärung im Play Store suchen';

  @override
  String get intakePlayStoreHelperNote =>
      'Öffnet den Play Store, damit Sie den Link zur Datenschutzerklärung kopieren können. Enprive kopiert ihn niemals automatisch und geht nicht davon aus, dass der Link offiziell ist.';

  @override
  String get intakePlayStoreUnavailable =>
      'Google Play Store konnte auf diesem Gerät nicht geöffnet werden. Fügen Sie die URL oder den Text stattdessen manuell ein.';

  @override
  String get intakeRecoverySwitchPaste => 'Stattdessen Text einfügen';

  @override
  String get intakeRecoverySwitchDocument => 'Dokument importieren';

  @override
  String get intakeRecoveryRetryUrl => 'Erneut abrufen';

  @override
  String get intakeExpiredDocumentShareNotice =>
      'Der ursprünglich geteilte Dateilink kann nicht erneut geöffnet werden. Wählen Sie eine andere PDF-, TXT- oder DOCX-Datei oder fügen Sie den Text manuell ein.';

  @override
  String get intakeAssociationWarningTitle => 'App- und Erklärungsabgleich';

  @override
  String get intakeAssociationContinueAnyway => 'Trotzdem fortfahren';

  @override
  String get intakeAssociationChangeApp => 'Ausgewählte App ändern';

  @override
  String get intakeAssociationInspectWithoutApp => 'Erklärung ohne App prüfen';

  @override
  String get intakeModeSelectorSemanticLabel =>
      'Eingabemethode für die Erklärung';

  @override
  String get tooltipClearSearch => 'Suche leeren';

  @override
  String get intakeRecoveryEditUrl => 'URL bearbeiten';

  @override
  String get voiceSummaryTitle => 'Kurzzusammenfassung von Deni';

  @override
  String get voiceSummaryPreparing => 'Einfache Zusammenfassung wird erstellt…';

  @override
  String get voiceSynthesizingExpressive =>
      'Ausdrucksstarke Stimme von Deni wird vorbereitet…';

  @override
  String get voiceBtnListenOffline => 'Anhören';

  @override
  String get voiceBtnStop => 'Stopp';

  @override
  String get voiceBtnExpressiveCloud => 'Ausdrucksstarke Stimme';

  @override
  String get voiceBtnSummarizeCloud => 'Mit Cloud-KI zusammenfassen';

  @override
  String get voiceBadgeExpressive => 'Ausdrucksstarke Cloud-Stimme';

  @override
  String get voiceBadgeDeviceOffline => 'Gerätestimme · Offline';

  @override
  String get voiceViewSourceQuote => 'Quellzitat';

  @override
  String get voiceHideSourceQuote => 'Zitat ausblenden';

  @override
  String get voiceInspectFinding => 'Hinweis ansehen';

  @override
  String get voiceConsentTitle => 'Stimme von Deni wählen';

  @override
  String get voiceConsentDisclosure =>
      'Um diese Zusammenfassung mit der ausdrucksstarken Cloud-Stimme von Deni vorzulesen, sendet Enprive nur den oben gezeigten Zusammenfassungstext (ohne persönliche Daten) für diese eine Anfrage. Ihre Apps und Telefonberechtigungen werden niemals gesendet.';

  @override
  String get voiceConsentPrimaryAction =>
      'Ausdrucksstarke Stimme einmalig nutzen';

  @override
  String get voiceConsentSecondaryAction => 'Auf diesem Gerät vorlesen';

  @override
  String get voiceConsentPayloadLabel => 'Genauer Sprechtext';

  @override
  String get voiceSummaryConsentTitle => 'Hinweise mit Cloud-KI zusammenfassen';

  @override
  String get voiceSummaryConsentDisclosure =>
      'Um diese Zitate in der Cloud einfach zusammenzufassen, sendet Enprive nur den oben gezeigten Text (ohne persönliche Daten) für diese eine Anfrage. Ihre Apps und Telefonberechtigungen werden niemals gesendet.';

  @override
  String get voiceFallbackDeviceNotice =>
      'Ausdrucksstarke Cloud-Stimme war nicht verfügbar: Stattdessen wird die Offline-Stimme dieses Geräts verwendet.';

  @override
  String get voiceUnavailableNotice =>
      'Die Sprachausgabe ist für diese Sprache auf diesem Gerät nicht verfügbar. Sie können die Zusammenfassung von Deni oben lesen.';

  @override
  String get voiceTooltipReadSummary =>
      'Einfache Zusammenfassung von Deni anhören';

  @override
  String get voiceTooltipStopReading => 'Vorlesen stoppen';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hinweise',
      one: 'Hinweis',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hinweise',
      one: '1 Hinweis',
      zero: 'Keine Hinweise',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zitate in der Erklärung bestätigt',
      one: '1 Zitat in der Erklärung bestätigt',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count auf diesem Gerät beobachtet',
      one: '1 auf diesem Gerät beobachtet',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'Auf diesem Gerät erlaubt';

  @override
  String get permissionNotAllowedOnPhone => 'Nicht erlaubt';

  @override
  String get permissionAllowedInSample => 'Im Beispiel erlaubt';

  @override
  String get permissionNotAllowedInSample => 'Im Beispiel nicht erlaubt';

  @override
  String get permissionMismatchChip => 'Nicht in Erklärung';

  @override
  String get howEnpriveCheckedThis => 'Wie Enprive das geprüft hat';

  @override
  String get hideHowEnpriveChecked => 'Prüfschritte von Enprive ausblenden';

  @override
  String get consentWhatWouldBeSent => 'Was gesendet würde';

  @override
  String get consentSentScope =>
      'Nur der Text in der Vorschau verlässt dieses Gerät, für diese eine Anfrage.';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persönliche Angaben werden zuerst ausgeblendet.',
      one: '1 persönliche Angabe wird zuerst ausgeblendet.',
      zero: 'Keine persönlichen Daten zum Ausblenden gefunden.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'Ihre App-Liste und Telefonberechtigungen bleiben auf diesem Gerät.';

  @override
  String receiptDeletedSnack(String title) {
    return '$title gelöscht';
  }

  @override
  String get btnUndo => 'Rückgängig';

  @override
  String get readinessPromiseMaskedTitle => 'Persönliche Daten ausgeblendet';

  @override
  String get readinessPromiseMaskedLine =>
      'Wenn Sie die Cloud wählen, werden Namen, E-Mails und Nummern zuerst ausgeblendet.';

  @override
  String findingDetailTitle(int index, int total) {
    return 'Hinweis $index von $total';
  }

  @override
  String get findingReviewChip => 'Prüfen';

  @override
  String get askDeniAboutThis => 'Deni dazu fragen';

  @override
  String get labelWhatPolicySays => 'Was die Erklärung sagt';

  @override
  String get labelWhatAndroidReports => 'Was Ihr Gerät anzeigt';

  @override
  String get sourceButtonTooltip => 'Geprüfte Quelle';

  @override
  String get linkInstalledAppBtn => 'Installierte App verknüpfen';

  @override
  String get linkInstalledAppCardTitle =>
      'Mit einer App auf diesem Gerät vergleichen';

  @override
  String get linkInstalledAppCardBody =>
      'Wählen Sie eine installierte App aus, um ihre Berechtigungen in derselben Prüfung mit dieser Erklärung zu vergleichen. Ihre App-Liste bleibt auf diesem Gerät.';

  @override
  String get linkAppPickerTitle => 'Installierte App verknüpfen';

  @override
  String get changeLinkedAppPickerTitle => 'Verknüpfte App ändern';

  @override
  String get linkAppPickerSubtitle =>
      'Wählen Sie eine App auf diesem Gerät, um ihre Berechtigungen mit dieser Erklärung zu vergleichen. Ihre App-Liste verlässt dieses Gerät niemals.';

  @override
  String get linkedAppCurrentlySelectedBadge => 'Verknüpft';

  @override
  String get linkedAppSectionLabel => 'Verknüpfte App auf diesem Gerät';

  @override
  String get btnChangeLinkedApp => 'App wechseln';

  @override
  String get btnUnlinkApp => 'Verknüpfung lösen';

  @override
  String get btnUpdatePrivacyPolicy =>
      'Aktualisierte Datenschutzerklärung anhängen';

  @override
  String linkedAppSnack(String appName) {
    return '$appName verknüpft. Berechtigungen auf diesem Gerät verglichen.';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return '$appName verknüpft. Prüfen Sie den Zuordnungshinweis unten.';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName ist bereits mit denselben Berechtigungen verknüpft.';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return 'Verknüpfung zu $appName gelöst. Es wird nur die Erklärungsprüfung angezeigt.';
  }

  @override
  String get associationStatusPackageTitle =>
      'App ID in dieser Erklärung gefunden';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'Diese Erklärung nennt $packageName. Das deutet darauf hin, dass sie $appName beschreiben könnte, doch Text allein beweist nicht, wem diese Erklärung gehört.';
  }

  @override
  String get associationStatusNameTitle =>
      'App-Name in dieser Erklärung gefunden';

  @override
  String associationStatusNameBody(String appName) {
    return 'Diese Erklärung nennt $appName. Das deutet darauf hin, dass sie diese App beschreiben könnte, doch ein übereinstimmender Name beweist nicht, wem diese Erklärung gehört.';
  }

  @override
  String get associationStatusUnverifiedTitle =>
      'Von Ihnen zum Vergleich verknüpft';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'Diese Erklärung nennt weder $appName noch dessen App ID. Prüfen Sie genau, ob es die richtige Erklärung ist: Die Verknüpfung hier beweist keine Zugehörigkeit.';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'Die Webadresse enthält Wörter aus $appName, doch der Erklärungstext selbst nennt diese App nicht. Prüfen Sie genau, ob es die richtige Erklärung ist: Die Verknüpfung hier beweist keine Zugehörigkeit.';
  }

  @override
  String get associationStatusUnmatchedTitle =>
      'Diese Erklärung gehört möglicherweise zu einer anderen App';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'Diese Erklärung erwähnt $appName nicht. Stattdessen nennt sie $otherApps. Prüfen Sie, ob Sie die richtige App verknüpft oder die richtige Erklärung geöffnet haben.';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'Diese Erklärung nennt mehr als eine App';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'Diese Erklärung nennt $appName zusammen mit $otherApps. Sie gilt möglicherweise für mehrere Apps oder als gemeinsame Unternehmensrichtlinie. Prüfen Sie, ob sie hier zutrifft.';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      'Mehrere Apps auf diesem Gerät haben einen ähnlichen Namen';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'Diese Erklärung nennt $appName ohne eine genaue App ID, und andere Apps auf Ihrem Gerät ($otherApps) heißen ähnlich. Vergewissern Sie sich, dass die richtige App verknüpft ist.';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'Diese Erklärung könnte sich auf mehr als eine App beziehen. Prüfen Sie genau, ob sie für $appName gilt.';
  }

  @override
  String get associationOwnershipLimitation =>
      'Texte und Weblinks beweisen niemals, wer eine Erklärung veröffentlicht hat oder besitzt.';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Berechtigungen auf diesem Gerät werden in dieser Erklärung nicht klar erwähnt. Eine Abweichung ist ein Anlass, genauer hinzusehen, kein Beweis für Fehlverhalten.',
      one: '1 Berechtigung auf diesem Gerät wird in dieser Erklärung nicht klar erwähnt. Eine Abweichung ist ein Anlass, genauer hinzusehen, kein Beweis für Fehlverhalten.',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'Keine der geprüften Berechtigungen auf diesem Gerät widerspricht dieser Erklärung. Berechtigungen allein können nicht zeigen, was eine App tatsächlich sendet.';

  @override
  String get permissionComparisonLimitationNote =>
      'Ihr Gerät zeigt nur die Berechtigungseinstellungen auf diesem Gerät. Dieser Vergleich ist ein Anlass, genauer hinzusehen, niemals ein Beweis für Fehlverhalten oder Datenversand.';

  @override
  String get permissionNotRequestedOnPhone => 'Von App nicht angefordert';

  @override
  String get permissionNotRequestedInSample => 'Im Beispiel nicht angefordert';

  @override
  String get permissionsEmptyComparisonTitle =>
      'Keine sensiblen Berechtigungen in dieser Prüfung gefunden';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'Ihr Gerät führt $requestedCount Berechtigungen ($grantedCount erlaubt) für $appName auf, aber keine in den hier geprüften sensiblen Kategorien (Standort, Kamera, Mikrofon, Kontakte, Fotos oder Werbe-ID).';
  }

  @override
  String get sourceDeviceInspection => 'Auf diesem Gerät geprüft';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => 'Erweiterte Details';

  @override
  String get advancedDetailsSubtitle =>
      'Technische Details, die belegen, wann und wo dieser Text geprüft wurde.';

  @override
  String get sourceSectionTitle => 'Woher diese Erklärung stammt';

  @override
  String get cloudPayloadLabel => 'Genauer Text, der gesendet wird';

  @override
  String get cloudPayloadNoPiiLabel => 'Keine persönlichen Daten gefunden';

  @override
  String cloudPayloadHiddenCount(int count) {
    return 'Ausgeblendet ($count)';
  }

  @override
  String get summarySourceOnDevice => 'Auf diesem Gerät zusammengefasst';

  @override
  String get summarySourceInCloud => 'In der Cloud zusammengefasst';

  @override
  String get summarySourceOffline => 'Offline auf diesem Gerät zusammengefasst';

  @override
  String get summarySourceUnknown => 'Quelle der Zusammenfassung unbekannt';

  @override
  String get notFromPolicySuffix =>
      'Aus Ihren Geräteeinstellungen, nicht aus der Erklärung';

  @override
  String get sampleNotFromPolicySuffix =>
      'Nur Beispiel, nicht aus der Erklärung';

  @override
  String get learnHeaderSubtitle => 'Offline-Datenschutzguides & Diagramme';

  @override
  String get learnFilterAll => 'Alle Themen';

  @override
  String get learnFilterPolicies => 'Erklärungen';

  @override
  String get learnFilterPermissions => 'Berechtigungen';

  @override
  String get learnFilterSharing => 'Weitergabe';

  @override
  String get learnFilterEvidence => 'Belege';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schritte',
      one: '1 Schritt',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle => 'Datenschutz-Gewohnheiten lokal üben';

  @override
  String get learnDeckBody =>
      '100 % Offline-Lektionen mit Diagrammen. Ihre installierten Apps und Belege gelangen niemals in Lernen.';

  @override
  String get learnDeckCheckBtn => 'Anwenden · App prüfen';

  @override
  String get learnCheckAppBridgeBtn => 'App auf diesem Gerät prüfen';

  @override
  String get learnSectionDiagram => 'So funktioniert es';

  @override
  String get learnSectionSteps => 'Wichtige Schritte';

  @override
  String get learnSectionQuickCheck => 'Kurzcheck';

  @override
  String get learnTooltipListenLesson => 'Diese Lektion offline vorlesen';

  @override
  String get learnTooltipStopLesson => 'Vorlesen der Lektion stoppen';

  @override
  String get learnVoiceUnavailableNotice =>
      'Die Offline-Sprachausgabe ist für diese Sprache auf diesem Gerät nicht verfügbar. Sie können die Lektion unten lesen.';

  @override
  String get learnQuickCheckCorrectBadge => 'Richtige Antwort';

  @override
  String get learnQuickCheckTryAgainBadge => 'Andere Auswahl versuchen';

  @override
  String learnLessonProgress(int current, int total) {
    return 'Lektion $current von $total';
  }

  @override
  String get learnBackTooltip => 'Zurück zu Lernen';

  @override
  String get learnPreviousLesson => 'Zurück';

  @override
  String get learnNextLesson => 'Weiter';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return 'Vorherige Lektion: $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return 'Nächste Lektion: $title';
  }

  @override
  String get learnPolicyFolderTitle => 'Datenschutzerklärungen';

  @override
  String get learnPolicyTitle =>
      'Was eine Datenschutzerklärung ist (und was sie nicht beweist)';

  @override
  String get learnPolicySubtitle =>
      'Was Entwickler versprechen vs. was unbekannt bleibt';

  @override
  String get learnPolicyIntro =>
      'Eine Datenschutzerklärung ist die öffentliche Aussage eines Entwicklers darüber, welche Daten eine App nach eigenen Angaben sammelt, wofür sie diese nutzt, wer sie erhalten kann und welche Wahlmöglichkeiten Familien haben.';

  @override
  String get learnPolicyStep1 =>
      'Achten Sie auf vier Grundlagen: welche Daten gesammelt werden, warum die App sie braucht, wer sie noch erhalten kann und wie Sie eine Löschung anfragen können.';

  @override
  String get learnPolicyStep2 =>
      'Unklare Sprache ist häufig. Eine Studie von 2026 zu Lern-Apps für Kinder zeigte, dass nur sehr wenige Erklärungen leicht lesbar waren und die meisten Apps nicht vollständig zu ihren Erklärungen passten.';

  @override
  String get learnPolicyStep3 =>
      'Eine Datenschutzerklärung zeigt nur, was ein Entwickler auf dem Papier sagt. Das Lesen beweist nicht, was die App tatsächlich über das Internet sendet.';

  @override
  String get learnPolicyStep4 =>
      'Der Vergleich einer Erklärung mit den Berechtigungen Ihres Geräts gibt ein klareres Bild, wobei Enprive keinen laufenden Internetverkehr sehen kann.';

  @override
  String get learnPolicyQuickQuestion =>
      'Was beweist das Lesen der Datenschutzerklärung einer App?';

  @override
  String get learnPolicyQuickOption1 =>
      'Dass die App niemals Daten an jemanden sendet';

  @override
  String get learnPolicyQuickOption2 =>
      'Was der Entwickler sagt: nicht, was die App tatsächlich sendet';

  @override
  String get learnPolicyQuickOption3 =>
      'Dass Kamera und Mikrofon des Geräts ausgeschaltet sind';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'Genau richtig. Eine Erklärung ist die öffentliche Aussage des Entwicklers, kein Beweis dafür, was die App tatsächlich über das Internet sendet.';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      'Nicht ganz. Eine Erklärung zeigt nur, was der Entwickler angibt: Sie beweist keine Internetaktivität und schaltet keine Berechtigungen aus.';

  @override
  String get learnDiagramPolicySaysTitle => 'Erklärung sagt';

  @override
  String get learnDiagramPolicySaysBody =>
      'Schriftliches Versprechen des Entwicklers';

  @override
  String get learnDiagramPolicyQuoteSample =>
      '„Wir können Daten mit Partnern teilen…“';

  @override
  String get learnDiagramPhoneShowsTitle => 'Gerät zeigt';

  @override
  String get learnDiagramPhoneShowsBody => 'Hier erlaubte Berechtigungen';

  @override
  String get learnDiagramUnknownTitle => 'Weiterhin unbekannt';

  @override
  String get learnDiagramUnknownBody =>
      'Laufender Internetverkehr, den Enprive nicht sieht';

  @override
  String get learnDiagramPolicyCaption =>
      'Eine Erklärung ist ein Versprechen, kein Verhaltensbeweis';

  @override
  String get learnDiagramPolicySemantic =>
      'Diagramm zum Vergleich von drei Teilen des App-Datenschutzes. Erstens, Erklärung sagt: das schriftliche Versprechen des Entwicklers. Zweitens, Gerät zeigt: die auf diesem Gerät erlaubten Berechtigungen. Drittens, innerhalb einer gestrichelten Grenze, Weiterhin unbekannt: laufender Internetverkehr, den Enprive nicht sehen kann. Eine Datenschutzerklärung ist ein Versprechen, kein Beweis für das Verhalten.';

  @override
  String get learnPermissionsFolderTitle => 'Geräteberechtigungen';

  @override
  String get learnPermissionsTitle => 'Android-Berechtigungen einfach erklärt';

  @override
  String get learnPermissionsSubtitle =>
      'Die vier Android-Optionen & wo Sie sie prüfen';

  @override
  String get learnPermissionsIntro =>
      'Berechtigungen sind Tore, die steuern, ob eine App auf Sensoren und Daten Ihres Geräts zugreifen darf, etwa Kamera, Mikrofon, Standort, Fotos, Kontakte oder Benachrichtigungen.';

  @override
  String get learnPermissionsStep1 =>
      'Fragen Sie, ob die Berechtigung zur Funktion passt: Ein Mathe-Quiz oder eine Lese-App braucht selten Standort, Kontakte oder Kamera.';

  @override
  String get learnPermissionsStep2 =>
      'Android bietet bis zu vier Optionen: Nicht zulassen, Jedes Mal fragen, Nur während der Nutzung der App zulassen und Immer zulassen (für Standort im Hintergrund).';

  @override
  String get learnPermissionsStep3 =>
      'Beginnen Sie mit der engsten Option, mit der die Funktion läuft, etwa Jedes Mal fragen oder Während der Nutzung der App.';

  @override
  String get learnPermissionsStep4 =>
      'Öffnen Sie die Android-Einstellungen und prüfen Sie das Datenschutz-Dashboard, um zu sehen, welche Apps kürzlich Kamera, Mikrofon oder Standort genutzt haben.';

  @override
  String get learnPermissionsStep5 =>
      'Schalten Sie Berechtigungen jederzeit in den App-Einstellungen aus oder lassen Sie App-Aktivität bei Nichtnutzung pausieren aktiv, damit Android alte Berechtigungen automatisch entfernt. Eine erlaubte Berechtigung zeigt eine Möglichkeit, keinen Beweis für gesendete Daten.';

  @override
  String get learnPermissionsQuickQuestion =>
      'Eine Mathe-Übungs-App fragt nach der Kamera und Sie wissen nicht warum. Was ist der beste erste Schritt?';

  @override
  String get learnPermissionsQuickOption1 =>
      'Auf Nicht zulassen tippen und prüfen, ob die Matheaufgaben trotzdem funktionieren';

  @override
  String get learnPermissionsQuickOption2 =>
      'Immer zulassen wählen, damit das Fenster nicht wiederkommt';

  @override
  String get learnPermissionsQuickOption3 =>
      'Annehmen, dass die App bereits Fotos hochgeladen hat';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      'Richtig. Mit Nicht zulassen prüfen Sie, ob die App ohne Kamera läuft, und Sie können Berechtigungen jederzeit in den Android-Einstellungen ändern.';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'Testen Sie zuerst eine engere Option. Tippen Sie auf Nicht zulassen, um zu prüfen, ob die Funktion läuft, und denken Sie daran: Eine erlaubte Berechtigung zeigt eine Möglichkeit, keinen Upload-Beweis.';

  @override
  String get learnDiagramPermLadderTitle => 'Vom engsten zum weitesten Zugriff';

  @override
  String get learnDiagramPermDenyTitle => 'Nicht zulassen';

  @override
  String get learnDiagramPermDenyDetail =>
      'Blockiert: App kann diesen Sensor nicht nutzen';

  @override
  String get learnDiagramPermAskTitle => 'Jedes Mal fragen';

  @override
  String get learnDiagramPermAskDetail =>
      'Einmaliger Zugriff nach Ihrem Tippen';

  @override
  String get learnDiagramPermWhileUsingTitle => 'Während der Nutzung';

  @override
  String get learnDiagramPermWhileUsingDetail =>
      'Nur solange die App auf dem Bildschirm offen ist';

  @override
  String get learnDiagramPermAllTimeTitle => 'Immer zulassen';

  @override
  String get learnDiagramPermAllTimeDetail =>
      'Hintergrundzugriff auch im geschlossenen Zustand';

  @override
  String get learnDiagramPermFitNote =>
      'Passt das? Mathe-Quiz + Kamera = nachfragen';

  @override
  String get learnDiagramPermSemantic =>
      'Vierstufige Android-Berechtigungsleiter vom engsten zum weitesten Zugriff. Schritt 1, Nicht zulassen: blockiert, die App kann diesen Sensor nicht nutzen. Schritt 2, Jedes Mal fragen: einmaliger Zugriff, wenn Sie auf Zulassen tippen. Schritt 3, Während der Nutzung: Zugriff nur solange die App auf dem Bildschirm offen ist. Schritt 4, Immer zulassen: Hintergrundzugriff auch im geschlossenen Zustand, gestrichelt umrahmt als Vorsichtshinweis. Tipp unten: Passt das? Wenn ein Mathe-Quiz die Kamera verlangt, sollten Sie fragen warum.';

  @override
  String get learnSharingFolderTitle => 'Werbung & Dritte';

  @override
  String get learnSharingTitle =>
      'Wer noch Daten erhält: Werbung, Analyse & Dritte';

  @override
  String get learnSharingSubtitle =>
      'App-Anbieter vs. Hilfsdienste, Analyse & Werbenetzwerke';

  @override
  String get learnSharingIntro =>
      'Viele kostenlose Apps verbinden sich im Hintergrund mit anderen Unternehmen. Zu wissen, wer Informationen erhält, hilft Familien, zwischen dem Betrieb der App und dem Tracking von Kindern über Apps hinweg zu unterscheiden.';

  @override
  String get learnSharingStep1 =>
      'Erstanbieter bedeutet der App-Anbieter selbst: zum Beispiel das Speichern von Hausaufgaben-Fortschritt oder Quiz-Ergebnissen, damit die App funktioniert.';

  @override
  String get learnSharingStep2 =>
      'Hilfsdienste sind Drittanbieter für Aufgaben im Hintergrund, wie Cloud-Speicher oder Absturzberichte, damit Fehler behoben werden.';

  @override
  String get learnSharingStep3 =>
      'Analyse-Tools messen, wie Bildschirme genutzt werden, während Werbenetzwerke und Datenmakler eine Werbe-ID nutzen können, um gezielte Werbung zu zeigen oder Aktivitäten über Apps hinweg zu verfolgen.';

  @override
  String get learnSharingStep4 =>
      'Achten Sie auf weite Begriffe wie „vertrauenswürdige Partner“ oder „geschäftliche Zwecke“ und prüfen Sie, ob eine Erklärung zeigt, wie personalisierte Werbung deaktiviert wird.';

  @override
  String get learnSharingQuickQuestion =>
      'Eine Erklärung sagt, die App teilt Informationen mit „Drittpartnern“. Was ist die beste nächste Frage?';

  @override
  String get learnSharingQuickOption1 =>
      'Annehmen, dass die App keine Werbung hat';

  @override
  String get learnSharingQuickOption2 =>
      'Annehmen, dass jeder Partner genau dasselbe tut';

  @override
  String get learnSharingQuickOption3 =>
      'Prüfen, ob diese Partner Hilfsdienste (wie Hosting) oder Werbenetzwerke sind, die über Apps hinweg tracken';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'Genau richtig. Hilfsdienste halten die App am Laufen, während Werbenetzwerke und Datenmakler Aktivitäten über Apps hinweg verfolgen können.';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      'Schauen Sie genauer hin, was jeder Partner tut. Nicht alle Drittanbieter sind gleich: Manche hosten Daten oder beheben Abstürze, andere betreiben Werbung oder Tracking.';

  @override
  String get learnDiagramThirdPartyYou => 'Sie';

  @override
  String get learnDiagramThirdPartyApp => 'Lern-App';

  @override
  String get learnDiagramThirdPartyHosting => 'Hilfsdienste & Abstürze';

  @override
  String get learnDiagramThirdPartyAnalytics => 'Analyse';

  @override
  String get learnDiagramThirdPartyAds => 'Werbenetzwerke';

  @override
  String get learnDiagramThirdPartyFirstParty => 'Erstanbieter';

  @override
  String get learnDiagramThirdPartyThirdParty => 'Drittanbieter';

  @override
  String get learnDiagramThirdPartySemantic =>
      'Flussdiagramm, das zeigt, wohin Daten aus einer Lern-App für Kinder gelangen können. Sie verbinden sich mit der Lern-App, die mit durchgezogener Linie mit dem App-Anbieter (Erstanbieter) und mit gestrichelten Linien mit Drittanbietern verbunden ist: Hilfs- und Absturz-Tools, Analyse-Tools sowie besonders markierte Werbenetzwerke.';

  @override
  String get learnEvidenceFolderTitle => 'Enprive lesen';

  @override
  String get learnEvidenceTitle => 'Wie Sie die Belege von Enprive lesen';

  @override
  String get learnEvidenceSubtitle =>
      'Belegebenen, Kategorien & ehrliche Grenzen';

  @override
  String get learnEvidenceIntro =>
      'Enprive trennt, was eine Datenschutzerklärung sagt, was Ihr Gerät anzeigt und was unbekannt bleibt, und ordnet Hinweise nach Themen, niemals als Sicherheitsnote.';

  @override
  String get learnEvidenceStep1 =>
      'Fünf Themenkategorien ordnen jeden Hinweis mit demselben Symbol und derselben Farbe wie auf der Prüfseite. Die Farbe zeigt das Thema, niemals einen Sicherheitswert.';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '$sourceMatched bedeutet, dass Enprive ein genaues Zitat Wort für Wort im geprüften Erklärungstext gefunden hat.';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '$deviceObserved bedeutet, dass Ihr Gerät eine Berechtigungseinstellung auf diesem Gerät gemeldet hat: kein Beweis dafür, dass Daten gesendet wurden.';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '$interpretation ist die einfache Erklärung von Deni, während $unverified Punkte markiert, die Enprive nicht finden konnte. Schweigen in einer Erklärung ist niemals ein Versprechen.';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return 'Prüfungen enden mit einem von drei ruhigen Ergebnissen: $reviewRecommended, $noConcern (was niemals eine Sicherheitszertifizierung ist) oder $insufficientEvidence.';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return 'Was bedeutet „$deviceObserved“ auf einer Prüfseite?';
  }

  @override
  String get learnEvidenceQuickOption1 =>
      'Dass die App als kindersicher zertifiziert ist';

  @override
  String get learnEvidenceQuickOption2 =>
      'Dass Ihr Gerät diese Berechtigungseinstellung anzeigt: kein Beweis für hochgeladene Daten';

  @override
  String get learnEvidenceQuickOption3 =>
      'Dass die App die Daten Ihres Kindes sicher hochgeladen hat';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'Stimmt. Diese Angabe spiegelt den Android-Berechtigungsstatus auf diesem Gerät wider; sie kann weder Uploads beweisen noch Sicherheit zertifizieren.';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      'Nicht ganz. Diese Angabe zeigt nur, was Ihr Gerät über eine Berechtigung meldet: Sie beweist niemals Uploads und ist niemals eine Sicherheitszertifizierung.';

  @override
  String get learnDiagramEvidencePolicyDetail =>
      'Genaues Zitat aus dem Erklärungstext';

  @override
  String get learnDiagramEvidencePhoneDetail =>
      'Telefonberechtigungen auf diesem Gerät';

  @override
  String get learnDiagramEvidenceDeniDetail => 'Einfache Erklärung von Deni';

  @override
  String get learnDiagramEvidenceUnknownDetail =>
      'Schweigen in einer Erklärung ist kein Versprechen';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Vier Belegebenen auf der Prüfseite von Enprive: 1, $sourceMatched, ein genaues Zitat aus der Datenschutzerklärung; 2, $deviceObserved, Telefonberechtigungen auf diesem Gerät; 3, $interpretation, einfache Erklärung von Deni; und 4, getrennt durch eine gestrichelte Linie, $unverified, denn Schweigen in einer Erklärung ist kein Versprechen.';
  }

  @override
  String get learnDiagramCategoriesTitle =>
      'Fünf Themenkategorien auf der Prüfseite';

  @override
  String get learnDiagramCategoriesNote =>
      'Farbe und Symbol markieren das Thema, niemals einen Sicherheitswert.';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Fünf Belegkategorien auf der Prüfseite von Enprive, jeweils mit eigenem Symbol und eigener Farbe: $dataCollection, $sharing, $tracking, $retention und $parentalControls. Farbe und Symbol markieren das Thema, niemals einen Sicherheitswert.';
  }

  @override
  String get learnDataCollectionFolderTitle => 'Daten, die Apps sammeln';

  @override
  String get learnDataCollectionTitle => 'Welche Daten Apps sammeln';

  @override
  String get learnDataCollectionSubtitle =>
      'Der Unterschied zwischen Eingaben und stiller Erfassung';

  @override
  String get learnDataCollectionIntro1 =>
      'Apps sammeln Informationen auf zwei Arten. Manche Daten stammen aus Ihren aktiven Eingaben: Name, E-Mail, Fotos, Sprachaufnahmen oder Hausaufgaben. Andere Daten werden automatisch im Hintergrund erfasst, etwa Ihre IP-Adresse (die Internetadresse Ihres Geräts), Gerätekennungen, Werbe-ID (ein Code, mit dem Werbung Ihr Gerät erkennt), Absturzberichte und wann Sie die App öffnen.';

  @override
  String get learnDataCollectionStep1 =>
      'Was Sie eingeben: Name, Schule, E-Mail, Fotos, Sprachclips und Hausaufgaben sind Daten, die Sie bewusst angeben.';

  @override
  String get learnDataCollectionStep2 =>
      'Was still mitläuft: Die App kann Werbe-ID, Gerätekennungen, IP-Adresse, Absturzberichte und Nutzungszeiten ohne Tastendruck erfassen. Stille Erfassung ist nicht automatisch schlecht: Diese Signale helfen Apps, stabil zu laufen.';

  @override
  String get learnDataCollectionStep3 =>
      'Sensible Kinderdaten: Standort, Mikrofonaufnahmen, Kamerafotos und biometrische Daten wie Stimmprofile (Daten über Körper oder Stimme) bergen für Kinder ein höheres Datenschutzrisiko.';

  @override
  String get learnDataCollectionStep4 =>
      'Hinweis zum Play Store: Der Bereich Datensicherheit bei Google Play stammt vom Entwickler selbst. Er ist ein Hinweis, kein Beweis, und umfasst keine Daten, die nur auf Ihrem Gerät verarbeitet oder kurz im Speicher gehalten werden.';

  @override
  String get learnDataCollectionQuizQuestion =>
      'Was ist ein Beispiel für Daten, die still im Hintergrund erfasst werden?';

  @override
  String get learnDataCollectionQuizChoiceA =>
      'Ein Foto, das Sie für Ihr Profil hochladen';

  @override
  String get learnDataCollectionQuizChoiceB =>
      'Ihre Werbe-ID und Gerätekennungen';

  @override
  String get learnDataCollectionQuizChoiceC =>
      'Eine Hausaufgaben-Antwort, die Sie in der App eintippen';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      'Richtig: Werbe-IDs und Gerätekennungen werden automatisch erfasst, ohne dass Sie sie eintippen.';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      'Nicht ganz: Das sind Daten, die Sie aktiv eingeben. Still erfasste Daten umfassen Werbe-IDs, Gerätekennungen, IP-Adresse und Nutzungszeiten.';

  @override
  String get learnDataCollectionDiagramYouTypeTitle =>
      'Was Sie eingeben oder teilen';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => 'Name, E-Mail, Schule';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => 'Fotos und Videos';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => 'Sprachaufnahmen';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => 'Hausaufgaben-Antworten';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle => 'Was still mitläuft';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => 'Werbe-ID';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 => 'Gerätekennungen';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'IP-Adresse';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 =>
      'Absturzberichte & Nutzungszeit';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      'Still heißt nicht schlecht: Diese Signale helfen Apps, zuverlässig zu laufen.';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      'Ein geteiltes Diagramm mit zwei Kategorien der Datenerhebung. Die obere Karte „Was Sie eingeben oder teilen“ nennt vier Punkte: Name, E-Mail, Schule; Fotos und Videos; Sprachaufnahmen; Hausaufgaben-Antworten. Die untere Karte „Was still mitläuft“ nennt vier Punkte: Werbe-ID; Gerätekennungen; IP-Adresse; Absturzberichte & Nutzungszeit. Ein kleiner Hinweis lautet „Still heißt nicht schlecht: Diese Signale helfen Apps, zuverlässig zu laufen.“ Deni sitzt darunter in nachdenklicher Pose.';

  @override
  String get learnDataCollectionCheckBridge =>
      'Prüfen Sie eine App auf diesem Gerät, um zu sehen, welche Daten sie erhebt.';

  @override
  String get learnDataCollectionHonestyNote =>
      'Diese Lektion erklärt übliche Datenarten. Sie beweist nicht, was eine bestimmte App sammelt oder sendet. Nur der genaue Erklärungstext und die Berechtigungen Ihres Geräts können das zeigen.';

  @override
  String get learnRetentionFolderTitle => 'Speicherung & Löschung';

  @override
  String get learnRetentionTitle => 'Speicherung und Löschung von Daten';

  @override
  String get learnRetentionSubtitle =>
      'Eine App zu deinstallieren löscht keine Daten auf Unternehmensservern';

  @override
  String get learnRetentionIntro1 =>
      'Wenn Sie eine App von Ihrem Gerät löschen, werden die lokalen Dateien entfernt, doch bereits auf Unternehmensserver hochgeladene Daten bleiben dort. Datenschutzerklärungen sollten angeben, wie lange Daten gespeichert werden, wie Sie eine Löschung anfragen und was mit Backups passiert, aber viele nutzen vage Formulierungen wie „so lange wie vernünftigerweise nötig“.';

  @override
  String get learnRetentionStep1 =>
      'Daten gesammelt: Während Sie die App nutzen, werden Ihre Informationen an die Server des Unternehmens gesendet und dort gespeichert.';

  @override
  String get learnRetentionStep2 =>
      'Auf Servern gespeichert: Ihre Daten können auch dann auf den Systemen des Unternehmens bleiben, wenn Sie die App nicht mehr nutzen.';

  @override
  String get learnRetentionStep3 =>
      'Deinstallieren löscht keine Serverdaten: Das Entfernen der App löscht nur lokale Dateien auf Ihrem Gerät, nicht die Kopien auf den Servern.';

  @override
  String get learnRetentionStep4 =>
      'Löschanfrage: Sie können das Unternehmen bitten, Ihr Konto und Ihre Daten zu löschen; Erklärungen sollten nennen, wie lange das dauert.';

  @override
  String get learnRetentionStep5 =>
      'Unbekannte Speicherdauer: Erklärungen mit „so lange wie nötig“ oder „für geschäftliche Zwecke“ lassen unklar, wann Daten tatsächlich gelöscht werden.';

  @override
  String get learnRetentionQuizQuestion =>
      'Was passiert mit Ihren Daten auf Unternehmensservern, wenn Sie eine App deinstallieren?';

  @override
  String get learnRetentionQuizChoiceA => 'Sie werden automatisch gelöscht';

  @override
  String get learnRetentionQuizChoiceB =>
      'Sie können auf den Servern bleiben: Deinstallieren löscht sie nicht';

  @override
  String get learnRetentionQuizChoiceC => 'Sie werden sofort anonymisiert';

  @override
  String get learnRetentionQuizFeedbackRight =>
      'Richtig: Deinstallieren entfernt nur die App von Ihrem Gerät. Daten auf Unternehmensservern können bleiben, bis Sie eine Löschung anfragen.';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      'Nicht ganz: Durch das Deinstallieren werden bereits hochgeladene Daten auf den Servern nicht gelöscht. Sie müssen die Kontolöschung anfragen.';

  @override
  String get learnRetentionDiagramCollected => 'Daten bei der Nutzung erfasst';

  @override
  String get learnRetentionDiagramStored =>
      'Auf Unternehmensservern gespeichert';

  @override
  String get learnRetentionDiagramUninstall =>
      'App deinstalliert: lokale Dateien weg, Serverdaten bleiben';

  @override
  String get learnRetentionDiagramDeleteRequest =>
      'Sie fordern Kontolöschung an';

  @override
  String get learnRetentionDiagramUnknownTail =>
      'Unbekannte Dauer: Erklärung sagt „so lange wie nötig“';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      'Eine fünfstufige Zeitleiste zum Datenlebenszyklus. Schritt 1: Daten bei der Nutzung erfasst, mit Datenbanksymbol. Schritt 2: Auf Unternehmensservern gespeichert, mit Serversymbol. Schritt 3: App deinstalliert: lokale Dateien weg, Serverdaten bleiben, mit Smartphone-Symbol. Schritt 4: Sie fordern Kontolöschung an, mit Papierkorb-Symbol. Schritt 5: Unbekannte Dauer: Erklärung sagt „so lange wie nötig“, mit gestricheltem Pfeil und Hilfesymbol. Deni steht darunter mit einem Beleg.';

  @override
  String get learnRetentionCheckBridge =>
      'Prüfen Sie eine App auf diesem Gerät, um zu sehen, was ihre Erklärung zur Speicherung sagt.';

  @override
  String get learnRetentionHonestyNote =>
      'Diese Lektion beschreibt übliche Speicherpraktiken. Sie beweist nicht, was ein bestimmtes Unternehmen tatsächlich mit Ihren Daten tut. Nur der genaue Erklärungstext und eine Löschanfrage können das zeigen.';

  @override
  String get learnUnclearPoliciesFolderTitle => 'Unklare Erklärungen';

  @override
  String get learnUnclearPoliciesTitle =>
      'Unklare Erklärungen & knifflige Buttons erkennen';

  @override
  String get learnUnclearPoliciesSubtitle =>
      'Wie Sie vage Sprache und drängende Zustimmungsfenster erkennen';

  @override
  String get learnUnclearPoliciesIntro1 =>
      'Manche Datenschutzerklärungen verwenden ungenaue Begriffe, sodass kaum klar wird, was wirklich mit Ihren Daten passiert. Zustimmungsfenster nutzen manchmal Designtricks, wie einen großen bunten „Alle akzeptieren“-Button neben einem winzigen „Einstellungen verwalten“-Link, um Sie zum schnellen Zustimmen zu bewegen.';

  @override
  String get learnUnclearPoliciesStep1 =>
      'Anzeichen für Nebel: Achten Sie auf offene Formulierungen wie „kann mit vertrauenswürdigen Partnern geteilt werden“, „für geschäftliche Zwecke“ oder „nach Bedarf speichern“: Sie lassen echte Details offen.';

  @override
  String get learnUnclearPoliciesStep2 =>
      'Schweigen ist kein Versprechen: Wenn eine Erklärung Mikrofon, Werbung oder Standort nie erwähnt, garantiert das nicht, dass die App darauf verzichtet.';

  @override
  String get learnUnclearPoliciesStep3 =>
      'Fehlende Grundlagen: Eine nachvollziehbare Erklärung hat ein klares Gültigkeitsdatum, eine Kontakt-E-Mail und ein zusammenhängendes Dokument, keinen versteckten Kinder-Zusatz.';

  @override
  String get learnUnclearPoliciesStep4 =>
      'Gedrängte Zustimmung (Dark Patterns): Riesige „Alle akzeptieren“-Buttons, vorab angekreuzte Werbe-Kästchen, ständige Nachfragen und schwer auffindbare Kündigungswege sollen Ihre Wahl lenken.';

  @override
  String get learnUnclearPoliciesStep5 =>
      'Ausgewogene Wahl: Ein fairer Bildschirm zeigt gleichwertige „Zulassen“- und „Nicht zulassen“-Buttons, und optionale Schalter sind standardmäßig aus.';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      'Welche Formulierung in einer Datenschutzerklärung ist ein „nebliges“ Zeichen dafür, dass Details fehlen?';

  @override
  String get learnUnclearPoliciesQuizChoiceA =>
      'Wir verkaufen Ihre persönlichen Daten nicht an Dritte';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      'Wir können Daten für geschäftliche Zwecke mit vertrauenswürdigen Partnern teilen';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'Sie können die Löschung per E-Mail an privacy@example.com anfordern';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      'Richtig: „für geschäftliche Zwecke mit vertrauenswürdigen Partnern teilen“ ist vage und nennt weder die Partner noch die geteilten Daten.';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      'Nicht ganz: Diese Aussage ist konkret und nutzbar. Neblige Formulierungen verwenden offene Wörter wie „können teilen“ oder „nach Bedarf“ ohne Details.';

  @override
  String get learnUnclearPoliciesDiagramClearTitle =>
      'Klarer Satz in der Erklärung';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      'Wir erheben Ihren Namen und Ihre E-Mail-Adresse für Ihr Konto. Wir teilen dies nicht mit Werbetreibenden.';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle =>
      'Nebliger Satz in der Erklärung';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      'Wir können Ihre Daten nach Bedarf für geschäftliche Zwecke mit vertrauenswürdigen Partnern teilen.';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle =>
      'So erkennen Sie den Nebel';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      'Achten Sie auf „kann“, „könnte“ oder „nach Bedarf“: Sie lassen die Tür offen.';

  @override
  String get learnUnclearPoliciesDiagramTip2 =>
      'Prüfen Sie, ob die Erklärung konkrete Unternehmen nennt, die Daten erhalten.';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      'Schweigen zu Werbung oder Mikrofon ist kein Versprechen, dass die App darauf verzichtet.';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote =>
      'Schweigen in einer Erklärung ist kein Versprechen.';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      'Ein direkter Vergleich zwischen einem klaren und einem nebligen Satz. Die linke Karte „Klar“ zeigt: „Wir erheben Ihren Namen und Ihre E-Mail-Adresse für Ihr Konto. Wir teilen dies nicht mit Werbetreibenden.“ Die rechte Karte „Neblig“ zeigt: „Wir können Ihre Daten nach Bedarf für geschäftliche Zwecke mit vertrauenswürdigen Partnern teilen.“ Darunter nennt die Tipps-Karte „So erkennen Sie den Nebel“ drei Hinweise: auf „kann“, „könnte“ oder „nach Bedarf“ achten; prüfen, ob konkrete Unternehmen genannt werden; Schweigen zu Werbung oder Mikrofon ist kein Versprechen. Ein Hinweis lautet „Schweigen in einer Erklärung ist kein Versprechen.“ Deni schaut über die Karten hinweg.';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      'Prüfen Sie eine App auf diesem Gerät auf ihre Zustimmungsseite und Klarheit.';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      'Diese Lektion beschreibt übliche unklare Muster. Sie beweist nicht, dass eine bestimmte App Dark Patterns einsetzt oder Datenpraktiken verbirgt. Nur die genaue Erklärung und der echte Zustimmungsbildschirm können das zeigen.';

  @override
  String get learnSafeSharingFolderTitle => 'Sicheres Teilen';

  @override
  String get learnSafeSharingTitle => 'Bewusste Teil-Gewohnheiten für Kinder';

  @override
  String get learnSafeSharingSubtitle =>
      'Stopp, Denken, Teilen: altersgerechte Schritte für das Teilen online';

  @override
  String get learnSafeSharingIntro1 =>
      'Bevor ein Foto, ein Video, ein Name oder ein Standort gepostet wird, helfen drei Schritte: Stopp, Denken, Teilen. Diese Lektion ist zum gemeinsamen Lesen mit einer vertrauten erwachsenen Person gedacht. Jüngere Kinder (5-7 Jahre) fragen vor dem Tippen. Kinder von 8-11 Jahren nutzen Spitznamen und starke Passwörter. Jugendliche (12-17 Jahre) achten auf ihren digitalen Fußabdruck (die Spur eigener Beiträge) und Zwei-Faktor-Bestätigung (eine zweite Prüfung, etwa ein Code beim Anmelden).';

  @override
  String get learnSafeSharingStep1 =>
      'Stopp: Kurz innehalten, bevor ein Foto, Video, Name, eine Schule oder ein Standort geteilt wird. Bei Unsicherheit eine vertraute erwachsene Person fragen.';

  @override
  String get learnSafeSharingStep2 =>
      'Denken: Verrät das meine Schule, mein Zuhause oder wo ich gerade bin? Habe ich meine Freunde gefragt, bevor ich Fotos von ihnen teile oder sie markiere?';

  @override
  String get learnSafeSharingStep3 =>
      'Teilen: Nur mit Menschen teilen, denen man vertraut. Persönliche Angaben wie vollständiger Name, Geburtstag, Adresse und Telefonnummer bleiben privat.';

  @override
  String get learnSafeSharingStep4 =>
      'Der Mensa-Test: Wäre es okay, wenn alle in der Schule (oder meine ganze Klasse) dieses Foto oder diese Nachricht sehen? Selbst verschwindende Beiträge können per Screenshot gespeichert werden und dauerhaft online bleiben.';

  @override
  String get learnSafeSharingStep5 =>
      'Alter 5-7: Vor dem Eintippen des Namens oder Antippen von Fenstern eine vertraute erwachsene Person fragen. Alter 8-11: Spitznamen statt echtem Namen, Geburtstag und Schule verwenden, starke Passwörter nutzen und niemals SMS- oder OTP-Codes weitergeben (Einmalcodes per SMS niemals teilen). Alter 12-17: Datenschutzeinstellungen prüfen, Zwei-Faktor-Bestätigung aktivieren und wissen, wie man Probleme meldet.';

  @override
  String get learnSafeSharingQuizQuestion =>
      'Was ist der „Mensa-Test“ für das Teilen im Internet?';

  @override
  String get learnSafeSharingQuizChoiceA =>
      'Nur Dinge teilen, die man in der Mensa essen würde';

  @override
  String get learnSafeSharingQuizChoiceB =>
      'Fragen: Wäre es okay, wenn alle in der Schule dieses Foto oder diese Nachricht sehen?';

  @override
  String get learnSafeSharingQuizChoiceC =>
      'Nur in der Mittagspause etwas teilen';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      'Richtig: Beim Mensa-Test fragt man sich, ob es in Ordnung wäre, wenn alle den eigenen Beitrag sehen.';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      'Nicht ganz: Der Mensa-Test ist eine kurze Gedankenprüfung: Wäre es okay, wenn jemand den eigenen Beitrag der ganzen Mensa zeigt?';

  @override
  String get learnSafeSharingDiagramStop =>
      'Stopp: vor dem Posten kurz innehalten';

  @override
  String get learnSafeSharingDiagramThink =>
      'Denken: Verrät das, wo oder mit wem ich bin?';

  @override
  String get learnSafeSharingDiagramConnect =>
      'Teilen: nur mit vertrauten Personen, bei Zweifel Erwachsene fragen';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      'Der Mensa-Test: Wäre es okay, wenn alle in der Schule das sehen? Selbst verschwindende Beiträge können per Screenshot gespeichert werden und dauerhaft online bleiben.';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      'Ein vierteiliges Diagramm zu bewussten Teil-Gewohnheiten. Schritt 1: Stopp: vor dem Posten kurz innehalten, mit Handsymbol. Schritt 2: Denken: Verrät das, wo oder mit wem ich bin?, mit Gehirnsymbol. Schritt 3: Teilen: nur mit vertrauten Personen, bei Zweifel Erwachsene fragen, mit Personensymbol. Schritt 4: Der Hinweis zum Mensa-Test fragt „Wäre es okay, wenn alle in der Schule das sehen? Selbst verschwindende Beiträge können per Screenshot gespeichert werden und dauerhaft online bleiben.“ Deni steht mit erhobener Hand daneben.';

  @override
  String get learnSafeSharingCheckBridge =>
      'Prüfen Sie gemeinsam mit einem Elternteil eine App, um zu sehen, wie sie mit dem Teilen umgeht.';

  @override
  String get learnSafeSharingHonestyNote =>
      'Diese Lektion vermittelt allgemeine Gewohnheiten für bewusstes Teilen. Sie garantiert nicht, dass eine App Geteiltes schützt. Lesen Sie immer die Datenschutzerklärung und nutzen Sie die Datenschutzeinstellungen Ihres Geräts.';

  @override
  String get translationDraftNotice =>
      'Einige Übersetzungen sind KI-generierte Entwürfe und können Fehler enthalten. Muttersprachler prüfen sie derzeit.';

  @override
  String get homeQuickSettingsTitle => 'Schnelleinstellungen-Begleiter';

  @override
  String get homeQuickSettingsSubtitle =>
      'Fragen Sie Deni jederzeit zur App, die Sie gerade nutzen';

  @override
  String get appearanceSectionTitle => 'Darstellung';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get quickSettingsSectionTitle =>
      'Enprive mit den Schnelleinstellungen verbinden';

  @override
  String get quickSettingsSectionSubtitle =>
      'Fügen Sie Enprive Check zu Ihren Android-Schnelleinstellungen hinzu, damit Sie Deni zu Apps fragen können, ohne zu verlassen, was Sie gerade tun.';

  @override
  String get quickSettingsTileTitle => 'Kachel „Enprive Check“';

  @override
  String get quickSettingsTileSubtitle =>
      'Fügen Sie Enprive Check zu den Schnelleinstellungen hinzu, um Deni zur gerade genutzten App zu fragen, ohne erst Enprive zu suchen.';

  @override
  String get quickSettingsStatusAdded => 'Hinzugefügt';

  @override
  String get quickSettingsStatusManual => 'Manuell';

  @override
  String get quickSettingsStatusNotAdded => 'Nicht hinzugefügt';

  @override
  String get usageAccessStatusGranted => 'Erteilt';

  @override
  String get usageAccessStatusNotGranted => 'Nicht erteilt';

  @override
  String get usageAccessTitle => 'Nutzungszugriff erlauben (optional)';

  @override
  String get usageAccessExplanation =>
      'Enprive nutzt den Nutzungszugriff nur, wenn Sie auf Enprive Check tippen, um die App zu erkennen, die Sie gerade verwendet haben. So kann Deni die richtige App und ihre Datenschutzinformationen finden. Enprive überwacht Ihren Bildschirm nicht dauerhaft.';

  @override
  String get usageAccessManageLink => 'So verwalten oder widerrufen Sie ihn';

  @override
  String get usageAccessManageTitle =>
      'Nutzungszugriff verwalten oder widerrufen';

  @override
  String get usageAccessManageBody =>
      'Der Nutzungszugriff ist ein besonderer Schalter in den Android-Einstellungen (kein automatisches Pop-up). Sie können ihn jederzeit unter Android-Einstellungen → Apps → Spezieller App-Zugriff → Nutzungszugriff → enprive ausschalten. Deni bleibt auch ohne ihn nutzbar, indem Sie die App manuell auswählen.';

  @override
  String get openDeniCompanionTitle => 'Deni-Begleiter öffnen';

  @override
  String get openDeniCompanionSubtitle =>
      'Prüfen Sie die Berechtigungen einer zuletzt genutzten oder ausgewählten App, ohne die Schnelleinstellungen.';

  @override
  String get btnGotIt => 'Verstanden';

  @override
  String get quickSettingsReadyDialogTitle =>
      'Enprive Check ist in den Schnelleinstellungen bereit';

  @override
  String get quickSettingsReadyDialogBody =>
      'Wischen Sie zweimal vom oberen Bildschirmrand nach unten und tippen Sie auf „Enprive Check“, wann immer Deni die Berechtigungen einer App erklären soll.';

  @override
  String get quickSettingsManualDialogTitle =>
      'Enprive Check manuell hinzufügen';

  @override
  String get quickSettingsManualDialogBody =>
      '1. Wischen Sie zweimal vom oberen Rand Ihres Android-Bildschirms nach unten, um die Schnelleinstellungen zu öffnen.\n2. Tippen Sie auf die Schaltfläche „Bearbeiten“ (Stift).\n3. Suchen Sie „Enprive Check“ und ziehen Sie es zu Ihren aktiven Kacheln.';

  @override
  String get quickSettingsSnackAdded =>
      'Enprive Check wurde zu Ihren Schnelleinstellungen hinzugefügt.';

  @override
  String get quickSettingsSnackAlreadyAdded =>
      'Enprive Check ist bereits in Ihren Schnelleinstellungen.';

  @override
  String get quickSettingsSnackDeclined =>
      'Anfrage geschlossen. Enprive fragt nicht erneut, es sei denn, Sie wählen in den Schnelleinstellungen „Bearbeiten“.';

  @override
  String get quickSettingsSnackManual =>
      'Wischen Sie in den Schnelleinstellungen nach unten, tippen Sie auf „Bearbeiten“ und ziehen Sie Enprive Check zu Ihren Kacheln.';

  @override
  String get quickSettingsSnackUnavailable =>
      'Die Systemabfrage ist hier nicht verfügbar. Sie können Enprive Check manuell über „Bearbeiten“ in den Schnelleinstellungen hinzufügen.';

  @override
  String get usageAccessOpenFailedSnack =>
      'Die Einstellungen für den Nutzungszugriff konnten auf diesem Gerät nicht geöffnet werden.';

  @override
  String get companionTitle => 'Deni: Enprive-Begleiter';

  @override
  String get companionSubtitle =>
      'Fragen Sie Deni nach den Berechtigungen einer App und danach, was ihre Datenschutzerklärung sagt.';

  @override
  String get companionTooltipReturnToPrev => 'Zur vorherigen App zurückkehren';

  @override
  String get companionTooltipBack => 'Zurück';

  @override
  String get companionLockedBadge => 'SPERRBILDSCHIRM GESCHÜTZT';

  @override
  String get companionLockedTitle =>
      'Entsperren Sie Ihr Telefon, um fortzufahren';

  @override
  String get companionLockedBody =>
      'Enprive blendet App-Namen, angegebene Berechtigungen und Belege der Prüfung aus, solange das Gerät gesperrt ist.';

  @override
  String get companionCheckUnlockBtn => 'Entsperrstatus prüfen';

  @override
  String get companionCheckingAppHeadline =>
      'Es wird geprüft, welche App Sie genutzt haben …';

  @override
  String get companionCheckingAppSubtitle =>
      'Die Prüfung erfolgt einmalig auf diesem Telefon, ohne Ihren Bildschirm zu beobachten.';

  @override
  String get companionGeneralGuideHeadline =>
      'Allgemeiner Leitfaden zu Android-Berechtigungen';

  @override
  String get companionGeneralGuideSubtitle =>
      'Keine App ausgewählt. Enprive erklärt Android-Berechtigungen nur mit lokalen Hinweisen.';

  @override
  String companionLookingAtHeadline(String appName) {
    return 'Sie sehen sich $appName an.';
  }

  @override
  String get companionLookingAtSubtitle =>
      'Die unten aufgeführten Berechtigungen stammen von der App auf Ihrem Telefon. Android steuert weiterhin, welches Pop-up auf dem Bildschirm erscheint.';

  @override
  String get companionThisAppFallback => 'diese App';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return 'Wir haben $appName vor $seconds s gesehen. Stimmt das?';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return 'Wir glauben, Sie nutzen $appName. Stimmt das?';
  }

  @override
  String companionAppIdLine(String packageName) {
    return 'App ID: $packageName';
  }

  @override
  String companionConfirmAppBtn(String appName) {
    return 'Bestätigen · $appName';
  }

  @override
  String get companionChooseAnotherAppBtn => 'Andere App wählen';

  @override
  String get companionWithoutAppContextBtn => 'Ohne App-Bezug';

  @override
  String get companionMultipleAppsTitle => 'Gerade waren mehrere Apps aktiv';

  @override
  String get companionMultipleAppsPrompt =>
      'Bestätigen Sie, welche App Sie ansehen möchten:';

  @override
  String companionSecondsAgo(int seconds) {
    return 'vor $seconds s';
  }

  @override
  String get companionSelectAppTitle => 'App zum Prüfen auswählen';

  @override
  String get companionSelectAppBody =>
      'Wählen Sie die App manuell aus den installierten Apps aus oder fahren Sie ohne App-Bezug fort.';

  @override
  String get companionChooseAppManuallyBtn => 'App manuell wählen';

  @override
  String get companionOpenUsageAccessBtn =>
      'Einstellungen für den Nutzungszugriff öffnen';

  @override
  String get companionContinueWithoutAppBtn => 'Ohne App-Bezug fortfahren';

  @override
  String get companionAddTileBtn => 'Kachel „Enprive Check“ hinzufügen';

  @override
  String get companionContinuingWithoutApp => 'Weiter ohne App-Bezug';

  @override
  String get companionSwitchAppBtn => 'App wechseln';

  @override
  String get companionPermissionsReadLocally =>
      'Die unten gezeigten Berechtigungen werden direkt von Ihrem Telefon gelesen.';

  @override
  String get companionPickPermissionType =>
      'Berechtigungsart zum Erkunden wählen';

  @override
  String get companionPickAppBtn => 'App auswählen';

  @override
  String get companionCouldNotReadPermsTitle =>
      'App-Berechtigungen konnten nicht gelesen werden';

  @override
  String get companionCouldNotReadPermsBody =>
      'Android hat verhindert, die Berechtigungen dieser App zu prüfen.';

  @override
  String get companionUnsurePermBtn => 'Ich weiß nicht, welche Berechtigung';

  @override
  String get companionWhichPermissionPrompt =>
      'Welche Berechtigung möchten Sie verstehen?';

  @override
  String get companionPermissionsListDisclaimer =>
      'Das sind Berechtigungen, die die App auf Ihrem Telefon auflistet, nicht unbedingt das Pop-up, das gerade auf Ihrem Bildschirm zu sehen ist.';

  @override
  String get companionNoSensitivePermsMsg =>
      'Diese App fragt auf Ihrem Telefon keine sensiblen Berechtigungen an.';

  @override
  String get companionGuidedMatchTitle =>
      'Wählen Sie, was das Pop-up auf Ihrem Bildschirm verlangt hat';

  @override
  String get companionGuidedMatchSubtitle =>
      'Enprive kann Ihre aktuelle Android-Abfrage nicht direkt lesen. Wählen Sie die Formulierung, die dem am nächsten kommt, was auf dem Bildschirm erschien:';

  @override
  String get companionSection1Title => '1. Was diese Berechtigung bedeutet';

  @override
  String get companionSection2Title =>
      '2. Was die App auf Ihrem Telefon anfordert';

  @override
  String get companionSection3Title => '3. Was ihre Datenschutzerklärung sagt';

  @override
  String get companionSection4Title =>
      '4. Warum das mit einer Funktion zusammenhängen könnte';

  @override
  String get companionSection4Fallback =>
      'Es wurde keine bestätigte Erklärung des Entwicklers zu einer Funktion gefunden. Beschreiben Sie unten, welche Funktion Sie nutzen wollten, wenn Deni die Relevanz prüfen soll.';

  @override
  String get companionSection5Title => '5. Was unbekannt bleibt';

  @override
  String get companionSection6Title => '6. Fragen, die Sie Deni stellen können';

  @override
  String get companionAddPolicyBtn => 'Datenschutzerklärung hinzufügen';

  @override
  String get companionCheckUpdatedPolicyBtn =>
      'Aktualisierte Datenschutzerklärung prüfen';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return 'Erklärung für $appName prüfen';
  }

  @override
  String get companionFeatureFieldLabel =>
      'Funktion, die Sie genutzt haben (optional)';

  @override
  String get companionFeatureFieldHint =>
      'z. B. QR-Code scannen, Sprachübung aufnehmen';

  @override
  String get companionQuestionFieldLabel => 'Deni eine Frage stellen';

  @override
  String get companionQuestionFieldHint =>
      'Was passiert, wenn ich diese Berechtigung verweigere?';

  @override
  String get companionReceiptSavedTitle => 'In Enprive-Belegen gespeichert';

  @override
  String get companionReceiptUnsavedTitle =>
      'Prüfung noch nicht in Enprive gespeichert';

  @override
  String get companionReceiptSavedBody =>
      'Lokal in Ihrem Archiv der Enprive-Belege gespeichert.';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      'Die aktualisierte Prüfung der Erklärung wird nur in dieser Sitzung aufbewahrt. Wenn Sie den Begleiter verlassen, wird dieser Entwurf verworfen und Ihr gespeicherter Beleg bleibt unverändert.';

  @override
  String get companionReceiptUnsavedBody =>
      'Nur in dieser Sitzung aufbewahrt. Beim Verlassen des Begleiters wird sie verworfen, wenn Sie sie nicht speichern.';

  @override
  String get companionSaveReceiptBtn => 'Beleg in Enprive speichern';

  @override
  String get companionSaveReceiptFailed =>
      'Der Beleg konnte nicht gespeichert werden. Er bleibt in dieser Sitzung erhalten: Versuchen Sie es erneut.';

  @override
  String get companionSavedLocalReceiptsSnack =>
      'In lokalen Belegen gespeichert.';

  @override
  String companionDoneReturnToApp(String appName) {
    return 'Fertig · Zurück zu $appName';
  }

  @override
  String get companionDoneReturnToPrev =>
      'Fertig · Zur vorherigen App zurückkehren';

  @override
  String get companionOpenFullAppBtn => 'Vollständige Enprive-App öffnen';

  @override
  String get companionCloudTimeoutSnack =>
      'Die Cloud-Analyse hat zu lange gedauert und wurde vor dem Abschluss beendet.';

  @override
  String get companionAnalysisCancelledSnack => 'Analyse abgebrochen.';

  @override
  String get companionCloudAnswerTimeoutSnack =>
      'Die Cloud-Antwort ist ohne Probleme abgelaufen.';

  @override
  String get companionQuestionCancelledSnack => 'Frage abgebrochen.';

  @override
  String get companionTileAddedSnack =>
      'Enprive Check wurde zu den Android-Schnelleinstellungen hinzugefügt.';

  @override
  String get companionTileAlreadyAddedSnack =>
      'Enprive Check ist bereits in Ihren Schnelleinstellungen.';

  @override
  String get companionTileDeclinedSnack =>
      'Kachelanfrage geschlossen. Sie können sie jederzeit in den Einstellungen oder über „Bearbeiten“ in den Schnelleinstellungen hinzufügen.';

  @override
  String get companionTileManualSnack =>
      'Wischen Sie zweimal in den Schnelleinstellungen nach unten, tippen Sie auf „Bearbeiten“ und ziehen Sie Enprive Check zu Ihren Kacheln.';

  @override
  String get companionTileUnavailableSnack =>
      'Android konnte die Abfrage für die Schnelleinstellungen auf diesem Gerät nicht anzeigen. Sie können Enprive Check manuell über „Bearbeiten“ in den Schnelleinstellungen hinzufügen.';

  @override
  String get companionUsageOptionalReason =>
      'Der Nutzungszugriff ist optional. Sie können eine App manuell auswählen oder den Nutzungszugriff erlauben, damit die App mit einem Fingertipp erkannt wird.';

  @override
  String get companionPermPreciseLocation => 'Genauer Standort';

  @override
  String get companionPermBackgroundLocation => 'Standort im Hintergrund';

  @override
  String get companionPermCamera => 'Kamera';

  @override
  String get companionPermMicrophone => 'Mikrofon';

  @override
  String get companionPermAdId => 'Google-Werbe-ID';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return 'Android-Berechtigung ($permission), angegeben von $appName.';
  }

  @override
  String get companionPermStatusAdId => 'Von der App aufgelistet · Werbe-ID';

  @override
  String get companionPermStatusAllowed => 'Von der App aufgelistet · Erlaubt';

  @override
  String get companionPermStatusNotAllowed =>
      'Von der App aufgelistet · Nicht erlaubt';

  @override
  String get guidedCatLocation => 'Standort';

  @override
  String get guidedCatContacts => 'Kontakte';

  @override
  String get guidedCatPhotosMedia => 'Fotos und Medien';

  @override
  String get guidedCatNotifications => 'Benachrichtigungen';

  @override
  String get guidedCatNearbyDevices => 'Geräte in der Nähe';

  @override
  String get guidedCatCalendar => 'Kalender';

  @override
  String get guidedCatPhone => 'Telefon';

  @override
  String get guidedCatSms => 'SMS';

  @override
  String get companionFallbackUsageNotEnabled =>
      'Der Nutzungszugriff wurde in den Android-Einstellungen nicht aktiviert.';

  @override
  String get companionFallbackUsageUnavailable =>
      'Android UsageStatsManager ist nicht verfügbar.';

  @override
  String get companionFallbackTransientUi =>
      'In den letzten Nutzungsereignissen erschienen nur Android-System- oder Berechtigungsabfragen. Wählen Sie die App manuell aus.';

  @override
  String get companionFallbackVisibilityRestricted =>
      'Die zuletzt aktive App kann wegen der Android-Einschränkungen für die Paketsichtbarkeit nicht geprüft werden. Bitte wählen Sie eine App aus der Liste oder fügen Sie ihre Erklärung ein.';

  @override
  String get companionFallbackUnlockRequired =>
      'Entsperren Sie Ihr Gerät, bevor Sie den App-Kontext ansehen.';

  @override
  String get consentReasonPolicyTooDetailed =>
      'Diese Datenschutzerklärung ist für die KI-Verarbeitung auf dem Gerät zu umfangreich.';

  @override
  String get consentReasonExcerptTooDetailed =>
      'Dieser Textauszug ist für die KI-Verarbeitung auf dem Gerät zu umfangreich.';

  @override
  String get consentReasonOnDeviceUnavailable =>
      'Die KI auf dem Gerät ist auf diesem Telefon gerade nicht verfügbar.';

  @override
  String get consentReasonOnDeviceCannotAnswer =>
      'Die KI auf dem Gerät konnte gerade von diesem Gerät aus nicht antworten.';

  @override
  String get consentReasonVoiceTooLong =>
      'Diese geprüften Ergebnisse überschreiten die Grenzen der Zusammenfassung auf dem Gerät. Sie können jetzt die Offline-Zusammenfassung nutzen oder die geschwärzten Ergebnisse einmalig an die Cloud-KI senden.';

  @override
  String get consentReasonVoiceUnavailable =>
      'Die KI auf dem Gerät ist auf diesem Telefon gerade nicht verfügbar. Es wird die einfache Offline-Zusammenfassung von Enprive angezeigt.';

  @override
  String get consentReasonVoiceTimedOut =>
      'Die Zusammenfassung auf dem Gerät hat zu lange gedauert. Es wird die einfache Offline-Zusammenfassung von Enprive angezeigt.';

  @override
  String get unsavedExitTitle => 'Diese Datenschutzprüfung speichern?';

  @override
  String get unsavedExitModifiedBody =>
      'Nicht gespeicherte Prüfungen werden verworfen, wenn Sie diesen Bildschirm schließen. So wird nichts ohne Ihre Entscheidung auf Ihrem Telefon gespeichert. Ihr ursprünglich gespeicherter Beleg bleibt unverändert.';

  @override
  String get unsavedExitDraftBody =>
      'Nicht gespeicherte Prüfungen werden verworfen, wenn Sie diesen Bildschirm schließen. So wird nichts ohne Ihre Entscheidung auf Ihrem Telefon gespeichert.';

  @override
  String get unsavedExitDiscardBtn => 'Verwerfen, ohne zu speichern';

  @override
  String get unsavedExitContinueBtn => 'Weiter prüfen';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return 'Datenschutzerklärung aktualisieren für $title';
  }

  @override
  String get reviewSaveFailedError =>
      'Der Beleg konnte nicht gespeichert werden. Ihr Prüfentwurf ist weiterhin geöffnet.';

  @override
  String get reviewRemovedFromReceiptsSnack =>
      'Aus den gespeicherten Belegen entfernt.';

  @override
  String get reviewRemoveFailedSnack =>
      'Der gespeicherte Beleg konnte nicht entfernt werden.';

  @override
  String get reviewModifiedDraftTitle =>
      'Neuer Entwurf aus gespeichertem Beleg';

  @override
  String get reviewModifiedDraftBody =>
      'Speichern Sie ihn in den Belegen, um diese aktualisierte Prüfung zu behalten: Ihr ursprünglich gespeicherter Beleg bleibt unverändert.';

  @override
  String get btnRetrySave => 'Erneut speichern';

  @override
  String samplePermissionsHeader(String badge) {
    return 'Beispielberechtigungen ($badge)';
  }

  @override
  String get sourceKindUrl => 'Öffentlicher Weblink';

  @override
  String get sourceKindPdf => 'Lokale PDF-Datei';

  @override
  String get sourceKindDocx => 'Lokale Word-Datei (DOCX)';

  @override
  String get sourceKindTextFile => 'Lokale Textdatei';

  @override
  String get sourceKindSharedText => 'Geteilter Text';

  @override
  String get sourceKindSelectedText => 'Ausgewählter Text';

  @override
  String get sourceKindSampleApp => 'Beispiel-App';

  @override
  String get sourceKindPhonePermissions => 'Telefonberechtigungen';

  @override
  String get sourceKindPastedText => 'Eingefügter Text';

  @override
  String get extractionStatusExtracted => 'Auf diesem Telefon gelesen';

  @override
  String get extractionStatusNone => 'Auf diesem Telefon bereitgestellt';

  @override
  String get extractionStatusUnsupported => 'Nicht unterstützter Dateityp';

  @override
  String get extractionStatusTooLarge => 'Datei zu groß';

  @override
  String get extractionStatusEmpty => 'Kein lesbarer Text';

  @override
  String get extractionStatusReadError => 'Datei konnte nicht gelesen werden';

  @override
  String get extractionStatusPasswordProtected => 'Passwortgeschützt';

  @override
  String get extractionStatusPermissionDenied => 'Zugriff verweigert';

  @override
  String get extractionStatusCancelled => 'Abgebrochen';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return 'Geprüft am: $timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return 'Kanonische URL: $url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return 'Weitergeleitet von: $url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return 'Datei: $filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return 'Status: $status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return 'SHA-256-Hash der Quelle: $hash';
  }

  @override
  String get semanticsPrimaryNavigation => 'Hauptnavigation';

  @override
  String semanticsProcessingLocation(String label) {
    return 'Verarbeitungsort: $label';
  }

  @override
  String get semanticsDeniMascot => 'Deni, Ihr Datenschutz-Begleiter';

  @override
  String get quoteCollapsibleDefaultHeader =>
      'Genauer Auszug aus der Datenschutzerklärung';
}
