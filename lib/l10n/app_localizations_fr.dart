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
      'Rien de préoccupant dans les preuves examinées. Ceci n\'est pas une certification de sécurité.';

  @override
  String get stateReviewRecommended => 'Vérification recommandée';

  @override
  String get stateReviewRecommendedSubtitle =>
      'Un ou plusieurs passages ou écarts d\'autorisations méritent un examen attentif.';

  @override
  String get stateInsufficientEvidence => 'Preuves insuffisantes';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Les preuves manquent, sont indisponibles ou n\'ont pas pu être vérifiées sur cet appareil.';

  @override
  String get chipOnDevice => 'Sur cet appareil';

  @override
  String get chipInCloud => 'Dans le cloud';

  @override
  String get chipLocationUnavailable => 'Lieu de traitement indisponible';

  @override
  String get statusSourceMatched => 'Extrait vérifié';

  @override
  String get statusDeviceObserved => 'Observé sur l\'appareil';

  @override
  String get statusInterpretation => 'Interprétation';

  @override
  String get statusUnverified => 'Non vérifié';

  @override
  String get statusStale => 'Obsolète';

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
      'Pour analyser ce texte dans le cloud, Enprive enverra uniquement le texte ci-dessous à Firebase AI Logic. Votre liste d\'applications installées et les autorisations Android ne seront jamais transmises.';

  @override
  String get permissionLimitationNotice =>
      'Android indique cet état d\'autorisation sur ce téléphone. Cela ne prouve pas si l\'application a réellement accédé aux données ou les a transmises.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navReceipts => 'Reçus';

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
      'Signale le partage, l\'enregistrement vocal et la conservation avec extraits exacts.';

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
      other: '$count clauses vérifiées',
      one: '1 clause vérifiée',
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
      'Si l\'IA locale est indisponible ou si le texte est long, noms, e-mails et numéros sont masqués avant la vérification App Check.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get privateAnalysisTitle => 'Analyse privée sur ce téléphone';

  @override
  String get onDeviceReadyMsg => 'L\'IA sur l\'appareil est active et prête.';

  @override
  String get localScannerProtectedMsg =>
      'Protégé par l\'analyseur local intégré.';

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
      'Gemini Nano est prêt sur ce téléphone. Les analyses restent entièrement locales.';

  @override
  String get modelDownloadingMsg =>
      'Téléchargement du modèle privé en arrière-plan.';

  @override
  String get modelDownloadableMsg =>
      'Le modèle local peut être téléchargé via Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'Ce téléphone utilise par défaut l\'analyseur local de clauses intégré d\'Enprive.';

  @override
  String get preparingPrivateAnalysis => 'Préparation de l\'analyse privée…';

  @override
  String get onDeviceAiReadyTitle => 'IA locale prête';

  @override
  String get localScannerActiveTitle => 'Analyseur local actif';

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
  String get readingClausesInitial => 'Lecture des clauses sur ce téléphone…';

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
  String get thoughtSignaturePrefix => 'Signature de raisonnement';

  @override
  String get viewStreamedThoughts => 'Afficher le raisonnement';

  @override
  String get hideStreamedThoughts => 'Masquer le raisonnement';

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
  String get snapshotDigestPrefix => 'Empreinte';

  @override
  String get statFindings => 'Points relevés';

  @override
  String get statVerified => 'Vérifiés';

  @override
  String get statOsGranted => 'Accordées OS';

  @override
  String get statUnverified => 'Non vérifiés';

  @override
  String get keyFindingsTitle => 'Points clés relevés';

  @override
  String get reviewedExcerptTitle => 'Extrait examiné';

  @override
  String get permissionsOnPhoneTitle => 'Autorisations sur ce téléphone';

  @override
  String get viewReviewedSnapshot => 'Voir le texte examiné complet';

  @override
  String get btnSavedToReceipts => 'Enregistré dans Reçus';

  @override
  String get observedOnPhoneLabel => 'Observé sur ce téléphone';

  @override
  String get quoteVerifiedLabel => 'Citation vérifiée dans la politique';

  @override
  String get unverifiedClaimLabel => 'Mention non vérifiée';

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
  String get labelWhatRemainsUnknown => 'Ce qui reste inconnu';

  @override
  String get presetQuestionMeaning =>
      'Qu\'est-ce que cela implique pour mon enfant ?';

  @override
  String get presetQuestionOptOut => 'Peut-on désactiver ou refuser cela ?';

  @override
  String get presetQuestionUnknown => 'Qu\'est-ce qui reste flou ici ?';

  @override
  String get readingCitedClause => 'Lecture de la clause citée…';

  @override
  String get deniAnswerTitle => 'Réponse de Deni';

  @override
  String get stepsAndReasoning => 'Étapes et raisonnement du modèle';

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
}
