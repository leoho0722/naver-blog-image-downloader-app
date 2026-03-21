# photo-detail-viewmodel

## Overview

PhotoDetailViewModel manages the display of a single photo at full resolution. It extends ChangeNotifier and delegates cache file retrieval to CacheRepository.

## File

`lib/ui/photo_detail/view_model/photo_detail_view_model.dart`

### Requirement: detail state properties

PhotoDetailViewModel SHALL extend `ChangeNotifier`.

PhotoDetailViewModel SHALL call `notifyListeners()` after every state change.

PhotoDetailViewModel SHALL expose the following read-only properties:
- `photo` (PhotoEntity?) — the loaded photo entity
- `blogId` (String?) — the Blog identifier
- `cachedFilePath` (String?) — the local file path to the full-resolution cached image

#### Scenario: initial state

Given a newly created PhotoDetailViewModel,
then `photo` SHALL be `null`,
and `blogId` SHALL be `null`,
and `cachedFilePath` SHALL be `null`.

### Requirement: load photo detail

PhotoDetailViewModel SHALL provide a `load(PhotoEntity photo, String blogId)` method.

When `load` is called, PhotoDetailViewModel SHALL:
1. Store the `photo` and `blogId`
2. Query `CacheRepository.cachedFile(photo.filename, blogId)` to retrieve the cached file
3. If the file exists, store its path in `cachedFilePath`
4. If the file does not exist, set `cachedFilePath` to `null`
5. Call `notifyListeners()`

#### Scenario: load with existing cached file

Given a PhotoDetailViewModel,
when `load` is called with a photo whose cache file exists,
then `photo` SHALL equal the provided PhotoEntity,
and `blogId` SHALL equal the provided value,
and `cachedFilePath` SHALL be a non-null file path string.

#### Scenario: load with missing cached file

Given a PhotoDetailViewModel,
when `load` is called with a photo whose cache file does not exist,
then `photo` SHALL equal the provided PhotoEntity,
and `cachedFilePath` SHALL be `null`.

### Requirement: cached file retrieval

The `cachedFilePath` getter SHALL return the absolute path of the cached file when it exists, or `null` when the file is not cached.

PhotoDetailViewModel SHALL provide a `cachedFile()` method that delegates to `CacheRepository.cachedFile(photo.filename, blogId)` and returns `Future<File?>`.

#### Scenario: cachedFilePath after successful load

Given a PhotoDetailViewModel that has been loaded with a cached photo,
then `cachedFilePath` SHALL be a non-empty string ending with the photo filename.

#### Scenario: cached file retrieval delegates to CacheRepository

Given a PhotoDetailViewModel with a loaded photo and blogId,
when `cachedFile()` is called,
then it SHALL delegate to `CacheRepository.cachedFile(photo.filename, blogId)`.

## Requirements

### Requirement: Detail state properties

The `PhotoDetailViewModel` class SHALL extend `ChangeNotifier` and provide a constructor that accepts both a `CacheRepository` instance via the `required` named parameter `cacheRepository` and a `GalleryService` instance via the `required` named parameter `galleryService`.

The ViewModel SHALL expose the following read-only properties:
- `photo` (PhotoEntity?) — the currently loaded photo entity
- `blogId` (String) — the blog identifier
- `cachedFile` (File?) — the cached file for the loaded photo, or null
- `fileSizeBytes` (int?) — the file size in bytes, or null
- `imageWidth` (int?) — the image width in pixels, or null
- `imageHeight` (int?) — the image height in pixels, or null
- `isSaving` (bool) — whether a save-to-gallery operation is in progress
- `isSaved` (bool) — whether the photo has been saved to gallery
- `formattedFileSize` (String) — human-readable file size string
- `formattedDimensions` (String) — human-readable image dimensions string

#### Scenario: Initial state

- **WHEN** a new `PhotoDetailViewModel` is created
- **THEN** `photo` SHALL be `null`
- **AND** `blogId` SHALL be an empty string
- **AND** `cachedFile` SHALL be `null`
- **AND** `fileSizeBytes` SHALL be `null`
- **AND** `imageWidth` SHALL be `null`
- **AND** `imageHeight` SHALL be `null`
- **AND** `isSaving` SHALL be `false`
- **AND** `isSaved` SHALL be `false`


<!-- @trace
source: s022-photo-detail-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

---
### Requirement: Load photo detail

The `load` method SHALL be async. It SHALL accept a `PhotoEntity` and a `String blogId`, store them, then read the cached file, determine file size, and decode image dimensions via `ui.instantiateImageCodec`.

#### Scenario: Load single photo

- **WHEN** `load` is called with a `PhotoEntity` and a `blogId`
- **THEN** `photo` SHALL hold the provided `PhotoEntity`
- **AND** `blogId` SHALL equal the provided blogId
- **AND** `cachedFile` SHALL hold the resolved cached file (or null if not found)
- **AND** `fileSizeBytes` SHALL hold the file size in bytes (or null if no file)
- **AND** `imageWidth` and `imageHeight` SHALL hold the decoded image dimensions (or null if decoding fails)
- **AND** `notifyListeners` SHALL be called


<!-- @trace
source: s022-photo-detail-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

---
### Requirement: Save to gallery

The `saveToGallery()` method SHALL save the cached photo to the device gallery via `GalleryService`.

#### Scenario: Save photo to gallery

- **GIVEN** `cachedFile` holds a valid File
- **WHEN** `saveToGallery()` is called
- **THEN** `isSaving` SHALL be set to `true` before the save operation
- **AND** `GalleryService` SHALL be called to save the file
- **AND** `isSaved` SHALL be set to `true` after successful save
- **AND** `isSaving` SHALL be set to `false` after the operation completes
- **AND** `notifyListeners` SHALL be called

<!-- @trace
source: s022-photo-detail-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
tests:
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->