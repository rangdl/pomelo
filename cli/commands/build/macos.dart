import 'dart:async';

import 'package:args/command_runner.dart';

import 'common.dart';

class MacosBuildCommand extends Command with BuildCommandCommonSteps {
  @override
  String get description => "Macos Build command";

  @override
  String get name => "macos";

  @override
  FutureOr? run() async {
    await bootstrap();

    await shell.run("""
      fastforge package --platform=macos --targets dmg,zip --skip-clean
      """);
  }
}
