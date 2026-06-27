import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/rx.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/modules/music_lx_server/providers/lx_server_providers.dart';

/// Lx Server 账号表单内容（桌面端对话框和移动端页面共享）
///
/// 包含服务器地址、用户名、密码三个必填字段。
/// 点击确定后尝试登录验证。
class _LxServerAccountContent extends HookConsumerWidget {
  const _LxServerAccountContent();

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
      final displayName = displayNameController.text.trim();

      if (serverUrl.isEmpty || username.isEmpty || password.isEmpty) {
        error.value = '服务器地址、用户名和密码为必填项';
        return;
      }

      isLoading.value = true;
      error.value = null;

      try {
        await ref.read(lxServerConnectionProvider.notifier).connect((
          serverUrl: serverUrl,
          username: username,
          password: password,
          displayName: displayName.isEmpty ? null : displayName,
        ));
        Rx.toast.success('连接成功');
        if (context.mounted) Navigator.of(context).pop(true);
      } catch (e) {
        isLoading.value = false;
        final msg = e
            .toString()
            .replaceFirst('StateError: ', '')
            .replaceFirst('Exception: ', '');
        error.value = msg;
        Rx.toast.error('连接失败: $msg');
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: serverUrlController,
          placeholder: const Text('http://127.0.0.1:3000'),
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
          placeholder: const Text('自定义显示名称，留空则使用 Lx Server'),
          onChanged: (_) => error.value != null ? error.value = null : null,
        ),
        const Gap(4),
        Text(
          '显示名称（可选）',
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
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GhostButton(
              onPressed: isLoading.value
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            const Gap(8),
            PrimaryButton(
              onPressed: isLoading.value ? null : submit,
              child: isLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('登录并连接'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 添加 Lx Server 账号对话框（桌面端使用）
class AddLxServerAccountDialog extends StatelessWidget {
  const AddLxServerAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加 Lx Server'),
      content: SizedBox(width: 400, child: const _LxServerAccountContent()),
    );
  }
}

/// 添加 Lx Server 账号页面（移动端使用）
class AddLxServerAccountPage extends StatelessWidget {
  const AddLxServerAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('添加 Lx Server'),
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
          child: SingleChildScrollView(child: _LxServerAccountContent()),
        ),
      ),
    );
  }
}
