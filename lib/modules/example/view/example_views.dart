import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pomelo/core/routers/router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Example 模块 - 示例列表页
class ExListView extends StatelessWidget {
  const ExListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('示例', style: theme.textTheme.h4),
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('组件演示', style: theme.textTheme.h3),
            const SizedBox(height: 8),
            Text('shadcn/ui 组件使用示例', style: theme.textTheme.muted),
            const SizedBox(height: 24),
            ShadCard(
              title: const Text('示例1'),
              description: const Text('包含按钮、Toast 等交互组件'),
              trailing: ShadButton(
                onPressed: () =>
                    GoRouter.of(context).pushNamed(Routes.ex1.name),
                child: const Text('打开'),
              ),
            ),
            const SizedBox(height: 12),
            ShadCard(
              title: const Text('示例2'),
              description: const Text('导航回退演示'),
              trailing: ShadButton(
                onPressed: () =>
                    GoRouter.of(context).pushNamed(Routes.ex2.name),
                child: const Text('打开'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 模块 - 示例1详情页
class Ex1DetailView extends StatelessWidget {
  const Ex1DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('示例1', style: theme.textTheme.h4)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('按钮变体', style: theme.textTheme.h3),
            const SizedBox(height: 8),
            Text('shadcn/ui 提供了多种按钮样式', style: theme.textTheme.muted),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ShadButton(child: const Text('Primary'), onPressed: () {}),
                ShadButton.secondary(
                  child: const Text('Secondary'),
                  onPressed: () {},
                ),
                ShadButton.destructive(
                  child: const Text('Destructive'),
                  onPressed: () {},
                ),
                ShadButton.outline(
                  child: const Text('Outline'),
                  onPressed: () {},
                ),
                ShadButton.ghost(child: const Text('Ghost'), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 32),
            Text('Toast 通知', style: theme.textTheme.h3),
            const SizedBox(height: 8),
            Text('使用 ShadToaster.of(context) 触发', style: theme.textTheme.muted),
            const SizedBox(height: 16),
            ShadButton(
              leading: const Icon(LucideIcons.checkCircle, size: 16),
              onPressed: () {
                ShadToaster.of(context).show(
                  const ShadToast(
                    title: Text('操作成功'),
                    description: Text('Welcome back!'),
                  ),
                );
              },
              child: const Text('显示 Toast'),
            ),
            const SizedBox(height: 12),
            ShadButton.destructive(
              leading: const Icon(LucideIcons.alertCircle, size: 16),
              onPressed: () {
                ShadToaster.of(context).show(
                  const ShadToast.destructive(
                    title: Text('错误'),
                    description: Text('操作失败，请重试'),
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
class Ex2DetailView extends StatelessWidget {
  const Ex2DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('示例2', style: theme.textTheme.h4)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('路由导航', style: theme.textTheme.h3),
            const SizedBox(height: 8),
            Text('使用 GoRouter 进行页面导航', style: theme.textTheme.muted),
            const SizedBox(height: 24),
            ShadCard(
              title: const Text('页面返回'),
              description: const Text('点击按钮返回上一页'),
              trailing: ShadButton(
                leading: const Icon(LucideIcons.arrowLeft, size: 16),
                onPressed: () => GoRouter.of(context).pop(),
                child: const Text('返回'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
