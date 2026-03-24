# settings-viewmodel

## Overview

SettingsViewModel manages cache information display and cache clearing operations for the settings screen. It extends ChangeNotifier and delegates cache operations to CacheRepository.

## File

`lib/ui/settings/view_model/settings_view_model.dart`

### Requirement: settings state properties

SettingsViewModel SHALL extend `ChangeNotifier`.

SettingsViewModel SHALL call `notifyListeners()` after every state change.

SettingsViewModel SHALL expose the following read-only properties:
- `totalCacheSize` (int) — the total cache size in bytes
- `allMetadata` (List&lt;BlogCacheMetadata&gt;) — metadata for all cached blogs
- `formattedCacheSize` (String) — human-readable cache size string
- `isLoading` (bool) — whether a load or clear operation is in progress

#### Scenario: initial state

Given a newly created SettingsViewModel,
then `totalCacheSize` SHALL be `0`,
and `allMetadata` SHALL be an empty list,
and `formattedCacheSize` SHALL be `"0 B"`,
and `isLoading` SHALL be `false`.

### Requirement: load cache info

SettingsViewModel SHALL provide a `loadCacheInfo()` method.

When `loadCacheInfo` is called, it SHALL:
1. Set `isLoading` to `true`
2. Call `CacheRepository.totalCacheSize()` and store the result in `totalCacheSize`
3. Call `CacheRepository.allMetadata()` and store the result in `allMetadata`
4. Set `isLoading` to `false`
5. Call `notifyListeners()`

#### Scenario: load cache info successfully

Given a SettingsViewModel,
when `loadCacheInfo()` is called and CacheRepository returns totalCacheSize of 157286400 and 3 metadata entries,
then `totalCacheSize` SHALL be `157286400`,
and `allMetadata` SHALL contain 3 items,
and `isLoading` SHALL be `false`.

### Requirement: formatted cache size

The `formattedCacheSize` getter SHALL convert `totalCacheSize` bytes to a human-readable string with appropriate units (B, KB, MB, GB) and one decimal place.

The formatting rules SHALL be:
- Less than 1024 bytes: display as "{n} B"
- Less than 1024 * 1024 bytes: display as "{n.d} KB"
- Less than 1024 * 1024 * 1024 bytes: display as "{n.d} MB"
- Otherwise: display as "{n.d} GB"

#### Scenario: format zero bytes

Given a SettingsViewModel with `totalCacheSize` of `0`,
then `formattedCacheSize` SHALL be `"0 B"`.

#### Scenario: format kilobytes

Given a SettingsViewModel with `totalCacheSize` of `1536`,
then `formattedCacheSize` SHALL be `"1.5 KB"`.

#### Scenario: format megabytes

Given a SettingsViewModel with `totalCacheSize` of `157286400`,
then `formattedCacheSize` SHALL be `"150.0 MB"`.

### Requirement: clear all cache

SettingsViewModel SHALL provide a `clearAllCache()` method.

When `clearAllCache` is called, it SHALL:
1. Call `CacheRepository.clearAll()`
2. Call `loadCacheInfo()` to refresh the displayed cache information

#### Scenario: clear all cache

Given a SettingsViewModel with cached data,
when `clearAllCache()` is called,
then `CacheRepository.clearAll()` SHALL be invoked,
and `loadCacheInfo()` SHALL be called to refresh data.

### Requirement: clear blog cache

SettingsViewModel SHALL provide a `clearBlogCache(String blogId)` method.

When `clearBlogCache` is called, it SHALL:
1. Call `CacheRepository.clearBlog(blogId)`
2. Call `loadCacheInfo()` to refresh the displayed cache information

#### Scenario: clear specific blog cache

Given a SettingsViewModel with multiple cached blogs,
when `clearBlogCache("abc123")` is called,
then `CacheRepository.clearBlog("abc123")` SHALL be invoked,
and `loadCacheInfo()` SHALL be called to refresh data.

## Requirements

### Requirement: Settings state properties

The `SettingsViewModel` class SHALL extend `ChangeNotifier` and provide a constructor that accepts a `CacheRepository` instance via the `required` named parameter `cacheRepository`.

The ViewModel SHALL expose the following read-only properties:
- `cacheSizeBytes` (int) — the total cache size in bytes
- `cachedBlogs` (List\<BlogCacheMetadata\>) — metadata for all cached blogs
- `isClearing` (bool) — whether a clear operation is in progress
- `formattedCacheSize` (String) — human-readable cache size string

#### Scenario: Initial state

- **WHEN** a new `SettingsViewModel` is created
- **THEN** `cacheSizeBytes` SHALL be `0`
- **AND** `cachedBlogs` SHALL be an empty list
- **AND** `isClearing` SHALL be `false`
- **AND** `formattedCacheSize` SHALL be `"0.0 MB"`


<!-- @trace
source: s023-settings-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
tests:
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

---
### Requirement: Load cache info

The `loadCacheInfo` method SHALL retrieve the total cache size and all blog metadata from `CacheRepository`.

#### Scenario: Load cache information

- **WHEN** `loadCacheInfo()` is called
- **THEN** `cacheSizeBytes` SHALL be updated with the value from `CacheRepository.totalCacheSize()`
- **AND** `cachedBlogs` SHALL be updated with the value from `CacheRepository.allMetadata()`
- **AND** `notifyListeners` SHALL be called


<!-- @trace
source: s023-settings-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
tests:
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

---
### Requirement: Formatted cache size

The `formattedCacheSize` getter SHALL convert `cacheSizeBytes` to a human-readable string with one decimal place in MB.

#### Scenario: Format cache size

- **GIVEN** `cacheSizeBytes` holds a value
- **WHEN** `formattedCacheSize` is accessed
- **THEN** the value SHALL be formatted as `"X.X MB"` where X.X is `cacheSizeBytes / 1024 / 1024` rounded to one decimal place


<!-- @trace
source: s023-settings-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
tests:
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

---
### Requirement: Clear all cache

The `clearAllCache` method SHALL clear all cached files and metadata via `CacheRepository.clearAll()`, then directly reset `cacheSizeBytes` to `0`, `cachedBlogs` to an empty list, and `formattedCacheSize` to its zero-state value. It SHALL NOT call `loadCacheInfo()`.

#### Scenario: Clear all cache successfully

- **WHEN** `clearAllCache()` is called
- **THEN** `isClearing` SHALL be set to `true` before the clear operation
- **AND** `CacheRepository.clearAll()` SHALL be called
- **AND** `cacheSizeBytes` SHALL be reset to `0`
- **AND** `cachedBlogs` SHALL be reset to an empty list
- **AND** `isClearing` SHALL be set to `false` after the operation completes
- **AND** `notifyListeners` SHALL be called


<!-- @trace
source: s023-settings-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
tests:
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

---
### Requirement: Settings page watches AppSettingsViewModel

The `SettingsView` SHALL use `context.watch<AppSettingsViewModel>()` in addition to `context.watch<SettingsViewModel>()` to access both cache-related state and app-wide preference state.

#### Scenario: Settings page accesses both ViewModels

- **WHEN** the `SettingsView` builds
- **THEN** it SHALL watch both `SettingsViewModel` (for cache operations) and `AppSettingsViewModel` (for theme mode and locale)

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