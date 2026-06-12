import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/lx_script_paths_provider.dart';

/// 添加 Lx 脚本对话框
///
/// 通过文件选择器选取 .js 脚本文件，
/// 复制到应用内部存储后加载为音乐平台。
class AddLxScriptDialog extends ConsumerWidget {
  const AddLxScriptDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('添加 Lx 音乐脚本'),
      content: const SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.code, size: 48),
            Gap(16),
            Text('选择一个 .js 格式的 musicsdk 脚本文件。'),
            Gap(8),
            Text(
              '脚本加载后会自动检测注册的音乐平台（如腾讯、酷狗、网易等），并为每个平台创建对应的音乐服务。',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        GhostButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        PrimaryButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              dialogTitle: '选择 JS 脚本文件',
              type: FileType.custom,
              allowedExtensions: ['js'],
            );
            if (result == null || result.files.isEmpty) return;
            final pickedFile = result.files.first;
            if (pickedFile.path == null) return;

            // 复制到应用内部存储
            final appDir = await getApplicationSupportDirectory();
            final scriptsDir = Directory(p.join(appDir.path, 'lx_scripts'));
            if (!await scriptsDir.exists()) {
              await scriptsDir.create(recursive: true);
            }
            final destPath = p.join(
              scriptsDir.path,
              p.basename(pickedFile.path!),
            );
            await File(pickedFile.path!).copy(destPath);

            // 加载脚本
            await ref.read(lxScriptPathsProvider.notifier).addScript(destPath);
            if (context.mounted) Navigator.of(context).pop(true);
          },
          child: const Text('选择文件'),
        ),
      ],
    );
  }
}
