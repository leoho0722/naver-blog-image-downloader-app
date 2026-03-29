import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 照片詳細頁面底部的膠囊型操作列，提供「檔案資訊」與「儲存至相簿」兩個按鈕。
///
/// 儲存按鈕會依據 [saveOperation] 自動切換圖示：
/// - `null`（閒置）：顯示下載圖示，可點擊
/// - [AsyncLoading]：顯示載入中動畫，不可點擊
/// - [AsyncData]：顯示打勾圖示，不可點擊
class PhotoDetailCapsuleBar extends StatelessWidget {
  /// 建立 [PhotoDetailCapsuleBar]。
  ///
  /// [onInfoTap] 為點擊「檔案資訊」按鈕時的回呼。
  /// [onSaveTap] 為點擊「儲存至相簿」按鈕時的回呼，儲存中或已儲存時為 `null`。
  /// [saveOperation] 為目前的儲存操作非同步狀態。
  const PhotoDetailCapsuleBar({
    super.key,
    required this.onInfoTap,
    required this.onSaveTap,
    required this.saveOperation,
  });

  /// 使用者點擊「檔案資訊」按鈕時觸發的回呼。
  final VoidCallback onInfoTap;

  /// 使用者點擊「儲存至相簿」按鈕時觸發的回呼；儲存中或已儲存時為 `null`。
  final VoidCallback? onSaveTap;

  /// 目前的儲存操作非同步狀態，用於決定儲存按鈕的圖示與是否可點擊。
  final AsyncValue<void>? saveOperation;

  /// 建構膠囊型操作列的 Widget 樹。
  ///
  /// [context] 為目前的 [BuildContext]，用於取得主題配色方案。
  ///
  /// 回傳包含「檔案資訊」與「儲存至相簿」按鈕的膠囊型 [Widget]。
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
              onPressed: saveOperation == null ? onSaveTap : null,
              icon: _buildSaveIcon(),
            ),
          ],
        ),
      ),
    );
  }

  /// 依據 [saveOperation] 建立對應的儲存按鈕圖示。
  ///
  /// 回傳載入中動畫、打勾圖示或下載圖示的 [Widget]。
  Widget _buildSaveIcon() {
    return switch (saveOperation) {
      AsyncLoading() => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      AsyncData() => const Icon(Icons.check),
      _ => const Icon(Icons.save_alt),
    };
  }
}
