import 'package:pomelo/modules/music/model/models.dart';

import 'repository/subsonic_client.dart';
import 'repository/subsonic_music_service.dart';

/// Subsonic 音乐来源
///
/// 继承 [MusicSource]，代表一个已配置的 Subsonic 账号。
/// 每个账号提供 1 个 [SubsonicMusicService]。
class SubsonicSource extends MusicSource {
  /// 服务器地址
  final String serverUrl;

  /// 用户名
  final String username;

  /// 密码
  final String password;

  /// 可选的显示名称（默认使用 username）
  final String? _displayName;

  SubsonicClient? _client;
  SubsonicMusicService? _service;
  bool _initialized = false;

  SubsonicSource({
    required this.serverUrl,
    required this.username,
    required this.password,
    String? displayName,
  }) : _displayName = displayName;

  @override
  String get id => 'subsonic-${serverUrl.hashCode.abs()}-$username';

  @override
  String get name => _displayName ?? '$username@${_hostFromUrl(serverUrl)}';

  @override
  MusicSourceType get type => MusicSourceType.subsonic;

  @override
  List<MusicService> get services =>
      _service != null ? [_service!] : [];

  /// 内部的 Subsonic 客户端（可能为 null，初始化后才可用）
  SubsonicClient? get client => _client;

  /// 内部的 Subsonic 音乐服务（可能为 null）
  SubsonicMusicService? get service => _service;

  /// 是否已完成初始化
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async {
    if (_initialized) return;

    // 移除尾部斜杠
    final cleanUrl = serverUrl.replaceAll(RegExp(r'/+$'), '');
    _client = SubsonicClient(
      serverUrl: cleanUrl,
      username: username,
      password: password,
    );

    // 验证连接
    try {
      await _client!.ping();
    } catch (e) {
      print('SubsonicSource: 连接 $cleanUrl 失败: $e');
      _client = null;
      rethrow;
    }

    _service = SubsonicMusicService(
      client: _client!,
      serverUrl: cleanUrl,
      username: username,
      displayName: _displayName,
    );

    _initialized = true;
    print('SubsonicSource: 已连接 $name');
  }

  @override
  Future<void> dispose() async {
    _client?.dispose();
    _client = null;
    _service = null;
    _initialized = false;
  }

  /// 从 URL 中提取主机名
  static String _hostFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (_) {
      return url;
    }
  }
}
