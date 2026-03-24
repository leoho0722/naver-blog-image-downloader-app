import 'package:flutter/foundation.dart';

import '../../../data/models/blog_cache_metadata.dart';
import '../../../data/repositories/cache_repository.dart';

/// 設定頁面的 ViewModel，負責快取資訊查詢與清除操作。
class SettingsViewModel extends ChangeNotifier {
  /// 建立 [SettingsViewModel]，需注入 [CacheRepository] 以查詢與管理快取。
  SettingsViewModel({required CacheRepository cacheRepository})
    : _cacheRepository = cacheRepository;

  /// 注入的快取 Repository，用於查詢快取大小與執行清除操作。
  final CacheRepository _cacheRepository;

  /// 目前快取佔用的磁碟空間大小（bytes）。
  int _cacheSizeBytes = 0;

  /// 所有已快取 Blog 的 metadata 清單。
  List<BlogCacheMetadata> _cachedBlogs = [];

  /// 是否正在執行清除快取操作。
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
}
