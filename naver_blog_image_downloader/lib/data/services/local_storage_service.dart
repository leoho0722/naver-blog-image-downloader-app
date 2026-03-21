import 'package:shared_preferences/shared_preferences.dart';

/// 本機鍵值對儲存服務，封裝 [SharedPreferences] 提供簡潔的讀寫介面。
class LocalStorageService {
  /// 建立 [LocalStorageService]，需傳入已初始化的 [SharedPreferences] 實例。
  LocalStorageService({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  /// 讀取字串值，不存在時回傳 `null`。
  String? getString(String key) => _prefs.getString(key);

  /// 寫入字串值。
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  /// 讀取布林值，不存在時回傳 `null`。
  bool? getBool(String key) => _prefs.getBool(key);

  /// 寫入布林值。
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  /// 移除指定 key 的資料。
  Future<bool> remove(String key) => _prefs.remove(key);
}
