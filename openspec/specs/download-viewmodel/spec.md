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
