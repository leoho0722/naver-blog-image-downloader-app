import 'package:flutter_test/flutter_test.dart';
import 'package:naver_blog_image_downloader/app.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const NaverPhotoApp());
  });
}
