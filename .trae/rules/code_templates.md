# Pomelo 项目代码生成模板

## 概述

本文件包含用于代码生成的模板和模式，适用于 AI 辅助编码或代码生成器使用。

---

## 1. 页面组件模板

### 1.1 标准页面结构

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/framework/framework.dart';

@RoutePage()
class ${PageName}Page extends HookConsumerWidget {
  const ${PageName}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状态监听
    final items = ref.watch(${providerName}Provider);
    final isLoading = useState(false);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('${PageTitle}'),
          trailing: [
            IconButton.text(
              icon: const Icon(Icons.add),
              onPressed: () => _handleAdd(context),
            ),
          ],
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 内容区域
        ],
      ),
    );
  }
}
```

### 1.2 响应式页面结构

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/rx.dart';

@RoutePage()
class ${PageName}Page extends HookConsumerWidget {
  const ${PageName}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [
        AppBar(title: const Text('${PageTitle}')),
      ],
      child: Rx.layout(
        context,
        mobile: () => _MobileLayout(),
        tablet: () => _TabletLayout(),
        desktop: () => _DesktopLayout(),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: []);
  }
}

class _TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // 左侧栏
      SizedBox(width: 240, child: ...),
      const VerticalDivider(width: 1),
      // 主内容区
      const Expanded(child: ...),
    ]);
  }
}
```

---

## 2. 列表项组件模板

### 2.1 标准列表项

```dart
Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(Icons.${iconName}, size: 20),
        title: Text('${title}'),
        subtitle: Text('${subtitle}'),
        trailing: IconButton.text(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () => _handleDelete(),
        ),
      ),
      const Divider(height: 1),
    ],
  ),
)
```

### 2.2 可点击列表项

```dart
Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(Icons.${iconName}, size: 20),
        title: Text('${title}'),
        subtitle: Text('${subtitle}'),
        onTap: () => _handleTap(),
      ),
    ],
  ),
)
```

---

## 3. 按钮组件模板

### 3.1 文本按钮

```dart
// 主要操作
PrimaryButton(
  onPressed: () => _handleAction(),
  child: const Text('确认'),
)

// 次要操作
GhostButton(
  onPressed: () => Navigator.pop(context),
  child: const Text('取消'),
)
```

### 3.2 图标按钮

```dart
// 列表项内删除按钮
IconButton.text(
  icon: const Icon(Icons.close, size: 18),
  onPressed: () => _handleDelete(),
)

// 工具栏按钮
IconButton.ghost(
  icon: const Icon(Icons.add),
  onPressed: () => _handleAdd(),
)

// 危险操作
IconButton.destructive(
  icon: const Icon(Icons.delete),
  onPressed: () => _handleDelete(),
)
```

---

## 4. 表单组件模板

### 4.1 文本输入

```dart
TextField(
  placeholder: const Text('${placeholder}'),
  onSubmitted: (value) => _handleSubmit(value),
  features: [
    InputFeature.leading(const Icon(Icons.${iconName}, size: 18)),
  ],
)
```

### 4.2 下拉选择

```dart
Select<String>(
  value: selectedValue,
  onChanged: (value) => _handleChange(value),
  popup: SelectPopup(
    items: SelectItemList(
      children: [
        SelectItemButton(
          value: '${value1}',
          child: const Text('${label1}'),
        ),
      ],
    ),
  ).call,
)
```

---

## 5. 对话框组件模板

### 5.1 标准对话框

```dart
AlertDialog(
  title: const Text('${Title}'),
  content: SizedBox(
    width: 420,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 内容
      ],
    ),
  ),
  actions: [
    GhostButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('取消'),
    ),
    PrimaryButton(
      onPressed: () => _handleConfirm(),
      child: const Text('确认'),
    ),
  ],
)
```

### 5.2 响应式对话框/页面

```dart
// 在调用处使用
Rx.action(
  context,
  mobile: () => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ${PageName}Page()),
  ),
  tablet: () => showDialog(
    context: context,
    builder: (_) => const ${DialogName}Dialog(),
  ),
);
```

---

## 6. Provider 模板

### 6.1 NotifierProvider（状态管理）

```dart
final ${providerName}Provider = NotifierProvider<${NotifierName}, ${StateType}>(
  ${NotifierName}.new,
);

class ${NotifierName} extends Notifier<${StateType}> {
  @override
  ${StateType} build() {
    // 初始化状态
    return ${initialValue};
  }

  void update(${Params} params) {
    // 更新逻辑
    state = newValue;
  }
}
```

### 6.2 FutureProvider（异步数据）

```dart
final ${providerName}Provider = FutureProvider.autoDispose<${ReturnType}>(
  (ref) async {
    final service = ref.watch(${serviceProvider});
    return await service.fetchData();
  },
);

// 使用
final data = ref.watch(${providerName}Provider);
data.when(
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('加载失败: $e'),
  data: (data) => _buildContent(data),
);
```

---

## 7. 响应式布局模板

### 7.1 布局组件

```dart
Rx.layout(
  context,
  mobile: () => _MobileLayout(),   // < 600px
  tablet: () => _TabletLayout(),   // 600-1024px
  desktop: () => _DesktopLayout(), // 1024-1440px
)
```

### 7.2 动作分支

```dart
Rx.action(
  context,
  mobile: () {
    // 移动端操作
    Navigator.push(...);
  },
  tablet: () {
    // 桌面端操作
    showDialog(...);
  },
)
```

---

## 8. 状态管理模板

### 8.1 使用 useState（本地状态）

```dart
class _MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final count = useState(0);

    Future<void> doSomething() async {
      isLoading.value = true;
      // ... 异步操作
      isLoading.value = false;
    }

    return Container();
  }
}
```

### 8.2 使用 useEffect（副作用）

```dart
class _MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      // 初始化逻辑
      final subscription = stream.listen((event) {
        // 处理事件
      });

      // 清理函数
      return () => subscription.cancel();
    }, [dependency]);

    return Container();
  }
}
```

---

## 9. 多源错误处理模板

```dart
final results = await safeCallServices<${ReturnType}>(
  services,
  (service) => service.${methodName}(params),
  getId: (service) => service.sourceId,
  getName: (service) => service.sourceName,
);

// 处理成功结果
for (final success in results.successes) {
  // ...
}

// 处理失败
if (results.failures.isNotEmpty) {
  // 显示错误横幅
  ProviderErrorBanner(errors: results.failures);
}
```

---

## 10. AppChip 使用模板

### 10.1 标签筛选

```dart
AppChip(
  label: '${label}',
  isSelected: isSelected,
  onTap: () => _handleSelect(),
  fill: ${fill},
  borderRadius: ${borderRadius},
  fontSize: ${fontSize},
)
```

### 10.2 常用场景参数

| 场景 | fill | borderRadius | fontSize |
|------|------|-------------|----------|
| 父分类标签 | `true` | 18 | 13 |
| 子分类标签 | `false` | 14 | 12 |
| Tab 标签 | `true` | 8 | 13 |
| 排序标签 | `false` | 14 | 12 |

---

## 11. 导航模板

### 11.1 路由跳转

```dart
// 使用 auto_route
context.pushRoute(${RouteName}(param: value));

// 返回
context.router.maybePop();

// Material 跳转
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const ${PageName}Page()),
);
```

---

## 12. 导入规范模板

```dart
// UI 组件
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/framework/framework.dart';

// 状态管理
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// 路由
import 'package:auto_route/auto_route.dart';

// 响应式
import 'package:pomelo/core/rx.dart';

// 持久化
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/storage/storage_keys.dart';
```

---

## 13. 常见错误避免清单

| 错误 | 正确做法 |
|------|----------|
| 使用 `IconButton()` | 使用 `IconButton.text()` / `IconButton.ghost()` 等命名构造函数 |
| 使用 Material 的 `ListTile` | 使用 `package:pomelo/core/framework/framework.dart` 中的 `ListTile` |
| `ListTile` 单独使用 | `ListTile` 必须放在 `Card` 内部 |
| 使用 `SizedBox` 做间距 | 优先使用 `Gap()` |
| `AppBar.leading` 传单个 Widget | 传 `List<Widget>` |
| 页面继承 `StatelessWidget` | 优先继承 `HookConsumerWidget` |
| 编造不存在的组件 | 如 `ShadDialog`、`ShadButton` 等不存在 |
