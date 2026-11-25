import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'shared/settings/theme_mode.dart';

const _defaultWindowSize = Size(1280, 720);
const _minimumWindowSize = Size(900, 600);
const _windowStateFileName = 'window_state.json';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  if (_supportsWindowManager) {
    await _setUpWindow();
  }
  // 预加载 shader 字节码，避免首帧卡顿（移动端底部导航栏仍用玻璃）
  await LiquidGlassWidgets.initialize();
  final initialThemeMode = await loadThemeModeOption();

  runApp(
    ProviderScope(
      overrides: [
        themeModeInitializerProvider.overrideWithValue(initialThemeMode),
      ],
      child: LiquidGlassWidgets.wrap(
        // 让玻璃组件的亮暗跟随应用主题，而不是系统
        brightnessResolver: Theme.maybeBrightnessOf,
        child: const PomeloApp(),
      ),
    ),
  );
}

bool get _supportsWindowManager =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

/// 恢复上次的窗口位置/大小；没有记录时居中显示，并在后续移动、缩放时保存窗口状态。
Future<void> _setUpWindow() async {
  await windowManager.ensureInitialized();
  final savedBounds = await _loadWindowBounds();

  final options = WindowOptions(
    size: savedBounds?.size ?? _defaultWindowSize,
    minimumSize: _minimumWindowSize,
    center: savedBounds == null,
    title: 'Pomelo',
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
    return bounds;
  } catch (_) {
    return null;
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
