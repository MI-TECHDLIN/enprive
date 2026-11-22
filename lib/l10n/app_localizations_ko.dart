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
      '하나 이상의 약관 문장이나 권한 불일치를 사람이 직접 확인해 보는 것이 좋습니다.';

  @override
  String get stateInsufficientEvidence => '근거 부족';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      '근거가 누락되었거나 사용할 수 없거나 이 기기에서 검증할 수 없습니다.';

  @override
  String get chipOnDevice => '이 기기에서 분석';

  @override
  String get chipInCloud => '클라우드 분석';

  @override
  String get chipLocationUnavailable => '처리 위치 불명';

  @override
  String get chipOfflineDeterministic => '오프라인 로컬 스캔';

  @override
  String get chipUnknown => '처리 출처를 알 수 없음';

  @override
  String get statusSourceMatched => '원문 일치 확인';

  @override
  String get statusDeviceObserved => '기기에서 확인됨';

  @override
  String get statusInterpretation => '요약 설명';

  @override
  String get statusUnverified => '미확인 주장';

  @override
  String get statusStale => '오래된 정보';

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
      '이 문장을 클라우드에서 분석하기 위해 Enprive는 위에 표시된 가림 처리된 텍스트만 Firebase AI Logic으로 전송합니다. 설치된 앱 목록과 Android 권한 정보는 절대 전송되지 않습니다.';

  @override
  String get permissionLimitationNotice =>
      'Android가 이 기기에서 보고한 권한 상태입니다. 실제로 데이터를 수집하거나 전송했는지는 증명하지 않습니다.';

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
  String get trySampleCheck => '샘플 앱 바로 검토하기';

  @override
  String get eduTrackSubtitle => '숙제·출결 샘플';

  @override
  String get eduTrackValue => '권한 3건';

  @override
  String get eduTrackTrend => '확인 권장';

  @override
  String get calmMathSubtitle => '오프라인 수학 샘플';

  @override
  String get calmMathValue => '민감 0건';

  @override
  String get calmMathTrend => '단순함';

  @override
  String get whatWeCheckTitle => '중점 확인 항목';

  @override
  String get checkQuoteTitle => '정확한 약관 원문';

  @override
  String get checkQuoteDesc => '공유·음성 녹음·보관 기간 조항을 원문과 함께 짚어줍니다.';

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
      other: '검증된 조항 $count건',
    );
    return '$_temp0';
  }

  @override
  String get trySampleText => '샘플 문장 넣기';

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
  String get readinessRow3Title => '개인정보 자동 가림 처리';

  @override
  String get readinessRow3Desc =>
      '기기 내 모델이 없거나 긴 약관을 검토할 때는 이름·이메일·전화번호를 [가림] 표시로 바꾼 뒤 App Check로 안전하게 확인합니다.';

  @override
  String get settingsTitle => '설정';

  @override
  String get privateAnalysisTitle => '이 휴대폰에서 비공개 분석';

  @override
  String get onDeviceReadyMsg => '온디바이스 모델이 준비되었습니다.';

  @override
  String get localScannerProtectedMsg => '내장된 로컬 약관 스캐너로 안전하게 작동 중입니다.';

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
      '온디바이스 Gemini Nano가 준비되었습니다. 모든 분석이 기기 안에서 이루어집니다.';

  @override
  String get modelDownloadingMsg => '비공개 모델을 백그라운드에서 다운로드하고 있습니다.';

  @override
  String get modelDownloadableMsg => 'Wi-Fi 연결 시 온디바이스 모델을 다운로드할 수 있습니다.';

  @override
  String get localScannerDefaultMsg => '이 기기에서는 내장된 로컬 약관 스캐너로 안전하게 작동합니다.';

  @override
  String get preparingPrivateAnalysis => '비공개 분석 준비 중…';

  @override
  String get onDeviceAiReadyTitle => '온디바이스 AI 준비 완료';

  @override
  String get localScannerActiveTitle => '로컬 스캐너 보호 활성';

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
  String get readingClausesInitial => '이 휴대폰에서 약관 조항을 읽는 중…';

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
  String get thoughtSignaturePrefix => '사고 서명';

  @override
  String get viewStreamedThoughts => '추론 과정 보기';

  @override
  String get hideStreamedThoughts => '추론 과정 접기';

  @override
  String get analysisTraceDefaultTitle => '이 검토가 확인된 방식';

  @override
  String get savedToLocalReceiptsSnack => '이 휴대폰의 영수증 보관함에 저장되었습니다.';

  @override
  String get snapshotSheetTitle => '검토한 약관 원문 스냅샷';

  @override
  String get snapshotSourcePrefix => '출처';

  @override
  String get snapshotReviewedPrefix => '검토 일시';

  @override
  String get snapshotDigestPrefix => '요약 해시';

  @override
  String get statFindings => '발견 항목';

  @override
  String get statVerified => '검증됨';

  @override
  String get statOsGranted => 'OS 허용됨';

  @override
  String get statUnverified => '미확인';

  @override
  String get keyFindingsTitle => '주요 발견 사항';

  @override
  String get reviewedExcerptTitle => '검토한 약관 전문';

  @override
  String get permissionsOnPhoneTitle => '이 휴대폰의 앱 권한';

  @override
  String get viewReviewedSnapshot => '검토한 약관 스냅샷 보기';

  @override
  String get btnSavedToReceipts => '영수증에 저장됨';

  @override
  String get observedOnPhoneLabel => '이 휴대폰에서 확인됨';

  @override
  String get quoteVerifiedLabel => '약관 원문에서 검증됨';

  @override
  String get unverifiedClaimLabel => '미확인 주장';

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
  String get labelWhatRemainsUnknown => '아직 확인되지 않은 부분';

  @override
  String get presetQuestionMeaning => '아이에게 어떤 영향이 있나요?';

  @override
  String get presetQuestionOptOut => '이 기능을 끄거나 거부할 수 있나요?';

  @override
  String get presetQuestionUnknown => '여기서 아직 알 수 없는 점은 무엇인가요?';

  @override
  String get readingCitedClause => '인용된 약관 조항을 읽는 중…';

  @override
  String get deniAnswerTitle => '데니의 답변';

  @override
  String get stepsAndReasoning => '확인 단계 및 모델 추론';

  @override
  String get chooseReviewModeTitle => '이 문장을 검토할 방법을 선택하세요';

  @override
  String get cloudNeverSendsAppsNote => '설치된 앱 목록과 휴대폰 권한은 절대 전송되지 않습니다.';

  @override
  String get tooltipClose => '닫기';

  @override
  String get checkAppSheetSubtitle => '이 휴대폰 안에서만 확인합니다. 앱 목록은 절대 업로드되지 않습니다.';

  @override
  String get trySampleKidsApp => '샘플 어린이 앱 테스트하기';

  @override
  String get sampleEduTrackSubtitle => '위치, 마이크 및 카메라';

  @override
  String get sampleCalmMathSubtitle => '오프라인 수학 연습';

  @override
  String get appsOnThisPhone => '이 휴대폰에 설치된 앱';

  @override
  String get hintSearchApps => '앱 이름 검색…';

  @override
  String get noMatchingApps => '일치하는 앱을 찾지 못했습니다.';

  @override
  String get sampleSyntheticBadge => '가상 예시';

  @override
  String get permissionInspectionTitle => '기기 권한 검사';

  @override
  String get addAppPrivacyPolicyBtn => '이 앱의 개인정보 처리방침 추가';

  @override
  String get snapshotDigestLabel => '스냅샷 다이제스트 · FNV-1a 64비트';

  @override
  String get snapshotDigestExplanation =>
      '이 텍스트의 빠른 64비트 로컬 지문입니다(암호화 SHA-256 아님). 한 글자만 바뀌어도 값이 달라집니다.';

  @override
  String get copyDigestBtn => '다이제스트 복사';

  @override
  String get digestCopiedMsg => '스냅샷 다이제스트를 복사했습니다';

  @override
  String get permissionGrantedBadge => '허용됨';

  @override
  String get permissionNotGrantedBadge => '허용되지 않음';

  @override
  String get checkingPolicyWithCloudAi => '클라우드 AI로 정책을 확인하고 있습니다.';

  @override
  String get preparingCloudAiStream => '개인정보를 가린 클라우드 확인을 준비하는 중…';

  @override
  String get cancellingAnalysis => '취소 중…';

  @override
  String get analysisCancelledNotice => '검토가 취소되었습니다.';

  @override
  String get cloudTimedOutNotice =>
      '클라우드 AI 응답 시간이 초과되었습니다. 자동 재시도는 전송되지 않았습니다.';

  @override
  String get cloudFallbackBannerTitle => '클라우드 AI를 사용할 수 없음 — 로컬 스캔 표시됨';

  @override
  String get cloudFallbackBannerBody =>
      '클라우드 분석을 사용할 수 없어 Enprive의 로컬 결정적 스캐너 결과를 표시하고 있습니다.';

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
  String receiptDeletedSnack(String title) {
    return 'Deleted $title';
  }

  @override
  String get btnUndo => 'Undo';

  @override
  String get readinessPromiseMaskedTitle => 'Personal details hidden';

  @override
  String get readinessPromiseMaskedLine =>
      'If you choose cloud, names, emails and numbers are masked first.';

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
