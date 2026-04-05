## Summary

擴展 What's New / Onboarding 功能，支援兩種內容格式（純文字列表 + 圖文 PageView 輪播），並預留資料來源抽象層以便未來切換為後端 API 配置。

## Motivation

目前 What's New 功能只有一種純文字格式（Icon + 標題 + 描述），無法展示圖文引導。首次安裝引導適合用圖文輪播（每頁一張圖 + 說明），而版本更新的新功能列表適合用純文字。兩種格式需共存於同一套架構中，且資料來源未來可能從本地 registry 切換為後端 API 配置。

## Proposed Solution

- 將 `WhatsNewFeature` 改為 sealed class，分為 `WhatsNewTextItem`（Icon + title + description）與 `WhatsNewImageItem`（base64 encoded image + title + description）
- 新增 `WhatsNewEntry` class 包裝每個版本/引導的內容，記錄使用的格式（text / image）
- Dialog 根據格式自動切換渲染：text → 現有圓角 Dialog 列表，image → PageView 輪播 + 圓點指示器
- 新增 `WhatsNewDataSource` 抽象介面（`Future<WhatsNewEntry?> fetch(String version)`），目前僅實作 `LocalWhatsNewDataSource`（從 registry 讀取），ViewModel 透過此介面取得內容，未來可替換為 API 實作
- Onboarding 的 `onboardingSteps` 改為 `WhatsNewEntry` 格式，支援切換為圖文

## Non-Goals

- 不實作後端 API `WhatsNewDataSource`（僅預留介面）
- 不新增圖片素材（onboarding 圖文內容維持佔位或使用 Icon，待設計師提供素材後替換）

## Impact

- 修改 spec: `whats-new-onboarding`
- 修改檔案:
  - `lib/config/whats_new_registry.dart`（sealed class 重構 + WhatsNewEntry + 資料來源介面）
  - `lib/ui/whats_new/widgets/whats_new_dialog.dart`（支援兩種格式渲染）
  - `lib/ui/whats_new/view_model/whats_new_view_model.dart`（使用 WhatsNewDataSource 取得內容）
  - `lib/ui/whats_new/widgets/whats_new_view.dart`（傳遞格式資訊）
