# Pomelo

跨平台音乐播放器，支持多音源聚合、响应式 UI 和本地音乐管理。

基于 Flutter 构建，运行于 Android、iOS、Windows、macOS 和 Linux。

## 功能特性

- **多音源聚合**：统一界面接入多种音乐服务
  - 本地音乐（扫描本地文件）
  - Lx 音乐（JS 插件，支持自定义音源）
  - Lx Server（自建服务端）
  - Subsonic（兼容 Subsonic/Navidrome/Airsonic 协议）
- **播放器**：基于 media_kit，支持播放队列、循环模式、随机播放、进度拖拽
- **歌词**：实时歌词滚动、多行显示、字体大小可调
- **搜索**：跨多音源并行搜索，结果合并去重
- **歌单与排行榜**：浏览各音源提供的歌单分类和排行榜
- **收藏**：收藏曲目，支持 Subsonic 收藏同步
- **统计**：播放记录与统计数据
- **响应式 UI**：自动适配手机（单栏）、平板（双栏）、桌面（多栏）
- **系统媒体控制**：Windows SMTC / 移动端通知栏媒体控制
- **音质选择**：Lx Server 支持音质选择与自动降级

## 技术栈

| 类别 | 技术 |
|------|------|
| UI 框架 | [shadcn_flutter](https://pub.dev/packages/shadcn_flutter) |
| 状态管理 | Riverpod + flutter_hooks |
| 路由 | auto_route |
| 音频播放 | media_kit |
| 持久化 | hive_ce |
| 响应式布局 | Rx.layout() / Rx.action() |
| JS 引擎 | flutter_js（Lx 插件运行时） |

## 支持平台

| 平台 | 状态 |
|------|------|
| Android | ✅ |
| iOS | ✅ |
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |

## 开始使用

### 环境要求

- Flutter 3.35.7
- Dart SDK ^3.9.0

### 构建运行

```bash
# 安装依赖
flutter pub get

# 生成路由等代码
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run

# 构建 APK
flutter build apk

# 构建 Windows
flutter build windows
```

### 添加 Lx 音源插件

在「我的」→「Lx 插件」中导入 `.js` 格式的 Lx 音源脚本。插件运行在 Flutter JS 引擎中，无需原生依赖。

### 连接 Subsonic 服务

在「我的」→「Subsonic」中添加服务器信息（支持 Subsonic / Navidrome / Airsonic）。

## 项目结构

```
lib/
├── core/                  # 核心层：框架、存储、路由、日志
│   ├── extensions/        # 扩展函数（DateTime 解析等）
│   ├── framework/         # 框架基础（Module、Service、Repository）
│   ├── log/               # 日志模块
│   ├── pagination/        # 分页响应
│   ├── routers/           # 路由配置
│   ├── storage/           # 持久化存储（Settings、StorageKeys）
│   └── ...
├── modules/               # 业务模块层
│   ├── music/             # 音乐核心（模型、服务抽象、多源聚合）
│   ├── music_local/       # 本地音乐
│   ├── music_lx/          # Lx 音乐（JS 插件）
│   ├── music_lx_server/   # Lx Server
│   ├── music_subsonic/    # Subsonic 协议
│   ├── audio_player/      # 播放器（media_kit 封装）
│   ├── favorite/          # 收藏
│   ├── home/              # 首页
│   ├── statistics/        # 统计
│   └── my/                # 设置
├── ui/                    # UI 层
│   ├── home/              # 首页
│   ├── music/             # 音乐相关页面（搜索、歌单详情等）
│   ├── player/            # 播放器 UI（全屏播放、迷你播放器、歌词）
│   ├── favorite/          # 收藏页
│   ├── log/               # 日志页
│   ├── my/                # 设置页
│   └── platform/          # 平台配置页（Lx 插件、Subsonic 账号）
└── main.dart              # 入口
```

## 架构

本项目遵循 **M.A.R.S.** 模块化分层架构，核心三层依赖遵循单向依赖原则：

```
  Provider (Riverpod 状态)
      │
      ▼
  Service (业务逻辑)
      │
      ▼
  Repository (数据访问)
```

| 调用方 | → Repository | → Service | → Provider |
|--------|:-----------:|:---------:|:----------:|
| **Repository** | — | ❌ 不允许 | ❌ 不允许 |
| **Service** | ✅ 构造函数注入 | — | ❌ 不允许 |
| **Provider** | ✅ 通过 Module 获取 | ✅ 通过 ref.watch/ref.read | — |
| **Module** (A → B) | ✅ 通过 ModuleManager | ✅ 通过 ModuleManager | ❌ 不允许 |

完整架构说明详见 [MARS_ARCHITECTURE.md](MARS_ARCHITECTURE.md)。

## 提交规范

```txt
请根据当前已暂存改动，用中文生成一条 git commit message，格式：类型: 描述
```

允许类型：`feat`（新功能）、`fix`（修复）、`docs`（文档）、`refactor`（重构）、`test`（测试）

---

## 免责声明

本项目（Pomelo）仅供学习和个人使用，不提供任何音乐资源。

1. **音源独立性**：本项目本身不内置、不分发任何音乐内容。所有音乐数据来源于用户自行配置的第三方音源（Lx 插件、Lx Server、Subsonic 兼容服务器、本地文件等），本项目仅作为播放工具进行数据展示和播放控制。

2. **用户责任**：用户使用本软件获取和播放的音乐内容，由用户自行负责确保符合当地法律法规及版权要求。用户应仅播放其有权访问的内容（如自有音乐文件、已授权的流媒体服务等）。

3. **版权声明**：本项目不存储、不缓存任何受版权保护的音乐文件。所有音乐的版权归属其原作者或版权所有者，未经授权不得用于商业用途。

4. **第三方插件**：Lx 音源插件由第三方开发者提供，本项目不对插件的内容、安全性和合法性承担责任。用户应自行审查所使用的插件。

5. **无担保**：本软件按"现状"提供，不提供任何明示或暗示的担保。在法律允许的最大范围内，作者不对因使用本软件而产生的任何直接或间接损失负责。

6. **用途限制**：请勿将本软件用于任何违法用途。如因用户行为导致的法律责任，由用户自行承担。

如您是音乐版权所有者，认为某个第三方音源侵犯了您的权益，请联系对应音源的服务提供者。

---

## License

本项目仅供学习交流使用，不得用于商业用途。
