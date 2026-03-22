import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/fetch_result.dart';
import '../../core/naver_url_validator.dart';
import '../../download/widgets/download_view.dart';
import '../../settings/widgets/settings_view.dart';
import '../view_model/blog_input_view_model.dart';

/// Blog 網址輸入頁面，提供文字輸入欄位讓使用者貼上 Naver Blog 網址並取得照片列表。
class BlogInputView extends StatefulWidget {
  const BlogInputView({super.key});

  @override
  State<BlogInputView> createState() => _BlogInputViewState();
}

class _BlogInputViewState extends State<BlogInputView>
    with WidgetsBindingObserver {
  late final BlogInputViewModel _viewModel;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BlogInputViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_onViewModelChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardOnResume();
    }
  }

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

  void _pasteUrl(String url) {
    _controller.text = url;
    _viewModel.onUrlChanged(url);
  }

  void _onViewModelChanged() {
    final fetchResult = _viewModel.fetchResult;
    if (fetchResult != null) {
      _viewModel.reset();
      _handleFetchResult(fetchResult);
    }
  }

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

  void _navigateToGallery(FetchResult fetchResult) {
    context.push('/gallery/${fetchResult.blogId}', extra: fetchResult);
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
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                clipBehavior: Clip.antiAlias,
                builder: (_) => const SettingsView(),
              ),
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
              if (viewModel.errorMessage != null)
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
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
