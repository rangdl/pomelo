import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'playback.dart';

/// 构建服务器路由
Router buildServerRouter(ServerPlaybackRoutes playbackRoutes) {
  final router = Router();

  router.get("/ping", (request) => Response.ok("pong"));

  router.head("/stream/<trackId>", playbackRoutes.headStreamTrackId);
  router.get("/stream/<trackId>", playbackRoutes.getStreamTrackId);

  router.get("/playback/toggle-playback", playbackRoutes.togglePlayback);
  router.get("/playback/previous", playbackRoutes.previousTrack);
  router.get("/playback/next", playbackRoutes.nextTrack);

  // router.all("/ws", connectRoutes.websocket);

  return router;
}
