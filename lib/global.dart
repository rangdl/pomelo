import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/helper.dart';

import 'core/app/app.provider.dart';
import 'core/routers/router.provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

late String appName;
late Directory appDocumentsDir;
late ProviderContainer container;

Future<void> initialize() async {
  appName = 'Pomelo';
  appDocumentsDir = await getApplicationDocumentsDirectory();
  if (Helper.isWindows) {
    appDocumentsDir = Directory(join(appDocumentsDir.path, appName));
  }
  await appDocumentsDir.create(recursive: true);
}

Future<void> initializeProvider() async {
  await container.read(appSettingsAsyncProvider.future);
  await container.read(settingsNavsAsyncProvider.future);
}
