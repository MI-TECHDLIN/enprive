// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline =>
      'Analyses de confidentialité fondées sur des preuves';

  @override
  String get homePrivacySubtitle => 'Vos analyses restent sur ce téléphone.';

  @override
  String get stateNoConcern => 'Aucun point préoccupant détecté';

  @override
  String get stateNoConcernSubtitle =>
      'Aucune préoccupation identifiée dans les preuves examinées. Ceci n\'est pas une certification de sécurité.';

  @override
  String get stateReviewRecommended => 'Vérification recommandée';

  @override
  String get stateReviewRecommendedSubtitle =>
      'Un ou plusieurs passages de la politique ou autorisations du téléphone méritent un examen plus attentif.';

  @override
  String get stateInsufficientEvidence => 'Preuves insuffisantes';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Nous avons besoin de plus de texte de la politique de confidentialité avant de pouvoir vérifier ce que fait cette app.';

  @override
  String get chipOnDevice => 'Sur cet appareil';

  @override
  String get chipInCloud => 'Dans le cloud';

  @override
  String get chipLocationUnavailable => 'Source indisponible';

  @override
  String get chipOfflineDeterministic => 'Vérifié hors ligne sur ce téléphone';

  @override
  String get chipUnknown => 'Source inconnue';

  @override
  String get statusSourceMatched => 'Trouvé dans la politique';

  @override
  String get statusDeviceObserved => 'Observé sur ce téléphone';

  @override
  String get statusInterpretation => 'Explication de Deni';

  @override
  String get statusUnverified => 'Introuvable dans la politique';

  @override
  String get statusStale => 'Analyse plus ancienne';

  @override
  String get btnCheckApp => 'Vérifier une app';

  @override
  String get btnPasteTerms => 'Coller un texte ou une URL';

  @override
  String get btnWhyThisFinding => 'Pourquoi ce résultat ?';

  @override
  String get btnSaveToReceipts => 'Enregistrer dans Reçus';

  @override
  String get btnDiscard => 'Ignorer';

  @override
  String get btnAskDeni => 'Demander à Deni';

  @override
  String get btnUseCloud => 'Utiliser le cloud pour ce contrôle';

  @override
  String get btnReviewManually => 'Examiner manuellement';

  @override
  String get btnGetStarted => 'Commencer';

  @override
  String get btnContinue => 'Continuer';

  @override
  String get deniIntro =>
      'Bonjour, je suis Deni. Je vous aide à comprendre ce que dit cette politique de confidentialité, à voir les preuves précises et à repérer ce qu\'Enprive n\'a pas pu vérifier.';

  @override
  String get cloudConsentDisclosure =>
      'Pour vérifier cela dans le cloud, Enprive n\'enverra que le texte affiché ci-dessus (avec les données personnelles masquées) pour cette seule demande. Vos applications et les autorisations de votre téléphone ne sont jamais envoyées.';

  @override
  String get permissionLimitationNotice =>
      'Votre téléphone indique si cette autorisation est accordée. Cela ne prouve pas si l\'application a réellement consulté ou envoyé des données.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navCheck => 'Vérifier';

  @override
  String get navReceipts => 'Reçus';

  @override
  String get navLearn => 'Apprendre';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get languageTitle => 'Langue';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get languageSubtitle =>
      'S\'applique à l\'interface, aux explications et à la lecture vocale';

  @override
  String get homeHeroHeadline =>
      'Un regard plus clair sur les\napps utilisées par les enfants';

  @override
  String get trySampleCheck => 'Essayer un exemple d\'analyse';

  @override
  String get eduTrackSubtitle => 'Devoirs et présence';

  @override
  String get eduTrackValue => '3 demandes';

  @override
  String get eduTrackTrend => 'À vérifier';

  @override
  String get calmMathSubtitle => 'Calcul mental hors ligne';

  @override
  String get calmMathValue => '0 sensible';

  @override
  String get calmMathTrend => 'Minimal';

  @override
  String get whatWeCheckTitle => 'Ce que nous vérifions';

  @override
  String get checkQuoteTitle => 'Citations exactes de la politique';

  @override
  String get checkQuoteDesc =>
      'Met en évidence le partage de données, l\'enregistrement vocal et la durée de conservation à l\'aide de citations exactes.';

  @override
  String get checkPermissionTitle => 'Écarts d\'autorisations téléphone';

  @override
  String get checkPermissionDesc =>
      'Compare l\'accès Caméra, Micro et Localisation avec les déclarations de la politique.';

  @override
  String get checkSelectTitle => 'Sélectionner du texte partout';

  @override
  String get checkSelectDesc =>
      'Surlignez des conditions dans n\'importe quelle app puis touchez Enprive Check dans le menu Android.';

  @override
  String get recentlyReviewed => 'Récemment vérifiés';

  @override
  String verifiedClausesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citations correspondantes',
      one: '1 citation correspondante',
    );
    return '$_temp0';
  }

  @override
  String get trySampleText => 'Essayer un texte exemple';

  @override
  String get modePasteText => 'Coller du texte';

  @override
  String get modePolicyLink => 'Lien vers la politique';

  @override
  String get hintAppName => 'Nom de l\'application';

  @override
  String get defaultSubjectTitle => 'Politique de confidentialité';

  @override
  String get selectedExcerptTitle => 'Extrait de politique sélectionné';

  @override
  String get hintPastePolicy =>
      'Collez le texte de la politique de confidentialité ici…';

  @override
  String get btnReviewOnPhone => 'Vérifier sur ce téléphone';

  @override
  String get onboardingIntroHeadline => 'Bonjour, je suis Deni. 👋';

  @override
  String get onboardingIntroLead =>
      'Rendons la confidentialité des applications plus facile à comprendre.';

  @override
  String get onboardingIntroBody =>
      'Je vous aide à découvrir ce que dit vraiment la politique de confidentialité d\'une application, à repérer les passages importants et à comprendre ce que signale votre appareil.\n\nSans devinettes ni fausses promesses. Juste des explications claires et des preuves pour décider en toute connaissance de cause.';

  @override
  String get onboardingIntroFooter => 'Sachez ce que vous acceptez.';

  @override
  String get splashQuote => 'Sachez ce que vous acceptez';

  @override
  String get onboardingStep1Question =>
      'Comment souhaitez-vous que j\'explique\nles conditions de confidentialité ?';

  @override
  String get depthQuickMultiline => 'Simple et\nrapide';

  @override
  String get depthBalancedMultiline => 'Vue\néquilibrée';

  @override
  String get depthFullMultiline => 'Détails\ncomplets';

  @override
  String get onboardingReadinessTitle => 'Privé par défaut\nsur ce téléphone';

  @override
  String get onboardingReadinessSubtitle =>
      'Conçu pour permettre aux parents et enseignants d\'inspecter des apps sans partager de données de l\'appareil.';

  @override
  String get readinessRow1Title => 'Analysé ici d\'abord';

  @override
  String get readinessRow1Desc =>
      'Les politiques sont lues sur votre téléphone avant toute chose.';

  @override
  String get readinessRow2Title => 'Vos apps restent privées';

  @override
  String get readinessRow2Desc =>
      'La liste de vos applications et leurs autorisations ne quittent jamais ce téléphone.';

  @override
  String get readinessRow3Title => 'Données personnelles masquées';

  @override
  String get readinessRow3Desc =>
      'Si vous choisissez l\'aide dans le cloud, les noms, adresses e-mail et numéros de téléphone sont masqués avant tout envoi.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get privateAnalysisTitle => 'Analyse privée sur ce téléphone';

  @override
  String get onDeviceReadyMsg => 'L\'IA sur l\'appareil est active et prête.';

  @override
  String get localScannerProtectedMsg =>
      'Prêt à vérifier les politiques hors ligne sur ce téléphone.';

  @override
  String get statusChecking => 'Vérification…';

  @override
  String get btnCheckReadiness => 'Vérifier l\'état';

  @override
  String get howShouldDeniExplain => 'Comment Deni doit-il expliquer ?';

  @override
  String get depthQuick => 'Rapide';

  @override
  String get depthBalanced => 'Équilibré';

  @override
  String get depthFull => 'Détaillé';

  @override
  String get preferencesSection => 'Préférences';

  @override
  String get meetDeniGuide => 'Découvrir Deni et le guide';

  @override
  String clearSavedReceiptsCount(int count) {
    return 'Effacer les reçus enregistrés ($count)';
  }

  @override
  String get btnClear => 'Effacer';

  @override
  String get confirmClearReceiptsTitle => 'Effacer les reçus enregistrés ?';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cela supprimera $count analyses enregistrées de votre téléphone.',
      one: 'Cela supprimera 1 analyse enregistrée de votre téléphone.',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'Annuler';

  @override
  String get receiptsTitle => 'Reçus';

  @override
  String get tooltipSearch => 'Rechercher';

  @override
  String get hintSearchReceipts => 'Rechercher des analyses…';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterReview => 'À vérifier';

  @override
  String get filterNoConcern => 'Sans alerte';

  @override
  String get emptyFilteredTitle => 'Aucun reçu correspondant';

  @override
  String get emptyReceiptsTitle => 'Aucun reçu enregistré';

  @override
  String get emptyFilteredBody => 'Essayez un autre filtre ci-dessus.';

  @override
  String get emptyReceiptsBody =>
      'Ajoutez un signet après une analyse pour en conserver une copie privée sur votre téléphone.';

  @override
  String get btnStartReview => 'Lancer une analyse';

  @override
  String get btnOpenReceipt => 'Ouvrir le reçu';

  @override
  String get btnDelete => 'Supprimer';

  @override
  String get checkingPhoneReadiness =>
      'Vérification de l\'analyse privée sur ce téléphone…';

  @override
  String get geminiNanoReadyMsg =>
      'L\'IA sur l\'appareil est prête sur ce téléphone. Les analyses restent entièrement sur votre appareil.';

  @override
  String get modelDownloadingMsg =>
      'Téléchargement du modèle privé en arrière-plan.';

  @override
  String get modelDownloadableMsg =>
      'Le modèle local peut être téléchargé via Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'Ce téléphone vérifie les politiques hors ligne sur votre appareil par défaut.';

  @override
  String get preparingPrivateAnalysis => 'Préparation de l\'analyse privée…';

  @override
  String get onDeviceAiReadyTitle => 'IA locale prête';

  @override
  String get localScannerActiveTitle => 'Vérification hors ligne prête';

  @override
  String get privateAnalysisSheetSubtitle =>
      'Vos applications installées et leurs autorisations ne quittent jamais votre téléphone.';

  @override
  String get btnDone => 'Terminé';

  @override
  String get btnCheckAgain => 'Vérifier à nouveau';

  @override
  String get reviewingOnPhone => 'Analyse sur ce téléphone…';

  @override
  String get readingClausesInitial =>
      'Lecture du texte de la politique sur ce téléphone…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current sur $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String get thoughtSignaturePrefix => 'ID de contrôle';

  @override
  String get viewStreamedThoughts => 'Comment Enprive a vérifié cela';

  @override
  String get hideStreamedThoughts => 'Masquer comment Enprive a vérifié cela';

  @override
  String get analysisTraceDefaultTitle => 'Comment ce contrôle a été vérifié';

  @override
  String get savedToLocalReceiptsSnack => 'Enregistré dans vos reçus locaux.';

  @override
  String get snapshotSheetTitle => 'Texte de politique examiné';

  @override
  String get snapshotSourcePrefix => 'Source';

  @override
  String get snapshotReviewedPrefix => 'Examiné';

  @override
  String get snapshotDigestPrefix => 'Empreinte du document';

  @override
  String get statFindings => 'Points relevés';

  @override
  String get statVerified => 'Vérifiés';

  @override
  String get statOsGranted => 'Autorisé sur le téléphone';

  @override
  String get statUnverified => 'Introuvable';

  @override
  String get keyFindingsTitle => 'Points clés relevés';

  @override
  String get reviewedExcerptTitle => 'Extrait examiné';

  @override
  String get permissionsOnPhoneTitle => 'Autorisations sur ce téléphone';

  @override
  String get viewReviewedSnapshot => 'Voir le texte de politique examiné';

  @override
  String get btnSavedToReceipts => 'Enregistré dans Reçus';

  @override
  String get observedOnPhoneLabel => 'Observé sur ce téléphone';

  @override
  String get quoteVerifiedLabel => 'Citation exacte de la politique';

  @override
  String get unverifiedClaimLabel => 'Introuvable dans la politique';

  @override
  String get categoryDataCollection => 'Collecte de données';

  @override
  String get categorySharing => 'Partage avec des tiers';

  @override
  String get categoryTracking => 'Localisation et suivi';

  @override
  String get categoryRetention => 'Conservation et voix';

  @override
  String get categoryParentalControls => 'Contrôle parental';

  @override
  String get labelInPlainLanguage => 'En termes simples';

  @override
  String get labelOnThisPhone => 'Sur ce téléphone';

  @override
  String get labelWhatRemainsUnknown => 'Ce que nous ignorons encore';

  @override
  String get presetQuestionMeaning =>
      'Qu\'est-ce que cela implique pour mon enfant ?';

  @override
  String get presetQuestionOptOut => 'Peut-on désactiver ou refuser cela ?';

  @override
  String get presetQuestionUnknown => 'Qu\'est-ce qui reste flou ici ?';

  @override
  String get readingCitedClause => 'Lecture de la citation de la politique…';

  @override
  String get deniAnswerTitle => 'Réponse de Deni';

  @override
  String get stepsAndReasoning => 'Comment Deni a vérifié cela';

  @override
  String get chooseReviewModeTitle => 'Choisissez comment analyser ce texte';

  @override
  String get cloudNeverSendsAppsNote =>
      'Les applications installées et les autorisations ne sont jamais envoyées.';

  @override
  String get tooltipClose => 'Fermer';

  @override
  String get checkAppSheetSubtitle =>
      'Vérifié localement sur votre téléphone. Votre liste d\'applications n\'est jamais envoyée.';

  @override
  String get trySampleKidsApp => 'Essayer un exemple d\'app enfant';

  @override
  String get sampleEduTrackSubtitle => 'Localisation, micro et caméra';

  @override
  String get sampleCalmMathSubtitle => 'Maths hors ligne';

  @override
  String get appsOnThisPhone => 'Applications sur ce téléphone';

  @override
  String get hintSearchApps => 'Rechercher des apps…';

  @override
  String get noMatchingApps =>
      'Aucune application correspondante trouvée sur ce téléphone.';

  @override
  String get sampleSyntheticBadge => 'App exemple';

  @override
  String get permissionInspectionTitle =>
      'Autorisations du téléphone vérifiées';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Ajouter la politique de confidentialité de cette app';

  @override
  String get snapshotDigestLabel => 'Empreinte du document';

  @override
  String get snapshotDigestExplanation =>
      'Un code unique qui permet de vérifier qu\'il s\'agit exactement du texte examiné par Enprive. Si ne serait-ce qu\'une lettre change, ce code change aussi.';

  @override
  String get copyDigestBtn => 'Copier l\'empreinte';

  @override
  String get digestCopiedMsg => 'Empreinte du document copiée';

  @override
  String get permissionGrantedBadge => 'Autorisé sur ce téléphone';

  @override
  String get permissionNotGrantedBadge => 'Non autorisé';

  @override
  String get checkingPolicyWithCloudAi =>
      'Vérification de la politique avec l’IA cloud.';

  @override
  String get preparingCloudAiStream =>
      'Masquage des données personnelles avant le contrôle cloud…';

  @override
  String get cancellingAnalysis => 'Annulation…';

  @override
  String get analysisCancelledNotice => 'Analyse annulée.';

  @override
  String get cloudTimedOutNotice =>
      'L’IA cloud n’a pas répondu à temps. Aucune nouvelle tentative automatique n’a été lancée.';

  @override
  String get cloudFallbackBannerTitle =>
      'Cloud indisponible : vérifié sur ce téléphone';

  @override
  String get cloudFallbackBannerBody =>
      'L\'analyse cloud était indisponible, Enprive a donc vérifié cette politique directement sur votre téléphone.';

  @override
  String get appPickerFilterAll => 'Toutes les apps';

  @override
  String get appPickerFilterDownloaded => 'Téléchargées';

  @override
  String get appPickerFilterSystem => 'Système';

  @override
  String get appPickerRecentlyChecked => 'Vérifiées récemment';

  @override
  String get appPickerStatusPolicySaved => 'Analyse de politique enregistrée';

  @override
  String get appPickerStatusPermissionsInspected => 'Autorisations vérifiées';

  @override
  String get appPickerStatusNotReviewed => 'Non vérifiée';

  @override
  String get appPickerSearchHint => 'Rechercher par nom d\'app ou App ID…';

  @override
  String get appPickerEmptyInstalledTitle =>
      'Aucune application installée disponible';

  @override
  String get appPickerEmptyInstalledBody =>
      'Nous n\'avons trouvé aucune application à vérifier sur ce téléphone.';

  @override
  String get intakeModeDocument => 'Document';

  @override
  String get intakeActionInspectText => 'Vérifier le texte de la politique';

  @override
  String get intakeActionFetchUrl => 'Ouvrir et vérifier la politique';

  @override
  String get intakeActionChooseDocument => 'Choisir un PDF, TXT ou DOCX';

  @override
  String get intakeActionReplaceDocument =>
      'Choisir un document de remplacement';

  @override
  String get intakeWorkingLabel => 'Traitement…';

  @override
  String get intakeCancelFetch => 'Annuler le chargement';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'Charge directement cette page web publique. Ajouter un lien ici ne prouve pas qui possède l\'application.';

  @override
  String get intakePasteLocalNote =>
      'Vérifié d\'abord localement sur ce téléphone. Rien n\'est envoyé sans votre autorisation.';

  @override
  String get intakeDocumentCardTitle =>
      'Importer un fichier de politique PDF, TXT ou DOCX';

  @override
  String get intakeDocumentCardBody =>
      'Nous lisons le texte directement sur votre téléphone (jusqu\'à 10 Mo). Votre fichier n\'est jamais envoyé.';

  @override
  String get intakeCompareWithAppPrompt =>
      'Comparer avec une app installée (facultatif)';

  @override
  String get intakeCompareWithAppHint =>
      'Fonctionne localement sur ce téléphone. Votre liste d\'applications ne quitte jamais votre appareil.';

  @override
  String get intakeCompareWithAppChange => 'Changer';

  @override
  String get intakeCompareWithAppRemove => 'Retirer';

  @override
  String get intakeLockedAppContextLabel => 'Application sélectionnée';

  @override
  String get intakeFindPolicyOnPlayStore =>
      'Trouver le lien de la politique sur le Play Store';

  @override
  String get intakePlayStoreHelperNote =>
      'Ouvre le Play Store pour vous permettre de copier le lien vers la politique de confidentialité. Enprive ne le copie jamais automatiquement et ne suppose pas que le lien est officiel.';

  @override
  String get intakePlayStoreUnavailable =>
      'Impossible d\'ouvrir Google Play Store sur cet appareil. Collez plutôt l\'URL ou le texte de la politique manuellement.';

  @override
  String get intakeRecoverySwitchPaste => 'Coller le texte à la place';

  @override
  String get intakeRecoverySwitchDocument => 'Importer un document';

  @override
  String get intakeRecoveryRetryUrl => 'Réessayer le chargement';

  @override
  String get intakeExpiredDocumentShareNotice =>
      'Le lien vers le fichier partagé à l\'origine ne peut plus être rouvert. Choisissez un autre fichier PDF, TXT ou DOCX ou collez le texte de la politique manuellement.';

  @override
  String get intakeAssociationWarningTitle =>
      'Vérification du lien app-politique';

  @override
  String get intakeAssociationContinueAnyway => 'Continuer quand même';

  @override
  String get intakeAssociationChangeApp => 'Changer l\'app sélectionnée';

  @override
  String get intakeAssociationInspectWithoutApp =>
      'Vérifier la politique sans app';

  @override
  String get intakeModeSelectorSemanticLabel =>
      'Méthode de saisie de la politique';

  @override
  String get tooltipClearSearch => 'Effacer la recherche';

  @override
  String get intakeRecoveryEditUrl => 'Modifier l\'URL';

  @override
  String get voiceSummaryTitle => 'Résumé de Deni en termes simples';

  @override
  String get voiceSummaryPreparing =>
      'Préparation du résumé en termes simples…';

  @override
  String get voiceSynthesizingExpressive =>
      'Préparation de la voix expressive de Deni…';

  @override
  String get voiceBtnListenOffline => 'Écouter';

  @override
  String get voiceBtnStop => 'Arrêter';

  @override
  String get voiceBtnExpressiveCloud => 'Voix expressive';

  @override
  String get voiceBtnSummarizeCloud => 'Résumer avec l\'IA cloud';

  @override
  String get voiceBadgeExpressive => 'Voix expressive cloud';

  @override
  String get voiceBadgeDeviceOffline => 'Voix du téléphone · Hors ligne';

  @override
  String get voiceViewSourceQuote => 'Citation source';

  @override
  String get voiceHideSourceQuote => 'Masquer la citation';

  @override
  String get voiceInspectFinding => 'Voir le point relevé';

  @override
  String get voiceConsentTitle => 'Choisir la voix de Deni';

  @override
  String get voiceConsentDisclosure =>
      'Pour lire ce résumé à voix haute avec la voix expressive cloud de Deni, Enprive n\'enverra que le texte du résumé affiché ci-dessus (avec les données personnelles masquées) pour cette seule demande. Vos applications et les autorisations de votre téléphone ne sont jamais envoyées.';

  @override
  String get voiceConsentPrimaryAction =>
      'Utiliser la voix expressive une fois';

  @override
  String get voiceConsentSecondaryAction => 'Lire sur ce téléphone';

  @override
  String get voiceConsentPayloadLabel => 'Texte exact qui sera lu';

  @override
  String get voiceSummaryConsentTitle =>
      'Résumer les points relevés avec l\'IA cloud';

  @override
  String get voiceSummaryConsentDisclosure =>
      'Pour résumer ces citations de politique en termes simples dans le cloud, Enprive n\'enverra que le texte affiché ci-dessus (avec les données personnelles masquées) pour cette seule demande. Vos applications et les autorisations de votre téléphone ne sont jamais envoyées.';

  @override
  String get voiceFallbackDeviceNotice =>
      'La voix expressive cloud était indisponible : utilisation de la voix hors ligne de ce téléphone à la place.';

  @override
  String get voiceUnavailableNotice =>
      'La lecture vocale n\'est pas disponible pour cette langue sur ce téléphone. Vous pouvez lire le résumé de Deni ci-dessus.';

  @override
  String get voiceTooltipReadSummary =>
      'Écouter le résumé de Deni en termes simples';

  @override
  String get voiceTooltipStopReading => 'Arrêter la lecture vocale';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'points',
      one: 'point',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points relevés',
      one: '1 point relevé',
      zero: 'Aucun point relevé',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citations vérifiées dans la politique',
      one: '1 citation vérifiée dans la politique',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observés sur ce téléphone',
      one: '1 observé sur ce téléphone',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'Autorisé sur ce téléphone';

  @override
  String get permissionNotAllowedOnPhone => 'Non autorisé';

  @override
  String get permissionAllowedInSample => 'Autorisé dans l\'exemple';

  @override
  String get permissionNotAllowedInSample => 'Non autorisé dans l\'exemple';

  @override
  String get permissionMismatchChip => 'Absent de la politique';

  @override
  String get howEnpriveCheckedThis => 'Comment Enprive a vérifié cela';

  @override
  String get hideHowEnpriveChecked => 'Masquer comment Enprive a vérifié cela';

  @override
  String get consentWhatWouldBeSent => 'Ce qui serait envoyé';

  @override
  String get consentSentScope =>
      'Seul le texte de l\'aperçu quitte ce téléphone, pour cette seule demande.';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count données personnelles sont masquées avant l\'envoi.',
      one: '1 donnée personnelle est masquée avant l\'envoi.',
      zero: 'Aucune donnée personnelle trouvée à masquer.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'Votre liste d\'applications et les autorisations de votre téléphone restent sur ce téléphone.';

  @override
  String receiptDeletedSnack(String title) {
    return '$title supprimé';
  }

  @override
  String get btnUndo => 'Annuler';

  @override
  String get readinessPromiseMaskedTitle => 'Données personnelles masquées';

  @override
  String get readinessPromiseMaskedLine =>
      'Si vous choisissez le cloud, les noms, e-mails et numéros sont masqués d\'abord.';

  @override
  String findingDetailTitle(int index, int total) {
    return 'Point $index sur $total';
  }

  @override
  String get findingReviewChip => 'À vérifier';

  @override
  String get askDeniAboutThis => 'Demander à Deni à ce sujet';

  @override
  String get labelWhatPolicySays => 'Ce que dit la politique';

  @override
  String get labelWhatAndroidReports => 'Ce que montre votre téléphone';

  @override
  String get sourceButtonTooltip => 'Source examinée';

  @override
  String get linkInstalledAppBtn => 'Associer une app installée';

  @override
  String get linkInstalledAppCardTitle =>
      'Comparer avec une app sur ce téléphone';

  @override
  String get linkInstalledAppCardBody =>
      'Choisissez une app installée pour comparer ses autorisations sur le téléphone avec cette politique dans la même analyse. Votre liste d\'applications reste sur ce téléphone.';

  @override
  String get linkAppPickerTitle => 'Associer une app installée';

  @override
  String get changeLinkedAppPickerTitle => 'Changer l\'app associée';

  @override
  String get linkAppPickerSubtitle =>
      'Choisissez une app sur ce téléphone pour comparer ses autorisations avec cette politique. Votre liste d\'applications ne quitte jamais ce téléphone.';

  @override
  String get linkedAppCurrentlySelectedBadge => 'Associée';

  @override
  String get linkedAppSectionLabel => 'App associée sur ce téléphone';

  @override
  String get btnChangeLinkedApp => 'Changer d\'app';

  @override
  String get btnUnlinkApp => 'Dissocier';

  @override
  String get btnUpdatePrivacyPolicy =>
      'Joindre une politique de confidentialité mise à jour';

  @override
  String linkedAppSnack(String appName) {
    return '$appName associée. Autorisations comparées sur ce téléphone.';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return '$appName associée. Vérifiez la note de correspondance ci-dessous.';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName est déjà associée avec les mêmes autorisations.';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return '$appName dissociée. Affichage de l\'analyse de la politique uniquement.';
  }

  @override
  String get associationStatusPackageTitle =>
      'App ID trouvé dans cette politique';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'Cette politique mentionne $packageName. Cela indique qu\'elle peut concerner $appName, mais le texte seul ne prouve pas qui détient cette politique.';
  }

  @override
  String get associationStatusNameTitle =>
      'Nom de l\'app trouvé dans cette politique';

  @override
  String associationStatusNameBody(String appName) {
    return 'Cette politique mentionne $appName. Cela indique qu\'elle peut concerner cette app, mais un nom identique ne prouve pas qui détient cette politique.';
  }

  @override
  String get associationStatusUnverifiedTitle =>
      'Associée par vous pour comparaison';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'Cette politique ne mentionne ni $appName ni son App ID. Vérifiez qu\'il s\'agit de la bonne politique : l\'associer ici ne prouve pas qui en est propriétaire.';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'L\'adresse web contient des mots de $appName, mais le texte de la politique ne cite pas cette app. Vérifiez qu\'il s\'agit de la bonne politique : l\'associer ici ne prouve pas qui en est propriétaire.';
  }

  @override
  String get associationStatusUnmatchedTitle =>
      'Cette politique concerne peut-être une autre app';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'Cette politique ne mentionne pas $appName. Elle cite plutôt $otherApps. Vérifiez que vous avez associé la bonne app ou ouvert la bonne politique.';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'Cette politique mentionne plusieurs apps';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'Cette politique mentionne $appName ainsi que $otherApps. Elle peut couvrir plusieurs apps ou une politique d\'entreprise commune : vérifiez qu\'elle s\'applique ici.';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      'Plusieurs apps sur ce téléphone portent un nom similaire';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'Cette politique mentionne $appName sans indiquer un App ID précis, et d\'autres apps sur votre téléphone ($otherApps) portent un nom similaire. Vérifiez que vous avez associé la bonne.';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'Cette politique peut concerner plusieurs apps. Vérifiez qu\'elle s\'applique bien à $appName.';
  }

  @override
  String get associationOwnershipLimitation =>
      'Le texte et les liens web ne prouvent jamais qui a publié ou possède une politique.';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count autorisations sur ce téléphone ne sont pas clairement mentionnées dans cette politique. Un écart invite à regarder de plus près, sans être une preuve d\'abus.',
      one: '1 autorisation sur ce téléphone n\'est pas clairement mentionnée dans cette politique. Un écart invite à regarder de plus près, sans être une preuve d\'abus.',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'Aucune des autorisations vérifiées sur ce téléphone ne contredit cette politique. Les autorisations seules ne peuvent pas montrer ce qu\'une app envoie réellement.';

  @override
  String get permissionComparisonLimitationNote =>
      'Votre téléphone n\'affiche que les réglages d\'autorisations sur ce téléphone. Cette comparaison invite à regarder de plus près : elle ne prouve jamais un abus ni un envoi de données.';

  @override
  String get permissionNotRequestedOnPhone => 'Non demandée par l\'app';

  @override
  String get permissionNotRequestedInSample => 'Non demandée dans l\'exemple';

  @override
  String get permissionsEmptyComparisonTitle =>
      'Aucune autorisation sensible dans ce contrôle';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'Votre téléphone recense $requestedCount autorisations ($grantedCount accordées) pour $appName, dont aucune dans les catégories sensibles vérifiées ici (localisation, caméra, micro, contacts, photos ou identifiant publicitaire).';
  }

  @override
  String get sourceDeviceInspection => 'Vérifié sur ce téléphone';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => 'Détails avancés';

  @override
  String get advancedDetailsSubtitle =>
      'Détails techniques confirmant quand et où ce texte de politique a été vérifié.';

  @override
  String get sourceSectionTitle => 'D\'où provient cette politique';

  @override
  String get cloudPayloadLabel => 'Texte exact qui sera envoyé';

  @override
  String get cloudPayloadNoPiiLabel => 'Aucune donnée personnelle trouvée';

  @override
  String cloudPayloadHiddenCount(int count) {
    return 'Masquées ($count)';
  }

  @override
  String get summarySourceOnDevice => 'Résumé sur ce téléphone';

  @override
  String get summarySourceInCloud => 'Résumé dans le cloud';

  @override
  String get summarySourceOffline => 'Résumé hors ligne sur ce téléphone';

  @override
  String get summarySourceUnknown => 'Source du résumé inconnue';

  @override
  String get notFromPolicySuffix =>
      'Issu des réglages du téléphone, pas de la politique';

  @override
  String get sampleNotFromPolicySuffix =>
      'Exemple uniquement, pas issu de la politique';

  @override
  String get learnHeaderSubtitle =>
      'Guides et schémas de confidentialité hors ligne';

  @override
  String get learnFilterAll => 'Tous les sujets';

  @override
  String get learnFilterPolicies => 'Politiques';

  @override
  String get learnFilterPermissions => 'Autorisations';

  @override
  String get learnFilterSharing => 'Partage';

  @override
  String get learnFilterEvidence => 'Preuves';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle =>
      'Adoptez des réflexes de confidentialité en local';

  @override
  String get learnDeckBody =>
      'Leçons 100 % hors ligne avec schémas. Vos applications installées et vos reçus n\'entrent jamais dans Apprendre.';

  @override
  String get learnDeckCheckBtn => 'Mettre en pratique · Vérifier une app';

  @override
  String get learnCheckAppBridgeBtn => 'Vérifier une app sur ce téléphone';

  @override
  String get learnSectionDiagram => 'Comment cela fonctionne';

  @override
  String get learnSectionSteps => 'Étapes clés';

  @override
  String get learnSectionQuickCheck => 'Vérification rapide';

  @override
  String get learnTooltipListenLesson =>
      'Lire cette leçon à voix haute hors ligne';

  @override
  String get learnTooltipStopLesson => 'Arrêter la lecture de la leçon';

  @override
  String get learnVoiceUnavailableNotice =>
      'La lecture vocale hors ligne n\'est pas disponible pour cette langue sur ce téléphone. Vous pouvez lire la leçon ci-dessous.';

  @override
  String get learnQuickCheckCorrectBadge => 'Bonne réponse';

  @override
  String get learnQuickCheckTryAgainBadge => 'Essayez un autre choix';

  @override
  String learnLessonProgress(int current, int total) {
    return 'Leçon $current sur $total';
  }

  @override
  String get learnBackTooltip => 'Retour à Apprendre';

  @override
  String get learnPreviousLesson => 'Précédent';

  @override
  String get learnNextLesson => 'Suivant';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return 'Leçon précédente : $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return 'Leçon suivante : $title';
  }

  @override
  String get learnPolicyFolderTitle => 'Politiques de confidentialité';

  @override
  String get learnPolicyTitle =>
      'Qu\'est-ce qu\'une politique de confidentialité (et ce qu\'elle ne peut pas prouver)';

  @override
  String get learnPolicySubtitle =>
      'Ce que promettent les développeurs face à ce qui reste inconnu';

  @override
  String get learnPolicyIntro =>
      'Une politique de confidentialité est la déclaration publique d\'un développeur expliquant quelles données une app dit collecter, pourquoi elle les utilise, qui peut les recevoir et quels choix ont les familles.';

  @override
  String get learnPolicyStep1 =>
      'Cherchez quatre bases : quelles données sont collectées, pourquoi l\'app en a besoin, qui d\'autre peut les recevoir et comment demander leur suppression.';

  @override
  String get learnPolicyStep2 =>
      'Les formulations confuses sont fréquentes. Une étude de 2026 sur les apps éducatives pour enfants a montré que très peu de politiques étaient faciles à lire et que la plupart des apps ne correspondaient pas entièrement à ce que leurs politiques affirmaient.';

  @override
  String get learnPolicyStep3 =>
      'Une politique de confidentialité ne montre que ce que dit le développeur sur le papier. La lire ne peut pas prouver ce que l\'app envoie réellement sur Internet.';

  @override
  String get learnPolicyStep4 =>
      'Comparer une politique avec les autorisations de votre téléphone donne une vue plus claire, tout en gardant à l\'esprit qu\'Enprive ne peut pas voir le trafic Internet en direct.';

  @override
  String get learnPolicyQuickQuestion =>
      'Que prouve la lecture de la politique de confidentialité d\'une app ?';

  @override
  String get learnPolicyQuickOption1 =>
      'Que l\'app n\'envoie jamais de données à personne';

  @override
  String get learnPolicyQuickOption2 =>
      'Ce que dit le développeur : pas ce que l\'app envoie réellement';

  @override
  String get learnPolicyQuickOption3 =>
      'Que la caméra et le micro du téléphone sont coupés';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'Exactement. Une politique est la déclaration publique du développeur, pas une preuve de ce que l\'app envoie réellement sur Internet.';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      'Pas tout à fait. Lire une politique vous dit seulement ce que déclare le développeur : cela ne peut ni prouver l\'activité Internet ni couper les autorisations du téléphone.';

  @override
  String get learnDiagramPolicySaysTitle => 'La politique dit';

  @override
  String get learnDiagramPolicySaysBody => 'Promesse écrite du développeur';

  @override
  String get learnDiagramPolicyQuoteSample =>
      '« Nous pouvons partager des données avec des partenaires… »';

  @override
  String get learnDiagramPhoneShowsTitle => 'Le téléphone montre';

  @override
  String get learnDiagramPhoneShowsBody => 'Autorisations accordées ici';

  @override
  String get learnDiagramUnknownTitle => 'Toujours inconnu';

  @override
  String get learnDiagramUnknownBody =>
      'Trafic Internet en direct invisible pour Enprive';

  @override
  String get learnDiagramPolicyCaption =>
      'Une politique est une promesse, pas une preuve de comportement';

  @override
  String get learnDiagramPolicySemantic =>
      'Schéma comparant trois aspects de la confidentialité d\'une app. D\'abord, La politique dit : la promesse écrite du développeur. Ensuite, Le téléphone montre : les autorisations accordées sur ce téléphone. Enfin, dans un cadre en pointillés, Toujours inconnu : le trafic Internet en direct qu\'Enprive ne peut pas voir. Une politique de confidentialité est une promesse, pas une preuve de comportement.';

  @override
  String get learnPermissionsFolderTitle => 'Autorisations du téléphone';

  @override
  String get learnPermissionsTitle => 'Les autorisations Android expliquées';

  @override
  String get learnPermissionsSubtitle =>
      'Les quatre choix Android et où les vérifier';

  @override
  String get learnPermissionsIntro =>
      'Les autorisations sont des portes qui contrôlent si une app peut accéder aux capteurs et aux données de votre téléphone, comme la caméra, le micro, la localisation, les photos, les contacts ou les notifications.';

  @override
  String get learnPermissionsStep1 =>
      'Demandez-vous si l\'autorisation correspond à la fonction : une app de calcul ou de lecture a rarement besoin de votre localisation, de vos contacts ou de votre caméra.';

  @override
  String get learnPermissionsStep2 =>
      'Android propose jusqu\'à quatre choix : Ne pas autoriser, Toujours demander, Autoriser seulement lorsque l\'appli est utilisée et Toujours autoriser (pour la localisation en arrière-plan).';

  @override
  String get learnPermissionsStep3 =>
      'Commencez par le choix le plus limité qui permet à la fonction de marcher, comme Toujours demander ou Lorsque l\'appli est utilisée.';

  @override
  String get learnPermissionsStep4 =>
      'Ouvrez les Paramètres Android et consultez le Tableau de bord de confidentialité pour voir quelles apps ont récemment utilisé la Caméra, le Micro ou la Localisation.';

  @override
  String get learnPermissionsStep5 =>
      'Désactivez les autorisations à tout moment dans les paramètres de l\'app, ou laissez activée la mise en veille de l\'app si elle est inutilisée pour qu\'Android retire automatiquement les anciennes autorisations. Une autorisation accordée montre une capacité, pas la preuve d\'un envoi de données.';

  @override
  String get learnPermissionsQuickQuestion =>
      'Une app d\'exercices de maths demande l\'accès à la caméra sans raison claire. Quelle est la meilleure première étape ?';

  @override
  String get learnPermissionsQuickOption1 =>
      'Toucher Ne pas autoriser et vérifier si les exercices fonctionnent toujours';

  @override
  String get learnPermissionsQuickOption2 =>
      'Choisir Toujours autoriser pour ne plus revoir la fenêtre';

  @override
  String get learnPermissionsQuickOption3 =>
      'Supposer que l\'app a déjà envoyé des photos';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      'Bien vu. Toucher Ne pas autoriser vous permet de vérifier si l\'app fonctionne sans caméra, et vous pouvez modifier les autorisations à tout moment dans les Paramètres Android.';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'Essayez d\'abord un choix plus limité. Touchez Ne pas autoriser pour tester si la fonction marche toujours, et souvenez-vous qu\'une autorisation accordée montre une capacité, pas la preuve d\'un envoi.';

  @override
  String get learnDiagramPermLadderTitle =>
      'De l\'accès le plus limité au plus large';

  @override
  String get learnDiagramPermDenyTitle => 'Ne pas autoriser';

  @override
  String get learnDiagramPermDenyDetail =>
      'Bloqué : l\'app ne peut pas utiliser ce capteur';

  @override
  String get learnDiagramPermAskTitle => 'Toujours demander';

  @override
  String get learnDiagramPermAskDetail =>
      'Accès unique lorsque vous touchez autoriser';

  @override
  String get learnDiagramPermWhileUsingTitle => 'Lorsque l\'app est utilisée';

  @override
  String get learnDiagramPermWhileUsingDetail =>
      'Uniquement quand l\'app est ouverte à l\'écran';

  @override
  String get learnDiagramPermAllTimeTitle => 'Tout le temps';

  @override
  String get learnDiagramPermAllTimeDetail =>
      'Accès en arrière-plan même fermée';

  @override
  String get learnDiagramPermFitNote =>
      'Est-ce logique ? Quiz de maths + Caméra = demandez pourquoi';

  @override
  String get learnDiagramPermSemantic =>
      'Échelle d\'autorisations Android en quatre étapes, de l\'accès le plus limité au plus large. Étape 1, Ne pas autoriser : bloqué, l\'app ne peut pas utiliser ce capteur. Étape 2, Toujours demander : accès unique lorsque vous touchez autoriser. Étape 3, Lorsque l\'app est utilisée : accès uniquement quand l\'app est ouverte à l\'écran. Étape 4, Tout le temps : accès en arrière-plan même fermée, encadré en pointillés pour plus de vigilance. Conseil en bas : Est-ce logique ? Un quiz de maths demandant la caméra est une bonne raison de demander pourquoi.';

  @override
  String get learnSharingFolderTitle => 'Pubs et tiers';

  @override
  String get learnSharingTitle =>
      'Qui d\'autre reçoit des données : pubs, analyses et tiers';

  @override
  String get learnSharingSubtitle =>
      'Créateur de l\'app face aux services d\'aide, analyses et régies pub';

  @override
  String get learnSharingIntro =>
      'De nombreuses apps gratuites se connectent en coulisses à d\'autres entreprises. Savoir qui reçoit les informations aide les familles à distinguer le fonctionnement de l\'app du suivi des enfants d\'une app à l\'autre.';

  @override
  String get learnSharingStep1 =>
      'La première partie désigne le créateur de l\'app lui-même : par exemple enregistrer l\'avancement des devoirs ou les scores d\'un quiz pour que l\'app fonctionne.';

  @override
  String get learnSharingStep2 =>
      'Les services d\'aide sont des tiers qui gèrent des tâches en coulisses comme l\'hébergement cloud ou les rapports de plantage pour corriger les bugs.';

  @override
  String get learnSharingStep3 =>
      'Les outils d\'analyse mesurent comment les écrans sont utilisés, tandis que les régies publicitaires et courtiers en données peuvent utiliser un identifiant publicitaire pour afficher des pubs ciblées ou suivre l\'activité entre apps.';

  @override
  String get learnSharingStep4 =>
      'Méfiez-vous des formules vagues comme « partenaires de confiance » ou « à des fins commerciales », et vérifiez si la politique explique comment refuser les publicités personnalisées.';

  @override
  String get learnSharingQuickQuestion =>
      'Une politique indique que l\'app partage des informations avec des « partenaires tiers ». Quelle est la meilleure question à poser ensuite ?';

  @override
  String get learnSharingQuickOption1 =>
      'Supposer que cela signifie qu\'il n\'y a aucune publicité';

  @override
  String get learnSharingQuickOption2 =>
      'Supposer que chaque partenaire fait exactement le même travail';

  @override
  String get learnSharingQuickOption3 =>
      'Vérifier si ces partenaires sont des services d\'aide (comme l\'hébergement) ou des régies pub qui suivent entre apps';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'Exact. Les services d\'aide font tourner l\'app, tandis que les régies publicitaires et courtiers en données peuvent suivre l\'activité entre apps.';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      'Regardez de plus près ce que fait chaque partenaire. Tous les tiers ne se ressemblent pas : certains hébergent les données ou corrigent les plantages, tandis que d\'autres diffusent des pubs ou font du suivi.';

  @override
  String get learnDiagramThirdPartyYou => 'Vous';

  @override
  String get learnDiagramThirdPartyApp => 'App éducative';

  @override
  String get learnDiagramThirdPartyHosting => 'Aide et plantages';

  @override
  String get learnDiagramThirdPartyAnalytics => 'Analyses';

  @override
  String get learnDiagramThirdPartyAds => 'Régies pub';

  @override
  String get learnDiagramThirdPartyFirstParty => 'Première partie';

  @override
  String get learnDiagramThirdPartyThirdParty => 'Tiers';

  @override
  String get learnDiagramThirdPartySemantic =>
      'Schéma de flux montrant où peuvent aller les données d\'une app éducative pour enfant. Vous vous connectez à l\'app éducative, reliée par un trait plein au créateur de l\'app (première partie) et par des traits en pointillés aux tiers : outils d\'aide et de plantage, outils d\'analyse et régies pub signalées pour plus d\'attention.';

  @override
  String get learnEvidenceFolderTitle => 'Lire Enprive';

  @override
  String get learnEvidenceTitle => 'Comment lire les preuves d\'Enprive';

  @override
  String get learnEvidenceSubtitle =>
      'Niveaux de preuves, catégories et limites honnêtes';

  @override
  String get learnEvidenceIntro =>
      'Enprive distingue ce que dit la politique de confidentialité, ce que montre votre téléphone et ce qui reste inconnu, et regroupe les points par thème, jamais comme une note de sécurité.';

  @override
  String get learnEvidenceStep1 =>
      'Cinq catégories thématiques regroupent chaque point avec la même icône et la même couleur que l\'écran d\'analyse. La couleur indique le thème, jamais une note de sécurité.';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '$sourceMatched signifie qu\'Enprive a trouvé une citation exacte, mot pour mot, dans le texte de la politique que vous avez vérifié.';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '$deviceObserved signifie que votre téléphone a signalé un réglage d\'autorisation sur cet appareil : pas la preuve que des données ont été envoyées.';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '$interpretation est l\'explication de Deni en termes simples, tandis que $unverified signale des détails qu\'Enprive n\'a pas trouvés. Le silence dans une politique n\'est jamais une promesse.';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return 'Les analyses se terminent par l\'un de ces trois constats posés : $reviewRecommended, $noConcern (ce qui n\'est jamais une certification de sécurité), ou $insufficientEvidence.';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return 'Sur un écran d\'analyse, que signifie « $deviceObserved » ?';
  }

  @override
  String get learnEvidenceQuickOption1 =>
      'Que l\'app est certifiée sûre pour les enfants';

  @override
  String get learnEvidenceQuickOption2 =>
      'Que votre téléphone indique ce réglage d\'autorisation sur cet appareil : pas la preuve que des données ont été envoyées';

  @override
  String get learnEvidenceQuickOption3 =>
      'Que l\'app a forcément envoyé les données de votre enfant';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'Tout à fait. Cette mention reflète l\'état de l\'autorisation Android sur cet appareil ; elle ne peut ni prouver des envois ni certifier la sécurité.';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      'Pas tout à fait. Cette mention montre uniquement ce que signale votre téléphone au sujet d\'une autorisation : elle ne prouve jamais un envoi et n\'est jamais une certification de sécurité.';

  @override
  String get learnDiagramEvidencePolicyDetail =>
      'Citation exacte trouvée dans le texte de la politique';

  @override
  String get learnDiagramEvidencePhoneDetail =>
      'Autorisations du téléphone sur cet appareil';

  @override
  String get learnDiagramEvidenceDeniDetail =>
      'Explication en termes simples par Deni';

  @override
  String get learnDiagramEvidenceUnknownDetail =>
      'Le silence dans une politique n\'est pas une promesse';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Quatre niveaux de preuves utilisés sur l\'écran d\'analyse d\'Enprive : 1, $sourceMatched, une citation exacte trouvée dans la politique de confidentialité ; 2, $deviceObserved, les autorisations du téléphone sur cet appareil ; 3, $interpretation, l\'explication en termes simples de Deni ; et 4, séparé par une ligne en pointillés, $unverified, car le silence dans une politique n\'est pas une promesse.';
  }

  @override
  String get learnDiagramCategoriesTitle =>
      'Cinq catégories thématiques sur l\'écran d\'analyse';

  @override
  String get learnDiagramCategoriesNote =>
      'La couleur et l\'icône indiquent le thème, jamais une note de sécurité.';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Cinq catégories de preuves affichées sur l\'écran d\'analyse d\'Enprive, chacune avec son icône et sa couleur : $dataCollection, $sharing, $tracking, $retention et $parentalControls. La couleur et l\'icône indiquent le thème, jamais une note de sécurité.';
  }

  @override
  String get learnDataCollectionFolderTitle => 'Données collectées';

  @override
  String get learnDataCollectionTitle => 'Quelles données les apps collectent';

  @override
  String get learnDataCollectionSubtitle =>
      'La différence entre ce que vous saisissez et ce qui tourne en silence';

  @override
  String get learnDataCollectionIntro1 =>
      'Les apps recueillent des informations de deux façons. Certaines données viennent de ce que vous saisissez activement : votre nom, e-mail, photos, enregistrements vocaux ou réponses aux devoirs. D\'autres sont collectées automatiquement en arrière-plan, comme votre adresse IP (l\'adresse utilisée par votre téléphone sur Internet), les identifiants de l\'appareil, l\'identifiant publicitaire (un code utilisé par les pubs pour reconnaître votre téléphone), les journaux de plantage et les heures d\'ouverture de l\'app.';

  @override
  String get learnDataCollectionStep1 =>
      'Ce que vous saisissez : votre nom, école, e-mail, photos, extraits vocaux et réponses aux devoirs sont des données que vous choisissez de fournir.';

  @override
  String get learnDataCollectionStep2 =>
      'Ce qui tourne en silence : l\'app peut collecter un identifiant publicitaire, des identifiants d\'appareil, une adresse IP, des rapports de plantage et la durée d\'utilisation sans que vous appuyiez sur un bouton. Cette collecte discrète n\'est pas automatiquement mauvaise : ces signaux aident les apps à bien fonctionner.';

  @override
  String get learnDataCollectionStep3 =>
      'Données sensibles des enfants : la localisation, les enregistrements micro, les photos de la caméra et les données biométriques comme les empreintes vocales (données sur votre corps ou votre voix) présentent un risque plus élevé pour la vie privée des enfants.';

  @override
  String get learnDataCollectionStep4 =>
      'Note sur le Play Store : la section Sécurité des données de Google Play est la description fournie par le développeur lui-même. C\'est un indice, pas une preuve, et elle n\'inclut pas les données traitées uniquement sur votre appareil ou gardées brièvement en mémoire.';

  @override
  String get learnDataCollectionQuizQuestion =>
      'Lequel de ces exemples correspond à des données collectées silencieusement en arrière-plan ?';

  @override
  String get learnDataCollectionQuizChoiceA =>
      'Une photo que vous importez pour votre profil';

  @override
  String get learnDataCollectionQuizChoiceB =>
      'Votre identifiant publicitaire et les identifiants de l\'appareil';

  @override
  String get learnDataCollectionQuizChoiceC =>
      'Une réponse de devoir que vous tapez dans l\'app';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      'Exact : les identifiants publicitaires et d\'appareil sont collectés automatiquement sans que vous les saisissiez.';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      'Pas tout à fait : ce sont des données que vous saisissez activement. Les données collectées en silence comprennent les identifiants publicitaires, les identifiants d\'appareil, l\'adresse IP et les temps d\'utilisation.';

  @override
  String get learnDataCollectionDiagramYouTypeTitle =>
      'Ce que vous saisissez ou donnez';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => 'Nom, e-mail, école';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => 'Photos et vidéos';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => 'Enregistrements vocaux';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => 'Réponses aux devoirs';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle =>
      'Ce qui tourne en silence';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 =>
      'Identifiant publicitaire';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 =>
      'Identifiants d\'appareil';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'Adresse IP';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 =>
      'Rapports de plantage et usage';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      'Discret ne veut pas dire mauvais : ces signaux aident les apps à bien fonctionner.';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      'Schéma en deux parties présentant deux catégories de collecte de données. La carte supérieure intitulée « Ce que vous saisissez ou donnez » liste quatre éléments : Nom, e-mail, école ; Photos et vidéos ; Enregistrements vocaux ; Réponses aux devoirs. La carte inférieure intitulée « Ce qui tourne en silence » liste quatre éléments : Identifiant publicitaire ; Identifiants d\'appareil ; Adresse IP ; Rapports de plantage et usage. Une petite note indique « Discret ne veut pas dire mauvais : ces signaux aident les apps à bien fonctionner. » Deni est assis dessous en pose réfléchie.';

  @override
  String get learnDataCollectionCheckBridge =>
      'Vérifiez une app sur ce téléphone pour voir quelles données elle collecte.';

  @override
  String get learnDataCollectionHonestyNote =>
      'Cette leçon explique des types de données courants. Elle ne prouve pas ce qu\'une app donnée collecte ou envoie. Seuls le texte exact de la politique et les autorisations de votre téléphone peuvent le montrer.';

  @override
  String get learnRetentionFolderTitle => 'Conservation et suppression';

  @override
  String get learnRetentionTitle => 'Conservation et suppression des données';

  @override
  String get learnRetentionSubtitle =>
      'Désinstaller une app n\'efface pas les données déjà sur les serveurs de l\'entreprise';

  @override
  String get learnRetentionIntro1 =>
      'Quand vous supprimez une app de votre téléphone, les fichiers locaux sur votre appareil sont effacés, mais toutes les données déjà envoyées sur les serveurs de l\'entreprise y restent. Les politiques de confidentialité devraient indiquer combien de temps vos données sont conservées, comment demander leur suppression et ce qu\'il advient des sauvegardes, mais beaucoup utilisent des formules floues comme « aussi longtemps que raisonnablement nécessaire ».';

  @override
  String get learnRetentionStep1 =>
      'Données collectées : pendant que vous utilisez l\'app, vos informations sont envoyées et enregistrées sur les serveurs de l\'entreprise.';

  @override
  String get learnRetentionStep2 =>
      'Stockées sur les serveurs : vos données peuvent rester sur les systèmes de l\'entreprise même après que vous ayez cessé d\'utiliser l\'app.';

  @override
  String get learnRetentionStep3 =>
      'Désinstaller ne supprime pas les données serveur : retirer l\'app de votre téléphone efface seulement les fichiers locaux, pas les copies présentes sur les serveurs de l\'entreprise.';

  @override
  String get learnRetentionStep4 =>
      'Demande de suppression : vous pouvez demander à l\'entreprise de supprimer votre compte et vos données ; les politiques devraient indiquer le délai prévu.';

  @override
  String get learnRetentionStep5 =>
      'Durée inconnue : les politiques qui disent « aussi longtemps que nécessaire » ou « à des fins commerciales » laissent le délai réel de suppression flou.';

  @override
  String get learnRetentionQuizQuestion =>
      'Que deviennent vos données sur les serveurs de l\'entreprise lorsque vous désinstallez une app de votre téléphone ?';

  @override
  String get learnRetentionQuizChoiceA =>
      'Elles sont supprimées automatiquement';

  @override
  String get learnRetentionQuizChoiceB =>
      'Elles peuvent rester sur les serveurs : désinstaller l\'app ne les supprime pas';

  @override
  String get learnRetentionQuizChoiceC =>
      'Elles sont anonymisées immédiatement';

  @override
  String get learnRetentionQuizFeedbackRight =>
      'Exact : la désinstallation retire uniquement l\'app de votre téléphone. Les données sur les serveurs de l\'entreprise peuvent rester jusqu\'à ce que vous demandiez leur suppression.';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      'Pas tout à fait : désinstaller une app ne supprime pas les données déjà envoyées sur les serveurs de l\'entreprise. Vous devez demander la suppression du compte.';

  @override
  String get learnRetentionDiagramCollected =>
      'Données collectées pendant l\'utilisation';

  @override
  String get learnRetentionDiagramStored =>
      'Stockées sur les serveurs de l\'entreprise';

  @override
  String get learnRetentionDiagramUninstall =>
      'Vous désinstallez l\'app : fichiers locaux effacés, données serveur conservées';

  @override
  String get learnRetentionDiagramDeleteRequest =>
      'Vous demandez la suppression du compte';

  @override
  String get learnRetentionDiagramUnknownTail =>
      'Durée inconnue : la politique dit « aussi longtemps que nécessaire »';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      'Frise en cinq étapes montrant le cycle de vie des données. Étape 1 : Données collectées pendant l\'utilisation, avec icône de base de données. Étape 2 : Stockées sur les serveurs de l\'entreprise, avec icône de serveur. Étape 3 : Vous désinstallez l\'app : fichiers locaux effacés, données serveur conservées, avec icône de smartphone. Étape 4 : Vous demandez la suppression du compte, avec icône de corbeille. Étape 5 : Durée inconnue : la politique dit « aussi longtemps que nécessaire », avec flèche en pointillés et icône d\'aide. Deni se tient dessous avec un reçu.';

  @override
  String get learnRetentionCheckBridge =>
      'Vérifiez une app sur ce téléphone pour voir ce que sa politique dit sur la conservation.';

  @override
  String get learnRetentionHonestyNote =>
      'Cette leçon décrit des pratiques courantes de conservation. Elle ne prouve pas ce qu\'une entreprise précise fait réellement de vos données. Seuls le texte exact de la politique et une demande de suppression peuvent le montrer.';

  @override
  String get learnUnclearPoliciesFolderTitle => 'Politiques floues';

  @override
  String get learnUnclearPoliciesTitle =>
      'Repérer les politiques floues et les boutons piégeurs';

  @override
  String get learnUnclearPoliciesSubtitle =>
      'Comment reconnaître un langage vague et des écrans de consentement insistants';

  @override
  String get learnUnclearPoliciesIntro1 =>
      'Certaines politiques de confidentialité utilisent des mots vagues qui empêchent de savoir ce qui arrive vraiment à vos données. Les écrans de consentement peuvent aussi utiliser des astuces de design, comme un gros bouton lumineux « Tout accepter » à côté d\'un tout petit lien « Gérer les paramètres », pour vous pousser à accepter sans lire.';

  @override
  String get learnUnclearPoliciesStep1 =>
      'Signes de flou : surveillez les formules ouvertes comme « peut partager avec des partenaires de confiance », « à des fins commerciales » ou « conserver selon les besoins » : elles laissent les vrais détails dans le vague.';

  @override
  String get learnUnclearPoliciesStep2 =>
      'Le silence n\'est pas une promesse : si une politique ne mentionne jamais le micro, la pub ou la localisation, cela ne garantit pas que l\'app les évite.';

  @override
  String get learnUnclearPoliciesStep3 =>
      'Bases manquantes : une politique fiable comporte une date d\'entrée en vigueur claire, une adresse e-mail de contact et un document unique, pas une annexe pour enfants cachée.';

  @override
  String get learnUnclearPoliciesStep4 =>
      'Consentement sous pression (interfaces trompeuses) : boutons géants « Tout accepter », cases marketing précochées, rappels insistants et parcours de résiliation difficiles à trouver sont conçus pour forcer votre choix.';

  @override
  String get learnUnclearPoliciesStep5 =>
      'Choix équilibré : un écran équitable affiche des boutons « Autoriser » et « Ne pas autoriser » égaux, avec les options facultatives décochées par défaut.';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      'Quelle phrase d\'une politique de confidentialité est un signe « flou » montrant qu\'il manque des détails ?';

  @override
  String get learnUnclearPoliciesQuizChoiceA =>
      'Nous ne vendons pas vos informations personnelles à des tiers';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      'Nous pouvons partager des données avec des partenaires de confiance à des fins commerciales';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'Vous pouvez demander la suppression en écrivant à privacy@example.com';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      'Exact : « pouvons partager avec des partenaires de confiance à des fins commerciales » est vague et ne précise ni qui sont ces partenaires ni quelles données sont partagées.';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      'Pas tout à fait : cette phrase est précise et utile. Les formules floues utilisent des tournures ouvertes comme « pouvons partager » ou « selon les besoins » sans donner de détails.';

  @override
  String get learnUnclearPoliciesDiagramClearTitle =>
      'Phrase claire de politique';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      'Nous collectons votre nom et votre e-mail pour créer votre compte. Nous ne partageons pas cela avec des annonceurs.';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle =>
      'Phrase floue de politique';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      'Nous pouvons partager vos informations avec des partenaires de confiance à des fins commerciales selon les besoins.';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle => 'Comment repérer le flou';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      'Cherchez « peut », « pourrait » ou « selon les besoins » : cela laisse la porte ouverte.';

  @override
  String get learnUnclearPoliciesDiagramTip2 =>
      'Vérifiez si la politique nomme les entreprises précises qui reçoivent les données.';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      'Le silence sur la publicité ou le micro ne promet pas que l\'app les évite.';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote =>
      'Le silence dans une politique n\'est pas une promesse.';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      'Comparaison côte à côte d\'une phrase claire et d\'une phrase floue de politique. La carte de gauche intitulée « Claire » montre : « Nous collectons votre nom et votre e-mail pour créer votre compte. Nous ne partageons pas cela avec des annonceurs. » La carte de droite intitulée « Floue » montre : « Nous pouvons partager vos informations avec des partenaires de confiance à des fins commerciales selon les besoins. » En dessous, une carte de conseils intitulée « Comment repérer le flou » donne trois conseils : cherchez « peut », « pourrait » ou « selon les besoins » car cela laisse la porte ouverte ; vérifiez si la politique nomme les entreprises précises qui reçoivent les données ; le silence sur la publicité ou le micro ne promet pas que l\'app les évite. Une note sur la carte floue indique « Le silence dans une politique n\'est pas une promesse. » Deni jette un œil au-dessus des cartes.';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      'Vérifiez une app sur ce téléphone pour examiner son écran de consentement et la clarté de sa politique.';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      'Cette leçon décrit des schémas flous courants. Elle ne prouve pas qu\'une app particulière utilise des interfaces trompeuses ou cache ses pratiques. Seules la lecture exacte de la politique et l\'observation du véritable écran de consentement peuvent le montrer.';

  @override
  String get learnSafeSharingFolderTitle => 'Réflexes de partage';

  @override
  String get learnSafeSharingTitle =>
      'Réflexes de partage prudent pour les enfants';

  @override
  String get learnSafeSharingSubtitle =>
      'Stop, Réfléchir, Partager : étapes adaptées à l\'âge pour partager en ligne';

  @override
  String get learnSafeSharingIntro1 =>
      'Avant de publier une photo, une vidéo, votre nom ou votre position, faites une pause et suivez trois étapes : Stop, Réfléchir, Partager. Cette leçon se lit avec un adulte de confiance. Les plus jeunes (5-7 ans) demandent avant de toucher l\'écran. Les enfants de 8-11 ans utilisent des pseudos et des mots de passe solides. Les ados (12-17 ans) gèrent leur empreinte numérique (la trace de ce qu\'ils publient) et l\'authentification à deux facteurs (une seconde vérification, comme un code, lors de la connexion).';

  @override
  String get learnSafeSharingStep1 =>
      'Stop : faites une pause avant de publier une photo, une vidéo, un nom, une école ou une position. Demandez à un adulte de confiance en cas de doute.';

  @override
  String get learnSafeSharingStep2 =>
      'Réfléchir : est-ce que cela révèle mon école, ma maison ou l\'endroit où je suis ? Ai-je demandé à mes amis avant de partager leurs photos ou de les identifier ?';

  @override
  String get learnSafeSharingStep3 =>
      'Partager : ne partagez qu\'avec des personnes de confiance. Gardez privés vos renseignements personnels comme votre nom complet, votre date de naissance, votre adresse et votre numéro de téléphone.';

  @override
  String get learnSafeSharingStep4 =>
      'Le test de la cantine : serais-je à l\'aise si toute l\'école (ou toute ma classe) voyait cette photo ou ce message ? Même les publications éphémères peuvent faire l\'objet d\'une capture d\'écran et rester en ligne pour toujours.';

  @override
  String get learnSafeSharingStep5 =>
      '5-7 ans : demandez à un adulte de confiance avant d\'écrire votre nom ou de toucher une fenêtre. 8-11 ans : utilisez un pseudo (pas votre vrai nom, date de naissance ni école), des mots de passe solides et ne partagez jamais de codes SMS ou OTP (codes à usage unique reçus par message : ne les partagez jamais). 12-17 ans : vérifiez les réglages de confidentialité, activez la double authentification et sachez signaler un problème.';

  @override
  String get learnSafeSharingQuizQuestion =>
      'Qu\'est-ce que le « test de la cantine » pour le partage en ligne ?';

  @override
  String get learnSafeSharingQuizChoiceA =>
      'Partager uniquement ce qu\'on mangerait à la cantine';

  @override
  String get learnSafeSharingQuizChoiceB =>
      'Se demander : serais-je à l\'aise si toute l\'école voyait cette photo ou ce message ?';

  @override
  String get learnSafeSharingQuizChoiceC =>
      'Partager uniquement pendant la pause déjeuner';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      'Exact : le test de la cantine consiste à se demander si vous seriez à l\'aise que tout le monde voie ce que vous publiez.';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      'Pas tout à fait : le test de la cantine est un réflexe mental : seriez-vous d\'accord si quelqu\'un montrait votre publication à toute la cantine ?';

  @override
  String get learnSafeSharingDiagramStop =>
      'Stop : faites une pause avant de publier';

  @override
  String get learnSafeSharingDiagramThink =>
      'Réfléchir : cela révèle-t-il où je suis ou avec qui ?';

  @override
  String get learnSafeSharingDiagramConnect =>
      'Partager : avec des proches de confiance, demandez à un adulte en cas de doute';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      'Le test de la cantine : serais-je à l\'aise si toute l\'école voyait cela ? Même les publications éphémères peuvent être capturées en écran et rester en ligne pour toujours.';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      'Schéma en quatre parties présentant des réflexes de partage prudent. Étape 1 : Stop : faites une pause avant de publier, avec icône de main. Étape 2 : Réfléchir : cela révèle-t-il où je suis ou avec qui ?, avec icône de cerveau. Étape 3 : Partager : avec des proches de confiance, demandez à un adulte en cas de doute, avec icône de groupe. Étape 4 : l\'encadré du test de la cantine demande « Serais-je à l\'aise si toute l\'école voyait cela ? Même les publications éphémères peuvent être capturées en écran et rester en ligne pour toujours. » Deni se tient à côté en levant la main.';

  @override
  String get learnSafeSharingCheckBridge =>
      'Vérifiez une app avec un parent pour voir comment elle gère le partage.';

  @override
  String get learnSafeSharingHonestyNote =>
      'Cette leçon partage des réflexes généraux de prudence. Elle ne garantit pas qu\'une app protège ce que vous partagez. Lisez toujours la politique de l\'app et utilisez les réglages de confidentialité de votre téléphone.';

  @override
  String get translationDraftNotice =>
      'Certaines traductions sont des ébauches générées par IA et peuvent contenir des erreurs. Des locuteurs natifs les relisent.';

  @override
  String get homeQuickSettingsTitle => 'Compagnon des Paramètres rapides';

  @override
  String get homeQuickSettingsSubtitle =>
      'Demandez à Deni à tout moment des infos sur l\'app que vous utilisez';

  @override
  String get appearanceSectionTitle => 'Apparence';

  @override
  String get themeModeSystem => 'Système';

  @override
  String get themeModeLight => 'Clair';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get quickSettingsSectionTitle =>
      'Connecter Enprive aux Paramètres rapides';

  @override
  String get quickSettingsSectionSubtitle =>
      'Ajoutez Enprive Check au panneau Paramètres rapides d\'Android pour interroger Deni sur vos applications sans quitter ce que vous faites.';

  @override
  String get quickSettingsTileTitle => 'Tuile Enprive Check';

  @override
  String get quickSettingsTileSubtitle =>
      'Ajoutez Enprive Check aux Paramètres rapides pour demander à Deni des infos sur l\'app en cours sans chercher Enprive d\'abord.';

  @override
  String get quickSettingsStatusAdded => 'Ajoutée';

  @override
  String get quickSettingsStatusManual => 'Manuel';

  @override
  String get quickSettingsStatusNotAdded => 'Non ajoutée';

  @override
  String get usageAccessStatusGranted => 'Autorisé';

  @override
  String get usageAccessStatusNotGranted => 'Non autorisé';

  @override
  String get usageAccessTitle =>
      'Autoriser l\'accès aux données d\'utilisation (facultatif)';

  @override
  String get usageAccessExplanation =>
      'Enprive utilise l\'accès aux données d\'utilisation uniquement lorsque vous appuyez sur Enprive Check afin d\'identifier l\'app que vous veniez d\'utiliser. Cela aide Deni à trouver la bonne app et ses informations de confidentialité. Enprive ne surveille pas votre écran en continu.';

  @override
  String get usageAccessManageLink => 'Comment gérer ou révoquer';

  @override
  String get usageAccessManageTitle =>
      'Gérer ou révoquer l\'accès aux données d\'utilisation';

  @override
  String get usageAccessManageBody =>
      'L\'accès aux données d\'utilisation est un réglage spécial d\'Android (pas une fenêtre automatique). Vous pouvez le désactiver à tout moment dans Paramètres Android -> Applications -> Accès spécial -> Accès aux données d\'utilisation -> enprive. Deni reste utilisable sans cet accès en choisissant l\'app manuellement.';

  @override
  String get openDeniCompanionTitle => 'Ouvrir le Compagnon Deni';

  @override
  String get openDeniCompanionSubtitle =>
      'Vérifier les autorisations d\'une app récente ou choisie sans Paramètres rapides.';

  @override
  String get btnGotIt => 'Compris';

  @override
  String get quickSettingsReadyDialogTitle =>
      'Enprive Check est prêt dans les Paramètres rapides';

  @override
  String get quickSettingsReadyDialogBody =>
      'Balayez deux fois vers le bas depuis le haut de l\'écran et appuyez sur « Enprive Check » dès que vous voulez que Deni explique les autorisations d\'une app.';

  @override
  String get quickSettingsManualDialogTitle =>
      'Ajouter Enprive Check manuellement';

  @override
  String get quickSettingsManualDialogBody =>
      '1. Balayez deux fois vers le bas depuis le haut de votre écran Android pour ouvrir les Paramètres rapides.\n2. Appuyez sur le bouton Modifier (crayon).\n3. Trouvez « Enprive Check » et glissez-le dans vos tuiles actives.';

  @override
  String get quickSettingsSnackAdded =>
      'Enprive Check a été ajouté à vos Paramètres rapides.';

  @override
  String get quickSettingsSnackAlreadyAdded =>
      'Enprive Check est déjà dans vos Paramètres rapides.';

  @override
  String get quickSettingsSnackDeclined =>
      'Demande ignorée. Enprive ne redemandera plus sauf si vous utilisez Modifier dans les Paramètres rapides.';

  @override
  String get quickSettingsSnackManual =>
      'Ouvrez les Paramètres rapides, appuyez sur Modifier et glissez Enprive Check dans vos tuiles.';

  @override
  String get quickSettingsSnackUnavailable =>
      'L\'invite système n\'est pas disponible ici ; vous pouvez glisser Enprive Check manuellement depuis Modifier dans les Paramètres rapides.';

  @override
  String get usageAccessOpenFailedSnack =>
      'Impossible d\'ouvrir les paramètres d\'accès aux données d\'utilisation sur cet appareil.';

  @override
  String get companionTitle => 'Deni : Compagnon Enprive';

  @override
  String get companionSubtitle =>
      'Interrogez Deni sur les autorisations d\'une app et sur ce que dit sa politique de confidentialité.';

  @override
  String get companionTooltipReturnToPrev => 'Revenir à l\'app précédente';

  @override
  String get companionTooltipBack => 'Retour';

  @override
  String get companionLockedBadge => 'PROTÉGÉ SUR ÉCRAN VERROUILLÉ';

  @override
  String get companionLockedTitle =>
      'Déverrouillez votre téléphone pour continuer';

  @override
  String get companionLockedBody =>
      'Enprive masque les noms d\'apps, les autorisations déclarées et les éléments de vérification tant que l\'appareil est verrouillé.';

  @override
  String get companionCheckUnlockBtn => 'Vérifier le déverrouillage';

  @override
  String get companionCheckingAppHeadline =>
      'Recherche de l\'app que vous utilisiez…';

  @override
  String get companionCheckingAppSubtitle =>
      'Vérification ponctuelle sur ce téléphone sans surveiller votre écran.';

  @override
  String get companionGeneralGuideHeadline =>
      'Guide général des autorisations Android';

  @override
  String get companionGeneralGuideSubtitle =>
      'Aucune app sélectionnée. Enprive explique les autorisations Android uniquement avec un guide local.';

  @override
  String companionLookingAtHeadline(String appName) {
    return 'Vous consultez $appName.';
  }

  @override
  String get companionLookingAtSubtitle =>
      'Les autorisations ci-dessous proviennent de l\'app sur votre téléphone : Android contrôle toujours la fenêtre affichée à l\'écran.';

  @override
  String get companionThisAppFallback => 'cette app';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return 'Nous avons vu $appName il y a $seconds s. Est-ce exact ?';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return 'Nous pensons que vous utilisez $appName. Est-ce exact ?';
  }

  @override
  String companionAppIdLine(String packageName) {
    return 'App ID : $packageName';
  }

  @override
  String companionConfirmAppBtn(String appName) {
    return 'Confirmer · $appName';
  }

  @override
  String get companionChooseAnotherAppBtn => 'Choisir une autre app';

  @override
  String get companionWithoutAppContextBtn => 'Sans app sélectionnée';

  @override
  String get companionMultipleAppsTitle =>
      'Plusieurs apps étaient actives à l\'instant';

  @override
  String get companionMultipleAppsPrompt =>
      'Confirmez l\'application que vous souhaitez examiner :';

  @override
  String companionSecondsAgo(int seconds) {
    return 'il y a $seconds s';
  }

  @override
  String get companionSelectAppTitle => 'Sélectionnez l\'app à vérifier';

  @override
  String get companionSelectAppBody =>
      'Choisissez l\'application manuellement parmi vos apps installées ou continuez sans contexte d\'app.';

  @override
  String get companionChooseAppManuallyBtn => 'Choisir l\'app manuellement';

  @override
  String get companionOpenUsageAccessBtn =>
      'Ouvrir l\'accès aux données d\'utilisation';

  @override
  String get companionContinueWithoutAppBtn => 'Continuer sans contexte d\'app';

  @override
  String get companionAddTileBtn => 'Ajouter la tuile Enprive Check';

  @override
  String get companionContinuingWithoutApp =>
      'Continuation sans contexte d\'app';

  @override
  String get companionSwitchAppBtn => 'Changer d\'app';

  @override
  String get companionPermissionsReadLocally =>
      'Les autorisations ci-dessous sont lues directement sur votre téléphone.';

  @override
  String get companionPickPermissionType =>
      'Choisissez un type d\'autorisation à explorer';

  @override
  String get companionPickAppBtn => 'Choisir une app';

  @override
  String get companionCouldNotReadPermsTitle =>
      'Impossible de lire les autorisations de l\'app';

  @override
  String get companionCouldNotReadPermsBody =>
      'Android a empêché l\'examen des autorisations de cette app.';

  @override
  String get companionUnsurePermBtn => 'Je ne sais pas quelle autorisation';

  @override
  String get companionWhichPermissionPrompt =>
      'Quelle autorisation souhaitez-vous comprendre ?';

  @override
  String get companionPermissionsListDisclaimer =>
      'Il s\'agit des autorisations déclarées par l\'app sur votre téléphone, pas nécessairement de la fenêtre affichée en ce moment.';

  @override
  String get companionNoSensitivePermsMsg =>
      'Cette app ne demande aucune autorisation sensible sur votre téléphone.';

  @override
  String get companionGuidedMatchTitle =>
      'Retrouvez ce que demandait la fenêtre à l\'écran';

  @override
  String get companionGuidedMatchSubtitle =>
      'Enprive ne peut pas lire directement votre fenêtre Android actuelle. Choisissez la formulation la plus proche de ce qui est apparu :';

  @override
  String get companionSection1Title => '1. Ce que signifie cette autorisation';

  @override
  String get companionSection2Title =>
      '2. Ce que l\'app demande sur votre téléphone';

  @override
  String get companionSection3Title =>
      '3. Ce que dit sa politique de confidentialité';

  @override
  String get companionSection4Title =>
      '4. Pourquoi cela peut concerner une fonction';

  @override
  String get companionSection4Fallback =>
      'Aucune explication vérifiée du développeur n\'a été trouvée pour cette fonction. Décrivez ci-dessous la fonction que vous vouliez utiliser si vous souhaitez que Deni vérifie le lien.';

  @override
  String get companionSection5Title => '5. Ce qui reste inconnu';

  @override
  String get companionSection6Title => '6. Questions à poser à Deni';

  @override
  String get companionAddPolicyBtn => 'Ajouter la politique de confidentialité';

  @override
  String get companionCheckUpdatedPolicyBtn =>
      'Vérifier une politique mise à jour';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return 'Vérifier la politique de $appName';
  }

  @override
  String get companionFeatureFieldLabel =>
      'Fonction que vous utilisiez (facultatif)';

  @override
  String get companionFeatureFieldHint =>
      'ex. : scanner un QR code, enregistrer un exercice vocal';

  @override
  String get companionQuestionFieldLabel => 'Poser une question à Deni';

  @override
  String get companionQuestionFieldHint =>
      'Que se passe-t-il si je refuse cette autorisation ?';

  @override
  String get companionReceiptSavedTitle => 'Enregistré dans les Reçus Enprive';

  @override
  String get companionReceiptUnsavedTitle =>
      'Vérification pas encore enregistrée';

  @override
  String get companionReceiptSavedBody =>
      'Stocké localement dans vos Reçus Enprive.';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      'Vérification mise à jour conservée uniquement pour cette session. Quitter le Compagnon supprime ce brouillon sans modifier votre reçu enregistré.';

  @override
  String get companionReceiptUnsavedBody =>
      'Conservé uniquement pour cette session. Quitter le Compagnon l\'effacera si vous ne l\'enregistrez pas.';

  @override
  String get companionSaveReceiptBtn => 'Enregistrer le reçu dans Enprive';

  @override
  String get companionSaveReceiptFailed =>
      'Impossible d\'enregistrer le reçu. Conservé dans cette session : réessayez.';

  @override
  String get companionSavedLocalReceiptsSnack =>
      'Enregistré dans les Reçus locaux.';

  @override
  String companionDoneReturnToApp(String appName) {
    return 'Terminé · Revenir à $appName';
  }

  @override
  String get companionDoneReturnToPrev =>
      'Terminé · Revenir à l\'app précédente';

  @override
  String get companionOpenFullAppBtn => 'Ouvrir toute l\'app Enprive';

  @override
  String get companionCloudTimeoutSnack =>
      'L\'analyse dans le cloud a pris trop de temps et s\'est arrêtée avant la fin.';

  @override
  String get companionAnalysisCancelledSnack => 'Analyse annulée.';

  @override
  String get companionCloudAnswerTimeoutSnack =>
      'La réponse du cloud a expiré proprement.';

  @override
  String get companionQuestionCancelledSnack => 'Question annulée.';

  @override
  String get companionTileAddedSnack =>
      'Enprive Check a été ajouté aux Paramètres rapides d\'Android.';

  @override
  String get companionTileAlreadyAddedSnack =>
      'Enprive Check est déjà dans vos Paramètres rapides.';

  @override
  String get companionTileDeclinedSnack =>
      'Demande ignorée. Vous pouvez l\'ajouter à tout moment depuis Paramètres ou Modifier dans les Paramètres rapides.';

  @override
  String get companionTileManualSnack =>
      'Balayez les Paramètres rapides deux fois, appuyez sur Modifier et glissez Enprive Check dans vos tuiles.';

  @override
  String get companionTileUnavailableSnack =>
      'Android n\'a pas pu afficher l\'invite des Paramètres rapides sur cet appareil. Vous pouvez glisser Enprive Check manuellement depuis Modifier.';

  @override
  String get companionUsageOptionalReason =>
      'L\'accès aux données d\'utilisation est facultatif. Vous pouvez choisir une app manuellement ou autoriser cet accès pour l\'identifier en un geste.';

  @override
  String get companionPermPreciseLocation => 'Position précise';

  @override
  String get companionPermBackgroundLocation => 'Position en arrière-plan';

  @override
  String get companionPermCamera => 'Appareil photo';

  @override
  String get companionPermMicrophone => 'Microphone';

  @override
  String get companionPermAdId => 'Identifiant publicitaire Google';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return 'Autorisation Android ($permission) déclarée par $appName.';
  }

  @override
  String get companionPermStatusAdId => 'Déclarée par l\'app · ID pub';

  @override
  String get companionPermStatusAllowed => 'Déclarée par l\'app · Autorisée';

  @override
  String get companionPermStatusNotAllowed =>
      'Déclarée par l\'app · Non autorisée';

  @override
  String get guidedCatLocation => 'Position';

  @override
  String get guidedCatContacts => 'Contacts';

  @override
  String get guidedCatPhotosMedia => 'Photos et médias';

  @override
  String get guidedCatNotifications => 'Notifications';

  @override
  String get guidedCatNearbyDevices => 'Appareils à proximité';

  @override
  String get guidedCatCalendar => 'Calendrier';

  @override
  String get guidedCatPhone => 'Téléphone';

  @override
  String get guidedCatSms => 'SMS';

  @override
  String get companionFallbackUsageNotEnabled =>
      'L\'accès aux données d\'utilisation n\'a pas été activé dans les Paramètres Android.';

  @override
  String get companionFallbackUsageUnavailable =>
      'Android UsageStatsManager n\'est pas disponible.';

  @override
  String get companionFallbackTransientUi =>
      'Seule l\'interface système Android ou une fenêtre d\'autorisation est apparue récemment ; choisissez l\'app manuellement.';

  @override
  String get companionFallbackVisibilityRestricted =>
      'L\'app active la plus récente ne peut pas être examinée en raison des restrictions de visibilité Android. Choisissez une app dans la liste ou collez sa politique.';

  @override
  String get companionFallbackUnlockRequired =>
      'Déverrouillez votre appareil avant d\'afficher le contexte de l\'app.';

  @override
  String get consentReasonPolicyTooDetailed =>
      'Cette politique est trop longue pour être traitée par l\'IA sur cet appareil.';

  @override
  String get consentReasonExcerptTooDetailed =>
      'Cet extrait est trop long pour être traité par l\'IA sur cet appareil.';

  @override
  String get consentReasonOnDeviceUnavailable =>
      'L\'IA sur l\'appareil n\'est pas disponible sur ce téléphone pour le moment.';

  @override
  String get consentReasonOnDeviceCannotAnswer =>
      'L\'IA sur l\'appareil n\'a pas pu répondre depuis ce téléphone pour le moment.';

  @override
  String get consentReasonVoiceTooLong =>
      'Ces éléments vérifiés dépassent la limite du résumé sur l\'appareil. Vous pouvez utiliser le résumé hors ligne maintenant ou envoyer les éléments masqués à l\'IA cloud une fois.';

  @override
  String get consentReasonVoiceUnavailable =>
      'L\'IA sur l\'appareil n\'est pas disponible pour le moment. Affichage du résumé simple hors ligne d\'Enprive.';

  @override
  String get consentReasonVoiceTimedOut =>
      'Le résumé sur l\'appareil a expiré. Affichage du résumé simple hors ligne d\'Enprive.';

  @override
  String get unsavedExitTitle =>
      'Enregistrer cette vérification de confidentialité ?';

  @override
  String get unsavedExitModifiedBody =>
      'Les vérifications non enregistrées sont supprimées lorsque vous fermez cet écran, afin que rien ne soit stocké sur votre téléphone sans votre choix. Votre reçu enregistré d\'origine reste inchangé.';

  @override
  String get unsavedExitDraftBody =>
      'Les vérifications non enregistrées sont supprimées lorsque vous fermez cet écran, afin que rien ne soit stocké sur votre téléphone sans votre choix.';

  @override
  String get unsavedExitDiscardBtn => 'Quitter sans enregistrer';

  @override
  String get unsavedExitContinueBtn => 'Continuer la vérification';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return 'Mettre à jour la politique de $title';
  }

  @override
  String get reviewSaveFailedError =>
      'Impossible d\'enregistrer le reçu. Votre brouillon reste ouvert.';

  @override
  String get reviewRemovedFromReceiptsSnack =>
      'Supprimé des reçus enregistrés.';

  @override
  String get reviewRemoveFailedSnack =>
      'Impossible de supprimer le reçu enregistré.';

  @override
  String get reviewModifiedDraftTitle =>
      'Nouveau brouillon d\'un reçu enregistré';

  @override
  String get reviewModifiedDraftBody =>
      'Enregistrez dans Reçus pour conserver cette vérification mise à jour : votre reçu enregistré d\'origine reste inchangé.';

  @override
  String get btnRetrySave => 'Réessayer l\'enregistrement';

  @override
  String samplePermissionsHeader(String badge) {
    return 'Autorisations d\'exemple ($badge)';
  }

  @override
  String get sourceKindUrl => 'Lien web public';

  @override
  String get sourceKindPdf => 'Fichier PDF local';

  @override
  String get sourceKindDocx => 'Fichier Word (DOCX) local';

  @override
  String get sourceKindTextFile => 'Fichier texte local';

  @override
  String get sourceKindSharedText => 'Texte partagé';

  @override
  String get sourceKindSelectedText => 'Texte sélectionné';

  @override
  String get sourceKindSampleApp => 'App d\'exemple';

  @override
  String get sourceKindPhonePermissions => 'Autorisations du téléphone';

  @override
  String get sourceKindPastedText => 'Texte collé';

  @override
  String get extractionStatusExtracted => 'Lu sur ce téléphone';

  @override
  String get extractionStatusNone => 'Fourni sur ce téléphone';

  @override
  String get extractionStatusUnsupported =>
      'Type de fichier non pris en charge';

  @override
  String get extractionStatusTooLarge => 'Fichier trop volumineux';

  @override
  String get extractionStatusEmpty => 'Aucun texte lisible';

  @override
  String get extractionStatusReadError => 'Impossible de lire le fichier';

  @override
  String get extractionStatusPasswordProtected => 'Protégé par mot de passe';

  @override
  String get extractionStatusPermissionDenied => 'Autorisation refusée';

  @override
  String get extractionStatusCancelled => 'Annulé';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return 'Vérifié le : $timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return 'URL canonique : $url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return 'Redirigé depuis : $url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return 'Fichier : $filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return 'État : $status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return 'Empreinte source SHA-256 : $hash';
  }

  @override
  String get semanticsPrimaryNavigation => 'Navigation principale';

  @override
  String semanticsProcessingLocation(String label) {
    return 'Lieu de traitement : $label';
  }

  @override
  String get semanticsDeniMascot => 'Deni, votre guide de confidentialité';

  @override
  String get quoteCollapsibleDefaultHeader => 'Extrait exact de la politique';
}
