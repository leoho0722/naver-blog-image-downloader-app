## 1. PhotoDownloadRequest DTO defined（PhotoDownloadRequest 請求 DTO）

- [x] 1.1 在 `lib/data/models/dtos/photo_download_request.dart` 中實作 PhotoDownloadRequest DTO defined：定義 `PhotoDownloadRequest` 類別
- [x] 1.2 實作 `toJson()` 方法，回傳 `Map<String, dynamic>` 包含所有請求參數

## 2. PhotoDownloadResponse DTO defined（PhotoDownloadResponse 回應 DTO）

- [x] 2.1 在 `lib/data/models/dtos/photo_download_response.dart` 中實作 PhotoDownloadResponse DTO defined：定義 `PhotoDownloadResponse` 類別，包含 `blogTitle`（String）與 `photos`（List\<PhotoDto\>）屬性
- [x] 2.2 實作 `factory PhotoDownloadResponse.fromJson(Map<String, dynamic> json)` 建構子

## 3. PhotoDto DTO defined with toEntity conversion（PhotoDto 照片 DTO 與 toEntity 轉換）

- [x] 3.1 在 `lib/data/models/dtos/photo_download_response.dart` 中實作 PhotoDto DTO defined with toEntity conversion：定義 `PhotoDto` 類別
- [x] 3.2 實作 `factory PhotoDto.fromJson(Map<String, dynamic> json)` 建構子
- [x] 3.3 實作 `PhotoEntity toEntity()` 方法，將 DTO 屬性映射為 `PhotoEntity`
