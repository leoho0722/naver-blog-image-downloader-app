## Context

應用程式需要與後端 Lambda API 通訊，API base URL 等配置需集中管理。此外，應用程式中有多處使用的常數值（如應用程式名稱、預設值等）也需統一定義，避免魔術數字與硬編碼字串散落各處。

## Goals / Non-Goals

**Goals:**

- 實作 `AppConfig` 類別，集中管理 API base URL 等環境配置
- 實作 `Constants` 類別，定義應用程式共用常數
- 確保配置值易於修改與維護

**Non-Goals:**

- 不實作多環境切換機制（如 dev/staging/prod）
- 不實作執行期動態配置載入
- 不實作 .env 檔案讀取

## Decisions

### AppConfig 靜態配置類別

使用 abstract final class 定義 `AppConfig`，以 static const 方式宣告配置值：
- `baseUrl`：API base URL（Lambda API 端點）

使用 abstract final class 確保不可被實例化或繼承，語義上表達純靜態用途。

### Constants 常數類別

使用 abstract final class 定義 `Constants`，集中管理應用程式常數：
- 應用程式名稱
- 預設下載相關設定值

## Risks / Trade-offs

- [取捨] 使用 static const 而非環境變數注入，簡化實作但不支援不同環境切換 → 對於此應用程式規模，靜態配置已足夠
- [取捨] 將 AppConfig 與 Constants 分為兩個檔案，增加檔案數但職責分離更清楚
