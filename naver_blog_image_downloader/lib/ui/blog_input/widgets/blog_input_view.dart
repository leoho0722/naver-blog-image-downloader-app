import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/fetch_result.dart';
import '../../download/widgets/download_view.dart';
import '../../settings/widgets/settings_view.dart';
import '../view_model/blog_input_view_model.dart';

/// Blog 網址輸入頁面，提供文字輸入欄位讓使用者貼上 Naver Blog 網址並取得照片列表。
class BlogInputView extends StatefulWidget {
  const BlogInputView({super.key});

  @override
  State<BlogInputView> createState() => _BlogInputViewState();
}

class _BlogInputViewState extends State<BlogInputView> {
  late final BlogInputViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BlogInputViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
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
                onChanged: viewModel.onUrlChanged,
                decoration: const InputDecoration(
                  labelText: 'Naver Blog 網址',
                  hintText: 'https://blog.naver.com/...',
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
