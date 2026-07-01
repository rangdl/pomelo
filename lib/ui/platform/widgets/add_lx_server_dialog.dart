import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/core/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/modules/music_lx_server/providers/lx_server_providers.dart';

/// Lx Server 账号表单内容（桌面端对话框和移动端页面共享）
///
/// 包含服务器地址、用户名、密码三个必填字段。
/// 点击确定后尝试登录验证。
/// 传入 [initialConfig] 时为编辑模式，字段预填充。
class _LxServerAccountContent extends HookConsumerWidget {
  final LxServerConfig? initialConfig;

  const _LxServerAccountContent({this.initialConfig});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrlController = useTextEditingController(
      text: initialConfig?.serverUrl ?? '',
    );
    final usernameController = useTextEditingController(
      text: initialConfig?.username ?? '',
    );
    final passwordController = useTextEditingController(
      text: initialConfig?.password ?? '',
    );
    final displayNameController = useTextEditingController(
      text: initialConfig?.name ?? '',
    );

    final isLoading = useState(false);
    final error = useState<String?>(null);
    final isEditing = initialConfig != null;
    final proxyPlayback = useState(initialConfig?.proxyPlayback ?? false);
    final allowSourceSwitching = useState(
      initialConfig?.allowSourceSwitching ?? false,
    );

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
          name: displayName.isEmpty ? 'Lx Server' : displayName,
          proxyPlayback: proxyPlayback.value,
          allowSourceSwitching: allowSourceSwitching.value,
        ));
        if (context.mounted) {
          Navigator.of(context).pop(true);
          AppToast().success(isEditing ? '已更新' : '连接成功');
        }
      } catch (e) {
        isLoading.value = false;
        final msg = e
            .toString()
            .replaceFirst('StateError: ', '')
            .replaceFirst('Exception: ', '');
        error.value = msg;
        AppToast().error(isEditing ? '更新失败: $msg' : '连接失败: $msg');
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
        const Gap(12),
        Switch(
          value: proxyPlayback.value,
          onChanged: (v) => proxyPlayback.value = v,
        ),
        const Gap(4),
        Text(
          '代理播放：开启后通过服务器代理获取音频流，适用于 CDN 直链无法直接访问的场景',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
        const Gap(12),
        Switch(
          value: allowSourceSwitching.value,
          onChanged: (v) => allowSourceSwitching.value = v,
        ),
        const Gap(4),
        Text(
          '允许换源：开启后当所有音质的播放链接获取失败时，自动搜索其他库并切换到匹配的新源重新获取',
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
                  : Text(isEditing ? '保存' : '登录并连接'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 添加 Lx Server 账号对话框（桌面端使用）
class AddLxServerAccountDialog extends StatelessWidget {
  /// 编辑模式时传入的初始配置
  final LxServerConfig? initialConfig;

  const AddLxServerAccountDialog({super.key, this.initialConfig});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(initialConfig != null ? '编辑 Lx Server' : '添加 Lx Server'),
      content: SizedBox(
        width: 400,
        child: _LxServerAccountContent(initialConfig: initialConfig),
      ),
    );
  }
}

/// 添加 Lx Server 账号页面（移动端使用）
class AddLxServerAccountPage extends StatelessWidget {
  /// 编辑模式时传入的初始配置
  final LxServerConfig? initialConfig;

  const AddLxServerAccountPage({super.key, this.initialConfig});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text(initialConfig != null ? '编辑 Lx Server' : '添加 Lx Server'),
          leading: [
            IconButton.text(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: _LxServerAccountContent(initialConfig: initialConfig),
          ),
        ),
      ),
    );
  }
}
