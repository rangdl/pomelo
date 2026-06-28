/// 格式化播放时长为 `m:ss`（如 `3:05`、`12:30`）。
///
/// 用于播放器进度显示。小时以上时长会以 `m` 累计（如 `75:00`）。
String formatDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60);
  return '$m:${s.toString().padLeft(2, '0')}';
}
