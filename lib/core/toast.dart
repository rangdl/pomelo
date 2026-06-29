import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Row, Flexible;

/// 全局 Navigator Key，用于在非 UI 上下文中获取 [BuildContext] 显示 Toast。
///
/// 在 [ShadcnApp.router] 的 `navigatorKey` 参数中传入此 key，
/// 之后即可通过 [AppToast] 默认构造函数在任意位置显示 Toast。
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Toast 类型
enum AppToastType {
  success(Color(0xFF22C55E), Icons.check_circle),
  error(Color(0xFFEF4444), Icons.error),
  warning(Color(0xFFF59E0B), Icons.warning),
  info(Color(0xFF3B82F6), Icons.info);

  final Color color;
  final IconData icon;

  const AppToastType(this.color, this.icon);
}

/// 基于 shadcn_flutter [showToast] 的统一 Toast 组件。
///
/// 优先使用传入的 [BuildContext]；未传入时回退到 [appNavigatorKey] 的当前上下文。
/// 这样既能从 Widget 回调中调用，也能从 Provider/Service 等非 UI 层调用。
///
/// 用法：
/// ```dart
/// // 1. 在 Widget 回调中（推荐）
/// context.toast.success('已保存');
///
/// // 2. 在非 UI 层（如 Provider/Service）
/// AppToast().success('解析中...');
/// ```
class AppToast {
  final BuildContext? _context;

  AppToast([this._context]);

  BuildContext? get _effectiveContext {
    final ctx = _context ?? appNavigatorKey.currentContext;
    if (ctx == null) return null;
    if (ctx is Element && !ctx.mounted) return null;
    return ctx;
  }

  ToastOverlay? success(String msg, {Duration? duration}) =>
      _show(msg, AppToastType.success, duration: duration);

  ToastOverlay? error(String msg, {Duration? duration}) =>
      _show(msg, AppToastType.error, duration: duration);

  ToastOverlay? warning(String msg, {Duration? duration}) =>
      _show(msg, AppToastType.warning, duration: duration);

  ToastOverlay? info(
    String msg, {
    Duration? duration,
    Color? color,
  }) {
    if (color == null) return _show(msg, AppToastType.info, duration: duration);
    return _showCustom(msg, color, Icons.info, duration: duration);
  }

  ToastOverlay? _show(String msg, AppToastType type, {Duration? duration}) {
    return _showCustom(msg, type.color, type.icon, duration: duration);
  }

  ToastOverlay? _showCustom(
    String msg,
    Color color,
    IconData icon, {
    Duration? duration,
  }) {
    final context = _effectiveContext;
    if (context == null) return null;
    return showToast(
      context: context,
      showDuration: duration ?? const Duration(seconds: 2),
      location: ToastLocation.topRight,
      builder: (context, overlay) => _AppToastCard(
        message: msg,
        color: color,
        icon: icon,
        onDismiss: overlay.close,
      ),
    );
  }
}

/// Toast 卡片组件
///
/// 右上角展示，宽度根据文本自适应（最大 480）。
/// 使用彩色左边框区分类型：成功绿、警告黄、错误红、信息蓝。
class _AppToastCard extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback? onDismiss;

  const _AppToastCard({
    required this.message,
    required this.color,
    required this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const Gap(8),
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.colorScheme.cardForeground,
                  fontSize: 13,
                ),
              ),
            ),
            if (onDismiss != null) ...[
              const Gap(8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    color: theme.colorScheme.mutedForeground,
                    size: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// [BuildContext] 上的 Toast 快捷扩展。
///
/// 用法：`context.toast.success('已保存');`
extension AppToastContextExtension on BuildContext {
  AppToast get toast => AppToast(this);
}
