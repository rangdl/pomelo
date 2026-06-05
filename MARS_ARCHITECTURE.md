# M.A.R.S. 模块化架构模型

## 概述

**M.A.R.S.** 是一种专为 Flutter 应用设计的模块化分层架构模型，其名称源自四个核心层的首字母：

| 层级 | 全称 | 职责 |
|------|------|------|
| **M** | **Model** (数据模型) | 定义数据结构与业务实体 |
| **A** | **Action** (应用用例) | 编排业务流程，协调各层协作 |
| **R** | **Repository** (数据仓储) | 封装数据访问，隔离数据源 |
| **S** | **Service/State** (服务/状态) | 管理业务逻辑与响应式状态 |

## 架构图

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                      │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│   │ Module A  │  │ Module B  │  │ Module C  │     │
│   │   View    │  │   View    │  │   View    │     │
│   └─────┬─────┘  └─────┬─────┘  └─────┬─────┘     │
├─────────┼───────────────┼───────────────┼─────────┤
│    [Provider/Observer]  │   Riverpod 状态桥梁      │
├─────────┼───────────────┼───────────────┼─────────┤
│         ▼               ▼               ▼         │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│   │ Service  │  │ Service  │  │ Service  │     │ ← Action/Service 层
│   └─────┬─────┘  └─────┬─────┘  └─────┬─────┘     │
├─────────┼───────────────┼───────────────┼─────────┤
│         ▼               ▼               ▼         │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│   │Repository│  │Repository│  │Repository│     │ ← Repository 层
│   └─────┬─────┘  └─────┬─────┘  └─────┬─────┘     │
├─────────┼───────────────┼───────────────┼─────────┤
│         ▼               ▼               ▼         │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│   │  Model   │  │  Model   │  │  Model   │     │ ← Model 层
│   └──────────┘  └──────────┘  └──────────┘     │
├─────────────────────────────────────────────────┤
│              Data Sources                        │
│   ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐          │
│   │ API  │ │  DB  │ │ File │ │Memory│          │
│   └──────┘ └──────┘ └──────┘ └──────┘          │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
lib/
├── core/                          # 核心基础设施
│   ├── mars.dart                  # M.A.R.S. 核心导出
│   ├── module/
│   │   ├── module.dart            # Module 抽象基类
│   │   ├── module_manager.dart    # 模块管理器（拓扑排序、生命周期）
│   │   └── module_widget.dart     # 模块化应用入口组件
│   ├── repository/
│   │   └── repository.dart        # Repository + InMemoryRepository 基类
│   ├── service/
│   │   └── service.dart           # Service 抽象基类
│   ├── routers/                   # 路由系统
│   ├── providers/                 # 全局 Provider
│   ├── theme/                     # 主题
│   └── widgets/                   # 通用组件
│
├── modules/                       # M.A.R.S. 模块（按业务域拆分）
│   ├── modules.dart               # Barrel 导出
│   ├── home/                      # 首页模块
│   │   ├── home_module.dart       # 模块定义（Module 子类）
│   │   ├── model/                 # M - 数据模型
│   │   ├── repository/            # R - 数据仓储
│   │   ├── service/               # S - 业务服务
│   │   ├── providers/             # S - Riverpod 状态
│   │   └── view/                  # UI 视图
│   │
│   └── example/                   # 示例模块
│       ├── example_module.dart
│       ├── model/
│       ├── repository/
│       ├── providers/
│       └── view/
│
├── data/                          # 全局数据层（可选）
│   └── repository/                # 跨模块仓储
│
├── services/                      # 全局服务
├── collections/                   # 集合扩展
├── global.dart                    # 全局导航键
└── main.dart                      # 应用入口（模块初始化）
```

## 核心概念

### 1. Module（模块）

每个模块是一个自包含的业务单元，拥有完整的生命周期：

```dart
class HomeModule extends Module {
  @override
  String get id => 'home';

  @override
  String get displayName => '首页';

  @override
  List<String> get dependencies => []; // 依赖其他模块

  @override
  Future<void> onInit() async { /* 初始化 */ }

  @override
  Future<void> onReady() async { /* 就绪 */ }

  @override
  Future<void> onDispose() async { /* 销毁 */ }
}
```

### 2. ModuleManager（模块管理器）

负责自动处理：
- **依赖拓扑排序**：按依赖顺序初始化模块
- **循环依赖检测**：抛出 `CycleDependencyException`
- **生命周期管理**：`register → initAll → readyAll → disposeAll`

### 3. Repository（仓储）

抽象数据源，模块通过 Repository 访问数据，不直接依赖 API/DB：

```dart
class HomeRepository extends InMemoryRepository<HomeItem> {
  HomeRepository() : super(id: 'home_repo', idSelector: (item) => item.id);

  @override
  Future<void> onInit() async { /* 填充初始数据 */ }
}
```

### 4. 分层依赖规则

```
✅ 允许:  View → Provider → Repository → Model
✅ 允许:  View → Service  → Repository → Model
✅ 允许:  Module A → Module B (依赖)
❌ 禁止:  View → 直接访问 API/DB
❌ 禁止:  Repository → View
❌ 禁止:  循环依赖
```

## 与现有技术的整合

| 技术 | 在 M.A.R.S. 中的角色 |
|------|----------------------|
| **Riverpod** | Service/State 层的响应式状态管理 |
| **GoRouter** | 模块级路由注册 + 全局路由配置 |
| **BotToast** | 全局 Toast 通知 (Rx utility) |
| **flutter_hooks** | View 层局部状态管理 |

## 最佳实践

1. **模块粒度**：一个模块对应一个业务功能域（如首页、收藏、统计）
2. **依赖方向**：永远从外层依赖内层（View → Service → Repository → Model）
3. **状态管理**：优先使用 Riverpod Provider 管理状态，Service 只封装纯业务逻辑
4. **测试**：Repository 可替换为 MockRepository，方便单元测试
5. **路由**：每个模块可以有自己的 router 配置，由 ModuleRouteProvider 统一收集