import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 循环模式的展示与循环切换规则（单一来源）
extension PlaylistModeUi on PlaylistMode {
  /// 点击「循环」按钮后的下一个模式：none → loop → single → none
  PlaylistMode get next => switch (this) {
    PlaylistMode.none => PlaylistMode.loop,
    PlaylistMode.loop => PlaylistMode.single,
    PlaylistMode.single => PlaylistMode.none,
  };

  /// 对应图标
  IconData get icon =>
      this == PlaylistMode.single ? Icons.repeat_one : Icons.repeat;

  /// 是否处于激活态（非「不循环」）
  bool get isActive => this != PlaylistMode.none;
}

/// 随机播放开关
///
/// 自订阅 `audioPlayerProvider` 的 shuffled 切面，状态变化只重建按钮本身。
class ShuffleToggleButton extends ConsumerWidget {
  final double size;

  const ShuffleToggleButton({super.key, this.size = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuffled = ref.watch(audioPlayerProvider.select((s) => s.shuffled));
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.ghost(
      icon: Icon(
        Icons.shuffle,
        size: size,
        color: shuffled ? colorScheme.primary : null,
      ),
      onPressed: () => audioPlayer.setShuffle(!shuffled),
    );
  }
}

/// 循环模式切换按钮
///
/// 自订阅 `audioPlayerProvider` 的 loopMode 切面，状态变化只重建按钮本身。
class LoopModeButton extends ConsumerWidget {
  final double size;

  const LoopModeButton({super.key, this.size = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loopMode = ref.watch(audioPlayerProvider.select((s) => s.loopMode));
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.ghost(
      icon: Icon(
        loopMode.icon,
        size: size,
        color: loopMode.isActive ? colorScheme.primary : null,
      ),
      onPressed: () => audioPlayer.setLoopMode(loopMode.next),
    );
  }
}
