## 1. ApiService class with injectable http.Client（ApiService 類別設計）

- [x] 1.1 在 `lib/data/services/api_service.dart` 中實作 ApiService class with injectable http.Client：定義 `ApiService` 類別，建構子接受 `http.Client` 參數
- [x] 1.2 將注入的 `http.Client` 儲存為 `_client` 私有 final 欄位

## 2. fetchPhotos sends HTTP POST to Lambda API（ApiService 類別設計）

- [x] 2.1 實作 fetchPhotos sends HTTP POST to Lambda API：定義 `Future<PhotoDownloadResponse> fetchPhotos(String blogUrl)` 方法
- [x] 2.2 向 `${AppConfig.baseUrl}/api/photos` 發送 POST 請求，body 為 JSON `{"url": blogUrl}`，header 設定 `Content-Type: application/json`
- [x] 2.3 成功（200）時解析 JSON 回應為 `PhotoDownloadResponse` 並回傳

## 3. HttpException thrown on non-200 response（ApiService 類別設計）

- [x] 3.1 實作 HttpException thrown on non-200 response：非 200 狀態碼時拋出 `HttpException`，訊息包含狀態碼

## 4. ApiService unit tests（單元測試策略）

- [x] 4.1 在 `test/data/services/api_service_test.dart` 中實作 ApiService unit tests：使用 `mocktail` mock `http.Client`
- [x] 4.2 測試成功回應的 JSON 解析
- [x] 4.3 測試非 200 狀態碼拋出 `HttpException`
- [x] 4.4 測試請求 URL、headers 與 body 的正確性
