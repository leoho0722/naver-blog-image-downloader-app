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
