import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pomelo/modules/music_lx/model/js_engine.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// JsEngine 测试页面
@RoutePage()
class JsEngineTestView extends HookWidget {
  const JsEngineTestView({super.key});

  @override
  Widget build(BuildContext context) {
    final jsEngine = useMemoized(() => JsEngine());
    useEffect(() => jsEngine.dispose, const []);

    // MD5
    final md5Controller = useTextEditingController(text: 'hello');
    final md5Result = useState('');

    // SHA256
    final sha256Controller = useTextEditingController(text: 'hello');
    final sha256Result = useState('');

    // AES
    final aesDataController = useTextEditingController(text: '48656c6c6f');
    final aesModeController = useTextEditingController(text: 'aes-128-cbc');
    final aesKeyController = useTextEditingController(
      text: '6368616e676520746869732070617373',
    );
    final aesIvController = useTextEditingController(
      text: '31323334353637383132333435363738',
    );
    final aesResult = useState('');

    void testMd5() {
      final result = jsEngine.jsRuntime.evaluate(
        "__go_crypto_md5('${md5Controller.text}')",
      );
      md5Result.value = result.rawResult.toString();
    }

    void testSha256() {
      final result = jsEngine.jsRuntime.evaluate(
        "__go_crypto_sha256('${sha256Controller.text}')",
      );
      sha256Result.value = result.rawResult.toString();
    }

    void testAesEncrypt() {
      final js =
          """
__go_crypto_aes_encrypt(
  '${aesDataController.text}',
  '${aesModeController.text}',
  '${aesKeyController.text}',
  '${aesIvController.text}'
)
""";
      final result = jsEngine.jsRuntime.evaluate(js);
      aesResult.value = result.rawResult.toString();
    }

    void stringToHex() {
      final controller = aesDataController;
      final text = controller.text;
      if (text.isEmpty) return;
      try {
        int.parse(text, radix: 16);
        showToast(
          context: context,
          builder: (ctx, overlay) => const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('已是 hex 格式'),
                  Text('无需转换', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        );
      } catch (_) {
        final hex = utf8
            .encode(text)
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join();
        controller.text = hex;
      }
    }

    return Scaffold(
      headers: [AppBar(title: const Text('JsEngine 测试'))],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── MD5 ──
          Text('MD5 哈希'),
          const Gap(8),
          TextField(
            controller: md5Controller,
            placeholder: const Text('输入字符串'),
          ),
          const Gap(8),
          Row(
            children: [
              PrimaryButton(onPressed: testMd5, child: const Text('计算 MD5')),
              const Gap(12),
              if (md5Result.value.isNotEmpty)
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: SelectableText(md5Result.value),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(),
          const Gap(16),

          // ── SHA256 ──
          Text('SHA256 哈希'),
          const Gap(8),
          TextField(
            controller: sha256Controller,
            placeholder: const Text('输入字符串'),
          ),
          const Gap(8),
          Row(
            children: [
              PrimaryButton(
                onPressed: testSha256,
                child: const Text('计算 SHA256'),
              ),
              const Gap(12),
              if (sha256Result.value.isNotEmpty)
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: SelectableText(sha256Result.value),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(),
          const Gap(16),

          // ── AES ──
          Text('AES 加密'),
          const Gap(8),
          TextField(
            controller: aesDataController,
            placeholder: const Text('数据 (hex)'),
            features: [
              InputFeature.trailing(
                GhostButton(onPressed: stringToHex, child: const Text('转Hex')),
              ),
            ],
          ),
          const Gap(8),
          TextField(
            controller: aesModeController,
            placeholder: const Text('模式 (例: aes-128-cbc)'),
          ),
          const Gap(8),
          TextField(
            controller: aesKeyController,
            placeholder: const Text('密钥 (hex)'),
          ),
          const Gap(8),
          TextField(
            controller: aesIvController,
            placeholder: const Text('IV (hex，ECB模式留空)'),
          ),
          const Gap(12),
          Row(
            children: [
              PrimaryButton(
                onPressed: testAesEncrypt,
                child: const Text('AES 加密'),
              ),
              const Gap(12),
              if (aesResult.value.isNotEmpty)
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: SelectableText(aesResult.value),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
