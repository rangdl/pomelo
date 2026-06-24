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
│  - 框架、存储、路由、工具函数               │
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
- **文件存储**: 仅 `log` 模块使用（JSON Lines）
- **内存存储**: 使用 `InMemoryRepository<T>`（`favorite`、`home`、`statistics`）

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

- **移动端**: 全屏页面（`Navigator.push`）
- **桌面端**: 对话框（`showDialog`）
- **使用 `Rx.action`** 自动适配两端

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

---

## 持久化 Key 管理

所有 Settings Key 集中定义在 `lib/core/storage/storage_keys.dart`：

| Key | 用途 | 所属模块 |
|-----|------|----------|
| `audioPlayerState` | 播放器状态 | audio_player |
| `logStorageLevel` | 日志存储级别 | log |
| `musicSelectedSource` | 当前选中来源 | music (UI) |
| `musicSelectedLibrary` | 当前选中库 | music (UI) |
| `musicLocalDirectories` | 本地音乐目录 | music_local |
| `musicLxMetadataPluginPath` | Lx 元数据插件路径 | music_lx |
| `musicLxSourcePluginPaths` | Lx 音源插件路径 | music_lx |
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

---

## 多源错误处理

使用 `ServiceResult<T>` + `safeCallServices<T>()` 逐服务隔离异常：

```dart
final results = await safeCallServices<PaginationResponse<Song>>(
  services,
  (s) => s.searchSongs(keyword),
  getId: (s) => s.sourceId,
  getName: (s) => s.sourceName,
);
```

---

## 常见错误避免

1. **不要使用 Material 的 ListTile** - 必须使用自定义的
2. **不要编造不存在的组件** - 如 `ShadDialog`、`ShadButton` 等
3. **IconButton 必须使用命名构造函数** - `IconButton.text()` 等
4. **ListTile 必须在 Card 内** - 不要单独使用
5. **间距优先使用 Gap** - 而不是 SizedBox
6. **AppBar.leading 是 List\<Widget\>** - 不是单个 Widget
7. **不要直接调用 ModuleManager** - 应通过 Provider 获取模块

---

## 已删除/废弃代码

- `lib/ui/music/model/provider_result.dart` — 已删除
- `lx_script_paths_provider.dart` — 已拆分
- `AddLxScriptDialog` / `LxScriptPage` — 已重命名为 `AddLxPluginDialog` / `LxPluginPage`
- `musicSourcesByTypeProvider` — 已删除，改用 `musicServicesListProvider` + `groupServicesByType()`
- **勿用 `FutureBuilder`** — 使用 Provider + `AsyncValue.when`

---

## 代码生成

代码生成相关的模板和模式请参考：[code_templates.md](code_templates.md)

---

## 本次会话更改记录

### 1. 持久化 Key 集中管理

**新增文件**：
- [storage_keys.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/core/storage/storage_keys.dart) — 集中定义所有 Settings Key 常量

**修改文件**：
- [storage.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/core/storage/storage.dart) — 导出 storage_keys.dart
- 6 个模块文件 — 消除魔法字符串，引用 `StorageKeys` 常量

### 2. Provider 下沉到模块层

**新增文件**：
- [lx_providers.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/modules/music_lx/providers/lx_providers.dart) — 合并两个 Lx 插件 Provider

**修改文件**：
- [lx_metadata_plugin_paths_provider.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/platform/providers/lx_metadata_plugin_paths_provider.dart) — 转为 re-export
- [lx_source_plugin_paths_provider.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/platform/providers/lx_source_plugin_paths_provider.dart) — 转为 re-export

### 3. UI 响应式双栏适配

| 页面 | 适配方案 | 文件 |
|------|----------|------|
| HomePage | tablet+: 排行榜+歌单双栏，desktop: maxWidth 1200 居中 | [home_page.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/home/home_page.dart) |
| MusicSearchPage | tablet+: 左侧来源筛选侧栏 + 右侧结果列表 | [search_page.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/music/search_page.dart) |
| LogPage | tablet+: 左侧筛选面板 + 右侧日志列表 | [log_page.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/log/log_page.dart) |
| PlaylistDetailPage | tablet+: 左侧封面信息(300px) + 右侧歌曲列表 | [playlist_detail_page.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/music/playlist_detail_page.dart) |
| PlaylistSection | 断点对齐: 2/3/4/5 列 | [playlist_section.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/music/playlist_section.dart) |
| FavoritePage | Subsonic 添加走 Rx.action，tablet+ 服务列表双栏 | [favorite_page.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/favorite/favorite_page.dart) |
| MyPage | tablet+: maxWidth 800 居中 | [my_page.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/my/my_page.dart) |

### 4. Subsonic 响应式对话框

**新增文件**：
- [add_subsonic_account_dialog.dart](file:///d:/WorkSpace/personal/flutter/pomelo/lib/ui/platform/widgets/add_subsonic_account_dialog.dart) — 重构为响应式结构

**模式**：提取共享内容组件 `_SubsonicAccountContent`，移动端用 `AddSubsonicAccountPage`，桌面端用 `AddSubsonicAccountDialog`

### 5. 规则文件拆分

**新增文件**：
- [code_templates.md](code_templates.md) — 代码生成模板

**修改文件**：
- [project_rules.md](project_rules.md) — 架构规范，移除代码模板内容

---

## 验证结果

`flutter analyze`：0 error，仅 29 个原有 info 级提示（非本次修改引入）
