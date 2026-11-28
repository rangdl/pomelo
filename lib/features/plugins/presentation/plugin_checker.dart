import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/logging/app_logger.dart';
import '../domain/plugin_record.dart';
import 'plugin_providers.dart';

/// 插件能力的完整清单（顺序即能力页的展示顺序）。
///
/// 与 MusicFree 官方方法集对齐，并包含宿主扩展；`method` 是插件里实际导出
/// 的函数名，能力页据此判断「支持 / 不支持」。
const List<({String method, String label, String desc})> kPluginAbilities = [
  (method: 'search', label: '搜索歌曲', desc: '按关键字搜索单曲 / 歌单 / 歌手 / 专辑'),
  (method: 'getMediaSource', label: '获取播放链接', desc: '解析可直接播放的地址（含请求头）'),
  (method: 'getLyric', label: '获取歌词', desc: '返回 LRC 歌词，可带翻译'),
  (method: 'getTopLists', label: '榜单列表', desc: '提供各平台排行榜入口'),
  (method: 'getTopListDetail', label: '榜单详情', desc: '展开某个榜单的歌曲'),
  (method: 'getRecommendSheetTags', label: '歌单标签', desc: '提供推荐歌单的分类标签'),
  (method: 'getRecommendSheetsByTag', label: '推荐歌单', desc: '按标签分页拉取推荐歌单'),
  (method: 'getMusicSheetInfo', label: '歌单详情', desc: '展开歌单曲目'),
  (method: 'importMusicSheet', label: '导入歌单', desc: '从分享链接导入歌单'),
  (method: 'importMusicItem', label: '导入单曲', desc: '从分享链接导入单曲'),
  (method: 'getArtistWorks', label: '歌手作品', desc: '按歌手查歌曲 / 专辑'),
  (method: 'getAlbumInfo', label: '专辑详情', desc: '展开专辑曲目'),
  (method: 'getMusicInfo', label: '歌曲详情', desc: '补全单曲元信息'),
  (method: 'getMusicComments', label: '歌曲评论', desc: '分页拉取评论列表'),
];

/// 方法名 → 中文能力名（详情页等按需查表）。
final Map<String, String> kPluginAbilityNames = {
  for (final a in kPluginAbilities) a.method: a.label,
};

/// 单条能力的探测结果。
class AbilityCheck {
  const AbilityCheck({required this.ability, required this.ok, this.detail});

  final String ability;
  final bool ok;
  final String? detail;
}

/// 某个插件的完整检查结果。
class PluginCheckReport {
  const PluginCheckReport({required this.pluginId, required this.results});

  final String pluginId;
  final List<AbilityCheck> results;

  int get passed => results.where((r) => r.ok).length;
  int get total => results.length;
}

/// 正在执行的检查（按插件 id 记录进度，避免整页闪烁）。
class CheckingPluginsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void add(String id) => state = {...state, id};

  void remove(String id) => state = {...state}..remove(id);
}

final checkingPluginsProvider =
    NotifierProvider<CheckingPluginsNotifier, Set<String>>(
      CheckingPluginsNotifier.new,
    );

/// 最近一次检查结果（仅内存，不落盘）。
class PluginCheckResultsNotifier
    extends Notifier<Map<String, PluginCheckReport>> {
  @override
  Map<String, PluginCheckReport> build() => const {};

  void put(PluginCheckReport report) =>
      state = {...state, report.pluginId: report};

  void clear(String pluginId) {
    final next = {...state}..remove(pluginId);
    state = next;
  }
}

final pluginCheckResultsProvider =
    NotifierProvider<
      PluginCheckResultsNotifier,
      Map<String, PluginCheckReport>
    >(PluginCheckResultsNotifier.new);

/// 对一个插件做能力探测。
///
/// 只做「安全」的探测：搜索、榜单、歌词、详情、评论等只读接口。
/// **不会**主动取播放链接——那会真的请求音乐平台且有风控风险，
/// 需要用户单独点「测试取链」。
class PluginChecker {
  PluginChecker(this._ref);

  final Ref _ref;

  Future<PluginCheckReport> run(
    PluginRecord plugin, {
    bool includeMedia = false,
  }) async {
    final results = <AbilityCheck>[];
    // 探测整体限时：单个插件卡住时不能让「检查」永远转圈。
    final rt = await _ref
        .read(pluginRuntimeProvider(plugin.id).future)
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw StateError('插件运行时启动超时'),
        );

    // 探测用的曲目：先搜一首，后续能力都基于它。
    Map<String, dynamic>? probeTrack;
    if (plugin.supportedMethods.contains('search')) {
      final sw = Stopwatch()..start();
      try {
        final res = await rt.search('周杰伦', page: 1);
        final tracks = (res['data'] as List?) ?? const [];
        probeTrack = tracks.isNotEmpty
            ? (tracks.first as Map).cast<String, dynamic>()
            : null;
        results.add(
          AbilityCheck(
            ability: 'search',
            ok: probeTrack != null,
            detail: probeTrack == null
                ? '搜索无结果'
                : '${sw.elapsedMilliseconds}ms',
          ),
        );
      } catch (e) {
        results.add(AbilityCheck(ability: 'search', ok: false, detail: '$e'));
      }
    }

    if (plugin.supportedMethods.contains('getTopLists')) {
      final sw = Stopwatch()..start();
      try {
        final lists = await rt.getTopLists();
        results.add(
          AbilityCheck(
            ability: 'getTopLists',
            ok: lists.isNotEmpty,
            detail: lists.isEmpty
                ? '返回空列表'
                : '${lists.length} 个 · ${sw.elapsedMilliseconds}ms',
          ),
        );
      } catch (e) {
        results.add(
          AbilityCheck(ability: 'getTopLists', ok: false, detail: '$e'),
        );
      }
    }

    if (probeTrack != null) {
      if (plugin.supportedMethods.contains('getLyric')) {
        try {
          final raw = await rt.getLyric(
            probeTrack,
            sourceKey: probeTrack['_sourceKey'] as String?,
            timeout: const Duration(seconds: 30),
          );
          final lyric = _lyricSummary(raw);
          results.add(
            AbilityCheck(
              ability: 'getLyric',
              ok: lyric.main.isNotEmpty,
              detail: lyric.main.isEmpty
                  ? '无歌词'
                  : (lyric.hasTranslation ? '正常（含翻译）' : '正常'),
            ),
          );
        } catch (e) {
          results.add(
            AbilityCheck(ability: 'getLyric', ok: false, detail: '$e'),
          );
        }
      }
      if (plugin.supportedMethods.contains('getMusicInfo')) {
        try {
          final info = await rt.getMusicInfo(probeTrack);
          results.add(
            AbilityCheck(
              ability: 'getMusicInfo',
              ok: info != null && info.isNotEmpty,
              detail: (info == null || info.isEmpty) ? '无数据' : '正常',
            ),
          );
        } catch (e) {
          results.add(
            AbilityCheck(ability: 'getMusicInfo', ok: false, detail: '$e'),
          );
        }
      }
      if (plugin.supportedMethods.contains('getMusicComments')) {
        try {
          final comments = await rt.getMusicComments(probeTrack, page: 1);
          results.add(
            AbilityCheck(
              ability: 'getMusicComments',
              ok: comments.isNotEmpty,
              detail: comments.isEmpty ? '暂无评论' : '${comments.length} 条',
            ),
          );
        } catch (e) {
          results.add(
            AbilityCheck(ability: 'getMusicComments', ok: false, detail: '$e'),
          );
        }
      }
    }

    // 取链探测可能慢且会打真实接口，只在用户显式要求时执行。
    if (includeMedia && probeTrack != null) {
      final key = probeTrack['_sourceKey'] as String?;
      final sw = Stopwatch()..start();
      try {
        final source = await rt.getMediaSource(
          probeTrack,
          'standard',
          sourceKey: key,
        );
        final url = '${source?['url'] ?? ''}';
        final notes = <String>[
          if ('${source?['userAgent'] ?? ''}'.isNotEmpty) 'UA',
          if ('${source?['quality'] ?? ''}'.isNotEmpty)
            '音质 ${source?['quality']}',
        ];
        results.add(
          AbilityCheck(
            ability: 'getMediaSource',
            ok: url.isNotEmpty,
            detail: url.isEmpty
                ? '未返回地址'
                : notes.isEmpty
                ? '${sw.elapsedMilliseconds}ms'
                : '${sw.elapsedMilliseconds}ms · ${notes.join(' · ')}',
          ),
        );
      } catch (e) {
        results.add(
          AbilityCheck(ability: 'getMediaSource', ok: false, detail: '$e'),
        );
      }
    }

    AppLogger.instance.info(
      'plugin.check',
      '${plugin.platform} 能力检查：'
          '${results.where((r) => r.ok).length}/${results.length} 通过',
    );

    return PluginCheckReport(pluginId: plugin.id, results: results);
  }
}

final pluginCheckerProvider = Provider<PluginChecker>(PluginChecker.new);

/// 从歌词返回值里取主歌词与是否有翻译（与 PlayerActions 的解析保持一致）。
({String main, bool hasTranslation}) _lyricSummary(dynamic raw) {
  if (raw is String) return (main: raw.trim(), hasTranslation: false);
  if (raw is Map) {
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = raw[k];
        if (v is String && v.trim().isNotEmpty) return v;
        if (v is Map) {
          final inner = pick(keys);
          if (inner.isNotEmpty) return inner;
        }
      }
      return '';
    }

    return (
      main: pick(const ['lyric', 'rawLrc', 'lrc', 'content']),
      hasTranslation: pick(const ['translation', 'trans']).isNotEmpty,
    );
  }
  return (main: '', hasTranslation: false);
}
