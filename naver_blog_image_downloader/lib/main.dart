import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'amplifyconfiguration.dart';
import 'app.dart';
import 'data/repositories/cache_repository.dart';
import 'data/repositories/photo_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/file_download_service.dart';
import 'data/services/gallery_service.dart';
import 'data/services/local_storage_service.dart';
import 'ui/blog_input/view_model/blog_input_view_model.dart';
import 'ui/core/view_model/app_settings_view_model.dart';
import 'ui/download/view_model/download_view_model.dart';
import 'ui/photo_detail/view_model/photo_detail_view_model.dart';
import 'ui/photo_gallery/view_model/photo_gallery_view_model.dart';
import 'ui/settings/view_model/settings_view_model.dart';

/// 應用程式進入點，負責初始化 Amplify SDK 與依賴注入（DI），並啟動 [NaverPhotoApp]。
///
/// 使用 [MultiProvider] 建立三層依賴結構：
/// 1. **Service 層** — API 通訊（Amplify REST）、檔案下載、相簿存取
/// 2. **Repository 層** — 快取管理、照片操作的統一存取介面
/// 3. **ViewModel 層** — 各頁面的狀態管理
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // Service 層
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => FileDownloadService(Dio())),
        Provider(create: (_) => GalleryService()),
        Provider(create: (_) => LocalStorageService(prefs: prefs)),
        // Repository 層
        Provider(create: (_) => CacheRepository()),
        Provider(
          create: (context) => SettingsRepository(
            localStorageService: context.read<LocalStorageService>(),
          ),
        ),
        ProxyProvider4<
          ApiService,
          FileDownloadService,
          GalleryService,
          CacheRepository,
          PhotoRepository
        >(
          update: (_, api, download, gallery, cache, _) => PhotoRepository(
            apiService: api,
            fileDownloadService: download,
            galleryService: gallery,
            cacheRepository: cache,
          ),
        ),
        // ViewModel 層
        ChangeNotifierProvider(
          create: (context) {
            final vm = AppSettingsViewModel(
              settingsRepository: context.read<SettingsRepository>(),
            );
            vm.loadSettings();
            return vm;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => BlogInputViewModel(
            photoRepository: context.read<PhotoRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DownloadViewModel(
            photoRepository: context.read<PhotoRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PhotoGalleryViewModel(
            photoRepository: context.read<PhotoRepository>(),
            cacheRepository: context.read<CacheRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PhotoDetailViewModel(
            cacheRepository: context.read<CacheRepository>(),
            photoRepository: context.read<PhotoRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsViewModel(
            cacheRepository: context.read<CacheRepository>(),
          ),
        ),
      ],
      child: const NaverPhotoApp(),
    ),
  );
}

/// 初始化 Amplify SDK，註冊 REST API 插件。
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
