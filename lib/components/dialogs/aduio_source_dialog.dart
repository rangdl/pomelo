import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AudioSourceDialog extends HookConsumerWidget {
  const AudioSourceDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final http = useState('');
    return AlertDialog(
      title: const Text('在线导入自定义源'),
      content: TextField(
        placeholder: const Text('请输入HTTP链接'),
        onChanged: (value) => http.value = value,
      ),
      actions: [
        Button.outline(
          onPressed: () {
            Navigator.pop(context, http.value);
          },
          child: const Text('取消'),
        ),
        Button.primary(
          onPressed: () {
            Navigator.pop(context, '');
          },
          child: const Text('导入'),
        ),
      ],
    );
  }
}
