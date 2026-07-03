import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/database/app_database.dart';

/// 应用数据库 Provider（全局单例）
///
/// 在应用启动时初始化，提供 drift 数据库访问。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
