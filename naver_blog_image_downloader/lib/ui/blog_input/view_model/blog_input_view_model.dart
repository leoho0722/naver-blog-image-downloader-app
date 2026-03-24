import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/dtos/job_status_response.dart';
import '../../../data/models/fetch_result.dart';
import '../../../data/repositories/photo_repository.dart';
import '../../../data/services/api_service.dart' show ApiServiceException;
import '../../core/app_error.dart';
import '../../core/result.dart';

/// 照片擷取操作的狀態，以 sealed class 表達互斥狀態。
sealed class FetchState {
  /// 建立 [FetchState]。
  const FetchState();
}

/// 閒置狀態，尚未執行擷取。
final class FetchIdle extends FetchState {
  /// 建立 [FetchIdle]。
  const FetchIdle();
}

/// 擷取中狀態，攜帶目前的處理狀態訊息。
final class FetchLoading extends FetchState {
  /// 建立 [FetchLoading]。
  const FetchLoading({required this.statusMessage});

  /// 目前的處理狀態訊息（如「伺服器處理中...」）。
  final String statusMessage;
}

/// 擷取失敗狀態，攜帶使用者可讀的錯誤訊息。
final class FetchError extends FetchState {
  /// 建立 [FetchError]。
  const FetchError({required this.message});

  /// 使用者可讀的錯誤訊息。
  final String message;
}

/// 擷取成功狀態，攜帶照片擷取結果。
final class FetchSuccess extends FetchState {
  /// 建立 [FetchSuccess]。
  const FetchSuccess({required this.result});

  /// 照片擷取結果。
  final FetchResult result;
}

/// Blog 網址輸入頁面的 ViewModel，負責管理使用者輸入的網址並發起照片擷取請求。
class BlogInputViewModel extends ChangeNotifier {
  /// 建立 [BlogInputViewModel]，需注入 [PhotoRepository] 以執行照片擷取。
  BlogInputViewModel({required PhotoRepository photoRepository})
    : _photoRepository = photoRepository;

  final PhotoRepository _photoRepository;

  /// 使用者輸入的 Blog 網址原始值。
  String _blogUrl = '';

  /// 擷取操作的狀態，以 sealed class 管理互斥狀態。
  FetchState _fetchState = const FetchIdle();

  /// 使用者輸入的 Blog 網址。
  String get blogUrl => _blogUrl;

  /// 目前的擷取狀態。
  FetchState get fetchState => _fetchState;

  /// 是否正在擷取照片（含提交任務 + 輪詢中）。
  bool get isLoading => _fetchState is FetchLoading;

  /// 錯誤訊息，無錯誤時為 null。
  String? get errorMessage =>
      _fetchState is FetchError ? (_fetchState as FetchError).message : null;

  /// 目前的處理狀態訊息（如「伺服器處理中...」），無狀態時為 null。
  String? get statusMessage => _fetchState is FetchLoading
      ? (_fetchState as FetchLoading).statusMessage
      : null;

  /// 照片擷取結果，尚未擷取時為 null。
  FetchResult? get fetchResult =>
      _fetchState is FetchSuccess ? (_fetchState as FetchSuccess).result : null;

  /// 當使用者修改網址時呼叫，同時將狀態重設為 [FetchIdle]。
  void onUrlChanged(String url) {
    _blogUrl = url;
    _fetchState = const FetchIdle();
    notifyListeners();
  }

  /// 根據目前的 [blogUrl] 發起照片擷取請求（非同步任務模式）。
  ///
  /// 若網址為空會設定錯誤訊息；若已在載入中則不重複發送。
  /// 任務提交後會自動輪詢狀態，並透過 [statusMessage] 通知 UI。
  Future<void> fetchPhotos() async {
    if (_blogUrl.isEmpty) {
      _fetchState = const FetchError(message: '請輸入 Blog 網址');
      notifyListeners();
      return;
    }

    if (_fetchState is FetchLoading) return;

    _fetchState = const FetchLoading(statusMessage: '正在提交任務...');
    notifyListeners();

    final result = await _photoRepository.fetchPhotos(
      _blogUrl,
      onStatusChanged: (status) {
        _fetchState = FetchLoading(
          statusMessage: switch (status) {
            JobStatus.processing => '伺服器處理中...',
            JobStatus.completed => '處理完成',
            JobStatus.failed => '',
          },
        );
        notifyListeners();
      },
    );

    switch (result) {
      case Ok<FetchResult>(:final value):
        _fetchState = FetchSuccess(result: value);
      case Error<FetchResult>(:final error):
        _fetchState = FetchError(message: _humanReadableError(error));
    }
    notifyListeners();
  }

  /// 將例外轉為使用者可讀的錯誤訊息。
  String _humanReadableError(Exception error) {
    if (error is TimeoutException) {
      return '請求逾時，請稍後再試';
    }
    if (error is ApiServiceException) {
      if (error.isRetryable) {
        return '伺服器暫時無法使用（${error.statusCode}），請稍後再試';
      }
      return 'API 呼叫失敗，請稍後再試';
    }
    if (error is AppError) {
      return switch (error.type) {
        AppErrorType.serverError => '伺服器處理失敗，請稍後再試',
        AppErrorType.network => '網路連線異常，請檢查網路設定',
        AppErrorType.timeout => '請求逾時，請稍後再試',
        _ => '發生錯誤，請稍後再試',
      };
    }
    return '發生錯誤，請稍後再試';
  }

  /// 重設擷取結果與錯誤訊息，回到初始狀態。
  void reset() {
    _fetchState = const FetchIdle();
    notifyListeners();
  }
}
