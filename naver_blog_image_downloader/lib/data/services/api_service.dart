import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

import '../models/dtos/job_status_response.dart';
import '../models/dtos/photo_download_request.dart';

/// 與後端 API Gateway 溝通的服務層，使用 AWS Amplify SDK 發送 REST 請求。
///
/// 採用非同步任務模式：
/// 1. [submitJob] 提交下載任務，Lambda 立即回傳 job_id（HTTP 202）
/// 2. [checkJobStatus] 輪詢任務狀態（HTTP 200 或 500）
class ApiService {
  /// 建立 [ApiService]。
  ///
  /// [apiName] 為 Amplify 配置中定義的 REST API 名稱。
  /// [timeout] 為單次請求逾時時間。
  ApiService({
    this.apiName = 'naverBlogApi',
    this.timeout = const Duration(seconds: 30),
  });

  /// Amplify 配置中的 REST API 名稱。
  final String apiName;

  /// 單次 HTTP 請求逾時時間。
  final Duration timeout;

  /// API endpoint 路徑。
  static const _path = '/api/photos';

  /// 提交非同步下載任務。
  ///
  /// 回傳 job_id；伺服器回應非 2xx 時拋出 [ApiServiceException]。
  Future<String> submitJob(String blogUrl) async {
    final payload = PhotoDownloadRequest.download(blogUrl: blogUrl).toJson();
    final response = await _post(payload);

    final jobId = response['job_id'] as String?;
    if (jobId == null) {
      throw const ApiServiceException('API 回應中缺少 job_id');
    }
    return jobId;
  }

  /// 查詢任務狀態。
  ///
  /// 回傳 [JobStatusResponse]，包含 status 與 result。
  /// HTTP 200（processing / completed）和 HTTP 500（failed）都會被正常解析，
  /// 因為 failed 是合法的業務狀態，不應視為 API 錯誤。
  Future<JobStatusResponse> checkJobStatus(String jobId) async {
    final payload = PhotoDownloadRequest.status(jobId: jobId).toJson();
    // 狀態查詢接受 200（processing/completed）和 500（failed）
    final response = await _post(payload, acceptStatusCodes: {200, 500});
    return JobStatusResponse.fromJson(response);
  }

  /// 發送 POST 請求並解析回應 JSON。
  ///
  /// [acceptStatusCodes] 指定可接受的 HTTP 狀態碼，其餘拋出 [ApiServiceException]。
  /// 預設接受 200-299 範圍。
  Future<Map<String, dynamic>> _post(
    Map<String, dynamic> body, {
    Set<int>? acceptStatusCodes,
  }) async {
    try {
      debugPrint('[ApiService] POST $_path');
      debugPrint('[ApiService] Request: ${jsonEncode(body)}');

      final restOperation = Amplify.API.post(
        _path,
        apiName: apiName,
        body: HttpPayload.json(body),
      );

      final response = await restOperation.response.timeout(timeout);
      final statusCode = response.statusCode;
      final rawBody = response.decodeBody();

      debugPrint('[ApiService] Response ($statusCode): $rawBody');

      // 檢查狀態碼是否在可接受範圍
      final isAccepted = acceptStatusCodes != null
          ? acceptStatusCodes.contains(statusCode)
          : (statusCode >= 200 && statusCode < 300);

      if (!isAccepted) {
        debugPrint('[ApiService] 非預期狀態碼: $statusCode');
        throw ApiServiceException('伺服器錯誤（$statusCode）', statusCode: statusCode);
      }

      final responseJson = jsonDecode(rawBody) as Map<String, dynamic>;

      // API Gateway Lambda proxy integration 會將資料包在 body 欄位中
      if (responseJson.containsKey('body') && responseJson['body'] is String) {
        final innerBody =
            jsonDecode(responseJson['body'] as String) as Map<String, dynamic>;
        debugPrint('[ApiService] Parsed inner body: ${jsonEncode(innerBody)}');
        return innerBody;
      }
      return responseJson;
    } on ApiServiceException {
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('[ApiService] 請求逾時: $e');
      rethrow;
    } on ApiException catch (e) {
      debugPrint('[ApiService] Amplify API 錯誤: ${e.message}');
      throw ApiServiceException('API 呼叫失敗：${e.message}');
    } on Exception catch (e) {
      debugPrint('[ApiService] 未預期錯誤: $e');
      throw ApiServiceException('發生未預期的錯誤：$e');
    }
  }
}

/// API 服務呼叫失敗時拋出的例外，攜帶 HTTP 狀態碼與錯誤訊息。
class ApiServiceException implements Exception {
  const ApiServiceException(this.message, {this.statusCode});

  /// 錯誤訊息。
  final String message;

  /// HTTP 狀態碼。
  final int? statusCode;

  /// 是否為可重試的伺服器錯誤（502、503、504）。
  bool get isRetryable =>
      statusCode == 502 || statusCode == 503 || statusCode == 504;

  @override
  String toString() => message;
}
