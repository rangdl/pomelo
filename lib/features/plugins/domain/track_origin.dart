import 'plugin_record.dart';
import 'source_keys.dart';

/// 给插件返回的条目打上来源标记。
///
/// - `_pluginId`：来源插件 id，用于找回原插件解析播放地址；
/// - `_sourceKey`：标准音源 key（kw/kg/tx…），用于跨插件兜底匹配。
///
/// 所有产出条目的路径（搜索/榜单/歌单/歌手）都必须走这里，避免出现
/// "能搜不能播"的孤儿条目。
Map<String, dynamic> tagTrackOrigin(
  Map<String, dynamic> item,
  PluginRecord plugin,
) {
  // 聚合类插件（如 GD 音乐台）一个插件覆盖多个平台，条目里的 source 才是
  // 真实音源；优先用它，拿不到再退回插件级推断。
  final rawSource = item['source'];
  final itemKey = rawSource is String && rawSource.isNotEmpty
      ? inferSourceKeyFromPlatform(rawSource)
      : null;
  final key = itemKey ?? primarySourceKey(plugin);
  return {
    ...item,
    '_pluginId': plugin.id,
    if (key != null && key.isNotEmpty) '_sourceKey': key,
  };
}

/// 去掉宿主内部标记，还原成插件认识的原始条目。
Map<String, dynamic> stripTrackOrigin(Map<String, dynamic> item) {
  return Map<String, dynamic>.from(item)
    ..remove('_pluginId')
    ..remove('_sourceKey')
    ..remove('lxSource');
}
