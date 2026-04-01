import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/helper.dart';

final navigatorKey = GlobalKey<NavigatorState>();

late String appName;
late Directory appDocumentsDir;

Future<void> initialize() async {
  appName = 'Pomelo';
  appDocumentsDir = await getApplicationDocumentsDirectory();
  if (Helper.isWindows) {
    appDocumentsDir = Directory(join(appDocumentsDir.path, appName));
  }
  await appDocumentsDir.create(recursive: true);
}
