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
