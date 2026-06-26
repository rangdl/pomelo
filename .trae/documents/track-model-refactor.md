# Track 模型重构计划

## 概述

将 `Song` 类重命名为 `Track`，按 Subsonic 风格 schema 重命名字段、新增字段，新增 `Artist` / `ArtistWithAlbums` / `AlbumWithTracks` 模型类，为所有模型添加 `@immutable` 注解和 `copyWith` 方法，并将 `Song` 的 freezed 联合类型（SongFull/SongLocal）拍平为单一 `Track` 类（用可选 `src`/`path` 字段区分在线/本地）。

---

## 一、当前状态分析

### 现有模型文件

| 文件 | 现状 |
|------|------|
| `lib/modules/music/model/song.dart` | freezed 联合类型 `Song.full()`/`Song.local()`，字段: id, name, artist, albumId, albumName, coverUrl, duration, source, meta, createdAt, src(Full), path(Local) |
| `lib/modules/music/model/song.freezed.dart` | freezed 生成代码 |
| `lib/modules/music/model/song.g.dart` | json_serializable 生成代码 |
| `lib/modules/music/model/album.dart` | 手写类，字段: id, title, artist, coverUrl, year, songCount, description, source, meta, createdAt |
| `lib/modules/music/model/playlist.dart` | 手写类 + `PlaylistCategory`，字段: id, name, coverUrl, creator, description, songs, source, meta, createdAt |
| `lib/modules/music/model/leaderboard.dart` | 手写类，字段: id, name |
| `lib/modules/music/model/models.dart` | barrel 导出 |
| `lib/modules/music/model/music_service.dart` | 抽象接口，方法名含 `Song`/`Songs` |
| `lib/modules/audio_player/model/state.dart` | freezed，引用 `Song/SongFull/SongLocal` |

### 影响范围

- `lib/modules/music/` — 8 文件
- `lib/modules/music_lx/` — 3 文件
- `lib/modules/music_lx_server/` — 2 文件
- `lib/modules/music_subsonic/` — 3 文件
- `lib/modules/music_local/` — 1 文件
- `lib/modules/audio_player/` — 10 文件
- `lib/ui/` — 11 文件
- `test/` — 1 文件
- 共约 40 文件

### `.map(full:..., local:...)` 模式使用点（3 文件）

- `lib/modules/audio_player/audio_player_module.dart` — `track.map(full: (f) => f.src, local: (l) => l.path)`
- `lib/modules/audio_player/providers/playback.dart` — 同上
- `lib/ui/player/playback_page.dart` — `track.map(full: (f) => f.coverUrl, local: (l) => null)` 等

---

## 二、字段映射表

### Track（替代 Song）

| 旧字段 | 新字段 | 类型 | 必填 | 说明 |
|--------|--------|------|------|------|
| id | id | String | ✅ | |
| name | **title** | String | ✅ | 重命名 |
| artist | artist | String | | |
| albumId | albumId | String | | |
| albumName | **album** | String | | 重命名 |
| coverUrl | **coverArt** | String | | 重命名 |
| duration | duration | int | | |
| source | source | record | ✅ | Pomelo 扩展，保留 |
| meta | meta | Map | | Pomelo 扩展，保留 |
| createdAt | **created** | DateTime | | 重命名 |
| src (SongFull) | src | String? | | 拍平：在线曲目播放地址 |
| path (SongLocal) | path | String? | | 拍平：本地曲目文件路径 |
| — | **track** | int? | | 新增：音轨号 |
| — | **year** | int? | | 新增 |
| — | **genre** | String? | | 新增 |
| — | **bitRate** | int? | | 新增：Kbps |
| — | **playCount** | int? | | 新增：播放次数 |
| — | **discNumber** | int? | | 新增：碟片号 |
| — | **starred** | DateTime? | | 新增：收藏时间 |
| — | **artistId** | String? | | 新增 |

**拍平规则**：`src != null` → 在线曲目；`path != null` → 本地曲目。提供便捷 getter：
```dart
bool get isLocal => path != null;
```

### Album

| 旧字段 | 新字段 | 类型 | 必填 | 说明 |
|--------|--------|------|------|------|
| id | id | String | ✅ | |
| title | **name** | String | ✅ | 重命名 |
| artist | artist | String | | |
| coverUrl | **coverArt** | String | | 重命名 |
| year | year | int? | | |
| songCount | songCount | int | | |
| description | **comment** | String? | | 重命名 |
| source | source | record | ✅ | Pomelo 扩展 |
| meta | meta | Map | | Pomelo 扩展 |
| createdAt | **created** | DateTime | | 重命名 |
| — | **artistId** | String? | | 新增 |
| — | **duration** | int | | 新增：默认 0 |
| — | **playCount** | int | | 新增：默认 0 |
| — | **starred** | DateTime? | | 新增 |
| — | **genre** | String? | | 新增 |

### Playlist

| 旧字段 | 新字段 | 类型 | 必填 | 说明 |
|--------|--------|------|------|------|
| id | id | String | ✅ | |
| name | name | String | ✅ | |
| coverUrl | **coverArt** | String | | 重命名 |
| creator | **owner** | String | | 重命名 |
| description | **comment** | String? | | 重命名 |
| songs | **tracks** | List\<Track\> | | 重命名 + 类型变 |
| source | source | record | ✅ | Pomelo 扩展 |
| meta | meta | Map | | Pomelo 扩展 |
| createdAt | **created** | DateTime | | 重命名 |
| — | **public** | bool | | 新增：默认 false |
| — | **duration** | int | | 新增：默认 0 |
| — | **changed** | DateTime? | | 新增 |
| — | **songCount** | int | | 新增：默认 0（原为 getter，改为字段） |

> 注：用户 schema 未列 `tracks` 字段，但当前代码大量使用 `playlist.songs`，保留为 Pomelo 扩展（默认空列表）。`songCount` 改为字段（来自 API），`totalDuration` getter 删除（由 `duration` 字段替代）。

### Artist（新增）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | ✅ | |
| name | String | ✅ | |
| coverArt | String? | | |
| artistImageUrl | String? | | |
| albumCount | int | | 默认 0 |
| starred | DateTime? | | |
| source | record? | | Pomelo 扩展（可选，便于多源管理） |
| meta | Map? | | Pomelo 扩展 |

### ArtistWithAlbums（新增，继承 Artist）

| 字段 | 类型 | 说明 |
|------|------|------|
| albums | List\<Album\> | 默认空列表 |

### AlbumWithTracks（新增，继承 Album）

| 字段 | 类型 | 说明 |
|------|------|------|
| tracks | List\<Track\> | 默认空列表 |

> 注：用户原文为 "AlbumWithSongs"，但既然 Song 已重命名为 Track 且字段名为 `tracks`，类名统一为 `AlbumWithTracks` 以保持一致。

---

## 三、DateTime 解析助手

新建 `lib/core/extensions/date_time.dart`，提供 `tryParseDateTime` 函数，兼容多种格式：

```dart
/// 健壮的 DateTime 解析，兼容多种格式
/// 支持：ISO 8601、epoch 毫秒(int)、常见字符串格式
DateTime? tryParseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    // epoch 毫秒
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    // 1. 优先尝试 ISO 8601（DateTime.parse）
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    // 2. 尝试常见格式
    const patterns = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy/MM/dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
      'yyyy/MM/dd HH:mm',
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'yyyy.MM.dd',
    ];
    for (final p in patterns) {
      final dt = DateFormat(p).tryParse(value);
      if (dt != null) return dt;
    }
  }
  return null;
}
```

所有模型的 `fromJson` 中 DateTime 字段统一改用此助手（替代直接 `DateTime.parse`，避免格式不符抛异常）。

---

## 四、实施步骤

### 步骤 1：创建 DateTime 解析助手

**新建** `lib/core/extensions/date_time.dart`

### 步骤 2：创建新模型文件

#### 2.1 新建 `lib/modules/music/model/track.dart`

替换 `song.dart`。手写 `@immutable` 类，含：
- 所有 Track 字段（见映射表）
- `const` 构造函数，`src`/`path` 可选
- `bool get isLocal => path != null;`
- `String get formattedDuration` 扩展（从 SongExtension 迁移）
- `copyWith`（含 `clearSrc`/`clearPath`/`clearStarred`/`clearCreated` 等 clearX 标志）
- `==` / `hashCode`
- `fromJson` / `toJson`（DateTime 字段用 `tryParseDateTime`）
- 不使用 freezed

#### 2.2 新建 `lib/modules/music/model/artist.dart`

`Artist` 基类 + `ArtistWithAlbums` 子类，均 `@immutable`，含 copyWith/==/hashCode/fromJson/toJson。

#### 2.3 修改 `lib/modules/music/model/album.dart`

- 字段重命名：title→name, coverUrl→coverArt, description→comment, createdAt→created
- 新增字段：artistId, duration, playCount, starred, genre
- 添加 `@immutable`、`const` 构造函数、copyWith（含 clearX 标志）、==、hashCode
- DateTime 解析改用 `tryParseDateTime`
- 新增 `AlbumWithTracks` 子类（extends Album，添加 `tracks` 字段）

#### 2.4 修改 `lib/modules/music/model/playlist.dart`

- 字段重命名：coverUrl→coverArt, creator→owner, description→comment, songs→tracks, createdAt→created
- 新增字段：public, duration, changed, songCount(改为字段)
- 删除 `totalDuration` getter（由 `duration` 字段替代）
- `songCount` getter 改为字段（默认 0）
- 添加 `@immutable`、`const` 构造函数、copyWith、==、hashCode
- DateTime 解析改用 `tryParseDateTime`
- `PlaylistCategory` 也加 `@immutable`

#### 2.5 修改 `lib/modules/music/model/leaderboard.dart`

- 添加 `@immutable`、copyWith、==、hashCode

#### 2.6 删除旧文件

- 删除 `lib/modules/music/model/song.dart`
- 删除 `lib/modules/music/model/song.freezed.dart`
- 删除 `lib/modules/music/model/song.g.dart`

#### 2.7 修改 `lib/modules/music/model/models.dart`

- `export 'song.dart'` → `export 'track.dart'`
- 新增 `export 'artist.dart'`

### 步骤 3：更新 MusicService 接口

**修改** `lib/modules/music/model/music_service.dart`

方法重命名：
- `searchSongs` → `searchTracks`
- `getSong` → `getTrack`
- `getSongs` → `getTracks`
- `getAlbumSongs` → `getAlbumTracks`
- `getPlaylistSongs` → `getPlaylistTracks`
- `getLeaderboardSongs` → `getLeaderboardTracks`
- `getMusicUrl(SongFull song, ...)` → `getMusicUrl(Track track, ...)`
- `getLyric(SongFull song)` → `getLyric(Track track)`
- 所有返回类型 `Song` → `Track`、`PaginationResponse<Song>` → `PaginationResponse<Track>`
- import `song.dart` → `track.dart`

### 步骤 4：更新 MusicModule + module_providers

**修改** `lib/modules/music/music_module.dart`
- `searchSongs` → `searchTracks`，`PaginationResponse<Song>` → `PaginationResponse<Track>`
- import `song.dart` → `track.dart`
- 文件头注释更新

**修改** `lib/modules/music/module_providers.dart`
- `musicSearchResultProvider` 返回 `List<Track>`
- import `song.dart` → `track.dart`

### 步骤 5：更新 4 个音乐服务实现

#### 5.1 `lib/modules/music_local/service/local_music_service.dart`
- `List<Song> _songs` → `List<Track> _songs`
- `Song.local(...)` → `Track(...)` with `path: entity.path`（src 留 null）
- `s is SongLocal && s.path...` → `s.path != null && s.path...`
- 方法名同步：searchSongs→searchTracks 等
- Album 构造：title→name, coverUrl→coverArt
- `.name` → `.title`（曲目标题访问）

#### 5.2 `lib/modules/music_subsonic/repository/subsonic_models.dart`
- `toSong` 方法 → `toTrack`，返回 `Track(...)`
- `Song.full(...)` → `Track(...)` with `src: ...`
- 字段映射：name→title, albumName→album, coverUrl→coverArt, createdAt→created
- import `song.dart` → `track.dart`

#### 5.3 `lib/modules/music_subsonic/repository/subsonic_music_service.dart`
- 方法名同步
- `Song` → `Track` 类型引用
- `.map((s) => s.toSong(...))` → `.map((s) => s.toTrack(...))`

#### 5.4 `lib/modules/music_subsonic/repository/subsonic_client.dart`
- `Song` → `Track` 类型引用（如有）

#### 5.5 `lib/modules/music_lx/model/lx_metadata_engine.dart`
- `PomeloTrackObjectMeta.toSong` → `toTrack`，返回 `Track(...)`
- `Song.full(...)` → `Track(...)` with `src: ...`
- 字段映射：name→title, albumName→album, coverUrl→coverArt, createdAt→created
- `PaginationResponse<Song>` → `PaginationResponse<Track>`
- import `song.dart` → `track.dart`

#### 5.6 `lib/modules/music_lx/model/lx_music_service.dart`
- 方法名同步
- `Song` → `Track` 类型引用
- import 更新

#### 5.7 `lib/modules/music_lx/model/lx_source_engine.dart`
- `Song` → `Track` 类型引用
- import `song.dart` → `track.dart`

#### 5.8 `lib/modules/music_lx_server/repository/lx_server_models.dart`
- `toSong` → `toTrack`
- `Song.full(...)` → `Track(...)`
- 字段映射同上

#### 5.9 `lib/modules/music_lx_server/repository/lx_server_music_service.dart`
- 方法名同步
- `Song` → `Track` 类型引用

### 步骤 6：更新 AudioPlayer 模块（10 文件）

#### 6.1 `lib/modules/audio_player/model/state.dart`
- `List<Song> tracks` → `List<Track> tracks`
- `Song? get activeTrack` → `Track? get activeTrack`
- `containsTrack(Song track)` → `containsTrack(Track track)`
- `containsTracks(List<Song> tracks)` → `containsTracks(List<Track> tracks)`
- 删除 `_inner` 工厂中的 SongFull/SongLocal 断言
- `containsTrack` 逻辑：`t.path != null && track.path != null ? t.path == track.path : t.id == track.id`
- import `song.dart` → `track.dart`
- **保留 freezed**（仅更新类型引用，后续 build_runner 重新生成）

#### 6.2 `lib/modules/audio_player/model/media.dart`
- `final Song track` → `final Track track`
- `track is SongLocal ? track.path : "http://..."` → `track.path != null ? track.path : "http://..."`
- `Song.fromJson(media.extras!)` → `Track.fromJson(media.extras!)`
- import `song.dart` → `track.dart`

#### 6.3 `lib/modules/audio_player/audio_player_module.dart`
- `getTrackUrl: (Song track)` → `getTrackUrl: (Track track)`
- `track.map(full: (f) => f.src, local: (l) => l.path)` → `track.src ?? track.path`
- `service.getMusicUrl(track as SongFull, ...)` → `service.getMusicUrl(track, ...)`
- import `song.dart` → `track.dart`

#### 6.4 `lib/modules/audio_player/providers/audio_player.dart`
- 所有 `Song` → `Track`，`SongFull`/`SongLocal` → 用 `isLocal`/path 判断
- `_assertAllowedTracks` / `_assertAllowedTrack`：删除或简化（不再有联合类型）
- `_compareTracks`：`a is SongLocal && b is SongLocal ? a.path == b.path : a.id == b.id` → `a.path != null && b.path != null ? a.path == b.path : a.id == b.id`
- `track is! SongLocal` / `track is SongFull` → `!track.isLocal` / `track.src != null`
- import `song.dart` → `track.dart`

#### 6.5 `lib/modules/audio_player/providers/playback.dart`
- `Song? Function() getActiveTrack` → `Track? Function()`
- `Future<String> Function(Song track)? getTrackUrl` → `Future<String> Function(Track track)?`
- `_resolveUrl(Song track)` → `_resolveUrl(Track track)`
- `track.map(full: (f) => f.src, local: (l) => l.path)` → `track.src ?? track.path`
- `streamTrackInformation(..., SongFull track)` → `streamTrackInformation(..., Track track)`
- `streamTrack(..., SongFull track, ...)` → `streamTrack(..., Track track, ...)`
- `activeTrack is! SongFull` → `activeTrack.src == null`（即非在线曲目不可流式播放）
- `track.name` → `track.title`
- import `song.dart` → `track.dart`

#### 6.6 `lib/modules/audio_player/service/audio_player_service.dart`
- `Song` → `Track` 类型引用

#### 6.7 `lib/modules/audio_player/services/audio_services.dart`
- `Song` → `Track` 类型引用
- `.name` → `.title`、`.albumName` → `.album`、`.coverUrl` → `.coverArt` 等

#### 6.8 `lib/modules/audio_player/services/windows_audio_service.dart`
- 同上

#### 6.9 `lib/core/storage/persistent_repository.dart`
- 如有 `Song` 泛型引用 → `Track`

### 步骤 7：更新 UI 层（11 文件）

#### 7.1 `lib/ui/music/widgets/song_tile.dart`
- `Song song` → `Track track`（或保留文件名但改类名）
- `song.name` → `track.title`
- `song.coverUrl` → `track.coverArt`
- import `song.dart` → `track.dart`
- **文件重命名**：`song_tile.dart` → `track_tile.dart`（含类名 `SongTile` → `TrackTile`）

#### 7.2 `lib/ui/music/song_list.dart`
- `Song` → `Track`
- **文件重命名**：`song_list.dart` → `track_list.dart`（含类名 `SongList` → `TrackList`）
- 引用更新

#### 7.3 `lib/ui/music/widgets/song_more_actions_button.dart`
- `Song` → `Track`
- **文件重命名**：→ `track_more_actions_button.dart`（类名同步）

#### 7.4 `lib/ui/music/widgets/play_all_button.dart`
- `Song` → `Track`、`List<Song>` → `List<Track>`

#### 7.5 `lib/ui/music/widgets/play_pause_button.dart`
- `Song` → `Track`

#### 7.6 `lib/ui/music/playlist_detail_page.dart`
- `Song` → `Track`、`.songs` → `.tracks`、`.name` → `.title`（曲目标题）

#### 7.7 `lib/ui/music/model/merged_song.dart`
- `Song primary` → `Track primary`
- `mergeSongs(Iterable<Song>)` → `mergeTracks(Iterable<Track>)`
- **文件重命名**：`merged_song.dart` → `merged_track.dart`（类名 `MergedSong` → `MergedTrack`）

#### 7.8 `lib/ui/music/providers/music_ui_providers.dart`
- `Song` → `Track` 类型引用

#### 7.9 `lib/ui/player/playback_page.dart`
- `Song track` → `Track track`
- `track.map(full: (f) => f.coverUrl, local: (l) => null)` → `track.coverArt`
- `track.map(full: (f) => f.albumName, local: (l) => null)` → `track.album`
- `track.name` → `track.title`
- import `song.dart` → `track.dart`

#### 7.10 `lib/ui/player/lyric_view.dart`
- `Song` → `Track` 类型引用（如有）

#### 7.11 `lib/ui/player/mini_player.dart`
- `Song` → `Track`、`.name` → `.title`、`.coverUrl` → `.coverArt`

### 步骤 8：更新测试和文档

#### 8.1 `test/fluxy_boot_test.dart`
- `.toSong(...)` → `.toTrack(...)`
- `Song` → `Track`（如有）

#### 8.2 检查 `lib/modules/audio_player/model/state.g.dart`
- build_runner 重新生成（步骤 9）

### 步骤 9：运行 build_runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

重新生成 `state.freezed.dart` 和 `state.g.dart`（因 `List<Song>` → `List<Track>`）。

### 步骤 10：验证

1. `flutter analyze` — 0 error, 0 warning
2. `grep -r "\bSong\b\|SongFull\|SongLocal" lib/ test/` — 仅剩注释或非模型引用
3. `grep -r "\.map(full:\|\.map<.*>(full:" lib/` — 0 结果（联合类型模式已全部替换）

---

## 五、`.map(full:..., local:...)` 替换指南

| 旧模式 | 新模式 |
|--------|--------|
| `track.map(full: (f) => f.src, local: (l) => l.path)` | `track.src ?? track.path` |
| `track.map(full: (f) => f.coverUrl, local: (l) => null)` | `track.coverArt` |
| `track.map(full: (f) => f.albumName, local: (l) => null)` | `track.album` |
| `track is SongFull` | `track.src != null` 或 `!track.isLocal` |
| `track is SongLocal` | `track.path != null` 或 `track.isLocal` |
| `track is! SongFull` | `track.src == null` 或 `track.isLocal` |
| `track is! SongLocal` | `track.path == null` 或 `!track.isLocal` |

---

## 六、假设与决策

1. **AlbumWithTracks 命名**：用户原文 "AlbumWithSongs"，但统一用 Track 命名，类名定为 `AlbumWithTracks`。
2. **source/meta 保留**：用户 schema 未列，但 Pomelo 多源架构依赖，作为扩展字段保留在 Track/Album/Playlist/Artist 上。Artist 的 source 设为可选（新增模型，部分场景可能无 source）。
3. **Playlist.tracks 保留**：用户 schema 未列，但当前代码使用，保留为 Pomelo 扩展（默认空列表）。
4. **AudioPlayerState 保留 freezed**：仅更新 Song→Track 引用，不转手写。build_runner 重新生成。
5. **持久化兼容性**：AudioPlayerRepository 持久化的 state JSON 格式变化（Song→Track 字段名变化），旧数据首次加载可能播放队列失效，属可接受范围。
6. **文件重命名**：UI 层 `song_*.dart` 文件重命名为 `track_*.dart`，类名同步（SongTile→TrackTile 等），保持命名一致。
7. **`track` 字段名**：Track 类有 `int? track` 字段（音轨号），与类名同名但无语法冲突。
8. **DateTime 解析**：所有模型 fromJson 中 DateTime 字段统一用 `tryParseDateTime`，解析失败返回 null（不抛异常）。

---

## 七、验证步骤

1. 运行 `dart run build_runner build --delete-conflicting-outputs` 成功
2. 运行 `flutter analyze`：0 error, 0 warning（info 级提示可接受）
3. 全局搜索 `\bSong\b`、`SongFull`、`SongLocal`：仅剩注释或字符串字面量
4. 全局搜索 `\.map(full:`：0 结果
5. 全局搜索 `import.*model/song\.dart`：0 结果
