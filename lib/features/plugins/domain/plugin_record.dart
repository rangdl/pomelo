/// 插件未声明 `supportedSearchType` 时，UI 默认展示的搜索类型。
const List<String> kDefaultSearchTypes = ['music', 'sheet', 'artist', 'album'];

/// 插件的类型：由脚本初始化时实际走的那条兼容路线决定。
///
/// 有导出方法 → 按 MusicFree 插件运行；没有导出方法但注册了 LX 处理器 /
/// 上报过 inited → 按洛雪音源脚本运行。两者都不算“官方”，官方只是内置预装
/// 的来源，与类型无关。
enum PluginOrigin {
  /// MusicFree 格式插件（module.exports）。
  musicfree('MusicFree'),

  /// 洛雪音乐助手脚本（经 LX 兼容层运行）。
  lx('LX');

  const PluginOrigin(this.label);

  final String label;

  static PluginOrigin fromName(String? name) => values.firstWhere(
    (o) => o.name == name,
    orElse: () => PluginOrigin.musicfree,
  );
}

/// 解析落库的类型字段。
///
/// 旧版本曾把内置插件存成 `official`，该值已废弃：按 id 前缀（`lx:`）重新
/// 归类，其余视为 MusicFree，下次加载插件时会按实际兼容路线上报覆盖。
PluginOrigin? _originFromStored(String name, {required String? id}) {
  if (name == 'official') {
    return (id ?? '').startsWith('lx:')
        ? PluginOrigin.lx
        : PluginOrigin.musicfree;
  }
  return PluginOrigin.fromName(name);
}

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
    this.origin,
    this.userSourceKeys,
    this.supportedSearchTypes = const [],
    this.defaultSearchType = '',
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

  /// 插件出身（官方 / MusicFree / 洛雪）。
  ///
  /// 为空表示老数据：按 id 前缀 `lx:` 识别洛雪，其余视为 MusicFree。
  PluginOrigin? origin;

  /// 用户手动指定的音源 key；非空时覆盖自动推断，插件更新不冲掉。
  List<String>? userSourceKeys;

  /// 插件支持的搜索类型（music/sheet/artist/album/lyric）。
  ///
  /// 空列表表示「不限制」——与 MusicFree 一致：未声明即全部支持。
  List<String> supportedSearchTypes;

  /// 默认搜索类型；为空时回退 music。
  String defaultSearchType;

  /// 实际可用于 UI 的搜索类型：有声明按声明，没声明给出四种常规类型。
  List<String> get searchableTypes =>
      supportedSearchTypes.isEmpty ? kDefaultSearchTypes : supportedSearchTypes;

  /// 展示用的类型：老数据（含已废弃的“官方”）按 id 前缀就近归类。
  PluginOrigin get displayOrigin {
    if (origin != null) return origin!;
    if (id.startsWith('lx:')) return PluginOrigin.lx;
    return PluginOrigin.musicfree;
  }

  /// 是否为 LX 兼容脚本。
  bool get isLxCompat =>
      (origin ?? PluginOrigin.musicfree) == PluginOrigin.lx ||
      id.startsWith('lx:');

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
    'origin': origin?.name,
    'userSourceKeys': userSourceKeys,
    'supportedSearchTypes': supportedSearchTypes,
    'defaultSearchType': defaultSearchType,
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
      origin: json['origin'] is String
          ? _originFromStored(
              json['origin'] as String,
              id: json['id'] as String?,
            )
          : null,
      userSourceKeys: (json['userSourceKeys'] as List?)?.cast<String>(),
      supportedSearchTypes:
          (json['supportedSearchTypes'] as List?)?.cast<String>() ?? const [],
      defaultSearchType: json['defaultSearchType'] as String? ?? '',
    );
  }
}
