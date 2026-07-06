import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 「播放全部」按钮
///
/// 根据 [UserPreference.overwritePlaylistOnPlay] 开关分流：
/// - false（默认）：将曲目列表添加到当前播放列表末尾并播放（不覆盖）
/// - true：覆盖当前播放列表
///
/// 列表为空时按钮自动禁用。会过滤掉本地文件已不存在的曲目并提示用户。
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
    final overwrite = ref.watch(
      userPreferenceProvider.select((p) => p.overwritePlaylistOnPlay),
    );
    return PrimaryButton(
      leading: const Icon(Icons.play_arrow, size: 18),
      enabled: tracks.isNotEmpty,
      onPressed: () => _playAll(context, ref, overwrite),
      child: Text(label ?? '播放全部'),
    );
  }

  Future<void> _playAll(
    BuildContext context,
    WidgetRef ref,
    bool overwrite,
  ) async {
    if (tracks.isEmpty) return;
    // 过滤掉本地文件不存在的曲目
    final valid = <Track>[];
    var missing = 0;
    for (final t in tracks) {
      if (t.isLocal && t.path != null) {
        if (!await File(t.path!).exists()) {
          missing++;
          continue;
        }
      }
      valid.add(t);
    }
    if (!context.mounted) return;
    if (valid.isEmpty) {
      context.toast.error('本地文件均不存在（共 $missing 首）');
      return;
    }
    final notifier = ref.read(audioPlayerProvider.notifier);
    // 调整 initialIndex 落在 valid 范围内
    final safeIndex = initialIndex.clamp(0, valid.length - 1);
    if (overwrite) {
      notifier.load(valid, initialIndex: safeIndex, autoPlay: true);
      context.toast.success(
        '开始播放：${valid.length} 首（覆盖队列）'
        '${missing > 0 ? "，跳过 $missing 首本地文件不存在" : ""}',
      );
    } else {
      notifier.playTracks(valid, initialIndex: safeIndex);
      context.toast.success(
        '已添加到播放列表：${valid.length} 首'
        '${missing > 0 ? "，跳过 $missing 首本地文件不存在" : ""}',
      );
    }
  }
}
