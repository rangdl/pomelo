# Song → Track 重构最终收尾计划

## 概述

承接已批准并执行的重构任务。模型层（Track/Album/Artist/Playlist + `@immutable` + `copyWith` + `tryParseDateTime`）和大部分模块/UI 层已完成。本计划完成**最后阻断编译的残留工作**：5 个 UI 文件的迁移未完成 + 10 个文件的 nullable 字段访问编译错误。

**核心根因**：`build_runner` 重新生成 freezed 文件时回退了部分 UI 编辑；同时新 Track 模型将 `artist`、`source`、`meta` 设为可空（`String?` / `(...)? ` / `Map?`），导致旧代码直接访问 `track.source.id`、`track.artist`、`Text(track.artist)` 等出现空安全编译错误。

---

## 当前状态分析

### 已完成（无需修改）
- 模型文件：`track.dart`、`album.dart`、`artist.dart`、`playlist.dart`、`models.dart` — 全部 `@immutable` + `copyWith` + `tryParseDateTime`
- `lib/core/extensions/date_time.dart` — `tryParseDateTime(dynamic)`
- `state.freezed.dart` / `state.g.dart` — 已重新生成
- `mini_player.dart`、`media.dart`、`persistent_repository.dart`、`fluxy_boot_test.dart` — 已迁移
- `music_ui_providers.dart`（`leaderboardTracksProvider`、`currentSourceTracksProvider`、`SearchListData.tracks`）、`music_section.dart`、`leaderboard_section.dart`、`track_tile.dart`、`track_list.dart`（组件结构）、`track_more_actions_button.dart`、`play_all_button.dart`、`play_pause_button.dart` — 已迁移
- `home_page.dart` 的 `_LeaderboardSongs`（L327-352）— 已正确使用 `leaderboardTracksProvider` + `TrackTile`

### 待修改文件清单（15 个文件）

**A. UI 迁移未完成（5 个文件，阻断编译）**

| 文件 | 残留问题 |
|------|----------|
| `lib/ui/music/search_page.dart` | L318 `data.songs`（应为 `data.tracks`）、L323/348 `songs` 变量；L355/357 已用 `tracks` 但变量未定义 → 当前已编译错误 |
| `lib/ui/music/playlist_detail_page.dart` | L11 import `song_list.dart`、L19-20 `playlistSongsProvider`+`List<Song>`、L26 `getPlaylistSongs`、L51/135 引用 |
| `lib/ui/music/playlist_section.dart` | L306-309 `playlist.coverUrl`、L330/334 `playlist.creator` |
| `lib/ui/home/home_page.dart` | L792-793 `playlist.coverUrl`/`playlist.creator`、L829/833 `playlist.creator`（`_PlaylistCard`，注意 L809 已用 `coverArt`） |
| `lib/ui/player/widgets/play_queue_content.dart` | L71-92 `song` 变量、`SongTile`、`SongMoreActionsButton`、`PlayPauseButton(song:)` |

**B. Nullable 字段访问编译错误（10 个文件）**

| 文件 | 行号 | 问题 | 修复 |
|------|------|------|------|
| `lib/ui/player/playback_page.dart` | 234, 479 | `track.artist` 传入 `Text()` | `track.artist ?? ''` |
| `lib/ui/player/lyric_view.dart` | 19 | `song.source.id`（source 可空） | `song.source?.id ?? ''` |
| `lib/ui/music/model/merged_track.dart` | 30, 34, 38 | `track.source.id` / `[track.source]`（source 可空） | `?.id` + null 检查列表构造 |
| `lib/ui/music/track_list.dart` | 39 | `track.source.name`（source 可空） | `track.source?.name ?? ''` |
| `lib/modules/audio_player/providers/audio_player.dart` | 6 | `import 'package:media_kit/media_kit.dart';` 缺 `hide Track` → `Track` 与 media_kit 歧义 | 加 `hide Track` |
| `lib/modules/audio_player/audio_player_module.dart` | 95 | `track.source.id`（source 可空） | 提取 `sourceId` + null 早返回 |
| `lib/modules/music_lx/model/lx_music_service.dart` | 239 | `track.source.libraryId` | `track.source?.libraryId` |
| `lib/modules/music_lx/model/lx_source_engine.dart` | 176 | `{...track.meta}`（meta 可空 Map） | `{...?track.meta}` |
| `lib/modules/music_lx_server/repository/lx_server_music_service.dart` | 294, 296, 317, 318 | `Map.from(track.meta)`（meta 可空）+ `track.source.libraryId` | `track.meta ?? {}` + `track.source?.libraryId` |
| `lib/modules/music_local/local_music_providers.dart` | 94 | `service?.songCount`（LocalMusicService 无此 getter，实为 `trackCount`） | `service?.trackCount` |

### 不修改（已验证正确或属 API 契约保留）
- `SubsonicSong`、`LxServerSong`、`client.getSong()`、`client.getLeaderboardSongs()` — API 契约
- `subsonic_client.dart:152` 注释 `Album/Song Lists` — 不影响编译
- `audio_player.dart:388` 注释 `as SongFull` — 不影响编译
- `PlaylistDetailPage` 构造参数 `coverUrl`/`creator` — 路由生成文件依赖，保留参数名

---

## 已确立的约定（沿用前次计划）

1. `SearchListData.tracks`（非 `songs`）— 已是字段名，`search_page.dart` 需对齐
2. `getPlaylistTracks`（非 `getPlaylistSongs`）— `MusicService` 抽象类已用此名
3. `leaderboardTracksProvider`、`currentSourceTracksProvider` — 已存在
4. `LocalMusicService.trackCount`（非 `songCount`）— 实际 getter 名
5. Track 的 `source`/`meta`/`artist` 为可空，访问需 `?.` 或 `?? ''`
6. `playlist.coverUrl` → `playlist.coverArt`；`playlist.creator` → `playlist.owner ?? ''`

---

## 实施步骤

### Step 1：完成 UI 文件迁移（5 个文件）

#### 1.1 `lib/ui/music/search_page.dart`
- **L318** `final songs = data.songs;` → `final tracks = data.tracks;`
- **L323** `if (songs.isEmpty)` → `if (tracks.isEmpty)`
- **L348** `'找到 ${songs.length} 首歌曲'` → `'找到 ${tracks.length} 首歌曲'`
- L355/357 已用 `tracks`（修复 L318 后即可编译）

#### 1.2 `lib/ui/music/playlist_detail_page.dart`
- **L11** `import 'package:pomelo/ui/music/song_list.dart';` → `import 'package:pomelo/ui/music/track_list.dart';`
- **L19-20** `final playlistSongsProvider = FutureProvider.family<List<Song>, ...>` → `final playlistTracksProvider = FutureProvider.family<List<Track>, ...>`
- **L26** `service.getPlaylistSongs(params.playlistId)` → `service.getPlaylistTracks(params.playlistId)`
- **L51** `playlistSongsProvider((sourceId: sourceId, playlistId: playlistId))` → `playlistTracksProvider(...)`
- **L135** `playlistSongsProvider(` → `playlistTracksProvider(`
- 注：L93 `TrackList`、L80 `tracks:`、L231 `PlayAllButton(tracks:)` 已正确

#### 1.3 `lib/ui/music/playlist_section.dart`（仅 `_PlaylistCard` 的 cover/creator 访问）
- **L306** `playlist.coverUrl != null &&` → `playlist.coverArt != null &&`
- **L307** `playlist.coverUrl!.isNotEmpty` → `playlist.coverArt!.isNotEmpty`
- **L309** `playlist.coverUrl!` → `playlist.coverArt!`
- **L330** `if (playlist.creator.isNotEmpty)` → `if ((playlist.owner ?? '').isNotEmpty)`
- **L334** `playlist.creator,` → `playlist.owner ?? '',`
- 注：L291-292 已正确使用 `playlist.coverArt` / `playlist.owner ?? ''`

#### 1.4 `lib/ui/home/home_page.dart`（`_PlaylistCard`，L775 起）
- **L792** `coverUrl: playlist.coverUrl,` → `coverUrl: playlist.coverArt,`
- **L793** `creator: playlist.creator,` → `creator: playlist.owner ?? '',`
- **L829** `if (playlist.creator.isNotEmpty)` → `if ((playlist.owner ?? '').isNotEmpty)`
- **L833** `playlist.creator,` → `playlist.owner ?? '',`
- 注：L809-811 已正确使用 `playlist.coverArt`

#### 1.5 `lib/ui/player/widgets/play_queue_content.dart`（L71-92）
- **L71** `final song = tracks[index];` → `final track = tracks[index];`
- **L72** `activeTrack?.id == song.id` → `activeTrack?.id == track.id`
- **L73-74** `return SongTile(\n  song: song,` → `return TrackTile(\n  track: track,`
- **L85** `PlayPauseButton(song: song),` → `PlayPauseButton(track: track),`
- **L86-88** `SongMoreActionsButton(\n  song: song,\n  onRemoveFromQueue: () => notifier.removeTrack(song.id),` → `TrackMoreActionsButton(\n  track: track,\n  onRemoveFromQueue: () => notifier.removeTrack(track.id),`
- **L92** `onTap: () => notifier.jumpToTrack(song),` → `onTap: () => notifier.jumpToTrack(track),`
- 注：imports（L7-8）已正确

### Step 2：修复 Nullable 字段访问（10 个文件）

#### 2.1 `lib/ui/player/playback_page.dart`
- **L234** `track.artist,` → `track.artist ?? '',`
- **L479** `track.artist,` → `track.artist ?? '',`

#### 2.2 `lib/ui/player/lyric_view.dart`
- **L19** `module?.service(song.source.id)` → `module?.service(song.source?.id ?? '')`

#### 2.3 `lib/ui/music/model/merged_track.dart`
- **L30** `existing.sources.any((s) => s.id == track.source.id)` → `existing.sources.any((s) => s.id == track.source?.id)`
- **L34** `sources: [...existing.sources, track.source],` → `sources: [...existing.sources, if (track.source != null) track.source],`
- **L38** `sources: [track.source]` → `sources: [if (track.source != null) track.source]`

#### 2.4 `lib/ui/music/track_list.dart`
- **L39** `Text(track.source.name).muted,` → `Text(track.source?.name ?? '').muted,`

#### 2.5 `lib/modules/audio_player/providers/audio_player.dart`
- **L6** `import 'package:media_kit/media_kit.dart';` → `import 'package:media_kit/media_kit.dart' hide Track;`

#### 2.6 `lib/modules/audio_player/audio_player_module.dart`
- **L95** `final service = musicModule.service(track.source.id);` → 提取并早返回：
  ```dart
  final sourceId = track.source?.id;
  if (sourceId == null) return track.src ?? track.path ?? '';
  final service = musicModule.service(sourceId);
  ```

#### 2.7 `lib/modules/music_lx/model/lx_music_service.dart`
- **L239** `final libraryId = track.source.libraryId ?? _defaultLibraryId;` → `final libraryId = track.source?.libraryId ?? _defaultLibraryId;`

#### 2.8 `lib/modules/music_lx/model/lx_source_engine.dart`
- **L176** `'musicInfo': {...track.meta},` → `'musicInfo': {...?track.meta},`

#### 2.9 `lib/modules/music_lx_server/repository/lx_server_music_service.dart`
- **L294** `final songInfo = Map<String, dynamic>.from(track.meta);` → `final songInfo = Map<String, dynamic>.from(track.meta ?? {});`
- **L296** `songInfo['source'] ??= track.source.libraryId ?? _currentSource;` → `track.source?.libraryId ?? _currentSource;`
- **L317** `final songInfo = Map<String, dynamic>.from(track.meta);` → `Map<String, dynamic>.from(track.meta ?? {});`
- **L318** `songInfo['source'] ??= track.source.libraryId ?? _currentSource;` → `track.source?.libraryId ?? _currentSource;`

#### 2.10 `lib/modules/music_local/local_music_providers.dart`
- **L94** `return service?.songCount ?? 0;` → `return service?.trackCount ?? 0;`

### Step 3：验证

1. **静态分析**：
   ```powershell
   flutter analyze
   ```
   预期：0 errors

2. **Grep 残留检查**（在 lib/ 中应 0 匹配）：
   - `data\.songs`、`\bSong\b`（除 `SubsonicSong`/`LxServerSong`/注释）
   - `playlist\.coverUrl`、`playlist\.creator`
   - `playlistSongsProvider`、`getPlaylistSongs`
   - `SongTile`、`SongMoreActionsButton`、`song_tile\.dart`、`song_list\.dart`、`song_more_actions_button\.dart`
   - `track\.source\.`（不应出现未用 `?.` 的直接访问，除 `source!`）
   - `service\?\.songCount`

---

## 假设与风险

1. **假设**：`SearchListData.tracks`、`MusicService.getPlaylistTracks`、`leaderboardTracksProvider`、`LocalMusicService.trackCount` 均已存在（已通过 Grep 验证）。
2. **风险**：`audio_player.dart` 加 `hide Track` 后，文件内若使用 media_kit 的 `Track` 类型会报错。检查显示该文件仅使用 pomelo 的 `Track`（L32/36/370 等均为 `Iterable<Track>`/`List<Track>`），无 media_kit Track 用法，安全。
3. **风险**：`merged_track.dart` 用 collection-if 构造列表，类型推断应得到 `List<(...)>`（非空），与 `MergedTrack.sources` 字段类型一致。
4. **不修改**：`subsonic_client.dart`、`lx_server_client.dart` 等 API 契约文件中的 `Song` 命名。
