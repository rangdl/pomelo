import 'package:flutter/material.dart';
import 'module_manager.dart';

/// M.A.R.S. 模块化应用入口组件
///
/// 自动管理模块初始化流程，并在初始化完成前展示启动画面。
///
/// ⚠️ 建议改为在 main.dart 中手动调用 ModuleManager 的生命周期方法。
///     详见 lib/main.dart 的使用方式。
class ModuleApp extends StatefulWidget {
  final WidgetBuilder builder;
  final bool initialized;

  const ModuleApp({super.key, required this.builder, this.initialized = false});

  /// 创建并启动模块化应用
  static Future<ModuleApp> create({
    required List<dynamic /*Module*/> modules,
    required WidgetBuilder builder,
    Widget? loading,
  }) async {
    final manager = ModuleManager();
    for (final module in modules) {
      await manager.register(module);
    }
    await manager.initAll();
    await manager.readyAll();
    return ModuleApp(builder: builder, initialized: true);
  }

  @override
  State<ModuleApp> createState() => _ModuleAppState();
}

class _ModuleAppState extends State<ModuleApp> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
