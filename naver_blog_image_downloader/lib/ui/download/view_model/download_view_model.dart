import 'package:flutter/foundation.dart';

import '../../../data/models/download_batch_result.dart';
import '../../../data/models/photo_entity.dart';
import '../../../data/repositories/photo_repository.dart';

export '../../../data/models/download_batch_result.dart';

/// 下載頁面的 ViewModel，負責管理批次照片下載進度與結果。
class DownloadViewModel extends ChangeNotifier {
  /// 建立 [DownloadViewModel]，需注入 [PhotoRepository] 以執行下載操作。
  DownloadViewModel({required PhotoRepository photoRepository})
    : _photoRepository = photoRepository;

  /// 注入的照片 Repository，用於執行實際的下載與儲存操作。
  final PhotoRepository _photoRepository;

  /// 已完成下載的照片數量（含成功、失敗與跳過）。
  int _completed = 0;

  /// 本次批次需下載的照片總數。
  int _total = 0;

  /// 是否正在執行批次下載。
  bool _isDownloading = false;

  /// 批次下載的結果摘要，下載完成後才有值。
  DownloadBatchResult? _result;

  /// 已完成下載的照片數量。
  int get completed => _completed;

  /// 需下載的照片總數。
  int get total => _total;

  /// 是否正在下載中。
  bool get isDownloading => _isDownloading;

  /// 批次下載結果，下載完成後可檢查失敗項目。
  DownloadBatchResult? get result => _result;

  /// 下載進度比例（0.0 ~ 1.0），用於進度條顯示。
  double get progress => _total > 0 ? _completed / _total : 0.0;

  /// 開始批次下載指定的照片至本機快取。
  ///
  /// [photos] 為要下載的照片清單，[blogId] 用於建立快取目錄結構，
  /// [blogUrl] 為原始 Blog 網址，用於記錄快取 metadata。
  Future<void> startDownload({
    required List<PhotoEntity> photos,
    required String blogId,
    required String blogUrl,
  }) async {
    if (_isDownloading) return;

    _isDownloading = true;
    _completed = 0;
    _total = photos.length;
    _result = null;
    notifyListeners();

    debugPrint('[DownloadVM] 開始下載 ${photos.length} 張照片 (blogId: $blogId)');
    for (final photo in photos) {
      debugPrint('[DownloadVM]   - ${photo.filename}: ${photo.url}');
    }

    _result = await _photoRepository.downloadAllToCache(
      photos: photos,
      blogId: blogId,
      blogUrl: blogUrl,
      onProgress: (completed, total) {
        _completed = completed;
        _total = total;
        debugPrint('[DownloadVM] 進度: $completed/$total');
        notifyListeners();
      },
    );

    debugPrint(
      '[DownloadVM] 下載完成 — 成功: ${_result!.successCount}, '
      '失敗: ${_result!.failureCount}, 跳過: ${_result!.skippedCount}',
    );

    _isDownloading = false;
    notifyListeners();
  }
}
