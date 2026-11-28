// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => 'Verifiche sulla privacy basate su prove';

  @override
  String get homePrivacySubtitle =>
      'Le tue verifiche restano su questo telefono.';

  @override
  String get stateNoConcern => 'Nessun elemento critico rilevato';

  @override
  String get stateNoConcernSubtitle =>
      'Nessuna criticità rilevata nelle prove esaminate. Questa non è una certificazione di sicurezza.';

  @override
  String get stateReviewRecommended => 'Verifica consigliata';

  @override
  String get stateReviewRecommendedSubtitle =>
      'Una o più parti dell\'informativa o permessi del telefono meritano uno sguardo più attento.';

  @override
  String get stateInsufficientEvidence => 'Prove insufficienti';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Servono più parti del testo dell\'informativa sulla privacy prima di poter verificare cosa fa questa app.';

  @override
  String get chipOnDevice => 'Su questo dispositivo';

  @override
  String get chipInCloud => 'Nel cloud';

  @override
  String get chipLocationUnavailable => 'Fonte non disponibile';

  @override
  String get chipOfflineDeterministic =>
      'Verificato offline su questo telefono';

  @override
  String get chipUnknown => 'Fonte sconosciuta';

  @override
  String get statusSourceMatched => 'Trovato nell\'informativa';

  @override
  String get statusDeviceObserved => 'Rilevato su questo telefono';

  @override
  String get statusInterpretation => 'Spiegazione di Deni';

  @override
  String get statusUnverified => 'Non trovato nell\'informativa';

  @override
  String get statusStale => 'Verifica precedente';

  @override
  String get btnCheckApp => 'Controlla un\'app';

  @override
  String get btnPasteTerms => 'Incolla informativa o URL';

  @override
  String get btnWhyThisFinding => 'Perché questo risultato?';

  @override
  String get btnSaveToReceipts => 'Salva nelle ricevute';

  @override
  String get btnDiscard => 'Scarta';

  @override
  String get btnAskDeni => 'Chiedi a Deni';

  @override
  String get btnUseCloud => 'Usa il cloud per questo controllo';

  @override
  String get btnReviewManually => 'Controlla manualmente';

  @override
  String get btnGetStarted => 'Inizia';

  @override
  String get btnContinue => 'Continua';

  @override
  String get deniIntro =>
      'Ciao, sono Deni. Ti aiuto a capire cosa dice questa informativa sulla privacy, a vedere le prove esatte e ciò che Enprive non ha potuto verificare.';

  @override
  String get cloudConsentDisclosure =>
      'Per eseguire questa verifica nel cloud, Enprive invierà solo il testo mostrato sopra (con i dati personali nascosti) per questa singola richiesta. Le tue app e i permessi del telefono non vengono mai inviati.';

  @override
  String get permissionLimitationNotice =>
      'Il tuo telefono mostra se questo permesso è consentito. Non prova se l\'app ha davvero letto o inviato dati.';

  @override
  String get navHome => 'Home';

  @override
  String get navCheck => 'Verifica';

  @override
  String get navReceipts => 'Ricevute';

  @override
  String get navLearn => 'Impara';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get chooseLanguage => 'Scegli la lingua';

  @override
  String get languageSubtitle =>
      'Si applica a interfaccia, spiegazioni e lettura vocale';

  @override
  String get homeHeroHeadline =>
      'Uno sguardo più chiaro alle\napp usate dai bambini';

  @override
  String get trySampleCheck => 'Prova un controllo di esempio';

  @override
  String get eduTrackSubtitle => 'Compiti e presenze';

  @override
  String get eduTrackValue => '3 richieste';

  @override
  String get eduTrackTrend => 'Controlla';

  @override
  String get calmMathSubtitle => 'Esercizi di matematica offline';

  @override
  String get calmMathValue => '0 sensibili';

  @override
  String get calmMathTrend => 'Minimo';

  @override
  String get whatWeCheckTitle => 'Cosa controlliamo';

  @override
  String get checkQuoteTitle => 'Citazioni esatte dall\'informativa';

  @override
  String get checkQuoteDesc =>
      'Evidenzia condivisione dei dati, registrazione vocale e durata di conservazione con citazioni esatte.';

  @override
  String get checkPermissionTitle => 'Discrepanze nei permessi';

  @override
  String get checkPermissionDesc =>
      'Confronta l\'accesso a Fotocamera, Microfono e Posizione con quanto dichiarato.';

  @override
  String get checkSelectTitle => 'Seleziona testo ovunque';

  @override
  String get checkSelectDesc =>
      'Evidenzia i termini in qualsiasi app e tocca Enprive Check dal menu Android.';

  @override
  String get recentlyReviewed => 'Verificati di recente';

  @override
  String verifiedClausesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citazioni corrispondenti',
      one: '1 citazione corrispondente',
    );
    return '$_temp0';
  }

  @override
  String get trySampleText => 'Prova testo di esempio';

  @override
  String get modePasteText => 'Incolla testo';

  @override
  String get modePolicyLink => 'Link informativa';

  @override
  String get hintAppName => 'Nome dell\'app';

  @override
  String get defaultSubjectTitle => 'Informativa sulla privacy';

  @override
  String get selectedExcerptTitle => 'Estratto selezionato';

  @override
  String get hintPastePolicy =>
      'Incolla qui il testo dell\'informativa sulla privacy…';

  @override
  String get btnReviewOnPhone => 'Controlla su questo telefono';

  @override
  String get onboardingIntroHeadline => 'Ciao, sono Deni. 👋';

  @override
  String get onboardingIntroLead =>
      'Rendiamo la privacy delle app più facile da capire.';

  @override
  String get onboardingIntroBody =>
      'Ti aiuterò a scoprire cosa dice davvero l\'informativa sulla privacy di un\'app, evidenzierò i passaggi esatti che contano e spiegherò cosa segnala il tuo dispositivo.\n\nNiente supposizioni. Niente false promesse. Solo spiegazioni chiare e prove concrete per decidere in modo consapevole.';

  @override
  String get onboardingIntroFooter => 'Sappi sempre a cosa stai acconsentendo.';

  @override
  String get splashQuote => 'Sappi sempre a cosa stai acconsentendo';

  @override
  String get onboardingStep1Question =>
      'Come preferisci che spieghi\ni termini sulla privacy?';

  @override
  String get depthQuickMultiline => 'Breve e\nsemplice';

  @override
  String get depthBalancedMultiline => 'Vista\nequilibrata';

  @override
  String get depthFullMultiline => 'Dettagli\ncompleti';

  @override
  String get onboardingReadinessTitle =>
      'Privato per impostazione\npredefinita su questo telefono';

  @override
  String get onboardingReadinessSubtitle =>
      'Progettato perché genitori e insegnanti controllino le app senza condividere dati del dispositivo.';

  @override
  String get readinessRow1Title => 'Controllato prima qui';

  @override
  String get readinessRow1Desc =>
      'Le informative vengono lette prima sul tuo telefono.';

  @override
  String get readinessRow2Title => 'Le tue app restano tue';

  @override
  String get readinessRow2Desc =>
      'Le app su questo telefono e i relativi permessi non lasciano mai il dispositivo.';

  @override
  String get readinessRow3Title => 'Dati personali nascosti';

  @override
  String get readinessRow3Desc =>
      'Se scegli l\'aiuto nel cloud, nomi, email e numeri di telefono vengono nascosti prima di inviare qualsiasi cosa.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get privateAnalysisTitle => 'Analisi privata su questo telefono';

  @override
  String get onDeviceReadyMsg => 'L\'IA sul dispositivo è attiva e pronta.';

  @override
  String get localScannerProtectedMsg =>
      'Pronto per verificare le informative offline su questo telefono.';

  @override
  String get statusChecking => 'Verifica in corso…';

  @override
  String get btnCheckReadiness => 'Verifica stato';

  @override
  String get howShouldDeniExplain => 'Come dovrebbe spiegare Deni?';

  @override
  String get depthQuick => 'Breve';

  @override
  String get depthBalanced => 'Bilanciato';

  @override
  String get depthFull => 'Dettagliato';

  @override
  String get preferencesSection => 'Preferenze';

  @override
  String get meetDeniGuide => 'Conosci Deni e la guida iniziale';

  @override
  String clearSavedReceiptsCount(int count) {
    return 'Cancella ricevute salvate ($count)';
  }

  @override
  String get btnClear => 'Cancella';

  @override
  String get confirmClearReceiptsTitle => 'Cancellare le ricevute salvate?';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Questo rimuoverà $count verifiche salvate dal tuo telefono.',
      one: 'Questo rimuoverà 1 verifica salvata dal tuo telefono.',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'Annulla';

  @override
  String get receiptsTitle => 'Ricevute';

  @override
  String get tooltipSearch => 'Cerca';

  @override
  String get hintSearchReceipts => 'Cerca verifiche salvate...';

  @override
  String get filterAll => 'Tutte';

  @override
  String get filterReview => 'Da rivedere';

  @override
  String get filterNoConcern => 'Nessun avviso';

  @override
  String get emptyFilteredTitle => 'Nessuna ricevuta corrispondente';

  @override
  String get emptyReceiptsTitle => 'Nessuna ricevuta salvata';

  @override
  String get emptyFilteredBody => 'Prova a selezionare un altro filtro sopra.';

  @override
  String get emptyReceiptsBody =>
      'Salva nei segnalibri qualsiasi controllo per conservare una copia privata sul telefono.';

  @override
  String get btnStartReview => 'Avvia una verifica';

  @override
  String get btnOpenReceipt => 'Apri ricevuta';

  @override
  String get btnDelete => 'Elimina';

  @override
  String get checkingPhoneReadiness =>
      'Verifica della disponibilità dell\'analisi privata su questo telefono…';

  @override
  String get geminiNanoReadyMsg =>
      'L\'IA sul dispositivo è pronta su questo telefono. Le verifiche restano completamente sul tuo dispositivo.';

  @override
  String get modelDownloadingMsg =>
      'Download del modello privato sul dispositivo in background.';

  @override
  String get modelDownloadableMsg =>
      'Il modello sul dispositivo può essere scaricato tramite Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'Questo telefono verifica le informative offline sul dispositivo per impostazione predefinita.';

  @override
  String get preparingPrivateAnalysis => 'Preparazione analisi privata…';

  @override
  String get onDeviceAiReadyTitle => 'IA locale pronta';

  @override
  String get localScannerActiveTitle => 'Verifica offline pronta';

  @override
  String get privateAnalysisSheetSubtitle =>
      'Le tue app installate e i permessi non lasciano mai il telefono.';

  @override
  String get btnDone => 'Fine';

  @override
  String get btnCheckAgain => 'Controlla di nuovo';

  @override
  String get reviewingOnPhone => 'Verifica su questo telefono…';

  @override
  String get readingClausesInitial =>
      'Lettura del testo dell\'informativa su questo telefono…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current di $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passaggi',
      one: '1 passaggio',
    );
    return '$_temp0';
  }

  @override
  String get thoughtSignaturePrefix => 'ID verifica';

  @override
  String get viewStreamedThoughts => 'Come Enprive ha verificato questo';

  @override
  String get hideStreamedThoughts =>
      'Nascondi come Enprive ha verificato questo';

  @override
  String get analysisTraceDefaultTitle =>
      'Come è stato verificato questo controllo';

  @override
  String get savedToLocalReceiptsSnack => 'Salvato nelle ricevute locali.';

  @override
  String get snapshotSheetTitle => 'Testo dell\'informativa verificata';

  @override
  String get snapshotSourcePrefix => 'Fonte';

  @override
  String get snapshotReviewedPrefix => 'Esaminata';

  @override
  String get snapshotDigestPrefix => 'Impronta del documento';

  @override
  String get statFindings => 'Risultati';

  @override
  String get statVerified => 'Verificati';

  @override
  String get statOsGranted => 'Consentito sul telefono';

  @override
  String get statUnverified => 'Non trovato';

  @override
  String get keyFindingsTitle => 'Risultati principali';

  @override
  String get reviewedExcerptTitle => 'Estratto esaminato';

  @override
  String get permissionsOnPhoneTitle => 'Permessi su questo telefono';

  @override
  String get viewReviewedSnapshot => 'Visualizza testo verificato';

  @override
  String get btnSavedToReceipts => 'Salvato nelle ricevute';

  @override
  String get observedOnPhoneLabel => 'Rilevato su questo telefono';

  @override
  String get quoteVerifiedLabel => 'Citazione esatta dall\'informativa';

  @override
  String get unverifiedClaimLabel => 'Non trovato nell\'informativa';

  @override
  String get categoryDataCollection => 'Raccolta dati';

  @override
  String get categorySharing => 'Condivisione con terzi';

  @override
  String get categoryTracking => 'Posizione e tracciamento';

  @override
  String get categoryRetention => 'Conservazione e voce';

  @override
  String get categoryParentalControls => 'Controllo genitori';

  @override
  String get labelInPlainLanguage => 'In parole semplici';

  @override
  String get labelOnThisPhone => 'Su questo telefono';

  @override
  String get labelWhatRemainsUnknown => 'Cosa non sappiamo ancora';

  @override
  String get presetQuestionMeaning => 'Cosa significa per mio figlio?';

  @override
  String get presetQuestionOptOut =>
      'Possiamo disattivarlo o negare il consenso?';

  @override
  String get presetQuestionUnknown => 'Cosa resta ancora poco chiaro qui?';

  @override
  String get readingCitedClause => 'Lettura della citazione dell\'informativa…';

  @override
  String get deniAnswerTitle => 'Risposta di Deni';

  @override
  String get stepsAndReasoning => 'Come Deni ha verificato questo';

  @override
  String get chooseReviewModeTitle => 'Scegli come analizzare questo testo';

  @override
  String get cloudNeverSendsAppsNote =>
      'Le app installate e i permessi del telefono non vengono mai inviati.';

  @override
  String get tooltipClose => 'Chiudi';

  @override
  String get checkAppSheetSubtitle =>
      'Controllato localmente sul telefono. L\'elenco delle app non viene mai caricato.';

  @override
  String get trySampleKidsApp => 'Prova un\'app per bambini di esempio';

  @override
  String get sampleEduTrackSubtitle => 'Posizione, microfono e fotocamera';

  @override
  String get sampleCalmMathSubtitle => 'Matematica offline';

  @override
  String get appsOnThisPhone => 'App su questo telefono';

  @override
  String get hintSearchApps => 'Cerca app…';

  @override
  String get noMatchingApps =>
      'Nessuna app corrispondente trovata su questo telefono.';

  @override
  String get sampleSyntheticBadge => 'App di esempio';

  @override
  String get permissionInspectionTitle => 'Permessi del telefono verificati';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Aggiungi l\'informativa sulla privacy di questa app';

  @override
  String get snapshotDigestLabel => 'Impronta del documento';

  @override
  String get snapshotDigestExplanation =>
      'Un codice univoco che aiuta a verificare che questo sia esattamente il testo controllato da Enprive. Se cambia anche una sola lettera, cambia anche questo codice.';

  @override
  String get copyDigestBtn => 'Copia impronta';

  @override
  String get digestCopiedMsg => 'Impronta del documento copiata';

  @override
  String get permissionGrantedBadge => 'Consentito su questo telefono';

  @override
  String get permissionNotGrantedBadge => 'Non consentito';

  @override
  String get checkingPolicyWithCloudAi =>
      'Verifica dell\'informativa con l\'IA cloud.';

  @override
  String get preparingCloudAiStream =>
      'Nascondo i dati personali prima della verifica nel cloud…';

  @override
  String get cancellingAnalysis => 'Annullamento…';

  @override
  String get analysisCancelledNotice => 'Analisi annullata.';

  @override
  String get cloudTimedOutNotice =>
      'L\'IA cloud ha superato il tempo limite prima di rispondere. Nessun nuovo tentativo automatico inviato.';

  @override
  String get cloudFallbackBannerTitle =>
      'Il controllo cloud non è riuscito a completarsi';

  @override
  String get cloudFallbackBannerBody =>
      'Questo è il risultato ottenuto sul tuo telefono e non è stato inviato nulla di nuovo. Il testo dell\'informativa è conservato. Non viene salvato nulla finché non tocchi Salva.';

  @override
  String get cloudFallbackRetryAction => 'Riprova il controllo cloud';

  @override
  String get appPickerFilterAll => 'Tutte le app';

  @override
  String get appPickerFilterDownloaded => 'Scaricate';

  @override
  String get appPickerFilterSystem => 'Di sistema';

  @override
  String get appPickerRecentlyChecked => 'Verificate di recente';

  @override
  String get appPickerStatusPolicySaved => 'Verifica informativa salvata';

  @override
  String get appPickerStatusPermissionsInspected => 'Permessi verificati';

  @override
  String get appPickerStatusNotReviewed => 'Non verificata';

  @override
  String get appPickerSearchHint => 'Cerca per nome app o App ID…';

  @override
  String get appPickerEmptyInstalledTitle =>
      'Nessuna app installata disponibile';

  @override
  String get appPickerEmptyInstalledBody =>
      'Non abbiamo trovato app da verificare su questo telefono.';

  @override
  String get intakeModeDocument => 'Documento';

  @override
  String get intakeActionInspectText => 'Verifica testo dell\'informativa';

  @override
  String get intakeActionFetchUrl => 'Apri e verifica informativa';

  @override
  String get intakeActionChooseDocument => 'Scegli PDF, TXT o DOCX';

  @override
  String get intakeActionReplaceDocument => 'Scegli documento sostitutivo';

  @override
  String get intakeWorkingLabel => 'Elaborazione…';

  @override
  String get intakeCancelFetch => 'Annulla caricamento';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'Carica direttamente questa pagina web pubblica. Aggiungere un link qui non dimostra chi possiede l\'app.';

  @override
  String get intakePasteLocalNote =>
      'Verificato prima in locale su questo telefono. Nulla viene caricato senza il tuo consenso.';

  @override
  String get intakeDocumentCardTitle =>
      'Importa file PDF, TXT o DOCX dell\'informativa';

  @override
  String get intakeDocumentCardBody =>
      'Leggiamo il testo direttamente sul tuo telefono (fino a 10 MB). Il tuo file non viene mai caricato.';

  @override
  String get intakeCompareWithAppPrompt =>
      'Confronta con un\'app installata (facoltativo)';

  @override
  String get intakeCompareWithAppHint =>
      'Funziona in locale su questo telefono. L\'elenco delle tue app non lascia mai il dispositivo.';

  @override
  String get intakeCompareWithAppChange => 'Cambia';

  @override
  String get intakeCompareWithAppRemove => 'Rimuovi';

  @override
  String get intakeLockedAppContextLabel => 'App selezionata';

  @override
  String get intakeFindPolicyOnPlayStore =>
      'Trova il link dell\'informativa su Play Store';

  @override
  String get intakePlayStoreHelperNote =>
      'Apre il Play Store così puoi copiare il link dell\'informativa sulla privacy dell\'app. Enprive non lo copia mai automaticamente né presume che sia ufficiale.';

  @override
  String get intakePlayStoreUnavailable =>
      'Impossibile aprire Google Play Store su questo dispositivo. Incolla manualmente l\'URL o il testo dell\'informativa.';

  @override
  String get intakeRecoverySwitchPaste => 'Incolla il testo invece';

  @override
  String get intakeRecoverySwitchDocument => 'Importa documento';

  @override
  String get intakeRecoveryRetryUrl => 'Riprova caricamento';

  @override
  String get intakeExpiredDocumentShareNotice =>
      'Il link al file condiviso in origine non può più essere riaperto. Scegli un altro file PDF, TXT o DOCX oppure incolla manualmente il testo dell\'informativa.';

  @override
  String get intakeAssociationWarningTitle =>
      'Controllo corrispondenza app e informativa';

  @override
  String get intakeAssociationContinueAnyway => 'Continua comunque';

  @override
  String get intakeAssociationChangeApp => 'Cambia app selezionata';

  @override
  String get intakeAssociationInspectWithoutApp =>
      'Verifica informativa senza app';

  @override
  String get intakeModeSelectorSemanticLabel =>
      'Metodo di inserimento dell\'informativa';

  @override
  String get tooltipClearSearch => 'Cancella ricerca';

  @override
  String get intakeRecoveryEditUrl => 'Modifica URL';

  @override
  String get voiceSummaryTitle => 'Riepilogo di Deni in parole semplici';

  @override
  String get voiceSummaryPreparing =>
      'Preparazione del riepilogo in parole semplici…';

  @override
  String get voiceSynthesizingExpressive =>
      'Preparazione della voce espressiva di Deni…';

  @override
  String get voiceBtnListenOffline => 'Ascolta';

  @override
  String get voiceBtnStop => 'Ferma';

  @override
  String get voiceBtnExpressiveCloud => 'Voce espressiva';

  @override
  String get voiceBtnSummarizeCloud => 'Riassumi con IA cloud';

  @override
  String get voiceBadgeExpressive => 'Voce espressiva cloud';

  @override
  String get voiceBadgeDeviceOffline => 'Voce del telefono · Offline';

  @override
  String get voiceViewSourceQuote => 'Citazione fonte';

  @override
  String get voiceHideSourceQuote => 'Nascondi citazione';

  @override
  String get voiceInspectFinding => 'Esamina risultato';

  @override
  String get voiceConsentTitle => 'Scegli la voce di Deni';

  @override
  String get voiceConsentDisclosure =>
      'Per leggere questo riepilogo ad alta voce con la voce espressiva cloud di Deni, Enprive invierà solo il testo del riepilogo mostrato sopra (con i dati personali nascosti) per questa singola richiesta. Le tue app e i permessi del telefono non vengono mai inviati.';

  @override
  String get voiceConsentPrimaryAction => 'Usa voce espressiva una volta';

  @override
  String get voiceConsentSecondaryAction => 'Leggi su questo telefono';

  @override
  String get voiceConsentPayloadLabel => 'Testo esatto da leggere';

  @override
  String get voiceSummaryConsentTitle => 'Riassumi risultati con IA cloud';

  @override
  String get voiceSummaryConsentDisclosure =>
      'Per riassumere in parole semplici queste citazioni nel cloud, Enprive invierà solo il testo mostrato sopra (con i dati personali nascosti) per questa singola richiesta. Le tue app e i permessi del telefono non vengono mai inviati.';

  @override
  String get voiceFallbackDeviceNotice =>
      'La voce espressiva cloud non era disponibile: verrà usata la voce offline di questo telefono.';

  @override
  String get voiceUnavailableNotice =>
      'La lettura vocale non è disponibile per questa lingua su questo telefono. Puoi leggere il riepilogo di Deni sopra.';

  @override
  String get voiceTooltipReadSummary =>
      'Ascolta il riepilogo di Deni in parole semplici';

  @override
  String get voiceTooltipStopReading => 'Ferma lettura vocale';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'risultati',
      one: 'risultato',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '1 risultato',
      zero: 'Nessun risultato',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citazioni verificate nell\'informativa',
      one: '1 citazione verificata nell\'informativa',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rilevati su questo telefono',
      one: '1 rilevato su questo telefono',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'Consentito su questo telefono';

  @override
  String get permissionNotAllowedOnPhone => 'Non consentito';

  @override
  String get permissionAllowedInSample => 'Consentito nell\'esempio';

  @override
  String get permissionNotAllowedInSample => 'Non consentito nell\'esempio';

  @override
  String get permissionMismatchChip => 'Assente nell\'informativa';

  @override
  String get howEnpriveCheckedThis => 'Come Enprive ha verificato questo';

  @override
  String get hideHowEnpriveChecked =>
      'Nascondi come Enprive ha verificato questo';

  @override
  String get consentWhatWouldBeSent => 'Cosa verrebbe inviato';

  @override
  String get consentSentScope =>
      'Solo il testo nell\'anteprima lascia questo telefono, per questa singola richiesta.';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dati personali vengono nascosti prima.',
      one: '1 dato personale viene nascosto prima.',
      zero: 'Nessun dato personale trovato da nascondere.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'L\'elenco delle tue app e i permessi del telefono restano su questo telefono.';

  @override
  String receiptDeletedSnack(String title) {
    return '$title eliminato';
  }

  @override
  String get btnUndo => 'Annulla';

  @override
  String get readinessPromiseMaskedTitle => 'Dati personali nascosti';

  @override
  String get readinessPromiseMaskedLine =>
      'Se scegli il cloud, nomi, email e numeri vengono nascosti prima.';

  @override
  String findingDetailTitle(int index, int total) {
    return 'Risultato $index di $total';
  }

  @override
  String get findingReviewChip => 'Verifica';

  @override
  String get askDeniAboutThis => 'Chiedi a Deni di questo';

  @override
  String get labelWhatPolicySays => 'Cosa dice l\'informativa';

  @override
  String get labelWhatAndroidReports => 'Cosa mostra il tuo telefono';

  @override
  String get sourceButtonTooltip => 'Fonte verificata';

  @override
  String get linkInstalledAppBtn => 'Collega un\'app installata';

  @override
  String get linkInstalledAppCardTitle =>
      'Confronta con un\'app su questo telefono';

  @override
  String get linkInstalledAppCardBody =>
      'Scegli un\'app installata per confrontare i suoi permessi del telefono con questa informativa nella stessa verifica. L\'elenco delle tue app resta su questo telefono.';

  @override
  String get linkAppPickerTitle => 'Collega un\'app installata';

  @override
  String get changeLinkedAppPickerTitle => 'Cambia app collegata';

  @override
  String get linkAppPickerSubtitle =>
      'Scegli un\'app su questo telefono per confrontarne i permessi con questa informativa. L\'elenco delle tue app non lascia mai questo telefono.';

  @override
  String get linkedAppCurrentlySelectedBadge => 'Collegata';

  @override
  String get linkedAppSectionLabel => 'App collegata su questo telefono';

  @override
  String get btnChangeLinkedApp => 'Cambia app';

  @override
  String get btnUnlinkApp => 'Scollega app';

  @override
  String get btnUpdatePrivacyPolicy => 'Allega informativa aggiornata';

  @override
  String linkedAppSnack(String appName) {
    return '$appName collegata. Permessi confrontati su questo telefono.';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return '$appName collegata. Controlla la nota di corrispondenza qui sotto.';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName è già collegata con gli stessi permessi.';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return '$appName scollegata. Viene mostrata solo la verifica dell\'informativa.';
  }

  @override
  String get associationStatusPackageTitle =>
      'App ID trovato in questa informativa';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'Questa informativa cita $packageName. Ciò suggerisce che potrebbe descrivere $appName, ma il solo testo non dimostra chi possiede questa informativa.';
  }

  @override
  String get associationStatusNameTitle =>
      'Nome dell\'app trovato in questa informativa';

  @override
  String associationStatusNameBody(String appName) {
    return 'Questa informativa cita $appName. Ciò suggerisce che potrebbe descrivere questa app, ma un nome coincidente non dimostra chi possiede questa informativa.';
  }

  @override
  String get associationStatusUnverifiedTitle =>
      'Collegata da te per confronto';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'Questa informativa non cita $appName né il suo App ID. Controlla che sia l\'informativa giusta: collegarla qui non ne dimostra la proprietà.';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'L\'indirizzo web contiene parole di $appName, ma il testo dell\'informativa non nomina questa app. Controlla che sia l\'informativa giusta: collegarla qui non ne dimostra la proprietà.';
  }

  @override
  String get associationStatusUnmatchedTitle =>
      'Questa informativa potrebbe essere di un\'altra app';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'Questa informativa non cita $appName. Nomina invece $otherApps. Controlla di aver collegato l\'app giusta o aperto l\'informativa corretta.';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'Questa informativa cita più di un\'app';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'Questa informativa cita $appName insieme a $otherApps. Potrebbe coprire più app o essere un\'informativa aziendale condivisa, quindi verifica che si applichi qui.';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      'Più app su questo telefono hanno un nome simile';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'Questa informativa cita $appName senza indicare un App ID preciso, e altre app sul tuo telefono ($otherApps) hanno un nome simile. Assicurati di aver collegato quella giusta.';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'Questa informativa potrebbe riferirsi a più di un\'app. Controlla che si applichi a $appName.';
  }

  @override
  String get associationOwnershipLimitation =>
      'Testi e link web non dimostrano mai chi ha pubblicato o possiede un\'informativa.';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count permessi su questo telefono non sono chiaramente menzionati in questa informativa. Una discrepanza invita a guardare più da vicino, non è prova di comportamenti scorretti.',
      one: '1 permesso su questo telefono non è chiaramente menzionato in questa informativa. Una discrepanza invita a guardare più da vicino, non è prova di comportamenti scorretti.',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'Nessuno dei permessi verificati su questo telefono contraddice questa informativa. I permessi da soli non possono mostrare cosa invia davvero un\'app.';

  @override
  String get permissionComparisonLimitationNote =>
      'Il tuo telefono mostra solo le impostazioni dei permessi su questo telefono. Questo confronto invita a guardare più da vicino, non è mai prova di comportamenti scorretti o di invio dati.';

  @override
  String get permissionNotRequestedOnPhone => 'Non richiesto dall\'app';

  @override
  String get permissionNotRequestedInSample => 'Non richiesto nell\'esempio';

  @override
  String get permissionsEmptyComparisonTitle =>
      'Nessun permesso sensibile rilevato in questa verifica';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'Il tuo telefono elenca $requestedCount permessi ($grantedCount consentiti) per $appName, ma nessuno nelle categorie sensibili controllate qui (posizione, fotocamera, microfono, contatti, foto o ID pubblicità).';
  }

  @override
  String get sourceDeviceInspection => 'Verificato su questo telefono';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => 'Dettagli avanzati';

  @override
  String get advancedDetailsSubtitle =>
      'Dettagli tecnici che verificano quando e dove è stato controllato questo testo.';

  @override
  String get sourceSectionTitle => 'Da dove proviene questa informativa';

  @override
  String get cloudPayloadLabel => 'Testo esatto che verrà inviato';

  @override
  String get cloudPayloadNoPiiLabel => 'Nessun dato personale trovato';

  @override
  String cloudPayloadHiddenCount(int count) {
    return 'Nascosti ($count)';
  }

  @override
  String get summarySourceOnDevice => 'Riassunto su questo telefono';

  @override
  String get summarySourceInCloud => 'Riassunto nel cloud';

  @override
  String get summarySourceOffline => 'Riassunto offline su questo telefono';

  @override
  String get summarySourceUnknown => 'Fonte del riepilogo sconosciuta';

  @override
  String get notFromPolicySuffix =>
      'Dalle impostazioni del telefono, non dall\'informativa';

  @override
  String get sampleNotFromPolicySuffix => 'Solo esempio, non dall\'informativa';

  @override
  String get learnHeaderSubtitle => 'Guide e schemi sulla privacy offline';

  @override
  String get learnFilterAll => 'Tutti i temi';

  @override
  String get learnFilterPolicies => 'Informative';

  @override
  String get learnFilterPermissions => 'Permessi';

  @override
  String get learnFilterSharing => 'Condivisione';

  @override
  String get learnFilterEvidence => 'Prove';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passaggi',
      one: '1 passaggio',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle => 'Allena buone abitudini di privacy in locale';

  @override
  String get learnDeckBody =>
      'Lezioni 100% offline con schemi. Le tue app installate e le ricevute non entrano mai in Impara.';

  @override
  String get learnDeckCheckBtn => 'Metti in pratica · Verifica un\'app';

  @override
  String get learnCheckAppBridgeBtn => 'Verifica un\'app su questo telefono';

  @override
  String get learnSectionDiagram => 'Come funziona';

  @override
  String get learnSectionSteps => 'Passaggi chiave';

  @override
  String get learnSectionQuickCheck => 'Controllo rapido';

  @override
  String get learnTooltipListenLesson => 'Ascolta questa lezione offline';

  @override
  String get learnTooltipStopLesson => 'Ferma lettura della lezione';

  @override
  String get learnVoiceUnavailableNotice =>
      'La lettura vocale offline non è disponibile per questa lingua su questo telefono. Puoi leggere la lezione qui sotto.';

  @override
  String get learnQuickCheckCorrectBadge => 'Risposta giusta';

  @override
  String get learnQuickCheckTryAgainBadge => 'Prova un\'altra scelta';

  @override
  String learnLessonProgress(int current, int total) {
    return 'Lezione $current di $total';
  }

  @override
  String get learnBackTooltip => 'Torna a Impara';

  @override
  String get learnPreviousLesson => 'Precedente';

  @override
  String get learnNextLesson => 'Successiva';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return 'Lezione precedente: $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return 'Lezione successiva: $title';
  }

  @override
  String get learnPolicyFolderTitle => 'Informative sulla privacy';

  @override
  String get learnPolicyTitle =>
      'Cos\'è un\'informativa sulla privacy (e cosa non può provare)';

  @override
  String get learnPolicySubtitle =>
      'Cosa promettono gli sviluppatori rispetto a ciò che resta ignoto';

  @override
  String get learnPolicyIntro =>
      'Un\'informativa sulla privacy è la dichiarazione pubblica di uno sviluppatore che spiega quali dati un\'app dice di raccogliere, perché li usa, chi può riceverli e quali scelte hanno le famiglie.';

  @override
  String get learnPolicyStep1 =>
      'Cerca quattro punti base: quali dati vengono raccolti, perché l\'app ne ha bisogno, chi altro può riceverli e come chiedere la cancellazione.';

  @override
  String get learnPolicyStep2 =>
      'Il linguaggio confuso è comune. Uno studio del 2026 sulle app educative per bambini ha rilevato che pochissime informative erano facili da leggere e la maggior parte delle app non corrispondeva del tutto a quanto dichiarato.';

  @override
  String get learnPolicyStep3 =>
      'Un\'informativa mostra solo ciò che lo sviluppatore dice su carta. Leggerla non può provare cosa l\'app invia davvero su Internet.';

  @override
  String get learnPolicyStep4 =>
      'Confrontare un\'informativa con i permessi del tuo telefono offre un quadro più chiaro, ricordando che Enprive non può vedere il traffico Internet in tempo reale.';

  @override
  String get learnPolicyQuickQuestion =>
      'Cosa dimostra leggere l\'informativa sulla privacy di un\'app?';

  @override
  String get learnPolicyQuickOption1 =>
      'Che l\'app non invia mai dati a nessuno';

  @override
  String get learnPolicyQuickOption2 =>
      'Cosa dice lo sviluppatore: non ciò che l\'app invia davvero';

  @override
  String get learnPolicyQuickOption3 =>
      'Che fotocamera e microfono del telefono sono spenti';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'Esatto. Un\'informativa è la dichiarazione pubblica dello sviluppatore, non una prova di ciò che l\'app invia realmente su Internet.';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      'Non proprio. Leggere un\'informativa dice solo cosa dichiara lo sviluppatore: non può provare l\'attività Internet né disattivare i permessi del telefono.';

  @override
  String get learnDiagramPolicySaysTitle => 'L\'informativa dice';

  @override
  String get learnDiagramPolicySaysBody =>
      'Promessa scritta dello sviluppatore';

  @override
  String get learnDiagramPolicyQuoteSample =>
      '\"Possiamo condividere dati con partner…\"';

  @override
  String get learnDiagramPhoneShowsTitle => 'Il telefono mostra';

  @override
  String get learnDiagramPhoneShowsBody => 'Permessi consentiti qui';

  @override
  String get learnDiagramUnknownTitle => 'Ancora ignoto';

  @override
  String get learnDiagramUnknownBody =>
      'Traffico Internet live che Enprive non vede';

  @override
  String get learnDiagramPolicyCaption =>
      'Un\'informativa è una promessa, non prova di comportamento';

  @override
  String get learnDiagramPolicySemantic =>
      'Schema che confronta tre aspetti della privacy delle app. Primo, L\'informativa dice: la promessa scritta dello sviluppatore. Secondo, Il telefono mostra: i permessi consentiti su questo telefono. Terzo, in un riquadro tratteggiato, Ancora ignoto: traffico Internet in tempo reale che Enprive non può vedere. Un\'informativa sulla privacy è una promessa, non una prova di comportamento.';

  @override
  String get learnPermissionsFolderTitle => 'Permessi del telefono';

  @override
  String get learnPermissionsTitle => 'Permessi Android spiegati semplice';

  @override
  String get learnPermissionsSubtitle =>
      'Le quattro scelte di Android e dove controllarle';

  @override
  String get learnPermissionsIntro =>
      'I permessi sono porte che controllano se un\'app può accedere a sensori e dati del tuo telefono, come fotocamera, microfono, posizione, foto, contatti o notifiche.';

  @override
  String get learnPermissionsStep1 =>
      'Chiediti se il permesso serve davvero alla funzione: un quiz di matematica o un\'app di lettura raramente ha bisogno di posizione, contatti o fotocamera.';

  @override
  String get learnPermissionsStep2 =>
      'Android offre fino a quattro scelte: Non consentire, Chiedi ogni volta, Consenti solo mentre usi l\'app e Consenti sempre (per la posizione in background).';

  @override
  String get learnPermissionsStep3 =>
      'Inizia dalla scelta più restrittiva che fa funzionare l\'app, come Chiedi ogni volta o Mentre usi l\'app.';

  @override
  String get learnPermissionsStep4 =>
      'Apri le Impostazioni Android e controlla la Dashboard della privacy per vedere quali app hanno usato di recente Fotocamera, Microfono o Posizione.';

  @override
  String get learnPermissionsStep5 =>
      'Disattiva i permessi quando vuoi nelle Impostazioni app, oppure tieni attiva la sospensione delle app inutilizzate così Android rimuove automaticamente i vecchi permessi. Un permesso consentito indica una possibilità, non la prova che siano stati inviati dati.';

  @override
  String get learnPermissionsQuickQuestion =>
      'Un\'app di matematica chiede la fotocamera e non sai perché. Qual è il miglior primo passo?';

  @override
  String get learnPermissionsQuickOption1 =>
      'Toccare Non consentire e verificare se gli esercizi funzionano lo stesso';

  @override
  String get learnPermissionsQuickOption2 =>
      'Scegliere Consenti sempre così l\'avviso non ricompare';

  @override
  String get learnPermissionsQuickOption3 =>
      'Dare per scontato che l\'app abbia già caricato foto';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      'Giusto. Toccare Non consentire ti permette di verificare se l\'app funziona senza fotocamera, e puoi cambiare i permessi in qualsiasi momento nelle Impostazioni Android.';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'Prova prima una scelta più limitata. Tocca Non consentire per testare se la funzione va comunque, e ricorda che un permesso consentito mostra una possibilità, non la prova di un invio.';

  @override
  String get learnDiagramPermLadderTitle =>
      'Dall\'accesso più ristretto al più ampio';

  @override
  String get learnDiagramPermDenyTitle => 'Non consentire';

  @override
  String get learnDiagramPermDenyDetail =>
      'Bloccato: l\'app non può usare questo sensore';

  @override
  String get learnDiagramPermAskTitle => 'Chiedi ogni volta';

  @override
  String get learnDiagramPermAskDetail =>
      'Accesso singolo quando tocchi consenti';

  @override
  String get learnDiagramPermWhileUsingTitle => 'Mentre usi l\'app';

  @override
  String get learnDiagramPermWhileUsingDetail =>
      'Solo mentre l\'app è aperta sullo schermo';

  @override
  String get learnDiagramPermAllTimeTitle => 'Sempre';

  @override
  String get learnDiagramPermAllTimeDetail =>
      'Accesso in background anche da chiusa';

  @override
  String get learnDiagramPermFitNote =>
      'Ha senso? Quiz di matematica + Fotocamera = chiedi perché';

  @override
  String get learnDiagramPermSemantic =>
      'Scala a quattro livelli dei permessi Android dall\'accesso più ristretto al più ampio. Livello 1, Non consentire: bloccato, l\'app non può usare questo sensore. Livello 2, Chiedi ogni volta: accesso singolo quando tocchi consenti. Livello 3, Mentre usi l\'app: accesso solo mentre l\'app è aperta sullo schermo. Livello 4, Sempre: accesso in background anche da chiusa, evidenziato con bordo tratteggiato per maggiore cautela. Consiglio in fondo: Ha senso? Un quiz di matematica che chiede la fotocamera è un motivo per chiedere perché.';

  @override
  String get learnSharingFolderTitle => 'Pubblicità e terzi';

  @override
  String get learnSharingTitle =>
      'Chi altro riceve dati: pubblicità, statistiche e terzi';

  @override
  String get learnSharingSubtitle =>
      'Creatore dell\'app rispetto a servizi di supporto, analisi e reti pubblicitarie';

  @override
  String get learnSharingIntro =>
      'Molte app gratuite si collegano ad altre aziende dietro le quinte. Sapere chi riceve le informazioni aiuta le famiglie a distinguere tra far funzionare l\'app e tracciare i bambini tra app diverse.';

  @override
  String get learnSharingStep1 =>
      'Prima parte significa il creatore stesso dell\'app: per esempio salvare i progressi dei compiti o i punteggi dei quiz per far funzionare l\'app.';

  @override
  String get learnSharingStep2 =>
      'I servizi di supporto sono terze parti che gestiscono compiti dietro le quinte, come l\'archiviazione cloud o i report sugli errori per correggere i bug.';

  @override
  String get learnSharingStep3 =>
      'Gli strumenti di analisi misurano l\'uso delle schermate, mentre le reti pubblicitarie e i broker di dati possono usare un ID pubblicità per mostrare annunci mirati o creare profili tra app.';

  @override
  String get learnSharingStep4 =>
      'Fai attenzione a espressioni vaghe come \'partner affidabili\' o \'scopi commerciali\' e verifica se l\'informativa spiega come disattivare gli annunci personalizzati.';

  @override
  String get learnSharingQuickQuestion =>
      'Un\'informativa dice che l\'app condivide dati con \'partner terzi\'. Qual è la prossima domanda migliore?';

  @override
  String get learnSharingQuickOption1 =>
      'Presumere che l\'app non abbia pubblicità';

  @override
  String get learnSharingQuickOption2 =>
      'Presumere che tutti i partner facciano esattamente lo stesso lavoro';

  @override
  String get learnSharingQuickOption3 =>
      'Verificare se quei partner sono servizi di supporto (come l\'hosting) o reti pubblicitarie che tracciano tra app';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'Esatto. I servizi di supporto mantengono attiva l\'app, mentre le reti pubblicitarie e i broker di dati possono tracciare l\'attività tra app.';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      'Guarda meglio cosa fa ogni partner. Non tutte le terze parti sono uguali: alcune ospitano dati o risolvono crash, mentre altre gestiscono annunci o tracciamento.';

  @override
  String get learnDiagramThirdPartyYou => 'Tu';

  @override
  String get learnDiagramThirdPartyApp => 'App educativa';

  @override
  String get learnDiagramThirdPartyHosting => 'Supporto e crash';

  @override
  String get learnDiagramThirdPartyAnalytics => 'Statistiche';

  @override
  String get learnDiagramThirdPartyAds => 'Reti pubblicitarie';

  @override
  String get learnDiagramThirdPartyFirstParty => 'Prima parte';

  @override
  String get learnDiagramThirdPartyThirdParty => 'Terze parti';

  @override
  String get learnDiagramThirdPartySemantic =>
      'Diagramma di flusso che mostra dove possono andare i dati di un\'app educativa per bambini. Tu ti colleghi all\'app educativa, che si collega con linea continua al creatore dell\'app (prima parte) e con linee tratteggiate alle terze parti: servizi di supporto e crash, strumenti di analisi e reti pubblicitarie evidenziate per maggiore attenzione.';

  @override
  String get learnEvidenceFolderTitle => 'Leggere Enprive';

  @override
  String get learnEvidenceTitle => 'Come leggere le prove di Enprive';

  @override
  String get learnEvidenceSubtitle =>
      'Livelli di prova, categorie e limiti onesti';

  @override
  String get learnEvidenceIntro =>
      'Enprive separa ciò che dice l\'informativa, ciò che mostra il telefono e ciò che resta ignoto, e raggruppa i risultati per argomento, mai come un voto di sicurezza.';

  @override
  String get learnEvidenceStep1 =>
      'Cinque categorie tematiche raggruppano ogni risultato con la stessa icona e lo stesso colore della schermata di Verifica. Il colore indica il tema, mai un punteggio di sicurezza.';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '$sourceMatched significa che Enprive ha trovato una citazione esatta, parola per parola, nel testo dell\'informativa verificata.';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '$deviceObserved significa che il tuo telefono ha segnalato un permesso su questo dispositivo: non prova che siano stati inviati dati.';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '$interpretation è la spiegazione in parole semplici di Deni, mentre $unverified segnala dettagli che Enprive non ha trovato. Il silenzio in un\'informativa non è mai una promessa.';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return 'Le verifiche terminano con uno di tre esiti chiari: $reviewRecommended, $noConcern (che non è mai una certificazione di sicurezza) oppure $insufficientEvidence.';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return 'Nella schermata di Verifica, cosa significa \'$deviceObserved\'?';
  }

  @override
  String get learnEvidenceQuickOption1 =>
      'Che l\'app è certificata sicura per i bambini';

  @override
  String get learnEvidenceQuickOption2 =>
      'Che il tuo telefono mostra questo permesso sul dispositivo: non prova che siano stati caricati dati';

  @override
  String get learnEvidenceQuickOption3 =>
      'Che l\'app ha sicuramente caricato i dati di tuo figlio';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'Esatto. Questa etichetta riflette lo stato del permesso Android sul dispositivo; non può provare caricamenti né certificare la sicurezza.';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      'Non proprio. Questa etichetta mostra solo ciò che segnala il telefono su un permesso: non prova mai caricamenti e non è mai una certificazione di sicurezza.';

  @override
  String get learnDiagramEvidencePolicyDetail =>
      'Citazione esatta trovata nel testo dell\'informativa';

  @override
  String get learnDiagramEvidencePhoneDetail =>
      'Permessi del telefono su questo dispositivo';

  @override
  String get learnDiagramEvidenceDeniDetail =>
      'Spiegazione in parole semplici di Deni';

  @override
  String get learnDiagramEvidenceUnknownDetail =>
      'Il silenzio nell\'informativa non è una promessa';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Quattro livelli di prova usati nella schermata di Verifica di Enprive: 1, $sourceMatched, citazione esatta trovata nell\'informativa; 2, $deviceObserved, permessi del telefono su questo dispositivo; 3, $interpretation, spiegazione in parole semplici di Deni; e 4, separato da una linea tratteggiata, $unverified, perché il silenzio in un\'informativa non è una promessa.';
  }

  @override
  String get learnDiagramCategoriesTitle =>
      'Cinque categorie tematiche nella schermata di Verifica';

  @override
  String get learnDiagramCategoriesNote =>
      'Colore e icona indicano il tema, mai un punteggio di sicurezza.';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Cinque categorie di prove mostrate nella schermata di Verifica di Enprive, ciascuna con la propria icona e il proprio colore: $dataCollection, $sharing, $tracking, $retention e $parentalControls. Colore e icona indicano il tema, mai un punteggio di sicurezza.';
  }

  @override
  String get learnDataCollectionFolderTitle => 'Dati raccolti dalle app';

  @override
  String get learnDataCollectionTitle => 'Quali dati raccolgono le app';

  @override
  String get learnDataCollectionSubtitle =>
      'La differenza tra ciò che scrivi e ciò che scorre in silenzio';

  @override
  String get learnDataCollectionIntro1 =>
      'Le app raccolgono informazioni in due modi. Alcuni dati arrivano da ciò che inserisci attivamente: nome, email, foto, registrazioni vocali o compiti. Altri dati vengono raccolti automaticamente in background, come l\'indirizzo IP (l\'indirizzo del telefono su Internet), identificatori del dispositivo, ID pubblicità (un codice usato dagli annunci per riconoscere il telefono), log di errore e orari di apertura dell\'app.';

  @override
  String get learnDataCollectionStep1 =>
      'Ciò che scrivi: nome, scuola, email, foto, clip vocali e risposte ai compiti sono dati che scegli di fornire.';

  @override
  String get learnDataCollectionStep2 =>
      'Ciò che scorre in silenzio: l\'app può raccogliere ID pubblicità, identificatori del dispositivo, indirizzo IP, report sugli errori e tempi di utilizzo senza che tu prema nulla. La raccolta silenziosa non è per forza negativa: questi segnali aiutano le app a funzionare bene.';

  @override
  String get learnDataCollectionStep3 =>
      'Dati sensibili dei bambini: posizione, registrazioni del microfono, foto dalla fotocamera e dati biometrici come le impronte vocali (dati sul corpo o sulla voce) comportano un rischio maggiore per la privacy dei bambini.';

  @override
  String get learnDataCollectionStep4 =>
      'Nota su Play Store: la sezione Sicurezza dei dati di Google Play è la descrizione fornita dallo sviluppatore stesso. È un indizio, non una prova, e non include dati elaborati solo sul dispositivo o tenuti brevemente in memoria.';

  @override
  String get learnDataCollectionQuizQuestion =>
      'Quale di questi è un esempio di dati raccolti in silenzio in background?';

  @override
  String get learnDataCollectionQuizChoiceA =>
      'Una foto che carichi per il tuo profilo';

  @override
  String get learnDataCollectionQuizChoiceB =>
      'Il tuo ID pubblicità e gli identificatori del dispositivo';

  @override
  String get learnDataCollectionQuizChoiceC =>
      'Una risposta a un compito che scrivi nell\'app';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      'Corretto: gli ID pubblicità e gli identificatori del dispositivo vengono raccolti automaticamente senza che tu li scriva.';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      'Non proprio: quelli sono dati che inserisci attivamente. I dati raccolti in silenzio includono ID pubblicità, identificatori del dispositivo, indirizzo IP e tempi di utilizzo.';

  @override
  String get learnDataCollectionDiagramYouTypeTitle =>
      'Ciò che scrivi o fornisci';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => 'Nome, email, scuola';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => 'Foto e video';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => 'Registrazioni vocali';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => 'Risposte ai compiti';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle =>
      'Ciò che scorre in silenzio';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => 'ID pubblicità';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 =>
      'Identificatori dispositivo';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'Indirizzo IP';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 =>
      'Log di errore e tempi d\'uso';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      'Silenzioso non significa cattivo: questi segnali aiutano le app a funzionare bene.';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      'Schema diviso in due categorie di raccolta dati. La scheda in alto \"Ciò che scrivi o fornisci\" elenca quattro elementi: Nome, email, scuola; Foto e video; Registrazioni vocali; Risposte ai compiti. La scheda in basso \"Ciò che scorre in silenzio\" elenca quattro elementi: ID pubblicità; Identificatori dispositivo; Indirizzo IP; Log di errore e tempi d\'uso. Una piccola nota dice \"Silenzioso non significa cattivo: questi segnali aiutano le app a funzionare bene.\" Deni siede sotto in posa riflessiva.';

  @override
  String get learnDataCollectionCheckBridge =>
      'Verifica un\'app su questo telefono per vedere quali dati raccoglie.';

  @override
  String get learnDataCollectionHonestyNote =>
      'Questa lezione spiega tipi comuni di dati. Non dimostra cosa raccoglie o invia un\'app specifica. Solo il testo esatto dell\'informativa e i permessi del telefono possono mostrarlo.';

  @override
  String get learnRetentionFolderTitle => 'Conservazione e cancellazione';

  @override
  String get learnRetentionTitle => 'Conservazione e cancellazione dei dati';

  @override
  String get learnRetentionSubtitle =>
      'Disinstallare un\'app non cancella i dati già presenti sui server aziendali';

  @override
  String get learnRetentionIntro1 =>
      'Quando elimini un\'app dal telefono, vengono rimossi i file locali sul dispositivo, ma i dati già caricati sui server dell\'azienda restano lì. Le informative sulla privacy dovrebbero spiegare per quanto tempo conservano i dati, come chiederne la cancellazione e cosa succede ai backup, ma molte usano frasi vaghe come \"per il tempo ragionevolmente necessario\".';

  @override
  String get learnRetentionStep1 =>
      'Dati raccolti: mentre usi l\'app, le tue informazioni vengono inviate e salvate sui server dell\'azienda.';

  @override
  String get learnRetentionStep2 =>
      'Salvati sui server: i tuoi dati possono restare nei sistemi aziendali anche dopo che smetti di usare l\'app.';

  @override
  String get learnRetentionStep3 =>
      'Disinstallare non elimina i dati sul server: rimuovere l\'app dal telefono elimina solo i file locali, non le copie sui server aziendali.';

  @override
  String get learnRetentionStep4 =>
      'Richiesta di cancellazione: puoi chiedere all\'azienda di eliminare il tuo account e i tuoi dati; le informative dovrebbero dire quanto tempo richiede.';

  @override
  String get learnRetentionStep5 =>
      'Conservazione sconosciuta: le informative che dicono \"finché necessario\" o \"per scopi aziendali\" lasciano poco chiaro quando i dati vengono davvero cancellati.';

  @override
  String get learnRetentionQuizQuestion =>
      'Cosa succede ai tuoi dati sui server aziendali quando disinstalli un\'app dal telefono?';

  @override
  String get learnRetentionQuizChoiceA => 'Vengono eliminati automaticamente';

  @override
  String get learnRetentionQuizChoiceB =>
      'Possono restare sui server: disinstallare l\'app non li cancella';

  @override
  String get learnRetentionQuizChoiceC => 'Vengono anonimizzati subito';

  @override
  String get learnRetentionQuizFeedbackRight =>
      'Corretto: disinstallare rimuove solo l\'app dal telefono. I dati sui server aziendali possono restare finché non richiedi la cancellazione.';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      'Non proprio: disinstallare un\'app non cancella i dati già caricati sui server aziendali. Devi richiedere la cancellazione dell\'account.';

  @override
  String get learnRetentionDiagramCollected => 'Dati raccolti durante l\'uso';

  @override
  String get learnRetentionDiagramStored => 'Salvati sui server aziendali';

  @override
  String get learnRetentionDiagramUninstall =>
      'Disinstalli l\'app: i file locali spariscono, i dati sul server restano';

  @override
  String get learnRetentionDiagramDeleteRequest =>
      'Richiedi la cancellazione dell\'account';

  @override
  String get learnRetentionDiagramUnknownTail =>
      'Conservazione ignota: l\'informativa dice \"finché necessario\"';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      'Una linea temporale in cinque passaggi che mostra il ciclo di vita dei dati. Passo 1: Dati raccolti durante l\'uso, con icona database. Passo 2: Salvati sui server aziendali, con icona server. Passo 3: Disinstalli l\'app: i file locali spariscono, i dati sul server restano, con icona smartphone. Passo 4: Richiedi la cancellazione dell\'account, con icona cestino. Passo 5: Conservazione ignota: l\'informativa dice \"finché necessario\", con freccia tratteggiata e icona aiuto. Deni è sotto con in mano una ricevuta.';

  @override
  String get learnRetentionCheckBridge =>
      'Verifica un\'app su questo telefono per vedere cosa dice la sua informativa sulla conservazione.';

  @override
  String get learnRetentionHonestyNote =>
      'Questa lezione descrive pratiche comuni di conservazione. Non dimostra cosa fa davvero una specifica azienda con i tuoi dati. Solo il testo esatto dell\'informativa e una richiesta di cancellazione possono mostrarlo.';

  @override
  String get learnUnclearPoliciesFolderTitle => 'Informative poco chiare';

  @override
  String get learnUnclearPoliciesTitle =>
      'Riconoscere informative poco chiare e pulsanti ingannevoli';

  @override
  String get learnUnclearPoliciesSubtitle =>
      'Come riconoscere parole vaghe e schermate di consenso pressanti';

  @override
  String get learnUnclearPoliciesIntro1 =>
      'Alcune informative usano parole sfocate che rendono difficile capire cosa accade davvero ai tuoi dati. Anche le schermate di consenso possono usare trucchi grafici, come un grande pulsante luminoso \"Accetta tutto\" vicino a un minuscolo link \"Gestisci impostazioni\", per spingerti ad accettare senza leggere.';

  @override
  String get learnUnclearPoliciesStep1 =>
      'Segnali di nebbia: fai attenzione a frasi generiche come \"possiamo condividere con partner affidabili\", \"per scopi commerciali\" o \"conservare se necessario\": lasciano i dettagli reali senza risposta.';

  @override
  String get learnUnclearPoliciesStep2 =>
      'Il silenzio non è una promessa: se un\'informativa non cita mai microfono, annunci o posizione, non garantisce che l\'app li eviti.';

  @override
  String get learnUnclearPoliciesStep3 =>
      'Basi mancanti: un\'informativa chiara ha una data di validità visibile, un\'email di contatto e un documento unico, non un allegato nascosto per i bambini.';

  @override
  String get learnUnclearPoliciesStep4 =>
      'Consenso forzato (dark pattern): pulsanti giganti \"Accetta tutto\", caselle marketing già spuntate, richieste insistenti e percorsi di disdetta nascosti servono a guidare la tua scelta.';

  @override
  String get learnUnclearPoliciesStep5 =>
      'Scelta equilibrata: una schermata corretta mostra pulsanti \"Consenti\" e \"Non consentire\" alla pari, con le opzioni facoltative disattive per impostazione predefinita.';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      'Quale frase in un\'informativa sulla privacy è un segnale \"nebbioso\" che mancano dettagli?';

  @override
  String get learnUnclearPoliciesQuizChoiceA =>
      'Non vendiamo le tue informazioni personali a terze parti';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      'Possiamo condividere dati con partner affidabili per scopi commerciali';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'Puoi richiedere la cancellazione scrivendo a privacy@example.com';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      'Corretto: \"possiamo condividere con partner affidabili per scopi commerciali\" è vago e non dice chi siano i partner né quali dati vengano condivisi.';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      'Non proprio: quella frase è precisa e concreta. Le frasi nebbiose usano espressioni aperte come \"possiamo condividere\" o \"se necessario\" senza dettagli.';

  @override
  String get learnUnclearPoliciesDiagramClearTitle =>
      'Frase chiara dell\'informativa';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      'Raccogliamo nome ed email per creare il tuo account. Non li condividiamo con inserzionisti.';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle =>
      'Frase nebbiosa dell\'informativa';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      'Possiamo condividere le tue informazioni con partner affidabili per scopi commerciali secondo necessità.';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle =>
      'Come riconoscere la nebbia';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      'Cerca \"può\", \"potrebbe\" o \"secondo necessità\": lasciano la porta aperta.';

  @override
  String get learnUnclearPoliciesDiagramTip2 =>
      'Controlla se l\'informativa indica i nomi precisi delle aziende che ricevono i dati.';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      'Il silenzio su pubblicità o microfono non promette che l\'app li eviti.';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote =>
      'Il silenzio in un\'informativa non è una promessa.';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      'Confronto affiancato tra una frase chiara e una frase nebbiosa. La scheda sinistra \"Chiara\" mostra: \"Raccogliamo nome ed email per creare il tuo account. Non li condividiamo con inserzionisti.\" La scheda destra \"Nebbiosa\" mostra: \"Possiamo condividere le tue informazioni con partner affidabili per scopi commerciali secondo necessità.\" Sotto, la scheda \"Come riconoscere la nebbia\" elenca tre consigli: cerca \"può\", \"potrebbe\" o \"secondo necessità\"; controlla se l\'informativa indica le aziende precise; il silenzio su pubblicità o microfono non è una promessa. Una nota dice \"Il silenzio in un\'informativa non è una promessa.\" Deni fa capolino sopra le schede.';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      'Verifica un\'app su questo telefono per controllare la sua schermata di consenso e la chiarezza.';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      'Questa lezione descrive schemi poco chiari frequenti. Non dimostra che una specifica app usi dark pattern o nasconda pratiche sui dati. Solo leggere l\'informativa esatta e vedere la vera schermata di consenso può mostrarlo.';

  @override
  String get learnSafeSharingFolderTitle => 'Condivisione consapevole';

  @override
  String get learnSafeSharingTitle =>
      'Abitudini di condivisione sicura per bambini';

  @override
  String get learnSafeSharingSubtitle =>
      'Fermati, Pensa, Condividi: passi adatti all\'età per condividere online';

  @override
  String get learnSafeSharingIntro1 =>
      'Prima di pubblicare una foto, un video, il tuo nome o la tua posizione, fermati e segui tre passi: Fermati, Pensa, Condividi. Questa lezione è pensata per essere letta con un adulto fidato. I più piccoli (5-7 anni) chiedono prima di toccare. I bambini di 8-11 anni usano soprannomi e password robuste. I ragazzi (12-17 anni) gestiscono la propria impronta digitale (la traccia di ciò che si pubblica) e l\'autenticazione a due fattori (un secondo controllo, come un codice, quando accedi).';

  @override
  String get learnSafeSharingStep1 =>
      'Fermati: fai una pausa prima di pubblicare una foto, un video, un nome, la scuola o la posizione. Chiedi a un adulto fidato se hai dubbi.';

  @override
  String get learnSafeSharingStep2 =>
      'Pensa: questo rivela la mia scuola, casa mia o dove sono adesso? Ho chiesto ai miei amici prima di condividere le loro foto o taggarli?';

  @override
  String get learnSafeSharingStep3 =>
      'Condividi: condividi solo con persone di cui ti fidi. Tieni privati i dati personali come nome completo, compleanno, indirizzo e numero di telefono.';

  @override
  String get learnSafeSharingStep4 =>
      'Il test della mensa: sarei a mio agio se tutta la scuola (o tutta la mia classe) vedesse questa foto o messaggio? Anche i post che scompaiono possono essere salvati con uno screenshot e restare online per sempre.';

  @override
  String get learnSafeSharingStep5 =>
      '5-7 anni: chiedi a un adulto fidato prima di scrivere il tuo nome o toccare un avviso. 8-11 anni: usa un soprannome (non nome vero, compleanno e scuola), password robuste e non condividere mai codici SMS o OTP (codici monouso via messaggio: mai condividerli). 12-17 anni: controlla le impostazioni sulla privacy, attiva la verifica in due passaggi e sappi come segnalare problemi.';

  @override
  String get learnSafeSharingQuizQuestion =>
      'Cos\'è il \"test della mensa\" per condividere online?';

  @override
  String get learnSafeSharingQuizChoiceA =>
      'Condividere solo ciò che mangeresti in mensa';

  @override
  String get learnSafeSharingQuizChoiceB =>
      'Chiedersi: sarei a mio agio se tutta la scuola vedesse questa foto o messaggio?';

  @override
  String get learnSafeSharingQuizChoiceC =>
      'Condividere solo durante la pausa pranzo';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      'Corretto: il test della mensa significa chiederti se ti sentiresti a tuo agio sapendo che tutti vedono ciò che pubblichi.';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      'Non proprio: il test della mensa è un controllo mentale: ti andrebbe bene se qualcuno mostrasse il tuo post a tutta la mensa?';

  @override
  String get learnSafeSharingDiagramStop =>
      'Fermati: fai una pausa prima di pubblicare';

  @override
  String get learnSafeSharingDiagramThink =>
      'Pensa: rivela dove sono o con chi sono?';

  @override
  String get learnSafeSharingDiagramConnect =>
      'Condividi: solo con persone fidate, chiedi a un adulto se hai dubbi';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      'Il test della mensa: sarei a mio agio se tutta la scuola lo vedesse? Anche i post che scompaiono possono essere salvati con uno screenshot e restare online per sempre.';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      'Schema in quattro parti sulle abitudini di condivisione attenta. Passo 1: Fermati: fai una pausa prima di pubblicare, con icona mano. Passo 2: Pensa: rivela dove sono o con chi sono?, con icona cervello. Passo 3: Condividi: solo con persone fidate, chiedi a un adulto se hai dubbi, con icona persone. Passo 4: il riquadro del test della mensa chiede \"Sarei a mio agio se tutta la scuola lo vedesse? Anche i post che scompaiono possono essere salvati con uno screenshot e restare online per sempre.\" Deni sta accanto al riquadro con la mano alzata.';

  @override
  String get learnSafeSharingCheckBridge =>
      'Verifica un\'app insieme a un genitore per vedere come gestisce la condivisione.';

  @override
  String get learnSafeSharingHonestyNote =>
      'Questa lezione condivide abitudini generali per condividere con cura. Non garantisce che un\'app protegga ciò che condividi. Leggi sempre l\'informativa dell\'app e usa le impostazioni sulla privacy del tuo telefono.';

  @override
  String get translationDraftNotice =>
      'Alcune traduzioni sono bozze generate dall\'IA e potrebbero contenere errori. Madrelingua le stanno revisionando.';

  @override
  String get homeQuickSettingsTitle => 'Assistente Impostazioni rapide';

  @override
  String get homeQuickSettingsSubtitle =>
      'Chiedi a Deni dell\'app che stai usando, quando vuoi';

  @override
  String get appearanceSectionTitle => 'Aspetto';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Chiaro';

  @override
  String get themeModeDark => 'Scuro';

  @override
  String get quickSettingsSectionTitle =>
      'Collega Enprive alle Impostazioni rapide';

  @override
  String get quickSettingsSectionSubtitle =>
      'Aggiungi Enprive Check al pannello Impostazioni rapide di Android, così puoi chiedere a Deni delle app senza interrompere ciò che stai facendo.';

  @override
  String get quickSettingsTileTitle => 'Riquadro Enprive Check';

  @override
  String get quickSettingsTileSubtitle =>
      'Aggiungi Enprive Check alle Impostazioni rapide per chiedere a Deni dell\'app che stai usando, senza dover cercare prima Enprive.';

  @override
  String get quickSettingsStatusAdded => 'Aggiunto';

  @override
  String get quickSettingsStatusManual => 'Manuale';

  @override
  String get quickSettingsStatusNotAdded => 'Non aggiunto';

  @override
  String get usageAccessStatusGranted => 'Concesso';

  @override
  String get usageAccessStatusNotGranted => 'Non concesso';

  @override
  String get usageAccessTitle =>
      'Consenti l\'accesso ai dati di utilizzo (facoltativo)';

  @override
  String get usageAccessExplanation =>
      'Enprive usa l\'accesso ai dati di utilizzo solo quando tocchi Enprive Check, per riconoscere l\'app che stavi usando. Così Deni trova l\'app giusta e le sue informazioni sulla privacy. Enprive non controlla il tuo schermo in continuazione.';

  @override
  String get usageAccessManageLink => 'Come gestirlo o revocarlo';

  @override
  String get usageAccessManageTitle =>
      'Gestisci o revoca l\'accesso ai dati di utilizzo';

  @override
  String get usageAccessManageBody =>
      'L\'accesso ai dati di utilizzo è un interruttore speciale nelle Impostazioni di Android (non un popup automatico). Puoi disattivarlo in qualsiasi momento da Impostazioni di Android → App → Accesso speciale per le app → Accesso ai dati di utilizzo → enprive. Deni resta utilizzabile anche senza, scegliendo l\'app a mano.';

  @override
  String get openDeniCompanionTitle => 'Apri l\'assistente Deni';

  @override
  String get openDeniCompanionSubtitle =>
      'Controlla i permessi di un\'app recente o scelta da te, senza usare le Impostazioni rapide.';

  @override
  String get btnGotIt => 'Ho capito';

  @override
  String get quickSettingsReadyDialogTitle =>
      'Enprive Check è pronto nelle Impostazioni rapide';

  @override
  String get quickSettingsReadyDialogBody =>
      'Scorri verso il basso due volte dalla parte alta dello schermo e tocca \"Enprive Check\" quando vuoi che Deni spieghi i permessi di un\'app.';

  @override
  String get quickSettingsManualDialogTitle => 'Aggiungi Enprive Check a mano';

  @override
  String get quickSettingsManualDialogBody =>
      '1. Scorri verso il basso due volte dalla parte alta dello schermo Android per aprire le Impostazioni rapide.\n2. Tocca il pulsante Modifica (matita).\n3. Trova \"Enprive Check\" e trascinalo tra i riquadri attivi delle Impostazioni rapide.';

  @override
  String get quickSettingsSnackAdded =>
      'Enprive Check è stato aggiunto alle tue Impostazioni rapide.';

  @override
  String get quickSettingsSnackAlreadyAdded =>
      'Enprive Check è già nelle tue Impostazioni rapide.';

  @override
  String get quickSettingsSnackDeclined =>
      'Richiesta chiusa. Enprive non lo chiederà di nuovo, a meno che tu non scelga Modifica nelle Impostazioni rapide.';

  @override
  String get quickSettingsSnackManual =>
      'Scorri verso il basso le Impostazioni rapide, tocca Modifica e trascina Enprive Check tra i tuoi riquadri.';

  @override
  String get quickSettingsSnackUnavailable =>
      'Qui la richiesta di sistema non è disponibile: puoi trascinare Enprive Check a mano da Modifica nelle Impostazioni rapide.';

  @override
  String get usageAccessOpenFailedSnack =>
      'Non è stato possibile aprire le impostazioni di accesso ai dati di utilizzo su questo dispositivo.';

  @override
  String get companionTitle => 'Deni: assistente di Enprive';

  @override
  String get companionSubtitle =>
      'Chiedi a Deni dei permessi di un\'app e di cosa dice la sua informativa sulla privacy.';

  @override
  String get companionTooltipReturnToPrev => 'Torna all\'app precedente';

  @override
  String get companionTooltipBack => 'Indietro';

  @override
  String get companionLockedBadge => 'SCHERMO BLOCCATO PROTETTO';

  @override
  String get companionLockedTitle => 'Sblocca il telefono per continuare';

  @override
  String get companionLockedBody =>
      'Finché il dispositivo è bloccato, Enprive nasconde i nomi delle app, i permessi dichiarati e le prove della verifica.';

  @override
  String get companionCheckUnlockBtn => 'Controlla lo stato di sblocco';

  @override
  String get companionCheckingAppHeadline =>
      'Sto controllando quale app stavi usando…';

  @override
  String get companionCheckingAppSubtitle =>
      'Il controllo avviene una sola volta su questo telefono, senza guardare il tuo schermo.';

  @override
  String get companionGeneralGuideHeadline =>
      'Guida generale ai permessi di Android';

  @override
  String get companionGeneralGuideSubtitle =>
      'Nessuna app selezionata. Enprive spiega i permessi di Android usando solo indicazioni locali.';

  @override
  String companionLookingAtHeadline(String appName) {
    return 'Stai guardando $appName.';
  }

  @override
  String get companionLookingAtSubtitle =>
      'I permessi elencati qui sotto vengono dall\'app sul tuo telefono. Android continua a controllare il popup che compare sullo schermo.';

  @override
  String get companionThisAppFallback => 'questa app';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return 'Abbiamo visto $appName $seconds s fa. È corretto?';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return 'Pensiamo che tu stia usando $appName. È corretto?';
  }

  @override
  String companionAppIdLine(String packageName) {
    return 'App ID: $packageName';
  }

  @override
  String companionConfirmAppBtn(String appName) {
    return 'Conferma · $appName';
  }

  @override
  String get companionChooseAnotherAppBtn => 'Scegli un\'altra app';

  @override
  String get companionWithoutAppContextBtn => 'Senza contesto dell\'app';

  @override
  String get companionMultipleAppsTitle => 'Poco fa erano attive più app';

  @override
  String get companionMultipleAppsPrompt =>
      'Conferma quale app vuoi controllare:';

  @override
  String companionSecondsAgo(int seconds) {
    return '$seconds s fa';
  }

  @override
  String get companionSelectAppTitle => 'Scegli l\'app da controllare';

  @override
  String get companionSelectAppBody =>
      'Scegli l\'app a mano tra quelle installate oppure continua senza contesto dell\'app.';

  @override
  String get companionChooseAppManuallyBtn => 'Scegli l\'app a mano';

  @override
  String get companionOpenUsageAccessBtn =>
      'Apri le impostazioni di accesso ai dati di utilizzo';

  @override
  String get companionContinueWithoutAppBtn =>
      'Continua senza contesto dell\'app';

  @override
  String get companionAddTileBtn => 'Aggiungi il riquadro Enprive Check';

  @override
  String get companionContinuingWithoutApp =>
      'Continuo senza contesto dell\'app';

  @override
  String get companionSwitchAppBtn => 'Cambia app';

  @override
  String get companionPermissionsReadLocally =>
      'I permessi mostrati qui sotto vengono letti direttamente dal tuo telefono.';

  @override
  String get companionPickPermissionType =>
      'Scegli un tipo di permesso da esplorare';

  @override
  String get companionPickAppBtn => 'Scegli un\'app';

  @override
  String get companionCouldNotReadPermsTitle =>
      'Non è stato possibile leggere i permessi dell\'app';

  @override
  String get companionCouldNotReadPermsBody =>
      'Android ha impedito di controllare i permessi di questa app.';

  @override
  String get companionUnsurePermBtn => 'Non so quale permesso';

  @override
  String get companionWhichPermissionPrompt => 'Quale permesso vuoi capire?';

  @override
  String get companionPermissionsListDisclaimer =>
      'Questi sono i permessi che l\'app elenca sul tuo telefono, non per forza il popup che vedi ora sullo schermo.';

  @override
  String get companionNoSensitivePermsMsg =>
      'Questa app non chiede permessi sensibili sul tuo telefono.';

  @override
  String get companionGuidedMatchTitle =>
      'Scegli cosa chiedeva il popup sul tuo schermo';

  @override
  String get companionGuidedMatchSubtitle =>
      'Enprive non può leggere direttamente la richiesta di Android che vedi ora. Scegli la frase più vicina a quella comparsa sullo schermo:';

  @override
  String get companionSection1Title => '1. Cosa significa questo permesso';

  @override
  String get companionSection2Title => '2. Cosa chiede l\'app sul tuo telefono';

  @override
  String get companionSection3Title =>
      '3. Cosa dice la sua informativa sulla privacy';

  @override
  String get companionSection4Title =>
      '4. Perché potrebbe riguardare una funzione';

  @override
  String get companionSection4Fallback =>
      'Non è stata trovata una spiegazione verificata dello sviluppatore su una funzione. Descrivi qui sotto quale funzione volevi usare, se vuoi che Deni controlli se è pertinente.';

  @override
  String get companionSection5Title => '5. Cosa resta sconosciuto';

  @override
  String get companionSection6Title => '6. Domande che puoi fare a Deni';

  @override
  String get companionAddPolicyBtn => 'Aggiungi l\'informativa sulla privacy';

  @override
  String get companionCheckUpdatedPolicyBtn =>
      'Controlla l\'informativa sulla privacy aggiornata';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return 'Verifica l\'informativa di $appName';
  }

  @override
  String get companionFeatureFieldLabel =>
      'Funzione che stavi usando (facoltativo)';

  @override
  String get companionFeatureFieldHint =>
      'ad es. scansionare un codice QR, registrare un esercizio vocale';

  @override
  String get companionQuestionFieldLabel => 'Fai una domanda a Deni';

  @override
  String get companionQuestionFieldHint =>
      'Cosa succede se nego questo permesso?';

  @override
  String get companionReceiptSavedTitle => 'Salvato nelle Ricevute di Enprive';

  @override
  String get companionReceiptUnsavedTitle =>
      'Verifica non ancora salvata in Enprive';

  @override
  String get companionReceiptSavedBody =>
      'Salvato in locale nel tuo archivio delle Ricevute di Enprive.';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      'La verifica dell\'informativa aggiornata resta solo in questa sessione. Uscendo dall\'assistente, questa bozza viene eliminata e la ricevuta salvata resta invariata.';

  @override
  String get companionReceiptUnsavedBody =>
      'Resta solo in questa sessione. Uscendo dall\'assistente verrà eliminata, a meno che tu non la salvi.';

  @override
  String get companionSaveReceiptBtn => 'Salva la ricevuta in Enprive';

  @override
  String get companionSaveReceiptFailed =>
      'Non è stato possibile salvare la ricevuta. Resta in questa sessione: riprova.';

  @override
  String get companionSavedLocalReceiptsSnack =>
      'Salvato nelle Ricevute locali.';

  @override
  String companionDoneReturnToApp(String appName) {
    return 'Fatto · Torna a $appName';
  }

  @override
  String get companionDoneReturnToPrev => 'Fatto · Torna all\'app precedente';

  @override
  String get companionOpenFullAppBtn => 'Apri l\'app Enprive completa';

  @override
  String get companionCloudTimeoutSnack =>
      'L\'analisi cloud ha richiesto troppo tempo ed è stata interrotta prima di finire.';

  @override
  String get companionAnalysisCancelledSnack => 'Analisi annullata.';

  @override
  String get companionCloudAnswerTimeoutSnack =>
      'La risposta cloud è scaduta senza problemi.';

  @override
  String get companionQuestionCancelledSnack => 'Domanda annullata.';

  @override
  String get companionTileAddedSnack =>
      'Enprive Check è stato aggiunto alle Impostazioni rapide di Android.';

  @override
  String get companionTileAlreadyAddedSnack =>
      'Enprive Check è già nelle tue Impostazioni rapide.';

  @override
  String get companionTileDeclinedSnack =>
      'Richiesta del riquadro chiusa. Puoi aggiungerlo in qualsiasi momento da Impostazioni o da Modifica nelle Impostazioni rapide.';

  @override
  String get companionTileManualSnack =>
      'Scorri verso il basso due volte le Impostazioni rapide, tocca Modifica e trascina Enprive Check tra i tuoi riquadri.';

  @override
  String get companionTileUnavailableSnack =>
      'Android non è riuscito a mostrare la richiesta delle Impostazioni rapide su questo dispositivo. Puoi trascinare Enprive Check a mano da Modifica nelle Impostazioni rapide.';

  @override
  String get companionUsageOptionalReason =>
      'L\'accesso ai dati di utilizzo è facoltativo. Puoi scegliere un\'app a mano oppure consentire l\'accesso per riconoscerla con un solo tocco.';

  @override
  String get companionPermPreciseLocation => 'Posizione precisa';

  @override
  String get companionPermBackgroundLocation => 'Posizione in background';

  @override
  String get companionPermCamera => 'Fotocamera';

  @override
  String get companionPermMicrophone => 'Microfono';

  @override
  String get companionPermAdId => 'ID pubblicitario di Google';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return 'Permesso di Android ($permission) dichiarato da $appName.';
  }

  @override
  String get companionPermStatusAdId => 'Elencato dall\'app · ID pubblicitario';

  @override
  String get companionPermStatusAllowed => 'Elencato dall\'app · Consentito';

  @override
  String get companionPermStatusNotAllowed =>
      'Elencato dall\'app · Non consentito';

  @override
  String get guidedCatLocation => 'Posizione';

  @override
  String get guidedCatContacts => 'Contatti';

  @override
  String get guidedCatPhotosMedia => 'Foto e contenuti multimediali';

  @override
  String get guidedCatNotifications => 'Notifiche';

  @override
  String get guidedCatNearbyDevices => 'Dispositivi nelle vicinanze';

  @override
  String get guidedCatCalendar => 'Calendario';

  @override
  String get guidedCatPhone => 'Telefono';

  @override
  String get guidedCatSms => 'SMS';

  @override
  String get companionFallbackUsageNotEnabled =>
      'L\'accesso ai dati di utilizzo non è stato attivato nelle Impostazioni di Android.';

  @override
  String get companionFallbackUsageUnavailable =>
      'Android UsageStatsManager non è disponibile.';

  @override
  String get companionFallbackTransientUi =>
      'Negli eventi di utilizzo recenti sono comparse solo schermate di sistema o richieste di permessi di Android: scegli l\'app a mano.';

  @override
  String get companionFallbackVisibilityRestricted =>
      'L\'app attiva più di recente non può essere controllata a causa delle restrizioni di Android sulla visibilità dei pacchetti. Scegli un\'app dall\'elenco o incolla la sua informativa.';

  @override
  String get companionFallbackUnlockRequired =>
      'Sblocca il dispositivo prima di vedere il contesto dell\'app.';

  @override
  String get consentReasonPolicyTooDetailed =>
      'Questa informativa è troppo dettagliata per essere elaborata dall\'IA sul dispositivo.';

  @override
  String get consentReasonExcerptTooDetailed =>
      'Questo estratto è troppo dettagliato per essere elaborato dall\'IA sul dispositivo.';

  @override
  String get consentReasonOnDeviceUnavailable =>
      'L\'IA sul dispositivo non è disponibile su questo telefono in questo momento.';

  @override
  String get consentReasonOnDeviceCannotAnswer =>
      'In questo momento l\'IA sul dispositivo non ha potuto rispondere da questo dispositivo.';

  @override
  String get consentReasonVoiceTooLong =>
      'Questi risultati verificati superano i limiti del riassunto sul dispositivo. Puoi usare subito il riassunto offline oppure inviare i risultati oscurati all\'IA cloud una sola volta.';

  @override
  String get consentReasonVoiceUnavailable =>
      'L\'IA sul dispositivo non è disponibile su questo telefono in questo momento. Mostro il riassunto offline in parole semplici di Enprive.';

  @override
  String get consentReasonVoiceTimedOut =>
      'Il riassunto sul dispositivo ha superato il tempo limite. Mostro il riassunto offline in parole semplici di Enprive.';

  @override
  String get unsavedExitTitle => 'Salvare questa verifica della privacy?';

  @override
  String get unsavedExitModifiedBody =>
      'Le verifiche non salvate vengono eliminate quando chiudi questa schermata, così nulla viene salvato sul telefono senza una tua scelta. La ricevuta salvata in origine resta invariata.';

  @override
  String get unsavedExitDraftBody =>
      'Le verifiche non salvate vengono eliminate quando chiudi questa schermata, così nulla viene salvato sul telefono senza una tua scelta.';

  @override
  String get unsavedExitDiscardBtn => 'Elimina senza salvare';

  @override
  String get unsavedExitContinueBtn => 'Continua a verificare';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return 'Aggiorna l\'informativa sulla privacy per $title';
  }

  @override
  String get reviewSaveFailedError =>
      'Non è stato possibile salvare la ricevuta. La bozza della verifica è ancora aperta.';

  @override
  String get reviewRemovedFromReceiptsSnack =>
      'Rimossa dalle ricevute salvate.';

  @override
  String get reviewRemoveFailedSnack =>
      'Non è stato possibile rimuovere la ricevuta salvata.';

  @override
  String get reviewModifiedDraftTitle => 'Nuova bozza dalla ricevuta salvata';

  @override
  String get reviewModifiedDraftBody =>
      'Salva nelle Ricevute per conservare questa verifica aggiornata: la ricevuta salvata in origine resta invariata.';

  @override
  String get btnRetrySave => 'Riprova a salvare';

  @override
  String samplePermissionsHeader(String badge) {
    return 'Permessi di esempio ($badge)';
  }

  @override
  String get sourceKindUrl => 'Link web pubblico';

  @override
  String get sourceKindPdf => 'File PDF locale';

  @override
  String get sourceKindDocx => 'File Word (DOCX) locale';

  @override
  String get sourceKindTextFile => 'File di testo locale';

  @override
  String get sourceKindSharedText => 'Testo condiviso';

  @override
  String get sourceKindSelectedText => 'Testo selezionato';

  @override
  String get sourceKindSampleApp => 'App di esempio';

  @override
  String get sourceKindPhonePermissions => 'Permessi del telefono';

  @override
  String get sourceKindPastedText => 'Testo incollato';

  @override
  String get extractionStatusExtracted => 'Letto su questo telefono';

  @override
  String get extractionStatusNone => 'Fornito su questo telefono';

  @override
  String get extractionStatusUnsupported => 'Tipo di file non supportato';

  @override
  String get extractionStatusTooLarge => 'File troppo grande';

  @override
  String get extractionStatusEmpty => 'Nessun testo leggibile';

  @override
  String get extractionStatusReadError => 'Impossibile leggere il file';

  @override
  String get extractionStatusPasswordProtected => 'Protetto da password';

  @override
  String get extractionStatusPermissionDenied => 'Permesso negato';

  @override
  String get extractionStatusCancelled => 'Annullato';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return 'Controllato il: $timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return 'URL canonico: $url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return 'Reindirizzato da: $url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return 'File: $filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return 'Stato: $status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return 'Hash SHA-256 della fonte: $hash';
  }

  @override
  String get semanticsPrimaryNavigation => 'Navigazione principale';

  @override
  String semanticsProcessingLocation(String label) {
    return 'Dove viene elaborato: $label';
  }

  @override
  String get semanticsDeniMascot => 'Deni, la tua guida alla privacy';

  @override
  String get quoteCollapsibleDefaultHeader =>
      'Estratto esatto dell\'informativa';
}
