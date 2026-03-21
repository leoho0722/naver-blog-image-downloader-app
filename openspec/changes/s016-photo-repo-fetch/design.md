## Context

`PhotoRepository` 是 MVVM 架構中 Data Layer 的核心 Repository，負責整合多個底層 Service 並向 ViewModel 提供統一的資料存取介面。`fetchPhotos` 作為照片資料流的起點，串接 API 呼叫、資料轉換與快取檢查，封裝為 `Result<FetchResult>` 回傳。

## Goals / Non-Goals

**Goals:**

- 建立 `PhotoRepository` 類別，透過建構函式注入四個依賴
- 實作 `fetchPhotos(String blogUrl)` 方法，完成 API → DTO → Entity → 快取檢查 → Result 的完整流程
- 將底層服務的錯誤封裝為 `Result.error`，避免例外洩漏至 ViewModel

**Non-Goals:**

- 不實作下載功能（屬於 S017）
- 不實作相簿儲存功能（屬於 S018）
- 不實作 DTO 本身的定義（屬於 S007）

## Decisions

### 依賴注入設計

`PhotoRepository` 透過建構函式注入所有依賴，不使用 Service Locator 模式。建構函式接受 `ApiService`、`FileDownloadService`、`GalleryService`、`CacheRepository` 四個參數，即使 `fetchPhotos` 僅使用 `ApiService` 與 `CacheRepository`，也一併注入以支援 S017、S018 的擴充，避免後續修改建構函式簽名。

### fetchPhotos 流程設計

`fetchPhotos(String blogUrl)` 的執行流程：
1. 呼叫 `CacheRepository.blogId(blogUrl)` 產生 `blogId`
2. 呼叫 `ApiService.fetchPhotos(blogUrl)` 取得 API 回應
3. 將每個 `PhotoDto` 透過 `toEntity(blogTitle)` 擴充方法轉換為 `PhotoEntity`
4. 從轉換後的 `PhotoEntity` 列表中提取所有 `filename` 作為預期檔案清單
5. 呼叫 `CacheRepository.isBlogFullyCached(blogId, filenames)` 檢查快取狀態
6. 建構 `FetchResult` 並回傳 `Result.ok(fetchResult)`

### 錯誤處理策略

使用 try-catch 包裹整個流程，任何 `Exception` 皆轉換為 `Result.error(e)`。不區分 API 錯誤與快取錯誤類型，統一回傳失敗結果由 ViewModel 層決定呈現方式。

## Risks / Trade-offs

- [取捨] 預先注入所有四個依賴而非僅注入 fetchPhotos 所需 → 減少後續 S017/S018 的破壞性修改
- [風險] `toEntity()` 轉換可能因 DTO 欄位缺失而拋出例外 → 已被 try-catch 捕獲並封裝為 Result.error
- [取捨] 不區分錯誤類型 → 簡化實作，但 ViewModel 無法針對特定錯誤做差異化處理
