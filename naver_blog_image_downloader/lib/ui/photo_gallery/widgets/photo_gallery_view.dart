import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/fetch_result.dart';
import '../../../data/models/photo_entity.dart';
import '../view_model/photo_gallery_view_model.dart';
import 'photo_card.dart';

/// 照片瀏覽頁面，使用 GridView 網格佈局展示照片卡片。
///
/// 透過 GoRouter `extra` 接收 [FetchResult]，初次進入時自動載入照片清單。
class PhotoGalleryView extends StatefulWidget {
  const PhotoGalleryView({super.key, required this.blogId});

  /// 目前瀏覽的 Blog 識別碼。
  final String blogId;

  @override
  State<PhotoGalleryView> createState() => _PhotoGalleryViewState();
}

class _PhotoGalleryViewState extends State<PhotoGalleryView> {
  late final PhotoGalleryViewModel _viewModel;
  bool _loaded = false;
  bool _isSavingDialogOpen = false;

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

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
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
              child: const SizedBox(
                width: 140,
                height: 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('儲存中...'),
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PhotoGalleryViewModel>();
    final photos = viewModel.photos;

    return Scaffold(
      appBar: AppBar(
        title: Text('照片瀏覽（${photos.length}）'),
        actions: [
          IconButton(
            icon: Icon(viewModel.isSelectMode ? Icons.close : Icons.select_all),
            tooltip: viewModel.isSelectMode ? '取消選取' : '選取模式',
            onPressed: viewModel.toggleSelectMode,
          ),
          if (viewModel.isSelectMode) ...[
            IconButton(
              icon: const Icon(Icons.check_box_outlined),
              tooltip: '全選',
              onPressed: viewModel.selectAll,
            ),
            IconButton(
              icon: const Icon(Icons.save_alt),
              tooltip: '儲存已選取',
              onPressed: viewModel.selectedIds.isEmpty
                  ? null
                  : viewModel.saveSelectedToGallery,
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: '儲存全部',
              onPressed: photos.isEmpty ? null : viewModel.saveAllToGallery,
            ),
        ],
      ),
      body: photos.isEmpty
          ? const Center(child: Text('沒有照片'))
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
                  onTap: () => _onPhotoTap(context, photo),
                  onSelect: () => viewModel.toggleSelection(photo.id),
                );
              },
            ),
    );
  }

  void _onPhotoTap(BuildContext context, PhotoEntity photo) {
    final blogId = context.read<PhotoGalleryViewModel>().blogId;
    context.push('/detail/${photo.id}', extra: (photo: photo, blogId: blogId));
  }
}
