import '../domain/plugin_record.dart';

/// 宿主认识的标准音源 key。
const List<String> kSourceKeys = ['kw', 'tx', 'wy', 'kg', 'mg', 'qs'];

/// 由插件 platform 名推断其对应的音源 key（kw/tx/wy/kg/mg/qs）。
///
/// 第三方插件普遍用中文平台名，不会声明音源 key。当插件自带取链失效时，宿主需要
/// 用同一平台的其它插件兜底解析，因此要先把 platform 映射成标准 key。
///
/// 返回 null 表示「没有对应的标准音源」（如猫耳FM/YouTube 等独立平台），
/// 这类插件不参与跨插件兜底匹配。
String? inferSourceKeyFromPlatform(String platform) {
  final p = platform.toLowerCase().trim();
  if (p.isEmpty) return null;

  bool hasToken(String key) {
    if (p == key) return true;
    return RegExp('(^|[^a-z0-9])$key([^a-z0-9]|\$)').hasMatch(p);
  }

  // 中文名优先，避免 "小蜗" 之类被 2 字母 key 误判。
  if (p.contains('酷我') || p.contains('kuwo') || p.contains('小蜗')) return 'kw';
  if (p.contains('qq') || p.contains('腾讯')) return 'tx';
  if (p.contains('网易') || p.contains('netease')) return 'wy';
  if (p.contains('酷狗') || p.contains('kugou')) return 'kg';
  if (p.contains('咪咕') || p.contains('migu')) return 'mg';
  if (p.contains('汽水') || p.contains('qishui')) return 'qs';
  for (final key in kSourceKeys) {
    if (hasToken(key)) return key;
  }
  return null;
}

/// 插件对外的主音源 key。
///
/// 单源且本身就是标准 key 时直接采用（LX 包装插件声明 `["kw"]`）；
/// 否则按 platform 名推断（自有格式插件 platform 多为中文平台名）。
String? primarySourceKey(PluginRecord plugin) {
  if (plugin.sourceKeys.length == 1 &&
      kSourceKeys.contains(plugin.sourceKeys.first)) {
    return plugin.sourceKeys.first;
  }
  final inferred = inferSourceKeyFromPlatform(plugin.platform);
  if (inferred != null) return inferred;
  return plugin.sourceKeys.length == 1 ? plugin.sourceKeys.first : null;
}
