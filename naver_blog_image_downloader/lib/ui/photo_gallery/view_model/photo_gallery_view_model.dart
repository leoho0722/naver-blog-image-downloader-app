import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../data/models/photo_entity.dart';
import '../../../data/repositories/cache_repository.dart';
import '../../../data/repositories/photo_repository.dart';
import '../../core/result.dart';

/// 相簿儲存操作的錯誤類型。
enum GallerySaveErrorType {
  /// 儲存至相簿失敗。
  saveToGalleryFailed,
}

/// 照片瀏覽頁面的互動模式。
enum GalleryMode {
  /// 一般瀏覽模式。
  browsing,

  /// 多選模式，使用者可勾選照片。
  selecting,

  /// 儲存中，正在將照片寫入相簿。
  saving,
}

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

  /// 目前的互動模式，以 enum 管理互斥狀態。
  GalleryMode _mode = GalleryMode.browsing;

  /// 最近一次儲存失敗的錯誤類型，無錯誤時為 `null`。
  GallerySaveErrorType? _errorType;

  /// 已載入的照片清單。
  List<PhotoEntity> get photos => _photos;

  /// 目前操作的 Blog 識別碼。
  String get blogId => _blogId;

  /// 預先解析的快取檔案對應表（photoId → File?）。
  Map<String, File?> get cachedFiles => _cachedFiles;

  /// 已選取的照片 ID 集合。
  Set<String> get selectedIds => _selectedIds;

  /// 目前的互動模式。
  GalleryMode get mode => _mode;

  /// 是否處於選取模式（selecting 或 saving 皆算）。
  bool get isSelectMode =>
      _mode == GalleryMode.selecting || _mode == GalleryMode.saving;

  /// 是否正在執行儲存至相簿操作。
  bool get isSaving => _mode == GalleryMode.saving;

  /// 最近一次儲存失敗的錯誤類型。
  GallerySaveErrorType? get errorType => _errorType;

  /// 載入照片清單與 Blog 識別碼，並預先解析所有快取檔案。
  ///
  /// [photos] 為要載入的照片實體清單。
  /// [blogId] 為目前操作的 Blog 識別碼，用於查詢對應的快取檔案。
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
    if (_mode == GalleryMode.selecting) {
      _mode = GalleryMode.browsing;
      _selectedIds.clear();
    } else {
      _mode = GalleryMode.selecting;
    }
    notifyListeners();
  }

  /// 切換指定照片的選取狀態。
  ///
  /// [photoId] 為要切換選取狀態的照片識別碼。
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
    _mode = GalleryMode.saving;
    _errorType = null;
    notifyListeners();

    final selected = _photos.where((p) => _selectedIds.contains(p.id)).toList();
    final result = await _photoRepository.saveToGalleryFromCache(
      photos: selected,
      blogId: _blogId,
    );

    switch (result) {
      case Ok<void>():
        _selectedIds.clear();
      case Error<void>(:final error):
        _errorType = GallerySaveErrorType.saveToGalleryFailed;
        debugPrint('[PhotoGalleryVM] $error');
    }

    _mode = GalleryMode.browsing;
    notifyListeners();
  }

  /// 將所有照片儲存至裝置相簿。
  Future<void> saveAllToGallery() async {
    _mode = GalleryMode.saving;
    _errorType = null;
    notifyListeners();

    final result = await _photoRepository.saveToGalleryFromCache(
      photos: _photos,
      blogId: _blogId,
    );

    switch (result) {
      case Ok<void>():
        break;
      case Error<void>(:final error):
        _errorType = GallerySaveErrorType.saveToGalleryFailed;
        debugPrint('[PhotoGalleryVM] $error');
    }

    _mode = GalleryMode.browsing;
    notifyListeners();
  }
}
