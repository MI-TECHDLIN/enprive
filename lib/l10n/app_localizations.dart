import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Enprive'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Evidence-first app privacy reviews'**
  String get appTagline;

  /// No description provided for @homePrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your reviews stay on this phone.'**
  String get homePrivacySubtitle;

  /// No description provided for @stateNoConcern.
  ///
  /// In en, this message translates to:
  /// **'No concern identified'**
  String get stateNoConcern;

  /// No description provided for @stateNoConcernSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing concerning in the reviewed evidence. This is not a safety certification.'**
  String get stateNoConcernSubtitle;

  /// No description provided for @stateReviewRecommended.
  ///
  /// In en, this message translates to:
  /// **'Review recommended'**
  String get stateReviewRecommended;

  /// No description provided for @stateReviewRecommendedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One or more passages or permission mismatches deserve a human look.'**
  String get stateReviewRecommendedSubtitle;

  /// No description provided for @stateInsufficientEvidence.
  ///
  /// In en, this message translates to:
  /// **'Insufficient evidence'**
  String get stateInsufficientEvidence;

  /// No description provided for @stateInsufficientEvidenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence is missing, unavailable, or could not be verified on this device.'**
  String get stateInsufficientEvidenceSubtitle;

  /// No description provided for @chipOnDevice.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get chipOnDevice;

  /// No description provided for @chipInCloud.
  ///
  /// In en, this message translates to:
  /// **'In the cloud'**
  String get chipInCloud;

  /// No description provided for @chipLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Processing location unavailable'**
  String get chipLocationUnavailable;

  /// No description provided for @statusSourceMatched.
  ///
  /// In en, this message translates to:
  /// **'Source matched'**
  String get statusSourceMatched;

  /// No description provided for @statusDeviceObserved.
  ///
  /// In en, this message translates to:
  /// **'Device observed'**
  String get statusDeviceObserved;

  /// No description provided for @statusInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Interpretation'**
  String get statusInterpretation;

  /// No description provided for @statusUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get statusUnverified;

  /// No description provided for @statusStale.
  ///
  /// In en, this message translates to:
  /// **'Outdated / Stale'**
  String get statusStale;

  /// No description provided for @btnCheckApp.
  ///
  /// In en, this message translates to:
  /// **'Check an app'**
  String get btnCheckApp;

  /// No description provided for @btnPasteTerms.
  ///
  /// In en, this message translates to:
  /// **'Paste terms or URL'**
  String get btnPasteTerms;

  /// No description provided for @btnWhyThisFinding.
  ///
  /// In en, this message translates to:
  /// **'Why this finding?'**
  String get btnWhyThisFinding;

  /// No description provided for @btnSaveToReceipts.
  ///
  /// In en, this message translates to:
  /// **'Save to Receipts'**
  String get btnSaveToReceipts;

  /// No description provided for @btnDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get btnDiscard;

  /// No description provided for @btnAskDeni.
  ///
  /// In en, this message translates to:
  /// **'Ask Deni'**
  String get btnAskDeni;

  /// No description provided for @btnUseCloud.
  ///
  /// In en, this message translates to:
  /// **'Use cloud for this check'**
  String get btnUseCloud;

  /// No description provided for @btnReviewManually.
  ///
  /// In en, this message translates to:
  /// **'Review manually'**
  String get btnReviewManually;

  /// No description provided for @btnGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get btnGetStarted;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @deniIntro.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Deni. I can help you understand what this policy says, show you the evidence behind a concern, and explain what Enprive could not verify.'**
  String get deniIntro;

  /// No description provided for @cloudConsentDisclosure.
  ///
  /// In en, this message translates to:
  /// **'To analyse this text in the cloud, Enprive will send only the text shown below to Firebase AI Logic. Your installed-app list and Android permission observations will never be sent.'**
  String get cloudConsentDisclosure;

  /// No description provided for @permissionLimitationNotice.
  ///
  /// In en, this message translates to:
  /// **'Android reports this permission state on this phone. It does not prove whether the app actually accessed or transmitted data.'**
  String get permissionLimitationNotice;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navReceipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get navReceipts;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applies to app interface, explanations, and voice read-aloud'**
  String get languageSubtitle;

  /// No description provided for @homeHeroHeadline.
  ///
  /// In en, this message translates to:
  /// **'A clearer look at the\napps children use'**
  String get homeHeroHeadline;

  /// No description provided for @trySampleCheck.
  ///
  /// In en, this message translates to:
  /// **'Try a sample app check'**
  String get trySampleCheck;

  /// No description provided for @eduTrackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Homework & attendance'**
  String get eduTrackSubtitle;

  /// No description provided for @eduTrackValue.
  ///
  /// In en, this message translates to:
  /// **'3 requests'**
  String get eduTrackValue;

  /// No description provided for @eduTrackTrend.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get eduTrackTrend;

  /// No description provided for @calmMathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline math practice'**
  String get calmMathSubtitle;

  /// No description provided for @calmMathValue.
  ///
  /// In en, this message translates to:
  /// **'0 sensitive'**
  String get calmMathValue;

  /// No description provided for @calmMathTrend.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get calmMathTrend;

  /// No description provided for @whatWeCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'What we check for'**
  String get whatWeCheckTitle;

  /// No description provided for @checkQuoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Exact policy quotes'**
  String get checkQuoteTitle;

  /// No description provided for @checkQuoteDesc.
  ///
  /// In en, this message translates to:
  /// **'Flags sharing, voice recording, and retention with verbatim quotes.'**
  String get checkQuoteDesc;

  /// No description provided for @checkPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone permission mismatches'**
  String get checkPermissionTitle;

  /// No description provided for @checkPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Compares Camera, Mic, and Location access against what the policy claims.'**
  String get checkPermissionDesc;

  /// No description provided for @checkSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select text anywhere'**
  String get checkSelectTitle;

  /// No description provided for @checkSelectDesc.
  ///
  /// In en, this message translates to:
  /// **'Highlight terms in any app and tap Enprive Check from Android’s menu.'**
  String get checkSelectDesc;

  /// No description provided for @recentlyReviewed.
  ///
  /// In en, this message translates to:
  /// **'Recently reviewed'**
  String get recentlyReviewed;

  /// Count of verified policy clauses shown in recently reviewed cards
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 verified clause} other{{count} verified clauses}}'**
  String verifiedClausesCount(int count);

  /// No description provided for @trySampleText.
  ///
  /// In en, this message translates to:
  /// **'Try sample text'**
  String get trySampleText;

  /// No description provided for @modePasteText.
  ///
  /// In en, this message translates to:
  /// **'Paste text'**
  String get modePasteText;

  /// No description provided for @modePolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Policy link'**
  String get modePolicyLink;

  /// No description provided for @hintAppName.
  ///
  /// In en, this message translates to:
  /// **'App name'**
  String get hintAppName;

  /// No description provided for @defaultSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get defaultSubjectTitle;

  /// No description provided for @selectedExcerptTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected Policy Excerpt'**
  String get selectedExcerptTitle;

  /// No description provided for @hintPastePolicy.
  ///
  /// In en, this message translates to:
  /// **'Paste privacy policy text here…'**
  String get hintPastePolicy;

  /// No description provided for @btnReviewOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Review on this phone'**
  String get btnReviewOnPhone;

  /// No description provided for @onboardingIntroHeadline.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Deni. 👋'**
  String get onboardingIntroHeadline;

  /// No description provided for @onboardingIntroLead.
  ///
  /// In en, this message translates to:
  /// **'Let\'s make app privacy easier to understand.'**
  String get onboardingIntroLead;

  /// No description provided for @onboardingIntroBody.
  ///
  /// In en, this message translates to:
  /// **'I\'ll help you uncover what an app\'s privacy policy really says, highlight the exact passages that matter, and explain what your device reports.\n\nNo guessing. No false promises. Just clear explanations and evidence to help you make informed decisions.'**
  String get onboardingIntroBody;

  /// No description provided for @onboardingIntroFooter.
  ///
  /// In en, this message translates to:
  /// **'Know what you\'re agreeing to.'**
  String get onboardingIntroFooter;

  /// No description provided for @onboardingStep1Question.
  ///
  /// In en, this message translates to:
  /// **'How should I explain\nprivacy terms?'**
  String get onboardingStep1Question;

  /// No description provided for @depthQuickMultiline.
  ///
  /// In en, this message translates to:
  /// **'Quick &\nplain'**
  String get depthQuickMultiline;

  /// No description provided for @depthBalancedMultiline.
  ///
  /// In en, this message translates to:
  /// **'Balanced\nview'**
  String get depthBalancedMultiline;

  /// No description provided for @depthFullMultiline.
  ///
  /// In en, this message translates to:
  /// **'Full\ndetail'**
  String get depthFullMultiline;

  /// No description provided for @onboardingReadinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Private by default\non this phone'**
  String get onboardingReadinessTitle;

  /// No description provided for @onboardingReadinessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Designed so parents and teachers can inspect apps without sharing device data.'**
  String get onboardingReadinessSubtitle;

  /// No description provided for @readinessRow1Title.
  ///
  /// In en, this message translates to:
  /// **'Checked here first'**
  String get readinessRow1Title;

  /// No description provided for @readinessRow1Desc.
  ///
  /// In en, this message translates to:
  /// **'Policies are read on your phone before anything else.'**
  String get readinessRow1Desc;

  /// No description provided for @readinessRow2Title.
  ///
  /// In en, this message translates to:
  /// **'Your apps stay yours'**
  String get readinessRow2Title;

  /// No description provided for @readinessRow2Desc.
  ///
  /// In en, this message translates to:
  /// **'The apps on this phone and their permissions never leave it.'**
  String get readinessRow2Desc;

  /// No description provided for @readinessRow3Title.
  ///
  /// In en, this message translates to:
  /// **'Personal details scrubbed'**
  String get readinessRow3Title;

  /// No description provided for @readinessRow3Desc.
  ///
  /// In en, this message translates to:
  /// **'If on-device AI isn’t available or a policy is long, names, emails, and phone numbers become placeholders before App Check verification.'**
  String get readinessRow3Desc;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @privateAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Private analysis on this phone'**
  String get privateAnalysisTitle;

  /// No description provided for @onDeviceReadyMsg.
  ///
  /// In en, this message translates to:
  /// **'On-device AI is active and ready.'**
  String get onDeviceReadyMsg;

  /// No description provided for @localScannerProtectedMsg.
  ///
  /// In en, this message translates to:
  /// **'Protected by built-in local clause scanning.'**
  String get localScannerProtectedMsg;

  /// No description provided for @statusChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get statusChecking;

  /// No description provided for @btnCheckReadiness.
  ///
  /// In en, this message translates to:
  /// **'Check readiness'**
  String get btnCheckReadiness;

  /// No description provided for @howShouldDeniExplain.
  ///
  /// In en, this message translates to:
  /// **'How should Deni explain things?'**
  String get howShouldDeniExplain;

  /// No description provided for @depthQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get depthQuick;

  /// No description provided for @depthBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get depthBalanced;

  /// No description provided for @depthFull.
  ///
  /// In en, this message translates to:
  /// **'Full detail'**
  String get depthFull;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @meetDeniGuide.
  ///
  /// In en, this message translates to:
  /// **'Meet Deni & setup guide'**
  String get meetDeniGuide;

  /// Settings action label showing saved receipt count
  ///
  /// In en, this message translates to:
  /// **'Clear saved receipts ({count})'**
  String clearSavedReceiptsCount(int count);

  /// No description provided for @btnClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get btnClear;

  /// No description provided for @confirmClearReceiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear saved receipts?'**
  String get confirmClearReceiptsTitle;

  /// Dialog confirmation body before clearing saved receipts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This removes 1 saved review from your phone.} other{This removes {count} saved reviews from your phone.}}'**
  String confirmClearReceiptsBody(int count);

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @receiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receiptsTitle;

  /// No description provided for @tooltipSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tooltipSearch;

  /// No description provided for @hintSearchReceipts.
  ///
  /// In en, this message translates to:
  /// **'Search saved reviews...'**
  String get hintSearchReceipts;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get filterReview;

  /// No description provided for @filterNoConcern.
  ///
  /// In en, this message translates to:
  /// **'No concern'**
  String get filterNoConcern;

  /// No description provided for @emptyFilteredTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching receipts'**
  String get emptyFilteredTitle;

  /// No description provided for @emptyReceiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved receipts yet'**
  String get emptyReceiptsTitle;

  /// No description provided for @emptyFilteredBody.
  ///
  /// In en, this message translates to:
  /// **'Try selecting another filter above.'**
  String get emptyFilteredBody;

  /// No description provided for @emptyReceiptsBody.
  ///
  /// In en, this message translates to:
  /// **'Bookmark any app review to keep a private copy on your phone.'**
  String get emptyReceiptsBody;

  /// No description provided for @btnStartReview.
  ///
  /// In en, this message translates to:
  /// **'Start a review'**
  String get btnStartReview;

  /// No description provided for @btnOpenReceipt.
  ///
  /// In en, this message translates to:
  /// **'Open receipt'**
  String get btnOpenReceipt;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @checkingPhoneReadiness.
  ///
  /// In en, this message translates to:
  /// **'Checking private analysis readiness on this phone…'**
  String get checkingPhoneReadiness;

  /// No description provided for @geminiNanoReadyMsg.
  ///
  /// In en, this message translates to:
  /// **'Gemini Nano is ready on this phone. Reviews stay completely on your device.'**
  String get geminiNanoReadyMsg;

  /// No description provided for @modelDownloadingMsg.
  ///
  /// In en, this message translates to:
  /// **'Downloading private on-device model in the background.'**
  String get modelDownloadingMsg;

  /// No description provided for @modelDownloadableMsg.
  ///
  /// In en, this message translates to:
  /// **'On-device model can be downloaded over Wi-Fi.'**
  String get modelDownloadableMsg;

  /// No description provided for @localScannerDefaultMsg.
  ///
  /// In en, this message translates to:
  /// **'This phone uses Enprive’s built-in local clause scanner by default.'**
  String get localScannerDefaultMsg;

  /// No description provided for @preparingPrivateAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Preparing private analysis…'**
  String get preparingPrivateAnalysis;

  /// No description provided for @onDeviceAiReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'On-device AI ready'**
  String get onDeviceAiReadyTitle;

  /// No description provided for @localScannerActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Local scanner active'**
  String get localScannerActiveTitle;

  /// No description provided for @privateAnalysisSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your installed apps and permission checks never leave your phone.'**
  String get privateAnalysisSheetSubtitle;

  /// No description provided for @btnDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get btnDone;

  /// No description provided for @btnCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get btnCheckAgain;

  /// No description provided for @reviewingOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Reviewing on this phone…'**
  String get reviewingOnPhone;

  /// No description provided for @readingClausesInitial.
  ///
  /// In en, this message translates to:
  /// **'Reading policy clauses on this phone…'**
  String get readingClausesInitial;

  /// Step counter inside the live review progress card
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String progressStepCounter(int current, int total);

  /// Step count badge on analysis trace card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String stepsCountLabel(int count);

  /// No description provided for @thoughtSignaturePrefix.
  ///
  /// In en, this message translates to:
  /// **'Thought signature'**
  String get thoughtSignaturePrefix;

  /// No description provided for @viewStreamedThoughts.
  ///
  /// In en, this message translates to:
  /// **'View streamed thoughts'**
  String get viewStreamedThoughts;

  /// No description provided for @hideStreamedThoughts.
  ///
  /// In en, this message translates to:
  /// **'Hide streamed thoughts'**
  String get hideStreamedThoughts;

  /// No description provided for @analysisTraceDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'How this review was checked'**
  String get analysisTraceDefaultTitle;

  /// No description provided for @savedToLocalReceiptsSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved to your local receipts.'**
  String get savedToLocalReceiptsSnack;

  /// No description provided for @snapshotSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviewed policy snapshot'**
  String get snapshotSheetTitle;

  /// No description provided for @snapshotSourcePrefix.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get snapshotSourcePrefix;

  /// No description provided for @snapshotReviewedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get snapshotReviewedPrefix;

  /// No description provided for @snapshotDigestPrefix.
  ///
  /// In en, this message translates to:
  /// **'Digest'**
  String get snapshotDigestPrefix;

  /// No description provided for @statFindings.
  ///
  /// In en, this message translates to:
  /// **'Findings'**
  String get statFindings;

  /// No description provided for @statVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statVerified;

  /// No description provided for @statOsGranted.
  ///
  /// In en, this message translates to:
  /// **'OS Granted'**
  String get statOsGranted;

  /// No description provided for @statUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get statUnverified;

  /// No description provided for @keyFindingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Findings'**
  String get keyFindingsTitle;

  /// No description provided for @reviewedExcerptTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviewed Excerpt'**
  String get reviewedExcerptTitle;

  /// No description provided for @permissionsOnPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions on this phone'**
  String get permissionsOnPhoneTitle;

  /// No description provided for @viewReviewedSnapshot.
  ///
  /// In en, this message translates to:
  /// **'View reviewed policy snapshot'**
  String get viewReviewedSnapshot;

  /// No description provided for @btnSavedToReceipts.
  ///
  /// In en, this message translates to:
  /// **'Saved to Receipts'**
  String get btnSavedToReceipts;

  /// No description provided for @observedOnPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Observed on this phone'**
  String get observedOnPhoneLabel;

  /// No description provided for @quoteVerifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote verified in policy'**
  String get quoteVerifiedLabel;

  /// No description provided for @unverifiedClaimLabel.
  ///
  /// In en, this message translates to:
  /// **'Unverified claim'**
  String get unverifiedClaimLabel;

  /// No description provided for @categoryDataCollection.
  ///
  /// In en, this message translates to:
  /// **'Data Collection'**
  String get categoryDataCollection;

  /// No description provided for @categorySharing.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Sharing'**
  String get categorySharing;

  /// No description provided for @categoryTracking.
  ///
  /// In en, this message translates to:
  /// **'Location & Tracking'**
  String get categoryTracking;

  /// No description provided for @categoryRetention.
  ///
  /// In en, this message translates to:
  /// **'Retention & Voice'**
  String get categoryRetention;

  /// No description provided for @categoryParentalControls.
  ///
  /// In en, this message translates to:
  /// **'Parental Controls'**
  String get categoryParentalControls;

  /// No description provided for @labelInPlainLanguage.
  ///
  /// In en, this message translates to:
  /// **'In plain language'**
  String get labelInPlainLanguage;

  /// No description provided for @labelOnThisPhone.
  ///
  /// In en, this message translates to:
  /// **'On this phone'**
  String get labelOnThisPhone;

  /// No description provided for @labelWhatRemainsUnknown.
  ///
  /// In en, this message translates to:
  /// **'What remains unknown'**
  String get labelWhatRemainsUnknown;

  /// No description provided for @presetQuestionMeaning.
  ///
  /// In en, this message translates to:
  /// **'What does this mean for my child?'**
  String get presetQuestionMeaning;

  /// No description provided for @presetQuestionOptOut.
  ///
  /// In en, this message translates to:
  /// **'Can we turn this off or opt out?'**
  String get presetQuestionOptOut;

  /// No description provided for @presetQuestionUnknown.
  ///
  /// In en, this message translates to:
  /// **'What is still unknown here?'**
  String get presetQuestionUnknown;

  /// No description provided for @readingCitedClause.
  ///
  /// In en, this message translates to:
  /// **'Reading cited policy clause…'**
  String get readingCitedClause;

  /// No description provided for @deniAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'Deni’s Answer'**
  String get deniAnswerTitle;

  /// No description provided for @stepsAndReasoning.
  ///
  /// In en, this message translates to:
  /// **'Steps & model reasoning'**
  String get stepsAndReasoning;

  /// No description provided for @chooseReviewModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how to review this text'**
  String get chooseReviewModeTitle;

  /// No description provided for @cloudNeverSendsAppsNote.
  ///
  /// In en, this message translates to:
  /// **'Installed apps and phone permissions are never sent.'**
  String get cloudNeverSendsAppsNote;

  /// No description provided for @tooltipClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tooltipClose;

  /// No description provided for @checkAppSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Checked locally on your phone. Your app list is never uploaded.'**
  String get checkAppSheetSubtitle;

  /// No description provided for @trySampleKidsApp.
  ///
  /// In en, this message translates to:
  /// **'Try a sample kids app'**
  String get trySampleKidsApp;

  /// No description provided for @sampleEduTrackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Location, mic & camera'**
  String get sampleEduTrackSubtitle;

  /// No description provided for @sampleCalmMathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline math practice'**
  String get sampleCalmMathSubtitle;

  /// No description provided for @appsOnThisPhone.
  ///
  /// In en, this message translates to:
  /// **'Apps on this phone'**
  String get appsOnThisPhone;

  /// No description provided for @hintSearchApps.
  ///
  /// In en, this message translates to:
  /// **'Search apps…'**
  String get hintSearchApps;

  /// No description provided for @noMatchingApps.
  ///
  /// In en, this message translates to:
  /// **'No matching apps found on this phone.'**
  String get noMatchingApps;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
