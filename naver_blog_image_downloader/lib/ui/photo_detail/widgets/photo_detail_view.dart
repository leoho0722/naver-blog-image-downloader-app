import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naver_blog_image_downloader/l10n/app_localizations.dart';
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

/// [PhotoDetailView] 的狀態管理類，處理照片分頁、手勢縮放與沈浸模式切換。
class _PhotoDetailViewState extends State<PhotoDetailView> {
  /// 是否已完成初始載入（防止 [didChangeDependencies] 重複觸發）。
  bool _loaded = false;

  /// 是否處於沈浸模式（隱藏系統 UI 與操作列）。
  bool _isImmersive = false;

  /// 照片是否正在被放大（縮放比例 > 1.01），放大時停用水平滑動。
  bool _isZoomed = false;

  /// 照片分頁控制器，控制水平滑動切換照片。
  late PageController _pageController;

  /// 照片縮放手勢的轉換矩陣控制器。
  final _transformationController = TransformationController();

  /// 初始化分頁控制器與縮放手勢監聽器。
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _transformationController.addListener(_onTransformChanged);
  }

  /// 依賴變更時初始化分頁控制器並載入照片資料。
  ///
  /// 首次呼叫時從路由 `extra` 取得照片清單與初始索引，觸發 ViewModel 載入。
  /// 透過 [_loaded] 旗標防止重複觸發。
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

  /// 釋放資源，恢復系統 UI 模式並銷毀控制器。
  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// 當縮放手勢改變時，更新 [_isZoomed] 狀態以決定是否停用水平滑動。
  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.01;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  /// 切換沈浸模式：隱藏／顯示系統狀態列、導航列與操作列。
  void _toggleImmersiveMode() {
    setState(() => _isImmersive = !_isImmersive);
    SystemChrome.setEnabledSystemUIMode(
      _isImmersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  /// 建構照片詳細頁面的 Widget 樹。
  ///
  /// 回傳包含全螢幕 PageView、頂部覆蓋列與底部膠囊操作列的 [Scaffold]。
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PhotoDetailViewModel>();
    final l10n = AppLocalizations.of(context);
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
                          l10n.detailPhotoCounter(
                            viewModel.currentIndex + 1,
                            viewModel.totalCount,
                          ),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
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

  /// 以 bottom sheet 顯示當前照片的檔案資訊（大小、尺寸）。
  ///
  /// [context] 為當前的 BuildContext，用於開啟 bottom sheet。
  /// [viewModel] 為照片詳細頁面的 ViewModel，提供檔案大小與尺寸資訊。
  void _showInfoSheet(BuildContext context, PhotoDetailViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.detailFileInfo,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: l10n.detailFileSize,
              value: viewModel.formattedFileSize,
            ),
            _InfoRow(
              label: l10n.detailDimensions,
              value: viewModel.formattedDimensions,
            ),
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
