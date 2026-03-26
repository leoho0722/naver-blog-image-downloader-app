import 'dart:ui';

/// 應用程式支援的語系列舉，包含對應的 [Locale] 物件與原生語言名稱。
enum SupportedLocale {
  /// 繁體中文。
  zhTW(Locale('zh', 'TW'), '繁體中文'),

  /// 英文。
  en(Locale('en'), 'English'),

  /// 日文。
  ja(Locale('ja'), '日本語'),

  /// 韓文。
  ko(Locale('ko'), '한국어');

  /// 建立 [SupportedLocale]。
  const SupportedLocale(this.locale, this.label);

  /// 對應的 [Locale] 物件。
  final Locale locale;

  /// 該語言的原生名稱（不做 l10n）。
  final String label;
}
