import 'dart:async';

import 'package:flutter/material.dart';
import 'package:naver_blog_image_downloader/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/fetch_result.dart';
import '../view_model/photo_gallery_view_model.dart';
import 'photo_card.dart';

/// 照片瀏覽頁面，使用 GridView 網格佈局展示照片卡片。
///
/// 透過 GoRouter `extra` 接收 [FetchResult]，初次進入時自動載入照片清單。
class PhotoGalleryView extends StatefulWidget {
  /// 建立 [PhotoGalleryView]，需指定要瀏覽的 [blogId]。
  const PhotoGalleryView({super.key, required this.blogId});

  /// 目前瀏覽的 Blog 識別碼，由路由參數傳入。
  final String blogId;

  @override
  State<PhotoGalleryView> createState() => _PhotoGalleryViewState();
}

/// [PhotoGalleryView] 的狀態管理類，處理照片載入、選取模式與儲存中對話框。
class _PhotoGalleryViewState extends State<PhotoGalleryView> {
  /// 頁面對應的 ViewModel，透過 Provider 取得。
  late final PhotoGalleryViewModel _viewModel;

  /// 是否已完成初始載入（防止 [didChangeDependencies] 重複觸發）。
  bool _loaded = false;

  /// 「儲存中」對話框是否正在顯示，用於避免重複開啟或多餘關閉。
  bool _isSavingDialogOpen = false;

  /// 依賴變更時初始化 ViewModel 並載入照片資料。
  ///
  /// 首次呼叫時從路由 `extra` 取得 [FetchResult]，觸發 ViewModel 載入照片清單。
  /// 透過 [_loaded] 旗標防止重複觸發。
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _viewModel = context.read<PhotoGalleryViewModel>();
      _viewModel.addListener(_onViewModelChanged);
      final fetchResult = GoRouterState.of(context).extra as FetchResult?;
      if (fetchResult != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _viewModel.load(fetchResult.photos, fetchResult.blogId);
          }
        });
      }
    }
  }

  /// 釋放資源，移除 ViewModel 的狀態監聽器。
  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  /// ViewModel 狀態變更的監聽回呼，根據 [isSaving] 開啟或關閉儲存中對話框。
  void _onViewModelChanged() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (_viewModel.isSaving && !_isSavingDialogOpen) {
      _isSavingDialogOpen = true;
      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(
                width: 140,
                height: 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.gallerySaving),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else if (!_viewModel.isSaving && _isSavingDialogOpen) {
      _isSavingDialogOpen = false;
      Navigator.of(context).pop();
    }
  }

  /// 建構照片瀏覽頁面的 Widget 樹。
  ///
  /// 回傳包含 AppBar 操作列與 GridView 照片網格的 [Scaffold]。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = context.watch<PhotoGalleryViewModel>();
    final photos = viewModel.photos;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.galleryTitle(photos.length)),
        actions: [
          IconButton(
            icon: Icon(viewModel.isSelectMode ? Icons.close : Icons.select_all),
            tooltip: viewModel.isSelectMode
                ? l10n.galleryDeselectMode
                : l10n.gallerySelectMode,
            onPressed: viewModel.toggleSelectMode,
          ),
          if (viewModel.isSelectMode) ...[
            IconButton(
              icon: const Icon(Icons.check_box_outlined),
              tooltip: l10n.gallerySelectAll,
              onPressed: viewModel.selectAll,
            ),
            IconButton(
              icon: const Icon(Icons.save_alt),
              tooltip: l10n.gallerySaveSelected,
              onPressed: viewModel.selectedIds.isEmpty
                  ? null
                  : viewModel.saveSelectedToGallery,
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: l10n.gallerySaveAll,
              onPressed: photos.isEmpty ? null : viewModel.saveAllToGallery,
            ),
        ],
      ),
      body: photos.isEmpty
          ? Center(child: Text(l10n.galleryEmpty))
          : GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return PhotoCard(
                  photo: photo,
                  cachedFile: viewModel.cachedFiles[photo.id],
                  isSelected: viewModel.selectedIds.contains(photo.id),
                  isSelectMode: viewModel.isSelectMode,
                  onTap: () => _onPhotoTap(context, index),
                  onSelect: () => viewModel.toggleSelection(photo.id),
                );
              },
            ),
    );
  }

  /// 使用者點擊照片時，導航至照片詳細頁面。
  ///
  /// [context] 為當前的 BuildContext，用於執行路由導航。
  /// [index] 為被點擊照片在清單中的索引位置。
  void _onPhotoTap(BuildContext context, int index) {
    final viewModel = context.read<PhotoGalleryViewModel>();
    final photo = viewModel.photos[index];
    context.push(
      '/detail/${photo.id}',
      extra: (
        photos: viewModel.photos,
        blogId: viewModel.blogId,
        initialIndex: index,
      ),
    );
  }
}
