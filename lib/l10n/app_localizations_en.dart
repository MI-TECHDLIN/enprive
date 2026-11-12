// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Enprive';

  @override
  String get appTagline => 'Evidence-first app privacy reviews';

  @override
  String get homePrivacySubtitle => 'Your reviews stay on this phone.';

  @override
  String get stateNoConcern => 'No concern identified';

  @override
  String get stateNoConcernSubtitle =>
      'Nothing concerning in the reviewed evidence. This is not a safety certification.';

  @override
  String get stateReviewRecommended => 'Review recommended';

  @override
  String get stateReviewRecommendedSubtitle =>
      'One or more passages or permission mismatches deserve a human look.';

  @override
  String get stateInsufficientEvidence => 'Insufficient evidence';

  @override
  String get stateInsufficientEvidenceSubtitle =>
      'Evidence is missing, unavailable, or could not be verified on this device.';

  @override
  String get chipOnDevice => 'On this device';

  @override
  String get chipInCloud => 'In the cloud';

  @override
  String get chipLocationUnavailable => 'Processing location unavailable';

  @override
  String get statusSourceMatched => 'Source matched';

  @override
  String get statusDeviceObserved => 'Device observed';

  @override
  String get statusInterpretation => 'Interpretation';

  @override
  String get statusUnverified => 'Unverified';

  @override
  String get statusStale => 'Outdated / Stale';

  @override
  String get btnCheckApp => 'Check an app';

  @override
  String get btnPasteTerms => 'Paste terms or URL';

  @override
  String get btnWhyThisFinding => 'Why this finding?';

  @override
  String get btnSaveToReceipts => 'Save to Receipts';

  @override
  String get btnDiscard => 'Discard';

  @override
  String get btnAskDeni => 'Ask Deni';

  @override
  String get btnUseCloud => 'Use cloud for this check';

  @override
  String get btnReviewManually => 'Review manually';

  @override
  String get btnGetStarted => 'Get started';

  @override
  String get btnContinue => 'Continue';

  @override
  String get deniIntro =>
      'Hi, I\'m Deni. I can help you understand what this policy says, show you the evidence behind a concern, and explain what Enprive could not verify.';

  @override
  String get cloudConsentDisclosure =>
      'To analyse this text in the cloud, Enprive will send only the text shown below to Firebase AI Logic. Your installed-app list and Android permission observations will never be sent.';

  @override
  String get permissionLimitationNotice =>
      'Android reports this permission state on this phone. It does not prove whether the app actually accessed or transmitted data.';
}
