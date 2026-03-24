import 'package:flutter/material.dart';
import 'package:naver_blog_image_downloader/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'routing/app_router.dart';
import 'ui/core/view_model/app_settings_view_model.dart';

/// Naver Blog 照片下載器的根 Widget，負責設定主題、語系與路由。
class NaverPhotoApp extends StatelessWidget {
  /// 建立 [NaverPhotoApp]。
  const NaverPhotoApp({super.key});

  /// 建構應用程式的 [MaterialApp.router]，根據使用者偏好設定主題模式與語系。
  ///
  /// 回傳已設定主題、語系、本地化代理與路由的 [MaterialApp.router]。
  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsViewModel>();

    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appSettings.themeMode,
      locale: appSettings.locale?.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: appRouter,
    );
  }
}
