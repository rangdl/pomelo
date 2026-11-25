/// 由插件 platform 名推断其对应的 LX 源平台（kw/tx/wy/kg/mg/qs…）。
///
/// 第三方 MusicFree 插件普遍用中文平台名，且不声明 `lxSource`。当插件自带的
/// 取链失效时，宿主需要用同一平台的 LX 脚本兜底解析——这要求把插件结果映射到
/// 对应的 LX 源。
///
/// 返回 null 表示「该插件没有对应的 LX 源」（如猫耳FM/YouTube/汽水等独立平台），
/// 这类插件不走 LX 兜底。
String? inferLxSourceFromPlatform(String platform) {
  final p = platform.toLowerCase();
  // 酷我（小蜗音乐底层走 kuwo，一并归到 kw）
  if (p.contains('酷我') ||
      p.contains('kuwo') ||
      p.contains('小蜗') ||
      p.contains('kw')) {
    return 'kw';
  }
  // QQ音乐（LX 源名为 tx）
  if (p.contains('qq') || p.contains('tx')) return 'tx';
  // 网易云
  if (p.contains('网易') || p.contains('netease') || p.contains('wy')) {
    return 'wy';
  }
  // 酷狗
  if (p.contains('酷狗') || p.contains('kugou') || p.contains('kg')) return 'kg';
  // 咪咕
  if (p.contains('咪咕') || p.contains('migu') || p.contains('mg')) return 'mg';
  // 汽水 / 抖音
  if (p.contains('汽水') || p.contains('qishui') || p.contains('qs')) return 'qs';
  return null;
}
