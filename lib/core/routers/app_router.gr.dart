// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:pomelo/core/models/metadata/metadata.dart' as _i15;
import 'package:pomelo/ui/example/example_page.dart' as _i4;
import 'package:pomelo/ui/home/home_page.dart' as _i5;
import 'package:pomelo/ui/log/log_page.dart' as _i6;
import 'package:pomelo/ui/music/album_detail_page.dart' as _i2;
import 'package:pomelo/ui/music/artist_detail_page.dart' as _i3;
import 'package:pomelo/ui/music/playlist_detail_page.dart' as _i9;
import 'package:pomelo/ui/music/search_page.dart' as _i7;
import 'package:pomelo/ui/player/playback_page.dart' as _i8;
import 'package:pomelo/ui/root/root_page.dart' as _i10;
import 'package:pomelo/ui/service/service_page.dart' as _i11;
import 'package:pomelo/ui/settings/about_page.dart' as _i1;
import 'package:pomelo/ui/settings/settings_page.dart' as _i12;
import 'package:shadcn_flutter/shadcn_flutter.dart' as _i14;

/// generated route for
/// [_i1.AboutPage]
class AboutRoute extends _i13.PageRouteInfo<void> {
  const AboutRoute({List<_i13.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutPage();
    },
  );
}

/// generated route for
/// [_i2.AlbumDetailPage]
class AlbumDetailRoute extends _i13.PageRouteInfo<AlbumDetailRouteArgs> {
  AlbumDetailRoute({
    _i14.Key? key,
    required String albumId,
    required String sourceId,
    required String albumName,
    String? coverUrl,
    String? artist,
    int? year,
    int songCount = 0,
    _i14.VoidCallback? onClose,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         AlbumDetailRoute.name,
         args: AlbumDetailRouteArgs(
           key: key,
           albumId: albumId,
           sourceId: sourceId,
           albumName: albumName,
           coverUrl: coverUrl,
           artist: artist,
           year: year,
           songCount: songCount,
           onClose: onClose,
         ),
         initialChildren: children,
       );

  static const String name = 'AlbumDetailRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AlbumDetailRouteArgs>();
      return _i2.AlbumDetailPage(
        key: args.key,
        albumId: args.albumId,
        sourceId: args.sourceId,
        albumName: args.albumName,
        coverUrl: args.coverUrl,
        artist: args.artist,
        year: args.year,
        songCount: args.songCount,
        onClose: args.onClose,
      );
    },
  );
}

class AlbumDetailRouteArgs {
  const AlbumDetailRouteArgs({
    this.key,
    required this.albumId,
    required this.sourceId,
    required this.albumName,
    this.coverUrl,
    this.artist,
    this.year,
    this.songCount = 0,
    this.onClose,
  });

  final _i14.Key? key;

  final String albumId;

  final String sourceId;

  final String albumName;

  final String? coverUrl;

  final String? artist;

  final int? year;

  final int songCount;

  final _i14.VoidCallback? onClose;

  @override
  String toString() {
    return 'AlbumDetailRouteArgs{key: $key, albumId: $albumId, sourceId: $sourceId, albumName: $albumName, coverUrl: $coverUrl, artist: $artist, year: $year, songCount: $songCount, onClose: $onClose}';
  }
}

/// generated route for
/// [_i3.ArtistDetailPage]
class ArtistDetailRoute extends _i13.PageRouteInfo<ArtistDetailRouteArgs> {
  ArtistDetailRoute({
    _i14.Key? key,
    required String artistId,
    required String sourceId,
    required String artistName,
    String? coverUrl,
    int albumCount = 0,
    _i14.VoidCallback? onClose,
    void Function(_i15.Album)? onOpenAlbum,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         ArtistDetailRoute.name,
         args: ArtistDetailRouteArgs(
           key: key,
           artistId: artistId,
           sourceId: sourceId,
           artistName: artistName,
           coverUrl: coverUrl,
           albumCount: albumCount,
           onClose: onClose,
           onOpenAlbum: onOpenAlbum,
         ),
         initialChildren: children,
       );

  static const String name = 'ArtistDetailRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArtistDetailRouteArgs>();
      return _i3.ArtistDetailPage(
        key: args.key,
        artistId: args.artistId,
        sourceId: args.sourceId,
        artistName: args.artistName,
        coverUrl: args.coverUrl,
        albumCount: args.albumCount,
        onClose: args.onClose,
        onOpenAlbum: args.onOpenAlbum,
      );
    },
  );
}

class ArtistDetailRouteArgs {
  const ArtistDetailRouteArgs({
    this.key,
    required this.artistId,
    required this.sourceId,
    required this.artistName,
    this.coverUrl,
    this.albumCount = 0,
    this.onClose,
    this.onOpenAlbum,
  });

  final _i14.Key? key;

  final String artistId;

  final String sourceId;

  final String artistName;

  final String? coverUrl;

  final int albumCount;

  final _i14.VoidCallback? onClose;

  final void Function(_i15.Album)? onOpenAlbum;

  @override
  String toString() {
    return 'ArtistDetailRouteArgs{key: $key, artistId: $artistId, sourceId: $sourceId, artistName: $artistName, coverUrl: $coverUrl, albumCount: $albumCount, onClose: $onClose, onOpenAlbum: $onOpenAlbum}';
  }
}

/// generated route for
/// [_i4.Ex1DetailView]
class Ex1DetailRoute extends _i13.PageRouteInfo<void> {
  const Ex1DetailRoute({List<_i13.PageRouteInfo>? children})
    : super(Ex1DetailRoute.name, initialChildren: children);

  static const String name = 'Ex1DetailRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i4.Ex1DetailView();
    },
  );
}

/// generated route for
/// [_i4.ExListPage]
class ExListRoute extends _i13.PageRouteInfo<void> {
  const ExListRoute({List<_i13.PageRouteInfo>? children})
    : super(ExListRoute.name, initialChildren: children);

  static const String name = 'ExListRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i4.ExListPage();
    },
  );
}

/// generated route for
/// [_i5.HomePage]
class HomeRoute extends _i13.PageRouteInfo<void> {
  const HomeRoute({List<_i13.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i5.HomePage();
    },
  );
}

/// generated route for
/// [_i6.LogPage]
class LogRoute extends _i13.PageRouteInfo<void> {
  const LogRoute({List<_i13.PageRouteInfo>? children})
    : super(LogRoute.name, initialChildren: children);

  static const String name = 'LogRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i6.LogPage();
    },
  );
}

/// generated route for
/// [_i7.MusicSearchPage]
class MusicSearchRoute extends _i13.PageRouteInfo<MusicSearchRouteArgs> {
  MusicSearchRoute({
    _i14.Key? key,
    String keyword = '',
    List<_i13.PageRouteInfo>? children,
  }) : super(
         MusicSearchRoute.name,
         args: MusicSearchRouteArgs(key: key, keyword: keyword),
         initialChildren: children,
       );

  static const String name = 'MusicSearchRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MusicSearchRouteArgs>(
        orElse: () => const MusicSearchRouteArgs(),
      );
      return _i7.MusicSearchPage(key: args.key, keyword: args.keyword);
    },
  );
}

class MusicSearchRouteArgs {
  const MusicSearchRouteArgs({this.key, this.keyword = ''});

  final _i14.Key? key;

  final String keyword;

  @override
  String toString() {
    return 'MusicSearchRouteArgs{key: $key, keyword: $keyword}';
  }
}

/// generated route for
/// [_i8.PlaybackPage]
class PlaybackRoute extends _i13.PageRouteInfo<void> {
  const PlaybackRoute({List<_i13.PageRouteInfo>? children})
    : super(PlaybackRoute.name, initialChildren: children);

  static const String name = 'PlaybackRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i8.PlaybackPage();
    },
  );
}

/// generated route for
/// [_i9.PlaylistDetailPage]
class PlaylistDetailRoute extends _i13.PageRouteInfo<PlaylistDetailRouteArgs> {
  PlaylistDetailRoute({
    _i14.Key? key,
    required String playlistId,
    required String sourceId,
    required String playlistName,
    String? coverUrl,
    String creator = '',
    _i14.VoidCallback? onClose,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         PlaylistDetailRoute.name,
         args: PlaylistDetailRouteArgs(
           key: key,
           playlistId: playlistId,
           sourceId: sourceId,
           playlistName: playlistName,
           coverUrl: coverUrl,
           creator: creator,
           onClose: onClose,
         ),
         initialChildren: children,
       );

  static const String name = 'PlaylistDetailRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PlaylistDetailRouteArgs>();
      return _i9.PlaylistDetailPage(
        key: args.key,
        playlistId: args.playlistId,
        sourceId: args.sourceId,
        playlistName: args.playlistName,
        coverUrl: args.coverUrl,
        creator: args.creator,
        onClose: args.onClose,
      );
    },
  );
}

class PlaylistDetailRouteArgs {
  const PlaylistDetailRouteArgs({
    this.key,
    required this.playlistId,
    required this.sourceId,
    required this.playlistName,
    this.coverUrl,
    this.creator = '',
    this.onClose,
  });

  final _i14.Key? key;

  final String playlistId;

  final String sourceId;

  final String playlistName;

  final String? coverUrl;

  final String creator;

  final _i14.VoidCallback? onClose;

  @override
  String toString() {
    return 'PlaylistDetailRouteArgs{key: $key, playlistId: $playlistId, sourceId: $sourceId, playlistName: $playlistName, coverUrl: $coverUrl, creator: $creator, onClose: $onClose}';
  }
}

/// generated route for
/// [_i10.RootPage]
class RootRoute extends _i13.PageRouteInfo<void> {
  const RootRoute({List<_i13.PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i10.RootPage();
    },
  );
}

/// generated route for
/// [_i11.ServicePage]
class ServiceRoute extends _i13.PageRouteInfo<void> {
  const ServiceRoute({List<_i13.PageRouteInfo>? children})
    : super(ServiceRoute.name, initialChildren: children);

  static const String name = 'ServiceRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i11.ServicePage();
    },
  );
}

/// generated route for
/// [_i12.SettingsPage]
class SettingsRoute extends _i13.PageRouteInfo<void> {
  const SettingsRoute({List<_i13.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i12.SettingsPage();
    },
  );
}
