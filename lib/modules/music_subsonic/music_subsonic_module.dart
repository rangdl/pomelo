import 'dart:convert';

import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/music_module.dart';

import 'subsonic_source.dart';

/// Settings key: Subsonic 账号配置列表（JSON 数组字符串）
const _kSubsonicAccounts = 'music_subsonic_accounts';

/// Subsonic 音乐模块
///
/// 管理多个 Subsonic 账号，每个账号对应一个 [SubsonicSource]。
/// 账号配置持久化到 Settings，应用启动时自动恢复。
class MusicSubsonicModule extends Module {
  /// 已配置的账号来源列表
  final List<SubsonicSource> _sources = [];

  @override
  String get id => 'music_subsonic';

  @override
  String get displayName => 'Subsonic 音乐';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['music'];

  /// 已配置的来源列表（只读）
  List<SubsonicSource> get sources => List.unmodifiable(_sources);

  @override
  Future<void> onInit() async {
    // 从 Settings 读取已保存的账号配置并尝试连接
    final configs = loadAccountConfigs();
    for (final config in configs) {
      await _createSource(
        serverUrl: config['serverUrl'] as String,
        username: config['username'] as String,
        password: config['password'] as String,
        displayName: config['displayName'] as String?,
        silent: true, // 静默模式：连接失败不抛异常
      );
    }
  }

  @override
  Future<void> onReady() async {
    final musicModule = ModuleManager().find<MusicModule>('music');
    if (musicModule == null) return;
    // 将所有来源注册到 MusicModule
    for (final source in _sources) {
      if (source.isInitialized) {
        await musicModule.addSource(source);
      }
    }
  }

  @override
  Future<void> onDispose() async {
    for (final source in _sources) {
      await source.dispose();
    }
    _sources.clear();
  }

  /// 添加 Subsonic 账号
  ///
  /// 创建来源、验证连接，并注册到 MusicModule。
  /// 连接成功返回来源实例，失败抛出异常。
  Future<SubsonicSource> addAccount({
    required String serverUrl,
    required String username,
    required String password,
    String? displayName,
  }) async {
    // 检查是否已存在相同账号
    final existingId = 'subsonic-${serverUrl.hashCode.abs()}-$username';
    if (_sources.any((s) => s.id == existingId)) {
      throw StateError('该 Subsonic 账号已存在: $username@$serverUrl');
    }

    final source = await _createSource(
      serverUrl: serverUrl,
      username: username,
      password: password,
      displayName: displayName,
      silent: false,
    );

    if (source == null) {
      throw StateError('无法连接到 Subsonic 服务器: $serverUrl');
    }

    // 如果模块已就绪，立即注册到 MusicModule
    if (isInitialized) {
      final musicModule = ModuleManager().find<MusicModule>('music');
      await musicModule?.addSource(source);
    }

    await _saveAccountConfigs();
    return source;
  }

  /// 移除 Subsonic 账号
  Future<void> removeAccount(String sourceId) async {
    final idx = _sources.indexWhere((s) => s.id == sourceId);
    if (idx == -1) return;

    final source = _sources.removeAt(idx);
    await source.dispose();

    // 从 MusicModule 注销
    final musicModule = ModuleManager().find<MusicModule>('music');
    await musicModule?.removeSource(sourceId);

    await _saveAccountConfigs();
  }

  /// 创建并初始化来源
  ///
  /// [silent] 为 true 时，连接失败只打印日志不抛异常。
  Future<SubsonicSource?> _createSource({
    required String serverUrl,
    required String username,
    required String password,
    String? displayName,
    required bool silent,
  }) async {
    final source = SubsonicSource(
      serverUrl: serverUrl,
      username: username,
      password: password,
      displayName: displayName,
    );

    try {
      await source.init();
      _sources.add(source);
      return source;
    } catch (e) {
      print('MusicSubsonicModule: 账号 $username@$serverUrl 连接失败: $e');
      if (!silent) rethrow;
      return null;
    }
  }

  // ========== 配置持久化 ==========

  /// 保存账号配置到 Settings
  Future<void> _saveAccountConfigs() async {
    final configs = _sources
        .map((s) => {
              'serverUrl': s.serverUrl,
              'username': s.username,
              'password': s.password,
              'displayName': null,
            })
        .toList();
    await Settings.set(_kSubsonicAccounts, jsonEncode(configs));
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
