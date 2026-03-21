## 1. GalleryService saveToGallery method（GalleryService 類別設計）

- [x] 1.1 在 `lib/data/services/gallery_service.dart` 中實作 GalleryService saveToGallery method：定義 `GalleryService` 類別
- [x] 1.2 實作 `Future<void> saveToGallery(String filePath)` 方法，呼叫 `Gal.putImage(filePath)`

## 2. GalleryService requestPermission method（薄封裝策略）

- [x] 2.1 實作 GalleryService requestPermission method：定義 `Future<bool> requestPermission()` 方法
- [x] 2.2 呼叫 `Gal.requestAccess()` 並回傳授權結果
