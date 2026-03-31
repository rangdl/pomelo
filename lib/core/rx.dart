import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';

class Rx {
  Rx._();
  static RxToast get toast => RxToast();
}

// 文档 https://github.com/MMMzq/bot_toast/blob/master/API_zh.md
class RxToast {
  // 单例
  static final RxToast _instance = RxToast._internal();
  factory RxToast() => _instance;
  RxToast._internal();

  // 默认显示时间
  final Duration _duration = Duration(seconds: 2);

  CancelFunc success(String msg, {Duration? duration}) {
    return info(msg, contentColor: Color(0xFF22C55E));
  }

  CancelFunc error(String msg, {Duration? duration}) {
    return info(msg, contentColor: Color(0xFFEF4444));
  }

  CancelFunc warning(String msg, {Duration? duration}) {
    return info(msg, contentColor: Color(0xFFF59E0B));
  }

  CancelFunc info(String msg, {Duration? duration, Color? contentColor}) {
    return BotToast.showText(
      text: msg,
      duration: duration ?? _duration,
      contentColor: contentColor ?? Color(0xFF3B82F6),
    );
  }
}
