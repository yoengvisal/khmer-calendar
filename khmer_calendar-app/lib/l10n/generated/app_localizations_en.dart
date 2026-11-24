// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Khmer Calendar';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navHolidays => 'Holidays';

  @override
  String get navSettings => 'Settings';

  @override
  String get today => 'Today';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get previousYear => 'Previous year';

  @override
  String get nextYear => 'Next year';

  @override
  String get holyDay => 'Holy day (Thngai Sel)';

  @override
  String get dayOff => 'Day off';

  @override
  String beYear(String year) {
    return 'BE $year';
  }

  @override
  String animalYear(String animal) {
    return 'Year of the $animal';
  }

  @override
  String holidaysTitle(String year) {
    return 'Holidays $year';
  }

  @override
  String get noEventsForYear =>
      'No published holidays or events for this year yet.';

  @override
  String get offlineBanner => 'Offline — showing saved data';

  @override
  String get eventsUnavailableBanner =>
      'Couldn\'t load events. Lunar dates are still shown.';

  @override
  String get errorNetwork =>
      'No internet connection. Check your connection and try again.';

  @override
  String get errorTimeout =>
      'The server is taking too long to respond. Please try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Please try again later.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorValidation => 'The request was invalid. Please try again.';

  @override
  String get errorUnknown => 'Something unexpected happened. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageKhmer => 'ខ្មែរ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'Version';

  @override
  String get environment => 'Environment';

  @override
  String get dayDetailEvents => 'Events';

  @override
  String get dayDetailNoEvents => 'No events on this day.';

  @override
  String get lunarDate => 'Lunar date';

  @override
  String get pastEvent => 'Past';

  @override
  String eventDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get categoryPublicHoliday => 'Public holiday';

  @override
  String get categoryBuddhistHolyDay => 'Buddhist holy day';

  @override
  String get categoryCultural => 'Cultural';

  @override
  String get categoryObservance => 'Observance';

  @override
  String get categoryOther => 'Event';

  @override
  String get legendEvent => 'Event';

  @override
  String get legendHoliday => 'Public holiday (day off)';

  @override
  String get legendHolyDay => 'Holy day';

  @override
  String get configErrorTitle => 'Configuration error';

  @override
  String get nextHoliday => 'Next holiday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String inDays(String days) {
    return 'in $days days';
  }

  @override
  String get ongoing => 'Happening now';

  @override
  String get filterAll => 'All';

  @override
  String get navEvents => 'Events';

  @override
  String get navWeather => 'Weather';

  @override
  String get navTools => 'Tools';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search holidays and events';

  @override
  String get noResults => 'No results';

  @override
  String get cityPhnomPenh => 'Phnom Penh';

  @override
  String get weatherClear => 'Clear';

  @override
  String get weatherPartlyCloudy => 'Partly Cloudy';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherFog => 'Fog';

  @override
  String get weatherDrizzle => 'Drizzle';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherThunderstorm => 'Thunderstorm';

  @override
  String highLow(String high, String low) {
    return 'H: $high°  L: $low°';
  }

  @override
  String rainChance(String percent) {
    return 'Rain $percent%';
  }

  @override
  String get weatherForecast => '7-day forecast';

  @override
  String get weatherAttribution => 'Weather data by Open-Meteo.com';

  @override
  String get weatherUnavailable => 'Weather unavailable';

  @override
  String get waxingMoon => 'Waxing Moon';

  @override
  String get waningMoon => 'Waning Moon';

  @override
  String get legendPublicHoliday => 'Public Holiday';

  @override
  String get legendBuddhistDay => 'Buddhist Day';

  @override
  String get legendMyEvent => 'My Event';

  @override
  String get legendOtherEvent => 'Other Event';

  @override
  String get tabHolidays => 'Holidays';

  @override
  String get tabMyEvents => 'My Events';

  @override
  String get addEvent => 'Add event';

  @override
  String get editEvent => 'Edit event';

  @override
  String get eventTitleLabel => 'Title';

  @override
  String get eventDateLabel => 'Date';

  @override
  String get eventNoteLabel => 'Note (optional)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get noMyEvents => 'No personal events yet. Tap + to add one.';

  @override
  String get eventDeleted => 'Event deleted';

  @override
  String get undo => 'Undo';

  @override
  String get toolConverter => 'Date converter';

  @override
  String get toolConverterSub => 'Gregorian date → Khmer lunar date';

  @override
  String get toolNewYear => 'Khmer New Year';

  @override
  String get toolNewYearSub => 'Songkran date and time for any year';

  @override
  String get toolHolyDays => 'Holy days';

  @override
  String get toolHolyDaysSub => 'Buddhist holy days (Thngai Sel) by month';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get newYearStart => 'New Year begins (Moha Songkran)';

  @override
  String get newYearLerngSak => 'Last day (Lerng Sak)';

  @override
  String get newYearTime => 'Time';

  @override
  String get display => 'Display';

  @override
  String get showLunarDays => 'Show lunar days in calendar';

  @override
  String get themeDefaultSuffix => '(Default)';

  @override
  String get followDevice => 'Follow device setting';

  @override
  String get moreThemes => 'More Themes';

  @override
  String get themeKhmerLight => 'Khmer Light';

  @override
  String get themeKhmerNight => 'Khmer Night';

  @override
  String get themeLotus => 'Lotus';

  @override
  String get themeGreen => 'Green Nature';

  @override
  String get themeSunset => 'Sunset';

  @override
  String get themeRoyal => 'Royal Blue';
}
