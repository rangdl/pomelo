import 'package:flutter/material.dart';

/// 全局 [ScaffoldMessengerState] 的 key。
///
/// 播放器等非 Widget 层（如播放错误回调）需要弹全局 SnackBar 时使用。
final GlobalKey<ScaffoldMessengerState> globalScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// 全局 [NavigatorState] 的 key。
///
/// 播放器等非 Widget 层需要跳转页面（如点击通知栏打开播放页）时使用。
final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();
