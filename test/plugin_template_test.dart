import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/plugins/runtime/pomelo_plugin_runtime.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('插件模板可加载、能力齐全、可返回播放地址', () async {
    final rt = await PomeloPluginRuntime.create();
    addTearDown(rt.dispose);

    final loaded = await rt.loadPlugin(
      File('docs/plugin-template.js').readAsStringSync(),
      name: 'template',
    );

    expect(loaded.isLxCompat, isFalse);
    expect(loaded.platform, '示例平台');
    expect(loaded.version, '1.0.0');
    expect(loaded.srcUrl, isNotNull);
    expect(loaded.supportedMethods, contains('search'));
    expect(loaded.supportedMethods, isNot(contains('getSearchSuggestions')));
    expect(loaded.supportedMethods, isNot(contains('getArtistInfo')));
    expect(loaded.supportedMethods, contains('getTopLists'));
    expect(loaded.supportedMethods, contains('getTopListDetail'));
    expect(loaded.supportedMethods, contains('getRecommendSheetTags'));
    expect(loaded.supportedMethods, contains('getRecommendSheetsByTag'));
    expect(loaded.supportedMethods, contains('getMusicSheetInfo'));
    expect(loaded.supportedMethods, contains('importMusicSheet'));
    expect(loaded.supportedMethods, contains('importMusicItem'));
    expect(loaded.supportedMethods, contains('getArtistWorks'));
    expect(loaded.supportedMethods, contains('getAlbumInfo'));
    expect(loaded.supportedMethods, contains('getMusicInfo'));
    expect(loaded.supportedMethods, contains('getMusicComments'));
    expect(loaded.supportedMethods, contains('getLyric'));
    expect(loaded.supportedMethods, contains('getMediaSource'));
    expect(loaded.sourceKeys, ['kw']);
    expect(loaded.supportedSearchTypes, contains('music'));
    expect(loaded.defaultSearchType, 'music');

    final search = await rt.search('测试');
    expect(search['data'], isA<List>());
    // 模板只声明了 4 类搜索，lyric 应被裁剪成空结果。
    expect((await rt.search('测试', type: 'lyric'))['data'], isEmpty);
    expect((await rt.getRecommendSheetTags()).first['id'], 'tag-1');

    final source = await rt.getMediaSource({'id': '1'}, 'high');
    expect(source, isNotNull);
    expect(source!['url'], startsWith('https://'));
    expect(source['quality'], 'high');
  });
}
