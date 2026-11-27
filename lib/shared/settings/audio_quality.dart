/// 播放音质偏好。
///
/// 档位与 MusicFree 官方的 low/standard/high/super 对齐；到 LX 的
/// `musicUrl` 音质名则映射为 128k/320k/flac/flac24bit。
enum AudioQuality {
  low('低品'),
  standard('标准'),
  high('高品'),
  lossless('无损');

  const AudioQuality(this.label);

  final String label;

  /// 传给 MusicFree 插件 `getMediaSource(item, quality)` 的值。
  String get musicFreeValue => switch (this) {
    AudioQuality.low => 'low',
    AudioQuality.standard => 'standard',
    AudioQuality.high => 'high',
    AudioQuality.lossless => 'super',
  };

  /// 传给 LX 脚本 `musicUrl` action 的 type 值（各脚本按此映射平台音质）。
  String get lxValue => switch (this) {
    AudioQuality.low => '128k',
    AudioQuality.standard => '320k',
    AudioQuality.high => 'flac',
    AudioQuality.lossless => 'flac24bit',
  };

  static AudioQuality fromName(String? name) => AudioQuality.values.firstWhere(
    (q) => q.name == name,
    orElse: () => AudioQuality.high,
  );
}
