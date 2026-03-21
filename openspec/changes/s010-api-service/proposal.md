## Why

應用程式需要與後端 Lambda API 通訊，以取得 Naver Blog 文章中的照片清單。需要一個封裝 HTTP POST 請求的服務類別，負責呼叫 `$baseUrl/api/photos` 端點，解析回應為 `PhotoDownloadResponse`，並在非 200 回應時拋出 `HttpException`。透過可注入的 `http.Client`，確保服務可測試性。

## What Changes

- 在 `lib/data/services/api_service.dart` 中實作 `ApiService` 類別，封裝 HTTP POST 請求邏輯
- 在 `test/data/services/api_service_test.dart` 中撰寫對應的單元測試

## Capabilities

### New Capabilities

- `api-service`: ApiService HTTP POST 服務，負責呼叫 Lambda API 並回傳結構化回應

### Modified Capabilities

（無）

## Impact

- 涵蓋檔案：`lib/data/services/api_service.dart`、`test/data/services/api_service_test.dart`
- 依賴：S001（專案依賴與目錄骨架）、S003（AppConfig 提供 baseUrl）、S007（API DTOs 提供 PhotoDownloadResponse）
- 此為資料服務層，後續 Repository 層（S016）將依賴於此
