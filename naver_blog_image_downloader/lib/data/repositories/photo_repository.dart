import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/blog_cache_metadata.dart';
import '../models/dtos/job_status_response.dart';
import '../models/download_batch_result.dart';
import '../models/fetch_result.dart';
import '../models/photo_entity.dart';
import '../services/api_service.dart';
import '../services/file_download_service.dart';
import '../services/gallery_service.dart';
import '../../ui/core/result.dart';
import 'cache_repository.dart';

/// 照片 Repository，負責協調 API 呼叫、快取與相簿儲存操作。
///
/// 作為 Domain 與 Data 層之間的橋梁，將 [ApiService]、[CacheRepository]、
/// [FileDownloadService] 與 [GalleryService] 的操作組合為上層可直接使用的用例。
class PhotoRepository {
  /// 建立 [PhotoRepository]，需注入所有依賴的服務與子 Repository。
  PhotoRepository({
    required ApiService apiService,
    required CacheRepository cacheRepository,
    required FileDownloadService fileDownloadService,
    required GalleryService galleryService,
  }) : _apiService = apiService,
       _cacheRepository = cacheRepository,
       _fileDownloadService = fileDownloadService,
       _galleryService = galleryService;

  final ApiService _apiService;
  final CacheRepository _cacheRepository;
  final FileDownloadService _fileDownloadService;
  final GalleryService _galleryService;

  /// 輪詢間隔。
  static const _pollInterval = Duration(seconds: 3);

  /// 輪詢最大次數（3 秒 × 200 次 = 10 分鐘上限）。
  static const _maxPollAttempts = 200;

  /// 取得指定 Blog URL 的照片列表（非同步任務模式）。
  ///
  /// 流程：
  /// 1. 以 [CacheRepository.blogId] 產生 blogId
  /// 2. 呼叫 [ApiService.submitJob] 提交非同步爬蟲任務
  /// 3. 每 3 秒輪詢 [ApiService.checkJobStatus] 直到完成或失敗
  /// 4. 透過 [PhotoDownloadResponse.toEntities] 將 URL 轉為 [PhotoEntity]
  /// 5. 檢查快取狀態
  /// 6. 回傳 [Result.ok] 包含 [FetchResult]，例外時回傳 [Result.error]
  ///
  /// [onStatusChanged] 可用於通知 UI 目前的任務狀態。
  Future<Result<FetchResult>> fetchPhotos(
    String blogUrl, {
    void Function(JobStatus status)? onStatusChanged,
  }) async {
    try {
      final blogId = _cacheRepository.blogId(blogUrl);

      // 提交非同步任務
      final jobId = await _apiService.submitJob(blogUrl);
      onStatusChanged?.call(JobStatus.processing);

      // 輪詢任務狀態
      for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
        await Future<void>.delayed(_pollInterval);

        final jobStatus = await _apiService.checkJobStatus(jobId);
        onStatusChanged?.call(jobStatus.status);

        switch (jobStatus.status) {
          case JobStatus.processing:
            continue;

          case JobStatus.completed:
            final response = jobStatus.result!;
            final photos = response.toEntities();
            final filenames = photos.map((p) => p.filename).toList();
            final isFullyCached = await _cacheRepository.isBlogFullyCached(
              blogId,
              filenames,
            );

            return Result.ok(
              FetchResult(
                photos: photos,
                blogId: blogId,
                isFullyCached: isFullyCached,
              ),
            );

          case JobStatus.failed:
            final errors = jobStatus.result?.errors ?? [];
            final message = errors.isNotEmpty ? errors.join('; ') : '伺服器處理失敗';
            return Result.error(Exception(message));
        }
      }

      return Result.error(Exception('任務處理逾時，請稍後再試'));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// 從快取讀取照片檔案並逐一儲存至系統相簿，完成後標記 metadata。
  ///
  /// 若快取中找不到某張照片的檔案，則跳過該張照片繼續處理。
  /// 成功回傳 [Result.ok]，任何例外回傳 [Result.error]。
  Future<Result<void>> saveToGalleryFromCache({
    required List<PhotoEntity> photos,
    required String blogId,
  }) async {
    try {
      for (final photo in photos) {
        final file = await _cacheRepository.cachedFile(photo.filename, blogId);
        if (file == null) continue;
        await _galleryService.saveToGallery(file.path);
      }
      await _cacheRepository.markAsSavedToGallery(blogId);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// 將照片列表並行下載至本地快取。
  ///
  /// - 最多 4 條並行下載（信號量模式）
  /// - 已快取的檔案自動跳過
  /// - 單一下載失敗不中斷整批下載
  /// - 完成後更新 [BlogCacheMetadata]
  /// - 回傳 [DownloadBatchResult] 包含成功、失敗、跳過統計
  Future<DownloadBatchResult> downloadAllToCache({
    required List<PhotoEntity> photos,
    required String blogId,
    void Function(int completed, int total)? onProgress,
  }) async {
    // 下載前先清理快取空間
    await _cacheRepository.evictIfNeeded();

    int successCount = 0;
    int skippedCount = 0;
    final failedPhotos = <PhotoEntity>[];
    final errors = <String>[];
    int completed = 0;

    Future<void> downloadOne(PhotoEntity photo) async {
      // 檢查是否已快取
      if (await _cacheRepository.cachedFile(photo.filename, blogId) != null) {
        skippedCount++;
        completed++;
        onProgress?.call(completed, photos.length);
        return;
      }

      try {
        // 產生臨時檔案路徑
        final cacheDir = await _cacheRepository.cacheDirectory(blogId);
        final tempPath = p.join(
          cacheDir.parent.path,
          'tmp_${DateTime.now().microsecondsSinceEpoch}_${photo.filename}',
        );

        // 下載到臨時檔案
        await _fileDownloadService.downloadFile(photo.url, tempPath);
        final tempFile = File(tempPath);
        final tempSize = await tempFile.length();
        debugPrint(
          '[PhotoRepo] 下載完成: ${photo.filename} '
          '(${(tempSize / 1024).toStringAsFixed(1)} KB)',
        );

        // 存入快取
        await _cacheRepository.storeFile(tempFile, photo.filename, blogId);

        // 清理臨時檔案
        if (await tempFile.exists()) {
          await tempFile.delete();
        }

        successCount++;
      } on Exception catch (e) {
        failedPhotos.add(photo);
        errors.add('${photo.filename}: $e');
      }
      completed++;
      onProgress?.call(completed, photos.length);
    }

    // 並行池：最多 4 條並行下載（信號量模式）
    final active = <Future<void>>[];
    for (final photo in photos) {
      if (active.length >= 4) {
        await Future.any(active);
        active.removeWhere((f) => f == Future.value());
      }
      final future = downloadOne(photo);
      active.add(future);
      future.then((_) => active.remove(future));
    }
    await Future.wait(active);

    // 更新 metadata
    await _cacheRepository.updateMetadata(
      BlogCacheMetadata(
        blogId: blogId,
        blogUrl: photos.firstOrNull?.url ?? '',
        photoCount: photos.length,
        downloadedAt: DateTime.now(),
        isSavedToGallery: false,
        filenames: photos.map((p) => p.filename).toList(),
      ),
    );

    return DownloadBatchResult(
      successCount: successCount,
      failedPhotos: failedPhotos,
      skippedCount: skippedCount,
      errors: errors,
    );
  }
}
