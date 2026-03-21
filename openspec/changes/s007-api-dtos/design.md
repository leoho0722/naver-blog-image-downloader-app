## Context

應用程式透過 HTTP 與後端 Lambda API 通訊，需要將 Dart 物件與 JSON 之間進行轉換。DTO 層負責隔離 API 資料格式與 domain model，確保 API 回應格式變更時只需修改 DTO 層，不影響核心業務邏輯。

## Goals / Non-Goals

**Goals:**

- 實作 `PhotoDownloadRequest` DTO，將請求參數序列化為 JSON
- 實作 `PhotoDownloadResponse` DTO，從 JSON 反序列化 API 回應，包含 `blogTitle` 與 `List<PhotoDto>`
- 實作 `PhotoDto` DTO，從 JSON 反序列化單張照片資訊，並提供 `toEntity` 方法轉換為 `PhotoEntity`

**Non-Goals:**

- 不實作 HTTP 請求發送邏輯（由 API Service 負責）
- 不實作錯誤回應的 DTO
- 不實作 code generation（手動撰寫序列化邏輯）

## Decisions

### PhotoDownloadRequest 請求 DTO

定義 `PhotoDownloadRequest` 類別，包含發送 API 請求所需的參數，並提供 `toJson()` 方法回傳 `Map<String, dynamic>`。

### PhotoDownloadResponse 回應 DTO

定義 `PhotoDownloadResponse` 類別，包含：
- `blogTitle`（String）：部落格標題
- `photos`（List\<PhotoDto\>）：照片列表

提供 `factory PhotoDownloadResponse.fromJson(Map<String, dynamic> json)` 建構子。

### PhotoDto 照片 DTO 與 toEntity 轉換

定義 `PhotoDto` 類別，包含從 API 回傳的單張照片原始資訊，並提供：
- `factory PhotoDto.fromJson(Map<String, dynamic> json)` 建構子
- `PhotoEntity toEntity()` 方法，將 DTO 轉換為 domain model

## Risks / Trade-offs

- [取捨] 使用手動 JSON 序列化而非 json_serializable code generation，減少建構複雜度但增加手動維護成本 → 對於少量 DTO 類別，手動撰寫更直覺
- [風險] API 回應格式變更可能導致 fromJson 解析失敗 → 透過 Result 型別在上層處理解析錯誤
