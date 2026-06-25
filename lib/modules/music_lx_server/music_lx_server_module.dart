import 'dart:convert';

import 'package:pomelo/core/mars.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music_lx_server/repository/lx_server_client.dart';
import 'package:pomelo/modules/music_lx_server/repository/lx_server_music_service.dart';

/// Lx Server 音乐模块
///
/// 管理单个 lx-server 连接，提供登录鉴权和音乐数据服务。
/// 配置（服务器地址、用户名、密码、Token）持久化到 Settings，应用启动时自动恢复。
///
/// lx-server 是一个 HTTP API 服务，聚合了多个音乐平台（kg/kw/tx/mg/wy），
/// 通过一次登录即可访问所有平台的排行榜、歌单和播放链接。
class MusicLxServerModule extends Module {
  /// HTTP 客户端（连接后创建）
  LxServerClient? _client;

  /// 音乐服务实例（登录成功后创建）
  LxServerMusicService? _service;

  /// 原始配置（用于持久化）
  Map<String, dynamic>? _config;

  @override
  String get id => 'music_lx_server';

  @override
  String get displayName => 'Lx Server 音乐';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['music'];

  /// 当前音乐服务（可能为 null，未连接时）
  LxServerMusicService? get service => _service;

  /// 当前 HTTP 客户端（可能为 null）
  LxServerClient? get client => _client;

  /// 是否已连接
  bool get isConnected => _service != null;

  /// 当前配置信息
  ({String serverUrl, String username, String password})? get config {
    if (_config == null) return null;
    return (
      serverUrl: _config!['serverUrl'] as String,
      username: _config!['username'] as String,
      password: _config!['password'] as String,
    );
  }

  @override
  Future<void> onInit() async {
    // 从 Settings 读取已保存的配置并尝试连接
    final saved = LxServerClient.parseConfig(
      Settings.get(StorageKeys.musicLxServerConfig),
    );
    if (saved == null) return;
    await _connect(
      serverUrl: saved['serverUrl'] as String,
      username: saved['username'] as String,
      password: saved['password'] as String,
      token: saved['token'] as String?,
      silent: true,
    );
  }

  @override
  Future<void> onReady() async {
    final musicModule = ModuleManager().find<MusicModule>('music');
    if (musicModule == null || _service == null) return;
    musicModule.register(_service!);
  }

  @override
  Future<void> onDispose() async {
    _client?.dispose();
    _client = null;
    _service = null;
  }

  // ========== 连接管理 ==========

  /// 添加/连接 lx-server
  ///
  /// 登录验证成功后创建服务并注册到 MusicModule。
  /// 连接失败抛出异常。
  Future<LxServerMusicService> connect({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    // 若已有连接，先断开
    await disconnect();

    final service = await _connect(
      serverUrl: serverUrl,
      username: username,
      password: password,
      silent: false,
    );

    if (service == null) {
      throw StateError('无法连接到 lx-server: $serverUrl');
    }

    // 持久化配置
    _config = {
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'token': _client!.token,
    };
    await _saveConfig();

    // 如果模块已就绪，立即注册到 MusicModule
    if (isInitialized) {
      final musicModule = ModuleManager().find<MusicModule>('music');
      musicModule?.register(service);
    }

    return service;
  }

  /// 断开连接
  Future<void> disconnect() async {
    if (_service != null) {
      final musicModule = ModuleManager().find<MusicModule>('music');
      musicModule?.unregister(_service!.sourceId);
    }
    _client?.dispose();
    _client = null;
    _service = null;
    _config = null;
    await _saveConfig();
  }

  /// 创建并初始化连接
  ///
  /// [silent] 为 true 时，连接失败只打印日志不抛异常。
  Future<LxServerMusicService?> _connect({
    required String serverUrl,
    required String username,
    required String password,
    String? token,
    required bool silent,
  }) async {
    final cleanUrl = serverUrl.replaceAll(RegExp(r'/+$'), '');
    final client = LxServerClient(
      serverUrl: cleanUrl,
      username: username,
      password: password,
      token: token,
    );

    try {
      // 如果有保存的 Token，先验证；无效则重新登录
      if (token != null && token.isNotEmpty) {
        final valid = await client.verifyToken();
        if (!valid) {
          await client.login();
        }
      } else {
        await client.login();
      }
    } catch (e) {
      log.error('LxServer', '连接 $username@$cleanUrl 失败: $e', error: e);
      if (!silent) rethrow;
      return null;
    }

    final sourceId = 'lx-server-${cleanUrl.hashCode.abs()}';
    final service = LxServerMusicService(
      client: client,
      sourceId: sourceId,
      sourceName: 'Lx Server',
    );

    _client = client;
    _service = service;
    _config = {
      'serverUrl': cleanUrl,
      'username': username,
      'password': password,
      'token': client.token,
    };
    log.info('LxServer', '已连接 $username@$cleanUrl');
    return service;
  }

  // ========== 配置持久化 ==========

  /// 保存配置到 Settings
  Future<void> _saveConfig() async {
    await Settings.set(
      StorageKeys.musicLxServerConfig,
      _config != null ? jsonEncode(_config) : '',
    );
  }

  /// 从 Settings 读取配置
  static Map<String, dynamic>? loadConfig() {
    return LxServerClient.parseConfig(
      Settings.get(StorageKeys.musicLxServerConfig),
    );
  }
}
