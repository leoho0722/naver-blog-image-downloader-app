import 'package:flutter/material.dart';

import '../../../config/whats_new_registry.dart';
import '../../../l10n/app_localizations.dart';

/// 共用的圓角 Dialog 元件，顯示新功能介紹或首次安裝引導。
///
/// [title] 為 Dialog 頂部標題文字。
/// [features] 為功能項目列表，每項包含圖示、標題與描述。
/// [dismissLabel] 為底部關閉按鈕的文字。
/// [onDismiss] 為使用者點擊關閉按鈕時的回呼。
class WhatsNewDialog extends StatelessWidget {
  /// 建立 [WhatsNewDialog]。
  ///
  /// [title] 為 Dialog 標題。
  /// [features] 為功能項目列表。
  /// [dismissLabel] 為關閉按鈕文字。
  /// [onDismiss] 為關閉回呼。
  const WhatsNewDialog({
    required this.title,
    required this.features,
    required this.dismissLabel,
    required this.onDismiss,
    super.key,
  });

  /// Dialog 頂部標題文字。
  final String title;

  /// 功能項目列表。
  final List<WhatsNewFeature> features;

  /// 底部關閉按鈕的文字。
  final String dismissLabel;

  /// 使用者點擊關閉按鈕時的回呼。
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      feature.icon,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _resolveL10n(l10n, feature.titleKey),
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _resolveL10n(l10n, feature.descriptionKey),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onDismiss,
                child: Text(dismissLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 將 l10n key 識別碼映射至 [AppLocalizations] 的本地化字串。
///
/// [l10n] 為當前語系的本地化資源。
/// [key] 為 [WhatsNewFeature] 中的 titleKey 或 descriptionKey。
///
/// 回傳對應的本地化字串，無法匹配時回傳 [key] 本身。
String _resolveL10n(AppLocalizations l10n, String key) {
  return switch (key) {
    'onboardingStep1Title' => l10n.onboardingStep1Title,
    'onboardingStep1Desc' => l10n.onboardingStep1Desc,
    'onboardingStep2Title' => l10n.onboardingStep2Title,
    'onboardingStep2Desc' => l10n.onboardingStep2Desc,
    'onboardingStep3Title' => l10n.onboardingStep3Title,
    'onboardingStep3Desc' => l10n.onboardingStep3Desc,
    'onboardingStep4Title' => l10n.onboardingStep4Title,
    'onboardingStep4Desc' => l10n.onboardingStep4Desc,
    'whatsNew140Feature1Title' => l10n.whatsNew140Feature1Title,
    'whatsNew140Feature1Desc' => l10n.whatsNew140Feature1Desc,
    _ => key,
  };
}
