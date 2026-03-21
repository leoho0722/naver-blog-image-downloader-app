## 1. PhotoRepository construction（依賴注入設計）

- [x] 1.1 在 `lib/data/repositories/photo_repository.dart` 建立 `PhotoRepository` 類別，建構函式接受 `ApiService`、`FileDownloadService`、`GalleryService`、`CacheRepository` 四個必要參數並儲存為私有欄位（PhotoRepository construction）
- [x] 1.2 在 `test/data/repositories/photo_repository_test.dart` 建立測試檔案與 Mock 依賴

## 2. BlogId derivation and API call（fetchPhotos 流程設計）

- [x] 2.1 實作 `fetchPhotos(String blogUrl)` 方法的前半段：呼叫 `CacheRepository.blogId(blogUrl)` 取得 blogId，再呼叫 `ApiService.fetchPhotos(blogUrl)` 取得 API 回應（BlogId derivation in fetchPhotos）
- [x] 2.2 實作 DTO 到 Entity 的轉換：將 `response.photos` 中的每個 `PhotoDto` 透過 `toEntity(response.blogTitle)` 轉為 `PhotoEntity`（API call and DTO to Entity conversion）
- [x] 2.3 撰寫單元測試驗證 API 呼叫成功與空列表情境

## 3. Cache status check（fetchPhotos 流程設計）

- [x] 3.1 實作快取狀態檢查：從 `PhotoEntity` 列表中提取 filename，呼叫 `CacheRepository.isBlogFullyCached(blogId, filenames)` 判斷快取狀態（Cache status check in fetchPhotos）
- [x] 3.2 撰寫單元測試驗證完整快取與部分快取兩種情境

## 4. Result wrapping and error handling（錯誤處理策略）

- [x] 4.1 將 fetchPhotos 完整流程以 try-catch 包裹，成功時回傳 `Result.ok(FetchResult(...))`，例外時回傳 `Result.error(e)`（Result wrapping）
- [x] 4.2 撰寫單元測試驗證 API 錯誤與快取檢查錯誤均正確回傳 `Result.error`
