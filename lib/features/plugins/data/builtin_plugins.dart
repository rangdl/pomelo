import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../shared/logging/app_logger.dart';
import '../../../shared/settings/settings_store.dart';
import '../data/plugin_repository.dart';

/// 一个随包内置的插件：assets 路径 + 稳定标识（用于区分来源与记录版本）。
class BuiltinPlugin {
  const BuiltinPlugin({required this.assetPath, required this.fallbackName});

  /// 打包进 assets 的源码路径。
  final String assetPath;

  /// 探针失败时的兜底显示名（一般用文件名去掉扩展名）。
  final String fallbackName;
}

/// 随包内置的插件清单。
///
/// 这些文件同时被 `pubspec.yaml` 的 assets 声明，构建时会打进 APK。
/// 首次启动（或清单版本变化时）由 [seedBuiltinPlugins] 自动安装进插件仓库，
/// 让用户开箱即有可用音源，无需手动「从文件安装」。
const List<BuiltinPlugin> builtinPlugins = [
  // LX 兼容脚本
  BuiltinPlugin(
    assetPath: 'scripts/xinghai-music-sourcev2.3.19.js',
    fallbackName: 'xinghai-music-source',
  ),
  BuiltinPlugin(
    assetPath: 'scripts/lx-aggregate-backend.js',
    fallbackName: 'lx-aggregate-backend',
  ),
  BuiltinPlugin(
    assetPath: 'scripts/lx-test-source.js',
    fallbackName: 'lx-test-source',
  ),
  // 自有格式（MusicFree 适配）
  BuiltinPlugin(
    assetPath: 'scripts/xinghai-music-source-qs-v1.3.0.js',
    fallbackName: 'xinghai-music-source-qs',
  ),
  BuiltinPlugin(
    assetPath: 'scripts/musicfree-plugins/fengsui-kg.js',
    fallbackName: 'fengsui-kg',
  ),
  BuiltinPlugin(
    assetPath: 'scripts/musicfree-plugins/fengsui-kw.js',
    fallbackName: 'fengsui-kw',
  ),
  BuiltinPlugin(
    assetPath: 'scripts/musicfree-plugins/fengsui-qq.js',
    fallbackName: 'fengsui-qq',
  ),
  BuiltinPlugin(
    assetPath: 'scripts/musicfree-plugins/fengsui-wy.js',
    fallbackName: 'fengsui-wy',
  ),
  // 咪咕（补全 LX 5 平台中的 mg 元数据源）
  BuiltinPlugin(
    assetPath: 'scripts/musicfree-plugins/migu.js',
    fallbackName: 'migu',
  ),
];

/// 内置插件清单版本号：修改 [builtinPlugins] 后请递增，
/// 已装老版本的用户下次启动会重新预装一次。
const int _builtinSeedVersion = 5;
const String _seedVersionKey = 'builtinPluginsSeedVersion';

/// 首次启动（或内置清单升级后）把内置插件安装进插件仓库。
///
/// 幂等：以 settings 中记录的 [ _builtinSeedVersion ] 做闸门，本版本已跑过则直接跳过。
/// 单个插件安装失败不影响其它插件；整体不抛出，避免阻断启动。
Future<void> seedBuiltinPlugins(
  PluginRepository repo,
  SettingsStore settings,
) async {
  if ((settings.read<int>(_seedVersionKey) ?? 0) >= _builtinSeedVersion) {
    return;
  }

  var installed = 0;
  for (final plugin in builtinPlugins) {
    try {
      final source = await rootBundle.loadString(plugin.assetPath);
      if (source.trim().isEmpty) {
        AppLogger.instance.warn('plugin.seed', '内置插件为空: ${plugin.assetPath}');
        continue;
      }
      final record = await repo.install(
        source,
        fallbackName: plugin.fallbackName,
      );
      installed++;
      debugPrint(
        '[pomelo] seed 已预装: ${record.platform} <- ${plugin.assetPath}',
      );
      AppLogger.instance.info(
        'plugin.seed',
        '已预装内置插件: ${record.platform}（来自 ${plugin.assetPath}）',
      );
    } catch (e, s) {
      debugPrint('[pomelo] seed 预装失败: ${plugin.assetPath} -> $e');
      AppLogger.instance.error(
        'plugin.seed',
        '预装内置插件失败: ${plugin.assetPath}',
        e,
        s,
      );
    }
  }

  await settings.patch({_seedVersionKey: _builtinSeedVersion});
  debugPrint('[pomelo] seed 完成: $installed/${builtinPlugins.length}');
}
