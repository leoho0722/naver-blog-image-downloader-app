# photo-gallery-viewmodel

## Overview

PhotoGalleryViewModel manages the photo list display, selection mode, and gallery saving operations for the photo gallery screen. It extends ChangeNotifier and delegates gallery saving to PhotoRepository and cache access to CacheRepository.

## File

`lib/ui/photo_gallery/view_model/photo_gallery_view_model.dart`

### Requirement: gallery state properties

PhotoGalleryViewModel SHALL extend `ChangeNotifier`.

PhotoGalleryViewModel SHALL call `notifyListeners()` after every state change.

PhotoGalleryViewModel SHALL expose the following read-only properties:
- `photos` (List&lt;PhotoEntity&gt;) — the loaded photo list
- `blogId` (String) — the Blog identifier
- `isSelectMode` (bool) — whether selection mode is active
- `selectedIds` (Set&lt;String&gt;) — the set of selected photo identifiers
- `isSaving` (bool) — whether a save-to-gallery operation is in progress

#### Scenario: initial state

Given a newly created PhotoGalleryViewModel,
then `photos` SHALL be an empty list,
and `isSelectMode` SHALL be `false`,
and `selectedIds` SHALL be an empty set,
and `isSaving` SHALL be `false`.

### Requirement: load photos

PhotoGalleryViewModel SHALL provide a `load(List<PhotoEntity> photos, String blogId)` method.

When `load` is called, it SHALL store the photos list and blogId, and call `notifyListeners()`.

#### Scenario: load photo list

Given a PhotoGalleryViewModel,
when `load` is called with a list of 10 photos and a blogId,
then `photos` SHALL contain 10 items,
and `blogId` SHALL equal the provided value.

### Requirement: toggle select mode

PhotoGalleryViewModel SHALL provide a `toggleSelectMode()` method.

When `toggleSelectMode` is called, it SHALL toggle `isSelectMode` between `true` and `false`. When exiting selection mode (setting to `false`), it SHALL clear `selectedIds`.

#### Scenario: enter selection mode

Given a PhotoGalleryViewModel with `isSelectMode` as `false`,
when `toggleSelectMode()` is called,
then `isSelectMode` SHALL be `true`.

#### Scenario: exit selection mode clears selection

Given a PhotoGalleryViewModel with `isSelectMode` as `true` and 3 selected photos,
when `toggleSelectMode()` is called,
then `isSelectMode` SHALL be `false`,
and `selectedIds` SHALL be empty.

### Requirement: toggle selection

PhotoGalleryViewModel SHALL provide a `toggleSelection(String photoId)` method.

When `toggleSelection` is called with a photoId that is not in `selectedIds`, it SHALL add the photoId. When called with a photoId already in `selectedIds`, it SHALL remove it.

#### Scenario: select a photo

Given a PhotoGalleryViewModel in selection mode,
when `toggleSelection("photo1")` is called and "photo1" is not selected,
then `selectedIds` SHALL contain "photo1".

#### Scenario: deselect a photo

Given a PhotoGalleryViewModel with "photo1" in `selectedIds`,
when `toggleSelection("photo1")` is called,
then `selectedIds` SHALL NOT contain "photo1".

### Requirement: select all

PhotoGalleryViewModel SHALL provide a `selectAll()` method.

When all photos are currently selected, `selectAll` SHALL clear `selectedIds` (deselect all). Otherwise, `selectAll` SHALL add all photo identifiers to `selectedIds`.

#### Scenario: select all when none selected

Given a PhotoGalleryViewModel with 5 photos and no selections,
when `selectAll()` is called,
then `selectedIds` SHALL contain all 5 photo identifiers.

#### Scenario: deselect all when all selected

Given a PhotoGalleryViewModel with 5 photos all selected,
when `selectAll()` is called,
then `selectedIds` SHALL be empty.

### Requirement: save selected to gallery

PhotoGalleryViewModel SHALL provide a `saveSelectedToGallery()` method.

When called, it SHALL:
1. Set `isSaving` to `true`
2. Filter photos by `selectedIds`
3. Call `PhotoRepository.saveToGalleryFromCache` for the selected photos
4. Set `isSaving` to `false`

#### Scenario: save selected photos

Given a PhotoGalleryViewModel with 2 photos selected out of 5,
when `saveSelectedToGallery()` is called,
then `PhotoRepository.saveToGalleryFromCache` SHALL be called with the 2 selected photos,
and `isSaving` SHALL be `false` after completion.

### Requirement: save all to gallery

PhotoGalleryViewModel SHALL provide a `saveAllToGallery()` method.

When called, it SHALL:
1. Set `isSaving` to `true`
2. Call `PhotoRepository.saveToGalleryFromCache` for all photos
3. Set `isSaving` to `false`

#### Scenario: save all photos

Given a PhotoGalleryViewModel with 5 photos loaded,
when `saveAllToGallery()` is called,
then `PhotoRepository.saveToGalleryFromCache` SHALL be called with all 5 photos,
and `isSaving` SHALL be `false` after completion.

### Requirement: cached file access

PhotoGalleryViewModel SHALL provide a `cachedFile(PhotoEntity photo)` method that delegates to `CacheRepository.cachedFile(photo.filename, blogId)` and returns `Future<File?>`.

#### Scenario: get cached file for photo

Given a PhotoGalleryViewModel with a loaded blogId,
when `cachedFile(photo)` is called,
then it SHALL delegate to `CacheRepository.cachedFile(photo.filename, blogId)`.
