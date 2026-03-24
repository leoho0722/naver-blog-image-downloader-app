# project-dependencies Specification

## Purpose

TBD - created by archiving change 's001-project-dependencies'. Update Purpose after archive.

## Requirements

### Requirement: Runtime dependencies declared

The `pubspec.yaml` file SHALL declare the following runtime dependencies: `provider`, `go_router`, `dio`, `crypto`, `path_provider`, `path`, `shared_preferences`, `amplify_flutter`, `amplify_api`, `package_info_plus`.

#### Scenario: All runtime packages present

- **WHEN** the pubspec.yaml is inspected
- **THEN** all ten runtime dependencies SHALL be listed under `dependencies`

#### Scenario: Flutter pub get succeeds

- **WHEN** `flutter pub get` is executed in the project directory
- **THEN** the command SHALL complete without errors


<!-- @trace
source: settings-ui-refinement
updated: 2026-03-22
code:
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: Platform minimum version

The project SHALL enforce minimum platform versions to ensure access to required native APIs.

- iOS deployment target (`IPHONEOS_DEPLOYMENT_TARGET`) SHALL be set to `17.0` (iOS 17.0).
- Android minimum SDK (`minSdk`) SHALL be set to `34` (Android 14.0).

#### Scenario: iOS minimum version

- **WHEN** the Xcode project build settings are inspected
- **THEN** `IPHONEOS_DEPLOYMENT_TARGET` SHALL be `17.0`

#### Scenario: Android minimum version

- **WHEN** `android/app/build.gradle.kts` is inspected
- **THEN** `minSdk` SHALL be `34`

---
### Requirement: Dev dependencies declared

The `pubspec.yaml` file SHALL declare `mocktail` as a dev dependency for testing.

#### Scenario: Mocktail available for tests

- **WHEN** the pubspec.yaml is inspected
- **THEN** `mocktail` SHALL be listed under `dev_dependencies`


<!-- @trace
source: s001-project-dependencies
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
-->

---
### Requirement: MVVM directory skeleton established

The project SHALL contain a `lib/` directory skeleton that reflects the MVVM layered architecture with the following subdirectories:
- `config/`
- `data/services/`, `data/repositories/`, `data/models/`, `data/models/dtos/`
- `ui/blog_input/view_model/`, `ui/blog_input/widgets/`
- `ui/download/view_model/`, `ui/download/widgets/`
- `ui/photo_gallery/view_model/`, `ui/photo_gallery/widgets/`
- `ui/photo_detail/view_model/`, `ui/photo_detail/widgets/`
- `ui/settings/view_model/`, `ui/settings/widgets/`
- `ui/core/`
- `routing/`
- `utils/`

#### Scenario: All directories exist

- **WHEN** the lib/ directory tree is listed
- **THEN** all specified subdirectories SHALL exist

#### Scenario: Directories are version-controlled

- **WHEN** the project is committed to Git
- **THEN** all empty directories SHALL contain a `.gitkeep` file to ensure they are tracked

<!-- @trace
source: s001-project-dependencies
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
-->

---
### Requirement: Localization dependencies

The `pubspec.yaml` SHALL declare the following additional dependencies:

- `flutter_localizations` from the Flutter SDK
- `intl` (version managed by `flutter_localizations`)

The `flutter` section SHALL include `generate: true` to enable code generation for localization.

#### Scenario: flutter_localizations declared

- **WHEN** `pubspec.yaml` is inspected
- **THEN** `flutter_localizations` SHALL be declared under `dependencies` with `sdk: flutter`

#### Scenario: generate flag enabled

- **WHEN** the `flutter` section of `pubspec.yaml` is inspected
- **THEN** `generate` SHALL be set to `true`

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