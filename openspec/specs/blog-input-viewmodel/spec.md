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

The ViewModel SHALL manage UI state through a single `FetchState` sealed class hierarchy instead of separate boolean and nullable fields. The sealed class SHALL have the following subtypes:
- `FetchIdle` — initial state, no operation in progress
- `FetchLoading` — fetch in progress, carries a `statusMessage` (String)
- `FetchError` — fetch failed, carries an error `message` (String)
- `FetchSuccess` — fetch succeeded, carries a `result` (FetchResult)

The ViewModel SHALL expose the following read-only convenience properties for backward compatibility:
- `blogUrl` (String) — the current URL input value
- `isLoading` (bool) — `true` when state is `FetchLoading`
- `errorMessage` (String?) — the error message when state is `FetchError`, otherwise `null`
- `fetchResult` (FetchResult?) — the fetch result when state is `FetchSuccess`, otherwise `null`
- `statusMessage` (String?) — the status message when state is `FetchLoading`, otherwise `null`

#### Scenario: Initial state

- **WHEN** a new `BlogInputViewModel` is created
- **THEN** the internal state SHALL be `FetchIdle`
- **AND** `blogUrl` SHALL be an empty string
- **AND** `isLoading` SHALL be `false`
- **AND** `errorMessage` SHALL be `null`
- **AND** `fetchResult` SHALL be `null`
- **AND** `statusMessage` SHALL be `null`

#### Scenario: URL value updated

- **WHEN** `onUrlChanged` is called with a URL string
- **THEN** `blogUrl` SHALL reflect the new value
- **AND** internal state SHALL reset to `FetchIdle`
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

The `fetchPhotos` method SHALL manage state transitions using `FetchLoadingPhase` enum instead of hardcoded status message strings:

- On submission: `FetchLoading(phase: FetchLoadingPhase.submitting)`
- On `JobStatus.processing`: `FetchLoading(phase: FetchLoadingPhase.processing)`
- On `JobStatus.completed`: `FetchLoading(phase: FetchLoadingPhase.completed)`

The `FetchLoading` class SHALL carry a `phase` property of type `FetchLoadingPhase` instead of a `statusMessage` property of type `String`.

On error, the method SHALL map exceptions to `FetchErrorType` enum values instead of calling `_humanReadableError()`:

- `TimeoutException` → `FetchErrorType.timeout`
- `ApiServiceException` with `isRetryable` true → `FetchErrorType.serverUnavailable`
- `ApiServiceException` without `isRetryable` → `FetchErrorType.apiFailed`
- `AppError` with `AppErrorType.serverError` → `FetchErrorType.serverError`
- `AppError` with `AppErrorType.network` → `FetchErrorType.networkError`
- `AppError` with `AppErrorType.timeout` → `FetchErrorType.timeout`
- All other exceptions → `FetchErrorType.unknown`

The `FetchError` class SHALL carry an `errorType` property of type `FetchErrorType` (and optionally a nullable `statusCode` of type `int?`) instead of a `message` property of type `String`.

#### Scenario: FetchLoading carries phase enum

- **WHEN** a `FetchLoading` state is created
- **THEN** it SHALL have a `phase` property of type `FetchLoadingPhase`
- **AND** it SHALL NOT have a `statusMessage` property

#### Scenario: FetchError carries errorType enum

- **WHEN** a `FetchError` state is created
- **THEN** it SHALL have an `errorType` property of type `FetchErrorType`
- **AND** it SHALL NOT have a `message` property of type `String`

#### Scenario: TimeoutException maps to FetchErrorType.timeout

- **WHEN** `fetchPhotos()` catches a `TimeoutException`
- **THEN** the state SHALL transition to `FetchError(errorType: FetchErrorType.timeout)`

#### Scenario: ApiServiceException with retryable maps to serverUnavailable

- **WHEN** `fetchPhotos()` catches an `ApiServiceException` with `isRetryable` true
- **THEN** the state SHALL transition to `FetchError(errorType: FetchErrorType.serverUnavailable)`


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
### Requirement: Reset state

The `reset()` method SHALL set internal state to `FetchIdle`, clearing `fetchResult`, `errorMessage`, and `statusMessage`. It SHALL NOT reset `blogUrl`.

#### Scenario: Reset after successful fetch

- **GIVEN** state is `FetchSuccess`
- **WHEN** `reset()` is called
- **THEN** state SHALL be `FetchIdle`
- **AND** `fetchResult` SHALL be `null`
- **AND** `errorMessage` SHALL be `null`
- **AND** `statusMessage` SHALL be `null`
- **AND** `blogUrl` SHALL remain unchanged
- **AND** `notifyListeners` SHALL be called


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
### Requirement: Human-readable error messages

The `_humanReadableError()` method SHALL be removed. Error message generation SHALL be delegated to the View layer, which maps `FetchErrorType` enum values to localized strings via `AppLocalizations`.

#### Scenario: No humanReadableError method

- **WHEN** the `BlogInputViewModel` class is inspected
- **THEN** it SHALL NOT contain a `_humanReadableError` method


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
### Requirement: FetchErrorType enum

A `FetchErrorType` enum SHALL be defined with the following values:

- `emptyUrl` — user submitted an empty URL
- `timeout` — request timed out
- `serverUnavailable` — server returned a retryable error
- `apiFailed` — API call failed (non-retryable)
- `serverError` — server-side processing error
- `networkError` — network connectivity issue
- `unknown` — unclassified error

#### Scenario: All error types defined

- **WHEN** `FetchErrorType.values` is inspected
- **THEN** it SHALL contain exactly 7 values: `emptyUrl`, `timeout`, `serverUnavailable`, `apiFailed`, `serverError`, `networkError`, `unknown`


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
### Requirement: FetchLoadingPhase enum

A `FetchLoadingPhase` enum SHALL be defined with the following values:

- `submitting` — task submission in progress
- `processing` — server processing the request
- `completed` — processing completed

#### Scenario: All loading phases defined

- **WHEN** `FetchLoadingPhase.values` is inspected
- **THEN** it SHALL contain exactly 3 values: `submitting`, `processing`, `completed`

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