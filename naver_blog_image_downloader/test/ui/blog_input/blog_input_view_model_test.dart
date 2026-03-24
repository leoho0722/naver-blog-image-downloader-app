import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naver_blog_image_downloader/data/models/fetch_result.dart';
import 'package:naver_blog_image_downloader/data/models/photo_entity.dart';
import 'package:naver_blog_image_downloader/data/repositories/photo_repository.dart';
import 'package:naver_blog_image_downloader/ui/blog_input/view_model/blog_input_view_model.dart';
import 'package:naver_blog_image_downloader/ui/core/result.dart';

// ignore: unused_import —確保 FetchState 子類別可用於 type check
// FetchState, FetchIdle, FetchLoading, FetchError, FetchSuccess
// 已在 blog_input_view_model.dart 中定義並透過上方 import 匯入。

class MockPhotoRepository extends Mock implements PhotoRepository {}

void main() {
  late MockPhotoRepository mockPhotoRepository;
  late BlogInputViewModel viewModel;

  setUpAll(() {
    registerFallbackValue((dynamic _) {});
  });

  const testBlogUrl = 'https://blog.naver.com/test/12345';

  const testFetchResult = FetchResult(
    photos: [
      PhotoEntity(
        id: 'photo-1',
        url: 'https://example.com/photo1.jpg',
        filename: 'photo1.jpg',
      ),
    ],
    blogId: 'test-blog-id',
    blogUrl: 'https://blog.naver.com/test/12345',
    isFullyCached: false,
  );

  setUp(() {
    mockPhotoRepository = MockPhotoRepository();
    viewModel = BlogInputViewModel(photoRepository: mockPhotoRepository);
  });

  group('URL input state management', () {
    test('初始狀態正確', () {
      expect(viewModel.blogUrl, '');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.fetchResult, isNull);
    });

    test('onUrlChanged 更新 blogUrl 並通知 listeners', () {
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.onUrlChanged(testBlogUrl);

      expect(viewModel.blogUrl, testBlogUrl);
      expect(notifyCount, 1);
    });

    test('onUrlChanged 清除 errorMessage', () {
      // 先產生一個 error
      viewModel.fetchPhotos(); // blogUrl 為空會設定 errorMessage
      expect(viewModel.errorMessage, isNotNull);

      viewModel.onUrlChanged(testBlogUrl);

      expect(viewModel.errorMessage, isNull);
    });
  });

  group('Empty URL validation', () {
    test('blogUrl 為空時設定 errorMessage 且不呼叫 repository', () async {
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.fetchPhotos();

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.errorMessage, '請輸入 Blog 網址');
      expect(viewModel.isLoading, isFalse);
      expect(notifyCount, 1);
      verifyNever(() => mockPhotoRepository.fetchPhotos(any()));
    });
  });

  group('Fetch photos with loading state', () {
    test('成功取得照片', () async {
      viewModel.onUrlChanged(testBlogUrl);

      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.ok(testFetchResult));

      await viewModel.fetchPhotos();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.fetchResult, testFetchResult);
      expect(viewModel.errorMessage, isNull);
    });

    test('fetchPhotos 開始時 isLoading 設為 true', () async {
      viewModel.onUrlChanged(testBlogUrl);

      bool wasLoadingDuringFetch = false;
      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async {
        wasLoadingDuringFetch = viewModel.isLoading;
        return Result.ok(testFetchResult);
      });

      await viewModel.fetchPhotos();

      expect(wasLoadingDuringFetch, isTrue);
      expect(viewModel.isLoading, isFalse);
    });

    test('取得照片失敗時設定 errorMessage', () async {
      viewModel.onUrlChanged(testBlogUrl);

      final exception = Exception('Network error');
      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.error(exception));

      await viewModel.fetchPhotos();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, '發生錯誤，請稍後再試');
      expect(viewModel.fetchResult, isNull);
    });

    test(
      'isLoading 為 true 時不重複呼叫 repository（duplicate fetch prevention）',
      () async {
        viewModel.onUrlChanged(testBlogUrl);

        final completer = Future<Result<FetchResult>>.delayed(
          const Duration(milliseconds: 100),
          () => Result.ok(testFetchResult),
        );

        when(
          () => mockPhotoRepository.fetchPhotos(
            testBlogUrl,
            onStatusChanged: any(named: 'onStatusChanged'),
          ),
        ).thenAnswer((_) => completer);

        // 同時觸發兩次 fetchPhotos
        final future1 = viewModel.fetchPhotos();
        final future2 = viewModel.fetchPhotos(); // 應該立即回傳

        await Future.wait([future1, future2]);

        // repository 只被呼叫一次
        verify(
          () => mockPhotoRepository.fetchPhotos(
            testBlogUrl,
            onStatusChanged: any(named: 'onStatusChanged'),
          ),
        ).called(1);
      },
    );

    test('通知 listeners 在 loading 開始和結束時各一次（加上 URL 變更）', () async {
      final notifications = <bool>[];
      viewModel.addListener(() {
        notifications.add(viewModel.isLoading);
      });

      viewModel.onUrlChanged(testBlogUrl);

      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.ok(testFetchResult));

      await viewModel.fetchPhotos();

      // onUrlChanged: 1 次, fetchPhotos: loading=true 1 次 + 完成 1 次 = 共 3 次
      expect(notifications.length, 3);
      expect(notifications[0], isFalse); // onUrlChanged 時 isLoading 仍為 false
      expect(notifications[1], isTrue); // fetchPhotos 開始 loading
      expect(notifications[2], isFalse); // fetchPhotos 完成
    });
  });

  group('Reset state', () {
    test('reset 清除 fetchResult 和 errorMessage 並通知 listeners', () async {
      // 先取得一個成功結果
      viewModel.onUrlChanged(testBlogUrl);
      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.ok(testFetchResult));
      await viewModel.fetchPhotos();
      expect(viewModel.fetchResult, isNotNull);

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.reset();

      expect(viewModel.fetchResult, isNull);
      expect(viewModel.errorMessage, isNull);
      expect(notifyCount, 1);
    });

    test('reset 後仍可重新 fetchPhotos', () async {
      viewModel.onUrlChanged(testBlogUrl);
      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.ok(testFetchResult));

      await viewModel.fetchPhotos();
      viewModel.reset();
      expect(viewModel.fetchResult, isNull);

      await viewModel.fetchPhotos();
      expect(viewModel.fetchResult, testFetchResult);
      verify(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).called(2);
    });

    test('reset 清除 errorMessage', () async {
      viewModel.onUrlChanged(testBlogUrl);
      final exception = Exception('Some error');
      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.error(exception));

      await viewModel.fetchPhotos();
      expect(viewModel.errorMessage, isNotNull);

      viewModel.reset();
      expect(viewModel.errorMessage, isNull);
    });
  });

  group('FetchState 狀態轉換', () {
    test('初始 fetchState 為 FetchIdle', () {
      expect(viewModel.fetchState, isA<FetchIdle>());
    });

    test('fetchPhotos 執行中 fetchState 轉為 FetchLoading', () async {
      viewModel.onUrlChanged(testBlogUrl);

      FetchState? stateDuringFetch;
      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async {
        stateDuringFetch = viewModel.fetchState;
        return Result.ok(testFetchResult);
      });

      await viewModel.fetchPhotos();

      expect(stateDuringFetch, isA<FetchLoading>());
      final loading = stateDuringFetch! as FetchLoading;
      expect(loading.statusMessage, '正在提交任務...');
    });

    test('fetchPhotos 成功後 fetchState 轉為 FetchSuccess', () async {
      viewModel.onUrlChanged(testBlogUrl);

      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.ok(testFetchResult));

      await viewModel.fetchPhotos();

      expect(viewModel.fetchState, isA<FetchSuccess>());
      final success = viewModel.fetchState as FetchSuccess;
      expect(success.result, testFetchResult);
    });

    test('fetchPhotos 失敗後 fetchState 轉為 FetchError', () async {
      viewModel.onUrlChanged(testBlogUrl);

      final exception = Exception('Network error');
      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.error(exception));

      await viewModel.fetchPhotos();

      expect(viewModel.fetchState, isA<FetchError>());
      final error = viewModel.fetchState as FetchError;
      expect(error.message, '發生錯誤，請稍後再試');
    });

    test('blogUrl 為空時 fetchPhotos 將 fetchState 設為 FetchError', () async {
      // blogUrl 預設為空字串
      await viewModel.fetchPhotos();

      expect(viewModel.fetchState, isA<FetchError>());
      final error = viewModel.fetchState as FetchError;
      expect(error.message, '請輸入 Blog 網址');
    });

    test('onUrlChanged 將 fetchState 重設為 FetchIdle', () async {
      // 先讓 fetchState 進入非 Idle 狀態（FetchError）
      await viewModel.fetchPhotos();
      expect(viewModel.fetchState, isA<FetchError>());

      viewModel.onUrlChanged(testBlogUrl);

      expect(viewModel.fetchState, isA<FetchIdle>());
    });

    test('reset 將 fetchState 重設為 FetchIdle', () async {
      viewModel.onUrlChanged(testBlogUrl);

      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.ok(testFetchResult));

      await viewModel.fetchPhotos();
      expect(viewModel.fetchState, isA<FetchSuccess>());

      viewModel.reset();

      expect(viewModel.fetchState, isA<FetchIdle>());
    });

    test('fetchState 完整轉換流程：Idle → Loading → Success → reset → Idle', () async {
      // 1. 初始為 Idle
      expect(viewModel.fetchState, isA<FetchIdle>());

      viewModel.onUrlChanged(testBlogUrl);

      final states = <FetchState>[];
      viewModel.addListener(() {
        states.add(viewModel.fetchState);
      });

      when(
        () => mockPhotoRepository.fetchPhotos(
          testBlogUrl,
          onStatusChanged: any(named: 'onStatusChanged'),
        ),
      ).thenAnswer((_) async => Result.ok(testFetchResult));

      // 2. 執行 fetch
      await viewModel.fetchPhotos();

      // 3. reset
      viewModel.reset();

      // 驗證轉換順序：Loading → Success → Idle
      expect(states.length, 3);
      expect(states[0], isA<FetchLoading>());
      expect(states[1], isA<FetchSuccess>());
      expect(states[2], isA<FetchIdle>());
    });
  });
}
