import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/photo_entity.dart';
import '../view_model/photo_detail_view_model.dart';

/// 照片詳細頁面，以全螢幕原始解析度顯示照片並支援手勢縮放。
///
/// 底部提供水平排列的 info 與儲存按鈕。
class PhotoDetailView extends StatefulWidget {
  const PhotoDetailView({super.key, required this.photoId});

  final String photoId;

  @override
  State<PhotoDetailView> createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final extra = GoRouterState.of(context).extra;
        if (extra is ({PhotoEntity photo, String blogId})) {
          context.read<PhotoDetailViewModel>().load(extra.photo, extra.blogId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PhotoDetailViewModel>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: viewModel.cachedFile == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 照片區域：撐滿剩餘空間，底部與按鈕間距 10
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InteractiveViewer(
                      child: SizedBox.expand(
                        child: Image.file(
                          viewModel.cachedFile!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                // 底部按鈕列：水平排列，左 info 右儲存
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: bottomPadding + 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'info',
                        onPressed: () => _showInfoSheet(context, viewModel),
                        child: const Icon(Icons.info_outline),
                      ),
                      FloatingActionButton(
                        heroTag: 'save',
                        onPressed: viewModel.isSaving || viewModel.isSaved
                            ? null
                            : viewModel.saveToGallery,
                        child: viewModel.isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                viewModel.isSaved
                                    ? Icons.check
                                    : Icons.save_alt,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showInfoSheet(BuildContext context, PhotoDetailViewModel viewModel) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('檔案資訊', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _InfoRow(label: '檔案名稱', value: viewModel.photo?.filename ?? '-'),
            _InfoRow(label: '檔案大小', value: viewModel.formattedFileSize),
            _InfoRow(label: '照片尺寸', value: viewModel.formattedDimensions),
            _InfoRow(label: '下載網址', value: viewModel.photo?.url ?? '-'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
