import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/app/app.provider.dart';

import '../../core/app/app.model.dart';

final settingsProvider = Provider<AppSettings>(
  (ref) => ref.watch(appSettingsProvider).value!,
);
