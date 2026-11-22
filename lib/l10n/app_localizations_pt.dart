// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => 'Análises de privacidade baseadas em evidências';

  @override
  String get homePrivacySubtitle => 'Suas análises permanecem neste telefone.';

  @override
  String get stateNoConcern => 'Nenhuma preocupação identificada';

  @override
  String get stateNoConcernSubtitle =>
      'Nada preocupante nas evidências analisadas. Isto não é uma certificação de segurança.';

  @override
  String get stateReviewRecommended => 'Revisão recomendada';

  @override
  String get stateReviewRecommendedSubtitle =>
      'One or more policy parts or phone permissions need a closer look.';

  @override
  String get stateInsufficientEvidence => 'Evidências insuficientes';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'We need more privacy policy text before we can check what this app does.';

  @override
  String get chipOnDevice => 'Neste dispositivo';

  @override
  String get chipInCloud => 'Na nuvem';

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
  String get btnCheckApp => 'Verificar um app';

  @override
  String get btnPasteTerms => 'Colar termos ou URL';

  @override
  String get btnWhyThisFinding => 'Por que este achado?';

  @override
  String get btnSaveToReceipts => 'Salvar em Recibos';

  @override
  String get btnDiscard => 'Descartar';

  @override
  String get btnAskDeni => 'Perguntar ao Deni';

  @override
  String get btnUseCloud => 'Usar nuvem nesta verificação';

  @override
  String get btnReviewManually => 'Revisar manualmente';

  @override
  String get btnGetStarted => 'Começar';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get deniIntro =>
      'Oi, eu sou o Deni. Posso ajudar você a entender o que esta política de privacidade diz, mostrar as evidências exatas e explicar o que o Enprive não pôde verificar.';

  @override
  String get cloudConsentDisclosure =>
      'To check this in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Your phone shows whether this permission is allowed. It does not prove whether the app actually accessed or sent data.';

  @override
  String get navHome => 'Início';

  @override
  String get navCheck => 'Verificar';

  @override
  String get navReceipts => 'Recibos';

  @override
  String get navLearn => 'Aprender';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get chooseLanguage => 'Escolher idioma';

  @override
  String get languageSubtitle =>
      'Aplica-se à interface, às explicações e à leitura em voz alta';

  @override
  String get homeHeroHeadline =>
      'Uma visão mais clara dos\napps que as crianças usam';

  @override
  String get trySampleCheck => 'Testar uma análise de exemplo';

  @override
  String get eduTrackSubtitle => 'Tarefas e frequência';

  @override
  String get eduTrackValue => '3 solicitações';

  @override
  String get eduTrackTrend => 'Revisar';

  @override
  String get calmMathSubtitle => 'Prática de matemática offline';

  @override
  String get calmMathValue => '0 sensíveis';

  @override
  String get calmMathTrend => 'Mínimo';

  @override
  String get whatWeCheckTitle => 'O que verificamos';

  @override
  String get checkQuoteTitle => 'Citações exatas da política';

  @override
  String get checkQuoteDesc =>
      'Highlights data sharing, voice recording, and how long data is kept using exact quotes.';

  @override
  String get checkPermissionTitle => 'Divergências de permissões';

  @override
  String get checkPermissionDesc =>
      'Compara o acesso à Câmera, Microfone e Localização com o que a política afirma.';

  @override
  String get checkSelectTitle => 'Selecione texto em qualquer lugar';

  @override
  String get checkSelectDesc =>
      'Destaque termos em qualquer app e toque em Enprive Check no menu do Android.';

  @override
  String get recentlyReviewed => 'Analisados recentemente';

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
  String get trySampleText => 'Testar texto de exemplo';

  @override
  String get modePasteText => 'Colar texto';

  @override
  String get modePolicyLink => 'Link da política';

  @override
  String get hintAppName => 'Nome do app';

  @override
  String get defaultSubjectTitle => 'Política de privacidade';

  @override
  String get selectedExcerptTitle => 'Trecho da política selecionado';

  @override
  String get hintPastePolicy => 'Cole o texto da política de privacidade aqui…';

  @override
  String get btnReviewOnPhone => 'Analisar neste telefone';

  @override
  String get onboardingIntroHeadline => 'Oi, eu sou o Deni. 👋';

  @override
  String get onboardingIntroLead =>
      'Vamos tornar a privacidade dos apps mais fácil de entender.';

  @override
  String get onboardingIntroBody =>
      'Vou ajudar você a descobrir o que a política de privacidade de um app realmente diz, destacar os trechos exatos que importam e explicar o que o seu dispositivo informa.\n\nSem achismos. Sem falsas promessas. Apenas explicações claras e evidências para ajudar você a tomar decisões informadas.';

  @override
  String get onboardingIntroFooter =>
      'Saiba exatamente com o que você está concordando.';

  @override
  String get splashQuote => 'Saiba exatamente com o que você está concordando';

  @override
  String get onboardingStep1Question =>
      'Como devo explicar os\ntermos de privacidade?';

  @override
  String get depthQuickMultiline => 'Rápido e\ndireto';

  @override
  String get depthBalancedMultiline => 'Visão\nequilibrada';

  @override
  String get depthFullMultiline => 'Detalhes\ncompletos';

  @override
  String get onboardingReadinessTitle => 'Privado por padrão\nneste telefone';

  @override
  String get onboardingReadinessSubtitle =>
      'Criado para que pais e professores inspecionem apps sem compartilhar dados do dispositivo.';

  @override
  String get readinessRow1Title => 'Verificado aqui primeiro';

  @override
  String get readinessRow1Desc =>
      'As políticas são lidas primeiro no seu telefone antes de qualquer coisa.';

  @override
  String get readinessRow2Title => 'Seus apps ficam com você';

  @override
  String get readinessRow2Desc =>
      'Os aplicativos neste telefone e suas permissões nunca saem dele.';

  @override
  String get readinessRow3Title => 'Personal details hidden';

  @override
  String get readinessRow3Desc =>
      'If you choose cloud help, names, emails, and phone numbers are hidden before anything is sent.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get privateAnalysisTitle => 'Análise privada neste telefone';

  @override
  String get onDeviceReadyMsg => 'A IA no dispositivo está ativa e pronta.';

  @override
  String get localScannerProtectedMsg =>
      'Ready to check policies offline on this phone.';

  @override
  String get statusChecking => 'Verificando…';

  @override
  String get btnCheckReadiness => 'Verificar disponibilidade';

  @override
  String get howShouldDeniExplain => 'Como o Deni deve explicar?';

  @override
  String get depthQuick => 'Rápido';

  @override
  String get depthBalanced => 'Equilibrado';

  @override
  String get depthFull => 'Detalhado';

  @override
  String get preferencesSection => 'Preferências';

  @override
  String get meetDeniGuide => 'Conheça o Deni e o guia';

  @override
  String clearSavedReceiptsCount(int count) {
    return 'Limpar recibos salvos ($count)';
  }

  @override
  String get btnClear => 'Limpar';

  @override
  String get confirmClearReceiptsTitle => 'Limpar recibos salvos?';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Isso remove $count análises salvas do seu telefone.',
      one: 'Isso remove 1 análise salva do seu telefone.',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get receiptsTitle => 'Recibos';

  @override
  String get tooltipSearch => 'Pesquisar';

  @override
  String get hintSearchReceipts => 'Pesquisar análises salvas...';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterReview => 'Revisar';

  @override
  String get filterNoConcern => 'Sem alerta';

  @override
  String get emptyFilteredTitle => 'Nenhum recibo correspondente';

  @override
  String get emptyReceiptsTitle => 'Nenhum recibo salvo ainda';

  @override
  String get emptyFilteredBody => 'Tente selecionar outro filtro acima.';

  @override
  String get emptyReceiptsBody =>
      'Marque qualquer análise de app para manter uma cópia privada no seu telefone.';

  @override
  String get btnStartReview => 'Iniciar análise';

  @override
  String get btnOpenReceipt => 'Abrir recibo';

  @override
  String get btnDelete => 'Excluir';

  @override
  String get checkingPhoneReadiness =>
      'Verificando a disponibilidade de análise privada neste telefone…';

  @override
  String get geminiNanoReadyMsg =>
      'On-device AI is ready on this phone. Reviews stay completely on your device.';

  @override
  String get modelDownloadingMsg =>
      'Baixando o modelo privado no dispositivo em segundo plano.';

  @override
  String get modelDownloadableMsg =>
      'O modelo no dispositivo pode ser baixado por Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'This phone checks policies offline on your device by default.';

  @override
  String get preparingPrivateAnalysis => 'Preparando análise privada…';

  @override
  String get onDeviceAiReadyTitle => 'IA no dispositivo pronta';

  @override
  String get localScannerActiveTitle => 'Offline check ready';

  @override
  String get privateAnalysisSheetSubtitle =>
      'Seus apps instalados e verificações de permissão nunca saem do telefone.';

  @override
  String get btnDone => 'Concluído';

  @override
  String get btnCheckAgain => 'Verificar novamente';

  @override
  String get reviewingOnPhone => 'Analisando neste telefone…';

  @override
  String get readingClausesInitial => 'Reading policy text on this phone…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current de $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etapas',
      one: '1 etapa',
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
  String get analysisTraceDefaultTitle => 'Como esta análise foi verificada';

  @override
  String get savedToLocalReceiptsSnack => 'Salvo nos seus recibos locais.';

  @override
  String get snapshotSheetTitle => 'Reviewed policy text';

  @override
  String get snapshotSourcePrefix => 'Fonte';

  @override
  String get snapshotReviewedPrefix => 'Analisado';

  @override
  String get snapshotDigestPrefix => 'Document fingerprint';

  @override
  String get statFindings => 'Achados';

  @override
  String get statVerified => 'Verificados';

  @override
  String get statOsGranted => 'Allowed on phone';

  @override
  String get statUnverified => 'Not found';

  @override
  String get keyFindingsTitle => 'Principais achados';

  @override
  String get reviewedExcerptTitle => 'Trecho analisado';

  @override
  String get permissionsOnPhoneTitle => 'Permissões neste telefone';

  @override
  String get viewReviewedSnapshot => 'View reviewed policy text';

  @override
  String get btnSavedToReceipts => 'Salvo em Recibos';

  @override
  String get observedOnPhoneLabel => 'Seen on this phone';

  @override
  String get quoteVerifiedLabel => 'Exact quote from policy';

  @override
  String get unverifiedClaimLabel => 'Not found in policy';

  @override
  String get categoryDataCollection => 'Coleta de dados';

  @override
  String get categorySharing => 'Compartilhamento com terceiros';

  @override
  String get categoryTracking => 'Localização e rastreamento';

  @override
  String get categoryRetention => 'Retenção e voz';

  @override
  String get categoryParentalControls => 'Controles parentais';

  @override
  String get labelInPlainLanguage => 'Em linguagem simples';

  @override
  String get labelOnThisPhone => 'Neste telefone';

  @override
  String get labelWhatRemainsUnknown => 'What we still don\'t know';

  @override
  String get presetQuestionMeaning => 'O que isso significa para meu filho?';

  @override
  String get presetQuestionOptOut => 'Podemos desativar ou recusar isso?';

  @override
  String get presetQuestionUnknown => 'O que ainda não está claro aqui?';

  @override
  String get readingCitedClause => 'Reading the policy quote…';

  @override
  String get deniAnswerTitle => 'Resposta do Deni';

  @override
  String get stepsAndReasoning => 'How Deni checked this';

  @override
  String get chooseReviewModeTitle => 'Escolha como analisar este texto';

  @override
  String get cloudNeverSendsAppsNote =>
      'Aplicativos instalados e permissões do telefone nunca são enviados.';

  @override
  String get tooltipClose => 'Fechar';

  @override
  String get checkAppSheetSubtitle =>
      'Verificado localmente no seu telefone. Sua lista de apps nunca é enviada.';

  @override
  String get trySampleKidsApp => 'Testar um app infantil de exemplo';

  @override
  String get sampleEduTrackSubtitle => 'Localização, microfone e câmera';

  @override
  String get sampleCalmMathSubtitle => 'Matemática offline';

  @override
  String get appsOnThisPhone => 'Apps neste telefone';

  @override
  String get hintSearchApps => 'Buscar apps…';

  @override
  String get noMatchingApps =>
      'Nenhum app correspondente encontrado neste telefone.';

  @override
  String get sampleSyntheticBadge => 'Sample app';

  @override
  String get permissionInspectionTitle => 'Phone permissions checked';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Adicionar política de privacidade deste app';

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
      'Verificando política com IA na nuvem.';

  @override
  String get preparingCloudAiStream =>
      'Hiding personal details before cloud check…';

  @override
  String get cancellingAnalysis => 'Cancelando…';

  @override
  String get analysisCancelledNotice => 'Análise cancelada.';

  @override
  String get cloudTimedOutNotice =>
      'A IA na nuvem atingiu o tempo limite antes de responder. Nenhuma nova tentativa automática foi enviada.';

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
