import 'package:flutter/material.dart';

import '../../../config/supported_locale.dart';
import '../../../data/repositories/settings_repository.dart';
import '../result.dart';

/// 全域偏好設定的 ViewModel，管理主題模式與語系狀態。
///
/// 註冊在 [MultiProvider] 最頂層，供 [MaterialApp] 響應式使用。
class AppSettingsViewModel extends ChangeNotifier {
  /// 建立 [AppSettingsViewModel]，需注入 [SettingsRepository]。
  AppSettingsViewModel({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository;

  /// 注入的偏好設定 Repository，用於讀寫主題模式與語系。
  final SettingsRepository _settingsRepository;

  /// 目前的主題模式，預設跟隨系統。
  ThemeMode _themeMode = ThemeMode.system;

  /// 目前的語系，`null` 表示無明確偏好。
  SupportedLocale? _locale;

  /// 目前的主題模式。
  ThemeMode get themeMode => _themeMode;

  /// 目前的語系。
  SupportedLocale? get locale => _locale;

  /// 從持久化儲存載入偏好設定。
  Future<void> loadSettings() async {
    final themeResult = _settingsRepository.loadThemeMode();
    switch (themeResult) {
      case Ok<ThemeMode>(:final value):
        _themeMode = value;
      case Error<ThemeMode>():
        break;
    }

    final localeResult = _settingsRepository.loadLocale();
    switch (localeResult) {
      case Ok<SupportedLocale?>(:final value):
        _locale = value;
      case Error<SupportedLocale?>():
        break;
    }

    notifyListeners();
  }

  /// 切換主題模式並持久化。
  ///
  /// [mode] 為要套用的主題模式（系統 / 淺色 / 深色）。
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _settingsRepository.saveThemeMode(mode);
  }

  /// 切換語系並持久化。
  ///
  /// [locale] 為要套用的語系（繁體中文 / English / 한국어）。
  Future<void> setLocale(SupportedLocale locale) async {
    _locale = locale;
    notifyListeners();
    await _settingsRepository.saveLocale(locale);
  }
}
