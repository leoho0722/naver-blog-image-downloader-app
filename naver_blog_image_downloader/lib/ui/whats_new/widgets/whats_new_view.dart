import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../view_model/whats_new_view_model.dart';
import 'whats_new_dialog.dart';

/// 顯示「新功能介紹」或「首次安裝引導」的全螢幕 Dialog。
///
/// 根據 [whatsNewState] 的類型決定 Dialog 標題與內容：
/// - [WhatsNewOnboarding]：標題為「歡迎使用」，內容為操作引導步驟。
/// - [WhatsNewUpdate]：標題為「v{version} 新功能」，內容為新功能列表。
///
/// [context] 為 `BuildContext`，用於取得 l10n 資源與顯示 Dialog。
/// [whatsNewState] 為當前的顯示狀態（[WhatsNewOnboarding] 或 [WhatsNewUpdate]）。
Future<void> showWhatsNewDialog(
  BuildContext context,
  WhatsNewState whatsNewState,
) {
  final l10n = AppLocalizations.of(context);

  final String title;
  final features = switch (whatsNewState) {
    WhatsNewOnboarding(:final steps) => steps,
    WhatsNewUpdate(:final features) => features,
    WhatsNewHidden() => <Never>[],
  };

  title = switch (whatsNewState) {
    WhatsNewOnboarding() => l10n.whatsNewOnboardingTitle,
    WhatsNewUpdate(:final version) => l10n.whatsNewTitle(version),
    WhatsNewHidden() => '',
  };

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => WhatsNewDialog(
      title: title,
      features: features,
      dismissLabel: l10n.whatsNewDismissButton,
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}
