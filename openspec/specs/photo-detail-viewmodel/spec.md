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

The `PhotoDetailViewModel` class SHALL extend `ChangeNotifier` and provide a constructor that accepts a `CacheRepository` instance via the `required` named parameter `cacheRepository` and a `PhotoRepository` instance via the `required` named parameter `photoRepository`.

The ViewModel SHALL expose the following read-only properties:
- `photo` (PhotoEntity?) — the currently loaded photo entity, computed from `_photos[_currentIndex]`
- `photos` (List<PhotoEntity>) — the full photo list
- `currentIndex` (int) — the index of the currently displayed photo
- `totalCount` (int) — the total number of photos
- `blogId` (String) — the blog identifier
- `cachedFile` (File?) — the cached file for the current photo, retrieved from metadata cache
- `fileSizeBytes` (int?) — the file size in bytes for the current photo
- `imageWidth` (int?) — the image width in pixels for the current photo
- `imageHeight` (int?) — the image height in pixels for the current photo
- `saveState` (SaveState) — the current save operation state
- `formattedFileSize` (String) — human-readable file size string
- `formattedDimensions` (String) — human-readable image dimensions string

#### Scenario: Initial state

- **WHEN** a new `PhotoDetailViewModel` is created
- **THEN** `photo` SHALL be `null`
- **AND** `photos` SHALL be an empty list
- **AND** `currentIndex` SHALL be `0`
- **AND** `totalCount` SHALL be `0`
- **AND** `blogId` SHALL be an empty string
- **AND** `cachedFile` SHALL be `null`
- **AND** `saveState` SHALL be `SaveState.idle`


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
### Requirement: Load photo detail

The `loadAll` method SHALL be async. It SHALL accept a `List<PhotoEntity>`, a `String blogId`, and an `int initialIndex`. It SHALL store the photo list and blogId, set `_currentIndex` to `initialIndex`, then load metadata (cached file, file size, image dimensions) for the current photo via `CacheRepository` and `ui.instantiateImageCodec`, and call `notifyListeners()`.

#### Scenario: Load photo list

- **WHEN** `loadAll` is called with a list of photos, a blogId, and an initialIndex
- **THEN** `photos` SHALL hold the provided list
- **AND** `blogId` SHALL equal the provided blogId
- **AND** `currentIndex` SHALL equal the provided initialIndex
- **AND** `photo` SHALL return the `PhotoEntity` at initialIndex
- **AND** `cachedFile` SHALL hold the resolved cached file for the initial photo
- **AND** `notifyListeners` SHALL be called


<!-- @trace
source: photo-detail-viewer-redesign
updated: 2026-03-23
code:
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_capsule_bar.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_detail/photo_detail_view_model_test.dart
-->

---
### Requirement: Save to gallery

The `saveToGallery()` method SHALL save the current photo (at `_currentIndex`) to the device gallery via `PhotoRepository.saveOneToGallery`.

#### Scenario: Save photo to gallery

- **GIVEN** `cachedFile` holds a valid File
- **WHEN** `saveToGallery()` is called
- **THEN** `saveState` SHALL transition from `idle` to `saving` before the save operation
- **AND** `PhotoRepository.saveOneToGallery` SHALL be called with the file path
- **AND** on `Result.ok`, `saveState` SHALL transition to `saved`
- **AND** `notifyListeners` SHALL be called

#### Scenario: Save fails with error

- **GIVEN** `cachedFile` holds a valid File
- **AND** `PhotoRepository.saveOneToGallery` returns `Result.error`
- **WHEN** `saveToGallery()` is called
- **THEN** `saveState` SHALL return to `idle`
- **AND** `notifyListeners` SHALL be called

#### Scenario: Save prevented when already saving

- **GIVEN** `saveState` is `saving`
- **WHEN** `saveToGallery()` is called
- **THEN** the method SHALL return immediately without performing any operation

#### Scenario: Permission denied

- **GIVEN** `PhotoRepository.saveOneToGallery` returns `Result.error` with permission denial
- **WHEN** `saveToGallery()` is called
- **THEN** `saveState` SHALL return to `idle`
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
### Requirement: SaveState enum

The `PhotoDetailViewModel` file SHALL define a `SaveState` enum with three values: `idle`, `saving`, and `saved`. The ViewModel SHALL use `SaveState` instead of separate `isSaving` and `isSaved` boolean flags to represent the save operation state.

#### Scenario: SaveState enum values

- **GIVEN** the `SaveState` enum
- **WHEN** its values are inspected
- **THEN** it SHALL contain exactly `idle`, `saving`, and `saved`


<!-- @trace
source: photo-detail-viewer-redesign
updated: 2026-03-23
code:
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_capsule_bar.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_detail/photo_detail_view_model_test.dart
-->

---
### Requirement: Photo list management

The `PhotoDetailViewModel` SHALL manage a list of `PhotoEntity` objects and a current index. It SHALL expose `photos` (List<PhotoEntity>), `currentIndex` (int), and `totalCount` (int) as read-only properties.

#### Scenario: Initial list state

- **GIVEN** a newly created `PhotoDetailViewModel`
- **WHEN** its list properties are inspected
- **THEN** `photos` SHALL be an empty list
- **AND** `currentIndex` SHALL be `0`
- **AND** `totalCount` SHALL be `0`


<!-- @trace
source: photo-detail-viewer-redesign
updated: 2026-03-23
code:
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_capsule_bar.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_detail/photo_detail_view_model_test.dart
-->

---
### Requirement: Metadata caching

The `PhotoDetailViewModel` SHALL maintain a metadata cache (`Map<int, _PhotoMetadata>`) to avoid redundant I/O and image decoding when revisiting previously viewed photos. The `_PhotoMetadata` class SHALL hold `cachedFile` (File?), `fileSizeBytes` (int?), `imageWidth` (int?), and `imageHeight` (int?).

#### Scenario: Cached metadata retrieval

- **GIVEN** a photo at index N has been loaded previously
- **WHEN** `setCurrentIndex` is called with index N again
- **THEN** the ViewModel SHALL retrieve metadata from the cache
- **AND** SHALL NOT call `CacheRepository.cachedFile` again for that index


<!-- @trace
source: photo-detail-viewer-redesign
updated: 2026-03-23
code:
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_capsule_bar.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_detail/photo_detail_view_model_test.dart
-->

---
### Requirement: Set current index

The `PhotoDetailViewModel` SHALL provide a `setCurrentIndex(int index)` method. When called, it SHALL update `_currentIndex`, reset `_saveState` to `SaveState.idle`, load metadata for the new index (from cache or I/O), and call `notifyListeners()`.

#### Scenario: Switch to a different photo

- **GIVEN** a loaded ViewModel with multiple photos
- **WHEN** `setCurrentIndex` is called with a different index
- **THEN** `currentIndex` SHALL equal the new index
- **AND** `photo` SHALL return the `PhotoEntity` at the new index
- **AND** `saveState` SHALL be `SaveState.idle`
- **AND** `notifyListeners` SHALL be called

<!-- @trace
source: photo-detail-viewer-redesign
updated: 2026-03-23
code:
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_capsule_bar.dart
  - naver_blog_image_downloader/lib/ui/photo_gallery/widgets/photo_gallery_view.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/view_model/photo_detail_view_model.dart
  - naver_blog_image_downloader/lib/ui/photo_detail/widgets/photo_detail_view.dart
tests:
  - naver_blog_image_downloader/test/ui/photo_detail/photo_detail_view_model_test.dart
-->