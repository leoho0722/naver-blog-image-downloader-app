import 'package:flutter/material.dart';

/// 「版本新功能」或「首次安裝引導」中的單一功能項目。
///
/// [icon] 為功能圖示，[titleKey] 與 [descriptionKey] 為 l10n key 識別碼，
/// 由 View 層透過 switch 映射至 `AppLocalizations` 對應的 getter。
class WhatsNewFeature {
  /// 建立 [WhatsNewFeature]。
  ///
  /// [icon] 為功能圖示。
  /// [titleKey] 為標題的 l10n key 識別碼。
  /// [descriptionKey] 為描述的 l10n key 識別碼。
  const WhatsNewFeature({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });

  /// 功能圖示。
  final IconData icon;

  /// 標題的 l10n key 識別碼。
  final String titleKey;

  /// 描述的 l10n key 識別碼。
  final String descriptionKey;
}

/// 首次安裝時的操作引導步驟（固定 4 步驟）。
const onboardingSteps = <WhatsNewFeature>[
  WhatsNewFeature(
    icon: Icons.content_paste,
    titleKey: 'onboardingStep1Title',
    descriptionKey: 'onboardingStep1Desc',
  ),
  WhatsNewFeature(
    icon: Icons.photo_library,
    titleKey: 'onboardingStep2Title',
    descriptionKey: 'onboardingStep2Desc',
  ),
  WhatsNewFeature(
    icon: Icons.download,
    titleKey: 'onboardingStep3Title',
    descriptionKey: 'onboardingStep3Desc',
  ),
  WhatsNewFeature(
    icon: Icons.swipe,
    titleKey: 'onboardingStep4Title',
    descriptionKey: 'onboardingStep4Desc',
  ),
];

/// 各版本的新功能列表，key 為版本號（如 `'1.4.0'`）。
///
/// 每次發版時只需在此 Map 新增一筆 entry，
/// 並在 ARB 檔案中新增對應的 l10n key。
const whatsNewRegistry = <String, List<WhatsNewFeature>>{
  '1.4.0': [
    WhatsNewFeature(
      icon: Icons.auto_awesome,
      titleKey: 'whatsNew140Feature1Title',
      descriptionKey: 'whatsNew140Feature1Desc',
    ),
  ],
};
