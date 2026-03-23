import 'package:flutter/material.dart';

import '../view_model/photo_detail_view_model.dart';

/// 照片詳細頁面底部的膠囊型操作列，提供「檔案資訊」與「儲存至相簿」兩個按鈕。
///
/// 儲存按鈕會依據 [saveState] 自動切換圖示：
/// - [SaveState.idle]：顯示下載圖示，可點擊
/// - [SaveState.saving]：顯示載入中動畫，不可點擊
/// - [SaveState.saved]：顯示打勾圖示，不可點擊
class PhotoDetailCapsuleBar extends StatelessWidget {
  /// 建立 [PhotoDetailCapsuleBar]。
  const PhotoDetailCapsuleBar({
    super.key,
    required this.onInfoTap,
    required this.onSaveTap,
    required this.saveState,
  });

  /// 使用者點擊「檔案資訊」按鈕時觸發的回呼。
  final VoidCallback onInfoTap;

  /// 使用者點擊「儲存至相簿」按鈕時觸發的回呼；儲存中或已儲存時為 `null`。
  final VoidCallback? onSaveTap;

  /// 目前的儲存操作狀態，用於決定儲存按鈕的圖示與是否可點擊。
  final SaveState saveState;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onInfoTap,
              icon: const Icon(Icons.info_outline),
            ),
            const VerticalDivider(),
            IconButton(
              onPressed: saveState == SaveState.idle ? onSaveTap : null,
              icon: _buildSaveIcon(),
            ),
          ],
        ),
      ),
    );
  }

  /// 依據 [saveState] 建立對應的儲存按鈕圖示。
  Widget _buildSaveIcon() {
    switch (saveState) {
      case SaveState.saving:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SaveState.saved:
        return const Icon(Icons.check);
      case SaveState.idle:
        return const Icon(Icons.save_alt);
    }
  }
}
