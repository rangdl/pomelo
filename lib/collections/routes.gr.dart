// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:pomelo/pages/artist/artist.dart' as _i1;
import 'package:pomelo/pages/home/home.dart' as _i3;
import 'package:pomelo/pages/library/user_local_tracks/user_local_tracks.dart'
    as _i8;
import 'package:pomelo/pages/player/queue.dart' as _i5;
import 'package:pomelo/pages/root/root_app.dart' as _i6;
import 'package:pomelo/pages/settings/logs.dart' as _i4;
import 'package:pomelo/pages/settings/settings.dart' as _i7;
import 'package:pomelo/pages/test/test.dart' as _i2;

/// generated route for
/// [_i1.ArtistPage]
class ArtistRoute extends _i9.PageRouteInfo<ArtistRouteArgs> {
  ArtistRoute({
    required String artistId,
    _i10.Key? key,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         ArtistRoute.name,
         args: ArtistRouteArgs(artistId: artistId, key: key),
         rawPathParams: {'id': artistId},
         initialChildren: children,
       );

  static const String name = 'ArtistRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ArtistRouteArgs>(
        orElse: () => ArtistRouteArgs(artistId: pathParams.getString('id')),
      );
      return _i1.ArtistPage(args.artistId, key: args.key);
    },
  );
}

class ArtistRouteArgs {
  const ArtistRouteArgs({required this.artistId, this.key});

  final String artistId;

  final _i10.Key? key;

  @override
  String toString() {
    return 'ArtistRouteArgs{artistId: $artistId, key: $key}';
  }
}

/// generated route for
/// [_i2.CupertinoSliverRefreshDemoPage]
class CupertinoSliverRefreshDemoRoute extends _i9.PageRouteInfo<void> {
  const CupertinoSliverRefreshDemoRoute({List<_i9.PageRouteInfo>? children})
    : super(CupertinoSliverRefreshDemoRoute.name, initialChildren: children);

  static const String name = 'CupertinoSliverRefreshDemoRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.CupertinoSliverRefreshDemoPage();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.LogsPage]
class LogsRoute extends _i9.PageRouteInfo<void> {
  const LogsRoute({List<_i9.PageRouteInfo>? children})
    : super(LogsRoute.name, initialChildren: children);

  static const String name = 'LogsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.LogsPage();
    },
  );
}

/// generated route for
/// [_i5.PlayerQueuePage]
class PlayerQueueRoute extends _i9.PageRouteInfo<void> {
  const PlayerQueueRoute({List<_i9.PageRouteInfo>? children})
    : super(PlayerQueueRoute.name, initialChildren: children);

  static const String name = 'PlayerQueueRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.PlayerQueuePage();
    },
  );
}

/// generated route for
/// [_i6.RootAppPage]
class RootAppRoute extends _i9.PageRouteInfo<void> {
  const RootAppRoute({List<_i9.PageRouteInfo>? children})
    : super(RootAppRoute.name, initialChildren: children);

  static const String name = 'RootAppRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.RootAppPage();
    },
  );
}

/// generated route for
/// [_i7.SettingsPage]
class SettingsRoute extends _i9.PageRouteInfo<void> {
  const SettingsRoute({List<_i9.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i7.SettingsPage();
    },
  );
}

/// generated route for
/// [_i2.TestPage]
class TestRoute extends _i9.PageRouteInfo<void> {
  const TestRoute({List<_i9.PageRouteInfo>? children})
    : super(TestRoute.name, initialChildren: children);

  static const String name = 'TestRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.TestPage();
    },
  );
}

/// generated route for
/// [_i8.UserLocalLibraryPage]
class UserLocalLibraryRoute extends _i9.PageRouteInfo<void> {
  const UserLocalLibraryRoute({List<_i9.PageRouteInfo>? children})
    : super(UserLocalLibraryRoute.name, initialChildren: children);

  static const String name = 'UserLocalLibraryRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i8.UserLocalLibraryPage();
    },
  );
}
