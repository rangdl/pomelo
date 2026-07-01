import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/preferences/user_preference.dart';
import 'package:pomelo/core/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';

/// Subsonic 账号表单内容（桌面端对话框和移动端页面共享）
///
/// 包含服务器地址、用户名、密码三个必填字段，
/// 可选的显示名称字段。点击确定后尝试连接验证。
/// 传入 [initialConfig] 和 [sourceId] 时为编辑模式，字段预填充并调用更新方法。
///
/// 高级字段（token / salt / version / pathPrefix）默认折叠，
/// 用于支持 LX Music Sync Server 等非标准 Subsonic 服务。
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
    final tokenController = useTextEditingController(
      text: initialConfig?.token ?? '',
    );
    final saltController = useTextEditingController(
      text: initialConfig?.salt ?? '',
    );
    final versionController = useTextEditingController(
      text: initialConfig?.version ?? '',
    );
    final pathPrefixController = useTextEditingController(
      text: initialConfig?.pathPrefix ?? '',
    );

    final isLoading = useState(false);
    final error = useState<String?>(null);
    final showAdvanced = useState(false);
    final isEditing = initialConfig != null && sourceId != null;

    // 如果初始配置中已有 token/salt/pathPrefix/version，默认展开高级选项
    useEffect(() {
      if (initialConfig != null &&
          ((initialConfig!.token != null && initialConfig!.token!.isNotEmpty) ||
              (initialConfig!.salt != null && initialConfig!.salt!.isNotEmpty) ||
              (initialConfig!.pathPrefix != null &&
                  initialConfig!.pathPrefix != '/rest' &&
                  initialConfig!.pathPrefix!.isNotEmpty) ||
              (initialConfig!.version != null &&
                  initialConfig!.version!.isNotEmpty))) {
        showAdvanced.value = true;
      }
      return null;
    }, [initialConfig]);

    Future<void> submit() async {
      final serverUrl = serverUrlController.text.trim();
      final username = usernameController.text.trim();
      final password = passwordController.text;
      final displayName = displayNameController.text.trim().isEmpty
          ? null
          : displayNameController.text.trim();
      final token = tokenController.text.trim().isEmpty
          ? null
          : tokenController.text.trim();
      final salt = saltController.text.trim().isEmpty
          ? null
          : saltController.text.trim();
      final version = versionController.text.trim().isEmpty
          ? null
          : versionController.text.trim();
      // pathPrefix: 空字符串是合法值（用于 LX Music Sync Server），
      // 但用户未输入任何内容时视为 null（使用默认 '/rest'）
      final pathPrefixRaw = pathPrefixController.text;
      final pathPrefix = pathPrefixRaw.isEmpty ? null : pathPrefixRaw;

      if (serverUrl.isEmpty || username.isEmpty || password.isEmpty) {
        error.value = '服务器地址、用户名和密码为必填项';
        return;
      }
      // token/salt 必须同时提供
      if ((token != null && salt == null) || (token == null && salt != null)) {
        error.value = 'token 和 salt 必须同时提供，或同时留空';
        return;
      }

      isLoading.value = true;
      error.value = null;

      try {
        final config = (
          serverUrl: serverUrl,
          username: username,
          password: password,
          token: token,
          salt: salt,
          displayName: displayName,
          version: version,
          pathPrefix: pathPrefix,
        );
        if (isEditing) {
          await ref
              .read(subsonicAccountsProvider.notifier)
              .updateAccount(sourceId!, config);
        } else {
          await ref
              .read(subsonicAccountsProvider.notifier)
              .addAccount(config);
        }
        if (context.mounted) {
          Navigator.of(context).pop(true);
          AppToast().success(isEditing ? '已更新' : '账号添加成功');
        }
      } catch (e) {
        isLoading.value = false;
        final msg = e
            .toString()
            .replaceFirst('StateError: ', '')
            .replaceFirst('Exception: ', '');
        error.value = msg;
        AppToast().error(isEditing ? '更新失败: $msg' : '添加失败: $msg');
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
          '密码（与 token+salt 二选一）',
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
        const Gap(12),
        // 高级选项折叠区
        GestureDetector(
          onTap: () => showAdvanced.value = !showAdvanced.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                showAdvanced.value
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 18,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
              const Gap(4),
              Text(
                '高级选项',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        if (showAdvanced.value) ...[
          const Gap(12),
          TextField(
            controller: tokenController,
            placeholder: const Text('token（可选，与 salt 配对）'),
            onChanged: (_) => error.value != null ? error.value = null : null,
          ),
          const Gap(4),
          Text(
            '预计算 token，提供后无需密码',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const Gap(12),
          TextField(
            controller: saltController,
            placeholder: const Text('salt（可选，与 token 配对）'),
            onChanged: (_) => error.value != null ? error.value = null : null,
          ),
          const Gap(4),
          Text(
            '预计算 salt，必须与 token 同时提供',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const Gap(12),
          TextField(
            controller: versionController,
            placeholder: const Text('1.16.1'),
          ),
          const Gap(4),
          Text(
            'API 版本，默认 1.16.1',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const Gap(12),
          TextField(
            controller: pathPrefixController,
            placeholder: const Text('/rest'),
          ),
          const Gap(4),
          Text(
            'API 路径前缀，默认 /rest；LX Music Sync Server 等需留空',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
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
