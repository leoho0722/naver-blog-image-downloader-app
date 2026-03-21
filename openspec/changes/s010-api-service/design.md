## Context

應用程式需要呼叫後端 Lambda API 的 `/api/photos` 端點，傳送 Naver Blog URL 並取得照片清單。此服務類別負責封裝 HTTP POST 請求、解析 JSON 回應、以及處理錯誤狀態碼。透過建構子注入 `http.Client`，使服務在測試中可使用 mock client。

## Goals / Non-Goals

**Goals:**

- 實作 `ApiService` 類別，提供呼叫 Lambda API 的方法
- 使用可注入的 `http.Client` 確保可測試性
- 在非 200 狀態碼時拋出 `HttpException`
- 撰寫完整的單元測試

**Non-Goals:**

- 不實作認證或 token 管理
- 不實作請求快取或重試邏輯（重試由 Repository 層處理）
- 不處理網路連線狀態檢查

## Decisions

### ApiService 類別設計

`ApiService` 類別透過建構子接收 `http.Client` 實例，提供 `fetchPhotos` 方法：
- 接受 `String blogUrl` 參數
- 向 `${AppConfig.baseUrl}/api/photos` 發送 HTTP POST 請求
- 請求 body 為 JSON 格式，包含 `url` 欄位
- 設定 `Content-Type: application/json` header
- 成功時（status 200）解析 JSON 回應為 `PhotoDownloadResponse`
- 非 200 時拋出 `HttpException`

### 單元測試策略

使用 `mocktail` 套件 mock `http.Client`，測試以下情境：
- 成功回應的 JSON 解析
- 非 200 狀態碼的例外拋出
- 請求 URL 與 headers 的正確性

## Risks / Trade-offs

- [取捨] 使用 `http` 套件而非 `dio` 進行 API 呼叫，因為此端點僅需簡單 POST 請求，不需串流功能 → 保持輕量
- [取捨] 不在服務層處理重試邏輯，由上層 Repository 決定重試策略 → 職責分離
- [風險] `HttpException` 訊息可能暴露後端錯誤細節 → Repository 層轉換為 `AppError` 時會過濾敏感資訊
