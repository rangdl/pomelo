# Pomelo 架构与自适应布局设计

> 本文档描述项目的目录结构分层与自适应布局方案。方案的目标是**一次设计、长期稳定**:断点标准采用 Material 3 窗口分级(跨端行业标准),布局决策集中在一层,页面与布局彻底解耦。

## 1. 目录结构

```
lib/
├── main.dart                      # 入口:窗口管理、设置加载、ProviderScope
├── app/                           # 应用级装配
│   ├── app.dart                   # MaterialApp.router + 双主题接线
│   ├── theme.dart                 # 浅色/深色双主题(seed 为主题色,默认蓝,设置页可换)
│   └── router.dart                # go_router:两级 shell + 全屏子页
├── shared/                        # 跨 feature 的共享层
│   ├── layout/                    # ★ 自适应布局层(核心,见 §2)
│   │   ├── window_class.dart      #   断点定义与测量(M3 标准,永不改)
│   │   └── adaptive_app_shell.dart #   应用外壳:桌面 rail / 移动底栏
│   ├── settings/
│   │   ├── settings_store.dart    # settings.json 读写(所有设置的持久化底座)
│   │   ├── theme_mode.dart        # 主题模式(系统/浅色/深色)
│   │   ├── theme_color.dart       # 主题色(蓝/橙/绿/紫/粉/青,默认蓝)
│   │   └── audio_quality.dart     # 音质偏好
│   ├── ui/
│   │   └── tokens.dart            #   设计令牌(间距/圆角/字号/图标徽章,见 UI_DESIGN.md)
│   └── widgets/                   #   通用组件(SectionHeader/GroupCard/SettingsItem/EmptyState/选择弹层/媒体网格)
└── features/                      # 按功能纵向切分
    ├── home/                      # 首页(搜索 + 播放条)
    ├── search/                    # 搜索(providers + view)
    ├── playback/                  # 播放(domain/application/presentation)
    ├── plugins/                   # 插件与 LX 音源(data/domain/presentation)
    │                              #   runtime/ 为独立 Isolate 中的 QuickJS 运行时(见 §6)
    └── settings/                  # 设置页(分组卡片列表)
```

### 各层职责

| 层 | 目录 | 职责 | 是否关心窗口大小 |
|---|---|---|---|
| 装配层 | `app/` | 主题、路由、应用壳接线 | 否 |
| **断点层** | `shared/layout/window_class.dart` | 定义并测量窗口分级 | **唯一标准来源** |
| **壳层** | `shared/layout/adaptive_app_shell.dart` | 标题栏 + 导航形态切换 | 是(读断点层) |
| 页面层 | `features/*/presentation` | 纯内容,各自管理局部重排 | 只许用 `WindowClassBuilder` |
| 状态层 | `shared/settings`、各 feature 的 providers | 持久化与业务状态 | 否 |

## 2. 自适应布局方案

### 2.1 断点(固定,不改)

采用 **Material 3 / Jetpack Compose `WindowSizeClass`** 标准,数字是行业共识,不是本项目自定:

| 分级 | 宽度 | 典型设备 |
|---|---|---|
| `compact` | < 600 | 手机竖屏 |
| `medium` | 600–839 | 手机横屏 / 小平板 |
| `expanded` | ≥ 840 | 平板横屏 / 桌面窗口 |

对外 API(`window_class.dart`,共 4 个):

- `WindowClass` 枚举
- `context.windowClass` — 页面局部判断
- `WindowClassBuilder` — 整块换布局,跨断点才重建
- `CenteredMaxWidth` — 超宽屏限制内容行宽居中

**规则:判断窗口大小时只允许依赖这几个 API,禁止再出现 `MediaQuery.sizeOf` 裸比较或魔法数字。**

### 2.2 壳层(唯一做布局决策的地方)

`AdaptiveAppShell`:

- **medium / expanded**:左侧 `AppSideNavigation` 自定义侧栏(折叠 76 / 展开 208 逻辑像素)+ 内容
- **compact**:底部玻璃导航栏(**全应用唯一保留玻璃效果的地方**)
- 标题栏、背景、导航形态全部收敛在这一层

导航形态在断点跨越时切换,`StatefulShellRoute.indexedStack` 保证各分支内容不重建——拖动窗口、旋转屏幕都不丢滚动位置与表单状态。

### 2.3 路由结构

```
StatefulShellRoute.indexedStack        # 一级导航壳(3 个入口)
├── 分支 0: '/'        首页
├── 分支 1: '/library' 我的(收藏 + 最近播放)
└── 分支 2: '/settings' 设置
顶层全屏路由(覆盖壳)
├── '/search'   搜索(可带关键词)
├── '/plugins'  插件管理(自有格式插件 + LX 脚本统一入口,设置页进入)
├── '/toplists' 榜单(可传 extra 榜单项直接进入歌曲列表)
├── '/sheets'   推荐歌单浏览
├── '/sheet'    歌单详情
├── '/album'    专辑详情
└── '/artist'   歌手详情
全屏播放页不走路由,是根 Navigator 上的自定义全屏路由(滑入 + 下滑关闭,见 player_sheet.dart)。
```

### 2.4 页面层规则

1. 页面**不带** Scaffold/AppBar(壳提供);二级全屏页(插件/榜单/歌单/专辑/歌手)自带 `Scaffold + AppBar + 返回`;播放页是全屏自定义路由。
2. 页面内部重排用 `WindowClassBuilder` / `context.windowClass`,不读裸尺寸。
3. 超宽列表页用 `CenteredMaxWidth` 限行宽。

## 3. 主题系统

- `ThemeModeOption`(system / light / dark)与 `AppThemeColor`(默认蓝 `#3B82F6`,蓝/橙/绿/紫/粉/青可选)各自 `Notifier` 持有,`settings.json` 持久化(应用支持目录),启动时由 `main()` 注入 `ProviderScope`。
- 双主题同 seed(主题色,`pomeloTheme(brightness, seedColor)`);背景走 iOS 分组列表风格:浅色 `#F2F2F7` / 深色 `#1C1C1E`,卡片为 surfaceContainerHigh。
- 玻璃组件(`liquid_glass_widgets`)通过 `LiquidGlassWidgets.wrap(brightnessResolver: Theme.maybeBrightnessOf)` 跟随**应用主题**;使用范围仅限移动端底部导航栏。

## 4. 扩展约定

- **加一级页面**:在 `adaptive_app_shell.dart` 的 `_destinations`/`_titles` 加一行 + `router.dart` 加一个 branch。
- **加设置项**:在 `settings_screen.dart` 的对应分组加 `SettingsItem`(共享组件,见 UI_DESIGN.md §5.1),必要时新增分组。
- **加二级全屏页**:顶层加 `GoRoute`,页面自带返回,从设置页 push。
- **新页面要自适应**:内容区套 `WindowClassBuilder` 局部重排,壳不动。

## 5. 稳定性原则(为什么这套不会频繁改动)

1. 断点是 M3 行业标准,不是自定参数——没有"调断点"的需求;
2. 布局决策只有壳层一处,页面与布局解耦——页面增删不动布局;
3. 状态保持靠 indexedStack,与视觉无关——重构皮肤不影响交互状态;
4. 主题切换走标准 `ThemeMode`,玻璃只限定在移动底栏——视觉边界清晰。

## 6. 插件运行时(隔离执行)

插件是第三方 JS,必须假设它会死循环、无限递归或卡住 Promise,因此**每个插件独占一个 Isolate**:

- 主 isolate 只保留门面 `PomeloPluginRuntime`(`features/plugins/runtime/pomelo_plugin_runtime.dart`),通过 `SendPort` 发送 `{id, method, args}`。
- worker isolate 里跑 QuickJS(`plugin_worker.dart` 的 `_WorkerEngine`),同一时刻只处理一个请求,结果以 `{id, ok, data|error}` 回传;全局结果位因此不会被并发调用互相覆盖。
- 主 isolate 侧调用带超时,超时即 `Isolate.kill(immediate)` 止损,UI 不会跟着卡死。
- fetch polyfill 依赖 `rootBundle`,只能在主 isolate 读取,启动时作为参数传给 worker。
- 插件实例闲置 10 分钟自动回收(`plugin_providers.dart`),避免用过的插件常驻一份引擎。
- 插件内 `sendMessage('pluginLog' / 'lxLog')` 走独立日志通道,不占用调用结果。
- LX 脚本由兼容层(`lx_compat.dart`)包装成与自有格式同形的 `getMediaSource` 导出,宿主不区分插件出身。

### 6.1 插件平台兼容文档

两类插件平台的兼容实现分别维护在独立文档中,新增平台时在 `docs/compat/` 下增加对应文件:

- MusicFree 插件:[docs/compat/musicfree.md](docs/compat/musicfree.md)
- LX 音源脚本:[docs/compat/lx.md](docs/compat/lx.md)
