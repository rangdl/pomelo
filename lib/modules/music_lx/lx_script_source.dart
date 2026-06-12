import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pomelo/modules/music/model/models.dart';
import 'model/lx_music_service.dart';
import 'providers/musicsdk_provider.dart';

/// Lx 脚本来源
///
/// 每个 JS 脚本文件对应一个 [LxScriptSource] 实例。
/// 加载脚本后自动检测注册了哪些平台，
/// 并为每个平台创建对应的 [LxMusicService]。
class LxScriptSource extends MusicSource {
  /// 脚本文件路径
  final String scriptPath;

  /// 共享的 JS 引擎（由 LxMusicModule 统一管理）
  final LxJsEngine jsEngine;

  /// 脚本标识（基于文件名生成）
  final String scriptId;

  /// 该脚本注册的平台信息列表（加载后填充）
  List<({String id, String name})> _platforms = [];

  /// 该脚本提供的服务列表
  List<LxMusicService> _services = [];

  /// 是否已初始化
  bool _isInitialized = false;

  LxScriptSource({
    required this.scriptPath,
    required this.jsEngine,
  }) : scriptId = _deriveScriptId(scriptPath);

  @override
  String get id => 'lx-script-$scriptId';

  @override
  String get name => p.basenameWithoutExtension(scriptPath);

  @override
  MusicSourceType get type => MusicSourceType.lx;

  @override
  List<MusicService> get services => List.unmodifiable(_services);

  /// 该脚本注册的平台信息列表
  List<({String id, String name})> get platforms =>
      List.unmodifiable(_platforms);

  /// 是否已完成初始化
  bool get isInitialized => _isInitialized;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final file = File(scriptPath);
    if (!await file.exists()) {
      print('LxScriptSource: 脚本文件不存在 $scriptPath');
      return;
    }
    final content = await file.readAsString();
    _platforms = await jsEngine.loadScriptWithSources(content);
    _services = _platforms
        .map(
          (p) => LxMusicService(
            jsEngine: jsEngine,
            scriptId: scriptId,
            platform: p.id,
            platformName: p.name,
          ),
        )
        .toList();
    print(
        'LxScriptSource: 脚本 $name 注册了 ${_platforms.length} 个平台: ${_platforms.map((p) => p.id).join(", ")}');
  }

  @override
  Future<void> dispose() async {
    _services = [];
    _platforms = [];
    _isInitialized = false;
  }

  /// 从脚本路径生成 scriptId（取文件名的 hash）
  static String _deriveScriptId(String path) {
    final fileName = p.basenameWithoutExtension(path);
    return '${fileName}_${path.hashCode.abs()}';
  }
}
