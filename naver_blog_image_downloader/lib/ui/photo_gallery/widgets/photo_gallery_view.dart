import 'dart:io';

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
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final fetchResult = GoRouterState.of(context).extra as FetchResult?;
      if (fetchResult != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<PhotoGalleryViewModel>().load(
              fetchResult.photos,
              fetchResult.blogId,
            );
          }
        });
      }
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
      body: viewModel.isSaving
          ? const Center(child: CircularProgressIndicator())
          : photos.isEmpty
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
                return FutureBuilder<File?>(
                  future: viewModel.cachedFile(photo),
                  builder: (context, snapshot) {
                    return PhotoCard(
                      photo: photo,
                      cachedFile: snapshot.data,
                      isSelected: viewModel.selectedIds.contains(photo.id),
                      isSelectMode: viewModel.isSelectMode,
                      onTap: () => _onPhotoTap(context, photo),
                      onSelect: () => viewModel.toggleSelection(photo.id),
                    );
                  },
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
