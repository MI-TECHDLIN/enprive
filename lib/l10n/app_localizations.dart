import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('en'),
    Locale('ko'),
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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
