import 'package:flutter/foundation.dart';

import '../player/audio_player_service.dart';
import '../plugins/plugin_store.dart';
import '../runtime/musicfree_runtime.dart';

/// 全局应用状态：插件仓库 + 当前选中的插件运行时 + 播放器。
///
/// 运行时是**懒创建**的：只有真正搜索/播放时才建 QuickJS 实例，
/// 并且同一时间只保留一个，避免多个引擎占内存。
class AppState extends ChangeNotifier {
  late PluginStore pluginStore;
  final AudioPlayerService player = AudioPlayerService();

  /// 当前正在使用的插件运行时（null 表示尚未创建）
  MusicFreeRuntime? _runtime;
  String? _runtimePluginId;

  bool ready = false;
  String? initError;

  /// 当前播放的歌曲信息（用于 UI 展示）
  Map<String, dynamic>? nowPlaying;
  String? nowPlayingUrl;

  Future<void> init() async {
    try {
      pluginStore = await PluginStore.open();
      ready = true;
    } catch (e) {
      initError = '$e';
    }
    notifyListeners();
  }

  /// 取指定插件对应的运行时，必要时创建并切换。
  Future<MusicFreeRuntime> runtimeFor(PluginRecord plugin) async {
    if (_runtime != null && _runtimePluginId == plugin.id) {
      return _runtime!;
    }
    _runtime?.dispose();
    final rt = await MusicFreeRuntime.create();
    rt.loadPlugin(plugin.source, name: plugin.platform);
    _runtime = rt;
    _runtimePluginId = plugin.id;
    return rt;
  }

  /// 用某个插件搜索。
  Future<List<Map<String, dynamic>>> search(
    PluginRecord plugin,
    String query,
  ) async {
    final rt = await runtimeFor(plugin);
    final result = await rt.search(query);
    final data = (result['data'] as List).cast<dynamic>();
    return data
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((e) => {...e, '_pluginId': plugin.id, '_platform': plugin.platform})
        .toList();
  }

  /// 解析播放地址并播放。
  Future<void> playItem(PluginRecord plugin, Map<String, dynamic> item) async {
    final rt = await runtimeFor(plugin);
    final source = await rt.getMediaSource(
      Map<String, dynamic>.from(item)
        ..remove('_pluginId')
        ..remove('_platform'),
      'standard',
    );
    if (source == null || source['url'] is! String) {
      throw StateError('插件未返回可播放地址');
    }
    final headers = <String, String>{};
    final rawHeaders = source['headers'];
    if (rawHeaders is Map) {
      rawHeaders.forEach((k, v) => headers['$k'] = '$v');
    }
    nowPlaying = item;
    nowPlayingUrl = source['url'] as String;
    notifyListeners();
    await player.open(nowPlayingUrl!, headers: headers);
  }

  @override
  void dispose() {
    _runtime?.dispose();
    player.dispose();
    super.dispose();
  }
}
