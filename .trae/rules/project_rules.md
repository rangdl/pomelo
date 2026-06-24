# Pomelo 项目 UI 开发规范

## 技术栈

- **UI 框架**: shadcn_flutter
- **状态管理**: Riverpod (hooks_riverpod, flutter_riverpod) + flutter_hooks
- **路由**: auto_route
- **响应式布局**: Rx.layout() / Rx.action()

## 核心组件使用规范

### 1. 页面容器

```dart
// 标准页面结构 — 优先使用 HookConsumerWidget
@RoutePage()
class XxxPage extends HookConsumerWidget {
  const XxxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('标题'),
          trailing: [...],  // 右侧操作按钮
        ),
      ],
      child: ListView(...),
    );
  }
}
```

**Widget 基类选择**：
- `HookConsumerWidget` — 优先使用，支持 `useState`/`useEffect` 管理本地 UI 状态
- `ConsumerWidget` — 无需 hooks 时使用
- `StatelessWidget` — 不需要 ref 时使用

### 2. 列表项布局

**必须使用自定义 ListTile**（来自 `pomelo/core/framework/framework.dart`）：

```dart
import 'package:pomelo/core/framework/framework.dart';

Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(Icons.xxx, size: 20),
        title: Text('标题'),
        subtitle: Text('副标题'),
        trailing: IconButton.text(
          icon: Icon(Icons.close, size: 18),
          onPressed: () {},
        ),
      ),
      if (需要分隔) const Divider(height: 1),
    ],
  ),
)
```

**注意**：
- `ListTile` 必须放在 `Card` 内部
- 多个列表项用 `Column` 包裹，中间用 `Divider(height: 1)` 分隔
- `ListTile` 的 `padding` 参数可自定义内边距
- `ListTile` 支持 `onTap` 回调（自动添加点击手势和鼠标指针）

### 3. 按钮组件

#### 文本按钮
| 组件 | 用途 | 示例 |
|------|------|------|
| `GhostButton` | 次要操作、取消 | `GhostButton(onPressed: () {}, child: Text('取消'))` |
| `PrimaryButton` | 主要操作、确认 | `PrimaryButton(onPressed: () {}, child: Text('确认'))` |

#### IconButton（图标按钮）
shadcn_flutter 的 `IconButton` 通过命名构造函数区分样式，**必须使用命名构造函数**：

| 构造函数 | 样式 | 用途 |
|----------|------|------|
| `IconButton.text()` | 文本样式（最轻量） | 列表项内删除/关闭按钮 |
| `IconButton.ghost()` | 幽灵透明 | 工具栏次要操作 |
| `IconButton.outline()` | 边框样式 | 中等强调操作 |
| `IconButton.primary()` | 主色样式 | 主要操作 |
| `IconButton.secondary()` | 次要样式 | 次要操作 |
| `IconButton.destructive()` | 危险红色 | 删除确认 |
| `IconButton.link()` | 链接样式 | 跳转操作 |

```dart
// 正确用法 ✅
IconButton.text(
  icon: Icon(Icons.close, size: 18),
  onPressed: () {},
)

// 错误用法 ❌ - IconButton 需要 variance 参数，不能直接调用默认构造函数
IconButton(
  icon: Icon(Icons.close),
  onPressed: () {},
)
```

### 4. 表单组件

```dart
// 下拉选择
Select<String>(
  value: selectedValue,
  onChanged: (value) { ... },
  popup: SelectPopup(
    items: SelectItemList(
      children: [
        SelectItemButton(value: 'option1', child: Text('选项1')),
      ],
    ),
  ).call,
  itemBuilder: (context, value) => Text('显示文本'),
)

// 文本输入
TextField(
  placeholder: const Text('搜索...'),
  onSubmitted: (value) { ... },
  features: [
    InputFeature.leading(Icon(Icons.search, size: 18)),
  ],
)
```

### 5. 对话框

```dart
AlertDialog(
  title: const Text('标题'),
  content: SizedBox(
    width: 420,  // 对话框宽度
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [...],
    ),
  ),
  actions: [
    GhostButton(onPressed: () => Navigator.pop(context), child: Text('取消')),
    PrimaryButton(onPressed: () {}, child: Text('确认')),
  ],
)
```

### 6. 间距组件

- `Gap(12)` - shadcn_flutter 提供的间距组件（优先使用）
- `SizedBox(height: 8)` - 标准 Flutter 间距
- `Divider(height: 1)` - 分隔线

### 7. 颜色主题

```dart
Theme.of(context).colorScheme.primary          // 主色
Theme.of(context).colorScheme.mutedForeground  // 次要文字
Theme.of(context).colorScheme.destructive      // 危险/删除
Theme.of(context).colorScheme.border           // 边框
Theme.of(context).colorScheme.mutedBackground  // 次要背景
Theme.of(context).colorScheme.muted            // 静音色（用于 AppChip 未选中）
```

### 8. 文本样式（TextExtension）

shadcn_flutter 提供 `TextExtension` 扩展，可以快速设置文本样式：

```dart
// 标题样式
Text('标题').h1()
Text('标题').h2()
Text('标题').h3()
Text('标题').h4()

// 段落样式
Text('正文').p()           // 标准段落
Text('引言').lead()        // 引导文本
Text('小字').small()       // 小号文本
Text('大字').large()       // 大号文本
Text('静音').muted()       // 次要文字（灰色）

// 字重样式
Text('粗体').bold()
Text('斜体').italic()

// 组合使用
Text('标题').h2().bold()
Text('说明').small().muted()
```

### 9. AppBar.leading 参数

`AppBar.leading` 接受 **`List<Widget>`**，不是单个 Widget：

```dart
AppBar(
  title: const Text('标题'),
  leading: [
    IconButton.text(
      icon: const Icon(Icons.arrow_back, size: 20),
      onPressed: () => Navigator.of(context).pop(),
    ),
  ],
)
```

## 状态管理规范

### Provider 使用

```dart
// 监听状态
final data = ref.watch(xxxProvider);

// 读取状态（不监听）
final module = ref.read(xxxProvider);

// 异步数据处理
dataAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('加载失败: $e'),
  data: (data) => buildContent(data),
)
```

### flutter_hooks 使用

本地 UI 状态（如 loading 标志）使用 `useState`，跨页面状态使用 `NotifierProvider`：

```dart
class _MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    Future<void> doSomething() async {
      isLoading.value = true;
      // ...
      isLoading.value = false;
    }

    // useEffect 用于副作用
    useEffect(() {
      // 初始化逻辑
      return null; // 清理函数
    }, [dependency]);
  }
}
```

## 导航规范

```dart
// 路由跳转
context.pushRoute(XxxRoute(param: value));

// 返回
context.router.maybePop();

// 显示对话框
showDialog(
  context: context,
  builder: (_) => const XxxDialog(),
);

// Material 页面跳转（非 auto_route 页面）
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => const XxxPage(),
  ),
);
```

## 响应式布局

```dart
// 布局组件 — 返回 Widget
Rx.layout(
  context,
  mobile: () => MobileLayout(),   // < 600px
  tablet: () => TabletLayout(),   // 600-1024px
  desktop: () => DesktopLayout(), // >= 1024px
)

// 响应式动作 — 执行回调，不返回 Widget
Rx.action(
  context,
  mobile: () {
    Navigator.of(context).push(...);
  },
  tablet: () {
    showDialog(context: context, ...);
  },
)
```

## 导入规范

```dart
// 必须导入
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/framework/framework.dart';  // 使用 ListTile 时

// 状态管理（优先使用 hooks_riverpod）
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';  // 使用 useState/useEffect 时

// 路由
import 'package:auto_route/auto_route.dart';

// 响应式工具
import 'package:pomelo/core/rx.dart';
```

## 常见错误避免

1. **不要使用 Material 的 ListTile** - 必须使用自定义的 `pomelo/core/framework/list_tile.dart`
2. **不要编造不存在的组件** - 如 `ShadDialog`、`ShadButton`、`ShadCard` 等
3. **IconButton 的正确用法** - 使用 `IconButton.text()` 等命名构造函数
4. **ListTile 必须在 Card 内** - 不要单独使用 ListTile
5. **间距优先使用 Gap** - 而不是 SizedBox
6. **AppBar.leading 是 List** - 不是单个 Widget
7. **页面优先用 HookConsumerWidget** - 支持 hooks 和 ref

## 页面结构示例

```dart
@RoutePage()
class ExamplePage extends HookConsumerWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider);
    final isLoading = useState(false);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('示例页面'),
          trailing: [
            IconButton.text(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddDialog(context),
            ),
          ],
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  ListTile(
                    leading: Icon(Icons.item, size: 20),
                    title: Text(items[i].name),
                    subtitle: Text(items[i].description),
                    trailing: IconButton.text(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => _deleteItem(items[i].id),
                    ),
                  ),
                  if (i < items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

# 项目约定与最佳实践

## 共享组件索引

| 组件 | 文件路径 | 用途 | 关键参数 |
|------|---------|------|---------|
| `CoverPlaceholder` | `lib/ui/music/widgets/cover_placeholder.dart` | 封面图占位 | `width`, `height` |
| `AppChip` | `lib/ui/music/widgets/app_chip.dart` | 标签/筛选 Chip | `label`, `isSelected`, `onTap`, `fill`, `selectedColor`, `unselectedColor`, `icon`, `borderRadius`, `fontSize`, `borderWhenUnselected` |
| `ProviderErrorBanner` | `lib/ui/music/widgets/provider_error_banner.dart` | 多源错误横幅 | `errors` |
| `PlayPauseButton` | `lib/ui/music/widgets/play_pause_button.dart` | 播放/暂停按钮 | `song` |
| `ListTile` | `lib/core/framework/list_tile.dart` | 列表项（必须放 Card 内） | `leading`, `title`, `subtitle`, `trailing`, `onTap`, `padding`, `subtitleGap` |
| `AddLxPluginDialog` | `lib/ui/platform/widgets/add_lx_script_dialog.dart` | Lx 插件管理对话框（桌面端） | — |
| `LxPluginPage` | `lib/ui/platform/widgets/add_lx_script_dialog.dart` | Lx 插件管理页面（移动端） | — |

## 工具函数

```dart
// 按 sourceType 分组服务 — 用于来源选择器/筛选
Map<MusicSourceType, List<MusicService>> groupServicesByType(List<MusicService> services)
// 定义: lib/ui/music/providers/music_ui_providers.dart
```

## Provider 约定

### 获取模块优先使用 Riverpod，不要直接调用 ModuleManager

```dart
// ✅ 正确
final module = ref.watch(musicModuleProvider);

// ❌ 错误 — 应通过 Provider 获取
final module = ModuleManager().find<MusicModule>('music');
```

**可用模块 Provider**（定义于 `lib/modules/music/providers/music_providers.dart`）：
- `musicReadyProvider` — 触发所有音乐模块懒加载
- `musicModuleProvider` — `MusicModule?` 实例
- `musicServicesProvider` — `List<MusicService>`
- `musicServiceBySourceProvider(sourceId)` — 按 sourceId 查找

### 异步数据用 FutureProvider，不要手动管理异步状态

```dart
// ✅ 正确 — 使用 FutureProvider.family
final searchResultsProvider = FutureProvider.family<SearchListData, Params>((ref, params) async {
  // ...
});
```

### 选中态用 NotifierProvider，不要用 useState

```dart
// ✅ 正确 — 跨页面保持选中态
ref.watch(selectedLeaderboardProvider);
ref.read(selectedLeaderboardProvider.notifier).select(id);
```

### 常见 Provider 列表

| Provider | 类型 | 位置 | 说明 |
|----------|------|------|------|
| `selectedSourceProvider` | `NotifierProvider` | `music_ui_providers.dart` | 当前选中来源，返回 `({String? sourceId, String? libraryId})` 记录 |
| `selectedLeaderboardProvider` | `NotifierProvider` | `music_ui_providers.dart` | 当前选中排行榜 id |
| `selectedPlaylistParentProvider` | `NotifierProvider` | `music_ui_providers.dart` | 歌单父分类选中态 |
| `selectedPlaylistCategoryProvider` | `NotifierProvider` | `music_ui_providers.dart` | 歌单子分类选中态 |
| `selectedPlaylistSortProvider` | `NotifierProvider` | `music_ui_providers.dart` | 歌单排序选中态 |
| `currentSourceSongsProvider` | `FutureProvider` | `music_ui_providers.dart` | 当前来源的歌曲列表（返回 `MusicListData`） |
| `leaderboardsProvider` | `FutureProvider` | `music_ui_providers.dart` | 当前来源的排行榜列表 |
| `leaderboardSongsProvider` | `FutureProvider.family` | `music_ui_providers.dart` | 指定排行榜的歌曲 |
| `playlistCategoriesProvider` | `FutureProvider` | `music_ui_providers.dart` | 当前来源的歌单分类 |
| `playlistsByCategoryProvider` | `FutureProvider` | `music_ui_providers.dart` | 当前分类下的歌单 |
| `searchResultsProvider` | `FutureProvider.family` | `music_ui_providers.dart` | 搜索结果，参数为 `({String keyword, String? sourceId, String? libraryId})` |
| `musicServicesListProvider` | `FutureProvider` | `music_ui_providers.dart` | 监听 Lx 插件路径变化的服务列表 |
| `lxMetadataPluginPathsProvider` | `NotifierProvider` | `lx_metadata_plugin_paths_provider.dart` | Lx 元数据插件路径（仅一份） |
| `lxSourcePluginPathsProvider` | `NotifierProvider` | `lx_source_plugin_paths_provider.dart` | Lx 音源插件路径列表（多份） |

## 多源错误处理模式

使用 `ServiceResult<T>` + `safeCallServices<T>()` 逐服务隔离异常，配合 `ProviderErrorBanner` 展示：

```dart
final results = await safeCallServices<PaginationResponse<Song>>(
  services,
  (s) => (s as MusicService).searchSongs(keyword),
  getId: (s) => s.sourceId,
  getName: (s) => s.sourceName,
);
// 分别处理 results 中的 success/failure
// UI 层通过 ProviderErrorBanner 展示错误摘要
```

## AppChip 场景参数速查

| 场景 | fill | borderRadius | fontSize | 特殊参数 |
|------|------|-------------|----------|---------|
| 父分类标签 | `true` | 18 | 13 | — |
| 子分类标签 | `false` | 14 | 12 | — |
| 排序标签 | `false` | 14 | 12 | `selectedColor: secondary`, `icon: Icons.sort` |
| Tab 标签 | `true` | 8 | 13 | — |
| 日志级别筛选 | — | 14 | 12 | `borderWhenUnselected: true`, `selectedColor: _levelColor(level)` |
| 排行榜标签 | `true` | 18 | 13 | — |

## Lx 音乐模块架构

### 双引擎设计

| 引擎 | 职责 | 插件数量 |
|------|------|----------|
| `LxMetadataEngine` | 音乐搜索、元信息查询、歌单、排行榜 | 仅 1 份 |
| `LxSourceEngine` | 获取播放链接 | 支持多份 |

### 插件管理 Provider

- **元数据插件**: `lxMetadataPluginPathsProvider` — `addPlugin()`, `replacePlugin()`, `removePlugin()`
- **音源插件**: `lxSourcePluginPathsProvider` — `addPlugin()` 返回 `List<LxSourceLibrary>`, `replacePlugin()`, `removePlugin()`

### 响应式对话框/页面模式

桌面端用对话框，移动端用全屏页面：

```dart
Rx.action(
  context,
  mobile: () => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const XxxPage()),
  ),
  tablet: () => showDialog(
    context: context,
    builder: (_) => const XxxDialog(),
  ),
);
```

## 已删除/废弃代码

- **勿创建或引用** `lib/ui/music/model/provider_result.dart` — 已删除，与 `service_result.dart` 重复
- **勿引用** `lx_script_paths_provider.dart` — 已拆分为 `lx_metadata_plugin_paths_provider.dart` + `lx_source_plugin_paths_provider.dart`
- **勿引用** `AddLxScriptDialog` / `LxScriptPage` — 已重命名为 `AddLxPluginDialog` / `LxPluginPage`
- **勿引用** `musicSourcesByTypeProvider` — 已删除，改用 `musicServicesListProvider` + `groupServicesByType()`
- **类名规范**: 所有页面类 `XxxPage`，勿用 `XxxView`
- **勿用 FutureBuilder** 替代方案：使用 Provider + `AsyncValue.when`
