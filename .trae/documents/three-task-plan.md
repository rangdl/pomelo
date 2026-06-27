# 三项功能改造计划

## 概述

1. **Lx Server 播放链接 HEAD 校验 + 质量降级** — 获取播放链接后通过 HEAD 请求校验，无效则降级重试
2. **日志页面每次打开重新加载** — 进入日志页时自动刷新数据
3. **首页平台/库切换按钮分离** — 平台按钮仅切换平台，新增左侧库切换按钮（仅多库时显示）

---

## Task 1: Lx Server 播放链接 HEAD 校验 + 质量降级

### 问题分析

当前流程：`headStreamTrackId` → `streamTrackInformation` → `_resolveUrl`（带缓存）→ `getTrackUrl` 回调 → `LxServerMusicService.getMusicUrl`（内部 `_selectQuality` 按可用性降级）→ 返回 URL → `dio.head(url)`

**缺失**：HEAD 请求失败后不会降级质量重试。`_selectQuality` 仅基于 `_types` 标记的可用性选择，但标记可用不代表 URL 实际有效（可能 403/404）。

### 改动方案

#### 1.1 修改 `getTrackUrl` 签名（playback.dart L45）

```
// 旧
final Future<String> Function(Track track)? getTrackUrl;
// 新
final Future<String> Function(Track track, {String? forcedQuality})? getTrackUrl;
```

#### 1.2 修改 `_resolveUrl`（playback.dart L63）

添加 `String? forcedQuality` 参数，传递给 `getTrackUrl`：

```dart
Future<String> _resolveUrl(Track track, {String? forcedQuality}) async {
  final cached = _urlCache[track.id];
  if (cached != null && cached.isNotEmpty && forcedQuality == null) return cached;
  String url = track.src ?? track.path ?? '';
  if (getTrackUrl != null) {
    try {
      final resolved = await getTrackUrl!(track, forcedQuality: forcedQuality);
      if (resolved.isNotEmpty) url = resolved;
    } catch (e) {
      log.error('Playback', 'getMusicUrl 失败: $e', error: e);
    }
  }
  if (forcedQuality == null) _urlCache[track.id] = url;
  return url;
}
```

#### 1.3 重写 `streamTrackInformation`（playback.dart L163-212）

实现 HEAD 校验 + 质量降级循环：

```dart
Future<dio_lib.Response> streamTrackInformation(
  Request request,
  Track track,
) async {
  log.debug('Playback', 'HEAD request for track: ${track.title}');

  // 获取可用音质列表
  final meta = track.meta ?? {};
  final typesMap = (meta['_types'] as Map<String, dynamic>?) ?? const {};
  const priority = ['flac24bit', 'flac', '320k', '128k'];
  final availableQualities = priority.where((q) => typesMap.containsKey(q)).toList();
  if (availableQualities.isEmpty) availableQualities.add('128k');

  // 第一次尝试：用户偏好（不强制 quality，由 _selectQuality 决定）
  try {
    final url = await _resolveUrl(track);
    final res = await _headValidate(url);
    if (res.statusCode! < 400) {
      return res;
    }
    log.warning('Playback', 'HEAD 失败(偏好音质), status=${res.statusCode}, 尝试降级');
  } catch (e) {
    log.warning('Playback', 'HEAD 请求失败(偏好音质): $e, 尝试降级');
  }

  // 降级重试：从最高可用音质逐个尝试（forcedQuality 绕过 _selectQuality）
  for (final quality in availableQualities) {
    clearUrlCache(track.id);
    try {
      final url = await _resolveUrl(track, forcedQuality: quality);
      final res = await _headValidate(url);
      if (res.statusCode! < 400) {
        _urlCache[track.id] = url;
        log.info('Playback', 'HEAD 成功, quality=$quality');
        return res;
      }
      log.warning('Playback', 'HEAD 失败 quality=$quality, status=${res.statusCode}');
    } catch (e) {
      log.warning('Playback', 'HEAD 请求失败 quality=$quality: $e');
    }
  }

  // 所有音质均失败
  log.error('Playback', '所有音质均无法获取有效播放链接: ${track.title}');
  throw Exception('无法获取有效的播放链接');
}

Future<dio_lib.Response> _headValidate(String url) async {
  final options = Options(
    headers: {
      "Cache-Control": "max-age=3600",
      "Connection": "keep-alive",
      "host": Uri.parse(url).host,
    },
    validateStatus: (status) => true, // 不抛异常，手动判断
  );
  return dio.head(url, options: options);
}
```

#### 1.4 更新 `headStreamTrackId`（playback.dart L342）

捕获降级穷尽异常，返回有意义的错误：

```dart
Future<Response> headStreamTrackId(Request request, String trackId) async {
  try {
    final activeTrack = getActiveTrack();
    if (activeTrack == null || activeTrack.src == null) {
      return Response.notFound('No active track or track is not streamable');
    }
    final res = await streamTrackInformation(request, activeTrack);
    return Response(res.statusCode!, headers: _sanitizeHeaders(res.headers.map));
  } on Exception catch (e) {
    log.error('Playback', e.toString(), error: e);
    return Response.internalServerError(body: e.toString());
  } catch (e, stack) {
    log.error('Playback', e.toString(), error: e, stackTrace: stack);
    return Response.internalServerError();
  }
}
```

#### 1.5 更新 `audio_player_module.dart` 回调（L90-102）

```dart
getTrackUrl: (Track track, {String? forcedQuality}) async {
  final musicModule = ModuleManager().find<MusicModule>('music');
  if (musicModule == null) return track.src ?? track.path ?? '';
  final sourceId = track.source?.id;
  if (sourceId == null) return track.src ?? track.path ?? '';
  final service = musicModule.service(sourceId);
  if (service == null) return track.src ?? track.path ?? '';
  final preferredQuality = forcedQuality ?? Settings.get(StorageKeys.musicLxServerQuality);
  return service.getMusicUrl(track, quality: preferredQuality);
},
```

### 涉及文件

| 文件 | 改动 |
|------|------|
| [playback.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/modules/audio_player/providers/playback.dart) | `getTrackUrl` 签名、`_resolveUrl` 参数、`streamTrackInformation` 重写、`headStreamTrackId` 异常处理、新增 `_headValidate` |
| [audio_player_module.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/modules/audio_player/audio_player_module.dart) | 回调适配 `forcedQuality` 参数 |

---

## Task 2: 日志页面每次打开重新加载

### 问题分析

`latestLogsProvider` / `logLevelStatsProvider` / `logTagsProvider` 是非 autoDispose 的 FutureProvider，首次加载后缓存，再次进入页面不会刷新。

### 改动方案

在 `_LogContent.build()` 中用 `useEffect` 进入时 invalidate 三个 Provider：

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  useEffect(() {
    ref.invalidate(latestLogsProvider);
    ref.invalidate(logLevelStatsProvider);
    ref.invalidate(logTagsProvider);
    return null;
  }, []);
  // ... 其余不变
}
```

### 涉及文件

| 文件 | 改动 |
|------|------|
| [log_page.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/log/log_page.dart) | `_LogContent.build` 添加 `useEffect` invalidate |

---

## Task 3: 首页平台/库切换按钮分离

### 问题分析

当前 `SourceSwitchButton` 的对话框同时展示平台和库（多库服务展开子选项），用户希望：
- 平台按钮仅切换平台（不显示库）
- 左侧新增库切换按钮（仅多库时显示）

### 改动方案

#### 3.1 简化 `SourceSwitchButton`（music_section.dart L14-164）

- 对话框移除库子选项，仅展示平台名称
- 选中平台时调用 `select(service.sourceId)` 不传 libraryId
- 显示名称仅显示服务名（不显示库名）

#### 3.2 新增 `LibrarySwitchButton`（music_section.dart 新增类）

```dart
class LibrarySwitchButton extends HookConsumerWidget {
  const LibrarySwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(musicServicesProvider);
    final selection = ref.watch(selectedSourceProvider);

    return servicesAsync.when(
      data: (services) {
        if (selection.sourceId == null) return const SizedBox.shrink();
        final service = services.where((s) => s.sourceId == selection.sourceId).firstOrNull;
        if (service == null || service.libraries.length <= 1) {
          return const SizedBox.shrink();
        }
        // 当前库名
        final currentLibId = selection.libraryId ?? service.defaultLibraryId;
        final currentLibName = service.libraries
            .where((l) => l.id == currentLibId)
            .firstOrNull?.name ?? '选择库';

        return GhostButton(
          size: ButtonSize.small,
          onPressed: () => _showLibraryPicker(context, ref, service, selection.sourceId!),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.library_music, size: 16),
              const SizedBox(width: 4),
              Text(currentLibName),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showLibraryPicker(BuildContext context, WidgetRef ref, MusicService service, String sourceId) {
    // showDialog 或 showDropdown 展示库列表
    // 选中后调用 ref.read(selectedSourceProvider.notifier).select(sourceId, libraryId: lib.id)
  }
}
```

#### 3.3 修改首页 AppBar（home_page.dart L30-47）

```dart
AppBar(
  leading: [const LibrarySwitchButton()],
  title: SizedBox(height: 36, child: TextField(...)),
  trailing: [const SourceSwitchButton()],
),
```

### 涉及文件

| 文件 | 改动 |
|------|------|
| [music_section.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/music/music_section.dart) | 简化 `SourceSwitchButton`、新增 `LibrarySwitchButton` |
| [home_page.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/home/home_page.dart) | AppBar 添加 `leading: [LibrarySwitchButton()]` |

---

## 验证

1. `flutter analyze` 确认 0 errors
2. Task 1：Lx Server 播放时观察日志，确认 HEAD 校验 + 降级逻辑触发
3. Task 2：进入日志页 → 离开 → 再次进入，确认数据刷新
4. Task 3：首页切换平台不显示库列表；选中 Lx Server 后左侧出现库切换按钮；选中本地音乐后库按钮消失
