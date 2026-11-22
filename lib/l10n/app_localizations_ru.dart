// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline =>
      'Проверка конфиденциальности приложений на основе фактов';

  @override
  String get homePrivacySubtitle => 'Ваши проверки остаются на этом телефоне.';

  @override
  String get stateNoConcern => 'Поводов для беспокойства не выявлено';

  @override
  String get stateNoConcernSubtitle =>
      'В проверенных материалах не найдено тревожных пунктов. Это не является сертификатом безопасности.';

  @override
  String get stateReviewRecommended => 'Рекомендуется проверка';

  @override
  String get stateReviewRecommendedSubtitle =>
      'One or more policy parts or phone permissions need a closer look.';

  @override
  String get stateInsufficientEvidence => 'Недостаточно данных';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'We need more privacy policy text before we can check what this app does.';

  @override
  String get chipOnDevice => 'На этом устройстве';

  @override
  String get chipInCloud => 'В облаке';

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
  String get btnCheckApp => 'Проверить приложение';

  @override
  String get btnPasteTerms => 'Вставить текст или URL';

  @override
  String get btnWhyThisFinding => 'Почему этот вывод?';

  @override
  String get btnSaveToReceipts => 'Сохранить в чеки';

  @override
  String get btnDiscard => 'Удалить';

  @override
  String get btnAskDeni => 'Спросить Дени';

  @override
  String get btnUseCloud => 'Использовать облако для проверки';

  @override
  String get btnReviewManually => 'Проверить вручную';

  @override
  String get btnGetStarted => 'Начать';

  @override
  String get btnContinue => 'Продолжить';

  @override
  String get deniIntro =>
      'Привет, я Дени. Я помогу разобраться в политике конфиденциальности, покажу точные цитаты и объясню, что Enprive не смог проверить.';

  @override
  String get cloudConsentDisclosure =>
      'To check this in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Your phone shows whether this permission is allowed. It does not prove whether the app actually accessed or sent data.';

  @override
  String get navHome => 'Главная';

  @override
  String get navCheck => 'Проверка';

  @override
  String get navReceipts => 'Чеки';

  @override
  String get navLearn => 'Обучение';

  @override
  String get navSettings => 'Настройки';

  @override
  String get languageTitle => 'Язык';

  @override
  String get chooseLanguage => 'Выбор языка';

  @override
  String get languageSubtitle =>
      'Применяется к интерфейсу, пояснениям и озвучиванию';

  @override
  String get homeHeroHeadline => 'Наглядный взгляд на\nприложения для детей';

  @override
  String get trySampleCheck => 'Попробовать пример проверки';

  @override
  String get eduTrackSubtitle => 'Домашние задания и посещаемость';

  @override
  String get eduTrackValue => '3 запроса';

  @override
  String get eduTrackTrend => 'Проверить';

  @override
  String get calmMathSubtitle => 'Математика без интернета';

  @override
  String get calmMathValue => '0 чувствительных';

  @override
  String get calmMathTrend => 'Минимум';

  @override
  String get whatWeCheckTitle => 'Что мы проверяем';

  @override
  String get checkQuoteTitle => 'Точные цитаты из политики';

  @override
  String get checkQuoteDesc =>
      'Highlights data sharing, voice recording, and how long data is kept using exact quotes.';

  @override
  String get checkPermissionTitle => 'Несоответствие разрешений';

  @override
  String get checkPermissionDesc =>
      'Сравнивает доступ к камере, микрофону и геолокации с тем, что заявлено в политике.';

  @override
  String get checkSelectTitle => 'Проверка текста где угодно';

  @override
  String get checkSelectDesc =>
      'Выделите фрагмент в любом приложении и нажмите Enprive Check в меню Android.';

  @override
  String get recentlyReviewed => 'Недавно проверенные';

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
  String get trySampleText => 'Подставить пример текста';

  @override
  String get modePasteText => 'Вставить текст';

  @override
  String get modePolicyLink => 'Ссылка на политику';

  @override
  String get hintAppName => 'Название приложения';

  @override
  String get defaultSubjectTitle => 'Политика конфиденциальности';

  @override
  String get selectedExcerptTitle => 'Выбранный фрагмент политики';

  @override
  String get hintPastePolicy =>
      'Вставьте сюда текст политики конфиденциальности…';

  @override
  String get btnReviewOnPhone => 'Проверить на этом телефоне';

  @override
  String get onboardingIntroHeadline => 'Привет, я Дени. 👋';

  @override
  String get onboardingIntroLead =>
      'Давайте сделаем конфиденциальность приложений понятнее.';

  @override
  String get onboardingIntroBody =>
      'Я помогу узнать, что на самом деле говорится в политике конфиденциальности приложения, выделю действительно важные фрагменты и объясню, какие данные сообщает ваше устройство.\n\nНикаких догадок. Никаких ложных обещаний. Только понятные объяснения и факты для взвешенных решений.';

  @override
  String get onboardingIntroFooter => 'Знайте, на что вы соглашаетесь.';

  @override
  String get splashQuote => 'Знайте, на что вы соглашаетесь';

  @override
  String get onboardingStep1Question =>
      'Как мне объяснять\nусловия конфиденциальности?';

  @override
  String get depthQuickMultiline => 'Кратко и\nпросто';

  @override
  String get depthBalancedMultiline => 'Сбалансированный\nвид';

  @override
  String get depthFullMultiline => 'Полные\nдетали';

  @override
  String get onboardingReadinessTitle =>
      'Приватно по умолчанию\nна этом телефоне';

  @override
  String get onboardingReadinessSubtitle =>
      'Создано, чтобы родители и учителя могли проверять приложения без передачи данных устройства.';

  @override
  String get readinessRow1Title => 'Сначала локальная проверка';

  @override
  String get readinessRow1Desc =>
      'Политики в первую очередь анализируются прямо на вашем телефоне.';

  @override
  String get readinessRow2Title => 'Ваши приложения остаются при вас';

  @override
  String get readinessRow2Desc =>
      'Список приложений и их разрешения Android никогда не покидают этот телефон.';

  @override
  String get readinessRow3Title => 'Personal details hidden';

  @override
  String get readinessRow3Desc =>
      'If you choose cloud help, names, emails, and phone numbers are hidden before anything is sent.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get privateAnalysisTitle => 'Приватный анализ на этом телефоне';

  @override
  String get onDeviceReadyMsg => 'ИИ на устройстве активен и готов.';

  @override
  String get localScannerProtectedMsg =>
      'Ready to check policies offline on this phone.';

  @override
  String get statusChecking => 'Проверка…';

  @override
  String get btnCheckReadiness => 'Проверить готовность';

  @override
  String get howShouldDeniExplain => 'Как Дени должен объяснять?';

  @override
  String get depthQuick => 'Кратко';

  @override
  String get depthBalanced => 'Оптимально';

  @override
  String get depthFull => 'Подробно';

  @override
  String get preferencesSection => 'Параметры';

  @override
  String get meetDeniGuide => 'Знакомство с Дени и руководство';

  @override
  String clearSavedReceiptsCount(int count) {
    return 'Очистить сохранённые чеки ($count)';
  }

  @override
  String get btnClear => 'Очистить';

  @override
  String get confirmClearReceiptsTitle => 'Удалить сохранённые чеки?';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'С телефона будет удалено $count сохранённых проверок.',
      many: 'С телефона будут удалены $count сохранённых проверок.',
      few: 'С телефона будут удалены $count сохранённые проверки.',
      one: 'С телефона будет удалена $count сохранённая проверка.',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => 'Отмена';

  @override
  String get receiptsTitle => 'Чеки';

  @override
  String get tooltipSearch => 'Поиск';

  @override
  String get hintSearchReceipts => 'Поиск по сохранённым проверкам...';

  @override
  String get filterAll => 'Все';

  @override
  String get filterReview => 'Проверить';

  @override
  String get filterNoConcern => 'Без угроз';

  @override
  String get emptyFilteredTitle => 'Подходящие чеки не найдены';

  @override
  String get emptyReceiptsTitle => 'Сохранённых чеков пока нет';

  @override
  String get emptyFilteredBody => 'Попробуйте выбрать другой фильтр выше.';

  @override
  String get emptyReceiptsBody =>
      'Нажмите значок закладки после проверки, чтобы сохранить локальную копию на телефоне.';

  @override
  String get btnStartReview => 'Начать проверку';

  @override
  String get btnOpenReceipt => 'Открыть чек';

  @override
  String get btnDelete => 'Удалить';

  @override
  String get checkingPhoneReadiness =>
      'Проверка готовности приватного анализа на этом телефоне…';

  @override
  String get geminiNanoReadyMsg =>
      'On-device AI is ready on this phone. Reviews stay completely on your device.';

  @override
  String get modelDownloadingMsg =>
      'Загрузка приватной модели в фоновом режиме.';

  @override
  String get modelDownloadableMsg =>
      'Модель на устройстве можно загрузить по Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'This phone checks policies offline on your device by default.';

  @override
  String get preparingPrivateAnalysis => 'Подготовка приватного анализа…';

  @override
  String get onDeviceAiReadyTitle => 'ИИ на устройстве готов';

  @override
  String get localScannerActiveTitle => 'Offline check ready';

  @override
  String get privateAnalysisSheetSubtitle =>
      'Установленные приложения и проверки разрешений никогда не покидают ваш телефон.';

  @override
  String get btnDone => 'Готово';

  @override
  String get btnCheckAgain => 'Проверить снова';

  @override
  String get reviewingOnPhone => 'Проверка на этом телефоне…';

  @override
  String get readingClausesInitial => 'Reading policy text on this phone…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current из $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шагов',
      many: '$count шагов',
      few: '$count шага',
      one: '$count шаг',
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
  String get analysisTraceDefaultTitle => 'Как выполнена эта проверка';

  @override
  String get savedToLocalReceiptsSnack => 'Сохранено в локальные чеки.';

  @override
  String get snapshotSheetTitle => 'Reviewed policy text';

  @override
  String get snapshotSourcePrefix => 'Источник';

  @override
  String get snapshotReviewedPrefix => 'Проверено';

  @override
  String get snapshotDigestPrefix => 'Document fingerprint';

  @override
  String get statFindings => 'Выводы';

  @override
  String get statVerified => 'Подтверждено';

  @override
  String get statOsGranted => 'Allowed on phone';

  @override
  String get statUnverified => 'Not found';

  @override
  String get keyFindingsTitle => 'Ключевые выводы';

  @override
  String get reviewedExcerptTitle => 'Проверенный фрагмент';

  @override
  String get permissionsOnPhoneTitle => 'Разрешения на этом телефоне';

  @override
  String get viewReviewedSnapshot => 'View reviewed policy text';

  @override
  String get btnSavedToReceipts => 'Сохранено в чеки';

  @override
  String get observedOnPhoneLabel => 'Seen on this phone';

  @override
  String get quoteVerifiedLabel => 'Exact quote from policy';

  @override
  String get unverifiedClaimLabel => 'Not found in policy';

  @override
  String get categoryDataCollection => 'Сбор данных';

  @override
  String get categorySharing => 'Передача третьим лицам';

  @override
  String get categoryTracking => 'Геолокация и отслеживание';

  @override
  String get categoryRetention => 'Хранение и голос';

  @override
  String get categoryParentalControls => 'Родительский контроль';

  @override
  String get labelInPlainLanguage => 'Простым языком';

  @override
  String get labelOnThisPhone => 'На этом телефоне';

  @override
  String get labelWhatRemainsUnknown => 'What we still don\'t know';

  @override
  String get presetQuestionMeaning => 'Что это значит для моего ребёнка?';

  @override
  String get presetQuestionOptOut => 'Можно ли это отключить или отказаться?';

  @override
  String get presetQuestionUnknown => 'Что здесь по-прежнему неясно?';

  @override
  String get readingCitedClause => 'Reading the policy quote…';

  @override
  String get deniAnswerTitle => 'Ответ Дени';

  @override
  String get stepsAndReasoning => 'How Deni checked this';

  @override
  String get chooseReviewModeTitle => 'Выберите способ проверки текста';

  @override
  String get cloudNeverSendsAppsNote =>
      'Установленные приложения и разрешения телефона никогда не отправляются.';

  @override
  String get tooltipClose => 'Закрыть';

  @override
  String get checkAppSheetSubtitle =>
      'Проверяется локально на телефоне. Список приложений не загружается на сервер.';

  @override
  String get trySampleKidsApp => 'Попробовать пример детского приложения';

  @override
  String get sampleEduTrackSubtitle => 'Геолокация, микрофон и камера';

  @override
  String get sampleCalmMathSubtitle => 'Офлайн-тренажёр по математике';

  @override
  String get appsOnThisPhone => 'Приложения на этом телефоне';

  @override
  String get hintSearchApps => 'Поиск приложений…';

  @override
  String get noMatchingApps =>
      'Подходящие приложения на этом телефоне не найдены.';

  @override
  String get sampleSyntheticBadge => 'Sample app';

  @override
  String get permissionInspectionTitle => 'Phone permissions checked';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Добавить политику конфиденциальности приложения';

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
      'Проверка политики с помощью облачного ИИ.';

  @override
  String get preparingCloudAiStream =>
      'Hiding personal details before cloud check…';

  @override
  String get cancellingAnalysis => 'Отмена…';

  @override
  String get analysisCancelledNotice => 'Проверка отменена.';

  @override
  String get cloudTimedOutNotice =>
      'Облачный ИИ не ответил вовремя. Автоматический повтор не выполнялся.';

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
