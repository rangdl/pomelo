import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/settings/audio_quality.dart';
import '../../../shared/settings/cache_limit.dart';
import '../../../shared/settings/settings_store.dart';
import '../../../shared/settings/theme_color.dart';
import '../../../shared/settings/theme_mode.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/data/media_proxy_server.dart';
import '../../playback/presentation/playback_providers.dart';

/// 设置页:分组卡片列表(iOS 设置风格),含主题模式切换。
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// 正在执行的清理动作(按行控制 loading,不整页闪)。
  final Set<String> _clearing = {};

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
    final themeMode = ref.watch(themeModeOptionProvider);
    final themeColor = ref.watch(themeColorProvider);
    final quality = ref.watch(audioQualityProvider);
    final cacheLimit = ref.watch(cacheLimitProvider);
    final cacheUsage = ref.watch(cacheUsageProvider);
    final sleepAt = ref.watch(sleepTimerProvider);
    final scheme = Theme.of(context).colorScheme;

    // 超宽窗口限行宽,避免列表被拉满整屏。
    return CenteredMaxWidth(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          const SectionHeader('偏好'),
          GroupCard(
            children: [
              SettingsItem(
                icon: Icons.dark_mode_rounded,
                title: '主题模式',
                subtitle: _themeModeLabel(themeMode),
                onTap: () => _pickThemeMode(themeMode),
              ),
              SettingsItem(
                icon: Icons.palette_rounded,
                title: '主题色',
                subtitle: themeColor.label,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: themeColor.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
                onTap: () => _pickThemeColor(themeColor),
              ),
              SettingsItem(
                icon: Icons.graphic_eq_rounded,
                title: '默认音质',
                subtitle: quality.label,
                onTap: () => _pickQuality(quality),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('播放'),
          GroupCard(
            children: [
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
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('内容源'),
          GroupCard(
            children: [
              SettingsItem(
                icon: Icons.extension_rounded,
                title: '插件管理',
                subtitle: '安装、启停与更新插件（音源脚本自动兼容）',
                onTap: () => context.push('/plugins'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('存储'),
          GroupCard(
            children: [
              SettingsItem(
                icon: Icons.inventory_2_rounded,
                title: '缓存占用',
                subtitle: cacheUsage.when(
                  data: (usage) =>
                      '音频 ${_formatBytes(usage.audioBytes)} · '
                      '封面 ${_formatBytes(usage.coverBytes)}',
                  loading: () => '统计中…',
                  error: (_, _) => '统计失败',
                ),
              ),
              SettingsItem(
                icon: Icons.data_usage_rounded,
                title: '缓存上限',
                subtitle: cacheLimit.label,
                onTap: () => _pickCacheLimit(cacheLimit),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('清理缓存'),
          GroupCard(
            children: [
              _clearItem(
                key: 'audio',
                icon: Icons.audio_file_rounded,
                title: '清除音频缓存',
                subtitle: '删除边播边存的歌曲文件',
                label: '音频缓存',
                action: () async {
                  await MediaProxyServer.instance?.clearAudioCache();
                },
              ),
              _clearItem(
                key: 'cover',
                icon: Icons.image_rounded,
                title: '清除封面缓存',
                subtitle: '下次展示时重新下载',
                label: '封面缓存',
                action: () async {
                  await MediaProxyServer.instance?.clearCoverCache();
                },
              ),
              _clearItem(
                key: 'links',
                icon: Icons.link_off_rounded,
                title: '清除播放链接缓存',
                subtitle: '下次播放时重新向音源取链',
                label: '播放链接缓存',
                action: () async {
                  await MediaLinkCache.instance?.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('关于'),
          GroupCard(
            children: [
              const SettingsItem(
                icon: Icons.info_outline_rounded,
                title: 'Pomelo',
                subtitle: '本地优先的 Flutter 音乐播放器',
              ),
              SettingsItem(
                icon: Icons.folder_open_rounded,
                title: '数据目录',
                subtitle: '查看配置与缓存所在位置',
                onTap: _showDataDir,
              ),
              SettingsItem(
                icon: Icons.description_outlined,
                title: '开源许可',
                subtitle: '查看第三方库许可',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Pomelo',
                ),
              ),
            ],
          ),
        ],
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
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('音量'),
        content: StatefulBuilder(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('完成'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _volume = player.volume);
    await ref.read(settingsStoreProvider).patch({'volume': player.volume});
  }

  Future<void> _pickSpeed() async {
    final player = ref.read(audioPlayerProvider);
    const options = [0.75, 1.0, 1.25, 1.5, 2.0];
    final picked = await showDialog<double>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('播放速度'),
        children: [
          RadioGroup<double>(
            groupValue: _speed,
            onChanged: (selected) => Navigator.pop(ctx, selected),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final v in options)
                  RadioListTile<double>(
                    value: v,
                    title: Text('${v.toStringAsFixed(2)}x'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    await player.setSpeed(picked);
    setState(() => _speed = picked);
    await ref.read(settingsStoreProvider).patch({'speed': picked});
  }

  Future<void> _pickSleep() async {
    final active = ref.read(sleepTimerProvider) != null;
    final minutes = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('睡眠定时器'),
        children: [
          for (final m in const [15, 30, 45, 60, 90])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, m),
              child: Text('$m 分钟后暂停'),
            ),
          if (active)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 0),
              child: const Text('关闭定时器'),
            ),
        ],
      ),
    );
    if (minutes == null) return;
    final notifier = ref.read(sleepTimerProvider.notifier);
    if (minutes == 0) {
      notifier.cancel();
    } else {
      notifier.start(Duration(minutes: minutes));
    }
  }

  Future<void> _showDataDir() async {
    final dir = await getApplicationSupportDirectory();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('数据目录'),
        content: SelectableText(dir.path),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: dir.path));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('复制路径'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 清理行:破坏性操作不带箭头(不跳转),执行中显示行级转圈。
  Widget _clearItem({
    required String key,
    required IconData icon,
    required String title,
    required String subtitle,
    required String label,
    required Future<void> Function() action,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final busy = _clearing.contains(key);
    return SettingsItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      danger: true,
      showChevron: false,
      trailing: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.delete_outline_rounded, color: scheme.error),
      onTap: busy ? null : () => _clearCache(key, label, action),
    );
  }

  static String _themeModeLabel(ThemeModeOption mode) => switch (mode) {
    ThemeModeOption.system => '跟随系统',
    ThemeModeOption.light => '浅色模式',
    ThemeModeOption.dark => '深色模式',
  };

  Future<void> _pickThemeMode(ThemeModeOption current) async {
    final picked = await showSelectionSheet<ThemeModeOption>(
      context: context,
      title: '主题模式',
      current: current,
      options: [
        for (final mode in ThemeModeOption.values)
          SelectionOption(value: mode, label: _themeModeLabel(mode)),
      ],
    );
    if (picked != null) {
      await ref.read(themeModeOptionProvider.notifier).set(picked);
    }
  }

  /// 主题色选择弹层:色板网格,选中项打勾。
  Future<void> _pickThemeColor(AppThemeColor current) async {
    final picked = await showModalBottomSheet<AppThemeColor>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: Text(
                  '主题色',
                  style: TextStyle(
                    fontSize: AppText.heading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Wrap(
                spacing: AppSpacing.xl,
                runSpacing: AppSpacing.lg,
                alignment: WrapAlignment.center,
                children: [
                  for (final option in AppThemeColor.values)
                    _ColorSwatch(
                      color: option,
                      selected: option == current,
                      onTap: () => Navigator.pop(context, option),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      await ref.read(themeColorProvider.notifier).set(picked);
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

  Future<void> _pickCacheLimit(CacheLimitOption current) async {
    final picked = await showSelectionSheet<CacheLimitOption>(
      context: context,
      title: '缓存上限',
      current: current,
      options: [
        for (final option in CacheLimitOption.values)
          SelectionOption(value: option, label: option.label),
      ],
    );
    if (picked != null) {
      await ref.read(cacheLimitProvider.notifier).set(picked);
      ref.invalidate(cacheUsageProvider);
    }
  }

  /// 清理缓存:先二次确认,再按行统计 loading。
  Future<void> _clearCache(
    String key,
    String label,
    Future<void> Function() action,
  ) async {
    if (_clearing.contains(key)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: Text('清除$label'),
        content: const Text('清除后无法恢复，下次使用时会重新下载或向音源取链。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _clearing.add(key));
    try {
      await action();
      ref.invalidate(cacheUsageProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('已清除$label')));
      }
    } catch (e) {
      // 清理是破坏性操作：失败要明确告知，而不是静默失败。
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('清除$label 失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _clearing.remove(key));
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final text = unit == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(value >= 100 ? 0 : 1);
    return '$text ${units[unit]}';
  }
}

/// 当前缓存占用（打开设置页时统计一次）。
final cacheUsageProvider = FutureProvider.autoDispose<MediaCacheUsage>((
  ref,
) async {
  final server = MediaProxyServer.instance;
  if (server == null) return MediaCacheUsage.empty;
  return server.usage();
});

/// 主题色色板圆:44 直径,选中时中心打勾。
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final AppThemeColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.color,
              shape: BoxShape.circle,
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white)
                : null,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            color.label,
            style: TextStyle(
              fontSize: AppText.rowSubtitle,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
