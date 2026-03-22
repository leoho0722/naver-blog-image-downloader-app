import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../view_model/settings_view_model.dart';

/// 設定頁面，提供快取管理介面與版本資訊。
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _loaded = false;
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

    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
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
                CupertinoListSection.insetGrouped(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  header: const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Text('快取'),
                  ),
                  children: [
                    CupertinoListTile(
                      title: const Text('快取大小', style: TextStyle(fontSize: 18)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            viewModel.formattedCacheSize,
                            style: const TextStyle(fontSize: 18),
                          ),
                          if (viewModel.cachedBlogs.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  _showClearAllDialog(context, viewModel),
                              child: Icon(
                                Icons.cleaning_services,
                                size: 20,
                                color: CupertinoColors.systemRed.resolveFrom(
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CupertinoListSection.insetGrouped(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  header: const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text('關於'),
                  ),
                  children: [
                    CupertinoListTile(
                      title: const Text('版本', style: TextStyle(fontSize: 18)),
                      additionalInfo: Text(
                        _version,
                        style: const TextStyle(fontSize: 18),
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

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
