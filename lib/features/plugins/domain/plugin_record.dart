/// 一个已安装的插件（元信息 + 源码 + 启用状态）。
class PluginRecord {
  PluginRecord({
    required this.id,
    required this.name,
    required this.platform,
    required this.version,
    this.description = '',
    this.author = '',
    this.enabled = true,
    required this.source,
    this.supportedMethods = const [],
    this.kind = 'musicfree',
    this.lxSources = const [],
    this.lxSource,
  });

  /// 稳定 id，默认用 platform，重名时加后缀
  String id;

  /// 显示名（插件导出的 platform）
  String name;
  String platform;
  String version;
  String description;
  String author;
  bool enabled;

  /// 原始 JS 源码
  String source;

  /// 从实例反射得到的可用方法
  List<String> supportedMethods;

  /// 插件类型：MusicFree 主协议 / LX 辅助协议
  String kind;

  /// LX 脚本声明的源（kw/kg/tx/wy…），仅 LX 类型使用
  List<String> lxSources;

  /// MusicFree 插件声明的默认 LX 平台（结果未单独声明时使用）
  String? lxSource;

  bool get isLx => kind == 'lx';
  bool get isMusicFree => kind == 'musicfree';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'platform': platform,
    'version': version,
    'description': description,
    'author': author,
    'enabled': enabled,
    'source': source,
    'supportedMethods': supportedMethods,
    'kind': kind,
    'lxSources': lxSources,
    'lxSource': lxSource,
  };

  static PluginRecord fromJson(Map<String, dynamic> json) => PluginRecord(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    platform: json['platform'] as String? ?? '',
    version: json['version'] as String? ?? '',
    description: json['description'] as String? ?? '',
    author: json['author'] as String? ?? '',
    enabled: json['enabled'] as bool? ?? true,
    source: json['source'] as String? ?? '',
    supportedMethods:
        (json['supportedMethods'] as List?)?.cast<String>() ?? const [],
    kind: json['kind'] as String? ?? 'musicfree',
    lxSources: (json['lxSources'] as List?)?.cast<String>() ?? const [],
    lxSource: json['lxSource'] as String?,
  );
}
