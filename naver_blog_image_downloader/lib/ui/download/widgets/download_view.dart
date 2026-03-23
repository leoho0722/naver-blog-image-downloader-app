import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/fetch_result.dart';
import '../view_model/download_view_model.dart';

/// 下載進度對話框，以 popup 方式顯示批次下載進度。
///
/// 使用 [showDownloadDialog] 顯示，下載完成後自動關閉並回傳 `true`。
class DownloadDialog extends StatefulWidget {
  /// 建立 [DownloadDialog]，需傳入 [fetchResult] 以決定要下載的照片。
  const DownloadDialog({super.key, required this.fetchResult});

  /// 要下載的照片擷取結果，包含照片清單、Blog ID 與來源網址。
  final FetchResult fetchResult;

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  bool _downloadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_downloadStarted) {
      _downloadStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startDownload());
    }
  }

  Future<void> _startDownload() async {
    if (!mounted) return;

    final viewModel = context.read<DownloadViewModel>();
    await viewModel.startDownload(
      photos: widget.fetchResult.photos,
      blogId: widget.fetchResult.blogId,
      blogUrl: widget.fetchResult.blogUrl,
    );

    // 下載完成，關閉對話框並回傳 true
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DownloadViewModel>();

    return AlertDialog(
      title: const Text('下載照片'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(value: viewModel.progress),
          const SizedBox(height: 24),
          Text(
            '${viewModel.completed} / ${viewModel.total}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.isDownloading ? '下載中...' : '下載完成',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (viewModel.result != null &&
              !viewModel.result!.isAllSuccessful) ...[
            const SizedBox(height: 12),
            Text(
              '${viewModel.result!.failedPhotos.length} 張下載失敗',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

/// 顯示下載進度對話框。
///
/// 下載完成後回傳 `true`，使用者手動關閉回傳 `null`。
Future<bool?> showDownloadDialog(
  BuildContext context,
  FetchResult fetchResult,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => DownloadDialog(fetchResult: fetchResult),
  );
}
