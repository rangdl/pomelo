import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';

/// 添加 Subsonic 账号对话框
///
/// 包含服务器地址、用户名、密码三个必填字段，
/// 可选的显示名称字段。点击确定后尝试连接验证。
class AddSubsonicAccountDialog extends HookConsumerWidget {
  const AddSubsonicAccountDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrlController = useTextEditingController();
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final displayNameController = useTextEditingController();

    final isLoading = useState(false);
    final error = useState<String?>(null);

    Future<void> submit() async {
      final serverUrl = serverUrlController.text.trim();
      final username = usernameController.text.trim();
      final password = passwordController.text;

      if (serverUrl.isEmpty || username.isEmpty || password.isEmpty) {
        error.value = '服务器地址、用户名和密码为必填项';
        return;
      }

      isLoading.value = true;
      error.value = null;

      try {
        await ref.read(subsonicAccountsProvider.notifier).addAccount((
          serverUrl: serverUrl,
          username: username,
          password: password,
          displayName: displayNameController.text.trim().isEmpty
              ? null
              : displayNameController.text.trim(),
        ));
        if (context.mounted) Navigator.of(context).pop(true);
      } catch (e) {
        isLoading.value = false;
        error.value = e.toString().replaceFirst('StateError: ', '').replaceFirst('Exception: ', '');
      }
    }

    return AlertDialog(
      title: const Text('添加 Subsonic 账号'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: serverUrlController,
              placeholder: const Text('https://music.example.com'),
              onChanged: (_) => error.value != null ? error.value = null : null,
            ),
            const Gap(4),
            Text(
              '服务器地址',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(12),
            TextField(
              controller: usernameController,
              placeholder: const Text('用户名'),
              onChanged: (_) => error.value != null ? error.value = null : null,
            ),
            const Gap(4),
            Text(
              '用户名',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(12),
            TextField(
              controller: passwordController,
              placeholder: const Text('密码'),
              obscureText: true,
              onChanged: (_) => error.value != null ? error.value = null : null,
            ),
            const Gap(4),
            Text(
              '密码',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(12),
            TextField(
              controller: displayNameController,
              placeholder: const Text('显示名称（可选）'),
            ),
            const Gap(4),
            Text(
              '自定义显示名称，留空则使用 用户名@主机名',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            if (error.value != null) ...[
              const Gap(12),
              Text(
                error.value!,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.destructive,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        GhostButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        PrimaryButton(
          onPressed: isLoading.value ? null : submit,
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('连接并添加'),
        ),
      ],
    );
  }
}
