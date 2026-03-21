import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/dtos/job_status_response.dart';
import '../../../data/models/fetch_result.dart';
import '../../../data/repositories/photo_repository.dart';
import '../../../data/services/api_service.dart' show ApiServiceException;
import '../../core/result.dart';

/// Blog 網址輸入頁面的 ViewModel，負責管理使用者輸入的網址並發起照片擷取請求。
class BlogInputViewModel extends ChangeNotifier {
  /// 建立 [BlogInputViewModel]，需注入 [PhotoRepository] 以執行照片擷取。
  BlogInputViewModel({required PhotoRepository photoRepository})
    : _photoRepository = photoRepository;

  final PhotoRepository _photoRepository;

  String _blogUrl = '';
  bool _isLoading = false;
  String? _errorMessage;
  String? _statusMessage;
  FetchResult? _fetchResult;

  /// 使用者輸入的 Blog 網址。
  String get blogUrl => _blogUrl;

  /// 是否正在擷取照片（含提交任務 + 輪詢中）。
  bool get isLoading => _isLoading;

  /// 錯誤訊息，無錯誤時為 null。
  String? get errorMessage => _errorMessage;

  /// 目前的處理狀態訊息（如「伺服器處理中...」），無狀態時為 null。
  String? get statusMessage => _statusMessage;

  /// 照片擷取結果，尚未擷取時為 null。
  FetchResult? get fetchResult => _fetchResult;

  /// 當使用者修改網址時呼叫，同時清除先前的錯誤訊息。
  void onUrlChanged(String url) {
    _blogUrl = url;
    _errorMessage = null;
    notifyListeners();
  }

  /// 根據目前的 [blogUrl] 發起照片擷取請求（非同步任務模式）。
  ///
  /// 若網址為空會設定錯誤訊息；若已在載入中則不重複發送。
  /// 任務提交後會自動輪詢狀態，並透過 [statusMessage] 通知 UI。
  Future<void> fetchPhotos() async {
    if (_blogUrl.isEmpty) {
      _errorMessage = '請輸入 Blog 網址';
      notifyListeners();
      return;
    }

    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _statusMessage = '正在提交任務...';
    notifyListeners();

    final result = await _photoRepository.fetchPhotos(
      _blogUrl,
      onStatusChanged: (status) {
        _statusMessage = switch (status) {
          JobStatus.processing => '伺服器處理中...',
          JobStatus.completed => '處理完成',
          JobStatus.failed => null,
        };
        notifyListeners();
      },
    );

    switch (result) {
      case Ok<FetchResult>(:final value):
        _fetchResult = value;
        _isLoading = false;
        _statusMessage = null;
      case Error<FetchResult>(:final error):
        _errorMessage = _humanReadableError(error);
        _isLoading = false;
        _statusMessage = null;
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
      return error.message;
    }
    return error.toString();
  }

  /// 重設擷取結果與錯誤訊息，回到初始狀態。
  void reset() {
    _fetchResult = null;
    _errorMessage = null;
    _statusMessage = null;
    notifyListeners();
  }
}
