# Pomelo 项目 UI 开发规范

## 技术栈

- **UI 框架**: shadcn_flutter
- **状态管理**: Riverpod (hooks_riverpod, flutter_riverpod)
- **路由**: auto_route
- **响应式布局**: Rx.layout()

## 核心组件使用规范

### 1. 页面容器

```dart
// 标准页面结构
@RoutePage()
class XxxPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('标题'),
          trailing: [...],  // 右侧操作按钮
        ),
      ],
      child: ListView(...),
    );
  }
}
```

### 2. 列表项布局

**必须使用自定义 ListTile**（来自 `pomelo/core/framework/framework.dart`）：

```dart
import 'package:pomelo/core/framework/framework.dart';

Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(Icons.xxx, size: 20),
        title: Text('标题'),
        subtitle: Text('副标题'),
        trailing: IconButton.text(
          icon: Icon(Icons.close, size: 18),
          onPressed: () {},
        ),
      ),
      if (需要分隔) const Divider(height: 1),
    ],
  ),
)
```

**注意**：
- `ListTile` 必须放在 `Card` 内部
- 多个列表项用 `Column` 包裹，中间用 `Divider(height: 1)` 分隔
- `ListTile` 的 `padding` 参数可自定义内边距

### 3. 按钮组件

#### 文本按钮
| 组件 | 用途 | 示例 |
|------|------|------|
| `GhostButton` | 次要操作、取消 | `GhostButton(onPressed: () {}, child: Text('取消'))` |
| `PrimaryButton` | 主要操作、确认 | `PrimaryButton(onPressed: () {}, child: Text('确认'))` |

#### IconButton（图标按钮）
shadcn_flutter 的 `IconButton` 通过命名构造函数区分样式，**必须使用命名构造函数**：

| 构造函数 | 样式 | 用途 |
|----------|------|------|
| `IconButton.text()` | 文本样式（最轻量） | 列表项内删除/关闭按钮 |
| `IconButton.ghost()` | 幽灵透明 | 工具栏次要操作 |
| `IconButton.outline()` | 边框样式 | 中等强调操作 |
| `IconButton.primary()` | 主色样式 | 主要操作 |
| `IconButton.secondary()` | 次要样式 | 次要操作 |
| `IconButton.destructive()` | 危险红色 | 删除确认 |
| `IconButton.link()` | 链接样式 | 跳转操作 |

```dart
// 正确用法 ✅
IconButton.text(
  icon: Icon(Icons.close, size: 18),
  onPressed: () {},
)

// 错误用法 ❌ - IconButton 需要 variance 参数，不能直接调用默认构造函数
IconButton(
  icon: Icon(Icons.close),
  onPressed: () {},
)
```

**注意**：不要与 Material 的 `IconButton` 混淆，shadcn_flutter 的 `IconButton` 必须指定样式变体（通过命名构造函数）。

### 4. 表单组件

```dart
// 下拉选择
Select<String>(
  value: selectedValue,
  onChanged: (value) { ... },
  popup: SelectPopup(
    items: SelectItemList(
      children: [
        SelectItemButton(value: 'option1', child: Text('选项1')),
      ],
    ),
  ).call,
)

// 文本输入
TextField(
  placeholder: const Text('搜索...'),
  onSubmitted: (value) { ... },
  features: [
    InputFeature.leading(Icon(Icons.search, size: 18)),
    InputFeature.trailing(IconButton(...)),
  ],
)
```

### 5. 对话框

```dart
AlertDialog(
  title: const Text('标题'),
  content: SizedBox(
    width: 420,  // 对话框宽度
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [...],
    ),
  ),
  actions: [
    GhostButton(onPressed: () => Navigator.pop(context), child: Text('取消')),
    PrimaryButton(onPressed: () {}, child: Text('确认')),
  ],
)
```

### 6. 间距组件

- `Gap(12)` - shadcn_flutter 提供的间距组件（优先使用）
- `SizedBox(height: 8)` - 标准 Flutter 间距
- `Divider(height: 1)` - 分隔线

### 7. 颜色主题

```dart
Theme.of(context).colorScheme.primary          // 主色
Theme.of(context).colorScheme.mutedForeground  // 次要文字
Theme.of(context).colorScheme.destructive      // 危险/删除
Theme.of(context).colorScheme.border           // 边框
Theme.of(context).colorScheme.mutedBackground  // 次要背景
```

### 8. 文本样式（TextExtension）

shadcn_flutter 提供 `TextExtension` 扩展，可以快速设置文本样式：

```dart
// 标题样式
Text('标题').h1()
Text('标题').h2()
Text('标题').h3()
Text('标题').h4()

// 段落样式
Text('正文').p()           // 标准段落
Text('引言').lead()        // 引导文本
Text('小字').small()       // 小号文本
Text('大字').large()       // 大号文本
Text('静音').muted()       // 次要文字（灰色）

// 字重样式
Text('粗体').bold()
Text('斜体').italic()

// 组合使用
Text('标题').h2().bold()
Text('说明').small().muted()
```

**注意**：这些扩展方法返回 `Text` Widget，可以直接作为子组件使用。

## 状态管理规范

### Provider 使用

```dart
// 监听状态
final data = ref.watch(xxxProvider);

// 读取状态（不监听）
final module = ref.read(xxxProvider);

// 异步数据处理
dataAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('错误: $e'),
  data: (data) => buildContent(data),
)
```

## 导航规范

```dart
// 路由跳转
context.pushRoute(XxxRoute(param: value));

// 返回
context.router.maybePop();

// 显示对话框
showDialog(
  context: context,
  builder: (_) => const XxxDialog(),
);
```

## 响应式布局

```dart
Rx.layout(
  context,
  mobile: () => MobileLayout(),   // < 600px
  tablet: () => TabletLayout(),   // 600-1024px
  desktop: () => DesktopLayout(), // >= 1024px
)
```

## 导入规范

```dart
// 必须导入
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/framework/framework.dart';  // 使用 ListTile 时

// 状态管理
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 或
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 路由
import 'package:auto_route/auto_route.dart';
```

## 常见错误避免

1. **不要使用 Material 的 ListTile** - 必须使用自定义的 `pomelo/core/framework/list_tile.dart`
2. **不要编造不存在的组件** - 如 `ShadDialog`、`ShadButton`、`ShadCard` 等
3. **IconButton 的正确用法** - 使用 `IconButton.text()` 而不是 `IconButton()`
4. **ListTile 必须在 Card 内** - 不要单独使用 ListTile
5. **间距优先使用 Gap** - 而不是 SizedBox

## 页面结构示例

```dart
@RoutePage()
class ExamplePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider);
    
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('示例页面'),
          trailing: [
            IconButton.text(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddDialog(context),
            ),
          ],
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  ListTile(
                    leading: Icon(Icons.item, size: 20),
                    title: Text(items[i].name),
                    subtitle: Text(items[i].description),
                    trailing: IconButton.text(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => _deleteItem(items[i].id),
                    ),
                  ),
                  if (i < items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```
