import '../domain/plugin_record.dart';

/// 宿主认识的标准音源 key。
const List<String> kSourceKeys = ['kw', 'tx', 'wy', 'kg', 'mg', 'qs'];

/// 音源 key 的中文名（用于设置页与兜底链展示）。
const Map<String, String> kSourceKeyLabels = {
  'kw': '酷我',
  'tx': 'QQ音乐',
  'wy': '网易云',
  'kg': '酷狗',
  'mg': '咪咕',
  'qs': '汽水',
};

/// 每个音源 key 的识别别名（全部小写，包含英文与拼音写法）。
///
/// 别名取自洛雪音乐助手的平台昵称约定（小蜗/小秋/小芸/小枸/小蜜），
/// 插件 platform 里出现这些词同样能正确归类。
const Map<String, List<String>> _sourceAliases = {
  'kw': ['酷我', 'kuwo', '小蜗', 'kw'],
  'tx': ['qq', '腾讯', 'qq音乐', '小秋', 'tencent', 'tx'],
  'wy': ['网易', 'netease', '网易云', '小芸', 'wy'],
  'kg': ['酷狗', 'kugou', '小枸', 'kg'],
  'mg': ['咪咕', 'migu', '小蜜', 'mg'],
  'qs': ['汽水', 'qishui', '抖音', 'douyin', '小汽', 'qs'],
};

/// 由插件 platform 名推断其对应的音源 key（kw/tx/wy/kg/mg/qs）。
///
/// 第三方插件普遍用中文平台名（如「风誰·酷狗」），不会声明音源 key。
/// 当插件自带取链失效时，宿主需要用同一平台的其它插件兜底解析，
/// 因此要先把 platform 映射成标准 key。
///
/// 匹配顺序：先按别名表逐 key 做包含匹配（长别名优先，避免误判），
/// 再退回 2 字母 key 的整词匹配。
///
/// 返回 null 表示「没有对应的标准音源」（如猫耳FM/YouTube 等独立平台），
/// 这类插件不参与跨插件兜底匹配。
String? inferSourceKeyFromPlatform(String platform) {
  final p = platform.toLowerCase().trim();
  if (p.isEmpty) return null;

  // 1) 别名包含匹配。按别名长度从长到短，保证「网易云」优先于「网易」、
  //    「qq音乐」优先于「qq」这类重叠别名不会互相抢。
  final entries = <(String key, String alias)>[
    for (final e in _sourceAliases.entries)
      for (final alias in e.value) (e.key, alias),
  ]..sort((a, b) => b.$2.length.compareTo(a.$2.length));

  for (final (key, alias) in entries) {
    // 2 字母 key（kw/tx/...）必须整词匹配，否则 "kugou" 里的 "kg" 会误命中。
    if (alias.length <= 2) {
      if (p == alias) return key;
      if (RegExp('(^|[^a-z0-9])$alias([^a-z0-9]|\$)').hasMatch(p)) return key;
      continue;
    }
    if (p.contains(alias)) return key;
  }
  return null;
}

/// 规范化插件的音源 key 列表。
///
/// LX 脚本自报的 key 本身就是标准 key，原样返回；
/// MusicFree 插件自报的是 platform 显示名（如「风誰·酷狗」），
/// 在这里统一推断成标准 key，兜底匹配才能命中。
///
/// 推断不出时保留原值（独立平台仍可被按自己的 key 兜底）。
List<String> normalizeSourceKeys({
  required List<String> declared,
  required String platform,
  required bool isLxCompat,
}) {
  if (isLxCompat) return declared;

  final inferred = <String>{};
  for (final key in declared) {
    final mapped = inferSourceKeyFromPlatform(key);
    if (mapped != null) inferred.add(mapped);
  }
  // 声明里一个标准 key 都没推断出来时，再从 platform 名试一次。
  final fromPlatform = inferSourceKeyFromPlatform(platform);
  if (fromPlatform != null) inferred.add(fromPlatform);

  if (inferred.isNotEmpty) return inferred.toList()..sort();
  return declared;
}

/// 插件有效的音源 key：用户手动指定优先，否则用规范化后的默认值。
List<String> effectiveSourceKeys(PluginRecord plugin) {
  final manual = plugin.userSourceKeys;
  if (manual != null && manual.isNotEmpty) return manual;
  return normalizeSourceKeys(
    declared: plugin.sourceKeys,
    platform: plugin.platform,
    isLxCompat: plugin.isLxCompat,
  );
}

/// 插件对外的主音源 key。
///
/// 单源且本身就是标准 key 时直接采用（LX 包装插件声明 `["kw"]`）；
/// 否则按 platform 名推断（自有格式插件 platform 多为中文平台名）。
String? primarySourceKey(PluginRecord plugin) {
  final keys = effectiveSourceKeys(plugin);
  if (keys.length == 1 && kSourceKeys.contains(keys.first)) {
    return keys.first;
  }
  final inferred = inferSourceKeyFromPlatform(plugin.platform);
  if (inferred != null) return inferred;
  return keys.length == 1 ? keys.first : null;
}

/// 音源 key 的展示名；未知 key 原样返回。
String sourceKeyLabel(String key) => kSourceKeyLabels[key] ?? key;
