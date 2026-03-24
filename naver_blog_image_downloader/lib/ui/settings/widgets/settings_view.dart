import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../view_model/settings_view_model.dart';

/// 設定頁面，提供快取管理介面與版本資訊。
class SettingsView extends StatefulWidget {
  /// 建立 [SettingsView]。
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  /// 是否已完成初始載入（防止 [didChangeDependencies] 重複觸發）。
  bool _loaded = false;

  /// 應用程式版本字串（例如「1.0.0 (1)」），從 PackageInfo 取得。
  String _version = '';

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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('設定'),
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
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 20, bottom: 8),
                  child: Text(
                    '快取',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card.filled(
                    child: ListTile(
                      title: const Text('快取大小'),
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
                              tooltip: '清除所有快取',
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
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 20, bottom: 8),
                  child: Text(
                    '關於',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card.filled(
                    child: ListTile(
                      title: const Text('版本'),
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

  /// 顯示「清除全部快取」確認對話框，使用者確認後執行清除操作。
  ///
  /// [context] 為當前的 BuildContext，用於開啟確認對話框。
  /// [viewModel] 為設定頁面的 ViewModel，用於執行清除快取與重新載入資訊。
  Future<void> _showClearAllDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除全部快取'),
        content: const Text('確定要清除所有已快取的照片嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('確認'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await viewModel.clearAllCache();
    }
  }
}
