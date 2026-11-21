# pomelo

Flutter 移动端项目（Android 优先）。

## 环境要求

| 组件 | 版本 | 路径 |
|---|---|---|
| Flutter | 3.47.9 stable (Dart 3.13.7) | `/opt/flutter` |
| JDK | 17 | `/usr/lib/jvm/java-17-openjdk-amd64` |
| Android SDK | Platform 36 / build-tools 36.0.0 / NDK 28.2 | `/opt/android-sdk` |
| Gradle | 9.3.1 | wrapper 内置 |

## 快速开始

```bash
source ./env.sh          # 载入 Flutter / Android / 镜像环境变量
flutter doctor           # 应显示 Android toolchain ✓、真机 ✓
flutter run              # 部署到已连接的 Android 设备
```

## 常用命令

```bash
flutter analyze                    # 静态检查
flutter test                       # 单元测试
flutter build apk --debug          # 构建 debug APK
flutter build apk --release        # 构建 release APK（需配置签名）
flutter build apk --split-per-abi  # 按 ABI 拆分，体积更小
adb devices                        # 查看已连接设备
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

debug 模式下 `flutter run` 支持热重载：终端按 `r` 热重载、`R` 热重启、`q` 退出。

## 网络说明

当前网络无法直连 `dl.google.com` / `maven.google.com` / `services.gradle.org`，因此：

- Maven 依赖走腾讯镜像（见 `android/build.gradle.kts`、`android/settings.gradle.kts`）
- Gradle 发行版走腾讯镜像（见 `android/gradle/wrapper/gradle-wrapper.properties`）
- Pub 包与 Flutter 引擎走 flutter-io.cn 镜像（见 `env.sh`）

## 工程结构

```
lib/            # Dart 源码
android/        # Android 原生工程（包名 com.pomelo.pomelo）
env.sh          # 本机环境变量脚本
```
