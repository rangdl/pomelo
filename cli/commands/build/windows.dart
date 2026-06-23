import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'common.dart';

class WindowsBuildCommand extends Command with BuildCommandCommonSteps {
  @override
  String get description => "Build Windows exe";

  @override
  String get name => "windows";

  Future<void> innoDependInstall() async {
    final innoDependencyPath = join(cwd.path, "build", "inno-depend");

    await shell.run(
      "git clone https://github.com/DomGries/InnoDependencyInstaller.git $innoDependencyPath",
    );
  }

  @override
  void run() async {
    await bootstrap();
    await innoDependInstall();

    await shell.run(
      "fastforge package --platform=windows --targets=exe,zip --skip-clean",
    );

    final ogExe = File(
      join(
        cwd.path,
        "dist",
        pubspec.version.toString(),
        "pomelo-${pubspec.version}-windows-setup.exe",
      ),
    );

    stdout.writeln("✅ Windows exe built at ${ogExe.path}");
  }
}
