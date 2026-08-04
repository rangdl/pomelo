# Pomelo 项目长期记忆

跨平台音乐播放器（Subsonic 客户端 + 本地音乐 + Lx 音乐/JS 插件 + Lx Server + DLNA 投屏），Dart/Flutter。

## 技术栈
- fvm 管理，Flutter 3.35.7 / Dart SDK ^3.9.0（`.fvmrc` 锁定）
- 状态管理：hooks_riverpod + flutter_riverpod 并存（建议只用 hooks_riverpod）
- 路由：auto_route；数据库：drift（SQLite）；播放器：media_kit；UI：shadcn_flutter
- 原生桥接：flutter_rust_bridge（metadata_god、rusty_dlna 依赖，需用 dependency_overrides 对齐版本）
- JS 引擎：flutter_js / jsf（QuickJS，两套存在重复，见 2026-08-04 体检）
- 构建 CLI：cli/（dart 脚本，process_run）；CI：.github/workflows/prepare-release.yaml

## 架构
- 三层单向依赖：UI(lib/ui) → Module(lib/modules) → Core(lib/core)
- MusicServer 抽象统一各音源；main.dart 用 ProviderContainer.overrideWithValue 注入核心模块

## 约定
- git commit 规范：类型(中文): 描述；类型 feat/fix/docs/refactor/test
- 应用已有 logger（AppLogger），生产代码无 print / setState
