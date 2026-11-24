/// Khmer numeral helpers (pure Dart; usable from domain code).
library;

const List<String> _khmerDigits = [
  '០',
  '១',
  '២',
  '៣',
  '៤',
  '៥',
  '៦',
  '៧',
  '៨',
  '៩',
];

/// Replaces every ASCII digit in [value] with its Khmer numeral.
String toKhmerNumeral(Object value) => value.toString().replaceAllMapped(
  RegExp(r'\d'),
  (m) => _khmerDigits[int.parse(m.group(0)!)],
);
