# download-viewmodel

## Overview

DownloadViewModel manages batch photo downloading, progress tracking, and result state for the download screen. It extends ChangeNotifier and delegates downloading to PhotoRepository.

## File

`lib/ui/download/view_model/download_view_model.dart`

### Requirement: download state properties

DownloadViewModel SHALL extend `ChangeNotifier`.

DownloadViewModel SHALL call `notifyListeners()` after every state change.

DownloadViewModel SHALL expose the following read-only properties:
- `completed` (int) — the number of photos that have been downloaded
- `total` (int) — the total number of photos to download
- `progress` (double) — the download progress as a value between 0.0 and 1.0
- `isDownloading` (bool) — whether a download operation is in progress
- `result` (DownloadBatchResult?) — the result of the last download operation

#### Scenario: initial state

Given a newly created DownloadViewModel,
then `completed` SHALL be `0`,
and `total` SHALL be `0`,
and `progress` SHALL be `0.0`,
and `isDownloading` SHALL be `false`,
and `result` SHALL be `null`.

### Requirement: progress calculation

The `progress` getter SHALL return `_completed / _total` as a double.

When `_total` is `0`, `progress` SHALL return `0.0` to avoid division by zero.

#### Scenario: progress with zero total

Given a DownloadViewModel where `total` is `0`,
then `progress` SHALL be `0.0`.

#### Scenario: progress mid-download

Given a DownloadViewModel where `completed` is `3` and `total` is `10`,
then `progress` SHALL be `0.3`.

### Requirement: start download with progress tracking

DownloadViewModel SHALL provide a `startDownload({required List<PhotoEntity> photos, required String blogId})` method.

When `startDownload` is called, DownloadViewModel SHALL:
1. Set `_total` to `photos.length` and `_completed` to `0`
2. Set `isDownloading` to `true`
3. Call `PhotoRepository.downloadAllToCache` with the provided photos, blogId, and an `onProgress` callback
4. Update `_completed` via the `onProgress` callback and call `notifyListeners()` on each update
5. Store the returned `DownloadBatchResult` in `result`
6. Set `isDownloading` to `false`

DownloadViewModel SHALL prevent concurrent download requests by checking `isDownloading` before initiating a new request.

DownloadViewModel SHALL set a disposed flag in its `dispose()` method. After disposal, progress callbacks SHALL NOT call `notifyListeners()`.

#### Scenario: successful batch download

Given a DownloadViewModel,
when `startDownload` is called with 5 photos,
then `total` SHALL be `5`,
and as each photo completes, `completed` SHALL increment,
and after all photos complete, `isDownloading` SHALL be `false`,
and `result` SHALL contain the DownloadBatchResult.

#### Scenario: duplicate download prevention

Given a DownloadViewModel where `isDownloading` is `true`,
when `startDownload` is called again,
then a second `PhotoRepository.downloadAllToCache` call SHALL NOT be initiated.

#### Scenario: callback after dispose

Given a DownloadViewModel that has been disposed,
when a progress callback fires,
then `notifyListeners()` SHALL NOT be called.

## Requirements

### Requirement: Download state properties

The `DownloadViewModel` class SHALL extend `ChangeNotifier` and provide a constructor that accepts a `PhotoRepository` instance via the `required` named parameter `photoRepository`.

The ViewModel SHALL expose the following read-only properties:
- `completed` (int) — the number of photos that have finished downloading
- `total` (int) — the total number of photos to download
- `isDownloading` (bool) — whether a download operation is in progress
- `result` (DownloadBatchResult?) — the batch download result, or null
- `progress` (double) — the download progress ratio from 0.0 to 1.0

#### Scenario: Initial state

- **WHEN** a new `DownloadViewModel` is created
- **THEN** `completed` SHALL be `0`
- **AND** `total` SHALL be `0`
- **AND** `isDownloading` SHALL be `false`
- **AND** `result` SHALL be `null`
- **AND** `progress` SHALL be `0.0`


<!-- @trace
source: s020-download-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/app.dart
tests:
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: Progress calculation

The `progress` getter SHALL compute the download progress as `completed / total`.

#### Scenario: Progress with valid total

- **GIVEN** `total` is greater than 0
- **WHEN** `progress` is accessed
- **THEN** the value SHALL equal `completed / total` as a double

#### Scenario: Progress with zero total

- **GIVEN** `total` is `0`
- **WHEN** `progress` is accessed
- **THEN** the value SHALL be `0.0`


<!-- @trace
source: s020-download-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/app.dart
tests:
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->

---
### Requirement: Start download with progress tracking

The `startDownload` method SHALL accept `required List<PhotoEntity> photos` and `required String blogId` parameters, set the downloading state, invoke `PhotoRepository.downloadAllToCache`, track progress via callback, and store the result.

#### Scenario: Successful batch download

- **GIVEN** a list of `PhotoEntity` objects and a `blogId`
- **WHEN** `startDownload` is called
- **THEN** `isDownloading` SHALL be set to `true` before the repository call
- **AND** `total` SHALL be set to the length of the photos list
- **AND** `completed` SHALL be updated incrementally as each photo completes
- **AND** `notifyListeners` SHALL be called on each progress update
- **AND** after the repository call completes, `result` SHALL hold the returned `DownloadBatchResult`
- **AND** `isDownloading` SHALL be set to `false`

#### Scenario: Duplicate download prevention

- **GIVEN** `isDownloading` is `true`
- **WHEN** `startDownload` is called again
- **THEN** the method SHALL return immediately without starting another download

<!-- @trace
source: s020-download-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/app.dart
tests:
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->