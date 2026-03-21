import 'dart:io';
import 'dart:typed_data';

import 'package:image_gallery_saver/image_gallery_saver.dart';

/// 系統相簿存取服務，使用 [ImageGallerySaver] 將照片存入相簿。
///
/// 透過 bytes 方式寫入，讓 iOS 系統自動產生 IMG_xxxx 檔名。
class GalleryService {
  /// 將指定路徑的圖片檔案儲存至系統相簿。
  ///
  /// 讀取檔案為 bytes 後透過 [ImageGallerySaver.saveImage] 存入，
  /// iOS 會自動指派 IMG_xxxx 格式的檔名。
  Future<void> saveToGallery(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(bytes),
      quality: 100,
    );

    if (result == null || result['isSuccess'] != true) {
      throw Exception('儲存至相簿失敗');
    }
  }

  /// 請求相簿存取權限。
  ///
  /// [ImageGallerySaver] 在儲存時會自動觸發權限請求，
  /// 此方法保留供需要預先請求權限的場景使用。
  Future<bool> requestPermission() async {
    // image_gallery_saver 在 saveImage 時自動請求權限，
    // 這裡回傳 true 表示可以繼續操作。
    return true;
  }
}
