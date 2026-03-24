import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../data/models/photo_entity.dart';
import '../../../data/repositories/cache_repository.dart';
import '../../../data/repositories/photo_repository.dart';

/// 照片瀏覽頁面的 ViewModel，管理照片清單呈現、選取模式與相簿儲存操作。
class PhotoGalleryViewModel extends ChangeNotifier {
  /// 建立 [PhotoGalleryViewModel]，需注入 [PhotoRepository] 與 [CacheRepository]。
  PhotoGalleryViewModel({
    required PhotoRepository photoRepository,
    required CacheRepository cacheRepository,
  }) : _photoRepository = photoRepository,
       _cacheRepository = cacheRepository;

  /// 注入的照片 Repository，用於執行儲存至相簿等操作。
  final PhotoRepository _photoRepository;

  /// 注入的快取 Repository，用於查詢本機快取檔案。
  final CacheRepository _cacheRepository;

  /// 目前載入的照片實體清單。
  List<PhotoEntity> _photos = [];

  /// 目前操作的 Blog 識別碼。
  String _blogId = '';

  /// 照片 ID 對應的本機快取檔案（預先解析，避免重複查詢）。
  final Map<String, File?> _cachedFiles = {};

  /// 目前已選取的照片 ID 集合（選取模式下使用）。
  Set<String> _selectedIds = {};

  /// 是否處於多選模式。
  bool _isSelectMode = false;

  /// 是否正在將照片儲存至相簿。
  bool _isSaving = false;

  /// 已載入的照片清單。
  List<PhotoEntity> get photos => _photos;

  /// 目前操作的 Blog 識別碼。
  String get blogId => _blogId;

  /// 預先解析的快取檔案對應表（photoId → File?）。
  Map<String, File?> get cachedFiles => _cachedFiles;

  /// 已選取的照片 ID 集合。
  Set<String> get selectedIds => _selectedIds;

  /// 是否處於選取模式。
  bool get isSelectMode => _isSelectMode;

  /// 是否正在執行儲存至相簿操作。
  bool get isSaving => _isSaving;

  /// 載入照片清單與 Blog 識別碼，並預先解析所有快取檔案。
  Future<void> load(List<PhotoEntity> photos, String blogId) async {
    _photos = photos;
    _blogId = blogId;
    _cachedFiles.clear();
    notifyListeners();

    for (final photo in photos) {
      _cachedFiles[photo.id] = await _cacheRepository.cachedFile(
        photo.filename,
        blogId,
      );
    }
    notifyListeners();
  }

  /// 切換選取模式。離開選取模式時清空已選取的照片。
  void toggleSelectMode() {
    _isSelectMode = !_isSelectMode;
    if (!_isSelectMode) {
      _selectedIds.clear();
    }
    notifyListeners();
  }

  /// 切換指定照片的選取狀態。
  void toggleSelection(String photoId) {
    _selectedIds.contains(photoId)
        ? _selectedIds.remove(photoId)
        : _selectedIds.add(photoId);
    notifyListeners();
  }

  /// 全選或取消全選。若目前已全選則取消全選，否則全選。
  void selectAll() {
    _selectedIds.length == _photos.length
        ? _selectedIds.clear()
        : _selectedIds = _photos.map((p) => p.id).toSet();
    notifyListeners();
  }

  /// 將已選取的照片儲存至裝置相簿。
  Future<void> saveSelectedToGallery() async {
    _isSaving = true;
    notifyListeners();

    final selected = _photos.where((p) => _selectedIds.contains(p.id)).toList();
    await _photoRepository.saveToGalleryFromCache(
      photos: selected,
      blogId: _blogId,
    );

    _isSaving = false;
    _selectedIds.clear();
    _isSelectMode = false;
    notifyListeners();
  }

  /// 將所有照片儲存至裝置相簿。
  Future<void> saveAllToGallery() async {
    _isSaving = true;
    notifyListeners();

    await _photoRepository.saveToGalleryFromCache(
      photos: _photos,
      blogId: _blogId,
    );

    _isSaving = false;
    notifyListeners();
  }
}
