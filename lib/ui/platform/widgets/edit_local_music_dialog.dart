import 'package:file_picker/file_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';
import 'package:pomelo/modules/music_local/local_music_providers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 本地音乐服务编辑内容（桌面端对话框和移动端页面共享）
///
/// 包含服务名称字段和目录列表管理（添加/删除/重新扫描）。
/// 缓存目录作为默认目录展示，并标注为"缓存目录"。
class _EditLocalMusicContent extends HookConsumerWidget {
  const _EditLocalMusicContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(
      text: ref.read(userPreferenceProvider).localServerName,
    );
    final dirs = useState<List<String>>(
      ref.read(userPreferenceProvider).localDirectories,
    );
    final cacheDir = useState<String?>(null);
    final trackCount = ref.watch(localMusicSongCountProvider);

    // 加载缓存目录路径用于标注
    useEffect(() {
      Future.microtask(() async {
        try {
          cacheDir.value = await MusicCacheDir.getOrCreate();
        } catch (_) {}
      });
      return null;
    }, const []);

    Future<void> addDirectory() async {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择音乐目录',
      );
      if (result == null) return;
      if (dirs.value.contains(result)) {
        Rx.toast.info('该目录已添加');
        return;
      }
      dirs.value = [...dirs.value, result];
    }

    Future<void> submit() async {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        Rx.toast.error('服务名称不能为空');
        return;
      }

      // 更新名称
      await ref.read(userPreferenceProvider.notifier).setLocalServerName(name);

      // 同步目录变更：对比新增/删除
      final currentDirs = ref.read(userPreferenceProvider).localDirectories;
      final newDirs = dirs.value;

      // 删除被移除的目录
      for (final dir in currentDirs) {
        if (!newDirs.contains(dir)) {
          ref.read(localMusicDirsProvider.notifier).removeDirectory(dir);
        }
      }
      // 添加新增的目录
      for (final dir in newDirs) {
        if (!currentDirs.contains(dir)) {
          await ref.read(localMusicDirsProvider.notifier).addDirectory(dir);
        }
      }

      Rx.toast.success('已保存');
      if (context.mounted) Navigator.of(context).pop(true);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 服务名称
        TextField(
          controller: nameController,
          placeholder: const Text('本地音乐'),
        ),
        const Gap(4),
        Text(
          '服务名称',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
        const Gap(16),

        // 目录列表标题
        Row(
          children: [
            Text(
              '音乐目录',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(8),
            Text(
              '已扫描 $trackCount 首',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Spacer(),
            GhostButton(
              size: ButtonSize.small,
              onPressed: addDirectory,
              leading: const Icon(Icons.add, size: 16),
              child: const Text('添加目录'),
            ),
          ],
        ),
        const Gap(8),

        // 目录列表
        if (dirs.value.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                '暂无目录，点击"添加目录"',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: dirs.value.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final dir = dirs.value[index];
                final isCacheDir =
                    cacheDir.value != null && dir == cacheDir.value;
                return ListTile(
                  leading: Icon(
                    isCacheDir ? Icons.cached : Icons.folder,
                    size: 20,
                  ),
                  title: Text(
                    isCacheDir ? '缓存目录' : p.basename(dir),
                  ),
                  subtitle: Text(
                    dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                  trailing: IconButton.text(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      dirs.value = dirs.value
                          .where((d) => d != dir)
                          .toList();
                    },
                  ),
                );
              },
            ),
          ),

        const Gap(8),
        Row(
          children: [
            GhostButton(
              size: ButtonSize.small,
              leading: const Icon(Icons.refresh, size: 16),
              onPressed: () async {
                await ref.read(localMusicDirsProvider.notifier).rescanAll();
                if (context.mounted) Rx.toast.success('已重新扫描');
              },
              child: const Text('重新扫描'),
            ),
          ],
        ),

        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GhostButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            const Gap(8),
            PrimaryButton(
              onPressed: submit,
              child: const Text('保存'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 编辑本地音乐服务对话框（桌面端使用）
class EditLocalMusicDialog extends StatelessWidget {
  const EditLocalMusicDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑本地音乐'),
      content: SizedBox(
        width: 480,
        child: const _EditLocalMusicContent(),
      ),
    );
  }
}

/// 编辑本地音乐服务页面（移动端使用）
class EditLocalMusicPage extends StatelessWidget {
  const EditLocalMusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('编辑本地音乐'),
          leading: [
            IconButton.text(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: _EditLocalMusicContent(),
          ),
        ),
      ),
    );
  }
}
