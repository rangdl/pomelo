import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show ListTile;
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Example 模块 - 示例列表页
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
                title: const Text('示例2'),
                subtitle: const Text('导航回退演示'),
                trailing: PrimaryButton(
                  onPressed: () => context.pushRoute(const Ex2DetailRoute()),
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

/// Example 模块 - 示例1详情页
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
                  builder: (BuildContext context, ToastOverlay overlay) =>
                      Alert(
                        leading: const Icon(Icons.check_circle),
                        title: const Text('操作成功'),
                        content: const Text('Welcome back!'),
                      ),
                );
              },
              child: const Text('显示 Toast'),
            ),
            const Gap(12),
            DestructiveButton(
              leading: const Icon(Icons.error, size: 16),
              onPressed: () {
                showToast(
                  context: context,
                  builder: (BuildContext context, ToastOverlay overlay) =>
                      Alert(
                        leading: const Icon(Icons.error),
                        title: const Text('错误'),
                        content: const Text('操作失败，请重试'),
                      ),
                );
              },
              child: const Text('显示错误 Toast'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 模块 - 示例2详情页
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
            Text('路由导航'),
            const Gap(8),
            Text('使用 auto_route 进行页面导航'),
            const Gap(24),
            Card(
              child: ListTile(
                title: const Text('页面返回'),
                subtitle: const Text('点击按钮返回上一页'),
                trailing: PrimaryButton(
                  leading: const Icon(Icons.arrow_back, size: 16),
                  onPressed: () => context.maybePop(),
                  child: const Text('返回'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
