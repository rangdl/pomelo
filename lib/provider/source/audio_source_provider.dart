// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_js/quickjs/ffi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/models/database/database.dart';
import 'package:pomelo/models/metadata/metadata.dart';
import 'package:pomelo/provider/database/database.dart';
import 'package:pomelo/services/dio/dio.dart';
import 'package:pomelo/services/js_engine/js_engine.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/services/sourced_track/sourced_track.dart';

// 音源文件添加之后存储到数据库
class SourcesNotifier extends StreamNotifier<List<SourceTableData>> {
  @override
  Stream<List<SourceTableData>> build() {
    final database = ref.watch(databaseProvider);
    return database.select(database.sourceTable).watch();
  }

  Future<void> add(String script) async {
    var sourceInfo = AudioSourceJsEngine.parseLxMusicScriptInfo(script);
    final database = ref.read(databaseProvider);
    await database
        .into(database.sourceTable)
        .insert(
          SourceTableCompanion.insert(
            name: sourceInfo['name'] ?? '',
            description: sourceInfo['description'] ?? '',
            author: sourceInfo['author'] ?? '',
            homepage: sourceInfo['homepage'] ?? '',
            version: sourceInfo['version'] ?? '',
            rawScript: script,
            enable: true,
          ),
          mode: InsertMode.insert,
        );
  }

  Future<void> addRemote(String url) async {
    final res = await globalDio.get(url);
    if (res.statusCode == 200) {
      await add(res.toString());
    }
  }

  Future<void> enableSwitch(int id, bool enable) async {
    final database = ref.read(databaseProvider);
    await (database.update(database.sourceTable)
          ..where((tbl) => tbl.id.equals(id)))
        .write(SourceTableCompanion(enable: Value(enable)));
  }

  Future<void> del(int id) async {
    final database = ref.read(databaseProvider);
    await (database.delete(
      database.sourceTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }
}

final sourcesProvider =
    StreamNotifierProvider<SourcesNotifier, List<SourceTableData>>(
      SourcesNotifier.new,
    );

class AudioSourceRuntime {
  final int id;
  final bool enable;
  final bool inited; // 初始化完成
  final String script;
  final AudioSourceJsEngine? jsEngine;
  AudioSourceRuntime({
    required this.id,
    required this.enable,
    required this.inited,
    required this.script,
    required this.jsEngine,
  });
}

class AudioSourcesNotifier extends Notifier<List<AudioSourceRuntime>> {
  final _inited = Completer<bool>();
  @override
  List<AudioSourceRuntime> build() {
    final database = ref.read(databaseProvider);
    database
        .select(database.sourceTable)
        .get()
        .then((sources) => _init(sources));
    ref.listen(sourcesProvider, (cb, _) {
      cb?.whenData((sources) => _init(sources));
    });
    return [];
  }

  Future<void> _init(List<SourceTableData> sources) async {
    for (final source in sources) {
      if (state.indexWhere((v) => v.id == source.id) == -1) {
        if (source.enable) {
          final jsEngine = await AudioSourceJsEngine.formScript(source);
          final inited = await jsEngine.init();
          state = [
            ...state,
            AudioSourceRuntime(
              id: source.id,
              enable: source.enable,
              inited: inited,
              script: source.rawScript,
              jsEngine: inited ? jsEngine : null,
            ),
          ];
        }
      } else {
        // 禁用之后从列表中移除
        if (!source.enable) {
          state.removeWhere((v) {
            final s = v.id == source.id;
            if (s) {
              v.jsEngine?.dispose();
            }
            return s;
          });
          state = [...state];
        }
      }
    }
    if (!_inited.isCompleted) {
      _inited.complete(true);
    }
  }

  Future<String?> musicUrl(Map<String, String> track) async {
    if (!_inited.isCompleted) {
      // 等待源初始化完成
      await _inited.future;
    }
    final sources = state.where((v) => v.enable).toList();
    if (sources.isNotEmpty) {
      for (final source in sources) {
        try {
          final url = await source.jsEngine?.musicUrl(track);
          print('从 ${source.jsEngine?.name} 获取到播放链接: $url');
          return url;
        } catch (e) {
          AppLogger.reportError(e, StackTrace.current);
        }
      }
    }
    return '';
  }

  Future<String?> musicUrl2(
    SpotubeFullTrackObject query, {
    quality = '128k',
  }) async {
    if (!_inited.isCompleted) {
      // 等待源初始化完成
      await _inited.future;
    }
    final sources = state.where((v) => v.enable).toList();
    if (sources.isNotEmpty) {
      for (final source in sources) {
        if (source.jsEngine == null) {
          continue;
        }
        try {
          final url = await source.jsEngine!.musicUrl(
            query.meta?.toJson() ?? {},
            quality: quality,
          );
          print('从 ${source.jsEngine?.name} 获取到播放链接: $url');
          return url;
        } catch (e) {
          AppLogger.reportError(e, StackTrace.current);
        }
      }
    }
    return null;
  }
}

final audioSourcesProvider =
    NotifierProvider<AudioSourcesNotifier, List<AudioSourceRuntime>>(
      AudioSourcesNotifier.new,
    );

final audioSourceProvider = Provider.family<AudioSourceRuntime?, int>((
  ref,
  id,
) {
  final audioSources = ref.watch(audioSourcesProvider);
  return audioSources.firstWhereOrNull((v) => v.id == id);
});

// class AudioSourcesProvider extends Notifier<List<SourceManager>> {
//   @override
//   List<SourceManager> build() {
//     ref.onDispose(() {
//       for (final sm in state) {
//         sm.dispose();
//       }
//     });
//     return [];
//   }

//   load(String script) async {
//     final source = SourceManager(script, enable: true);
//     await source.init();
//     state = [...state, source];
//   }

//   enableSwitch(String id, bool enable) async {
//     state = state
//         .map((v) => v.id == id ? v.copyWith(enable: enable) : v)
//         .toList();
//   }

//   remove(String id) {
//     final source = state.firstWhereOrNull((v) => v.id == id);
//     if (source != null) {
//       if (state.remove(source)) {
//         state = [...state];
//         source.dispose();
//       }
//     }
//   }

//   Future<String> musicUrl(Map<String, String> track) async {
//     final sources = state.where((v) => v.enable).toList();
//     if (sources.isNotEmpty) {
//       for (final source in sources) {
//         try {
//           final url = await source.musicUrl(track);
//           print('从 ${source.name} 获取到播放链接: $url');
//           return url;
//         } catch (e) {
//           AppLogger.reportError(e, StackTrace.current);
//         }
//       }
//     }
//     return '';
//   }
// }

// final audioSourcesProvider =
//     NotifierProvider<AudioSourcesProvider, List<SourceManager>>(
//       AudioSourcesProvider.new,
//     );
