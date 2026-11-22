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
      'One or more policy parts or phone permissions need a closer look.';

  @override
  String get stateInsufficientEvidence => 'Preuves insuffisantes';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'We need more privacy policy text before we can check what this app does.';

  @override
  String get chipOnDevice => 'Sur cet appareil';

  @override
  String get chipInCloud => 'Dans le cloud';

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
      'To check this in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Your phone shows whether this permission is allowed. It does not prove whether the app actually accessed or sent data.';

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
      'Highlights data sharing, voice recording, and how long data is kept using exact quotes.';

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
      other: '$count matched quotes',
      one: '1 matched quote',
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
  String get readinessRow3Title => 'Personal details hidden';

  @override
  String get readinessRow3Desc =>
      'If you choose cloud help, names, emails, and phone numbers are hidden before anything is sent.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get privateAnalysisTitle => 'Analyse privée sur ce téléphone';

  @override
  String get onDeviceReadyMsg => 'L\'IA sur l\'appareil est active et prête.';

  @override
  String get localScannerProtectedMsg =>
      'Ready to check policies offline on this phone.';

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
      'On-device AI is ready on this phone. Reviews stay completely on your device.';

  @override
  String get modelDownloadingMsg =>
      'Téléchargement du modèle privé en arrière-plan.';

  @override
  String get modelDownloadableMsg =>
      'Le modèle local peut être téléchargé via Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'This phone checks policies offline on your device by default.';

  @override
  String get preparingPrivateAnalysis => 'Préparation de l\'analyse privée…';

  @override
  String get onDeviceAiReadyTitle => 'IA locale prête';

  @override
  String get localScannerActiveTitle => 'Offline check ready';

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
  String get readingClausesInitial => 'Reading policy text on this phone…';

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
  String get thoughtSignaturePrefix => 'Check ID';

  @override
  String get viewStreamedThoughts => 'How Enprive checked this';

  @override
  String get hideStreamedThoughts => 'Hide how Enprive checked this';

  @override
  String get analysisTraceDefaultTitle => 'Comment ce contrôle a été vérifié';

  @override
  String get savedToLocalReceiptsSnack => 'Enregistré dans vos reçus locaux.';

  @override
  String get snapshotSheetTitle => 'Reviewed policy text';

  @override
  String get snapshotSourcePrefix => 'Source';

  @override
  String get snapshotReviewedPrefix => 'Examiné';

  @override
  String get snapshotDigestPrefix => 'Document fingerprint';

  @override
  String get statFindings => 'Points relevés';

  @override
  String get statVerified => 'Vérifiés';

  @override
  String get statOsGranted => 'Allowed on phone';

  @override
  String get statUnverified => 'Not found';

  @override
  String get keyFindingsTitle => 'Points clés relevés';

  @override
  String get reviewedExcerptTitle => 'Extrait examiné';

  @override
  String get permissionsOnPhoneTitle => 'Autorisations sur ce téléphone';

  @override
  String get viewReviewedSnapshot => 'View reviewed policy text';

  @override
  String get btnSavedToReceipts => 'Enregistré dans Reçus';

  @override
  String get observedOnPhoneLabel => 'Seen on this phone';

  @override
  String get quoteVerifiedLabel => 'Exact quote from policy';

  @override
  String get unverifiedClaimLabel => 'Not found in policy';

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
  String get labelWhatRemainsUnknown => 'What we still don\'t know';

  @override
  String get presetQuestionMeaning =>
      'Qu\'est-ce que cela implique pour mon enfant ?';

  @override
  String get presetQuestionOptOut => 'Peut-on désactiver ou refuser cela ?';

  @override
  String get presetQuestionUnknown => 'Qu\'est-ce qui reste flou ici ?';

  @override
  String get readingCitedClause => 'Reading the policy quote…';

  @override
  String get deniAnswerTitle => 'Réponse de Deni';

  @override
  String get stepsAndReasoning => 'How Deni checked this';

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
  String get sampleSyntheticBadge => 'Sample app';

  @override
  String get permissionInspectionTitle => 'Phone permissions checked';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Ajouter la politique de confidentialité de cette app';

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
      'Vérification de la politique avec l’IA cloud.';

  @override
  String get preparingCloudAiStream =>
      'Hiding personal details before cloud check…';

  @override
  String get cancellingAnalysis => 'Annulation…';

  @override
  String get analysisCancelledNotice => 'Analyse annulée.';

  @override
  String get cloudTimedOutNotice =>
      'L’IA cloud n’a pas répondu à temps. Aucune nouvelle tentative automatique n’a été lancée.';

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
