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
        AutoRoute(path: "settings", page: SettingsRoute.page),

        AutoRoute(path: "test", page: TestRoute.page),
      ],
    ),
  ];
}
