import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supported_locale.dart';
import '../../../data/repositories/settings_repository.dart';

part 'app_settings_view_model.g.dart';

/// 全域偏好設定的不可變狀態，包含主題模式與語系。
class AppSettingsState {
  /// 建立 [AppSettingsState]。
  ///
  /// - [themeMode]：主題模式，預設為 [ThemeMode.system]。
  /// - [locale]：語系偏好，`null` 表示無明確偏好。
  const AppSettingsState({this.themeMode = ThemeMode.system, this.locale});

  /// 目前的主題模式，預設跟隨系統。
  final ThemeMode themeMode;

  /// 目前的語系，`null` 表示無明確偏好。
  final SupportedLocale? locale;

  /// 回傳複製後的新實例，僅覆寫指定欄位。
  ///
  /// - [themeMode]：若提供則覆寫主題模式。
  /// - [locale]：若提供則覆寫語系。
  ///
  /// 回傳新的 [AppSettingsState]，未指定的欄位保留原值。
  AppSettingsState copyWith({ThemeMode? themeMode, SupportedLocale? locale}) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  /// 比較兩個 [AppSettingsState] 是否相等。
  ///
  /// [other] 為比較對象。
  /// 當 [other] 同為 [AppSettingsState] 且 [themeMode] 與 [locale] 皆相同時回傳 `true`。
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsState &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          locale == other.locale;

  /// 基於 [themeMode] 與 [locale] 計算雜湊值。
  ///
  /// 回傳此實例的雜湊碼。
  @override
  int get hashCode => Object.hash(themeMode, locale);
}

/// 全域偏好設定的 ViewModel，管理主題模式與語系狀態。
///
/// 以 [AsyncNotifier] 實作，`build()` 負責從 [SettingsRepository] 載入初始設定。
@Riverpod(keepAlive: true)
class AppSettingsViewModel extends _$AppSettingsViewModel {
  /// 從 [SettingsRepository] 載入偏好設定並回傳初始 [AppSettingsState]。
  ///
  /// 回傳包含主題模式與語系偏好的 [AppSettingsState]。
  @override
  Future<AppSettingsState> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final themeMode = repo.loadThemeMode();
    final locale = repo.loadLocale();
    return AppSettingsState(themeMode: themeMode, locale: locale);
  }

  /// 切換主題模式並持久化。
  ///
  /// [mode] 為要套用的主題模式（系統 / 淺色 / 深色）。
  /// 採用樂觀更新：先更新 UI 狀態，再寫入持久化儲存。
  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveThemeMode(mode);
  }

  /// 切換語系並持久化。
  ///
  /// [locale] 為要套用的語系（繁體中文 / English / 日本語 / 한국어）。
  /// 採用樂觀更新：先更新 UI 狀態，再寫入持久化儲存。
  Future<void> setLocale(SupportedLocale locale) async {
    state = AsyncData(state.requireValue.copyWith(locale: locale));
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveLocale(locale);
  }
}
