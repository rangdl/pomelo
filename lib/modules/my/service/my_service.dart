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
    await Settings.set('my_theme_mode', mode);
  }

  /// 读取用户偏好的主题模式
  String getThemeMode() {
    return Settings.get('my_theme_mode', defaultValue: 'system')!;
  }

  /// 保存歌词字体大小
  Future<void> setLyricFontSize(int size) async {
    await Settings.setInt('my_lyric_font_size', size);
  }

  /// 读取歌词字体大小
  int getLyricFontSize() {
    return Settings.getInt('my_lyric_font_size', defaultValue: 14)!;
  }

  /// 批量更新用户设置
  Future<void> updateUserPreferences({
    String? themeMode,
    int? lyricFontSize,
    bool? autoPlay,
  }) async {
    await Settings.setAll({
      'my_theme_mode': themeMode,
      'my_lyric_font_size': lyricFontSize?.toString(),
      'my_auto_play': autoPlay?.toString(),
    });
  }

  /// 读取用户设置的自动播放
  bool getAutoPlay() {
    return Settings.getBool('my_auto_play', defaultValue: true)!;
  }
}
