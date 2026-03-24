import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naver_blog_image_downloader/data/models/photo_entity.dart';
import 'package:naver_blog_image_downloader/data/repositories/cache_repository.dart';
import 'package:naver_blog_image_downloader/data/repositories/photo_repository.dart';
import 'package:naver_blog_image_downloader/ui/core/result.dart';
import 'package:naver_blog_image_downloader/ui/photo_gallery/view_model/photo_gallery_view_model.dart';

class MockPhotoRepository extends Mock implements PhotoRepository {}

class MockCacheRepository extends Mock implements CacheRepository {}

void main() {
  late MockPhotoRepository mockPhotoRepository;
  late MockCacheRepository mockCacheRepository;
  late PhotoGalleryViewModel viewModel;

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
  ];

  setUpAll(() {
    registerFallbackValue(const <PhotoEntity>[]);
  });

  setUp(() {
    mockPhotoRepository = MockPhotoRepository();
    mockCacheRepository = MockCacheRepository();
    viewModel = PhotoGalleryViewModel(
      photoRepository: mockPhotoRepository,
      cacheRepository: mockCacheRepository,
    );
  });

  group('initial state', () {
    test('cachedFiles 初始為空 map', () {
      expect(viewModel.cachedFiles, isEmpty);
    });

    test('photos 初始為空 list', () {
      expect(viewModel.photos, isEmpty);
    });

    test('blogId 初始為空字串', () {
      expect(viewModel.blogId, '');
    });
  });

  group('load photos', () {
    test('load 後 photos 與 blogId 正確設定', () async {
      // 模擬所有快取查詢回傳 null（無快取）
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.load(testPhotos, testBlogId);

      expect(viewModel.photos, testPhotos);
      expect(viewModel.blogId, testBlogId);
    });

    test('load 會通知 listeners', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.load(testPhotos, testBlogId);

      // 第一次：設定 photos/blogId 後通知；第二次：快取解析完成後通知
      expect(notifyCount, 2);
    });
  });

  group('cachedFiles populated after load', () {
    test('部分照片有快取時，cachedFiles 對應正確', () async {
      final mockFile = File('/tmp/test_photo.jpg');

      // photo1 有快取，photo2 無快取
      when(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).thenAnswer((_) async => mockFile);
      when(
        () => mockCacheRepository.cachedFile('photo2.jpg', testBlogId),
      ).thenAnswer((_) async => null);

      await viewModel.load(testPhotos, testBlogId);

      expect(viewModel.cachedFiles.length, 2);
      expect(viewModel.cachedFiles['1'], mockFile);
      expect(viewModel.cachedFiles['2'], isNull);
    });

    test('所有照片皆有快取時，cachedFiles 全部非 null', () async {
      final mockFile1 = File('/tmp/photo1.jpg');
      final mockFile2 = File('/tmp/photo2.jpg');

      when(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).thenAnswer((_) async => mockFile1);
      when(
        () => mockCacheRepository.cachedFile('photo2.jpg', testBlogId),
      ).thenAnswer((_) async => mockFile2);

      await viewModel.load(testPhotos, testBlogId);

      expect(viewModel.cachedFiles['1'], mockFile1);
      expect(viewModel.cachedFiles['2'], mockFile2);
    });

    test('所有照片皆無快取時，cachedFiles 全部為 null', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.load(testPhotos, testBlogId);

      expect(viewModel.cachedFiles['1'], isNull);
      expect(viewModel.cachedFiles['2'], isNull);
    });

    test('重新 load 會清除舊的 cachedFiles', () async {
      final mockFile = File('/tmp/test_photo.jpg');

      // 第一次 load：photo1 有快取
      when(
        () => mockCacheRepository.cachedFile('photo1.jpg', testBlogId),
      ).thenAnswer((_) async => mockFile);
      when(
        () => mockCacheRepository.cachedFile('photo2.jpg', testBlogId),
      ).thenAnswer((_) async => null);

      await viewModel.load(testPhotos, testBlogId);
      expect(viewModel.cachedFiles['1'], mockFile);

      // 第二次 load：使用不同的照片清單
      const newPhotos = [
        PhotoEntity(
          id: '3',
          url: 'https://img.naver.com/3.jpg',
          filename: 'photo3.jpg',
        ),
      ];

      when(
        () => mockCacheRepository.cachedFile('photo3.jpg', 'newBlog'),
      ).thenAnswer((_) async => null);

      await viewModel.load(newPhotos, 'newBlog');

      // 舊的 key 應該不存在，只有新的 key
      expect(viewModel.cachedFiles.containsKey('1'), isFalse);
      expect(viewModel.cachedFiles.containsKey('2'), isFalse);
      expect(viewModel.cachedFiles.containsKey('3'), isTrue);
    });

    test('cachedFile 以 photo.id 作為 key', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.load(testPhotos, testBlogId);

      // 驗證 key 是 photo.id 而非 filename
      expect(viewModel.cachedFiles.containsKey('1'), isTrue);
      expect(viewModel.cachedFiles.containsKey('2'), isTrue);
      expect(viewModel.cachedFiles.containsKey('photo1.jpg'), isFalse);
    });
  });

  group('GalleryMode 狀態管理', () {
    test('初始 mode 為 GalleryMode.browsing', () {
      expect(viewModel.mode, GalleryMode.browsing);
    });

    test('toggleSelectMode 在 browsing 與 selecting 間切換', () {
      viewModel.toggleSelectMode();
      expect(viewModel.mode, GalleryMode.selecting);

      viewModel.toggleSelectMode();
      expect(viewModel.mode, GalleryMode.browsing);
    });

    test('toggleSelectMode 切回 browsing 時清空 selectedIds', () async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.load(testPhotos, testBlogId);

      // 進入選取模式並選取照片
      viewModel.toggleSelectMode();
      viewModel.toggleSelection('1');
      expect(viewModel.selectedIds, {'1'});

      // 切回 browsing 後 selectedIds 被清空
      viewModel.toggleSelectMode();
      expect(viewModel.mode, GalleryMode.browsing);
      expect(viewModel.selectedIds, isEmpty);
    });
  });

  group('saveSelectedToGallery Result 處理', () {
    setUp(() async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.load(testPhotos, testBlogId);

      // 進入選取模式並選取一張照片
      viewModel.toggleSelectMode();
      viewModel.toggleSelection('1');
    });

    test('Result.ok 時 mode 回到 browsing 且 selectedIds 被清空', () async {
      when(
        () => mockPhotoRepository.saveToGalleryFromCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
        ),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.saveSelectedToGallery();

      expect(viewModel.mode, GalleryMode.browsing);
      expect(viewModel.selectedIds, isEmpty);
      expect(viewModel.errorType, isNull);
    });

    test('Result.error 時 mode 回到 browsing 且 errorType 被設定', () async {
      when(
        () => mockPhotoRepository.saveToGalleryFromCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
        ),
      ).thenAnswer((_) async => Result.error(Exception('fail')));

      await viewModel.saveSelectedToGallery();

      expect(viewModel.mode, GalleryMode.browsing);
      expect(viewModel.errorType, GallerySaveErrorType.saveToGalleryFailed);
    });
  });

  group('saveAllToGallery Result 處理', () {
    setUp(() async {
      when(
        () => mockCacheRepository.cachedFile(any(), any()),
      ).thenAnswer((_) async => null);

      await viewModel.load(testPhotos, testBlogId);
    });

    test('Result.ok 時 mode 回到 browsing', () async {
      when(
        () => mockPhotoRepository.saveToGalleryFromCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
        ),
      ).thenAnswer((_) async => Result.ok(null));

      await viewModel.saveAllToGallery();

      expect(viewModel.mode, GalleryMode.browsing);
      expect(viewModel.errorType, isNull);
    });

    test('Result.error 時 mode 回到 browsing 且 errorType 被設定', () async {
      when(
        () => mockPhotoRepository.saveToGalleryFromCache(
          photos: any(named: 'photos'),
          blogId: any(named: 'blogId'),
        ),
      ).thenAnswer((_) async => Result.error(Exception('fail')));

      await viewModel.saveAllToGallery();

      expect(viewModel.mode, GalleryMode.browsing);
      expect(viewModel.errorType, GallerySaveErrorType.saveToGalleryFailed);
    });
  });
}
