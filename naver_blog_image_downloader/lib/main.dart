import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'amplifyconfiguration.dart';
import 'app.dart';
import 'data/services/local_storage_service.dart';

/// 應用程式進入點，負責初始化 Amplify SDK 並啟動 [NaverPhotoApp]。
///
/// 依序執行 Flutter binding 初始化、Amplify SDK 配置與 [SharedPreferences] 載入，
/// 最後以 [ProviderScope] 建立 Riverpod 依賴注入容器，
/// 透過 `overrides` 注入預先初始化的 [SharedPreferences] 並啟動應用程式。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const NaverPhotoApp(),
    ),
  );
}

/// 初始化 Amplify SDK，註冊 REST API 插件。
///
/// 若 Amplify 已經初始化過（[AmplifyAlreadyConfiguredException]），
/// 則靜默忽略；其他例外則印出錯誤訊息。
Future<void> _configureAmplify() async {
  try {
    final apiPlugin = AmplifyAPI();
    await Amplify.addPlugins([apiPlugin]);
    await Amplify.configure(amplifyConfig);
    safePrint('Amplify 初始化成功');
  } on AmplifyAlreadyConfiguredException {
    safePrint('Amplify 已初始化，略過');
  } on Exception catch (e) {
    safePrint('Amplify 初始化失敗：$e');
  }
}
