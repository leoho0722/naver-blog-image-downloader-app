import 'photo_entity.dart';

/// 從部落格擷取照片清單的結果。
///
/// 封裝一次擷取操作所取得的 [PhotoEntity] 清單，
/// 並記錄該結果是否完全來自快取。
class FetchResult {
  /// 建立 [FetchResult] 實例。
  const FetchResult({
    required this.photos,
    required this.blogId,
    required this.isFullyCached,
  });

  /// 擷取到的照片實體清單。
  final List<PhotoEntity> photos;

  /// 部落格的唯一識別碼。
  final String blogId;

  /// 此次結果是否完全來自本地快取，而非從遠端重新擷取。
  final bool isFullyCached;
}
