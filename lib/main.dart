import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'features/playback/data/audio_player_service.dart';
import 'features/playback/data/media_proxy_server.dart';
import 'features/playback/data/playback_store.dart';
import 'features/playback/presentation/playback_providers.dart';
import 'features/plugins/data/builtin_plugins.dart';
import 'features/plugins/data/plugin_repository.dart';
import 'features/plugins/presentation/plugin_providers.dart';
import 'shared/logging/app_logger.dart';
import 'shared/settings/app_font.dart';
import 'shared/settings/cache_limit.dart';
import 'shared/settings/settings_store.dart';
import 'shared/settings/theme_color.dart';
import 'shared/settings/theme_mode.dart';

const _defaultWindowSize = Size(1280, 720);
// 最小窗口不再高于 expanded 断点（840），保证小窗口下也能走到紧凑布局。
const _minimumWindowSize = Size(720, 480);
const _windowStateFileName = 'window_state.json';

/// 单实例锁文件句柄：持有到进程退出，由系统释放。
RandomAccessFile? _instanceLock;

Future<void> main() async {
  // 全局兜底：未捕获的异步异常也写入日志，桌面端不至于无痕退出。
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // 日志最先初始化：之后所有错误（含已有 debugPrint 分支）都能落盘。
      await AppLogger.instance.init();
      // 同一时间只允许一个播放器实例，避免两个进程抢音频设备与缓存文件。
      if (!await _acquireSingleInstance()) {
        debugPrint('[pomelo] 已有一个实例在运行，退出本次启动');
        exit(0);
      }
      MediaKit.ensureInitialized();
      if (_supportsWindowManager) {
        await _setUpWindow();
      }
      // 预加载 shader 字节码，避免首帧卡顿（移动端底部导航栏仍用玻璃）
      await LiquidGlassWidgets.initialize();
      final settingsStore = await SettingsStore.open();
      final initialThemeMode = await loadThemeModeOption(settingsStore);
      final initialThemeColor = await loadThemeColor(settingsStore);
      final initialAudioQuality = await loadAudioQuality(settingsStore);
      final initialCacheLimit = cacheLimitFromStore(settingsStore);
      // 自定义字体在这里完成注册，首帧就用用户选中的字体。
      final initialFont = await loadAppFontSelection(settingsStore);
      final playbackSnapshot = await loadPlaybackSnapshot();

      // 首次启动预装内置音源插件（幂等；失败不阻断启动）。
      try {
        final pluginRepo = await PluginRepository.open();
        await seedBuiltinPlugins(pluginRepo, settingsStore);
      } catch (e, s) {
        AppLogger.instance.error('main', '内置插件预装流程异常', e, s);
      }

      // 本地媒体服务：播放器与封面统一走 127.0.0.1，由服务端取流/取图并落盘缓存。
      MediaLinkCache.instance = await MediaLinkCache.open();
      MediaProxyServer.instance = await MediaProxyServer.start();
      MediaProxyServer.instance?.maxCacheBytes = initialCacheLimit.bytes;
      // 启动时先按上限清理一次，避免上次遗留的缓存无限增长。
      unawaited(
        MediaProxyServer.instance?.enforceLimit() ?? Future<void>.value(),
      );

      // 播放下沉到前台 Service：切后台 / 锁屏也能继续播放并可被系统控制。
      final audioHandler = await AudioService.init<AudioPlayerService>(
        builder: () => AudioPlayerService(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.pomelo.pomelo.audio',
          androidNotificationChannelName: 'Pomelo 播放',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );

      // 恢复上次的音量与播放速度。
      final savedVolume = settingsStore.read<num>('volume')?.toDouble();
      if (savedVolume != null) {
        await audioHandler.setVolume(savedVolume.clamp(0, 100).toDouble());
      }
      final savedSpeed = settingsStore.read<num>('speed')?.toDouble();
      if (savedSpeed != null && savedSpeed != 1.0) {
        await audioHandler.setSpeed(savedSpeed);
      }

      runApp(
        ProviderScope(
          overrides: [
            settingsStoreProvider.overrideWithValue(settingsStore),
            themeModeInitializerProvider.overrideWithValue(initialThemeMode),
            themeColorInitializerProvider.overrideWithValue(initialThemeColor),
            audioQualityInitializerProvider.overrideWithValue(
              initialAudioQuality,
            ),
            cacheLimitInitializerProvider.overrideWithValue(initialCacheLimit),
            appFontInitializerProvider.overrideWithValue(initialFont),
            selectedSearchPluginInitializerProvider.overrideWithValue(
              settingsStore.read<String>('selectedSearchPluginId'),
            ),
            playbackSnapshotInitializerProvider.overrideWithValue(
              playbackSnapshot,
            ),
            audioPlayerProvider.overrideWithValue(audioHandler),
          ],
          child: LiquidGlassWidgets.wrap(
            // 让玻璃组件的亮暗跟随应用主题，而不是系统
            brightnessResolver: Theme.maybeBrightnessOf,
            child: const PomeloApp(),
          ),
        ),
      );
    },
    (error, stack) {
      // 兜底记录（zone 内未捕获的异步异常）。
      AppLogger.instance.error('uncaught', '$error', error, stack);
    },
  );
}

bool get _supportsWindowManager =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

/// 获取单实例文件锁；已被其它实例占用时返回 false。
Future<bool> _acquireSingleInstance() async {
  if (_instanceLock != null) return true;
  try {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}pomelo.lock');
    final handle = await file.open(mode: FileMode.write);
    await handle.lock(FileLock.exclusive);
    // 不关闭句柄：锁随进程存活，退出时由操作系统释放。
    _instanceLock = handle;
    return true;
  } catch (_) {
    // 拿不到锁说明已有实例在运行；其它异常（平台不支持文件锁）不应阻止启动。
    return false;
  }
}

/// 恢复上次的窗口位置/大小；没有记录时居中显示，并在后续移动、缩放时保存窗口状态。
Future<void> _setUpWindow() async {
  await windowManager.ensureInitialized();
  final savedBounds = await _loadWindowBounds();

  final options = WindowOptions(
    size: savedBounds?.size ?? _defaultWindowSize,
    minimumSize: _minimumWindowSize,
    center: savedBounds == null,
    title: '柚子音乐',
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    if (savedBounds != null) {
      await windowManager.setBounds(savedBounds);
    }
    await windowManager.show();
    await windowManager.focus();
  });

  windowManager.addListener(_WindowBoundsSaver());
}

Future<File> _windowStateFile() async {
  final directory = await getApplicationSupportDirectory();
  return File(
    '${directory.path}${Platform.pathSeparator}$_windowStateFileName',
  );
}

Future<Rect?> _loadWindowBounds() async {
  try {
    final file = await _windowStateFile();
    if (!await file.exists()) return null;
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final bounds = Rect.fromLTWH(
      (data['left'] as num).toDouble(),
      (data['top'] as num).toDouble(),
      (data['width'] as num).toDouble(),
      (data['height'] as num).toDouble(),
    );
    if (bounds.width < _minimumWindowSize.width ||
        bounds.height < _minimumWindowSize.height) {
      return null;
    }
    // 上次可能在已拔掉的副屏上：位置完全落在可见范围外就丢弃，改为居中。
    if (!_isBoundsReachable(bounds)) return null;
    return bounds;
  } catch (_) {
    return null;
  }
}

/// 粗略判断窗口是否还「够得着」。
///
/// Flutter 不提供显示器坐标，只能拿到各屏尺寸；这里用「所有屏宽度之和」
/// 作为虚拟桌面宽度、最大高度作为高度，避免把副屏上的正常位置误判为越界，
/// 同时能拦掉「拔掉副屏后窗口跑到 4000px 之外」的情况。
bool _isBoundsReachable(Rect bounds) {
  try {
    final displays = WidgetsBinding.instance.platformDispatcher.displays;
    if (displays.isEmpty) return true;
    var totalWidth = 0.0;
    var maxHeight = 0.0;
    for (final d in displays) {
      final ratio = d.devicePixelRatio <= 0 ? 1.0 : d.devicePixelRatio;
      totalWidth += d.size.width / ratio;
      final h = d.size.height / ratio;
      if (h > maxHeight) maxHeight = h;
    }
    // 标题栏至少留一点在桌面范围内，用户才拖得回来。
    final titleBarX = bounds.left + bounds.width / 2;
    return titleBarX > 0 &&
        titleBarX < totalWidth &&
        bounds.top > -10 &&
        bounds.top < maxHeight - 40;
  } catch (_) {
    return true;
  }
}

Future<void> _saveWindowBounds(Rect bounds) async {
  try {
    final file = await _windowStateFile();
    await file.writeAsString(
      jsonEncode({
        'left': bounds.left,
        'top': bounds.top,
        'width': bounds.width,
        'height': bounds.height,
      }),
    );
  } catch (_) {
    // 窗口状态保存失败不影响正常使用
  }
}

class _WindowBoundsSaver extends WindowListener {
  Timer? _timer;

  void _scheduleSave() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), _save);
  }

  Future<void> _save() async {
    // 最大化/最小化/全屏时记录的是临时尺寸，恢复普通状态后才保存
    if (await windowManager.isMaximized() ||
        await windowManager.isMinimized() ||
        await windowManager.isFullScreen()) {
      return;
    }
    await _saveWindowBounds(await windowManager.getBounds());
  }

  @override
  void onWindowResize() => _scheduleSave();

  @override
  void onWindowResized() => _scheduleSave();

  @override
  void onWindowMove() => _scheduleSave();

  @override
  void onWindowMoved() => _scheduleSave();

  @override
  void onWindowBlur() => _scheduleSave();

  @override
  void onWindowUnmaximize() => _scheduleSave();

  @override
  void onWindowRestore() => _scheduleSave();
}
