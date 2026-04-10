import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/utils/platform.dart';

final navigatorKey = GlobalKey<NavigatorState>();

late String appName;
late Directory appDocumentsDir;
late ProviderContainer container;

Future<void> initialize() async {
  appName = 'Pomelo';
  appDocumentsDir = await getApplicationDocumentsDirectory();
  if (kIsWindows) {
    appDocumentsDir = Directory(join(appDocumentsDir.path, appName));
  }
  await appDocumentsDir.create(recursive: true);
}
