import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/settings_view_model.dart';

/// 設定頁面，提供快取管理介面，包含快取大小顯示、Blog 列表與清除功能。
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<SettingsViewModel>().loadCacheInfo();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

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
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '快取大小：${viewModel.formattedCacheSize}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.tonal(
                    onPressed: viewModel.cachedBlogs.isEmpty
                        ? null
                        : () => _showClearAllDialog(context, viewModel),
                    child: const Text('清除全部快取'),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.cachedBlogs.length,
                    itemBuilder: (context, index) {
                      final blog = viewModel.cachedBlogs[index];
                      return ListTile(
                        title: Text(blog.blogUrl),
                        subtitle: Text('${blog.photoCount} 張照片'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: '清除此 Blog 快取',
                          onPressed: () => _showClearBlogDialog(
                            context,
                            viewModel,
                            blog.blogId,
                            blog.blogUrl,
                          ),
                        ),
                      );
                    },
                  ),
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
    if (confirmed == true) {
      await viewModel.clearAllCache();
    }
  }

  Future<void> _showClearBlogDialog(
    BuildContext context,
    SettingsViewModel viewModel,
    String blogId,
    String blogUrl,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除 Blog 快取'),
        content: Text('確定要清除「$blogUrl」的快取照片嗎？此操作無法復原。'),
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
    if (confirmed == true) {
      await viewModel.clearBlogCache(blogId);
    }
  }
}
