/// M.A.R.S. 存储层
///
/// 提供两类存储能力:
/// 1. Settings — 全局运行时设置（KV，所有模块直接调用）
/// 2. PersistentRepository — 模块级持久化仓储（JSON 序列化，零迁移）
library;

export 'settings.dart';
export 'persistent_repository.dart';
