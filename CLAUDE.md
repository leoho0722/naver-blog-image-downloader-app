<!-- SPECTRA:START v1.0.1 -->

# Spectra Instructions

This project uses Spectra for Spec-Driven Development(SDD). Specs live in `openspec/specs/`, change proposals in `openspec/changes/`.

## Use `/spectra:*` skills when:

- A discussion needs structure before coding → `/spectra:discuss`
- User wants to plan, propose, or design a change → `/spectra:propose`
- Tasks are ready to implement → `/spectra:apply`
- There's an in-progress change to continue → `/spectra:ingest`
- User asks about specs or how something works → `/spectra:ask`
- Implementation is done → `/spectra:archive`

## Workflow

discuss? → propose → apply ⇄ ingest → archive

- `discuss` is optional — skip if requirements are clear
- Requirements change mid-work? Plan mode → `ingest` → resume `apply`

## Parked Changes

Changes can be parked（暫存）— temporarily moved out of `openspec/changes/`. Parked changes won't appear in `spectra list` but can be found with `spectra list --parked`. To restore: `spectra unpark <name>`. The `/spectra:apply` and `/spectra:ingest` skills handle parked changes automatically.

<!-- SPECTRA:END -->

# 專案說明

Naver Blog 照片下載器 — 輸入 Naver Blog 網址，自動擷取並批次下載文章中的所有照片至本機快取與裝置相簿。

## 技術棧

- **框架**：Flutter（僅 iOS / Android）
- **架構**：MVVM + Riverpod 3.x（code generation + `@riverpod` 註解）
- **導航**：GoRouter
- **API 通訊**：AWS Amplify Flutter SDK（REST）
- **檔案下載**：Dio（串流 + 指數退避重試）
- **相簿存取**：原生 MethodChannel（iOS: PhotoKit / Android: MediaStore）
- **快取**：磁碟快取 + SharedPreferences metadata

## 初始設定（新 clone）

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

> `.g.dart` 檔案已加入 `.gitignore`，新 clone 後須執行 code generation 產生 Riverpod provider 定義。

## 平台最低版本

- **iOS**：17.0
- **Android**：14.0（API 34）

## 架構分層

```text
View（ConsumerWidget / ConsumerStatefulWidget）
  ↓ ref.watch
ViewModel（Notifier<State> / AsyncNotifier<State>，@riverpod 註解）
  ↓ ref.read
Repository（PhotoRepository / CacheRepository）— SSOT
  ↓
Service（ApiService / FileDownloadService / GalleryService）— 無狀態
  ↓
Native（Swift / Kotlin via MethodChannel）— GalleryService 橋接原生 API
```

- ViewModel 不得直接存取 Service，必須透過 Repository
- Repository 方法失敗時直接 throw Exception，ViewModel 以 `AsyncValue` 處理 loading / error / data 狀態
- GalleryService 透過 MethodChannel 呼叫原生 API（iOS: PhotoKit / Android: MediaStore）
- ViewModel 使用不可變 State class + `copyWith`，非同步操作以 `AsyncValue<T>` 欄位表達
- Service / Repository 使用 `@Riverpod(keepAlive: true)`（App 級單例）
- `AppSettingsViewModel` 使用 `@Riverpod(keepAlive: true)`（提供 theme/locale 給 MaterialApp）
- 其餘 ViewModel 使用 `@riverpod`（auto-dispose，畫面離開時自動清理）
- ViewModel 中多個互斥狀態須以 `AsyncValue<T>` 欄位表達（如儲存操作使用 `AsyncValue<void>?`：`null` = 閒置、`AsyncLoading` = 執行中、`AsyncData` = 完成、`AsyncError` = 失敗），避免自訂 enum 或多個 boolean flags

## API 通訊（非同步任務模式）

後端為 AWS API Gateway + Lambda，因 Lambda 執行爬蟲超過 API Gateway 29 秒硬限制，採用非同步模式：

1. `POST /api/photos` — `{"action": "download", "blog_url": "..."}` → HTTP 202，回傳 `job_id`
2. `POST /api/photos` — `{"action": "status", "job_id": "..."}` → 輪詢（每 3 秒，最多 10 分鐘）
3. 完成 → HTTP 200 + `image_urls` 清單；失敗 → HTTP 500 + `errors` 清單

## 快取策略

- Blog ID：URL 的 SHA-256 前 16 碼
- 快取路徑：`<appCacheDir>/blogs/<blogId>/<filename>`
- 軟性閥值：300 MB，超過時自動淘汰（優先清除已儲存至相簿的最舊 Blog）
- Metadata 持久化至 SharedPreferences

## 環境切換

透過編譯參數切換 API Gateway 部署階段：

```bash
flutter run                              # 預設（default stage）
flutter run --dart-define=API_STAGE=uat   # UAT 環境
flutter build apk --dart-define=API_STAGE=prod  # 正式環境
```

支援階段：`default`、`ut`、`stg`、`uat`、`prod`

## 開發規範

1. **遵循 Spectra 流程**：所有功能變更皆須走 `propose → apply ⇄ ingest → archive` 流程。建立 change 時，若 `openspec/specs/` 已有相關 spec 存在，須在 proposal 的 Modified Capabilities 中自動關聯，確保 archive 時 delta spec 能同步回主 spec。
2. **遵循 Flutter 官方規範**：所有 Flutter 相關檔案皆需符合 `flutter/skills` 官方規範（包括 Widget 建構、狀態管理、導航、測試等）。
3. **Analyze + Format**：執行 `flutter analyze` 後，須自動接續執行 `dart format .`，確保所有 Flutter 相關檔案排版格式一致。
4. **程式碼註解規範（Dart）**：
   - 所有註解須以**正體中文**撰寫
   - 註解須具備**高可讀性**、**直覺易懂**、**高可維護性**，使用連 PM 或 Flutter 初學者都能理解的白話說明，避免過度技術術語
   - 所有 class、constructor、method、property、getter、enum、enum value、top-level function/variable 皆須撰寫 `///` 文件註解
   - 有參數的項目須以 `[paramName]` 格式標記每個參數並附說明
   - 非 void 回傳值須描述回傳內容（如 `/// 回傳...`）
   - 會拋出例外的方法須標明例外類型（如 `/// 失敗時拋出 [AppError]`）
   - Private 項目（含 `_` 開頭的 class、method、field）亦須撰寫註解
   - `copyWith` 方法須列出所有參數說明與回傳描述
   - `operator ==` 須標記 `[other]` 參數，`hashCode` 須標記回傳描述
5. **原生程式碼規範（Swift / Kotlin）**：
   - 縮排使用 4 格空格（Dart 用 2 格，原生用 4 格）
   - 所有註解須以**正體中文**撰寫，具備**高可讀性**、**直覺易懂**、**高可維護性**，使用連 PM 或 Flutter 初學者都能理解的白話說明
   - 註解須包含傳入參數、回傳值、錯誤拋出說明（Swift: `- Parameter`/`- Returns`/`- Throws`，Kotlin: `@param`/`@return`/`@throws`）
   - Swift 當有多個傳入參數時，須使用 `- Parameters:` 並將各參數各自一行（單一參數使用 `- Parameter paramName:`）
   - 不得直接在生命週期方法（`didFinishLaunchingWithOptions`/`configureFlutterEngine`）內撰寫邏輯，應抽成獨立方法
   - Private 方法透過 Extension 方式管理（Swift: `private extension`，Kotlin: file-level `private fun ClassName.xxx()`）

## Commit 風格

使用正體中文撰寫 conventional commits，description（body）使用列點格式，例如：

- `feat(s010): 實作 ApiService（AWS Amplify SDK + 非同步任務模式）`
- `fix: 修正下載進度對話框在 build 期間觸發 setState`

```text
refactor(settings-view): 設定頁面 Cupertino → Material 3 重構

- 移除所有 Cupertino 元件
- 統一採用 Material 3 Card.filled + ListTile 呈現
```
