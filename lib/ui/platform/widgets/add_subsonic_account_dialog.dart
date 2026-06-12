import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';

/// 添加 Subsonic 账号对话框
///
/// 包含服务器地址、用户名、密码三个必填字段，
/// 可选的显示名称字段。点击确定后尝试连接验证。
class AddSubsonicAccountDialog extends ConsumerStatefulWidget {
  const AddSubsonicAccountDialog({super.key});

  @override
  ConsumerState<AddSubsonicAccountDialog> createState() =>
      _AddSubsonicAccountDialogState();
}

class _AddSubsonicAccountDialogState
    extends ConsumerState<AddSubsonicAccountDialog> {
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final serverUrl = _serverUrlController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (serverUrl.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() => _error = '服务器地址、用户名和密码为必填项');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(subsonicAccountsProvider.notifier).addAccount((
        serverUrl: serverUrl,
        username: username,
        password: password,
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('StateError: ', '').replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加 Subsonic 账号'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _serverUrlController,
              placeholder: const Text('https://music.example.com'),
              onChanged: (_) => _error != null ? setState(() => _error = null) : null,
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
              controller: _usernameController,
              placeholder: const Text('用户名'),
              onChanged: (_) => _error != null ? setState(() => _error = null) : null,
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
              controller: _passwordController,
              placeholder: const Text('密码'),
              obscureText: true,
              onChanged: (_) => _error != null ? setState(() => _error = null) : null,
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
              controller: _displayNameController,
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
            if (_error != null) ...[
              const Gap(12),
              Text(
                _error!,
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
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        PrimaryButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
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
