import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/metadata/music_server.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/modules/music_local/local_music_providers.dart';
import 'package:pomelo/modules/music_lx_server/providers/lx_server_providers.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';

/// 按 configId 懒创建 MusicServer 实例
///
/// 读取 [musicServerConfigsProvider] 获取配置，
/// 根据配置类型分发到对应的初始化逻辑：
/// - [LocalMusicConfig] → [localMusicServerProvider]
/// - [LxServerConfig] → [lxServerMusicServerProvider]
/// - [SubsonicConfig] → [subsonicServerProvider]
///
/// 仅在需要时初始化对应服务，不在启动时全量初始化。
/// 配置变化时自动重建。
final musicServerProvider = FutureProvider.family<MusicServer?, String>((
  ref,
  configId,
) async {
  final configs = await ref.watch(musicServerConfigsProvider.future);
  final config = configs.where((c) => c.id == configId).firstOrNull;
  if (config == null) return null;

  switch (config) {
    case LocalMusicConfig():
      return await ref.watch(localMusicServerProvider.future);
    case LxServerConfig():
      return await ref.watch(lxServerMusicServerProvider.future);
    case SubsonicConfig():
      return await ref.watch(subsonicServerProvider(configId).future);
  }
});
