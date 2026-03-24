import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naver_blog_image_downloader/data/models/photo_entity.dart';
import 'package:naver_blog_image_downloader/data/repositories/cache_repository.dart';
import 'package:naver_blog_image_downloader/data/repositories/photo_repository.dart';
import 'package:naver_blog_image_downloader/ui/core/app_error.dart';
import 'package:naver_blog_image_downloader/ui/core/result.dart';
import 'package:naver_blog_image_downloader/ui/photo_detail/view_model/photo_detail_view_model.dart';

class MockCacheRepository extends Mock implements CacheRepository {}

class MockPhotoRepository extends Mock implements PhotoRepository {}

/// 建立包含有效 PNG 資料的暫存檔案。
Future<File> _createTempImageFile() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 10, 10),
    Paint()..color = const Color(0xFFFF0000),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(10, 10);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  final dir = Directory.systemTemp.createTempSync('photo_detail_test_');
  final file = File('${dir.path}/test_photo.png');
  await file.writeAsBytes(byteData!.buffer.asUint8List());
  return file;
}

void main() {
  late MockCacheRepository mockCacheRepository;
  late MockPhotoRepository mockPhotoRepository;
  late PhotoDetailViewModel viewModel;

  const testBlogId = 'blog123';
  const testPhotos = [
    PhotoEntity(
      id: '1',
      url: 'https://img.naver.com/1.jpg',
      filename: 'photo1.jpg',
    ),
    PhotoEntity(
      id: '2',
      url: 'https://img.naver.com/2.jpg',
      filename: 'photo2.jpg',
    ),
    PhotoEntity(
      id: '3',
      url: 'https://img.naver.com/3.jpg',
      filename: 'photo3.jpg',
    ),
  ];

  setUp(() {
    mockCacheRepository = MockCacheRepository();
    mockPhotoRepository = MockPhotoRepository();
    viewModel = PhotoDetailViewModel(
      cacheRepository: mockCacheRepository,
      photoRepository: mockPhotoRepository,
    );
  });

  group('initial state', () {
    test('photos 初始為空 list', () {
      expect(viewModel.photos, isEmpty);
    });

    test('currentIndex 初始為 0', () {
      expect(viewModel.currentIndex, 0);
    });

    test('totalCount 初始為 0', () {
      expect(viewModel.totalCount, 0);
    });

    test('photo 初始為 null', () {
      expect(viewModel.photo, isNull);
    });

    test('cachedFile 初始為 null', () {
      expect(viewModel.cachedFile, isNull);
    });

    test('saveState 初始為 SaveState.idle', () {
      expect(viewModel.saveState, SaveState.idle);
    });

    test('formattedFileSize 初始為 "-"', () {
      expect(viewModel.formattedFileSize, '-');
    });

    test('formattedDimensions 初始為 "-"', () {
      expect(viewModel.formattedDimensions, '-');
    });
  });

  group('loadAll', () {
    test('載入後 photos、blogId、currentIndex 正確設定', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.loadAll(testPhotos, testBlogId, 0);

      expect(viewModel.photos, testPhotos);
      expect(viewModel.blogId, testBlogId);
      expect(viewModel.currentIndex, 0);
    });

    test('載入後 photo 為 photos[initialIndex]', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.loadAll(testPhotos, testBlogId, 1);

      expect(viewModel.photo, testPhotos[1]);
      expect(viewModel.currentIndex, 1);
    });

    test('initialIndex 非 0 時正確定位', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.loadAll(testPhotos, testBlogId, 2);

      expect(viewModel.currentIndex, 2);
      expect(viewModel.photo?.id, '3');
    });

    test('載入會通知 listeners', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.loadAll(testPhotos, testBlogId, 0);

      // 第一次：設定 photos/blogId 後通知；第二次：metadata 載入完成後通知
      expect(notifyCount, 2);
    });

    test('重新 loadAll 會清除 metadataCache', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.loadAll(testPhotos, testBlogId, 0);

      // 第二次 loadAll 應重設所有狀態
      const newPhotos = [
        PhotoEntity(
          id: '4',
          url: 'https://img.naver.com/4.jpg',
          filename: 'photo4.jpg',
        ),
      ];

      await viewModel.loadAll(newPhotos, 'newBlog', 0);

      expect(viewModel.photos, newPhotos);
      expect(viewModel.blogId, 'newBlog');
      expect(viewModel.photo?.id, '4');
    });
  });

  group('setCurrentIndex', () {
    setUp(() {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);
    });

    test('切換後 currentIndex 更新', () async {
      await viewModel.loadAll(testPhotos, testBlogId, 0);

      await viewModel.setCurrentIndex(2);

      expect(viewModel.currentIndex, 2);
      expect(viewModel.photo?.id, '3');
    });

    test('切換後 saveState 重設為 SaveState.idle', () async {
      await viewModel.loadAll(testPhotos, testBlogId, 0);

      // 直接測試 setCurrentIndex 是否重設 saveState
      await viewModel.setCurrentIndex(1);

      expect(viewModel.saveState, SaveState.idle);
    });

    test('切換到已快取索引時不重複呼叫 CacheRepository', () async {
      await viewModel.loadAll(testPhotos, testBlogId, 0);

      // loadAll 已對 index 0 呼叫 cachedFile
      verify(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).called(1);

      // 切換到 index 1
      await viewModel.setCurrentIndex(1);
      verify(
        () => mockCacheRepository.cachedFile('photo2.jpg', testBlogId),
      ).called(1);

      // 回到 index 0 — 應從 metadataCache 取值，不再呼叫 CacheRepository
      await viewModel.setCurrentIndex(0);
      verifyNever(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      );
    });

    test('切換會通知 listeners', () async {
      await viewModel.loadAll(testPhotos, testBlogId, 0);

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.setCurrentIndex(1);

      // 1 次立即通知 + 1 次 metadata 載入完成
      expect(notifyCount, 2);
    });

    test('索引超出範圍時不執行', () async {
      await viewModel.loadAll(testPhotos, testBlogId, 0);

      await viewModel.setCurrentIndex(-1);
      expect(viewModel.currentIndex, 0);

      await viewModel.setCurrentIndex(10);
      expect(viewModel.currentIndex, 0);
    });
  });

  group('saveToGallery', () {
    test('無快取檔案時直接返回不執行儲存', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.loadAll(testPhotos, testBlogId, 0);
      await viewModel.saveToGallery();

      expect(viewModel.saveState, SaveState.idle);
      verifyNever(() => mockPhotoRepository.saveOneToGallery(any()));
    });

    test('儲存時 saveState 流轉：idle → saving → saved', () async {
      final tempFile = await _createTempImageFile();
      addTearDown(() => tempFile.parent.deleteSync(recursive: true));

      when(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).thenAnswer((_) async => tempFile);
      when(
        () => mockPhotoRepository.saveOneToGallery(any()),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.loadAll(testPhotos, testBlogId, 0);

      final stateSnapshots = <SaveState>[];
      viewModel.addListener(() {
        stateSnapshots.add(viewModel.saveState);
      });

      await viewModel.saveToGallery();

      expect(stateSnapshots, contains(SaveState.saving));
      expect(viewModel.saveState, SaveState.saved);
    });

    test('saveState 為 saving 時再次呼叫直接返回', () async {
      final tempFile = await _createTempImageFile();
      addTearDown(() => tempFile.parent.deleteSync(recursive: true));

      when(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).thenAnswer((_) async => tempFile);
      when(() => mockPhotoRepository.saveOneToGallery(any())).thenAnswer((
        _,
      ) async {
        // 在儲存過程中嘗試再次呼叫
        await viewModel.saveToGallery();
        return Result.ok(null);
      });

      await viewModel.loadAll(testPhotos, testBlogId, 0);
      await viewModel.saveToGallery();

      // saveOneToGallery 只被呼叫一次
      verify(() => mockPhotoRepository.saveOneToGallery(any())).called(1);
    });

    test('Repository 回傳 Error 時 saveState 回到 idle', () async {
      final tempFile = await _createTempImageFile();
      addTearDown(() => tempFile.parent.deleteSync(recursive: true));

      when(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).thenAnswer((_) async => tempFile);
      when(() => mockPhotoRepository.saveOneToGallery(any())).thenAnswer(
        (_) async => Result.error(
          const AppError(type: AppErrorType.gallery, message: '權限未授權'),
        ),
      );

      await viewModel.loadAll(testPhotos, testBlogId, 0);
      await viewModel.saveToGallery();

      expect(viewModel.saveState, SaveState.idle);
    });
  });

  group('formattedFileSize / formattedDimensions', () {
    test('無資料時回傳 "-"', () {
      expect(viewModel.formattedFileSize, '-');
      expect(viewModel.formattedDimensions, '-');
    });
  });
}
