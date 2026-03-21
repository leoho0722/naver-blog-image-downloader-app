import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naver_blog_image_downloader/data/models/photo_entity.dart';
import 'package:naver_blog_image_downloader/data/repositories/photo_repository.dart';
import 'package:naver_blog_image_downloader/ui/download/view_model/download_view_model.dart';

class MockPhotoRepository extends Mock implements PhotoRepository {}

void main() {
  late MockPhotoRepository mockPhotoRepository;
  late DownloadViewModel viewModel;

  const testBlogId = 'test_blog_id';

  final testPhotos = [
    const PhotoEntity(
      id: 'p1',
      url: 'https://example.com/p1.jpg',
      filename: 'p1.jpg',
    ),
    const PhotoEntity(
      id: 'p2',
      url: 'https://example.com/p2.jpg',
      filename: 'p2.jpg',
    ),
    const PhotoEntity(
      id: 'p3',
      url: 'https://example.com/p3.jpg',
      filename: 'p3.jpg',
    ),
  ];

  final successResult = DownloadBatchResult(
    successCount: 3,
    failedPhotos: const [],
  );

  setUp(() {
    mockPhotoRepository = MockPhotoRepository();
    viewModel = DownloadViewModel(photoRepository: mockPhotoRepository);
  });

  group('Download state properties - 初始狀態', () {
    test('completed 初始值為 0', () {
      expect(viewModel.completed, 0);
    });

    test('total 初始值為 0', () {
      expect(viewModel.total, 0);
    });

    test('isDownloading 初始值為 false', () {
      expect(viewModel.isDownloading, isFalse);
    });

    test('result 初始值為 null', () {
      expect(viewModel.result, isNull);
    });

    test('progress 初始值為 0.0', () {
      expect(viewModel.progress, 0.0);
    });
  });

  group('Progress calculation', () {
    test('total 為 0 時 progress 回傳 0.0（避免除以零）', () {
      // 初始狀態 total = 0
      expect(viewModel.progress, 0.0);
    });

    test('total 大於 0 時 progress 回傳 completed / total', () async {
      // Arrange — 讓 downloadAllToCache 透過 onProgress 設定 completed/total
      double capturedProgress = 0.0;

      when(
        () => mockPhotoRepository.downloadAllToCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((invocation) async {
        final onProgress =
            invocation.namedArguments[#onProgress] as void Function(int, int)?;
        onProgress?.call(1, 3);
        capturedProgress = viewModel.progress;
        onProgress?.call(2, 3);
        onProgress?.call(3, 3);
        return successResult;
      });

      // Act
      await viewModel.startDownload(photos: testPhotos, blogId: testBlogId);

      // Assert — 在 1/3 時 progress 應約為 0.333
      expect(capturedProgress, closeTo(1 / 3, 0.001));
      // 完成後 progress 為 1.0
      expect(viewModel.progress, closeTo(1.0, 0.001));
    });
  });

  group('Start download with progress tracking', () {
    test('成功批次下載：狀態依序正確更新', () async {
      // Arrange
      final stateSnapshots = <Map<String, dynamic>>[];

      when(
        () => mockPhotoRepository.downloadAllToCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((invocation) async {
        final onProgress =
            invocation.namedArguments[#onProgress] as void Function(int, int)?;

        for (int i = 1; i <= testPhotos.length; i++) {
          onProgress?.call(i, testPhotos.length);
        }

        return successResult;
      });

      viewModel.addListener(() {
        stateSnapshots.add({
          'isDownloading': viewModel.isDownloading,
          'completed': viewModel.completed,
          'total': viewModel.total,
          'result': viewModel.result,
        });
      });

      // Act
      await viewModel.startDownload(photos: testPhotos, blogId: testBlogId);

      // Assert
      // 第一次通知：isDownloading = true, total = 3, completed = 0, result = null
      expect(stateSnapshots[0]['isDownloading'], isTrue);
      expect(stateSnapshots[0]['completed'], 0);
      expect(stateSnapshots[0]['total'], 3);
      expect(stateSnapshots[0]['result'], isNull);

      // 中間通知：progress 更新
      expect(stateSnapshots[1]['completed'], 1);
      expect(stateSnapshots[2]['completed'], 2);
      expect(stateSnapshots[3]['completed'], 3);

      // 最後通知：isDownloading = false, result 有值
      final lastSnapshot = stateSnapshots.last;
      expect(lastSnapshot['isDownloading'], isFalse);
      expect(lastSnapshot['result'], isNotNull);
      expect((lastSnapshot['result'] as DownloadBatchResult).successCount, 3);

      verify(
        () => mockPhotoRepository.downloadAllToCache(
          photos: testPhotos,
          blogId: testBlogId,
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1);
    });

    test('下載前 isDownloading 設為 true、result 清為 null', () async {
      // Arrange
      bool isDownloadingBeforeCall = false;

      when(
        () => mockPhotoRepository.downloadAllToCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async {
        isDownloadingBeforeCall = viewModel.isDownloading;
        return successResult;
      });

      // Act
      await viewModel.startDownload(photos: testPhotos, blogId: testBlogId);

      // Assert
      expect(isDownloadingBeforeCall, isTrue);
      expect(viewModel.isDownloading, isFalse);
    });

    test('下載完成後 result 持有 DownloadBatchResult', () async {
      // Arrange
      final expectedResult = DownloadBatchResult(
        successCount: 2,
        failedPhotos: [testPhotos[2]],
        errors: ['p3.jpg: Exception: fail'],
      );

      when(
        () => mockPhotoRepository.downloadAllToCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => expectedResult);

      // Act
      await viewModel.startDownload(photos: testPhotos, blogId: testBlogId);

      // Assert
      expect(viewModel.result, equals(expectedResult));
      expect(viewModel.result!.successCount, 2);
      expect(viewModel.result!.failureCount, 1);
    });

    test('duplicate download prevention：下載中再次呼叫 startDownload 時直接返回', () async {
      // Arrange
      final completer = Completer<DownloadBatchResult>();

      when(
        () => mockPhotoRepository.downloadAllToCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) => completer.future);

      // Act — 啟動第一次下載（不完成）
      final firstCall = viewModel.startDownload(
        photos: testPhotos,
        blogId: testBlogId,
      );

      // 下載中嘗試第二次呼叫
      await viewModel.startDownload(photos: testPhotos, blogId: testBlogId);

      // 完成第一次下載
      completer.complete(successResult);
      await firstCall;

      // Assert — downloadAllToCache 只被呼叫一次
      verify(
        () => mockPhotoRepository.downloadAllToCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1);
    });

    test('total 設為照片清單長度', () async {
      // Arrange
      when(
        () => mockPhotoRepository.downloadAllToCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => successResult);

      int? capturedTotal;
      viewModel.addListener(() {
        if (capturedTotal == null && viewModel.isDownloading) {
          capturedTotal = viewModel.total;
        }
      });

      // Act
      await viewModel.startDownload(photos: testPhotos, blogId: testBlogId);

      // Assert
      expect(capturedTotal, 3);
    });

    test('每次 progress 更新都呼叫 notifyListeners', () async {
      // Arrange
      int notifyCount = 0;

      when(
        () => mockPhotoRepository.downloadAllToCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((invocation) async {
        final onProgress =
            invocation.namedArguments[#onProgress] as void Function(int, int)?;
        onProgress?.call(1, 3);
        onProgress?.call(2, 3);
        onProgress?.call(3, 3);
        return successResult;
      });

      viewModel.addListener(() {
        notifyCount++;
      });

      // Act
      await viewModel.startDownload(photos: testPhotos, blogId: testBlogId);

      // Assert
      // 1 (start) + 3 (progress) + 1 (done) = 5
      expect(notifyCount, 5);
    });
  });
}
