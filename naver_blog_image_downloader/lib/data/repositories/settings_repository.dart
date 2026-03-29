import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/app_settings_keys.dart';
import '../../config/supported_locale.dart';
import '../services/local_storage_service.dart';

part 'settings_repository.g.dart';

/// SettingsRepository 的 Riverpod provider（App 級單例）。
///
/// [ref] 為 Riverpod 的依賴參照，用於取得 [LocalStorageService] 實例。
/// 回傳注入 [LocalStorageService] 的 [SettingsRepository] 實例。
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(
    localStorageService: ref.watch(localStorageServiceProvider),
  );
}

/// 使用者偏好設定的 Repository，封裝 [LocalStorageService] 提供主題模式與語系的讀寫介面。
class SettingsRepository {
  /// 建立 [SettingsRepository]。
  ///
  /// - [localStorageService]：注入的本機儲存服務，用於讀寫使用者偏好設定。
  SettingsRepository({required LocalStorageService localStorageService})
    : _storage = localStorageService;

  /// 注入的本機儲存服務，用於讀寫使用者偏好設定。
  final LocalStorageService _storage;

  /// 從持久化儲存載入主題模式，未設定時預設回傳 [ThemeMode.system]。
  ///
  /// - 回傳：使用者先前儲存的 [ThemeMode]，若無記錄則回傳 [ThemeMode.system]。
  ThemeMode loadThemeMode() {
    final value = _storage.getString(AppSettingsKeys.themeMode);
    return switch (value) {
      'system' => ThemeMode.system,
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// 將主題模式持久化至儲存。
  ///
  /// - [mode]：要儲存的 [ThemeMode]（`system`、`light` 或 `dark`）。
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.setString(AppSettingsKeys.themeMode, mode.name);
  }

  /// 從持久化儲存載入語系，未設定時回傳 `null`（表示無明確偏好）。
  ///
  /// - 回傳：使用者先前儲存的 [SupportedLocale]，若無記錄或值無法識別則回傳 `null`。
  SupportedLocale? loadLocale() {
    final value = _storage.getString(AppSettingsKeys.locale);
    if (value == null) return null;
    final locale = SupportedLocale.values.where((e) => e.name == value);
    return locale.isEmpty ? null : locale.first;
  }

  /// 將語系持久化至儲存。
  ///
  /// - [locale]：要儲存的 [SupportedLocale]。
  Future<void> saveLocale(SupportedLocale locale) async {
    await _storage.setString(AppSettingsKeys.locale, locale.name);
  }
}
