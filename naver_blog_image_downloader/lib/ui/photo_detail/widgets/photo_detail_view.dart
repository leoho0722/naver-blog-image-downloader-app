import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/photo_entity.dart';
import '../view_model/photo_detail_view_model.dart';
import 'photo_detail_capsule_bar.dart';

/// 照片詳細頁面，以全螢幕顯示照片並支援手勢縮放、水平滑動切換與沈浸模式。
class PhotoDetailView extends StatefulWidget {
  /// 建立 [PhotoDetailView]，需指定要顯示的 [photoId]。
  const PhotoDetailView({super.key, required this.photoId});

  /// 要顯示的照片識別碼，由路由參數傳入。
  final String photoId;

  @override
  State<PhotoDetailView> createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
  bool _loaded = false;
  bool _isImmersive = false;
  bool _isZoomed = false;

  late PageController _pageController;
  final _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final extra = GoRouterState.of(context).extra;
      if (extra
          is ({List<PhotoEntity> photos, String blogId, int initialIndex})) {
        _pageController.dispose();
        _pageController = PageController(initialPage: extra.initialIndex);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<PhotoDetailViewModel>().loadAll(
              extra.photos,
              extra.blogId,
              extra.initialIndex,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.01;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  void _toggleImmersiveMode() {
    setState(() => _isImmersive = !_isImmersive);
    SystemChrome.setEnabledSystemUIMode(
      _isImmersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PhotoDetailViewModel>();
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _isImmersive
          ? Colors.black
          : Theme.of(context).scaffoldBackgroundColor,
      body: viewModel.photos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Layer 1: PageView（全螢幕）
                PageView.builder(
                  controller: _pageController,
                  physics: _isZoomed
                      ? const NeverScrollableScrollPhysics()
                      : const PageScrollPhysics(),
                  itemCount: viewModel.totalCount,
                  onPageChanged: (index) {
                    viewModel.setCurrentIndex(index);
                    _transformationController.value = Matrix4.identity();
                  },
                  itemBuilder: (context, index) {
                    final file = index == viewModel.currentIndex
                        ? viewModel.cachedFile
                        : null;

                    return GestureDetector(
                      onTap: _toggleImmersiveMode,
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        child: Center(
                          child: file != null
                              ? Image.file(file, fit: BoxFit.contain)
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    );
                  },
                ),

                // Layer 2: 頂部覆蓋列
                AnimatedSlide(
                  offset: _isImmersive ? const Offset(0, -1) : Offset.zero,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Container(
                    padding: EdgeInsets.only(top: topPadding),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      children: [
                        BackButton(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        const Spacer(),
                        Text(
                          '${viewModel.currentIndex + 1} / ${viewModel.totalCount}',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                // Layer 3: 底部膠囊操作列
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedSlide(
                    offset: _isImmersive ? const Offset(0, 1) : Offset.zero,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding + 20),
                      child: Center(
                        child: PhotoDetailCapsuleBar(
                          onInfoTap: () => _showInfoSheet(context, viewModel),
                          onSaveTap: viewModel.saveToGallery,
                          saveState: viewModel.saveState,
                        ),
                      ),
                    ),
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
            _InfoRow(label: '檔案大小', value: viewModel.formattedFileSize),
            _InfoRow(label: '照片尺寸', value: viewModel.formattedDimensions),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 資訊列元件，以「標籤：值」的水平排列顯示單項照片資訊。
class _InfoRow extends StatelessWidget {
  /// 建立 [_InfoRow]。
  const _InfoRow({required this.label, required this.value});

  /// 左側標籤文字（例如「檔案大小」）。
  final String label;

  /// 右側數值文字（例如「1.5 MB」）。
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
