import 'package:flutter_test/flutter_test.dart';
import 'package:naver_blog_image_downloader/ui/core/naver_url_validator.dart';

void main() {
  group('NaverUrlValidator', () {
    test('電腦版 HTTPS URL 為合法', () {
      expect(
        NaverUrlValidator.isValid('https://blog.naver.com/example_post'),
        isTrue,
      );
    });

    test('手機版 HTTPS URL 為合法', () {
      expect(
        NaverUrlValidator.isValid('https://m.blog.naver.com/example_post'),
        isTrue,
      );
    });

    test('HTTP URL 為不合法（不安全）', () {
      expect(
        NaverUrlValidator.isValid('http://blog.naver.com/example_post'),
        isFalse,
      );
    });

    test('非 Naver URL 為不合法', () {
      expect(
        NaverUrlValidator.isValid('https://example.com/some-page'),
        isFalse,
      );
    });

    test('空字串為不合法', () {
      expect(NaverUrlValidator.isValid(''), isFalse);
    });

    test('非 URL 純文字為不合法', () {
      expect(NaverUrlValidator.isValid('hello world'), isFalse);
    });
  });
}
