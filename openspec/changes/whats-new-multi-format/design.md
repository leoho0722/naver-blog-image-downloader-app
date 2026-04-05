## Context

目前 What's New 功能使用單一 `WhatsNewFeature` class（`IconData` + `titleKey` + `descriptionKey`），所有內容以純文字列表呈現在圓角 Dialog 中。Registry 為靜態 `Map<String, List<WhatsNewFeature>>`。需要擴展為支援圖文 PageView 格式，並預留資料來源抽象以便未來接入後端 API。

## Goals / Non-Goals

**Goals:**

- `WhatsNewFeature` 重構為 sealed class，支援 text（Icon）和 image（base64 encoded image）兩種項目類型
- 新增 `WhatsNewEntry` 包裝 class，統一描述每組內容（format + items）
- Dialog 自動根據 format 切換渲染方式（列表 vs PageView）
- 抽象 `WhatsNewDataSource` 介面 + 單一 `WhatsNewDataSourceImpl` 實作

**Non-Goals:**

- 不實作遠端 API 資料取得邏輯（僅預留介面，未來在同一實作中擴充）
- 不提供圖片素材（使用 base64 encoded image 佔位）

## Decisions

### Sealed class 取代單一 WhatsNewFeature

將 `WhatsNewFeature` 改為 sealed class，兩個子類：

```dart
sealed class WhatsNewItem {
  const WhatsNewItem({required this.titleKey, required this.descriptionKey});
  final String titleKey;
  final String descriptionKey;
}

class WhatsNewTextItem extends WhatsNewItem {
  const WhatsNewTextItem({required this.icon, required super.titleKey, required super.descriptionKey});
  final IconData icon;
}

class WhatsNewImageItem extends WhatsNewItem {
  const WhatsNewImageItem({required this.base64Image, required super.titleKey, required super.descriptionKey});
  final String base64Image;
}
```

**替代方案**：在原 class 加 optional `base64Image` 欄位。放棄原因：缺乏型別安全，Icon 和 base64Image 同時存在或都不存在的語意不清。

### WhatsNewEntry 包裝 class

```dart
class WhatsNewEntry {
  const WhatsNewEntry({required this.items});
  final List<WhatsNewItem> items;
}
```

格式由 items 的實際類型決定（全部 `WhatsNewTextItem` → 列表；含 `WhatsNewImageItem` → PageView）。不需額外 enum，直接用 items 的 runtime type 判斷。

Registry 從 `Map<String, List<WhatsNewFeature>>` 改為 `Map<String, WhatsNewEntry>`，`onboardingSteps` 也改為 `WhatsNewEntry`。

### Dialog 雙格式渲染

Dialog 元件檢查 `items` 的類型：

- 全部為 `WhatsNewTextItem` → 目前的圓角 Dialog 列表渲染（不變）
- 含 `WhatsNewImageItem` → PageView 輪播，每頁顯示圖片 + 標題 + 描述，底部圓點指示器，所有頁面統一顯示「關閉」按鈕（使用者可在任何頁面關閉）

### WhatsNewDataSource 抽象介面

```dart
abstract class WhatsNewDataSource {
  WhatsNewEntry? getOnboardingEntry();
  WhatsNewEntry? getWhatsNewEntry(String version);
}
```

`WhatsNewDataSourceImpl` 實作此介面，目前從 `onboardingEntry` 和 `whatsNewRegistry` 常數讀取。ViewModel 透過 Riverpod provider 注入 `WhatsNewDataSource` 介面。未來需要 API 資料時，在同一個 `WhatsNewDataSourceImpl` 中擴充（先嘗試 API → fallback 本地 registry），不需要分開 Local / Remote 兩個 class，因為回傳邏輯相同。

### ViewModel 適配

`WhatsNewViewModel.build()` 從直接讀取 registry 改為呼叫 `WhatsNewDataSource.getWhatsNewEntry(version)` 和 `getOnboardingEntry()`。Sealed state（`WhatsNewHidden` / `WhatsNewOnboarding` / `WhatsNewUpdate`）不變，只是內部的 `features`/`steps` 型別從 `List<WhatsNewFeature>` 改為 `WhatsNewEntry`。

## Risks / Trade-offs

- **Sealed class 遷移**：需更新所有引用 `WhatsNewFeature` 的位置（ViewModel state、Dialog、l10n 解析），但檔案數量少（4 個），風險可控
- **PageView 在小內容量時的體驗**：若只有 1 頁 image item，PageView 退化為靜態頁面（無滑動），行為合理無需特別處理
- **DataSource 介面抽象**：目前只從本地讀取，但介面簡單（2 個方法），未來在同一實作中加入 API 呼叫即可，維護成本極低
