# pomelo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 提交
```txt
请根据当前已暂存改动，用中文生成一条 git commit message，格式：类型: 描述
```

## M.A.R.S. 架构分层调用指南

> 完整架构说明详见 [MARS_ARCHITECTURE.md](MARS_ARCHITECTURE.md)

本项目遵循 **M.A.R.S.** 模块化分层架构，核心三层的依赖关系遵循 **单向依赖** 原则：

```
  Provider (Riverpod 状态)
      │
      ▼
  Service (业务逻辑)
      │
      ▼
Repository (数据访问)
```

### 各层调用规则

| 调用方 | → Repository | → Service | → Provider |
|--------|:-----------:|:---------:|:----------:|
| **Repository** | — | ❌ 不允许 | ❌ 不允许 |
| **Service** | ✅ 构造函数注入 | — | ❌ 不允许 |
| **Provider** | ✅ 通过 Module 获取 | ✅ 通过 ref.watch/ref.read | — |
| **Module** (A → B) | ✅ 通过 ModuleManager | ✅ 通过 ModuleManager | ❌ 不允许 |

### 1. Service → Repository（构造函数注入）

```dart
class FavoriteService extends Service {
  final FavoriteRepository repository;

  // 通过构造函数注入 Repository
  FavoriteService(this.repository);

  Future<void> addFavorite(Song song) async {
    await repository.save(FavoriteItem(song: song));
  }

  Future<List<FavoriteItem>> getAll() async {
    return repository.fetchAll();
  }
}
```

Module 的 `onInit` 中完成装配：

```dart
class FavoriteModule extends Module {
  @override
  Future<void> onInit() async {
    await _repository.onInit();
    _service = FavoriteService(_repository); // 注入 Repository
    await _service.onInit();
  }
}
```

### 2. Provider → Service（ref.watch / ref.read）

```dart
// Provider 通过 ref.watch 获取 Service 实例
final logQueryProvider = FutureProvider.family<List<LogEntry>, LogQuery>((ref) async {
  final service = ref.watch(logServiceProvider);
  return service.query(query); // 调用 Service 方法
});

// 或通过 Module 间接获取
final musicProvidersProvider = FutureProvider<List<MusicProvider>>((ref) async {
  final module = ref.watch(musicModuleProvider);
  return module?.providers ?? [];
});
```

### 3. Provider → Repository（通过 Module 间接访问）

```dart
final musicSdkSongRepositoryProvider = Provider<InMemoryRepository<Song>>((ref) {
  // 通过 Module 实例获取其内部的 Repository
  return ref.watch(musicSdkModuleProvider).repository.songs;
});
```

### 4. 跨模块调用（Module → Module）

通过 `ModuleManager` 获取其他模块实例，再访问其公开的 `service` / `repository`：

```dart
// 方式一：在模块生命周期中
class MusicLocalModule extends Module {
  @override
  Future<void> onReady() async {
    final musicModule = ModuleManager().find<MusicModule>('music');
    musicModule?.register(_provider);
  }
}

// 方式二：在任意位置（如 Provider、UI 回调）
void someFunction() {
  final logModule = ModuleManager().find<LogModule>('log');
  logModule?.service.info('Tag', '消息内容');
}

// 方式三：懒加载模块触发（使用前确保模块已初始化）
await ModuleManager().lazyInit('favorite');
final favModule = ModuleManager().find<FavoriteModule>('favorite');
```

### 5. Provider 获取 Module 的两种方式

```dart
// 方式 A：main.dart 中 override 注入（适用于非 lazy 模块）
// —— 在 main.dart 中：
// audioPlayerModuleProvider.overrideWithValue(audioPlayerModule)
// —— 在 Provider 中：
final audioPlayerModuleProvider = Provider<AudioPlayerModule>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

// 方式 B：通过 ModuleManager 动态查找（适用于所有模块，包括 lazy 模块）
final musicModuleProvider = Provider<MusicModule?>((ref) {
  return ModuleManager().find<MusicModule>('music');
});
```

### 核心原则

| 原则 | 说明 |
|------|------|
| **单向依赖** | Provider → Service → Repository，绝不允许反向调用 |
| **构造函数注入** | Service 通过构造函数接收 Repository，由 Module 负责装配 |
| **Provider 作为 UI 出口** | UI 层只通过 `ref.watch` / `ref.read` 调用 Provider，不直接访问 Service/Repository |
| **模块间通过 ModuleManager** | 跨模块调用通过 `ModuleManager().find<T>(id)` 获取目标模块实例 |
| **Service 不依赖 Provider** | Service 是纯 Dart 类，不导入 Riverpod/hooks_riverpod |
| **Repository 仅关注数据** | Repository 只负责 CRUD，不包含业务逻辑 |