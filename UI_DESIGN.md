# Pomelo 页面设计约束(UI Design Constraints)

> 面向所有在本项目新增页面 / UI 组件的智能体与开发者。
> 目标风格:以 uzn 1.7.0 截图(豆瓣首页、设置页)为参照的「Material 3 + iOS 分组列表 + 克制玻璃拟态」。
> 布局与断点规则见 [ARCHITECTURE.md](ARCHITECTURE.md),本文只管视觉。两份文档冲突时以本文为准。
>
> **本文所有数值都有代码对应物,见 §0。改风格 = 改令牌/主题,不改页面。**

## 0. 风格系统的代码结构

| 关注点 | 唯一来源 |
|---|---|
| 间距 / 圆角 / 图标徽章 / 字号 | [tokens.dart](lib/shared/ui/tokens.dart)(`AppSpacing` / `AppRadius` / `AppIconBadge` / `AppText`) |
| 品牌色 / 组件主题(AppBar、Card、输入框、TabBar、按钮、弹层…) | [theme.dart](lib/app/theme.dart) |
| 分组列表组件 | [shared/widgets](lib/shared/widgets/widgets.dart)(`SectionHeader` / `GroupCard` / `SettingsItem` / `EmptyState` / `showSelectionSheet` / `PosterCard` / `mediaGridDelegate`) |
| 断点与壳层 | [shared/layout](lib/shared/layout/window_class.dart) |

## 1. 设计基调

- **底层是 Material 3**(`useMaterial3: true`,seed 品牌橙),视觉表达偏 iOS:
  浅灰底 + 白色圆角分组卡片(浅色) / 深灰底 + 深色卡片(深色)。
- **分层靠色块,不靠阴影**。卡片 `elevation: 0`(CardTheme 已统一),禁止投影。
- **玻璃拟态全应用只有一处**:移动端底部导航栏。页面内禁止任何玻璃/模糊组件。
- **克制用色**:交互强调 = `colorScheme.primary`(品牌橙 `#FF7A45`);
  语义图标块 = 固定蓝色系(`AppIconBadge`);危险操作 = `colorScheme.error`。
  除此之外不得引入新颜色。

## 2. 色彩令牌

| 令牌 | 取值 / 来源 | 用途 |
|---|---|---|
| 品牌橙 | `pomeloBrandColor` `#FF7A45`(theme seed) | 选中态、主按钮、进度 |
| 页面背景 | 浅色 `#F2F2F7` / 深色 `#1C1C1E` | 仅 theme.dart 的 scaffoldBackgroundColor |
| 卡片/分组底色 | `colorScheme.surfaceContainerHigh` | GroupCard、浮动卡、输入框填充 |
| 次要文字 | `colorScheme.onSurfaceVariant` | 副标题、组标题、未选中图标 |
| 图标块底色 | `AppIconBadge.background(brightness)` | 设置行等语义图标的方块底 |
| 图标块前景 | `AppIconBadge.foreground(brightness)` | 图标块内的 glyph |
| 危险操作 | `colorScheme.error` / `errorContainer` | `SettingsItem(danger: true)` |

规则:
1. 除上表外**禁止手写任何 `Color(0x…)`**;一切表面/文字色走 `Theme.of(context).colorScheme`。
2. 覆盖在图片上的文字/角标(海报遮罩、播放页)允许用 `Colors.white` / `Colors.black54`(见 `PosterCard._Badge`)。

## 3. 排版令牌(`AppText`)

| 层级 | 规格 | 用途 |
|---|---|---|
| 页面大标题 | 壳层 AppBar 统一提供,页面不写 | 一级页面标题 |
| 组标题 | `AppText.sectionHeader` 13,`onSurfaceVariant` | `SectionHeader` |
| 行标题 | `AppText.rowTitle` 15,`w600` | `SettingsItem` 标题、卡片标题 |
| 行副标题 | `AppText.rowSubtitle` 12.5,`onSurfaceVariant` | `SettingsItem` 副标题 |
| 紧凑文字 | `AppText.compact` 11 | 时间、角标、底栏标签 |
| 长文本 | 单行 `maxLines: 1` + `ellipsis` | 所有列表行 |

## 4. 间距与圆角令牌

间距:`AppSpacing` xs4 / sm8 / md12 / lg16 / xl24 / xxl32;页面左右 `AppSpacing.page`(16),
列表页整体用 `AppSpacing.pagePadding`,分组间 `SizedBox(height: AppSpacing.xl)`。

圆角:`AppRadius` badge8(图标块 34×34,glyph 20)/ card12(分组卡、输入框、封面)/
floating16(浮动卡)/ glass26(仅底栏)/ sheet28(弹层顶角)。

## 5. 组件配方

新增 UI 优先套用配方,全部已实现在 `shared/widgets/widgets.dart`,**禁止复制副本**。

### 5.1 分组列表页(设置/表单类页面首选骨架)
```dart
CenteredMaxWidth(
  child: ListView(
    padding: AppSpacing.pagePadding,
    children: [
      const SectionHeader('分组名'),
      GroupCard(children: [
        SettingsItem(icon: ..., title: ..., subtitle: ..., onTap: ...),
        SettingsItem(icon: ..., title: ..., danger: true), // 危险操作
      ]),
      const SizedBox(height: AppSpacing.xl),
      // …下一组
    ],
  ),
)
```
参照实现:[settings_screen.dart](lib/features/settings/presentation/settings_screen.dart)。

### 5.2 筛选/标签行(参照 uzn 豆瓣首页)
- 一级分类:`TabBar`(主题已统一:主题色下划线 + 未选中次要色),横向滚动。
- 二级筛选:纯文字横排(标签 + 值),选中值 `primary` + `w600`,无边框无 Chip 容器。

### 5.3 媒体网格卡(歌单/专辑/海报)
```dart
WindowClassBuilder(
  builder: (context, windowClass) => GridView.builder(
    padding: AppSpacing.pagePadding,
    gridDelegate: mediaGridDelegate(windowClass), // 3 / 4 / 6 列,禁止写死
    itemBuilder: (context, i) => PosterCard(
      title: ..., subtitle: ..., coverUrl: ...,
      badge: '评分 8.6',       // 可选,压在封面左下
      aspectRatio: 1,          // 音乐 1:1;影视 2:3
      onTap: ...,
    ),
  ),
)
```

### 5.4 浮动卡片(吸附在内容底部的条)
圆角 `AppRadius.floating` + `surfaceContainerHigh` + `InkWell` 整卡可点,
内部 `IconButton(visualDensity: VisualDensity.compact)`。
参照实现:[now_playing_bar.dart](lib/features/playback/presentation/now_playing_bar.dart)。

### 5.5 底部弹层选择器(所有单选场景唯一入口)
```dart
final picked = await showSelectionSheet<T>(
  context: context, title: '…', current: current,
  options: [SelectionOption(value: v, label: '…', icon: …)],
);
```
参照:settings_screen.dart 的 `_pickThemeMode`。

### 5.6 空状态
`EmptyState(icon:, title:, message:, actions: [FilledButton.tonalIcon(...)])`。
参照实现:[home_screen.dart](lib/features/home/presentation/home_screen.dart)。

### 5.7 玻璃底栏(已存在,禁止复刻)
[adaptive_app_shell.dart](lib/shared/layout/adaptive_app_shell.dart) `_GlassBottomNavigation`。
任何页面不得再使用 `GlassContainer` / `BackdropFilter`。

## 6. 布局与自适应(视觉侧)

1. 一级页面**不带** `Scaffold`/`AppBar`;二级全屏页自带 `Scaffold + AppBar + 返回`(路由规则见 ARCHITECTURE.md §2.3)。
2. 局部重排只用 `WindowClassBuilder` / `context.windowClass`,禁止 `MediaQuery` 裸尺寸比较(弹层高度等用 `LayoutBuilder` 约束驱动)。
3. 超宽窗口的列表/表单页:内容套 `CenteredMaxWidth`(默认 720)。
4. 网格列数必须经 `mediaGridDelegate(windowClass)`,禁止写死列数。
5. 页面底部预留浮动条/底栏空间:列表 `padding.bottom ≥ AppSpacing.xl`(`pagePadding` 已含)。

## 7. 禁止清单

- 禁止页面自带 AppBar / 重复导航;禁止在 compact 页面内再画底栏。
- 禁止新增玻璃/模糊效果(唯一例外已存在)。
- 禁止卡片阴影/elevation;分层只用 `surfaceContainerHigh` 与背景差。
- 禁止手写 `Color(0x…)`(§2 表内除外);禁止发明表外的字号、圆角、间距——需要新值先加进 `tokens.dart` 再登记到本文。
- 禁止 `MediaQuery` 裸尺寸比较;禁止 `Platform.isIOS ? …` 的视觉分支。
- 禁止图片拉伸:封面一律 `BoxFit.cover` + 圆角裁剪(直接用 `PosterCard`)。
- 禁止复制 shared/widgets 里的组件副本到 feature 内;要改样式就改共享组件本身。

## 8. 新增页面 Checklist

1. 页面骨架:一级页 = 纯内容 Widget;二级页 = `Scaffold + AppBar`。
2. 列表/表单页先套 §5.1;媒体页先套 §5.3;空态用 §5.6;单选用 §5.5。
3. 颜色、字号、圆角、间距逐项对照 §2–§4,全部来自 `tokens.dart` / colorScheme,无表外新值。
4. 自适应:`WindowClassBuilder` 决定列数/单双栏;超宽套 `CenteredMaxWidth`。
5. 深浅色双主题自查:图标块、分隔线、遮罩在深色下对比度正常。
6. `flutter analyze` 零 issue 后交付。
