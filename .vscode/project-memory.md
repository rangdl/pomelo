# Pomelo 项目记忆

## M.A.R.S. 模块化架构
- 核心框架: `lib/core/mars.dart` (module/module_manager/repository/service)
- Module 抽象基类: 生命周期 onInit/onReady/onDispose, 依赖拓扑排序
- ModuleManager: 单例, registerAll → initAll → readyAll → disposeAll
- Repository: 数据访问抽象, InMemoryRepository 开箱即用
- Service: 业务逻辑封装
- 模块目录: `lib/modules/<module_name>/` (model/repository/service/providers) — 纯业务，无 UI
- UI 目录: `lib/ui/<module_name>/` — 纯视图层，只依赖 modules 中的 Provider/Model
- 模块定义: 继承 Module, 在 main.dart 中用 ModuleManager 注册
- 已注册模块(8个):
  - **home** (即时加载)
  - **example** (懒加载)
  - **favorite** (懒加载)
  - **my** (懒加载)
  - **statistics** (懒加载)
  - **music_sdk** (懒加载) — 最底层音乐数据模型
  - **music** (懒加载) — 抽象接口层
  - **music_local** (懒加载) — 本地实现
- 懒加载机制: Module.lazy=true → ModuleManager.lazyInit(id) 触发
- 三层音乐体系: music_sdk → music(MusicProvider接口) → music_local/其他平台模块

## 状态管理 — Riverpod 3.x
- 包: hooks_riverpod ^3.3.1 / flutter_riverpod ^3.3.1
- ⚠️ StateProvider 已被移除，替代方案: NotifierProvider + Notifier
- 可用: Provider, FutureProvider, NotifierProvider + Notifier, StreamProvider
- UI 层用 hooks_riverpod (ConsumerWidget/ref)，模块内用 flutter_riverpod

## 路由
- auto_route 配置在 `lib/core/routers/app_router.dart`
- build.yaml 同时扫描 `lib/modules/**/*.dart` 和 `lib/ui/**/*.dart`

## shadcn_flutter ^0.0.52 集成 (⚠️ shadcn_ui 已完全移除)
- **入口**: `ShadcnApp(...)` / `ShadcnApp.router(...)`，不是 MaterialApp
- **配色**: `ColorSchemes.lightSlate` / `ColorSchemes.darkSlate`
- **主题访问**: `Theme.of(context).colorScheme`（自己的 ThemeData，无单独的 ShadTheme）
- **shadcn 扩展色**: background, foreground, card, cardForeground, popover, popoverForeground, muted, mutedForeground, accent, accentForeground, border, input, ring
- **按钮**: `Button.primary/secondary/outline/ghost/link/text/destructive/fixed/menu`
  - 快捷类: `PrimaryButton`, `SecondaryButton`, `OutlineButton`, `GhostButton`, `DestructiveButton`
  - 参数: child, onPressed, leading, trailing, size(ButtonSize), density(ButtonDensity), shape(ButtonShape)
  - ButtonSize: normal/small/large
  - ButtonDensity: normal/compact/comfortable/icon
  - ButtonShape: rectangle/circle
- **Card**: `Card` / `SurfaceCard`，支持 CardTheme 全局配置
- **Toast**: `showToast(context:context, builder:(ctx,overlay)=>..., location:ToastLocation.bottomRight, showDuration:Duration(seconds:5))` — 自由函数，不是 ShadToaster
- **Popover**: `PopoverOverlayHandler().show(context:context, alignment:, builder:)` — 不是 Popover widget
- **图标**: 内置 LucideIcons / RadixIcons / BootstrapIcons，开箱即用
- **命名冲突**: shadcn_flutter 重新导出了 Row/Column/Card/Theme/CircularProgressIndicator/showDialog/Form/Table 等 Flutter 组件（有补丁版本），导入时用 `show X` 精确控制或 `hide X` 排除冲突
- **布局组件**: Scaffold, Accordion, Alert, Breadcrumb, Collapsible, Stepper, Steps, Table, Tree, Resizable
- **表单**: Input, TextArea, Select, Checkbox, Switch, Slider, DatePicker, TimePicker, RadioGroup, Autocomplete
- **导航**: Tabs, NavigationBar, NavigationMenu, Pagination, Sidebar, Menu, DropdownMenu, ContextMenu

## 音乐模型
- Song/Album/Playlist 在 `lib/modules/music_sdk/model/`
- `source` 字段: `({String id, String name})` Record 类型
- `meta` 字段: `Map<String, dynamic>?` 供平台模块扩展
- MusicProvider 抽象接口: searchSongs/searchAlbums/searchPlaylists/getSong/getSongs/getAlbum/getAlbumSongs/getPlaylist/getPlaylists