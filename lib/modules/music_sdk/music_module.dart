import 'package:pomelo/core/mars.dart';
import 'repository/music_repository.dart';
import 'service/music_service.dart';

/// Music SDK 模块定义
///
/// 音乐播放最底层模块，提供统一的数据模型和播放能力。
/// 上层音乐平台模块（如网易云、QQ音乐）通过此 SDK 注入数据。
///
/// 遵循 M.A.R.S. 架构：
/// - Model: song.dart, album.dart, playlist.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: MusicSdkRepository
/// - Service/State: MusicSdkService / Riverpod Provider
class MusicSdkModule extends Module {
  MusicSdkModule() : _repository = MusicSdkRepository();

  final MusicSdkRepository _repository;
  late final MusicSdkService _service;

  @override
  String get id => 'music_sdk';

  @override
  String get displayName => '音乐SDK';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['home'];

  @override
  Future<void> onInit() async {
    await _repository.onInit();
    _service = MusicSdkService(repository: _repository);
    await _service.onInit();
  }

  @override
  Future<void> onReady() async {
    // 所有依赖模块就绪后的逻辑
  }

  @override
  Future<void> onDispose() async {
    await _service.onDispose();
    await _repository.onDispose();
  }

  /// 对外暴露仓储，供 Provider 使用
  MusicSdkRepository get repository => _repository;

  /// 对外暴露服务，供 Provider 使用
  MusicSdkService get service => _service;
}
