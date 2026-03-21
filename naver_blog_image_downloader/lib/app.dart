import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'routing/app_router.dart';

/// Naver Blog 照片下載器的根 Widget，負責設定主題與路由。
class NaverPhotoApp extends StatelessWidget {
  const NaverPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Naver Blog 照片下載器',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
