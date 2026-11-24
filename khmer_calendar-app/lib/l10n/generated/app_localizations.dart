import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';
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
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('km'),
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Khmer Calendar'**
  String get appTitle;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navHolidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get navHolidays;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @previousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get previousYear;

  /// No description provided for @nextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get nextYear;

  /// No description provided for @holyDay.
  ///
  /// In en, this message translates to:
  /// **'Holy day (Thngai Sel)'**
  String get holyDay;

  /// No description provided for @dayOff.
  ///
  /// In en, this message translates to:
  /// **'Day off'**
  String get dayOff;

  /// No description provided for @beYear.
  ///
  /// In en, this message translates to:
  /// **'BE {year}'**
  String beYear(String year);

  /// No description provided for @animalYear.
  ///
  /// In en, this message translates to:
  /// **'Year of the {animal}'**
  String animalYear(String animal);

  /// No description provided for @holidaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Holidays {year}'**
  String holidaysTitle(String year);

  /// No description provided for @noEventsForYear.
  ///
  /// In en, this message translates to:
  /// **'No published holidays or events for this year yet.'**
  String get noEventsForYear;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved data'**
  String get offlineBanner;

  /// No description provided for @eventsUnavailableBanner.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load events. Lunar dates are still shown.'**
  String get eventsUnavailableBanner;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server is taking too long to respond. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'The request was invalid. Please try again.'**
  String get errorValidation;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened. Please try again.'**
  String get errorUnknown;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageKhmer.
  ///
  /// In en, this message translates to:
  /// **'ខ្មែរ'**
  String get languageKhmer;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @dayDetailEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get dayDetailEvents;

  /// No description provided for @dayDetailNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events on this day.'**
  String get dayDetailNoEvents;

  /// No description provided for @lunarDate.
  ///
  /// In en, this message translates to:
  /// **'Lunar date'**
  String get lunarDate;

  /// No description provided for @pastEvent.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get pastEvent;

  /// No description provided for @eventDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String eventDays(int count);

  /// No description provided for @categoryPublicHoliday.
  ///
  /// In en, this message translates to:
  /// **'Public holiday'**
  String get categoryPublicHoliday;

  /// No description provided for @categoryBuddhistHolyDay.
  ///
  /// In en, this message translates to:
  /// **'Buddhist holy day'**
  String get categoryBuddhistHolyDay;

  /// No description provided for @categoryCultural.
  ///
  /// In en, this message translates to:
  /// **'Cultural'**
  String get categoryCultural;

  /// No description provided for @categoryObservance.
  ///
  /// In en, this message translates to:
  /// **'Observance'**
  String get categoryObservance;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get categoryOther;

  /// No description provided for @legendEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get legendEvent;

  /// No description provided for @legendHoliday.
  ///
  /// In en, this message translates to:
  /// **'Public holiday (day off)'**
  String get legendHoliday;

  /// No description provided for @legendHolyDay.
  ///
  /// In en, this message translates to:
  /// **'Holy day'**
  String get legendHolyDay;

  /// No description provided for @configErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration error'**
  String get configErrorTitle;

  /// No description provided for @nextHoliday.
  ///
  /// In en, this message translates to:
  /// **'Next holiday'**
  String get nextHoliday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'in {days} days'**
  String inDays(String days);

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Happening now'**
  String get ongoing;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get navWeather;

  /// No description provided for @navTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search holidays and events'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @cityPhnomPenh.
  ///
  /// In en, this message translates to:
  /// **'Phnom Penh'**
  String get cityPhnomPenh;

  /// No description provided for @weatherClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherClear;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly Cloudy'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherCloudy;

  /// No description provided for @weatherFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get weatherFog;

  /// No description provided for @weatherDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get weatherDrizzle;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherRain;

  /// No description provided for @weatherThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get weatherThunderstorm;

  /// No description provided for @highLow.
  ///
  /// In en, this message translates to:
  /// **'H: {high}°  L: {low}°'**
  String highLow(String high, String low);

  /// No description provided for @rainChance.
  ///
  /// In en, this message translates to:
  /// **'Rain {percent}%'**
  String rainChance(String percent);

  /// No description provided for @weatherForecast.
  ///
  /// In en, this message translates to:
  /// **'7-day forecast'**
  String get weatherForecast;

  /// No description provided for @weatherAttribution.
  ///
  /// In en, this message translates to:
  /// **'Weather data by Open-Meteo.com'**
  String get weatherAttribution;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get weatherUnavailable;

  /// No description provided for @waxingMoon.
  ///
  /// In en, this message translates to:
  /// **'Waxing Moon'**
  String get waxingMoon;

  /// No description provided for @waningMoon.
  ///
  /// In en, this message translates to:
  /// **'Waning Moon'**
  String get waningMoon;

  /// No description provided for @legendPublicHoliday.
  ///
  /// In en, this message translates to:
  /// **'Public Holiday'**
  String get legendPublicHoliday;

  /// No description provided for @legendBuddhistDay.
  ///
  /// In en, this message translates to:
  /// **'Buddhist Day'**
  String get legendBuddhistDay;

  /// No description provided for @legendMyEvent.
  ///
  /// In en, this message translates to:
  /// **'My Event'**
  String get legendMyEvent;

  /// No description provided for @legendOtherEvent.
  ///
  /// In en, this message translates to:
  /// **'Other Event'**
  String get legendOtherEvent;

  /// No description provided for @tabHolidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get tabHolidays;

  /// No description provided for @tabMyEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get tabMyEvents;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// No description provided for @eventTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitleLabel;

  /// No description provided for @eventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDateLabel;

  /// No description provided for @eventNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get eventNoteLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// No description provided for @noMyEvents.
  ///
  /// In en, this message translates to:
  /// **'No personal events yet. Tap + to add one.'**
  String get noMyEvents;

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'Event deleted'**
  String get eventDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @toolConverter.
  ///
  /// In en, this message translates to:
  /// **'Date converter'**
  String get toolConverter;

  /// No description provided for @toolConverterSub.
  ///
  /// In en, this message translates to:
  /// **'Gregorian date → Khmer lunar date'**
  String get toolConverterSub;

  /// No description provided for @toolNewYear.
  ///
  /// In en, this message translates to:
  /// **'Khmer New Year'**
  String get toolNewYear;

  /// No description provided for @toolNewYearSub.
  ///
  /// In en, this message translates to:
  /// **'Songkran date and time for any year'**
  String get toolNewYearSub;

  /// No description provided for @toolHolyDays.
  ///
  /// In en, this message translates to:
  /// **'Holy days'**
  String get toolHolyDays;

  /// No description provided for @toolHolyDaysSub.
  ///
  /// In en, this message translates to:
  /// **'Buddhist holy days (Thngai Sel) by month'**
  String get toolHolyDaysSub;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @newYearStart.
  ///
  /// In en, this message translates to:
  /// **'New Year begins (Moha Songkran)'**
  String get newYearStart;

  /// No description provided for @newYearLerngSak.
  ///
  /// In en, this message translates to:
  /// **'Last day (Lerng Sak)'**
  String get newYearLerngSak;

  /// No description provided for @newYearTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get newYearTime;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @showLunarDays.
  ///
  /// In en, this message translates to:
  /// **'Show lunar days in calendar'**
  String get showLunarDays;

  /// No description provided for @themeDefaultSuffix.
  ///
  /// In en, this message translates to:
  /// **'(Default)'**
  String get themeDefaultSuffix;

  /// No description provided for @followDevice.
  ///
  /// In en, this message translates to:
  /// **'Follow device setting'**
  String get followDevice;

  /// No description provided for @moreThemes.
  ///
  /// In en, this message translates to:
  /// **'More Themes'**
  String get moreThemes;

  /// No description provided for @themeKhmerLight.
  ///
  /// In en, this message translates to:
  /// **'Khmer Light'**
  String get themeKhmerLight;

  /// No description provided for @themeKhmerNight.
  ///
  /// In en, this message translates to:
  /// **'Khmer Night'**
  String get themeKhmerNight;

  /// No description provided for @themeLotus.
  ///
  /// In en, this message translates to:
  /// **'Lotus'**
  String get themeLotus;

  /// No description provided for @themeGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Nature'**
  String get themeGreen;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeSunset;

  /// No description provided for @themeRoyal.
  ///
  /// In en, this message translates to:
  /// **'Royal Blue'**
  String get themeRoyal;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themePastel.
  ///
  /// In en, this message translates to:
  /// **'Pastel'**
  String get themePastel;

  /// No description provided for @themeAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get themeAurora;

  /// No description provided for @themeKitty.
  ///
  /// In en, this message translates to:
  /// **'Kitty'**
  String get themeKitty;

  /// No description provided for @themePuppy.
  ///
  /// In en, this message translates to:
  /// **'Puppy'**
  String get themePuppy;

  /// No description provided for @themeBuddha.
  ///
  /// In en, this message translates to:
  /// **'Buddha'**
  String get themeBuddha;
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
      <String>['en', 'km', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
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
