import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naver_blog_image_downloader/data/models/photo_entity.dart';
import 'package:naver_blog_image_downloader/data/repositories/cache_repository.dart';
import 'package:naver_blog_image_downloader/data/repositories/photo_repository.dart';
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
  late ProviderContainer container;

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
    container = ProviderContainer(
      overrides: [
        cacheRepositoryProvider.overrideWithValue(mockCacheRepository),
        photoRepositoryProvider.overrideWithValue(mockPhotoRepository),
      ],
    );
    // 維持 auto-dispose provider 存活，避免在 async 操作中被提前釋放
    container.listen(photoDetailViewModelProvider, (_, _) {});
    addTearDown(container.dispose);
  });

  group('initial state', () {
    test('photos 初始為空 list', () {
      final state = container.read(photoDetailViewModelProvider);
      expect(state.photos, isEmpty);
    });

    test('currentIndex 初始為 0', () {
      final state = container.read(photoDetailViewModelProvider);
      expect(state.currentIndex, 0);
    });

    test('totalCount 初始為 0', () {
      final state = container.read(photoDetailViewModelProvider);
      expect(state.totalCount, 0);
    });

    test('photo 初始為 null', () {
      final state = container.read(photoDetailViewModelProvider);
      expect(state.photo, isNull);
    });

    test('cachedFile 初始為 null', () {
      final state = container.read(photoDetailViewModelProvider);
      expect(state.cachedFile, isNull);
    });

    test('saveOperation 初始為 null（idle）', () {
      final state = container.read(photoDetailViewModelProvider);
      expect(state.saveOperation, isNull);
    });

    test('formattedFileSize 初始為 "-"', () {
      final state = container.read(photoDetailViewModelProvider);
      expect(state.formattedFileSize, '-');
    });

    test('formattedDimensions 初始為 "-"', () {
      final state = container.read(photoDetailViewModelProvider);
      expect(state.formattedDimensions, '-');
    });
  });

  group('loadAll', () {
    test('載入後 photos、blogId、currentIndex 正確設定', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);

      final state = container.read(photoDetailViewModelProvider);
      expect(state.photos, testPhotos);
      expect(state.blogId, testBlogId);
      expect(state.currentIndex, 0);
    });

    test('載入後 photo 為 photos[initialIndex]', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 1);

      final state = container.read(photoDetailViewModelProvider);
      expect(state.photo, testPhotos[1]);
      expect(state.currentIndex, 1);
    });

    test('initialIndex 非 0 時正確定位', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 2);

      final state = container.read(photoDetailViewModelProvider);
      expect(state.currentIndex, 2);
      expect(state.photo?.id, '3');
    });

    test('載入會觸發狀態變更', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      int stateChangeCount = 0;
      container.listen(photoDetailViewModelProvider, (prev, next) {
        stateChangeCount++;
      });

      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);

      // 第一次：設定 photos/blogId 後通知；第二次：metadata 載入完成後通知
      expect(stateChangeCount, 2);
    });

    test('重新 loadAll 會清除 metadataCache', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);

      // 第二次 loadAll 應重設所有狀態
      const newPhotos = [
        PhotoEntity(
          id: '4',
          url: 'https://img.naver.com/4.jpg',
          filename: 'photo4.jpg',
        ),
      ];

      await notifier.loadAll(newPhotos, 'newBlog', 0);

      final state = container.read(photoDetailViewModelProvider);
      expect(state.photos, newPhotos);
      expect(state.blogId, 'newBlog');
      expect(state.photo?.id, '4');
    });
  });

  group('setCurrentIndex', () {
    setUp(() {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);
    });

    test('切換後 currentIndex 更新', () async {
      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);

      await notifier.setCurrentIndex(2);

      final state = container.read(photoDetailViewModelProvider);
      expect(state.currentIndex, 2);
      expect(state.photo?.id, '3');
    });

    test('切換後 saveOperation 重設為 null（idle）', () async {
      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);

      // 直接測試 setCurrentIndex 是否重設 saveOperation
      await notifier.setCurrentIndex(1);

      final state = container.read(photoDetailViewModelProvider);
      expect(state.saveOperation, isNull);
    });

    test('切換到已快取索引時不重複呼叫 CacheRepository', () async {
      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);

      // loadAll 已對 index 0 呼叫 cachedFile
      verify(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).called(1);

      // 切換到 index 1
      await notifier.setCurrentIndex(1);
      verify(
        () => mockCacheRepository.cachedFile('photo2.jpg', testBlogId),
      ).called(1);

      // 回到 index 0 — 應從 metadataCache 取值，不再呼叫 CacheRepository
      await notifier.setCurrentIndex(0);
      verifyNever(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      );
    });

    test('切換會觸發狀態變更', () async {
      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);

      int stateChangeCount = 0;
      container.listen(photoDetailViewModelProvider, (prev, next) {
        stateChangeCount++;
      });

      await notifier.setCurrentIndex(1);

      // 1 次立即通知 + 1 次 metadata 載入完成
      expect(stateChangeCount, 2);
    });

    test('索引超出範圍時不執行', () async {
      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);

      await notifier.setCurrentIndex(-1);
      expect(container.read(photoDetailViewModelProvider).currentIndex, 0);

      await notifier.setCurrentIndex(10);
      expect(container.read(photoDetailViewModelProvider).currentIndex, 0);
    });
  });

  group('saveToGallery', () {
    test('無快取檔案時直接返回不執行儲存', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);
      await notifier.saveToGallery();

      final state = container.read(photoDetailViewModelProvider);
      expect(state.saveOperation, isNull);
      verifyNever(() => mockPhotoRepository.saveOneToGallery(any()));
    });

    test('儲存時 saveOperation 流轉：null → saving → saved', () async {
      final tempFile = await _createTempImageFile();
      addTearDown(() => tempFile.parent.deleteSync(recursive: true));

      when(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).thenAnswer((_) async => tempFile);
      when(
        () => mockPhotoRepository.saveOneToGallery(any()),
      ).thenAnswer((_) async {});

      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);

      final stateSnapshots = <PhotoDetailState>[];
      container.listen(photoDetailViewModelProvider, (prev, next) {
        stateSnapshots.add(next);
      });

      await notifier.saveToGallery();

      expect(stateSnapshots.any((s) => s.isSaving), isTrue);
      final state = container.read(photoDetailViewModelProvider);
      expect(state.isSaved, isTrue);
    });

    test('isSaving 為 true 時再次呼叫直接返回', () async {
      final tempFile = await _createTempImageFile();
      addTearDown(() => tempFile.parent.deleteSync(recursive: true));

      when(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).thenAnswer((_) async => tempFile);
      when(() => mockPhotoRepository.saveOneToGallery(any())).thenAnswer((
        _,
      ) async {
        // 在儲存過程中嘗試再次呼叫
        final notifier = container.read(photoDetailViewModelProvider.notifier);
        await notifier.saveToGallery();
      });

      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);
      await notifier.saveToGallery();

      // saveOneToGallery 只被呼叫一次
      verify(() => mockPhotoRepository.saveOneToGallery(any())).called(1);
    });

    test('Repository 拋出例外時 saveOperation 回到 null（idle）', () async {
      final tempFile = await _createTempImageFile();
      addTearDown(() => tempFile.parent.deleteSync(recursive: true));

      when(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).thenAnswer((_) async => tempFile);
      when(
        () => mockPhotoRepository.saveOneToGallery(any()),
      ).thenThrow(Exception('權限未授權'));

      final notifier = container.read(photoDetailViewModelProvider.notifier);
      await notifier.loadAll(testPhotos, testBlogId, 0);
      await notifier.saveToGallery();

      final state = container.read(photoDetailViewModelProvider);
      expect(state.saveOperation, isNull);
    });
  });

  group('formattedFileSize / formattedDimensions', () {
    test('無資料時回傳 "-"', () {
      final state = container.read(photoDetailViewModelProvider);
      expect(state.formattedFileSize, '-');
      expect(state.formattedDimensions, '-');
    });
  });
}
