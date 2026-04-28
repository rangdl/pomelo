import 'package:auto_route/auto_route.dart' hide TestRoute;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/collections/routes.gr.dart';
// import 'package:pomelo/provider/metadata_plugin/core/auth.dart';
// import 'package:pomelo/services/kv_store/kv_store.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  final WidgetRef ref;

  AppRouter(this.ref) : super(navigatorKey: rootNavigatorKey);

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: "/",
      page: RootAppRoute.page,
      initial: true,
      children: [
        AutoRoute(
          path: "home",
          page: HomeRoute.page,
          initial: true,
          // guards: [
          //   AutoRouteGuardCallback(
          //     (resolver, router) async {
          //       final authenticated = await ref
          //           .read(metadataPluginAuthenticatedProvider.future);
          //       if (!authenticated && !KVStoreService.doneGettingStarted) {
          //         resolver.redirect(const GettingStartedRoute());
          //       } else {
          //         resolver.next(true);
          //       }
          //     },
          //   ),
          // ],
        ),
        AutoRoute(
          path: "library",
          page: LibraryRoute.page,
          children: [
            // AutoRoute(
            //   path: "playlists",
            //   page: UserPlaylistsRoute.page,
            // ),
            // AutoRoute(
            //   path: "artists",
            //   page: UserArtistsRoute.page,
            // ),
            // AutoRoute(
            //   path: "albums",
            //   page: UserAlbumsRoute.page,
            // ),
            AutoRoute(path: "local", page: UserLocalLibraryRoute.page),
            AutoRoute(path: "downloads", page: UserDownloadsRoute.page),
          ],
        ),
        AutoRoute(path: "artist/:id", page: ArtistRoute.page),
        AutoRoute(path: "lyrics", page: LyricsRoute.page),
        AutoRoute(path: "settings", page: SettingsRoute.page),
        if (!kIsWeb) AutoRoute(path: "settings/logs", page: LogsRoute.page),

        AutoRoute(path: "test", page: TestRoute.page),
        AutoRoute(
          path: "CupertinoSliverRefreshDemoRoute",
          page: CupertinoSliverRefreshDemoRoute.page,
        ),
      ],
    ),
    CustomRoute(
      transitionsBuilder: TransitionsBuilders.slideBottom,
      durationInMilliseconds: 200,
      reverseDurationInMilliseconds: 200,
      path: "/player/queue",
      page: PlayerQueueRoute.page,
    ),
    CustomRoute(
      transitionsBuilder: TransitionsBuilders.slideBottom,
      durationInMilliseconds: 200,
      reverseDurationInMilliseconds: 200,
      path: "/player/lyrics",
      page: PlayerLyricsRoute.page,
    ),
    AutoRoute(
      path: "/mini-player",
      page: MiniLyricsRoute.page,
      // parentNavigatorKey: rootNavigatorKey,
    ),
  ];
}
