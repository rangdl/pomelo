import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/music/model/song.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 「播放全部」按钮
///
/// 点击后用提供的歌曲列表替换当前播放队列并自动播放。
/// 列表为空时按钮自动禁用。
class PlayAllButton extends HookConsumerWidget {
  final List<Song> songs;

  /// 起始播放索引，默认 0
  final int initialIndex;

  /// 按钮文案，默认「播放全部」
  final String? label;

  const PlayAllButton({
    required this.songs,
    super.key,
    this.initialIndex = 0,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryButton(
      leading: const Icon(Icons.play_arrow, size: 18),
      enabled: songs.isNotEmpty,
      onPressed: () => _playAll(ref),
      child: Text(label ?? '播放全部'),
    );
  }

  void _playAll(WidgetRef ref) {
    if (songs.isEmpty) return;
    final notifier = ref.read(audioPlayerProvider.notifier);
    notifier.load(songs, initialIndex: initialIndex, autoPlay: true);
    Rx.toast.success('开始播放：${songs.length} 首');
  }
}
