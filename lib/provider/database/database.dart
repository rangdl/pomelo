import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/models/database/database.dart';

final databaseProvider = Provider((ref) => AppDatabase());
