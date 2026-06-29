import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/preferences/user_preference.dart';
import 'package:pomelo/core/rx.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';

/// Subsonic 账号表单内容（桌面端对话框和移动端页面共享）
///
/// 包含服务器地址、用户名、密码三个必填字段，
/// 可选的显示名称字段。点击确定后尝试连接验证。
/// 传入 [initialConfig] 和 [sourceId] 时为编辑模式，字段预填充并调用更新方法。
class _SubsonicAccountContent extends HookConsumerWidget {
  /// 编辑模式时传入的初始配置
  final SubsonicAccountConfig? initialConfig;

  /// 编辑模式时传入的 sourceId（用于定位待更新账号）
  final String? sourceId;

  const _SubsonicAccountContent({this.initialConfig, this.sourceId});

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
      text: initialConfig?.displayName ?? '',
    );

    final isLoading = useState(false);
    final error = useState<String?>(null);
    final isEditing = initialConfig != null && sourceId != null;

    Future<void> submit() async {
      final serverUrl = serverUrlController.text.trim();
      final username = usernameController.text.trim();
      final password = passwordController.text;
      final displayName = displayNameController.text.trim().isEmpty
          ? null
          : displayNameController.text.trim();

      if (serverUrl.isEmpty || username.isEmpty || password.isEmpty) {
        error.value = '服务器地址、用户名和密码为必填项';
        return;
      }

      isLoading.value = true;
      error.value = null;

      try {
        final config = (
          serverUrl: serverUrl,
          username: username,
          password: password,
          displayName: displayName,
        );
        if (isEditing) {
          await ref
              .read(subsonicAccountsProvider.notifier)
              .updateAccount(sourceId!, config);
          Rx.toast.success('已更新');
        } else {
          await ref
              .read(subsonicAccountsProvider.notifier)
              .addAccount(config);
          Rx.toast.success('账号添加成功');
        }
        if (context.mounted) Navigator.of(context).pop(true);
      } catch (e) {
        isLoading.value = false;
        final msg = e
            .toString()
            .replaceFirst('StateError: ', '')
            .replaceFirst('Exception: ', '');
        error.value = msg;
        Rx.toast.error(isEditing ? '更新失败: $msg' : '添加失败: $msg');
      }
    }

    return Column(
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
                  : Text(isEditing ? '保存' : '连接并添加'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 添加 Subsonic 账号对话框（桌面端使用）
class AddSubsonicAccountDialog extends StatelessWidget {
  /// 编辑模式时传入的初始配置
  final SubsonicAccountConfig? initialConfig;

  /// 编辑模式时传入的 sourceId
  final String? sourceId;

  const AddSubsonicAccountDialog({
    super.key,
    this.initialConfig,
    this.sourceId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        initialConfig != null ? '编辑 Subsonic 账号' : '添加 Subsonic 账号',
      ),
      content: SizedBox(
        width: 400,
        child: _SubsonicAccountContent(
          initialConfig: initialConfig,
          sourceId: sourceId,
        ),
      ),
    );
  }
}

/// 添加 Subsonic 账号页面（移动端使用）
class AddSubsonicAccountPage extends StatelessWidget {
  /// 编辑模式时传入的初始配置
  final SubsonicAccountConfig? initialConfig;

  /// 编辑模式时传入的 sourceId
  final String? sourceId;

  const AddSubsonicAccountPage({
    super.key,
    this.initialConfig,
    this.sourceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text(
            initialConfig != null ? '编辑 Subsonic 账号' : '添加 Subsonic 账号',
          ),
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
            child: _SubsonicAccountContent(
              initialConfig: initialConfig,
              sourceId: sourceId,
            ),
          ),
        ),
      ),
    );
  }
}
