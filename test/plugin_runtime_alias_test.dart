import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/plugins/domain/plugin_record.dart';
import 'package:pomelo/features/plugins/runtime/pomelo_plugin_runtime.dart';

/// 跨插件兜底时，曲目来自自有格式插件（title/artist/album/duration），
/// LX 脚本却按 songmid/hash/name/singer/albumName/interval 取值。
/// 这里用一个只回显字段的 LX 脚本验证别名补齐确实生效。
const _echoScript = r'''
lx.on('request', async (payload) => {
  if (payload.action !== 'musicUrl') return null;
  const m = payload.info.musicInfo;
  const fields = [m.songmid, m.hash, m.name, m.singer, m.albumName, m.interval];
  return { url: 'https://example.test/' + encodeURIComponent(fields.join('|')) };
});
lx.send('inited', {
  status: true,
  sources: { kw: { name: '酷我', actions: [], qualitys: ['128k'] } }
});
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('跨插件字段别名补齐 LX 取链所需字段', () async {
    final rt = await PomeloPluginRuntime.create();
    addTearDown(rt.dispose);
    await rt.loadPlugin(_echoScript, name: 'alias');
    expect(rt.initialized, isTrue, reason: rt.initError ?? '');

    final source = await rt.getMediaSource(
      {
        'id': 'abc',
        'title': '标题',
        'artist': '歌手',
        'album': '专辑',
        'duration': 245,
        // 宿主内部标记必须被剔除，不能传给脚本。
        '_pluginId': 'other',
        '_sourceKey': 'kw',
      },
      'high',
      sourceKey: 'kw',
    );

    final url = Uri.parse(source!['url'] as String);
    final fields = Uri.decodeComponent(url.path.substring(1)).split('|');
    expect(fields[0], 'abc'); // songmid ← id
    expect(fields[1], 'abc'); // hash ← id
    expect(fields[2], '标题'); // name ← title
    expect(fields[3], '歌手'); // singer ← artist
    expect(fields[4], '专辑'); // albumName ← album
    expect(fields[5], '245'); // interval ← duration
  });

  test('PluginRecord.disableResolve 可 JSON 往返', () {
    final record = PluginRecord(
      id: 'demo',
      name: '示例',
      platform: '示例平台',
      version: '1.0.0',
      source: 'module.exports = {}',
      supportedMethods: const ['getMediaSource'],
      disableResolve: true,
    );

    final restored = PluginRecord.fromJson(record.toJson());
    expect(restored.disableResolve, isTrue);
    expect(record.toJson()['disableResolve'], isTrue);

    // 老数据缺字段时默认 false（保持原有行为）。
    final legacy = PluginRecord.fromJson({'id': 'old'});
    expect(legacy.disableResolve, isFalse);
  });

  test('sourceKey 通过 musicItem 传入，不再作为额外实参', () async {
    final rt = await PomeloPluginRuntime.create();
    addTearDown(rt.dispose);
    await rt.loadPlugin(_argEchoScript, name: 'args');

    final source = await rt.getMediaSource(
      {'id': 'abc', '_pluginId': 'x'},
      'high',
      sourceKey: 'kw',
    );
    // 脚本把 arguments.length 与 musicItem.sourceKey 一起回显。
    expect(source!['url'], 'https://example.test/2|kw');
  });

  test('支持的搜索类型从 supportedSearchType 反射，缺省不限制', () async {
    final rt = await PomeloPluginRuntime.create();
    addTearDown(rt.dispose);
    final loaded = await rt.loadPlugin(_searchScript, name: 'search');

    expect(loaded.supportedSearchTypes, ['music']);
    // 声明外的类型被裁剪成空，且不打网络。
    expect((await rt.search('x', type: 'sheet'))['data'], isEmpty);
    expect((await rt.search('x', type: 'music'))['data'], isNotEmpty);
    // isEnd 缺省视为已到末页。
    expect((await rt.search('x', type: 'music'))['isEnd'], isTrue);
  });
}

/// 回显实参个数与 musicItem.sourceKey。
const _argEchoScript = r'''
module.exports = {
  platform: '参数回显',
  version: '1.0.0',
  async search() { return { isEnd: true, data: [] }; },
  async getMediaSource(musicItem, quality) {
    return { url: 'https://example.test/' + arguments.length + '|' + (musicItem.sourceKey || '') };
  },
};
''';

/// 只声明 music 类型、且 search 不返回 isEnd。
const _searchScript = r'''
module.exports = {
  platform: '搜索类型',
  version: '1.0.0',
  supportedSearchType: ['music'],
  async search(query, page, type) {
    return { data: [{ id: '1', title: 't', artist: 'a' }] };
  },
};
''';
