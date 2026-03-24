# provider-di Specification

## Purpose

TBD - created by archiving change 's030-provider-di'. Update Purpose after archive.

## Requirements

### Requirement: Service providers registered

The `lib/main.dart` file SHALL register the following services using `Provider` within a `MultiProvider`:

- `ApiService` SHALL be created with no arguments (uses Amplify config).
- `FileDownloadService` SHALL be created with a positional `Dio()` argument (i.e., `FileDownloadService(Dio())`).
- `GalleryService` SHALL be created with no arguments.
- `LocalStorageService` SHALL be created with a `SharedPreferences` instance obtained via `await SharedPreferences.getInstance()` before `runApp`.

#### Scenario: ApiService created with no arguments

- **WHEN** the `MultiProvider` initializes the `ApiService`
- **THEN** it SHALL create `ApiService()` with no constructor arguments (uses Amplify config)

#### Scenario: All four services are available in the widget tree

- **WHEN** a descendant widget calls `context.read<ApiService>()`
- **THEN** it SHALL receive a valid `ApiService` instance
- **AND** `context.read<FileDownloadService>()` SHALL return a valid instance
- **AND** `context.read<GalleryService>()` SHALL return a valid instance
- **AND** `context.read<LocalStorageService>()` SHALL return a valid instance


<!-- @trace
source: settings-theme-locale-l10n
updated: 2026-03-25
code:
  - naver_blog_image_downloader/lib/config/supported_locale.dart
  - naver_blog_image_downloader/lib/data/repositories/settings_repository.dart
  - naver_blog_image_downloader/lib/ui/core/view_model/app_settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/l10n/app_ja.arb
  - naver_blog_image_downloader/lib/l10n/app_zh_TW.arb
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/l10n/app_en.arb
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_ko.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/l10n/app_ko.arb
  - naver_blog_image_downloader/l10n.yaml
  - naver_blog_image_downloader/lib/l10n/app_localizations_en.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_zh.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/config/app_settings_keys.dart
  - naver_blog_image_downloader/lib/l10n/app_zh.arb
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_gallery/photo_gallery_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: Repository providers registered

The `lib/main.dart` file SHALL register repositories within the `MultiProvider`:

- `CacheRepository` SHALL be registered using `Provider`.
- `PhotoRepository` SHALL be registered using `ProxyProvider4`, injecting `ApiService`, `FileDownloadService`, `GalleryService`, and `CacheRepository` as dependencies.
- `SettingsRepository` SHALL be registered using `Provider`, injecting `LocalStorageService` via `context.read<LocalStorageService>()`.

#### Scenario: CacheRepository is available

- **WHEN** a descendant widget calls `context.read<CacheRepository>()`
- **THEN** it SHALL receive a valid `CacheRepository` instance

#### Scenario: PhotoRepository receives all four dependencies

- **WHEN** the `ProxyProvider4` creates the `PhotoRepository`
- **THEN** it SHALL inject `ApiService`, `FileDownloadService`, `GalleryService`, and `CacheRepository`

#### Scenario: SettingsRepository receives LocalStorageService

- **WHEN** the `Provider` creates the `SettingsRepository`
- **THEN** it SHALL inject `LocalStorageService` obtained from the widget tree


<!-- @trace
source: settings-theme-locale-l10n
updated: 2026-03-25
code:
  - naver_blog_image_downloader/lib/config/supported_locale.dart
  - naver_blog_image_downloader/lib/data/repositories/settings_repository.dart
  - naver_blog_image_downloader/lib/ui/core/view_model/app_settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/l10n/app_ja.arb
  - naver_blog_image_downloader/lib/l10n/app_zh_TW.arb
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/l10n/app_en.arb
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_ko.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/l10n/app_ko.arb
  - naver_blog_image_downloader/l10n.yaml
  - naver_blog_image_downloader/lib/l10n/app_localizations_en.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_zh.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/config/app_settings_keys.dart
  - naver_blog_image_downloader/lib/l10n/app_zh.arb
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_gallery/photo_gallery_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: ViewModel providers registered

The `MultiProvider` in `main.dart` SHALL register `PhotoDetailViewModel` with the following dependencies:
- `cacheRepository`: obtained via `context.read<CacheRepository>()`
- `photoRepository`: obtained via `context.read<PhotoRepository>()`

The `PhotoDetailViewModel` provider SHALL NOT inject `GalleryService` directly. Gallery operations SHALL be delegated through `PhotoRepository`.

#### Scenario: PhotoDetailViewModel DI wiring

- **GIVEN** the application starts
- **WHEN** `PhotoDetailViewModel` is created via `ChangeNotifierProvider`
- **THEN** the constructor SHALL receive `PhotoRepository` and `CacheRepository`
- **AND** SHALL NOT receive `GalleryService`


<!-- @trace
source: architecture-enum-state-refactor
updated: 2026-03-24
code:
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
tests:
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/photo_detail/photo_detail_view_model_test.dart
  - naver_blog_image_downloader/test/ui/photo_gallery/photo_gallery_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: NaverPhotoApp widget defined

The file `lib/app.dart` SHALL define a `NaverPhotoApp` class that extends `StatelessWidget`.

- The `build` method SHALL return a `MaterialApp.router`.
- The `routerConfig` property SHALL be set to the `appRouter` instance from `lib/routing/app_router.dart`.
- The `theme` property SHALL be set to `AppTheme.lightTheme`.
- The `darkTheme` property SHALL be set to `AppTheme.darkTheme`.
- The `themeMode` property SHALL be set to `AppSettingsViewModel.themeMode` obtained via `context.watch<AppSettingsViewModel>()`.
- The `locale` property SHALL be set to `AppSettingsViewModel.locale?.locale` (null means follow system).
- The `localizationsDelegates` property SHALL be set to `AppLocalizations.localizationsDelegates`.
- The `supportedLocales` property SHALL be set to `AppLocalizations.supportedLocales`.

#### Scenario: NaverPhotoApp uses MaterialApp.router

- **WHEN** `NaverPhotoApp.build()` is invoked
- **THEN** it SHALL return a `MaterialApp.router` widget

#### Scenario: NaverPhotoApp integrates GoRouter

- **WHEN** the `MaterialApp.router` is configured
- **THEN** its `routerConfig` SHALL reference the `appRouter` instance

#### Scenario: NaverPhotoApp applies both themes with themeMode

- **WHEN** the `MaterialApp.router` is configured
- **THEN** its `theme` SHALL be `AppTheme.lightTheme`
- **AND** its `darkTheme` SHALL be `AppTheme.darkTheme`
- **AND** its `themeMode` SHALL be sourced from `AppSettingsViewModel.themeMode`

#### Scenario: NaverPhotoApp configures localization

- **WHEN** the `MaterialApp.router` is configured
- **THEN** its `localizationsDelegates` SHALL be `AppLocalizations.localizationsDelegates`
- **AND** its `supportedLocales` SHALL be `AppLocalizations.supportedLocales`
- **AND** its `locale` SHALL be sourced from `AppSettingsViewModel.locale?.locale`


<!-- @trace
source: settings-theme-locale-l10n
updated: 2026-03-25
code:
  - naver_blog_image_downloader/lib/config/supported_locale.dart
  - naver_blog_image_downloader/lib/data/repositories/settings_repository.dart
  - naver_blog_image_downloader/lib/ui/core/view_model/app_settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/l10n/app_ja.arb
  - naver_blog_image_downloader/lib/l10n/app_zh_TW.arb
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/l10n/app_en.arb
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_ko.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/l10n/app_ko.arb
  - naver_blog_image_downloader/l10n.yaml
  - naver_blog_image_downloader/lib/l10n/app_localizations_en.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_zh.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/config/app_settings_keys.dart
  - naver_blog_image_downloader/lib/l10n/app_zh.arb
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_gallery/photo_gallery_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: main function defined

The file `lib/main.dart` SHALL define a `main()` function that calls `runApp()` with a `MultiProvider` wrapping `NaverPhotoApp` as its child.

#### Scenario: App launches with MultiProvider

- **WHEN** `main()` is executed
- **THEN** `runApp()` SHALL be called with a `MultiProvider` widget
- **AND** the `MultiProvider.child` SHALL be `const NaverPhotoApp()`

#### Scenario: Provider registration order

- **WHEN** the `MultiProvider.providers` list is inspected
- **THEN** Service providers SHALL appear before Repository providers
- **AND** Repository providers SHALL appear before ViewModel providers

<!-- @trace
source: s030-provider-di
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
tests:
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
-->

---
### Requirement: AppSettingsViewModel provider registered

The `MultiProvider` in `main.dart` SHALL register `AppSettingsViewModel` via `ChangeNotifierProvider` as the first ViewModel provider, injecting `SettingsRepository` via `context.read<SettingsRepository>()`. The `create` callback SHALL call `loadSettings()` on the newly created instance.

#### Scenario: AppSettingsViewModel DI wiring

- **GIVEN** the application starts
- **WHEN** `AppSettingsViewModel` is created via `ChangeNotifierProvider`
- **THEN** the constructor SHALL receive `SettingsRepository`
- **AND** `loadSettings()` SHALL be called immediately after creation

#### Scenario: AppSettingsViewModel is first ViewModel provider

- **WHEN** the `MultiProvider.providers` list is inspected
- **THEN** `AppSettingsViewModel` SHALL appear before all other `ChangeNotifierProvider` entries


<!-- @trace
source: settings-theme-locale-l10n
updated: 2026-03-25
code:
  - naver_blog_image_downloader/lib/config/supported_locale.dart
  - naver_blog_image_downloader/lib/data/repositories/settings_repository.dart
  - naver_blog_image_downloader/lib/ui/core/view_model/app_settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/l10n/app_ja.arb
  - naver_blog_image_downloader/lib/l10n/app_zh_TW.arb
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/l10n/app_en.arb
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_ko.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/l10n/app_ko.arb
  - naver_blog_image_downloader/l10n.yaml
  - naver_blog_image_downloader/lib/l10n/app_localizations_en.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_zh.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/config/app_settings_keys.dart
  - naver_blog_image_downloader/lib/l10n/app_zh.arb
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_gallery/photo_gallery_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: SharedPreferences eagerly initialized

The `main()` function SHALL call `await SharedPreferences.getInstance()` before `runApp` and pass the result to `LocalStorageService`.

#### Scenario: SharedPreferences available before runApp

- **WHEN** `main()` executes
- **THEN** `SharedPreferences.getInstance()` SHALL complete before `runApp` is called

<!-- @trace
source: settings-theme-locale-l10n
updated: 2026-03-25
code:
  - naver_blog_image_downloader/lib/config/supported_locale.dart
  - naver_blog_image_downloader/lib/data/repositories/settings_repository.dart
  - naver_blog_image_downloader/lib/ui/core/view_model/app_settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/l10n/app_ja.arb
  - naver_blog_image_downloader/lib/l10n/app_zh_TW.arb
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/l10n/app_en.arb
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_ko.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/l10n/app_ko.arb
  - naver_blog_image_downloader/l10n.yaml
  - naver_blog_image_downloader/lib/l10n/app_localizations_en.dart
  - naver_blog_image_downloader/lib/l10n/app_localizations_zh.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/config/app_settings_keys.dart
  - naver_blog_image_downloader/lib/l10n/app_zh.arb
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_gallery/photo_gallery_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->