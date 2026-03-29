import 'dart:io';
import 'dart:ui' as ui;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/photo_entity.dart';
import '../../../data/repositories/cache_repository.dart';
import '../../../data/repositories/log_repository.dart';
import '../../../data/repositories/photo_repository.dart';

part 'photo_detail_view_model.g.dart';

/// 照片詳細頁面的不可變狀態，封裝照片列表、當前索引、儲存操作與檔案元資料。
class PhotoDetailState {
  /// 建立 [PhotoDetailState]。
  ///
  /// - [photos]：照片實體清單，預設為空清單。
  /// - [blogId]：Blog 識別碼，預設為空字串。
  /// - [currentIndex]：目前顯示照片的索引，預設為 0。
  /// - [saveOperation]：儲存操作的非同步狀態，預設為 `null`（閒置）。
  /// - [cachedFile]：當前照片的快取檔案，預設為 `null`。
  /// - [fileSizeBytes]：當前照片的檔案大小（bytes），預設為 `null`。
  /// - [imageWidth]：當前照片的寬度（px），預設為 `null`。
  /// - [imageHeight]：當前照片的高度（px），預設為 `null`。
  const PhotoDetailState({
    this.photos = const [],
    this.blogId = '',
    this.currentIndex = 0,
    this.saveOperation,
    this.cachedFile,
    this.fileSizeBytes,
    this.imageWidth,
    this.imageHeight,
  });

  /// 目前載入的照片實體清單。
  final List<PhotoEntity> photos;

  /// 目前操作的 Blog 識別碼。
  final String blogId;

  /// 目前顯示照片在 [photos] 中的索引位置。
  final int currentIndex;

  /// 儲存操作的非同步狀態；`null` 表示閒置。
  final AsyncValue<void>? saveOperation;

  /// 當前照片的快取檔案。
  final File? cachedFile;

  /// 當前照片的檔案大小（bytes）。
  final int? fileSizeBytes;

  /// 當前照片的寬度（px）。
  final int? imageWidth;

  /// 當前照片的高度（px）。
  final int? imageHeight;

  /// 目前載入的照片實體。
  ///
  /// 回傳 [currentIndex] 對應的 [PhotoEntity]；清單為空時回傳 `null`。
  PhotoEntity? get photo => photos.isNotEmpty ? photos[currentIndex] : null;

  /// 照片總數。
  ///
  /// 回傳 [photos] 清單的長度。
  int get totalCount => photos.length;

  /// 是否正在儲存中。
  ///
  /// 回傳 `true` 表示 [saveOperation] 為 [AsyncLoading] 狀態。
  bool get isSaving => saveOperation is AsyncLoading;

  /// 是否已成功儲存。
  ///
  /// 回傳 `true` 表示 [saveOperation] 為 [AsyncData] 狀態。
  bool get isSaved => saveOperation is AsyncData;

  /// 格式化的檔案大小字串。
  ///
  /// 回傳以 KB 或 MB 為單位的字串（保留一位小數）；尚未讀取時回傳 `"-"`。
  String get formattedFileSize {
    final bytes = fileSizeBytes;
    if (bytes == null) return '-';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  /// 格式化的照片尺寸字串。
  ///
  /// 回傳 `"寬 × 高"` 格式的字串；尚未解析時回傳 `"-"`。
  String get formattedDimensions {
    final w = imageWidth;
    final h = imageHeight;
    if (w == null || h == null) return '-';
    return '$w × $h';
  }

  /// 建立狀態副本，僅覆寫指定欄位。
  ///
  /// - [photos]：若提供則覆寫照片清單。
  /// - [blogId]：若提供則覆寫 Blog 識別碼。
  /// - [currentIndex]：若提供則覆寫目前索引。
  /// - [saveOperation]：使用函式包裝以允許顯式設定為 `null`。
  /// - [cachedFile]：使用函式包裝以允許顯式設定為 `null`。
  /// - [fileSizeBytes]：使用函式包裝以允許顯式設定為 `null`。
  /// - [imageWidth]：使用函式包裝以允許顯式設定為 `null`。
  /// - [imageHeight]：使用函式包裝以允許顯式設定為 `null`。
  ///
  /// 回傳新的 [PhotoDetailState]，未指定的欄位保留原值。
  PhotoDetailState copyWith({
    List<PhotoEntity>? photos,
    String? blogId,
    int? currentIndex,
    AsyncValue<void>? Function()? saveOperation,
    File? Function()? cachedFile,
    int? Function()? fileSizeBytes,
    int? Function()? imageWidth,
    int? Function()? imageHeight,
  }) {
    return PhotoDetailState(
      photos: photos ?? this.photos,
      blogId: blogId ?? this.blogId,
      currentIndex: currentIndex ?? this.currentIndex,
      saveOperation: saveOperation != null
          ? saveOperation()
          : this.saveOperation,
      cachedFile: cachedFile != null ? cachedFile() : this.cachedFile,
      fileSizeBytes: fileSizeBytes != null
          ? fileSizeBytes()
          : this.fileSizeBytes,
      imageWidth: imageWidth != null ? imageWidth() : this.imageWidth,
      imageHeight: imageHeight != null ? imageHeight() : this.imageHeight,
    );
  }
}

/// 單張照片的元資料快取，包含快取檔案、檔案大小與圖片尺寸。
class _PhotoMetadata {
  /// 建立 [_PhotoMetadata]。
  ///
  /// - [cachedFile]：本機快取的照片檔案，預設為 `null`。
  /// - [fileSizeBytes]：照片檔案大小（bytes），預設為 `null`。
  /// - [imageWidth]：照片寬度（像素），預設為 `null`。
  /// - [imageHeight]：照片高度（像素），預設為 `null`。
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

/// 照片詳細頁面的 ViewModel，管理照片列表、當前索引、檔案元資料快取與儲存至相簿。
@riverpod
class PhotoDetailViewModel extends _$PhotoDetailViewModel {
  /// 照片索引對應的元資料快取，避免重複讀取檔案與解析圖片尺寸。
  final Map<int, _PhotoMetadata> _metadataCache = {};

  /// 初始化狀態，回傳預設的 [PhotoDetailState]。
  @override
  PhotoDetailState build() => const PhotoDetailState();

  /// 載入照片列表並讀取初始照片的檔案元資料。
  ///
  /// [photos] 為要載入的照片實體清單。
  /// [blogId] 為目前操作的 Blog 識別碼，用於查詢快取。
  /// [initialIndex] 為初始顯示的照片索引，會立即載入該照片的元資料。
  Future<void> loadAll(
    List<PhotoEntity> photos,
    String blogId,
    int initialIndex,
  ) async {
    _metadataCache.clear();
    state = state.copyWith(
      photos: photos,
      blogId: blogId,
      currentIndex: initialIndex,
      saveOperation: () => null,
    );

    await _loadMetadataForIndex(initialIndex);
    final meta = _metadataCache[initialIndex];
    state = state.copyWith(
      cachedFile: () => meta?.cachedFile,
      fileSizeBytes: () => meta?.fileSizeBytes,
      imageWidth: () => meta?.imageWidth,
      imageHeight: () => meta?.imageHeight,
    );
  }

  /// 切換當前顯示的照片索引。
  ///
  /// [index] 為目標照片在清單中的索引位置，超出範圍時不做任何處理。
  /// 若該索引的元資料尚未快取，會先非同步載入後再更新狀態。
  Future<void> setCurrentIndex(int index) async {
    if (index < 0 || index >= state.photos.length) return;
    state = state.copyWith(currentIndex: index, saveOperation: () => null);

    if (!_metadataCache.containsKey(index)) {
      await _loadMetadataForIndex(index);
    }

    final meta = _metadataCache[index];
    state = state.copyWith(
      cachedFile: () => meta?.cachedFile,
      fileSizeBytes: () => meta?.fileSizeBytes,
      imageWidth: () => meta?.imageWidth,
      imageHeight: () => meta?.imageHeight,
    );
  }

  /// 將目前照片儲存至裝置相簿，透過 [PhotoRepository.saveOneToGallery] 委派。
  Future<void> saveToGallery() async {
    if (state.cachedFile == null || state.isSaving) return;

    state = state.copyWith(saveOperation: () => const AsyncLoading());

    try {
      await ref
          .read(photoRepositoryProvider)
          .saveOneToGallery(state.cachedFile!.path);
      ref
          .read(logRepositoryProvider)
          .logSaveToGallery(
            blogId: state.blogId,
            photoCount: 1,
            mode: 'single',
          );
      state = state.copyWith(saveOperation: () => const AsyncData(null));
    } catch (_) {
      state = state.copyWith(saveOperation: () => null);
    }
  }

  /// 載入指定索引照片的元資料（快取檔案、檔案大小、圖片尺寸）。
  ///
  /// [index] 為目標照片在 [PhotoDetailState.photos] 中的索引位置。
  /// 若索引超出範圍或已存在於快取中，會直接返回不做處理。
  Future<void> _loadMetadataForIndex(int index) async {
    if (index < 0 || index >= state.photos.length) return;
    if (_metadataCache.containsKey(index)) return;

    final photo = state.photos[index];
    final file = await ref
        .read(cacheRepositoryProvider)
        .cachedFile(photo.filename, state.blogId);

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
