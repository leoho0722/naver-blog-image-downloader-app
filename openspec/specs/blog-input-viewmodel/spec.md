# blog-input-viewmodel

## Overview

BlogInputViewModel manages the blog URL input, photo fetching, and UI state for the blog input screen. It extends ChangeNotifier and delegates photo fetching to PhotoRepository.

## File

`lib/ui/blog_input/view_model/blog_input_view_model.dart`

### Requirement: URL input state management

BlogInputViewModel SHALL extend `ChangeNotifier`.

BlogInputViewModel SHALL call `notifyListeners()` after every state change.

BlogInputViewModel SHALL expose the following read-only properties:
- `blogUrl` (String) — the current URL input value
- `isLoading` (bool) — whether a fetch operation is in progress
- `errorMessage` (String?) — the error message if the last operation failed
- `fetchResult` (FetchResult?) — the result of the last successful fetch

BlogInputViewModel SHALL provide an `onUrlChanged(String url)` method. When `onUrlChanged` is called, it SHALL update `blogUrl` to the provided value and call `notifyListeners()`.

#### Scenario: initial state

Given a newly created BlogInputViewModel,
then `blogUrl` SHALL be an empty string,
and `isLoading` SHALL be `false`,
and `errorMessage` SHALL be `null`,
and `fetchResult` SHALL be `null`.

#### Scenario: URL value updated

Given a BlogInputViewModel,
when `onUrlChanged("https://blog.naver.com/test/123")` is called,
then `blogUrl` SHALL equal `"https://blog.naver.com/test/123"`.


<!-- @trace
source: s019-blog-input-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
tests:
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

### Requirement: empty URL validation

When `fetchPhotos()` is called and `blogUrl` is an empty string, BlogInputViewModel SHALL set `errorMessage` to a non-null value and SHALL NOT call `PhotoRepository.fetchPhotos`.

#### Scenario: fetch with empty URL

Given a BlogInputViewModel with `blogUrl` as empty string,
when `fetchPhotos()` is called,
then `errorMessage` SHALL be set to a non-null error message,
and `PhotoRepository.fetchPhotos` SHALL NOT be invoked.

### Requirement: fetch photos with loading state

When `fetchPhotos()` is called with a non-empty `blogUrl`, BlogInputViewModel SHALL:
1. Set `isLoading` to `true` and clear `errorMessage`
2. Call `PhotoRepository.fetchPhotos(blogUrl)`
3. On `Result.ok`, store the `FetchResult` in `fetchResult`
4. On `Result.error`, store the error message in `errorMessage`
5. Set `isLoading` to `false`

BlogInputViewModel SHALL prevent concurrent fetch requests by checking `isLoading` before initiating a new request.

#### Scenario: successful fetch

Given a BlogInputViewModel with a valid `blogUrl`,
when `fetchPhotos()` is called and PhotoRepository returns `Result.ok(fetchResult)`,
then `fetchResult` SHALL contain the returned FetchResult,
and `isLoading` SHALL be `false`,
and `errorMessage` SHALL be `null`.

#### Scenario: fetch failure

Given a BlogInputViewModel with a valid `blogUrl`,
when `fetchPhotos()` is called and PhotoRepository returns `Result.error(exception)`,
then `errorMessage` SHALL contain the error message,
and `isLoading` SHALL be `false`,
and `fetchResult` SHALL remain `null`.

#### Scenario: duplicate fetch prevention

Given a BlogInputViewModel where `isLoading` is `true`,
when `fetchPhotos()` is called again,
then a second `PhotoRepository.fetchPhotos` call SHALL NOT be initiated.

### Requirement: reset state

BlogInputViewModel SHALL provide a `reset()` method that clears `fetchResult`, `errorMessage`, and resets `blogUrl` to an empty string.

#### Scenario: reset after successful fetch

Given a BlogInputViewModel with a non-null `fetchResult`,
when `reset()` is called,
then `fetchResult` SHALL be `null`,
and `errorMessage` SHALL be `null`,
and `blogUrl` SHALL be an empty string.

## Requirements

### Requirement: URL input state management

The `BlogInputViewModel` class SHALL extend `ChangeNotifier` and provide a constructor that accepts a `PhotoRepository` instance via the `required` named parameter `photoRepository`.

The ViewModel SHALL expose the following read-only properties:
- `blogUrl` (String) — the current URL input value
- `isLoading` (bool) — whether a fetch operation is in progress
- `errorMessage` (String?) — the current error message, or null
- `fetchResult` (FetchResult?) — the fetch result, or null
- `statusMessage` (String?) — the current status message reflecting the async job progress, or null

#### Scenario: Initial state

- **WHEN** a new `BlogInputViewModel` is created
- **THEN** `blogUrl` SHALL be an empty string
- **AND** `isLoading` SHALL be `false`
- **AND** `errorMessage` SHALL be `null`
- **AND** `fetchResult` SHALL be `null`
- **AND** `statusMessage` SHALL be `null`

#### Scenario: URL value updated

- **WHEN** `onUrlChanged` is called with a URL string
- **THEN** `blogUrl` SHALL reflect the new value
- **AND** `notifyListeners` SHALL be called

---
### Requirement: Empty URL validation

The `fetchPhotos()` method SHALL validate that `blogUrl` is not empty before initiating a fetch operation.

#### Scenario: Fetch with empty URL

- **GIVEN** `blogUrl` is an empty string
- **WHEN** `fetchPhotos()` is called
- **THEN** `errorMessage` SHALL be set to a non-null error message
- **AND** `isLoading` SHALL remain `false`
- **AND** no call to `PhotoRepository.fetchPhotos` SHALL be made


<!-- @trace
source: s019-blog-input-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
tests:
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

---
### Requirement: Fetch photos with loading state and status message

The `fetchPhotos()` method SHALL manage the loading state, status message, and delegate to `PhotoRepository.fetchPhotos`.

- `fetchPhotos()` SHALL pass an `onStatusChanged` callback to `PhotoRepository.fetchPhotos`.
- The `onStatusChanged` callback receives a `JobStatus` enum value. The ViewModel SHALL map the `JobStatus` enum to a user-facing string internally.
- When the callback is invoked, `statusMessage` SHALL be updated with the mapped string and `notifyListeners()` SHALL be called.
- After the fetch operation completes (success or failure), `statusMessage` SHALL be cleared to `null`.

#### Scenario: Successful fetch

- **GIVEN** `blogUrl` is a non-empty string
- **AND** `PhotoRepository.fetchPhotos` returns `Result.ok(fetchResult)`
- **WHEN** `fetchPhotos()` is called
- **THEN** `isLoading` SHALL be set to `true` before the repository call
- **AND** `isLoading` SHALL be set to `false` after the repository call completes
- **AND** `fetchResult` SHALL hold the returned `FetchResult`
- **AND** `errorMessage` SHALL be `null`
- **AND** `statusMessage` SHALL be `null` after completion

#### Scenario: Failed fetch

- **GIVEN** `blogUrl` is a non-empty string
- **AND** `PhotoRepository.fetchPhotos` returns `Result.error(exception)`
- **WHEN** `fetchPhotos()` is called
- **THEN** `isLoading` SHALL be set to `true` before the repository call
- **AND** `isLoading` SHALL be set to `false` after the repository call completes
- **AND** `errorMessage` SHALL contain the error description
- **AND** `fetchResult` SHALL remain `null`
- **AND** `statusMessage` SHALL be `null` after completion

#### Scenario: Status message updates during fetch

- **GIVEN** `blogUrl` is a non-empty string
- **AND** the `onStatusChanged` callback is invoked during `PhotoRepository.fetchPhotos`
- **WHEN** the callback receives a `JobStatus` enum value
- **THEN** `statusMessage` SHALL be updated to the corresponding user-facing string mapped internally by the ViewModel
- **AND** `notifyListeners()` SHALL be called

#### Scenario: Duplicate fetch prevention

- **GIVEN** `isLoading` is `true`
- **WHEN** `fetchPhotos()` is called again
- **THEN** the method SHALL return immediately without making another repository call


<!-- @trace
source: s019-blog-input-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
tests:
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

---
### Requirement: Reset state

The `reset()` method SHALL clear `fetchResult`, `errorMessage`, and `statusMessage`. It SHALL NOT reset `blogUrl`.

#### Scenario: Reset after successful fetch

- **GIVEN** `fetchResult` holds a value
- **WHEN** `reset()` is called
- **THEN** `fetchResult` SHALL be `null`
- **AND** `errorMessage` SHALL be `null`
- **AND** `statusMessage` SHALL be `null`
- **AND** `blogUrl` SHALL remain unchanged
- **AND** `notifyListeners` SHALL be called

<!-- @trace
source: s019-blog-input-viewmodel
updated: 2026-03-21
code:
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/utils/constants.dart
  - naver_blog_image_downloader/lib/data/models/fetch_result.dart
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/ios/Podfile.lock
  - naver_blog_image_downloader/ios/Runner.xcodeproj/project.pbxproj
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
  - naver_blog_image_downloader/lib/data/services/local_storage_service.dart
  - naver_blog_image_downloader/lib/data/services/api_service.dart
  - naver_blog_image_downloader/ios/Flutter/Release.xcconfig
  - naver_blog_image_downloader/lib/data/repositories/photo_repository.dart
  - naver_blog_image_downloader/lib/app.dart
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_request.dart
  - naver_blog_image_downloader/lib/data/services/file_download_service.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_card.dart
  - naver_blog_image_downloader/lib/ui/core/result.dart
  - Naver Blog 照片下載器-Flutter-系統架構設計書-完整版.md
  - naver_blog_image_downloader/lib/ui/core/app_error.dart
  - naver_blog_image_downloader/lib/data/models/blog_cache_metadata.dart
  - naver_blog_image_downloader/lib/ui/settings/widgets/settings_view.dart
  - naver_blog_image_downloader/lib/ui/download/widgets/download_view.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
  - naver_blog_image_downloader/lib/main.dart
  - naver_blog_image_downloader/ios/Runner/Info.plist
  - naver_blog_image_downloader/lib/config/app_config.dart
  - naver_blog_image_downloader/ios/Runner.xcworkspace/contents.xcworkspacedata
  - naver_blog_image_downloader/pubspec.yaml
  - naver_blog_image_downloader/lib/ui/settings/view_model/settings_view_model.dart
  - naver_blog_image_downloader/lib/amplifyconfiguration.dart
  - naver_blog_image_downloader/lib/data/models/dtos/job_status_response.dart
  - naver_blog_image_downloader/ios/Flutter/Debug.xcconfig
  - naver_blog_image_downloader/lib/data/models/dtos/photo_download_response.dart
  - naver_blog_image_downloader/lib/utils/extensions.dart
  - naver_blog_image_downloader/lib/ui/download/view_model/download_view_model.dart
  - naver_blog_image_downloader/lib/data/repositories/cache_repository.dart
  - naver_blog_image_downloader/devtools_options.yaml
  - naver_blog_image_downloader/pubspec.lock
  - naver_blog_image_downloader/lib/config/theme.dart
  - naver_blog_image_downloader/ios/Podfile
  - naver_blog_image_downloader/lib/data/services/gallery_service.dart
  - naver_blog_image_downloader/lib/data/models/download_batch_result.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/data/models/photo_entity.dart
  - naver_blog_image_downloader/lib/routing/app_router.dart
tests:
  - naver_blog_image_downloader/test/widget_test.dart
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/cache_repository_test.dart
  - naver_blog_image_downloader/test/data/services/api_service_test.dart
  - naver_blog_image_downloader/test/ui/download/download_view_model_test.dart
  - naver_blog_image_downloader/test/data/repositories/photo_repository_test.dart
-->

---
### Requirement: Human-readable error messages

The `BlogInputViewModel` SHALL convert all error types to human-readable Chinese messages before setting `errorMessage`. For `AppError` with `AppErrorType.serverError`, the message SHALL be "伺服器處理失敗，請稍後再試". For `AppError` with `AppErrorType.networkError`, the message SHALL be "網路連線異常，請檢查網路設定". For any other `AppError` type, the message SHALL be "發生錯誤，請稍後再試". The `errorMessage` property SHALL NOT contain raw JSON, technical details, or unicode escape sequences.

#### Scenario: Server error produces human-readable message

- **GIVEN** `PhotoRepository.fetchPhotos()` returns `Result.error` with `AppError(type: AppErrorType.serverError)`
- **WHEN** the error is processed
- **THEN** `errorMessage` SHALL be "伺服器處理失敗，請稍後再試"

#### Scenario: Network error produces human-readable message

- **GIVEN** `PhotoRepository.fetchPhotos()` returns `Result.error` with `AppError(type: AppErrorType.networkError)`
- **WHEN** the error is processed
- **THEN** `errorMessage` SHALL be "網路連線異常，請檢查網路設定"

#### Scenario: Unknown error produces generic message

- **GIVEN** an unexpected error type is encountered
- **WHEN** the error is processed
- **THEN** `errorMessage` SHALL be "發生錯誤，請稍後再試"

<!-- @trace
source: lambda-error-dialog
updated: 2026-03-22
code:
  - naver_blog_image_downloader/lib/ui/blog_input/widgets/blog_input_view.dart
  - naver_blog_image_downloader/lib/ui/blog_input/view_model/blog_input_view_model.dart
tests:
  - naver_blog_image_downloader/test/ui/blog_input/blog_input_view_model_test.dart
-->