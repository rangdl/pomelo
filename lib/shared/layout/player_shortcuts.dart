import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/playback/application/player_actions.dart';
import '../../features/playback/presentation/playback_providers.dart';

/// 桌面端全局快捷键。
///
/// 包在 MaterialApp.builder 外层，整个应用共享；输入框等自身消费按键的控件
/// 会先拿到事件，不会误触发（例如在搜索框里按空格仍是输入空格）。
class PlayerShortcuts extends ConsumerWidget {
  const PlayerShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space): PlayerIntent(
          PlayerCommand.togglePlay,
        ),
        SingleActivator(LogicalKeyboardKey.arrowLeft): PlayerIntent(
          PlayerCommand.seekBackward,
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight): PlayerIntent(
          PlayerCommand.seekForward,
        ),
        SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            PlayerIntent(PlayerCommand.previous),
        SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            PlayerIntent(PlayerCommand.next),
        SingleActivator(LogicalKeyboardKey.keyM): PlayerIntent(
          PlayerCommand.toggleMute,
        ),
        SingleActivator(LogicalKeyboardKey.keyF, control: true): PlayerIntent(
          PlayerCommand.search,
        ),
        SingleActivator(LogicalKeyboardKey.keyK, control: true): PlayerIntent(
          PlayerCommand.search,
        ),
        SingleActivator(LogicalKeyboardKey.escape): PlayerIntent(
          PlayerCommand.escape,
        ),
        SingleActivator(LogicalKeyboardKey.digit1, control: true): PlayerIntent(
          PlayerCommand.branch,
          branch: 0,
        ),
        SingleActivator(LogicalKeyboardKey.digit2, control: true): PlayerIntent(
          PlayerCommand.branch,
          branch: 1,
        ),
        SingleActivator(LogicalKeyboardKey.digit3, control: true): PlayerIntent(
          PlayerCommand.branch,
          branch: 2,
        ),
      },
      child: Actions(
        actions: {
          PlayerIntent: CallbackAction<PlayerIntent>(
            onInvoke: (intent) {
              _run(context, ref, intent);
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }

  void _run(BuildContext context, WidgetRef ref, PlayerIntent intent) {
    final player = ref.read(audioPlayerProvider);
    final actions = ref.read(playerActionsProvider);
    switch (intent.command) {
      case PlayerCommand.togglePlay:
        actions.togglePlay();
      case PlayerCommand.seekBackward:
        final target = player.position - const Duration(seconds: 5);
        player.seek(target < Duration.zero ? Duration.zero : target);
      case PlayerCommand.seekForward:
        final target = player.position + const Duration(seconds: 5);
        if (player.duration > Duration.zero && target > player.duration) {
          player.seek(player.duration);
        } else {
          player.seek(target);
        }
      case PlayerCommand.previous:
        actions.skip(next: false);
      case PlayerCommand.next:
        actions.skip(next: true);
      case PlayerCommand.toggleMute:
        player.toggleMute();
      case PlayerCommand.search:
        context.push('/search');
      case PlayerCommand.escape:
        if (context.canPop()) context.pop();
      case PlayerCommand.branch:
        final branch = intent.branch;
        if (branch == null) return;
        context.go(switch (branch) {
          0 => '/',
          1 => '/library',
          _ => '/settings',
        });
    }
  }
}

/// 可执行的播放器命令。
enum PlayerCommand {
  togglePlay,
  seekBackward,
  seekForward,
  previous,
  next,
  toggleMute,
  search,
  escape,
  branch,
}

class PlayerIntent extends Intent {
  const PlayerIntent(this.command, {this.branch});

  final PlayerCommand command;

  /// 仅 [PlayerCommand.branch] 使用：目标导航分支。
  final int? branch;
}
