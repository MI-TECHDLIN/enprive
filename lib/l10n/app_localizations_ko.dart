// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => '근거 중심 앱 개인정보 검토';

  @override
  String get homePrivacySubtitle => '검토 내역은 이 휴대폰 안에만 안전하게 보관됩니다.';

  @override
  String get stateNoConcern => '우려 사항 없음';

  @override
  String get stateNoConcernSubtitle =>
      '검토한 근거에서 우려할 만한 내용을 찾지 못했습니다. 이는 안전 인증이 아닙니다.';

  @override
  String get stateReviewRecommended => '검토 권장';

  @override
  String get stateReviewRecommendedSubtitle =>
      '개인정보 처리방침의 일부 내용이나 휴대폰 권한을 더 자세히 살펴볼 필요가 있습니다.';

  @override
  String get stateInsufficientEvidence => '근거 부족';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      '이 앱의 동작을 확인하려면 개인정보 처리방침 본문이 더 필요합니다.';

  @override
  String get chipOnDevice => '이 기기에서 분석';

  @override
  String get chipInCloud => '클라우드 분석';

  @override
  String get chipLocationUnavailable => '출처를 알 수 없음';

  @override
  String get chipOfflineDeterministic => '이 휴대폰에서 오프라인 확인됨';

  @override
  String get chipUnknown => '출처 미상';

  @override
  String get statusSourceMatched => '방침에서 일치';

  @override
  String get statusDeviceObserved => '이 휴대폰에서 확인';

  @override
  String get statusInterpretation => 'Deni의 설명';

  @override
  String get statusUnverified => '방침에서 찾을 수 없음';

  @override
  String get statusStale => '이전 확인';

  @override
  String get btnCheckApp => '앱 확인하기';

  @override
  String get btnPasteTerms => '약관 또는 링크 붙여넣기';

  @override
  String get btnWhyThisFinding => '왜 이 항목인가요?';

  @override
  String get btnSaveToReceipts => '영수증에 저장';

  @override
  String get btnDiscard => '지우기';

  @override
  String get btnAskDeni => '데니에게 물어보기';

  @override
  String get btnUseCloud => '이번 검사만 클라우드 사용';

  @override
  String get btnReviewManually => '직접 검토하기';

  @override
  String get btnGetStarted => '시작하기';

  @override
  String get btnContinue => '계속하기';

  @override
  String get deniIntro =>
      '안녕하세요, 데니예요. 이 약관이 무엇을 뜻하는지 알기 쉽게 풀어드리고, 근거가 되는 원문과 확인되지 않은 점까지 함께 짚어드릴게요.';

  @override
  String get cloudConsentDisclosure =>
      '클라우드에서 확인하기 위해 Enprive는 이번 한 번의 요청에만 위에 표시된 텍스트(개인정보 가림 처리됨)를 전송합니다. 설치된 앱 목록과 휴대폰 권한은 절대 전송되지 않습니다.';

  @override
  String get permissionLimitationNotice =>
      '휴대폰은 이 권한이 허용되었는지만 보여줍니다. 앱이 실제로 데이터를 읽거나 전송했는지는 증명하지 못합니다.';

  @override
  String get navHome => '홈';

  @override
  String get navCheck => '확인';

  @override
  String get navReceipts => '영수증';

  @override
  String get navLearn => '배우기';

  @override
  String get navSettings => '설정';

  @override
  String get languageTitle => '언어';

  @override
  String get chooseLanguage => '언어 선택';

  @override
  String get languageSubtitle => '앱 화면, AI 설명, 음성 읽기 언어에 적용됩니다';

  @override
  String get homeHeroHeadline => '아이들이 쓰는 앱,\n약관과 권한을 한눈에';

  @override
  String get whatWeCheckTitle => '중점 확인 항목';

  @override
  String get checkQuoteTitle => '정확한 약관 원문';

  @override
  String get checkQuoteDesc => '정확한 원문 인용을 통해 데이터 공유, 음성 녹음, 보관 기간을 짚어줍니다.';

  @override
  String get checkPermissionTitle => '휴대폰 권한 불일치';

  @override
  String get checkPermissionDesc => '카메라·마이크·위치 권한을 약관 설명과 직접 대조합니다.';

  @override
  String get checkSelectTitle => '어디서나 텍스트 선택';

  @override
  String get checkSelectDesc =>
      '다른 앱에서 문장을 선택하고 Android 메뉴의 Enprive Check를 누르세요.';

  @override
  String get recentlyReviewed => '최근 검토한 영수증';

  @override
  String verifiedClausesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '일치한 인용 $count건',
    );
    return '$_temp0';
  }

  @override
  String get modePasteText => '문장 붙여넣기';

  @override
  String get modePolicyLink => '약관 링크';

  @override
  String get hintAppName => '앱 이름';

  @override
  String get defaultSubjectTitle => '개인정보 처리방침';

  @override
  String get selectedExcerptTitle => '선택한 약관 발췌';

  @override
  String get hintPastePolicy => '개인정보 처리방침이나 약관 문장을 붙여넣으세요…';

  @override
  String get btnReviewOnPhone => '이 휴대폰에서 검토하기';

  @override
  String get onboardingIntroHeadline => '안녕하세요, 데니예요. 👋';

  @override
  String get onboardingIntroLead => '앱 개인정보 보호, 이제 훨씬 쉽게 이해할 수 있어요.';

  @override
  String get onboardingIntroBody =>
      '앱의 개인정보 처리방침이 실제로 무엇을 말하는지 찾아내고, 중요한 조항 원문을 정확히 짚어드리며, 이 기기에서 확인된 권한 상태도 알기 쉽게 설명해 드립니다.\n\n추측이나 섣부른 안전 보장은 하지 않아요. 현명한 선택을 할 수 있도록 투명한 설명과 근거만 전해드릴게요.';

  @override
  String get onboardingIntroFooter => '무엇에 동의하는지 알고 선택하세요.';

  @override
  String get splashQuote => '무엇에 동의하는지 알고 선택하세요';

  @override
  String get onboardingStep1Question => '약관을 어떤 방식으로\n설명해 드릴까요?';

  @override
  String get depthQuickMultiline => '핵심만 간단히';

  @override
  String get depthBalancedMultiline => '요약 + 원문';

  @override
  String get depthFullMultiline => '조항별 자세히';

  @override
  String get onboardingReadinessTitle => '이 기기에서 안전하게\n보호되는 개인정보';

  @override
  String get onboardingReadinessSubtitle =>
      '부모님과 선생님이 안심하고 앱을 검토할 수 있도록 설계했어요.';

  @override
  String get readinessRow1Title => '이 기기에서 먼저 확인';

  @override
  String get readinessRow1Desc => '약관은 기기 내 모델과 로컬 스캐너로 먼저 대조합니다.';

  @override
  String get readinessRow2Title => '앱 목록·권한은 폰 안에만';

  @override
  String get readinessRow2Desc => '설치된 앱과 Android 권한 정보는 폰 밖으로 나가지 않습니다.';

  @override
  String get readinessRow3Title => '개인정보 자동 가림';

  @override
  String get readinessRow3Desc => '클라우드 도움을 선택하면 전송 전에 이름, 이메일, 전화번호를 먼저 가립니다.';

  @override
  String get settingsTitle => '설정';

  @override
  String get privateAnalysisTitle => '이 휴대폰에서 비공개 분석';

  @override
  String get onDeviceReadyMsg => '온디바이스 모델이 준비되었습니다.';

  @override
  String get localScannerProtectedMsg => '이 휴대폰에서 오프라인으로 방침을 확인할 준비가 되었습니다.';

  @override
  String get statusChecking => '확인 중…';

  @override
  String get btnCheckReadiness => '기기 상태 확인하기';

  @override
  String get howShouldDeniExplain => '어떻게 설명해 드릴까요?';

  @override
  String get depthQuick => '핵심만';

  @override
  String get depthBalanced => '요약+원문';

  @override
  String get depthFull => '자세히';

  @override
  String get preferencesSection => '환경 설정';

  @override
  String get meetDeniGuide => '데니 소개 및 시작 가이드';

  @override
  String clearSavedReceiptsCount(int count) {
    return '저장된 영수증 지우기 ($count)';
  }

  @override
  String get btnClear => '지우기';

  @override
  String get confirmClearReceiptsTitle => '저장된 영수증을 모두 지울까요?';

  @override
  String confirmClearReceiptsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이 기기에 저장된 $count개의 검토 기록이 삭제됩니다.',
    );
    return '$_temp0';
  }

  @override
  String get btnCancel => '취소';

  @override
  String get receiptsTitle => '영수증 보관함';

  @override
  String get tooltipSearch => '검색';

  @override
  String get hintSearchReceipts => '앱 이름 또는 내용 검색...';

  @override
  String get filterAll => '전체';

  @override
  String get filterReview => '검토 권장';

  @override
  String get filterNoConcern => '우려 없음';

  @override
  String get emptyFilteredTitle => '일치하는 영수증이 없어요';

  @override
  String get emptyReceiptsTitle => '아직 저장된 영수증이 없어요';

  @override
  String get emptyFilteredBody => '다른 필터를 선택해 보세요.';

  @override
  String get emptyReceiptsBody => '앱이나 약관을 검토한 뒤 북마크 아이콘을 누르면 이곳에 보관됩니다.';

  @override
  String get btnStartReview => '첫 검토 시작하기';

  @override
  String get btnOpenReceipt => '열기';

  @override
  String get btnDelete => '삭제';

  @override
  String get checkingPhoneReadiness => '이 휴대폰의 비공개 AI 상태를 확인하고 있어요…';

  @override
  String get geminiNanoReadyMsg =>
      '이 휴대폰에서 온디바이스 AI를 사용할 수 있습니다. 검토 내용은 기기 안에만 남습니다.';

  @override
  String get modelDownloadingMsg => '비공개 모델을 백그라운드에서 다운로드하고 있습니다.';

  @override
  String get modelDownloadableMsg => 'Wi-Fi 연결 시 온디바이스 모델을 다운로드할 수 있습니다.';

  @override
  String get localScannerDefaultMsg => '이 휴대폰은 기본적으로 기기 안에서 오프라인으로 방침을 확인합니다.';

  @override
  String get preparingPrivateAnalysis => '비공개 분석 준비 중…';

  @override
  String get onDeviceAiReadyTitle => '온디바이스 AI 준비 완료';

  @override
  String get localScannerActiveTitle => '오프라인 확인 준비 완료';

  @override
  String get privateAnalysisSheetSubtitle =>
      '설치된 앱 목록과 권한 상태는 절대 외부 서버로 전송되지 않습니다.';

  @override
  String get btnDone => '확인';

  @override
  String get btnCheckAgain => '다시 확인하기';

  @override
  String get reviewingOnPhone => '이 휴대폰에서 검토하는 중…';

  @override
  String get readingClausesInitial => '이 휴대폰에서 개인정보 처리방침을 읽는 중…';

  @override
  String progressStepCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String stepsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count단계',
    );
    return '$_temp0';
  }

  @override
  String get thoughtSignaturePrefix => '확인 ID';

  @override
  String get viewStreamedThoughts => 'Enprive의 확인 과정 보기';

  @override
  String get hideStreamedThoughts => 'Enprive의 확인 과정 숨기기';

  @override
  String get analysisTraceDefaultTitle => '이 검토가 확인된 방식';

  @override
  String get savedToLocalReceiptsSnack => '이 휴대폰의 영수증 보관함에 저장되었습니다.';

  @override
  String get snapshotSheetTitle => '검토한 방침 본문';

  @override
  String get snapshotSourcePrefix => '출처';

  @override
  String get snapshotReviewedPrefix => '검토 일시';

  @override
  String get snapshotDigestPrefix => '문서 지문 코드';

  @override
  String get statFindings => '발견 항목';

  @override
  String get statVerified => '검증됨';

  @override
  String get statOsGranted => '휴대폰에서 허용됨';

  @override
  String get statUnverified => '찾을 수 없음';

  @override
  String get keyFindingsTitle => '주요 발견 사항';

  @override
  String get reviewedExcerptTitle => '검토한 약관 전문';

  @override
  String get permissionsOnPhoneTitle => '이 휴대폰의 앱 권한';

  @override
  String get viewReviewedSnapshot => '검토한 방침 본문 보기';

  @override
  String get btnSavedToReceipts => '영수증에 저장됨';

  @override
  String get observedOnPhoneLabel => '이 휴대폰에서 확인';

  @override
  String get quoteVerifiedLabel => '방침의 정확한 원문 인용';

  @override
  String get unverifiedClaimLabel => '방침에서 찾을 수 없음';

  @override
  String get categoryDataCollection => '데이터 수집';

  @override
  String get categorySharing => '제3자 공유';

  @override
  String get categoryTracking => '위치 및 추적';

  @override
  String get categoryRetention => '보관 및 음성';

  @override
  String get categoryParentalControls => '보호자 관리';

  @override
  String get labelInPlainLanguage => '알기 쉬운 설명';

  @override
  String get labelOnThisPhone => '이 휴대폰에서의 상태';

  @override
  String get labelWhatRemainsUnknown => '아직 알 수 없는 점';

  @override
  String get presetQuestionMeaning => '아이에게 어떤 영향이 있나요?';

  @override
  String get presetQuestionOptOut => '이 기능을 끄거나 거부할 수 있나요?';

  @override
  String get presetQuestionUnknown => '여기서 아직 알 수 없는 점은 무엇인가요?';

  @override
  String get readingCitedClause => '방침 인용문을 읽는 중…';

  @override
  String get deniAnswerTitle => '데니의 답변';

  @override
  String get stepsAndReasoning => 'Deni의 확인 과정';

  @override
  String get chooseReviewModeTitle => '이 문장을 검토할 방법을 선택하세요';

  @override
  String get cloudNeverSendsAppsNote => '설치된 앱 목록과 휴대폰 권한은 절대 전송되지 않습니다.';

  @override
  String get tooltipClose => '닫기';

  @override
  String get checkAppSheetSubtitle => '이 휴대폰 안에서만 확인합니다. 앱 목록은 절대 업로드되지 않습니다.';

  @override
  String get appsOnThisPhone => '이 휴대폰에 설치된 앱';

  @override
  String get hintSearchApps => '앱 이름 검색…';

  @override
  String get noMatchingApps => '일치하는 앱을 찾지 못했습니다.';

  @override
  String get permissionInspectionTitle => '휴대폰 권한 확인됨';

  @override
  String get addAppPrivacyPolicyBtn => '이 앱의 개인정보 처리방침 추가';

  @override
  String get snapshotDigestLabel => '문서 지문 코드';

  @override
  String get snapshotDigestExplanation =>
      'Enprive가 검토한 정확한 원문인지 확인하는 고유 코드입니다. 글자 하나만 바뀌어도 이 코드가 달라집니다.';

  @override
  String get copyDigestBtn => '코드 복사';

  @override
  String get digestCopiedMsg => '문서 지문 코드가 복사되었습니다';

  @override
  String get permissionGrantedBadge => '이 휴대폰에서 허용됨';

  @override
  String get permissionNotGrantedBadge => '허용 안 됨';

  @override
  String get checkingPolicyWithCloudAi => '클라우드 AI로 정책을 확인하고 있습니다.';

  @override
  String get preparingCloudAiStream => '클라우드 확인 전 개인정보를 가리는 중…';

  @override
  String get cancellingAnalysis => '취소 중…';

  @override
  String get analysisCancelledNotice => '검토가 취소되었습니다.';

  @override
  String get cloudTimedOutNotice =>
      '클라우드 AI 응답 시간이 초과되었습니다. 자동 재시도는 전송되지 않았습니다.';

  @override
  String get cloudFallbackBannerTitle => '클라우드 확인을 끝내지 못했어요';

  @override
  String get cloudFallbackBannerBody =>
      '이 결과는 휴대폰에서 확인한 내용이며, 데이터를 다시 보내지 않았어요. 개인정보 처리방침 텍스트는 그대로 남아 있어요. 저장을 누르기 전에는 아무것도 저장되지 않아요.';

  @override
  String get cloudFallbackRetryAction => '클라우드 확인 다시 시도';

  @override
  String get appPickerFilterAll => '모든 앱';

  @override
  String get appPickerFilterDownloaded => '다운로드함';

  @override
  String get appPickerFilterSystem => '시스템';

  @override
  String get appPickerRecentlyChecked => '최근 확인한 앱';

  @override
  String get appPickerStatusPolicySaved => '방침 검토 저장됨';

  @override
  String get appPickerStatusPermissionsInspected => '권한 확인됨';

  @override
  String get appPickerStatusNotReviewed => '미검토';

  @override
  String get appPickerSearchHint => '앱 이름 또는 App ID 검색…';

  @override
  String get appPickerEmptyInstalledTitle => '사용 가능한 설치 앱 없음';

  @override
  String get appPickerEmptyInstalledBody => '이 휴대폰에서 확인할 수 있는 앱을 찾지 못했습니다.';

  @override
  String get intakeModeDocument => '문서';

  @override
  String get intakeActionInspectText => '방침 본문 확인';

  @override
  String get intakeActionFetchUrl => '열고 방침 확인';

  @override
  String get intakeActionChooseDocument => 'PDF, TXT 또는 DOCX 선택';

  @override
  String get intakeActionReplaceDocument => '대체 문서 선택';

  @override
  String get intakeWorkingLabel => '처리 중…';

  @override
  String get intakeCancelFetch => '불러오기 취소';

  @override
  String get intakeUrlHint => 'https://example.com/privacy-policy';

  @override
  String get intakeUrlDisclosure =>
      '이 공개 웹페이지를 직접 불러옵니다. 링크를 추가해도 앱 소유권을 증명하지는 않습니다.';

  @override
  String get intakePasteLocalNote =>
      '먼저 이 휴대폰에서 로컬로 확인합니다. 동의 없이 외부로 업로드되지 않습니다.';

  @override
  String get intakeDocumentCardTitle => 'PDF, TXT 또는 DOCX 방침 파일 가져오기';

  @override
  String get intakeDocumentCardBody =>
      '휴대폰에서 직접 텍스트를 읽습니다(최대 10 MB). 파일은 절대 업로드되지 않습니다.';

  @override
  String get intakeCompareWithAppPrompt => '설치된 앱과 비교하기(선택)';

  @override
  String get intakeCompareWithAppHint =>
      '이 휴대폰에서만 실행됩니다. 앱 목록은 기기 밖으로 나가지 않습니다.';

  @override
  String get intakeCompareWithAppChange => '변경';

  @override
  String get intakeCompareWithAppRemove => '제거';

  @override
  String get intakeLockedAppContextLabel => '선택된 앱';

  @override
  String get intakeFindPolicyOnPlayStore => 'Play Store에서 방침 링크 찾기';

  @override
  String get intakePlayStoreHelperNote =>
      '앱의 개인정보 처리방침 링크를 복사할 수 있도록 Play Store를 엽니다. Enprive가 자동으로 복사하거나 공식 링크로 단정하지 않습니다.';

  @override
  String get intakePlayStoreUnavailable =>
      '이 기기에서 Google Play Store를 열 수 없습니다. 방침 URL이나 본문을 직접 붙여넣으세요.';

  @override
  String get intakeRecoverySwitchPaste => '대신 텍스트 붙여넣기';

  @override
  String get intakeRecoverySwitchDocument => '문서 가져오기';

  @override
  String get intakeRecoveryRetryUrl => '다시 불러오기';

  @override
  String get intakeExpiredDocumentShareNotice =>
      '처음 공유된 파일 링크를 다시 열 수 없습니다. 다른 PDF, TXT 또는 DOCX 파일을 선택하거나 방침 본문을 직접 붙여넣으세요.';

  @override
  String get intakeAssociationWarningTitle => '앱과 방침 일치 확인';

  @override
  String get intakeAssociationContinueAnyway => '계속 진행';

  @override
  String get intakeAssociationChangeApp => '선택한 앱 변경';

  @override
  String get intakeAssociationInspectWithoutApp => '앱 없이 방침만 확인';

  @override
  String get intakeModeSelectorSemanticLabel => '방침 입력 방법';

  @override
  String get tooltipClearSearch => '검색어 지우기';

  @override
  String get intakeRecoveryEditUrl => 'URL 수정';

  @override
  String get voiceSummaryTitle => 'Deni의 알기 쉬운 요약';

  @override
  String get voiceSummaryPreparing => '알기 쉬운 요약을 준비하는 중…';

  @override
  String get voiceSynthesizingExpressive => 'Deni의 표현력 있는 음성을 준비하는 중…';

  @override
  String get voiceBtnListenOffline => '듣기';

  @override
  String get voiceBtnStop => '정지';

  @override
  String get voiceBtnExpressiveCloud => '표현력 있는 음성';

  @override
  String get voiceBtnSummarizeCloud => '클라우드 AI로 요약';

  @override
  String get voiceBadgeExpressive => '클라우드 표현 음성';

  @override
  String get voiceBadgeDeviceOffline => '휴대폰 음성 · 오프라인';

  @override
  String get voiceViewSourceQuote => '원문 인용';

  @override
  String get voiceHideSourceQuote => '인용 숨기기';

  @override
  String get voiceInspectFinding => '항목 살펴보기';

  @override
  String get voiceConsentTitle => 'Deni의 음성 선택';

  @override
  String get voiceConsentDisclosure =>
      'Deni의 표현력 있는 클라우드 음성으로 이 요약을 읽어드리기 위해 Enprive는 이번 한 번의 요청에만 위에 표시된 요약문(개인정보 가림 처리됨)을 전송합니다. 앱 목록과 휴대폰 권한은 절대 전송되지 않습니다.';

  @override
  String get voiceConsentPrimaryAction => '이번 한 번만 표현 음성 사용';

  @override
  String get voiceConsentSecondaryAction => '이 휴대폰에서 읽기';

  @override
  String get voiceConsentPayloadLabel => '읽어드릴 정확한 문구';

  @override
  String get voiceSummaryConsentTitle => '클라우드 AI로 발견 사항 요약';

  @override
  String get voiceSummaryConsentDisclosure =>
      '클라우드에서 이 방침 인용문을 알기 쉽게 요약하기 위해 Enprive는 이번 한 번의 요청에만 위에 표시된 텍스트(개인정보 가림 처리됨)를 전송합니다. 앱 목록과 휴대폰 권한은 절대 전송되지 않습니다.';

  @override
  String get voiceFallbackDeviceNotice =>
      '클라우드 표현 음성을 사용할 수 없어 이 휴대폰의 오프라인 음성으로 읽어드립니다.';

  @override
  String get voiceUnavailableNotice =>
      '이 휴대폰에서는 이 언어의 음성 재생을 사용할 수 없습니다. 위의 Deni 요약을 읽어보세요.';

  @override
  String get voiceTooltipReadSummary => 'Deni의 알기 쉬운 요약 듣기';

  @override
  String get voiceTooltipStopReading => '읽어주기 정지';

  @override
  String findingsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '건',
    );
    return '$_temp0';
  }

  @override
  String findingsCountPhrase(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '발견 항목 $count건',
      zero: '발견 항목 없음',
    );
    return '$_temp0';
  }

  @override
  String quotesVerifiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '방침에서 검증된 인용 $count건',
    );
    return '$_temp0';
  }

  @override
  String observedOnPhoneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이 휴대폰에서 확인됨 $count건',
    );
    return '$_temp0';
  }

  @override
  String get permissionAllowedOnPhone => '이 휴대폰에서 허용됨';

  @override
  String get permissionNotAllowedOnPhone => '허용 안 됨';

  @override
  String get permissionMismatchChip => '방침에 없음';

  @override
  String get howEnpriveCheckedThis => 'Enprive의 확인 과정';

  @override
  String get hideHowEnpriveChecked => 'Enprive의 확인 과정 숨기기';

  @override
  String get consentWhatWouldBeSent => '전송되는 내용';

  @override
  String get consentSentScope =>
      '이번 한 번의 요청에 한해 미리보기에 표시된 텍스트만 이 휴대폰 밖으로 전송됩니다.';

  @override
  String consentMaskedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '전송 전 개인정보 $count건이 먼저 가려집니다.',
      zero: '가릴 개인정보가 발견되지 않았습니다.',
    );
    return '$_temp0';
  }

  @override
  String get consentStaysOnPhone => '앱 목록과 휴대폰 권한은 이 휴대폰 안에 그대로 남습니다.';

  @override
  String receiptDeletedSnack(String title) {
    return '$title 삭제됨';
  }

  @override
  String get btnUndo => '실행 취소';

  @override
  String get readinessPromiseMaskedTitle => '개인정보 자동 가림';

  @override
  String get readinessPromiseMaskedLine => '클라우드를 선택하면 이름, 이메일, 번호를 먼저 가립니다.';

  @override
  String findingDetailTitle(int index, int total) {
    return '발견 항목 $index / $total';
  }

  @override
  String get findingReviewChip => '검토';

  @override
  String get askDeniAboutThis => '이 항목을 Deni에게 물어보기';

  @override
  String get labelWhatPolicySays => '방침에 적힌 내용';

  @override
  String get labelWhatAndroidReports => '휴대폰에 표시된 내용';

  @override
  String get sourceButtonTooltip => '검토한 원문';

  @override
  String get linkInstalledAppBtn => '설치된 앱 연결하기';

  @override
  String get linkInstalledAppCardTitle => '이 휴대폰의 앱과 비교하기';

  @override
  String get linkInstalledAppCardBody =>
      '설치된 앱을 선택하면 같은 검토 화면에서 휴대폰 권한과 이 방침을 비교할 수 있습니다. 앱 목록은 이 휴대폰 안에 남습니다.';

  @override
  String get linkAppPickerTitle => '설치된 앱 연결하기';

  @override
  String get changeLinkedAppPickerTitle => '연결된 앱 변경';

  @override
  String get linkAppPickerSubtitle =>
      '이 방침과 권한을 비교할 앱을 선택하세요. 앱 목록은 절대 휴대폰 밖으로 나가지 않습니다.';

  @override
  String get linkedAppCurrentlySelectedBadge => '연결됨';

  @override
  String get linkedAppSectionLabel => '이 휴대폰의 연결된 앱';

  @override
  String get btnChangeLinkedApp => '앱 변경';

  @override
  String get btnUnlinkApp => '연결 해제';

  @override
  String get btnUpdatePrivacyPolicy => '최신 개인정보 처리방침 첨부';

  @override
  String linkedAppSnack(String appName) {
    return '$appName 연결됨. 이 휴대폰에서 권한을 비교했습니다.';
  }

  @override
  String linkedAppCheckMatchSnack(String appName) {
    return '$appName 연결됨. 아래 앱-방침 일치 안내를 확인하세요.';
  }

  @override
  String linkedAppUnchangedSnack(String appName) {
    return '$appName 앱은 이미 동일한 권한으로 연결되어 있습니다.';
  }

  @override
  String unlinkedAppSnack(String appName) {
    return '$appName 연결이 해제되었습니다. 방침 검토만 표시합니다.';
  }

  @override
  String get associationStatusPackageTitle => '이 방침에서 App ID를 찾았습니다';

  @override
  String associationStatusPackageBody(String packageName, String appName) {
    return '이 방침에 $packageName 항목이 언급되어 있습니다. $appName 앱에 대한 내용일 수 있음을 뜻하지만, 텍스트만으로 방침 소유자를 증명할 수는 없습니다.';
  }

  @override
  String get associationStatusNameTitle => '이 방침에서 앱 이름을 찾았습니다';

  @override
  String associationStatusNameBody(String appName) {
    return '이 방침에 $appName 이름이 언급되어 있습니다. 이 앱에 대한 내용일 수 있지만, 이름 일치만으로 방침 소유자를 증명할 수는 없습니다.';
  }

  @override
  String get associationStatusUnverifiedTitle => '비교를 위해 직접 연결함';

  @override
  String associationStatusUnverifiedBody(String appName) {
    return '이 방침에는 $appName 이름이나 App ID가 나오지 않습니다. 올바른 방침인지 다시 확인하세요. 여기서 연결해도 소유권이 증명되지는 않습니다.';
  }

  @override
  String associationStatusUnverifiedUrlHostBody(String appName) {
    return '웹 주소에 $appName 관련 단어가 포함되어 있지만, 방침 본문에는 이 앱 이름이 없습니다. 올바른 방침인지 다시 확인하세요. 여기서 연결해도 소유권이 증명되지는 않습니다.';
  }

  @override
  String get associationStatusUnmatchedTitle => '다른 앱의 방침일 수 있습니다';

  @override
  String associationStatusUnmatchedBody(String appName, String otherApps) {
    return '이 방침에는 $appName 언급이 없고 대신 $otherApps 항목이 나옵니다. 올바른 앱을 연결했거나 맞는 방침을 열었는지 확인하세요.';
  }

  @override
  String get associationStatusAmbiguousConflictTitle => '이 방침에 여러 앱이 언급되어 있습니다';

  @override
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  ) {
    return '이 방침에는 $appName 외에도 $otherApps 항목이 함께 나옵니다. 여러 앱을 다루거나 회사 공통 방침일 수 있으니 이 앱에 해당하는지 확인하세요.';
  }

  @override
  String get associationStatusAmbiguousPeerTitle =>
      '이 휴대폰에 비슷한 이름의 앱이 여러 개 있습니다';

  @override
  String associationStatusAmbiguousPeerBody(String appName, String otherApps) {
    return '이 방침은 정확한 App ID 없이 $appName 이름만 언급하고 있으며, 휴대폰에 비슷한 이름의 앱($otherApps)이 더 있습니다. 올바른 앱을 연결했는지 확인하세요.';
  }

  @override
  String associationStatusAmbiguousGenericBody(String appName) {
    return '이 방침은 여러 앱을 가리킬 수 있습니다. $appName 앱에 해당하는지 다시 확인하세요.';
  }

  @override
  String get associationOwnershipLimitation =>
      '텍스트와 웹 링크만으로는 누가 방침을 게시하거나 소유했는지 절대 증명할 수 없습니다.';

  @override
  String permissionComparisonMismatchNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '이 휴대폰의 권한 $count개가 이 방침에 명확히 언급되지 않았습니다. 불일치는 자세히 살펴보라는 신호일 뿐, 위법 행위의 증거는 아닙니다.',
    );
    return '$_temp0';
  }

  @override
  String get permissionComparisonNoMismatchNote =>
      '이 휴대폰에서 확인한 권한 중 이 방침과 어긋나는 항목은 없습니다. 권한만으로 앱이 실제로 무엇을 전송하는지 알 수는 없습니다.';

  @override
  String get permissionComparisonLimitationNote =>
      '휴대폰은 이 기기의 권한 설정만 보여줍니다. 이 비교는 자세히 살펴보기 위한 참고 자료이며, 위법이나 데이터 전송의 증거가 아닙니다.';

  @override
  String get permissionNotRequestedOnPhone => '앱에서 요청 안 함';

  @override
  String get permissionsEmptyComparisonTitle => '이번 확인에 해당하는 민감 권한이 없습니다';

  @override
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  ) {
    return '휴대폰에는 $appName 앱의 권한 $requestedCount개(허용됨 $grantedCount개)가 표시되지만, 여기서 확인하는 민감 범주(위치, 카메라, 마이크, 연락처, 사진, 광고 ID)에는 해당하지 않습니다.';
  }

  @override
  String get sourceDeviceInspection => '이 휴대폰에서 확인됨';

  @override
  String get appIdPrefix => 'App ID';

  @override
  String get advancedDetailsTitle => '고급 세부정보';

  @override
  String get advancedDetailsSubtitle =>
      '이 방침 텍스트를 언제, 어디서 확인했는지 검증하는 기술 정보입니다.';

  @override
  String get sourceSectionTitle => '이 방침의 출처';

  @override
  String get cloudPayloadLabel => '전송될 정확한 텍스트';

  @override
  String get cloudPayloadNoPiiLabel => '개인정보가 발견되지 않음';

  @override
  String cloudPayloadHiddenCount(int count) {
    return '가려짐 ($count)';
  }

  @override
  String get summarySourceOnDevice => '이 휴대폰에서 요약됨';

  @override
  String get summarySourceInCloud => '클라우드에서 요약됨';

  @override
  String get summarySourceOffline => '이 휴대폰에서 오프라인 요약됨';

  @override
  String get summarySourceUnknown => '요약 출처 미상';

  @override
  String get notFromPolicySuffix => '방침이 아닌 휴대폰 설정에서 가져옴';

  @override
  String get learnHeaderSubtitle => '오프라인 개인정보 가이드 및 도표';

  @override
  String get learnFilterAll => '전체 주제';

  @override
  String get learnFilterPolicies => '방침';

  @override
  String get learnFilterPermissions => '권한';

  @override
  String get learnFilterSharing => '공유';

  @override
  String get learnFilterEvidence => '근거';

  @override
  String learnLessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count단계',
    );
    return '$_temp0';
  }

  @override
  String get learnDeckTitle => '기기 안에서 개인정보 습관 익히기';

  @override
  String get learnDeckBody =>
      '도표가 포함된 100% 오프라인 레슨입니다. 설치된 앱과 영수증은 배우기 탭에 절대 들어가지 않습니다.';

  @override
  String get learnDeckCheckBtn => '바로 해보기 · 앱 확인';

  @override
  String get learnCheckAppBridgeBtn => '이 휴대폰의 앱 확인하기';

  @override
  String get learnSectionDiagram => '작동 원리';

  @override
  String get learnSectionSteps => '핵심 단계';

  @override
  String get learnSectionQuickCheck => '퀵 체크';

  @override
  String get learnTooltipListenLesson => '이 레슨을 오프라인 음성으로 듣기';

  @override
  String get learnTooltipStopLesson => '레슨 읽기 정지';

  @override
  String get learnVoiceUnavailableNotice =>
      '이 휴대폰에서는 이 언어의 오프라인 음성 재생을 사용할 수 없습니다. 아래에서 레슨을 읽어보세요.';

  @override
  String get learnQuickCheckCorrectBadge => '정답';

  @override
  String get learnQuickCheckTryAgainBadge => '다른 보기 선택';

  @override
  String learnLessonProgress(int current, int total) {
    return '레슨 $current / $total';
  }

  @override
  String get learnBackTooltip => '배우기로 돌아가기';

  @override
  String get learnPreviousLesson => '이전';

  @override
  String get learnNextLesson => '다음';

  @override
  String learnLessonNavPreviousSemantic(String title) {
    return '이전 레슨: $title';
  }

  @override
  String learnLessonNavNextSemantic(String title) {
    return '다음 레슨: $title';
  }

  @override
  String get learnPolicyFolderTitle => '개인정보 처리방침';

  @override
  String get learnPolicyTitle => '개인정보 처리방침이란 (그리고 증명할 수 없는 것)';

  @override
  String get learnPolicySubtitle => '개발자의 약속과 여전히 알 수 없는 것';

  @override
  String get learnPolicyIntro =>
      '개인정보 처리방침은 앱이 어떤 데이터를 수집한다고 밝히는지, 왜 사용하는지, 누가 받을 수 있는지, 가족에게 어떤 선택권이 있는지 설명하는 개발자의 공개 문서입니다.';

  @override
  String get learnPolicyStep1 =>
      '네 가지 기본을 확인하세요. 어떤 데이터를 모으는지, 앱에 왜 필요한지, 또 누가 받는지, 삭제 요청은 어떻게 하는지입니다.';

  @override
  String get learnPolicyStep2 =>
      '이해하기 어려운 표현이 흔합니다. 2026년 어린이 학습 앱 연구에 따르면 읽기 쉬운 방침은 매우 적었고, 대부분의 앱은 방침에 적은 내용과 완전히 일치하지 않았습니다.';

  @override
  String get learnPolicyStep3 =>
      '개인정보 처리방침은 개발자가 문서에 적은 말만 보여줍니다. 방침을 읽는 것만으로 앱이 실제로 인터넷으로 무엇을 보내는지 증명할 수는 없습니다.';

  @override
  String get learnPolicyStep4 =>
      '방침을 휴대폰의 권한 설정과 비교하면 더 분명하게 볼 수 있지만, Enprive는 실시간 인터넷 통신을 볼 수 없다는 점을 기억하세요.';

  @override
  String get learnPolicyQuickQuestion => '앱의 개인정보 처리방침을 읽으면 무엇을 알 수 있나요?';

  @override
  String get learnPolicyQuickOption1 => '앱이 누구에게도 데이터를 보내지 않는다는 사실';

  @override
  String get learnPolicyQuickOption2 => '개발자가 말한 내용(앱이 실제로 보내는 내용이 아님)';

  @override
  String get learnPolicyQuickOption3 => '휴대폰의 카메라와 마이크가 꺼져 있다는 사실';

  @override
  String get learnPolicyQuickCorrectFeedback =>
      '맞아요. 방침은 개발자의 공개 설명일 뿐, 앱이 실제로 인터넷으로 무엇을 보내는지 증명하지 않습니다.';

  @override
  String get learnPolicyQuickTryAgainFeedback =>
      '아쉬워요. 방침을 읽으면 개발자가 밝힌 내용만 알 수 있으며, 인터넷 통신을 증명하거나 휴대폰 권한을 끄지는 못합니다.';

  @override
  String get learnDiagramPolicySaysTitle => '방침의 설명';

  @override
  String get learnDiagramPolicySaysBody => '개발자가 문서로 남긴 약속';

  @override
  String get learnDiagramPolicyQuoteSample => '\"파트너와 데이터를 공유할 수 있습니다…\"';

  @override
  String get learnDiagramPhoneShowsTitle => '휴대폰의 표시';

  @override
  String get learnDiagramPhoneShowsBody => '여기서 허용된 권한';

  @override
  String get learnDiagramUnknownTitle => '여전히 알 수 없음';

  @override
  String get learnDiagramUnknownBody => 'Enprive가 볼 수 없는 실시간 통신';

  @override
  String get learnDiagramPolicyCaption => '방침은 약속일 뿐, 실제 동작의 증거가 아닙니다';

  @override
  String get learnDiagramPolicySemantic =>
      '앱 개인정보의 세 부분을 비교하는 도표입니다. 첫째, 방침의 설명: 개발자가 문서로 남긴 약속. 둘째, 휴대폰의 표시: 이 휴대폰에서 허용된 권한. 셋째, 점선 테두리 안의 여전히 알 수 없음: Enprive가 볼 수 없는 실시간 인터넷 통신. 개인정보 처리방침은 약속일 뿐 실제 동작의 증거가 아닙니다.';

  @override
  String get learnPermissionsFolderTitle => '휴대폰 권한';

  @override
  String get learnPermissionsTitle => 'Android 권한 쉽게 이해하기';

  @override
  String get learnPermissionsSubtitle => 'Android의 4가지 선택과 확인 위치';

  @override
  String get learnPermissionsIntro =>
      '권한은 앱이 카메라, 마이크, 위치, 사진, 연락처, 알림 같은 휴대폰 센서와 데이터에 접근할 수 있는지 제어하는 문입니다.';

  @override
  String get learnPermissionsStep1 =>
      '기능에 꼭 필요한지 물어보세요. 수학 퀴즈나 독서 앱에 위치, 연락처, 카메라가 필요한 경우는 드뭅니다.';

  @override
  String get learnPermissionsStep2 =>
      'Android는 최대 4가지 선택지를 제공합니다. 허용 안 함, 매번 물어보기, 앱 사용 중에만 허용, 항상 허용(백그라운드 위치)입니다.';

  @override
  String get learnPermissionsStep3 =>
      '매번 물어보기나 앱 사용 중에만 허용처럼 기능이 작동하는 가장 좁은 범위로 시작하세요.';

  @override
  String get learnPermissionsStep4 =>
      'Android 설정에서 개인정보 보호 대시보드를 열면 최근 카메라, 마이크, 위치에 접근한 앱을 확인할 수 있습니다.';

  @override
  String get learnPermissionsStep5 =>
      '앱 설정에서 언제든 권한을 끌 수 있으며, 사용하지 않는 앱 일시 중지를 켜두면 Android가 오래된 권한을 자동으로 제거합니다. 허용된 권한은 가능성을 뜻할 뿐 데이터 전송 증거는 아닙니다.';

  @override
  String get learnPermissionsQuickQuestion =>
      '수학 연습 앱이 카메라 권한을 요청했는데 이유를 모르겠어요. 가장 좋은 첫 단계는?';

  @override
  String get learnPermissionsQuickOption1 =>
      '허용 안 함을 누르고 수학 문제가 그대로 작동하는지 확인한다';

  @override
  String get learnPermissionsQuickOption2 => '팝업이 다시 뜨지 않게 항상 허용을 고른다';

  @override
  String get learnPermissionsQuickOption3 => '앱이 이미 사진을 업로드했다고 단정한다';

  @override
  String get learnPermissionsQuickCorrectFeedback =>
      '정확해요. 허용 안 함을 누르면 카메라 없이도 앱이 작동하는지 확인할 수 있고, Android 설정에서 언제든 다시 바꿀 수 있습니다.';

  @override
  String get learnPermissionsQuickTryAgainFeedback =>
      '먼저 더 좁은 선택지를 써보세요. 허용 안 함으로 기능이 작동하는지 확인하고, 허용된 권한은 가능성일 뿐 업로드 증거가 아님을 기억하세요.';

  @override
  String get learnDiagramPermLadderTitle => '가장 좁은 접근부터 가장 넓은 접근까지';

  @override
  String get learnDiagramPermDenyTitle => '허용 안 함';

  @override
  String get learnDiagramPermDenyDetail => '차단됨: 앱이 이 센서를 쓸 수 없음';

  @override
  String get learnDiagramPermAskTitle => '매번 물어보기';

  @override
  String get learnDiagramPermAskDetail => '허용을 누를 때 한 번만 접근';

  @override
  String get learnDiagramPermWhileUsingTitle => '앱 사용 중에만';

  @override
  String get learnDiagramPermWhileUsingDetail => '앱이 화면에 열려 있는 동안만';

  @override
  String get learnDiagramPermAllTimeTitle => '항상 허용';

  @override
  String get learnDiagramPermAllTimeDetail => '닫혀 있어도 백그라운드에서 접근';

  @override
  String get learnDiagramPermFitNote => '기능에 맞나요? 수학 퀴즈 + 카메라 = 이유 묻기';

  @override
  String get learnDiagramPermSemantic =>
      '가장 좁은 접근에서 가장 넓은 접근까지 4단계 Android 권한 사다리입니다. 1단계 허용 안 함: 차단됨, 앱이 센서를 쓸 수 없음. 2단계 매번 물어보기: 허용을 누를 때 한 번만 접근. 3단계 앱 사용 중에만: 앱이 화면에 열려 있을 때만 접근. 4단계 항상 허용: 닫혀 있어도 백그라운드 접근, 주의 표시 점선 테두리. 하단 팁: 수학 퀴즈가 카메라를 요청하면 이유를 물어보세요.';

  @override
  String get learnSharingFolderTitle => '광고 및 제3자';

  @override
  String get learnSharingTitle => '데이터를 또 누가 받나요: 광고, 분석, 제3자';

  @override
  String get learnSharingSubtitle => '앱 제작사와 도우미 서비스, 분석, 광고 네트워크의 차이';

  @override
  String get learnSharingIntro =>
      '많은 무료 앱은 보이지 않는 곳에서 다른 회사와 연결됩니다. 누가 정보를 받는지 알면 앱 운영에 필요한 일과 앱 간 어린이 추적을 구분할 수 있습니다.';

  @override
  String get learnSharingStep1 =>
      '제1자(직접 제공자)는 앱 제작사 자신입니다. 예를 들어 앱이 작동하도록 숙제 진행률이나 퀴즈 점수를 저장하는 경우입니다.';

  @override
  String get learnSharingStep2 =>
      '도우미 회사는 오류를 고치기 위한 크래시 보고나 클라우드 저장처럼 뒤에서 기술 작업을 맡는 제3자입니다.';

  @override
  String get learnSharingStep3 =>
      '분석 도구는 화면 사용 방식을 측정하며, 광고 네트워크와 데이터 브로커는 광고 ID를 사용해 맞춤 광고를 보여주거나 앱 간 활동을 추적할 수 있습니다.';

  @override
  String get learnSharingStep4 =>
      '\'신뢰할 수 있는 파트너\'나 \'사업 목적\' 같은 넓은 표현에 주의하고, 맞춤 광고 거부 방법이 방침에 나와 있는지 확인하세요.';

  @override
  String get learnSharingQuickQuestion =>
      '방침에 \'제3자 파트너와 정보를 공유한다\'고 적혀 있습니다. 다음에 물을 가장 좋은 질문은?';

  @override
  String get learnSharingQuickOption1 => '앱에 광고가 없다는 뜻이라고 생각한다';

  @override
  String get learnSharingQuickOption2 => '모든 파트너가 똑같은 일을 한다고 생각한다';

  @override
  String get learnSharingQuickOption3 =>
      '호스팅 같은 도우미 서비스인지, 앱 간 추적하는 광고 네트워크인지 확인한다';

  @override
  String get learnSharingQuickCorrectFeedback =>
      '정확해요. 도우미 서비스는 앱 작동을 돕지만, 광고 네트워크와 데이터 브로커는 앱 간 활동을 추적할 수 있습니다.';

  @override
  String get learnSharingQuickTryAgainFeedback =>
      '각 파트너의 역할을 살펴보세요. 제3자라고 다 같은 것은 아닙니다. 데이터를 보관하거나 오류를 고치는 곳도 있고, 광고나 추적을 하는 곳도 있습니다.';

  @override
  String get learnDiagramThirdPartyYou => '나';

  @override
  String get learnDiagramThirdPartyApp => '학습 앱';

  @override
  String get learnDiagramThirdPartyHosting => '도우미 및 오류';

  @override
  String get learnDiagramThirdPartyAnalytics => '분석';

  @override
  String get learnDiagramThirdPartyAds => '광고 네트워크';

  @override
  String get learnDiagramThirdPartyFirstParty => '제1자';

  @override
  String get learnDiagramThirdPartyThirdParty => '제3자';

  @override
  String get learnDiagramThirdPartySemantic =>
      '어린이 학습 앱의 데이터가 어디로 갈 수 있는지 보여주는 흐름도입니다. 사용자가 학습 앱에 연결되고, 앱은 실선으로 앱 제작사(제1자)에, 점선으로 제3자인 도우미 및 오류 도구, 분석 도구, 주의 표시된 광고 네트워크에 연결됩니다.';

  @override
  String get learnEvidenceFolderTitle => 'Enprive 읽기';

  @override
  String get learnEvidenceTitle => 'Enprive의 근거 읽는 법';

  @override
  String get learnEvidenceSubtitle => '근거 계층, 범주, 그리고 솔직한 한계';

  @override
  String get learnEvidenceIntro =>
      'Enprive는 개인정보 처리방침의 내용, 휴대폰의 표시, 여전히 알 수 없는 부분을 구분하고, 안전 점수가 아니라 주제별로 정리해 보여줍니다.';

  @override
  String get learnEvidenceStep1 =>
      '5가지 주제 범주가 검토 화면과 동일한 아이콘과 색상으로 항목을 묶습니다. 색상은 주제를 구분할 뿐 안전 점수가 아닙니다.';

  @override
  String learnEvidenceStep2(String sourceMatched) {
    return '$sourceMatched 표시는 Enprive가 검토한 방침 본문에서 글자 그대로 일치하는 원문 인용을 찾았다는 뜻입니다.';
  }

  @override
  String learnEvidenceStep3(String deviceObserved) {
    return '$deviceObserved 표시는 휴대폰이 이 기기의 권한 설정을 알려주었다는 뜻이며, 데이터 전송 증거는 아닙니다.';
  }

  @override
  String learnEvidenceStep4(String interpretation, String unverified) {
    return '$interpretation 항목은 Deni의 알기 쉬운 설명이고, $unverified 항목은 Enprive가 찾지 못한 내용입니다. 방침에 언급이 없는 것은 약속이 아닙니다.';
  }

  @override
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  ) {
    return '검토는 세 가지 차분한 결과 중 하나로 끝납니다: $reviewRecommended, $noConcern(안전 인증이 아님), 또는 $insufficientEvidence.';
  }

  @override
  String learnEvidenceQuickQuestion(String deviceObserved) {
    return '검토 화면에서 \'$deviceObserved\' 표시는 무엇을 뜻하나요?';
  }

  @override
  String get learnEvidenceQuickOption1 => '어린이에게 안전한 앱으로 인증되었다';

  @override
  String get learnEvidenceQuickOption2 =>
      '휴대폰이 이 기기의 권한 설정을 보여준다(데이터 업로드 증거는 아님)';

  @override
  String get learnEvidenceQuickOption3 => '앱이 아이의 데이터를 확실히 업로드했다';

  @override
  String get learnEvidenceQuickCorrectFeedback =>
      '맞아요. 이 표시는 이 기기의 Android 권한 상태만 반영하며, 업로드를 증명하거나 안전을 인증하지 않습니다.';

  @override
  String get learnEvidenceQuickTryAgainFeedback =>
      '아쉬워요. 이 표시는 휴대폰이 보고한 권한 설정만 보여주며, 업로드 증거도 안전 인증도 아닙니다.';

  @override
  String get learnDiagramEvidencePolicyDetail => '방침 본문에서 일치한 정확한 인용';

  @override
  String get learnDiagramEvidencePhoneDetail => '이 기기의 휴대폰 권한';

  @override
  String get learnDiagramEvidenceDeniDetail => 'Deni의 알기 쉬운 설명';

  @override
  String get learnDiagramEvidenceUnknownDetail => '방침의 침묵은 약속이 아닙니다';

  @override
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  ) {
    return 'Enprive 검토 화면의 4가지 근거 계층입니다. 1, $sourceMatched: 방침에서 일치한 정확한 인용. 2, $deviceObserved: 이 기기의 휴대폰 권한. 3, $interpretation: Deni의 알기 쉬운 설명. 4, 점선으로 구분된 $unverified: 방침에 언급이 없는 것은 약속이 아니기 때문입니다.';
  }

  @override
  String get learnDiagramCategoriesTitle => '검토 화면의 5가지 주제 범주';

  @override
  String get learnDiagramCategoriesNote => '색상과 아이콘은 주제를 표시할 뿐 안전 점수가 아닙니다.';

  @override
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  ) {
    return 'Enprive 검토 화면에 각기 다른 아이콘과 색상으로 표시되는 5가지 근거 범주: $dataCollection, $sharing, $tracking, $retention, $parentalControls. 색상과 아이콘은 주제를 표시할 뿐 안전 점수가 아닙니다.';
  }

  @override
  String get learnDataCollectionFolderTitle => '앱이 모으는 데이터';

  @override
  String get learnDataCollectionTitle => '앱이 수집하는 데이터';

  @override
  String get learnDataCollectionSubtitle => '직접 입력하는 정보와 조용히 수집되는 정보의 차이';

  @override
  String get learnDataCollectionIntro1 =>
      '앱은 두 가지 방식으로 정보를 모읍니다. 이름, 이메일, 사진, 음성 녹음, 숙제 답안처럼 직접 입력하는 정보가 있고, IP 주소(인터넷에서 휴대폰이 쓰는 주소), 기기 식별자, 광고 ID(광고가 휴대폰을 알아보는 코드), 오류 기록, 앱 실행 시각처럼 백그라운드에서 자동으로 수집되는 정보도 있습니다.';

  @override
  String get learnDataCollectionStep1 =>
      '직접 입력하는 정보: 이름, 학교, 이메일, 사진, 음성 클립, 숙제 답안은 내가 선택해서 입력하는 데이터입니다.';

  @override
  String get learnDataCollectionStep2 =>
      '조용히 수집되는 정보: 버튼을 누르지 않아도 앱은 광고 ID, 기기 식별자, IP 주소, 오류 보고서, 사용 시간을 모을 수 있습니다. 조용한 수집이 무조건 나쁜 것은 아니며, 앱이 원활히 작동하도록 돕는 신호이기도 합니다.';

  @override
  String get learnDataCollectionStep3 =>
      '민감한 어린이 데이터: 위치, 마이크 녹음, 카메라 사진, 성문 같은 생체 데이터(신체나 목소리에 관한 데이터)는 어린이에게 더 높은 개인정보 위험이 있습니다.';

  @override
  String get learnDataCollectionStep4 =>
      'Play Store 참고: Google Play의 데이터 보안 섹션은 개발자가 직접 작성한 설명입니다. 힌트는 되지만 증거는 아니며, 기기 안에서만 처리되거나 메모리에 잠시 머무는 데이터는 포함되지 않습니다.';

  @override
  String get learnDataCollectionQuizQuestion =>
      '백그라운드에서 조용히 수집되는 데이터의 예시는 무엇인가요?';

  @override
  String get learnDataCollectionQuizChoiceA => '프로필용으로 직접 올린 사진';

  @override
  String get learnDataCollectionQuizChoiceB => '광고 ID와 기기 식별자';

  @override
  String get learnDataCollectionQuizChoiceC => '앱에 직접 입력한 숙제 답안';

  @override
  String get learnDataCollectionQuizFeedbackRight =>
      '정답이에요. 광고 ID와 기기 식별자는 직접 입력하지 않아도 자동으로 수집됩니다.';

  @override
  String get learnDataCollectionQuizFeedbackWrong =>
      '아쉬워요. 그건 직접 입력하는 정보입니다. 조용히 수집되는 데이터에는 광고 ID, 기기 식별자, IP 주소, 사용 시간이 포함됩니다.';

  @override
  String get learnDataCollectionDiagramYouTypeTitle => '직접 입력하거나 주는 정보';

  @override
  String get learnDataCollectionDiagramYouTypeItem1 => '이름, 이메일, 학교';

  @override
  String get learnDataCollectionDiagramYouTypeItem2 => '사진 및 동영상';

  @override
  String get learnDataCollectionDiagramYouTypeItem3 => '음성 녹음';

  @override
  String get learnDataCollectionDiagramYouTypeItem4 => '숙제 답안';

  @override
  String get learnDataCollectionDiagramRunsQuietlyTitle => '조용히 수집되는 정보';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem1 => '광고 ID';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem2 => '기기 식별자';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem3 => 'IP 주소';

  @override
  String get learnDataCollectionDiagramRunsQuietlyItem4 => '오류 기록 및 사용 시간';

  @override
  String get learnDataCollectionDiagramQuietNote =>
      '조용하다고 나쁜 뜻은 아닙니다. 이런 신호는 앱이 잘 돌아가도록 돕습니다.';

  @override
  String get learnDataCollectionDiagramSemanticDescription =>
      '두 가지 데이터 수집 범주를 보여주는 분할 도표입니다. 위 카드 \"직접 입력하거나 주는 정보\"에는 이름·이메일·학교, 사진 및 동영상, 음성 녹음, 숙제 답안이 있고, 아래 카드 \"조용히 수집되는 정보\"에는 광고 ID, 기기 식별자, IP 주소, 오류 기록 및 사용 시간이 있습니다. 작은 안내문에는 \"조용하다고 나쁜 뜻은 아닙니다. 이런 신호는 앱이 잘 돌아가도록 돕습니다.\"라고 적혀 있고 아래에 Deni가 생각하는 모습으로 앉아 있습니다.';

  @override
  String get learnDataCollectionCheckBridge =>
      '이 휴대폰의 앱을 확인해 어떤 데이터를 수집하는지 살펴보세요.';

  @override
  String get learnDataCollectionHonestyNote =>
      '이 레슨은 일반적인 데이터 유형을 설명합니다. 특정 앱이 무엇을 수집하거나 전송하는지 증명하지는 않습니다. 정확한 방침 본문과 휴대폰 권한 설정으로 확인하세요.';

  @override
  String get learnRetentionFolderTitle => '보관 및 삭제';

  @override
  String get learnRetentionTitle => '데이터 보관과 삭제';

  @override
  String get learnRetentionSubtitle => '앱을 삭제해도 회사 서버에 이미 올라간 데이터는 지워지지 않습니다';

  @override
  String get learnRetentionIntro1 =>
      '휴대폰에서 앱을 지우면 기기 안의 파일은 사라지지만, 회사 서버에 이미 업로드된 데이터는 그대로 남습니다. 개인정보 처리방침에는 데이터를 얼마나 보관하는지, 삭제 요청 방법과 백업 처리 방식이 나와야 하지만, 많은 방침이 \"합리적으로 필요한 기간 동안\"처럼 모호한 표현을 씁니다.';

  @override
  String get learnRetentionStep1 =>
      '데이터 수집: 앱을 사용하는 동안 내 정보가 회사 서버로 전송되어 저장됩니다.';

  @override
  String get learnRetentionStep2 =>
      '서버에 보관됨: 앱 사용을 멈춘 뒤에도 데이터가 회사 시스템에 남아 있을 수 있습니다.';

  @override
  String get learnRetentionStep3 =>
      '앱 삭제가 서버 데이터를 지우지 않음: 휴대폰에서 앱을 지우면 기기 파일만 삭제되며 회사 서버의 사본은 남습니다.';

  @override
  String get learnRetentionStep4 =>
      '삭제 요청: 회사에 계정과 데이터 삭제를 요청할 수 있으며, 방침에는 처리 기간이 나와 있어야 합니다.';

  @override
  String get learnRetentionStep5 =>
      '알 수 없는 보관 기간: \"필요한 기간 동안\" 또는 \"사업 목적을 위해\"라고만 적힌 방침은 실제 삭제 시점이 불분명합니다.';

  @override
  String get learnRetentionQuizQuestion =>
      '휴대폰에서 앱을 삭제하면 회사 서버에 있는 내 데이터는 어떻게 되나요?';

  @override
  String get learnRetentionQuizChoiceA => '자동으로 삭제된다';

  @override
  String get learnRetentionQuizChoiceB => '서버에 남아 있을 수 있다(앱 삭제만으로 지워지지 않음)';

  @override
  String get learnRetentionQuizChoiceC => '즉시 익명 처리된다';

  @override
  String get learnRetentionQuizFeedbackRight =>
      '정답이에요. 앱 삭제는 휴대폰에서만 앱을 지웁니다. 삭제를 요청하기 전까지 회사 서버에 데이터가 남을 수 있습니다.';

  @override
  String get learnRetentionQuizFeedbackWrong =>
      '아쉬워요. 앱을 지워도 회사 서버에 이미 업로드된 데이터는 삭제되지 않습니다. 계정 삭제를 직접 요청해야 합니다.';

  @override
  String get learnRetentionDiagramCollected => '사용 중 데이터 수집';

  @override
  String get learnRetentionDiagramStored => '회사 서버에 보관';

  @override
  String get learnRetentionDiagramUninstall => '앱 삭제: 기기 파일은 사라지고 서버 데이터는 남음';

  @override
  String get learnRetentionDiagramDeleteRequest => '계정 삭제 요청';

  @override
  String get learnRetentionDiagramUnknownTail =>
      '보관 기간 미상: 방침에 \"필요한 기간 동안\" 기재';

  @override
  String get learnRetentionDiagramSemanticDescription =>
      '데이터 수명 주기를 보여주는 5단계 타임라인입니다. 1단계: 사용 중 데이터 수집(데이터베이스 아이콘). 2단계: 회사 서버에 보관(서버 아이콘). 3단계: 앱 삭제 시 기기 파일은 사라지고 서버 데이터는 남음(스마트폰 아이콘). 4단계: 계정 삭제 요청(휴지통 아이콘). 5단계: 보관 기간 미상, 방침에 \"필요한 기간 동안\" 기재(점선 화살표와 물음표 아이콘). 아래에 영수증을 든 Deni가 서 있습니다.';

  @override
  String get learnRetentionCheckBridge =>
      '이 휴대폰의 앱을 확인해 보관 기간에 대한 방침 내용을 살펴보세요.';

  @override
  String get learnRetentionHonestyNote =>
      '이 레슨은 일반적인 보관 방식을 설명합니다. 특정 회사가 데이터를 어떻게 처리하는지 증명하지는 않습니다. 정확한 방침 본문과 삭제 요청으로 확인하세요.';

  @override
  String get learnUnclearPoliciesFolderTitle => '모호한 방침';

  @override
  String get learnUnclearPoliciesTitle => '모호한 방침과 유도 버튼 알아보기';

  @override
  String get learnUnclearPoliciesSubtitle => '애매한 표현과 동의를 재촉하는 화면 구별하기';

  @override
  String get learnUnclearPoliciesIntro1 =>
      '일부 개인정보 처리방침은 모호한 말을 써서 내 데이터가 실제로 어떻게 쓰이는지 알기 어렵게 만듭니다. 동의 화면에서도 작은 \"설정 관리\" 링크 옆에 크고 밝은 \"모두 동의\" 버튼을 두는 등 읽지 않고 동의하게 유도하는 디자인이 쓰일 수 있습니다.';

  @override
  String get learnUnclearPoliciesStep1 =>
      '흐릿한 방침의 신호: \"신뢰할 수 있는 파트너와 공유할 수 있음\", \"사업 목적\", \"필요에 따라 보관\" 같은 열린 표현은 구체적인 내용을 숨깁니다.';

  @override
  String get learnUnclearPoliciesStep2 =>
      '침묵은 약속이 아님: 방침에 마이크, 광고, 위치가 전혀 언급되지 않았더라도 앱이 이를 쓰지 않는다는 보장은 아닙니다.';

  @override
  String get learnUnclearPoliciesStep3 =>
      '빠진 기본 요소: 신뢰할 수 있는 방침에는 명확한 시행일, 연락처 이메일, 그리고 숨겨진 어린이 별지가 아닌 하나의 통합 문서가 있습니다.';

  @override
  String get learnUnclearPoliciesStep4 =>
      '압박형 동의(다크 패턴): 거대한 \"모두 동의\" 버튼, 미리 체크된 마케팅 항목, 반복되는 알림, 찾기 어려운 해지 경로는 선택을 유도하도록 설계됩니다.';

  @override
  String get learnUnclearPoliciesStep5 =>
      '균형 잡힌 선택: 공정한 화면은 \"허용\"과 \"허용 안 함\" 버튼을 같은 크기로 보여주고, 선택 항목은 기본으로 꺼져 있습니다.';

  @override
  String get learnUnclearPoliciesQuizQuestion =>
      '개인정보 처리방침에서 세부 정보가 빠져 있음을 보여주는 \"모호한\" 문구는?';

  @override
  String get learnUnclearPoliciesQuizChoiceA => '개인정보를 제3자에게 판매하지 않습니다';

  @override
  String get learnUnclearPoliciesQuizChoiceB =>
      '사업 목적을 위해 신뢰할 수 있는 파트너와 데이터를 공유할 수 있습니다';

  @override
  String get learnUnclearPoliciesQuizChoiceC =>
      'privacy@example.com으로 이메일을 보내 삭제를 요청할 수 있습니다';

  @override
  String get learnUnclearPoliciesQuizFeedbackRight =>
      '정답이에요. \"사업 목적을 위해 신뢰할 수 있는 파트너와 공유할 수 있습니다\"는 모호하며 파트너가 누구인지, 어떤 데이터를 공유하는지 밝히지 않습니다.';

  @override
  String get learnUnclearPoliciesQuizFeedbackWrong =>
      '아쉬워요. 그 문구는 구체적이고 실행 가능합니다. 모호한 문구는 세부 내용 없이 \"공유할 수 있음\", \"필요에 따라\" 같은 열린 표현을 씁니다.';

  @override
  String get learnUnclearPoliciesDiagramClearTitle => '명확한 방침 문장';

  @override
  String get learnUnclearPoliciesDiagramClearExample =>
      '계정 생성을 위해 이름과 이메일을 수집합니다. 광고주와는 공유하지 않습니다.';

  @override
  String get learnUnclearPoliciesDiagramFoggyTitle => '모호한 방침 문장';

  @override
  String get learnUnclearPoliciesDiagramFoggyExample =>
      '필요에 따라 사업 목적을 위해 신뢰할 수 있는 파트너와 정보를 공유할 수 있습니다.';

  @override
  String get learnUnclearPoliciesDiagramTipsTitle => '모호함을 찾는 법';

  @override
  String get learnUnclearPoliciesDiagramTip1 =>
      '\"~할 수 있음\", \"필요에 따라\" 같은 표현은 여지를 남깁니다.';

  @override
  String get learnUnclearPoliciesDiagramTip2 =>
      '데이터를 받는 구체적인 회사 이름이 적혀 있는지 확인하세요.';

  @override
  String get learnUnclearPoliciesDiagramTip3 =>
      '광고나 마이크 언급이 없다고 해서 쓰지 않는다는 약속은 아닙니다.';

  @override
  String get learnUnclearPoliciesDiagramSilenceNote => '방침의 침묵은 약속이 아닙니다.';

  @override
  String get learnUnclearPoliciesDiagramSemanticDescription =>
      '명확한 방침 문장과 모호한 문장을 나란히 비교한 도표입니다. 왼쪽 \"명확\" 카드에는 \"계정 생성을 위해 이름과 이메일을 수집합니다. 광고주와는 공유하지 않습니다.\"가, 오른쪽 \"모호\" 카드에는 \"필요에 따라 사업 목적을 위해 신뢰할 수 있는 파트너와 정보를 공유할 수 있습니다.\"가 표시됩니다. 아래 팁 카드 \"모호함을 찾는 법\"에는 세 가지 팁이 있고, 모호 카드에 \"방침의 침묵은 약속이 아닙니다.\"라는 안내가 있습니다. 카드 위로 Deni가 고개를 내밀고 있습니다.';

  @override
  String get learnUnclearPoliciesCheckBridge =>
      '이 휴대폰의 앱을 확인해 동의 화면과 방침의 명확성을 살펴보세요.';

  @override
  String get learnUnclearPoliciesHonestyNote =>
      '이 레슨은 흔한 모호한 패턴을 설명합니다. 특정 앱이 다크 패턴을 쓰거나 데이터 관행을 숨긴다고 증명하지는 않습니다. 실제 방침 본문과 동의 화면을 직접 확인하세요.';

  @override
  String get learnSafeSharingFolderTitle => '안전한 공유 습관';

  @override
  String get learnSafeSharingTitle => '어린이를 위한 안전한 공유 습관';

  @override
  String get learnSafeSharingSubtitle => '멈추고, 생각하고, 연결하기: 연령별 온라인 공유 단계';

  @override
  String get learnSafeSharingIntro1 =>
      '사진, 동영상, 이름, 위치를 올리기 전에 잠시 멈추고 세 단계(멈추고, 생각하고, 연결하기)를 떠올려 보세요. 이 레슨은 믿을 수 있는 어른과 함께 읽도록 만들었습니다. 어린아이(5-7세)는 누르기 전에 물어봅니다. 8-11세는 별명과 강한 비밀번호를 사용합니다. 청소년(12-17세)은 디지털 발자국(올린 게시물의 흔적)과 2단계 인증(로그인 시 코드 확인 같은 추가 확인)을 관리합니다.';

  @override
  String get learnSafeSharingStep1 =>
      '멈추기: 사진, 동영상, 이름, 학교, 위치를 올리기 전에 잠시 멈추세요. 확신이 없다면 믿을 수 있는 어른에게 물어보세요.';

  @override
  String get learnSafeSharingStep2 =>
      '생각하기: 내 학교, 집, 지금 있는 곳이 드러나지 않을까요? 친구 사진을 올리거나 태그하기 전에 허락을 받았나요?';

  @override
  String get learnSafeSharingStep3 =>
      '연결하기: 믿을 수 있는 사람에게만 공유하세요. 본명, 생일, 주소, 전화번호 같은 개인정보는 비공개로 지키세요.';

  @override
  String get learnSafeSharingStep4 =>
      '급식실 테스트: 학교 사람 모두(또는 우리 반 전체)가 이 사진이나 메시지를 봐도 괜찮을까요? 사라지는 게시물도 스크린샷으로 찍혀 온라인에 영원히 남을 수 있습니다.';

  @override
  String get learnSafeSharingStep5 =>
      '5-7세: 이름을 입력하거나 팝업을 누르기 전에 믿을 수 있는 어른에게 물어보세요. 8-11세: 본명·생일·학교 대신 별명과 강한 비밀번호를 쓰고, SMS나 OTP 코드(문자로 오는 일회용 인증번호)는 절대 공유하지 마세요. 12-17세: 개인정보 설정을 점검하고 2단계 인증을 켜며 문제 신고 방법을 익히세요.';

  @override
  String get learnSafeSharingQuizQuestion => '온라인 공유에서의 \"급식실 테스트\"란 무엇인가요?';

  @override
  String get learnSafeSharingQuizChoiceA => '급식실에서 먹을 것만 공유하는 것';

  @override
  String get learnSafeSharingQuizChoiceB =>
      '학교 사람 모두가 이 사진이나 메시지를 봐도 괜찮을지 스스로 물어보는 것';

  @override
  String get learnSafeSharingQuizChoiceC => '점심시간에만 공유하는 것';

  @override
  String get learnSafeSharingQuizFeedbackRight =>
      '정답이에요. 급식실 테스트는 내가 올린 내용을 모두가 봐도 괜찮을지 스스로 확인하는 방법입니다.';

  @override
  String get learnSafeSharingQuizFeedbackWrong =>
      '아쉬워요. 급식실 테스트는 누군가 내 게시물을 급식실 전체에 보여줘도 괜찮을지 생각해 보는 마음속 점검입니다.';

  @override
  String get learnSafeSharingDiagramStop => '멈추기: 올리기 전에 잠시 멈춤';

  @override
  String get learnSafeSharingDiagramThink => '생각하기: 내 위치나 함께 있는 사람이 드러나지 않나?';

  @override
  String get learnSafeSharingDiagramConnect => '연결하기: 믿는 사람에게만, 헷갈리면 어른께 질문';

  @override
  String get learnSafeSharingDiagramCafeteriaTest =>
      '급식실 테스트: 학교 사람 모두가 봐도 괜찮을까요? 사라지는 게시물도 스크린샷으로 영원히 남을 수 있어요.';

  @override
  String get learnSafeSharingDiagramSemanticDescription =>
      '안전한 공유 습관을 알려주는 4부분 도표입니다. 1단계: 멈추기: 올리기 전에 잠시 멈춤(손 아이콘). 2단계: 생각하기: 내 위치나 함께 있는 사람이 드러나지 않나?(뇌 아이콘). 3단계: 연결하기: 믿는 사람에게만, 헷갈리면 어른께 질문(사람들 아이콘). 4단계: 급식실 테스트 안내에 \"학교 사람 모두가 봐도 괜찮을까요? 사라지는 게시물도 스크린샷으로 영원히 남을 수 있어요.\"라고 적혀 있고 옆에 손을 든 Deni가 서 있습니다.';

  @override
  String get learnSafeSharingCheckBridge => '보호자와 함께 앱을 확인해 공유 방식을 살펴보세요.';

  @override
  String get learnSafeSharingHonestyNote =>
      '이 레슨은 일반적인 안전 공유 습관을 나눕니다. 특정 앱이 공유한 내용을 보호한다고 보장하지는 않습니다. 항상 앱 방침을 읽고 휴대폰 개인정보 설정을 사용하세요.';

  @override
  String get translationDraftNotice =>
      '일부 번역은 AI가 생성한 초안으로 오류가 있을 수 있습니다. 현재 원어민 검토가 진행 중입니다.';

  @override
  String get homeQuickSettingsTitle => '빠른 설정 도우미';

  @override
  String get homeQuickSettingsSubtitle => '지금 쓰는 앱에 대해 언제든 Deni에게 물어보세요';

  @override
  String get appearanceSectionTitle => '화면 스타일';

  @override
  String get themeModeSystem => '시스템';

  @override
  String get themeModeLight => '라이트';

  @override
  String get themeModeDark => '다크';

  @override
  String get quickSettingsSectionTitle => 'Enprive를 빠른 설정에 연결하기';

  @override
  String get quickSettingsSectionSubtitle =>
      'Enprive Check를 Android 빠른 설정 패널에 추가하면, 하던 일을 멈추지 않고 앱에 대해 Deni에게 물어볼 수 있어요.';

  @override
  String get quickSettingsTileTitle => 'Enprive Check 타일';

  @override
  String get quickSettingsTileSubtitle =>
      'Enprive Check를 빠른 설정에 추가하면, Enprive를 먼저 찾지 않고도 지금 쓰는 앱에 대해 Deni에게 물어볼 수 있어요.';

  @override
  String get quickSettingsStatusAdded => '추가됨';

  @override
  String get quickSettingsStatusManual => '수동';

  @override
  String get quickSettingsStatusNotAdded => '추가 안 됨';

  @override
  String get usageAccessStatusGranted => '허용됨';

  @override
  String get usageAccessStatusNotGranted => '허용 안 됨';

  @override
  String get usageAccessTitle => '사용 정보 접근 허용 (선택)';

  @override
  String get usageAccessExplanation =>
      'Enprive는 Enprive Check를 눌러 방금 쓴 앱을 알아볼 때만 사용 정보 접근을 사용해요. 그래야 Deni가 알맞은 앱과 그 앱의 개인정보 정보를 찾을 수 있어요. Enprive는 화면을 계속 지켜보지 않아요.';

  @override
  String get usageAccessManageLink => '관리 및 해제 방법';

  @override
  String get usageAccessManageTitle => '사용 정보 접근 관리 또는 해제';

  @override
  String get usageAccessManageBody =>
      '사용 정보 접근은 Android 설정에 있는 특별한 스위치예요 (자동으로 뜨는 팝업이 아니에요). Android 설정 → 앱 → 특별한 앱 접근 → 사용 정보 접근 → enprive에서 언제든 끌 수 있어요. 꺼도 앱을 직접 고르면 Deni를 쓸 수 있어요.';

  @override
  String get openDeniCompanionTitle => 'Deni 도우미 열기';

  @override
  String get openDeniCompanionSubtitle => '빠른 설정 없이 최근에 쓴 앱이나 고른 앱의 권한을 확인해요.';

  @override
  String get btnGotIt => '알겠어요';

  @override
  String get quickSettingsReadyDialogTitle => '빠른 설정에서 Enprive Check를 쓸 수 있어요';

  @override
  String get quickSettingsReadyDialogBody =>
      '화면 위쪽에서 두 번 아래로 쓸어내린 다음, Deni가 앱의 권한을 설명해 주길 원할 때 \"Enprive Check\"를 누르세요.';

  @override
  String get quickSettingsManualDialogTitle => 'Enprive Check를 직접 추가하기';

  @override
  String get quickSettingsManualDialogBody =>
      '1. Android 화면 위쪽에서 두 번 아래로 쓸어내려 빠른 설정을 열어요.\n2. 편집 (연필) 버튼을 눌러요.\n3. \"Enprive Check\"를 찾아 사용 중인 타일로 끌어다 놓아요.';

  @override
  String get quickSettingsSnackAdded => 'Enprive Check를 빠른 설정에 추가했어요.';

  @override
  String get quickSettingsSnackAlreadyAdded => 'Enprive Check가 이미 빠른 설정에 있어요.';

  @override
  String get quickSettingsSnackDeclined =>
      '요청을 닫았어요. 빠른 설정에서 편집을 직접 고르지 않으면 Enprive가 다시 묻지 않아요.';

  @override
  String get quickSettingsSnackManual =>
      '빠른 설정을 아래로 쓸어내리고 편집을 누른 다음, Enprive Check를 타일로 끌어다 놓으세요.';

  @override
  String get quickSettingsSnackUnavailable =>
      '여기서는 시스템 안내를 띄울 수 없어요. 빠른 설정의 편집에서 Enprive Check를 직접 끌어다 놓을 수 있어요.';

  @override
  String get usageAccessOpenFailedSnack => '이 기기에서 사용 정보 접근 설정을 열 수 없었어요.';

  @override
  String get companionTitle => 'Deni: Enprive 도우미';

  @override
  String get companionSubtitle => '앱의 권한과 개인정보 처리방침에 적힌 내용을 Deni에게 물어보세요.';

  @override
  String get companionTooltipReturnToPrev => '이전 앱으로 돌아가기';

  @override
  String get companionTooltipBack => '뒤로';

  @override
  String get companionLockedBadge => '잠금 화면 보호 중';

  @override
  String get companionLockedTitle => '계속하려면 휴대폰 잠금을 해제하세요';

  @override
  String get companionLockedBody =>
      '기기가 잠겨 있는 동안 Enprive는 앱 이름, 앱이 밝힌 권한, 검토 근거를 숨겨요.';

  @override
  String get companionCheckUnlockBtn => '잠금 해제 상태 확인';

  @override
  String get companionCheckingAppHeadline => '어떤 앱을 쓰고 있었는지 확인하는 중…';

  @override
  String get companionCheckingAppSubtitle => '화면을 지켜보지 않고, 이 휴대폰에서 한 번만 확인해요.';

  @override
  String get companionGeneralGuideHeadline => 'Android 권한 일반 안내';

  @override
  String get companionGeneralGuideSubtitle =>
      '선택한 앱이 없어요. Enprive는 기기 안의 안내만 사용해서 Android 권한을 설명해요.';

  @override
  String companionLookingAtHeadline(String appName) {
    return '$appName을(를) 보고 있어요.';
  }

  @override
  String get companionLookingAtSubtitle =>
      '아래 권한은 휴대폰에 있는 앱에서 가져온 거예요. 화면에 뜨는 팝업은 여전히 Android가 관리해요.';

  @override
  String get companionThisAppFallback => '이 앱';

  @override
  String companionSawAppAgo(String appName, int seconds) {
    return '$seconds초 전에 $appName을(를) 봤어요. 맞나요?';
  }

  @override
  String companionThinkUsingApp(String appName) {
    return '$appName을(를) 쓰고 있는 것 같아요. 맞나요?';
  }

  @override
  String companionAppIdLine(String packageName) {
    return 'App ID: $packageName';
  }

  @override
  String companionConfirmAppBtn(String appName) {
    return '확인 · $appName';
  }

  @override
  String get companionChooseAnotherAppBtn => '다른 앱 고르기';

  @override
  String get companionWithoutAppContextBtn => '앱 없이 진행';

  @override
  String get companionMultipleAppsTitle => '방금 여러 앱이 켜져 있었어요';

  @override
  String get companionMultipleAppsPrompt => '확인하려는 앱을 골라 주세요:';

  @override
  String companionSecondsAgo(int seconds) {
    return '$seconds초 전';
  }

  @override
  String get companionSelectAppTitle => '확인할 앱을 고르세요';

  @override
  String get companionSelectAppBody => '설치된 앱에서 직접 고르거나, 앱 없이 계속할 수 있어요.';

  @override
  String get companionChooseAppManuallyBtn => '앱 직접 고르기';

  @override
  String get companionOpenUsageAccessBtn => '사용 정보 접근 설정 열기';

  @override
  String get companionContinueWithoutAppBtn => '앱 없이 계속하기';

  @override
  String get companionAddTileBtn => 'Enprive Check 타일 추가';

  @override
  String get companionContinuingWithoutApp => '앱 없이 계속하는 중';

  @override
  String get companionSwitchAppBtn => '앱 바꾸기';

  @override
  String get companionPermissionsReadLocally => '아래 권한은 휴대폰에서 직접 읽어 온 거예요.';

  @override
  String get companionPickPermissionType => '알아볼 권한 종류를 고르세요';

  @override
  String get companionPickAppBtn => '앱 고르기';

  @override
  String get companionCouldNotReadPermsTitle => '앱 권한을 읽을 수 없어요';

  @override
  String get companionCouldNotReadPermsBody =>
      'Android가 이 앱의 권한을 확인하지 못하게 막았어요.';

  @override
  String get companionUnsurePermBtn => '어떤 권한인지 모르겠어요';

  @override
  String get companionWhichPermissionPrompt => '어떤 권한을 알고 싶나요?';

  @override
  String get companionPermissionsListDisclaimer =>
      '이 목록은 앱이 휴대폰에서 밝힌 권한이에요. 지금 화면에 뜬 팝업과 같지 않을 수도 있어요.';

  @override
  String get companionNoSensitivePermsMsg => '이 앱은 휴대폰에서 민감한 권한을 요청하지 않아요.';

  @override
  String get companionGuidedMatchTitle => '화면의 팝업이 요청한 내용을 고르세요';

  @override
  String get companionGuidedMatchSubtitle =>
      'Enprive는 지금 Android 안내 화면을 직접 읽을 수 없어요. 화면에 나온 문구와 가장 비슷한 것을 고르세요:';

  @override
  String get companionSection1Title => '1. 이 권한의 뜻';

  @override
  String get companionSection2Title => '2. 앱이 휴대폰에서 요청하는 것';

  @override
  String get companionSection3Title => '3. 개인정보 처리방침에 적힌 내용';

  @override
  String get companionSection4Title => '4. 기능과 관련 있을 수 있는 이유';

  @override
  String get companionSection4Fallback =>
      '확인된 개발자의 기능 설명을 찾지 못했어요. Deni가 관련이 있는지 확인하길 원하면, 쓰려던 기능을 아래에 적어 주세요.';

  @override
  String get companionSection5Title => '5. 아직 알 수 없는 것';

  @override
  String get companionSection6Title => '6. Deni에게 물어볼 수 있는 질문';

  @override
  String get companionAddPolicyBtn => '개인정보 처리방침 추가';

  @override
  String get companionCheckUpdatedPolicyBtn => '업데이트된 개인정보 처리방침 확인';

  @override
  String companionVerifyPolicyTitle(String appName) {
    return '$appName의 방침 확인';
  }

  @override
  String get companionFeatureFieldLabel => '쓰던 기능 (선택)';

  @override
  String get companionFeatureFieldHint => '예: QR 코드 스캔, 음성 연습 녹음';

  @override
  String get companionQuestionFieldLabel => 'Deni에게 질문하기';

  @override
  String get companionQuestionFieldHint => '이 권한을 허용하지 않으면 어떻게 되나요?';

  @override
  String get companionReceiptSavedTitle => 'Enprive 영수증에 저장됨';

  @override
  String get companionReceiptUnsavedTitle => '검토가 아직 Enprive에 저장되지 않았어요';

  @override
  String get companionReceiptSavedBody => 'Enprive 영수증 보관함에 기기 안에만 저장돼요.';

  @override
  String get companionReceiptUpdatedUnsavedBody =>
      '업데이트된 방침 검토는 이 세션에만 남아요. 도우미를 나가면 이 초안은 지워지고, 저장된 영수증은 그대로예요.';

  @override
  String get companionReceiptUnsavedBody =>
      '이 세션에만 남아요. 저장하지 않고 도우미를 나가면 지워져요.';

  @override
  String get companionSaveReceiptBtn => '영수증을 Enprive에 저장';

  @override
  String get companionSaveReceiptFailed =>
      '영수증을 저장하지 못했어요. 이 세션에는 남아 있어요. 다시 시도해 주세요.';

  @override
  String get companionSavedLocalReceiptsSnack => '기기 영수증에 저장했어요.';

  @override
  String companionDoneReturnToApp(String appName) {
    return '완료 · $appName(으)로 돌아가기';
  }

  @override
  String get companionDoneReturnToPrev => '완료 · 이전 앱으로 돌아가기';

  @override
  String get companionOpenFullAppBtn => 'Enprive 앱 전체 열기';

  @override
  String get companionCloudTimeoutSnack => '클라우드 분석이 너무 오래 걸려 끝나기 전에 멈췄어요.';

  @override
  String get companionAnalysisCancelledSnack => '분석을 취소했어요.';

  @override
  String get companionCloudAnswerTimeoutSnack =>
      '클라우드 답변 시간이 초과됐어요. 문제 없이 마무리됐어요.';

  @override
  String get companionQuestionCancelledSnack => '질문을 취소했어요.';

  @override
  String get companionTileAddedSnack => 'Enprive Check를 Android 빠른 설정에 추가했어요.';

  @override
  String get companionTileAlreadyAddedSnack => 'Enprive Check가 이미 빠른 설정에 있어요.';

  @override
  String get companionTileDeclinedSnack =>
      '타일 요청을 닫았어요. 설정이나 빠른 설정의 편집에서 언제든 추가할 수 있어요.';

  @override
  String get companionTileManualSnack =>
      '빠른 설정을 두 번 아래로 쓸어내리고 편집을 누른 다음, Enprive Check를 타일로 끌어다 놓으세요.';

  @override
  String get companionTileUnavailableSnack =>
      '이 기기에서는 Android가 빠른 설정 안내를 띄우지 못했어요. 빠른 설정의 편집에서 Enprive Check를 직접 끌어다 놓을 수 있어요.';

  @override
  String get companionUsageOptionalReason =>
      '사용 정보 접근은 선택이에요. 앱을 직접 고르거나, 사용 정보 접근을 허용하면 한 번 눌러서 앱을 알아볼 수 있어요.';

  @override
  String get companionPermPreciseLocation => '정확한 위치';

  @override
  String get companionPermBackgroundLocation => '백그라운드 위치';

  @override
  String get companionPermCamera => '카메라';

  @override
  String get companionPermMicrophone => '마이크';

  @override
  String get companionPermAdId => 'Google 광고 ID';

  @override
  String companionPermDeclaredBy(String permission, String appName) {
    return '$appName이(가) 밝힌 Android 권한 ($permission).';
  }

  @override
  String get companionPermStatusAdId => '앱이 목록에 표시 · 광고 ID';

  @override
  String get companionPermStatusAllowed => '앱이 목록에 표시 · 허용';

  @override
  String get companionPermStatusNotAllowed => '앱이 목록에 표시 · 허용 안 함';

  @override
  String get guidedCatLocation => '위치';

  @override
  String get guidedCatContacts => '연락처';

  @override
  String get guidedCatPhotosMedia => '사진 및 미디어';

  @override
  String get guidedCatNotifications => '알림';

  @override
  String get guidedCatNearbyDevices => '근처 기기';

  @override
  String get guidedCatCalendar => '캘린더';

  @override
  String get guidedCatPhone => '전화';

  @override
  String get guidedCatSms => 'SMS';

  @override
  String get companionFallbackUsageNotEnabled =>
      'Android 설정에서 사용 정보 접근이 켜져 있지 않아요.';

  @override
  String get companionFallbackUsageUnavailable =>
      'Android UsageStatsManager를 사용할 수 없어요.';

  @override
  String get companionFallbackTransientUi =>
      '최근 사용 기록에는 Android 시스템 화면이나 권한 안내만 나왔어요. 앱을 직접 고르세요.';

  @override
  String get companionFallbackVisibilityRestricted =>
      'Android의 패키지 가시성 제한 때문에 가장 최근에 쓴 앱을 확인할 수 없어요. 목록에서 앱을 고르거나 방침을 붙여 넣어 주세요.';

  @override
  String get companionFallbackUnlockRequired => '앱 정보를 보기 전에 기기 잠금을 해제하세요.';

  @override
  String get consentReasonPolicyTooDetailed =>
      '이 방침은 너무 자세해서 온디바이스 AI가 처리할 수 없어요.';

  @override
  String get consentReasonExcerptTooDetailed =>
      '이 발췌문은 너무 자세해서 온디바이스 AI가 처리할 수 없어요.';

  @override
  String get consentReasonOnDeviceUnavailable =>
      '지금은 이 휴대폰에서 온디바이스 AI를 사용할 수 없어요.';

  @override
  String get consentReasonOnDeviceCannotAnswer =>
      '지금은 이 기기의 온디바이스 AI가 답하지 못했어요.';

  @override
  String get consentReasonVoiceTooLong =>
      '확인된 이 결과는 온디바이스 요약 한도를 넘어요. 지금 오프라인 요약을 쓰거나, 개인정보를 가린 결과를 클라우드 AI에 한 번만 보낼 수 있어요.';

  @override
  String get consentReasonVoiceUnavailable =>
      '지금은 이 휴대폰에서 온디바이스 AI를 사용할 수 없어요. Enprive의 오프라인 쉬운 요약을 보여 드려요.';

  @override
  String get consentReasonVoiceTimedOut =>
      '온디바이스 요약 시간이 초과됐어요. Enprive의 오프라인 쉬운 요약을 보여 드려요.';

  @override
  String get unsavedExitTitle => '이 개인정보 검토를 저장할까요?';

  @override
  String get unsavedExitModifiedBody =>
      '저장하지 않은 검토는 이 화면을 닫으면 지워져요. 그래서 직접 선택하지 않으면 휴대폰에 아무것도 저장되지 않아요. 원래 저장된 영수증은 그대로예요.';

  @override
  String get unsavedExitDraftBody =>
      '저장하지 않은 검토는 이 화면을 닫으면 지워져요. 그래서 직접 선택하지 않으면 휴대폰에 아무것도 저장되지 않아요.';

  @override
  String get unsavedExitDiscardBtn => '저장하지 않고 지우기';

  @override
  String get unsavedExitContinueBtn => '계속 검토하기';

  @override
  String updatePrivacyPolicyForTitle(String title) {
    return '$title의 개인정보 처리방침 업데이트';
  }

  @override
  String get reviewSaveFailedError => '영수증을 저장하지 못했어요. 검토 초안은 아직 열려 있어요.';

  @override
  String get reviewRemovedFromReceiptsSnack => '저장된 영수증에서 삭제했어요.';

  @override
  String get reviewRemoveFailedSnack => '저장된 영수증을 삭제하지 못했어요.';

  @override
  String get reviewModifiedDraftTitle => '저장된 영수증에서 만든 새 초안';

  @override
  String get reviewModifiedDraftBody =>
      '이 업데이트된 검토를 남기려면 영수증에 저장하세요. 원래 저장된 영수증은 그대로예요.';

  @override
  String get btnRetrySave => '저장 다시 시도';

  @override
  String get sourceKindUrl => '공개 웹 링크';

  @override
  String get sourceKindPdf => '기기 안의 PDF 파일';

  @override
  String get sourceKindDocx => '기기 안의 Word (DOCX) 파일';

  @override
  String get sourceKindTextFile => '기기 안의 텍스트 파일';

  @override
  String get sourceKindSharedText => '공유된 텍스트';

  @override
  String get sourceKindSelectedText => '선택한 텍스트';

  @override
  String get sourceKindPhonePermissions => '휴대폰 권한';

  @override
  String get sourceKindPastedText => '붙여 넣은 텍스트';

  @override
  String get extractionStatusExtracted => '이 휴대폰에서 읽음';

  @override
  String get extractionStatusNone => '이 휴대폰에서 입력됨';

  @override
  String get extractionStatusUnsupported => '지원하지 않는 파일 형식';

  @override
  String get extractionStatusTooLarge => '파일이 너무 커요';

  @override
  String get extractionStatusEmpty => '읽을 수 있는 텍스트 없음';

  @override
  String get extractionStatusReadError => '파일을 읽을 수 없어요';

  @override
  String get extractionStatusPasswordProtected => '비밀번호로 보호됨';

  @override
  String get extractionStatusPermissionDenied => '권한이 거부됨';

  @override
  String get extractionStatusCancelled => '취소됨';

  @override
  String advancedDetailsCheckedAt(String timestamp) {
    return '확인 시각: $timestamp';
  }

  @override
  String advancedDetailsCanonicalUrl(String url) {
    return '표준 URL: $url';
  }

  @override
  String advancedDetailsRedirectedFrom(String url) {
    return '리디렉션 출처: $url';
  }

  @override
  String advancedDetailsFileLine(String filename) {
    return '파일: $filename';
  }

  @override
  String advancedDetailsStatusSuffix(String status) {
    return '상태: $status';
  }

  @override
  String advancedDetailsSha256Hash(String hash) {
    return '출처 SHA-256 해시: $hash';
  }

  @override
  String get semanticsPrimaryNavigation => '기본 내비게이션';

  @override
  String semanticsProcessingLocation(String label) {
    return '처리 위치: $label';
  }

  @override
  String get semanticsDeniMascot => 'Deni, 나의 개인정보 안내자';

  @override
  String get quoteCollapsibleDefaultHeader => '방침 원문 발췌';
}
