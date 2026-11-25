import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // 预加载 shader 字节码，避免首帧卡顿
  await LiquidGlassWidgets.initialize();

  runApp(
    ProviderScope(
      child: LiquidGlassWidgets.wrap(
        // 让玻璃组件的亮暗跟随应用主题，而不是系统
        brightnessResolver: Theme.maybeBrightnessOf,
        child: const PomeloApp(),
      ),
    ),
  );
}
