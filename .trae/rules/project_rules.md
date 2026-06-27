# Pomelo 项目架构规范

## 技术栈

- **UI 框架**: shadcn_flutter
- **状态管理**: Riverpod (hooks_riverpod, flutter_riverpod) + flutter_hooks
- **路由**: auto_route
- **响应式布局**: Rx.layout() / Rx.action()
- **持久化**: hive_ce + Settings

---

## 核心架构原则

### 1. 分层架构

```
┌─────────────────────────────────────────────┐
│  UI Layer (lib/ui/)                        │
│  - 页面、组件、UI Provider                  │
├─────────────────────────────────────────────┤
│  Module Layer (lib/modules/)               │
│  - 业务模块、服务、仓储、模块级 Provider     │
├─────────────────────────────────────────────┤
│  Core Layer (lib/core/)                    │
│  - 框架、存储、路由、日志、工具函数         │
└─────────────────────────────────────────────┘
```

### 2. Provider 分层原则

| 层级 | 位置 | 职责 |
|------|------|------|
| Core | `lib/core/storage/` | 全局存储 Provider（`settingsProvider`） |
| 模块级 | `lib/modules/*/providers/` | 模块实例、服务、仓储、业务状态 |
| UI 级 | `lib/ui/*/providers/` | 页面选中态、派生数据、UI 状态 |

### 3. 持久化策略

- **全局 KV**: 使用 `Settings.set/get`（基于 hive_ce）
- **模块级仓储**: 使用 `PersistentRepository<T>`（基于 hive_ce）
- **文件存储**: 仅 `lib/core/log/` 模块使用（JSON Lines）
- **内存存储**: 使用 `InMemoryRepository<T>`（`favorite`、`home`、`statistics`）

---

## 模型层规范

### 1. 核心模型类

所有模型位于 `lib/modules/music/model/`，通过 `models.dart` barrel 导出。

| 类 | 文件 | 说明 |
|----|------|------|
| `Track` | [track.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/modules/music/model/track.dart) | 曲目（替代旧 `Song`） |
| `Album` / `AlbumWithTracks` | [album.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/modules/music/model/album.dart) | 专辑 / 带曲目列表的专辑 |
| `Artist` / `ArtistWithAlbums` | [artist.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/modules/music/model/artist.dart) | 艺术家 / 带专辑列表的艺术家 |
| `Playlist` / `PlaylistCategory` | [playlist.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/modules/music/model/playlist.dart) | 歌单 / 歌单分类 |

### 2. 模型设计约定

- **`@immutable` 注解**: 所有模型类使用 `@immutable`（来自 `package:flutter/foundation.dart`），字段全 `final`
- **手写 `copyWith`**: 不使用 freezed；nullable 字段的 `copyWith` 带 `clearX` 布尔参数（如 `clearStarred`）
- **`fromJson` / `toJson`**: 手写，缺 key 容忍（`??` 兜底），支持零迁移 schema 升级
- **DateTime 解析**: 使用 `tryParseDateTime(dynamic)`（[date_time.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/core/extensions/date_time.dart)），兼容 ISO8601、epoch 毫秒、常见字符串格式
- **`==` / `hashCode`**: 按 `id` 判等

### 3. Track 模型要点

- **扁平结构**: 无 `SongFull` / `SongLocal` 联合类型，单一 `Track` 类用 `src`（在线地址）和 `path`（本地路径）区分
  - `bool get isLocal => path != null;`
  - `bool get isOnline => src != null;`
- **字段命名遵循 Subsonic 风格**: `title`（非 `name`）、`coverArt`（非 `coverUrl`）、`album`（非 `albumName`）
- **可空字段**: `artist`、`source`、`meta` 为可空，访问需 `?.` 或 `?? ''`
- **`source` 字段类型**: `({String id, String name, String? libraryId, String? libraryName})?`
  - `id` = 服务标识（如 `lx-server`、`lx-$pluginId`、`subsonic-xxx`、`local`）
  - `libraryId` = 库标识（如 `tx`、`kg`），无库概念时为 null

### 4. Playlist 模型要点

- `coverArt`（非 `coverUrl`）、`owner`（非 `creator`）、`comment`（非 `description`）
- `tracks` 字段（非 `songs`），类型 `List<Track>`
- `songCount` 字段名保留（Subsonic 命名）

### 5. media_kit 冲突处理

`package:media_kit` 也定义了 `Track` 类。导入 media_kit 时**必须**隐藏：

```dart
import 'package:media_kit/media_kit.dart' hide Track;
```

### 6. freezed 使用范围

- **仅** `AudioPlayerState`（`lib/modules/audio_player/model/state.dart`）使用 freezed + json_serializable
- 音乐模型（Track/Album/Artist/Playlist）**不使用** freezed
- 修改 `state.dart` 后需运行 `dart run build_runner build --delete-conflicting-outputs`

---

## 关键约定

### 1. Widget 基类选择

| 基类 | 适用场景 |
|------|----------|
| `HookConsumerWidget` | 优先使用，支持 hooks + ref |
| `ConsumerWidget` | 无需 hooks 时使用 |
| `StatelessWidget` | 不需要 ref 时使用 |

### 2. 响应式断点

| 断点 | 宽度范围 | 布局策略 |
|------|---------|----------|
| mobile | < 600px | 单列布局、底部导航 |
| tablet | 600-1024px | 双栏布局、侧边栏 |
| desktop | 1024-1440px | 多栏布局、展开侧边栏 |
| tv | >= 1440px | 最大宽度约束、多列网格 |

### 3. 导航模式

#### 3.1 响应式导航壳

| 端 | 导航壳 | 标题栏 |
|----|--------|--------|
| mobile (< 600px) | 底部 `NavigationBar` + 各页面自带 `AppBar` | 无统一标题栏 |
| tablet/desktop (>= 600px) | 左侧 `NavigationRail` + 顶部固定 `_DesktopTitleBar` | 统一标题栏 |

#### 3.2 桌面端标题栏（`_DesktopTitleBar`）

位于 `lib/ui/root/root_page.dart`，固定在 Root 页面顶部，包含：

| 位置 | 内容 | 说明 |
|------|------|------|
| 左侧 | 返回按钮 | 监听 `rootCanPopProvider`，根页面禁用，有内联导航时激活 |
| 中部 | 库切换 + 平台切换 + 搜索框 | 从各页面 AppBar 上移至标题栏统一承载 |
| 右侧 | 最小化 + 关闭 | `windowManager.minimize()` / `windowManager.destroy()`，仅 `Helper.isDesktop` 时显示 |

- 关闭使用 `destroy()` 而非 `close()`（`main.dart` 中 `setPreventClose(true)`）
- 桌面端各 Tab 页面不再自带 `AppBar`（搜索/切换由标题栏承载），移动端保留各自 `AppBar`

#### 3.3 Root 导航 Provider（`lib/ui/root/root_providers.dart`）

| Provider | 类型 | 说明 |
|----------|------|------|
| `activeTabIndexProvider` | `NotifierProvider<_, int>` | 当前激活 Tab 索引，由 Root 布局在 Tab 切换时 `set()` |
| `rootCanPopProvider` | `NotifierProvider<_, bool>` | 当前 Tab 是否有可返回的内联导航 |
| `rootPopCallbackProvider` | `NotifierProvider<_, VoidCallback?>` | 返回回调，标题栏返回按钮调用 |

**Tab 页面注册内联导航状态的约定**：

```dart
final activeTabIndex = ref.watch(activeTabIndexProvider);

useEffect(() {
  if (activeTabIndex == myTabIndex && hasInlineNav) {
    ref.read(rootCanPopProvider.notifier).set(true);
    ref.read(rootPopCallbackProvider.notifier).set(() => goBack());
    return () {
      ref.read(rootCanPopProvider.notifier).set(false);
      ref.read(rootPopCallbackProvider.notifier).set(null);
    };
  }
  return null;
}, [activeTabIndex, inlineNavState]);
```

- 必须以 `activeTabIndex` 作为依赖之一，确保切换 Tab 时正确设置/清除状态
- 清理函数（`return () => ...`）负责清除状态，防止非激活 Tab 污染标题栏

#### 3.4 页面打开位置约定

**除非特别指定，新页面默认在对应的 Tab 中内联打开**，不作为覆盖全屏的顶级路由。

| 方式 | 适用场景 | 实现 |
|------|----------|------|
| 内联状态导航（推荐） | Tab 内子页面（如歌单详情） | `useState<Ref?>` + `onClose` 回调，渲染在 Tab 内容区 |
| `openSheet` | 播放详情、播放队列等浮层 | 底部/右侧 Sheet，覆盖当前页面 |
| `showDialog` | 表单、确认框等对话框 | 桌面端对话框 |
| `context.pushRoute` | **仅限**需要覆盖全屏（含底部导航）的场景 | 谨慎使用 |

**内联页面模式**（参考 `PlaylistDetailPage`）：

```dart
// 子页面添加可选 onClose 回调
class DetailPage extends HookConsumerWidget {
  final VoidCallback? onClose;
  // onClose 非 null 时，返回按钮调用 onClose；否则用 context.router.maybePop()
}

// Tab 页面用 useState 控制内联渲染
final viewingDetail = useState<Ref?>(null);
if (viewingDetail.value != null) {
  return DetailPage(..., onClose: () => viewingDetail.value = null);
}
return NormalContent(...);
```

#### 3.5 弹窗与菜单交互模式

沿用 `Rx.action(context, mobile:, tablet:)` 模式，详见下方 [弹窗与菜单交互模式](#弹窗与菜单交互模式) 章节。

**关闭面板约定（按弹层类型区分）**：

| 弹层类型 | 关闭方式 | 原因 |
|----------|----------|------|
| `openSheet` / `showDropdown` | `closeOverlay(context)` | shadcn_flutter 的 sheet/dropdown 走 Overlay（非 Navigator 栈），`Navigator.pop()` 会误弹真实路由导致白屏 |
| `showDialog` | `Navigator.of(context).pop()` 或 `Navigator.of(context, rootNavigator: true).pop()` | 走 Flutter 标准的 `DialogRoute`（Navigator 栈） |

**关键注意**：
- `closeOverlay(context)` 通过 `Data.maybeFind<OverlayHandlerStateMixin>(context)` 查找最近 sheet/dropdown 的状态并关闭，`context` 必须是 sheet/dropdown **内部**的 BuildContext
- 每个 `Scaffold` 都会创建一个空的 `DrawerOverlay`，其 `PopScope(canPop: _entries.isEmpty)` 在空时为 `true`，因此从 sheet 内部的 Scaffold 调用 `Navigator.pop()` 会穿透到父 Navigator 弹出真实路由（如 RootPage），造成白屏
- `MenuButton` 默认 `autoClose: true`，按下后自动关闭 dropdown，无需手动调用 `closeOverlay`

---

## 组件使用规范

### 1. 列表项

- **必须**使用 `package:pomelo/core/framework/framework.dart` 中的 `ListTile`
- **必须**放在 `Card` 内部
- **多列表项**用 `Column` + `Divider(height: 1)` 分隔

### 2. 按钮组件

| 组件 | 用途 |
|------|------|
| `GhostButton` | 次要操作、取消 |
| `PrimaryButton` | 主要操作、确认 |
| `IconButton.text()` | 列表项内操作 |
| `IconButton.ghost()` | 工具栏次要操作 |
| `IconButton.destructive()` | 删除/危险操作 |

### 3. 间距组件

- 优先使用 `Gap()`（shadcn_flutter）
- 其次使用 `SizedBox()`
- 分隔使用 `Divider(height: 1)`

### 4. 曲目列表组件

| 组件 | 用途 |
|------|------|
| `TrackTile` | 统一曲目列表项（含封面、序号、高亮） |
| `TrackList` | 曲目列表容器 |
| `TrackMoreActionsButton` | 曲目更多操作按钮/菜单 |
| `PlayPauseButton` | 播放/暂停按钮，参数 `track:` |
| `PlayAllButton` | 全部播放，参数 `tracks:` |

---

## Provider 约定

### 1. 获取模块

```dart
// ✅ 正确
final module = ref.watch(musicModuleProvider);

// ❌ 错误
final module = ModuleManager().find<MusicModule>('music');
```

### 2. 异步数据

使用 `FutureProvider`，避免手动管理 loading/error 状态：

```dart
final searchResultsProvider = FutureProvider.family<SearchListData, Params>(
  (ref, params) async {
    // ...
  },
);
```

### 3. 选中态

跨页面状态使用 `NotifierProvider`，避免 `useState`：

```dart
// ✅ 正确
ref.watch(selectedLeaderboardProvider);

// ❌ 错误（页面切换后状态丢失）
final selectedId = useState<String?>(null);
```

### 4. 持久化选中态

| Provider | 持久化 |
|----------|--------|
| `selectedSourceProvider` | ✅ 是 |
| `selectedLeaderboardProvider` | ❌ 否 |
| `selectedPlaylistParentProvider` | ❌ 否 |
| `selectedPlaylistCategoryProvider` | ❌ 否 |
| `selectedPlaylistSortProvider` | ❌ 否 |

### 5. 曲目相关 Provider 命名

| Provider | 说明 |
|----------|------|
| `leaderboardTracksProvider` | 排行榜曲目（非 `leaderboardSongsProvider`） |
| `currentSourceTracksProvider` | 当前来源曲目 |
| `playlistTracksProvider` | 歌单曲目（非 `playlistSongsProvider`） |
| `searchResultsProvider` | 搜索结果，返回 `SearchListData`（含 `.tracks` 字段） |

### 6. MusicService 方法命名

| 方法 | 说明 |
|------|------|
| `searchTracks(keyword)` | 搜索曲目（非 `searchSongs`） |
| `getPlaylistTracks(id)` | 获取歌单曲目（非 `getPlaylistSongs`） |
| `getLeaderboardTracks(...)` | 获取排行榜曲目 |
| `LocalMusicService.trackCount` | 本地曲目数（非 `songCount`） |

---

## 持久化 Key 管理

所有 Settings Key 集中定义在 [storage_keys.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/core/storage/storage_keys.dart)：

| Key 常量 | 用途 | 所属模块 |
|----------|------|----------|
| `audioPlayerState` | 播放器状态 | audio_player |
| `logStorageLevel` | 日志存储级别 | core/log |
| `musicSelectedSource` | 当前选中来源 | music (UI) |
| `musicSelectedLibrary` | 当前选中库 | music (UI) |
| `musicLocalDirectories` | 本地音乐目录 | music_local |
| `musicLxMetadataPluginPath` | Lx 元数据插件路径 | music_lx |
| `musicLxSourcePluginPaths` | Lx 音源插件路径 | music_lx |
| `musicLxServerConfig` | Lx Server 配置 | music_lx_server |
| `musicLxServerQuality` | Lx Server 音质设置 | music_lx_server |
| `musicSubsonicAccounts` | Subsonic 账号 | music_subsonic |
| `myThemeMode` | 主题模式 | my |
| `myLyricFontSize` | 歌词字体大小 | my |
| `myAutoPlay` | 自动播放开关 | my |

---

## Lx 音乐模块架构

### 双引擎设计

| 引擎 | 职责 | 插件数量 |
|------|------|----------|
| `LxMetadataEngine` | 搜索、元信息、歌单、排行榜 | 仅 1 份 |
| `LxSourceEngine` | 获取播放链接 | 支持多份 |

### 响应式模式

桌面端用对话框，移动端用全屏页面：

```dart
Rx.action(
  context,
  mobile: () => Navigator.push(...),
  tablet: () => showDialog(...),
);
```

### 弹窗与菜单交互模式

所有"次要面板/菜单"按场景分流，统一用 `Rx.action(context, mobile: ..., tablet: ...)`：

| 场景 | 移动端 | 桌面端 |
|------|--------|--------|
| 全屏页面（如播放队列页） | `context.pushRoute(XxxRoute())` | `openSheet(position: OverlayPosition.right, builder:)` |
| 表单/详情对话框 | `Navigator.push(MaterialPageRoute)` 全屏页 | `showDialog(builder:)` |
| 曲目更多操作菜单 | `openSheet(position: OverlayPosition.bottom, draggable: true)` | `showDropdown(builder: (_) => DropdownMenu(children:))` |
| 危险/确认操作 | `showDialog` 确认框 | `showDialog` 确认框 |

```dart
// 播放队列入口（移动端全屏 / 桌面端右侧 Sheet）
void _openPlayQueue(BuildContext context) {
  Rx.action(
    context,
    mobile: () => context.pushRoute(const PlayQueueRoute()),
    tablet: () => openSheet(
      context: context,
      position: OverlayPosition.right,
      builder: (_) => const SizedBox(width: 360, child: PlayQueueContent()),
    ),
  );
}

// 曲目更多操作菜单（移动端底部 Sheet / 桌面端 DropdownMenu）
void _openActions(BuildContext context, WidgetRef ref) {
  Rx.action(
    context,
    mobile: () => openSheet(
      context: context,
      position: OverlayPosition.bottom,
      draggable: true,
      builder: (_) => TrackMoreActionsContent(track: track, onRemoveFromQueue: onRemoveFromQueue),
    ),
    tablet: () => showDropdown(
      context: context,
      builder: (_) => DropdownMenu(children: _buildMenuItems(context, ref)),
    ),
  );
}

// 移动端 sheet 内容组件内部用 closeOverlay(context) 关闭
// 桌面端 dropdown 的 MenuButton 默认 autoClose: true，无需手动关闭
```

**共享内容组件模式**：移动端与桌面端复用同一组件，移动端用 `Column + ListTile + Divider(height: 1)` 嵌入 `openSheet`，桌面端用 `DropdownMenu(children: List<MenuItem>)`。

**关闭面板约定**：见上方 [3.5 弹窗与菜单交互模式](#35-弹窗与菜单交互模式) 章节。`openSheet`/`showDropdown` 必须用 `closeOverlay(context)`，`showDialog` 用 `Navigator.pop()`。

### shadcn_flutter 菜单/按钮 API

| 组件 | 用途 | 关键参数 |
|------|------|---------|
| `openSheet` | 侧边/底部面板 | `position: OverlayPosition.right/bottom/left/top`、`draggable`、`barrierDismissible` |
| `showDropdown<T>` | 命令式下拉菜单 | `context`、`builder` 返回 `DropdownMenu`，返回 `OverlayCompleter<T?>` |
| `DropdownMenu` | 菜单容器 | `children: List<MenuItem>` |
| `MenuButton` | 菜单项（具体类） | `leading`、`child`、`onPressed: (BuildContext) =>`、`trailing` |
| `MenuLabel` | 菜单标题（不可点） | `child` |
| `MenuDivider` | 菜单分隔线 | 无参数 |
| `PrimaryButton` | 主按钮 | `leading:`（图标）、`child:`（文案）、`onPressed:`、`enabled:` |
| `GhostButton` / `DestructiveButton` | 次要/危险按钮 | 同上 |

**易错点**：
- `MenuItem` 是**抽象类**，不能直接 `MenuItem(...)`，必须用具体子类 `MenuButton`
- `PrimaryButton` 没有 `.icon` 命名构造，加图标用 `leading:` 参数
- `MenuButton.onPressed` 签名是 `void Function(BuildContext)`，不是 `VoidCallback`

---

## 多源错误处理

使用 `ServiceResult<T>` + `safeCallServices<T>()` 逐服务隔离异常：

```dart
final results = await safeCallServices<PaginationResponse<Track>>(
  services,
  (s) => s.searchTracks(keyword),
  getId: (s) => s.sourceId,
  getName: (s) => s.sourceName,
);
```

---

## 常见错误避免

1. **不要使用 Material 的 ListTile** - 必须使用自定义的
2. **不要编造不存在的组件** - 如 `ShadDialog`、`ShadButton` 等不存在
3. **IconButton 必须使用命名构造函数** - `IconButton.text()` 等
4. **ListTile 必须在 Card 内** - 不要单独使用
5. **间距优先使用 Gap** - 而不是 SizedBox
6. **AppBar.leading 是 List\<Widget\>** - 不是单个 Widget
7. **不要直接调用 ModuleManager** - 应通过 Provider 获取模块
8. **导入 media_kit 时 hide Track** - 避免与 pomelo Track 歧义
9. **勿用 `FutureBuilder`** - 使用 Provider + `AsyncValue.when`
10. **不要使用 `Song` 命名** - 已统一为 `Track`（API 契约层 `SubsonicSong`/`LxServerSong` 除外）
11. **Track 可空字段访问** - `artist`、`source`、`meta` 为可空，Text 组件需 `?? ''`，属性访问需 `?.`
12. **新页面默认在 Tab 内联打开** - 使用 `useState` + `onClose` 回调模式，不作为顶级路由覆盖全屏（除非特别指定）
13. **桌面端页面不再自带 AppBar** - 搜索/切换由 Root 标题栏统一承载，仅移动端保留各自 AppBar
14. **窗口关闭用 `destroy()`** - `main.dart` 中 `setPreventClose(true)`，`close()` 会被拦截
15. **内联导航状态需注册到 Root Provider** - Tab 页面用 `useEffect` 监听 `activeTabIndexProvider`，设置/清除 `rootCanPopProvider` 和 `rootPopCallbackProvider`

---

## 已删除/废弃代码

- `Song` 类 — 已重命名为 `Track`，字段 `name`→`title`、`coverUrl`→`coverArt`、`albumName`→`album`
- `SongFull` / `SongLocal` 联合类型 — 已扁平化为 `Track`（用 `src`/`path` 区分）
- `SongTile` / `SongList` / `SongMoreActionsButton` — 已重命名为 `TrackTile` / `TrackList` / `TrackMoreActionsButton`
- `playlistSongsProvider` / `leaderboardSongsProvider` — 已重命名为 `playlistTracksProvider` / `leaderboardTracksProvider`
- `searchSongs()` / `getPlaylistSongs()` — 已重命名为 `searchTracks()` / `getPlaylistTracks()`
- `lib/ui/music/model/provider_result.dart` — 已删除
- `lib/modules/log/` — 已迁移至 `lib/core/log/`
- 音乐模型的 freezed 依赖 — 已移除，改为手写 `@immutable` + `copyWith`
- `FutureBuilder` — 勿用，改用 Provider + `AsyncValue.when`

---

## 代码生成

代码生成相关的模板和模式请参考：[code_templates.md](code_templates.md)
