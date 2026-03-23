/// Naver Blog 網址驗證工具。
///
/// 僅接受 HTTPS 協定的電腦版（`blog.naver.com`）與
/// 手機版（`m.blog.naver.com`）網址格式。
abstract final class NaverUrlValidator {
  /// 用來比對 Naver Blog 網址的正規表達式，支援電腦版與手機版。
  static final _pattern = RegExp(r'^https://(m\.)?blog\.naver\.com/');

  /// 驗證 [url] 是否為合法的 Naver Blog 網址。
  ///
  /// 合法範例：
  /// - `https://blog.naver.com/example/12345`
  /// - `https://m.blog.naver.com/example/12345`
  static bool isValid(String url) => _pattern.hasMatch(url);
}
