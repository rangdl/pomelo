# Pomelo 项目规则

> 本文件是项目唯一规则来源，整合架构规范、代码模板、组件约定与 Git 规范。
> 所有 AI 辅助编码与代码生成**必须**遵循本文件。

---

## 一、技术栈

- **UI 框架**: shadcn_flutter
- **状态管理**: Riverpod（hooks_riverpod / flutter_riverpod）+ flutter_hooks
- **路由**: auto_route
- **响应式布局**: `Rx.layout()` / `Rx.action()`
- **持久化**: drift（SQLite），统一 `AppDatabase`（schema v4）
- **日志**: `AppLogger`（`lib/services/logger.dart`，基于 `package:logger`，JSON Lines 文件存储）

---

## 二、分层架构

```
┌─────────────────────────────────────────────┐
│  UI Layer (lib/ui/)                        │
│  - 页面、组件、UI Provider                  │
├─────────────────────────────────────────────┤
│  Provider Layer (lib/provider/)            │
│  - Riverpod 状态管理（播放器、数据库、历史、  │
│    服务器）                                 │
├─────────────────────────────────────────────┤
│  Service Layer (lib/services/)             │
│  - 无状态服务（音频播放器、系统媒体控制、     │
│    更新、日志）                             │
├─────────────────────────────────────────────┤
│  Module Layer (lib/modules/)               │
│  - 业务模块、MusicServer、仓储               │
├─────────────────────────────────────────────┤
│  Core Layer (lib/core/)                    │
│  - 框架工具、数据库、路由、UserPreference     │
└─────────────────────────────────────────────┘
```

### Service 层与 Provider 层的关系

| 层级 | 位置 | 职责 | 示例 |
|------|------|------|------|
| Service | `lib/services/` | 无状态服务，封装核心业务逻辑，不依赖 Riverpod | `audioPlayer`（全局实例）、`AudioServices`、`AppLogger` |
| Provider | `lib/provider/` | 对应 Service 的 Riverpod 状态管理，持有 `Ref` | `audioPlayerProvider`、`appDatabaseProvider`、`playHistoryProvider` |

> **约定**：Service 层不持有 `Ref`，不直接读写 Provider；Provider 层通过 `Ref` 访问 Service 和其他 Provider。

### Provider 分层

| 层级 | 位置 | 职责 |
|------|------|------|
| Core | `lib/core/preferences/` | 全局设置 Provider（`userPreferenceProvider`） |
| Core | `lib/core/providers/` | 全局配置 Provider（`musicServerConfigsProvider`） |
| Provider | `lib/provider/audio_player/` | 播放器状态（`audioPlayerProvider`）、流监听（`AudioPlayerStreamListeners`） |
| Provider | `lib/provider/database/` | 数据库 Provider（`appDatabaseProvider`） |
| Provider | `lib/provider/history/` | 播放历史 Provider（`playHistoryProvider`） |
| Provider | `lib/provider/server/` | 播放服务器 Provider（`serverProvider`、`sourcedTrackProvider`） |
| 模块级 | `lib/modules/*/providers/` | MusicServer 实例、业务状态 |
| UI 级 | `lib/ui/*/providers/` | 页面选中态、派生数据、UI 状态 |

---

## 三、模块系统

### 1. 核心服务初始化

应用启动时不再使用 `AudioPlayerModule`，直接在 `main.dart` 中初始化核心服务与 Provider。

**初始化流程**（`main.dart`）：

```dart
final database = AppDatabase();
final persistedPref = await UserPreference.loadFromDatabase(database);
MusicCacheDir.setCustomDirectory(persistedPref.cacheDirectory);
MusicCacheDir.setSizeLimit(persistedPref.cacheSizeLimitGB);

final container = ProviderContainer(
  overrides: [appDatabaseProvider.overrideWithValue(database)],
  observers: [AppLoggerProviderObserver()],
);

await container.read(userPreferenceProvider.notifier).initialize();

runApp(UncontrolledProviderScope(container: container, child: const Pomelo()));
```

**播放器流监听与服务器**在 `Pomelo` widget 中通过 `ref.listen` 启动：

```dart
ref.listen(audioPlayerStreamListenersProvider, (_, _) {});
ref.listen(serverProvider, (_, _) {});
```

| 服务/Provider | 文件 | 说明 |
|---------------|------|------|
| `audioPlayer`（全局实例） | `lib/services/audio_player/audio_player.dart` | 无状态播放器服务 |
| `audioPlayerProvider` | `lib/provider/audio_player/audio_player.dart` | 播放器状态管理 |
| `audioPlayerStreamListenersProvider` | `lib/provider/audio_player/audio_player_streams.dart` | 流监听（SMTC、播放历史、歌词） |
| `appDatabaseProvider` | `lib/provider/database/database_provider.dart` | 数据库 Provider |
| `serverProvider` | `lib/provider/server/server.dart` | 播放服务器 |

### 2. 业务模块

业务模块（`music_local`、`music_lx`、`music_lx_server`、`music_subsonic` 等）直接通过 Riverpod Provider 创建 `MusicServer` 实例，配置统一从 `musicServerConfigsProvider` 读取。

### 3. 日志

使用 `AppLogger`（`lib/services/logger.dart`）：
- `AppLogger.log.d/i/w/e(...)` 用于普通日志
- `AppLogger.reportError(error, stackTrace, message)` 用于错误上报

---

## 四、持久化策略（drift）

### 1. AppDatabase

- 文件：`lib/core/models/database/app_database.dart`
- schema 版本：**v4**
- 数据库文件路径：`<documents>/pomelo/app.db`（Windows 平台 `getApplicationDocumentsDirectory()` 返回文档根目录，故增加 `pomelo` 子目录）

### 2. 表结构

| 表 | 用途 | 版本 |
|----|------|------|
| `PlayerStateTable` | 播放器状态（单行 id=0） | v1 |
| `PlayerTrackTable` | 当前播放列表曲目 | v1 |
| `PlayHistoryTable` | 播放记录（含 playCount，upsert 语义） | v1/v2 |
| `SourcedTrackTable` | 已解析音源曲目（播放链接与缓存路径持久化） | v2 |
| `PreferenceTable` | UserPreference JSON（单行 id=0） | v3 |
| `MusicServerConfigTable` | 音乐服务配置（单表多行） | v4 |

### 3. schema 升级约定

新增表时：
1. 创建 `xxx_table.dart` 定义 `Table` 子类
2. 在 `AppDatabase` 的 `@DriftDatabase(tables: [...])` 添加
3. `schemaVersion` 递增
4. 在 `migration.onUpgrade` 添加 `if (from < N) await m.createTable(xxxTable)`
5. 运行 `dart run build_runner build --delete-conflicting-outputs`

### 4. Provider 访问

```dart
// AppDatabase Provider（在 main.dart 中 overrideWithValue）
final appDatabaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError());
```

### 5. 存储相关文件

- `lib/core/storage/music_cache_dir.dart`：音频流缓存目录管理
- **已删除**：`settings.dart`、`storage_keys.dart`、`persistent_repository.dart`（旧 hive_ce 方案）

---

## 五、UserPreference（用户偏好设置）

### 1. 字段清单

所有用户偏好集中在 `UserPreference` 实体类（`lib/core/preferences/user_preference.dart`），整体序列化为 JSON 存入 `PreferenceTable`（单行 id=0）。

| 字段 | 类型 | 说明 |
|------|------|------|
| `themeMode` | `String` | 主题模式（'light'/'dark'/'system'） |
| `lyricFontSize` | `int` | 歌词字体大小 |
| `autoPlay` | `bool` | 自动播放开关 |
| `updateProxy` | `String?` | 更新代理地址 |
| `selectedSourceId` | `String?` | 当前选中音乐源 |
| `selectedLibraryId` | `String?` | 当前选中库 |
| `logStorageLevel` | `LogLevel` | 日志存储级别 |
| `cacheDirectory` | `String?` | 音频流缓存目录（null=系统默认） |
| `cacheSizeLimitGB` | `int` | 缓存上限（1~5，默认 1） |
| `lxServerQuality` | `LxServerQuality` | 全局音质偏好 |

> **注意**：音乐源配置（local/lx/lxServer/subsonic）已迁移到 `MusicServerConfigTable`，**不在** `UserPreference` 中。

### 2. 读写约定

**必须**通过 `userPreferenceProvider` 读写：

```dart
// ✅ 读取
final themeMode = ref.watch(userPreferenceProvider.select((p) => p.themeMode));

// ✅ 写入
await ref.read(userPreferenceProvider.notifier).setThemeMode('dark');

// ❌ 错误：旧的 Settings/StorageKeys 已删除
// await Settings.set(StorageKeys.myThemeMode, 'dark');
```

### 3. 新增字段流程

1. 在 `UserPreference` 类添加 `final` 字段 + 构造函数默认值
2. 在 `fromJson` 添加解析（`??` 兜底）
3. 在 `toJson` 添加序列化
4. 在 `copyWith` 添加参数（可空字段用 sentinel 对象区分"不更新"与"清除为 null"）
5. 在 `UserPreferenceNotifier` 添加 `setXxx` 方法

### 4. copyWith 可空字段约定

可空字段（`updateProxy`/`selectedSourceId`/`selectedLibraryId`/`cacheDirectory`）使用 sentinel 对象：

```dart
Object? selectedSourceId = _unset,
// 传 null = 显式清除；不传 = 保持原值
```

---

## 六、MusicServerConfig（音乐源统一配置）

### 1. 配置基类与子类

文件：`lib/core/models/music_server_config.dart`

`sealed class MusicServerConfig` 定义公共字段 `id`/`name`/`type`，各子类继承并增加自身特定字段：

| 子类 | type | 特有字段 | sourceId 格式 |
|------|------|----------|---------------|
| `LocalMusicConfig` | `local` | `directories: List<String>` | `local` |
| `LxPluginConfig` | `lx` | `metadataPluginPath: String`、`sourcePluginPaths: List<String>` | `lx-$pluginId` |
| `LxServerConfig` | `lxServer` | `serverUrl`/`username`/`password`/`token?`/`proxyPlayback`/`allowSourceSwitching` | `lx-server-$hash` |
| `SubsonicConfig` | `subsonic` | `serverUrl`/`username`/`password`/`token?`/`salt?`/`version?`/`pathPrefix?` | `subsonic-$hash-$username` |

- `name` 替代原 `LxServerConfig.displayName` / `SubsonicAccountConfig.displayName`
- 子类提供 `extraToJson()` 和 `fromJson(id, name, extra)` 用于序列化额外字段

### 2. 持久化策略

drift `MusicServerConfigTable`（单表多行）：
- 基类字段（id/name/type）映射到表列
- 子类额外字段以 JSON 字符串存入 `config_json` 列
- `enabled` 列默认 true

```dart
class MusicServerConfigTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get configJson => text().withDefault(const Constant('{}'))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}
```

### 3. Provider 架构

文件：`lib/core/providers/music_server_config_provider.dart`

```dart
// 所有配置列表（FutureProvider）
final musicServerConfigsProvider = FutureProvider<List<MusicServerConfig>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.getAllMusicServerConfigs();
  return rows.map(_entityToConfig).toList();
});

// 配置管理 Notifier（upsert/remove/getByType/getById）
final musicServerConfigsNotifierProvider =
    NotifierProvider<MusicServerConfigsNotifier, List<MusicServerConfig>>(...);
```

**关键特性**：配置变更通过 `ref.invalidate(musicServerConfigsProvider)` 触发刷新，所有依赖它的音乐源 Provider 自动重建。

### 4. 各音乐源 Provider 读取配置

| 来源 | Provider | 读取的配置类型 |
|------|----------|---------------|
| local | `localMusicServerProvider` | `LocalMusicConfig` |
| lx | `lxMetadataEngineProvider` / `lxSourceEngineProvider` | `LxPluginConfig` |
| lxServer | `lxServerMusicServerProvider` | `LxServerConfig` |
| subsonic | `subsonicServersProvider` | `SubsonicConfig` |

```dart
final configs = await ref.watch(musicServerConfigsProvider.future);
final config = configs.whereType<LxServerConfig>().firstOrNull;
```

---

## 七、MusicServer 实体

### 1. 核心抽象

所有音乐来源统一实现 `MusicServer` 抽象类（`lib/modules/music/model/music_server.dart`）：

| 子类 | 文件 | 说明 |
|------|------|------|
| `LocalMusicServer` | `lib/modules/music_local/service/local_music_server.dart` | 本地音乐 |
| `LxMusicServer` | `lib/modules/music_lx/model/lx_music_server.dart` | Lx 音乐（JS 插件） |
| `LxServerMusicServer` | `lib/modules/music_lx_server/repository/lx_server_music_server.dart` | Lx Server |
| `SubsonicMusicServer` | `lib/modules/music_subsonic/repository/subsonic_music_server.dart` | Subsonic/Navidrome |

### 2. Provider 聚合

```dart
final musicServersProvider = FutureProvider<List<MusicServer>>((ref) async {
  final local = await ref.watch(localMusicServerProvider.future);
  final lx = await ref.watch(lxMusicServerProvider.future);
  final lxServer = await ref.watch(lxServerMusicServerProvider.future);
  final subsonic = await ref.watch(subsonicServersProvider.future);
  return [local, ?lx, ?lxServer, ...subsonic];
});

final musicServerByProvider = FutureProvider.family<MusicServer?, String>(...);

// 当前选中的音乐服务（监听 selectedSourceId，自动选择/初始化）
final musicServerProvider = FutureProvider<MusicServer?>((ref) async { ... });
```

### 3. MusicServer 方法命名

| 方法 | 说明 |
|------|------|
| `searchTracks(keyword)` | 搜索曲目（非 `searchSongs`） |
| `getPlaylistTracks(id)` | 获取歌单曲目（非 `getPlaylistSongs`） |
| `getLeaderboardTracks(...)` | 获取排行榜曲目 |
| `LocalMusicServer.trackCount` | 本地曲目数（非 `songCount`） |

---

## 八、模型层规范

### 1. 核心模型类

所有模型位于 `lib/modules/music/model/`，通过 `models.dart` barrel 导出。

| 类 | 说明 |
|----|------|
| `Track` | 曲目（替代旧 `Song`） |
| `Album` / `AlbumWithTracks` | 专辑 / 带曲目列表的专辑 |
| `Artist` / `ArtistWithAlbums` | 艺术家 / 带专辑列表的艺术家 |
| `Playlist` / `PlaylistCategory` | 歌单 / 歌单分类 |

### 2. 模型设计约定

- **`@immutable` 注解**：所有模型类使用 `@immutable`，字段全 `final`
- **手写 `copyWith`**：不使用 freezed；nullable 字段的 `copyWith` 带 `clearX` 布尔参数
- **`fromJson` / `toJson`**：手写，缺 key 容忍（`??` 兜底），支持零迁移 schema 升级
- **DateTime 解析**：使用 `tryParseDateTime(dynamic)`，兼容 ISO8601、epoch 毫秒、常见字符串格式
- **`==` / `hashCode`**：按 `id` 判等

### 3. Track 模型要点

- **扁平结构**：单一 `Track` 类用 `src`（在线地址）和 `path`（本地路径）区分
  - `bool get isLocal => path != null;`
  - `bool get isOnline => src != null;`
- **字段命名遵循 Subsonic 风格**：`title`（非 `name`）、`coverArt`（非 `coverUrl`）、`album`（非 `albumName`）
- **可空字段**：`artist`、`source`、`meta` 为可空，访问需 `?.` 或 `?? ''`
- **`source` 字段类型**：`({String id, String name, String? libraryId, String? libraryName})?`

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

- **仅** `AudioPlayerState`（`lib/services/audio_player/state.dart`）使用 freezed + json_serializable
- 音乐模型（Track/Album/Artist/Playlist）**不使用** freezed
- 修改 `state.dart` 或 drift 表后需运行 `dart run build_runner build --delete-conflicting-outputs`

### 7. LxServerQuality（全局音质偏好）

文件：`lib/core/models/lx_server_quality.dart`

音质偏好为**全局**设置，持久化到 `UserPreference.lxServerQuality`。`LxServerQuality` 枚举已从 `modules/music_lx_server/model/` 移动到 `core/models/`。

---

## 九、Widget 基类与响应式

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

---

## 十、导航模式

### 1. 响应式导航壳

| 端 | 导航壳 | 标题栏 |
|----|--------|--------|
| mobile (< 600px) | 底部 `NavigationBar` + 各页面自带 `AppBar` | 无统一标题栏 |
| tablet/desktop (>= 600px) | 左侧 `NavigationRail`（左侧固定） + 顶部固定 `_DesktopTitleBar` | 统一标题栏 |

### 2. 桌面端标题栏（`_DesktopTitleBar`）

位于 `lib/ui/root/root_page.dart`，固定在 Root 页面顶部：

| 位置 | 内容 | 说明 |
|------|------|------|
| 左侧 | 返回按钮 | 监听 `rootCanPopProvider`，根页面禁用，有内联导航时激活 |
| 中部 | 库切换 + 平台切换 + 搜索框 | 从各页面 AppBar 上移至标题栏统一承载 |
| 右侧 | 最小化 + 关闭 | `windowManager.minimize()` / `windowManager.destroy()`，仅 `Helper.isDesktop` 时显示 |

- 关闭使用 `destroy()` 而非 `close()`（`main.dart` 中 `setPreventClose(true)`）
- 桌面端各 Tab 页面不再自带 `AppBar`，移动端保留各自 `AppBar`

### 3. Root 导航 Provider

文件：`lib/ui/root/root_providers.dart`

| Provider | 类型 | 说明 |
|----------|------|------|
| `activeTabIndexProvider` | `NotifierProvider<_, int>` | 当前激活 Tab 索引 |
| `rootCanPopProvider` | `NotifierProvider<_, bool>` | 当前 Tab 是否有可返回的内联导航 |
| `rootPopCallbackProvider` | `NotifierProvider<_, VoidCallback?>` | 返回回调 |

**Tab 页面注册内联导航状态**：

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

### 4. 页面打开位置约定

**除非特别指定，新页面默认在对应的 Tab 中内联打开**，不作为覆盖全屏的顶级路由。

| 方式 | 适用场景 | 实现 |
|------|----------|------|
| 内联状态导航（推荐） | Tab 内子页面 | `useState<Ref?>` + `onClose` 回调 |
| `openSheet` | 播放详情、播放队列等浮层 | 底部/右侧 Sheet |
| `showDialog` | 表单、确认框 | 桌面端对话框 |
| `context.pushRoute` | **仅限**覆盖全屏（含底部导航） | 谨慎使用 |

**内联页面模式**（参考 `PlaylistDetailPage`）：

```dart
class DetailPage extends HookConsumerWidget {
  final VoidCallback? onClose;
  // onClose 非 null 时，返回按钮调用 onClose()；否则用 context.router.maybePop()
}

final viewingDetail = useState<Ref?>(null);
if (viewingDetail.value != null) {
  return DetailPage(..., onClose: () => viewingDetail.value = null);
}
return NormalContent(...);
```

---

## 十一、弹窗与菜单交互模式

### 1. 响应式分流

所有"次要面板/菜单"统一用 `Rx.action(context, mobile: ..., tablet: ...)`：

| 场景 | 移动端 | 桌面端 |
|------|--------|--------|
| 全屏页面（如播放队列页） | `context.pushRoute(XxxRoute())` | `openSheet(position: OverlayPosition.right, builder:)` |
| 表单/详情对话框 | `Navigator.push(MaterialPageRoute)` 全屏页 | `showDialog(builder:)` |
| 曲目更多操作菜单 | `openSheet(position: OverlayPosition.bottom, draggable: true)` | `showDropdown(builder: (_) => DropdownMenu(children:))` |
| 危险/确认操作 | `showDialog` 确认框 | `showDialog` 确认框 |

### 2. 关闭面板约定（关键）

| 弹层类型 | 关闭方式 | 原因 |
|----------|----------|------|
| `openSheet` / `showDropdown` | `closeOverlay(context)` | 走 Overlay（非 Navigator 栈），`Navigator.pop()` 会误弹真实路由导致白屏 |
| `showDialog` | `Navigator.of(context).pop()` | 走 Flutter 标准 `DialogRoute`（Navigator 栈） |

**关键注意**：
- `closeOverlay(context)` 的 `context` 必须是 sheet/dropdown **内部**的 BuildContext
- 每个 `Scaffold` 都会创建一个空的 `DrawerOverlay`，其 `PopScope(canPop: true)` 在空时为 true，因此从 sheet 内部的 Scaffold 调用 `Navigator.pop()` 会穿透到父 Navigator 弹出真实路由（如 RootPage），造成白屏
- `MenuButton` 默认 `autoClose: true`，按下后自动关闭 dropdown，无需手动调用 `closeOverlay`

### 3. 下拉选择统一组件

所有下拉选择按钮**必须**使用 `showSelectionPicker`（`lib/core/framework/selection_picker.dart`）：
- 桌面端：`showDropdown` + `DropdownMenu`
- 移动端：`openSheet` 从底部弹出
- 覆盖平台/库/排序等所有选择场景

```dart
showSelectionPicker<T>(
  context: context,
  title: '选择平台',
  options: [
    SelectionOption(value: 'a', label: '选项A', selected: true),
    SelectionOption(value: 'b', label: '选项B'),
  ],
  onSelected: (value) => _handleSelect(value),
);
```

### 4. shadcn_flutter 菜单/按钮 API

| 组件 | 用途 | 关键参数 |
|------|------|---------|
| `openSheet` | 侧边/底部面板 | `position`、`draggable`、`barrierDismissible` |
| `showDropdown<T>` | 命令式下拉菜单 | `builder` 返回 `DropdownMenu` |
| `DropdownMenu` | 菜单容器 | `children: List<MenuItem>` |
| `MenuButton` | 菜单项（具体类） | `leading`、`child`、`onPressed: (BuildContext) =>`、`trailing` |
| `MenuLabel` | 菜单标题（不可点） | `child` |
| `MenuDivider` | 菜单分隔线 | 无参数 |
| `PrimaryButton` | 主按钮 | `leading:`（图标）、`child:`、`onPressed:`、`enabled:` |
| `GhostButton` / `DestructiveButton` | 次要/危险按钮 | 同上 |

**易错点**：
- `MenuItem` 是**抽象类**，不能直接 `MenuItem(...)`，必须用具体子类 `MenuButton`
- `PrimaryButton` 没有 `.icon` 命名构造，加图标用 `leading:` 参数
- `MenuButton.onPressed` 签名是 `void Function(BuildContext)`，不是 `VoidCallback`

---

## 十二、组件使用规范

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

> `IconButton` 必须使用命名构造函数，不能直接 `IconButton()`

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

### 5. 居中滚动列表

需要居中内容 + maxWidth 约束的滚动页面，使用 `CenteredListView`（`lib/core/framework/centered_list_view.dart`），确保滚动条出现在屏幕右边缘而非居中容器边缘。

### 6. AppChip（标签筛选）

文件：`lib/ui/music/widgets/app_chip.dart`

```dart
AppChip(
  label: '${label}',
  isSelected: isSelected,
  onTap: () => _handleSelect(),
  fill: ${fill},
  borderRadius: ${borderRadius},
  fontSize: ${fontSize},
)
```

常用场景参数：

| 场景 | fill | borderRadius | fontSize |
|------|------|-------------|----------|
| 父分类标签 | `true` | 18 | 13 |
| 子分类标签 | `false` | 14 | 12 |
| Tab 标签 | `true` | 8 | 13 |
| 排序标签 | `false` | 14 | 12 |

---

## 十三、Toast 组件

文件：`lib/core/toast.dart`

### 1. 用法

```dart
// 1. 在 Widget 回调中（推荐）
context.toast.success('已保存');
context.toast.error('失败');
context.toast.warning('警告');
context.toast.info('信息');

// 2. 在非 UI 层（如 Provider/Service）
AppToast().success('解析中...');
```

### 2. 样式规范

Toast 使用 `SurfaceCard` + `Basic` 组件构建，统一样式：

- **位置**：`ToastLocation.topCenter`
- **卡片**：`SurfaceCard`，带 1px 边框（类型色 50% 透明度）+ 阴影
- **填充色**：`colorScheme.card`（跟随主题）
- **左侧图标**：类型色，16px
- **标题**：`colorScheme.cardForeground`，13px
- **右侧关闭按钮**：`Icons.close`，16px，`colorScheme.mutedForeground`，点击调用 `overlay.close`
- **默认时长**：2 秒

### 3. 类型与颜色

| 类型 | 颜色 | 图标 |
|------|------|------|
| success | `Color(0xFF22C55E)` | `Icons.check_circle` |
| error | `Color(0xFFEF4444)` | `Icons.error` |
| warning | `Color(0xFFF59E0B)` | `Icons.warning` |
| info | `Color(0xFF3B82F6)` | `Icons.info` |

### 4. 非上下文调用

`AppToast` 优先使用传入的 `BuildContext`；未传入时回退到 `appNavigatorKey.currentContext`。`appNavigatorKey` 在 `ShadcnApp.router` 的 `navigatorKey` 参数中传入。

### 5. 主题色读取

Toast overlay 的 context 不在主题树内，直接 `Theme.of(overlayContext)` 会触发 `inherited_theme` 断言失败。**必须**在原始 context 上读取主题色后传入 builder：

```dart
final colorScheme = Theme.of(context).colorScheme;
return showToast(
  context: context,
  builder: (context, overlay) => SurfaceCard(
    fillColor: colorScheme.card,
    borderColor: color.withValues(alpha: 0.5),
    // ...
  ),
);
```

---

## 十四、Provider 约定

### 1. 获取音乐服务

```dart
// ✅ 正确：通过 Riverpod Provider 获取 MusicServer
await ref.watch(musicServersProvider.future);
final service = await ref.watch(musicServerByProvider(sourceId).future);

// ✅ 正确：获取当前选中的音乐服务
final service = await ref.watch(musicServerProvider.future);
```

### 2. 异步数据

使用 `FutureProvider`，避免手动管理 loading/error 状态，使用 `AsyncValue.when`：

```dart
final searchResultsProvider = FutureProvider.family<SearchListData, Params>(
  (ref, params) async { ... },
);

// 使用
data.when(
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('加载失败: $e'),
  data: (data) => _buildContent(data),
);
```

> **勿用** `FutureBuilder`，使用 Provider + `AsyncValue.when`

### 3. 选中态

跨页面状态使用 `NotifierProvider`，避免 `useState`（页面切换后状态丢失）：

```dart
// ✅ 正确
ref.watch(selectedLeaderboardProvider);

// ❌ 错误
final selectedId = useState<String?>(null);
```

### 4. 持久化选中态

| 选中态 | 持久化方式 | 说明 |
|----------|--------|------|
| `selectedSourceProvider` | `UserPreference.selectedSourceId` | 通过 `userPreferenceProvider` 持久化 |
| `selectedLibraryId` | `UserPreference.selectedLibraryId` | 同上 |
| `selectedLeaderboardProvider` | ❌ 否 | 仅内存 |
| `selectedPlaylistParentProvider` | ❌ 否 | 仅内存 |
| `selectedPlaylistCategoryProvider` | ❌ 否 | 仅内存 |
| `selectedPlaylistSortProvider` | ❌ 否 | 仅内存 |

### 5. 选中态 Provider 自动重置

选中态 Provider（`selectedLeaderboardProvider` 等）**必须**在 `build()` 中 watch `selectedSourceProvider`，当来源/库变化时自动重置为 null，避免 stale 选中态导致白屏或 UI 错配。

### 6. 曲目相关 Provider 命名

| Provider | 说明 |
|----------|------|
| `leaderboardTracksProvider` | 排行榜曲目（非 `leaderboardSongsProvider`） |
| `currentSourceTracksProvider` | 当前来源曲目 |
| `playlistTracksProvider` | 歌单曲目（非 `playlistSongsProvider`） |
| `searchResultsProvider` | 搜索结果，返回 `SearchListData`（含 `.tracks` 字段） |

### 7. 构建期 Provider 修改

**禁止**在 Widget 树构建期间修改 Provider 状态，需用 `Future.microtask()` 延迟到构建完成后：

```dart
useEffect(() {
  Future.microtask(() async {
    ref.read(xxxProvider.notifier).update(...);
  });
  return null;
}, []);
```

---

## 十五、多源错误处理

使用 `ServiceResult<T>` + `safeCallServices<T>()` 逐服务隔离异常：

```dart
final results = await safeCallServices<PaginationResponse<Track>>(
  services,
  (s) => s.searchTracks(keyword),
  getId: (s) => s.sourceId,
  getName: (s) => s.sourceName,
);

for (final success in results.successes) { /* ... */ }
if (results.failures.isNotEmpty) {
  ProviderErrorBanner(errors: results.failures);
}
```

---

## 十六、Lx 音乐模块架构

### 1. 双引擎设计

| 引擎 | 职责 | 插件数量 |
|------|------|----------|
| `LxMetadataEngine` | 搜索、元信息、歌单、排行榜 | 仅 1 份 |
| `LxSourceEngine` | 获取播放链接 | 支持多份 |

### 2. 插件存储

Lx 插件文件复制到 `<appSupportDir>/lx_scripts/` 目录，配置（路径列表）存入 `MusicServerConfigTable`（`LxPluginConfig`）。

### 3. JsEngine.evalAsync 约定

jsf 库的 `JsRuntime.evalAsync()` 使用 `Future.delayed(Duration.zero)` 轮询 Promise 状态，会导致主线程消息爆炸（"Failed to post message to main thread"）。

**必须**使用 `JsEngine.evalAsync()`（`lib/services/js_engine/js_engine.dart`），它用 5ms 轮询间隔替代 `Duration.zero`。

```dart
// ✅ 正确
final result = await engine.evalAsync(expression);

// ❌ 错误 — 绕过 JsEngine，使用 jsf 默认的 Duration.zero 轮询
final result = await engine.jsRuntime.evalAsync(expression);
```

---

## 十七、日志

### 1. AppLogger

文件：`lib/services/logger.dart`

- `AppLogger.log`：`Logger` 实例（基于 `package:logger`）
  - `AppLogger.log.d('[Tag] msg')` — debug
  - `AppLogger.log.i('[Tag] msg')` — info
  - `AppLogger.log.w('[Tag] msg')` — warning
  - `AppLogger.log.e('[Tag] msg')` — error
- `AppLogger.reportError(error, stackTrace, message)` — 错误上报（带堆栈）

### 2. 日志路径

- 桌面端：`<documents>/pomelo/logs/`（Windows 平台 `getApplicationDocumentsDirectory()` 返回文档根目录，故增加 `pomelo` 子目录）
- 文件格式：JSON Lines

### 3. 日志页面刷新

日志页面打开时**必须**重新加载日志（`latestLogsProvider`、`logLevelStatsProvider`、`logTagsProvider`）。

### 4. 日志存储级别

通过 `UserPreference.logStorageLevel` 控制，持久化到 drift。

---

## 十八、播放器与缓存

### 1. 播放器状态持久化

- `AudioPlayerState` 使用 freezed + json_serializable
- 持久化到 `PlayerStateTable` + `PlayerTrackTable`
- 播放列表曲目以 `trackJson`（JSON 字符串）存储

### 2. 音频流缓存

- 文件：`lib/core/storage/music_cache_dir.dart`
- 缓存目录：`UserPreference.cacheDirectory`（null=系统默认）
- 缓存上限：`UserPreference.cacheSizeLimitGB`（1~5GB，默认 1）
- 缓存大小限制在 1-5GB 之间，默认值 1GB
- 清理缓存时仅删除音频扩展名文件（白名单），保护数据库/配置文件

### 3. 播放链接解析

Lx Server 播放链接**必须**通过 HEAD 请求验证后使用；若无效则音质降级，全部失败时抛出"无法获取有效的播放链接"错误。

**SourcedTrack 架构**（`lib/provider/server/sourced_track.dart`）：
- `TrackSource`：`url`（播放链接）、`path`（本地缓存文件路径）、`type`（音质）、`size`，全部 `final`
- `SourcedTrack.fetchFromTrack()`：解析时同步完成 HEAD 校验 + 缓存路径生成
- `SourcedTrackNotifier.build()`：优先从 DB 持久化加载（`urlMap` + `cachePathMap`），无记录时回退 `fetchFromTrack()`
- `listenSelf`：状态变更时自动持久化到 DB
- `refreshStreamingUrl()`：重新解析播放链接

**播放链接获取限流**：
- 限流器：`RateLimiter`（`lib/services/rate_limiter.dart`），滑动窗口算法
- 全局实例：`musicUrlRateLimiter`，每秒最多 3 次
- 在 `SourcedTrack._getMusicUrl()` 中调用 `musicUrlRateLimiter.acquire()`

**playback.dart 流程**：
- `streamTrackInformation`（HEAD）：优先检查 `track.path` 本地缓存文件，存在则返回文件元信息
- `streamTrack`（GET）：优先检查 `track.path` 本地缓存文件，存在则返回文件流
- URL 为 null 时调用 `refreshStreamingUrl()` 重新解析

### 4. Lx Server 换源

`LxServerConfig.allowSourceSwitching`（默认 false）启用后，当所有音质获取播放链接失败时，跨其他库搜索（`title artist` 关键词），按 title（大小写不敏感精确匹配）+ artist（包含匹配）匹配新源。

### 5. 播放记录

播放记录 upsert 语义：重复播放时 `playCount` 递增 1。

**记录时机**：在 `AudioPlayerStreamListeners.subscribeToScrobbleChanged()`（`lib/provider/audio_player/audio_player_streams.dart`）中，当满足 scrobble 条件（听完 4 分钟或 50% 时长，取较小值）后记录。不再在曲目索引切换时记录。

**读取 Provider**：`playHistoryProvider`（`lib/provider/history/play_history_provider.dart`，`FutureProvider.autoDispose`），记录后通过 `ref.invalidate(playHistoryProvider)` 刷新。

### 6. SourcedTrack 持久化

已解析音源曲目持久化优先级：
1. 本地缓存文件
2. 缓存 URL（HEAD 验证）
3. 重新获取 URL

**持久化方式**：`SourcedTrackNotifier` 通过 `listenSelf` 自动将 `sources`（url + path）批量写入 DB 的 `urlMap` 和 `cachePathMap` 列。

---

## 十九、平台与窗口

### 1. 桌面端窗口

- `main.dart` 中 `setPreventClose(true)`，关闭用 `windowManager.destroy()`（非 `close()`）
- Windows 隐藏原生标题栏（`TitleBarStyle.hidden`），使用自定义右侧标题栏
- 窗口标题通过 Dart 侧 `windowManager.setTitle('柚子音乐')` 设置（避免 C++ 源文件编码乱码）

### 2. 平台与库切换分离

- 平台切换按钮：仅切换平台
- 库切换按钮：仅当平台有多个库时显示，切换库

### 3. 平台选择 UI

平台选择 UI（`music_section.dart`、`search_page.dart`）使用扁平列表展示，不按类型分组。

### 4. Lx Server 显示名称

`LxServerConfig.name` 为可选显示名称，未提供时默认 'Lx Server'。

---

## 二十、代码生成模板

### 1. 标准页面结构

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/framework/framework.dart';

@RoutePage()
class ${PageName}Page extends HookConsumerWidget {
  const ${PageName}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(${providerName}Provider);
    final isLoading = useState(false);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('${PageTitle}'),
          trailing: [
            IconButton.text(
              icon: const Icon(Icons.add),
              onPressed: () => _handleAdd(context),
            ),
          ],
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [],
      ),
    );
  }
}
```

### 2. 响应式页面结构

```dart
@RoutePage()
class ${PageName}Page extends HookConsumerWidget {
  const ${PageName}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [AppBar(title: const Text('${PageTitle}'))],
      child: Rx.layout(
        context,
        mobile: () => _MobileLayout(),
        tablet: () => _TabletLayout(),
        desktop: () => _DesktopLayout(),
      ),
    );
  }
}
```

### 3. 列表项

```dart
Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(Icons.${iconName}, size: 20),
        title: Text('${title}'),
        subtitle: Text('${subtitle}'),
        trailing: IconButton.text(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () => _handleDelete(),
        ),
      ),
      const Divider(height: 1),
    ],
  ),
)
```

### 4. 对话框

```dart
AlertDialog(
  title: const Text('${Title}'),
  content: SizedBox(
    width: 420,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [],
    ),
  ),
  actions: [
    GhostButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('取消'),
    ),
    PrimaryButton(
      onPressed: () => _handleConfirm(),
      child: const Text('确认'),
    ),
  ],
)
```

### 5. 响应式对话框/页面

```dart
Rx.action(
  context,
  mobile: () => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ${PageName}Page()),
  ),
  tablet: () => showDialog(
    context: context,
    builder: (_) => const ${DialogName}Dialog(),
  ),
);
```

### 6. Provider 模板

```dart
// NotifierProvider
final ${providerName}Provider = NotifierProvider<${NotifierName}, ${StateType}>(
  ${NotifierName}.new,
);

class ${NotifierName} extends Notifier<${StateType}> {
  @override
  ${StateType} build() => ${initialValue};

  void update(${Params} params) {
    state = newValue;
  }
}

// FutureProvider
final ${providerName}Provider = FutureProvider<${ReturnType}>((ref) async {
  final service = ref.watch(${serviceProvider});
  return await service.fetchData();
});
```

### 7. 状态管理（Hooks）

```dart
// useState（本地状态）
final isLoading = useState(false);

// useEffect（副作用）
useEffect(() {
  // 初始化逻辑
  return () => /* 清理 */;
}, [dependency]);
```

### 8. 导入规范

```dart
// UI 组件
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/framework/framework.dart';

// 状态管理
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// 路由
import 'package:auto_route/auto_route.dart';

// 响应式
import 'package:pomelo/core/rx.dart';

// 持久化（drift）
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/provider/database/database_provider.dart';

// 播放器状态管理
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/provider/audio_player/audio_player_streams.dart';

// 播放历史
import 'package:pomelo/provider/history/play_history_provider.dart';

// 用户偏好
import 'package:pomelo/core/preferences/user_preference_provider.dart';

// 音乐源配置
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/core/providers/music_server_config_provider.dart';

// Toast
import 'package:pomelo/core/toast.dart';
```

---

## 二十一、Git Commit 规范

移动到git-commit-message.md中

---

## 二十二、常见错误避免清单

| 错误 | 正确做法 |
|------|----------|
| 使用 `IconButton()` | 使用 `IconButton.text()` / `IconButton.ghost()` 等命名构造函数 |
| 使用 Material 的 `ListTile` | 使用 `package:pomelo/core/framework/framework.dart` 中的 `ListTile` |
| `ListTile` 单独使用 | `ListTile` 必须放在 `Card` 内部 |
| 使用 `SizedBox` 做间距 | 优先使用 `Gap()` |
| `AppBar.leading` 传单个 Widget | 传 `List<Widget>` |
| 页面继承 `StatelessWidget` | 优先继承 `HookConsumerWidget` |
| 编造不存在的组件 | 如 `ShadDialog`、`ShadButton` 等不存在 |
| 使用 `FutureBuilder` | 使用 Provider + `AsyncValue.when` |
| 使用 `Song` 命名 | 已统一为 `Track`（API 契约层 `SubsonicSong`/`LxServerSong` 除外） |
| Track 可空字段直接访问 | `artist`/`source`/`meta` 为可空，Text 需 `?? ''`，属性访问需 `?.` |
| 导入 media_kit 不 hide Track | `import 'package:media_kit/media_kit.dart' hide Track;` |
| 直接调用 `Settings`/`StorageKeys` | 已删除，必须用 `userPreferenceProvider` |
| 使用 `MusicService` 命名 | 已统一为 `MusicServer` |
| 为业务模块创建 `Module` 子类 | `Module` 基类已删除，所有模块直接通过 Provider |
| 新页面用顶级路由覆盖全屏 | 默认 Tab 内联打开（`useState` + `onClose`） |
| 桌面端页面自带 `AppBar` | 搜索/切换由 Root 标题栏承载，仅移动端保留 `AppBar` |
| 窗口关闭用 `close()` | 用 `destroy()`（`setPreventClose(true)`） |
| `openSheet`/`showDropdown` 用 `Navigator.pop()` | 用 `closeOverlay(context)` |
| `showDialog` 用 `closeOverlay()` | 用 `Navigator.pop()` |
| `MenuItem(...)` 直接实例化 | `MenuItem` 是抽象类，用 `MenuButton` |
| `PrimaryButton.icon()` | 不存在，用 `leading:` 参数 |
| 构建期修改 Provider 状态 | 用 `Future.microtask()` 延迟 |
| 选中态用 `useState` | 跨页面用 `NotifierProvider` |
| 音乐源配置写入 `UserPreference` | 用 `musicServerConfigsNotifierProvider` |
| `MenuItem.onPressed` 当 `VoidCallback` | 签名是 `void Function(BuildContext)` |
| `AnimatedSwitcher` 用 `alignment` 参数 | Flutter 的 `AnimatedSwitcher` 无 `alignment` 参数，用 `layoutBuilder` + `Stack(alignment:)` |
| `engine.jsRuntime.evalAsync()` | 用 `engine.evalAsync()`（5ms 轮询，避免主线程消息爆炸） |
| `firstWhere` 无 `orElse` | 用 `firstWhereOrNull`（来自 `package:collection`），避免 `StateError` |
| `SourcedTrackNotifier` 手动持久化 | `listenSelf` 自动持久化，无需手动调用 `saveCachePathToPersistence` |

---

## 二十三、已删除/废弃代码

- **M.A.R.S. 架构** — `Module`/`Service`/`Repository` 基类、`ModuleManager`、`ModuleWidget`、`modules.dart` barrel、`HomeModule`/`LogModule` 等模块类已删除
- **`AudioPlayerModule`** — 已废弃，不再使用。播放器逻辑拆分到 `lib/services/audio_player/`（无状态服务）和 `lib/provider/audio_player/`（Riverpod 状态管理）
- **`core/core.dart` 中的 M.A.R.S. 导出** — `module/module.dart`、`repository/repository.dart`、`service/service.dart` 已删除
- **旧日志系统** — `lib/core/log.dart`、`lib/core/log/` 目录（`LogModule`/`LogService`/`LogRepository`/`log_providers.dart`）已删除，迁移到 `lib/services/logger.dart` 的 `AppLogger`
- **`MusicService` 接口** — 已重命名为 `MusicServer`，4 个子类同步重命名
- **`musicServicesProvider` 等** — 已重命名为 `musicServersProvider` / `musicServerByProvider`
- **`musicServerBySourceProvider`** — 已重命名为 `musicServerByProvider`（改为 `FutureProvider.family`，监听配置变化自动重建）
- **`currentMusicServerProvider`** — 已替换为 `musicServerProvider`（监听 `selectedSourceId`，选中为空时自动选择第一个）
- **`musicModuleProvider` / `musicReadyProvider` 等** — 已删除，直接使用 `musicServersProvider`
- **散落的 `Settings.get/set(StorageKeys.xxx)`** — 已迁移到 `UserPreference`，通过 `userPreferenceProvider` 管理
- **`Settings` / `StorageKeys` / `PersistentRepository`** — 文件已删除（hive_ce 依赖已移除）
- **`Song` 类** — 已重命名为 `Track`，字段 `name`→`title`、`coverUrl`→`coverArt`、`albumName`→`album`
- **`SongFull` / `SongLocal` 联合类型** — 已扁平化为 `Track`（用 `src`/`path` 区分）
- **`SongTile` / `SongList` / `SongMoreActionsButton`** — 已重命名为 `TrackTile` / `TrackList` / `TrackMoreActionsButton`
- **`playlistSongsProvider` / `leaderboardSongsProvider`** — 已重命名为 `playlistTracksProvider` / `leaderboardTracksProvider`
- **`searchSongs()` / `getPlaylistSongs()`** — 已重命名为 `searchTracks()` / `getPlaylistTracks()`
- **音乐源配置散落在 `UserPreference`** — 已迁移到 `MusicServerConfigTable`（`localDirectories`/`lxMetadataPluginPath`/`lxSourcePluginPaths`/`lxServerConfig`/`subsonicAccounts` 字段已从 `UserPreference` 移除）
- **`LxServerConfig`（旧 user_preference 中的）** — 已替换为 `core/models/music_server_config.dart` 中的 `LxServerConfig`（继承 `MusicServerConfig`）
- **`SubsonicAccountConfig`** — 已替换为 `SubsonicConfig`
- **`LxServerQuality` 在 modules 中** — 已移动到 `core/models/lx_server_quality.dart`（全局音质偏好）
- **`lib/modules/log/`** — 已迁移至 `lib/services/logger.dart`
- **`lib/modules/home/`** — 已删除（死代码）
- **音乐模型的 freezed 依赖** — 已移除，改为手写 `@immutable` + `copyWith`
- **`FutureBuilder`** — 勿用，改用 Provider + `AsyncValue.when`
- **`lib/ui/music/model/provider_result.dart`** — 已删除
