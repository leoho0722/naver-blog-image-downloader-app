package com.example.naver_blog_image_downloader

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupGalleryChannel(flutterEngine)
    }
}

// region Gallery Channel Extension

private const val GALLERY_CHANNEL_NAME = "com.example.naver_blog_image_downloader/gallery"

/**
 * 註冊 Gallery MethodChannel，處理 `saveToGallery` 與 `requestPermission` 呼叫。
 *
 * @param flutterEngine Flutter 引擎實例，用於取得 BinaryMessenger。
 */
private fun MainActivity.setupGalleryChannel(flutterEngine: FlutterEngine) {
    val gallerySaver = GallerySaver(this)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GALLERY_CHANNEL_NAME)
        .setMethodCallHandler { call, result ->
            handleGalleryMethodCall(call, result, gallerySaver)
        }
}

/**
 * 分派 Gallery MethodChannel 的方法呼叫。
 *
 * @param call Flutter 端傳入的方法呼叫，包含方法名稱與參數。
 * @param result 回傳結果給 Flutter 端的 callback。
 * @param gallerySaver 相簿儲存服務實例。
 */
private fun MainActivity.handleGalleryMethodCall(
    call: MethodCall,
    result: MethodChannel.Result,
    gallerySaver: GallerySaver
) {
    lifecycleScope.launch {
        when (call.method) {
            "saveToGallery" -> handleSaveToGallery(call, result, gallerySaver)
            "requestPermission" -> handleRequestPermission(result, gallerySaver)
            else -> result.notImplemented()
        }
    }
}

/**
 * 處理 `saveToGallery` 方法呼叫。
 *
 * @param call 需包含 `Map` 類型的參數，含 `filePath`（String）與 `totalCount`（Int）。
 * @param result 成功回傳 `true`，失敗回傳錯誤。
 * @param gallerySaver 相簿儲存服務實例。
 */
private suspend fun MainActivity.handleSaveToGallery(
    call: MethodCall,
    result: MethodChannel.Result,
    gallerySaver: GallerySaver
) {
    val args = call.arguments as? Map<*, *>
    val filePath = args?.get("filePath") as? String
    val totalCount = (args?.get("totalCount") as? Int) ?: 1
    if (filePath == null) {
        result.error("INVALID_ARG", "filePath is required", null)
        return
    }
    try {
        val success = gallerySaver.saveToGallery(filePath, totalCount)
        result.success(success)
    } catch (e: Exception) {
        result.error("SAVE_FAILED", e.message, null)
    }
}

/**
 * 處理 `requestPermission` 方法呼叫。
 *
 * @param result 授權成功回傳 `true`，否則回傳 `false`。
 * @param gallerySaver 相簿儲存服務實例。
 */
private fun MainActivity.handleRequestPermission(
    result: MethodChannel.Result,
    gallerySaver: GallerySaver
) {
    result.success(gallerySaver.requestPermission())
}

// endregion
