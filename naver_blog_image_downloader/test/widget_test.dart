import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naver_blog_image_downloader/app.dart';
import 'package:naver_blog_image_downloader/data/repositories/cache_repository.dart';
import 'package:naver_blog_image_downloader/data/repositories/photo_repository.dart';
import 'package:naver_blog_image_downloader/data/services/api_service.dart';
import 'package:naver_blog_image_downloader/data/services/file_download_service.dart';
import 'package:naver_blog_image_downloader/data/services/gallery_service.dart';
import 'package:naver_blog_image_downloader/ui/blog_input/view_model/blog_input_view_model.dart';
import 'package:naver_blog_image_downloader/ui/download/view_model/download_view_model.dart';
import 'package:naver_blog_image_downloader/ui/photo_detail/view_model/photo_detail_view_model.dart';
import 'package:naver_blog_image_downloader/ui/photo_gallery/view_model/photo_gallery_view_model.dart';
import 'package:naver_blog_image_downloader/ui/settings/view_model/settings_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    final apiService = ApiService();
    final fileDownloadService = FileDownloadService(Dio());
    final galleryService = GalleryService();
    final cacheRepository = CacheRepository();
    final photoRepository = PhotoRepository(
      apiService: apiService,
      fileDownloadService: fileDownloadService,
      galleryService: galleryService,
      cacheRepository: cacheRepository,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: apiService),
          Provider.value(value: fileDownloadService),
          Provider.value(value: galleryService),
          Provider.value(value: cacheRepository),
          Provider.value(value: photoRepository),
          ChangeNotifierProvider(
            create: (_) => BlogInputViewModel(photoRepository: photoRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => DownloadViewModel(photoRepository: photoRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => PhotoGalleryViewModel(
              photoRepository: photoRepository,
              cacheRepository: cacheRepository,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => PhotoDetailViewModel(
              cacheRepository: cacheRepository,
              galleryService: galleryService,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => SettingsViewModel(cacheRepository: cacheRepository),
          ),
        ],
        child: const NaverPhotoApp(),
      ),
    );
  });
}
