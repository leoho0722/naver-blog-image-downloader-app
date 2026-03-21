import 'package:flutter/foundation.dart';

import '../../../data/models/blog_cache_metadata.dart';
import '../../../data/repositories/cache_repository.dart';

/// 設定頁面的 ViewModel，負責快取資訊查詢與清除操作。
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required CacheRepository cacheRepository})
      : _cacheRepository = cacheRepository;

  final CacheRepository _cacheRepository;

  int _cacheSizeBytes = 0;
  List<BlogCacheMetadata> _cachedBlogs = [];
  bool _isClearing = false;

  /// 快取總大小（bytes）。
  int get cacheSizeBytes => _cacheSizeBytes;

  /// 所有已快取 Blog 的 metadata 清單。
  List<BlogCacheMetadata> get cachedBlogs => _cachedBlogs;

  /// 是否正在執行清除操作。
  bool get isClearing => _isClearing;

  /// 人類可讀的快取大小字串（MB 為單位，保留一位小數）。
  String get formattedCacheSize =>
      '${(_cacheSizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';

  /// 載入快取資訊，包含總大小與各 Blog metadata。
  Future<void> loadCacheInfo() async {
    _cacheSizeBytes = await _cacheRepository.totalCacheSize();
    _cachedBlogs = await _cacheRepository.allMetadata();
    notifyListeners();
  }

  /// 清除所有快取檔案與 metadata。
  Future<void> clearAllCache() async {
    _isClearing = true;
    notifyListeners();

    await _cacheRepository.clearAll();

    _isClearing = false;
    _cacheSizeBytes = 0;
    _cachedBlogs = [];
    notifyListeners();
  }

  /// 清除指定 Blog 的快取檔案與 metadata，完成後重新載入快取資訊。
  Future<void> clearBlogCache(String blogId) async {
    await _cacheRepository.clearBlog(blogId);
    await loadCacheInfo();
  }
}
