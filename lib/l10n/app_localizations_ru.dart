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
      'Один или несколько фрагментов либо расхождения разрешений требуют внимательного просмотра.';

  @override
  String get stateInsufficientEvidence => 'Недостаточно данных';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Доказательства отсутствуют, недоступны или не удалось проверить их на этом устройстве.';

  @override
  String get chipOnDevice => 'На этом устройстве';

  @override
  String get chipInCloud => 'В облаке';

  @override
  String get chipLocationUnavailable => 'Место обработки недоступно';

  @override
  String get statusSourceMatched => 'Цитата подтверждена';

  @override
  String get statusDeviceObserved => 'Обнаружено на устройстве';

  @override
  String get statusInterpretation => 'Пояснение';

  @override
  String get statusUnverified => 'Не подтверждено';

  @override
  String get statusStale => 'Устарело';

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
      'Для анализа текста в облаке Enprive отправит в Firebase AI Logic только текст, показанный ниже. Список установленных приложений и разрешения Android никогда не передаются.';

  @override
  String get permissionLimitationNotice =>
      'Android показывает состояние разрешений на этом телефоне. Это не доказывает, получало ли приложение доступ к данным или передавало ли их фактически.';

  @override
  String get navHome => 'Главная';

  @override
  String get navReceipts => 'Чеки';

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
      'Отмечает пункты о передаче данных, записи голоса и хранении с точными выдержками.';

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
      other: '$count проверенных пунктов',
      many: '$count проверенных пунктов',
      few: '$count проверенных пункта',
      one: '$count проверенный пункт',
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
      'Если локальный ИИ недоступен или текст длинный, имена, email и номера телефонов заменяются метками до проверки через App Check.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get privateAnalysisTitle => 'Приватный анализ на этом телефоне';

  @override
  String get onDeviceReadyMsg => 'ИИ на устройстве активен и готов.';

  @override
  String get localScannerProtectedMsg =>
      'Защищено встроенным локальным сканером условий.';

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
      'Gemini Nano готов на этом телефоне. Проверки полностью остаются на устройстве.';

  @override
  String get modelDownloadingMsg =>
      'Загрузка приватной модели в фоновом режиме.';

  @override
  String get modelDownloadableMsg =>
      'Модель на устройстве можно загрузить по Wi-Fi.';

  @override
  String get localScannerDefaultMsg =>
      'На этом телефоне по умолчанию используется встроенный локальный сканер Enprive.';

  @override
  String get preparingPrivateAnalysis => 'Подготовка приватного анализа…';

  @override
  String get onDeviceAiReadyTitle => 'ИИ на устройстве готов';

  @override
  String get localScannerActiveTitle => 'Локальный сканер активен';

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
      'Чтение условий политики на этом телефоне…';

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
  String get thoughtSignaturePrefix => 'Подпись рассуждения';

  @override
  String get viewStreamedThoughts => 'Показать ход рассуждений';

  @override
  String get hideStreamedThoughts => 'Скрыть рассуждения';

  @override
  String get analysisTraceDefaultTitle => 'Как выполнена эта проверка';

  @override
  String get savedToLocalReceiptsSnack => 'Сохранено в локальные чеки.';

  @override
  String get snapshotSheetTitle => 'Проверенная копия политики';

  @override
  String get snapshotSourcePrefix => 'Источник';

  @override
  String get snapshotReviewedPrefix => 'Проверено';

  @override
  String get snapshotDigestPrefix => 'Хеш';

  @override
  String get statFindings => 'Выводы';

  @override
  String get statVerified => 'Подтверждено';

  @override
  String get statOsGranted => 'Выдано ОС';

  @override
  String get statUnverified => 'Не проверено';

  @override
  String get keyFindingsTitle => 'Ключевые выводы';

  @override
  String get reviewedExcerptTitle => 'Проверенный фрагмент';

  @override
  String get permissionsOnPhoneTitle => 'Разрешения на этом телефоне';

  @override
  String get viewReviewedSnapshot => 'Посмотреть полный проверенный текст';

  @override
  String get btnSavedToReceipts => 'Сохранено в чеки';

  @override
  String get observedOnPhoneLabel => 'Обнаружено на этом телефоне';

  @override
  String get quoteVerifiedLabel => 'Цитата подтверждена в тексте';

  @override
  String get unverifiedClaimLabel => 'Неподтверждённое утверждение';

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
  String get labelWhatRemainsUnknown => 'Что остаётся неизвестным';

  @override
  String get presetQuestionMeaning => 'Что это значит для моего ребёнка?';

  @override
  String get presetQuestionOptOut => 'Можно ли это отключить или отказаться?';

  @override
  String get presetQuestionUnknown => 'Что здесь по-прежнему неясно?';

  @override
  String get readingCitedClause => 'Чтение приведённого пункта…';

  @override
  String get deniAnswerTitle => 'Ответ Дени';

  @override
  String get stepsAndReasoning => 'Шаги и логика модели';

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
}
