// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '高棉日历';

  @override
  String get navCalendar => '日历';

  @override
  String get navHolidays => '节假日';

  @override
  String get navSettings => '设置';

  @override
  String get today => '今天';

  @override
  String get previousMonth => '上个月';

  @override
  String get nextMonth => '下个月';

  @override
  String get previousYear => '上一年';

  @override
  String get nextYear => '下一年';

  @override
  String get holyDay => '持戒日（佛日）';

  @override
  String get dayOff => '放假';

  @override
  String beYear(String year) {
    return '佛历 $year';
  }

  @override
  String animalYear(String animal) {
    return '$animal年';
  }

  @override
  String holidaysTitle(String year) {
    return '$year年节假日';
  }

  @override
  String get noEventsForYear => '本年度尚无已发布的节假日或活动。';

  @override
  String get offlineBanner => '离线 — 显示已保存的数据';

  @override
  String get eventsUnavailableBanner => '无法加载活动，柬历日期仍正常显示。';

  @override
  String get errorNetwork => '没有网络连接。请检查网络后重试。';

  @override
  String get errorTimeout => '服务器响应超时，请重试。';

  @override
  String get errorServer => '服务器出现问题，请稍后再试。';

  @override
  String get errorNotFound => '找不到您要的内容。';

  @override
  String get errorValidation => '请求无效，请重试。';

  @override
  String get errorUnknown => '发生意外错误，请重试。';

  @override
  String get retry => '重试';

  @override
  String get settingsTitle => '设置';

  @override
  String get language => '语言';

  @override
  String get languageKhmer => 'ខ្មែរ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get about => '关于';

  @override
  String get appVersion => '版本';

  @override
  String get environment => '环境';

  @override
  String get dayDetailEvents => '活动';

  @override
  String get dayDetailNoEvents => '当天没有活动。';

  @override
  String get lunarDate => '柬历日期';

  @override
  String get pastEvent => '已过';

  @override
  String eventDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String get categoryPublicHoliday => '公共假日';

  @override
  String get categoryBuddhistHolyDay => '佛教节日';

  @override
  String get categoryCultural => '传统文化';

  @override
  String get categoryObservance => '纪念日';

  @override
  String get categoryOther => '活动';

  @override
  String get legendEvent => '活动';

  @override
  String get legendHoliday => '公共假日（放假）';

  @override
  String get legendHolyDay => '持戒日';

  @override
  String get configErrorTitle => '配置错误';

  @override
  String get nextHoliday => '下一个节日';

  @override
  String get tomorrow => '明天';

  @override
  String inDays(String days) {
    return '还有 $days 天';
  }

  @override
  String get ongoing => '进行中';

  @override
  String get filterAll => '全部';

  @override
  String get navEvents => '活动';

  @override
  String get navWeather => '天气';

  @override
  String get navTools => '工具';

  @override
  String get search => '搜索';

  @override
  String get searchHint => '搜索节日和活动';

  @override
  String get noResults => '没有结果';

  @override
  String get cityPhnomPenh => '金边';

  @override
  String get weatherClear => '晴';

  @override
  String get weatherPartlyCloudy => '局部多云';

  @override
  String get weatherCloudy => '多云';

  @override
  String get weatherFog => '雾';

  @override
  String get weatherDrizzle => '毛毛雨';

  @override
  String get weatherRain => '雨';

  @override
  String get weatherThunderstorm => '雷雨';

  @override
  String highLow(String high, String low) {
    return '最高 $high°  最低 $low°';
  }

  @override
  String rainChance(String percent) {
    return '降雨 $percent%';
  }

  @override
  String get weatherForecast => '7 天预报';

  @override
  String get weatherAttribution => '天气数据来自 Open-Meteo.com';

  @override
  String get weatherUnavailable => '暂时无法获取天气';

  @override
  String get waxingMoon => '盈月';

  @override
  String get waningMoon => '亏月';

  @override
  String get legendPublicHoliday => '公共假日';

  @override
  String get legendBuddhistDay => '持戒日';

  @override
  String get legendMyEvent => '我的活动';

  @override
  String get legendOtherEvent => '其他活动';

  @override
  String get tabHolidays => '节假日';

  @override
  String get tabMyEvents => '我的活动';

  @override
  String get addEvent => '添加活动';

  @override
  String get editEvent => '编辑活动';

  @override
  String get eventTitleLabel => '标题';

  @override
  String get eventDateLabel => '日期';

  @override
  String get eventNoteLabel => '备注（可选）';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get titleRequired => '请输入标题';

  @override
  String get noMyEvents => '还没有个人活动。点 + 添加。';

  @override
  String get eventDeleted => '活动已删除';

  @override
  String get undo => '撤销';

  @override
  String get toolConverter => '日期转换';

  @override
  String get toolConverterSub => '公历 → 柬历';

  @override
  String get toolNewYear => '柬埔寨新年';

  @override
  String get toolNewYearSub => '任意年份的新年日期与时间';

  @override
  String get toolHolyDays => '持戒日';

  @override
  String get toolHolyDaysSub => '按月查看持戒日';

  @override
  String get pickDate => '选择日期';

  @override
  String get newYearStart => '新年开始';

  @override
  String get newYearLerngSak => '新年最后一天';

  @override
  String get newYearTime => '时间';

  @override
  String get display => '显示';

  @override
  String get showLunarDays => '在日历中显示柬历日';

  @override
  String get themeDefaultSuffix => '（默认）';

  @override
  String get followDevice => '跟随设备设置';

  @override
  String get moreThemes => '更多主题';

  @override
  String get themeKhmerLight => '高棉晨光';

  @override
  String get themeKhmerNight => '高棉之夜';

  @override
  String get themeLotus => '莲花';

  @override
  String get themeGreen => '绿意自然';

  @override
  String get themeSunset => '日落';

  @override
  String get themeRoyal => '皇家蓝';

  @override
  String get themeOcean => '海洋';

  @override
  String get themePastel => '马卡龙';

  @override
  String get themeAurora => '极光';

  @override
  String get themeKitty => '小猫';

  @override
  String get themePuppy => '小狗';

  @override
  String get themeBuddha => '佛光';
}
