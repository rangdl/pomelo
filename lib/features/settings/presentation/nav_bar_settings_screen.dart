import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/adaptive_app_shell.dart';
import '../../../shared/layout/nav_bar_capsule.dart';
import '../../../shared/layout/window_class.dart';
import '../../../shared/settings/nav_animation.dart';
import '../../../shared/settings/nav_bar_style.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';

/// 底部导航的样式设置：尺寸滑杆 + 动画风格 + 实时预览。
///
/// 预览用的 [NavBarCapsule] 与真实导航是同一个组件，且不传 onTap，
/// 所以点预览只会重放动画，不会真的切换分支。
class NavBarSettingsScreen extends ConsumerStatefulWidget {
  const NavBarSettingsScreen({super.key});

  @override
  ConsumerState<NavBarSettingsScreen> createState() =>
      _NavBarSettingsScreenState();
}

class _NavBarSettingsScreenState extends ConsumerState<NavBarSettingsScreen> {
  /// 预览当前高亮的标签（与真实导航分支无关）。
  int _previewIndex = 0;

  /// 递增后让预览重放一次动画。
  int _replayToken = 0;

  void _replay() {
    setState(() {
      // 交替在两个标签之间切换，方便看清过渡。
      _previewIndex = _previewIndex == 0 ? 1 : 0;
      _replayToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(navBarMetricsProvider);
    final style = ref.watch(navAnimationProvider);
    final notifier = ref.read(navBarMetricsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('底部导航'),
        actions: [
          TextButton(
            onPressed: () => notifier.set(const NavBarMetrics()),
            child: const Text('恢复默认'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: CenteredMaxWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.floatingPlayerInset,
          ),
          children: [
            // 预览放在最上面：改下面的滑杆能立刻看到效果。
            GroupCard(
              dividerIndent: 0,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 110,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: NavBarCapsule(
                              destinations: appNavDestinations,
                              currentIndex: _previewIndex,
                              metrics: metrics,
                              style: style,
                              replayToken: _replayToken,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: _replay,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                            ),
                            label: const Text('重放动画'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader('导航切换动画'),
            GroupCard(
              children: [
                SettingsItem(
                  icon: Icons.animation_rounded,
                  title: '动画风格',
                  subtitle: style.label,
                  onTap: () => _pickStyle(style),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader('尺寸'),
            GroupCard(
              dividerIndent: AppSpacing.lg,
              children: [
                _SliderItem(
                  label: '整体高度',
                  value: metrics.height,
                  min: 36,
                  max: 96,
                  unit: 'px',
                  onChanged: (v) => notifier.patch(height: v),
                ),
                _SliderItem(
                  label: '单项宽度',
                  value: metrics.itemWidth,
                  min: 40,
                  max: 120,
                  unit: 'px',
                  onChanged: (v) => notifier.patch(itemWidth: v),
                ),
                _SliderItem(
                  label: '与边缘间距',
                  value: metrics.inset,
                  min: 0,
                  max: 16,
                  unit: 'px',
                  onChanged: (v) => notifier.patch(inset: v),
                ),
                _SliderItem(
                  label: '图标大小',
                  value: metrics.iconSize,
                  min: 12,
                  max: 32,
                  unit: 'px',
                  onChanged: (v) => notifier.patch(iconSize: v),
                ),
                _SliderItem(
                  label: '文字大小',
                  value: metrics.fontSize,
                  min: 8,
                  max: 18,
                  unit: 'px',
                  onChanged: (v) => notifier.patch(fontSize: v),
                ),
                _SliderItem(
                  label: '图标与文字间距',
                  value: metrics.iconTextGap,
                  min: 0,
                  max: 12,
                  unit: 'px',
                  onChanged: (v) => notifier.patch(iconTextGap: v),
                ),
                _SliderItem(
                  label: '图标上边距',
                  value: metrics.iconTopPadding,
                  min: 0,
                  max: 24,
                  unit: 'px',
                  onChanged: (v) => notifier.patch(iconTopPadding: v),
                ),
                _SliderItem(
                  label: '文字下边距',
                  value: metrics.textBottomPadding,
                  min: 0,
                  max: 24,
                  unit: 'px',
                  onChanged: (v) => notifier.patch(textBottomPadding: v),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '高度不足时图标与文字会被裁切，可适当调大「整体高度」或减小上下边距。',
                style: TextStyle(
                  fontSize: AppText.rowSubtitle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStyle(NavAnimationStyle current) async {
    final picked = await showSelectionSheet<NavAnimationStyle>(
      context: context,
      title: '动画风格',
      current: current,
      description: '选完可用上方预览的「重放动画」查看效果。',
      options: [
        for (final style in NavAnimationStyle.values)
          SelectionOption(value: style, label: style.label),
      ],
    );
    if (picked != null) {
      await ref.read(navAnimationProvider.notifier).set(picked);
    }
  }
}

/// 带标题与数值的滑杆行。
class _SliderItem extends StatelessWidget {
  const _SliderItem({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit = '',
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppText.rowTitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(0)}$unit',
                style: TextStyle(
                  fontSize: AppText.rowSubtitle,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              // 去掉默认上下各 24 的触控留白，让滑杆行更紧凑。
              padding: const EdgeInsets.symmetric(horizontal: 8),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
