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
      'Uno o più passaggi o discrepanze nei permessi meritano un controllo diretto.';

  @override
  String get stateInsufficientEvidence => 'Prove insufficienti';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Le prove mancano, non sono disponibili o non è stato possibile verificarle su questo dispositivo.';

  @override
  String get chipOnDevice => 'Su questo dispositivo';

  @override
  String get chipInCloud => 'Nel cloud';

  @override
  String get chipLocationUnavailable =>
      'Posizione di elaborazione non disponibile';

  @override
  String get statusSourceMatched => 'Testo confermato';

  @override
  String get statusDeviceObserved => 'Rilevato sul dispositivo';

  @override
  String get statusInterpretation => 'Interpretazione';

  @override
  String get statusUnverified => 'Non verificato';

  @override
  String get statusStale => 'Obsoleto';

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
      'Per analizzare questo testo nel cloud, Enprive invierà solo il testo mostrato qui sotto a Firebase AI Logic. L\'elenco delle tue app installate e i permessi Android non verranno mai inviati.';

  @override
  String get permissionLimitationNotice =>
      'Android segnala questo stato dei permessi su questo telefono. Non dimostra se l\'app abbia effettivamente avuto accesso ai dati o li abbia trasmessi.';

  @override
  String get navHome => 'Home';

  @override
  String get navReceipts => 'Ricevute';

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
      'Segnala condivisione, registrazione vocale e tempi di conservazione con citazioni letterali.';

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
      other: '$count clausole verificate',
      one: '1 clausola verificata',
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
  String get readinessRow3Title => 'Dati personali oscurati';

  @override
  String get readinessRow3Desc =>
      'Se l\'IA su dispositivo manca o il testo è lungo, nomi, email e numeri diventano segnaposto prima della verifica App Check.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get privateAnalysisTitle => 'Analisi privata su questo telefono';

  @override
  String get onDeviceReadyMsg => 'L\'IA sul dispositivo è attiva e pronta.';

  @override
  String get localScannerProtectedMsg =>
      'Protetto dallo scanner locale integrato.';

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
      'Gemini Nano è pronto su questo telefono. Le verifiche restano interamente sul dispositivo.';

  @override
  String get modelDownloadingMsg =>
      'Download del modello privato sul dispositivo in background.';

  @override
  String get modelDownloadableMsg =>
      'Il modello sul dispositivo può essere scaricato tramite Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'Questo telefono utilizza in modo predefinito lo scanner locale integrato di Enprive.';

  @override
  String get preparingPrivateAnalysis => 'Preparazione analisi privata…';

  @override
  String get onDeviceAiReadyTitle => 'IA locale pronta';

  @override
  String get localScannerActiveTitle => 'Scanner locale attivo';

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
      'Lettura delle clausole su questo telefono…';

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
  String get thoughtSignaturePrefix => 'Firma di ragionamento';

  @override
  String get viewStreamedThoughts => 'Mostra ragionamento';

  @override
  String get hideStreamedThoughts => 'Nascondi ragionamento';

  @override
  String get analysisTraceDefaultTitle =>
      'Come è stato verificato questo controllo';

  @override
  String get savedToLocalReceiptsSnack => 'Salvato nelle ricevute locali.';

  @override
  String get snapshotSheetTitle => 'Copia dell\'informativa esaminata';

  @override
  String get snapshotSourcePrefix => 'Fonte';

  @override
  String get snapshotReviewedPrefix => 'Esaminata';

  @override
  String get snapshotDigestPrefix => 'Digest';

  @override
  String get statFindings => 'Risultati';

  @override
  String get statVerified => 'Verificati';

  @override
  String get statOsGranted => 'Concessi OS';

  @override
  String get statUnverified => 'Non verificati';

  @override
  String get keyFindingsTitle => 'Risultati principali';

  @override
  String get reviewedExcerptTitle => 'Estratto esaminato';

  @override
  String get permissionsOnPhoneTitle => 'Permessi su questo telefono';

  @override
  String get viewReviewedSnapshot => 'Vedi copia completa esaminata';

  @override
  String get btnSavedToReceipts => 'Salvato nelle ricevute';

  @override
  String get observedOnPhoneLabel => 'Rilevato su questo telefono';

  @override
  String get quoteVerifiedLabel => 'Citazione verificata nell\'informativa';

  @override
  String get unverifiedClaimLabel => 'Affermazione non verificata';

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
  String get labelWhatRemainsUnknown => 'Cosa resta sconosciuto';

  @override
  String get presetQuestionMeaning => 'Cosa significa per mio figlio?';

  @override
  String get presetQuestionOptOut =>
      'Possiamo disattivarlo o negare il consenso?';

  @override
  String get presetQuestionUnknown => 'Cosa resta ancora poco chiaro qui?';

  @override
  String get readingCitedClause => 'Lettura della clausola citata…';

  @override
  String get deniAnswerTitle => 'Risposta di Deni';

  @override
  String get stepsAndReasoning => 'Passaggi e ragionamento del modello';

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
}
