import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 关于页面
///
/// 展示应用名称、版本号、简介、技术栈与第三方依赖。
@RoutePage()
class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = useState<PackageInfo?>(null);

    useEffect(() {
      PackageInfo.fromPlatform().then((info) {
        packageInfo.value = info;
      });
      return null;
    }, []);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              density: ButtonDensity.icon,
              onPressed: () => context.router.maybePop(),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ],
          title: const Text('关于'),
        ),
      ],
      child: CenteredListView(
        maxWidth: 640,
        padding: const EdgeInsets.all(24),
        children: _buildChildren(context, packageInfo.value),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context, PackageInfo? info) {
    final colorScheme = Theme.of(context).colorScheme;
    final version = info == null ? '' : '${info.version} (${info.buildNumber})';

    return [
      // 应用标识区
      Center(
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const Gap(16),
            const Text(
              '柚子音乐',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const Gap(4),
            Text(
              info == null ? '加载中…' : 'v $version',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.mutedForeground,
              ),
            ),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '一个基于 Flutter 的多源音乐播放器，聚合本地音乐、Lx 在线音乐与 Subsonic 流媒体服务。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.mutedForeground,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
      const Gap(32),

      // 技术栈
      _SectionTitle(text: '技术栈'),
      const Gap(8),
      Card(
        child: Column(
          children: [
            _TechRow(
              icon: Icons.widgets_outlined,
              name: 'UI 框架',
              value: 'shadcn_flutter',
            ),
            const Divider(height: 1),
            _TechRow(
              icon: Icons.settings_input_component,
              name: '状态管理',
              value: 'Riverpod + flutter_hooks',
            ),
            const Divider(height: 1),
            _TechRow(icon: Icons.alt_route, name: '路由', value: 'auto_route'),
            const Divider(height: 1),
            _TechRow(
              icon: Icons.play_circle_outline,
              name: '播放引擎',
              value: 'media_kit',
            ),
            const Divider(height: 1),
            _TechRow(icon: Icons.storage, name: '本地存储', value: 'drift (SQLite)'),
          ],
        ),
      ),
      const Gap(24),

      // 功能特性
      _SectionTitle(text: '功能特性'),
      const Gap(8),
      Card(
        child: Column(
          children: [
            _FeatureRow(text: '多源音乐聚合（本地 / Lx Server / Subsonic）'),
            const Divider(height: 1),
            _FeatureRow(text: '响应式布局，适配移动端与桌面端'),
            const Divider(height: 1),
            _FeatureRow(text: '歌词滚动展示与播放队列管理'),
            const Divider(height: 1),
            _FeatureRow(text: '主题切换（跟随系统 / 浅色 / 深色）'),
            const Divider(height: 1),
            _FeatureRow(text: '内置本地 HTTP 流代理，支持外部播放器接入'),
          ],
        ),
      ),
      const Gap(24),

      // 版权
      Center(
        child: Text(
          '© ${DateTime.now().year} 柚子音乐',
          style: TextStyle(fontSize: 12, color: colorScheme.mutedForeground),
        ),
      ),
      const Gap(16),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.mutedForeground,
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String value;

  const _TechRow({required this.icon, required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(name),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.mutedForeground,
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;

  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.check_circle_outline,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
