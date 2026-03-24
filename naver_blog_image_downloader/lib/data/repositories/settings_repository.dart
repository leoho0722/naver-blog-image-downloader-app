import 'package:flutter/material.dart';

import '../../config/app_settings_keys.dart';
import '../../config/supported_locale.dart';
import '../../ui/core/result.dart';
import '../services/local_storage_service.dart';

/// 使用者偏好設定的 Repository，封裝 [LocalStorageService] 提供主題模式與語系的讀寫介面。
class SettingsRepository {
  /// 建立 [SettingsRepository]，需注入 [LocalStorageService]。
  SettingsRepository({required LocalStorageService localStorageService})
    : _storage = localStorageService;

  /// 注入的本機儲存服務，用於讀寫使用者偏好設定。
  final LocalStorageService _storage;

  /// 從持久化儲存載入主題模式，未設定時預設回傳 [ThemeMode.system]。
  Result<ThemeMode> loadThemeMode() {
    final value = _storage.getString(AppSettingsKeys.themeMode);
    final mode = switch (value) {
      'system' => ThemeMode.system,
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return Result.ok(mode);
  }

  /// 將主題模式持久化至儲存。
  Future<Result<void>> saveThemeMode(ThemeMode mode) async {
    await _storage.setString(AppSettingsKeys.themeMode, mode.name);
    return Result.ok(null);
  }

  /// 從持久化儲存載入語系，未設定時回傳 `null`（表示無明確偏好）。
  Result<SupportedLocale?> loadLocale() {
    final value = _storage.getString(AppSettingsKeys.locale);
    if (value == null) return Result.ok(null);
    final locale = SupportedLocale.values.where((e) => e.name == value);
    return Result.ok(locale.isEmpty ? null : locale.first);
  }

  /// 將語系持久化至儲存。
  Future<Result<void>> saveLocale(SupportedLocale locale) async {
    await _storage.setString(AppSettingsKeys.locale, locale.name);
    return Result.ok(null);
  }
}
