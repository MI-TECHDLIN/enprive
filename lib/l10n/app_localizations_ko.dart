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
  String get appTagline => '증거 중심 앱 개인정보 검토';

  @override
  String get homePrivacySubtitle => '검토 내용은 이 기기에만 안전하게 보관됩니다.';

  @override
  String get stateNoConcern => '우려 사항 미발견';

  @override
  String get stateNoConcernSubtitle =>
      '검토된 증거에서 우려 사항이 발견되지 않았습니다. 이는 안전성 보증이 아닙니다.';

  @override
  String get stateReviewRecommended => '검토 권장';

  @override
  String get stateReviewRecommendedSubtitle =>
      '하나 이상의 방침 조항 또는 권한 불일치에 대한 확인이 필요합니다.';

  @override
  String get stateInsufficientEvidence => '증거 불충분';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      '증거가 누락되었거나 이 기기에서 안전하게 검토할 수 없습니다.';

  @override
  String get chipOnDevice => '기기 내 처리 (On-Device)';

  @override
  String get chipInCloud => '클라우드 처리 (In-Cloud)';

  @override
  String get chipLocationUnavailable => '처리 위치 확인 불가';

  @override
  String get statusSourceMatched => '출처 일치';

  @override
  String get statusDeviceObserved => '기기 확인됨';

  @override
  String get statusInterpretation => '해석';

  @override
  String get statusUnverified => '미확인';

  @override
  String get statusStale => '확인 필요 / 만료됨';

  @override
  String get btnCheckApp => '앱 검토하기';

  @override
  String get btnPasteTerms => '방침 또는 URL 붙여넣기';

  @override
  String get btnWhyThisFinding => '이 결과를 도출한 근거는?';

  @override
  String get btnSaveToReceipts => '영수증에 저장';

  @override
  String get btnDiscard => '삭제';

  @override
  String get btnAskDeni => '데니에게 질문하기';

  @override
  String get btnUseCloud => '이 검토에 클라우드 사용';

  @override
  String get btnReviewManually => '직접 검토하기';

  @override
  String get btnGetStarted => '시작하기';

  @override
  String get btnContinue => '계속';

  @override
  String get deniIntro =>
      '안녕하세요, 데니입니다. 방침 내용을 이해하기 쉽게 설명해 드리고, 우려 사항의 근거를 확인해 드리며, 검증되지 않은 부분도 솔직하게 안내해 드립니다.';

  @override
  String get cloudConsentDisclosure =>
      '이 텍스트를 클라우드에서 분석하기 위해, 아래에 표시된 내용만 Firebase AI Logic으로 전송합니다. 설치된 앱 목록과 Android 권한 상태는 절대 전송되지 않습니다.';

  @override
  String get permissionLimitationNotice =>
      'Android가 이 기기에서 보고한 권한 상태입니다. 앱이 실제로 데이터를 전송했는지는 증명하지 않습니다.';
}
