import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/settings/audio_quality.dart';
import '../../../shared/settings/lock_screen_lyric.dart';
import '../../../shared/settings/open_player_on_play.dart';
import '../../../shared/settings/theme_mode.dart';
import '../../../shared/settings/settings_store.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/presentation/playback_providers.dart';

/// 播放设置：音质、音量、速度、睡眠定时器、播放行为。
class PlaybackSettingsScreen extends ConsumerStatefulWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  ConsumerState<PlaybackSettingsScreen> createState() =>
      _PlaybackSettingsScreenState();
}

class _PlaybackSettingsScreenState
    extends ConsumerState<PlaybackSettingsScreen> {
  /// 当前音量/速度（本地镜像，改完立刻反映到副标题）。
  double _volume = 100;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    final player = ref.read(audioPlayerProvider);
    _volume = player.volume;
    _speed = player.speed;
  }

  @override
  Widget build(BuildContext context) {
    final quality = ref.watch(audioQualityProvider);
    final sleepAt = ref.watch(sleepTimerProvider);
    final openPlayerOnPlay = ref.watch(openPlayerOnPlayProvider);
    final lockLyricMode = ref.watch(lockScreenLyricModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('播放设置')),
      body: CenteredMaxWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.floatingPlayerInset,
          ),
          children: [
            const SectionHeader('播放'),
            GroupCard(
              children: [
                SettingsItem(
                  icon: Icons.graphic_eq_rounded,
                  title: '默认音质',
                  subtitle: quality.label,
                  onTap: () => _pickQuality(quality),
                ),
                SettingsItem(
                  icon: Icons.volume_up_rounded,
                  title: '音量',
                  subtitle: '${_volume.round()}%',
                  onTap: _pickVolume,
                ),
                SettingsItem(
                  icon: Icons.speed_rounded,
                  title: '播放速度',
                  subtitle: '${_speed.toStringAsFixed(2)}x',
                  onTap: _pickSpeed,
                ),
                SettingsItem(
                  icon: Icons.bedtime_rounded,
                  title: '睡眠定时器',
                  subtitle: _sleepLabel(sleepAt),
                  onTap: _pickSleep,
                ),
                SettingsItem(
                  icon: Icons.open_in_full_rounded,
                  title: '点击歌曲进入播放页',
                  subtitle: openPlayerOnPlay ? '开启' : '关闭',
                  showChevron: false,
                  trailing: Switch(
                    value: openPlayerOnPlay,
                    onChanged: (v) =>
                        ref.read(openPlayerOnPlayProvider.notifier).set(v),
                  ),
                  onTap: () => ref
                      .read(openPlayerOnPlayProvider.notifier)
                      .set(!openPlayerOnPlay),
                ),
                // 仅 iOS：控制中心 / 锁屏媒体卡是否显示歌词及所在位置。
                if (Platform.isIOS)
                  SettingsItem(
                    icon: Icons.lyrics_rounded,
                    title: '控制中心显示歌词',
                    subtitle: lockLyricMode.label,
                    onTap: () => _pickLockLyricMode(lockLyricMode),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 睡眠定时器副标题：显示剩余时间。
  String _sleepLabel(DateTime? at) {
    if (at == null) return '未开启';
    final left = at.difference(DateTime.now());
    if (left.isNegative) return '未开启';
    final minutes = (left.inSeconds / 60).ceil();
    return '约 $minutes 分钟后暂停';
  }

  Future<void> _pickVolume() async {
    final player = ref.read(audioPlayerProvider);
    var value = _volume;
    await showAppModal<void>(
      context: context,
      title: '音量',
      body: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Row(
          children: [
            const Icon(Icons.volume_down_rounded),
            Expanded(
              child: Slider(
                value: value,
                max: 100,
                onChanged: (v) {
                  setLocal(() => value = v);
                  player.setVolume(v);
                },
              ),
            ),
            SizedBox(
              width: 42,
              child: Text('${value.round()}%', textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
      actions: (ctx) => [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('完成'),
        ),
      ],
    );
    if (!mounted) return;
    setState(() => _volume = player.volume);
    await ref.read(settingsStoreProvider).patch({'volume': player.volume});
  }

  Future<void> _pickSpeed() async {
    final player = ref.read(audioPlayerProvider);
    const options = [0.75, 1.0, 1.25, 1.5, 2.0];
    final picked = await showSelectionSheet<double>(
      context: context,
      title: '播放速度',
      current: _speed,
      options: [
        for (final v in options)
          SelectionOption(value: v, label: '${v.toStringAsFixed(2)}x'),
      ],
    );
    if (picked == null || !mounted) return;
    await player.setSpeed(picked);
    setState(() => _speed = picked);
    await ref.read(settingsStoreProvider).patch({'speed': picked});
  }

  Future<void> _pickSleep() async {
    final active = ref.read(sleepTimerProvider) != null;
    final minutes = await showSelectionSheet<int>(
      context: context,
      title: '睡眠定时器',
      current: null,
      options: [
        for (final m in const [15, 30, 45, 60, 90])
          SelectionOption(value: m, label: '$m 分钟后暂停'),
        if (active) const SelectionOption(value: 0, label: '关闭定时器'),
      ],
    );
    if (minutes == null) return;
    final notifier = ref.read(sleepTimerProvider.notifier);
    if (minutes == 0) {
      notifier.cancel();
    } else {
      notifier.start(Duration(minutes: minutes));
    }
  }

  Future<void> _pickLockLyricMode(LockScreenLyricMode current) async {
    final picked = await showSelectionSheet<LockScreenLyricMode>(
      context: context,
      title: '控制中心显示歌词',
      current: current,
      options: [
        for (final m in LockScreenLyricMode.values)
          SelectionOption(value: m, label: m.label),
      ],
    );
    if (picked != null) {
      await ref.read(lockScreenLyricModeProvider.notifier).set(picked);
    }
  }

  Future<void> _pickQuality(AudioQuality current) async {
    final picked = await showSelectionSheet<AudioQuality>(
      context: context,
      title: '默认音质',
      current: current,
      options: [
        for (final q in AudioQuality.values)
          SelectionOption(value: q, label: q.label),
      ],
    );
    if (picked != null) {
      await ref.read(audioQualityProvider.notifier).set(picked);
    }
  }
}
