# Track 模型重构 — 收尾实施计划

## 概述

本计划承接前序会话已完成的工作，将 `Song` 类到 `Track` 类的重命名推广到剩余的所有消费方文件，使项目恢复编译并通过 `flutter analyze`。

### 当前状态

**已完成（前序会话）：**
- 模型层：`track.dart`、`artist.dart`、`album.dart`、`playlist.dart`、`leaderboard.dart` 均已按新 schema 重写，带 `@immutable`、`copyWith`、`fromJson`/`toJson`、`tryParseDateTime`
- `date_time.dart` 扩展（健壮的 DateTime 解析）已创建
- `models.dart` 已导出 `track.dart` + `artist.dart`，`song.dart` 已删除
- `music_service.dart` 接口已重命名方法（`searchTracks`/`getTrack`/`getTracks`/`getAlbumTracks`/`getPlaylistTracks`/`getLeaderboardTracks`，`getMusicUrl(Track)`，`getLyric(Track)`）
- `music_module.dart`、`module_providers.dart` 已更新
- Subsonic: `subsonic_models.dart`（`toTrack`）、`subsonic_music_service.dart` 已更新
- Local: `local_music_service.dart` 已更新

**待完成（本计划）：**
- Lx 模块 3 个文件
- LxServer 模块 2 个文件
- AudioPlayer 模块 8 个文件
- UI 层 ~13 个文件（含 4 个文件重命名）
- 测试文件 1 个
- `persistent_repository.dart` 文档示例
- `build_runner` 重新生成 freezed/json 文件

### 当前编译状态

项目当前处于**不可编译**状态：`song.dart` 已删除，但 18 个文件仍 `import 'song.dart'`，且大量消费方仍引用 `Song`/`SongFull`/`SongLocal` 类型及旧字段名。

---

## 决策与约定

1. **保留 API 映射命名**：`SubsonicSong`、`SubsonicClient.getSong()`、`SubsonicClient.getRandomSongs()`、`SubsonicClient.getSongsByGenre()`、`SubsonicAlbum.songs`、`SubsonicSearchResult3.songs` 保持不变（映射 Subsonic REST API 的 "song" 术语/JSON 字段名）
2. **保留 `LxServerSong`** 类名及 `LxServerClient.getLeaderboardSongs()` 方法名（内部 HTTP 客户端层，与 API 响应模型对应）
3. **保留 `PlaylistDetailPage` 构造参数名** `coverUrl`/`creator` 不变（避免触发 auto_route 的 `app_router.gr.dart` 重新生成；仅更新调用方传入的值）
4. **union type 扁平化**：`SongFull`/`SongLocal` → 单一 `Track` 类，通过 `track.src`/`track.path`/`track.isLocal` 区分
5. **`.map(full:..., local:...)` 模式替换**：
   - `track.map(full: (f) => f.src, local: (l) => l.path)` → `track.src ?? track.path`
   - `track.map(full: (f) => f.coverUrl, local: (l) => null)` → `track.coverArt`
   - `track.map(full: (f) => f.albumName, local: (l) => null)` → `track.album`
6. **字段映射**（Track）：`.name`→`.title`、`.albumName`→`.album`、`.coverUrl`→`.coverArt`
7. **字段映射**（Playlist）：`.coverUrl`→`.coverArt`、`.creator`→`.owner`、`.description`→`.comment`、`.songs`→`.tracks`
8. **类型判断替换**：`track is SongFull` → `track.src != null`；`track is SongLocal` → `track.path != null`；`track is! SongFull` → `track.src == null`
9. **UI 文件重命名**：`song_tile.dart`→`track_tile.dart`、`song_list.dart`→`track_list.dart`、`song_more_actions_button.dart`→`track_more_actions_button.dart`、`merged_song.dart`→`merged_track.dart`
10. **类名重命名**：`SongTile`→`TrackTile`、`SongList`→`TrackList`、`SongMoreActionsButton`→`TrackMoreActionsButton`、`SongMoreActionsContent`→`TrackMoreActionsContent`、`MergedSong`→`MergedTrack`、`mergeSongs`→`mergeTracks`、`AsMediaListSong`→`AsMediaListTrack`
11. **Provider 重命名**：`currentSourceSongsProvider`→`currentSourceTracksProvider`、`playlistSongsProvider`→`playlistTracksProvider`、`leaderboardSongsProvider`→`leaderboardTracksProvider`；数据类字段 `MusicListData.songs`→`.tracks`、`SearchListData.songs`→`.tracks`
12. **`SongFull`/`SongLocal` 断言**：`AudioPlayerState` 构造函数中的 `assert(tracks.every((t) => t is SongFull || t is SongLocal))` 删除（扁平化后无意义）
13. **`starSong`/`unstarSong`**（SubsonicMusicService 便捷方法）：保持不变（Subsonic API 术语，不引用 Song 类）

---

## 实施步骤

### 步骤 1：Lx 模块（3 文件）

#### 1.1 `lib/modules/music_lx/model/lx_metadata_engine.dart`

- **import**：`models.dart` 已导入，无需改 import
- **`search` 方法**（L97）：`PaginationResponse<Song>` → `PaginationResponse<Track>`；两处 `PaginationResponse<Song>(...)` → `PaginationResponse<Track>(...)`
- **`PomeloTrackObjectMeta.toSong`**（L622）→ 重命名为 `toTrack`；`Song.full(...)` → `Track(...)`；字段映射：`name:` → `title:`、`albumName:` → `album:`、`coverUrl:` → `coverArt:`
- **`getPlaylistsDetail`**（L373）：返回类型 `List<Song>` → `List<Track>`；`.toSong(...)` → `.toTrack(...)`
- **`getLeaderboardSongs`**（L460）→ 重命名为 `getLeaderboardTracks`；返回类型 `List<Song>` → `List<Track>`；`.toSong(...)` → `.toTrack(...)`
- **Playlist 构造**（L188-196、L351-359）：`coverUrl:` → `coverArt:`、`creator:` → `owner:`、`description:` → `comment:`
- 注释中 "搜索歌曲" / "获取歌单详情" 等中文注释保留（"歌曲" 是 UI 术语，不影响编译）

#### 1.2 `lib/modules/music_lx/model/lx_music_service.dart`

- **import**：无 `import song.dart`，使用 `models.dart`，无需改
- **方法重命名**（@override）：`searchSongs`→`searchTracks`、`getSong`→`getTrack`、`getSongs`→`getTracks`、`getAlbumSongs`→`getAlbumTracks`、`getPlaylistSongs`→`getPlaylistTracks`、`getLeaderboardSongs`→`getLeaderboardTracks`
- **类型替换**：所有 `PaginationResponse<Song>` → `PaginationResponse<Track>`、`Future<Song?>` → `Future<Track?>`、`Future<List<Song>>` → `Future<List<Track>>`、`SongFull song` → `Track track`
- **`getMusicUrl`**（L233）：`SongFull song` → `Track track`；`song.source.libraryId` → `track.source.libraryId`；`sourceEngine!.getMusicUrl(libraryId, song, ...)` → `sourceEngine!.getMusicUrl(libraryId, track, ...)`
- **`getPlaylistSongs`→`getPlaylistTracks`**（L212）：`metadataEngine.getPlaylistsDetail(...)` 调用不变
- **`getLeaderboardSongs`→`getLeaderboardTracks`**（L266）：`metadataEngine.getLeaderboardSongs(...)` → `metadataEngine.getLeaderboardTracks(...)`

#### 1.3 `lib/modules/music_lx/model/lx_source_engine.dart`

- **import**（L6）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`（或 `models.dart`）
- **`getMusicUrl`**（L156）：`Song song` → `Track track`；`{...song.meta}` → `{...track.meta}`

---

### 步骤 2：LxServer 模块（2 文件）

#### 2.1 `lib/modules/music_lx_server/repository/lx_server_models.dart`

- **import**：`models.dart` 已导入，无需改
- **`LxServerSong.toSong`**（L249）→ 重命名为 `toTrack`；`Song.full(...)` → `Track(...)`；字段映射：`name:` → `title:`、`albumName:` → `album:`、`coverUrl:` → `coverArt:`
- **`LxServerSong.albumName` 字段**（L39）：保持不变（映射 lx-server API 响应字段名）
- **`LxServerPlaylist.toPlaylist`**（L303）：`coverUrl:` → `coverArt:`、`creator:` → `owner:`、`description:` → `comment:`
- 类名 `LxServerSong`/`LxServerPlaylist` 保持不变

#### 2.2 `lib/modules/music_lx_server/repository/lx_server_music_service.dart`

- **import**：`models.dart` 已导入，无需改
- **方法重命名**（@override）：`searchSongs`→`searchTracks`、`getSong`→`getTrack`、`getSongs`→`getTracks`、`getAlbumSongs`→`getAlbumTracks`、`getPlaylistSongs`→`getPlaylistTracks`、`getLeaderboardSongs`→`getLeaderboardTracks`
- **类型替换**：所有 `PaginationResponse<Song>` → `PaginationResponse<Track>`、`Future<Song?>` → `Future<Track?>`、`Future<List<Song>>` → `Future<List<Track>>`、`SongFull song` → `Track track`
- **`getMusicUrl`**（L292）：`SongFull song` → `Track track`；`song.meta` → `track.meta`；`song.source.libraryId` → `track.source.libraryId`；`song.name` → `track.title`；`song.artist` → `track.artist`；`song.id` → `track.id`
- **`getLyric`**（L316）：`SongFull song` → `Track track`；`song.meta` → `track.meta`；`song.source.libraryId` → `track.source.libraryId`；`song.id` → `track.id`
- **`getPlaylist`**（L217）：`.toSong(...)` → `.toTrack(...)`；Playlist 构造：`creator: ''` → `owner: ''`、`songs: songs` → `tracks: tracks`
- **`getPlaylistSongs`→`getPlaylistTracks`**（L243）：`.toSong(...)` → `.toTrack(...)`
- **`getLeaderboardSongs`→`getLeaderboardTracks`**（L367）：`client.getLeaderboardSongs(...)` 调用不变（客户端方法名保持）；`.toSong(...)` → `.toTrack(...)`；变量名 `songs` → `tracks`

---

### 步骤 3：AudioPlayer 模块（8 文件）

#### 3.1 `lib/modules/audio_player/model/state.dart`

- **import**（L3）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **`List<Song> tracks`**（L18、L27）→ `List<Track> tracks`
- **删除断言**（L29-33）：`assert(tracks.every((track) => track is SongFull || track is SongLocal), ...)` 整段删除
- **`activeTrack`**（L47）：`Song?` → `Track?`
- **`containsTrack`**（L52）：`Song track` → `Track track`；`t is SongLocal && track is SongLocal ? t.path == track.path : t.id == track.id` → `t.path != null && track.path != null ? t.path == track.path : t.id == track.id`
- **`containsTracks`**（L61）：`List<Song>` → `List<Track>`

#### 3.2 `lib/modules/audio_player/model/media.dart`

- **import**（L6-7）：`import 'package:pomelo/modules/music/model/models.dart' show Song` → `import 'package:pomelo/modules/music/model/models.dart' show Track`；删除 `import 'package:pomelo/modules/music/model/song.dart' show SongLocal`
- **`final Song track`**（L26）→ `final Track track`
- **构造函数**（L33-37）：`track is SongLocal ? track.path : "http://..."` → `track.path != null ? track.path! : "http://..."`
- **`Song.fromJson`**（L43）→ `Track.fromJson`

#### 3.3 `lib/modules/audio_player/providers/playback.dart`

- **import**（L7）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **`getActiveTrack`**（L39）：`Song? Function()` → `Track? Function()`
- **`getTrackUrl`**（L45）：`Future<String> Function(Song track)?` → `Future<String> Function(Track track)?`
- **`_resolveUrl`**（L63）：`Song track` → `Track track`；`track.map(full: (f) => f.src, local: (l) => l.path)` → `track.src ?? track.path`
- **`streamTrackInformation`**（L165）：`SongFull track` → `Track track`；`track.name` → `track.title`
- **`streamTrack`**（L214）：`SongFull track` → `Track track`；`track.name` → `track.title`
- **`headStreamTrackId`**（L351）：`activeTrack is! SongFull` → `activeTrack.src == null`
- **`getStreamTrackId`**（L377）：`activeTrack is! SongFull` → `activeTrack.src == null`

#### 3.4 `lib/modules/audio_player/providers/audio_player.dart`

- **import**（L14）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **`_assertAllowedTracks`**（L32）：`Iterable<Song>` → `Iterable<Track>`；删除 assert body 中的 `track is SongFull || track is SongLocal` 检查（改为空实现或删除整个方法）
- **`_assertAllowedTrack`**（L39）：`Song tracks` → `Track tracks`；同上删除类型检查
- **所有方法签名**：`Iterable<Song>` → `Iterable<Track>`、`Song track` → `Track track`、`List<Song>` → `List<Track>`
- **`_compareTracks`**（L367）：`Song a, Song b` → `Track a, Track b`；`a is SongLocal && b is SongLocal ? a.path == b.path : a.id == b.id` → `a.path != null && b.path != null ? a.path == b.path : a.id == b.id`
- **`load`**（L392）：`intendedActiveTrack.track is! SongLocal` → `intendedActiveTrack.track.path == null`
- **`swapActiveSource`**（L423）：`state.activeTrack is! SongFull` → `state.activeTrack?.src == null`
- **`addTracksAtFirst`**（L252）、**`addTrack`**（L287）、**`addTracks`**（L306）、**`jumpToTrack`**（L455）：参数类型 `Song` → `Track`

#### 3.5 `lib/modules/audio_player/audio_player_module.dart`

- **import**（L18）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **`getTrackUrl`**（L90）：`(Song track)` → `(Track track)`；`track.map(full: (f) => f.src, local: (l) => l.path)` → `track.src ?? track.path`（两处，L93 和 L96）
- **`service.getMusicUrl(track as SongFull, ...)`**（L99）→ `service.getMusicUrl(track, ...)`

#### 3.6 `lib/modules/audio_player/services/audio_services.dart`

- **import**（L9）：`import 'package:pomelo/modules/music/model/song.dart' show Song` → `import 'package:pomelo/modules/music/model/track.dart' show Track`
- **`addTrack`**（L51）：`Song track` → `Track track`
- **字段映射**（L56-60）：`track.albumName ?? 'Unknown'` → `track.album ?? 'Unknown'`、`track.name` → `track.title`、`track.coverUrl` → `track.coverArt`

#### 3.7 `lib/modules/audio_player/services/windows_audio_service.dart`

- **import**（L9）：`import 'package:pomelo/modules/music/model/song.dart' show Song` → `import 'package:pomelo/modules/music/model/track.dart' show Track`
- **`addTrack`**（L82）：`Song track` → `Track track`
- **字段映射**（L88-92）：`track.name` → `track.title`、`track.albumName ?? 'Unknown'` → `track.album ?? 'Unknown'`、`track.coverUrl` → `track.coverArt`

#### 3.8 `lib/modules/audio_player/service/audio_player_service.dart`

- **import**（L18）：`import 'package:pomelo/modules/music/model/song.dart' show Song` → `import 'package:pomelo/modules/music/model/track.dart' show Track`
- **`extension AsMediaListSong on Iterable<Song>`**（L411）→ `extension AsMediaListTrack on Iterable<Track>`

---

### 步骤 4：UI 层（13 文件，含 4 个重命名）

#### 4.1 重命名 `lib/ui/music/model/merged_song.dart` → `merged_track.dart`

- **import**：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **类名**：`MergedSong` → `MergedTrack`；`Song primary` → `Track primary`
- **函数**：`mergeSongs(Iterable<Song> songs)` → `mergeTracks(Iterable<Track> tracks)`；参数名 `songs` → `tracks`、`song` → `track`、`song.source` → `track.source`

#### 4.2 重命名 `lib/ui/music/widgets/song_tile.dart` → `track_tile.dart`

- **import**：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **类名**：`SongTile` → `TrackTile`
- **字段**：`final Song song` → `final Track track`
- **字段访问**：`song.name` → `track.title`、`song.artist` → `track.artist`、`song.coverUrl` → `track.coverArt`、`song.formattedDuration` → `track.formattedDuration`
- 构造参数 `required this.song` → `required this.track`

#### 4.3 重命名 `lib/ui/music/song_list.dart` → `track_list.dart`

- **import**：更新 `song_more_actions_button.dart` → `track_more_actions_button.dart`、`song_tile.dart` → `track_tile.dart`；`models.dart` 已导入
- **类名**：`SongList` → `TrackList`
- **字段**：`List<Song> songs` → `List<Track> tracks`、`void Function(Song)? onRemoveFromQueue` → `void Function(Track)?`
- **内部**：`songs[index]` → `tracks[index]`、`final song = ...` → `final track = ...`、`SongTile(song: song, ...)` → `TrackTile(track: track, ...)`、`SongMoreActionsButton(song: song, ...)` → `TrackMoreActionsButton(track: track, ...)`、`PlayPauseButton(song: song)` → `PlayPauseButton(track: track)`、`onRemoveFromQueue!(song)` → `onRemoveFromQueue!(track)`

#### 4.4 重命名 `lib/ui/music/widgets/song_more_actions_button.dart` → `track_more_actions_button.dart`

- **import**：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **类名**：`SongMoreActionsButton` → `TrackMoreActionsButton`、`SongMoreActionsContent` → `TrackMoreActionsContent`
- **字段**：`Song song` → `Track track`
- **字段访问**：`song.name` → `track.title`、`song.artist` → `track.artist`
- **内部**：`SongMoreActionsContent(song: song, ...)` → `TrackMoreActionsContent(track: track, ...)`、`notifier.addTracksAtFirst([song])` → `notifier.addTracksAtFirst([track])`、`notifier.addTracks([song])` → `notifier.addTracks([track])`

#### 4.5 `lib/ui/music/widgets/play_all_button.dart`

- **import**（L4）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **字段**：`List<Song> songs` → `List<Track> tracks`
- **内部**：`songs.isNotEmpty` → `tracks.isNotEmpty`、`songs.isEmpty` → `tracks.isEmpty`、`notifier.load(songs, ...)` → `notifier.load(tracks, ...)`、`songs.length` → `tracks.length`

#### 4.6 `lib/ui/music/widgets/play_pause_button.dart`

- **import**（L3）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **字段**：`Song? song` → `Track? track`
- **内部**：`song == null` → `track == null`、`song!.id` → `track!.id`、`notifier.load([song!], ...)` → `notifier.load([track!], ...)`

#### 4.7 `lib/ui/music/playlist_detail_page.dart`

- **import**（L11）：`import 'package:pomelo/ui/music/song_list.dart'` → `import 'package:pomelo/ui/music/track_list.dart'`
- **Provider**：`playlistSongsProvider` → `playlistTracksProvider`；`FutureProvider.family<List<Song>, ...>` → `FutureProvider.family<List<Track>, ...>`；`service.getPlaylistSongs(...)` → `service.getPlaylistTracks(...)`
- **`_PlaylistHeader`**：`List<Song> songs` → `List<Track> tracks`；`PlayAllButton(songs: songs)` → `PlayAllButton(tracks: tracks)`
- **页面主体**：`songsAsync.when(data: (songs) {...})` → `tracksAsync.when(data: (tracks) {...})`；`songs.isEmpty` → `tracks.isEmpty`；`SongList(songs: songs, ...)` → `TrackList(tracks: tracks, ...)`；`songs.length` → `tracks.length`
- **构造参数 `coverUrl`/`creator` 保持不变**（避免路由重新生成）

#### 4.8 `lib/ui/music/providers/music_ui_providers.dart`

- **import**（L10）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **import**（L14）：`import 'package:pomelo/ui/music/model/merged_song.dart'` → `import 'package:pomelo/ui/music/model/merged_track.dart'`
- **`MusicListData`**：`List<Song> songs` → `List<Track> tracks`；构造参数 `this.songs` → `this.tracks`
- **`currentSourceSongsProvider`** → `currentSourceTracksProvider`；`PaginationResponse<Song>` → `PaginationResponse<Track>`；`(s as MusicService).getSongs()` → `(s as MusicService).getTracks()`；`final songs = <Song>[]` → `final tracks = <Track>[]`；`songs.addAll(...)` → `tracks.addAll(...)`；`MusicListData(songs: songs, ...)` → `MusicListData(tracks: tracks, ...)`
- **`SearchListData`**：`List<MergedSong> songs` → `List<MergedTrack> tracks`
- **`searchResultsProvider`**：`PaginationResponse<Song>` → `PaginationResponse<Track>`；`(s as MusicService).searchSongs(...)` → `(s as MusicService).searchTracks(...)`；`final allSongs = <Song>[]` → `final allTracks = <Track>[]`；`allSongs.addAll(...)` → `allTracks.addAll(...)`；`SearchListData(songs: mergeSongs(allSongs), ...)` → `SearchListData(tracks: mergeTracks(allTracks), ...)`
- **`leaderboardSongsProvider`** → `leaderboardTracksProvider`；`FutureProvider.family<List<Song>, String>` → `FutureProvider.family<List<Track>, String>`；`service.getLeaderboardSongs(...)` → `service.getLeaderboardTracks(...)`

#### 4.9 `lib/ui/music/music_section.dart`

- **import**（L6）：`import 'package:pomelo/ui/music/song_list.dart'` → `import 'package:pomelo/ui/music/track_list.dart'`
- **`currentSourceSongsProvider`** → `currentSourceTracksProvider`
- **`data.songs`** → `data.tracks`；`SongList(songs: data.songs)` → `TrackList(tracks: data.tracks)`

#### 4.10 `lib/ui/music/leaderboard_section.dart`

- **import**（L5）：`import 'package:pomelo/ui/music/widgets/song_tile.dart'` → `import 'package:pomelo/ui/music/widgets/track_tile.dart'`
- **`leaderboardSongsProvider`** → `leaderboardTracksProvider`
- **`_LeaderboardSongs`**：`songsAsync` → `tracksAsync`；`data: (songs)` → `data: (tracks)`；`songs.isEmpty` → `tracks.isEmpty`；`displaySongs` → `displayTracks`；`final song = ...` → `final track = ...`；`SongTile(song: song, ...)` → `TrackTile(track: track, ...)`；`PlayPauseButton(song: song)` → `PlayPauseButton(track: track)`

#### 4.11 `lib/ui/music/search_page.dart`

- **import**（L18）：`import 'package:pomelo/ui/music/widgets/song_tile.dart'` → `import 'package:pomelo/ui/music/widgets/track_tile.dart'`
- **`_SearchResultsList`**：`data.songs` → `data.tracks`；`final songs = data.songs` → `final tracks = data.tracks`；`songs.isEmpty` → `tracks.isEmpty`；`songs.length` → `tracks.length`；`SongTile(song: merged.primary, ...)` → `TrackTile(track: merged.primary, ...)`；`PlayPauseButton(song: merged.primary)` → `PlayPauseButton(track: merged.primary)`

#### 4.12 `lib/ui/home/home_page.dart`

- **import**（L12）：`import 'package:pomelo/ui/music/widgets/song_tile.dart'` → `import 'package:pomelo/ui/music/widgets/track_tile.dart'`
- **`leaderboardSongsProvider`** → `leaderboardTracksProvider`
- **`_LeaderboardSongs`**：`songsAsync` → `tracksAsync`；`data: (songs)` → `data: (tracks)`；`songs.isEmpty` → `tracks.isEmpty`；`final song = ...` → `final track = ...`；`SongTile(song: song, ...)` → `TrackTile(track: track, ...)`；`PlayPauseButton(song: song)` → `PlayPauseButton(track: track)`
- **Playlist 字段映射**（L792-833）：`playlist.coverUrl` → `playlist.coverArt`（4 处）、`playlist.creator` → `playlist.owner`（2 处）；构造参数名 `coverUrl:`/`creator:` 保持不变（仅改右侧值）

#### 4.13 `lib/ui/music/playlist_section.dart`

- **Playlist 字段映射**（L291-334）：`playlist.coverUrl` → `playlist.coverArt`（4 处）、`playlist.creator` → `playlist.owner`（2 处）；构造参数名 `coverUrl:`/`creator:` 保持不变

#### 4.14 `lib/ui/player/playback_page.dart`

- **import**（L8）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **`_MobileLayout`/`_DesktopLayout`**：`Song track` → `Track track`
- **字段映射**：`track.map(full: (f) => f.coverUrl, local: (l) => null)` → `track.coverArt`（两处）；`track.map(full: (f) => f.albumName, local: (l) => null)` → `track.album`（两处）；`track.name` → `track.title`（多处）

#### 4.15 `lib/ui/player/mini_player.dart`

- **import**（L4）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **`_buildContent`/`_buildCover`**：`Song track` → `Track track`
- **字段映射**：`track.map(full: (f) => f.coverUrl, local: (l) => null)` → `track.coverArt`；`track.name` → `track.title`

#### 4.16 `lib/ui/player/lyric_view.dart`

- **import**（L4）：`import 'package:pomelo/modules/music/model/song.dart'` → `import 'package:pomelo/modules/music/model/track.dart'`
- **`lyricProvider`**（L15）：`FutureProvider.autoDispose.family<String?, Song>` → `<String?, Track>`；参数 `Song song` → `Track track`
- **`song is! SongFull`**（L16）→ `track.src == null`
- **`service.getLyric(song)`**（L22）→ `service.getLyric(track)`

#### 4.17 `lib/ui/player/widgets/play_queue_content.dart`

- **import**（L7-8）：`import 'package:pomelo/ui/music/widgets/song_more_actions_button.dart'` → `track_more_actions_button.dart`；`import 'package:pomelo/ui/music/widgets/song_tile.dart'` → `track_tile.dart`
- **`final song = tracks[index]`**（L71）→ `final track = tracks[index]`
- **`SongTile(song: song, ...)`** → `TrackTile(track: track, ...)`；`PlayPauseButton(song: song)` → `PlayPauseButton(track: track)`；`SongMoreActionsButton(song: song, ...)` → `TrackMoreActionsButton(track: track, ...)`；`notifier.removeTrack(song.id)` → `notifier.removeTrack(track.id)`；`notifier.jumpToTrack(song)` → `notifier.jumpToTrack(track)`
- **`_QueueHeader.songCount`** 字段名保持不变（只是显示文本 "播放队列 · N 首"）

---

### 步骤 5：核心层与测试（2 文件）

#### 5.1 `lib/core/storage/persistent_repository.dart`

- **文档示例**（L13-31）：将示例中的 `Song`/`SongRepository`/`songs`/`item.title` 等更新为 `Track`/`TrackRepository`/`tracks`（仅文档注释，不影响功能）

#### 5.2 `test/fluxy_boot_test.dart`

- **`.toSong(sourceId: 'lx-test', sourceName: '测试')`**（L39）→ `.toTrack(sourceId: 'lx-test', sourceName: '测试')`

---

### 步骤 6：重新生成代码

运行 `dart run build_runner build --delete-conflicting-outputs` 以重新生成：
- `lib/modules/audio_player/model/state.freezed.dart`（`List<Song>` → `List<Track>`）
- `lib/modules/audio_player/model/state.g.dart`（同上）

**注意**：auto_route 的 `app_router.gr.dart` 不需要重新生成（未修改 `@RoutePage()` 页面的构造参数签名）。

---

### 步骤 7：验证

1. 运行 `flutter analyze`，确认 0 error
2. 用 Grep 搜索残留引用：
   - `Grep "\bSong\b|SongFull|SongLocal" path=lib`（应仅剩 `SubsonicSong`、`LxServerSong` 等内部 API 模型类名）
   - `Grep "import.*model/song\.dart" path=lib`（应为 0 结果）
   - `Grep "\.searchSongs\(|\.getSong\(|\.getSongs\(|\.getAlbumSongs\(|\.getPlaylistSongs\(|\.getLeaderboardSongs\(" path=lib`（应仅剩 `client.getSong`/`client.getLeaderboardSongs` 等内部客户端方法）
   - `Grep "SongTile|SongList|SongMoreActionsButton|MergedSong|mergeSongs|currentSourceSongsProvider|playlistSongsProvider|leaderboardSongsProvider"`（应为 0 结果，仅文档/规则文件中残留）

---

## 文件清单总览

| # | 文件路径 | 操作 |
|---|---------|------|
| 1 | `lib/modules/music_lx/model/lx_metadata_engine.dart` | 修改 |
| 2 | `lib/modules/music_lx/model/lx_music_service.dart` | 修改 |
| 3 | `lib/modules/music_lx/model/lx_source_engine.dart` | 修改 |
| 4 | `lib/modules/music_lx_server/repository/lx_server_models.dart` | 修改 |
| 5 | `lib/modules/music_lx_server/repository/lx_server_music_service.dart` | 修改 |
| 6 | `lib/modules/audio_player/model/state.dart` | 修改 |
| 7 | `lib/modules/audio_player/model/media.dart` | 修改 |
| 8 | `lib/modules/audio_player/providers/playback.dart` | 修改 |
| 9 | `lib/modules/audio_player/providers/audio_player.dart` | 修改 |
| 10 | `lib/modules/audio_player/audio_player_module.dart` | 修改 |
| 11 | `lib/modules/audio_player/services/audio_services.dart` | 修改 |
| 12 | `lib/modules/audio_player/services/windows_audio_service.dart` | 修改 |
| 13 | `lib/modules/audio_player/service/audio_player_service.dart` | 修改 |
| 14 | `lib/core/storage/persistent_repository.dart` | 修改（文档） |
| 15 | `lib/ui/music/model/merged_song.dart` → `merged_track.dart` | 重命名+修改 |
| 16 | `lib/ui/music/widgets/song_tile.dart` → `track_tile.dart` | 重命名+修改 |
| 17 | `lib/ui/music/song_list.dart` → `track_list.dart` | 重命名+修改 |
| 18 | `lib/ui/music/widgets/song_more_actions_button.dart` → `track_more_actions_button.dart` | 重命名+修改 |
| 19 | `lib/ui/music/widgets/play_all_button.dart` | 修改 |
| 20 | `lib/ui/music/widgets/play_pause_button.dart` | 修改 |
| 21 | `lib/ui/music/playlist_detail_page.dart` | 修改 |
| 22 | `lib/ui/music/providers/music_ui_providers.dart` | 修改 |
| 23 | `lib/ui/music/music_section.dart` | 修改 |
| 24 | `lib/ui/music/leaderboard_section.dart` | 修改 |
| 25 | `lib/ui/music/search_page.dart` | 修改 |
| 26 | `lib/ui/music/playlist_section.dart` | 修改 |
| 27 | `lib/ui/home/home_page.dart` | 修改 |
| 28 | `lib/ui/player/playback_page.dart` | 修改 |
| 29 | `lib/ui/player/mini_player.dart` | 修改 |
| 30 | `lib/ui/player/lyric_view.dart` | 修改 |
| 31 | `lib/ui/player/widgets/play_queue_content.dart` | 修改 |
| 32 | `test/fluxy_boot_test.dart` | 修改 |
| — | `state.freezed.dart` + `state.g.dart` | build_runner 重新生成 |

**不修改的文件**（API 映射命名保持不变）：
- `lib/modules/music_subsonic/repository/subsonic_client.dart`（REST 端点名）
- `lib/modules/music_subsonic/repository/subsonic_models.dart`（`SubsonicSong` 类、`songs` JSON 字段名）
- `lib/modules/music_lx_server/repository/lx_server_client.dart`（`LxServerSong`、内部方法名）
- `lib/core/routers/app_router.gr.dart`（路由生成文件，构造参数签名未变）
