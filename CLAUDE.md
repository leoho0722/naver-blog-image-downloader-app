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
- **架構**：MVVM + Provider（ChangeNotifier）
- **導航**：GoRouter
- **API 通訊**：AWS Amplify Flutter SDK（REST）
- **檔案下載**：Dio（串流 + 指數退避重試）
- **相簿存取**：image_gallery_saver
- **快取**：磁碟快取 + SharedPreferences metadata

## 架構分層

```text
View（StatelessWidget / StatefulWidget）
  ↓ context.watch
ViewModel（ChangeNotifier）
  ↓
Repository（PhotoRepository / CacheRepository）— SSOT
  ↓
Service（ApiService / FileDownloadService / GalleryService）— 無狀態
```

- ViewModel 不得直接存取 Service，必須透過 Repository
- Repository 回傳 `Result<T>`（sealed class），ViewModel 以 switch 處理 Ok / Error

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

## Commit 風格

使用正體中文撰寫 conventional commits，例如：

- `feat(s010): 實作 ApiService（AWS Amplify SDK + 非同步任務模式）`
- `fix: 修正下載進度對話框在 build 期間觸發 setState`
