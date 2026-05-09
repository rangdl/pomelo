import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/services/source/source.dart';

class AudioSourcesProvider extends Notifier<List<SourceManager>> {
  @override
  List<SourceManager> build() {
    ref.onDispose(() {
      for (final sm in state) {
        sm.dispose();
      }
    });
    return [];
  }

  load(String script) async {
    final source = SourceManager(script, enable: true);
    await source.init();
    state = [...state, source];
  }

  enableSwitch(String id, bool enable) async {
    state = state
        .map((v) => v.id == id ? v.copyWith(enable: enable) : v)
        .toList();
  }

  musicUrl() async {
    final sources = state.where((v) => v.enable).toList();
    if (sources.isNotEmpty) {
      for (final source in sources) {
        final url = await source.musicUrl({
          'source': 'tx',
          "songmid": "0039MnYb0qxYhV",
        });
        print('从 ${source.name} 获取到播放链接: $url');
      }
    }
  }
}

final audioSourcesProvider =
    NotifierProvider<AudioSourcesProvider, List<SourceManager>>(
      () => AudioSourcesProvider(),
    );
