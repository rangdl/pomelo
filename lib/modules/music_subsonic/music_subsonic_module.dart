import 'dart:convert';

import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/music_module.dart';

import 'repository/subsonic_client.dart';
import 'repository/subsonic_music_service.dart';

/// Settings key: Subsonic 账号配置列表（JSON 数组字符串）
const _kSubsonicAccounts = 'music_subsonic_accounts';

/// Subsonic 音乐模块
///
/// 管理多个 Subsonic 账号，每个账号对应一个 [SubsonicMusicService]。
/// 账号配置持久化到 Settings，应用启动时自动恢复。
///
/// 每个 Subsonic 服务直接注册到 [MusicModule]，
/// 最多可注册 10 个账号（[SubsonicMusicService.maxServiceCount] = 10）。
class MusicSubsonicModule extends Module {
  /// 已配置的服务及其客户端
  final List<({SubsonicClient client, SubsonicMusicService service})> _accounts = [];

  /// 原始账号配置（用于持久化，保留 serverUrl/username/password）
  final List<Map<String, dynamic>> _configs = [];

  @override
  String get id => 'music_subsonic';

  @override
  String get displayName => 'Subsonic 音乐';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['music'];

  /// 已配置的服务列表（只读）
  List<SubsonicMusicService> get services =>
      _accounts.map((a) => a.service).toList();

  @override
  Future<void> onInit() async {
    // 从 Settings 读取已保存的账号配置并尝试连接
    final configs = loadAccountConfigs();
    for (final config in configs) {
      final account = await _createAccount(
        serverUrl: config['serverUrl'] as String,
        username: config['username'] as String,
        password: config['password'] as String,
        displayName: config['displayName'] as String?,
        silent: true, // 静默模式：连接失败不抛异常
      );
      if (account != null) {
        _configs.add(config);
      }
    }
  }

  @override
  Future<void> onReady() async {
    final musicModule = ModuleManager().find<MusicModule>('music');
    if (musicModule == null) return;
    // 将所有服务注册到 MusicModule
    for (final account in _accounts) {
      musicModule.register(account.service);
    }
  }

  @override
  Future<void> onDispose() async {
    for (final account in _accounts) {
      account.client.dispose();
    }
    _accounts.clear();
  }

  /// 添加 Subsonic 账号
  ///
  /// 创建客户端、验证连接，并注册到 MusicModule。
  /// 连接成功返回服务实例，失败抛出异常。
  Future<SubsonicMusicService> addAccount({
    required String serverUrl,
    required String username,
    required String password,
    String? displayName,
  }) async {
    // 检查是否已存在相同账号
    final existingId = 'subsonic-${serverUrl.hashCode.abs()}-$username';
    if (_accounts.any((a) => a.service.sourceId == existingId)) {
      throw StateError('该 Subsonic 账号已存在: $username@$serverUrl');
    }

    final account = await _createAccount(
      serverUrl: serverUrl,
      username: username,
      password: password,
      displayName: displayName,
      silent: false,
    );

    if (account == null) {
      throw StateError('无法连接到 Subsonic 服务器: $serverUrl');
    }

    // 如果模块已就绪，立即注册到 MusicModule
    if (isInitialized) {
      final musicModule = ModuleManager().find<MusicModule>('music');
      musicModule?.register(account.service);
    }

    _configs.add({
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'displayName': displayName,
    });
    await _saveAccountConfigs();
    return account.service;
  }

  /// 移除 Subsonic 账号
  Future<void> removeAccount(String sourceId) async {
    final idx = _accounts.indexWhere((a) => a.service.sourceId == sourceId);
    if (idx == -1) return;

    final account = _accounts.removeAt(idx);
    account.client.dispose();

    // 从 MusicModule 注销
    final musicModule = ModuleManager().find<MusicModule>('music');
    musicModule?.unregister(sourceId);

    _configs.removeWhere((c) {
      final id = 'subsonic-${(c['serverUrl'] as String).hashCode.abs()}-${c['username']}';
      return id == sourceId;
    });
    await _saveAccountConfigs();
  }

  /// 创建并初始化账号
  ///
  /// [silent] 为 true 时，连接失败只打印日志不抛异常。
  Future<({SubsonicClient client, SubsonicMusicService service})?> _createAccount({
    required String serverUrl,
    required String username,
    required String password,
    String? displayName,
    required bool silent,
  }) async {
    final cleanUrl = serverUrl.replaceAll(RegExp(r'/+$'), '');
    final client = SubsonicClient(
      serverUrl: cleanUrl,
      username: username,
      password: password,
    );

    try {
      await client.ping();
    } catch (e) {
      print('MusicSubsonicModule: 账号 $username@$cleanUrl 连接失败: $e');
      if (!silent) rethrow;
      return null;
    }

    final service = SubsonicMusicService(
      client: client,
      serverUrl: cleanUrl,
      username: username,
      displayName: displayName,
    );

    final account = (client: client, service: service);
    _accounts.add(account);
    print('MusicSubsonicModule: 已连接 ${service.sourceName}');
    return account;
  }

  // ========== 配置持久化 ==========

  /// 保存账号配置到 Settings
  Future<void> _saveAccountConfigs() async {
    await Settings.set(_kSubsonicAccounts, jsonEncode(_configs));
  }

  /// 从 Settings 读取账号配置列表
  static List<Map<String, dynamic>> loadAccountConfigs() {
    final json = Settings.get(_kSubsonicAccounts);
    if (json == null) return [];
    try {
      return (jsonDecode(json) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
