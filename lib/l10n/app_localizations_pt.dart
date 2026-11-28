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
      'Uma ou mais partes da política ou permissões do telefone merecem um olhar mais atento.';

  @override
  String get stateInsufficientEvidence => 'Evidências insuficientes';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Precisamos de mais texto da política de privacidade antes de verificar o que este app faz.';

  @override
  String get chipOnDevice => 'Neste dispositivo';

  @override
  String get chipInCloud => 'Na nuvem';

  @override
  String get chipLocationUnavailable => 'Fonte indisponível';

  @override
  String get chipOfflineDeterministic => 'Verificado offline neste telefone';

  @override
  String get chipUnknown => 'Fonte desconhecida';

  @override
  String get statusSourceMatched => 'Encontrado na política';

  @override
  String get statusDeviceObserved => 'Visto neste telefone';

  @override
  String get statusInterpretation => 'Explicação do Deni';

  @override
  String get statusUnverified => 'Não encontrado na política';

  @override
  String get statusStale => 'Verificação anterior';

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
      'Para verificar isso na nuvem, o Enprive enviará apenas o texto mostrado acima (com dados pessoais ocultos) para esta única solicitação. Seus apps e permissões do telefone nunca serão enviados.';

  @override
  String get permissionLimitationNotice =>
      'Seu telefone mostra se esta permissão está permitida. Isso não prova se o app realmente acessou ou enviou dados.';

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
  String get whatWeCheckTitle => 'O que verificamos';

  @override
  String get checkQuoteTitle => 'Citações exatas da política';

  @override
  String get checkQuoteDesc =>
      'Destaca compartilhamento de dados, gravação de voz e por quanto tempo os dados ficam guardados usando citações exatas.';

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
      other: '$count citações correspondentes',
      one: '1 citação correspondente',
    );
    return '$_temp0';
  }

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
  String get readinessRow3Title => 'Dados pessoais ocultos';

  @override
  String get readinessRow3Desc =>
      'Se você escolher ajuda na nuvem, nomes, e-mails e números de telefone são ocultados antes de qualquer envio.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get privateAnalysisTitle => 'Análise privada neste telefone';

  @override
  String get onDeviceReadyMsg => 'A IA no dispositivo está ativa e pronta.';

  @override
  String get localScannerProtectedMsg =>
      'Pronto para verificar políticas offline neste telefone.';

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
      'A IA no dispositivo está pronta neste telefone. As análises ficam completamente no seu aparelho.';

  @override
  String get modelDownloadingMsg =>
      'Baixando o modelo privado no dispositivo em segundo plano.';

  @override
  String get modelDownloadableMsg =>
      'O modelo no dispositivo pode ser baixado por Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'Este telefone verifica políticas offline no seu dispositivo por padrão.';

  @override
  String get preparingPrivateAnalysis => 'Preparando análise privada…';

  @override
  String get onDeviceAiReadyTitle => 'IA no dispositivo pronta';

  @override
  String get localScannerActiveTitle => 'Verificação offline pronta';

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
  String get readingClausesInitial =>
      'Lendo o texto da política neste telefone…';

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
  String get thoughtSignaturePrefix => 'ID da verificação';

  @override
  String get viewStreamedThoughts => 'Como o Enprive verificou isso';

  @override
  String get hideStreamedThoughts => 'Ocultar como o Enprive verificou isso';

  @override
  String get analysisTraceDefaultTitle => 'Como esta análise foi verificada';

  @override
  String get savedToLocalReceiptsSnack => 'Salvo nos seus recibos locais.';

  @override
  String get snapshotSheetTitle => 'Texto da política analisada';

  @override
  String get snapshotSourcePrefix => 'Fonte';

  @override
  String get snapshotReviewedPrefix => 'Analisado';

  @override
  String get snapshotDigestPrefix => 'Impressão digital do documento';

  @override
  String get statFindings => 'Achados';

  @override
  String get statVerified => 'Verificados';

  @override
  String get statOsGranted => 'Permitido no telefone';

  @override
  String get statUnverified => 'Não encontrado';

  @override
  String get keyFindingsTitle => 'Principais achados';

  @override
  String get reviewedExcerptTitle => 'Trecho analisado';

  @override
  String get permissionsOnPhoneTitle => 'Permissões neste telefone';

  @override
  String get viewReviewedSnapshot => 'Ver texto da política analisada';

  @override
  String get btnSavedToReceipts => 'Salvo em Recibos';

  @override
  String get observedOnPhoneLabel => 'Visto neste telefone';

  @override
  String get quoteVerifiedLabel => 'Citação exata da política';

  @override
  String get unverifiedClaimLabel => 'Não encontrado na política';

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
  String get labelWhatRemainsUnknown => 'O que ainda não sabemos';

  @override
  String get presetQuestionMeaning => 'O que isso significa para meu filho?';

  @override
  String get presetQuestionOptOut => 'Podemos desativar ou recusar isso?';

  @override
  String get presetQuestionUnknown => 'O que ainda não está claro aqui?';

  @override
  String get readingCitedClause => 'Lendo a citação da política…';

  @override
  String get deniAnswerTitle => 'Resposta do Deni';

  @override
  String get stepsAndReasoning => 'Como o Deni verificou isso';

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
  String get appsOnThisPhone => 'Apps neste telefone';

  @override
  String get hintSearchApps => 'Buscar apps…';

  @override
  String get noMatchingApps =>
      'Nenhum app correspondente encontrado neste telefone.';

  @override
  String get permissionInspectionTitle => 'Permissões do telefone verificadas';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Adicionar política de privacidade deste app';

  @override
  String get snapshotDigestLabel => 'Impressão digital do documento';

  @override
  String get snapshotDigestExplanation =>
      'Um código único que ajuda a confirmar que este é exatamente o texto verificado pelo Enprive. Se mudar uma única letra, esse código também muda.';

  @override
  String get copyDigestBtn => 'Copiar código';

  @override
  String get digestCopiedMsg => 'Impressão digital do documento copiada';

  @override
  String get permissionGrantedBadge => 'Permitido neste telefone';

  @override
  String get permissionNotGrantedBadge => 'Não permitido';

  @override
  String get checkingPolicyWithCloudAi =>
      'Verificando política com IA na nuvem.';

  @override
  String get preparingCloudAiStream =>
      'Ocultando dados pessoais antes da verificação na nuvem…';

  @override
  String get cancellingAnalysis => 'Cancelando…';

  @override
  String get analysisCancelledNotice => 'Análise cancelada.';

  @override
  String get cloudTimedOutNotice =>
      'A IA na nuvem atingiu o tempo limite antes de responder. Nenhuma nova tentativa automática foi enviada.';

  @override
  String get cloudFallbackBannerTitle =>
      'A verificação na nuvem não pôde ser concluída';

  @override
  String get cloudFallbackBannerBody =>
      'Este é o resultado obtido no seu telefone, e nada foi enviado de novo. O texto da política foi mantido. Nada é salvo até você tocar em Salvar.';

  @override
  String get cloudFallbackRetryAction =>
      'Tentar a verificação na nuvem de novo';

  @override
  String get appPickerFilterAll => 'Todos os apps';

  @override
  String get appPickerFilterDownloaded => 'Baixados';

  @override
  String get appPickerFilterSystem => 'Sistema';

  @override
  String get appPickerRecentlyChecked => 'Verificados recentemente';

  @override
  String get appPickerStatusPolicySaved => 'Análise de política salva';

  @override
  String get appPickerStatusPermissionsInspected => 'Permissões verificadas';

  @override
  String get appPickerStatusNotReviewed => 'Não analisado';

  @override
  String get appPickerSearchHint => 'Buscar por nome do app ou App ID…';

  @override
  String get appPickerEmptyInstalledTitle => 'Nenhum app instalado disponível';

  @override
  String get appPickerEmptyInstalledBody =>
      'Não encontramos nenhum app para verificar neste telefone.';

  @override
  String get intakeModeDocument => 'Documento';

  @override
  String get intakeActionInspectText => 'Verificar texto da política';

  @override
  String get intakeActionFetchUrl => 'Abrir e verificar política';

  @override
  String get intakeActionChooseDocument => 'Escolher PDF, TXT ou DOCX';

  @override
  String get intakeActionReplaceDocument => 'Escolher documento substituto';

  @override
  String get intakeWorkingLabel => 'Processando…';

  @override
  String get intakeCancelFetch => 'Cancelar busca';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'Carrega esta página pública diretamente. Adicionar um link aqui não prova quem é dono do app.';

  @override
  String get intakePasteLocalNote =>
      'Verificado localmente neste telefone primeiro. Nada é enviado sem sua permissão.';

  @override
  String get intakeDocumentCardTitle =>
      'Importar arquivo de política PDF, TXT ou DOCX';

  @override
  String get intakeDocumentCardBody =>
      'Lemos o texto direto no seu telefone (até 10 MB). Seu arquivo nunca é enviado.';

  @override
  String get intakeCompareWithAppPrompt =>
      'Comparar com um app instalado (opcional)';

  @override
  String get intakeCompareWithAppHint =>
      'Roda localmente neste telefone. Sua lista de apps nunca sai do seu dispositivo.';

  @override
  String get intakeCompareWithAppChange => 'Trocar';

  @override
  String get intakeCompareWithAppRemove => 'Remover';

  @override
  String get intakeLockedAppContextLabel => 'App selecionado';

  @override
  String get intakeFindPolicyOnPlayStore =>
      'Encontrar link da política na Play Store';

  @override
  String get intakePlayStoreHelperNote =>
      'Abre a Play Store para você copiar o link da política de privacidade do app. O Enprive nunca copia automaticamente nem presume que o link seja oficial.';

  @override
  String get intakePlayStoreUnavailable =>
      'Não foi possível abrir a Google Play Store neste dispositivo. Cole a URL ou o texto da política manualmente.';

  @override
  String get intakeRecoverySwitchPaste => 'Colar texto em vez disso';

  @override
  String get intakeRecoverySwitchDocument => 'Importar documento';

  @override
  String get intakeRecoveryRetryUrl => 'Tentar novamente';

  @override
  String get intakeExpiredDocumentShareNotice =>
      'O link do arquivo compartilhado originalmente não pode mais ser reaberto. Escolha outro arquivo PDF, TXT ou DOCX ou cole o texto da política manualmente.';

  @override
  String get intakeAssociationWarningTitle =>
      'Verificação de vínculo app-política';

  @override
  String get intakeAssociationContinueAnyway => 'Continuar mesmo assim';

  @override
  String get intakeAssociationChangeApp => 'Trocar app selecionado';

  @override
  String get intakeAssociationInspectWithoutApp => 'Verificar política sem app';

  @override
  String get intakeModeSelectorSemanticLabel => 'Método de entrada da política';

  @override
  String get tooltipClearSearch => 'Limpar busca';

  @override
  String get intakeRecoveryEditUrl => 'Editar URL';

  @override
  String get voiceSummaryTitle => 'Resumo do Deni em linguagem simples';

  @override
  String get voiceSummaryPreparing => 'Preparando resumo em linguagem simples…';

  @override
  String get voiceSynthesizingExpressive =>
      'Preparando a voz expressiva do Deni…';

  @override
  String get voiceBtnListenOffline => 'Ouvir';

  @override
  String get voiceBtnStop => 'Parar';

  @override
  String get voiceBtnExpressiveCloud => 'Voz expressiva';

  @override
  String get voiceBtnSummarizeCloud => 'Resumir com IA na nuvem';

  @override
  String get voiceBadgeExpressive => 'Voz expressiva na nuvem';

  @override
  String get voiceBadgeDeviceOffline => 'Voz do telefone · Offline';

  @override
  String get voiceViewSourceQuote => 'Citação original';

  @override
  String get voiceHideSourceQuote => 'Ocultar citação';

  @override
  String get voiceInspectFinding => 'Ver achado';

  @override
  String get voiceConsentTitle => 'Escolher a voz do Deni';

  @override
  String get voiceConsentDisclosure =>
      'Para ler este resumo em voz alta com a voz expressiva na nuvem do Deni, o Enprive enviará apenas o texto do resumo mostrado acima (com dados pessoais ocultos) para esta única solicitação. Seus apps e permissões do telefone nunca são enviados.';

  @override
  String get voiceConsentPrimaryAction => 'Usar voz expressiva uma vez';

  @override
  String get voiceConsentSecondaryAction => 'Falar neste telefone';

  @override
  String get voiceConsentPayloadLabel => 'Texto exato que será falado';

  @override
  String get voiceSummaryConsentTitle => 'Resumir achados com IA na nuvem';

  @override
  String get voiceSummaryConsentDisclosure =>
      'Para resumir estas citações da política em linguagem simples na nuvem, o Enprive enviará apenas o texto mostrado acima (com dados pessoais ocultos) para esta única solicitação. Seus apps e permissões do telefone nunca são enviados.';

  @override
  String get voiceFallbackDeviceNotice =>
      'A voz expressiva na nuvem estava indisponível: usando a voz offline deste telefone.';

  @override
  String get voiceUnavailableNotice =>
      'A leitura em voz alta não está disponível para este idioma neste telefone. Você pode ler o resumo do Deni acima.';

  @override
  String get voiceTooltipReadSummary =>
      'Ouvir o resumo do Deni em linguagem simples';

  @override
  String get voiceTooltipStopReading => 'Parar leitura em voz alta';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'achados',
      one: 'achado',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count achados',
      one: '1 achado',
      zero: 'Nenhum achado',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citações verificadas na política',
      one: '1 citação verificada na política',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vistos neste telefone',
      one: '1 visto neste telefone',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'Permitido neste telefone';

  @override
  String get permissionNotAllowedOnPhone => 'Não permitido';

  @override
  String get permissionMismatchChip => 'Fora da política';

  @override
  String get howEnpriveCheckedThis => 'Como o Enprive verificou isso';

  @override
  String get hideHowEnpriveChecked => 'Ocultar como o Enprive verificou isso';

  @override
  String get consentWhatWouldBeSent => 'O que seria enviado';

  @override
  String get consentSentScope =>
      'Apenas o texto na prévia sai deste telefone, para esta única solicitação.';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dados pessoais são ocultados antes.',
      one: '1 dado pessoal é ocultado antes.',
      zero: 'Nenhum dado pessoal encontrado para ocultar.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'Sua lista de apps e permissões do telefone ficam neste telefone.';

  @override
  String receiptDeletedSnack(String title) {
    return '$title excluído';
  }

  @override
  String get btnUndo => 'Desfazer';

  @override
  String get readinessPromiseMaskedTitle => 'Dados pessoais ocultos';

  @override
  String get readinessPromiseMaskedLine =>
      'Se você escolher a nuvem, nomes, e-mails e números são ocultados antes.';

  @override
  String findingDetailTitle(int index, int total) {
    return 'Achado $index de $total';
  }

  @override
  String get findingReviewChip => 'Revisar';

  @override
  String get askDeniAboutThis => 'Perguntar ao Deni sobre isso';

  @override
  String get labelWhatPolicySays => 'O que a política diz';

  @override
  String get labelWhatAndroidReports => 'O que seu telefone mostra';

  @override
  String get sourceButtonTooltip => 'Fonte analisada';

  @override
  String get linkInstalledAppBtn => 'Vincular um app instalado';

  @override
  String get linkInstalledAppCardTitle => 'Comparar com um app neste telefone';

  @override
  String get linkInstalledAppCardBody =>
      'Escolha um app instalado para comparar as permissões dele com esta política na mesma análise. Sua lista de apps fica neste telefone.';

  @override
  String get linkAppPickerTitle => 'Vincular um app instalado';

  @override
  String get changeLinkedAppPickerTitle => 'Trocar app vinculado';

  @override
  String get linkAppPickerSubtitle =>
      'Escolha um app neste telefone para comparar as permissões dele com esta política. Sua lista de apps nunca sai deste telefone.';

  @override
  String get linkedAppCurrentlySelectedBadge => 'Vinculado';

  @override
  String get linkedAppSectionLabel => 'App vinculado neste telefone';

  @override
  String get btnChangeLinkedApp => 'Trocar app';

  @override
  String get btnUnlinkApp => 'Desvincular app';

  @override
  String get btnUpdatePrivacyPolicy =>
      'Anexar política de privacidade atualizada';

  @override
  String linkedAppSnack(String appName) {
    return '$appName vinculado. Permissões comparadas neste telefone.';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return '$appName vinculado. Confira a nota de correspondência abaixo.';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName já está vinculado com as mesmas permissões.';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return '$appName desvinculado. Exibindo apenas a análise da política.';
  }

  @override
  String get associationStatusPackageTitle =>
      'App ID encontrado nesta política';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'Esta política menciona $packageName. Isso sugere que ela pode descrever $appName, embora o texto sozinho não prove quem é dono desta política.';
  }

  @override
  String get associationStatusNameTitle =>
      'Nome do app encontrado nesta política';

  @override
  String associationStatusNameBody(String appName) {
    return 'Esta política menciona $appName. Isso sugere que ela pode descrever este app, embora o nome igual não prove quem é dono desta política.';
  }

  @override
  String get associationStatusUnverifiedTitle =>
      'Vinculado por você para comparação';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'Esta política não cita $appName nem o App ID dele. Confira se é a política certa: vincular aqui não prova propriedade.';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'O endereço web inclui palavras de $appName, mas o texto da política em si não cita este app. Confira se é a política certa: vincular aqui não prova propriedade.';
  }

  @override
  String get associationStatusUnmatchedTitle =>
      'Esta política pode ser de outro app';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'Esta política não menciona $appName. Em vez disso, cita $otherApps. Confira se você vinculou o app certo ou abriu a política certa.';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'Esta política menciona mais de um app';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'Esta política menciona $appName junto com $otherApps. Ela pode cobrir vários apps ou ser uma política compartilhada da empresa, então confirme se vale aqui.';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      'Mais de um app neste telefone tem nome parecido';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'Esta política menciona $appName sem informar um App ID exato, e outros apps no seu telefone ($otherApps) têm nome parecido. Confirme se vinculou o correto.';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'Esta política pode se referir a mais de um app. Confira se ela vale para $appName.';
  }

  @override
  String get associationOwnershipLimitation =>
      'Textos e links da web nunca provam quem publicou ou é dono de uma política.';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count permissões neste telefone não aparecem claramente nesta política. Uma divergência é um convite para olhar de perto, não prova de irregularidade.',
      one: '1 permissão neste telefone não aparece claramente nesta política. Uma divergência é um convite para olhar de perto, não prova de irregularidade.',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'Nenhuma das permissões verificadas neste telefone contradiz esta política. Permissões sozinhas não mostram o que um app realmente envia.';

  @override
  String get permissionComparisonLimitationNote =>
      'Seu telefone mostra apenas as configurações de permissão deste aparelho. Esta comparação convida a olhar de perto, nunca é prova de irregularidade ou de envio de dados.';

  @override
  String get permissionNotRequestedOnPhone => 'Não pedida pelo app';

  @override
  String get permissionsEmptyComparisonTitle =>
      'Nenhuma permissão sensível nesta verificação';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'Seu telefone lista $requestedCount permissões ($grantedCount permitidas) para $appName, sem nenhuma nas categorias sensíveis verificadas aqui (localização, câmera, microfone, contatos, fotos ou ID de publicidade).';
  }

  @override
  String get sourceDeviceInspection => 'Verificado neste telefone';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => 'Detalhes avançados';

  @override
  String get advancedDetailsSubtitle =>
      'Detalhes técnicos que confirmam quando e onde este texto de política foi verificado.';

  @override
  String get sourceSectionTitle => 'De onde veio esta política';

  @override
  String get cloudPayloadLabel => 'Texto exato que será enviado';

  @override
  String get cloudPayloadNoPiiLabel => 'Nenhum dado pessoal encontrado';

  @override
  String cloudPayloadHiddenCount(int count) {
    return 'Ocultos ($count)';
  }

  @override
  String get summarySourceOnDevice => 'Resumido neste telefone';

  @override
  String get summarySourceInCloud => 'Resumido na nuvem';

  @override
  String get summarySourceOffline => 'Resumido offline neste telefone';

  @override
  String get summarySourceUnknown => 'Fonte do resumo desconhecida';

  @override
  String get notFromPolicySuffix =>
      'Das configurações do seu telefone, não da política';

  @override
  String get learnHeaderSubtitle => 'Guias e diagramas de privacidade offline';

  @override
  String get learnFilterAll => 'Todos os temas';

  @override
  String get learnFilterPolicies => 'Políticas';

  @override
  String get learnFilterPermissions => 'Permissões';

  @override
  String get learnFilterSharing => 'Compartilhamento';

  @override
  String get learnFilterEvidence => 'Evidências';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etapas',
      one: '1 etapa',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle => 'Pratique hábitos de privacidade localmente';

  @override
  String get learnDeckBody =>
      'Lições 100% offline com diagramas. Seus apps instalados e recibos nunca entram em Aprender.';

  @override
  String get learnDeckCheckBtn => 'Coloque em prática · Verificar um app';

  @override
  String get learnCheckAppBridgeBtn => 'Verificar um app neste telefone';

  @override
  String get learnSectionDiagram => 'Como funciona';

  @override
  String get learnSectionSteps => 'Passos principais';

  @override
  String get learnSectionQuickCheck => 'Verificação rápida';

  @override
  String get learnTooltipListenLesson => 'Ouvir esta lição em voz alta offline';

  @override
  String get learnTooltipStopLesson => 'Parar leitura da lição';

  @override
  String get learnVoiceUnavailableNotice =>
      'A leitura por voz offline não está disponível para este idioma neste telefone. Você pode ler a lição abaixo.';

  @override
  String get learnQuickCheckCorrectBadge => 'Resposta certa';

  @override
  String get learnQuickCheckTryAgainBadge => 'Tente outra opção';

  @override
  String learnLessonProgress(int current, int total) {
    return 'Lição $current de $total';
  }

  @override
  String get learnBackTooltip => 'Voltar para Aprender';

  @override
  String get learnPreviousLesson => 'Anterior';

  @override
  String get learnNextLesson => 'Próxima';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return 'Lição anterior: $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return 'Próxima lição: $title';
  }

  @override
  String get learnPolicyFolderTitle => 'Políticas de privacidade';

  @override
  String get learnPolicyTitle =>
      'O que é uma política de privacidade (e o que ela não prova)';

  @override
  String get learnPolicySubtitle =>
      'O que desenvolvedores prometem vs. o que segue desconhecido';

  @override
  String get learnPolicyIntro =>
      'Uma política de privacidade é a declaração pública de um desenvolvedor explicando que dados um app diz coletar, por que os usa, quem pode recebê-los e que escolhas as famílias têm.';

  @override
  String get learnPolicyStep1 =>
      'Procure quatro pontos básicos: que dados são coletados, por que o app precisa deles, quem mais pode recebê-los e como pedir a exclusão.';

  @override
  String get learnPolicyStep2 =>
      'Texto confuso é comum. Um estudo de 2026 sobre apps educativos infantis descobriu que pouquíssimas políticas eram fáceis de ler e que a maioria dos apps não correspondia totalmente ao que suas políticas diziam.';

  @override
  String get learnPolicyStep3 =>
      'Uma política de privacidade mostra apenas o que o desenvolvedor diz no papel. Lê-la não prova o que o app realmente envia pela internet.';

  @override
  String get learnPolicyStep4 =>
      'Comparar uma política com as permissões do seu telefone dá uma visão mais clara, lembrando que o Enprive não pode ver o tráfego de internet ao vivo.';

  @override
  String get learnPolicyQuickQuestion =>
      'O que ler a política de privacidade de um app prova?';

  @override
  String get learnPolicyQuickOption1 =>
      'Que o app nunca envia dados para ninguém';

  @override
  String get learnPolicyQuickOption2 =>
      'O que o desenvolvedor diz: não o que o app realmente envia';

  @override
  String get learnPolicyQuickOption3 =>
      'Que a câmera e o microfone do telefone estão desligados';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'Isso mesmo. Uma política é a declaração pública do desenvolvedor, não prova do que o app realmente envia pela internet.';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      'Não exatamente. Ler uma política só mostra o que o desenvolvedor afirma: não prova atividade na internet nem desliga permissões do telefone.';

  @override
  String get learnDiagramPolicySaysTitle => 'A política diz';

  @override
  String get learnDiagramPolicySaysBody => 'Promessa escrita do desenvolvedor';

  @override
  String get learnDiagramPolicyQuoteSample =>
      '\"Podemos compartilhar dados com parceiros…\"';

  @override
  String get learnDiagramPhoneShowsTitle => 'O telefone mostra';

  @override
  String get learnDiagramPhoneShowsBody => 'Permissões liberadas aqui';

  @override
  String get learnDiagramUnknownTitle => 'Ainda desconhecido';

  @override
  String get learnDiagramUnknownBody =>
      'Tráfego de internet ao vivo que o Enprive não vê';

  @override
  String get learnDiagramPolicyCaption =>
      'Uma política é uma promessa, não prova de comportamento';

  @override
  String get learnDiagramPolicySemantic =>
      'Diagrama comparando três partes da privacidade de um app. Primeiro, A política diz: a promessa escrita do desenvolvedor. Segundo, O telefone mostra: as permissões liberadas neste telefone. Terceiro, dentro de uma borda tracejada, Ainda desconhecido: tráfego de internet ao vivo que o Enprive não pode ver. Uma política de privacidade é uma promessa, não prova de comportamento.';

  @override
  String get learnPermissionsFolderTitle => 'Permissões do telefone';

  @override
  String get learnPermissionsTitle => 'Permissões do Android explicadas';

  @override
  String get learnPermissionsSubtitle =>
      'As quatro opções do Android e onde revisá-las';

  @override
  String get learnPermissionsIntro =>
      'Permissões são portas que controlam se um app pode alcançar sensores e dados no seu telefone, como câmera, microfone, localização, fotos, contatos ou notificações.';

  @override
  String get learnPermissionsStep1 =>
      'Pergunte se a permissão combina com o recurso: um quiz de matemática ou app de leitura raramente precisa de localização, contatos ou câmera.';

  @override
  String get learnPermissionsStep2 =>
      'O Android oferece até quatro opções: Não permitir, Perguntar sempre, Permitir apenas durante o uso do app e O tempo todo (para localização em segundo plano).';

  @override
  String get learnPermissionsStep3 =>
      'Comece pela opção mais restrita que deixa o recurso funcionar, como Perguntar sempre ou Durante o uso do app.';

  @override
  String get learnPermissionsStep4 =>
      'Abra as Configurações do Android e confira o Painel de privacidade para ver quais apps acessaram Câmera, Microfone ou Localização recentemente.';

  @override
  String get learnPermissionsStep5 =>
      'Desative permissões a qualquer momento nas Configurações do app, ou mantenha Pausar atividade do app se não for usado ativado para o Android remover permissões antigas automaticamente. Uma permissão liberada mostra capacidade, não prova de que dados foram enviados.';

  @override
  String get learnPermissionsQuickQuestion =>
      'Um app de matemática pede acesso à câmera e você não sabe o motivo. Qual é o melhor primeiro passo?';

  @override
  String get learnPermissionsQuickOption1 =>
      'Tocar em Não permitir e ver se os exercícios de matemática continuam funcionando';

  @override
  String get learnPermissionsQuickOption2 =>
      'Escolher O tempo todo para o aviso não voltar a aparecer';

  @override
  String get learnPermissionsQuickOption3 => 'Supor que o app já enviou fotos';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      'Certo. Tocar em Não permitir deixa você ver se o app funciona sem a câmera, e você pode mudar permissões quando quiser nas Configurações do Android.';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'Tente primeiro uma opção mais restrita. Toque em Não permitir para testar se o recurso continua funcionando e lembre-se de que uma permissão liberada mostra capacidade, não prova de envio.';

  @override
  String get learnDiagramPermLadderTitle =>
      'Do acesso mais restrito ao mais amplo';

  @override
  String get learnDiagramPermDenyTitle => 'Não permitir';

  @override
  String get learnDiagramPermDenyDetail =>
      'Bloqueado: o app não pode usar este sensor';

  @override
  String get learnDiagramPermAskTitle => 'Perguntar sempre';

  @override
  String get learnDiagramPermAskDetail =>
      'Acesso único quando você toca em permitir';

  @override
  String get learnDiagramPermWhileUsingTitle => 'Durante o uso do app';

  @override
  String get learnDiagramPermWhileUsingDetail =>
      'Somente enquanto o app está aberto na tela';

  @override
  String get learnDiagramPermAllTimeTitle => 'O tempo todo';

  @override
  String get learnDiagramPermAllTimeDetail =>
      'Acesso em segundo plano mesmo fechado';

  @override
  String get learnDiagramPermFitNote =>
      'Combina? Quiz de matemática + Câmera = pergunte por quê';

  @override
  String get learnDiagramPermSemantic =>
      'Escada de quatro passos das permissões do Android do acesso mais restrito ao mais amplo. Passo 1, Não permitir: bloqueado, o app não pode usar este sensor. Passo 2, Perguntar sempre: acesso único quando você toca em permitir. Passo 3, Durante o uso do app: acesso somente enquanto o app está aberto na tela. Passo 4, O tempo todo: acesso em segundo plano mesmo fechado, com borda tracejada para atenção extra. Dica abaixo: Combina? Um quiz de matemática pedindo a câmera é motivo para perguntar por quê.';

  @override
  String get learnSharingFolderTitle => 'Anúncios e terceiros';

  @override
  String get learnSharingTitle =>
      'Quem mais recebe dados: anúncios, métricas e terceiros';

  @override
  String get learnSharingSubtitle =>
      'Criador do app vs. serviços de apoio, métricas e redes de anúncios';

  @override
  String get learnSharingIntro =>
      'Muitos apps gratuitos se conectam a outras empresas nos bastidores. Saber quem recebe as informações ajuda as famílias a diferenciar o que faz o app funcionar do que rastreia crianças entre apps.';

  @override
  String get learnSharingStep1 =>
      'Primeira parte é o próprio criador do app: por exemplo, salvar o progresso das tarefas ou notas de quiz para o app funcionar.';

  @override
  String get learnSharingStep2 =>
      'Empresas de apoio são terceiros que cuidam de tarefas nos bastidores, como armazenamento em nuvem ou relatórios de falha para corrigir bugs.';

  @override
  String get learnSharingStep3 =>
      'Ferramentas de métricas medem como as telas são usadas, enquanto redes de anúncios e corretores de dados podem usar um ID de publicidade para mostrar anúncios direcionados ou traçar perfis entre apps.';

  @override
  String get learnSharingStep4 =>
      'Fique atento a termos amplos como \'parceiros confiáveis\' ou \'fins comerciais\' e confira se a política explica como desativar anúncios personalizados.';

  @override
  String get learnSharingQuickQuestion =>
      'Uma política diz que o app compartilha dados com \'parceiros terceiros\'. Qual é a melhor próxima pergunta?';

  @override
  String get learnSharingQuickOption1 =>
      'Supor que isso significa que o app não tem anúncios';

  @override
  String get learnSharingQuickOption2 =>
      'Supor que todos os parceiros fazem exatamente o mesmo trabalho';

  @override
  String get learnSharingQuickOption3 =>
      'Verificar se esses parceiros são serviços de apoio (como hospedagem) ou redes de anúncios que rastreiam entre apps';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'Acertou. Serviços de apoio mantêm o app funcionando, enquanto redes de anúncios e corretores de dados podem rastrear atividades entre apps.';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      'Olhe mais de perto o que cada parceiro faz. Nem todos os terceiros são iguais: alguns hospedam dados ou corrigem falhas, enquanto outros exibem anúncios ou fazem rastreamento.';

  @override
  String get learnDiagramThirdPartyYou => 'Você';

  @override
  String get learnDiagramThirdPartyApp => 'App educativo';

  @override
  String get learnDiagramThirdPartyHosting => 'Apoio e falhas';

  @override
  String get learnDiagramThirdPartyAnalytics => 'Métricas';

  @override
  String get learnDiagramThirdPartyAds => 'Redes de anúncios';

  @override
  String get learnDiagramThirdPartyFirstParty => 'Primeira parte';

  @override
  String get learnDiagramThirdPartyThirdParty => 'Terceiros';

  @override
  String get learnDiagramThirdPartySemantic =>
      'Diagrama de fluxo mostrando para onde podem ir os dados de um app educativo infantil. Você se conecta ao app educativo, que se conecta com linha contínua ao criador do app (primeira parte) e com linhas tracejadas a terceiros: ferramentas de apoio e falhas, métricas e redes de anúncios destacadas para atenção extra.';

  @override
  String get learnEvidenceFolderTitle => 'Ler o Enprive';

  @override
  String get learnEvidenceTitle => 'Como ler as evidências do Enprive';

  @override
  String get learnEvidenceSubtitle =>
      'Camadas de evidência, categorias e limites honestos';

  @override
  String get learnEvidenceIntro =>
      'O Enprive separa o que a política de privacidade diz, o que seu telefone mostra e o que segue desconhecido, e agrupa achados por tema, nunca como nota de segurança.';

  @override
  String get learnEvidenceStep1 =>
      'Cinco categorias temáticas agrupam cada achado com o mesmo ícone e cor da tela de Análise. A cor marca o tema, nunca uma pontuação de segurança.';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '$sourceMatched significa que o Enprive encontrou uma citação exata, palavra por palavra, no texto da política que você verificou.';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '$deviceObserved significa que seu telefone informou uma configuração de permissão neste aparelho: não é prova de que dados foram enviados.';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '$interpretation é a explicação do Deni em linguagem simples, enquanto $unverified marca detalhes que o Enprive não encontrou. Silêncio em uma política nunca é promessa.';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return 'As análises terminam com um de três resultados claros: $reviewRecommended, $noConcern (que nunca é certificação de segurança) ou $insufficientEvidence.';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return 'Na tela de Análise, o que significa \'$deviceObserved\'?';
  }

  @override
  String get learnEvidenceQuickOption1 =>
      'Que o app tem certificação de segurança para crianças';

  @override
  String get learnEvidenceQuickOption2 =>
      'Que seu telefone mostra essa configuração de permissão neste aparelho: não prova envio de dados';

  @override
  String get learnEvidenceQuickOption3 =>
      'Que o app com certeza enviou os dados do seu filho';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'Isso mesmo. Esse selo reflete o estado da permissão do Android neste aparelho; ele não pode provar envios nem certificar segurança.';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      'Não exatamente. Esse selo só mostra o que seu telefone informa sobre uma permissão: ele nunca prova envios e nunca é certificação de segurança.';

  @override
  String get learnDiagramEvidencePolicyDetail =>
      'Citação exata encontrada no texto da política';

  @override
  String get learnDiagramEvidencePhoneDetail =>
      'Permissões do telefone neste aparelho';

  @override
  String get learnDiagramEvidenceDeniDetail =>
      'Explicação do Deni em linguagem simples';

  @override
  String get learnDiagramEvidenceUnknownDetail =>
      'Silêncio em uma política não é promessa';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Quatro camadas de evidência usadas na tela de Análise do Enprive: 1, $sourceMatched, citação exata encontrada na política; 2, $deviceObserved, permissões do telefone neste aparelho; 3, $interpretation, explicação do Deni em linguagem simples; e 4, separada por linha tracejada, $unverified, porque silêncio em uma política não é promessa.';
  }

  @override
  String get learnDiagramCategoriesTitle =>
      'Cinco categorias temáticas na tela de Análise';

  @override
  String get learnDiagramCategoriesNote =>
      'Cor e ícone marcam o tema, nunca uma pontuação de segurança.';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Cinco categorias de evidência mostradas na tela de Análise do Enprive, cada uma com seu ícone e cor: $dataCollection, $sharing, $tracking, $retention e $parentalControls. Cor e ícone marcam o tema, nunca uma pontuação de segurança.';
  }

  @override
  String get learnDataCollectionFolderTitle => 'Dados que apps coletam';

  @override
  String get learnDataCollectionTitle => 'Quais dados os apps coletam';

  @override
  String get learnDataCollectionSubtitle =>
      'A diferença entre o que você digita e o que roda em silêncio';

  @override
  String get learnDataCollectionIntro1 =>
      'Apps reúnem informações de duas formas. Alguns dados vêm do que você digita ativamente: nome, e-mail, fotos, gravações de voz ou respostas de tarefas. Outros dados são coletados automaticamente em segundo plano, como endereço IP (o endereço do seu telefone na internet), identificadores do aparelho, ID de publicidade (um código usado por anúncios para reconhecer seu telefone), registros de falhas e quando você abre o app.';

  @override
  String get learnDataCollectionStep1 =>
      'O que você digita: nome, escola, e-mail, fotos, áudios e respostas de tarefas são dados que você escolhe informar.';

  @override
  String get learnDataCollectionStep2 =>
      'O que roda em silêncio: o app pode coletar ID de publicidade, identificadores do aparelho, endereço IP, relatórios de falha e horários de uso sem você tocar em nada. Coleta silenciosa não é automaticamente ruim: esses sinais ajudam os apps a funcionar bem.';

  @override
  String get learnDataCollectionStep3 =>
      'Dados sensíveis de crianças: localização, gravações de microfone, fotos da câmera e dados biométricos como impressões de voz (dados sobre corpo ou voz) trazem maior risco à privacidade infantil.';

  @override
  String get learnDataCollectionStep4 =>
      'Nota sobre a Play Store: a seção Segurança dos dados do Google Play é a própria descrição do desenvolvedor. É uma pista, não prova, e não inclui dados processados apenas no dispositivo ou mantidos brevemente na memória.';

  @override
  String get learnDataCollectionQuizQuestion =>
      'Qual destes é um exemplo de dado coletado em silêncio em segundo plano?';

  @override
  String get learnDataCollectionQuizChoiceA =>
      'Uma foto que você envia para seu perfil';

  @override
  String get learnDataCollectionQuizChoiceB =>
      'Seu ID de publicidade e identificadores do dispositivo';

  @override
  String get learnDataCollectionQuizChoiceC =>
      'Uma resposta de tarefa que você digita no app';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      'Certo: IDs de publicidade e identificadores do dispositivo são coletados automaticamente sem você digitá-los.';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      'Não exatamente: esses são dados que você informa ativamente. Dados coletados em silêncio incluem IDs de publicidade, identificadores do dispositivo, endereço IP e horários de uso.';

  @override
  String get learnDataCollectionDiagramYouTypeTitle =>
      'O que você digita ou envia';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => 'Nome, e-mail, escola';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => 'Fotos e vídeos';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => 'Gravações de voz';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => 'Respostas de tarefas';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle =>
      'O que roda em silêncio';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => 'ID de publicidade';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 =>
      'Identificadores do aparelho';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'Endereço IP';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 =>
      'Registros de falha e uso';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      'Silencioso não quer dizer ruim: esses sinais ajudam os apps a rodar bem.';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      'Diagrama dividido mostrando duas categorias de coleta de dados. O cartão superior \"O que você digita ou envia\" lista quatro itens: Nome, e-mail, escola; Fotos e vídeos; Gravações de voz; Respostas de tarefas. O cartão inferior \"O que roda em silêncio\" lista quatro itens: ID de publicidade; Identificadores do aparelho; Endereço IP; Registros de falha e uso. Uma pequena nota diz \"Silencioso não quer dizer ruim: esses sinais ajudam os apps a rodar bem.\" Deni aparece abaixo em pose pensativa.';

  @override
  String get learnDataCollectionCheckBridge =>
      'Verifique um app neste telefone para ver quais dados ele coleta.';

  @override
  String get learnDataCollectionHonestyNote =>
      'Esta lição explica tipos comuns de dados. Ela não prova o que um app específico coleta ou envia. Apenas o texto exato da política e as permissões do seu telefone podem mostrar isso.';

  @override
  String get learnRetentionFolderTitle => 'Retenção e exclusão';

  @override
  String get learnRetentionTitle => 'Retenção e exclusão de dados';

  @override
  String get learnRetentionSubtitle =>
      'Desinstalar um app não apaga dados que já estão nos servidores da empresa';

  @override
  String get learnRetentionIntro1 =>
      'Quando você remove um app do telefone, os arquivos locais do aparelho são apagados, mas os dados já enviados aos servidores da empresa continuam lá. Políticas de privacidade deveriam dizer por quanto tempo guardam seus dados, como pedir exclusão e o que acontece com backups, mas muitas usam frases vagas como \"pelo tempo razoavelmente necessário\".';

  @override
  String get learnRetentionStep1 =>
      'Dados coletados: enquanto você usa o app, suas informações são enviadas e guardadas nos servidores da empresa.';

  @override
  String get learnRetentionStep2 =>
      'Guardados em servidores: seus dados podem continuar nos sistemas da empresa mesmo depois que você para de usar o app.';

  @override
  String get learnRetentionStep3 =>
      'Desinstalar não apaga dados no servidor: remover o app do telefone só apaga arquivos locais, não as cópias nos servidores da empresa.';

  @override
  String get learnRetentionStep4 =>
      'Pedido de exclusão: você pode pedir à empresa para excluir sua conta e seus dados; políticas deveriam informar quanto tempo isso leva.';

  @override
  String get learnRetentionStep5 =>
      'Retenção desconhecida: políticas que dizem \"enquanto for necessário\" ou \"para fins comerciais\" deixam indefinido quando os dados serão realmente apagados.';

  @override
  String get learnRetentionQuizQuestion =>
      'O que acontece com seus dados nos servidores da empresa quando você desinstala um app do telefone?';

  @override
  String get learnRetentionQuizChoiceA => 'Eles são apagados automaticamente';

  @override
  String get learnRetentionQuizChoiceB =>
      'Podem ficar nos servidores: desinstalar o app não os apaga';

  @override
  String get learnRetentionQuizChoiceC => 'São anonimizados na hora';

  @override
  String get learnRetentionQuizFeedbackRight =>
      'Certo: desinstalar remove apenas o app do seu telefone. Dados nos servidores da empresa podem ficar lá até você pedir exclusão.';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      'Não exatamente: desinstalar um app não apaga dados já enviados aos servidores da empresa. Você precisa pedir a exclusão da conta.';

  @override
  String get learnRetentionDiagramCollected => 'Dados coletados durante o uso';

  @override
  String get learnRetentionDiagramStored =>
      'Guardados nos servidores da empresa';

  @override
  String get learnRetentionDiagramUninstall =>
      'Você desinstala o app: arquivos do telefone somem, dados do servidor ficam';

  @override
  String get learnRetentionDiagramDeleteRequest =>
      'Você pede exclusão da conta';

  @override
  String get learnRetentionDiagramUnknownTail =>
      'Retenção desconhecida: a política diz \"enquanto for necessário\"';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      'Linha do tempo de cinco etapas mostrando o ciclo de vida dos dados. Etapa 1: Dados coletados durante o uso, com ícone de banco de dados. Etapa 2: Guardados nos servidores da empresa, com ícone de servidor. Etapa 3: Você desinstala o app: arquivos do telefone somem, dados do servidor ficam, com ícone de celular. Etapa 4: Você pede exclusão da conta, com ícone de lixeira. Etapa 5: Retenção desconhecida: a política diz \"enquanto for necessário\", com seta tracejada e ícone de ajuda. Deni está abaixo segurando um recibo.';

  @override
  String get learnRetentionCheckBridge =>
      'Verifique um app neste telefone para ver o que a política dele diz sobre retenção.';

  @override
  String get learnRetentionHonestyNote =>
      'Esta lição descreve padrões comuns de retenção. Ela não prova o que uma empresa específica realmente faz com seus dados. Apenas o texto exato da política e um pedido de exclusão podem mostrar isso.';

  @override
  String get learnUnclearPoliciesFolderTitle => 'Políticas pouco claras';

  @override
  String get learnUnclearPoliciesTitle =>
      'Como identificar políticas vagas e botões enganosos';

  @override
  String get learnUnclearPoliciesSubtitle =>
      'Como reconhecer linguagem vaga e telas de consentimento com pressão';

  @override
  String get learnUnclearPoliciesIntro1 =>
      'Algumas políticas de privacidade usam palavras soltas que dificultam saber o que acontece de fato com seus dados. Telas de consentimento também podem usar truques visuais, como um botão grande e brilhante \"Aceitar tudo\" ao lado de um link minúsculo \"Gerenciar configurações\", para pressionar você a concordar sem ler.';

  @override
  String get learnUnclearPoliciesStep1 =>
      'Sinais de névoa na política: fique atento a frases abertas como \"podemos compartilhar com parceiros confiáveis\", \"para fins comerciais\" ou \"manter conforme necessário\": elas deixam os detalhes reais de fora.';

  @override
  String get learnUnclearPoliciesStep2 =>
      'Silêncio não é promessa: se uma política nunca menciona microfone, anúncios ou localização, isso não garante que o app os evite.';

  @override
  String get learnUnclearPoliciesStep3 =>
      'Básico faltando: uma política transparente tem data de vigência clara, e-mail de contato e um documento único, não um anexo infantil escondido.';

  @override
  String get learnUnclearPoliciesStep4 =>
      'Consentimento sob pressão (padrões enganosos): botões gigantes \"Aceitar tudo\", caixas de marketing já marcadas, avisos insistentes e caminhos difíceis para cancelar servem para induzir sua escolha.';

  @override
  String get learnUnclearPoliciesStep5 =>
      'Escolha equilibrada: uma tela justa mostra botões iguais de \"Permitir\" e \"Não permitir\", com opções extras desmarcadas por padrão.';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      'Qual frase em uma política de privacidade é um sinal \"nebuloso\" de que faltam detalhes?';

  @override
  String get learnUnclearPoliciesQuizChoiceA =>
      'Não vendemos suas informações pessoais a terceiros';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      'Podemos compartilhar dados com parceiros confiáveis para fins comerciais';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'Você pode pedir exclusão escrevendo para privacy@example.com';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      'Certo: \"podemos compartilhar com parceiros confiáveis para fins comerciais\" é vago e não diz quem são os parceiros nem que dados são compartilhados.';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      'Não exatamente: essa frase é específica e útil. Frases nebulosas usam termos abertos como \"podemos compartilhar\" ou \"conforme necessário\" sem detalhes.';

  @override
  String get learnUnclearPoliciesDiagramClearTitle => 'Frase clara na política';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      'Coletamos seu nome e e-mail para criar sua conta. Não compartilhamos isso com anunciantes.';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle =>
      'Frase nebulosa na política';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      'Podemos compartilhar suas informações com parceiros confiáveis para fins comerciais conforme necessário.';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle => 'Como notar a névoa';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      'Procure \"pode\", \"poderia\" ou \"conforme necessário\": deixam a porta aberta.';

  @override
  String get learnUnclearPoliciesDiagramTip2 =>
      'Veja se a política cita o nome exato das empresas que recebem os dados.';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      'Silêncio sobre anúncios ou microfone não promete que o app os evite.';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote =>
      'Silêncio em uma política não é promessa.';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      'Comparação lado a lado entre uma frase clara e uma nebulosa. O cartão à esquerda \"Clara\" mostra: \"Coletamos seu nome e e-mail para criar sua conta. Não compartilhamos isso com anunciantes.\" O cartão à direita \"Nebulosa\" mostra: \"Podemos compartilhar suas informações com parceiros confiáveis para fins comerciais conforme necessário.\" Abaixo, o cartão \"Como notar a névoa\" lista três dicas: procure \"pode\", \"poderia\" ou \"conforme necessário\"; veja se a política cita empresas específicas; silêncio sobre anúncios ou microfone não é promessa. Uma nota diz \"Silêncio em uma política não é promessa.\" Deni espreita por cima dos cartões.';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      'Verifique um app neste telefone para conferir a tela de consentimento e a clareza da política.';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      'Esta lição descreve padrões pouco claros comuns. Ela não prova que um app específico use padrões enganosos ou esconda práticas de dados. Só ler a política exata e ver a tela real de consentimento pode mostrar isso.';

  @override
  String get learnSafeSharingFolderTitle => 'Compartilhamento seguro';

  @override
  String get learnSafeSharingTitle =>
      'Hábitos seguros de compartilhamento para crianças';

  @override
  String get learnSafeSharingSubtitle =>
      'Pare, Pense, Conecte: passos por idade para compartilhar online';

  @override
  String get learnSafeSharingIntro1 =>
      'Antes de postar uma foto, vídeo, seu nome ou localização, faça uma pausa e siga três passos: Pare, Pense, Conecte. Esta lição é para ler junto com um adulto de confiança. Crianças menores (5-7 anos) perguntam antes de tocar. Crianças de 8-11 usam apelidos e senhas fortes. Adolescentes (12-17) cuidam da pegada digital (o rastro do que você publica) e da verificação em duas etapas (uma segunda checagem, como um código, ao entrar).';

  @override
  String get learnSafeSharingStep1 =>
      'Pare: faça uma pausa antes de postar foto, vídeo, nome, escola ou localização. Pergunte a um adulto de confiança se tiver dúvida.';

  @override
  String get learnSafeSharingStep2 =>
      'Pense: isso revela minha escola, minha casa ou onde estou agora? Perguntei aos meus amigos antes de postar fotos deles ou marcá-los?';

  @override
  String get learnSafeSharingStep3 =>
      'Conecte: compartilhe apenas com pessoas em quem você confia. Mantenha privados dados pessoais como nome completo, aniversário, endereço e telefone.';

  @override
  String get learnSafeSharingStep4 =>
      'O teste do refeitório: eu ficaria bem se toda a escola (ou toda a minha turma) visse esta foto ou mensagem? Mesmo postagens que somem podem receber captura de tela e ficar online para sempre.';

  @override
  String get learnSafeSharingStep5 =>
      '5-7 anos: pergunte a um adulto de confiança antes de digitar seu nome ou tocar em avisos. 8-11 anos: use apelido (não nome real, aniversário nem escola), senhas fortes e nunca compartilhe códigos SMS ou OTP (códigos de uso único por mensagem: nunca compartilhe). 12-17 anos: revise configurações de privacidade, ative verificação em duas etapas e saiba como denunciar problemas.';

  @override
  String get learnSafeSharingQuizQuestion =>
      'O que é o \"teste do refeitório\" para compartilhar online?';

  @override
  String get learnSafeSharingQuizChoiceA =>
      'Compartilhar apenas coisas que você comeria no refeitório';

  @override
  String get learnSafeSharingQuizChoiceB =>
      'Perguntar: eu ficaria bem se toda a escola visse esta foto ou mensagem?';

  @override
  String get learnSafeSharingQuizChoiceC =>
      'Compartilhar apenas durante o intervalo do almoço';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      'Certo: o teste do refeitório significa perguntar a si mesmo se ficaria confortável com todo mundo vendo o que você publica.';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      'Não exatamente: o teste do refeitório é uma checagem mental: você ficaria bem se alguém mostrasse sua postagem para todo o refeitório?';

  @override
  String get learnSafeSharingDiagramStop =>
      'Pare: faça uma pausa antes de postar';

  @override
  String get learnSafeSharingDiagramThink =>
      'Pense: isso revela onde ou com quem estou?';

  @override
  String get learnSafeSharingDiagramConnect =>
      'Conecte: só com quem confia, pergunte a um adulto na dúvida';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      'O teste do refeitório: eu ficaria bem se toda a escola visse isso? Mesmo postagens que somem podem receber captura de tela e ficar online para sempre.';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      'Diagrama em quatro partes ensinando hábitos cuidadosos de compartilhamento. Etapa 1: Pare: faça uma pausa antes de postar, com ícone de mão. Etapa 2: Pense: isso revela onde ou com quem estou?, com ícone de cérebro. Etapa 3: Conecte: só com quem confia, pergunte a um adulto na dúvida, com ícone de pessoas. Etapa 4: o destaque do teste do refeitório pergunta \"Eu ficaria bem se toda a escola visse isso? Mesmo postagens que somem podem receber captura de tela e ficar online para sempre.\" Deni está ao lado com a mão levantada.';

  @override
  String get learnSafeSharingCheckBridge =>
      'Verifique um app junto com um responsável para ver como ele lida com compartilhamento.';

  @override
  String get learnSafeSharingHonestyNote =>
      'Esta lição traz hábitos gerais para compartilhar com cuidado. Ela não garante que algum app proteja o que você compartilha. Leia sempre a política do app e use as configurações de privacidade do seu telefone.';

  @override
  String get translationDraftNotice =>
      'Algumas traduções são rascunhos gerados por IA e podem conter erros. Falantes nativos estão revisando.';

  @override
  String get homeQuickSettingsTitle => 'Assistente das Configurações rápidas';

  @override
  String get homeQuickSettingsSubtitle =>
      'Pergunte ao Deni sobre o app que você está usando, a qualquer hora';

  @override
  String get appearanceSectionTitle => 'Aparência';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get quickSettingsSectionTitle =>
      'Conectar o Enprive às Configurações rápidas';

  @override
  String get quickSettingsSectionSubtitle =>
      'Adicione o Enprive Check ao painel de Configurações rápidas do Android para perguntar ao Deni sobre apps sem sair do que você está fazendo.';

  @override
  String get quickSettingsTileTitle => 'Bloco do Enprive Check';

  @override
  String get quickSettingsTileSubtitle =>
      'Adicione o Enprive Check às Configurações rápidas para perguntar ao Deni sobre o app que você está usando, sem precisar procurar o Enprive antes.';

  @override
  String get quickSettingsStatusAdded => 'Adicionado';

  @override
  String get quickSettingsStatusManual => 'Manual';

  @override
  String get quickSettingsStatusNotAdded => 'Não adicionado';

  @override
  String get usageAccessStatusGranted => 'Concedido';

  @override
  String get usageAccessStatusNotGranted => 'Não concedido';

  @override
  String get usageAccessTitle => 'Permitir o Acesso ao uso (opcional)';

  @override
  String get usageAccessExplanation =>
      'O Enprive usa o Acesso ao uso apenas quando você toca em Enprive Check, para identificar o app que você acabou de usar. Isso ajuda o Deni a encontrar o app certo e as informações de privacidade dele. O Enprive não monitora sua tela o tempo todo.';

  @override
  String get usageAccessManageLink => 'Como gerenciar ou revogar';

  @override
  String get usageAccessManageTitle => 'Gerenciar ou revogar o Acesso ao uso';

  @override
  String get usageAccessManageBody =>
      'O Acesso ao uso é uma chave especial nos Ajustes do Android (não é um pop-up automático). Você pode desativá-lo a qualquer momento em Ajustes do Android → Apps → Acesso especial a apps → Acesso ao uso → enprive. O Deni continua funcionando sem ele, com a escolha manual do app.';

  @override
  String get openDeniCompanionTitle => 'Abrir o assistente Deni';

  @override
  String get openDeniCompanionSubtitle =>
      'Veja as permissões de um app recente ou escolhido por você, sem usar as Configurações rápidas.';

  @override
  String get btnGotIt => 'Entendi';

  @override
  String get quickSettingsReadyDialogTitle =>
      'O Enprive Check está pronto nas Configurações rápidas';

  @override
  String get quickSettingsReadyDialogBody =>
      'Deslize duas vezes para baixo a partir do topo da tela e toque em \"Enprive Check\" sempre que quiser que o Deni explique as permissões de um app.';

  @override
  String get quickSettingsManualDialogTitle =>
      'Adicionar o Enprive Check manualmente';

  @override
  String get quickSettingsManualDialogBody =>
      '1. Deslize duas vezes para baixo a partir do topo da tela do Android para abrir as Configurações rápidas.\n2. Toque no botão Editar (lápis).\n3. Encontre \"Enprive Check\" e arraste para os blocos ativos das Configurações rápidas.';

  @override
  String get quickSettingsSnackAdded =>
      'O Enprive Check foi adicionado às suas Configurações rápidas.';

  @override
  String get quickSettingsSnackAlreadyAdded =>
      'O Enprive Check já está nas suas Configurações rápidas.';

  @override
  String get quickSettingsSnackDeclined =>
      'Pedido dispensado. O Enprive não vai perguntar de novo, a menos que você escolha Editar nas Configurações rápidas.';

  @override
  String get quickSettingsSnackManual =>
      'Deslize as Configurações rápidas para baixo, toque em Editar e arraste o Enprive Check para os seus blocos.';

  @override
  String get quickSettingsSnackUnavailable =>
      'O pedido do sistema não está disponível aqui: você pode arrastar o Enprive Check manualmente em Editar, nas Configurações rápidas.';

  @override
  String get usageAccessOpenFailedSnack =>
      'Não foi possível abrir os ajustes de Acesso ao uso neste dispositivo.';

  @override
  String get companionTitle => 'Deni: assistente do Enprive';

  @override
  String get companionSubtitle =>
      'Pergunte ao Deni sobre as permissões de um app e o que a política de privacidade dele diz.';

  @override
  String get companionTooltipReturnToPrev => 'Voltar ao app anterior';

  @override
  String get companionTooltipBack => 'Voltar';

  @override
  String get companionLockedBadge => 'TELA BLOQUEADA PROTEGIDA';

  @override
  String get companionLockedTitle => 'Desbloqueie o telefone para continuar';

  @override
  String get companionLockedBody =>
      'Enquanto o dispositivo está bloqueado, o Enprive oculta nomes de apps, permissões declaradas e evidências da análise.';

  @override
  String get companionCheckUnlockBtn => 'Verificar o estado de bloqueio';

  @override
  String get companionCheckingAppHeadline =>
      'Verificando qual app você estava usando…';

  @override
  String get companionCheckingAppSubtitle =>
      'A verificação é feita uma vez neste telefone, sem observar a sua tela.';

  @override
  String get companionGeneralGuideHeadline =>
      'Guia geral de permissões do Android';

  @override
  String get companionGeneralGuideSubtitle =>
      'Nenhum app selecionado. O Enprive explica as permissões do Android usando apenas orientações locais.';

  @override
  String companionLookingAtHeadline(String appName) {
    return 'Você está olhando para $appName.';
  }

  @override
  String get companionLookingAtSubtitle =>
      'As permissões listadas abaixo vêm do app no seu telefone. O Android continua controlando o pop-up que aparece na tela.';

  @override
  String get companionThisAppFallback => 'este app';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return 'Vimos $appName há $seconds s. Está correto?';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return 'Achamos que você está usando $appName. Está correto?';
  }

  @override
  String companionAppIdLine(String packageName) {
    return 'App ID: $packageName';
  }

  @override
  String companionConfirmAppBtn(String appName) {
    return 'Confirmar · $appName';
  }

  @override
  String get companionChooseAnotherAppBtn => 'Escolher outro app';

  @override
  String get companionWithoutAppContextBtn => 'Sem contexto de app';

  @override
  String get companionMultipleAppsTitle =>
      'Vários apps estavam ativos agora há pouco';

  @override
  String get companionMultipleAppsPrompt =>
      'Confirme qual app você quer verificar:';

  @override
  String companionSecondsAgo(int seconds) {
    return 'há $seconds s';
  }

  @override
  String get companionSelectAppTitle =>
      'Selecione o app que você quer verificar';

  @override
  String get companionSelectAppBody =>
      'Escolha o app manualmente entre os instalados ou continue sem contexto de app.';

  @override
  String get companionChooseAppManuallyBtn => 'Escolher o app manualmente';

  @override
  String get companionOpenUsageAccessBtn => 'Abrir ajustes de Acesso ao uso';

  @override
  String get companionContinueWithoutAppBtn => 'Continuar sem contexto de app';

  @override
  String get companionAddTileBtn => 'Adicionar o bloco Enprive Check';

  @override
  String get companionContinuingWithoutApp => 'Continuando sem contexto de app';

  @override
  String get companionSwitchAppBtn => 'Trocar de app';

  @override
  String get companionPermissionsReadLocally =>
      'As permissões mostradas abaixo são lidas diretamente do seu telefone.';

  @override
  String get companionPickPermissionType =>
      'Escolha um tipo de permissão para explorar';

  @override
  String get companionPickAppBtn => 'Escolher um app';

  @override
  String get companionCouldNotReadPermsTitle =>
      'Não foi possível ler as permissões do app';

  @override
  String get companionCouldNotReadPermsBody =>
      'O Android impediu a verificação das permissões deste app.';

  @override
  String get companionUnsurePermBtn => 'Não sei qual permissão';

  @override
  String get companionWhichPermissionPrompt =>
      'Qual permissão você quer entender?';

  @override
  String get companionPermissionsListDisclaimer =>
      'Estas são as permissões que o app lista no seu telefone, não necessariamente o pop-up que está na sua tela agora.';

  @override
  String get companionNoSensitivePermsMsg =>
      'Este app não pede nenhuma permissão sensível no seu telefone.';

  @override
  String get companionGuidedMatchTitle =>
      'Escolha o que o pop-up na sua tela pediu';

  @override
  String get companionGuidedMatchSubtitle =>
      'O Enprive não consegue ler diretamente o pedido atual do Android. Escolha o texto mais parecido com o que apareceu na tela:';

  @override
  String get companionSection1Title => '1. O que esta permissão significa';

  @override
  String get companionSection2Title => '2. O que o app pede no seu telefone';

  @override
  String get companionSection3Title =>
      '3. O que a política de privacidade dele diz';

  @override
  String get companionSection4Title =>
      '4. Por que isso pode estar ligado a um recurso';

  @override
  String get companionSection4Fallback =>
      'Nenhuma explicação verificada do desenvolvedor sobre um recurso foi encontrada. Descreva abaixo qual recurso você queria usar se quiser que o Deni verifique a relevância.';

  @override
  String get companionSection5Title => '5. O que continua desconhecido';

  @override
  String get companionSection6Title =>
      '6. Perguntas que você pode fazer ao Deni';

  @override
  String get companionAddPolicyBtn => 'Adicionar política de privacidade';

  @override
  String get companionCheckUpdatedPolicyBtn =>
      'Verificar política de privacidade atualizada';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return 'Verificar a política de $appName';
  }

  @override
  String get companionFeatureFieldLabel =>
      'Recurso que você estava usando (opcional)';

  @override
  String get companionFeatureFieldHint =>
      'ex.: escanear um QR code, gravar um treino de voz';

  @override
  String get companionQuestionFieldLabel => 'Faça uma pergunta ao Deni';

  @override
  String get companionQuestionFieldHint =>
      'O que acontece se eu negar esta permissão?';

  @override
  String get companionReceiptSavedTitle => 'Salvo nos Recibos do Enprive';

  @override
  String get companionReceiptUnsavedTitle =>
      'Análise ainda não salva no Enprive';

  @override
  String get companionReceiptSavedBody =>
      'Guardado localmente no seu arquivo de Recibos do Enprive.';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      'A análise da política atualizada fica apenas nesta sessão. Ao sair do Assistente, este rascunho é descartado e o recibo salvo permanece inalterado.';

  @override
  String get companionReceiptUnsavedBody =>
      'Fica apenas nesta sessão. Ao sair do Assistente, ela será descartada, a menos que você a salve.';

  @override
  String get companionSaveReceiptBtn => 'Salvar recibo no Enprive';

  @override
  String get companionSaveReceiptFailed =>
      'Não foi possível salvar o recibo. Ele continua nesta sessão: tente de novo.';

  @override
  String get companionSavedLocalReceiptsSnack => 'Salvo nos Recibos locais.';

  @override
  String companionDoneReturnToApp(String appName) {
    return 'Concluído · Voltar para $appName';
  }

  @override
  String get companionDoneReturnToPrev => 'Concluído · Voltar ao app anterior';

  @override
  String get companionOpenFullAppBtn => 'Abrir o app Enprive completo';

  @override
  String get companionCloudTimeoutSnack =>
      'A análise na nuvem demorou demais e foi interrompida antes de terminar.';

  @override
  String get companionAnalysisCancelledSnack => 'Análise cancelada.';

  @override
  String get companionCloudAnswerTimeoutSnack =>
      'A resposta da nuvem expirou sem problemas.';

  @override
  String get companionQuestionCancelledSnack => 'Pergunta cancelada.';

  @override
  String get companionTileAddedSnack =>
      'O Enprive Check foi adicionado às Configurações rápidas do Android.';

  @override
  String get companionTileAlreadyAddedSnack =>
      'O Enprive Check já está nas suas Configurações rápidas.';

  @override
  String get companionTileDeclinedSnack =>
      'Pedido do bloco dispensado. Você pode adicioná-lo a qualquer hora em Ajustes ou em Editar nas Configurações rápidas.';

  @override
  String get companionTileManualSnack =>
      'Deslize as Configurações rápidas para baixo duas vezes, toque em Editar e arraste o Enprive Check para os seus blocos.';

  @override
  String get companionTileUnavailableSnack =>
      'O Android não conseguiu mostrar o pedido das Configurações rápidas neste dispositivo. Você pode arrastar o Enprive Check manualmente em Editar, nas Configurações rápidas.';

  @override
  String get companionUsageOptionalReason =>
      'O Acesso ao uso é opcional. Você pode escolher um app manualmente ou permitir o Acesso ao uso para identificá-lo com um toque.';

  @override
  String get companionPermPreciseLocation => 'Localização precisa';

  @override
  String get companionPermBackgroundLocation => 'Localização em segundo plano';

  @override
  String get companionPermCamera => 'Câmera';

  @override
  String get companionPermMicrophone => 'Microfone';

  @override
  String get companionPermAdId => 'ID de publicidade do Google';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return 'Permissão do Android ($permission) declarada por $appName.';
  }

  @override
  String get companionPermStatusAdId => 'Listada pelo app · ID de publicidade';

  @override
  String get companionPermStatusAllowed => 'Listada pelo app · Permitida';

  @override
  String get companionPermStatusNotAllowed =>
      'Listada pelo app · Não permitida';

  @override
  String get guidedCatLocation => 'Localização';

  @override
  String get guidedCatContacts => 'Contatos';

  @override
  String get guidedCatPhotosMedia => 'Fotos e mídia';

  @override
  String get guidedCatNotifications => 'Notificações';

  @override
  String get guidedCatNearbyDevices => 'Dispositivos por perto';

  @override
  String get guidedCatCalendar => 'Agenda';

  @override
  String get guidedCatPhone => 'Telefone';

  @override
  String get guidedCatSms => 'SMS';

  @override
  String get companionFallbackUsageNotEnabled =>
      'O Acesso ao uso não foi ativado nos Ajustes do Android.';

  @override
  String get companionFallbackUsageUnavailable =>
      'O UsageStatsManager do Android não está disponível.';

  @override
  String get companionFallbackTransientUi =>
      'Nos eventos de uso recentes apareceram apenas telas do sistema Android ou pedidos de permissão. Escolha o app manualmente.';

  @override
  String get companionFallbackVisibilityRestricted =>
      'O app usado mais recentemente não pode ser verificado por causa das restrições de visibilidade de pacotes do Android. Escolha um app da lista ou cole a política dele.';

  @override
  String get companionFallbackUnlockRequired =>
      'Desbloqueie o dispositivo antes de ver o contexto do app.';

  @override
  String get consentReasonPolicyTooDetailed =>
      'Esta política é detalhada demais para o processamento por IA no dispositivo.';

  @override
  String get consentReasonExcerptTooDetailed =>
      'Este trecho do achado é detalhado demais para o processamento por IA no dispositivo.';

  @override
  String get consentReasonOnDeviceUnavailable =>
      'A IA no dispositivo não está disponível neste telefone agora.';

  @override
  String get consentReasonOnDeviceCannotAnswer =>
      'A IA no dispositivo não conseguiu responder a partir deste dispositivo agora.';

  @override
  String get consentReasonVoiceTooLong =>
      'Estes achados verificados passam dos limites do resumo no dispositivo. Você pode usar o resumo offline agora ou enviar os achados com dados ocultados para a IA na nuvem uma única vez.';

  @override
  String get consentReasonVoiceUnavailable =>
      'A IA no dispositivo não está disponível neste telefone agora. Mostrando o resumo offline em linguagem simples do Enprive.';

  @override
  String get consentReasonVoiceTimedOut =>
      'O resumo no dispositivo demorou demais. Mostrando o resumo offline em linguagem simples do Enprive.';

  @override
  String get unsavedExitTitle => 'Salvar esta análise de privacidade?';

  @override
  String get unsavedExitModifiedBody =>
      'Análises não salvas são descartadas quando você fecha esta tela, então nada fica guardado no seu telefone sem a sua escolha. O recibo salvo originalmente permanece inalterado.';

  @override
  String get unsavedExitDraftBody =>
      'Análises não salvas são descartadas quando você fecha esta tela, então nada fica guardado no seu telefone sem a sua escolha.';

  @override
  String get unsavedExitDiscardBtn => 'Descartar sem salvar';

  @override
  String get unsavedExitContinueBtn => 'Continuar analisando';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return 'Atualizar a política de privacidade de $title';
  }

  @override
  String get reviewSaveFailedError =>
      'Não foi possível salvar o recibo. O rascunho da análise continua aberto.';

  @override
  String get reviewRemovedFromReceiptsSnack => 'Removido dos recibos salvos.';

  @override
  String get reviewRemoveFailedSnack =>
      'Não foi possível remover o recibo salvo.';

  @override
  String get reviewModifiedDraftTitle =>
      'Novo rascunho a partir do recibo salvo';

  @override
  String get reviewModifiedDraftBody =>
      'Salve nos Recibos para guardar esta análise atualizada: o recibo salvo originalmente permanece inalterado.';

  @override
  String get btnRetrySave => 'Tentar salvar de novo';

  @override
  String get sourceKindUrl => 'Link público da web';

  @override
  String get sourceKindPdf => 'Arquivo PDF local';

  @override
  String get sourceKindDocx => 'Arquivo Word (DOCX) local';

  @override
  String get sourceKindTextFile => 'Arquivo de texto local';

  @override
  String get sourceKindSharedText => 'Texto compartilhado';

  @override
  String get sourceKindSelectedText => 'Texto selecionado';

  @override
  String get sourceKindPhonePermissions => 'Permissões do telefone';

  @override
  String get sourceKindPastedText => 'Texto colado';

  @override
  String get extractionStatusExtracted => 'Lido neste telefone';

  @override
  String get extractionStatusNone => 'Fornecido neste telefone';

  @override
  String get extractionStatusUnsupported => 'Tipo de arquivo não compatível';

  @override
  String get extractionStatusTooLarge => 'Arquivo grande demais';

  @override
  String get extractionStatusEmpty => 'Nenhum texto legível';

  @override
  String get extractionStatusReadError => 'Não foi possível ler o arquivo';

  @override
  String get extractionStatusPasswordProtected => 'Protegido por senha';

  @override
  String get extractionStatusPermissionDenied => 'Permissão negada';

  @override
  String get extractionStatusCancelled => 'Cancelado';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return 'Verificado em: $timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return 'URL canônica: $url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return 'Redirecionado de: $url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return 'Arquivo: $filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return 'Status: $status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return 'Hash SHA-256 da fonte: $hash';
  }

  @override
  String get semanticsPrimaryNavigation => 'Navegação principal';

  @override
  String semanticsProcessingLocation(String label) {
    return 'Onde é processado: $label';
  }

  @override
  String get semanticsDeniMascot => 'Deni, seu guia de privacidade';

  @override
  String get quoteCollapsibleDefaultHeader => 'Trecho exato da política';
}
