import 'dart:io';
import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/audio_player/model/media.dart';
import 'package:shelf/shelf_io.dart';
import 'pipeline.dart';
import 'router.dart';

final serverProvider = FutureProvider((ref) async {
  final enabledRemoteConnect = true;
  // final enabledRemoteConnect = ref.watch(
  //   userPreferencesProvider.select((value) => value.enableConnect),
  // );
  final connectPort = -1;
  // final connectPort = ref.watch(
  //   userPreferencesProvider.select((value) => value.connectPort),
  // );
  final pipeline = ref.watch(pipelineProvider);
  final router = ref.watch(serverRouterProvider);

  // When connect port is -1, we need to generate a random port
  // but we shouldn't reset it if it's already been set (caused by a state change)
  if (connectPort == -1) {
    if (PomeloMedia.serverPort == 0) {
      final port = Random().nextInt(17500) + 5000;
      PomeloMedia.serverPort = port;
    }
  } else {
    PomeloMedia.serverPort = connectPort;
  }

  final server = await serve(
    pipeline.addHandler(router.call),
    enabledRemoteConnect
        ? InternetAddress.anyIPv4
        : InternetAddress.loopbackIPv4,
    PomeloMedia.serverPort,
  );

  print('Playback server at http://${server.address.host}:${server.port}');

  ref.onDispose(() {
    server.close();
  });

  return (server: server, port: PomeloMedia.serverPort);
});
