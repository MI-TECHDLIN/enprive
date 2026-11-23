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
  /// **'No concern identified in the reviewed evidence. This is not a safety certification.'**
  String get stateNoConcernSubtitle;

  /// No description provided for @stateReviewRecommended.
  ///
  /// In en, this message translates to:
  /// **'Review recommended'**
  String get stateReviewRecommended;

  /// No description provided for @stateReviewRecommendedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One or more policy parts or phone permissions need a closer look.'**
  String get stateReviewRecommendedSubtitle;

  /// No description provided for @stateInsufficientEvidence.
  ///
  /// In en, this message translates to:
  /// **'Insufficient evidence'**
  String get stateInsufficientEvidence;

  /// No description provided for @stateInsufficientEvidenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We need more privacy policy text before we can check what this app does.'**
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
  /// **'Source not available'**
  String get chipLocationUnavailable;

  /// No description provided for @chipOfflineDeterministic.
  ///
  /// In en, this message translates to:
  /// **'Checked offline on this phone'**
  String get chipOfflineDeterministic;

  /// No description provided for @chipUnknown.
  ///
  /// In en, this message translates to:
  /// **'Source unknown'**
  String get chipUnknown;

  /// No description provided for @statusSourceMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched in policy'**
  String get statusSourceMatched;

  /// No description provided for @statusDeviceObserved.
  ///
  /// In en, this message translates to:
  /// **'Seen on this phone'**
  String get statusDeviceObserved;

  /// No description provided for @statusInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Deni\'s explanation'**
  String get statusInterpretation;

  /// No description provided for @statusUnverified.
  ///
  /// In en, this message translates to:
  /// **'Not found in policy'**
  String get statusUnverified;

  /// No description provided for @statusStale.
  ///
  /// In en, this message translates to:
  /// **'Older check'**
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
  /// **'To check this in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions will never be sent.'**
  String get cloudConsentDisclosure;

  /// No description provided for @permissionLimitationNotice.
  ///
  /// In en, this message translates to:
  /// **'Your phone shows whether this permission is allowed. It does not prove whether the app actually accessed or sent data.'**
  String get permissionLimitationNotice;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get navCheck;

  /// No description provided for @navReceipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get navReceipts;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

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
  /// **'Highlights data sharing, voice recording, and how long data is kept using exact quotes.'**
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
  /// **'{count, plural, =1{1 matched quote} other{{count} matched quotes}}'**
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

  /// No description provided for @splashQuote.
  ///
  /// In en, this message translates to:
  /// **'Know what you\'re agreeing to'**
  String get splashQuote;

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
  /// **'Personal details hidden'**
  String get readinessRow3Title;

  /// No description provided for @readinessRow3Desc.
  ///
  /// In en, this message translates to:
  /// **'If you choose cloud help, names, emails, and phone numbers are hidden before anything is sent.'**
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
  /// **'Ready to check policies offline on this phone.'**
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
  /// **'On-device AI is ready on this phone. Reviews stay completely on your device.'**
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
  /// **'This phone checks policies offline on your device by default.'**
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
  /// **'Offline check ready'**
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
  /// **'Reviewing on this phone.'**
  String get reviewingOnPhone;

  /// No description provided for @readingClausesInitial.
  ///
  /// In en, this message translates to:
  /// **'Reading policy text on this phone…'**
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
  /// **'Check ID'**
  String get thoughtSignaturePrefix;

  /// No description provided for @viewStreamedThoughts.
  ///
  /// In en, this message translates to:
  /// **'How Enprive checked this'**
  String get viewStreamedThoughts;

  /// No description provided for @hideStreamedThoughts.
  ///
  /// In en, this message translates to:
  /// **'Hide how Enprive checked this'**
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
  /// **'Reviewed policy text'**
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
  /// **'Document fingerprint'**
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
  /// **'Allowed on phone'**
  String get statOsGranted;

  /// No description provided for @statUnverified.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
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
  /// **'View reviewed policy text'**
  String get viewReviewedSnapshot;

  /// No description provided for @btnSavedToReceipts.
  ///
  /// In en, this message translates to:
  /// **'Saved to Receipts'**
  String get btnSavedToReceipts;

  /// No description provided for @observedOnPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Seen on this phone'**
  String get observedOnPhoneLabel;

  /// No description provided for @quoteVerifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Exact quote from policy'**
  String get quoteVerifiedLabel;

  /// No description provided for @unverifiedClaimLabel.
  ///
  /// In en, this message translates to:
  /// **'Not found in policy'**
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
  /// **'What we still don\'t know'**
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
  /// **'Reading the policy quote…'**
  String get readingCitedClause;

  /// No description provided for @deniAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'Deni’s Answer'**
  String get deniAnswerTitle;

  /// No description provided for @stepsAndReasoning.
  ///
  /// In en, this message translates to:
  /// **'How Deni checked this'**
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

  /// No description provided for @sampleSyntheticBadge.
  ///
  /// In en, this message translates to:
  /// **'Sample app'**
  String get sampleSyntheticBadge;

  /// No description provided for @permissionInspectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone permissions checked'**
  String get permissionInspectionTitle;

  /// No description provided for @addAppPrivacyPolicyBtn.
  ///
  /// In en, this message translates to:
  /// **'Add this app\'s privacy policy'**
  String get addAppPrivacyPolicyBtn;

  /// No description provided for @snapshotDigestLabel.
  ///
  /// In en, this message translates to:
  /// **'Document fingerprint'**
  String get snapshotDigestLabel;

  /// No description provided for @snapshotDigestExplanation.
  ///
  /// In en, this message translates to:
  /// **'A unique code that helps verify this is the exact text Enprive checked. If even one letter changes, this code changes too.'**
  String get snapshotDigestExplanation;

  /// No description provided for @copyDigestBtn.
  ///
  /// In en, this message translates to:
  /// **'Copy fingerprint'**
  String get copyDigestBtn;

  /// No description provided for @digestCopiedMsg.
  ///
  /// In en, this message translates to:
  /// **'Document fingerprint copied'**
  String get digestCopiedMsg;

  /// No description provided for @permissionGrantedBadge.
  ///
  /// In en, this message translates to:
  /// **'Allowed on this phone'**
  String get permissionGrantedBadge;

  /// No description provided for @permissionNotGrantedBadge.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get permissionNotGrantedBadge;

  /// No description provided for @checkingPolicyWithCloudAi.
  ///
  /// In en, this message translates to:
  /// **'Checking policy with cloud AI.'**
  String get checkingPolicyWithCloudAi;

  /// No description provided for @preparingCloudAiStream.
  ///
  /// In en, this message translates to:
  /// **'Hiding personal details before cloud check…'**
  String get preparingCloudAiStream;

  /// No description provided for @cancellingAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get cancellingAnalysis;

  /// No description provided for @analysisCancelledNotice.
  ///
  /// In en, this message translates to:
  /// **'Review cancelled.'**
  String get analysisCancelledNotice;

  /// No description provided for @cloudTimedOutNotice.
  ///
  /// In en, this message translates to:
  /// **'Cloud AI timed out before responding. No automatic retry was sent.'**
  String get cloudTimedOutNotice;

  /// No description provided for @cloudFallbackBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud unavailable: checked on this phone'**
  String get cloudFallbackBannerTitle;

  /// No description provided for @cloudFallbackBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Cloud analysis was unavailable, so Enprive checked this policy directly on your phone.'**
  String get cloudFallbackBannerBody;

  /// Filter chip showing all launchable installed apps
  ///
  /// In en, this message translates to:
  /// **'All apps'**
  String get appPickerFilterAll;

  /// Filter chip showing user-downloaded apps
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get appPickerFilterDownloaded;

  /// Filter chip showing pre-installed system apps
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appPickerFilterSystem;

  /// Section heading for up to three recently checked installed apps
  ///
  /// In en, this message translates to:
  /// **'Recently checked'**
  String get appPickerRecentlyChecked;

  /// Neutral status indicator when a policy review receipt is saved for this app
  ///
  /// In en, this message translates to:
  /// **'Policy review saved'**
  String get appPickerStatusPolicySaved;

  /// Neutral status indicator when only device permissions were inspected and saved
  ///
  /// In en, this message translates to:
  /// **'Permissions checked'**
  String get appPickerStatusPermissionsInspected;

  /// Neutral status indicator when no saved receipt exists for this app
  ///
  /// In en, this message translates to:
  /// **'Not reviewed'**
  String get appPickerStatusNotReviewed;

  /// Search input placeholder in the installed app picker
  ///
  /// In en, this message translates to:
  /// **'Search by app name or App ID…'**
  String get appPickerSearchHint;

  /// Title shown when Android reports no launchable installed applications
  ///
  /// In en, this message translates to:
  /// **'No installed apps available'**
  String get appPickerEmptyInstalledTitle;

  /// Body shown when no launchable apps are available on the device
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any apps to check on this phone.'**
  String get appPickerEmptyInstalledBody;

  /// Segmented mode label for local document import (PDF, TXT, DOCX)
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get intakeModeDocument;

  /// Primary action button label in Paste text mode of the unified intake sheet
  ///
  /// In en, this message translates to:
  /// **'Check policy text'**
  String get intakeActionInspectText;

  /// Primary action button label in Public URL mode of the unified intake sheet
  ///
  /// In en, this message translates to:
  /// **'Open & check policy'**
  String get intakeActionFetchUrl;

  /// Primary action button label in Document mode of the unified intake sheet
  ///
  /// In en, this message translates to:
  /// **'Choose PDF, TXT, or DOCX'**
  String get intakeActionChooseDocument;

  /// Primary action button label when replacing an expired incoming document share
  ///
  /// In en, this message translates to:
  /// **'Choose replacement document'**
  String get intakeActionReplaceDocument;

  /// Primary action button label while a URL fetch or document extraction is active
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get intakeWorkingLabel;

  /// Secondary button label cancelling an active public URL fetch
  ///
  /// In en, this message translates to:
  /// **'Cancel fetch'**
  String get intakeCancelFetch;

  /// Placeholder hint for the public privacy policy URL input field
  ///
  /// In en, this message translates to:
  /// **'https://example.com/privacy-policy'**
  String get intakeUrlHint;

  /// Disclosure clarifying direct public URL retrieval and non-ownership
  ///
  /// In en, this message translates to:
  /// **'Loads this public web page directly. Adding a link here does not prove app ownership.'**
  String get intakeUrlDisclosure;

  /// Privacy note beneath the policy text input box
  ///
  /// In en, this message translates to:
  /// **'Checked locally on this phone first. Nothing is uploaded without your permission.'**
  String get intakePasteLocalNote;

  /// Title of the local document import information card
  ///
  /// In en, this message translates to:
  /// **'Import PDF, TXT, or DOCX policy file'**
  String get intakeDocumentCardTitle;

  /// Description of strictly local document extraction and size limit
  ///
  /// In en, this message translates to:
  /// **'We read the text right on your phone (up to 10 MB). Your file is never uploaded.'**
  String get intakeDocumentCardBody;

  /// Optional action prompt allowing the user to pair an installed app during policy-first intake
  ///
  /// In en, this message translates to:
  /// **'Compare with an installed app (optional)'**
  String get intakeCompareWithAppPrompt;

  /// Privacy note explaining that optional installed app comparison remains on-device
  ///
  /// In en, this message translates to:
  /// **'Runs locally on this phone. App lists never leave your device.'**
  String get intakeCompareWithAppHint;

  /// Action label to change the optionally selected installed app
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get intakeCompareWithAppChange;

  /// Action label to remove the optionally selected installed app
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get intakeCompareWithAppRemove;

  /// Label identifying the locked Android application in app-first or Companion intake
  ///
  /// In en, this message translates to:
  /// **'Selected app'**
  String get intakeLockedAppContextLabel;

  /// Optional action opening the selected app listing on Google Play Store to look up its policy link
  ///
  /// In en, this message translates to:
  /// **'Find policy link on Play Store'**
  String get intakeFindPolicyOnPlayStore;

  /// Clarification beneath the Play Store convenience link button
  ///
  /// In en, this message translates to:
  /// **'Opens the Play Store so you can copy the app\'s privacy policy link. Enprive never copies it automatically or assumes the link is official.'**
  String get intakePlayStoreHelperNote;

  /// Inline message shown if launching Play Store fails or is unavailable
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Play Store on this device. Paste the policy URL or text manually instead.'**
  String get intakePlayStoreUnavailable;

  /// Inline recovery action switching the intake sheet to Paste text mode
  ///
  /// In en, this message translates to:
  /// **'Paste text instead'**
  String get intakeRecoverySwitchPaste;

  /// Inline recovery action switching the intake sheet to Document import mode
  ///
  /// In en, this message translates to:
  /// **'Import document'**
  String get intakeRecoverySwitchDocument;

  /// Inline recovery action retrying the failed URL retrieval
  ///
  /// In en, this message translates to:
  /// **'Retry fetch'**
  String get intakeRecoveryRetryUrl;

  /// Explanation shown when an incoming Android document share failed and its content URI cannot be reused
  ///
  /// In en, this message translates to:
  /// **'The originally shared file link can no longer be reopened. Choose a replacement PDF, TXT, or DOCX file or paste the policy text manually.'**
  String get intakeExpiredDocumentShareNotice;

  /// Heading for the non-blocking app-policy association warning banner
  ///
  /// In en, this message translates to:
  /// **'App-policy identity check'**
  String get intakeAssociationWarningTitle;

  /// Action accepting an unmatched or ambiguous app-policy association warning
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get intakeAssociationContinueAnyway;

  /// Action to pick a different installed app after an association mismatch or ambiguity
  ///
  /// In en, this message translates to:
  /// **'Change selected app'**
  String get intakeAssociationChangeApp;

  /// Action to drop the optional app association and inspect only the supplied policy
  ///
  /// In en, this message translates to:
  /// **'Check policy without app'**
  String get intakeAssociationInspectWithoutApp;

  /// Accessibility label for the Paste text / Policy link / Document mode selector
  ///
  /// In en, this message translates to:
  /// **'Policy input method'**
  String get intakeModeSelectorSemanticLabel;

  /// Tooltip and accessibility label for clearing the installed app picker search query
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get tooltipClearSearch;

  /// Inline recovery action focusing the URL input field after a blocked or invalid URL failure
  ///
  /// In en, this message translates to:
  /// **'Edit URL'**
  String get intakeRecoveryEditUrl;

  /// Section card heading for Deni's evidence-grounded plain-language summary alongside audio playback
  ///
  /// In en, this message translates to:
  /// **'Deni’s plain-language summary'**
  String get voiceSummaryTitle;

  /// Status text shown while Deni generates a plain-language summary on-device or in the cloud
  ///
  /// In en, this message translates to:
  /// **'Preparing plain-language summary…'**
  String get voiceSummaryPreparing;

  /// Status text shown while Gemini TTS synthesizes speech after user consent
  ///
  /// In en, this message translates to:
  /// **'Preparing Deni’s expressive voice…'**
  String get voiceSynthesizingExpressive;

  /// Accessible button label to read Deni's plain-language summary aloud using this phone's offline voice
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get voiceBtnListenOffline;

  /// Accessible button label to stop active Deni voice playback or cancel speech synthesis
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get voiceBtnStop;

  /// Accessible button label to request Deni's expressive Gemini voice after explicit consent
  ///
  /// In en, this message translates to:
  /// **'Expressive voice'**
  String get voiceBtnExpressiveCloud;

  /// Optional action allowing the user to enhance the offline plain-language summary via CloudConsentSheet
  ///
  /// In en, this message translates to:
  /// **'Summarize with Cloud AI'**
  String get voiceBtnSummarizeCloud;

  /// Badge identifying playback via Firebase AI Logic Gemini TTS prebuilt voice
  ///
  /// In en, this message translates to:
  /// **'Expressive cloud voice'**
  String get voiceBadgeExpressive;

  /// Badge identifying playback via local Android TextToSpeech
  ///
  /// In en, this message translates to:
  /// **'Phone voice · Offline'**
  String get voiceBadgeDeviceOffline;

  /// Button label on a summary point to expand or collapse its linked verbatim policy excerpt
  ///
  /// In en, this message translates to:
  /// **'Source quote'**
  String get voiceViewSourceQuote;

  /// Button label to collapse an expanded verbatim policy excerpt inside Deni's summary card
  ///
  /// In en, this message translates to:
  /// **'Hide quote'**
  String get voiceHideSourceQuote;

  /// Button label inside an expanded summary evidence quote to open full WhyThisFindingSheet details
  ///
  /// In en, this message translates to:
  /// **'Inspect finding'**
  String get voiceInspectFinding;

  /// CloudConsentSheet title when the user requests expressive Gemini TTS playback
  ///
  /// In en, this message translates to:
  /// **'Choose Deni’s voice'**
  String get voiceConsentTitle;

  /// Disclosure text inside CloudConsentSheet before requesting Gemini TTS speech synthesis
  ///
  /// In en, this message translates to:
  /// **'To read this summary aloud with Deni’s expressive cloud voice, Enprive will send only the summary text shown above (with personal details hidden) for this one request. Your apps and phone permissions are never sent.'**
  String get voiceConsentDisclosure;

  /// Primary consent button approving one Gemini TTS request
  ///
  /// In en, this message translates to:
  /// **'Use expressive voice once'**
  String get voiceConsentPrimaryAction;

  /// Secondary button choosing local offline Android TextToSpeech without cloud upload
  ///
  /// In en, this message translates to:
  /// **'Speak on this phone'**
  String get voiceConsentSecondaryAction;

  /// Category label on the preview card inside CloudConsentSheet for voice playback
  ///
  /// In en, this message translates to:
  /// **'Exact spoken script'**
  String get voiceConsentPayloadLabel;

  /// CloudConsentSheet title when the user opts into cloud plain-language summarization
  ///
  /// In en, this message translates to:
  /// **'Summarize findings with Cloud AI'**
  String get voiceSummaryConsentTitle;

  /// Disclosure text inside CloudConsentSheet before requesting cloud plain-language summarization
  ///
  /// In en, this message translates to:
  /// **'To summarize these policy quotes in plain language in the cloud, Enprive will send only the text shown above (with personal details hidden) for this one request. Your apps and phone permissions are never sent.'**
  String get voiceSummaryConsentDisclosure;

  /// Honest notice shown when consented Gemini TTS fails or times out and falls back to local Android TTS
  ///
  /// In en, this message translates to:
  /// **'Expressive cloud voice was unavailable: using this phone\'s offline voice instead.'**
  String get voiceFallbackDeviceNotice;

  /// Honest notice shown when neither cloud TTS nor local Android TTS can speak the summary
  ///
  /// In en, this message translates to:
  /// **'Voice playback is unavailable for this language on this phone. You can read Deni’s summary above.'**
  String get voiceUnavailableNotice;

  /// Accessibility tooltip for starting voice playback of Deni's plain-language summary
  ///
  /// In en, this message translates to:
  /// **'Listen to Deni’s plain-language summary'**
  String get voiceTooltipReadSummary;

  /// Accessibility tooltip for stopping voice playback
  ///
  /// In en, this message translates to:
  /// **'Stop reading aloud'**
  String get voiceTooltipStopReading;

  /// Small label under the finding count in the center of the evidence ring; a count of evidence, never a score
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{finding} other{findings}}'**
  String findingsCountUnit(int count);

  /// Start of the evidence ring TalkBack label, followed by the per-category breakdown
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No findings} =1{1 finding} other{{count} findings}}'**
  String findingsCountPhrase(int count);

  /// Evidence summary: how many findings are backed by an exact quote matched in the policy text
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 quote verified in policy} other{{count} quotes verified in policy}}'**
  String quotesVerifiedCount(int count);

  /// Evidence summary: how many findings come from Android observations on this phone
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 observed on this phone} other{{count} observed on this phone}}'**
  String observedOnPhoneCount(int count);

  /// Neutral factual chip for an Android permission that is currently allowed; not an approval
  ///
  /// In en, this message translates to:
  /// **'Allowed on this phone'**
  String get permissionAllowedOnPhone;

  /// Neutral factual chip for an Android permission that is currently not allowed
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get permissionNotAllowedOnPhone;

  /// Neutral chip for a synthetic sample permission marked allowed; never claims to describe this phone
  ///
  /// In en, this message translates to:
  /// **'Allowed in sample'**
  String get permissionAllowedInSample;

  /// Neutral chip for a synthetic sample permission marked not allowed
  ///
  /// In en, this message translates to:
  /// **'Not allowed in sample'**
  String get permissionNotAllowedInSample;

  /// Chip on a permission row whose permission is not mentioned in the reviewed policy
  ///
  /// In en, this message translates to:
  /// **'Not in policy'**
  String get permissionMismatchChip;

  /// Toggle that reveals the saved analysis steps of a review
  ///
  /// In en, this message translates to:
  /// **'How Enprive checked this'**
  String get howEnpriveCheckedThis;

  /// Toggle that hides the saved analysis steps of a review
  ///
  /// In en, this message translates to:
  /// **'Hide how Enprive checked this'**
  String get hideHowEnpriveChecked;

  /// Heading of the summary at the top of the cloud consent sheet
  ///
  /// In en, this message translates to:
  /// **'What would be sent'**
  String get consentWhatWouldBeSent;

  /// Consent summary line describing exactly what is sent and how often
  ///
  /// In en, this message translates to:
  /// **'Only the text in the preview leaves this phone, for this one request.'**
  String get consentSentScope;

  /// Consent summary line counting the personal details hidden before anything is sent
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No personal details were found to hide.} =1{1 personal detail is hidden first.} other{{count} personal details are hidden first.}}'**
  String consentMaskedCount(int count);

  /// Consent summary line naming what never leaves the phone
  ///
  /// In en, this message translates to:
  /// **'Your app list and phone permissions stay on this phone.'**
  String get consentStaysOnPhone;

  /// Snackbar after a saved receipt is deleted; paired with an Undo action
  ///
  /// In en, this message translates to:
  /// **'Deleted {title}'**
  String receiptDeletedSnack(String title);

  /// Snackbar action that restores a just-deleted receipt
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get btnUndo;

  /// Last onboarding screen promise tile title about hiding personal details
  ///
  /// In en, this message translates to:
  /// **'Personal details hidden'**
  String get readinessPromiseMaskedTitle;

  /// Last onboarding screen promise tile line; plain words, no technical jargon
  ///
  /// In en, this message translates to:
  /// **'If you choose cloud, names, emails and numbers are hidden first.'**
  String get readinessPromiseMaskedLine;

  /// App bar title of the finding detail page
  ///
  /// In en, this message translates to:
  /// **'Finding {index} of {total}'**
  String findingDetailTitle(int index, int total);

  /// Short state chip on a finding row that deserves a human look
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get findingReviewChip;

  /// Button on the finding detail page that opens Deni's explanation for this finding
  ///
  /// In en, this message translates to:
  /// **'Ask Deni about this'**
  String get askDeniAboutThis;

  /// Section heading on the finding detail page
  ///
  /// In en, this message translates to:
  /// **'What the policy says'**
  String get labelWhatPolicySays;

  /// Section heading on the finding detail page
  ///
  /// In en, this message translates to:
  /// **'What your phone shows'**
  String get labelWhatAndroidReports;

  /// Tooltip for the icon button that opens the reviewed policy snapshot
  ///
  /// In en, this message translates to:
  /// **'Reviewed source'**
  String get sourceButtonTooltip;

  /// Primary action button on a policy-first review to link an installed app and compare its phone permissions
  ///
  /// In en, this message translates to:
  /// **'Link an installed app'**
  String get linkInstalledAppBtn;

  /// Heading of the card inviting the user to link an installed app to a policy-first review
  ///
  /// In en, this message translates to:
  /// **'Compare with an app on this phone'**
  String get linkInstalledAppCardTitle;

  /// Plain-language explanation of linking an installed app after a policy-first review
  ///
  /// In en, this message translates to:
  /// **'Pick an installed app to compare its phone permissions with this policy in the same review. Your app list stays on this phone.'**
  String get linkInstalledAppCardBody;

  /// Bottom sheet title when picking an installed app to link to an open policy review
  ///
  /// In en, this message translates to:
  /// **'Link an installed app'**
  String get linkAppPickerTitle;

  /// Bottom sheet title when switching the installed app linked to an open policy review
  ///
  /// In en, this message translates to:
  /// **'Change linked app'**
  String get changeLinkedAppPickerTitle;

  /// Subtitle explaining local-only installed app linking inside the app picker
  ///
  /// In en, this message translates to:
  /// **'Pick an app on this phone to compare its permissions with this policy. Your app list never leaves this phone.'**
  String get linkAppPickerSubtitle;

  /// Short neutral badge marking the app currently linked to the open review
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linkedAppCurrentlySelectedBadge;

  /// Label above the currently linked app identity on a combined review
  ///
  /// In en, this message translates to:
  /// **'Linked app on this phone'**
  String get linkedAppSectionLabel;

  /// Action button to switch the installed app linked to an open review
  ///
  /// In en, this message translates to:
  /// **'Change app'**
  String get btnChangeLinkedApp;

  /// Action button to remove the linked installed app and return to the policy-only review
  ///
  /// In en, this message translates to:
  /// **'Unlink app'**
  String get btnUnlinkApp;

  /// Action button to attach or replace the privacy policy for the currently linked app
  ///
  /// In en, this message translates to:
  /// **'Attach updated privacy policy'**
  String get btnUpdatePrivacyPolicy;

  /// Confirmation snackbar after linking an installed app to a policy review
  ///
  /// In en, this message translates to:
  /// **'Linked {appName}. Permissions compared on this phone.'**
  String linkedAppSnack(String appName);

  /// Confirmation snackbar when a newly linked app triggers a mismatch or ambiguity notice
  ///
  /// In en, this message translates to:
  /// **'Linked {appName}. Check the app-policy match note below.'**
  String linkedAppCheckMatchSnack(String appName);

  /// Snackbar when re-selecting the already linked app whose permissions have not changed
  ///
  /// In en, this message translates to:
  /// **'{appName} is already linked with the same permissions.'**
  String linkedAppUnchangedSnack(String appName);

  /// Confirmation snackbar after unlinking an installed app from an open review
  ///
  /// In en, this message translates to:
  /// **'Unlinked {appName}. Showing the policy review only.'**
  String unlinkedAppSnack(String appName);

  /// Plain-language heading when the linked app's package ID appears in the policy text or URL
  ///
  /// In en, this message translates to:
  /// **'App ID found in this policy'**
  String get associationStatusPackageTitle;

  /// Plain-language non-ownership explanation when the linked app's package ID is mentioned
  ///
  /// In en, this message translates to:
  /// **'This policy mentions {packageName}. That suggests it may describe {appName}, though text alone does not prove who owns this policy.'**
  String associationStatusPackageBody(String packageName, String appName);

  /// Plain-language heading when the linked app's display name appears in the policy text
  ///
  /// In en, this message translates to:
  /// **'App name found in this policy'**
  String get associationStatusNameTitle;

  /// Plain-language non-ownership explanation when the linked app's name is mentioned
  ///
  /// In en, this message translates to:
  /// **'This policy mentions {appName}. That suggests it may describe this app, though a name match does not prove who owns this policy.'**
  String associationStatusNameBody(String appName);

  /// Plain-language heading when the policy does not mention the linked app name or ID and has no conflicting IDs
  ///
  /// In en, this message translates to:
  /// **'Linked by you for comparison'**
  String get associationStatusUnverifiedTitle;

  /// Plain-language explanation when the user linked an app whose name and ID do not appear in the policy
  ///
  /// In en, this message translates to:
  /// **'This policy does not name {appName} or its App ID. Double-check that it is the right policy: linking it here does not prove ownership.'**
  String associationStatusUnverifiedBody(String appName);

  /// Plain-language explanation when only the URL domain matches the linked app name
  ///
  /// In en, this message translates to:
  /// **'The web address includes words from {appName}, but the policy text itself does not name this app. Double-check that it is the right policy: linking it here does not prove ownership.'**
  String associationStatusUnverifiedUrlHostBody(String appName);

  /// Plain-language warning heading when the policy mentions a different app ID than the linked app
  ///
  /// In en, this message translates to:
  /// **'This policy may be for a different app'**
  String get associationStatusUnmatchedTitle;

  /// Plain-language warning explaining a policy-to-app mismatch
  ///
  /// In en, this message translates to:
  /// **'This policy does not mention {appName}. Instead, it names {otherApps}. Check that you linked the right app or opened the right policy.'**
  String associationStatusUnmatchedBody(String appName, String otherApps);

  /// Plain-language warning heading when the policy mentions both the linked app and other app IDs
  ///
  /// In en, this message translates to:
  /// **'This policy mentions more than one app'**
  String get associationStatusAmbiguousConflictTitle;

  /// Plain-language warning explaining conflicting app IDs in the same policy
  ///
  /// In en, this message translates to:
  /// **'This policy mentions {appName} alongside {otherApps}. It may cover several apps or a shared company policy, so check that it applies here.'**
  String associationStatusAmbiguousConflictBody(
    String appName,
    String otherApps,
  );

  /// Plain-language warning heading when multiple installed apps share the name mentioned in the policy
  ///
  /// In en, this message translates to:
  /// **'More than one app on this phone has a similar name'**
  String get associationStatusAmbiguousPeerTitle;

  /// Plain-language warning explaining peer display-name ambiguity on the user's phone
  ///
  /// In en, this message translates to:
  /// **'This policy mentions {appName} without listing one exact App ID, and other apps on your phone ({otherApps}) have a similar name. Make sure you linked the right one.'**
  String associationStatusAmbiguousPeerBody(String appName, String otherApps);

  /// Fallback plain-language warning for an ambiguous app-policy match
  ///
  /// In en, this message translates to:
  /// **'This policy could refer to more than one app. Double-check that it applies to {appName}.'**
  String associationStatusAmbiguousGenericBody(String appName);

  /// Non-ownership disclaimer shown on app-policy identity notices
  ///
  /// In en, this message translates to:
  /// **'Text and web links never prove who published or owns a policy.'**
  String get associationOwnershipLimitation;

  /// Plain-language non-accusatory summary when one or more phone permissions are not mentioned in the policy
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 permission on this phone is not clearly mentioned in this policy. A mismatch is a prompt to look closer, not proof of wrongdoing.} other{{count} permissions on this phone are not clearly mentioned in this policy. A mismatch is a prompt to look closer, not proof of wrongdoing.}}'**
  String permissionComparisonMismatchNote(int count);

  /// Plain-language summary when no checked phone permissions contradict the policy
  ///
  /// In en, this message translates to:
  /// **'None of the checked permissions on this phone contradict this policy. Permissions alone cannot show what an app actually sends.'**
  String get permissionComparisonNoMismatchNote;

  /// Calibrated limitation disclaimer below the permission comparison list
  ///
  /// In en, this message translates to:
  /// **'Your phone shows permission settings on this phone only. This comparison is a prompt to look closer, never proof of wrongdoing or that data was sent.'**
  String get permissionComparisonLimitationNote;

  /// Neutral factual chip when a permission is mentioned in the policy but not requested by the installed app
  ///
  /// In en, this message translates to:
  /// **'Not requested by app'**
  String get permissionNotRequestedOnPhone;

  /// Neutral factual chip when a permission is mentioned in a sample policy but not in the sample fixture
  ///
  /// In en, this message translates to:
  /// **'Not requested in sample'**
  String get permissionNotRequestedInSample;

  /// Heading when a linked installed app has no permissions in the checked sensitive categories
  ///
  /// In en, this message translates to:
  /// **'No sensitive permissions matched in this check'**
  String get permissionsEmptyComparisonTitle;

  /// Plain-language summary when a linked installed app declares zero sensitive catalog permissions
  ///
  /// In en, this message translates to:
  /// **'Your phone lists {requestedCount} permissions ({grantedCount} allowed) for {appName}, with none in the sensitive categories checked here (location, camera, microphone, contacts, photos, or ad ID).'**
  String permissionsEmptyComparisonBody(
    int requestedCount,
    int grantedCount,
    String appName,
  );

  /// Plain source label when inspecting an installed app on this phone
  ///
  /// In en, this message translates to:
  /// **'Checked on this phone'**
  String get sourceDeviceInspection;

  /// Plain-language label prefixing an Android package name (e.g. App ID: com.example.app)
  ///
  /// In en, this message translates to:
  /// **'App ID'**
  String get appIdPrefix;

  /// Title of the collapsible expander hiding technical verification details
  ///
  /// In en, this message translates to:
  /// **'Advanced details'**
  String get advancedDetailsTitle;

  /// Plain one-line explanation above the Advanced details expander
  ///
  /// In en, this message translates to:
  /// **'Technical details that verify when and where this policy text was checked.'**
  String get advancedDetailsSubtitle;

  /// Plain heading for the policy source card on the review result screen
  ///
  /// In en, this message translates to:
  /// **'Where this policy came from'**
  String get sourceSectionTitle;

  /// Plain category label on the cloud consent preview card
  ///
  /// In en, this message translates to:
  /// **'Exact text to be sent'**
  String get cloudPayloadLabel;

  /// Plain badge on the cloud consent preview card when no personal details were found
  ///
  /// In en, this message translates to:
  /// **'No personal details found'**
  String get cloudPayloadNoPiiLabel;

  /// Plain badge on the cloud consent preview card showing how many personal details were hidden
  ///
  /// In en, this message translates to:
  /// **'Hidden ({count})'**
  String cloudPayloadHiddenCount(int count);

  /// Plain provenance pill for an on-device AI plain-language summary
  ///
  /// In en, this message translates to:
  /// **'Summarized on this phone'**
  String get summarySourceOnDevice;

  /// Plain provenance pill for a consented cloud AI plain-language summary
  ///
  /// In en, this message translates to:
  /// **'Summarized in the cloud'**
  String get summarySourceInCloud;

  /// Plain provenance pill for a built-in offline plain-language summary
  ///
  /// In en, this message translates to:
  /// **'Summarized offline on this phone'**
  String get summarySourceOffline;

  /// Plain provenance pill when the summary source is unknown
  ///
  /// In en, this message translates to:
  /// **'Summary source unknown'**
  String get summarySourceUnknown;

  /// Plain suffix clarifying that an observation comes from phone permission settings rather than the privacy policy
  ///
  /// In en, this message translates to:
  /// **'From your phone settings, not the policy'**
  String get notFromPolicySuffix;

  /// Plain suffix clarifying that a sample permission comes from a built-in example rather than the privacy policy
  ///
  /// In en, this message translates to:
  /// **'Example only, not from the policy'**
  String get sampleNotFromPolicySuffix;

  /// Subtitle under the Learn tab heading
  ///
  /// In en, this message translates to:
  /// **'Offline privacy guides & diagrams'**
  String get learnHeaderSubtitle;

  /// Filter chip showing all Learn lessons
  ///
  /// In en, this message translates to:
  /// **'All topics'**
  String get learnFilterAll;

  /// Filter chip for privacy policy lessons
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get learnFilterPolicies;

  /// Filter chip for Android permission lessons
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get learnFilterPermissions;

  /// Filter chip for ads, analytics, and third-party data sharing lessons
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get learnFilterSharing;

  /// Filter chip for lessons explaining Enprive's evidence layers and categories
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get learnFilterEvidence;

  /// Short step count stat displayed on each Learn folder card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String learnLessonStepCount(int count);

  /// Heading on the Learn bottom deck card
  ///
  /// In en, this message translates to:
  /// **'Practice privacy habits locally'**
  String get learnDeckTitle;

  /// Privacy assurance body on the Learn bottom deck card
  ///
  /// In en, this message translates to:
  /// **'100% offline lessons with diagrams. Your installed apps and receipts never enter Learn.'**
  String get learnDeckBody;

  /// Button label on the Learn bottom deck bridging to the Check tab
  ///
  /// In en, this message translates to:
  /// **'Apply it · Check an app'**
  String get learnDeckCheckBtn;

  /// Primary bridge CTA at the bottom of each Learn lesson sheet
  ///
  /// In en, this message translates to:
  /// **'Check an app on this phone'**
  String get learnCheckAppBridgeBtn;

  /// Section heading above the vector diagram in a Learn lesson
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get learnSectionDiagram;

  /// Section heading above the numbered steps in a Learn lesson
  ///
  /// In en, this message translates to:
  /// **'Key steps'**
  String get learnSectionSteps;

  /// Section heading above the one-question quick check in a Learn lesson
  ///
  /// In en, this message translates to:
  /// **'Quick check'**
  String get learnSectionQuickCheck;

  /// Accessibility label for the offline Listen button inside a Learn lesson
  ///
  /// In en, this message translates to:
  /// **'Read this lesson aloud offline'**
  String get learnTooltipListenLesson;

  /// Accessibility label for the Stop button while a Learn lesson is being read aloud
  ///
  /// In en, this message translates to:
  /// **'Stop reading lesson aloud'**
  String get learnTooltipStopLesson;

  /// Calm inline notice when local Android TTS cannot speak the lesson in the current locale
  ///
  /// In en, this message translates to:
  /// **'Offline voice playback is not available for this language on this phone. You can read the lesson below.'**
  String get learnVoiceUnavailableNotice;

  /// Status label shown alongside an icon when the user chooses the right quick-check option
  ///
  /// In en, this message translates to:
  /// **'Right answer'**
  String get learnQuickCheckCorrectBadge;

  /// Gentle non-judgmental status label when the user chooses a distractor quick-check option
  ///
  /// In en, this message translates to:
  /// **'Try another choice'**
  String get learnQuickCheckTryAgainBadge;

  /// Progress indicator showing which lesson is currently open out of the total lessons
  ///
  /// In en, this message translates to:
  /// **'Lesson {current} of {total}'**
  String learnLessonProgress(int current, int total);

  /// Tooltip and accessibility label for the back button on a full-screen Learn lesson
  ///
  /// In en, this message translates to:
  /// **'Back to Learn'**
  String get learnBackTooltip;

  /// Direction label on the previous-lesson navigation button at the end of a lesson
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get learnPreviousLesson;

  /// Direction label on the next-lesson navigation button at the end of a lesson
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get learnNextLesson;

  /// Accessibility label for navigating to the previous Learn lesson
  ///
  /// In en, this message translates to:
  /// **'Previous lesson: {title}'**
  String learnLessonNavPreviousSemantic(String title);

  /// Accessibility label for navigating to the next Learn lesson
  ///
  /// In en, this message translates to:
  /// **'Next lesson: {title}'**
  String learnLessonNavNextSemantic(String title);

  /// Short folder title for Lesson 1 on the Learn home screen
  ///
  /// In en, this message translates to:
  /// **'Privacy policies'**
  String get learnPolicyFolderTitle;

  /// Full lesson title for Lesson 1
  ///
  /// In en, this message translates to:
  /// **'What a privacy policy is (and what it can\'t prove)'**
  String get learnPolicyTitle;

  /// Short subtitle for Lesson 1
  ///
  /// In en, this message translates to:
  /// **'What developers promise vs. what stays unknown'**
  String get learnPolicySubtitle;

  /// Plain-language introduction for Lesson 1
  ///
  /// In en, this message translates to:
  /// **'A privacy policy is a developer\'s public statement explaining what data an app says it collects, why it uses it, who may receive it, and what choices families have.'**
  String get learnPolicyIntro;

  /// Step 1 of Lesson 1
  ///
  /// In en, this message translates to:
  /// **'Look for four basics: what data is collected, why the app needs it, who else may get it, and how you can ask for deletion.'**
  String get learnPolicyStep1;

  /// Step 2 of Lesson 1 referencing verified UNSW 2026 findings in plain words
  ///
  /// In en, this message translates to:
  /// **'Confusing wording is common. A 2026 study of children\'s learning apps found that very few policies were easy to read, and most apps did not fully match what their policies stated.'**
  String get learnPolicyStep2;

  /// Step 3 of Lesson 1
  ///
  /// In en, this message translates to:
  /// **'A privacy policy only shows what a developer says on paper. Reading it cannot prove what the app actually sends over the internet.'**
  String get learnPolicyStep3;

  /// Step 4 of Lesson 1
  ///
  /// In en, this message translates to:
  /// **'Comparing a policy with your phone\'s permission settings gives a clearer view, while remembering that Enprive cannot see live internet traffic.'**
  String get learnPolicyStep4;

  /// Quick check question for Lesson 1
  ///
  /// In en, this message translates to:
  /// **'What does reading an app\'s privacy policy prove?'**
  String get learnPolicyQuickQuestion;

  /// First quick check option for Lesson 1
  ///
  /// In en, this message translates to:
  /// **'That the app never sends data to anyone'**
  String get learnPolicyQuickOption1;

  /// Correct second quick check option for Lesson 1
  ///
  /// In en, this message translates to:
  /// **'What the developer says: not what the app actually sends'**
  String get learnPolicyQuickOption2;

  /// Third quick check option for Lesson 1
  ///
  /// In en, this message translates to:
  /// **'That the phone\'s camera and mic are switched off'**
  String get learnPolicyQuickOption3;

  /// Feedback shown when the user selects the right answer in Lesson 1
  ///
  /// In en, this message translates to:
  /// **'That\'s right. A policy is the developer\'s public statement, not proof of what the app actually sends over the internet.'**
  String get learnPolicyQuickCorrectFeedback;

  /// Feedback shown when the user selects another option in Lesson 1
  ///
  /// In en, this message translates to:
  /// **'Not quite. Reading a policy only tells you what the developer says: it cannot prove internet activity or turn off phone permissions.'**
  String get learnPolicyQuickTryAgainFeedback;

  /// First node title in the Lesson 1 Policy Limit diagram
  ///
  /// In en, this message translates to:
  /// **'Policy says'**
  String get learnDiagramPolicySaysTitle;

  /// First node body in the Lesson 1 Policy Limit diagram
  ///
  /// In en, this message translates to:
  /// **'Developer\'s written promise'**
  String get learnDiagramPolicySaysBody;

  /// Illustrative sample quote snippet inside the Lesson 1 diagram
  ///
  /// In en, this message translates to:
  /// **'\"We may share data with partners…\"'**
  String get learnDiagramPolicyQuoteSample;

  /// Second node title in the Lesson 1 Policy Limit diagram
  ///
  /// In en, this message translates to:
  /// **'Phone shows'**
  String get learnDiagramPhoneShowsTitle;

  /// Second node body in the Lesson 1 Policy Limit diagram
  ///
  /// In en, this message translates to:
  /// **'Permissions allowed here'**
  String get learnDiagramPhoneShowsBody;

  /// Third node title in the Lesson 1 Policy Limit diagram
  ///
  /// In en, this message translates to:
  /// **'Still unknown'**
  String get learnDiagramUnknownTitle;

  /// Third node body in the Lesson 1 Policy Limit diagram
  ///
  /// In en, this message translates to:
  /// **'Live internet traffic Enprive can\'t see'**
  String get learnDiagramUnknownBody;

  /// Bottom takeaway caption in the Lesson 1 diagram
  ///
  /// In en, this message translates to:
  /// **'A policy is a promise, not proof of behavior'**
  String get learnDiagramPolicyCaption;

  /// Full TalkBack description for the Lesson 1 Policy Limit diagram
  ///
  /// In en, this message translates to:
  /// **'Diagram comparing three parts of app privacy. First, Policy says: the developer\'s written promise. Second, Phone shows: the permissions allowed on this phone. Third, inside a dashed boundary, Still unknown: live internet traffic that Enprive cannot see. A privacy policy is a promise, not proof of behavior.'**
  String get learnDiagramPolicySemantic;

  /// Short folder title for Lesson 2 on the Learn home screen
  ///
  /// In en, this message translates to:
  /// **'Phone permissions'**
  String get learnPermissionsFolderTitle;

  /// Full lesson title for Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Android permissions explained'**
  String get learnPermissionsTitle;

  /// Short subtitle for Lesson 2
  ///
  /// In en, this message translates to:
  /// **'The four Android choices & where to review them'**
  String get learnPermissionsSubtitle;

  /// Plain-language introduction for Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Permissions are gates that control whether an app can reach sensors and data on your phone, such as the camera, microphone, location, photos, contacts, or notifications.'**
  String get learnPermissionsIntro;

  /// Step 1 of Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Ask whether the permission fits the feature: a math quiz or reading app rarely needs your location, contacts, or camera.'**
  String get learnPermissionsStep1;

  /// Step 2 of Lesson 2 explaining Android's four permission choices
  ///
  /// In en, this message translates to:
  /// **'Android offers up to four choices: Don\'t allow, Ask every time, Allow only while using the app, and All the time (for background location).'**
  String get learnPermissionsStep2;

  /// Step 3 of Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Start with the narrowest choice that lets the feature work, such as Ask every time or While using the app.'**
  String get learnPermissionsStep3;

  /// Step 4 of Lesson 2 explaining where to review recent permission use
  ///
  /// In en, this message translates to:
  /// **'Open Android Settings and check Privacy Dashboard to see which apps recently accessed Camera, Microphone, or Location.'**
  String get learnPermissionsStep4;

  /// Step 5 of Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Turn permissions off anytime in App Settings, or keep Pause app activity if unused on so Android removes old permissions automatically. An allowed permission shows capability, not proof that data was sent.'**
  String get learnPermissionsStep5;

  /// Quick check question for Lesson 2
  ///
  /// In en, this message translates to:
  /// **'A math practice app asks for your camera and you aren\'t sure why. What is the best first step?'**
  String get learnPermissionsQuickQuestion;

  /// Correct first quick check option for Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Tap Don\'t allow and see if the math exercises still work'**
  String get learnPermissionsQuickOption1;

  /// Second quick check option for Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Choose All the time so the popup doesn\'t come back'**
  String get learnPermissionsQuickOption2;

  /// Third quick check option for Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Assume the app has already uploaded photos'**
  String get learnPermissionsQuickOption3;

  /// Feedback shown when the user selects the right answer in Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Right. Tapping Don\'t allow lets you check if the app works without the camera, and you can change permissions anytime in Android Settings.'**
  String get learnPermissionsQuickCorrectFeedback;

  /// Feedback shown when the user selects another option in Lesson 2
  ///
  /// In en, this message translates to:
  /// **'Try a narrower choice first. Tap Don\'t allow to test if the feature still works, and remember an allowed permission shows capability, not proof of an upload.'**
  String get learnPermissionsQuickTryAgainFeedback;

  /// Heading inside the Lesson 2 Android Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'From narrowest to broadest access'**
  String get learnDiagramPermLadderTitle;

  /// Step 1 label in the Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'Don\'t allow'**
  String get learnDiagramPermDenyTitle;

  /// Step 1 detail in the Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'Blocked: app cannot use this sensor'**
  String get learnDiagramPermDenyDetail;

  /// Step 2 label in the Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'Ask every time'**
  String get learnDiagramPermAskTitle;

  /// Step 2 detail in the Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'One-time access when you tap allow'**
  String get learnDiagramPermAskDetail;

  /// Step 3 label in the Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'While using the app'**
  String get learnDiagramPermWhileUsingTitle;

  /// Step 3 detail in the Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'Only while the app is open on screen'**
  String get learnDiagramPermWhileUsingDetail;

  /// Step 4 label in the Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'All the time'**
  String get learnDiagramPermAllTimeTitle;

  /// Step 4 detail in the Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'Background access even when closed'**
  String get learnDiagramPermAllTimeDetail;

  /// Feature-fit prompt caption at the bottom of the Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'Does it fit? Math quiz + Camera = ask why'**
  String get learnDiagramPermFitNote;

  /// Full TalkBack description for the Lesson 2 Permissions Ladder diagram
  ///
  /// In en, this message translates to:
  /// **'Four-step Android permission ladder from narrowest to broadest access. Step 1, Don\'t allow: blocked, the app cannot use this sensor. Step 2, Ask every time: one-time access when you tap allow. Step 3, While using the app: access only while the app is open on screen. Step 4, All the time: background access even when closed, marked with a dashed border for extra caution. Bottom tip: Does it fit? A math quiz asking for the camera is a reason to ask why.'**
  String get learnDiagramPermSemantic;

  /// Short folder title for Lesson 3 on the Learn home screen
  ///
  /// In en, this message translates to:
  /// **'Ads & third parties'**
  String get learnSharingFolderTitle;

  /// Full lesson title for Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Who else gets data: ads, analytics & third parties'**
  String get learnSharingTitle;

  /// Short subtitle for Lesson 3
  ///
  /// In en, this message translates to:
  /// **'App maker vs. helpers, analytics & ad networks'**
  String get learnSharingSubtitle;

  /// Plain-language introduction for Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Many free apps connect to other companies behind the scenes. Knowing who receives information helps families tell the difference between running the app and tracking kids across apps.'**
  String get learnSharingIntro;

  /// Step 1 of Lesson 3
  ///
  /// In en, this message translates to:
  /// **'First party means the app maker itself: for example, saving homework progress or quiz scores so the app works.'**
  String get learnSharingStep1;

  /// Step 2 of Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Helper companies are third parties that handle behind-the-scenes jobs like cloud storage or crash reports so bugs get fixed.'**
  String get learnSharingStep2;

  /// Step 3 of Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Analytics tools measure how screens are used, while ad networks and data brokers may use an advertising ID to show targeted ads or profile activity across apps.'**
  String get learnSharingStep3;

  /// Step 4 of Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Watch for broad phrases like \'trusted partners\' or \'business purposes,\' and check whether a policy explains how to opt out of personalized ads.'**
  String get learnSharingStep4;

  /// Quick check question for Lesson 3
  ///
  /// In en, this message translates to:
  /// **'A policy says the app shares information with \'third-party partners.\' What is the best next question to ask?'**
  String get learnSharingQuickQuestion;

  /// First quick check option for Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Assume that means the app has no ads'**
  String get learnSharingQuickOption1;

  /// Second quick check option for Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Assume every partner does the exact same job'**
  String get learnSharingQuickOption2;

  /// Correct third quick check option for Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Check whether those partners are helpers (like hosting) or ad networks that track across apps'**
  String get learnSharingQuickOption3;

  /// Feedback shown when the user selects the right answer in Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Spot on. Helper services keep the app running, while ad networks and data brokers may track activity across apps.'**
  String get learnSharingQuickCorrectFeedback;

  /// Feedback shown when the user selects another option in Lesson 3
  ///
  /// In en, this message translates to:
  /// **'Look closer at what each partner does. Not all third parties are the same: some host data or fix crashes, while others run ads or tracking.'**
  String get learnSharingQuickTryAgainFeedback;

  /// Node label for the family/child user in the Lesson 3 diagram
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get learnDiagramThirdPartyYou;

  /// Node label for the learning app in the Lesson 3 diagram
  ///
  /// In en, this message translates to:
  /// **'Learning app'**
  String get learnDiagramThirdPartyApp;

  /// Node label for operational hosting and crash-fix services in the Lesson 3 diagram
  ///
  /// In en, this message translates to:
  /// **'Helpers & crashes'**
  String get learnDiagramThirdPartyHosting;

  /// Node label for analytics services in the Lesson 3 diagram
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get learnDiagramThirdPartyAnalytics;

  /// Node label for advertising networks in the Lesson 3 diagram
  ///
  /// In en, this message translates to:
  /// **'Ad networks'**
  String get learnDiagramThirdPartyAds;

  /// Badge label distinguishing first-party data flow in the Lesson 3 diagram
  ///
  /// In en, this message translates to:
  /// **'First party'**
  String get learnDiagramThirdPartyFirstParty;

  /// Badge label distinguishing third-party data flow in the Lesson 3 diagram
  ///
  /// In en, this message translates to:
  /// **'Third parties'**
  String get learnDiagramThirdPartyThirdParty;

  /// Full TalkBack description for the Lesson 3 ThirdPartyDiagram
  ///
  /// In en, this message translates to:
  /// **'Flow diagram showing where data from a child\'s learning app can go. You connect to the learning app, which connects with a solid line to the app maker (first party) and with dashed lines to third parties: helper and crash tools, analytics tools, and ad networks marked for extra attention.'**
  String get learnDiagramThirdPartySemantic;

  /// Short folder title for Lesson 4 on the Learn home screen
  ///
  /// In en, this message translates to:
  /// **'Reading Enprive'**
  String get learnEvidenceFolderTitle;

  /// Full lesson title for Lesson 4
  ///
  /// In en, this message translates to:
  /// **'How to read Enprive\'s evidence'**
  String get learnEvidenceTitle;

  /// Short subtitle for Lesson 4
  ///
  /// In en, this message translates to:
  /// **'Evidence layers, categories & honest limits'**
  String get learnEvidenceSubtitle;

  /// Plain-language introduction for Lesson 4
  ///
  /// In en, this message translates to:
  /// **'Enprive separates what a privacy policy says, what your phone shows, and what stays unknown, and groups findings by topic, never as a safety grade.'**
  String get learnEvidenceIntro;

  /// Step 1 of Lesson 4
  ///
  /// In en, this message translates to:
  /// **'Five topic categories group every finding with the same icon and color as the Review screen. Color marks the topic, never a safety score.'**
  String get learnEvidenceStep1;

  /// Step 2 of Lesson 4 referencing the exact Review screen source-matched badge
  ///
  /// In en, this message translates to:
  /// **'{sourceMatched} means Enprive found an exact quote word for word in the policy text you checked.'**
  String learnEvidenceStep2(String sourceMatched);

  /// Step 3 of Lesson 4 referencing the exact Review screen device-observed badge
  ///
  /// In en, this message translates to:
  /// **'{deviceObserved} means your phone reported a permission setting on this device: not proof that data was sent.'**
  String learnEvidenceStep3(String deviceObserved);

  /// Step 4 of Lesson 4 referencing exact Review screen interpretation and unverified badges
  ///
  /// In en, this message translates to:
  /// **'{interpretation} is Deni\'s plain-language explanation, while {unverified} marks details Enprive could not find. Silence in a policy is never a promise.'**
  String learnEvidenceStep4(String interpretation, String unverified);

  /// Step 5 of Lesson 4 referencing the three exact calibrated Review outcomes
  ///
  /// In en, this message translates to:
  /// **'Reviews end with one of three calm outcomes: {reviewRecommended}, {noConcern} (which is never a safety certification), or {insufficientEvidence}.'**
  String learnEvidenceStep5(
    String reviewRecommended,
    String noConcern,
    String insufficientEvidence,
  );

  /// Quick check question for Lesson 4
  ///
  /// In en, this message translates to:
  /// **'On a Review screen, what does \'{deviceObserved}\' mean?'**
  String learnEvidenceQuickQuestion(String deviceObserved);

  /// First quick check option for Lesson 4
  ///
  /// In en, this message translates to:
  /// **'The app is certified safe for children'**
  String get learnEvidenceQuickOption1;

  /// Correct second quick check option for Lesson 4
  ///
  /// In en, this message translates to:
  /// **'Your phone shows this permission setting on this device: not proof that data was uploaded'**
  String get learnEvidenceQuickOption2;

  /// Third quick check option for Lesson 4
  ///
  /// In en, this message translates to:
  /// **'The app has definitely uploaded your child\'s data'**
  String get learnEvidenceQuickOption3;

  /// Feedback shown when the user selects the right answer in Lesson 4
  ///
  /// In en, this message translates to:
  /// **'That\'s right. That label reflects Android\'s permission state on this device; it cannot prove uploads or certify safety.'**
  String get learnEvidenceQuickCorrectFeedback;

  /// Feedback shown when the user selects another option in Lesson 4
  ///
  /// In en, this message translates to:
  /// **'Not quite. That label only shows what your phone reports about a permission setting: it never proves uploads and is never a safety certification.'**
  String get learnEvidenceQuickTryAgainFeedback;

  /// Supporting caption for Layer 1 in the Lesson 4 EvidenceLayersDiagram
  ///
  /// In en, this message translates to:
  /// **'Exact quote matched in the policy text'**
  String get learnDiagramEvidencePolicyDetail;

  /// Supporting caption for Layer 2 in the Lesson 4 EvidenceLayersDiagram
  ///
  /// In en, this message translates to:
  /// **'Phone permissions on this device'**
  String get learnDiagramEvidencePhoneDetail;

  /// Supporting caption for Layer 3 in the Lesson 4 EvidenceLayersDiagram
  ///
  /// In en, this message translates to:
  /// **'Plain-language explanation by Deni'**
  String get learnDiagramEvidenceDeniDetail;

  /// Supporting caption for Layer 4 and bottom note in the Lesson 4 EvidenceLayersDiagram
  ///
  /// In en, this message translates to:
  /// **'Silence in a policy is not a promise'**
  String get learnDiagramEvidenceUnknownDetail;

  /// Full TalkBack description for the Lesson 4 EvidenceLayersDiagram
  ///
  /// In en, this message translates to:
  /// **'Four evidence layers used on Enprive\'s Review screen: 1, {sourceMatched}, an exact quote matched in the privacy policy; 2, {deviceObserved}, phone permissions on this device; 3, {interpretation}, Deni\'s plain-language explanation; and 4, separated by a dashed line, {unverified}, because silence in a policy is not a promise.'**
  String learnDiagramEvidenceSemantic(
    String sourceMatched,
    String deviceObserved,
    String interpretation,
    String unverified,
  );

  /// Heading for the five evidence categories legend in Lesson 4
  ///
  /// In en, this message translates to:
  /// **'Five topic categories on the Review screen'**
  String get learnDiagramCategoriesTitle;

  /// Clarification under the five evidence categories legend in Lesson 4
  ///
  /// In en, this message translates to:
  /// **'Color and icon mark the topic, never a safety score.'**
  String get learnDiagramCategoriesNote;

  /// Full TalkBack description for the five evidence categories legend in Lesson 4
  ///
  /// In en, this message translates to:
  /// **'Five evidence categories shown on Enprive\'s Review screen, each with its own icon and color: {dataCollection}, {sharing}, {tracking}, {retention}, and {parentalControls}. Color and icon mark the topic, never a safety score.'**
  String learnDiagramCategoriesSemantic(
    String dataCollection,
    String sharing,
    String tracking,
    String retention,
    String parentalControls,
  );

  /// Short folder title for Lesson 5 on the Learn home screen
  ///
  /// In en, this message translates to:
  /// **'Data apps collect'**
  String get learnDataCollectionFolderTitle;

  /// Full lesson title for Lesson 5
  ///
  /// In en, this message translates to:
  /// **'What Data Apps Collect'**
  String get learnDataCollectionTitle;

  /// Short subtitle for Lesson 5
  ///
  /// In en, this message translates to:
  /// **'The difference between what you type and what runs quietly'**
  String get learnDataCollectionSubtitle;

  /// Plain-language introduction for Lesson 5
  ///
  /// In en, this message translates to:
  /// **'Apps gather information in two ways. Some data comes from what you actively enter: your name, email, photos, voice recordings, or homework answers. Other data is collected automatically in the background, like your IP address (the address your phone uses on the internet), device identifiers, advertising ID (a code ads use to recognize your phone), crash logs, and when you open the app.'**
  String get learnDataCollectionIntro1;

  /// Step 1 of Lesson 5
  ///
  /// In en, this message translates to:
  /// **'What you type: Your name, school, email, photos, voice clips, and homework answers are data you choose to give.'**
  String get learnDataCollectionStep1;

  /// Step 2 of Lesson 5
  ///
  /// In en, this message translates to:
  /// **'What runs quietly: The app can collect an advertising ID, device identifiers, IP address, crash reports, and usage timing without you pressing a button. Quiet collection is not automatically bad: these signals help apps run smoothly.'**
  String get learnDataCollectionStep2;

  /// Step 3 of Lesson 5
  ///
  /// In en, this message translates to:
  /// **'Sensitive child data: Location, microphone recordings, camera photos, and biometric data like voiceprints (data about your body or voice) carry higher privacy risk for children.'**
  String get learnDataCollectionStep3;

  /// Step 4 of Lesson 5
  ///
  /// In en, this message translates to:
  /// **'Play Store note: Google Play\'s Data Safety section is the developer\'s own description. It is a hint, not proof, and does not include data processed only on your device or kept briefly in memory.'**
  String get learnDataCollectionStep4;

  /// Quick check question for Lesson 5
  ///
  /// In en, this message translates to:
  /// **'Which of these is an example of data that runs quietly in the background?'**
  String get learnDataCollectionQuizQuestion;

  /// First quick check option for Lesson 5
  ///
  /// In en, this message translates to:
  /// **'A photo you upload for your profile'**
  String get learnDataCollectionQuizChoiceA;

  /// Correct second quick check option for Lesson 5
  ///
  /// In en, this message translates to:
  /// **'Your advertising ID and device identifiers'**
  String get learnDataCollectionQuizChoiceB;

  /// Third quick check option for Lesson 5
  ///
  /// In en, this message translates to:
  /// **'A homework answer you type in the app'**
  String get learnDataCollectionQuizChoiceC;

  /// Feedback shown when the user selects the right answer in Lesson 5
  ///
  /// In en, this message translates to:
  /// **'Correct: advertising IDs and device identifiers are collected automatically without you typing them.'**
  String get learnDataCollectionQuizFeedbackRight;

  /// Feedback shown when the user selects another option in Lesson 5
  ///
  /// In en, this message translates to:
  /// **'Not quite: that is data you actively enter. Data that runs quietly includes advertising IDs, device identifiers, IP address, and usage timing.'**
  String get learnDataCollectionQuizFeedbackWrong;

  /// First card title in the Lesson 5 Data Collection diagram
  ///
  /// In en, this message translates to:
  /// **'What you type or give'**
  String get learnDataCollectionDiagramYouTypeTitle;

  /// First item in the 'What you type' card
  ///
  /// In en, this message translates to:
  /// **'Name, email, school'**
  String get learnDataCollectionDiagramYouTypeItem1;

  /// Second item in the 'What you type' card
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get learnDataCollectionDiagramYouTypeItem2;

  /// Third item in the 'What you type' card
  ///
  /// In en, this message translates to:
  /// **'Voice recordings'**
  String get learnDataCollectionDiagramYouTypeItem3;

  /// Fourth item in the 'What you type' card
  ///
  /// In en, this message translates to:
  /// **'Homework answers'**
  String get learnDataCollectionDiagramYouTypeItem4;

  /// Second card title in the Lesson 5 Data Collection diagram
  ///
  /// In en, this message translates to:
  /// **'What runs quietly'**
  String get learnDataCollectionDiagramRunsQuietlyTitle;

  /// First item in the 'What runs quietly' card
  ///
  /// In en, this message translates to:
  /// **'Advertising ID'**
  String get learnDataCollectionDiagramRunsQuietlyItem1;

  /// Second item in the 'What runs quietly' card
  ///
  /// In en, this message translates to:
  /// **'Device identifiers'**
  String get learnDataCollectionDiagramRunsQuietlyItem2;

  /// Third item in the 'What runs quietly' card
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get learnDataCollectionDiagramRunsQuietlyItem3;

  /// Fourth item in the 'What runs quietly' card
  ///
  /// In en, this message translates to:
  /// **'Crash logs and usage timing'**
  String get learnDataCollectionDiagramRunsQuietlyItem4;

  /// Calm footer note beside Deni in the Lesson 5 Data Collection diagram
  ///
  /// In en, this message translates to:
  /// **'Quiet does not mean bad: these signals help apps run smoothly.'**
  String get learnDataCollectionDiagramQuietNote;

  /// Full TalkBack description for the Lesson 5 Data Collection diagram
  ///
  /// In en, this message translates to:
  /// **'A split diagram showing two categories of data collection. The top card titled \"What you type or give\" lists four chips: Name email school, Photos and videos, Voice recordings, Homework answers. The bottom card titled \"What runs quietly\" lists four chips: Advertising ID, Device identifiers, IP address, Crash logs and usage timing. A small note reads \"Quiet does not mean bad: these signals help apps run smoothly.\" Deni the mascot sits below in a thinking pose.'**
  String get learnDataCollectionDiagramSemanticDescription;

  /// Bridge CTA for Lesson 5
  ///
  /// In en, this message translates to:
  /// **'Check an app on this phone to see what data it collects.'**
  String get learnDataCollectionCheckBridge;

  /// Honesty note for Lesson 5
  ///
  /// In en, this message translates to:
  /// **'This lesson explains common data types. It does not prove what any specific app collects or sends. Only the app\'s exact policy text and your phone\'s permission settings can show that.'**
  String get learnDataCollectionHonestyNote;

  /// Short folder title for Lesson 6 on the Learn home screen
  ///
  /// In en, this message translates to:
  /// **'Retention and deletion'**
  String get learnRetentionFolderTitle;

  /// Full lesson title for Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Retention and Deletion'**
  String get learnRetentionTitle;

  /// Short subtitle for Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Uninstalling an app does not erase data already on company servers'**
  String get learnRetentionSubtitle;

  /// Plain-language introduction for Lesson 6
  ///
  /// In en, this message translates to:
  /// **'When you delete an app from your phone, the app\'s files on your device are removed, but any data already uploaded to the company\'s servers stays there. Privacy policies should say how long they keep your data, how to ask for deletion, and what happens to backups, but many policies use vague phrases like \"as long as reasonably necessary.\"'**
  String get learnRetentionIntro1;

  /// Step 1 of Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Data collected: While you use the app, your information is sent to and stored on the company\'s servers.'**
  String get learnRetentionStep1;

  /// Step 2 of Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Stored on servers: Your data can stay on company systems even after you stop using the app.'**
  String get learnRetentionStep2;

  /// Step 3 of Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Uninstall does not delete server data: Removing the app from your phone only deletes local files, not the copies on company servers.'**
  String get learnRetentionStep3;

  /// Step 4 of Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Deletion request: You can ask the company to delete your account and data; policies should say how long this takes.'**
  String get learnRetentionStep4;

  /// Step 5 of Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Unknown retention: Policies that say \"as long as needed\" or \"for business purposes\" leave the actual deletion timeline unclear.'**
  String get learnRetentionStep5;

  /// Quick check question for Lesson 6
  ///
  /// In en, this message translates to:
  /// **'What happens to your data on company servers when you uninstall an app from your phone?'**
  String get learnRetentionQuizQuestion;

  /// First quick check option for Lesson 6
  ///
  /// In en, this message translates to:
  /// **'It is deleted automatically'**
  String get learnRetentionQuizChoiceA;

  /// Correct second quick check option for Lesson 6
  ///
  /// In en, this message translates to:
  /// **'It may stay on the servers - uninstalling the app does not delete it'**
  String get learnRetentionQuizChoiceB;

  /// Third quick check option for Lesson 6
  ///
  /// In en, this message translates to:
  /// **'It is anonymized immediately'**
  String get learnRetentionQuizChoiceC;

  /// Feedback shown when the user selects the right answer in Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Correct: uninstalling only removes the app from your phone. Data on company servers may stay until you request deletion.'**
  String get learnRetentionQuizFeedbackRight;

  /// Feedback shown when the user selects another option in Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Not quite: uninstalling an app does not delete data already uploaded to company servers. You need to request account deletion.'**
  String get learnRetentionQuizFeedbackWrong;

  /// Step 1 label in the Lesson 6 Retention Timeline diagram
  ///
  /// In en, this message translates to:
  /// **'Data collected during use'**
  String get learnRetentionDiagramCollected;

  /// Step 2 label in the Lesson 6 Retention Timeline diagram
  ///
  /// In en, this message translates to:
  /// **'Stored on company servers'**
  String get learnRetentionDiagramStored;

  /// Step 3 label in the Lesson 6 Retention Timeline diagram
  ///
  /// In en, this message translates to:
  /// **'You uninstall the app - phone files go, server data stays'**
  String get learnRetentionDiagramUninstall;

  /// Step 4 label in the Lesson 6 Retention Timeline diagram
  ///
  /// In en, this message translates to:
  /// **'You request account deletion'**
  String get learnRetentionDiagramDeleteRequest;

  /// Step 5 label in the Lesson 6 Retention Timeline diagram
  ///
  /// In en, this message translates to:
  /// **'Unknown retention - policy says \"as long as needed\"'**
  String get learnRetentionDiagramUnknownTail;

  /// Full TalkBack description for the Lesson 6 Retention Timeline diagram
  ///
  /// In en, this message translates to:
  /// **'A five-step timeline showing the data lifecycle. Step 1: Data collected during use, with a database icon. Step 2: Stored on company servers, with a server icon. Step 3: You uninstall the app - phone files go, server data stays, with a smartphone icon. Step 4: You request account deletion, with a trash icon. Step 5: Unknown retention - policy says \"as long as needed,\" shown with a dashed arrow and a help circle icon. Deni the mascot stands below holding a receipt.'**
  String get learnRetentionDiagramSemanticDescription;

  /// Bridge CTA for Lesson 6
  ///
  /// In en, this message translates to:
  /// **'Check an app on this phone to see what its policy says about retention.'**
  String get learnRetentionCheckBridge;

  /// Honesty note for Lesson 6
  ///
  /// In en, this message translates to:
  /// **'This lesson describes common retention patterns. It does not prove what any specific company actually does with your data. Only the exact policy text and a deletion request can show that.'**
  String get learnRetentionHonestyNote;

  /// Short folder title for Lesson 7 on the Learn home screen
  ///
  /// In en, this message translates to:
  /// **'Unclear policies'**
  String get learnUnclearPoliciesFolderTitle;

  /// Full lesson title for Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Spotting Unclear Policies & Tricky Buttons'**
  String get learnUnclearPoliciesTitle;

  /// Short subtitle for Lesson 7
  ///
  /// In en, this message translates to:
  /// **'How to recognize vague language and pressured consent screens'**
  String get learnUnclearPoliciesSubtitle;

  /// Plain-language introduction for Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Some privacy policies use fuzzy words that make it hard to know what actually happens to your data. Consent screens can also use design tricks, like a big bright \"Accept All\" button next to a tiny \"Manage Settings\" link, to push you into agreeing without reading.'**
  String get learnUnclearPoliciesIntro1;

  /// Step 1 of Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Policy fog signs: Watch for open-ended phrases like \"may share with trusted partners,\" \"for business purposes,\" or \"retain as needed\": they leave the real details unspecified.'**
  String get learnUnclearPoliciesStep1;

  /// Step 2 of Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Silence is not a promise: If a policy never mentions the microphone, ads, or location, it does not guarantee the app avoids them.'**
  String get learnUnclearPoliciesStep2;

  /// Step 3 of Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Missing basics: A trustworthy policy has a clear effective date, a contact email, and one unified document: not a hidden children\'s addendum.'**
  String get learnUnclearPoliciesStep3;

  /// Step 4 of Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Pressured consent (dark patterns): Giant \"Accept All\" buttons, pre-checked marketing boxes, nagging re-prompts, and hard-to-find cancellation paths are designed to override your choice.'**
  String get learnUnclearPoliciesStep4;

  /// Step 5 of Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Balanced choice: A fair screen shows equal \"Allow\" and \"Don\'t allow\" buttons, with optional toggles unchecked by default.'**
  String get learnUnclearPoliciesStep5;

  /// Quick check question for Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Which phrase in a privacy policy is a \"foggy\" signal that details are missing?'**
  String get learnUnclearPoliciesQuizQuestion;

  /// First quick check option for Lesson 7
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal information to third parties'**
  String get learnUnclearPoliciesQuizChoiceA;

  /// Correct second quick check option for Lesson 7
  ///
  /// In en, this message translates to:
  /// **'We may share data with trusted partners for business purposes'**
  String get learnUnclearPoliciesQuizChoiceB;

  /// Third quick check option for Lesson 7
  ///
  /// In en, this message translates to:
  /// **'You can request deletion by emailing privacy@example.com'**
  String get learnUnclearPoliciesQuizChoiceC;

  /// Feedback shown when the user selects the right answer in Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Correct: \"may share with trusted partners for business purposes\" is vague and does not say who the partners are or what data is shared.'**
  String get learnUnclearPoliciesQuizFeedbackRight;

  /// Feedback shown when the user selects another option in Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Not quite: that phrase is specific and actionable. Foggy phrases use open-ended language like \"may share\" or \"as needed\" without details.'**
  String get learnUnclearPoliciesQuizFeedbackWrong;

  /// Left card title in the Lesson 7 Policy Fog diagram
  ///
  /// In en, this message translates to:
  /// **'Clear policy sentence'**
  String get learnUnclearPoliciesDiagramClearTitle;

  /// Clear policy example in the Lesson 7 diagram
  ///
  /// In en, this message translates to:
  /// **'We collect your name and email to create your account. We do not share this with advertisers.'**
  String get learnUnclearPoliciesDiagramClearExample;

  /// Right card title in the Lesson 7 Policy Fog diagram
  ///
  /// In en, this message translates to:
  /// **'Foggy policy sentence'**
  String get learnUnclearPoliciesDiagramFoggyTitle;

  /// Foggy policy example in the Lesson 7 diagram
  ///
  /// In en, this message translates to:
  /// **'We may share your information with trusted partners for business purposes as needed.'**
  String get learnUnclearPoliciesDiagramFoggyExample;

  /// Tips card title in the Lesson 7 Policy Fog diagram
  ///
  /// In en, this message translates to:
  /// **'How to spot the fog'**
  String get learnUnclearPoliciesDiagramTipsTitle;

  /// First tip in the Lesson 7 Policy Fog diagram
  ///
  /// In en, this message translates to:
  /// **'Look for \"may,\" \"could,\" or \"as needed\": they leave the door open.'**
  String get learnUnclearPoliciesDiagramTip1;

  /// Second tip in the Lesson 7 Policy Fog diagram
  ///
  /// In en, this message translates to:
  /// **'Check if the policy names the specific companies data goes to.'**
  String get learnUnclearPoliciesDiagramTip2;

  /// Third tip in the Lesson 7 Policy Fog diagram
  ///
  /// In en, this message translates to:
  /// **'Silence on a topic like ads or microphone is not a promise the app avoids it.'**
  String get learnUnclearPoliciesDiagramTip3;

  /// Footer reminder note beside Deni in the Lesson 7 Policy Fog diagram
  ///
  /// In en, this message translates to:
  /// **'Silence in a policy is not a promise.'**
  String get learnUnclearPoliciesDiagramSilenceNote;

  /// Full TalkBack description for the Lesson 7 Policy Fog diagram
  ///
  /// In en, this message translates to:
  /// **'A side-by-side comparison of a clear policy sentence and a foggy one. The left card labeled \"Clear\" shows: \"We collect your name and email to create your account. We do not share this with advertisers.\" The right card labeled \"Foggy\" shows: \"We may share your information with trusted partners for business purposes as needed.\" Below, a tips card titled \"How to spot the fog\" lists three tips: Look for \"may,\" \"could,\" or \"as needed\": they leave the door open. Check if the policy names the specific companies data goes to. Silence on a topic like ads or microphone is not a promise the app avoids it. A note on the foggy card reads \"Silence in a policy is not a promise.\" Deni the mascot peeks over the cards.'**
  String get learnUnclearPoliciesDiagramSemanticDescription;

  /// Bridge CTA for Lesson 7
  ///
  /// In en, this message translates to:
  /// **'Check an app on this phone to test its consent screen and policy clarity.'**
  String get learnUnclearPoliciesCheckBridge;

  /// Honesty note for Lesson 7
  ///
  /// In en, this message translates to:
  /// **'This lesson describes common unclear patterns. It does not prove any specific app uses dark patterns or hides data practices. Only reading the exact policy and seeing the real consent screen can show that.'**
  String get learnUnclearPoliciesHonestyNote;

  /// Short folder title for Lesson 8 on the Learn home screen
  ///
  /// In en, this message translates to:
  /// **'Safe sharing habits'**
  String get learnSafeSharingFolderTitle;

  /// Full lesson title for Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Safe-Sharing Habits for Kids'**
  String get learnSafeSharingTitle;

  /// Short subtitle for Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Stop, Think, Connect - age-appropriate steps for sharing online'**
  String get learnSafeSharingSubtitle;

  /// Plain-language introduction for Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Before you post a photo, video, your name, or your location, pause and use the three steps: Stop, Think, Connect. This lesson is for reading together with a trusted adult. Younger kids (ages 5-7) ask before tapping. Older kids (8-11) use nicknames and strong passwords. Teens (12-17) manage digital footprints (the trail of things you post) and two-factor authentication (a second check, like a code, when you sign in).'**
  String get learnSafeSharingIntro1;

  /// Step 1 of Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Stop: Pause before you post a photo, video, name, school, or location. Ask a trusted adult if you are not sure.'**
  String get learnSafeSharingStep1;

  /// Step 2 of Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Think: Does this reveal my school, home, or where I am right now? Did I ask my friends before sharing their photos or tagging them?'**
  String get learnSafeSharingStep2;

  /// Step 3 of Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Connect: Share only with people you trust. Keep personal details like your full name, birthday, address, and phone number private.'**
  String get learnSafeSharingStep3;

  /// Step 4 of Lesson 8
  ///
  /// In en, this message translates to:
  /// **'The Cafeteria Test: Would I be okay if everyone at school (or my whole class) saw this photo or message? Even disappearing posts can be screenshotted and stay online permanently.'**
  String get learnSafeSharingStep4;

  /// Step 5 of Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Age 5-7: Ask a trusted adult before typing your name or tapping popups. Age 8-11: Use a nickname (not real name, birthday, and school), strong passwords, never share SMS or OTP codes (one-time codes sent by text message - never share them). Age 12-17: Review privacy settings, turn on two-factor authentication, know how to report problems.'**
  String get learnSafeSharingStep5;

  /// Quick check question for Lesson 8
  ///
  /// In en, this message translates to:
  /// **'What is the \"Cafeteria Test\" for sharing online?'**
  String get learnSafeSharingQuizQuestion;

  /// First quick check option for Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Only share things you would eat in the cafeteria'**
  String get learnSafeSharingQuizChoiceA;

  /// Correct second quick check option for Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Ask: would I be okay if everyone at school saw this photo or message?'**
  String get learnSafeSharingQuizChoiceB;

  /// Third quick check option for Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Share only during lunch break'**
  String get learnSafeSharingQuizChoiceC;

  /// Feedback shown when the user selects the right answer in Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Correct: the Cafeteria Test means asking yourself if you would be comfortable with everyone seeing what you post.'**
  String get learnSafeSharingQuizFeedbackRight;

  /// Feedback shown when the user selects another option in Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Not quite: the Cafeteria Test is a mental check: would you be okay if someone showed your post to the whole cafeteria?'**
  String get learnSafeSharingQuizFeedbackWrong;

  /// Step 1 label in the Lesson 8 Safe Sharing diagram
  ///
  /// In en, this message translates to:
  /// **'Stop - pause before you post'**
  String get learnSafeSharingDiagramStop;

  /// Step 2 label in the Lesson 8 Safe Sharing diagram
  ///
  /// In en, this message translates to:
  /// **'Think - does this reveal where I am or who I am with?'**
  String get learnSafeSharingDiagramThink;

  /// Step 3 label in the Lesson 8 Safe Sharing diagram
  ///
  /// In en, this message translates to:
  /// **'Connect - share with people you trust, ask an adult if unsure'**
  String get learnSafeSharingDiagramConnect;

  /// Cafeteria Test callout in the Lesson 8 Safe Sharing diagram
  ///
  /// In en, this message translates to:
  /// **'The Cafeteria Test: Would I be okay if everyone at school saw this? Even disappearing posts can be screenshotted and stay online permanently.'**
  String get learnSafeSharingDiagramCafeteriaTest;

  /// Full TalkBack description for the Lesson 8 Safe Sharing diagram
  ///
  /// In en, this message translates to:
  /// **'A four-part diagram teaching safe sharing habits. Step 1: Stop - pause before you post, with a hand icon. Step 2: Think - does this reveal where I am or who I am with, with a brain icon. Step 3: Connect - share with people you trust, ask an adult if unsure, with a users icon. Step 4: The Cafeteria Test callout asks \"Would I be okay if everyone at school saw this? Even disappearing posts can be screenshotted and stay online permanently.\" Deni the mascot stands beside the callout with a raised hand.'**
  String get learnSafeSharingDiagramSemanticDescription;

  /// Bridge CTA for Lesson 8
  ///
  /// In en, this message translates to:
  /// **'Check an app together with a parent to see how it handles sharing.'**
  String get learnSafeSharingCheckBridge;

  /// Honesty note for Lesson 8
  ///
  /// In en, this message translates to:
  /// **'This lesson shares general safe-sharing habits. It does not guarantee any app will protect what you share. Always read the app\'s policy and use your phone\'s privacy settings.'**
  String get learnSafeSharingHonestyNote;

  /// Short honest note in the language settings area explaining that non-English translations are AI-assisted drafts undergoing native-speaker review
  ///
  /// In en, this message translates to:
  /// **'Some translations are AI-generated drafts and may contain mistakes. Native speakers are reviewing them.'**
  String get translationDraftNotice;

  /// Title of the Quick Settings Companion card on Home
  ///
  /// In en, this message translates to:
  /// **'Quick Settings Companion'**
  String get homeQuickSettingsTitle;

  /// Subtitle of the Quick Settings Companion card on Home
  ///
  /// In en, this message translates to:
  /// **'Ask Deni about the app you\'re using anytime'**
  String get homeQuickSettingsSubtitle;

  /// Heading for the light/dark/system theme selector in Settings
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// System default theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// Section title for Quick Settings tile and optional Usage Access in Settings
  ///
  /// In en, this message translates to:
  /// **'Connect Enprive to Quick Settings'**
  String get quickSettingsSectionTitle;

  /// Explanation of Quick Settings tile integration
  ///
  /// In en, this message translates to:
  /// **'Add Enprive Check to your Android Quick Settings panel so you can ask Deni about applications without leaving what you\'re doing.'**
  String get quickSettingsSectionSubtitle;

  /// Row title for the Enprive Check Quick Settings tile
  ///
  /// In en, this message translates to:
  /// **'Enprive Check tile'**
  String get quickSettingsTileTitle;

  /// Row subtitle for the Enprive Check Quick Settings tile
  ///
  /// In en, this message translates to:
  /// **'Add Enprive Check to Quick Settings to ask Deni about the app you\'re using without searching for Enprive first.'**
  String get quickSettingsTileSubtitle;

  /// Status badge when Quick Settings tile is added
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get quickSettingsStatusAdded;

  /// Status badge when Quick Settings tile must be added manually
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get quickSettingsStatusManual;

  /// Status badge when Quick Settings tile is not yet added
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get quickSettingsStatusNotAdded;

  /// Status badge when Android Usage Access is granted
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get usageAccessStatusGranted;

  /// Status badge when Android Usage Access is not granted
  ///
  /// In en, this message translates to:
  /// **'Not granted'**
  String get usageAccessStatusNotGranted;

  /// Row title for optional Android Usage Access
  ///
  /// In en, this message translates to:
  /// **'Allow Usage Access (optional)'**
  String get usageAccessTitle;

  /// Honest explanation of how Enprive uses Android Usage Access
  ///
  /// In en, this message translates to:
  /// **'Enprive uses Usage Access only when you tap Enprive Check to identify the app you were just using. This helps Deni find the correct app and its privacy information. Enprive does not continuously monitor your screen.'**
  String get usageAccessExplanation;

  /// Link text to open instructions for managing or revoking Usage Access
  ///
  /// In en, this message translates to:
  /// **'How to manage / revoke'**
  String get usageAccessManageLink;

  /// Dialog title for Usage Access revocation instructions
  ///
  /// In en, this message translates to:
  /// **'Manage or revoke Usage Access'**
  String get usageAccessManageTitle;

  /// Dialog body explaining how to turn off Usage Access in Android Settings
  ///
  /// In en, this message translates to:
  /// **'Usage Access is a special Android Settings toggle (not an automatic popup). You can turn it off anytime under Android Settings -> Apps -> Special app access -> Usage access -> enprive. Deni remains usable without it via manual app selection.'**
  String get usageAccessManageBody;

  /// Settings row title to launch Deni Companion directly
  ///
  /// In en, this message translates to:
  /// **'Open Deni Companion'**
  String get openDeniCompanionTitle;

  /// Settings row subtitle for opening Deni Companion directly
  ///
  /// In en, this message translates to:
  /// **'Check a recent or selected app\'s permissions without Quick Settings.'**
  String get openDeniCompanionSubtitle;

  /// Short confirmation button on informational dialogs
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get btnGotIt;

  /// Dialog title when Quick Settings tile is already added
  ///
  /// In en, this message translates to:
  /// **'Enprive Check is ready in Quick Settings'**
  String get quickSettingsReadyDialogTitle;

  /// Dialog body explaining how to use the Quick Settings tile
  ///
  /// In en, this message translates to:
  /// **'Swipe down twice from the top of your screen and tap \"Enprive Check\" anytime you want Deni to explain an app\'s permissions.'**
  String get quickSettingsReadyDialogBody;

  /// Dialog title for manual Quick Settings tile setup instructions
  ///
  /// In en, this message translates to:
  /// **'Add Enprive Check manually'**
  String get quickSettingsManualDialogTitle;

  /// Numbered instructions to add the Quick Settings tile manually
  ///
  /// In en, this message translates to:
  /// **'1. Swipe down twice from the top of your Android screen to open Quick Settings.\n2. Tap the Edit (pencil) button.\n3. Find \"Enprive Check\" and drag it into your active Quick Settings tiles.'**
  String get quickSettingsManualDialogBody;

  /// Snackbar after Quick Settings tile is added
  ///
  /// In en, this message translates to:
  /// **'Enprive Check added to your Quick Settings tray.'**
  String get quickSettingsSnackAdded;

  /// Snackbar when Quick Settings tile is already present
  ///
  /// In en, this message translates to:
  /// **'Enprive Check is already in your Quick Settings tray.'**
  String get quickSettingsSnackAlreadyAdded;

  /// Snackbar when user declines the Quick Settings tile prompt
  ///
  /// In en, this message translates to:
  /// **'Request dismissed. Enprive won\'t ask again unless you choose Edit in Quick Settings.'**
  String get quickSettingsSnackDeclined;

  /// Snackbar prompting manual tile addition
  ///
  /// In en, this message translates to:
  /// **'Swipe down Quick Settings, tap Edit, and drag Enprive Check into your tiles.'**
  String get quickSettingsSnackManual;

  /// Snackbar when Android Quick Settings add prompt is unavailable
  ///
  /// In en, this message translates to:
  /// **'System prompt unavailable here; you can drag Enprive Check manually from Quick Settings Edit.'**
  String get quickSettingsSnackUnavailable;

  /// Snackbar when opening Android Usage Access settings fails
  ///
  /// In en, this message translates to:
  /// **'Could not open Usage Access Settings on this device.'**
  String get usageAccessOpenFailedSnack;

  /// Title of the Companion screen
  ///
  /// In en, this message translates to:
  /// **'Deni: Enprive Companion'**
  String get companionTitle;

  /// Subtitle on the Companion header banner
  ///
  /// In en, this message translates to:
  /// **'Ask Deni about an app\'s permissions and what its privacy policy says.'**
  String get companionSubtitle;

  /// Tooltip for closing Companion and returning to the previous app
  ///
  /// In en, this message translates to:
  /// **'Return to previous app'**
  String get companionTooltipReturnToPrev;

  /// Tooltip for navigating back from Companion
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get companionTooltipBack;

  /// Badge shown when device is locked
  ///
  /// In en, this message translates to:
  /// **'LOCK SCREEN PROTECTED'**
  String get companionLockedBadge;

  /// Title of the lock-screen privacy guard
  ///
  /// In en, this message translates to:
  /// **'Unlock your phone to continue'**
  String get companionLockedTitle;

  /// Body of the lock-screen privacy guard
  ///
  /// In en, this message translates to:
  /// **'Enprive hides app names, declared permissions, and review evidence while the device is locked.'**
  String get companionLockedBody;

  /// Button to re-check whether the phone is unlocked
  ///
  /// In en, this message translates to:
  /// **'Check unlock state'**
  String get companionCheckUnlockBtn;

  /// Headline while Companion looks up the recent foreground app
  ///
  /// In en, this message translates to:
  /// **'Checking which app you were using…'**
  String get companionCheckingAppHeadline;

  /// Subtitle explaining one-time foreground app lookup
  ///
  /// In en, this message translates to:
  /// **'Checking once on this phone without watching your screen.'**
  String get companionCheckingAppSubtitle;

  /// Headline when browsing general Android permissions without an app selected
  ///
  /// In en, this message translates to:
  /// **'General Android permission guide'**
  String get companionGeneralGuideHeadline;

  /// Subtitle when no app is selected in Companion
  ///
  /// In en, this message translates to:
  /// **'No app selected. Enprive explains Android permissions using local guidance only.'**
  String get companionGeneralGuideSubtitle;

  /// Headline naming the confirmed app in Companion
  ///
  /// In en, this message translates to:
  /// **'You\'re looking at {appName}.'**
  String companionLookingAtHeadline(String appName);

  /// Clarification that listed permissions come from the installed app manifest, not live screen reading
  ///
  /// In en, this message translates to:
  /// **'Permissions listed below come from the app on your phone: Android still controls whichever popup is on screen.'**
  String get companionLookingAtSubtitle;

  /// Fallback phrase when an app label is unavailable
  ///
  /// In en, this message translates to:
  /// **'this app'**
  String get companionThisAppFallback;

  /// Prompt confirming a recently active app with age in seconds
  ///
  /// In en, this message translates to:
  /// **'We saw {appName} {seconds}s ago. Is this correct?'**
  String companionSawAppAgo(String appName, int seconds);

  /// Prompt confirming the detected foreground app
  ///
  /// In en, this message translates to:
  /// **'We think you\'re using {appName}. Is this correct?'**
  String companionThinkUsingApp(String appName);

  /// Line displaying the Android App ID (package name)
  ///
  /// In en, this message translates to:
  /// **'App ID: {packageName}'**
  String companionAppIdLine(String packageName);

  /// Primary button confirming the detected app
  ///
  /// In en, this message translates to:
  /// **'Confirm · {appName}'**
  String companionConfirmAppBtn(String appName);

  /// Button to pick a different installed app
  ///
  /// In en, this message translates to:
  /// **'Choose another app'**
  String get companionChooseAnotherAppBtn;

  /// Short button to proceed without selecting an app
  ///
  /// In en, this message translates to:
  /// **'Without app context'**
  String get companionWithoutAppContextBtn;

  /// Title when multiple recent foreground apps were found
  ///
  /// In en, this message translates to:
  /// **'Multiple apps were active just now'**
  String get companionMultipleAppsTitle;

  /// Prompt asking user to choose among recently active apps
  ///
  /// In en, this message translates to:
  /// **'Confirm which application you want to inspect:'**
  String get companionMultipleAppsPrompt;

  /// Relative time in seconds for recent app activity
  ///
  /// In en, this message translates to:
  /// **'{seconds}s ago'**
  String companionSecondsAgo(int seconds);

  /// Title prompting manual app selection
  ///
  /// In en, this message translates to:
  /// **'Select the app you want to check'**
  String get companionSelectAppTitle;

  /// Body prompting manual app selection or general guidance
  ///
  /// In en, this message translates to:
  /// **'Choose the application manually from installed apps, or continue without app context.'**
  String get companionSelectAppBody;

  /// Primary button to pick an app manually
  ///
  /// In en, this message translates to:
  /// **'Choose app manually'**
  String get companionChooseAppManuallyBtn;

  /// Button to open Android Usage Access settings
  ///
  /// In en, this message translates to:
  /// **'Open Usage Access Settings'**
  String get companionOpenUsageAccessBtn;

  /// Button to continue with general Android permission explanations
  ///
  /// In en, this message translates to:
  /// **'Continue without app context'**
  String get companionContinueWithoutAppBtn;

  /// Button to request adding the Enprive Check Quick Settings tile
  ///
  /// In en, this message translates to:
  /// **'Add Enprive Check tile'**
  String get companionAddTileBtn;

  /// Summary label when continuing without an app selected
  ///
  /// In en, this message translates to:
  /// **'Continuing without app context'**
  String get companionContinuingWithoutApp;

  /// Button to change the selected app
  ///
  /// In en, this message translates to:
  /// **'Switch app'**
  String get companionSwitchAppBtn;

  /// Note explaining permissions are inspected locally on-device
  ///
  /// In en, this message translates to:
  /// **'Permissions shown below are read directly from your phone.'**
  String get companionPermissionsReadLocally;

  /// Heading for general Android permission exploration
  ///
  /// In en, this message translates to:
  /// **'Pick a permission type to explore'**
  String get companionPickPermissionType;

  /// Button to select an installed app
  ///
  /// In en, this message translates to:
  /// **'Pick an app'**
  String get companionPickAppBtn;

  /// Error heading when app permissions could not be inspected
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read app permissions'**
  String get companionCouldNotReadPermsTitle;

  /// Fallback error body when Android restricts package inspection
  ///
  /// In en, this message translates to:
  /// **'Android prevented inspecting this app\'s permissions.'**
  String get companionCouldNotReadPermsBody;

  /// Button opening the guided permission matcher
  ///
  /// In en, this message translates to:
  /// **'I\'m not sure which permission'**
  String get companionUnsurePermBtn;

  /// Heading above the selected app's declared permissions
  ///
  /// In en, this message translates to:
  /// **'Which permission would you like to understand?'**
  String get companionWhichPermissionPrompt;

  /// Disclaimer separating manifest permissions from live Android dialogs
  ///
  /// In en, this message translates to:
  /// **'These are permissions the app lists on your phone, not necessarily the popup on your screen right now.'**
  String get companionPermissionsListDisclaimer;

  /// Message when the selected app declares no sensitive permissions
  ///
  /// In en, this message translates to:
  /// **'This app doesn\'t ask for any sensitive permissions on your phone.'**
  String get companionNoSensitivePermsMsg;

  /// Title of the guided permission picker
  ///
  /// In en, this message translates to:
  /// **'Match what the popup on your screen asked for'**
  String get companionGuidedMatchTitle;

  /// Honest explanation that Enprive cannot read live system popups
  ///
  /// In en, this message translates to:
  /// **'Enprive cannot read your current Android prompt directly. Choose the wording closest to what appeared on screen:'**
  String get companionGuidedMatchSubtitle;

  /// Section 1 heading in Companion permission explanation
  ///
  /// In en, this message translates to:
  /// **'1. What this permission means'**
  String get companionSection1Title;

  /// Section 2 heading in Companion permission explanation
  ///
  /// In en, this message translates to:
  /// **'2. What the app asks for on your phone'**
  String get companionSection2Title;

  /// Section 3 heading in Companion permission explanation
  ///
  /// In en, this message translates to:
  /// **'3. What its privacy policy says'**
  String get companionSection3Title;

  /// Section 4 heading in Companion permission explanation
  ///
  /// In en, this message translates to:
  /// **'4. Why this might relate to a feature'**
  String get companionSection4Title;

  /// Fallback text when no policy feature explanation was matched
  ///
  /// In en, this message translates to:
  /// **'No verified developer feature explanation found. Describe below what feature you were trying to use if you want Deni to check relevance.'**
  String get companionSection4Fallback;

  /// Section 5 heading in Companion permission explanation
  ///
  /// In en, this message translates to:
  /// **'5. What remains unknown'**
  String get companionSection5Title;

  /// Section 6 heading in Companion permission explanation
  ///
  /// In en, this message translates to:
  /// **'6. Questions you can ask Deni'**
  String get companionSection6Title;

  /// Button to attach a privacy policy in Companion
  ///
  /// In en, this message translates to:
  /// **'Add privacy policy'**
  String get companionAddPolicyBtn;

  /// Button to check an updated privacy policy in Companion
  ///
  /// In en, this message translates to:
  /// **'Check updated privacy policy'**
  String get companionCheckUpdatedPolicyBtn;

  /// Title override for intake sheet launched from Companion
  ///
  /// In en, this message translates to:
  /// **'Verify policy for {appName}'**
  String companionVerifyPolicyTitle(String appName);

  /// Input label for optional feature context
  ///
  /// In en, this message translates to:
  /// **'Feature you were using (optional)'**
  String get companionFeatureFieldLabel;

  /// Input hint for optional feature context
  ///
  /// In en, this message translates to:
  /// **'e.g., scanning a QR code, recording voice practice'**
  String get companionFeatureFieldHint;

  /// Input label for asking Deni a question in Companion
  ///
  /// In en, this message translates to:
  /// **'Ask Deni a question'**
  String get companionQuestionFieldLabel;

  /// Input hint for asking Deni a question in Companion
  ///
  /// In en, this message translates to:
  /// **'What happens if I deny this permission?'**
  String get companionQuestionFieldHint;

  /// Badge title when Companion policy review is saved locally
  ///
  /// In en, this message translates to:
  /// **'Saved in Enprive Receipts'**
  String get companionReceiptSavedTitle;

  /// Label when Companion policy review is only in the current session
  ///
  /// In en, this message translates to:
  /// **'Review not saved to Enprive yet'**
  String get companionReceiptUnsavedTitle;

  /// Description when Companion review is saved locally
  ///
  /// In en, this message translates to:
  /// **'Stored locally in your Enprive Receipts archive.'**
  String get companionReceiptSavedBody;

  /// Warning for an unsaved updated review draft in Companion
  ///
  /// In en, this message translates to:
  /// **'Updated policy review kept in this session only. Leaving Companion discards this draft and keeps your saved receipt unchanged.'**
  String get companionReceiptUpdatedUnsavedBody;

  /// Warning for an unsaved review draft in Companion
  ///
  /// In en, this message translates to:
  /// **'Kept in this session only. Leaving Companion will discard it unless you save it.'**
  String get companionReceiptUnsavedBody;

  /// Button to save Companion policy review to local Receipts
  ///
  /// In en, this message translates to:
  /// **'Save receipt to Enprive'**
  String get companionSaveReceiptBtn;

  /// Error message when saving a Companion receipt fails
  ///
  /// In en, this message translates to:
  /// **'Could not save receipt. Kept in this session: try again.'**
  String get companionSaveReceiptFailed;

  /// Snackbar after saving a receipt from Companion
  ///
  /// In en, this message translates to:
  /// **'Saved to local Receipts.'**
  String get companionSavedLocalReceiptsSnack;

  /// Primary bottom button returning to the caller app
  ///
  /// In en, this message translates to:
  /// **'Done · Return to {appName}'**
  String companionDoneReturnToApp(String appName);

  /// Bottom button returning to the previous app
  ///
  /// In en, this message translates to:
  /// **'Done · Return to previous app'**
  String get companionDoneReturnToPrev;

  /// Secondary button to open the full Enprive app from Quick Settings Companion
  ///
  /// In en, this message translates to:
  /// **'Open full Enprive app'**
  String get companionOpenFullAppBtn;

  /// Snackbar when Companion cloud policy analysis times out
  ///
  /// In en, this message translates to:
  /// **'Cloud analysis took too long and was stopped before completing.'**
  String get companionCloudTimeoutSnack;

  /// Snackbar when Companion policy analysis is cancelled
  ///
  /// In en, this message translates to:
  /// **'Analysis cancelled.'**
  String get companionAnalysisCancelledSnack;

  /// Snackbar when Companion cloud question times out
  ///
  /// In en, this message translates to:
  /// **'Cloud answer timed out cleanly.'**
  String get companionCloudAnswerTimeoutSnack;

  /// Snackbar when Companion question is cancelled
  ///
  /// In en, this message translates to:
  /// **'Question cancelled.'**
  String get companionQuestionCancelledSnack;

  /// Snackbar after adding tile from Companion
  ///
  /// In en, this message translates to:
  /// **'Enprive Check added to Android Quick Settings.'**
  String get companionTileAddedSnack;

  /// Snackbar when tile is already added in Companion
  ///
  /// In en, this message translates to:
  /// **'Enprive Check is already in your Quick Settings.'**
  String get companionTileAlreadyAddedSnack;

  /// Snackbar when tile request is dismissed in Companion
  ///
  /// In en, this message translates to:
  /// **'Tile request dismissed. You can add it anytime from Settings or Quick Settings Edit.'**
  String get companionTileDeclinedSnack;

  /// Snackbar with manual Quick Settings instructions in Companion
  ///
  /// In en, this message translates to:
  /// **'Swipe down Quick Settings twice, tap Edit, and drag Enprive Check into your tiles.'**
  String get companionTileManualSnack;

  /// Snackbar when system Quick Settings prompt is unavailable in Companion
  ///
  /// In en, this message translates to:
  /// **'Android could not show the Quick Settings prompt on this device. You can drag Enprive Check manually from Quick Settings Edit.'**
  String get companionTileUnavailableSnack;

  /// Fallback note explaining Usage Access is optional
  ///
  /// In en, this message translates to:
  /// **'Usage Access is optional. You can choose an app manually or allow Usage Access for one-tap identification.'**
  String get companionUsageOptionalReason;

  /// Permission title for ACCESS_FINE_LOCATION
  ///
  /// In en, this message translates to:
  /// **'Precise location'**
  String get companionPermPreciseLocation;

  /// Permission title for ACCESS_BACKGROUND_LOCATION
  ///
  /// In en, this message translates to:
  /// **'Background location'**
  String get companionPermBackgroundLocation;

  /// Permission title for CAMERA
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get companionPermCamera;

  /// Permission title for RECORD_AUDIO
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get companionPermMicrophone;

  /// Permission title for AD_ID
  ///
  /// In en, this message translates to:
  /// **'Google Advertising ID'**
  String get companionPermAdId;

  /// Fallback explanation for a declared Android permission
  ///
  /// In en, this message translates to:
  /// **'Android permission ({permission}) declared by {appName}.'**
  String companionPermDeclaredBy(String permission, String appName);

  /// Grant status note for Advertising ID
  ///
  /// In en, this message translates to:
  /// **'Listed by app · Ad ID'**
  String get companionPermStatusAdId;

  /// Grant status note when a permission is allowed
  ///
  /// In en, this message translates to:
  /// **'Listed by app · Allowed'**
  String get companionPermStatusAllowed;

  /// Grant status note when a permission is not allowed
  ///
  /// In en, this message translates to:
  /// **'Listed by app · Not allowed'**
  String get companionPermStatusNotAllowed;

  /// Guided permission category chip for Location
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get guidedCatLocation;

  /// Guided permission category chip for Contacts
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get guidedCatContacts;

  /// Guided permission category chip for Photos and media
  ///
  /// In en, this message translates to:
  /// **'Photos and media'**
  String get guidedCatPhotosMedia;

  /// Guided permission category chip for Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get guidedCatNotifications;

  /// Guided permission category chip for Nearby devices
  ///
  /// In en, this message translates to:
  /// **'Nearby devices'**
  String get guidedCatNearbyDevices;

  /// Guided permission category chip for Calendar
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get guidedCatCalendar;

  /// Guided permission category chip for Phone
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get guidedCatPhone;

  /// Guided permission category chip for SMS
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get guidedCatSms;

  /// Localized fallback reason when Usage Access is disabled
  ///
  /// In en, this message translates to:
  /// **'Usage Access has not been enabled in Android Settings.'**
  String get companionFallbackUsageNotEnabled;

  /// Localized fallback reason when UsageStatsManager is unavailable
  ///
  /// In en, this message translates to:
  /// **'Android UsageStatsManager is unavailable.'**
  String get companionFallbackUsageUnavailable;

  /// Localized fallback reason when only transient Android UI was seen
  ///
  /// In en, this message translates to:
  /// **'Only Android system or permission prompt UI appeared in recent usage events; choose the app manually.'**
  String get companionFallbackTransientUi;

  /// Localized fallback reason when Android package visibility hides the app
  ///
  /// In en, this message translates to:
  /// **'The most recently active app cannot be inspected under Android package visibility restrictions. Please choose an app from the list or paste its policy.'**
  String get companionFallbackVisibilityRestricted;

  /// Localized fallback reason when device is locked
  ///
  /// In en, this message translates to:
  /// **'Unlock your device before viewing app context.'**
  String get companionFallbackUnlockRequired;

  /// Reason shown in CloudConsentSheet when policy exceeds on-device limit
  ///
  /// In en, this message translates to:
  /// **'This policy is too detailed for on-device AI processing.'**
  String get consentReasonPolicyTooDetailed;

  /// Reason shown in CloudConsentSheet when finding excerpt exceeds on-device limit
  ///
  /// In en, this message translates to:
  /// **'This finding excerpt is too detailed for on-device AI processing.'**
  String get consentReasonExcerptTooDetailed;

  /// Reason shown in CloudConsentSheet when on-device AI is unavailable
  ///
  /// In en, this message translates to:
  /// **'On-device AI is unavailable on this phone right now.'**
  String get consentReasonOnDeviceUnavailable;

  /// Reason shown in CloudConsentSheet when on-device AI cannot answer
  ///
  /// In en, this message translates to:
  /// **'On-device AI could not answer from this device right now.'**
  String get consentReasonOnDeviceCannotAnswer;

  /// Reason shown when voice summary findings exceed on-device limits
  ///
  /// In en, this message translates to:
  /// **'These verified findings exceed on-device summary limits. You can use the offline summary now or send the redacted findings to Cloud AI once.'**
  String get consentReasonVoiceTooLong;

  /// Reason shown when voice summary falls back to offline summary
  ///
  /// In en, this message translates to:
  /// **'On-device AI is unavailable on this phone right now. Showing Enprive\'s offline plain-language summary.'**
  String get consentReasonVoiceUnavailable;

  /// Reason shown when on-device voice summary times out
  ///
  /// In en, this message translates to:
  /// **'On-device summary timed out. Showing Enprive\'s offline plain-language summary.'**
  String get consentReasonVoiceTimedOut;

  /// Title of exit confirmation sheet for an unsaved review
  ///
  /// In en, this message translates to:
  /// **'Save this privacy review?'**
  String get unsavedExitTitle;

  /// Explanation when closing an unsaved update to a saved receipt
  ///
  /// In en, this message translates to:
  /// **'Unsaved reviews are discarded when you close this screen, so nothing is stored on your phone without your choice. Your original saved receipt will remain unchanged.'**
  String get unsavedExitModifiedBody;

  /// Explanation when closing an unsaved new review draft
  ///
  /// In en, this message translates to:
  /// **'Unsaved reviews are discarded when you close this screen, so nothing is stored on your phone without your choice.'**
  String get unsavedExitDraftBody;

  /// Button to discard unsaved review and exit
  ///
  /// In en, this message translates to:
  /// **'Discard without saving'**
  String get unsavedExitDiscardBtn;

  /// Button to cancel exiting and keep reviewing
  ///
  /// In en, this message translates to:
  /// **'Continue reviewing'**
  String get unsavedExitContinueBtn;

  /// Sheet title when updating a privacy policy for an existing subject
  ///
  /// In en, this message translates to:
  /// **'Update privacy policy for {title}'**
  String updatePrivacyPolicyForTitle(String title);

  /// Error shown if saving a receipt fails
  ///
  /// In en, this message translates to:
  /// **'Could not save receipt. Your review draft is still open.'**
  String get reviewSaveFailedError;

  /// Snackbar after deleting a saved receipt
  ///
  /// In en, this message translates to:
  /// **'Removed from saved receipts.'**
  String get reviewRemovedFromReceiptsSnack;

  /// Snackbar when deleting a saved receipt fails
  ///
  /// In en, this message translates to:
  /// **'Could not remove saved receipt.'**
  String get reviewRemoveFailedSnack;

  /// Banner title when viewing an unsaved updated draft of a saved receipt
  ///
  /// In en, this message translates to:
  /// **'New draft from saved receipt'**
  String get reviewModifiedDraftTitle;

  /// Banner body when viewing an unsaved updated draft of a saved receipt
  ///
  /// In en, this message translates to:
  /// **'Save to Receipts to keep this updated review: your original saved receipt remains unchanged.'**
  String get reviewModifiedDraftBody;

  /// Action button to retry saving a receipt
  ///
  /// In en, this message translates to:
  /// **'Retry save'**
  String get btnRetrySave;

  /// Header for synthetic sample app permissions
  ///
  /// In en, this message translates to:
  /// **'Sample permissions ({badge})'**
  String samplePermissionsHeader(String badge);

  /// Source kind label for a fetched URL
  ///
  /// In en, this message translates to:
  /// **'Public web link'**
  String get sourceKindUrl;

  /// Source kind label for a local PDF file
  ///
  /// In en, this message translates to:
  /// **'Local PDF file'**
  String get sourceKindPdf;

  /// Source kind label for a local DOCX file
  ///
  /// In en, this message translates to:
  /// **'Local Word (DOCX) file'**
  String get sourceKindDocx;

  /// Source kind label for a local text file
  ///
  /// In en, this message translates to:
  /// **'Local text file'**
  String get sourceKindTextFile;

  /// Source kind label for Android shared text
  ///
  /// In en, this message translates to:
  /// **'Shared text'**
  String get sourceKindSharedText;

  /// Source kind label for selected text
  ///
  /// In en, this message translates to:
  /// **'Selected text'**
  String get sourceKindSelectedText;

  /// Source kind label for a built-in sample app
  ///
  /// In en, this message translates to:
  /// **'Sample app'**
  String get sourceKindSampleApp;

  /// Source kind label for phone permissions inspection
  ///
  /// In en, this message translates to:
  /// **'Phone permissions'**
  String get sourceKindPhonePermissions;

  /// Source kind label for pasted policy text
  ///
  /// In en, this message translates to:
  /// **'Pasted text'**
  String get sourceKindPastedText;

  /// Extraction status when text was extracted locally
  ///
  /// In en, this message translates to:
  /// **'Read on this phone'**
  String get extractionStatusExtracted;

  /// Extraction status when text was provided directly
  ///
  /// In en, this message translates to:
  /// **'Provided on this phone'**
  String get extractionStatusNone;

  /// Extraction status for unsupported file types
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type'**
  String get extractionStatusUnsupported;

  /// Extraction status when file exceeds size limit
  ///
  /// In en, this message translates to:
  /// **'File too large'**
  String get extractionStatusTooLarge;

  /// Extraction status when file has no extractable text
  ///
  /// In en, this message translates to:
  /// **'No readable text'**
  String get extractionStatusEmpty;

  /// Extraction status when reading file fails
  ///
  /// In en, this message translates to:
  /// **'Could not read file'**
  String get extractionStatusReadError;

  /// Extraction status for password-protected documents
  ///
  /// In en, this message translates to:
  /// **'Password-protected'**
  String get extractionStatusPasswordProtected;

  /// Extraction status when file access is denied
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get extractionStatusPermissionDenied;

  /// Extraction status when extraction was cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get extractionStatusCancelled;

  /// Timestamp row inside Advanced details
  ///
  /// In en, this message translates to:
  /// **'Checked at: {timestamp}'**
  String advancedDetailsCheckedAt(String timestamp);

  /// Canonical URL row inside Advanced details
  ///
  /// In en, this message translates to:
  /// **'Canonical URL: {url}'**
  String advancedDetailsCanonicalUrl(String url);

  /// Redirect origin row inside Advanced details
  ///
  /// In en, this message translates to:
  /// **'Redirected from: {url}'**
  String advancedDetailsRedirectedFrom(String url);

  /// Filename label inside Advanced details
  ///
  /// In en, this message translates to:
  /// **'File: {filename}'**
  String advancedDetailsFileLine(String filename);

  /// Extraction status suffix inside Advanced details
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String advancedDetailsStatusSuffix(String status);

  /// SHA-256 hash row inside Advanced details
  ///
  /// In en, this message translates to:
  /// **'SHA-256 source hash: {hash}'**
  String advancedDetailsSha256Hash(String hash);

  /// Accessibility label for the bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'Primary navigation'**
  String get semanticsPrimaryNavigation;

  /// Accessibility label for the inference provenance chip
  ///
  /// In en, this message translates to:
  /// **'Processing location: {label}'**
  String semanticsProcessingLocation(String label);

  /// Default accessibility label for the interactive Deni mascot
  ///
  /// In en, this message translates to:
  /// **'Deni, your privacy guide'**
  String get semanticsDeniMascot;

  /// Default header for collapsible policy quote box
  ///
  /// In en, this message translates to:
  /// **'Exact Policy Excerpt'**
  String get quoteCollapsibleDefaultHeader;
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
