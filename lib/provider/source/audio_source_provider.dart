import 'package:flutter_js/quickjs/ffi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/services/logger/logger.dart';
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

  remove(String id) {
    final source = state.firstWhereOrNull((v) => v.id == id);
    if (source != null) {
      if (state.remove(source)) {
        state = [...state];
        source.dispose();
      }
    }
  }

  musicUrl() async {
    final sources = state.where((v) => v.enable).toList();
    if (sources.isNotEmpty) {
      for (final source in sources) {
        try {
          final url = await source.musicUrl({
            'source': 'tx',
            "songmid": "0039MnYb0qxYhV",
          });
          print('从 ${source.name} 获取到播放链接: $url');
        } catch (e) {
          AppLogger.reportError(e, StackTrace.current);
        }
      }
    }
  }
}

final audioSourcesProvider =
    NotifierProvider<AudioSourcesProvider, List<SourceManager>>(
      () => AudioSourcesProvider(),
    );
