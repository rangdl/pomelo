import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show ListTile;
import 'package:pomelo/modules/music_lx/model/js_engine.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// JsEngine 测试页面
@RoutePage()
class JsEngineTestView extends StatefulWidget {
  const JsEngineTestView({super.key});

  @override
  State<JsEngineTestView> createState() => _JsEngineTestViewState();
}

class _JsEngineTestViewState extends State<JsEngineTestView> {
  late final JsEngine _jsEngine;

  // MD5
  final _md5Controller = TextEditingController(text: 'hello');
  String _md5Result = '';

  // SHA256
  final _sha256Controller = TextEditingController(text: 'hello');
  String _sha256Result = '';

  // AES
  final _aesDataController = TextEditingController(
    text: '48656c6c6f',
  ); // "Hello" in hex
  final _aesModeController = TextEditingController(text: 'aes-128-cbc');
  final _aesKeyController = TextEditingController(
    text: '6368616e676520746869732070617373',
  );
  final _aesIvController = TextEditingController(
    text: '31323334353637383132333435363738',
  );
  String _aesResult = '';

  @override
  void initState() {
    super.initState();
    _jsEngine = JsEngine();
  }

  @override
  void dispose() {
    _jsEngine.dispose();
    _md5Controller.dispose();
    _sha256Controller.dispose();
    _aesDataController.dispose();
    _aesModeController.dispose();
    _aesKeyController.dispose();
    _aesIvController.dispose();
    super.dispose();
  }

  void _testMd5() {
    final result = _jsEngine.jsRuntime.evaluate(
      "__go_crypto_md5('${_md5Controller.text}')",
    );
    setState(() => _md5Result = result.rawResult.toString());
  }

  void _testSha256() {
    final result = _jsEngine.jsRuntime.evaluate(
      "__go_crypto_sha256('${_sha256Controller.text}')",
    );
    setState(() => _sha256Result = result.rawResult.toString());
  }

  void _testAesEncrypt() {
    final js =
        """
__go_crypto_aes_encrypt(
  '${_aesDataController.text}',
  '${_aesModeController.text}',
  '${_aesKeyController.text}',
  '${_aesIvController.text}'
)
""";
    final result = _jsEngine.jsRuntime.evaluate(js);
    setState(() => _aesResult = result.rawResult.toString());
  }

  void _stringToHex() {
    // 辅助工具：将字符串转 hex，方便填入 dataHex
    final controller = _aesDataController; // 直接操作 AES data 输入框
    final text = controller.text;
    if (text.isEmpty) return;
    try {
      // 如果已经是 hex 就不转了
      int.parse(text, radix: 16);
      showToast(
        context: context,
        builder: (ctx, overlay) => const Card(
          child: ListTile(title: Text('已是 hex 格式'), subtitle: Text('无需转换')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [AppBar(title: const Text('JsEngine 测试'))],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── MD5 ──
          Text('MD5 哈希'),
          const Gap(8),
          TextField(
            controller: _md5Controller,
            placeholder: const Text('输入字符串'),
          ),
          const Gap(8),
          Row(
            children: [
              PrimaryButton(onPressed: _testMd5, child: const Text('计算 MD5')),
              const Gap(12),
              if (_md5Result.isNotEmpty)
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: SelectableText(_md5Result),
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
            controller: _sha256Controller,
            placeholder: const Text('输入字符串'),
          ),
          const Gap(8),
          Row(
            children: [
              PrimaryButton(
                onPressed: _testSha256,
                child: const Text('计算 SHA256'),
              ),
              const Gap(12),
              if (_sha256Result.isNotEmpty)
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: SelectableText(_sha256Result),
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
            controller: _aesDataController,
            placeholder: const Text('数据 (hex)'),
            // trailing: GhostButton(
            //   onPressed: _stringToHex,
            //   child: const Text('转Hex'),
            // ),
            features: [
              InputFeature.trailing(
                GhostButton(onPressed: _stringToHex, child: const Text('转Hex')),
              ),
            ],
          ),
          const Gap(8),
          TextField(
            controller: _aesModeController,
            placeholder: const Text('模式 (例: aes-128-cbc)'),
          ),
          const Gap(8),
          TextField(
            controller: _aesKeyController,
            placeholder: const Text('密钥 (hex)'),
          ),
          const Gap(8),
          TextField(
            controller: _aesIvController,
            placeholder: const Text('IV (hex，ECB模式留空)'),
          ),
          const Gap(12),
          Row(
            children: [
              PrimaryButton(
                onPressed: _testAesEncrypt,
                child: const Text('AES 加密'),
              ),
              const Gap(12),
              if (_aesResult.isNotEmpty)
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: SelectableText(_aesResult),
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
