## 1. 資料模型重構

- [ ] 1.1 Sealed class 取代單一 WhatsNewFeature（重構 WhatsNewFeature data model）：修改 `lib/config/whats_new_registry.dart`，將 `WhatsNewFeature` 改為 sealed class `WhatsNewItem`（含 `titleKey`、`descriptionKey`），新增子類 `WhatsNewTextItem`（含 `IconData icon`）與 `WhatsNewImageItem`（含 `String base64Image`）
- [ ] 1.2 實作 WhatsNewEntry 包裝 class（WhatsNewEntry wrapper class）：在 `lib/config/whats_new_registry.dart` 新增 `WhatsNewEntry` class（含 `List<WhatsNewItem> items`），判斷渲染格式的邏輯由 items 的 runtime type 決定
- [ ] 1.3 更新 Onboarding steps registry：將 `onboardingSteps` 從 `List<WhatsNewFeature>` 改為 `onboardingEntry`（`WhatsNewEntry` 型別），4 個項目改為 `WhatsNewTextItem`
- [ ] 1.4 更新 What's New version registry：將 `whatsNewRegistry` 從 `Map<String, List<WhatsNewFeature>>` 改為 `Map<String, WhatsNewEntry>`，`'1.4.0'` entry 使用 `WhatsNewTextItem`

## 2. WhatsNewDataSource abstraction 資料來源抽象

- [ ] 2.1 實作 WhatsNewDataSource 抽象介面（WhatsNewDataSource abstraction）：在 `lib/config/whats_new_registry.dart` 新增 `abstract class WhatsNewDataSource`（含 `WhatsNewEntry? getOnboardingEntry()` 與 `WhatsNewEntry? getWhatsNewEntry(String version)` 兩個方法）
- [ ] 2.2 實作 `WhatsNewDataSourceImpl`（`implements WhatsNewDataSource`），目前從 `onboardingEntry` 和 `whatsNewRegistry` 讀取內容，未來 API 在同一 class 擴充；新增 Riverpod provider（`@Riverpod(keepAlive: true)`）

## 3. ViewModel 適配

- [ ] 3.1 修改 WhatsNewViewModel sealed state：`lib/ui/whats_new/view_model/whats_new_view_model.dart` 的 `build()` 改為透過 `WhatsNewDataSource` provider 取得內容；sealed state 中的 `List<WhatsNewFeature>` 改為 `WhatsNewEntry`；當 `getOnboardingEntry()` 或 `getWhatsNewEntry()` 回傳 `null` 時，靜默寫入版本號並回傳 `WhatsNewHidden`；所有情境（onboarding 顯示/跳過、what's new 顯示/跳過、同版本、PackageInfo 失敗、dismiss）皆以 fire-and-forget 方式透過 `LogRepository` 記錄 log
- [ ] 3.2 執行 `dart run build_runner build --delete-conflicting-outputs` 產生 `.g.dart`

## 4. View 層 — Dialog 雙格式渲染

- [ ] 4.1 修改 `lib/ui/whats_new/widgets/whats_new_dialog.dart` 支援純文字列表：將 `List<WhatsNewFeature>` 參數改為 `WhatsNewEntry`，純文字（全部 `WhatsNewTextItem`）維持現有圓角 Dialog 列表渲染
- [ ] 4.2 實作 PageView carousel dialog UI：在 `lib/ui/whats_new/widgets/whats_new_dialog.dart` 新增圖文 PageView 渲染（含 `WhatsNewImageItem` 時），每頁顯示圖片 + 標題 + 描述，底部圓點指示器，非最後一頁按鈕為「下一步」、最後一頁為「知道了」
- [ ] 4.3 修改 `lib/ui/whats_new/widgets/whats_new_view.dart`：`showWhatsNewDialog` 改為傳遞 `WhatsNewEntry` 而非分別傳遞 title + features

## 5. L10n

- [ ] 5.1 在 5 個 ARB 檔新增 `whatsNewCloseButton`（「關閉」）key，用於 PageView carousel 所有頁面的按鈕文字

## 6. 驗證

- [ ] 6.1 執行 `flutter analyze` 確認無靜態分析錯誤
- [ ] 6.2 執行 `dart format .` 確保格式一致
- [ ] 6.3 執行 `flutter test` 確認既有測試通過
