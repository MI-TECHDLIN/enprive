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
      'Um ou mais trechos ou divergências de permissões merecem uma análise humana.';

  @override
  String get stateInsufficientEvidence => 'Evidências insuficientes';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Faltam evidências, elas estão indisponíveis ou não puderam ser verificadas neste dispositivo.';

  @override
  String get chipOnDevice => 'Neste dispositivo';

  @override
  String get chipInCloud => 'Na nuvem';

  @override
  String get chipLocationUnavailable => 'Local de processamento indisponível';

  @override
  String get statusSourceMatched => 'Trecho confirmado';

  @override
  String get statusDeviceObserved => 'Observado no dispositivo';

  @override
  String get statusInterpretation => 'Interpretação';

  @override
  String get statusUnverified => 'Não verificado';

  @override
  String get statusStale => 'Desatualizado';

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
      'Para analisar este texto na nuvem, o Enprive enviará apenas o texto mostrado abaixo ao Firebase AI Logic. Sua lista de aplicativos instalados e permissões do Android nunca serão enviadas.';

  @override
  String get permissionLimitationNotice =>
      'O Android relata este estado de permissão neste telefone. Isso não comprova se o app realmente acessou ou transmitiu dados.';

  @override
  String get navHome => 'Início';

  @override
  String get navReceipts => 'Recibos';

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
      'Destaca cláusulas de compartilhamento, gravação de voz e retenção com trechos literais.';

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
      other: '$count cláusulas verificadas',
      one: '1 cláusula verificada',
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
  String get readinessRow3Title => 'Dados pessoais ocultados';

  @override
  String get readinessRow3Desc =>
      'Se a IA local não estiver disponível ou o texto for longo, nomes, e-mails e telefones viram marcadores antes da verificação com App Check.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get privateAnalysisTitle => 'Análise privada neste telefone';

  @override
  String get onDeviceReadyMsg => 'A IA no dispositivo está ativa e pronta.';

  @override
  String get localScannerProtectedMsg =>
      'Protegido pelo leitor local de cláusulas integrado.';

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
      'O Gemini Nano está pronto neste telefone. As análises ficam totalmente no dispositivo.';

  @override
  String get modelDownloadingMsg =>
      'Baixando o modelo privado no dispositivo em segundo plano.';

  @override
  String get modelDownloadableMsg =>
      'O modelo no dispositivo pode ser baixado por Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'Este telefone usa por padrão o leitor local de cláusulas integrado do Enprive.';

  @override
  String get preparingPrivateAnalysis => 'Preparando análise privada…';

  @override
  String get onDeviceAiReadyTitle => 'IA no dispositivo pronta';

  @override
  String get localScannerActiveTitle => 'Leitor local ativo';

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
      'Lendo cláusulas da política neste telefone…';

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
  String get thoughtSignaturePrefix => 'Assinatura de raciocínio';

  @override
  String get viewStreamedThoughts => 'Ver raciocínio transmitido';

  @override
  String get hideStreamedThoughts => 'Ocultar raciocínio';

  @override
  String get analysisTraceDefaultTitle => 'Como esta análise foi verificada';

  @override
  String get savedToLocalReceiptsSnack => 'Salvo nos seus recibos locais.';

  @override
  String get snapshotSheetTitle => 'Cópia da política analisada';

  @override
  String get snapshotSourcePrefix => 'Fonte';

  @override
  String get snapshotReviewedPrefix => 'Analisado';

  @override
  String get snapshotDigestPrefix => 'Resumo';

  @override
  String get statFindings => 'Achados';

  @override
  String get statVerified => 'Verificados';

  @override
  String get statOsGranted => 'Concedidas OS';

  @override
  String get statUnverified => 'Não verificados';

  @override
  String get keyFindingsTitle => 'Principais achados';

  @override
  String get reviewedExcerptTitle => 'Trecho analisado';

  @override
  String get permissionsOnPhoneTitle => 'Permissões neste telefone';

  @override
  String get viewReviewedSnapshot => 'Ver texto completo analisado';

  @override
  String get btnSavedToReceipts => 'Salvo em Recibos';

  @override
  String get observedOnPhoneLabel => 'Observado neste telefone';

  @override
  String get quoteVerifiedLabel => 'Citação confirmada na política';

  @override
  String get unverifiedClaimLabel => 'Afirmação não verificada';

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
  String get labelWhatRemainsUnknown => 'O que continua desconhecido';

  @override
  String get presetQuestionMeaning => 'O que isso significa para meu filho?';

  @override
  String get presetQuestionOptOut => 'Podemos desativar ou recusar isso?';

  @override
  String get presetQuestionUnknown => 'O que ainda não está claro aqui?';

  @override
  String get readingCitedClause => 'Lendo a cláusula citada…';

  @override
  String get deniAnswerTitle => 'Resposta do Deni';

  @override
  String get stepsAndReasoning => 'Etapas e raciocínio do modelo';

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
}
