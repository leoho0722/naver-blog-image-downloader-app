## Why

目前專案缺少一個統一的照片資料存取層。使用者輸入 Naver Blog URL 後，App 需要呼叫 API 取得照片列表、將 DTO 轉換為 Entity、並檢查快取狀態，最終回傳一個統一的 `FetchResult`。`PhotoRepository` 的 `fetchPhotos` 方法整合了 `ApiService` 與 `CacheRepository`，作為照片資料流的 Single Source of Truth。

## What Changes

- 新增 `lib/data/repositories/photo_repository.dart`，建立 `PhotoRepository` 類別
- 新增 `test/data/repositories/photo_repository_test.dart`，涵蓋 `fetchPhotos` 的完整測試
- `PhotoRepository` 透過建構函式注入 `ApiService`、`FileDownloadService`、`GalleryService`、`CacheRepository` 四個依賴
- 實作 `fetchPhotos(String blogUrl)` 方法：
  1. 使用 `CacheRepository.blogId()` 產生 blogId
  2. 呼叫 `ApiService.fetchPhotos()` 取得 API 回應
  3. 將 DTO 列表透過 `toEntity()` 轉換為 `PhotoEntity` 列表
  4. 呼叫 `CacheRepository.isBlogFullyCached()` 檢查快取狀態
  5. 回傳 `Result<FetchResult>`

## Capabilities

### New Capabilities

- `photo-repo-fetch`: 照片列表取得功能，整合 API 呼叫、DTO 轉 Entity、快取檢查，回傳 `Result<FetchResult>`

### Modified Capabilities

（無）

## Impact

- 新增檔案：`lib/data/repositories/photo_repository.dart`、`test/data/repositories/photo_repository_test.dart`
- 依賴 S002（Result）、S009（FetchResult）、S010（ApiService）、S014（CacheRepository）
- S017（downloadAllToCache）與 S018（saveToGalleryFromCache）將擴充此類別
