import 'dart:io';
import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/provider/server/pipeline.dart';
import 'package:pomelo/provider/server/router.dart';
import 'package:pomelo/services/audio_player/media.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:shelf/shelf_io.dart';

final serverProvider = FutureProvider((ref) async {
  // final enabledRemoteConnect = false;
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
    // enabledRemoteConnect
    //     ? InternetAddress.anyIPv4
    //     : InternetAddress.loopbackIPv4,
    // 绑定到所有网卡（anyIPv4），DLNA 渲染设备（局域网另一台设备）才能连回
    // 本机 HTTP 流服务器拉取音频；仅绑 loopback 会导致 iOS/macOS 投屏时设备
    // 连接被拒、投送失败（"投送就消失"）。
    InternetAddress.anyIPv4,
    PomeloMedia.serverPort,
  );

  AppLogger.log.t(
    '[server] Playback server at http://${server.address.host}:${server.port}',
  );

  ref.onDispose(() {
    server.close();
  });

  return (server: server, port: PomeloMedia.serverPort);
});
