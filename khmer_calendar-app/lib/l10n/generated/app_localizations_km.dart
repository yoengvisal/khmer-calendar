// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'ប្រតិទិនខ្មែរ';

  @override
  String get navCalendar => 'ប្រតិទិន';

  @override
  String get navHolidays => 'ថ្ងៃឈប់សម្រាក';

  @override
  String get navSettings => 'ការកំណត់';

  @override
  String get today => 'ថ្ងៃនេះ';

  @override
  String get previousMonth => 'ខែមុន';

  @override
  String get nextMonth => 'ខែបន្ទាប់';

  @override
  String get previousYear => 'ឆ្នាំមុន';

  @override
  String get nextYear => 'ឆ្នាំបន្ទាប់';

  @override
  String get holyDay => 'ថ្ងៃសីល';

  @override
  String get dayOff => 'ថ្ងៃឈប់សម្រាក';

  @override
  String beYear(String year) {
    return 'ព.ស. $year';
  }

  @override
  String animalYear(String animal) {
    return 'ឆ្នាំ$animal';
  }

  @override
  String holidaysTitle(String year) {
    return 'ថ្ងៃឈប់សម្រាក ឆ្នាំ$year';
  }

  @override
  String get noEventsForYear =>
      'មិនទាន់មានថ្ងៃឈប់សម្រាក ឬព្រឹត្តិការណ៍សម្រាប់ឆ្នាំនេះទេ។';

  @override
  String get offlineBanner =>
      'គ្មានអ៊ីនធឺណិត — កំពុងបង្ហាញទិន្នន័យដែលបានរក្សាទុក';

  @override
  String get eventsUnavailableBanner =>
      'មិនអាចផ្ទុកព្រឹត្តិការណ៍បានទេ។ ថ្ងៃចន្ទគតិនៅតែបង្ហាញ។';

  @override
  String get errorNetwork =>
      'គ្មានការតភ្ជាប់អ៊ីនធឺណិត។ សូមពិនិត្យការតភ្ជាប់ ហើយព្យាយាមម្តងទៀត។';

  @override
  String get errorTimeout => 'ម៉ាស៊ីនមេឆ្លើយតបយឺតពេក។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get errorServer => 'មានបញ្ហាពីខាងយើង។ សូមព្យាយាមម្តងទៀតនៅពេលក្រោយ។';

  @override
  String get errorNotFound => 'រកមិនឃើញអ្វីដែលអ្នកកំពុងស្វែងរកទេ។';

  @override
  String get errorValidation => 'សំណើមិនត្រឹមត្រូវ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get errorUnknown => 'មានបញ្ហាមិនរំពឹងទុក។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get retry => 'ព្យាយាមម្តងទៀត';

  @override
  String get settingsTitle => 'ការកំណត់';

  @override
  String get language => 'ភាសា';

  @override
  String get languageKhmer => 'ខ្មែរ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get theme => 'រូបរាង';

  @override
  String get themeSystem => 'តាមប្រព័ន្ធ';

  @override
  String get themeLight => 'ភ្លឺ';

  @override
  String get themeDark => 'ងងឹត';

  @override
  String get about => 'អំពីកម្មវិធី';

  @override
  String get appVersion => 'កំណែ';

  @override
  String get environment => 'បរិស្ថាន';

  @override
  String get dayDetailEvents => 'ព្រឹត្តិការណ៍';

  @override
  String get dayDetailNoEvents => 'គ្មានព្រឹត្តិការណ៍នៅថ្ងៃនេះទេ។';

  @override
  String get lunarDate => 'ថ្ងៃចន្ទគតិ';

  @override
  String get pastEvent => 'កន្លងផុត';

  @override
  String eventDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ថ្ងៃ',
    );
    return '$_temp0';
  }

  @override
  String get categoryPublicHoliday => 'ថ្ងៃឈប់សម្រាកសាធារណៈ';

  @override
  String get categoryBuddhistHolyDay => 'ថ្ងៃបុណ្យព្រះពុទ្ធសាសនា';

  @override
  String get categoryCultural => 'វប្បធម៌';

  @override
  String get categoryObservance => 'ទិវា';

  @override
  String get categoryOther => 'ព្រឹត្តិការណ៍';

  @override
  String get legendEvent => 'ព្រឹត្តិការណ៍';

  @override
  String get legendHoliday => 'ថ្ងៃឈប់សម្រាក';

  @override
  String get legendHolyDay => 'ថ្ងៃសីល';

  @override
  String get configErrorTitle => 'កំហុសការកំណត់រចនាសម្ព័ន្ធ';

  @override
  String get nextHoliday => 'ថ្ងៃបុណ្យបន្ទាប់';

  @override
  String get tomorrow => 'ថ្ងៃស្អែក';

  @override
  String inDays(String days) {
    return '$days ថ្ងៃទៀត';
  }

  @override
  String get ongoing => 'កំពុងប្រារព្ធ';

  @override
  String get filterAll => 'ទាំងអស់';

  @override
  String get navEvents => 'ព្រឹត្តិការណ៍';

  @override
  String get navWeather => 'អាកាសធាតុ';

  @override
  String get navTools => 'ឧបករណ៍';

  @override
  String get search => 'ស្វែងរក';

  @override
  String get searchHint => 'ស្វែងរកថ្ងៃបុណ្យ និងព្រឹត្តិការណ៍';

  @override
  String get noResults => 'រកមិនឃើញ';

  @override
  String get cityPhnomPenh => 'ភ្នំពេញ';

  @override
  String get weatherClear => 'មេឃស្រឡះ';

  @override
  String get weatherPartlyCloudy => 'មានពពកខ្លះ';

  @override
  String get weatherCloudy => 'មានពពក';

  @override
  String get weatherFog => 'អ័ព្ទ';

  @override
  String get weatherDrizzle => 'ភ្លៀងរលឹម';

  @override
  String get weatherRain => 'ភ្លៀង';

  @override
  String get weatherThunderstorm => 'ផ្គររន្ទះ';

  @override
  String highLow(String high, String low) {
    return 'ខ្ពស់ $high°  ទាប $low°';
  }

  @override
  String rainChance(String percent) {
    return 'ភ្លៀង $percent%';
  }

  @override
  String get weatherForecast => 'ការព្យាករណ៍ ៧ ថ្ងៃ';

  @override
  String get weatherAttribution => 'ទិន្នន័យអាកាសធាតុពី Open-Meteo.com';

  @override
  String get weatherUnavailable => 'មិនអាចទាញយកអាកាសធាតុបាន';

  @override
  String get waxingMoon => 'ព្រះចន្ទខាងកើត';

  @override
  String get waningMoon => 'ព្រះចន្ទខាងរោច';

  @override
  String get legendPublicHoliday => 'ថ្ងៃឈប់សម្រាក';

  @override
  String get legendBuddhistDay => 'ថ្ងៃសីល';

  @override
  String get legendMyEvent => 'ព្រឹត្តិការណ៍ខ្ញុំ';

  @override
  String get legendOtherEvent => 'ព្រឹត្តិការណ៍ផ្សេង';

  @override
  String get tabHolidays => 'ថ្ងៃបុណ្យ';

  @override
  String get tabMyEvents => 'ព្រឹត្តិការណ៍ខ្ញុំ';

  @override
  String get addEvent => 'បន្ថែមព្រឹត្តិការណ៍';

  @override
  String get editEvent => 'កែព្រឹត្តិការណ៍';

  @override
  String get eventTitleLabel => 'ចំណងជើង';

  @override
  String get eventDateLabel => 'កាលបរិច្ឆេទ';

  @override
  String get eventNoteLabel => 'កំណត់ចំណាំ (ស្រេចចិត្ត)';

  @override
  String get save => 'រក្សាទុក';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get delete => 'លុប';

  @override
  String get titleRequired => 'សូមបញ្ចូលចំណងជើង';

  @override
  String get noMyEvents =>
      'មិនទាន់មានព្រឹត្តិការណ៍ផ្ទាល់ខ្លួនទេ។ ចុច + ដើម្បីបន្ថែម។';

  @override
  String get eventDeleted => 'បានលុបព្រឹត្តិការណ៍';

  @override
  String get undo => 'មិនធ្វើវិញ';

  @override
  String get toolConverter => 'បម្លែងកាលបរិច្ឆេទ';

  @override
  String get toolConverterSub => 'ថ្ងៃសុរិយគតិ → ថ្ងៃចន្ទគតិ';

  @override
  String get toolNewYear => 'ចូលឆ្នាំខ្មែរ';

  @override
  String get toolNewYearSub => 'ថ្ងៃ និងម៉ោងចូលឆ្នាំ គ្រប់ឆ្នាំ';

  @override
  String get toolHolyDays => 'ថ្ងៃសីល';

  @override
  String get toolHolyDaysSub => 'ថ្ងៃសីលតាមខែ';

  @override
  String get pickDate => 'ជ្រើសរើសកាលបរិច្ឆេទ';

  @override
  String get newYearStart => 'ចូលឆ្នាំ (មហាសង្ក្រាន្ត)';

  @override
  String get newYearLerngSak => 'ថ្ងៃឡើងស័ក';

  @override
  String get newYearTime => 'ម៉ោង';

  @override
  String get display => 'ការបង្ហាញ';

  @override
  String get showLunarDays => 'បង្ហាញថ្ងៃចន្ទគតិក្នុងប្រតិទិន';

  @override
  String get themeDefaultSuffix => '(លំនាំដើម)';

  @override
  String get followDevice => 'តាមការកំណត់ទូរស័ព្ទ';

  @override
  String get moreThemes => 'រចនាប័ទ្មផ្សេងទៀត';

  @override
  String get themeKhmerLight => 'ខ្មែរភ្លឺ';

  @override
  String get themeKhmerNight => 'រាត្រីខ្មែរ';

  @override
  String get themeLotus => 'ផ្កាឈូក';

  @override
  String get themeGreen => 'ធម្មជាតិបៃតង';

  @override
  String get themeSunset => 'ថ្ងៃលិច';

  @override
  String get themeRoyal => 'ខៀវរាជ';

  @override
  String get themeOcean => 'មហាសមុទ្រ';

  @override
  String get themePastel => 'ពណ៌ស្រាល';

  @override
  String get themeAurora => 'ពន្លឺប៉ូល';

  @override
  String get themeKitty => 'ឆ្មាតូច';

  @override
  String get themePuppy => 'កូនឆ្កែ';

  @override
  String get themeBuddha => 'ព្រះពុទ្ធ';
}
