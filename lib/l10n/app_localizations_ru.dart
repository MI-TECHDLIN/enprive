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
      'Один или несколько разделов политики или разрешений телефона требуют внимания.';

  @override
  String get stateInsufficientEvidence => 'Недостаточно данных';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Нужно больше текста политики конфиденциальности, чтобы проверить, что делает это приложение.';

  @override
  String get chipOnDevice => 'На этом устройстве';

  @override
  String get chipInCloud => 'В облаке';

  @override
  String get chipLocationUnavailable => 'Источник недоступен';

  @override
  String get chipOfflineDeterministic => 'Проверено офлайн на этом телефоне';

  @override
  String get chipUnknown => 'Источник неизвестен';

  @override
  String get statusSourceMatched => 'Найдено в политике';

  @override
  String get statusDeviceObserved => 'Замечено на этом телефоне';

  @override
  String get statusInterpretation => 'Пояснение Deni';

  @override
  String get statusUnverified => 'Не найдено в политике';

  @override
  String get statusStale => 'Более ранняя проверка';

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
      'Чтобы проверить это в облаке, Enprive отправит только текст, показанный выше (со скрытыми личными данными), для этого одного запроса. Ваши приложения и разрешения телефона никогда не отправляются.';

  @override
  String get permissionLimitationNotice =>
      'Ваш телефон показывает, выдано ли это разрешение. Это не доказывает, действительно ли приложение читало или отправляло данные.';

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
      'Показывает передачу данных, запись голоса и сроки хранения с помощью точных цитат.';

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
      other: '$count найденных цитат',
      many: '$count найденных цитат',
      few: '$count найденные цитаты',
      one: '$count найденная цитата',
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
  String get readinessRow3Title => 'Личные данные скрываются';

  @override
  String get readinessRow3Desc =>
      'Если вы выберете помощь облака, имена, адреса электронной почты и номера телефонов скрываются до отправки.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get privateAnalysisTitle => 'Приватный анализ на этом телефоне';

  @override
  String get onDeviceReadyMsg => 'ИИ на устройстве активен и готов.';

  @override
  String get localScannerProtectedMsg =>
      'Готово к офлайн-проверке политик на этом телефоне.';

  @override
  String get statusChecking => 'Проверка…';

  @override
  String get btnCheckReadiness => 'Проверить готовность';

  @override
  String get howShouldDeniExplain => 'Как Дени должен объяснять?';

  @override
  String get depthQuick => 'Кратко';

  @override
  String get depthBalanced => 'Баланс';

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
      'ИИ на устройстве готов к работе на этом телефоне. Проверки полностью остаются на вашем устройстве.';

  @override
  String get modelDownloadingMsg =>
      'Загрузка приватной модели в фоновом режиме.';

  @override
  String get modelDownloadableMsg =>
      'Модель на устройстве можно загрузить по Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'По умолчанию этот телефон проверяет политики офлайн на вашем устройстве.';

  @override
  String get preparingPrivateAnalysis => 'Подготовка приватного анализа…';

  @override
  String get onDeviceAiReadyTitle => 'ИИ на устройстве готов';

  @override
  String get localScannerActiveTitle => 'Офлайн-проверка готова';

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
  String get readingClausesInitial =>
      'Чтение текста политики на этом телефоне…';

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
  String get thoughtSignaturePrefix => 'ID проверки';

  @override
  String get viewStreamedThoughts => 'Как Enprive это проверил';

  @override
  String get hideStreamedThoughts => 'Скрыть, как Enprive это проверил';

  @override
  String get analysisTraceDefaultTitle => 'Как выполнена эта проверка';

  @override
  String get savedToLocalReceiptsSnack => 'Сохранено в локальные чеки.';

  @override
  String get snapshotSheetTitle => 'Проверенный текст политики';

  @override
  String get snapshotSourcePrefix => 'Источник';

  @override
  String get snapshotReviewedPrefix => 'Проверено';

  @override
  String get snapshotDigestPrefix => 'Отпечаток документа';

  @override
  String get statFindings => 'Выводы';

  @override
  String get statVerified => 'Подтверждено';

  @override
  String get statOsGranted => 'Разрешено на телефоне';

  @override
  String get statUnverified => 'Не найдено';

  @override
  String get keyFindingsTitle => 'Ключевые выводы';

  @override
  String get reviewedExcerptTitle => 'Проверенный фрагмент';

  @override
  String get permissionsOnPhoneTitle => 'Разрешения на этом телефоне';

  @override
  String get viewReviewedSnapshot => 'Посмотреть проверенный текст политики';

  @override
  String get btnSavedToReceipts => 'Сохранено в чеки';

  @override
  String get observedOnPhoneLabel => 'Замечено на этом телефоне';

  @override
  String get quoteVerifiedLabel => 'Точная цитата из политики';

  @override
  String get unverifiedClaimLabel => 'Не найдено в политике';

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
  String get labelWhatRemainsUnknown => 'Что пока остаётся неизвестным';

  @override
  String get presetQuestionMeaning => 'Что это значит для моего ребёнка?';

  @override
  String get presetQuestionOptOut => 'Можно ли это отключить или отказаться?';

  @override
  String get presetQuestionUnknown => 'Что здесь по-прежнему неясно?';

  @override
  String get readingCitedClause => 'Чтение цитаты из политики…';

  @override
  String get deniAnswerTitle => 'Ответ Дени';

  @override
  String get stepsAndReasoning => 'Как Deni это проверил';

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
  String get sampleSyntheticBadge => 'Пример приложения';

  @override
  String get permissionInspectionTitle => 'Разрешения телефона проверены';

  @override
  String get addAppPrivacyPolicyBtn =>
      'Добавить политику конфиденциальности приложения';

  @override
  String get snapshotDigestLabel => 'Отпечаток документа';

  @override
  String get snapshotDigestExplanation =>
      'Уникальный код, помогающий убедиться, что Enprive проверил именно этот текст. Если изменится хотя бы одна буква, код тоже изменится.';

  @override
  String get copyDigestBtn => 'Копировать отпечаток';

  @override
  String get digestCopiedMsg => 'Отпечаток документа скопирован';

  @override
  String get permissionGrantedBadge => 'Разрешено на этом телефоне';

  @override
  String get permissionNotGrantedBadge => 'Не разрешено';

  @override
  String get checkingPolicyWithCloudAi =>
      'Проверка политики с помощью облачного ИИ.';

  @override
  String get preparingCloudAiStream =>
      'Скрытие личных данных перед облачной проверкой…';

  @override
  String get cancellingAnalysis => 'Отмена…';

  @override
  String get analysisCancelledNotice => 'Проверка отменена.';

  @override
  String get cloudTimedOutNotice =>
      'Облачный ИИ не ответил вовремя. Автоматический повтор не выполнялся.';

  @override
  String get cloudFallbackBannerTitle =>
      'Облачную проверку не удалось завершить';

  @override
  String get cloudFallbackBannerBody =>
      'Это результат проверки на вашем телефоне, ничего повторно не отправлялось. Текст политики сохранён. Ничего не сохраняется, пока вы не нажмёте «Сохранить».';

  @override
  String get cloudFallbackRetryAction => 'Повторить облачную проверку';

  @override
  String get appPickerFilterAll => 'Все приложения';

  @override
  String get appPickerFilterDownloaded => 'Скачанные';

  @override
  String get appPickerFilterSystem => 'Системные';

  @override
  String get appPickerRecentlyChecked => 'Недавно проверенные';

  @override
  String get appPickerStatusPolicySaved => 'Проверка политики сохранена';

  @override
  String get appPickerStatusPermissionsInspected => 'Разрешения проверены';

  @override
  String get appPickerStatusNotReviewed => 'Не проверялось';

  @override
  String get appPickerSearchHint => 'Поиск по названию или App ID…';

  @override
  String get appPickerEmptyInstalledTitle =>
      'Нет доступных установленных приложений';

  @override
  String get appPickerEmptyInstalledBody =>
      'Не удалось найти приложения для проверки на этом телефоне.';

  @override
  String get intakeModeDocument => 'Документ';

  @override
  String get intakeActionInspectText => 'Проверить текст политики';

  @override
  String get intakeActionFetchUrl => 'Открыть и проверить политику';

  @override
  String get intakeActionChooseDocument => 'Выбрать PDF, TXT или DOCX';

  @override
  String get intakeActionReplaceDocument => 'Выбрать другой документ';

  @override
  String get intakeWorkingLabel => 'Обработка…';

  @override
  String get intakeCancelFetch => 'Отменить загрузку';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      'Загружает эту общедоступную веб-страницу напрямую. Добавление ссылки не доказывает, кому принадлежит приложение.';

  @override
  String get intakePasteLocalNote =>
      'Сначала проверяется локально на этом телефоне. Без вашего согласия ничего не отправляется.';

  @override
  String get intakeDocumentCardTitle =>
      'Импорт файла политики PDF, TXT или DOCX';

  @override
  String get intakeDocumentCardBody =>
      'Мы читаем текст прямо на вашем телефоне (до 10 МБ). Ваш файл никогда не загружается в сеть.';

  @override
  String get intakeCompareWithAppPrompt =>
      'Сравнить с установленным приложением (необязательно)';

  @override
  String get intakeCompareWithAppHint =>
      'Выполняется локально на этом телефоне. Список приложений никогда не покидает устройство.';

  @override
  String get intakeCompareWithAppChange => 'Изменить';

  @override
  String get intakeCompareWithAppRemove => 'Убрать';

  @override
  String get intakeLockedAppContextLabel => 'Выбранное приложение';

  @override
  String get intakeFindPolicyOnPlayStore =>
      'Найти ссылку на политику в Play Store';

  @override
  String get intakePlayStoreHelperNote =>
      'Открывает Play Store, чтобы вы могли скопировать ссылку на политику конфиденциальности. Enprive никогда не копирует её сам и не считает ссылку официальной.';

  @override
  String get intakePlayStoreUnavailable =>
      'Не удалось открыть Google Play Store на этом устройстве. Вставьте URL или текст политики вручную.';

  @override
  String get intakeRecoverySwitchPaste => 'Вставить текст';

  @override
  String get intakeRecoverySwitchDocument => 'Импорт документа';

  @override
  String get intakeRecoveryRetryUrl => 'Повторить загрузку';

  @override
  String get intakeExpiredDocumentShareNotice =>
      'Исходную ссылку на переданный файл больше нельзя открыть повторно. Выберите другой файл PDF, TXT или DOCX или вставьте текст политики вручную.';

  @override
  String get intakeAssociationWarningTitle =>
      'Проверка связи приложения и политики';

  @override
  String get intakeAssociationContinueAnyway => 'Всё равно продолжить';

  @override
  String get intakeAssociationChangeApp => 'Сменить приложение';

  @override
  String get intakeAssociationInspectWithoutApp =>
      'Проверить политику без приложения';

  @override
  String get intakeModeSelectorSemanticLabel => 'Способ ввода политики';

  @override
  String get tooltipClearSearch => 'Очистить поиск';

  @override
  String get intakeRecoveryEditUrl => 'Изменить URL';

  @override
  String get voiceSummaryTitle => 'Краткий разбор Deni простым языком';

  @override
  String get voiceSummaryPreparing =>
      'Подготовка краткого разбора простым языком…';

  @override
  String get voiceSynthesizingExpressive =>
      'Подготовка выразительного голоса Deni…';

  @override
  String get voiceBtnListenOffline => 'Слушать';

  @override
  String get voiceBtnStop => 'Стоп';

  @override
  String get voiceBtnExpressiveCloud => 'Выразительный голос';

  @override
  String get voiceBtnSummarizeCloud => 'Кратко с облачным ИИ';

  @override
  String get voiceBadgeExpressive => 'Выразительный облачный голос';

  @override
  String get voiceBadgeDeviceOffline => 'Голос телефона · Офлайн';

  @override
  String get voiceViewSourceQuote => 'Цитата из источника';

  @override
  String get voiceHideSourceQuote => 'Скрыть цитату';

  @override
  String get voiceInspectFinding => 'Открыть вывод';

  @override
  String get voiceConsentTitle => 'Выберите голос Deni';

  @override
  String get voiceConsentDisclosure =>
      'Чтобы озвучить этот разбор выразительным облачным голосом Deni, Enprive отправит только показанный выше текст разбора (со скрытыми личными данными) для этого одного запроса. Ваши приложения и разрешения телефона никогда не отправляются.';

  @override
  String get voiceConsentPrimaryAction =>
      'Использовать выразительный голос один раз';

  @override
  String get voiceConsentSecondaryAction => 'Озвучить на этом телефоне';

  @override
  String get voiceConsentPayloadLabel => 'Точный текст для озвучивания';

  @override
  String get voiceSummaryConsentTitle => 'Кратко изложить выводы с облачным ИИ';

  @override
  String get voiceSummaryConsentDisclosure =>
      'Чтобы кратко пересказать эти цитаты простым языком в облаке, Enprive отправит только показанный выше текст (со скрытыми личными данными) для этого одного запроса. Ваши приложения и разрешения телефона никогда не отправляются.';

  @override
  String get voiceFallbackDeviceNotice =>
      'Выразительный облачный голос недоступен: используется офлайн-голос этого телефона.';

  @override
  String get voiceUnavailableNotice =>
      'Озвучивание для этого языка недоступно на этом телефоне. Вы можете прочитать разбор Deni выше.';

  @override
  String get voiceTooltipReadSummary =>
      'Послушать краткий разбор Deni простым языком';

  @override
  String get voiceTooltipStopReading => 'Остановить озвучивание';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'выводов',
      many: 'выводов',
      few: 'вывода',
      one: 'вывод',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выводов',
      many: '$count выводов',
      few: '$count вывода',
      one: '$count вывод',
      zero: 'Выводов нет',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count цитат подтверждено в политике',
      many: '$count цитат подтверждено в политике',
      few: '$count цитаты подтверждены в политике',
      one: '$count цитата подтверждена в политике',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count замечено на этом телефоне',
      many: '$count замечено на этом телефоне',
      few: '$count замечены на этом телефоне',
      one: '$count замечено на этом телефоне',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => 'Разрешено на этом телефоне';

  @override
  String get permissionNotAllowedOnPhone => 'Не разрешено';

  @override
  String get permissionAllowedInSample => 'Разрешено в примере';

  @override
  String get permissionNotAllowedInSample => 'Не разрешено в примере';

  @override
  String get permissionMismatchChip => 'Нет в политике';

  @override
  String get howEnpriveCheckedThis => 'Как Enprive это проверил';

  @override
  String get hideHowEnpriveChecked => 'Скрыть, как Enprive это проверил';

  @override
  String get consentWhatWouldBeSent => 'Что будет отправлено';

  @override
  String get consentSentScope =>
      'С этого телефона уйдёт только текст из предпросмотра, для этого одного запроса.';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сначала скрыто $count личных деталей.',
      many: 'Сначала скрыто $count личных деталей.',
      few: 'Сначала скрыты $count личные детали.',
      one: 'Сначала скрыта $count личная деталь.',
      zero: 'Личных данных для скрытия не найдено.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone =>
      'Ваш список приложений и разрешения телефона остаются на этом телефоне.';

  @override
  String receiptDeletedSnack(String title) {
    return 'Удалено: $title';
  }

  @override
  String get btnUndo => 'Отменить';

  @override
  String get readinessPromiseMaskedTitle => 'Личные данные скрываются';

  @override
  String get readinessPromiseMaskedLine =>
      'Если вы выберете облако, имена, почта и номера скрываются заранее.';

  @override
  String findingDetailTitle(int index, int total) {
    return 'Вывод $index из $total';
  }

  @override
  String get findingReviewChip => 'Проверить';

  @override
  String get askDeniAboutThis => 'Спросить Deni об этом';

  @override
  String get labelWhatPolicySays => 'Что говорит политика';

  @override
  String get labelWhatAndroidReports => 'Что показывает ваш телефон';

  @override
  String get sourceButtonTooltip => 'Проверенный источник';

  @override
  String get linkInstalledAppBtn => 'Связать приложение';

  @override
  String get linkInstalledAppCardTitle =>
      'Сравнить с приложением на этом телефоне';

  @override
  String get linkInstalledAppCardBody =>
      'Выберите установленное приложение, чтобы сравнить его разрешения с этой политикой в одной проверке. Список приложений остаётся на этом телефоне.';

  @override
  String get linkAppPickerTitle => 'Связать приложение';

  @override
  String get changeLinkedAppPickerTitle => 'Сменить связанное приложение';

  @override
  String get linkAppPickerSubtitle =>
      'Выберите приложение на этом телефоне, чтобы сравнить его разрешения с этой политикой. Список приложений никогда не покидает телефон.';

  @override
  String get linkedAppCurrentlySelectedBadge => 'Связано';

  @override
  String get linkedAppSectionLabel => 'Связанное приложение на этом телефоне';

  @override
  String get btnChangeLinkedApp => 'Сменить';

  @override
  String get btnUnlinkApp => 'Отвязать';

  @override
  String get btnUpdatePrivacyPolicy => 'Прикрепить обновлённую политику';

  @override
  String linkedAppSnack(String appName) {
    return 'Связано: $appName. Разрешения сравнены на этом телефоне.';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return 'Связано: $appName. Проверьте примечание о совпадении ниже.';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName уже связано с теми же разрешениями.';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return 'Связь с $appName снята. Показана только проверка политики.';
  }

  @override
  String get associationStatusPackageTitle => 'App ID найден в этой политике';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return 'В этой политике упоминается $packageName. Это указывает, что она может относиться к $appName, но сам текст не доказывает, кому принадлежит политика.';
  }

  @override
  String get associationStatusNameTitle =>
      'Название приложения найдено в политике';

  @override
  String associationStatusNameBody(String appName) {
    return 'В этой политике упоминается $appName. Это указывает, что она может относиться к этому приложению, но совпадение названия не доказывает, кому принадлежит политика.';
  }

  @override
  String get associationStatusUnverifiedTitle => 'Связано вами для сравнения';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return 'В этой политике не указаны $appName и его App ID. Убедитесь, что выбрана нужная политика: связывание здесь не доказывает принадлежность.';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return 'Веб-адрес содержит слова из $appName, но сам текст политики не называет это приложение. Убедитесь, что выбрана нужная политика: связывание здесь не доказывает принадлежность.';
  }

  @override
  String get associationStatusUnmatchedTitle =>
      'Эта политика может быть для другого приложения';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return 'В этой политике не упоминается $appName. Вместо этого указаны: $otherApps. Проверьте, то ли приложение вы связали и ту ли политику открыли.';
  }

  @override
  String get associationStatusAmbiguousConflictTitle =>
      'В этой политике указано несколько приложений';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return 'В этой политике упоминаются $appName и $otherApps. Она может касаться нескольких приложений или быть общей политикой компании, поэтому проверьте, применима ли она здесь.';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      'На этом телефоне несколько приложений с похожим названием';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return 'В этой политике упоминается $appName без точного App ID, а на телефоне есть другие приложения ($otherApps) с похожим названием. Убедитесь, что вы связали нужное.';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return 'Эта политика может относиться к нескольким приложениям. Проверьте, применима ли она к $appName.';
  }

  @override
  String get associationOwnershipLimitation =>
      'Текст и веб-ссылки никогда не доказывают, кто опубликовал политику или владеет ею.';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count разрешений на этом телефоне не упомянуты чётко в этой политике. Несоответствие: это повод присмотреться, а не доказательство нарушения.',
      many:
          '$count разрешений на этом телефоне не упомянуты чётко в этой политике. Несоответствие: это повод присмотреться, а не доказательство нарушения.',
      few:
          '$count разрешения на этом телефоне не упомянуты чётко в этой политике. Несоответствие: это повод присмотреться, а не доказательство нарушения.',
      one:
          '$count разрешение на этом телефоне не упомянуто чётко в этой политике. Несоответствие: это повод присмотреться, а не доказательство нарушения.',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      'Ни одно из проверенных разрешений на этом телефоне не противоречит этой политике. Одни разрешения не показывают, что приложение отправляет на самом деле.';

  @override
  String get permissionComparisonLimitationNote =>
      'Ваш телефон показывает только настройки разрешений на этом телефоне. Это сравнение лишь повод присмотреться, но никогда не доказательство нарушений или отправки данных.';

  @override
  String get permissionNotRequestedOnPhone => 'Не запрашивается';

  @override
  String get permissionNotRequestedInSample => 'Не запрашивается в примере';

  @override
  String get permissionsEmptyComparisonTitle =>
      'Чувствительные разрешения не найдены';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return 'Телефон показывает $requestedCount разрешений ($grantedCount выдано) для $appName, но ни одного в проверяемых чувствительных категориях (геолокация, камера, микрофон, контакты, фото или рекламный ID).';
  }

  @override
  String get sourceDeviceInspection => 'Проверено на этом телефоне';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => 'Расширенные сведения';

  @override
  String get advancedDetailsSubtitle =>
      'Технические сведения, подтверждающие, когда и где был проверен этот текст политики.';

  @override
  String get sourceSectionTitle => 'Откуда взята эта политика';

  @override
  String get cloudPayloadLabel => 'Точный текст для отправки';

  @override
  String get cloudPayloadNoPiiLabel => 'Личные данные не найдены';

  @override
  String cloudPayloadHiddenCount(int count) {
    return 'Скрыто ($count)';
  }

  @override
  String get summarySourceOnDevice => 'Обобщено на этом телефоне';

  @override
  String get summarySourceInCloud => 'Обобщено в облаке';

  @override
  String get summarySourceOffline => 'Обобщено офлайн на этом телефоне';

  @override
  String get summarySourceUnknown => 'Источник разбора неизвестен';

  @override
  String get notFromPolicySuffix =>
      'Из настроек вашего телефона, не из политики';

  @override
  String get sampleNotFromPolicySuffix => 'Только пример, не из политики';

  @override
  String get learnHeaderSubtitle => 'Офлайн-руководства и схемы по приватности';

  @override
  String get learnFilterAll => 'Все темы';

  @override
  String get learnFilterPolicies => 'Политики';

  @override
  String get learnFilterPermissions => 'Разрешения';

  @override
  String get learnFilterSharing => 'Передача';

  @override
  String get learnFilterEvidence => 'Факты';

  @override
  String learnLessonStepCount(int count) {
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
  String get learnDeckTitle =>
      'Тренируйте полезные привычки приватности локально';

  @override
  String get learnDeckBody =>
      '100% офлайн-уроки со схемами. Ваши установленные приложения и чеки никогда не попадают в раздел Обучение.';

  @override
  String get learnDeckCheckBtn => 'Применить · Проверить приложение';

  @override
  String get learnCheckAppBridgeBtn => 'Проверить приложение на этом телефоне';

  @override
  String get learnSectionDiagram => 'Как это работает';

  @override
  String get learnSectionSteps => 'Основные шаги';

  @override
  String get learnSectionQuickCheck => 'Быстрая проверка';

  @override
  String get learnTooltipListenLesson => 'Прослушать урок офлайн';

  @override
  String get learnTooltipStopLesson => 'Остановить озвучивание урока';

  @override
  String get learnVoiceUnavailableNotice =>
      'Офлайн-озвучивание для этого языка недоступно на этом телефоне. Вы можете прочитать урок ниже.';

  @override
  String get learnQuickCheckCorrectBadge => 'Верный ответ';

  @override
  String get learnQuickCheckTryAgainBadge => 'Попробуйте другой вариант';

  @override
  String learnLessonProgress(int current, int total) {
    return 'Урок $current из $total';
  }

  @override
  String get learnBackTooltip => 'Назад к Обучению';

  @override
  String get learnPreviousLesson => 'Назад';

  @override
  String get learnNextLesson => 'Далее';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return 'Предыдущий урок: $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return 'Следующий урок: $title';
  }

  @override
  String get learnPolicyFolderTitle => 'Политики приватности';

  @override
  String get learnPolicyTitle =>
      'Что такое политика конфиденциальности (и чего она не доказывает)';

  @override
  String get learnPolicySubtitle =>
      'Что обещают разработчики и что остаётся неизвестным';

  @override
  String get learnPolicyIntro =>
      'Политика конфиденциальности: публичное заявление разработчика о том, какие данные приложение заявляет собирать, зачем они нужны, кто может их получить и какие есть настройки у семьи.';

  @override
  String get learnPolicyStep1 =>
      'Ищите четыре основы: какие данные собираются, зачем они приложению, кто ещё может их получить и как запросить удаление.';

  @override
  String get learnPolicyStep2 =>
      'Запутанные формулировки встречаются часто. Исследование детских учебных приложений 2026 года показало, что лишь немногие политики легко читать, а большинство приложений не полностью соответствовали своим политикам.';

  @override
  String get learnPolicyStep3 =>
      'Политика конфиденциальности показывает лишь то, что разработчик написал на бумаге. Её чтение не доказывает, что приложение на самом деле отправляет в интернет.';

  @override
  String get learnPolicyStep4 =>
      'Сравнение политики с разрешениями вашего телефона даёт более ясную картину, при этом важно помнить, что Enprive не видит реальный интернет-трафик.';

  @override
  String get learnPolicyQuickQuestion =>
      'Что доказывает чтение политики конфиденциальности приложения?';

  @override
  String get learnPolicyQuickOption1 =>
      'Что приложение никогда никому не отправляет данные';

  @override
  String get learnPolicyQuickOption2 =>
      'То, что заявляет разработчик, а не то, что приложение реально отправляет';

  @override
  String get learnPolicyQuickOption3 =>
      'Что камера и микрофон телефона выключены';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      'Верно. Политика является публичным заявлением разработчика, а не доказательством того, что приложение фактически отправляет в интернет.';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      'Не совсем. Политика сообщает только слова разработчика: она не доказывает сетевую активность и не отключает разрешения телефона.';

  @override
  String get learnDiagramPolicySaysTitle => 'Политика говорит';

  @override
  String get learnDiagramPolicySaysBody => 'Письменное обещание разработчика';

  @override
  String get learnDiagramPolicyQuoteSample =>
      '«Мы можем передавать данные партнёрам…»';

  @override
  String get learnDiagramPhoneShowsTitle => 'Телефон показывает';

  @override
  String get learnDiagramPhoneShowsBody => 'Разрешения, выданные здесь';

  @override
  String get learnDiagramUnknownTitle => 'Пока неизвестно';

  @override
  String get learnDiagramUnknownBody =>
      'Сетевой трафик, который Enprive не видит';

  @override
  String get learnDiagramPolicyCaption =>
      'Политика является обещанием, а не доказательством поведения';

  @override
  String get learnDiagramPolicySemantic =>
      'Схема, сравнивающая три стороны приватности приложения. Первое, Политика говорит: письменное обещание разработчика. Второе, Телефон показывает: разрешения, выданные на этом телефоне. Третье, в пунктирной рамке, Пока неизвестно: реальный интернет-трафик, который Enprive не может видеть. Политика конфиденциальности является обещанием, а не доказательством поведения.';

  @override
  String get learnPermissionsFolderTitle => 'Разрешения телефона';

  @override
  String get learnPermissionsTitle => 'Как устроены разрешения Android';

  @override
  String get learnPermissionsSubtitle =>
      'Четыре варианта Android и где их проверить';

  @override
  String get learnPermissionsIntro =>
      'Разрешения работают как замки, которые решают, может ли приложение обращаться к датчикам и данным телефона: камере, микрофону, геолокации, фото, контактам или уведомлениям.';

  @override
  String get learnPermissionsStep1 =>
      'Спросите, подходит ли разрешение к задаче: приложению для счёта или чтения редко нужны геолокация, контакты или камера.';

  @override
  String get learnPermissionsStep2 =>
      'Android предлагает до четырёх вариантов: Не разрешать, Спрашивать каждый раз, Разрешить только во время использования приложения и Разрешить в любом режиме (для фоновой геолокации).';

  @override
  String get learnPermissionsStep3 =>
      'Начинайте с самого узкого варианта, с которым функция работает, например Спрашивать каждый раз или Во время использования приложения.';

  @override
  String get learnPermissionsStep4 =>
      'Откройте Настройки Android и загляните в Панель конфиденциальности, чтобы увидеть, какие приложения недавно обращались к Камере, Микрофону или Геолокации.';

  @override
  String get learnPermissionsStep5 =>
      'Отключайте разрешения в любое время в настройках приложения или оставьте включённой приостановку неиспользуемых приложений, чтобы Android сам снимал старые разрешения. Выданное разрешение показывает возможность, а не факт отправки данных.';

  @override
  String get learnPermissionsQuickQuestion =>
      'Приложение по математике просит доступ к камере, и вы не знаете зачем. Какой лучший первый шаг?';

  @override
  String get learnPermissionsQuickOption1 =>
      'Нажать Не разрешать и проверить, работают ли задания по математике';

  @override
  String get learnPermissionsQuickOption2 =>
      'Выбрать В любом режиме, чтобы окно больше не появлялось';

  @override
  String get learnPermissionsQuickOption3 =>
      'Решить, что приложение уже загрузило фотографии';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      'Правильно. Нажав Не разрешать, вы проверите, работает ли приложение без камеры, а изменить разрешения можно в любой момент в Настройках Android.';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      'Сначала попробуйте более узкий вариант. Нажмите Не разрешать, чтобы проверить работу функции, и помните: выданное разрешение показывает возможность, а не факт отправки.';

  @override
  String get learnDiagramPermLadderTitle =>
      'От самого узкого доступа к самому широкому';

  @override
  String get learnDiagramPermDenyTitle => 'Не разрешать';

  @override
  String get learnDiagramPermDenyDetail =>
      'Заблокировано: датчик недоступен приложению';

  @override
  String get learnDiagramPermAskTitle => 'Спрашивать каждый раз';

  @override
  String get learnDiagramPermAskDetail => 'Разовый доступ после вашего нажатия';

  @override
  String get learnDiagramPermWhileUsingTitle => 'Во время использования';

  @override
  String get learnDiagramPermWhileUsingDetail =>
      'Только пока приложение открыто на экране';

  @override
  String get learnDiagramPermAllTimeTitle => 'В любом режиме';

  @override
  String get learnDiagramPermAllTimeDetail =>
      'Доступ в фоне, даже когда приложение закрыто';

  @override
  String get learnDiagramPermFitNote =>
      'Логично ли это? Математика + Камера = стоит спросить зачем';

  @override
  String get learnDiagramPermSemantic =>
      'Четырёхступенчатая лестница разрешений Android от самого узкого доступа к самому широкому. Шаг 1, Не разрешать: заблокировано, приложение не может использовать датчик. Шаг 2, Спрашивать каждый раз: разовый доступ после вашего подтверждения. Шаг 3, Во время использования: доступ только пока приложение открыто на экране. Шаг 4, В любом режиме: доступ в фоне даже после закрытия, обведён пунктиром для особого внимания. Совет внизу: Логично ли это? Если тест по математике просит камеру, стоит спросить зачем.';

  @override
  String get learnSharingFolderTitle => 'Реклама и третьи лица';

  @override
  String get learnSharingTitle =>
      'Кто ещё получает данные: реклама, аналитика и третьи лица';

  @override
  String get learnSharingSubtitle =>
      'Создатель приложения vs. помощники, аналитика и рекламные сети';

  @override
  String get learnSharingIntro =>
      'Многие бесплатные приложения в фоне подключаются к другим компаниям. Понимание того, кто получает информацию, помогает семьям отличать работу приложения от отслеживания детей между разными приложениями.';

  @override
  String get learnSharingStep1 =>
      'Первая сторона означает самого создателя приложения: например, сохранение прогресса заданий или баллов теста для работы приложения.';

  @override
  String get learnSharingStep2 =>
      'Компании-помощники являются третьими лицами, выполняющими технические задачи в фоне, например облачное хранение или отчёты о сбоях для исправления ошибок.';

  @override
  String get learnSharingStep3 =>
      'Инструменты аналитики измеряют использование экранов, а рекламные сети и брокеры данных могут использовать рекламный ID для показа целевой рекламы или составления профиля по разным приложениям.';

  @override
  String get learnSharingStep4 =>
      'Обращайте внимание на размытые фразы вроде «доверенные партнёры» или «деловые цели» и проверяйте, объясняет ли политика, как отключить персонализированную рекламу.';

  @override
  String get learnSharingQuickQuestion =>
      'В политике написано, что приложение делится данными со «сторонними партнёрами». Какой лучший следующий вопрос?';

  @override
  String get learnSharingQuickOption1 => 'Решить, что в приложении нет рекламы';

  @override
  String get learnSharingQuickOption2 =>
      'Решить, что все партнёры выполняют одну и ту же работу';

  @override
  String get learnSharingQuickOption3 =>
      'Проверить, это технические помощники (например, хостинг) или рекламные сети, отслеживающие действия между приложениями';

  @override
  String get learnSharingQuickCorrectFeedback =>
      'Точно. Технические сервисы поддерживают работу приложения, а рекламные сети и брокеры данных могут отслеживать активность между приложениями.';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      'Присмотритесь, чем занимается каждый партнёр. Не все третьи лица одинаковы: одни хранят данные или чинят сбои, а другие показывают рекламу или ведут отслеживание.';

  @override
  String get learnDiagramThirdPartyYou => 'Вы';

  @override
  String get learnDiagramThirdPartyApp => 'Учебное приложение';

  @override
  String get learnDiagramThirdPartyHosting => 'Помощники и сбои';

  @override
  String get learnDiagramThirdPartyAnalytics => 'Аналитика';

  @override
  String get learnDiagramThirdPartyAds => 'Рекламные сети';

  @override
  String get learnDiagramThirdPartyFirstParty => 'Первая сторона';

  @override
  String get learnDiagramThirdPartyThirdParty => 'Третьи лица';

  @override
  String get learnDiagramThirdPartySemantic =>
      'Схема потоков данных из детского учебного приложения. Вы подключаетесь к учебному приложению, которое сплошной линией связано с разработчиком (первой стороной) и пунктирными линиями с третьими лицами: сервисами поддержки и отчётов о сбоях, аналитикой и выделенными для особого внимания рекламными сетями.';

  @override
  String get learnEvidenceFolderTitle => 'Как читать Enprive';

  @override
  String get learnEvidenceTitle => 'Как читать факты в Enprive';

  @override
  String get learnEvidenceSubtitle =>
      'Уровни фактов, категории и честные границы';

  @override
  String get learnEvidenceIntro =>
      'Enprive разделяет то, что сказано в политике конфиденциальности, что показывает ваш телефон и что остаётся неизвестным, и группирует выводы по темам, но никогда не ставит оценку безопасности.';

  @override
  String get learnEvidenceStep1 =>
      'Пять тематических категорий группируют каждый вывод тем же значком и цветом, что и на экране проверки. Цвет означает тему, а не балл безопасности.';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '«$sourceMatched» означает, что Enprive нашёл точную дословную цитату в проверенном тексте политики.';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '«$deviceObserved» означает, что ваш телефон сообщил о настройке разрешения на этом устройстве: это не доказательство отправки данных.';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '«$interpretation» означает пояснение Deni простым языком, а «$unverified» отмечает детали, которых Enprive не нашёл. Умолчание в политике никогда не является обещанием.';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return 'Проверки завершаются одним из трёх спокойных итогов: $reviewRecommended, $noConcern (что никогда не является сертификатом безопасности) или $insufficientEvidence.';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return 'Что означает метка «$deviceObserved» на экране проверки?';
  }

  @override
  String get learnEvidenceQuickOption1 =>
      'Что приложение сертифицировано как безопасное для детей';

  @override
  String get learnEvidenceQuickOption2 =>
      'Что ваш телефон показывает эту настройку разрешения на устройстве: это не доказывает загрузку данных';

  @override
  String get learnEvidenceQuickOption3 =>
      'Что приложение точно загрузило данные вашего ребёнка';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      'Верно. Эта метка отражает состояние разрешения Android на устройстве; она не доказывает отправку данных и не подтверждает безопасность.';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      'Не совсем. Эта метка показывает лишь состояние разрешения на вашем телефоне: она никогда не доказывает отправку данных и не является сертификатом безопасности.';

  @override
  String get learnDiagramEvidencePolicyDetail =>
      'Точная цитата, найденная в тексте политики';

  @override
  String get learnDiagramEvidencePhoneDetail =>
      'Разрешения телефона на этом устройстве';

  @override
  String get learnDiagramEvidenceDeniDetail => 'Пояснение Deni простым языком';

  @override
  String get learnDiagramEvidenceUnknownDetail =>
      'Умолчание в политике не является обещанием';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Четыре уровня фактов на экране проверки Enprive: 1, $sourceMatched, точная цитата из политики конфиденциальности; 2, $deviceObserved, разрешения на этом устройстве; 3, $interpretation, пояснение Deni простым языком; и 4, отделённый пунктирной линией, $unverified, потому что умолчание в политике не является обещанием.';
  }

  @override
  String get learnDiagramCategoriesTitle =>
      'Пять тематических категорий на экране проверки';

  @override
  String get learnDiagramCategoriesNote =>
      'Цвет и значок означают тему, но никогда не оценку безопасности.';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Пять категорий фактов на экране проверки Enprive, каждая со своим значком и цветом: $dataCollection, $sharing, $tracking, $retention и $parentalControls. Цвет и значок означают тему, но никогда не оценку безопасности.';
  }

  @override
  String get learnDataCollectionFolderTitle => 'Какие данные собирают';

  @override
  String get learnDataCollectionTitle => 'Какие данные собирают приложения';

  @override
  String get learnDataCollectionSubtitle =>
      'Разница между тем, что вы вводите, и тем, что собирается незаметно';

  @override
  String get learnDataCollectionIntro1 =>
      'Приложения собирают сведения двумя способами. Часть данных вы вводите сами: имя, почту, фото, голосовые записи или ответы на задания. Другие собираются автоматически в фоне: IP-адрес (адрес вашего телефона в интернете), идентификаторы устройства, рекламный ID (код, по которому реклама узнаёт телефон), журналы сбоев и время открытия приложения.';

  @override
  String get learnDataCollectionStep1 =>
      'Что вы вводите: имя, школу, почту, фото, голосовые записи и ответы на задания вы передаёте осознанно.';

  @override
  String get learnDataCollectionStep2 =>
      'Что собирается незаметно: приложение может собирать рекламный ID, идентификаторы устройства, IP-адрес, отчёты о сбоях и время работы без нажатия кнопок. Фоновый сбор не всегда плох: эти сигналы помогают приложению работать стабильно.';

  @override
  String get learnDataCollectionStep3 =>
      'Чувствительные детские данные: геолокация, записи микрофона, фото с камеры и биометрия вроде образцов голоса (данные о теле или голосе) несут более высокий риск для приватности детей.';

  @override
  String get learnDataCollectionStep4 =>
      'Примечание о Play Store: раздел «Безопасность данных» в Google Play заполняет сам разработчик. Это подсказка, а не доказательство, и туда не входят данные, обрабатываемые только на устройстве или кратковременно в памяти.';

  @override
  String get learnDataCollectionQuizQuestion =>
      'Что из этого является примером данных, собираемых незаметно в фоне?';

  @override
  String get learnDataCollectionQuizChoiceA =>
      'Фотография, которую вы загрузили для профиля';

  @override
  String get learnDataCollectionQuizChoiceB =>
      'Ваш рекламный ID и идентификаторы устройства';

  @override
  String get learnDataCollectionQuizChoiceC =>
      'Ответ на задание, который вы ввели в приложении';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      'Верно: рекламный ID и идентификаторы устройства собираются автоматически без вашего ввода.';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      'Не совсем: эти данные вы вводите сами. К данным, собираемым в фоне, относятся рекламный ID, идентификаторы устройства, IP-адрес и время использования.';

  @override
  String get learnDataCollectionDiagramYouTypeTitle =>
      'Что вы вводите или даёте';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => 'Имя, почта, школа';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => 'Фото и видео';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => 'Голосовые записи';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => 'Ответы на задания';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle =>
      'Что собирается в фоне';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => 'Рекламный ID';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 =>
      'Идентификаторы устройства';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'IP-адрес';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 =>
      'Отчёты о сбоях и время работы';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      'Незаметно не значит плохо: эти сигналы помогают приложениям работать стабильно.';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      'Разделённая схема с двумя категориями сбора данных. Верхняя карточка «Что вы вводите или даёте» содержит четыре пункта: Имя, почта, школа; Фото и видео; Голосовые записи; Ответы на задания. Нижняя карточка «Что собирается в фоне» содержит четыре пункта: Рекламный ID; Идентификаторы устройства; IP-адрес; Отчёты о сбоях и время работы. Небольшое примечание гласит: «Незаметно не значит плохо: эти сигналы помогают приложениям работать стабильно.» Ниже сидит Deni в задумчивой позе.';

  @override
  String get learnDataCollectionCheckBridge =>
      'Проверьте приложение на этом телефоне, чтобы увидеть, какие данные оно собирает.';

  @override
  String get learnDataCollectionHonestyNote =>
      'Этот урок объясняет типичные виды данных. Он не доказывает, что именно собирает или отправляет конкретное приложение. Это покажут только точный текст политики и настройки разрешений вашего телефона.';

  @override
  String get learnRetentionFolderTitle => 'Хранение и удаление';

  @override
  String get learnRetentionTitle => 'Хранение и удаление данных';

  @override
  String get learnRetentionSubtitle =>
      'Удаление приложения с телефона не стирает данные на серверах компании';

  @override
  String get learnRetentionIntro1 =>
      'Когда вы удаляете приложение с телефона, стираются файлы на вашем устройстве, но данные, уже отправленные на серверы компании, остаются там. В политиках конфиденциальности должно быть указано, сколько хранятся данные, как запросить удаление и что происходит с резервными копиями, но многие используют расплывчатые фразы вроде «столько, сколько разумно необходимо».';

  @override
  String get learnRetentionStep1 =>
      'Сбор данных: пока вы пользуетесь приложением, ваши сведения отправляются и сохраняются на серверах компании.';

  @override
  String get learnRetentionStep2 =>
      'Хранение на серверах: ваши данные могут оставаться в системах компании даже после того, как вы перестанете пользоваться приложением.';

  @override
  String get learnRetentionStep3 =>
      'Удаление приложения не стирает данные на сервере: с телефона исчезают только локальные файлы, но не копии на серверах компании.';

  @override
  String get learnRetentionStep4 =>
      'Запрос на удаление: вы можете попросить компанию удалить аккаунт и данные; в политике должно быть сказано, сколько времени это занимает.';

  @override
  String get learnRetentionStep5 =>
      'Неизвестный срок хранения: политики со словами «по мере необходимости» или «для деловых целей» не дают ясного срока удаления.';

  @override
  String get learnRetentionQuizQuestion =>
      'Что происходит с вашими данными на серверах компании, когда вы удаляете приложение с телефона?';

  @override
  String get learnRetentionQuizChoiceA => 'Они удаляются автоматически';

  @override
  String get learnRetentionQuizChoiceB =>
      'Они могут остаться на серверах: удаление приложения их не стирает';

  @override
  String get learnRetentionQuizChoiceC => 'Они мгновенно обезличиваются';

  @override
  String get learnRetentionQuizFeedbackRight =>
      'Верно: удаление убирает приложение только с телефона. Данные на серверах компании могут оставаться, пока вы не запросите удаление.';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      'Не совсем: удаление приложения не стирает данные, уже загруженные на серверы компании. Нужно отправить запрос на удаление аккаунта.';

  @override
  String get learnRetentionDiagramCollected =>
      'Данные собираются при использовании';

  @override
  String get learnRetentionDiagramStored => 'Хранятся на серверах компании';

  @override
  String get learnRetentionDiagramUninstall =>
      'Вы удаляете приложение: локальные файлы уходят, данные на сервере остаются';

  @override
  String get learnRetentionDiagramDeleteRequest =>
      'Вы запрашиваете удаление аккаунта';

  @override
  String get learnRetentionDiagramUnknownTail =>
      'Неизвестный срок: в политике сказано «по мере необходимости»';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      'Пятишаговая шкала жизненного цикла данных. Шаг 1: Данные собираются при использовании, со значком базы данных. Шаг 2: Хранятся на серверах компании, со значком сервера. Шаг 3: Вы удаляете приложение: локальные файлы уходят, данные на сервере остаются, со значком смартфона. Шаг 4: Вы запрашиваете удаление аккаунта, со значком корзины. Шаг 5: Неизвестный срок: в политике сказано «по мере необходимости», с пунктирной стрелкой и значком вопроса. Ниже стоит Deni с чеком в руке.';

  @override
  String get learnRetentionCheckBridge =>
      'Проверьте приложение на этом телефоне, чтобы увидеть, что политика говорит о хранении.';

  @override
  String get learnRetentionHonestyNote =>
      'Этот урок описывает типичные подходы к хранению. Он не доказывает, что конкретная компания делает с вашими данными. Это покажут только точный текст политики и запрос на удаление.';

  @override
  String get learnUnclearPoliciesFolderTitle => 'Неясные политики';

  @override
  String get learnUnclearPoliciesTitle =>
      'Как замечать неясные политики и хитрые кнопки';

  @override
  String get learnUnclearPoliciesSubtitle =>
      'Как распознавать расплывчатые слова и навязчивые экраны согласия';

  @override
  String get learnUnclearPoliciesIntro1 =>
      'Некоторые политики конфиденциальности используют размытые формулировки, из-за которых трудно понять, что реально происходит с данными. Экраны согласия тоже могут использовать приёмы дизайна, например огромную яркую кнопку «Принять всё» рядом с крошечной ссылкой «Настроить», чтобы подтолкнуть к согласию без чтения.';

  @override
  String get learnUnclearPoliciesStep1 =>
      'Признаки тумана: замечайте открытые фразы вроде «можем делиться с доверенными партнёрами», «в деловых целях» или «хранить по мере необходимости»: они скрывают реальные детали.';

  @override
  String get learnUnclearPoliciesStep2 =>
      'Умолчание не является обещанием: если в политике ни слова нет о микрофоне, рекламе или геолокации, это не гарантирует, что приложение их не использует.';

  @override
  String get learnUnclearPoliciesStep3 =>
      'Отсутствуют основы: у понятной политики есть чёткая дата вступления в силу, адрес для связи и один цельный документ, а не спрятанное дополнение для детей.';

  @override
  String get learnUnclearPoliciesStep4 =>
      'Навязанное согласие (тёмные паттерны): гигантские кнопки «Принять всё», заранее отмеченные галочки рассылок, навязчивые повторы и спрятанная отмена подписки созданы, чтобы обойти ваш выбор.';

  @override
  String get learnUnclearPoliciesStep5 =>
      'Равный выбор: честный экран показывает одинаковые кнопки «Разрешить» и «Не разрешать», а необязательные переключатели выключены по умолчанию.';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      'Какая фраза в политике конфиденциальности является «туманным» сигналом о нехватке подробностей?';

  @override
  String get learnUnclearPoliciesQuizChoiceA =>
      'Мы не продаём ваши личные данные третьим лицам';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      'Мы можем передавать данные доверенным партнёрам в деловых целях';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'Вы можете запросить удаление по адресу privacy@example.com';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      'Верно: «можем передавать доверенным партнёрам в деловых целях» звучит расплывчато и не называет ни партнёров, ни передаваемые данные.';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      'Не совсем: эта фраза конкретна и понятна. «Туманные» фразы используют открытые слова вроде «можем делиться» или «по мере необходимости» без подробностей.';

  @override
  String get learnUnclearPoliciesDiagramClearTitle => 'Ясная фраза в политике';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      'Мы собираем имя и почту для создания аккаунта. Мы не передаём их рекламодателям.';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle =>
      'Туманная фраза в политике';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      'Мы можем передавать ваши сведения доверенным партнёрам в деловых целях по мере необходимости.';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle => 'Как распознать туман';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      'Ищите слова «может», «вправе» или «по мере необходимости»: они оставляют лазейку.';

  @override
  String get learnUnclearPoliciesDiagramTip2 =>
      'Проверьте, называет ли политика конкретные компании, получающие данные.';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      'Умолчание о рекламе или микрофоне не обещает, что приложение их не использует.';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote =>
      'Умолчание в политике не является обещанием.';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      'Сравнение ясной и туманной фразы политики рядом. Левая карточка «Ясно» показывает: «Мы собираем имя и почту для создания аккаунта. Мы не передаём их рекламодателям.» Правая карточка «Туманно» показывает: «Мы можем передавать ваши сведения доверенным партнёрам в деловых целях по мере необходимости.» Ниже карточка советов «Как распознать туман» перечисляет три подсказки: ищите слова «может», «вправе» или «по мере необходимости»; проверьте, названы ли конкретные компании; умолчание о рекламе или микрофоне не является обещанием. На туманной карточке примечание: «Умолчание в политике не является обещанием.» Deni выглядывает из-за карточек.';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      'Проверьте приложение на этом телефоне, чтобы оценить его экран согласия и ясность политики.';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      'Этот урок описывает типичные неясные приёмы. Он не доказывает, что конкретное приложение использует тёмные паттерны или скрывает работу с данными. Это покажут только точный текст политики и реальный экран согласия.';

  @override
  String get learnSafeSharingFolderTitle => 'Безопасные привычки';

  @override
  String get learnSafeSharingTitle =>
      'Привычки осторожного общения в сети для детей';

  @override
  String get learnSafeSharingSubtitle =>
      'Стоп, Подумайте, Поделитесь: шаги по возрасту для публикаций в сети';

  @override
  String get learnSafeSharingIntro1 =>
      'Прежде чем выложить фото, видео, имя или местоположение, сделайте паузу и используйте три шага: Стоп, Подумайте, Поделитесь. Этот урок создан для совместного чтения с надёжным взрослым. Младшие дети (5-7 лет) спрашивают, прежде чем нажать. Дети 8-11 лет используют никнеймы и надёжные пароли. Подростки (12-17 лет) следят за цифровым следом (тем, что остаётся от публикаций) и включают двухфакторную защиту (вторую проверку, например код при входе).';

  @override
  String get learnSafeSharingStep1 =>
      'Стоп: сделайте паузу, прежде чем публиковать фото, видео, имя, школу или местоположение. Если не уверены, спросите надёжного взрослого.';

  @override
  String get learnSafeSharingStep2 =>
      'Подумайте: не раскрывает ли это мою школу, дом или место, где я сейчас? Спросил ли я друзей, прежде чем выкладывать их фото или отмечать их?';

  @override
  String get learnSafeSharingStep3 =>
      'Поделитесь: делитесь только с теми, кому доверяете. Держите в секрете личные данные: полное имя, день рождения, адрес и номер телефона.';

  @override
  String get learnSafeSharingStep4 =>
      'Правило школьной столовой: было бы мне комфортно, если бы вся школа (или весь класс) увидели это фото или сообщение? Даже исчезающие посты можно сохранить скриншотом, и они останутся в сети навсегда.';

  @override
  String get learnSafeSharingStep5 =>
      '5-7 лет: спрашивайте надёжного взрослого, прежде чем писать своё имя или нажимать всплывающие окна. 8-11 лет: используйте ник (не настоящее имя, дату рождения и школу), надёжные пароли и никогда не делитесь кодами из SMS или OTP (одноразовыми кодами из сообщений: их нельзя никому говорить). 12-17 лет: проверяйте настройки приватности, включайте двухфакторную защиту и знайте, как пожаловаться на проблему.';

  @override
  String get learnSafeSharingQuizQuestion =>
      'Что такое «правило школьной столовой» при публикациях в сети?';

  @override
  String get learnSafeSharingQuizChoiceA =>
      'Делиться только тем, что ешь в столовой';

  @override
  String get learnSafeSharingQuizChoiceB =>
      'Спросить себя: было бы мне нормально, если бы вся школа увидела это фото или сообщение?';

  @override
  String get learnSafeSharingQuizChoiceC =>
      'Публиковать только во время обеденного перерыва';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      'Верно: правило школьной столовой означает спросить себя, комфортно ли вам, если публикацию увидят все вокруг.';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      'Не совсем: правило школьной столовой является мысленной проверкой: устроило бы вас, если бы ваш пост показали всей столовой?';

  @override
  String get learnSafeSharingDiagramStop =>
      'Стоп: сделайте паузу перед публикацией';

  @override
  String get learnSafeSharingDiagramThink =>
      'Подумайте: не раскрывает ли это, где я и с кем?';

  @override
  String get learnSafeSharingDiagramConnect =>
      'Поделитесь: только с близкими, при сомнении спросите взрослого';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      'Правило школьной столовой: было бы мне нормально, если бы это увидела вся школа? Даже исчезающие посты можно сохранить скриншотом, и они останутся в сети навсегда.';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      'Схема из четырёх частей о привычках осторожного общения в сети. Шаг 1: Стоп: сделайте паузу перед публикацией, со значком руки. Шаг 2: Подумайте: не раскрывает ли это, где я и с кем?, со значком мозга. Шаг 3: Поделитесь: только с близкими, при сомнении спросите взрослого, со значком людей. Шаг 4: блок правила школьной столовой спрашивает «Было бы мне нормально, если бы это увидела вся школа? Даже исчезающие посты можно сохранить скриншотом, и они останутся в сети навсегда.» Рядом стоит Deni с поднятой рукой.';

  @override
  String get learnSafeSharingCheckBridge =>
      'Проверьте приложение вместе с родителем, чтобы увидеть, как оно работает с передачей данных.';

  @override
  String get learnSafeSharingHonestyNote =>
      'Этот урок делится общими привычками осторожного общения. Он не гарантирует, что какое-либо приложение защитит то, чем вы делитесь. Всегда читайте политику приложения и используйте настройки приватности телефона.';

  @override
  String get translationDraftNotice =>
      'Некоторые переводы являются черновиками, созданными ИИ, и могут содержать неточности. Носители языка сейчас их проверяют.';

  @override
  String get homeQuickSettingsTitle => 'Помощник в быстрых настройках';

  @override
  String get homeQuickSettingsSubtitle =>
      'Спрашивайте Deni о приложении, которым вы пользуетесь, в любой момент';

  @override
  String get appearanceSectionTitle => 'Оформление';

  @override
  String get themeModeSystem => 'Авто';

  @override
  String get themeModeLight => 'Светлая';

  @override
  String get themeModeDark => 'Тёмная';

  @override
  String get quickSettingsSectionTitle =>
      'Подключить Enprive к быстрым настройкам';

  @override
  String get quickSettingsSectionSubtitle =>
      'Добавьте Enprive Check на панель быстрых настроек Android, чтобы спрашивать Deni о приложениях, не прерывая своих дел.';

  @override
  String get quickSettingsTileTitle => 'Плитка Enprive Check';

  @override
  String get quickSettingsTileSubtitle =>
      'Добавьте Enprive Check в быстрые настройки, чтобы спросить Deni о приложении, которым вы пользуетесь, не ища сначала Enprive.';

  @override
  String get quickSettingsStatusAdded => 'Добавлена';

  @override
  String get quickSettingsStatusManual => 'Вручную';

  @override
  String get quickSettingsStatusNotAdded => 'Не добавлена';

  @override
  String get usageAccessStatusGranted => 'Предоставлен';

  @override
  String get usageAccessStatusNotGranted => 'Не предоставлен';

  @override
  String get usageAccessTitle =>
      'Разрешить доступ к данным об использовании (необязательно)';

  @override
  String get usageAccessExplanation =>
      'Enprive использует доступ к данным об использовании только когда вы нажимаете Enprive Check, чтобы определить приложение, которым вы только что пользовались. Так Deni находит нужное приложение и сведения о его конфиденциальности. Enprive не следит за вашим экраном постоянно.';

  @override
  String get usageAccessManageLink => 'Как управлять доступом или отозвать его';

  @override
  String get usageAccessManageTitle =>
      'Управление доступом к данным об использовании';

  @override
  String get usageAccessManageBody =>
      'Доступ к данным об использовании это особый переключатель в настройках Android (а не автоматическое всплывающее окно). Его можно отключить в любой момент: Настройки Android → Приложения → Специальный доступ → Доступ к данным об использовании → enprive. Deni работает и без него, если выбирать приложение вручную.';

  @override
  String get openDeniCompanionTitle => 'Открыть помощника Deni';

  @override
  String get openDeniCompanionSubtitle =>
      'Посмотрите разрешения недавнего или выбранного приложения без быстрых настроек.';

  @override
  String get btnGotIt => 'Понятно';

  @override
  String get quickSettingsReadyDialogTitle =>
      'Enprive Check готов в быстрых настройках';

  @override
  String get quickSettingsReadyDialogBody =>
      'Дважды проведите пальцем вниз от верхнего края экрана и нажмите «Enprive Check», когда хотите, чтобы Deni объяснил разрешения приложения.';

  @override
  String get quickSettingsManualDialogTitle => 'Добавить Enprive Check вручную';

  @override
  String get quickSettingsManualDialogBody =>
      '1. Дважды проведите пальцем вниз от верхнего края экрана Android, чтобы открыть быстрые настройки.\n2. Нажмите кнопку «Изменить» (карандаш).\n3. Найдите «Enprive Check» и перетащите его к активным плиткам.';

  @override
  String get quickSettingsSnackAdded =>
      'Enprive Check добавлен в ваши быстрые настройки.';

  @override
  String get quickSettingsSnackAlreadyAdded =>
      'Enprive Check уже есть в ваших быстрых настройках.';

  @override
  String get quickSettingsSnackDeclined =>
      'Запрос закрыт. Enprive не будет спрашивать снова, пока вы сами не выберете «Изменить» в быстрых настройках.';

  @override
  String get quickSettingsSnackManual =>
      'Опустите быстрые настройки, нажмите «Изменить» и перетащите Enprive Check к своим плиткам.';

  @override
  String get quickSettingsSnackUnavailable =>
      'Системный запрос здесь недоступен: вы можете перетащить Enprive Check вручную через «Изменить» в быстрых настройках.';

  @override
  String get usageAccessOpenFailedSnack =>
      'Не удалось открыть настройки доступа к данным об использовании на этом устройстве.';

  @override
  String get companionTitle => 'Deni: помощник Enprive';

  @override
  String get companionSubtitle =>
      'Спросите Deni о разрешениях приложения и о том, что говорится в его политике конфиденциальности.';

  @override
  String get companionTooltipReturnToPrev =>
      'Вернуться к предыдущему приложению';

  @override
  String get companionTooltipBack => 'Назад';

  @override
  String get companionLockedBadge => 'ЭКРАН БЛОКИРОВКИ ЗАЩИЩЁН';

  @override
  String get companionLockedTitle => 'Разблокируйте телефон, чтобы продолжить';

  @override
  String get companionLockedBody =>
      'Пока устройство заблокировано, Enprive скрывает названия приложений, заявленные разрешения и данные проверки.';

  @override
  String get companionCheckUnlockBtn =>
      'Проверить, разблокировано ли устройство';

  @override
  String get companionCheckingAppHeadline =>
      'Проверяем, каким приложением вы пользовались…';

  @override
  String get companionCheckingAppSubtitle =>
      'Проверка выполняется один раз на этом телефоне, без наблюдения за вашим экраном.';

  @override
  String get companionGeneralGuideHeadline =>
      'Общее руководство по разрешениям Android';

  @override
  String get companionGeneralGuideSubtitle =>
      'Приложение не выбрано. Enprive объясняет разрешения Android только с помощью локальных подсказок.';

  @override
  String companionLookingAtHeadline(String appName) {
    return 'Вы смотрите на $appName.';
  }

  @override
  String get companionLookingAtSubtitle =>
      'Разрешения ниже взяты из приложения на вашем телефоне. Всплывающим окном на экране по-прежнему управляет Android.';

  @override
  String get companionThisAppFallback => 'это приложение';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return 'Мы заметили $appName $seconds с назад. Это верно?';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return 'Мы думаем, что вы пользуетесь $appName. Это верно?';
  }

  @override
  String companionAppIdLine(String packageName) {
    return 'App ID: $packageName';
  }

  @override
  String companionConfirmAppBtn(String appName) {
    return 'Подтвердить · $appName';
  }

  @override
  String get companionChooseAnotherAppBtn => 'Выбрать другое приложение';

  @override
  String get companionWithoutAppContextBtn => 'Без приложения';

  @override
  String get companionMultipleAppsTitle =>
      'Только что были активны несколько приложений';

  @override
  String get companionMultipleAppsPrompt =>
      'Подтвердите, какое приложение вы хотите проверить:';

  @override
  String companionSecondsAgo(int seconds) {
    return '$seconds с назад';
  }

  @override
  String get companionSelectAppTitle => 'Выберите приложение для проверки';

  @override
  String get companionSelectAppBody =>
      'Выберите приложение вручную из установленных или продолжите без приложения.';

  @override
  String get companionChooseAppManuallyBtn => 'Выбрать приложение вручную';

  @override
  String get companionOpenUsageAccessBtn =>
      'Открыть настройки доступа к данным об использовании';

  @override
  String get companionContinueWithoutAppBtn => 'Продолжить без приложения';

  @override
  String get companionAddTileBtn => 'Добавить плитку Enprive Check';

  @override
  String get companionContinuingWithoutApp => 'Продолжаем без приложения';

  @override
  String get companionSwitchAppBtn => 'Сменить приложение';

  @override
  String get companionPermissionsReadLocally =>
      'Разрешения ниже считываются прямо с вашего телефона.';

  @override
  String get companionPickPermissionType =>
      'Выберите тип разрешения, чтобы узнать о нём';

  @override
  String get companionPickAppBtn => 'Выбрать приложение';

  @override
  String get companionCouldNotReadPermsTitle =>
      'Не удалось прочитать разрешения приложения';

  @override
  String get companionCouldNotReadPermsBody =>
      'Android не позволил проверить разрешения этого приложения.';

  @override
  String get companionUnsurePermBtn => 'Я не знаю, какое это разрешение';

  @override
  String get companionWhichPermissionPrompt =>
      'Какое разрешение вы хотите понять?';

  @override
  String get companionPermissionsListDisclaimer =>
      'Это разрешения, которые приложение указывает на вашем телефоне, а не обязательно то окно, которое сейчас на вашем экране.';

  @override
  String get companionNoSensitivePermsMsg =>
      'Это приложение не запрашивает на вашем телефоне никаких важных разрешений.';

  @override
  String get companionGuidedMatchTitle =>
      'Выберите, что запрашивало окно на вашем экране';

  @override
  String get companionGuidedMatchSubtitle =>
      'Enprive не может напрямую прочитать текущий запрос Android. Выберите формулировку, ближайшую к той, что появилась на экране:';

  @override
  String get companionSection1Title => '1. Что означает это разрешение';

  @override
  String get companionSection2Title =>
      '2. Что приложение запрашивает на вашем телефоне';

  @override
  String get companionSection3Title =>
      '3. Что говорит его политика конфиденциальности';

  @override
  String get companionSection4Title =>
      '4. Почему это может быть связано с функцией';

  @override
  String get companionSection4Fallback =>
      'Подтверждённого объяснения разработчика о функции не найдено. Опишите ниже, какой функцией вы хотели воспользоваться, если хотите, чтобы Deni проверил, есть ли связь.';

  @override
  String get companionSection5Title => '5. Что остаётся неизвестным';

  @override
  String get companionSection6Title => '6. Вопросы, которые можно задать Deni';

  @override
  String get companionAddPolicyBtn => 'Добавить политику конфиденциальности';

  @override
  String get companionCheckUpdatedPolicyBtn =>
      'Проверить обновлённую политику конфиденциальности';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return 'Проверить политику для $appName';
  }

  @override
  String get companionFeatureFieldLabel =>
      'Функция, которой вы пользовались (необязательно)';

  @override
  String get companionFeatureFieldHint =>
      'например, сканирование QR-кода, запись голосовой тренировки';

  @override
  String get companionQuestionFieldLabel => 'Задайте вопрос Deni';

  @override
  String get companionQuestionFieldHint =>
      'Что будет, если я откажу в этом разрешении?';

  @override
  String get companionReceiptSavedTitle => 'Сохранено в чеках Enprive';

  @override
  String get companionReceiptUnsavedTitle =>
      'Проверка ещё не сохранена в Enprive';

  @override
  String get companionReceiptSavedBody =>
      'Хранится на устройстве в вашем архиве чеков Enprive.';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      'Проверка обновлённой политики хранится только в этом сеансе. Если выйти из помощника, этот черновик будет удалён, а сохранённый чек останется без изменений.';

  @override
  String get companionReceiptUnsavedBody =>
      'Хранится только в этом сеансе. Если выйти из помощника, она будет удалена, если вы её не сохраните.';

  @override
  String get companionSaveReceiptBtn => 'Сохранить чек в Enprive';

  @override
  String get companionSaveReceiptFailed =>
      'Не удалось сохранить чек. Он остаётся в этом сеансе: попробуйте ещё раз.';

  @override
  String get companionSavedLocalReceiptsSnack => 'Сохранено в локальных чеках.';

  @override
  String companionDoneReturnToApp(String appName) {
    return 'Готово · Вернуться к $appName';
  }

  @override
  String get companionDoneReturnToPrev =>
      'Готово · Вернуться к предыдущему приложению';

  @override
  String get companionOpenFullAppBtn => 'Открыть полное приложение Enprive';

  @override
  String get companionCloudTimeoutSnack =>
      'Облачный анализ шёл слишком долго и был остановлен до завершения.';

  @override
  String get companionAnalysisCancelledSnack => 'Анализ отменён.';

  @override
  String get companionCloudAnswerTimeoutSnack =>
      'Время ожидания облачного ответа истекло без сбоев.';

  @override
  String get companionQuestionCancelledSnack => 'Вопрос отменён.';

  @override
  String get companionTileAddedSnack =>
      'Enprive Check добавлен в быстрые настройки Android.';

  @override
  String get companionTileAlreadyAddedSnack =>
      'Enprive Check уже есть в ваших быстрых настройках.';

  @override
  String get companionTileDeclinedSnack =>
      'Запрос на добавление плитки закрыт. Её можно добавить в любой момент в настройках или через «Изменить» в быстрых настройках.';

  @override
  String get companionTileManualSnack =>
      'Дважды опустите быстрые настройки, нажмите «Изменить» и перетащите Enprive Check к своим плиткам.';

  @override
  String get companionTileUnavailableSnack =>
      'Android не смог показать запрос быстрых настроек на этом устройстве. Вы можете перетащить Enprive Check вручную через «Изменить» в быстрых настройках.';

  @override
  String get companionUsageOptionalReason =>
      'Доступ к данным об использовании необязателен. Вы можете выбрать приложение вручную или разрешить доступ, чтобы определять его одним нажатием.';

  @override
  String get companionPermPreciseLocation => 'Точное местоположение';

  @override
  String get companionPermBackgroundLocation =>
      'Местоположение в фоновом режиме';

  @override
  String get companionPermCamera => 'Камера';

  @override
  String get companionPermMicrophone => 'Микрофон';

  @override
  String get companionPermAdId => 'Рекламный идентификатор Google';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return 'Разрешение Android ($permission), заявленное приложением $appName.';
  }

  @override
  String get companionPermStatusAdId => 'Указано в приложении · Рекламный ID';

  @override
  String get companionPermStatusAllowed => 'Указано в приложении · Разрешено';

  @override
  String get companionPermStatusNotAllowed =>
      'Указано в приложении · Не разрешено';

  @override
  String get guidedCatLocation => 'Местоположение';

  @override
  String get guidedCatContacts => 'Контакты';

  @override
  String get guidedCatPhotosMedia => 'Фото и медиа';

  @override
  String get guidedCatNotifications => 'Уведомления';

  @override
  String get guidedCatNearbyDevices => 'Устройства поблизости';

  @override
  String get guidedCatCalendar => 'Календарь';

  @override
  String get guidedCatPhone => 'Телефон';

  @override
  String get guidedCatSms => 'SMS';

  @override
  String get companionFallbackUsageNotEnabled =>
      'Доступ к данным об использовании не включён в настройках Android.';

  @override
  String get companionFallbackUsageUnavailable =>
      'Android UsageStatsManager недоступен.';

  @override
  String get companionFallbackTransientUi =>
      'В последних событиях использования появились только системные окна Android или запросы разрешений. Выберите приложение вручную.';

  @override
  String get companionFallbackVisibilityRestricted =>
      'Последнее активное приложение нельзя проверить из-за ограничений Android на видимость пакетов. Выберите приложение из списка или вставьте его политику.';

  @override
  String get companionFallbackUnlockRequired =>
      'Разблокируйте устройство, прежде чем смотреть сведения о приложении.';

  @override
  String get consentReasonPolicyTooDetailed =>
      'Эта политика слишком подробная для обработки ИИ на устройстве.';

  @override
  String get consentReasonExcerptTooDetailed =>
      'Этот фрагмент вывода слишком подробный для обработки ИИ на устройстве.';

  @override
  String get consentReasonOnDeviceUnavailable =>
      'ИИ на устройстве сейчас недоступен на этом телефоне.';

  @override
  String get consentReasonOnDeviceCannotAnswer =>
      'ИИ на устройстве сейчас не смог ответить на этом устройстве.';

  @override
  String get consentReasonVoiceTooLong =>
      'Эти проверенные выводы превышают пределы краткого изложения на устройстве. Вы можете сейчас воспользоваться офлайн-сводкой или один раз отправить выводы со скрытыми данными в облачный ИИ.';

  @override
  String get consentReasonVoiceUnavailable =>
      'ИИ на устройстве сейчас недоступен на этом телефоне. Показываем простую офлайн-сводку Enprive.';

  @override
  String get consentReasonVoiceTimedOut =>
      'Время ожидания краткого изложения на устройстве истекло. Показываем простую офлайн-сводку Enprive.';

  @override
  String get unsavedExitTitle => 'Сохранить эту проверку конфиденциальности?';

  @override
  String get unsavedExitModifiedBody =>
      'Несохранённые проверки удаляются, когда вы закрываете этот экран, поэтому ничего не сохраняется на телефоне без вашего выбора. Ваш прежний сохранённый чек останется без изменений.';

  @override
  String get unsavedExitDraftBody =>
      'Несохранённые проверки удаляются, когда вы закрываете этот экран, поэтому ничего не сохраняется на телефоне без вашего выбора.';

  @override
  String get unsavedExitDiscardBtn => 'Удалить без сохранения';

  @override
  String get unsavedExitContinueBtn => 'Продолжить проверку';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return 'Обновить политику конфиденциальности для $title';
  }

  @override
  String get reviewSaveFailedError =>
      'Не удалось сохранить чек. Черновик проверки всё ещё открыт.';

  @override
  String get reviewRemovedFromReceiptsSnack => 'Удалено из сохранённых чеков.';

  @override
  String get reviewRemoveFailedSnack => 'Не удалось удалить сохранённый чек.';

  @override
  String get reviewModifiedDraftTitle => 'Новый черновик из сохранённого чека';

  @override
  String get reviewModifiedDraftBody =>
      'Сохраните в чеки, чтобы оставить эту обновлённую проверку: ваш прежний сохранённый чек останется без изменений.';

  @override
  String get btnRetrySave => 'Повторить сохранение';

  @override
  String samplePermissionsHeader(String badge) {
    return 'Примеры разрешений ($badge)';
  }

  @override
  String get sourceKindUrl => 'Публичная веб-ссылка';

  @override
  String get sourceKindPdf => 'Локальный PDF-файл';

  @override
  String get sourceKindDocx => 'Локальный файл Word (DOCX)';

  @override
  String get sourceKindTextFile => 'Локальный текстовый файл';

  @override
  String get sourceKindSharedText => 'Полученный текст';

  @override
  String get sourceKindSelectedText => 'Выделенный текст';

  @override
  String get sourceKindSampleApp => 'Пример приложения';

  @override
  String get sourceKindPhonePermissions => 'Разрешения телефона';

  @override
  String get sourceKindPastedText => 'Вставленный текст';

  @override
  String get extractionStatusExtracted => 'Прочитано на этом телефоне';

  @override
  String get extractionStatusNone => 'Передано на этом телефоне';

  @override
  String get extractionStatusUnsupported => 'Неподдерживаемый тип файла';

  @override
  String get extractionStatusTooLarge => 'Файл слишком большой';

  @override
  String get extractionStatusEmpty => 'Нет читаемого текста';

  @override
  String get extractionStatusReadError => 'Не удалось прочитать файл';

  @override
  String get extractionStatusPasswordProtected => 'Защищён паролем';

  @override
  String get extractionStatusPermissionDenied => 'В доступе отказано';

  @override
  String get extractionStatusCancelled => 'Отменено';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return 'Проверено: $timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return 'Канонический URL: $url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return 'Перенаправлено с: $url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return 'Файл: $filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return 'Статус: $status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return 'Хеш источника SHA-256: $hash';
  }

  @override
  String get semanticsPrimaryNavigation => 'Основная навигация';

  @override
  String semanticsProcessingLocation(String label) {
    return 'Где выполняется обработка: $label';
  }

  @override
  String get semanticsDeniMascot => 'Deni, ваш помощник по конфиденциальности';

  @override
  String get quoteCollapsibleDefaultHeader => 'Точный фрагмент политики';
}
