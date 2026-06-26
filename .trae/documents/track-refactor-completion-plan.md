# Song → Track 重构收尾计划

## 概述

本计划承接上一会话已批准并部分执行的重构任务：将 `Song` 类重命名为 `Track`，字段命名对齐 Subsonic schema，扁平化 union 类型，添加 `@immutable` + `copyWith`，DateTime 健壮解析。

**当前进度**：模型层、Lx 模块、LxServer 模块、AudioPlayer 模块、以及大部分 UI 层已完成。代码库目前处于不可编译状态（8 处对已删除文件的 import + 多处旧字段访问）。本计划完成剩余收尾工作。

---

## 当前状态分析

### 已完成（无需修改）
- 模型文件：`track.dart`、`album.dart`、`artist.dart`、`playlist.dart`、`models.dart` — 全部 `@immutable` + `copyWith` + `tryParseDateTime`
- `lib/core/extensions/date_time.dart` — `tryParseDateTime(dynamic)` 健壮解析
- Lx 模块（Step 1）、LxServer 模块（Step 2）、AudioPlayer 模块（Step 3）— 已完成方法重命名和字段映射
- UI 已迁移文件：`merged_track.dart`、`track_tile.dart`、`track_list.dart`、`track_more_actions_button.dart`（4 个新文件，旧文件已删除）、`play_all_button.dart`、`play_pause_button.dart`、`music_ui_providers.dart`、`music_section.dart`、`leaderboard_section.dart`
- `lib/modules/music/model/song.dart` — 已删除

### 待修改文件清单（11 个源文件 + 2 个生成文件）

| 文件 | 问题类型 | 严重程度 |
|------|----------|----------|
| `lib/ui/player/mini_player.dart` | import song.dart + Song 类 + .map() + track.name/coverUrl | 阻断编译 |
| `lib/ui/player/lyric_view.dart` | import song.dart + Song 类 + SongFull 判断 | 阻断编译 |
| `lib/ui/player/playback_page.dart` | import song.dart + Song 类 + .map() + track.name/coverUrl/albumName | 阻断编译 |
| `lib/ui/music/search_page.dart` | import song_tile.dart + SongTile + data.songs | 阻断编译 |
| `lib/ui/music/playlist_detail_page.dart` | import song_list.dart + SongList + playlistSongsProvider + List<Song> + getPlaylistSongs | 阻断编译 |
| `lib/ui/music/playlist_section.dart` | playlist.coverUrl + playlist.creator 字段访问 | 阻断编译 |
| `lib/ui/home/home_page.dart` | import song_tile.dart + SongTile + leaderboardSongsProvider + playlist.coverUrl/creator | 阻断编译 |
| `lib/ui/player/widgets/play_queue_content.dart` | import song_more_actions_button.dart + song_tile.dart + SongTile + SongMoreActionsButton + song 变量 | 阻断编译 |
| `lib/core/storage/persistent_repository.dart` | docstring 示例中的 Song | 不阻断（文档） |
| `lib/modules/audio_player/model/media.dart` | 注释中的 AsMediaListSong on Iterable<Song> | 不阻断（注释） |
| `test/fluxy_boot_test.dart` | .toSong( 调用 | 阻断测试编译 |
| `lib/modules/audio_player/model/state.freezed.dart` | 生成文件，引用 List<Song> | 阻断编译（需重新生成） |
| `lib/modules/audio_player/model/state.g.dart` | 生成文件，引用 Song.fromJson | 阻断编译（需重新生成） |

### 不修改（API 契约保留）
- `lib/modules/music_subsonic/repository/subsonic_client.dart` — `getSong()`、`SubsonicSong` 为 Subsonic API 契约
- `lib/modules/music_subsonic/repository/subsonic_models.dart` — `SubsonicSong` 类、`songs` 字段
- `lib/modules/music_lx_server/repository/lx_server_client.dart` — `getLeaderboardSongs()` 为 API 契约
- `lib/modules/music_lx_server/repository/lx_server_models.dart` — `LxServerSong` 类
- `lib/core/routers/app_router.gr.dart` — 路由生成文件，`coverUrl`/`creator` 参数保留

---

## 已确立的决策与约定

1. **API 契约保留**：`SubsonicSong`、`LxServerSong`、`client.getSong()`、`client.getLeaderboardSongs()` 保持原名
2. **PlaylistDetailPage 构造参数保留**：`coverUrl`、`creator` 参数名不变（避免触发路由 regen），传入时用 `playlist.coverArt` / `playlist.owner ?? ''`
3. **`songCount` 字段名保留**：Album/Playlist 模型中的 `songCount` 是 Subsonic schema 字段，保持不变
4. **union 类型扁平化**：Track 有可选 `src`/`path`；`isLocal`/`isOnline` getter；`is! SongFull` → `src == null`；`is! SongLocal` → `path == null`
5. **`.map(full:..., local:...)` 替换**：直接字段访问，如 `track.coverArt`、`track.album`、`track.src ?? track.path`
6. **字段映射**：`track.name`→`track.title`、`track.coverUrl`→`track.coverArt`、`track.albumName`→`track.album`；`playlist.coverUrl`→`playlist.coverArt`、`playlist.creator`→`playlist.owner`、`playlist.description`→`playlist.comment`
7. **DateTime 健壮解析**：已由 `lib/core/extensions/date_time.dart` 的 `tryParseDateTime(dynamic)` 实现，支持 ISO8601、epoch 毫秒、`yyyy-MM-dd HH:mm:ss`、`/`/`.` 分隔符
8. **`@immutable` + 手动 copyWith**：所有模型已用 `@immutable` 注解，copyWith 带 `clearX` 布尔参数处理可空字段
9. **生成文件**：`state.freezed.dart`、`state.g.dart` 通过 `build_runner` 重新生成，不手动编辑

---

## 实施步骤

### Step 1：UI Player 文件（3 个文件）

#### 1.1 `lib/ui/player/mini_player.dart`
- **L4** import：`song.dart` → `track.dart`
- **L38** 注释：`空 Song 占位` → `空 Track 占位`
- **L99** 方法签名：`Song track,` → `Track track,`
- **L122** 字段访问：`track.name,` → `track.title,`
- **L184** 方法签名：`Widget _buildCover(BuildContext context, Song track, double size)` → `Track track`
- **L185-188** union 模式：
  ```dart
  // 旧
  final coverUrl = track.map(
    full: (f) => f.coverUrl,
    local: (l) => null,
  );
  // 新
  final coverUrl = track.coverArt;
  ```

#### 1.2 `lib/ui/player/lyric_view.dart`
- **L4** import：`song.dart` → `track.dart`
- **L13** 注释：`非 SongFull 或服务不支持歌词时返回 null` → `非在线曲目或服务不支持歌词时返回 null`
- **L15** Provider 类型：`FutureProvider.autoDispose.family<String?, Song>` → `<String?, Track>`
- **L16** 类型判断：`if (song is! SongFull) return null;` → `if (song.src == null) return null;`
- **L19** 字段访问：`module?.service(song.source.id)` → 不变（source 字段名未变）
- **L22** 方法调用：`service.getLyric(song)` → `service.getLyric(song)`（参数名不变，类型已由签名保证）

#### 1.3 `lib/ui/player/playback_page.dart`
- **L8** import：`song.dart` → `track.dart`
- **L137** 字段声明：`final Song track;` → `final Track track;`（_MobileLayout）
- **L161-162** union 模式（_MobileLayout）：
  ```dart
  // 旧
  final coverUrl = track.map(full: (f) => f.coverUrl, local: (l) => null);
  final albumName = track.map(full: (f) => f.albumName, local: (l) => null);
  // 新
  final coverUrl = track.coverArt;
  final albumName = track.album;
  ```
- **L227** 字段访问：`track.name,` → `track.title,`
- **L373** 字段声明：`final Song track;` → `final Track track;`（_DesktopLayout）
- **L397-398** union 模式（_DesktopLayout）：同 L161-162
- **L471** 字段访问：`track.name,` → `track.title,`

### Step 2：UI Music 文件（3 个文件）

#### 2.1 `lib/ui/music/search_page.dart`
- **L18** import：`song_tile.dart` → `track_tile.dart`
- **L318** 变量：`final songs = data.songs;` → `final tracks = data.tracks;`
- **L323** 判空：`if (songs.isEmpty)` → `if (tracks.isEmpty)`
- **L348** 文案：`'找到 ${songs.length} 首歌曲'` → `'找到 ${tracks.length} 首歌曲'`
- **L355** 计数：`itemCount: songs.length` → `itemCount: tracks.length`
- **L357** 取值：`final merged = songs[index];` → `final merged = tracks[index];`
- **L358-367** 组件调用：
  ```dart
  // 旧
  return SongTile(
    song: merged.primary,
    ...
    PlayPauseButton(song: merged.primary),
  );
  // 新
  return TrackTile(
    track: merged.primary,
    ...
    PlayPauseButton(track: merged.primary),
  );
  ```

#### 2.2 `lib/ui/music/playlist_detail_page.dart`
- **L11** import：`song_list.dart` → `track_list.dart`
- **L19-20** Provider 重命名 + 类型：
  ```dart
  // 旧
  final playlistSongsProvider =
      FutureProvider.family<List<Song>, ({String sourceId, String playlistId})>(
  // 新
  final playlistTracksProvider =
      FutureProvider.family<List<Track>, ({String sourceId, String playlistId})>(
  ```
- **L26** 方法调用：`service.getPlaylistSongs(params.playlistId)` → `service.getPlaylistTracks(params.playlistId)`
- **L51, L135** Provider 引用：`playlistSongsProvider(` → `playlistTracksProvider(`
- **L73** 回调参数：`data: (songs) {` → `data: (tracks) {`
- **L79** 字段：`songCount: songs.length,` → `songCount: tracks.length,`（songCount 是 _PlaylistHeader 参数名，保留）
- **L80** 字段：`songs: songs,` → `tracks: tracks,`
- **L83** 判空：`final songListContent = songs.isEmpty` → `tracks.isEmpty`
- **L93** 组件：`SongList(songs: songs, showMoreActions: true)` → `TrackList(tracks: tracks, showMoreActions: true)`
- **L156** 字段声明：`final List<Song> songs;` → `final List<Track> tracks;`
- **L163** 构造参数：`required this.songs,` → `required this.tracks,`
- **L231** 组件：`PlayAllButton(songs: songs)` → `PlayAllButton(tracks: tracks)`
- **保留不变**：PlaylistDetailPage 构造参数 `coverUrl`、`creator`（路由生成文件依赖）

#### 2.3 `lib/ui/music/playlist_section.dart`
- **L291** 字段访问：`coverUrl: playlist.coverUrl,` → `coverUrl: playlist.coverArt,`（传给 PlaylistDetailRoute，参数名保留）
- **L292** 字段访问：`creator: playlist.creator,` → `creator: playlist.owner ?? '',`
- **L306-307** 判空：`playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty` → `playlist.coverArt != null && playlist.coverArt!.isNotEmpty`
- **L309** 取值：`playlist.coverUrl!` → `playlist.coverArt!`
- **L330** 判空：`if (playlist.creator.isNotEmpty)` → `if ((playlist.owner ?? '').isNotEmpty)`
- **L833** 取值：`playlist.creator,` → `playlist.owner ?? '',`

### Step 3：UI Home 与 PlayQueue 文件（2 个文件）

#### 3.1 `lib/ui/home/home_page.dart`
- **L12** import：`song_tile.dart` → `track_tile.dart`
- **L327** Provider：`leaderboardSongsProvider` → `leaderboardTracksProvider`
- **L330** 变量名：`songsAsync` → `tracksAsync`（局部变量，可选但建议一致）
- **L331** 回调：`data: (songs) {` → `data: (tracks) {`
- **L332** 判空：`if (songs.isEmpty)` → `if (tracks.isEmpty)`
- **L343** 计数：`itemCount: songs.length` → `itemCount: tracks.length`
- **L345** 取值：`final song = songs[index];` → `final track = tracks[index];`
- **L346-349** 组件调用：
  ```dart
  // 旧
  return SongTile(
    song: song,
    index: index + 1,
    trailing: PlayPauseButton(song: song),
  );
  // 新
  return TrackTile(
    track: track,
    index: index + 1,
    trailing: PlayPauseButton(track: track),
  );
  ```
- **L792** 字段访问：`coverUrl: playlist.coverUrl,` → `coverUrl: playlist.coverArt,`
- **L793** 字段访问：`creator: playlist.creator,` → `creator: playlist.owner ?? '',`
- **L809** 判空：`playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty` → `playlist.coverArt != null && playlist.coverArt!.isNotEmpty`
- **L811** 取值：`playlist.coverUrl!` → `playlist.coverArt!`
- **L829** 判空：`if (playlist.creator.isNotEmpty)` → `if ((playlist.owner ?? '').isNotEmpty)`
- **L833** 取值：`playlist.creator,` → `playlist.owner ?? '',`

#### 3.2 `lib/ui/player/widgets/play_queue_content.dart`
- **L7** import：`song_more_actions_button.dart` → `track_more_actions_button.dart`
- **L8** import：`song_tile.dart` → `track_tile.dart`
- **L48** 参数名保留：`songCount: tracks.length`（_QueueHeader 的 songCount 参数名保留，仅语义）
- **L71** 变量：`final song = tracks[index];` → `final track = tracks[index];`
- **L72** 比较：`activeTrack?.id == song.id` → `activeTrack?.id == track.id`
- **L73-94** 组件调用：
  ```dart
  // 旧
  return SongTile(
    song: song,
    ...
    trailing: Row(
      children: [
        PlayPauseButton(song: song),
        SongMoreActionsButton(
          song: song,
          onRemoveFromQueue: () => notifier.removeTrack(song.id),
        ),
      ],
    ),
    onTap: () => notifier.jumpToTrack(song),
  );
  // 新
  return TrackTile(
    track: track,
    ...
    trailing: Row(
      children: [
        PlayPauseButton(track: track),
        TrackMoreActionsButton(
          track: track,
          onRemoveFromQueue: () => notifier.removeTrack(track.id),
        ),
      ],
    ),
    onTap: () => notifier.jumpToTrack(track),
  );
  ```

### Step 4：Core 与 Test 文件（3 个文件）

#### 4.1 `lib/core/storage/persistent_repository.dart`（docstring）
- **L13** `class SongRepository extends PersistentRepository<Song>` → `class TrackRepository extends PersistentRepository<Track>`
- **L15** `String get boxName => 'songs';` → `=> 'tracks';`
- **L18** `String idSelector(Song item)` → `Track item`
- **L21** `Song fromJson(...) => Song(` → `Track fromJson(...) => Track(`
- **L23** `title: json['title'] as String? ?? '',` → 保持不变
- **L27** `Map<String, dynamic> toJson(Song item)` → `Track item`

#### 4.2 `lib/modules/audio_player/model/media.dart`（注释清理）
- **L131** 注释：`// extension AsMediaListSong on Iterable<Song> {` → `// extension AsMediaListTrack on Iterable<Track> {`

#### 4.3 `test/fluxy_boot_test.dart`
- **L39** 方法调用：`.toSong(` → `.toTrack(`

### Step 5：重新生成 freezed 文件

运行 build_runner 重新生成 `state.freezed.dart` 和 `state.g.dart`：

```powershell
dart run build_runner build --delete-conflicting-outputs
```

这会基于 `state.dart`（已使用 `Track`）重新生成引用 `List<Track>` 的代码。

### Step 6：验证

1. **静态分析**：
   ```powershell
   flutter analyze
   ```
   预期：0 errors（与重构前基线一致，可能保留原有 info 级提示）

2. **Grep 验证残留引用**：
   - `song.dart`、`song_tile.dart`、`song_list.dart`、`song_more_actions_button.dart`、`merged_song.dart` 在 lib/ 中应 0 引用
   - `\bSong\b`（单词边界）在 lib/ 中应仅出现在：`SubsonicSong`、`LxServerSong`、`state.freezed.dart`/`state.g.dart`（已 regen 后应消失）、注释中（可选清理）
   - `.map(full:`、`is! SongFull`、`is SongFull`、`SongLocal` 应 0 匹配
   - `track.name`、`track.coverUrl`、`track.albumName`、`playlist.coverUrl`、`playlist.creator` 应 0 匹配
   - `getPlaylistSongs`、`leaderboardSongsProvider`、`playlistSongsProvider`、`currentSourceSongsProvider` 应 0 匹配

3. **测试编译**：
   ```powershell
   flutter test test/fluxy_boot_test.dart
   ```
   预期：编译通过（测试逻辑本身可能因 lx 插件环境缺失而失败，但编译应通过）

---

## 假设与风险

1. **假设**：`build_runner` 配置正确，`state.dart` 的 freezed 注解完整。若 build_runner 失败，需检查 `pubspec.yaml` 依赖和 `build.yaml` 配置。
2. **假设**：路由生成文件 `app_router.gr.dart` 的 `PlaylistDetailRoute` 仍接受 `coverUrl`/`creator` 参数（已验证 L276-277、L289-290）。
3. **风险**：`subsonic_music_service.dart` L143 的局部变量 `song`（`final song = await client.getSong(id);`）类型为 `SubsonicSong`（API 类型），重命名为 `track` 会与已有 `track` 变量冲突吗？检查显示该作用域内无冲突，但**本计划不修改该文件**（局部变量名不影响编译，且 `SubsonicSong` 是保留类型，`song` 命名反而更贴切）。
4. **风险**：`audio_player.dart` L388 注释中的 `as SongFull` 不影响编译，本计划不强制清理（可选）。
5. **风险**：`subsonic_client.dart` L152 注释 `Album/Song Lists` 不影响编译，本计划不修改（API 文件保持原样）。

---

## 执行顺序建议

1. 先做 Step 1-3（8 个 UI 文件）—— 解除编译阻断
2. 再做 Step 4（3 个 core/test 文件）—— 清理文档和测试
3. 然后 Step 5（build_runner）—— 重新生成 freezed 文件
4. 最后 Step 6（验证）—— flutter analyze + grep 检查

每完成一个 Step 后可运行 `flutter analyze` 增量验证，但最终验证以 Step 6 为准。
