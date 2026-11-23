// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => 'Revisiones de privacidad basadas en pruebas';

  @override
  String get homePrivacySubtitle =>
      'Tus revisiones permanecen en este teléfono.';

  @override
  String get stateNoConcern => 'Sin preocupaciones detectadas';

  @override
  String get stateNoConcernSubtitle =>
      'No hay nada preocupante en las pruebas revisadas. Esto no es una certificación de seguridad.';

  @override
  String get stateReviewRecommended => 'Revisión recomendada';

  @override
  String get stateReviewRecommendedSubtitle =>
      'Una o más partes de la política o permisos del teléfono merecen una mirada más cercana.';

  @override
  String get stateInsufficientEvidence => 'Pruebas insuficientes';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Necesitamos más texto de la política de privacidad antes de poder revisar qué hace esta app.';

  @override
  String get chipOnDevice => 'En este dispositivo';

  @override
  String get chipInCloud => 'En la nube';

  @override
  String get chipLocationUnavailable => 'Fuente no disponible';

  @override
  String get chipOfflineDeterministic =>
      'Revisado sin conexión en este teléfono';

  @override
  String get chipUnknown => 'Fuente desconocida';

  @override
  String get statusSourceMatched => 'Coincide con la política';

  @override
  String get statusDeviceObserved => 'Visto en este teléfono';

  @override
  String get statusInterpretation => 'Explicación de Deni';

  @override
  String get statusUnverified => 'No encontrado en la política';

  @override
  String get statusStale => 'Revisión anterior';

  @override
  String get btnCheckApp => 'Revisar una app';

  @override
  String get btnPasteTerms => 'Pegar términos o URL';

  @override
  String get btnWhyThisFinding => '¿Por qué este hallazgo?';

  @override
  String get btnSaveToReceipts => 'Guardar en recibos';

  @override
  String get btnDiscard => 'Descartar';

  @override
  String get btnAskDeni => 'Preguntar a Deni';

  @override
  String get btnUseCloud => 'Usar la nube para esta revisión';

  @override
  String get btnReviewManually => 'Revisar manualmente';

  @override
  String get btnGetStarted => 'Comenzar';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get deniIntro =>
      'Hola, soy Deni. Puedo ayudarte a entender qué dice esta política de privacidad, mostrarte las pruebas detrás de cada punto y explicar lo que Enprive no pudo verificar.';

  @override
  String get cloudConsentDisclosure =>
      'Para revisar esto en la nube, Enprive enviará solo el texto mostrado arriba (con los datos personales ocultos) para esta única solicitud. Tus apps y permisos del teléfono nunca se enviarán.';

  @override
  String get permissionLimitationNotice =>
      'Tu teléfono muestra si este permiso está permitido. No prueba si la app realmente accedió a datos o los envió.';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCheck => 'Revisar';

  @override
  String get navReceipts => 'Recibos';

  @override
  String get navLearn => 'Aprender';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get chooseLanguage => 'Elegir idioma';

  @override
  String get languageSubtitle =>
      'Se aplica a la interfaz, explicaciones y lectura en voz alta';

  @override
  String get homeHeroHeadline =>
      'Una mirada más clara a las\napps que usan los niños';

  @override
  String get trySampleCheck => 'Prueba una revisión de ejemplo';

  @override
  String get eduTrackSubtitle => 'Tareas y asistencia';

  @override
  String get eduTrackValue => '3 solicitudes';

  @override
  String get eduTrackTrend => 'Revisar';

  @override
  String get calmMathSubtitle => 'Práctica de matemáticas sin conexión';

  @override
  String get calmMathValue => '0 sensibles';

  @override
  String get calmMathTrend => 'Mínimo';

  @override
  String get whatWeCheckTitle => 'Qué analizamos';

  @override
  String get checkQuoteTitle => 'Citas exactas de la política';

  @override
  String get checkQuoteDesc =>
      'Destaca el uso compartido de datos, la grabación de voz y cuánto tiempo se conservan los datos usando citas exactas.';

  @override
  String get checkPermissionTitle => 'Diferencias en permisos del teléfono';

  @override
  String get checkPermissionDesc =>
      'Compara el acceso a Cámara, Micrófono y Ubicación con lo declarado en la política.';

  @override
  String get checkSelectTitle => 'Selecciona texto donde sea';

  @override
  String get checkSelectDesc =>
      'Resalta términos en cualquier app y toca Enprive Check en el menú de Android.';

  @override
  String get recentlyReviewed => 'Revisados recientemente';

  @override
  String verifiedClausesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citas coincidentes',
      one: '1 cita coincidente',
    );
    return '$_temp0';
  }

  @override
  String get trySampleText => 'Probar texto de ejemplo';

  @override
  String get modePasteText => 'Pegar texto';

  @override
  String get modePolicyLink => 'Enlace de política';

  @override
  String get hintAppName => 'Nombre de la app';

  @override
  String get defaultSubjectTitle => 'Política de privacidad';

  @override
  String get selectedExcerptTitle => 'Extracto de política seleccionado';

  @override
  String get hintPastePolicy =>
      'Pega aquí el texto de la política de privacidad…';

  @override
  String get btnReviewOnPhone => 'Revisar en este teléfono';

  @override
  String get onboardingIntroHeadline => 'Hola, soy Deni. 👋';

  @override
  String get onboardingIntroLead =>
      'Hagamos que la privacidad de las apps sea más fácil de entender.';

  @override
  String get onboardingIntroBody =>
      'Te ayudaré a descubrir qué dice realmente la política de privacidad de una app, resaltaré los pasajes exactos que importan y te explicaré lo que informa tu dispositivo.\n\nSin suposiciones ni falsas promesas. Solo explicaciones claras y pruebas para tomar decisiones informadas.';

  @override
  String get onboardingIntroFooter =>
      'Sabe exactamente a qué das tu consentimiento.';

  @override
  String get splashQuote => 'Sabe exactamente a qué das tu consentimiento';

  @override
  String get onboardingStep1Question =>
      '¿Cómo prefieres que explique\nlos términos de privacidad?';

  @override
  String get depthQuickMultiline => 'Rápido y\nsencillo';

  @override
  String get depthBalancedMultiline => 'Vista\nequilibrada';

  @override
  String get depthFullMultiline => 'Detalle\ncompleto';

  @override
  String get onboardingReadinessTitle =>
      'Privado por defecto\nen este teléfono';

  @override
  String get onboardingReadinessSubtitle =>
      'Diseñado para que madres, padres y docentes revisen apps sin compartir datos del dispositivo.';

  @override
  String get readinessRow1Title => 'Revisado aquí primero';

  @override
  String get readinessRow1Desc =>
      'Las políticas se leen primero en tu teléfono antes que nada.';

  @override
  String get readinessRow2Title => 'Tus apps se quedan contigo';

  @override
  String get readinessRow2Desc =>
      'Las apps instaladas y los permisos de este teléfono nunca salen de él.';

  @override
  String get readinessRow3Title => 'Datos personales ocultos';

  @override
  String get readinessRow3Desc =>
      'Si eliges ayuda en la nube, los nombres, correos y números de teléfono se ocultan antes de enviar nada.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get privateAnalysisTitle => 'Análisis privado en este teléfono';

  @override
  String get onDeviceReadyMsg => 'La IA en el dispositivo está activa y lista.';

  @override
  String get localScannerProtectedMsg =>
      'Listo para revisar políticas sin conexión en este teléfono.';

  @override
  String get statusChecking => 'Comprobando…';

  @override
  String get btnCheckReadiness => 'Comprobar estado';

  @override
  String get howShouldDeniExplain => '¿Cómo debe explicar Deni?';

  @override
  String get depthQuick => 'Rápido';

  @override
  String get depthBalanced => 'Equilibrado';

  @override
  String get depthFull => 'Detallado';

  @override
  String get preferencesSection => 'Preferencias';

  @override
  String get meetDeniGuide => 'Conoce a Deni y guía inicial';

  @override
  String clearSavedReceiptsCount(int count) {
    return 'Borrar recibos guardados ($count)';
  }

  @override
  String get btnClear => 'Borrar';

  @override
  String get confirmClearReceiptsTitle => '¿Borrar los recibos guardados?';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esto eliminará $count revisiones guardadas de tu teléfono.',
      one: 'Esto eliminará 1 revisión guardada de tu teléfono.',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get receiptsTitle => 'Recibos';

  @override
  String get tooltipSearch => 'Buscar';

  @override
  String get hintSearchReceipts => 'Buscar revisiones guardadas...';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterReview => 'Revisar';

  @override
  String get filterNoConcern => 'Sin alerta';

  @override
  String get emptyFilteredTitle => 'No hay recibos coincidentes';

  @override
  String get emptyReceiptsTitle => 'Aún no hay recibos guardados';

  @override
  String get emptyFilteredBody => 'Prueba seleccionando otro filtro arriba.';

  @override
  String get emptyReceiptsBody =>
      'Marca cualquier revisión para guardar una copia privada en tu teléfono.';

  @override
  String get btnStartReview => 'Iniciar una revisión';

  @override
  String get btnOpenReceipt => 'Abrir recibo';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get checkingPhoneReadiness =>
      'Comprobando la disponibilidad de análisis privado en este teléfono…';

  @override
  String get geminiNanoReadyMsg =>
      'La IA en el dispositivo está lista en este teléfono. Las revisiones se quedan completamente en tu dispositivo.';

  @override
  String get modelDownloadingMsg =>
      'Descargando el modelo privado en segundo plano.';

  @override
  String get modelDownloadableMsg =>
      'El modelo en el dispositivo puede descargarse por Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'Este teléfono revisa políticas sin conexión en tu dispositivo de forma predeterminada.';

  @override
  String get preparingPrivateAnalysis => 'Preparando análisis privado…';

  @override
  String get onDeviceAiReadyTitle => 'IA en el dispositivo lista';

  @override
  String get localScannerActiveTitle => 'Revisión sin conexión lista';

  @override
  String get privateAnalysisSheetSubtitle =>
      'Tus apps instaladas y permisos nunca salen de tu teléfono.';

  @override
  String get btnDone => 'Listo';

  @override
  String get btnCheckAgain => 'Comprobar de nuevo';

  @override
  String get reviewingOnPhone => 'Revisando en este teléfono…';

  @override
  String get readingClausesInitial =>
      'Leyendo el texto de la política en este teléfono…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current de $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get thoughtSignaturePrefix => 'ID de revisión';

  @override
  String get viewStreamedThoughts => 'Cómo revisó Enprive esto';

  @override
  String get hideStreamedThoughts => 'Ocultar cómo revisó Enprive esto';

  @override
  String get analysisTraceDefaultTitle => 'Cómo se verificó esta revisión';

  @override
  String get savedToLocalReceiptsSnack => 'Guardado en tus recibos locales.';

  @override
  String get snapshotSheetTitle => 'Texto de la política revisada';

  @override
  String get snapshotSourcePrefix => 'Fuente';

  @override
  String get snapshotReviewedPrefix => 'Revisado';

  @override
  String get snapshotDigestPrefix => 'Huella del documento';

  @override
  String get statFindings => 'Hallazgos';

  @override
  String get statVerified => 'Verificados';

  @override
  String get statOsGranted => 'Permitido en el teléfono';

  @override
  String get statUnverified => 'No encontrado';

  @override
  String get keyFindingsTitle => 'Hallazgos clave';

  @override
  String get reviewedExcerptTitle => 'Extracto revisado';

  @override
  String get permissionsOnPhoneTitle => 'Permisos en este teléfono';

  @override
  String get viewReviewedSnapshot => 'Ver texto de la política revisada';

  @override
  String get btnSavedToReceipts => 'Guardado en recibos';

  @override
  String get observedOnPhoneLabel => 'Visto en este teléfono';

  @override
  String get quoteVerifiedLabel => 'Cita exacta de la política';

  @override
  String get unverifiedClaimLabel => 'No encontrado en la política';

  @override
  String get categoryDataCollection => 'Recopilación de datos';

  @override
  String get categorySharing => 'Uso compartido con terceros';

  @override
  String get categoryTracking => 'Ubicación y seguimiento';

  @override
  String get categoryRetention => 'Retención y voz';

  @override
  String get categoryParentalControls => 'Controles parentales';

  @override
  String get labelInPlainLanguage => 'En lenguaje sencillo';

  @override
  String get labelOnThisPhone => 'En este teléfono';

  @override
  String get labelWhatRemainsUnknown => 'Lo que aún no sabemos';

  @override
  String get presetQuestionMeaning =>
      '¿Qué significa esto para mi hijo o hija?';

  @override
  String get presetQuestionOptOut => '¿Podemos desactivar esto o rechazarlo?';

  @override
  String get presetQuestionUnknown => '¿Qué sigue sin quedar claro aquí?';

  @override
  String get readingCitedClause => 'Leyendo la cita de la política…';

  @override
  String get deniAnswerTitle => 'Respuesta de Deni';

  @override
  String get stepsAndReasoning => 'Cómo revisó Deni esto';

  @override
  String get chooseReviewModeTitle => 'Elige cómo revisar este texto';

  @override
  String get cloudNeverSendsAppsNote =>
      'Las apps instaladas y los permisos del teléfono nunca se envían.';

  @override
  String get tooltipClose => 'Cerrar';

  @override
  String get checkAppSheetSubtitle =>
      'Comprobado localmente en tu teléfono. Tu lista de apps nunca se sube.';

  @override
  String get trySampleKidsApp => 'Prueba una app infantil de ejemplo';

  @override
  String get sampleEduTrackSubtitle => 'Ubicación, micrófono y cámara';

  @override
  String get sampleCalmMathSubtitle => 'Matemáticas sin conexión';

  @override
  String get appsOnThisPhone => 'Apps en este teléfono';

  @override
  String get hintSearchApps => 'Buscar apps…';

  @override
  String get noMatchingApps =>
      'No se encontraron apps coincidentes en este teléfono.';

  @override
  String get sampleSyntheticBadge => 'App de ejemplo';

  @override
  String get permissionInspectionTitle => 'Permisos del teléfono revisados';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Añadir la política de privacidad de esta app';

  @override
  String get snapshotDigestLabel => 'Huella del documento';

  @override
  String get snapshotDigestExplanation =>
      'Un código único que ayuda a comprobar que este es el texto exacto que revisó Enprive. Si cambia una sola letra, este código también cambia.';

  @override
  String get copyDigestBtn => 'Copiar huella';

  @override
  String get digestCopiedMsg => 'Huella del documento copiada';

  @override
  String get permissionGrantedBadge => 'Permitido en este teléfono';

  @override
  String get permissionNotGrantedBadge => 'No permitido';

  @override
  String get checkingPolicyWithCloudAi =>
      'Revisando la política con IA en la nube.';

  @override
  String get preparingCloudAiStream =>
      'Ocultando datos personales antes de revisar en la nube…';

  @override
  String get cancellingAnalysis => 'Cancelando…';

  @override
  String get analysisCancelledNotice => 'Revisión cancelada.';

  @override
  String get cloudTimedOutNotice =>
      'La IA en la nube superó el tiempo límite antes de responder. No se envió ningún reintento automático.';

  @override
  String get cloudFallbackBannerTitle =>
      'Nube no disponible: revisado en este teléfono';

  @override
  String get cloudFallbackBannerBody =>
      'El análisis en la nube no estuvo disponible, así que Enprive revisó esta política directamente en tu teléfono.';

  @override
  String get appPickerFilterAll => 'Todas las apps';

  @override
  String get appPickerFilterDownloaded => 'Descargadas';

  @override
  String get appPickerFilterSystem => 'Del sistema';

  @override
  String get appPickerRecentlyChecked => 'Revisadas recientemente';

  @override
  String get appPickerStatusPolicySaved => 'Revisión de política guardada';

  @override
  String get appPickerStatusPermissionsInspected => 'Permisos revisados';

  @override
  String get appPickerStatusNotReviewed => 'Sin revisar';

  @override
  String get appPickerSearchHint => 'Buscar por nombre de app o App ID…';

  @override
  String get appPickerEmptyInstalledTitle =>
      'No hay apps instaladas disponibles';

  @override
  String get appPickerEmptyInstalledBody =>
      'No pudimos encontrar ninguna app para revisar en este teléfono.';

  @override
  String get intakeModeDocument => 'Documento';

  @override
  String get intakeActionInspectText => 'Revisar texto de la política';

  @override
  String get intakeActionFetchUrl => 'Abrir y revisar política';

  @override
  String get intakeActionChooseDocument => 'Elegir PDF, TXT o DOCX';

  @override
  String get intakeActionReplaceDocument => 'Elegir documento de reemplazo';

  @override
  String get intakeWorkingLabel => 'Trabajando…';

  @override
  String get intakeCancelFetch => 'Cancelar descarga';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'Carga esta página web pública directamente. Añadir un enlace aquí no prueba quién es dueño de la app.';

  @override
  String get intakePasteLocalNote =>
      'Se revisa primero de forma local en este teléfono. Nada se sube sin tu permiso.';

  @override
  String get intakeDocumentCardTitle =>
      'Importar archivo de política PDF, TXT o DOCX';

  @override
  String get intakeDocumentCardBody =>
      'Leemos el texto directamente en tu teléfono (hasta 10 MB). Tu archivo nunca se sube.';

  @override
  String get intakeCompareWithAppPrompt =>
      'Comparar con una app instalada (opcional)';

  @override
  String get intakeCompareWithAppHint =>
      'Funciona de forma local en este teléfono. Tu lista de apps nunca sale de tu dispositivo.';

  @override
  String get intakeCompareWithAppChange => 'Cambiar';

  @override
  String get intakeCompareWithAppRemove => 'Quitar';

  @override
  String get intakeLockedAppContextLabel => 'App seleccionada';

  @override
  String get intakeFindPolicyOnPlayStore =>
      'Buscar enlace de política en Play Store';

  @override
  String get intakePlayStoreHelperNote =>
      'Abre Play Store para que puedas copiar el enlace de la política de privacidad de la app. Enprive nunca lo copia automáticamente ni da por hecho que sea oficial.';

  @override
  String get intakePlayStoreUnavailable =>
      'No se pudo abrir Google Play Store en este dispositivo. Pega la URL o el texto de la política manualmente.';

  @override
  String get intakeRecoverySwitchPaste => 'Pegar texto en su lugar';

  @override
  String get intakeRecoverySwitchDocument => 'Importar documento';

  @override
  String get intakeRecoveryRetryUrl => 'Reintentar descarga';

  @override
  String get intakeExpiredDocumentShareNotice =>
      'El enlace del archivo compartido originalmente ya no se puede volver a abrir. Elige un archivo PDF, TXT o DOCX de reemplazo o pega el texto de la política manualmente.';

  @override
  String get intakeAssociationWarningTitle => 'Comprobación de app y política';

  @override
  String get intakeAssociationContinueAnyway => 'Continuar de todos modos';

  @override
  String get intakeAssociationChangeApp => 'Cambiar app seleccionada';

  @override
  String get intakeAssociationInspectWithoutApp => 'Revisar política sin app';

  @override
  String get intakeModeSelectorSemanticLabel =>
      'Método de entrada de la política';

  @override
  String get tooltipClearSearch => 'Borrar búsqueda';

  @override
  String get intakeRecoveryEditUrl => 'Editar URL';

  @override
  String get voiceSummaryTitle => 'Resumen de Deni en lenguaje sencillo';

  @override
  String get voiceSummaryPreparing =>
      'Preparando resumen en lenguaje sencillo…';

  @override
  String get voiceSynthesizingExpressive =>
      'Preparando la voz expresiva de Deni…';

  @override
  String get voiceBtnListenOffline => 'Escuchar';

  @override
  String get voiceBtnStop => 'Detener';

  @override
  String get voiceBtnExpressiveCloud => 'Voz expresiva';

  @override
  String get voiceBtnSummarizeCloud => 'Resumir con IA en la nube';

  @override
  String get voiceBadgeExpressive => 'Voz expresiva en la nube';

  @override
  String get voiceBadgeDeviceOffline => 'Voz del teléfono · Sin conexión';

  @override
  String get voiceViewSourceQuote => 'Cita de origen';

  @override
  String get voiceHideSourceQuote => 'Ocultar cita';

  @override
  String get voiceInspectFinding => 'Ver hallazgo';

  @override
  String get voiceConsentTitle => 'Elige la voz de Deni';

  @override
  String get voiceConsentDisclosure =>
      'Para leer este resumen en voz alta con la voz expresiva en la nube de Deni, Enprive enviará solo el texto del resumen mostrado arriba (con los datos personales ocultos) para esta única solicitud. Tus apps y permisos del teléfono nunca se enviarán.';

  @override
  String get voiceConsentPrimaryAction => 'Usar voz expresiva una vez';

  @override
  String get voiceConsentSecondaryAction => 'Leer en este teléfono';

  @override
  String get voiceConsentPayloadLabel => 'Guion hablado exacto';

  @override
  String get voiceSummaryConsentTitle => 'Resumir hallazgos con IA en la nube';

  @override
  String get voiceSummaryConsentDisclosure =>
      'Para resumir estas citas de la política en lenguaje sencillo en la nube, Enprive enviará solo el texto mostrado arriba (con los datos personales ocultos) para esta única solicitud. Tus apps y permisos del teléfono nunca se enviarán.';

  @override
  String get voiceFallbackDeviceNotice =>
      'La voz expresiva en la nube no estuvo disponible: se usará la voz sin conexión de este teléfono.';

  @override
  String get voiceUnavailableNotice =>
      'La lectura en voz alta no está disponible para este idioma en este teléfono. Puedes leer el resumen de Deni arriba.';

  @override
  String get voiceTooltipReadSummary =>
      'Escuchar el resumen de Deni en lenguaje sencillo';

  @override
  String get voiceTooltipStopReading => 'Detener lectura en voz alta';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hallazgos',
      one: 'hallazgo',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hallazgos',
      one: '1 hallazgo',
      zero: 'Sin hallazgos',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citas verificadas en la política',
      one: '1 cita verificada en la política',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vistos en este teléfono',
      one: '1 visto en este teléfono',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'Permitido en este teléfono';

  @override
  String get permissionNotAllowedOnPhone => 'No permitido';

  @override
  String get permissionAllowedInSample => 'Permitido en el ejemplo';

  @override
  String get permissionNotAllowedInSample => 'No permitido en el ejemplo';

  @override
  String get permissionMismatchChip => 'No está en la política';

  @override
  String get howEnpriveCheckedThis => 'Cómo revisó Enprive esto';

  @override
  String get hideHowEnpriveChecked => 'Ocultar cómo revisó Enprive esto';

  @override
  String get consentWhatWouldBeSent => 'Qué se enviaría';

  @override
  String get consentSentScope =>
      'Solo el texto de la vista previa sale de este teléfono, para esta única solicitud.';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se ocultan $count datos personales primero.',
      one: 'Se oculta 1 dato personal primero.',
      zero: 'No se encontraron datos personales para ocultar.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'Tu lista de apps y los permisos del teléfono se quedan en este teléfono.';

  @override
  String receiptDeletedSnack(String title) {
    return 'Se eliminó $title';
  }

  @override
  String get btnUndo => 'Deshacer';

  @override
  String get readinessPromiseMaskedTitle => 'Datos personales ocultos';

  @override
  String get readinessPromiseMaskedLine =>
      'Si eliges la nube, los nombres, correos y números se ocultan primero.';

  @override
  String findingDetailTitle(int index, int total) {
    return 'Hallazgo $index de $total';
  }

  @override
  String get findingReviewChip => 'Revisar';

  @override
  String get askDeniAboutThis => 'Preguntar a Deni sobre esto';

  @override
  String get labelWhatPolicySays => 'Qué dice la política';

  @override
  String get labelWhatAndroidReports => 'Qué muestra tu teléfono';

  @override
  String get sourceButtonTooltip => 'Fuente revisada';

  @override
  String get linkInstalledAppBtn => 'Vincular una app instalada';

  @override
  String get linkInstalledAppCardTitle =>
      'Comparar con una app en este teléfono';

  @override
  String get linkInstalledAppCardBody =>
      'Elige una app instalada para comparar sus permisos del teléfono con esta política en la misma revisión. Tu lista de apps se queda en este teléfono.';

  @override
  String get linkAppPickerTitle => 'Vincular una app instalada';

  @override
  String get changeLinkedAppPickerTitle => 'Cambiar app vinculada';

  @override
  String get linkAppPickerSubtitle =>
      'Elige una app en este teléfono para comparar sus permisos con esta política. Tu lista de apps nunca sale de este teléfono.';

  @override
  String get linkedAppCurrentlySelectedBadge => 'Vinculada';

  @override
  String get linkedAppSectionLabel => 'App vinculada en este teléfono';

  @override
  String get btnChangeLinkedApp => 'Cambiar app';

  @override
  String get btnUnlinkApp => 'Desvincular app';

  @override
  String get btnUpdatePrivacyPolicy =>
      'Adjuntar política de privacidad actualizada';

  @override
  String linkedAppSnack(String appName) {
    return 'Se vinculó $appName. Permisos comparados en este teléfono.';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return 'Se vinculó $appName. Revisa la nota de coincidencia abajo.';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName ya está vinculada con los mismos permisos.';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return 'Se desvinculó $appName. Mostrando solo la revisión de la política.';
  }

  @override
  String get associationStatusPackageTitle =>
      'App ID encontrado en esta política';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'Esta política menciona $packageName. Eso sugiere que podría describir a $appName, aunque el texto por sí solo no prueba quién es dueño de esta política.';
  }

  @override
  String get associationStatusNameTitle =>
      'Nombre de la app encontrado en esta política';

  @override
  String associationStatusNameBody(String appName) {
    return 'Esta política menciona $appName. Eso sugiere que podría describir esta app, aunque coincidir en el nombre no prueba quién es dueño de esta política.';
  }

  @override
  String get associationStatusUnverifiedTitle =>
      'Vinculada por ti para comparar';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'Esta política no menciona a $appName ni su App ID. Comprueba que sea la política correcta: vincularla aquí no prueba su propiedad.';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'La dirección web incluye palabras de $appName, pero el texto de la política no nombra esta app. Comprueba que sea la política correcta: vincularla aquí no prueba su propiedad.';
  }

  @override
  String get associationStatusUnmatchedTitle =>
      'Esta política podría ser de otra app';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'Esta política no menciona a $appName. En su lugar, nombra a $otherApps. Comprueba que vinculaste la app correcta o abriste la política correcta.';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'Esta política menciona más de una app';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'Esta política menciona $appName junto con $otherApps. Puede cubrir varias apps o ser una política compartida de la empresa, así que comprueba si aplica aquí.';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      'Más de una app en este teléfono tiene un nombre similar';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'Esta política menciona $appName sin indicar un App ID exacto, y otras apps en tu teléfono ($otherApps) tienen un nombre similar. Asegúrate de haber vinculado la correcta.';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'Esta política podría referirse a más de una app. Comprueba que aplique a $appName.';
  }

  @override
  String get associationOwnershipLimitation =>
      'El texto y los enlaces web nunca prueban quién publicó o es dueño de una política.';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count permisos en este teléfono no se mencionan con claridad en esta política. Una diferencia invita a mirar más de cerca, no es prueba de mala conducta.',
      one: '1 permiso en este teléfono no se menciona con claridad en esta política. Una diferencia invita a mirar más de cerca, no es prueba de mala conducta.',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'Ninguno de los permisos revisados en este teléfono contradice esta política. Los permisos por sí solos no pueden mostrar qué envía realmente una app.';

  @override
  String get permissionComparisonLimitationNote =>
      'Tu teléfono muestra solo los ajustes de permisos en este teléfono. Esta comparación invita a mirar más de cerca, nunca es prueba de mala conducta ni de que se hayan enviado datos.';

  @override
  String get permissionNotRequestedOnPhone => 'No solicitado por la app';

  @override
  String get permissionNotRequestedInSample => 'No solicitado en el ejemplo';

  @override
  String get permissionsEmptyComparisonTitle =>
      'No hubo permisos sensibles en esta revisión';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'Tu teléfono muestra $requestedCount permisos ($grantedCount permitidos) para $appName, sin ninguno en las categorías sensibles revisadas aquí (ubicación, cámara, micrófono, contactos, fotos o ID de publicidad).';
  }

  @override
  String get sourceDeviceInspection => 'Revisado en este teléfono';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => 'Detalles avanzados';

  @override
  String get advancedDetailsSubtitle =>
      'Detalles técnicos que verifican cuándo y dónde se revisó el texto de esta política.';

  @override
  String get sourceSectionTitle => 'De dónde proviene esta política';

  @override
  String get cloudPayloadLabel => 'Texto exacto que se enviará';

  @override
  String get cloudPayloadNoPiiLabel => 'No se encontraron datos personales';

  @override
  String cloudPayloadHiddenCount(int count) {
    return 'Ocultos ($count)';
  }

  @override
  String get summarySourceOnDevice => 'Resumido en este teléfono';

  @override
  String get summarySourceInCloud => 'Resumido en la nube';

  @override
  String get summarySourceOffline => 'Resumido sin conexión en este teléfono';

  @override
  String get summarySourceUnknown => 'Fuente del resumen desconocida';

  @override
  String get notFromPolicySuffix =>
      'De los ajustes de tu teléfono, no de la política';

  @override
  String get sampleNotFromPolicySuffix => 'Solo ejemplo, no es de la política';

  @override
  String get learnHeaderSubtitle =>
      'Guías y diagramas de privacidad sin conexión';

  @override
  String get learnFilterAll => 'Todos los temas';

  @override
  String get learnFilterPolicies => 'Políticas';

  @override
  String get learnFilterPermissions => 'Permisos';

  @override
  String get learnFilterSharing => 'Compartir';

  @override
  String get learnFilterEvidence => 'Pruebas';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle => 'Practica hábitos de privacidad de forma local';

  @override
  String get learnDeckBody =>
      'Lecciones 100 % sin conexión con diagramas. Tus apps instaladas y recibos nunca entran en Aprender.';

  @override
  String get learnDeckCheckBtn => 'Ponlo en práctica · Revisar una app';

  @override
  String get learnCheckAppBridgeBtn => 'Revisar una app en este teléfono';

  @override
  String get learnSectionDiagram => 'Cómo funciona';

  @override
  String get learnSectionSteps => 'Pasos clave';

  @override
  String get learnSectionQuickCheck => 'Comprobación rápida';

  @override
  String get learnTooltipListenLesson =>
      'Leer esta lección en voz alta sin conexión';

  @override
  String get learnTooltipStopLesson => 'Detener la lectura de la lección';

  @override
  String get learnVoiceUnavailableNotice =>
      'La lectura de voz sin conexión no está disponible para este idioma en este teléfono. Puedes leer la lección abajo.';

  @override
  String get learnQuickCheckCorrectBadge => 'Respuesta correcta';

  @override
  String get learnQuickCheckTryAgainBadge => 'Prueba otra opción';

  @override
  String learnLessonProgress(int current, int total) {
    return 'Lección $current de $total';
  }

  @override
  String get learnBackTooltip => 'Volver a Aprender';

  @override
  String get learnPreviousLesson => 'Anterior';

  @override
  String get learnNextLesson => 'Siguiente';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return 'Lección anterior: $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return 'Siguiente lección: $title';
  }

  @override
  String get learnPolicyFolderTitle => 'Políticas de privacidad';

  @override
  String get learnPolicyTitle =>
      'Qué es una política de privacidad (y qué no puede probar)';

  @override
  String get learnPolicySubtitle =>
      'Lo que prometen los desarrolladores frente a lo que sigue sin saberse';

  @override
  String get learnPolicyIntro =>
      'Una política de privacidad es la declaración pública de un desarrollador que explica qué datos dice recopilar una app, por qué los usa, quién puede recibirlos y qué opciones tienen las familias.';

  @override
  String get learnPolicyStep1 =>
      'Busca cuatro puntos básicos: qué datos se recopilan, por qué los necesita la app, quién más puede recibirlos y cómo pedir que los borren.';

  @override
  String get learnPolicyStep2 =>
      'El lenguaje confuso es común. Un estudio de 2026 sobre apps educativas para niños halló que muy pocas políticas eran fáciles de leer y que la mayoría de las apps no coincidían del todo con lo que afirmaban sus políticas.';

  @override
  String get learnPolicyStep3 =>
      'Una política de privacidad solo muestra lo que dice el desarrollador en papel. Leerla no puede probar qué envía realmente la app por internet.';

  @override
  String get learnPolicyStep4 =>
      'Comparar una política con los permisos de tu teléfono da una vista más clara, recordando que Enprive no puede ver el tráfico de internet en vivo.';

  @override
  String get learnPolicyQuickQuestion =>
      '¿Qué demuestra leer la política de privacidad de una app?';

  @override
  String get learnPolicyQuickOption1 => 'Que la app nunca envía datos a nadie';

  @override
  String get learnPolicyQuickOption2 =>
      'Lo que dice el desarrollador: no lo que la app envía realmente';

  @override
  String get learnPolicyQuickOption3 =>
      'Que la cámara y el micrófono del teléfono están apagados';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'Exacto. Una política es la declaración pública del desarrollador, no una prueba de lo que la app envía realmente por internet.';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      'No del todo. Leer una política solo te dice lo que afirma el desarrollador: no puede probar actividad en internet ni desactivar permisos del teléfono.';

  @override
  String get learnDiagramPolicySaysTitle => 'La política dice';

  @override
  String get learnDiagramPolicySaysBody => 'Promesa escrita del desarrollador';

  @override
  String get learnDiagramPolicyQuoteSample =>
      '\"Podemos compartir datos con socios…\"';

  @override
  String get learnDiagramPhoneShowsTitle => 'El teléfono muestra';

  @override
  String get learnDiagramPhoneShowsBody => 'Permisos permitidos aquí';

  @override
  String get learnDiagramUnknownTitle => 'Aún desconocido';

  @override
  String get learnDiagramUnknownBody =>
      'Tráfico de internet en vivo que Enprive no ve';

  @override
  String get learnDiagramPolicyCaption =>
      'Una política es una promesa, no prueba de comportamiento';

  @override
  String get learnDiagramPolicySemantic =>
      'Diagrama que compara tres partes de la privacidad de una app. Primero, La política dice: la promesa escrita del desarrollador. Segundo, El teléfono muestra: los permisos permitidos en este teléfono. Tercero, dentro de un borde discontinuo, Aún desconocido: el tráfico de internet en vivo que Enprive no puede ver. Una política de privacidad es una promesa, no una prueba de comportamiento.';

  @override
  String get learnPermissionsFolderTitle => 'Permisos del teléfono';

  @override
  String get learnPermissionsTitle => 'Permisos de Android explicados';

  @override
  String get learnPermissionsSubtitle =>
      'Las cuatro opciones de Android y dónde revisarlas';

  @override
  String get learnPermissionsIntro =>
      'Los permisos son puertas que controlan si una app puede acceder a sensores y datos de tu teléfono, como la cámara, el micrófono, la ubicación, las fotos, los contactos o las notificaciones.';

  @override
  String get learnPermissionsStep1 =>
      'Pregúntate si el permiso encaja con la función: una app de matemáticas o lectura rara vez necesita tu ubicación, contactos o cámara.';

  @override
  String get learnPermissionsStep2 =>
      'Android ofrece hasta cuatro opciones: No permitir, Preguntar siempre, Permitir solo mientras la app está en uso y Todo el tiempo (para ubicación en segundo plano).';

  @override
  String get learnPermissionsStep3 =>
      'Empieza con la opción más limitada que permita que la función marche, como Preguntar siempre o Mientras la app está en uso.';

  @override
  String get learnPermissionsStep4 =>
      'Abre los Ajustes de Android y revisa el Panel de privacidad para ver qué apps accedieron hace poco a la Cámara, el Micrófono o la Ubicación.';

  @override
  String get learnPermissionsStep5 =>
      'Desactiva permisos en cualquier momento en los ajustes de la app, o deja activada la opción de pausar la actividad de la app si no se usa para que Android quite permisos antiguos automáticamente. Un permiso concedido muestra capacidad, no prueba de que se enviaran datos.';

  @override
  String get learnPermissionsQuickQuestion =>
      'Una app de práctica de matemáticas pide permiso para la cámara y no sabes por qué. ¿Cuál es el mejor primer paso?';

  @override
  String get learnPermissionsQuickOption1 =>
      'Tocar No permitir y comprobar si los ejercicios de matemáticas siguen funcionando';

  @override
  String get learnPermissionsQuickOption2 =>
      'Elegir Todo el tiempo para que el aviso no vuelva a aparecer';

  @override
  String get learnPermissionsQuickOption3 =>
      'Suponer que la app ya subió fotos';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      'Correcto. Tocar No permitir te deja ver si la app funciona sin la cámara, y puedes cambiar los permisos en cualquier momento en los Ajustes de Android.';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'Prueba primero una opción más limitada. Toca No permitir para ver si la función sigue marchando y recuerda que un permiso concedido muestra capacidad, no prueba de subida.';

  @override
  String get learnDiagramPermLadderTitle =>
      'Del acceso más limitado al más amplio';

  @override
  String get learnDiagramPermDenyTitle => 'No permitir';

  @override
  String get learnDiagramPermDenyDetail =>
      'Bloqueado: la app no puede usar este sensor';

  @override
  String get learnDiagramPermAskTitle => 'Preguntar siempre';

  @override
  String get learnDiagramPermAskDetail =>
      'Acceso único cada vez que tocas permitir';

  @override
  String get learnDiagramPermWhileUsingTitle => 'Mientras usas la app';

  @override
  String get learnDiagramPermWhileUsingDetail =>
      'Solo mientras la app está abierta en pantalla';

  @override
  String get learnDiagramPermAllTimeTitle => 'Todo el tiempo';

  @override
  String get learnDiagramPermAllTimeDetail =>
      'Acceso en segundo plano incluso cerrada';

  @override
  String get learnDiagramPermFitNote =>
      '¿Encaja? Matemáticas + Cámara = pregúntate por qué';

  @override
  String get learnDiagramPermSemantic =>
      'Escalera de permisos de Android de cuatro pasos, del acceso más limitado al más amplio. Paso 1, No permitir: bloqueado, la app no puede usar este sensor. Paso 2, Preguntar siempre: acceso único cada vez que tocas permitir. Paso 3, Mientras usas la app: acceso solo mientras la app está abierta en pantalla. Paso 4, Todo el tiempo: acceso en segundo plano incluso cerrada, marcado con borde discontinuo para mayor precaución. Consejo final: ¿Encaja? Que un ejercicio de matemáticas pida la cámara es motivo para preguntar por qué.';

  @override
  String get learnSharingFolderTitle => 'Anuncios y terceros';

  @override
  String get learnSharingTitle =>
      'Quién más recibe datos: anuncios, análisis y terceros';

  @override
  String get learnSharingSubtitle =>
      'Creador de la app frente a ayudantes, análisis y redes de anuncios';

  @override
  String get learnSharingIntro =>
      'Muchas apps gratuitas se conectan con otras empresas entre bastidores. Saber quién recibe la información ayuda a las familias a distinguir entre hacer funcionar la app y rastrear a los niños entre distintas apps.';

  @override
  String get learnSharingStep1 =>
      'Primera parte significa el creador de la app: por ejemplo, guardar el progreso de tareas o los resultados de un cuestionario para que la app funcione.';

  @override
  String get learnSharingStep2 =>
      'Las empresas de apoyo son terceros que hacen trabajos en segundo plano, como almacenamiento en la nube o informes de fallos para corregir errores.';

  @override
  String get learnSharingStep3 =>
      'Las herramientas de análisis miden cómo se usan las pantallas, mientras que las redes de anuncios y los intermediarios de datos pueden usar un ID de publicidad para mostrar anuncios personalizados o crear perfiles entre apps.';

  @override
  String get learnSharingStep4 =>
      'Presta atención a frases amplias como \'socios de confianza\' o \'fines comerciales\', y comprueba si la política explica cómo rechazar los anuncios personalizados.';

  @override
  String get learnSharingQuickQuestion =>
      'Una política dice que la app comparte información con \'socios terceros\'. ¿Cuál es la mejor siguiente pregunta?';

  @override
  String get learnSharingQuickOption1 =>
      'Suponer que eso significa que la app no tiene anuncios';

  @override
  String get learnSharingQuickOption2 =>
      'Suponer que todos los socios hacen exactamente lo mismo';

  @override
  String get learnSharingQuickOption3 =>
      'Comprobar si esos socios son servicios de apoyo (como alojamiento) o redes de anuncios que rastrean entre apps';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'Muy bien. Los servicios de apoyo mantienen la app en marcha, mientras que las redes de anuncios y los intermediarios de datos pueden rastrear la actividad entre apps.';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      'Fíjate mejor en qué hace cada socio. No todos los terceros son iguales: unos alojan datos o arreglan fallos, mientras que otros muestran anuncios o hacen seguimiento.';

  @override
  String get learnDiagramThirdPartyYou => 'Tú';

  @override
  String get learnDiagramThirdPartyApp => 'App educativa';

  @override
  String get learnDiagramThirdPartyHosting => 'Apoyo y fallos';

  @override
  String get learnDiagramThirdPartyAnalytics => 'Análisis';

  @override
  String get learnDiagramThirdPartyAds => 'Redes de anuncios';

  @override
  String get learnDiagramThirdPartyFirstParty => 'Primera parte';

  @override
  String get learnDiagramThirdPartyThirdParty => 'Terceros';

  @override
  String get learnDiagramThirdPartySemantic =>
      'Diagrama de flujo que muestra adónde pueden ir los datos de una app educativa infantil. Tú te conectas a la app educativa, que se conecta con línea continua al creador de la app (primera parte) y con líneas discontinuas a terceros: herramientas de apoyo y fallos, herramientas de análisis y redes de anuncios marcadas para mayor atención.';

  @override
  String get learnEvidenceFolderTitle => 'Leer Enprive';

  @override
  String get learnEvidenceTitle => 'Cómo leer las pruebas de Enprive';

  @override
  String get learnEvidenceSubtitle =>
      'Capas de pruebas, categorías y límites honestos';

  @override
  String get learnEvidenceIntro =>
      'Enprive separa lo que dice la política de privacidad, lo que muestra tu teléfono y lo que sigue sin saberse, y agrupa los hallazgos por tema, nunca como una calificación de seguridad.';

  @override
  String get learnEvidenceStep1 =>
      'Cinco categorías temáticas agrupan cada hallazgo con el mismo icono y color que la pantalla de Revisión. El color indica el tema, nunca una puntuación de seguridad.';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '$sourceMatched significa que Enprive encontró una cita exacta, palabra por palabra, en el texto de la política que revisaste.';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '$deviceObserved significa que tu teléfono informó un ajuste de permiso en este dispositivo: no es prueba de que se enviaran datos.';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '$interpretation es la explicación en lenguaje sencillo de Deni, mientras que $unverified señala detalles que Enprive no pudo encontrar. El silencio en una política nunca es una promesa.';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return 'Las revisiones terminan con uno de tres resultados claros: $reviewRecommended, $noConcern (que nunca es una certificación de seguridad) o $insufficientEvidence.';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return 'En una pantalla de Revisión, ¿qué significa \'$deviceObserved\'?';
  }

  @override
  String get learnEvidenceQuickOption1 =>
      'Que la app está certificada como segura para niños';

  @override
  String get learnEvidenceQuickOption2 =>
      'Que tu teléfono muestra este ajuste de permiso en este dispositivo: no prueba que se subieran datos';

  @override
  String get learnEvidenceQuickOption3 =>
      'Que la app sin duda ha subido los datos de tu hijo';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'Así es. Esa etiqueta refleja el estado del permiso de Android en este dispositivo; no puede probar envíos ni certificar seguridad.';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      'No del todo. Esa etiqueta solo muestra lo que informa tu teléfono sobre un permiso: nunca prueba subidas ni es una certificación de seguridad.';

  @override
  String get learnDiagramEvidencePolicyDetail =>
      'Cita exacta encontrada en el texto de la política';

  @override
  String get learnDiagramEvidencePhoneDetail =>
      'Permisos del teléfono en este dispositivo';

  @override
  String get learnDiagramEvidenceDeniDetail =>
      'Explicación en lenguaje sencillo de Deni';

  @override
  String get learnDiagramEvidenceUnknownDetail =>
      'El silencio en una política no es una promesa';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Cuatro capas de pruebas usadas en la pantalla de Revisión de Enprive: 1, $sourceMatched, una cita exacta encontrada en la política de privacidad; 2, $deviceObserved, permisos del teléfono en este dispositivo; 3, $interpretation, la explicación en lenguaje sencillo de Deni; y 4, separada por una línea discontinua, $unverified, porque el silencio en una política no es una promesa.';
  }

  @override
  String get learnDiagramCategoriesTitle =>
      'Cinco categorías temáticas en la pantalla de Revisión';

  @override
  String get learnDiagramCategoriesNote =>
      'El color y el icono indican el tema, nunca una puntuación de seguridad.';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Cinco categorías de pruebas mostradas en la pantalla de Revisión de Enprive, cada una con su icono y color: $dataCollection, $sharing, $tracking, $retention y $parentalControls. El color y el icono indican el tema, nunca una puntuación de seguridad.';
  }

  @override
  String get learnDataCollectionFolderTitle => 'Datos que recopilan';

  @override
  String get learnDataCollectionTitle => 'Qué datos recopilan las apps';

  @override
  String get learnDataCollectionSubtitle =>
      'La diferencia entre lo que escribes y lo que ocurre en silencio';

  @override
  String get learnDataCollectionIntro1 =>
      'Las apps reúnen información de dos maneras. Algunos datos provienen de lo que ingresas activamente: tu nombre, correo, fotos, grabaciones de voz o respuestas de tareas. Otros se recopilan automáticamente en segundo plano, como tu dirección IP (la dirección que usa tu teléfono en internet), identificadores del dispositivo, ID de publicidad (un código que usan los anuncios para reconocer tu teléfono), registros de fallos y cuándo abres la app.';

  @override
  String get learnDataCollectionStep1 =>
      'Lo que escribes: tu nombre, escuela, correo, fotos, audios y respuestas de tareas son datos que eliges compartir.';

  @override
  String get learnDataCollectionStep2 =>
      'Lo que corre en silencio: la app puede recopilar un ID de publicidad, identificadores del dispositivo, dirección IP, informes de fallos y tiempos de uso sin que toques un botón. Que sea silencioso no significa automáticamente que sea malo: estas señales ayudan a que las apps funcionen bien.';

  @override
  String get learnDataCollectionStep3 =>
      'Datos infantiles sensibles: la ubicación, grabaciones de micrófono, fotos de cámara y datos biométricos como huellas de voz (datos sobre tu cuerpo o tu voz) conllevan mayor riesgo de privacidad para los niños.';

  @override
  String get learnDataCollectionStep4 =>
      'Nota sobre Play Store: la sección Seguridad de los datos de Google Play es la descripción del propio desarrollador. Es una pista, no una prueba, y no incluye datos procesados solo en tu dispositivo o guardados brevemente en memoria.';

  @override
  String get learnDataCollectionQuizQuestion =>
      '¿Cuál de estos es un ejemplo de datos que se recopilan en silencio en segundo plano?';

  @override
  String get learnDataCollectionQuizChoiceA =>
      'Una foto que subes para tu perfil';

  @override
  String get learnDataCollectionQuizChoiceB =>
      'Tu ID de publicidad e identificadores del dispositivo';

  @override
  String get learnDataCollectionQuizChoiceC =>
      'Una respuesta de tarea que escribes en la app';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      'Correcto: los ID de publicidad e identificadores del dispositivo se recopilan automáticamente sin que los escribas.';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      'No del todo: esos son datos que introduces activamente. Los datos que se recopilan en silencio incluyen ID de publicidad, identificadores del dispositivo, dirección IP y tiempos de uso.';

  @override
  String get learnDataCollectionDiagramYouTypeTitle => 'Lo que escribes o das';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 =>
      'Nombre, correo, escuela';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => 'Fotos y videos';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => 'Grabaciones de voz';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => 'Respuestas de tareas';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle =>
      'Lo que corre en silencio';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => 'ID de publicidad';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 =>
      'Identificadores del dispositivo';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'Dirección IP';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 =>
      'Registros de fallos y tiempos de uso';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      'Silencioso no significa malo: estas señales ayudan a que las apps funcionen bien.';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      'Un diagrama dividido que muestra dos categorías de recopilación de datos. La tarjeta superior titulada \"Lo que escribes o das\" lista cuatro elementos: Nombre, correo, escuela; Fotos y videos; Grabaciones de voz; Respuestas de tareas. La tarjeta inferior titulada \"Lo que corre en silencio\" lista cuatro elementos: ID de publicidad; Identificadores del dispositivo; Dirección IP; Registros de fallos y tiempos de uso. Una pequeña nota dice \"Silencioso no significa malo: estas señales ayudan a que las apps funcionen bien.\" Deni aparece abajo en pose pensativa.';

  @override
  String get learnDataCollectionCheckBridge =>
      'Revisa una app en este teléfono para ver qué datos recopila.';

  @override
  String get learnDataCollectionHonestyNote =>
      'Esta lección explica tipos comunes de datos. No prueba lo que recopila o envía una app en concreto. Solo el texto exacto de la política y los permisos de tu teléfono pueden mostrarlo.';

  @override
  String get learnRetentionFolderTitle => 'Retención y borrado';

  @override
  String get learnRetentionTitle => 'Retención y borrado de datos';

  @override
  String get learnRetentionSubtitle =>
      'Desinstalar una app no borra los datos que ya están en los servidores de la empresa';

  @override
  String get learnRetentionIntro1 =>
      'Cuando borras una app de tu teléfono, se eliminan los archivos locales de tu dispositivo, pero los datos ya subidos a los servidores de la empresa siguen allí. Las políticas de privacidad deberían indicar cuánto tiempo conservan tus datos, cómo pedir que los borren y qué pasa con las copias de seguridad, pero muchas usan frases vagas como \"el tiempo razonablemente necesario\".';

  @override
  String get learnRetentionStep1 =>
      'Datos recopilados: mientras usas la app, tu información se envía y se guarda en los servidores de la empresa.';

  @override
  String get learnRetentionStep2 =>
      'Guardados en servidores: tus datos pueden seguir en los sistemas de la empresa incluso después de dejar de usar la app.';

  @override
  String get learnRetentionStep3 =>
      'Desinstalar no borra datos del servidor: quitar la app de tu teléfono solo borra archivos locales, no las copias en los servidores de la empresa.';

  @override
  String get learnRetentionStep4 =>
      'Solicitud de borrado: puedes pedir a la empresa que elimine tu cuenta y tus datos; las políticas deberían indicar cuánto tarda.';

  @override
  String get learnRetentionStep5 =>
      'Retención desconocida: las políticas que dicen \"el tiempo que sea necesario\" o \"para fines comerciales\" dejan poco claro cuándo se borran realmente los datos.';

  @override
  String get learnRetentionQuizQuestion =>
      '¿Qué pasa con tus datos en los servidores de la empresa cuando desinstalas una app de tu teléfono?';

  @override
  String get learnRetentionQuizChoiceA => 'Se borran automáticamente';

  @override
  String get learnRetentionQuizChoiceB =>
      'Pueden quedarse en los servidores: desinstalar la app no los borra';

  @override
  String get learnRetentionQuizChoiceC => 'Se anonimizan de inmediato';

  @override
  String get learnRetentionQuizFeedbackRight =>
      'Correcto: desinstalar solo quita la app de tu teléfono. Los datos en los servidores de la empresa pueden quedarse hasta que pidas borrarlos.';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      'No del todo: desinstalar una app no borra los datos ya subidos a los servidores de la empresa. Tienes que solicitar la eliminación de la cuenta.';

  @override
  String get learnRetentionDiagramCollected =>
      'Datos recopilados durante el uso';

  @override
  String get learnRetentionDiagramStored =>
      'Guardados en servidores de la empresa';

  @override
  String get learnRetentionDiagramUninstall =>
      'Desinstalas la app: se borran archivos locales, siguen los del servidor';

  @override
  String get learnRetentionDiagramDeleteRequest =>
      'Solicitas eliminar tu cuenta';

  @override
  String get learnRetentionDiagramUnknownTail =>
      'Retención desconocida: la política dice \"el tiempo que sea necesario\"';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      'Una línea de tiempo de cinco pasos que muestra el ciclo de vida de los datos. Paso 1: Datos recopilados durante el uso, con icono de base de datos. Paso 2: Guardados en servidores de la empresa, con icono de servidor. Paso 3: Desinstalas la app: se borran archivos locales, siguen los del servidor, con icono de teléfono. Paso 4: Solicitas eliminar tu cuenta, con icono de papelera. Paso 5: Retención desconocida: la política dice \"el tiempo que sea necesario\", con flecha discontinua e icono de ayuda. Deni está abajo sosteniendo un recibo.';

  @override
  String get learnRetentionCheckBridge =>
      'Revisa una app en este teléfono para ver qué dice su política sobre retención.';

  @override
  String get learnRetentionHonestyNote =>
      'Esta lección describe patrones comunes de retención. No prueba lo que hace realmente una empresa concreta con tus datos. Solo el texto exacto de la política y una solicitud de borrado pueden mostrarlo.';

  @override
  String get learnUnclearPoliciesFolderTitle => 'Políticas poco claras';

  @override
  String get learnUnclearPoliciesTitle =>
      'Cómo detectar políticas poco claras y botones engañosos';

  @override
  String get learnUnclearPoliciesSubtitle =>
      'Cómo reconocer lenguaje vago y pantallas de consentimiento con presión';

  @override
  String get learnUnclearPoliciesIntro1 =>
      'Algunas políticas de privacidad usan palabras difusas que dificultan saber qué pasa realmente con tus datos. Las pantallas de consentimiento también pueden usar trucos de diseño, como un gran botón brillante de \"Aceptar todo\" junto a un enlace diminuto de \"Gestionar ajustes\", para empujarte a aceptar sin leer.';

  @override
  String get learnUnclearPoliciesStep1 =>
      'Señales de niebla en la política: fíjate en frases abiertas como \"podemos compartir con socios de confianza\", \"para fines comerciales\" o \"conservar según sea necesario\": dejan sin especificar los detalles reales.';

  @override
  String get learnUnclearPoliciesStep2 =>
      'El silencio no es una promesa: si una política nunca menciona el micrófono, los anuncios o la ubicación, eso no garantiza que la app los evite.';

  @override
  String get learnUnclearPoliciesStep3 =>
      'Básicos que faltan: una política clara tiene una fecha de vigencia visible, un correo de contacto y un solo documento unificado, no un anexo infantil escondido.';

  @override
  String get learnUnclearPoliciesStep4 =>
      'Consentimiento bajo presión (patrones oscuros): botones gigantes de \"Aceptar todo\", casillas de marketing ya marcadas, avisos insistentes y rutas difíciles para cancelar están pensados para imponerse a tu elección.';

  @override
  String get learnUnclearPoliciesStep5 =>
      'Elección equilibrada: una pantalla justa muestra botones iguales de \"Permitir\" y \"No permitir\", con los interruptores opcionales desactivados por defecto.';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      '¿Qué frase en una política de privacidad es una señal \"difusa\" de que faltan detalles?';

  @override
  String get learnUnclearPoliciesQuizChoiceA =>
      'No vendemos tu información personal a terceros';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      'Podemos compartir datos con socios de confianza para fines comerciales';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'Puedes solicitar el borrado escribiendo a privacy@example.com';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      'Correcto: \"podemos compartir con socios de confianza para fines comerciales\" es vago y no dice quiénes son los socios ni qué datos se comparten.';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      'No del todo: esa frase es concreta y útil. Las frases difusas usan expresiones abiertas como \"podemos compartir\" o \"según sea necesario\" sin dar detalles.';

  @override
  String get learnUnclearPoliciesDiagramClearTitle =>
      'Frase clara en la política';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      'Recopilamos tu nombre y correo para crear tu cuenta. No compartimos esto con anunciantes.';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle =>
      'Frase difusa en la política';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      'Podemos compartir tu información con socios de confianza para fines comerciales según sea necesario.';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle => 'Cómo detectar la niebla';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      'Busca \"puede\", \"podría\" o \"según sea necesario\": dejan la puerta abierta.';

  @override
  String get learnUnclearPoliciesDiagramTip2 =>
      'Comprueba si la política nombra las empresas concretas que reciben los datos.';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      'El silencio sobre temas como anuncios o micrófono no promete que la app los evite.';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote =>
      'El silencio en una política no es una promesa.';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      'Comparación lado a lado entre una frase clara y una frase difusa de una política. La tarjeta izquierda titulada \"Clara\" muestra: \"Recopilamos tu nombre y correo para crear tu cuenta. No compartimos esto con anunciantes.\" La tarjeta derecha titulada \"Difusa\" muestra: \"Podemos compartir tu información con socios de confianza para fines comerciales según sea necesario.\" Abajo, una tarjeta de consejos titulada \"Cómo detectar la niebla\" enumera tres consejos: busca \"puede\", \"podría\" o \"según sea necesario\", dejan la puerta abierta; comprueba si la política nombra las empresas concretas que reciben los datos; el silencio sobre temas como anuncios o micrófono no promete que la app los evite. Una nota en la tarjeta difusa dice \"El silencio en una política no es una promesa.\" Deni se asoma por encima de las tarjetas.';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      'Revisa una app en este teléfono para comprobar su pantalla de consentimiento y claridad.';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      'Esta lección describe patrones poco claros habituales. No prueba que una app en concreto use patrones oscuros u oculte prácticas de datos. Solo leer la política exacta y ver la pantalla real de consentimiento puede mostrarlo.';

  @override
  String get learnSafeSharingFolderTitle => 'Hábitos al compartir';

  @override
  String get learnSafeSharingTitle => 'Hábitos seguros al compartir para niños';

  @override
  String get learnSafeSharingSubtitle =>
      'Para, Piensa, Conecta: pasos según la edad para compartir en línea';

  @override
  String get learnSafeSharingIntro1 =>
      'Antes de publicar una foto, un video, tu nombre o tu ubicación, haz una pausa y usa estos tres pasos: Para, Piensa, Conecta. Esta lección es para leerla junto a un adulto de confianza. Los más pequeños (5 a 7 años) preguntan antes de tocar. Los niños de 8 a 11 usan apodos y contraseñas seguras. Los adolescentes (12 a 17) cuidan su huella digital (el rastro de lo que publicas) y activan la verificación en dos pasos (una segunda comprobación, como un código, al iniciar sesión).';

  @override
  String get learnSafeSharingStep1 =>
      'Para: haz una pausa antes de publicar una foto, un video, tu nombre, tu escuela o tu ubicación. Pregunta a un adulto de confianza si tienes dudas.';

  @override
  String get learnSafeSharingStep2 =>
      'Piensa: ¿esto revela mi escuela, mi casa o dónde estoy ahora? ¿Les pregunté a mis amigos antes de compartir sus fotos o etiquetarlos?';

  @override
  String get learnSafeSharingStep3 =>
      'Conecta: comparte solo con personas en las que confías. Mantén en privado datos personales como tu nombre completo, cumpleaños, dirección y número de teléfono.';

  @override
  String get learnSafeSharingStep4 =>
      'La prueba de la cafetería: ¿estaría bien si todos en la escuela (o toda mi clase) vieran esta foto o mensaje? Incluso las publicaciones que desaparecen pueden capturarse en pantalla y quedarse en internet para siempre.';

  @override
  String get learnSafeSharingStep5 =>
      'De 5 a 7 años: pregunta a un adulto de confianza antes de escribir tu nombre o tocar avisos. De 8 a 11: usa un apodo (no tu nombre real, cumpleaños ni escuela), contraseñas seguras y nunca compartas códigos SMS ni OTP (códigos de un solo uso enviados por mensaje de texto: nunca los compartas). De 12 a 17: revisa los ajustes de privacidad, activa la verificación en dos pasos y aprende cómo denunciar problemas.';

  @override
  String get learnSafeSharingQuizQuestion =>
      '¿Qué es la \"prueba de la cafetería\" al compartir en línea?';

  @override
  String get learnSafeSharingQuizChoiceA =>
      'Compartir solo cosas que comerías en la cafetería';

  @override
  String get learnSafeSharingQuizChoiceB =>
      'Preguntarte: ¿estaría bien si todos en la escuela vieran esta foto o mensaje?';

  @override
  String get learnSafeSharingQuizChoiceC =>
      'Compartir solo durante la hora del almuerzo';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      'Correcto: la prueba de la cafetería consiste en preguntarte si te sentirías cómodo si todos vieran lo que publicas.';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      'No del todo: la prueba de la cafetería es una comprobación mental: ¿te parecería bien que alguien mostrara tu publicación a toda la cafetería?';

  @override
  String get learnSafeSharingDiagramStop =>
      'Para: haz una pausa antes de publicar';

  @override
  String get learnSafeSharingDiagramThink =>
      'Piensa: ¿esto revela dónde estoy o con quién estoy?';

  @override
  String get learnSafeSharingDiagramConnect =>
      'Conecta: comparte con quien confías y pregunta a un adulto si dudas';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      'La prueba de la cafetería: ¿estaría bien si todos en la escuela vieran esto? Incluso las publicaciones que desaparecen pueden capturarse en pantalla y quedarse en internet para siempre.';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      'Un diagrama de cuatro partes que enseña hábitos cuidadosos al compartir. Paso 1: Para: haz una pausa antes de publicar, con icono de mano. Paso 2: Piensa: ¿esto revela dónde estoy o con quién estoy?, con icono de cerebro. Paso 3: Conecta: comparte con quien confías y pregunta a un adulto si dudas, con icono de personas. Paso 4: el recuadro de la prueba de la cafetería pregunta \"¿estaría bien si todos en la escuela vieran esto? Incluso las publicaciones que desaparecen pueden capturarse en pantalla y quedarse en internet para siempre.\" Deni está junto al recuadro con la mano levantada.';

  @override
  String get learnSafeSharingCheckBridge =>
      'Revisa una app junto a tu madre o padre para ver cómo maneja el uso compartido.';

  @override
  String get learnSafeSharingHonestyNote =>
      'Esta lección comparte hábitos generales para compartir con cuidado. No garantiza que ninguna app proteja lo que compartes. Lee siempre la política de la app y usa los ajustes de privacidad de tu teléfono.';

  @override
  String get translationDraftNotice =>
      'Algunas traducciones son borradores generados por IA y pueden contener errores. Hablantes nativos las están revisando.';

  @override
  String get homeQuickSettingsTitle => 'Acompañante de Ajustes rápidos';

  @override
  String get homeQuickSettingsSubtitle =>
      'Pregunta a Deni sobre la app que usas en cualquier momento';

  @override
  String get appearanceSectionTitle => 'Apariencia';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get quickSettingsSectionTitle => 'Conectar Enprive a Ajustes rápidos';

  @override
  String get quickSettingsSectionSubtitle =>
      'Añade Enprive Check al panel de Ajustes rápidos de Android para preguntarle a Deni sobre aplicaciones sin salir de lo que haces.';

  @override
  String get quickSettingsTileTitle => 'Acceso Enprive Check';

  @override
  String get quickSettingsTileSubtitle =>
      'Añade Enprive Check a Ajustes rápidos para preguntarle a Deni sobre la app que usas sin buscar Enprive primero.';

  @override
  String get quickSettingsStatusAdded => 'Añadido';

  @override
  String get quickSettingsStatusManual => 'Manual';

  @override
  String get quickSettingsStatusNotAdded => 'No añadido';

  @override
  String get usageAccessStatusGranted => 'Concedido';

  @override
  String get usageAccessStatusNotGranted => 'No concedido';

  @override
  String get usageAccessTitle => 'Permitir Acceso a uso (opcional)';

  @override
  String get usageAccessExplanation =>
      'Enprive usa Acceso a uso solo cuando tocas Enprive Check para identificar la app que estabas usando. Esto ayuda a Deni a encontrar la app correcta y su información de privacidad. Enprive no vigila tu pantalla de forma continua.';

  @override
  String get usageAccessManageLink => 'Cómo gestionar o revocar';

  @override
  String get usageAccessManageTitle => 'Gestionar o revocar Acceso a uso';

  @override
  String get usageAccessManageBody =>
      'Acceso a uso es un interruptor especial en los Ajustes de Android (no una ventana automática). Puedes desactivarlo en cualquier momento en Ajustes de Android -> Aplicaciones -> Acceso especial -> Acceso a datos de uso -> enprive. Deni sigue funcionando sin él eligiendo la app manualmente.';

  @override
  String get openDeniCompanionTitle => 'Abrir Acompañante Deni';

  @override
  String get openDeniCompanionSubtitle =>
      'Revisa los permisos de una app reciente o elegida sin Ajustes rápidos.';

  @override
  String get btnGotIt => 'Entendido';

  @override
  String get quickSettingsReadyDialogTitle =>
      'Enprive Check está listo en Ajustes rápidos';

  @override
  String get quickSettingsReadyDialogBody =>
      'Desliza hacia abajo dos veces desde la parte superior de la pantalla y toca \"Enprive Check\" cuando quieras que Deni explique los permisos de una app.';

  @override
  String get quickSettingsManualDialogTitle =>
      'Añadir Enprive Check manualmente';

  @override
  String get quickSettingsManualDialogBody =>
      '1. Desliza hacia abajo dos veces desde la parte superior de tu pantalla Android para abrir Ajustes rápidos.\n2. Toca el botón Editar (lápiz).\n3. Busca \"Enprive Check\" y arrástralo a tus accesos activos de Ajustes rápidos.';

  @override
  String get quickSettingsSnackAdded =>
      'Enprive Check se añadió a tu panel de Ajustes rápidos.';

  @override
  String get quickSettingsSnackAlreadyAdded =>
      'Enprive Check ya está en tu panel de Ajustes rápidos.';

  @override
  String get quickSettingsSnackDeclined =>
      'Solicitud descartada. Enprive no volverá a preguntar salvo que elijas Editar en Ajustes rápidos.';

  @override
  String get quickSettingsSnackManual =>
      'Desliza Ajustes rápidos hacia abajo, toca Editar y arrastra Enprive Check a tus accesos.';

  @override
  String get quickSettingsSnackUnavailable =>
      'El aviso del sistema no está disponible aquí; puedes arrastrar Enprive Check manualmente desde Editar en Ajustes rápidos.';

  @override
  String get usageAccessOpenFailedSnack =>
      'No se pudieron abrir los ajustes de Acceso a uso en este dispositivo.';

  @override
  String get companionTitle => 'Deni: Acompañante de Enprive';

  @override
  String get companionSubtitle =>
      'Pregunta a Deni sobre los permisos de una app y lo que dice su política de privacidad.';

  @override
  String get companionTooltipReturnToPrev => 'Volver a la app anterior';

  @override
  String get companionTooltipBack => 'Atrás';

  @override
  String get companionLockedBadge => 'PROTEGIDO EN PANTALLA BLOQUEADA';

  @override
  String get companionLockedTitle => 'Desbloquea tu teléfono para continuar';

  @override
  String get companionLockedBody =>
      'Enprive oculta nombres de apps, permisos declarados y pruebas de revisión mientras el dispositivo está bloqueado.';

  @override
  String get companionCheckUnlockBtn => 'Comprobar desbloqueo';

  @override
  String get companionCheckingAppHeadline =>
      'Comprobando qué app estabas usando…';

  @override
  String get companionCheckingAppSubtitle =>
      'Comprobando una sola vez en este teléfono sin vigilar tu pantalla.';

  @override
  String get companionGeneralGuideHeadline =>
      'Guía general de permisos de Android';

  @override
  String get companionGeneralGuideSubtitle =>
      'No hay ninguna app seleccionada. Enprive explica los permisos de Android solo con guía local.';

  @override
  String companionLookingAtHeadline(String appName) {
    return 'Estás viendo $appName.';
  }

  @override
  String get companionLookingAtSubtitle =>
      'Los permisos mostrados abajo vienen de la app en tu teléfono: Android sigue controlando cualquier aviso que aparezca en pantalla.';

  @override
  String get companionThisAppFallback => 'esta app';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return 'Vimos $appName hace $seconds s. ¿Es correcto?';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return 'Creemos que estás usando $appName. ¿Es correcto?';
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
  String get companionChooseAnotherAppBtn => 'Elegir otra app';

  @override
  String get companionWithoutAppContextBtn => 'Sin contexto de app';

  @override
  String get companionMultipleAppsTitle =>
      'Había varias apps activas hace un momento';

  @override
  String get companionMultipleAppsPrompt =>
      'Confirma qué aplicación quieres inspeccionar:';

  @override
  String companionSecondsAgo(int seconds) {
    return 'hace $seconds s';
  }

  @override
  String get companionSelectAppTitle => 'Elige la app que quieres revisar';

  @override
  String get companionSelectAppBody =>
      'Elige la aplicación manualmente entre las apps instaladas o continúa sin contexto de app.';

  @override
  String get companionChooseAppManuallyBtn => 'Elegir app manualmente';

  @override
  String get companionOpenUsageAccessBtn => 'Abrir ajustes de Acceso a uso';

  @override
  String get companionContinueWithoutAppBtn => 'Continuar sin contexto de app';

  @override
  String get companionAddTileBtn => 'Añadir acceso Enprive Check';

  @override
  String get companionContinuingWithoutApp => 'Continuando sin contexto de app';

  @override
  String get companionSwitchAppBtn => 'Cambiar app';

  @override
  String get companionPermissionsReadLocally =>
      'Los permisos mostrados abajo se leen directamente desde tu teléfono.';

  @override
  String get companionPickPermissionType =>
      'Elige un tipo de permiso para explorar';

  @override
  String get companionPickAppBtn => 'Elegir una app';

  @override
  String get companionCouldNotReadPermsTitle =>
      'No se pudieron leer los permisos de la app';

  @override
  String get companionCouldNotReadPermsBody =>
      'Android impidió inspeccionar los permisos de esta app.';

  @override
  String get companionUnsurePermBtn => 'No sé qué permiso es';

  @override
  String get companionWhichPermissionPrompt => '¿Qué permiso quieres entender?';

  @override
  String get companionPermissionsListDisclaimer =>
      'Estos son permisos que la app declara en tu teléfono, no necesariamente el aviso que ves en pantalla ahora mismo.';

  @override
  String get companionNoSensitivePermsMsg =>
      'Esta app no pide permisos sensibles en tu teléfono.';

  @override
  String get companionGuidedMatchTitle =>
      'Elige lo que pidió el aviso en tu pantalla';

  @override
  String get companionGuidedMatchSubtitle =>
      'Enprive no puede leer directamente el aviso actual de Android. Elige la opción más parecida a lo que apareció en pantalla:';

  @override
  String get companionSection1Title => '1. Qué significa este permiso';

  @override
  String get companionSection2Title => '2. Qué pide la app en tu teléfono';

  @override
  String get companionSection3Title => '3. Qué dice su política de privacidad';

  @override
  String get companionSection4Title =>
      '4. Por qué podría relacionarse con una función';

  @override
  String get companionSection4Fallback =>
      'No se encontró una explicación verificada del desarrollador para esta función. Describe abajo qué función intentabas usar si quieres que Deni revise si tiene relación.';

  @override
  String get companionSection5Title => '5. Qué sigue sin saberse';

  @override
  String get companionSection6Title => '6. Preguntas que puedes hacerle a Deni';

  @override
  String get companionAddPolicyBtn => 'Añadir política de privacidad';

  @override
  String get companionCheckUpdatedPolicyBtn => 'Revisar política actualizada';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return 'Verificar política de $appName';
  }

  @override
  String get companionFeatureFieldLabel =>
      'Función que estabas usando (opcional)';

  @override
  String get companionFeatureFieldHint =>
      'p. ej., escanear un código QR, grabar práctica de voz';

  @override
  String get companionQuestionFieldLabel => 'Haz una pregunta a Deni';

  @override
  String get companionQuestionFieldHint => '¿Qué pasa si deniego este permiso?';

  @override
  String get companionReceiptSavedTitle =>
      'Guardado en Comprobantes de Enprive';

  @override
  String get companionReceiptUnsavedTitle =>
      'Revisión aún no guardada en Enprive';

  @override
  String get companionReceiptSavedBody =>
      'Guardado localmente en tu archivo de Comprobantes de Enprive.';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      'La revisión actualizada se conserva solo en esta sesión. Al salir de Acompañante se descarta este borrador y tu comprobante guardado sigue igual.';

  @override
  String get companionReceiptUnsavedBody =>
      'Se conserva solo en esta sesión. Al salir de Acompañante se descartará si no la guardas.';

  @override
  String get companionSaveReceiptBtn => 'Guardar comprobante en Enprive';

  @override
  String get companionSaveReceiptFailed =>
      'No se pudo guardar el comprobante. Se mantiene en esta sesión: inténtalo de nuevo.';

  @override
  String get companionSavedLocalReceiptsSnack =>
      'Guardado en Comprobantes locales.';

  @override
  String companionDoneReturnToApp(String appName) {
    return 'Listo · Volver a $appName';
  }

  @override
  String get companionDoneReturnToPrev => 'Listo · Volver a la app anterior';

  @override
  String get companionOpenFullAppBtn => 'Abrir la app completa de Enprive';

  @override
  String get companionCloudTimeoutSnack =>
      'El análisis en la nube tardó demasiado y se detuvo antes de terminar.';

  @override
  String get companionAnalysisCancelledSnack => 'Análisis cancelado.';

  @override
  String get companionCloudAnswerTimeoutSnack =>
      'La respuesta en la nube agotó el tiempo sin errores.';

  @override
  String get companionQuestionCancelledSnack => 'Pregunta cancelada.';

  @override
  String get companionTileAddedSnack =>
      'Enprive Check se añadió a Ajustes rápidos de Android.';

  @override
  String get companionTileAlreadyAddedSnack =>
      'Enprive Check ya está en tus Ajustes rápidos.';

  @override
  String get companionTileDeclinedSnack =>
      'Solicitud descartada. Puedes añadirlo cuando quieras desde Ajustes o Editar en Ajustes rápidos.';

  @override
  String get companionTileManualSnack =>
      'Desliza Ajustes rápidos dos veces, toca Editar y arrastra Enprive Check a tus accesos.';

  @override
  String get companionTileUnavailableSnack =>
      'Android no pudo mostrar el aviso de Ajustes rápidos en este dispositivo. Puedes arrastrar Enprive Check manualmente desde Editar en Ajustes rápidos.';

  @override
  String get companionUsageOptionalReason =>
      'Acceso a uso es opcional. Puedes elegir una app manualmente o permitir Acceso a uso para identificarla con un toque.';

  @override
  String get companionPermPreciseLocation => 'Ubicación precisa';

  @override
  String get companionPermBackgroundLocation => 'Ubicación en segundo plano';

  @override
  String get companionPermCamera => 'Cámara';

  @override
  String get companionPermMicrophone => 'Micrófono';

  @override
  String get companionPermAdId => 'ID de publicidad de Google';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return 'Permiso de Android ($permission) declarado por $appName.';
  }

  @override
  String get companionPermStatusAdId =>
      'Declarado por la app · ID de publicidad';

  @override
  String get companionPermStatusAllowed => 'Declarado por la app · Permitido';

  @override
  String get companionPermStatusNotAllowed =>
      'Declarado por la app · No permitido';

  @override
  String get guidedCatLocation => 'Ubicación';

  @override
  String get guidedCatContacts => 'Contactos';

  @override
  String get guidedCatPhotosMedia => 'Fotos y contenido multimedia';

  @override
  String get guidedCatNotifications => 'Notificaciones';

  @override
  String get guidedCatNearbyDevices => 'Dispositivos cercanos';

  @override
  String get guidedCatCalendar => 'Calendario';

  @override
  String get guidedCatPhone => 'Teléfono';

  @override
  String get guidedCatSms => 'SMS';

  @override
  String get companionFallbackUsageNotEnabled =>
      'El Acceso a uso no se ha activado en los Ajustes de Android.';

  @override
  String get companionFallbackUsageUnavailable =>
      'Android UsageStatsManager no está disponible.';

  @override
  String get companionFallbackTransientUi =>
      'Solo apareció la interfaz del sistema Android o un aviso de permisos en la actividad reciente; elige la app manualmente.';

  @override
  String get companionFallbackVisibilityRestricted =>
      'No se puede inspeccionar la app activa más reciente por restricciones de visibilidad de paquetes de Android. Elige una app de la lista o pega su política.';

  @override
  String get companionFallbackUnlockRequired =>
      'Desbloquea tu dispositivo antes de ver el contexto de la app.';

  @override
  String get consentReasonPolicyTooDetailed =>
      'Esta política es demasiado extensa para procesarla con IA en el teléfono.';

  @override
  String get consentReasonExcerptTooDetailed =>
      'Este fragmento es demasiado extenso para procesarlo con IA en el teléfono.';

  @override
  String get consentReasonOnDeviceUnavailable =>
      'La IA en el teléfono no está disponible en este dispositivo ahora mismo.';

  @override
  String get consentReasonOnDeviceCannotAnswer =>
      'La IA en el teléfono no pudo responder desde este dispositivo ahora mismo.';

  @override
  String get consentReasonVoiceTooLong =>
      'Estos hallazgos verificados superan el límite del resumen en el teléfono. Puedes usar el resumen sin conexión ahora o enviar los hallazgos redactados a la IA en la nube una vez.';

  @override
  String get consentReasonVoiceUnavailable =>
      'La IA en el teléfono no está disponible en este dispositivo ahora mismo. Mostrando el resumen sencillo sin conexión de Enprive.';

  @override
  String get consentReasonVoiceTimedOut =>
      'El resumen en el teléfono agotó el tiempo. Mostrando el resumen sencillo sin conexión de Enprive.';

  @override
  String get unsavedExitTitle => '¿Guardar esta revisión de privacidad?';

  @override
  String get unsavedExitModifiedBody =>
      'Las revisiones sin guardar se descartan al cerrar esta pantalla, así que nada se guarda en tu teléfono sin tu elección. Tu comprobante guardado original seguirá igual.';

  @override
  String get unsavedExitDraftBody =>
      'Las revisiones sin guardar se descartan al cerrar esta pantalla, así que nada se guarda en tu teléfono sin tu elección.';

  @override
  String get unsavedExitDiscardBtn => 'Descartar sin guardar';

  @override
  String get unsavedExitContinueBtn => 'Seguir revisando';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return 'Actualizar política de privacidad de $title';
  }

  @override
  String get reviewSaveFailedError =>
      'No se pudo guardar el comprobante. Tu borrador de revisión sigue abierto.';

  @override
  String get reviewRemovedFromReceiptsSnack =>
      'Eliminado de los comprobantes guardados.';

  @override
  String get reviewRemoveFailedSnack =>
      'No se pudo eliminar el comprobante guardado.';

  @override
  String get reviewModifiedDraftTitle =>
      'Nuevo borrador de un comprobante guardado';

  @override
  String get reviewModifiedDraftBody =>
      'Guarda en Comprobantes para conservar esta revisión actualizada: tu comprobante guardado original sigue igual.';

  @override
  String get btnRetrySave => 'Reintentar guardado';

  @override
  String samplePermissionsHeader(String badge) {
    return 'Permisos de ejemplo ($badge)';
  }

  @override
  String get sourceKindUrl => 'Enlace web público';

  @override
  String get sourceKindPdf => 'Archivo PDF local';

  @override
  String get sourceKindDocx => 'Archivo Word (DOCX) local';

  @override
  String get sourceKindTextFile => 'Archivo de texto local';

  @override
  String get sourceKindSharedText => 'Texto compartido';

  @override
  String get sourceKindSelectedText => 'Texto seleccionado';

  @override
  String get sourceKindSampleApp => 'App de ejemplo';

  @override
  String get sourceKindPhonePermissions => 'Permisos del teléfono';

  @override
  String get sourceKindPastedText => 'Texto pegado';

  @override
  String get extractionStatusExtracted => 'Leído en este teléfono';

  @override
  String get extractionStatusNone => 'Proporcionado en este teléfono';

  @override
  String get extractionStatusUnsupported => 'Tipo de archivo no compatible';

  @override
  String get extractionStatusTooLarge => 'Archivo demasiado grande';

  @override
  String get extractionStatusEmpty => 'Sin texto legible';

  @override
  String get extractionStatusReadError => 'No se pudo leer el archivo';

  @override
  String get extractionStatusPasswordProtected => 'Protegido con contraseña';

  @override
  String get extractionStatusPermissionDenied => 'Permiso denegado';

  @override
  String get extractionStatusCancelled => 'Cancelado';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return 'Revisado el: $timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return 'URL canónica: $url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return 'Redirigido desde: $url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return 'Archivo: $filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return 'Estado: $status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return 'Hash SHA-256 de origen: $hash';
  }

  @override
  String get semanticsPrimaryNavigation => 'Navegación principal';

  @override
  String semanticsProcessingLocation(String label) {
    return 'Lugar de procesamiento: $label';
  }

  @override
  String get semanticsDeniMascot => 'Deni, tu guía de privacidad';

  @override
  String get quoteCollapsibleDefaultHeader => 'Fragmento exacto de la política';
}
