import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/dtos/job_status_response.dart';
import '../../../data/models/fetch_result.dart';
import '../../../data/repositories/photo_repository.dart';
import '../../../data/services/api_service.dart' show ApiServiceException;
import '../../core/app_error.dart';
import '../../core/result.dart';

/// 擷取載入階段的列舉。
enum FetchLoadingPhase {
  /// 正在提交任務。
  submitting,

  /// 伺服器處理中。
  processing,

  /// 處理完成。
  completed,
}

/// 擷取錯誤類型的列舉。
enum FetchErrorType {
  /// 使用者未輸入網址。
  emptyUrl,

  /// 請求逾時。
  timeout,

  /// 伺服器暫時無法使用（可重試）。
  serverUnavailable,

  /// API 呼叫失敗（不可重試）。
  apiFailed,

  /// 伺服器處理失敗。
  serverError,

  /// 網路連線異常。
  networkError,

  /// 未知錯誤。
  unknown,
}

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

/// 擷取中狀態，攜帶目前的處理階段。
final class FetchLoading extends FetchState {
  /// 建立 [FetchLoading]。
  const FetchLoading({required this.phase});

  /// 目前的處理階段。
  final FetchLoadingPhase phase;
}

/// 擷取失敗狀態，攜帶錯誤類型。
final class FetchError extends FetchState {
  /// 建立 [FetchError]。
  const FetchError({required this.errorType, this.statusCode});

  /// 錯誤類型。
  final FetchErrorType errorType;

  /// HTTP 狀態碼（僅 [FetchErrorType.serverUnavailable] 時有值）。
  final int? statusCode;
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

  /// 照片擷取結果，尚未擷取時為 null。
  FetchResult? get fetchResult =>
      _fetchState is FetchSuccess ? (_fetchState as FetchSuccess).result : null;

  /// 當使用者修改網址時呼叫，同時將狀態重設為 [FetchIdle]。
  ///
  /// [url] 為使用者目前輸入的 Blog 網址。
  void onUrlChanged(String url) {
    _blogUrl = url;
    _fetchState = const FetchIdle();
    notifyListeners();
  }

  /// 根據目前的 [blogUrl] 發起照片擷取請求（非同步任務模式）。
  ///
  /// 若網址為空會設定錯誤類型；若已在載入中則不重複發送。
  /// 任務提交後會自動輪詢狀態，並透過 [FetchLoadingPhase] 通知 UI。
  Future<void> fetchPhotos() async {
    if (_blogUrl.isEmpty) {
      _fetchState = const FetchError(errorType: FetchErrorType.emptyUrl);
      notifyListeners();
      return;
    }

    if (_fetchState is FetchLoading) return;

    _fetchState = const FetchLoading(phase: FetchLoadingPhase.submitting);
    notifyListeners();

    final result = await _photoRepository.fetchPhotos(
      _blogUrl,
      onStatusChanged: (status) {
        _fetchState = FetchLoading(
          phase: switch (status) {
            JobStatus.processing => FetchLoadingPhase.processing,
            JobStatus.completed => FetchLoadingPhase.completed,
            JobStatus.failed => FetchLoadingPhase.completed,
          },
        );
        notifyListeners();
      },
    );

    switch (result) {
      case Ok<FetchResult>(:final value):
        _fetchState = FetchSuccess(result: value);
      case Error<FetchResult>(:final error):
        _fetchState = _mapError(error);
    }
    notifyListeners();
  }

  /// 將例外映射為對應的 [FetchError] 狀態。
  ///
  /// [error] 為 Repository 回傳的例外物件，會依照類型對應至 [FetchErrorType]。
  /// 回傳包含錯誤類型（與可選狀態碼）的 [FetchError]。
  FetchError _mapError(Exception error) {
    if (error is TimeoutException) {
      return const FetchError(errorType: FetchErrorType.timeout);
    }
    if (error is ApiServiceException) {
      if (error.isRetryable) {
        return FetchError(
          errorType: FetchErrorType.serverUnavailable,
          statusCode: error.statusCode,
        );
      }
      return const FetchError(errorType: FetchErrorType.apiFailed);
    }
    if (error is AppError) {
      return FetchError(
        errorType: switch (error.type) {
          AppErrorType.serverError => FetchErrorType.serverError,
          AppErrorType.network => FetchErrorType.networkError,
          AppErrorType.timeout => FetchErrorType.timeout,
          _ => FetchErrorType.unknown,
        },
      );
    }
    return const FetchError(errorType: FetchErrorType.unknown);
  }

  /// 重設擷取結果與錯誤訊息，回到初始狀態。
  void reset() {
    _fetchState = const FetchIdle();
    notifyListeners();
  }
}
