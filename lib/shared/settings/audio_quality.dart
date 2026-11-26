/// 播放音质偏好。
///
/// 不同插件对不同档位的命名各异，这里给出统一的抽象档位，并提供到
/// MusicFree 与 LX 各脚本实际使用值的映射。
enum AudioQuality {
  standard('标准'),
  high('高品'),
  lossless('无损');

  const AudioQuality(this.label);

  final String label;

  /// 传给 MusicFree 插件 `getMediaSource(item, quality)` 的值。
  ///
  /// 星海 qs 等脚本内部 QUALITY_MAP 用 low/standard/high/super 这组键，
  /// 通用 MusicFree 插件通常用 standard/higher/highest（酷狗/网易系）。
  /// 这里取 maxim「通用 MusicFree 约定」的一组，兼容多数插件。
  String get musicFreeValue => switch (this) {
    AudioQuality.standard => 'standard',
    AudioQuality.high => 'higher',
    AudioQuality.lossless => 'highest',
  };

  /// 传给 LX 脚本 `musicUrl` action 的 type 值（各脚本按此映射平台音质）。
  String get lxValue => switch (this) {
    AudioQuality.standard => '128k',
    AudioQuality.high => '320k',
    AudioQuality.lossless => 'flac',
  };

  static AudioQuality fromName(String? name) => AudioQuality.values.firstWhere(
    (q) => q.name == name,
    orElse: () => AudioQuality.high,
  );
}
