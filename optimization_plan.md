# Pomelo 音乐来源 & UI 展示 优化计划

> 生成日期：2026-08-05
> 范围：音源模块（MusicServer 体系） + UI 展示层
> 验证基线：改动后均以 `flutter analyze`（0 error 0 warning 为目标）+ `flutter test` 全量回归

---

## 0. 架构现状速览

四个音源实现（均继承 `MusicServer`，见 `core/models/metadata/music_server.dart:17`）：

| 实现 | 文件 | 配置类型 |
|---|---|---|
| `LocalMusicServer` | `modules/music_local/service/local_music_server.dart` | `LocalMusicConfig` |
| `SubsonicMusicServer` | `modules/music_subsonic/repository/subsonic_music_server.dart` | `SubsonicConfig` |
| `LxMusicServer` | `modules/music_lx/model/lx_music_server.dart` | `LxPluginConfig` |
| `LxServerMusicServer` | `modules/music_lx_server/repository/lx_server_music_server.dart` | `LxServerConfig` |

路由中枢：`modules/music/providers/music_providers.dart`（`musicServerProvider` family 按 config 类型分发）。

**LxMusicServer 现状**：仍被 `LxPluginConfig`（`MusicSourceType.lx`，设置页"Lx 音乐插件"）路由使用，`LxMetadataEngine` 仅被它消费。详见第 1 节。

---

## 1. LxMusicServer 清理（✅ 已执行·scope A·commit ba0509d）

> 已彻底移除整个 Lx 插件平台：删除 `LxMusicServer`/`LxMetadataEngine` 及其 MusicServer 实现、`LxPluginConfig` 类与 `MusicSourceType.lx` 枚举、相关 Provider 与 UI 对话框/测试；保留 `LxServer` 与 `LxSourceEngine`。验证：`flutter analyze` 0 error/0 warning、`flutter test` 全过。详见下方"执行记录"。

### 1.0 执行记录（2026-08-05）

### 1.1 依赖事实
- `LxMusicServer` ← `lxMusicServerProvider`（`lx_providers.dart:213`）
- `lxMusicServerProvider` ← `music_providers.dart:34`（`case LxPluginConfig()`）
- `LxMetadataEngine` ← 仅 `LxMusicServer`（metadata 搜索/歌单/榜单）
- `LxPluginConfig`（`music_server_config.dart:96`）使用方：
  - `service_page.dart:312`（编辑，空实现）、`:393`（删除 → `lxMetadataPluginPathsProvider.removePlugin`）
  - `lx_providers.dart:57/235/265`（读 `metadataPluginPath`）、`music_server_config.dart:46`（fromJson）
  - `service_page.dart` `_PlatformType.lx` → `AddLxPluginDialog`/`LxPluginPage`
- `lxMetadataPluginPathsProvider` / `LxMetadataPluginPathsNotifier`（`lx_providers.dart:231-284`）→ 仅服务 Lx 插件元数据路径，被 `service_page:395`、`add_lx_script_dialog.dart:62/79/93/102` 使用。

### 1.2 三套范围方案

**方案 A（推荐·彻底弃用整个 Lx 插件平台）**
- 删除 `lx_music_server.dart`、`lx_metadata_engine.dart`
- 删除 `LxPluginConfig` 类；`MusicSourceType.lx` 枚举值移除并清理所有 `switch`/`typeOrder`（`service_page.dart:100-107, 218-224, 312, 318-325, 393`）
- `music_providers.dart` 移除 `case LxPluginConfig()` 分支（改 `default: return null`）
- 移除 `lxMusicServerProvider`、`lxMetadataEngineProvider`、`LxMetadataPluginPathsNotifier`/`lxMetadataPluginPathsProvider`
- 移除 `service_page` 的 `_PlatformType.lx` 入口与 `AddLxPluginDialog`/`LxPluginPage`/`add_lx_script_dialog.dart`
- 清理 `models.dart` 对 `lx_music_server.dart` 的 export、`README.md:99,170` 旧描述
- 风险：已配置"Lx 音乐插件"的用户配置失效，需引导迁移到 LxServer。

**方案 B（仅标记弃用，保留可用）**
- `LxMusicServer` 加 `@Deprecated('迁移到 LxServerMusicServer / LxServerConfig')`
- 清理文档/export 残留（README、models export、music_providers 注释）
- 不动功能，后续再迁移。

**方案 C（仅清理文档死引用）**
- 删 `models.dart` 多余 export、`README` 旧描述、`music_providers` 注释里对 `lxMusicServerProvider` 的引用
- 保留 `LxMusicServer` 功能（与"弃用"语义不符，不推荐）。

> 待用户确认采用 A / B / C 后，按对应方案落地第 1 节。

---

## 2. 音乐来源模块优化

### 2.1 音质降级单一来源（高优先级·功能正确性）
- **问题**：`lx_server_music_server.dart:783` 与 `sourced_track.dart:118` 各硬编码 `['flac24bit','flac','320k','128k']`；上游 `sourced_track.dart:127-146` 已做降级遍历，下游 `_selectQuality` 又降一次 → 用户选 320k 可能拿到 flac。
- **做法**：
  1. 新增 `core/models/lx_server_quality.dart` 中导出 `const kQualityLadder = ['flac24bit','flac','320k','128k']`（已有 `lx_server_quality.dart`，复用）。
  2. `sourced_track.dart` 与 `lx_server_music_server.dart` 统一引用该常量。
  3. 明确职责：音源只负责"给定音质能否解析"，降级决策只在 `sourced_track.dart` 一处完成；`_selectQuality` 改为"选择首个可用音质"（去掉二次降级）。
- **验证**：`flutter analyze`；构造 320k 偏好 + 仅有 flac 的场景单测验证拿到 flac（降级）而非无谓跳过。

### 2.2 底层异常不再吞掉（高优先级）
- **问题**：Subsonic 全量 `catch` 返空，使上层 `safeCallServices`（`music_ui_providers.dart:100`）错误 banner 失效；LxServer 部分方法裸抛。
- **做法**：底层方法抛具体 `Exception`（保留 logger）；UI 层统一 `safeCall` 展示错误态。删除 Subsonic 里"吞异常返 empty"的 6+ 处。
- **验证**：制造一个失败的网络请求，确认 UI 出现错误提示而非空白。

### 2.3 抽 `MultiLibraryMusicServer` mixin（中优先级）
- **问题**：`LxMusicServer:63-88` 与 `LxServerMusicServer:97-112` 的 `setDefaultLibrary` + `_libraryName` 查表逻辑同构，且都持有 `_currentSource`。
- **做法**：在 `core/models/metadata/` 抽取 mixin，统一库切换/校验/`_libraryName`，两个实现继承。
- **验证**：`flutter analyze` + 现有 LxServer 用例不退化。

### 2.4 去重样板（中优先级）
- `_cleanUrl`：`subsonic_providers.dart:22` 与 `lx_server_providers.dart:13` 逐字重复 → 提到 `core/utils/url.dart`。
- 三段式配置流程（`subsonic_providers.dart:103/159`、`lx_server_providers.dart:103`）→ 抽 `validateAndUpsert` 辅助。
- 分页 `hasMore`/`total`：LxServer 6 处、Subsonic 3 处 → 抽 `PaginationResponse.fromApi(items, page, limit, total)`。
- `.map(toTrack(...))` 在 LxServer 重复约 10 处 → 抽 `toTrack` 工厂方法。

### 2.5 `sourceId` 统一由 config 注入（中优先级）
- **问题**：Subsonic 自拼 `sourceId`（`subsonic_music_server.dart:33`）与 `subsonic_providers.dart:122` configId 拼法重复；`sourced_track.dart:231`/`lyric.dart:21` 用 `track.source.id` 反查 `musicServerProvider(configId)`，二者相等纯属巧合。
- **做法**：统一由 config 注入 `sourceId`（参考 `LxServerMusicServer` 已正确做法），消除隐式拼串。

---

## 3. UI 展示层优化

### 3.1 播放器进度子树拆分（高优先级·性能）
- **问题**：`mini_player.dart:30-58`、`playback_page.dart:35-59` `watch(audioPlayerProvider)` + `positionStream`，进度每帧驱动整个 MiniPlayer（含封面、歌词 `useMemoized`）重建。
- **做法**：将进度条、`position/duration` 文本、`useMemoized` 歌词拆为独立 `Consumer` 子树，父树不被进度流驱动。
- **验证**：开启 DevTools 看 MiniPlayer rebuild 次数在播放时是否显著下降。

### 3.2 首页 TabBar 重建（高优先级·性能，已验证）
- **问题**：`home_page.dart:185-208` `_HomeTabBar` 为渲染"播放全部"按钮 `watch` 整个 `leaderboardTracksProvider`。
- **做法**：把 `PlayAllButton` 下沉为独立 `Consumer`，TabBar 不再 watch 整列表。
- **验证**：`flutter analyze`。

### 3.3 `MediaQuery.of(context).size.width` 重复计算（中优先级）
- **问题**：`playable_track_tile.dart:83` 及 album/playlist/artist/home/favorites 共 7 处，窗口尺寸变化触发全表 rebuild。
- **做法**：父级算一次下发，或改用 `Rx` 响应式宽度。
- **验证**：`flutter analyze`。

### 3.4 列表 `itemExtent` / `key`（中优先级）
- **问题**：`home_page`、`favorites_page`、`play_queue_content` 的 `ListView.builder` 无 `itemExtent`/`key`；`track_list.dart:53` 每项传整表引用。
- **做法**：列表项加 `key`、固定高度项加 `itemExtent`；`TrackList` 避免每项持有整表，改为按需索引。
- **验证**：长列表滚动帧率。

### 3.5 抽重复 widget（中优先级）
- `_TabItem`（`home_page.dart:230-284` 与 `favorites_page.dart:103-160` 逐行相同）→ 提取 `SegmentTabItem`（与 `AppChip` 合并）。
- 详情页骨架三份（`album/playlist/artist_detail_page`）→ 提取 `DetailScaffold` + `DetailHeader`。
- 循环模式切换逻辑（`playback_page.dart:593-597` 与 `play_queue_content.dart:83-87`）→ 提取 `PlaybackModeToggle`。
- 空/错态 40+ 处 → 提取统一 `EmptyHint` / `ErrorView`（`home_page` 已有 `_EmptyHint` 未复用）。

### 3.6 硬编码色 / 魔法数（低优先级）
- 成功率配色 `audio_source_settings_page.dart:527-530` 与 `core/toast.dart:11-14` 重复 → 进 `core/theme/app_theme.dart` 语义色。
- `Colors.white` 硬编码（`playback_settings_page:371`、`about_page:67`）→ 改 `colorScheme` 语义色，修复深色主题问题。
- 侧栏宽/字号魔法数 → 进 theme typography / 常量。

### 3.7 UI 越界（低优先级·架构）
- `playable_track_tile.dart:119`、`play_queue_content.dart:121` `onTap` 内 `File(...).exists()` → 移入 provider。
- `audio_source_settings_page.dart:63` build 闭包内 `File.readAsString()` → 移入 provider。
- `audio_source_settings_page.dart:715-723` Switch 回调直接 `upsert(config)` 写库 → 走 notifier。
- `playback_page`/`mini_player` 绕过 Riverpod 直接调全局 `audioPlayer` → 统一走 `audioPlayerProvider`。

---

## 4. 落地顺序建议

| 序 | 任务 | 优先级 | 风险 |
|---|---|---|---|
| 1 | **第 1 节 LxMusicServer 清理（按选定范围）** | 取决于范围 | A 高 / B 低 |
| 2 | 2.1 音质降级单一来源 | 高 | 低 |
| 3 | 2.2 底层异常不吞 | 高 | 中 |
| 4 | 3.1 播放器进度子树拆分 | 高 | 中 |
| 5 | 3.2 首页 TabBar 重建 | 高 | 低 |
| 6 | 3.3 / 3.4 MediaQuery & 列表优化 | 中 | 低 |
| 7 | 3.5 抽重复 widget | 中 | 低 |
| 8 | 2.3 / 2.4 / 2.5 音源抽象去重 | 中 | 中 |
| 9 | 3.6 / 3.7 硬编码 & UI 越界 | 低 | 低 |

**每步完成后**：`flutter analyze`（目标 0 error 0 warning）+ `flutter test` 全量回归，再提交（commit 类型前缀：`refactor`/`fix`/`perf`）。
