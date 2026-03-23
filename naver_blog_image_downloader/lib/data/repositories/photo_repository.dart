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
import '../../ui/core/app_error.dart';
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

  /// API 通訊服務，負責提交爬蟲任務與查詢狀態。
  final ApiService _apiService;

  /// 快取 Repository，負責本機檔案快取與 metadata 管理。
  final CacheRepository _cacheRepository;

  /// 檔案下載服務，負責從遠端 URL 下載圖片至本機。
  final FileDownloadService _fileDownloadService;

  /// 系統相簿存取服務，負責將照片儲存至使用者相簿。
  final GalleryService _galleryService;

  /// 每次輪詢任務狀態的等待間隔（3 秒）。
  static const _pollInterval = Duration(seconds: 3);

  /// 輪詢最大次數（3 秒 × 200 次 = 最多等待 10 分鐘）。
  static const _maxPollAttempts = 200;

  /// 單批並行下載的最大併發數量。
  static const _maxConcurrency = 4;

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

      // 快取優先：若 metadata 存在且所有檔案完整快取，直接回傳
      final metadata = await _cacheRepository.metadata(blogId);
      if (metadata != null) {
        final isFullyCached = await _cacheRepository.isBlogFullyCached(
          blogId,
          metadata.filenames,
        );
        if (isFullyCached) {
          final photos = metadata.filenames
              .asMap()
              .entries
              .map(
                (e) => PhotoEntity(
                  id: 'photo_${e.key}',
                  url: '',
                  filename: e.value,
                ),
              )
              .toList();
          return Result.ok(
            FetchResult(
              photos: photos,
              blogId: blogId,
              blogUrl: blogUrl,
              isFullyCached: true,
            ),
          );
        }
      }

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
                blogUrl: blogUrl,
                isFullyCached: isFullyCached,
                totalImages: response.totalImages,
                failureDownloads: response.failureDownloads,
                fetchErrors: response.errors,
              ),
            );

          case JobStatus.failed:
            final errors = jobStatus.result?.errors ?? [];
            final message = errors.isNotEmpty ? errors.join('; ') : '伺服器處理失敗';
            return Result.error(
              AppError(type: AppErrorType.serverError, message: message),
            );
        }
      }

      return Result.error(
        const AppError(type: AppErrorType.timeout, message: '任務處理逾時，請稍後再試'),
      );
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
        await _galleryService.saveToGallery(
          file.path,
          totalCount: photos.length,
        );
      }
      await _cacheRepository.markAsSavedToGallery(blogId);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// 將照片列表並行下載至本地快取。
  ///
  /// - 最多 _maxConcurrency 條並行下載（分批 Future.wait）
  /// - 已快取的檔案自動跳過
  /// - 單一下載失敗不中斷整批下載
  /// - 完成後更新 [BlogCacheMetadata]
  /// - 回傳 [DownloadBatchResult] 包含成功、失敗、跳過統計
  Future<DownloadBatchResult> downloadAllToCache({
    required List<PhotoEntity> photos,
    required String blogId,
    required String blogUrl,
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

    // 分批並行下載：每批最多 _maxConcurrency 張，一批完成再下一批
    for (var i = 0; i < photos.length; i += _maxConcurrency) {
      final end = (i + _maxConcurrency < photos.length)
          ? i + _maxConcurrency
          : photos.length;
      await Future.wait(photos.sublist(i, end).map(downloadOne));
    }

    // 更新 metadata
    await _cacheRepository.updateMetadata(
      BlogCacheMetadata(
        blogId: blogId,
        blogUrl: blogUrl,
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
