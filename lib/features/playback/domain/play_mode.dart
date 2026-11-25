/// 播放模式。
enum PlayMode {
  /// 列表循环
  listLoop,

  /// 单曲循环
  singleLoop,

  /// 顺序播放（播完最后一首停止）
  sequential;

  String get label => switch (this) {
    PlayMode.listLoop => '列表循环',
    PlayMode.singleLoop => '单曲循环',
    PlayMode.sequential => '顺序播放',
  };
}
