import 'package:path/path.dart' as p;

import '../photo_entity.dart';

/// 照片下載的回應資料傳輸物件（DTO），對應後端 Lambda API 的 JSON 結構。
///
/// API 回傳的是圖片 URL 清單而非結構化的照片物件，
/// 透過 [toEntities] 可將 URL 清單轉換為領域層的 [PhotoEntity] 清單。
class PhotoDownloadResponse {
  /// 建立 [PhotoDownloadResponse] 實例。
  const PhotoDownloadResponse({
    required this.totalImages,
    required this.successfulDownloads,
    required this.failureDownloads,
    required this.imageUrls,
    required this.errors,
    required this.elapsedTime,
  });

  /// 部落格中偵測到的總圖片數量。
  final int totalImages;

  /// 成功取得的圖片數量。
  final int successfulDownloads;

  /// 取得失敗的圖片數量。
  final int failureDownloads;

  /// 成功取得的圖片 URL 清單。
  final List<String> imageUrls;

  /// 取得失敗時的錯誤訊息清單。
  final List<String> errors;

  /// API 處理耗時（秒）。
  final double elapsedTime;

  /// 從 JSON 格式的 [Map] 反序列化為 [PhotoDownloadResponse] 實例。
  factory PhotoDownloadResponse.fromJson(Map<String, dynamic> json) =>
      PhotoDownloadResponse(
        totalImages: json['total_images'] as int,
        successfulDownloads: json['successful_downloads'] as int,
        failureDownloads: json['failure_downloads'] as int,
        imageUrls: List<String>.from(json['image_urls'] as List),
        errors: List<String>.from(json['errors'] as List),
        elapsedTime: (json['elapsed_time'] as num).toDouble(),
      );

  /// 將 [imageUrls] 轉換為 [PhotoEntity] 清單。
  ///
  /// 由於 API 僅回傳 URL，因此：
  /// - `id` 由 URL 的 hash 產生
  /// - `filename` 從 URL 路徑中擷取
  List<PhotoEntity> toEntities() {
    return imageUrls.asMap().entries.map((entry) {
      final url = entry.value;
      final uri = Uri.tryParse(url);
      final filename = uri != null
          ? p.basename(uri.path)
          : 'image_${entry.key}.jpg';

      return PhotoEntity(
        id: '${url.hashCode}',
        url: url,
        filename: filename,
      );
    }).toList();
  }
}
