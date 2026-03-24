import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../../../data/models/photo_entity.dart';
import '../../../data/repositories/cache_repository.dart';
import '../../../data/services/gallery_service.dart';

/// 儲存操作狀態。
enum SaveState {
  /// 閒置，尚未執行儲存。
  idle,

  /// 儲存中，正在將照片寫入相簿。
  saving,

  /// 已儲存，照片已成功寫入相簿。
  saved,
}

/// 照片詳細頁面的 ViewModel，管理照片列表、當前索引、檔案元資料快取與儲存至相簿。
class PhotoDetailViewModel extends ChangeNotifier {
  /// 建立 [PhotoDetailViewModel]，需注入 [CacheRepository] 與 [GalleryService]。
  PhotoDetailViewModel({
    required CacheRepository cacheRepository,
    required GalleryService galleryService,
  }) : _cacheRepository = cacheRepository,
       _galleryService = galleryService;

  final CacheRepository _cacheRepository;
  final GalleryService _galleryService;

  /// 目前載入的照片實體清單。
  List<PhotoEntity> _photos = [];

  /// 目前操作的 Blog 識別碼。
  String _blogId = '';

  /// 目前顯示照片在 [_photos] 中的索引位置。
  int _currentIndex = 0;

  /// 目前的儲存操作狀態（閒置 / 儲存中 / 已儲存）。
  SaveState _saveState = SaveState.idle;

  /// 照片索引對應的元資料快取，避免重複讀取檔案與解析圖片尺寸。
  final Map<int, _PhotoMetadata> _metadataCache = {};

  /// 已載入的照片清單。
  List<PhotoEntity> get photos => _photos;

  /// 目前操作的 Blog 識別碼。
  String get blogId => _blogId;

  /// 目前顯示照片的索引。
  int get currentIndex => _currentIndex;

  /// 照片總數。
  int get totalCount => _photos.length;

  /// 目前載入的照片實體。
  PhotoEntity? get photo => _photos.isNotEmpty ? _photos[_currentIndex] : null;

  /// 當前照片的快取檔案。
  File? get cachedFile => _metadataCache[_currentIndex]?.cachedFile;

  /// 當前照片的檔案大小（bytes）。
  int? get fileSizeBytes => _metadataCache[_currentIndex]?.fileSizeBytes;

  /// 當前照片的寬度（px）。
  int? get imageWidth => _metadataCache[_currentIndex]?.imageWidth;

  /// 當前照片的高度（px）。
  int? get imageHeight => _metadataCache[_currentIndex]?.imageHeight;

  /// 儲存操作狀態。
  SaveState get saveState => _saveState;

  /// 格式化的檔案大小字串。
  String get formattedFileSize {
    final bytes = fileSizeBytes;
    if (bytes == null) return '-';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  /// 格式化的照片尺寸字串。
  String get formattedDimensions {
    final w = imageWidth;
    final h = imageHeight;
    if (w == null || h == null) return '-';
    return '$w × $h';
  }

  /// 載入照片列表並讀取初始照片的檔案元資料。
  Future<void> loadAll(
    List<PhotoEntity> photos,
    String blogId,
    int initialIndex,
  ) async {
    _photos = photos;
    _blogId = blogId;
    _currentIndex = initialIndex;
    _saveState = SaveState.idle;
    _metadataCache.clear();
    notifyListeners();

    await _loadMetadataForIndex(initialIndex);
    notifyListeners();
  }

  /// 切換當前顯示的照片索引。
  Future<void> setCurrentIndex(int index) async {
    if (index < 0 || index >= _photos.length) return;
    _currentIndex = index;
    _saveState = SaveState.idle;
    notifyListeners();

    if (!_metadataCache.containsKey(index)) {
      await _loadMetadataForIndex(index);
      notifyListeners();
    }
  }

  /// 將目前照片儲存至裝置相簿。
  Future<void> saveToGallery() async {
    if (cachedFile == null || _saveState == SaveState.saving) return;

    _saveState = SaveState.saving;
    notifyListeners();

    try {
      final hasPermission = await _galleryService.requestPermission();
      if (!hasPermission) {
        debugPrint('[PhotoDetailVM] 相簿權限未授權');
        _saveState = SaveState.idle;
        notifyListeners();
        return;
      }

      await _galleryService.saveToGallery(cachedFile!.path);
      _saveState = SaveState.saved;
    } on Exception catch (e) {
      debugPrint('[PhotoDetailVM] 儲存失敗: $e');
      _saveState = SaveState.idle;
    }

    notifyListeners();
  }

  /// 載入指定索引照片的元資料（快取檔案、檔案大小、圖片尺寸）。
  Future<void> _loadMetadataForIndex(int index) async {
    if (index < 0 || index >= _photos.length) return;
    if (_metadataCache.containsKey(index)) return;

    final photo = _photos[index];
    final file = await _cacheRepository.cachedFile(photo.filename, _blogId);

    int? fileSize;
    int? width;
    int? height;

    if (file != null) {
      fileSize = await file.length();

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      width = frame.image.width;
      height = frame.image.height;
      frame.image.dispose();
    }

    _metadataCache[index] = _PhotoMetadata(
      cachedFile: file,
      fileSizeBytes: fileSize,
      imageWidth: width,
      imageHeight: height,
    );
  }
}

/// 單張照片的元資料快取，包含快取檔案、檔案大小與圖片尺寸。
class _PhotoMetadata {
  /// 建立 [_PhotoMetadata]。
  const _PhotoMetadata({
    this.cachedFile,
    this.fileSizeBytes,
    this.imageWidth,
    this.imageHeight,
  });

  /// 本機快取的照片檔案，若尚未快取則為 `null`。
  final File? cachedFile;

  /// 照片檔案大小（bytes），若尚未讀取則為 `null`。
  final int? fileSizeBytes;

  /// 照片寬度（像素），若尚未解析則為 `null`。
  final int? imageWidth;

  /// 照片高度（像素），若尚未解析則為 `null`。
  final int? imageHeight;
}
