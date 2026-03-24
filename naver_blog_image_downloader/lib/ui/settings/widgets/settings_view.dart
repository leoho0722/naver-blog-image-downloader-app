import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:naver_blog_image_downloader/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../config/bottom_sheet_animation.dart';
import '../../../config/supported_locale.dart';
import '../../core/view_model/app_settings_view_model.dart';
import '../view_model/settings_view_model.dart';

/// 設定頁面，提供外觀模式切換、語系切換、快取管理介面與版本資訊。
class SettingsView extends StatefulWidget {
  /// 建立 [SettingsView]。
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with SingleTickerProviderStateMixin {
  /// 是否已完成初始載入（防止 [didChangeDependencies] 重複觸發）。
  bool _loaded = false;

  /// 語言選擇 bottom sheet 的動畫控制器。
  late final AnimationController _languageSheetController;

  /// 應用程式版本字串（例如「1.0.0 (1)」），從 PackageInfo 取得。
  String _version = '';

  /// 初始化語言選擇 Bottom Sheet 的動畫控制器。
  @override
  void initState() {
    super.initState();
    _languageSheetController = BottomSheetAnimation.createController(
      vsync: this,
      platform: defaultTargetPlatform,
    );
  }

  /// 釋放語言選擇 Bottom Sheet 的動畫控制器，避免記憶體洩漏。
  @override
  void dispose() {
    _languageSheetController.dispose();
    super.dispose();
  }

  /// 首次建構時載入快取資訊與應用程式版本，僅執行一次以避免重複觸發。
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        unawaited(context.read<SettingsViewModel>().loadCacheInfo());
        final info = await PackageInfo.fromPlatform();
        if (mounted) {
          setState(() {
            _version = '${info.version} (${info.buildNumber})';
          });
        }
      });
    }
  }

  /// 建構設定頁面，包含外觀模式、語言切換、快取管理與關於等區段。
  ///
  /// 回傳一個 [Widget]，為包含 [AppBar] 與 [ListView] 的 [Scaffold]。
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final appSettings = context.watch<AppSettingsViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.settingsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: viewModel.isClearing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // 外觀區段
                _buildSectionHeader(
                  l10n.settingsSectionAppearance,
                  textTheme,
                  colorScheme,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l10n.settingsThemeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l10n.settingsThemeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l10n.settingsThemeDark),
                      ),
                    ],
                    selected: {appSettings.themeMode},
                    onSelectionChanged: (selected) =>
                        appSettings.setThemeMode(selected.first),
                  ),
                ),
                // 語言區段
                _buildSectionHeader(
                  l10n.settingsSectionLanguage,
                  textTheme,
                  colorScheme,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: InkWell(
                    onTap: () => _showLanguageBottomSheet(context, appSettings),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (appSettings.locale ?? SupportedLocale.zhTW).label,
                            style: textTheme.bodyLarge,
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                // 快取區段
                _buildSectionHeader(
                  l10n.settingsSectionCache,
                  textTheme,
                  colorScheme,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card.filled(
                    child: ListTile(
                      title: Text(l10n.settingsCacheSizeLabel),
                      contentPadding: const EdgeInsets.only(
                        left: 16,
                        right: 12,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            viewModel.formattedCacheSize,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (viewModel.cachedBlogs.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.cleaning_services),
                              iconSize: 20,
                              color: colorScheme.error,
                              tooltip: l10n.settingsClearAllTooltip,
                              padding: const EdgeInsets.only(left: 4),
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  _showClearAllDialog(context, viewModel),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 關於區段
                _buildSectionHeader(
                  l10n.settingsSectionAbout,
                  textTheme,
                  colorScheme,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card.filled(
                    child: ListTile(
                      title: Text(l10n.settingsVersionLabel),
                      trailing: Text(
                        _version,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// 建立設定頁面的區段標題（如「外觀」、「語言」、「快取」、「關於」）。
  ///
  /// [title] 為區段標題文字。
  /// [textTheme] 為當前主題的文字樣式，用於套用 `titleSmall`。
  /// [colorScheme] 為當前主題的配色方案，用於套用 `onSurfaceVariant` 顏色。
  Widget _buildSectionHeader(
    String title,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 20, bottom: 8),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// 顯示「清除全部快取」確認對話框，使用者確認後執行清除操作。
  ///
  /// [context] 為當前的 BuildContext，用於開啟確認對話框。
  /// [viewModel] 為設定頁面的 ViewModel，用於執行清除快取與重新載入資訊。
  Future<void> _showClearAllDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsClearAllDialogTitle),
        content: Text(l10n.settingsClearAllDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await viewModel.clearAllCache();
    }
  }

  /// 從底部彈出語言選擇清單，使用者點選後立即切換語系。
  ///
  /// [context] 為當前的 BuildContext，用於開啟 Bottom Sheet。
  /// [appSettings] 為全域偏好設定的 ViewModel，用於讀取當前語系與執行切換。
  void _showLanguageBottomSheet(
    BuildContext context,
    AppSettingsViewModel appSettings,
  ) {
    final current = appSettings.locale ?? SupportedLocale.zhTW;
    showModalBottomSheet<SupportedLocale>(
      context: context,
      transitionAnimationController: _languageSheetController,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: SupportedLocale.values
                .map(
                  (e) => ListTile(
                    title: Text(e.label),
                    trailing: e == current ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(e),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ).then((selected) {
      if (selected != null) appSettings.setLocale(selected);
    });
  }
}
