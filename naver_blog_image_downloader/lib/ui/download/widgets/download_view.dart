import 'package:flutter/material.dart';
import 'package:naver_blog_image_downloader/l10n/app_localizations.dart';
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
  /// 是否已啟動下載流程，用於防止 [didChangeDependencies] 重複觸發。
  bool _downloadStarted = false;

  /// 依賴變更時啟動批次下載流程。
  ///
  /// 首次呼叫時透過 [_downloadStarted] 旗標確保只觸發一次下載。
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_downloadStarted) {
      _downloadStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startDownload());
    }
  }

  /// 啟動批次下載，完成後自動關閉對話框並回傳 `true`。
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

  /// 建構下載進度對話框的 Widget 樹。
  ///
  /// 回傳包含進度環、已完成數量與下載狀態文字的 [AlertDialog]。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = context.watch<DownloadViewModel>();

    return AlertDialog(
      title: Text(l10n.downloadDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(value: viewModel.progress),
          const SizedBox(height: 24),
          Text(
            l10n.downloadProgress(viewModel.completed, viewModel.total),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.isDownloading
                ? l10n.downloadStatusDownloading
                : l10n.downloadStatusCompleted,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (viewModel.result != null &&
              !viewModel.result!.isAllSuccessful) ...[
            const SizedBox(height: 12),
            Text(
              l10n.downloadFailedCount(viewModel.result!.failedPhotos.length),
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
///
/// [context] 為當前的 BuildContext，用於開啟對話框。
/// [fetchResult] 為照片擷取結果，包含要下載的照片清單與 Blog 資訊。
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
