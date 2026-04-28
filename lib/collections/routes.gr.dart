// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:flutter/material.dart' as _i15;
import 'package:pomelo/pages/artist/artist.dart' as _i1;
import 'package:pomelo/pages/home/home.dart' as _i3;
import 'package:pomelo/pages/library/library.dart' as _i4;
import 'package:pomelo/pages/library/user_downloads.dart' as _i12;
import 'package:pomelo/pages/library/user_local_tracks/user_local_tracks.dart'
    as _i13;
import 'package:pomelo/pages/lyrics/lyrics.dart' as _i6;
import 'package:pomelo/pages/lyrics/mini_lyrics.dart' as _i7;
import 'package:pomelo/pages/player/lyrics.dart' as _i8;
import 'package:pomelo/pages/player/queue.dart' as _i9;
import 'package:pomelo/pages/root/root_app.dart' as _i10;
import 'package:pomelo/pages/settings/logs.dart' as _i5;
import 'package:pomelo/pages/settings/settings.dart' as _i11;
import 'package:pomelo/pages/test/test.dart' as _i2;
import 'package:shadcn_flutter/shadcn_flutter.dart' as _i16;

/// generated route for
/// [_i1.ArtistPage]
class ArtistRoute extends _i14.PageRouteInfo<ArtistRouteArgs> {
  ArtistRoute({
    required String artistId,
    _i15.Key? key,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         ArtistRoute.name,
         args: ArtistRouteArgs(artistId: artistId, key: key),
         rawPathParams: {'id': artistId},
         initialChildren: children,
       );

  static const String name = 'ArtistRoute';

  static _i14.PageInfo page = _i14.PageInfo(
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

  final _i15.Key? key;

  @override
  String toString() {
    return 'ArtistRouteArgs{artistId: $artistId, key: $key}';
  }
}

/// generated route for
/// [_i2.CupertinoSliverRefreshDemoPage]
class CupertinoSliverRefreshDemoRoute extends _i14.PageRouteInfo<void> {
  const CupertinoSliverRefreshDemoRoute({List<_i14.PageRouteInfo>? children})
    : super(CupertinoSliverRefreshDemoRoute.name, initialChildren: children);

  static const String name = 'CupertinoSliverRefreshDemoRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i2.CupertinoSliverRefreshDemoPage();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i14.PageRouteInfo<void> {
  const HomeRoute({List<_i14.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.LibraryPage]
class LibraryRoute extends _i14.PageRouteInfo<void> {
  const LibraryRoute({List<_i14.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i4.LibraryPage();
    },
  );
}

/// generated route for
/// [_i5.LogsPage]
class LogsRoute extends _i14.PageRouteInfo<void> {
  const LogsRoute({List<_i14.PageRouteInfo>? children})
    : super(LogsRoute.name, initialChildren: children);

  static const String name = 'LogsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i5.LogsPage();
    },
  );
}

/// generated route for
/// [_i6.LyricsPage]
class LyricsRoute extends _i14.PageRouteInfo<void> {
  const LyricsRoute({List<_i14.PageRouteInfo>? children})
    : super(LyricsRoute.name, initialChildren: children);

  static const String name = 'LyricsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i6.LyricsPage();
    },
  );
}

/// generated route for
/// [_i7.MiniLyricsPage]
class MiniLyricsRoute extends _i14.PageRouteInfo<MiniLyricsRouteArgs> {
  MiniLyricsRoute({
    _i16.Key? key,
    required _i16.Size prevSize,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         MiniLyricsRoute.name,
         args: MiniLyricsRouteArgs(key: key, prevSize: prevSize),
         initialChildren: children,
       );

  static const String name = 'MiniLyricsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MiniLyricsRouteArgs>();
      return _i7.MiniLyricsPage(key: args.key, prevSize: args.prevSize);
    },
  );
}

class MiniLyricsRouteArgs {
  const MiniLyricsRouteArgs({this.key, required this.prevSize});

  final _i16.Key? key;

  final _i16.Size prevSize;

  @override
  String toString() {
    return 'MiniLyricsRouteArgs{key: $key, prevSize: $prevSize}';
  }
}

/// generated route for
/// [_i8.PlayerLyricsPage]
class PlayerLyricsRoute extends _i14.PageRouteInfo<void> {
  const PlayerLyricsRoute({List<_i14.PageRouteInfo>? children})
    : super(PlayerLyricsRoute.name, initialChildren: children);

  static const String name = 'PlayerLyricsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i8.PlayerLyricsPage();
    },
  );
}

/// generated route for
/// [_i9.PlayerQueuePage]
class PlayerQueueRoute extends _i14.PageRouteInfo<void> {
  const PlayerQueueRoute({List<_i14.PageRouteInfo>? children})
    : super(PlayerQueueRoute.name, initialChildren: children);

  static const String name = 'PlayerQueueRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i9.PlayerQueuePage();
    },
  );
}

/// generated route for
/// [_i10.RootAppPage]
class RootAppRoute extends _i14.PageRouteInfo<void> {
  const RootAppRoute({List<_i14.PageRouteInfo>? children})
    : super(RootAppRoute.name, initialChildren: children);

  static const String name = 'RootAppRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i10.RootAppPage();
    },
  );
}

/// generated route for
/// [_i11.SettingsPage]
class SettingsRoute extends _i14.PageRouteInfo<void> {
  const SettingsRoute({List<_i14.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i11.SettingsPage();
    },
  );
}

/// generated route for
/// [_i2.TestPage]
class TestRoute extends _i14.PageRouteInfo<void> {
  const TestRoute({List<_i14.PageRouteInfo>? children})
    : super(TestRoute.name, initialChildren: children);

  static const String name = 'TestRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i2.TestPage();
    },
  );
}

/// generated route for
/// [_i12.UserDownloadsPage]
class UserDownloadsRoute extends _i14.PageRouteInfo<void> {
  const UserDownloadsRoute({List<_i14.PageRouteInfo>? children})
    : super(UserDownloadsRoute.name, initialChildren: children);

  static const String name = 'UserDownloadsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i12.UserDownloadsPage();
    },
  );
}

/// generated route for
/// [_i13.UserLocalLibraryPage]
class UserLocalLibraryRoute extends _i14.PageRouteInfo<void> {
  const UserLocalLibraryRoute({List<_i14.PageRouteInfo>? children})
    : super(UserLocalLibraryRoute.name, initialChildren: children);

  static const String name = 'UserLocalLibraryRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i13.UserLocalLibraryPage();
    },
  );
}
