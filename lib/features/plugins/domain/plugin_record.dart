/// 一个已安装的插件（元信息 + 源码 + 启用状态）。
///
/// 宿主不区分插件出身：自有格式插件与经 LX 兼容层包装的脚本都落在同一个模型里，
/// 差异只体现在 [supportedMethods] 与 [sourceKeys] 上。
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
    this.sourceKeys = const [],
    this.qualitys = const {},
    this.srcUrl,
    this.updateLog,
    this.allowFallback = true,
    this.disableResolve = false,
  });

  /// 稳定 id：自有格式用 platform，LX 用 `lx:<脚本名>`。重名时替换而不是新增。
  String id;

  /// 显示名
  String name;

  /// 身份标识（自有格式=导出 platform，LX=脚本名）
  String platform;
  String version;
  String description;
  String author;
  bool enabled;

  /// 原始 JS 源码
  String source;

  /// 从实例反射得到的可用方法
  List<String> supportedMethods;

  /// 可处理的音源 key 集合：自有格式为 `[platform]`，LX 为其声明的全部源。
  List<String> sourceKeys;

  /// 音源 key → 该源支持的音质列表（仅 LX 有值）。
  Map<String, List<String>> qualitys;

  /// 更新源地址（自有格式=srcUrl，LX=updateAlert.updateUrl）。
  String? srcUrl;

  /// 已发现的更新说明；非空表示"有更新"。
  String? updateLog;

  /// 是否允许其它插件缺少音源时调用本插件（默认允许）。
  bool allowFallback;

  /// 禁用本插件取链：播放时跳过它的 getMediaSource，直接走同音源兜底。
  bool disableResolve;

  /// 本插件能否提供播放链接。
  bool get canProvideMediaSource => supportedMethods.contains('getMediaSource');

  /// 是否有待处理的更新。
  bool get hasUpdate => updateLog != null && updateLog!.isNotEmpty;

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
    'sourceKeys': sourceKeys,
    'qualitys': qualitys,
    'srcUrl': srcUrl,
    'updateLog': updateLog,
    'allowFallback': allowFallback,
    'disableResolve': disableResolve,
  };

  static PluginRecord fromJson(Map<String, dynamic> json) {
    final rawQualitys = json['qualitys'];
    return PluginRecord(
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
      sourceKeys: (json['sourceKeys'] as List?)?.cast<String>() ?? const [],
      qualitys: rawQualitys is Map
          ? {
              for (final entry in rawQualitys.entries)
                '${entry.key}': (entry.value as List).map((e) => '$e').toList(),
            }
          : const {},
      srcUrl: json['srcUrl'] as String?,
      updateLog: json['updateLog'] as String?,
      allowFallback: json['allowFallback'] as bool? ?? true,
      disableResolve: json['disableResolve'] as bool? ?? false,
    );
  }
}
