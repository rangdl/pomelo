import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show ListTile;
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'js_engine_test_page.dart';

/// Example 页面 — 示例列表页
@RoutePage()
class ExListPage extends StatelessWidget {
  const ExListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(title: Text('示例')),
        const Divider(),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('组件演示'),
            const Gap(8),
            Text('shadcn_flutter 组件使用示例'),
            const Gap(24),
            Card(
              child: ListTile(
                title: const Text('示例1'),
                subtitle: const Text('包含按钮、Toast 等交互组件'),
                trailing: PrimaryButton(
                  onPressed: () => context.pushRoute(const Ex1DetailRoute()),
                  child: const Text('打开'),
                ),
              ),
            ),
            const Gap(12),
            Card(
              child: ListTile(
                title: const Text('示例3'),
                subtitle: const Text('JsEngine 引擎 (MD5/SHA256/AES)'),
                trailing: PrimaryButton(
                  onPressed: () => context.pushRoute(const JsEngineTestRoute()),
                  child: const Text('打开'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 页面 — 示例1详情页
@RoutePage()
class Ex1DetailView extends StatelessWidget {
  const Ex1DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [AppBar(title: Text('示例1'))],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('按钮变体'),
            const Gap(8),
            Text('shadcn_flutter 提供了多种按钮样式'),
            const Gap(24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                PrimaryButton(child: const Text('Primary'), onPressed: () {}),
                SecondaryButton(
                  child: const Text('Secondary'),
                  onPressed: () {},
                ),
                DestructiveButton(
                  child: const Text('Destructive'),
                  onPressed: () {},
                ),
                OutlineButton(child: const Text('Outline'), onPressed: () {}),
                GhostButton(child: const Text('Ghost'), onPressed: () {}),
              ],
            ),
            const Gap(32),
            Text('Toast 通知'),
            const Gap(8),
            Text('使用 showToast() 触发'),
            const Gap(16),
            PrimaryButton(
              leading: const Icon(Icons.check_circle, size: 16),
              onPressed: () {
                showToast(
                  context: context,
                  builder: (context, overlay) => Card(
                    child: ListTile(
                      title: Text('操作成功'),
                      subtitle: Text('这是一个 shadcn_flutter Toast'),
                    ),
                  ),
                );
              },
              child: const Text('显示 Toast'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 页面 — 示例2详情页（导航演示）
@RoutePage()
class Ex2DetailView extends StatelessWidget {
  const Ex2DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [AppBar(title: Text('示例2'))],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('导航示例'),
            const Gap(8),
            Text('返回上级页面'),
            const Gap(24),
            PrimaryButton(
              onPressed: () => context.router.pop(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
