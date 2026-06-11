import 'package:pomelo/core/mars.dart';
import '../model/song.dart';
import '../repository/music_repository.dart';

/// Music SDK 业务服务
///
/// 音乐播放最底层服务，封装通用的音乐播放核心能力。
/// 不依赖任何特定的音乐平台，由上层模块提供数据。
class MusicSdkService extends Service {
  final MusicSdkRepository repository;

  MusicSdkService({required this.repository});

  @override
  String get id => 'music_service';

  @override
  Future<void> onInit() async {
    await super.onInit();
  }

  @override
  Future<void> onDispose() async {
    await super.onDispose();
  }
}
