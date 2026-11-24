/// Display language for the pure-Dart formatting helpers.
library;

enum UiLanguage {
  km,
  en,
  zh;

  /// Unknown codes fall back to English.
  static UiLanguage fromCode(String code) => switch (code) {
    'km' => UiLanguage.km,
    'zh' => UiLanguage.zh,
    _ => UiLanguage.en,
  };
}
