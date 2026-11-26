# pomelo

Flutter 跨平台音乐播放器：音源全部来自可插拔插件（兼容 MusicFree 插件格式与
LX 音源脚本），支持 Windows 桌面与 Android。

## 环境要求

| 组件 | 版本 | 路径 |
|---|---|---|
| Flutter | 3.47.9 stable (Dart 3.13.7) | `/opt/flutter` |
| JDK | 17 | `/usr/lib/jvm/java-17-openjdk-amd64` |
| Android SDK | Platform 36 / build-tools 36.0.0 / NDK 28.2 | `/opt/android-sdk` |
| Gradle | 9.3.1 | wrapper 内置 |
| Visual Studio | 2022（含 C++ 桌面开发） | 仅 Windows 构建需要 |

## 快速开始

```bash
# Windows 桌面
flutter run -d windows

# Android 真机
source ./env.sh          # 载入 Flutter / Android / 镜像环境变量
flutter doctor           # 应显示 Android toolchain ✓、真机 ✓
flutter run
```

插件 JS 运行在**独立 Isolate** 中的 QuickJS 引擎里，原生桥接库需先编译一次：

```bash
cmake -S third_party/quickjs_engine/native -B third_party/quickjs_engine/native/build
cmake --build third_party/quickjs_engine/native/build --config Release
```

`flutter test` 里的插件脚本测试需要该原生库，可通过环境变量
`LIBQUICKJSC_TEST_PATH` 指向生成的动态库；未提供时相关用例会快速失败。

## 常用命令

```bash
flutter analyze                    # 静态检查
flutter test                       # 单元测试
flutter run -d windows             # 运行 Windows 桌面版
flutter build windows              # 构建 Windows 桌面版
flutter build apk --debug          # 构建 debug APK
flutter build apk --release        # 构建 release APK（需配置签名）
flutter build apk --split-per-abi  # 按 ABI 拆分，体积更小
adb devices                        # 查看已连接设备
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

debug 模式下 `flutter run` 支持热重载：终端按 `r` 热重载、`R` 热重启、`q` 退出。

桌面端全局快捷键：空格播放/暂停、`←`/`→` 快退/快进 5 秒、`Ctrl+←`/`Ctrl+→`
上一首/下一首、`M` 静音、`Ctrl+F` 搜索、`Esc` 返回。

## 网络说明

当前网络无法直连 `dl.google.com` / `maven.google.com` / `services.gradle.org`，因此：

- Maven 依赖走腾讯镜像（见 `android/build.gradle.kts`、`android/settings.gradle.kts`）
- Gradle 发行版走腾讯镜像（见 `android/gradle/wrapper/gradle-wrapper.properties`）
- Pub 包与 Flutter 引擎走 flutter-io.cn 镜像（见 `env.sh`）

## 工程结构

```
lib/                        # Dart 源码（app / shared / features 分层）
android/                    # Android 原生工程（包名 com.pomelo.pomelo）
windows/                    # Windows 桌面工程
third_party/quickjs_engine/ # 内置 QuickJS JS 引擎（含原生桥接源码）
scripts/                    # 真实插件脚本（测试与真机集成测试用）
test/                       # 单元测试
integration_test/           # 真机集成测试
env.sh                      # 本机环境变量脚本
```

架构与 UI 约定见 [ARCHITECTURE.md](ARCHITECTURE.md)、[UI_DESIGN.md](UI_DESIGN.md)。
