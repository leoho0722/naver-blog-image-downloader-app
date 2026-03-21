import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../../../data/models/photo_entity.dart';
import '../../../data/repositories/cache_repository.dart';
import '../../../data/services/gallery_service.dart';

/// 照片詳細頁面的 ViewModel，負責載入單張照片資訊、檔案元資料查詢與儲存至相簿。
class PhotoDetailViewModel extends ChangeNotifier {
  PhotoDetailViewModel({
    required CacheRepository cacheRepository,
    required GalleryService galleryService,
  })  : _cacheRepository = cacheRepository,
        _galleryService = galleryService;

  final CacheRepository _cacheRepository;
  final GalleryService _galleryService;

  PhotoEntity? _photo;
  String _blogId = '';
  File? _cachedFile;
  int? _fileSizeBytes;
  int? _imageWidth;
  int? _imageHeight;
  bool _isSaving = false;
  bool _isSaved = false;

  /// 目前載入的照片實體。
  PhotoEntity? get photo => _photo;

  /// 目前操作的 Blog 識別碼。
  String get blogId => _blogId;

  /// 快取的本地檔案。
  File? get cachedFile => _cachedFile;

  /// 檔案大小（bytes）。
  int? get fileSizeBytes => _fileSizeBytes;

  /// 照片寬度（px）。
  int? get imageWidth => _imageWidth;

  /// 照片高度（px）。
  int? get imageHeight => _imageHeight;

  /// 是否正在儲存至相簿。
  bool get isSaving => _isSaving;

  /// 是否已儲存至相簿。
  bool get isSaved => _isSaved;

  /// 格式化的檔案大小字串。
  String get formattedFileSize {
    if (_fileSizeBytes == null) return '-';
    final kb = _fileSizeBytes! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  /// 格式化的照片尺寸字串。
  String get formattedDimensions {
    if (_imageWidth == null || _imageHeight == null) return '-';
    return '$_imageWidth × $_imageHeight';
  }

  /// 載入指定照片並讀取檔案元資料（大小、尺寸）。
  Future<void> load(PhotoEntity photo, String blogId) async {
    _photo = photo;
    _blogId = blogId;
    _isSaved = false;
    notifyListeners();

    // 讀取快取檔案
    _cachedFile = await _cacheRepository.cachedFile(photo.filename, blogId);
    if (_cachedFile != null) {
      // 讀取檔案大小
      _fileSizeBytes = await _cachedFile!.length();

      // 讀取圖片尺寸
      final bytes = await _cachedFile!.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _imageWidth = frame.image.width;
      _imageHeight = frame.image.height;
      frame.image.dispose();
    }
    notifyListeners();
  }

  /// 將目前照片儲存至裝置相簿。
  ///
  /// 儲存前會先請求相簿存取權限，未授權時不執行儲存。
  Future<void> saveToGallery() async {
    if (_cachedFile == null || _isSaving) return;

    _isSaving = true;
    notifyListeners();

    try {
      final hasPermission = await _galleryService.requestPermission();
      if (!hasPermission) {
        debugPrint('[PhotoDetailVM] 相簿權限未授權');
        _isSaving = false;
        notifyListeners();
        return;
      }

      await _galleryService.saveToGallery(_cachedFile!.path);
      _isSaved = true;
    } on Exception catch (e) {
      debugPrint('[PhotoDetailVM] 儲存失敗: $e');
    }

    _isSaving = false;
    notifyListeners();
  }
}
