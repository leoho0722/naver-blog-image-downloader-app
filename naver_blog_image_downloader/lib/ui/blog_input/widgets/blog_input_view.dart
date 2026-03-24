import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../config/bottom_sheet_animation.dart';
import '../../../data/models/fetch_result.dart';
import '../../core/naver_url_validator.dart';
import '../../download/widgets/download_view.dart';
import '../../settings/widgets/settings_view.dart';
import '../view_model/blog_input_view_model.dart';

/// Blog 網址輸入頁面，提供文字輸入欄位讓使用者貼上 Naver Blog 網址並取得照片列表。
class BlogInputView extends StatefulWidget {
  /// 建立 [BlogInputView]。
  const BlogInputView({super.key});

  @override
  State<BlogInputView> createState() => _BlogInputViewState();
}

class _BlogInputViewState extends State<BlogInputView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  /// 頁面對應的 ViewModel，透過 Provider 取得。
  late final BlogInputViewModel _viewModel;

  /// 網址輸入欄位的文字控制器。
  final _controller = TextEditingController();

  /// 設定頁面 bottom sheet 的動畫控制器。
  late final AnimationController _sheetAnimationController;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BlogInputViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    WidgetsBinding.instance.addObserver(this);
    _sheetAnimationController = BottomSheetAnimation.createController(
      vsync: this,
      platform: defaultTargetPlatform,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_onViewModelChanged);
    _sheetAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardOnResume();
    }
  }

  /// 當 App 從背景恢復時，檢查剪貼板是否包含 Naver Blog 網址，
  /// 若有則彈出對話框詢問使用者是否貼上。
  Future<void> _checkClipboardOnResume() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    if (!NaverUrlValidator.isValid(text)) return;
    if (text == _controller.text) return;
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('偵測到 Blog 網址'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('貼上'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _pasteUrl(text);
    }
  }

  /// 使用者點擊「貼上」按鈕時觸發，從剪貼板讀取內容並驗證是否為合法網址。
  Future<void> _onPasteButtonPressed() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (!mounted) return;

    if (text == null || text.isEmpty) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('剪貼板沒有內容'),
            content: const Text('目前剪貼板中沒有可貼上的文字。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('好的'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    if (!NaverUrlValidator.isValid(text)) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('無法貼上'),
            content: const Text('目前剪貼板的內容似乎不是 Naver Blog 網址，請確認後再試一次。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('好的'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    _pasteUrl(text);
  }

  /// 將指定的 [url] 填入輸入欄位並通知 ViewModel。
  void _pasteUrl(String url) {
    _controller.text = url;
    _viewModel.onUrlChanged(url);
  }

  /// ViewModel 狀態變更的監聽回呼，根據錯誤或擷取結果執行對應的 UI 操作。
  void _onViewModelChanged() {
    final errorMessage = _viewModel.errorMessage;
    if (errorMessage != null) {
      _viewModel.onUrlChanged(_viewModel.blogUrl);
      _showErrorDialog(errorMessage);
      return;
    }

    final fetchResult = _viewModel.fetchResult;
    if (fetchResult != null) {
      _viewModel.reset();
      _handleFetchResult(fetchResult);
    }
  }

  /// 以 AlertDialog 顯示錯誤訊息。
  void _showErrorDialog(String message) {
    if (!mounted) return;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('發生錯誤'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('好的'),
            ),
          ],
        ),
      ),
    );
  }

  /// 處理照片擷取結果：若有失敗先警告，若已快取直接導航，否則顯示下載對話框。
  Future<void> _handleFetchResult(FetchResult fetchResult) async {
    // 有擷取失敗時，先顯示警告對話框
    if (fetchResult.failureDownloads > 0) {
      final shouldContinue = await _showFetchFailureDialog(fetchResult);
      if (shouldContinue != true || !mounted) return;
    }

    if (fetchResult.isFullyCached) {
      // 已完整快取，直接跳到照片瀏覽頁
      _navigateToGallery(fetchResult);
      return;
    }

    // 顯示下載進度對話框
    final completed = await showDownloadDialog(context, fetchResult);
    if (completed == true && mounted) {
      _navigateToGallery(fetchResult);
    }
  }

  /// 顯示部分照片擷取失敗的警告對話框，回傳使用者是否選擇繼續下載。
  Future<bool?> _showFetchFailureDialog(FetchResult fetchResult) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('部分照片擷取失敗'),
        content: Text(
          '總共有 ${fetchResult.totalImages} 張照片，'
          '成功取得 ${fetchResult.photos.length} 張，'
          '無法取得 ${fetchResult.failureDownloads} 張。\n\n'
          '請問是否繼續下載已取得的照片？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消下載'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('繼續下載'),
          ),
        ],
      ),
    );
  }

  /// 導航至照片瀏覽頁面，傳入擷取結果作為頁面參數。
  void _navigateToGallery(FetchResult fetchResult) {
    context.push('/gallery/${fetchResult.blogId}', extra: fetchResult);
  }

  /// 以 modal bottom sheet 開啟設定頁面。
  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      transitionAnimationController: _sheetAnimationController,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => const SettingsView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BlogInputViewModel>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('照片下載器'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsSheet,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                onChanged: viewModel.onUrlChanged,
                decoration: InputDecoration(
                  labelText: 'Naver Blog 網址',
                  hintText: 'https://blog.naver.com/...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste),
                    tooltip: '從剪貼板貼上',
                    onPressed: _onPasteButtonPressed,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (viewModel.statusMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      viewModel.statusMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          viewModel.fetchPhotos();
                        },
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('取得照片列表'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
