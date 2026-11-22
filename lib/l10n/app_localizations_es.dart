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
      'Uno o más pasajes o diferencias de permisos merecen una revisión humana.';

  @override
  String get stateInsufficientEvidence => 'Pruebas insuficientes';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Faltan pruebas, no están disponibles o no pudieron verificarse en este dispositivo.';

  @override
  String get chipOnDevice => 'En este dispositivo';

  @override
  String get chipInCloud => 'En la nube';

  @override
  String get chipLocationUnavailable => 'Ubicación de análisis no disponible';

  @override
  String get chipOfflineDeterministic => 'Análisis local sin conexión';

  @override
  String get chipUnknown => 'Origen de procesamiento desconocido';

  @override
  String get statusSourceMatched => 'Texto verificado';

  @override
  String get statusDeviceObserved => 'Observado en el dispositivo';

  @override
  String get statusInterpretation => 'Interpretación';

  @override
  String get statusUnverified => 'Sin verificar';

  @override
  String get statusStale => 'Desactualizado';

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
      'Para analizar este texto en la nube, Enprive enviará únicamente el texto redactado mostrado arriba a Firebase AI Logic. Tu lista de apps instaladas y los permisos de Android nunca se enviarán.';

  @override
  String get permissionLimitationNotice =>
      'Android informa este estado de permisos en este teléfono. No demuestra si la app realmente accedió a los datos o los transmitió.';

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
      'Señala cláusulas de compartición, grabación de voz y retención con citas textuales.';

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
      other: '$count cláusulas verificadas',
      one: '1 cláusula verificada',
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
  String get readinessRow3Title => 'Datos personales ocultados';

  @override
  String get readinessRow3Desc =>
      'Si la IA local no está disponible o la política es extensa, nombres, correos y teléfonos se sustituyen por marcadores antes de verificar con App Check.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get privateAnalysisTitle => 'Análisis privado en este teléfono';

  @override
  String get onDeviceReadyMsg => 'La IA en el dispositivo está activa y lista.';

  @override
  String get localScannerProtectedMsg =>
      'Protegido por el escáner local integrado.';

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
      'Gemini Nano está listo en este teléfono. Las revisiones permanecen en tu dispositivo.';

  @override
  String get modelDownloadingMsg =>
      'Descargando el modelo privado en segundo plano.';

  @override
  String get modelDownloadableMsg =>
      'El modelo en el dispositivo puede descargarse por Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'Este teléfono usa de forma predeterminada el escáner local integrado de Enprive.';

  @override
  String get preparingPrivateAnalysis => 'Preparando análisis privado…';

  @override
  String get onDeviceAiReadyTitle => 'IA en el dispositivo lista';

  @override
  String get localScannerActiveTitle => 'Escáner local activo';

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
      'Leyendo cláusulas de la política en este teléfono…';

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
  String get thoughtSignaturePrefix => 'Firma de razonamiento';

  @override
  String get viewStreamedThoughts => 'Ver razonamiento transmitido';

  @override
  String get hideStreamedThoughts => 'Ocultar razonamiento';

  @override
  String get analysisTraceDefaultTitle => 'Cómo se verificó esta revisión';

  @override
  String get savedToLocalReceiptsSnack => 'Guardado en tus recibos locales.';

  @override
  String get snapshotSheetTitle => 'Copia de la política revisada';

  @override
  String get snapshotSourcePrefix => 'Fuente';

  @override
  String get snapshotReviewedPrefix => 'Revisado';

  @override
  String get snapshotDigestPrefix => 'Resumen';

  @override
  String get statFindings => 'Hallazgos';

  @override
  String get statVerified => 'Verificados';

  @override
  String get statOsGranted => 'Concedidos OS';

  @override
  String get statUnverified => 'Sin verificar';

  @override
  String get keyFindingsTitle => 'Hallazgos clave';

  @override
  String get reviewedExcerptTitle => 'Extracto revisado';

  @override
  String get permissionsOnPhoneTitle => 'Permisos en este teléfono';

  @override
  String get viewReviewedSnapshot => 'Ver copia de la política revisada';

  @override
  String get btnSavedToReceipts => 'Guardado en recibos';

  @override
  String get observedOnPhoneLabel => 'Observado en este teléfono';

  @override
  String get quoteVerifiedLabel => 'Cita verificada en la política';

  @override
  String get unverifiedClaimLabel => 'Afirmación sin verificar';

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
  String get labelWhatRemainsUnknown => 'Qué sigue sin saberse';

  @override
  String get presetQuestionMeaning =>
      '¿Qué significa esto para mi hijo o hija?';

  @override
  String get presetQuestionOptOut => '¿Podemos desactivar esto o rechazarlo?';

  @override
  String get presetQuestionUnknown => '¿Qué sigue sin quedar claro aquí?';

  @override
  String get readingCitedClause => 'Leyendo la cláusula citada…';

  @override
  String get deniAnswerTitle => 'Respuesta de Deni';

  @override
  String get stepsAndReasoning => 'Pasos y razonamiento del modelo';

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
  String get sampleSyntheticBadge => 'Ejemplo sintético';

  @override
  String get permissionInspectionTitle =>
      'Inspección de permisos del dispositivo';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Añadir la política de privacidad de esta app';

  @override
  String get snapshotDigestLabel =>
      'Resumen de instantánea · FNV-1a de 64 bits';

  @override
  String get snapshotDigestExplanation =>
      'Huella digital local rápida de 64 bits de este texto (no es SHA-256 criptográfico). Cambia si se modifica un solo carácter.';

  @override
  String get copyDigestBtn => 'Copiar resumen';

  @override
  String get digestCopiedMsg => 'Resumen de instantánea copiado';

  @override
  String get permissionGrantedBadge => 'Concedido';

  @override
  String get permissionNotGrantedBadge => 'No concedido';

  @override
  String get checkingPolicyWithCloudAi =>
      'Revisando la política con IA en la nube.';

  @override
  String get preparingCloudAiStream =>
      'Preparando verificación en la nube sin datos personales…';

  @override
  String get cancellingAnalysis => 'Cancelando…';

  @override
  String get analysisCancelledNotice => 'Revisión cancelada.';

  @override
  String get cloudTimedOutNotice =>
      'La IA en la nube superó el tiempo límite antes de responder. No se envió ningún reintento automático.';

  @override
  String get cloudFallbackBannerTitle =>
      'IA en la nube no disponible — escaneo local mostrado';

  @override
  String get cloudFallbackBannerBody =>
      'El análisis en la nube no estuvo disponible, por lo que este resultado proviene del escáner determinista local de Enprive.';

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
  String get appPickerStatusPermissionsInspected => 'Permissions inspected';

  @override
  String get appPickerStatusNotReviewed => 'Not reviewed';

  @override
  String get appPickerSearchHint => 'Search by app or package name…';

  @override
  String get appPickerEmptyInstalledTitle => 'No installed apps available';

  @override
  String get appPickerEmptyInstalledBody =>
      'No launchable apps were reported on this device.';

  @override
  String get intakeModeDocument => 'Document';

  @override
  String get intakeActionInspectText => 'Inspect policy text';

  @override
  String get intakeActionFetchUrl => 'Fetch & inspect policy';

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
      'Fetches the public web page directly. A user-supplied link does not prove app ownership.';

  @override
  String get intakePasteLocalNote =>
      'Checked locally on this phone first. Nothing is uploaded without your permission.';

  @override
  String get intakeDocumentCardTitle => 'Import PDF, TXT, or DOCX policy file';

  @override
  String get intakeDocumentCardBody =>
      'Text is extracted strictly on this phone (up to 10 MB) with a local SHA-256 snapshot hash. Files are never uploaded.';

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
      'Opens the app\'s Play Store listing so you can copy its privacy policy link. Enprive never scrapes Play Store or assumes link ownership.';

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
  String get intakeAssociationInspectWithoutApp => 'Inspect policy without app';

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
  String get voiceBadgeExpressive => 'Expressive voice · Puck';

  @override
  String get voiceBadgeDeviceOffline => 'Device voice · Offline';

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
      'To speak this summary with Deni’s expressive Gemini voice (Puck), Enprive will send only the redacted summary text shown above to Firebase AI Logic for this single request. Your installed apps and Android permissions are never sent.';

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
      'To rewrite these verified policy findings in plain language in the cloud, Enprive will send only the redacted excerpts shown above to Firebase AI Logic once. Your installed apps and Android permissions are never sent.';

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
      other: '$count personal details are masked first.',
      one: '1 personal detail is masked first.',
      zero: 'No personal details were found to mask.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'Your app list and phone permissions stay on this phone.';

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
  String get labelWhatAndroidReports => 'What Android reports';

  @override
  String get sourceButtonTooltip => 'Reviewed source';
}
