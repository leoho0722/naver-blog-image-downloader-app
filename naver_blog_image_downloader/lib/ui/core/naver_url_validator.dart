/// Naver Blog URL 驗證工具，僅接受 HTTPS 協定的電腦版與手機版網址。
abstract final class NaverUrlValidator {
  static final _pattern = RegExp(r'^https://(m\.)?blog\.naver\.com/');

  /// 驗證 [url] 是否為合法的 Naver Blog 網址。
  static bool isValid(String url) => _pattern.hasMatch(url);
}
