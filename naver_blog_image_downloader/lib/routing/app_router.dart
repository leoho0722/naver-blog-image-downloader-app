import 'package:go_router/go_router.dart';
import '../ui/blog_input/widgets/blog_input_view.dart';
import '../ui/photo_gallery/widgets/photo_gallery_view.dart';
import '../ui/photo_detail/widgets/photo_detail_view.dart';
import '../ui/settings/widgets/settings_view.dart';

/// 應用程式的路由設定，使用 [GoRouter] 定義所有頁面的路徑與對應 Widget。
///
/// 路由結構：
/// - `/` — Blog 網址輸入頁面（[BlogInputView]）
/// - `/download/:blogId` — 下載進度頁面（[DownloadView]）
/// - `/gallery/:blogId` — 照片瀏覽頁面（[PhotoGalleryView]）
/// - `/detail/:photoId` — 照片詳細頁面（[PhotoDetailView]）
/// - `/settings` — 設定頁面（[SettingsView]）
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BlogInputView(),
    ),
    GoRoute(
      path: '/gallery/:blogId',
      builder: (context, state) => PhotoGalleryView(
        blogId: state.pathParameters['blogId']!,
      ),
    ),
    GoRoute(
      path: '/detail/:photoId',
      builder: (context, state) => PhotoDetailView(
        photoId: state.pathParameters['photoId']!,
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsView(),
    ),
  ],
);
