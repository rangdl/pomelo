import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

// import '../../core/env.dart';
import 'common.dart';

class AndroidBuildCommand extends Command with BuildCommandCommonSteps {
  @override
  String get description => "Build for android";

  @override
  String get name => "android";

  @override
  FutureOr? run() async {
    await bootstrap();

    // await shell.run("flutter build apk");
    await shell.run("""
      fastforge package --platform=android --targets apk --skip-clean
      """);

    stdout.writeln("✅ Built Android Apk and Appbundle");
  }
}
