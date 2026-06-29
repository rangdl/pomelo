import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 「播放全部」按钮
///
/// 点击后用提供的曲目列表替换当前播放队列并自动播放。
/// 列表为空时按钮自动禁用。
class PlayAllButton extends HookConsumerWidget {
  final List<Track> tracks;

  /// 起始播放索引，默认 0
  final int initialIndex;

  /// 按钮文案，默认「播放全部」
  final String? label;

  const PlayAllButton({
    required this.tracks,
    super.key,
    this.initialIndex = 0,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryButton(
      leading: const Icon(Icons.play_arrow, size: 18),
      enabled: tracks.isNotEmpty,
      onPressed: () => _playAll(ref),
      child: Text(label ?? '播放全部'),
    );
  }

  void _playAll(WidgetRef ref) {
    if (tracks.isEmpty) return;
    final notifier = ref.read(audioPlayerProvider.notifier);
    notifier.load(tracks, initialIndex: initialIndex, autoPlay: true);
    Rx.toast.success('开始播放：${tracks.length} 首');
  }
}
