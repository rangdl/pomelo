import 'package:pomelo/core/mars.dart';
import '../model/my_profile.dart';
import '../repository/my_repository.dart';

/// My 模块 - 服务层
///
/// 演示模块内如何使用 Settings：
/// - 服务方法中直接调用 Settings.get/set
/// - 无需依赖注入，无需 Provider，纯静态调用
class MyService extends Service {
  @override
  String get id => 'my_service';

  final MyRepository repository;

  MyService(this.repository);

  /// 获取用户信息
  MyProfile? getProfile() => throw UnimplementedError('待实现');

  /// ==================== Settings 使用示例 ====================

  /// 保存用户偏好的主题模式
  Future<void> setThemeMode(String mode) async {
    await Settings.set(StorageKeys.myThemeMode, mode);
  }

  /// 读取用户偏好的主题模式
  String getThemeMode() {
    return Settings.get(StorageKeys.myThemeMode, defaultValue: 'system')!;
  }

  /// 保存歌词字体大小
  Future<void> setLyricFontSize(int size) async {
    await Settings.setInt(StorageKeys.myLyricFontSize, size);
  }

  /// 读取歌词字体大小
  int getLyricFontSize() {
    return Settings.getInt(StorageKeys.myLyricFontSize, defaultValue: 14)!;
  }

  /// 批量更新用户设置
  Future<void> updateUserPreferences({
    String? themeMode,
    int? lyricFontSize,
    bool? autoPlay,
  }) async {
    await Settings.setAll({
      StorageKeys.myThemeMode: themeMode,
      StorageKeys.myLyricFontSize: lyricFontSize?.toString(),
      StorageKeys.myAutoPlay: autoPlay?.toString(),
    });
  }

  /// 读取用户设置的自动播放
  bool getAutoPlay() {
    return Settings.getBool(StorageKeys.myAutoPlay, defaultValue: true)!;
  }
}
